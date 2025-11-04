import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';

import '../../providers/team_chat_providers.dart';
import '../../data/team_chat_repository.dart';
import '../../../notifications/presentation/providers/notifications_providers.dart';
import '../../data/players_service.dart';

class TeamChatPage extends ConsumerStatefulWidget {
  final String teamId;
  const TeamChatPage({super.key, required this.teamId});

  @override
  ConsumerState<TeamChatPage> createState() => _TeamChatPageState();
}

class _TeamChatPageState extends ConsumerState<TeamChatPage> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  int _unread = 0;
  bool _nearBottom = true;

  @override
  void initState() {
    super.initState();
    // Diferir la carga inicial para no modificar providers durante el build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Verificar membresía antes de cargar chat
      ref.read(isTeamMemberProvider(widget.teamId).future).then((isMember) {
        if (!mounted) return;
        if (isMember != true) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No perteneces a este equipo'),
              backgroundColor: Colors.red,
            ),
          );
          // Redirigir a Equipos
          context.go('/teams');
          return;
        }

        final notifier = ref.read(
          teamChatNotifierProvider(widget.teamId).notifier,
        );
        notifier.loadInitial();
        notifier.startRealtime();
        // Marcar visto al abrir el chat y refrescar badge
        final repo = ref.read(teamChatRepositoryProvider);
        repo.setLastSeen(widget.teamId);
        ref.invalidate(notificationsBadgeCountProvider);
      });
    });

    // Escuchar cambios de scroll para detectar si está cerca del final
    _scrollController.addListener(() {
      final pos = _scrollController.position;
      // Con reverse:true, el final visual (nuevo) es minScrollExtent
      _nearBottom = (pos.pixels <= (pos.minScrollExtent + 50));
      if (_nearBottom && _unread != 0) {
        setState(() => _unread = 0);
        // Marcar mensajes como leídos para este equipo
        final repo = ref.read(teamChatRepositoryProvider);
        repo.setLastSeen(widget.teamId);
        // Refrescar badge de notificaciones
        ref.invalidate(notificationsBadgeCountProvider);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  String _relativeTime(DateTime ts) {
    final now = DateTime.now().toUtc();
    final diff = now.difference(ts);
    if (diff.inSeconds < 60) return 'ahora';
    if (diff.inMinutes < 60) return '${diff.inMinutes} min';
    if (diff.inHours < 24) return '${diff.inHours} h';
    return '${diff.inDays} d';
  }

  @override
  Widget build(BuildContext context) {
    // Listener para contar no leídos cuando llegan mensajes y no estamos al fondo
    ref.listen(teamChatNotifierProvider(widget.teamId), (prev, next) {
      final prevLen = prev?.messages.length ?? 0;
      final nextLen = next.messages.length;
      if (nextLen > prevLen && !_nearBottom) {
        final added = nextLen - prevLen;
        if (added > 0 && mounted) {
          setState(() => _unread += added);
        }
      }
    });

    // Si no es miembro, podríamos opcionalmente mostrar un placeholder
    final state = ref.watch(teamChatNotifierProvider(widget.teamId));
    final notifier = ref.read(teamChatNotifierProvider(widget.teamId).notifier);
    final myId = Supabase.instance.client.auth.currentUser?.id;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat del equipo'),
        actions: [
          // Bell de notificaciones también visible en el Chat
          Consumer(
            builder: (context, ref, _) {
              final countAsync = ref.watch(notificationsBadgeCountProvider);
              final count = countAsync.asData?.value ?? 0;
              return InkWell(
                borderRadius: BorderRadius.circular(24),
                onTap: () => context.push('/notifications'),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12.0),
                      child: Icon(Icons.notifications, size: 24),
                    ),
                    if (count > 0)
                      Positioned(
                        right: 6,
                        top: 6,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFF6F00),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            count > 99 ? '99+' : '$count',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: NotificationListener<ScrollNotification>(
              onNotification: (n) {
                if (n is ScrollUpdateNotification ||
                    n is ScrollEndNotification) {
                  final pos = _scrollController.position;
                  // Umbral de 80px para cargar más (parte alta: mensajes antiguos)
                  final nearTop = (pos.maxScrollExtent - pos.pixels) <= 80.0;
                  if (nearTop) {
                    notifier.loadMore();
                  }
                }
                return false;
              },
              child: ListView.builder(
                controller: _scrollController,
                reverse: true, // newest at bottom; reverse to show from end
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                itemCount: state.messages.length + (state.loading ? 1 : 0),
                itemBuilder: (context, index) {
                  if (state.loading && index == state.messages.length) {
                    return const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  final msg = state.messages.reversed.toList()[index];
                  final isMine = (myId != null && msg.userId == myId);
                  return Align(
                    alignment:
                        isMine ? Alignment.centerRight : Alignment.centerLeft,
                    child: GestureDetector(
                      onLongPress: () async {
                        await _showMessageActions(
                          context,
                          notifier,
                          msg,
                          isMine,
                        );
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color:
                              isMine
                                  ? const Color(0xFF2E7D32).withOpacity(0.9)
                                  : const Color(0xFFF1F3F5),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Nombre del remitente
                            Padding(
                              padding: const EdgeInsets.only(bottom: 2),
                              child: Text(
                                isMine
                                    ? 'Tú'
                                    : (state.users[msg.userId] ??
                                        msg.userId.substring(0, 8)),
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color:
                                      isMine
                                          ? Colors.white70
                                          : const Color(0xFF2E7D32),
                                ),
                              ),
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Flexible(
                                  child: Text(
                                    msg.content,
                                    style: TextStyle(
                                      color:
                                          isMine ? Colors.white : Colors.black,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                if (isMine) ...[
                                  if (msg.failed)
                                    const Icon(
                                      Icons.error,
                                      size: 14,
                                      color: Colors.redAccent,
                                    )
                                  else if (msg.sending)
                                    const SizedBox(
                                      width: 14,
                                      height: 14,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white70,
                                      ),
                                    )
                                  else
                                    const Icon(
                                      Icons.check,
                                      size: 14,
                                      color: Colors.white70,
                                    ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  _relativeTime(msg.createdAt),
                                  style: TextStyle(
                                    fontSize: 11,
                                    color:
                                        isMine
                                            ? Colors.white70
                                            : Colors.grey.shade600,
                                  ),
                                ),
                                if (msg.editedAt != null) ...[
                                  const SizedBox(width: 6),
                                  Text(
                                    '(editado)',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontStyle: FontStyle.italic,
                                      color:
                                          isMine
                                              ? Colors.white70
                                              : Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      minLines: 1,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        hintText: 'Escribe un mensaje...',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: () async {
                      final text = _controller.text.trim();
                      if (text.isEmpty) return;
                      _controller.clear();
                      await notifier.send(text);
                      // Al enviar, estamos al día: marcar leído e invalidar badge
                      final repo = ref.read(teamChatRepositoryProvider);
                      await repo.setLastSeen(widget.teamId);
                      ref.invalidate(notificationsBadgeCountProvider);
                    },
                    color: const Color(0xFF2E7D32),
                  ),
                ],
              ),
            ),
          ),
          // Botón "Ir al final" con contador de no leídos
          if (!_nearBottom || _unread > 0)
            SafeArea(
              child: Align(
                alignment: Alignment.bottomRight,
                child: Padding(
                  padding: const EdgeInsets.only(right: 12, bottom: 76),
                  child: FloatingActionButton.extended(
                    heroTag: 'scroll_bottom',
                    onPressed: () {
                      _scrollController.animateTo(
                        _scrollController.position.minScrollExtent,
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeOut,
                      );
                      setState(() => _unread = 0);
                      final repo = ref.read(teamChatRepositoryProvider);
                      repo.setLastSeen(widget.teamId);
                      ref.invalidate(notificationsBadgeCountProvider);
                    },
                    backgroundColor: const Color(0xFF2E7D32),
                    icon: const Icon(Icons.arrow_downward, color: Colors.white),
                    label: Text(
                      _unread > 0 ? '$_unread nuevos' : 'Ir al final',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _showMessageActions(
    BuildContext context,
    dynamic notifier,
    dynamic msg,
    bool isMine,
  ) async {
    final theme = Theme.of(context);
    await showModalBottomSheet(
      context: context,
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.copy),
                title: const Text('Copiar'),
                onTap: () {
                  Navigator.pop(ctx);
                  Clipboard.setData(ClipboardData(text: msg.content));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Mensaje copiado')),
                  );
                },
              ),
              if (isMine) ...[
                ListTile(
                  leading: const Icon(Icons.edit),
                  title: const Text('Editar'),
                  onTap: () async {
                    Navigator.pop(ctx);
                    final newContent = await _promptEdit(context, msg.content);
                    if (newContent != null && newContent.trim().isNotEmpty) {
                      await notifier.updateContent(
                        messageId: msg.id,
                        newContent: newContent.trim(),
                      );
                    }
                  },
                ),
                ListTile(
                  leading: Icon(Icons.delete, color: theme.colorScheme.error),
                  title: Text(
                    'Eliminar',
                    style: TextStyle(color: theme.colorScheme.error),
                  ),
                  onTap: () async {
                    Navigator.pop(ctx);
                    await notifier.deleteMessage(msg.id);
                  },
                ),
                if (msg.failed)
                  ListTile(
                    leading: const Icon(Icons.refresh),
                    title: const Text('Reintentar envío'),
                    onTap: () async {
                      Navigator.pop(ctx);
                      await notifier.retrySend(msg);
                    },
                  ),
              ],
            ],
          ),
        );
      },
    );
  }

  Future<String?> _promptEdit(BuildContext context, String initial) async {
    final c = TextEditingController(text: initial);
    return showDialog<String>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Editar mensaje'),
            content: TextField(
              controller: c,
              minLines: 1,
              maxLines: 5,
              decoration: const InputDecoration(border: OutlineInputBorder()),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(ctx, c.text),
                child: const Text('Guardar'),
              ),
            ],
          ),
    );
  }
}
