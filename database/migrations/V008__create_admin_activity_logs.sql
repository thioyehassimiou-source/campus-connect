-- =============================================================
-- TABLE : admin_activity_logs
-- Enregistre toutes les actions effectuées par les administrateurs.
-- À exécuter dans le SQL Editor de Supabase.
-- =============================================================

CREATE TABLE IF NOT EXISTS admin_activity_logs (
  id          UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  admin_id    UUID        REFERENCES auth.users(id) ON DELETE SET NULL,
  admin_name  TEXT,                        -- Cache du nom admin au moment de l'action
  action      TEXT        NOT NULL,         -- ex: create_user, validate_schedule
  target_type TEXT,                         -- ex: user, schedule, announcement
  target_id   TEXT,                         -- ID de l'entité concernée
  details     JSONB,                        -- Détails libres en JSON
  created_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Index pour les requêtes fréquentes
CREATE INDEX IF NOT EXISTS idx_admin_logs_admin_id   ON admin_activity_logs(admin_id);
CREATE INDEX IF NOT EXISTS idx_admin_logs_created_at ON admin_activity_logs(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_admin_logs_action     ON admin_activity_logs(action);

-- ─── Row Level Security ──────────────────────────────────────────────────────

ALTER TABLE admin_activity_logs ENABLE ROW LEVEL SECURITY;

-- Seuls les admins peuvent lire les logs
CREATE POLICY "Admins can read activity logs"
  ON admin_activity_logs
  FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM profiles
      WHERE id = auth.uid()
        AND role IN ('Admin', 'SUPER_ADMIN', 'Administrateur', 'admin')
    )
  );

-- Un admin peut insérer ses propres logs
CREATE POLICY "Admins can insert own logs"
  ON admin_activity_logs
  FOR INSERT
  WITH CHECK (admin_id = auth.uid());

-- Personne ne peut modifier un log (intégrité de l'historique)
-- (Pas de policy UPDATE = pas d'UPDATE autorisé)

-- ─── Colonne is_active dans profiles (si elle n'existe pas encore) ──────────
-- Ajoutez cette colonne si les profils ne l'ont pas encore :

ALTER TABLE profiles
  ADD COLUMN IF NOT EXISTS is_active      BOOLEAN     DEFAULT true,
  ADD COLUMN IF NOT EXISTS last_login_at  TIMESTAMPTZ,
  ADD COLUMN IF NOT EXISTS matricule      TEXT,
  ADD COLUMN IF NOT EXISTS departement    TEXT,
  ADD COLUMN IF NOT EXISTS filiere        TEXT,
  ADD COLUMN IF NOT EXISTS niveau         TEXT;

-- ─── Vérification des policies existantes sur profiles ──────────────────────
-- Assurez-vous que les admins peuvent SELECT tous les profils :

-- (Optionnel — exécuter seulement si nécessaire)
-- DROP POLICY IF EXISTS "Admin can read all profiles" ON profiles;
-- CREATE POLICY "Admin can read all profiles"
--   ON profiles FOR SELECT
--   USING (
--     auth.uid() = id
--     OR EXISTS (
--       SELECT 1 FROM profiles p2
--       WHERE p2.id = auth.uid()
--         AND p2.role IN ('Admin', 'SUPER_ADMIN', 'Administrateur')
--     )
--   );
