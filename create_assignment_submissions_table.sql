-- Création de la table pour les soumissions de devoirs
CREATE TABLE IF NOT EXISTS assignment_submissions (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  assignment_id UUID REFERENCES assignments(id) ON DELETE CASCADE,
  student_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
  file_url TEXT NOT NULL,
  file_name TEXT NOT NULL,
  submitted_at TIMESTAMP DEFAULT NOW(),
  status TEXT DEFAULT 'submitted', -- submitted, graded, late
  score FLOAT,
  feedback TEXT,
  graded_at TIMESTAMP,
  graded_by UUID REFERENCES profiles(id),
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW(),
  UNIQUE(assignment_id, student_id)
);

-- Index pour optimiser les requêtes
CREATE INDEX IF NOT EXISTS idx_submissions_assignment ON assignment_submissions(assignment_id);
CREATE INDEX IF NOT EXISTS idx_submissions_student ON assignment_submissions(student_id);
CREATE INDEX IF NOT EXISTS idx_submissions_status ON assignment_submissions(status);

-- RLS Policies
ALTER TABLE assignment_submissions ENABLE ROW LEVEL SECURITY;

-- Les étudiants peuvent voir leurs propres soumissions
CREATE POLICY "Students can view own submissions"
  ON assignment_submissions
  FOR SELECT
  USING (auth.uid() = student_id);

-- Les étudiants peuvent créer leurs propres soumissions
CREATE POLICY "Students can create own submissions"
  ON assignment_submissions
  FOR INSERT
  WITH CHECK (auth.uid() = student_id);

-- Les étudiants peuvent mettre à jour leurs soumissions (avant notation)
CREATE POLICY "Students can update own ungraded submissions"
  ON assignment_submissions
  FOR UPDATE
  USING (auth.uid() = student_id AND status = 'submitted');

-- Les enseignants peuvent voir toutes les soumissions de leurs devoirs
CREATE POLICY "Teachers can view submissions for their assignments"
  ON assignment_submissions
  FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM assignments a
      JOIN profiles p ON p.id = auth.uid()
      WHERE a.id = assignment_submissions.assignment_id
      AND a.teacher_id = auth.uid()
      AND p.role = 'teacher'
    )
  );

-- Les enseignants peuvent noter les soumissions
CREATE POLICY "Teachers can grade submissions"
  ON assignment_submissions
  FOR UPDATE
  USING (
    EXISTS (
      SELECT 1 FROM assignments a
      JOIN profiles p ON p.id = auth.uid()
      WHERE a.id = assignment_submissions.assignment_id
      AND a.teacher_id = auth.uid()
      AND p.role = 'teacher'
    )
  );

-- Les admins ont accès complet
CREATE POLICY "Admins have full access to submissions"
  ON assignment_submissions
  FOR ALL
  USING (
    EXISTS (
      SELECT 1 FROM profiles
      WHERE id = auth.uid() AND role = 'admin'
    )
  );

-- Fonction pour mettre à jour updated_at automatiquement
CREATE OR REPLACE FUNCTION update_assignment_submissions_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_assignment_submissions_updated_at
  BEFORE UPDATE ON assignment_submissions
  FOR EACH ROW
  EXECUTE FUNCTION update_assignment_submissions_updated_at();

-- Commentaires
COMMENT ON TABLE assignment_submissions IS 'Soumissions de devoirs par les étudiants';
COMMENT ON COLUMN assignment_submissions.status IS 'Statut: submitted, graded, late';
COMMENT ON COLUMN assignment_submissions.score IS 'Note sur le maximum défini dans assignments.max_score';
