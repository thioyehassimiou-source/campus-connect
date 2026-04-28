-- 🛡️ RESTAURATION TRIGGER DE SÉCURITÉ (ANTI-CRASH)
-- 🎯 OBJECTIF : Créer le profil côté serveur car le client n'a pas les droits (Email non confirmé = "anon").
-- ✅ STRATÉGIE : Un trigger "try-catch" silencieux qui ne fait jamais planter l'inscription.

BEGIN;

-- 1. Nettoyage préalable
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
DROP FUNCTION IF EXISTS public.handle_new_user() CASCADE;

-- 2. Fonction Trigger "Blindée"
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER -- ⚠️ CRITIQUE : Contourne RLS pour écrire le profil
SET search_path = public
AS $$
DECLARE
  v_role text;
  v_nom text;
  v_prenom text;
  v_full_name text;
BEGIN
  -- Bloc de sécurité global : Si QUOI QUE CE SOIT échoue, on ne bloque pas l'user auth
  BEGIN
    -- Récupération données de base
    v_role := COALESCE(new.raw_user_meta_data->>'role', 'Étudiant');
    v_nom := new.raw_user_meta_data->>'nom';
    v_prenom := new.raw_user_meta_data->>'first_name'; -- Au cas où
    
    IF v_nom IS NULL AND v_prenom IS NOT NULL THEN
       v_full_name := v_prenom || ' ' || COALESCE(new.raw_user_meta_data->>'last_name', '');
    ELSE
       v_full_name := COALESCE(v_nom, 'Utilisateur');
    END IF;

    -- Insertion simplifiée (On laisse les IDs optionnels à NULL pour éviter les erreurs de type)
    INSERT INTO public.profiles (id, email, role, nom, created_at, updated_at)
    VALUES (
      new.id, 
      new.email, 
      v_role, 
      v_full_name, 
      NOW(), 
      NOW()
    )
    ON CONFLICT (id) DO UPDATE SET
      email = EXCLUDED.email,
      updated_at = NOW();

  EXCEPTION WHEN OTHERS THEN
    -- 🛑 CATCH-ALL : On log l'erreur mais on laisse passer l'inscription
    RAISE WARNING 'Trigger failed gracefully: %', SQLERRM;
  END;

  RETURN new;
END;
$$;

-- 3. Activation du Trigger
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

COMMIT;
