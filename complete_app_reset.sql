-- ========================================
-- RESET COMPLETO DE LA APLICACIÓN
-- ¡ESTO BORRA TODO! Úsalo con cuidado
-- ========================================

-- PASO 1: Deshabilitar RLS temporalmente para hacer limpieza masiva
ALTER TABLE public.profiles DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.teams DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.matches DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.public_matches DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.challenges DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.friendships DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.friend_requests DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.notifications DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.activity_feed DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.recruitment_posts DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_stats DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.rankings DISABLE ROW LEVEL SECURITY;

-- PASO 2: ELIMINAR TODOS LOS DATOS EN ORDEN CORRECTO
-- (De dependientes a principales para evitar errores de foreign key)

-- Eliminar datos de tablas dependientes primero
DELETE FROM public.match_applications;
DELETE FROM public.recruitment_by_modality;
DELETE FROM public.team_elo_by_modality;
DELETE FROM public.player_modality_stats;
DELETE FROM public.activity_feed;
DELETE FROM public.notifications;
DELETE FROM public.friendships;
DELETE FROM public.friend_requests;
DELETE FROM public.challenges;
DELETE FROM public.rankings;
DELETE FROM public.user_stats;
DELETE FROM public.recruitment_posts;
DELETE FROM public.public_matches;
DELETE FROM public.matches;

-- Limpiar arrays de miembros e invitaciones si el equipo es "ALBOS"
UPDATE public.teams SET member_ids = '{}', pending_invites = '{}' WHERE name = 'ALBOS';
-- Eliminar el equipo "ALBOS"
DELETE FROM public.teams WHERE name = 'ALBOS';
-- Eliminar perfiles (esto debería eliminar todo en cascada si funciona)
DELETE FROM public.profiles;

-- PASO 3: ELIMINAR USUARIOS DE AUTENTICACIÓN
-- ¡CUIDADO! Esto elimina las cuentas de login
DELETE FROM auth.users;

-- PASO 4: RESETEAR SECUENCIAS (para que los IDs empiecen desde 1)
-- Nota: Supabase usa UUIDs, pero por si acaso

-- PASO 5: VERIFICAR QUE TODO ESTÉ VACÍO
SELECT 
    'auth.users' as tabla,
    COUNT(*) as registros
FROM auth.users
UNION ALL
SELECT 
    'profiles' as tabla,
    COUNT(*) as registros
FROM public.profiles
UNION ALL
SELECT 
    'teams' as tabla,
    COUNT(*) as registros
FROM public.teams
UNION ALL
SELECT 
    'matches' as tabla,
    COUNT(*) as registros
FROM public.matches
UNION ALL
SELECT 
    'public_matches' as tabla,
    COUNT(*) as registros
FROM public.public_matches
UNION ALL
SELECT 
    'challenges' as tabla,
    COUNT(*) as registros
FROM public.challenges
UNION ALL
SELECT 
    'friendships' as tabla,
    COUNT(*) as registros
FROM public.friendships
UNION ALL
SELECT 
    'notifications' as tabla,
    COUNT(*) as registros
FROM public.notifications
UNION ALL
SELECT 
    'activity_feed' as tabla,
    COUNT(*) as registros
FROM public.activity_feed
UNION ALL
SELECT 
    'recruitment_posts' as tabla,
    COUNT(*) as registros
FROM public.recruitment_posts
UNION ALL
SELECT 
    'user_stats' as tabla,
    COUNT(*) as registros
FROM public.user_stats
UNION ALL
SELECT 
    'rankings' as tabla,
    COUNT(*) as registros
FROM public.rankings;

-- PASO 6: REHABILITAR RLS
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.teams ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.matches ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.public_matches ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.challenges ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.friendships ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.friend_requests ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.activity_feed ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.recruitment_posts ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_stats ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.rankings ENABLE ROW LEVEL SECURITY;

-- ========================================
-- RESULTADO ESPERADO:
-- ========================================
-- ✅ Todas las tablas vacías (COUNT = 0)
-- ✅ No hay usuarios de auth
-- ✅ No hay perfiles
-- ✅ No hay equipos
-- ✅ No hay partidos
-- ✅ No hay publicaciones
-- ✅ App completamente limpia y funcional
-- 
-- PRÓXIMO PASO:
-- 🚀 Crear usuarios nuevos desde la app
-- 🏆 Probar todas las funcionalidades
-- ⚽ Crear equipos y partidos desde cero

COMMIT;

-- ========================================
-- NOTAS IMPORTANTES:
-- ========================================
-- 1. Después de esto, la app estará vacía pero FUNCIONAL
-- 2. Podrás registrar usuarios nuevos normalmente
-- 3. Todas las funcionalidades seguirán trabajando
-- 4. Los triggers y funciones de la DB siguen intactos
-- 5. Solo se borran los DATOS, no la ESTRUCTURA
