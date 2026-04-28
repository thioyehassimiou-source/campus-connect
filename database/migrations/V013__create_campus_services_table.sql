-- ==============================================================================
-- 🏤 CRÉATION DE LA TABLE SERVICES (Vie du Campus)
-- ==============================================================================

CREATE TABLE IF NOT EXISTS public.services (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    nom TEXT NOT NULL UNIQUE,
    description TEXT,
    telephone TEXT,
    email TEXT,
    localisation TEXT,
    horaires TEXT,
    site_web TEXT,
    
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Assurer que les colonnes existent
ALTER TABLE public.services ADD COLUMN IF NOT EXISTS description TEXT;
ALTER TABLE public.services ADD COLUMN IF NOT EXISTS telephone TEXT;
ALTER TABLE public.services ADD COLUMN IF NOT EXISTS email TEXT;
ALTER TABLE public.services ADD COLUMN IF NOT EXISTS localisation TEXT;
ALTER TABLE public.services ADD COLUMN IF NOT EXISTS horaires TEXT;
ALTER TABLE public.services ADD COLUMN IF NOT EXISTS site_web TEXT;
ALTER TABLE public.services ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ DEFAULT NOW();
ALTER TABLE public.services ADD COLUMN IF NOT EXISTS created_at TIMESTAMPTZ DEFAULT NOW();

-- NETTOYAGE DES DOUBLONS (Critique pour ajouter la contrainte UNIQUE)
-- Si plusieurs services ont le même nom, on redirige les profils vers le premier (par ID alpha) et on supprime les autres.
DO $$ 
DECLARE
    r RECORD;
BEGIN
    FOR r IN (SELECT nom, MIN(id::text)::uuid as master_id FROM public.services GROUP BY nom HAVING COUNT(*) > 1) LOOP
        -- Rediriger les profils vers l'ID "maître"
        UPDATE public.profiles SET service_id = r.master_id WHERE service_id IN (SELECT id FROM public.services WHERE nom = r.nom AND id <> r.master_id);
        -- Supprimer les doublons
        DELETE FROM public.services WHERE nom = r.nom AND id <> r.master_id;
    END LOOP;
END $$;

-- Assurer que la contrainte UNIQUE sur le nom existe
DO $$ 
BEGIN 
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'services_nom_key') THEN
        ALTER TABLE public.services ADD CONSTRAINT services_nom_key UNIQUE (nom);
    END IF;
END $$;

-- Sécurité (RLS)
ALTER TABLE public.services ENABLE ROW LEVEL SECURITY;

-- 1. Tout le monde peut LIRE les services
DROP POLICY IF EXISTS "Lecture publique des services" ON public.services;
CREATE POLICY "Lecture publique des services" 
ON public.services FOR SELECT 
TO authenticated 
USING (true);

-- 2. Seuls les Admins peuvent AJOUTER/MODIFIER/SUPPRIMER
DROP POLICY IF EXISTS "Admins peuvent gérer les services" ON public.services;
CREATE POLICY "Admins peuvent gérer les services" 
ON public.services FOR ALL 
TO authenticated 
USING (
    EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role IN ('admin', 'director'))
);

-- DATA SAMPLE (Services de base du Campus de Labé)
-- Note: On ne supprime plus (DELETE) pour éviter de casser les contraintes 
-- sur les profils Administratifs existants.

INSERT INTO public.services (nom, description, telephone, email, localisation, horaires, site_web)
VALUES 
(
    'Bibliothèque Universitaire', 
    'Espace d''étude et de recherche avec des milliers d''ouvrages et ressources numériques.', 
    '+224 621 00 11 22', 
    'bu@univ-labe.edu.gn', 
    'Bâtiment Central, 2ème étage', 
    'Lun-Ven: 8h-18h, Sam: 9h-13h', 
    'https://bu.univ-labe.edu.gn'
),
(
    'Service de la Scolarité', 
    'Gestion des inscriptions, des relevés de notes et des diplômes.', 
    '+224 622 33 44 55', 
    'scolarite@univ-labe.edu.gn', 
    'Rez-de-chaussée, Bloc Administratif', 
    'Lun-Ven: 8h-16h', 
    NULL
),
(
    'Centre de Santé', 
    'Soins de premiers secours et consultations médicales pour les étudiants.', 
    '112 (Urgence Campus)', 
    'sante@univ-labe.edu.gn', 
    'Près des Résidences Universitaires', 
    '24h/24, 7j/7', 
    NULL
),
(
    'Restauration Universitaire', 
    'Repas équilibrés à prix subventionnés pour toute la communauté.', 
    NULL, 
    'resto@univ-labe.edu.gn', 
    'Pavillon Restauration', 
    'Déjeuner: 12h-14h30, Dîner: 19h-21h', 
    NULL
),
(
    'Service Informatique / IT', 
    'Support technique, gestion du Wi-Fi et maintenance des labos informatiques.', 
    '+224 620 99 88 77', 
    'support@univ-labe.edu.gn', 
    'Département Informatique, Salle 105', 
    'Lun-Ven: 8h-17h', 
    'https://it.univ-labe.edu.gn'
),
(
    'Bureau des Sports', 
    'Organisation des activités sportives et gestion des infrastructures.', 
    '+224 625 55 66 77', 
    'sport@univ-labe.edu.gn', 
    'Gymnase Universitaire', 
    'Mercredi & Samedi après-midi', 
    NULL
)
ON CONFLICT (nom) DO UPDATE SET
    description = EXCLUDED.description,
    telephone = EXCLUDED.telephone,
    email = EXCLUDED.email,
    localisation = EXCLUDED.localisation,
    horaires = EXCLUDED.horaires,
    site_web = EXCLUDED.site_web,
    updated_at = NOW();
