-- 🔓 DÉBLOCAGE PERMISSIONS (RLS 42501 FIX)
-- L'erreur 42501 peut aussi venir d'un manque de "GRANT" sur la table

BEGIN;

-- Accordez explicitement les droits CRUD à l'utilisateur authentifié
GRANT ALL ON TABLE public.profiles TO authenticated;
GRANT ALL ON TABLE public.profiles TO service_role;

-- S'assurer que la séquence (si utilisée, pas le cas ici pour ID mais bon) est accessible
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO authenticated;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO service_role;

COMMIT;
