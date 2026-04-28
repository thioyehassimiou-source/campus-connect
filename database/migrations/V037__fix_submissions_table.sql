-- Mise à jour de la table submissions existante pour supporter les fichiers
ALTER TABLE public.submissions 
ADD COLUMN IF NOT EXISTS file_url TEXT,
ADD COLUMN IF NOT EXISTS file_name TEXT,
ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ DEFAULT NOW();

-- Ajouter un trigger pour updated_at si nécessaire
CREATE OR REPLACE FUNCTION update_submissions_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DO $$ 
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'tr_update_submissions_updated_at') THEN
    CREATE TRIGGER tr_update_submissions_updated_at
    BEFORE UPDATE ON public.submissions
    FOR EACH ROW
    EXECUTE FUNCTION update_submissions_updated_at();
  END IF;
END $$;

-- Mise à jour des RLS policies pour inclure les nouveaux champs (les existantes sont conservées)
-- Les politiques existantes dans create_assignments_tables.sql sont déjà assez bonnes.
