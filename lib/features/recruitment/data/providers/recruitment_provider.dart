import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../shared/models/recruitment_models.dart';

enum RecruitmentFilter { all, teamsOnly, playersOnly, myPosts }

class RecruitmentNotifier
    extends StateNotifier<AsyncValue<List<RecruitmentPost>>> {
  RecruitmentNotifier() : super(const AsyncValue.data([]));

  final _supabase = Supabase.instance.client;

  Future<void> searchPosts({
    RecruitmentFilter filter = RecruitmentFilter.all,
    String? comuna,
    String? position,
    String? experienceLevel,
  }) async {
    state = const AsyncValue.loading();

    try {
      var query = _supabase
          .from('recruitment_posts')
          .select('''
            id,
            author_id,
            post_type,
            title,
            description,
            team_id,
            position_needed,
            experience_level,
            age_range_min,
            age_range_max,
            training_schedule,
            player_position,
            player_experience,
            availability,
            preferred_comuna,
            comuna,
            contact_method,
            contact_info,
            is_active,
            featured,
            expires_at,
            created_at,
            updated_at,
            author:profiles!author_id (
              display_name,
              photo_url
            ),
            team:teams (
              name,
              tag,
              logo_url
            )
          ''')
          .eq('is_active', true)
          .gt('expires_at', DateTime.now().toIso8601String())
          .order('featured', ascending: false)
          .order('created_at', ascending: false);

      // Aplicar filtros básicos (comentado temporalmente por compatibilidad)
      /*
      switch (filter) {
        case RecruitmentFilter.teamsOnly:
          query = query.eq('post_type', 'team_seeking_player');
          break;
        case RecruitmentFilter.playersOnly:
          query = query.eq('post_type', 'player_seeking_team');
          break;
        case RecruitmentFilter.myPosts:
          final user = _supabase.auth.currentUser;
          if (user != null) {
            query = query.eq('author_id', user.id);
          }
          break;
        case RecruitmentFilter.all:
          break;
      }

      if (comuna != null && comuna.isNotEmpty) {
        query = query.eq('comuna', comuna);
      }

      if (position != null && position.isNotEmpty) {
        query = query.or(
          'position_needed.eq.$position,player_position.eq.$position',
        );
      }

      if (experienceLevel != null && experienceLevel.isNotEmpty) {
        query = query.or(
          'experience_level.eq.$experienceLevel,player_experience.eq.$experienceLevel',
        );
      }
      */

      final response = await query.limit(50);

      final posts =
          (response as List)
              .map((post) => RecruitmentPost.fromJson(post))
              .toList();

      state = AsyncValue.data(posts);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<bool> createPost(RecruitmentPost post) async {
    try {
      await _supabase.from('recruitment_posts').insert(post.toJson());
      // Recargar la lista
      await searchPosts();
      return true;
    } catch (error) {
      print('Error creating recruitment post: $error');
      return false;
    }
  }

  Future<bool> updatePost(String postId, Map<String, dynamic> updates) async {
    try {
      await _supabase
          .from('recruitment_posts')
          .update({...updates, 'updated_at': DateTime.now().toIso8601String()})
          .eq('id', postId);

      // Recargar la lista
      await searchPosts();
      return true;
    } catch (error) {
      print('Error updating recruitment post: $error');
      return false;
    }
  }

  Future<bool> deletePost(String postId) async {
    try {
      await _supabase
          .from('recruitment_posts')
          .update({'is_active': false})
          .eq('id', postId);

      // Recargar la lista
      await searchPosts();
      return true;
    } catch (error) {
      print('Error deleting recruitment post: $error');
      return false;
    }
  }

  void clearPosts() {
    state = const AsyncValue.data([]);
  }
}

class RecruitmentApplicationsNotifier
    extends StateNotifier<AsyncValue<List<RecruitmentApplication>>> {
  RecruitmentApplicationsNotifier() : super(const AsyncValue.data([]));

  final _supabase = Supabase.instance.client;

  Future<void> getApplicationsForPost(String postId) async {
    state = const AsyncValue.loading();

    try {
      final response = await _supabase
          .from('recruitment_applications')
          .select('''
            id,
            post_id,
            applicant_id,
            message,
            status,
            player_stats,
            preferred_position,
            availability_details,
            created_at,
            updated_at,
            applicant:profiles!applicant_id (
              display_name,
              photo_url
            )
          ''')
          .eq('post_id', postId)
          .order('created_at', ascending: false);

      final applications =
          (response as List)
              .map((app) => RecruitmentApplication.fromJson(app))
              .toList();

      state = AsyncValue.data(applications);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> getMyApplications() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    state = const AsyncValue.loading();

    try {
      final response = await _supabase
          .from('recruitment_applications')
          .select('''
            id,
            post_id,
            applicant_id,
            message,
            status,
            player_stats,
            preferred_position,
            availability_details,
            created_at,
            updated_at,
            applicant:profiles!applicant_id (
              display_name,
              photo_url
            )
          ''')
          .eq('applicant_id', user.id)
          .order('created_at', ascending: false);

      final applications =
          (response as List)
              .map((app) => RecruitmentApplication.fromJson(app))
              .toList();

      state = AsyncValue.data(applications);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<bool> applyToPost({
    required String postId,
    String? message,
    String? preferredPosition,
    String? availabilityDetails,
    Map<String, dynamic>? playerStats,
  }) async {
    final user = _supabase.auth.currentUser;
    if (user == null) return false;

    try {
      await _supabase.from('recruitment_applications').insert({
        'post_id': postId,
        'applicant_id': user.id,
        'message': message,
        'preferred_position': preferredPosition,
        'availability_details': availabilityDetails,
        'player_stats': playerStats,
      });

      return true;
    } catch (error) {
      print('Error applying to post: $error');
      return false;
    }
  }

  Future<bool> updateApplicationStatus(
    String applicationId,
    String status,
  ) async {
    try {
      await _supabase
          .from('recruitment_applications')
          .update({
            'status': status,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', applicationId);

      return true;
    } catch (error) {
      print('Error updating application status: $error');
      return false;
    }
  }
}

class PlayerProfileNotifier extends StateNotifier<AsyncValue<PlayerProfile?>> {
  PlayerProfileNotifier() : super(const AsyncValue.data(null));

  final _supabase = Supabase.instance.client;

  Future<void> getPlayerProfile(String userId) async {
    state = const AsyncValue.loading();

    try {
      final response =
          await _supabase
              .from('player_profiles')
              .select('''
            id,
            user_id,
            preferred_positions,
            secondary_positions,
            preferred_foot,
            height,
            weight,
            birth_date,
            experience_level,
            years_playing,
            previous_teams,
            achievements,
            speed_rating,
            technique_rating,
            strength_rating,
            endurance_rating,
            available_days,
            preferred_time_slots,
            preferred_comunas,
            looking_for_team,
            open_to_offers,
            profile_visibility,
            created_at,
            updated_at,
            user:profiles!user_id (
              display_name,
              photo_url,
              bio
            )
          ''')
              .eq('user_id', userId)
              .maybeSingle();

      if (response != null) {
        final profile = PlayerProfile.fromJson(response);
        state = AsyncValue.data(profile);
      } else {
        state = const AsyncValue.data(null);
      }
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> getCurrentUserProfile() async {
    final user = _supabase.auth.currentUser;
    if (user != null) {
      await getPlayerProfile(user.id);
    }
  }

  Future<bool> createOrUpdateProfile(PlayerProfile profile) async {
    try {
      final existingProfile =
          await _supabase
              .from('player_profiles')
              .select('id')
              .eq('user_id', profile.userId)
              .maybeSingle();

      if (existingProfile != null) {
        // Update existing profile
        await _supabase
            .from('player_profiles')
            .update({
              'preferred_positions': profile.preferredPositions,
              'secondary_positions': profile.secondaryPositions,
              'preferred_foot': profile.preferredFoot,
              'height': profile.height,
              'weight': profile.weight,
              'birth_date': profile.birthDate?.toIso8601String().split('T')[0],
              'experience_level': profile.experienceLevel,
              'years_playing': profile.yearsPlaying,
              'previous_teams': profile.previousTeams,
              'achievements': profile.achievements,
              'speed_rating': profile.speedRating,
              'technique_rating': profile.techniqueRating,
              'strength_rating': profile.strengthRating,
              'endurance_rating': profile.enduranceRating,
              'available_days': profile.availableDays,
              'preferred_time_slots': profile.preferredTimeSlots,
              'preferred_comunas': profile.preferredComunas,
              'looking_for_team': profile.lookingForTeam,
              'open_to_offers': profile.openToOffers,
              'profile_visibility': profile.profileVisibility,
              'updated_at': DateTime.now().toIso8601String(),
            })
            .eq('user_id', profile.userId);
      } else {
        // Create new profile
        await _supabase.from('player_profiles').insert({
          'user_id': profile.userId,
          'preferred_positions': profile.preferredPositions,
          'secondary_positions': profile.secondaryPositions,
          'preferred_foot': profile.preferredFoot,
          'height': profile.height,
          'weight': profile.weight,
          'birth_date': profile.birthDate?.toIso8601String().split('T')[0],
          'experience_level': profile.experienceLevel,
          'years_playing': profile.yearsPlaying,
          'previous_teams': profile.previousTeams,
          'achievements': profile.achievements,
          'speed_rating': profile.speedRating,
          'technique_rating': profile.techniqueRating,
          'strength_rating': profile.strengthRating,
          'endurance_rating': profile.enduranceRating,
          'available_days': profile.availableDays,
          'preferred_time_slots': profile.preferredTimeSlots,
          'preferred_comunas': profile.preferredComunas,
          'looking_for_team': profile.lookingForTeam,
          'open_to_offers': profile.openToOffers,
          'profile_visibility': profile.profileVisibility,
        });
      }

      return true;
    } catch (error) {
      print('Error saving player profile: $error');
      return false;
    }
  }
}

// Providers
final recruitmentProvider = StateNotifierProvider<
  RecruitmentNotifier,
  AsyncValue<List<RecruitmentPost>>
>((ref) {
  return RecruitmentNotifier();
});

final recruitmentApplicationsProvider = StateNotifierProvider<
  RecruitmentApplicationsNotifier,
  AsyncValue<List<RecruitmentApplication>>
>((ref) {
  return RecruitmentApplicationsNotifier();
});

final playerProfileProvider =
    StateNotifierProvider<PlayerProfileNotifier, AsyncValue<PlayerProfile?>>((
      ref,
    ) {
      return PlayerProfileNotifier();
    });

// Provider específico para obtener un perfil de jugador por ID
final specificPlayerProfileProvider =
    FutureProvider.family<PlayerProfile?, String>((ref, userId) async {
      final notifier = PlayerProfileNotifier();
      await notifier.getPlayerProfile(userId);
      return notifier.debugState.value;
    });
