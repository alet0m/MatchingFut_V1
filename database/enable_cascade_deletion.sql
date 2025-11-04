-- CONFIGURAR CASCADE DELETION PARA ADMINISTRADOR
-- Esto permite eliminar usuarios y que sus equipos se borren automáticamente

-- ========================================
-- PASO 1: ELIMINAR CONSTRAINTS DUPLICADAS
-- ========================================

-- Eliminar constraints antiguas/duplicadas de teams
ALTER TABLE public.teams DROP CONSTRAINT IF EXISTS teams_captain_id_fkey;
ALTER TABLE public.teams DROP CONSTRAINT IF EXISTS teams_owner_id_fkey;
ALTER TABLE public.teams DROP CONSTRAINT IF EXISTS fk_teams_captain;
ALTER TABLE public.teams DROP CONSTRAINT IF EXISTS fk_teams_owner;

-- ========================================
-- PASO 2: RECREAR CON CASCADE
-- ========================================

-- Recrear foreign keys con CASCADE para teams
ALTER TABLE public.teams 
ADD CONSTRAINT teams_captain_id_fkey 
FOREIGN KEY (captain_id) REFERENCES public.profiles(id) ON DELETE CASCADE;

ALTER TABLE public.teams 
ADD CONSTRAINT teams_owner_id_fkey 
FOREIGN KEY (owner_id) REFERENCES public.profiles(id) ON DELETE CASCADE;

-- ========================================
-- PASO 3: CONFIGURAR CASCADE PARA OTRAS TABLAS RELACIONADAS
-- ========================================

-- Activity Feed
ALTER TABLE public.activity_feed DROP CONSTRAINT IF EXISTS activity_feed_user_id_fkey;
ALTER TABLE public.activity_feed DROP CONSTRAINT IF EXISTS activity_feed_actor_id_fkey;

ALTER TABLE public.activity_feed 
ADD CONSTRAINT activity_feed_user_id_fkey 
FOREIGN KEY (user_id) REFERENCES public.profiles(id) ON DELETE CASCADE;

ALTER TABLE public.activity_feed 
ADD CONSTRAINT activity_feed_actor_id_fkey 
FOREIGN KEY (actor_id) REFERENCES public.profiles(id) ON DELETE CASCADE;

-- Challenges
ALTER TABLE public.challenges DROP CONSTRAINT IF EXISTS challenges_challenger_id_fkey;
ALTER TABLE public.challenges DROP CONSTRAINT IF EXISTS challenges_challenged_id_fkey;

ALTER TABLE public.challenges 
ADD CONSTRAINT challenges_challenger_id_fkey 
FOREIGN KEY (challenger_id) REFERENCES public.profiles(id) ON DELETE CASCADE;

ALTER TABLE public.challenges 
ADD CONSTRAINT challenges_challenged_id_fkey 
FOREIGN KEY (challenged_id) REFERENCES public.profiles(id) ON DELETE CASCADE;

-- Friend Requests
ALTER TABLE public.friend_requests DROP CONSTRAINT IF EXISTS friend_requests_sender_id_fkey;
ALTER TABLE public.friend_requests DROP CONSTRAINT IF EXISTS friend_requests_receiver_id_fkey;

ALTER TABLE public.friend_requests 
ADD CONSTRAINT friend_requests_sender_id_fkey 
FOREIGN KEY (sender_id) REFERENCES public.profiles(id) ON DELETE CASCADE;

ALTER TABLE public.friend_requests 
ADD CONSTRAINT friend_requests_receiver_id_fkey 
FOREIGN KEY (receiver_id) REFERENCES public.profiles(id) ON DELETE CASCADE;

-- Friendships
ALTER TABLE public.friendships DROP CONSTRAINT IF EXISTS fk_friendships_requester;
ALTER TABLE public.friendships DROP CONSTRAINT IF EXISTS fk_friendships_receiver;

ALTER TABLE public.friendships 
ADD CONSTRAINT fk_friendships_requester 
FOREIGN KEY (requester_id) REFERENCES public.profiles(id) ON DELETE CASCADE;

ALTER TABLE public.friendships 
ADD CONSTRAINT fk_friendships_receiver 
FOREIGN KEY (receiver_id) REFERENCES public.profiles(id) ON DELETE CASCADE;

-- Matches
ALTER TABLE public.matches DROP CONSTRAINT IF EXISTS matches_player1_id_fkey;
ALTER TABLE public.matches DROP CONSTRAINT IF EXISTS matches_player2_id_fkey;
ALTER TABLE public.matches DROP CONSTRAINT IF EXISTS matches_verified_by_fkey;

ALTER TABLE public.matches 
ADD CONSTRAINT matches_player1_id_fkey 
FOREIGN KEY (player1_id) REFERENCES public.profiles(id) ON DELETE CASCADE;

ALTER TABLE public.matches 
ADD CONSTRAINT matches_player2_id_fkey 
FOREIGN KEY (player2_id) REFERENCES public.profiles(id) ON DELETE CASCADE;

ALTER TABLE public.matches 
ADD CONSTRAINT matches_verified_by_fkey 
FOREIGN KEY (verified_by) REFERENCES public.profiles(id) ON DELETE SET NULL;

-- Notifications
ALTER TABLE public.notifications DROP CONSTRAINT IF EXISTS fk_notifications_user;

ALTER TABLE public.notifications 
ADD CONSTRAINT fk_notifications_user 
FOREIGN KEY (user_id) REFERENCES public.profiles(id) ON DELETE CASCADE;

-- Player Modality Stats
ALTER TABLE public.player_modality_stats DROP CONSTRAINT IF EXISTS player_modality_user_fkey;

ALTER TABLE public.player_modality_stats 
ADD CONSTRAINT player_modality_user_fkey 
FOREIGN KEY (user_id) REFERENCES public.profiles(id) ON DELETE CASCADE;

-- Rankings
ALTER TABLE public.rankings DROP CONSTRAINT IF EXISTS rankings_player_id_fkey;

ALTER TABLE public.rankings 
ADD CONSTRAINT rankings_player_id_fkey 
FOREIGN KEY (player_id) REFERENCES public.profiles(id) ON DELETE CASCADE;

-- Recruitment Posts
ALTER TABLE public.recruitment_posts DROP CONSTRAINT IF EXISTS recruitment_posts_author_profiles_fkey;

ALTER TABLE public.recruitment_posts 
ADD CONSTRAINT recruitment_posts_author_profiles_fkey 
FOREIGN KEY (author_id) REFERENCES public.profiles(id) ON DELETE CASCADE;

-- User Stats
ALTER TABLE public.user_stats DROP CONSTRAINT IF EXISTS user_stats_user_id_fkey;

ALTER TABLE public.user_stats 
ADD CONSTRAINT user_stats_user_id_fkey 
FOREIGN KEY (user_id) REFERENCES public.profiles(id) ON DELETE CASCADE;

-- ========================================
-- PASO 4: VERIFICAR CONFIGURACIÓN
-- ========================================

-- Ver todas las foreign keys con CASCADE configuradas
SELECT 
    tc.table_name,
    kcu.column_name,
    ccu.table_name AS references_table,
    ccu.column_name AS references_column,
    rc.delete_rule
FROM information_schema.table_constraints AS tc 
JOIN information_schema.key_column_usage AS kcu
    ON tc.constraint_name = kcu.constraint_name
JOIN information_schema.constraint_column_usage AS ccu
    ON ccu.constraint_name = tc.constraint_name
JOIN information_schema.referential_constraints AS rc
    ON tc.constraint_name = rc.constraint_name
WHERE tc.constraint_type = 'FOREIGN KEY' 
AND ccu.table_name = 'profiles'
ORDER BY tc.table_name, kcu.column_name;

-- ========================================
-- RESULTADO ESPERADO:
-- ========================================
-- Ahora cuando elimines un usuario desde Supabase:
-- ✅ Se eliminarán automáticamente todos sus equipos
-- ✅ Se eliminarán sus estadísticas
-- ✅ Se eliminarán sus notificaciones  
-- ✅ Se eliminarán sus amistades
-- ✅ Se eliminarán sus desafíos
-- ✅ Se eliminarán sus partidos (como jugador)
-- ✅ Se eliminarán sus posts de reclutamiento
-- ✅ Su actividad del feed se borrará

COMMIT;
