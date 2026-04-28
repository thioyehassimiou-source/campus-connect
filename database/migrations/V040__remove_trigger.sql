-- 🗑️ SUPPRESSION DÉFINITIVE DU TRIGGER (SOLUTION ULTIME)
-- 🎯 OBJECTIF : Débloquer l'inscription en supprimant le composant backend qui plante (le trigger).
-- ✅ SÉCURITÉ : Votre application Flutter (SupabaseAuthService) crée DÉJÀ le profil manuellement juste après l'inscription.
--              Supprimer ce trigger ne cassera pas l'app, au contraire, cela laissera le code Flutter gérer la création.

BEGIN;

-- 1. Supprimer le trigger sur auth.users
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;

-- 2. Supprimer la fonction associée
DROP FUNCTION IF EXISTS public.handle_new_user() CASCADE;

-- 3. (Opt) S'assurer une dernière fois que les permissions sont OK pour le client Flutter
GRANT ALL ON TABLE public.profiles TO authenticated;
GRANT ALL ON TABLE public.profiles TO service_role;

-- 4. S'assurer que les politiques RLS autorisent l'insertion par le client
-- (On garde celles définies précédemment qui étaient correctes)

COMMIT;
