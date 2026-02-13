-- 🛠️ MISE À JOUR DES PROFILS STAFF (ENREGIGNANTS & ADMINS)
-- Ajout de colonnes pour les informations professionnelles.

BEGIN;

DO $$ 
BEGIN 
    -- 1. Bureau physique
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'profiles' AND column_name = 'office') THEN
        ALTER TABLE public.profiles ADD COLUMN office TEXT;
    END IF;

    -- 2. Spécialisation / Expertise
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'profiles' AND column_name = 'specialization') THEN
        ALTER TABLE public.profiles ADD COLUMN specialization TEXT;
    END IF;

    -- 3. Horaires de bureau (JSONB pour plus de flexibilité : {"Lundi": "08:00 - 18:00", ...})
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'profiles' AND column_name = 'office_hours') THEN
        ALTER TABLE public.profiles ADD COLUMN office_hours JSONB DEFAULT '{}'::jsonb;
    END IF;

    -- 4. Publications / Travaux (JSONB)
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'profiles' AND column_name = 'publications') THEN
        ALTER TABLE public.profiles ADD COLUMN publications JSONB DEFAULT '[]'::jsonb;
    END IF;

    -- 5. Liens Sociaux (JSONB : {"linkedin": "...", "scholar": "..."})
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'profiles' AND column_name = 'social_links') THEN
        ALTER TABLE public.profiles ADD COLUMN social_links JSONB DEFAULT '{}'::jsonb;
    END IF;

END $$;

COMMIT;
