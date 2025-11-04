import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/models/team_message_model.dart';
import '../data/team_chat_repository.dart';

class TeamChatState {
  final List<TeamMessage> messages; // ASC (oldest -> newest)
  final bool loading;
  final bool canLoadMore;
  final String? error;
  final Map<String, String> users; // userId -> display name

  const TeamChatState({
    required this.messages,
    required this.loading,
    required this.canLoadMore,
    required this.users,
    this.error,
  });

  TeamChatState copyWith({
    List<TeamMessage>? messages,
    bool? loading,
    bool? canLoadMore,
    Map<String, String>? users,
    String? error,
  }) => TeamChatState(
    messages: messages ?? this.messages,
    loading: loading ?? this.loading,
    canLoadMore: canLoadMore ?? this.canLoadMore,
    users: users ?? this.users,
    error: error,
  );

  factory TeamChatState.initial() => const TeamChatState(
    messages: [],
    loading: false,
    canLoadMore: true,
    users: {},
  );
}

class TeamChatNotifier extends StateNotifier<TeamChatState> {
  final TeamChatRepository _repo;
  final String teamId;
  StreamSubscription<dynamic>? _sub;

  TeamChatNotifier(this._repo, this.teamId) : super(TeamChatState.initial());

  Future<void> loadInitial() async {
    state = state.copyWith(loading: true, error: null);
    try {
      final items = await _repo.fetchLatest(teamId: teamId);
      // Fetch display names for involved users
      final ids = items.map((e) => e.userId).toSet();
      final names = await _repo.fetchUserNames(ids);
      state = state.copyWith(
        loading: false,
        messages: items,
        canLoadMore: items.length >= 50,
        users: {...state.users, ...names},
      );
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
    }
  }

  Future<void> loadMore() async {
    if (!state.canLoadMore || state.loading || state.messages.isEmpty) return;
    state = state.copyWith(loading: true, error: null);
    try {
      final oldest = state.messages.first.createdAt;
      final items = await _repo.fetchMore(teamId: teamId, before: oldest);
      final merged = [...items, ...state.messages];
      // Fetch any missing display names
      final missing =
          items
              .map((m) => m.userId)
              .where((id) => !state.users.containsKey(id))
              .toSet();
      Map<String, String> add = {};
      if (missing.isNotEmpty) {
        add = await _repo.fetchUserNames(missing);
      }
      state = state.copyWith(
        loading: false,
        messages: merged,
        canLoadMore: items.length >= 50,
        users: {...state.users, ...add},
      );
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
    }
  }

  void startRealtime() {
    _sub?.cancel();
    _sub = _repo.subscribeChanges(teamId: teamId).listen((change) {
      switch (change.op) {
        case 'insert':
          final msg = change.newMessage!;
          if (state.messages.any((m) => m.id == msg.id)) return;
          final idx = state.messages.indexWhere(
            (m) =>
                m.optimistic &&
                m.userId == msg.userId &&
                m.content == msg.content,
          );
          if (idx != -1) {
            final updatedList = [...state.messages];
            updatedList[idx] = msg.copyWith(optimistic: false, sending: false);
            if (!state.users.containsKey(msg.userId)) {
              _fetchAndMergeUser(msg.userId);
            }
            state = state.copyWith(messages: updatedList);
          } else {
            final updated = [...state.messages, msg];
            if (!state.users.containsKey(msg.userId)) {
              _fetchAndMergeUser(msg.userId);
            }
            state = state.copyWith(messages: updated);
          }
          break;
        case 'update':
          final newMsg = change.newMessage!;
          final idxU = state.messages.indexWhere((m) => m.id == newMsg.id);
          if (idxU != -1) {
            // Merge incoming content/editedAt and clear flags
            final prev = state.messages[idxU];
            final updatedList = [...state.messages];
            updatedList[idxU] = prev.copyWith(
              content: newMsg.content,
              editedAt: newMsg.editedAt,
              optimistic: false,
              sending: false,
              failed: false,
            );
            state = state.copyWith(messages: updatedList);
          } else {
            // If not found (e.g., pagination gap), append respecting ASC order
            final updated = [...state.messages, newMsg];
            state = state.copyWith(messages: updated);
          }
          if (!state.users.containsKey(newMsg.userId)) {
            _fetchAndMergeUser(newMsg.userId);
          }
          break;
        case 'delete':
          final oldMsg = change.oldMessage!;
          final idxD = state.messages.indexWhere((m) => m.id == oldMsg.id);
          if (idxD != -1) {
            final updatedList = [...state.messages]..removeAt(idxD);
            state = state.copyWith(messages: updatedList);
          }
          break;
      }
    });
  }

  Future<void> _fetchAndMergeUser(String userId) async {
    try {
      final map = await _repo.fetchUserNames({userId});
      if (map.isNotEmpty) {
        state = state.copyWith(users: {...state.users, ...map});
      }
    } catch (_) {}
  }

  Future<void> send(String content) async {
    if (content.trim().isEmpty) return;
    // Optimistic UI: create a local temp message
    final temp = TeamMessage(
      id: 'temp-${DateTime.now().microsecondsSinceEpoch}',
      teamId: teamId,
      userId: _repo.currentUserId ?? 'me',
      content: content,
      createdAt: DateTime.now().toUtc(),
      optimistic: true,
      sending: true,
    );
    state = state.copyWith(messages: [...state.messages, temp]);

    try {
      final newId = await _repo.send(teamId: teamId, content: content);
      // Replace optimistic temp with server id, mark as sent
      final idx = state.messages.indexWhere((m) => m.id == temp.id);
      if (idx != -1) {
        final updatedList = [...state.messages];
        updatedList[idx] = temp.copyWith(
          id: newId,
          optimistic: false,
          sending: false,
        );
        state = state.copyWith(messages: updatedList);
      }
    } catch (e) {
      // Mark optimistic as failed, keep visible with retry option
      final idx = state.messages.indexWhere((m) => m.id == temp.id);
      if (idx != -1) {
        final updatedList = [...state.messages];
        updatedList[idx] = temp.copyWith(sending: false, failed: true);
        state = state.copyWith(messages: updatedList, error: e.toString());
      } else {
        state = state.copyWith(error: e.toString());
      }
      rethrow;
    }
  }

  Future<void> retrySend(TeamMessage msg) async {
    if (!msg.failed) return;
    final idx = state.messages.indexWhere((m) => m.id == msg.id);
    if (idx == -1) return;
    // Mark sending
    final updatedList = [...state.messages];
    updatedList[idx] = msg.copyWith(sending: true, failed: false);
    state = state.copyWith(messages: updatedList, error: null);

    try {
      final newId = await _repo.send(teamId: teamId, content: msg.content);
      updatedList[idx] = msg.copyWith(
        id: newId,
        optimistic: false,
        sending: false,
      );
      state = state.copyWith(messages: updatedList);
    } catch (e) {
      updatedList[idx] = msg.copyWith(sending: false, failed: true);
      state = state.copyWith(messages: updatedList, error: e.toString());
    }
  }

  Future<void> updateContent({
    required String messageId,
    required String newContent,
  }) async {
    // Optimistic update of content
    final idx = state.messages.indexWhere((m) => m.id == messageId);
    if (idx == -1) return;
    final prev = state.messages[idx];
    final updatedList = [...state.messages];
    updatedList[idx] = prev.copyWith(content: newContent, sending: true);
    state = state.copyWith(messages: updatedList, error: null);
    try {
      await _repo.updateMessage(messageId: messageId, newContent: newContent);
      // Server will set edited_at trigger; we can clear sending flag
      updatedList[idx] = updatedList[idx].copyWith(
        sending: false,
        optimistic: false,
      );
      state = state.copyWith(messages: updatedList);
    } catch (e) {
      // Revert on error
      updatedList[idx] = prev.copyWith(failed: true);
      state = state.copyWith(messages: updatedList, error: e.toString());
    }
  }

  Future<void> deleteMessage(String messageId) async {
    final idx = state.messages.indexWhere((m) => m.id == messageId);
    if (idx == -1) return;
    final prev = state.messages[idx];
    final updatedList = [...state.messages]..removeAt(idx);
    state = state.copyWith(messages: updatedList, error: null);
    try {
      await _repo.deleteMessage(messageId: messageId);
    } catch (e) {
      // Revert on error
      final revertList = [...state.messages];
      // Re-insert at original position if still valid
      if (idx <= revertList.length) {
        revertList.insert(idx, prev);
      } else {
        revertList.add(prev);
      }
      state = state.copyWith(messages: revertList, error: e.toString());
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}

final teamChatNotifierProvider =
    StateNotifierProvider.family<TeamChatNotifier, TeamChatState, String>((
      ref,
      teamId,
    ) {
      final repo = ref.read(teamChatRepositoryProvider);
      final notifier = TeamChatNotifier(repo, teamId);
      // Lazy init: caller should call loadInitial() and startRealtime()
      return notifier;
    });
