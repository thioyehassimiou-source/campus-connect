-- 🔍 DIAGNOSTIC BACKEND CAMPUSCONNECT
-- Exécuter ce script dans l'éditeur SQL de Supabase pour auditer l'état actuel.

-- 1. Vériifer la structure de la table 'users' (ou 'profiles')
SELECT 
    table_name, 
    column_name, 
    data_type, 
    is_nullable, 
    column_default
FROM information_schema.columns
WHERE table_schema = 'public' 
AND table_name IN ('users', 'profiles');

-- 2. Vérifier les contraintes (Clés étrangères, Not Null, Unique)
SELECT 
    tc.table_name, 
    kcu.column_name, 
    tc.constraint_name, 
    tc.constraint_type
FROM information_schema.table_constraints AS tc 
JOIN information_schema.key_column_usage AS kcu
  ON tc.constraint_name = kcu.constraint_name
WHERE tc.table_schema = 'public' 
AND tc.table_name IN ('users', 'profiles');

-- 3. Vérifier la définition du Trigger actuel handle_new_user
SELECT 
    p.proname as function_name,
    pg_get_functiondef(p.oid) as definition
FROM pg_proc p
JOIN pg_namespace n ON p.pronamespace = n.oid
WHERE n.nspname = 'public'
AND p.proname = 'handle_new_user';

-- 4. Vérifier si le Trigger est actif sur auth.users
SELECT 
    event_object_schema as schema,
    event_object_table as table,
    trigger_name,
    action_timing,
    event_manipulation
FROM information_schema.triggers
WHERE event_object_schema = 'auth' 
AND event_object_table = 'users';

-- 5. Vérifier les politiques RLS (Sécurité)
SELECT 
    tablename, 
    policyname, 
    permissive, 
    roles, 
    cmd, 
    qual, 
    with_check 
FROM pg_policies 
WHERE schemaname = 'public' 
AND tablename IN ('users', 'profiles');
