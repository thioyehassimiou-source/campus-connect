-- 🚀 ENRICHISSEMENT DE LA TABLE PROFILES
-- Permet de stocker les infos académiques et sociales pour qu'elles ne soient plus mockées.

ALTER TABLE public.profiles 
  ADD COLUMN IF NOT EXISTS moyenne FLOAT DEFAULT 0,
  ADD COLUMN IF NOT EXISTS credits_valides INTEGER DEFAULT 0,
  ADD COLUMN IF NOT EXISTS classement TEXT,
  ADD COLUMN IF NOT EXISTS linkedin TEXT,
  ADD COLUMN IF NOT EXISTS github TEXT,
  ADD COLUMN IF NOT EXISTS twitter TEXT,
  ADD COLUMN IF NOT EXISTS bio TEXT,
  ADD COLUMN IF NOT EXISTS competences TEXT[],
  ADD COLUMN IF NOT EXISTS interets TEXT[];

-- Ajout d'une colonne pour la photo de profil (facultatif)
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS avatar_url TEXT;

-- Mettre à jour les politiques si besoin (normalement OK avec UPDATE soi-même)

-- Données de démo pour l'utilisateur TEST (si besoin, à adapter avec l'UUID réel)
-- UPDATE public.profiles SET moyenne = 14.5, credits_valides = 60, classement = '5/120' WHERE role = 'Étudiant';
