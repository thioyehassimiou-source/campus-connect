-- 🔍 VÉRIFICATION POST-INSCRIPTION
-- Exécutez ce script pour voir si l'utilisateur a été créé malgré l'erreur RLS 42501
-- Remplacez 'Bah@gmail.com' par l'email que vous avez utilisé si différent

SELECT 
    au.id as auth_id, 
    au.email, 
    au.created_at as auth_created_at,
    p.id as profile_id, 
    p.role, 
    p.nom,
    p.faculty_id
FROM auth.users au
LEFT JOIN public.profiles p ON au.id = p.id
WHERE au.email = 'Bah@gmail.com'; 
