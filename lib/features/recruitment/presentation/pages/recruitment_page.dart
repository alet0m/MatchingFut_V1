import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/models/recruitment_models.dart';
import '../../data/providers/recruitment_provider.dart';
import 'create_recruitment_post_page.dart';
import 'player_profile_page.dart';
import 'recruitment_details_page.dart';

class RecruitmentPage extends ConsumerStatefulWidget {
  const RecruitmentPage({super.key});

  @override
  ConsumerState<RecruitmentPage> createState() => _RecruitmentPageState();
}

class _RecruitmentPageState extends ConsumerState<RecruitmentPage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  RecruitmentFilter _currentFilter = RecruitmentFilter.all;
  String? _selectedComuna;
  String? _selectedPosition;

  final List<String> _comunas = [
    'Quilicura',
    'Las Condes',
    'Providencia',
    'Santiago Centro',
    'Ñuñoa',
    'La Florida',
    'Maipú',
    'Puente Alto',
  ];

  final List<String> _positions = [
    'arquero',
    'defensa',
    'mediocampo',
    'delantero',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_onTabChange);

    // Cargar posts iniciales
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(recruitmentProvider.notifier).searchPosts();
    });
  }

  void _onTabChange() {
    switch (_tabController.index) {
      case 0:
        _currentFilter = RecruitmentFilter.all;
        break;
      case 1:
        _currentFilter = RecruitmentFilter.teamsOnly;
        break;
      case 2:
        _currentFilter = RecruitmentFilter.playersOnly;
        break;
    }
    _refreshPosts();
  }

  void _refreshPosts() {
    ref
        .read(recruitmentProvider.notifier)
        .searchPosts(
          filter: _currentFilter,
          comuna: _selectedComuna,
          position: _selectedPosition,
        );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF2E7D32), Color(0xFF1B5E20)],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Column(
          children: [
            _buildHeader(),
            _buildTabBar(),
            _buildFilters(),
            Expanded(child: _buildContent()),
          ],
        ),
        floatingActionButton: _buildFAB(),
      ),
    );
  }

  Widget _buildHeader() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(
                  Icons.arrow_back_ios_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
            const SizedBox(width: 16),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Reclutamiento',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Encuentra tu equipo ideal o jugador perfecto',
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PlayerProfilePage(),
                  ),
                );
              },
              icon: const Icon(Icons.person, color: Colors.white, size: 24),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        indicatorPadding: const EdgeInsets.all(4),
        labelColor: const Color(0xFF2E7D32),
        unselectedLabelColor: Colors.white70,
        labelStyle: const TextStyle(fontWeight: FontWeight.w600),
        dividerColor: Colors.transparent,
        tabs: const [
          Tab(text: 'Todo'),
          Tab(text: 'Equipos'),
          Tab(text: 'Jugadores'),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      height: 50,
      child: Row(
        children: [
          Expanded(
            child: _buildFilterDropdown(
              value: _selectedComuna,
              hint: 'Comuna',
              items: _comunas,
              onChanged: (value) {
                setState(() {
                  _selectedComuna = value;
                });
                _refreshPosts();
              },
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildFilterDropdown(
              value: _selectedPosition,
              hint: 'Posición',
              items: _positions,
              onChanged: (value) {
                setState(() {
                  _selectedPosition = value;
                });
                _refreshPosts();
              },
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              onPressed: () {
                setState(() {
                  _selectedComuna = null;
                  _selectedPosition = null;
                });
                _refreshPosts();
              },
              icon: const Icon(Icons.clear, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterDropdown({
    String? value,
    required String hint,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          hint: Text(
            hint,
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white70),
          dropdownColor: const Color(0xFF2E7D32),
          items:
              items.map((item) {
                return DropdownMenuItem<String>(
                  value: item,
                  child: Text(
                    item,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                  ),
                );
              }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildContent() {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFF8F9FA),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(32),
          topRight: Radius.circular(32),
        ),
      ),
      child: TabBarView(
        controller: _tabController,
        children: [_buildPostsList(), _buildPostsList(), _buildPostsList()],
      ),
    );
  }

  Widget _buildPostsList() {
    final postsAsync = ref.watch(recruitmentProvider);

    return postsAsync.when(
      data: (posts) {
        if (posts.isEmpty) {
          return _buildEmptyState();
        }

        return RefreshIndicator(
          onRefresh: () async {
            _refreshPosts();
          },
          child: ListView.builder(
            padding: const EdgeInsets.all(24),
            itemCount: posts.length,
            itemBuilder: (context, index) {
              final post = posts[index];
              return _buildPostCard(post);
            },
          ),
        );
      },
      loading:
          () => const Center(
            child: CircularProgressIndicator(color: Color(0xFF2E7D32)),
          ),
      error:
          (error, _) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error, size: 60, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  'Error al cargar publicaciones',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  error.toString(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _refreshPosts,
                  child: const Text('Reintentar'),
                ),
              ],
            ),
          ),
    );
  }

  Widget _buildPostCard(RecruitmentPost post) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
        border:
            post.featured ? Border.all(color: Colors.amber, width: 2) : null,
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RecruitmentDetailsPage(post: post),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header con tipo y destacado
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color:
                          post.isTeamPost
                              ? Colors.blue.shade100
                              : Colors.green.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      post.isTeamPost ? 'EQUIPO BUSCA' : 'JUGADOR BUSCA',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color:
                            post.isTeamPost
                                ? Colors.blue.shade700
                                : Colors.green.shade700,
                      ),
                    ),
                  ),
                  if (post.featured) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.amber,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        '⭐ DESTACADO',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                  const Spacer(),
                  Text(
                    post.comuna,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Título principal
              Text(
                post.title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A1A),
                ),
              ),

              const SizedBox(height: 8),

              // Información específica
              Row(
                children: [
                  Icon(
                    post.isTeamPost ? Icons.sports_soccer : Icons.person,
                    size: 16,
                    color: Colors.grey.shade600,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    post.positionDisplay,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Icon(Icons.bar_chart, size: 16, color: Colors.grey.shade600),
                  const SizedBox(width: 8),
                  Text(
                    post.isTeamPost
                        ? post.experienceLevel ?? 'Cualquier nivel'
                        : post.playerExperience ?? 'Nivel flexible',
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Descripción
              Text(
                post.description,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                  height: 1.4,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: 12),

              // Footer con autor y fecha
              Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: Colors.grey.shade200,
                    backgroundImage:
                        post.authorPhotoUrl != null
                            ? NetworkImage(post.authorPhotoUrl!)
                            : null,
                    child:
                        post.authorPhotoUrl == null
                            ? Text(
                              post.authorName.substring(0, 1).toUpperCase(),
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                            : null,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          post.isTeamPost && post.teamName != null
                              ? post.teamName!
                              : post.authorName,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          _formatDate(post.createdAt),
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Colors.grey.shade400,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(60),
              ),
              child: const Icon(
                Icons.people_outline,
                size: 60,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No hay publicaciones',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            const Text(
              'Sé el primero en publicar\ny encontrar tu partido ideal',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CreateRecruitmentPostPage(),
                  ),
                );
              },
              icon: const Icon(Icons.add),
              label: const Text('Crear Publicación'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E7D32),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFAB() {
    return FloatingActionButton.extended(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const CreateRecruitmentPostPage(),
          ),
        );
      },
      backgroundColor: const Color(0xFF2E7D32),
      foregroundColor: Colors.white,
      icon: const Icon(Icons.add),
      label: const Text('Publicar'),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return 'Hace ${difference.inMinutes}min';
      }
      return 'Hace ${difference.inHours}h';
    } else if (difference.inDays < 7) {
      return 'Hace ${difference.inDays}d';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
