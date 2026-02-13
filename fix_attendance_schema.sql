-- Amélioration de la table attendance
-- 1. Ajouter une contrainte d'unicité pour éviter les doublons (Même étudiant, même cours, même jour)
-- On utilise une expression pour la date (sans l'heure)
CREATE UNIQUE INDEX IF NOT EXISTS idx_unique_attendance_day 
ON public.attendance (student_id, course, (date::date));

-- 2. Ajouter des indexes pour la performance
CREATE INDEX IF NOT EXISTS idx_attendance_course_date ON public.attendance (course, date);

-- 3. Mettre à jour les RLS (assurer que les profs peuvent aussi UPDATE)
CREATE POLICY "Enseignants peuvent modifier les présences" 
ON public.attendance FOR UPDATE 
TO authenticated 
USING (
    EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role IN ('teacher', 'admin', 'director'))
);

-- Note: Les triggers de notifications pour 'absence' pourraient être ajoutés ici ultérieurement.
