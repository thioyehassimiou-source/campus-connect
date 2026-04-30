-- ============================================================
-- CampusConnect - Schéma PostgreSQL Propre (sans Supabase)
-- Remplace auth.users par public.users avec JWT custom
-- ============================================================

-- Extension UUID
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- ============================================================
-- TABLE CENTRALE : users (remplace auth.users de Supabase)
-- ============================================================
CREATE TABLE IF NOT EXISTS public.users (
  id            UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  email         TEXT UNIQUE NOT NULL,
  password_hash TEXT NOT NULL,
  role          TEXT NOT NULL DEFAULT 'Étudiant' CHECK (role IN ('Étudiant', 'Enseignant', 'Admin')),
  created_at    TIMESTAMPTZ DEFAULT NOW(),
  updated_at    TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================
-- PROFILS UTILISATEURS
-- ============================================================
CREATE TABLE IF NOT EXISTS public.profiles (
  id            UUID PRIMARY KEY REFERENCES public.users(id) ON DELETE CASCADE,
  full_name     TEXT,
  avatar_url    TEXT,
  role          TEXT NOT NULL DEFAULT 'Étudiant',
  filiere       TEXT,
  niveau        TEXT,
  matricule     TEXT UNIQUE,
  phone         TEXT,
  bio           TEXT,
  date_naissance DATE,
  created_at    TIMESTAMPTZ DEFAULT NOW(),
  updated_at    TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================
-- FILIERES
-- ============================================================
CREATE TABLE IF NOT EXISTS public.filieres (
  id          UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  nom         TEXT NOT NULL,
  code        TEXT UNIQUE NOT NULL,
  description TEXT,
  created_at  TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================
-- COURS
-- ============================================================
CREATE TABLE IF NOT EXISTS public.courses (
  id             UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  title          TEXT NOT NULL,
  description    TEXT,
  teacher_id     UUID REFERENCES public.users(id),
  level          TEXT NOT NULL,
  color          TEXT DEFAULT '#2563EB',
  status         TEXT DEFAULT 'Actif',
  students_count INTEGER DEFAULT 0,
  created_at     TIMESTAMPTZ DEFAULT NOW(),
  updated_at     TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================
-- EMPLOI DU TEMPS
-- ============================================================
CREATE TABLE IF NOT EXISTS public.schedules (
  id          UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  course_id   UUID REFERENCES public.courses(id) ON DELETE CASCADE,
  teacher_id  UUID REFERENCES public.users(id),
  day_of_week TEXT NOT NULL,
  start_time  TIME NOT NULL,
  end_time    TIME NOT NULL,
  room        TEXT,
  filiere     TEXT,
  niveau      TEXT,
  semester    TEXT,
  created_at  TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================
-- NOTES (GRADES)
-- ============================================================
CREATE TABLE IF NOT EXISTS public.grades (
  id          UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  student_id  UUID REFERENCES public.users(id) ON DELETE CASCADE,
  course_id   UUID REFERENCES public.courses(id) ON DELETE CASCADE,
  teacher_id  UUID REFERENCES public.users(id),
  grade       NUMERIC(5,2),
  comment     TEXT,
  semester    TEXT,
  created_at  TIMESTAMPTZ DEFAULT NOW(),
  updated_at  TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================
-- ABSENCES (ATTENDANCE)
-- ============================================================
CREATE TABLE IF NOT EXISTS public.attendance (
  id          UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  student_id  UUID REFERENCES public.users(id) ON DELETE CASCADE,
  course_id   UUID REFERENCES public.courses(id) ON DELETE CASCADE,
  teacher_id  UUID REFERENCES public.users(id),
  date        DATE NOT NULL,
  status      TEXT NOT NULL DEFAULT 'Présent' CHECK (status IN ('Présent', 'Absent', 'Retard', 'Excusé')),
  comment     TEXT,
  created_at  TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================
-- ANNONCES
-- ============================================================
CREATE TABLE IF NOT EXISTS public.announcements (
  id          UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  title       TEXT NOT NULL,
  content     TEXT NOT NULL,
  category    TEXT,
  priority    TEXT DEFAULT 'Normale',
  author_id   UUID REFERENCES public.users(id),
  author_name TEXT,
  service_id  UUID,
  scope       TEXT DEFAULT 'global',
  filiere     TEXT,
  niveau      TEXT,
  created_at  TIMESTAMPTZ DEFAULT NOW(),
  updated_at  TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================
-- DEVOIRS (ASSIGNMENTS)
-- ============================================================
CREATE TABLE IF NOT EXISTS public.assignments (
  id           UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  title        TEXT NOT NULL,
  description  TEXT,
  course_id    UUID REFERENCES public.courses(id),
  teacher_id   UUID REFERENCES public.users(id),
  due_date     TIMESTAMPTZ,
  max_grade    NUMERIC(5,2) DEFAULT 20,
  created_at   TIMESTAMPTZ DEFAULT NOW(),
  updated_at   TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.assignment_submissions (
  id            UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  assignment_id UUID REFERENCES public.assignments(id) ON DELETE CASCADE,
  student_id    UUID REFERENCES public.users(id) ON DELETE CASCADE,
  content       TEXT,
  file_url      TEXT,
  grade         NUMERIC(5,2),
  feedback      TEXT,
  submitted_at  TIMESTAMPTZ DEFAULT NOW(),
  graded_at     TIMESTAMPTZ,
  UNIQUE(assignment_id, student_id)
);

-- ============================================================
-- MESSAGERIE
-- ============================================================
CREATE TABLE IF NOT EXISTS public.conversations (
  id           UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  participant1 UUID REFERENCES public.users(id) ON DELETE CASCADE,
  participant2 UUID REFERENCES public.users(id) ON DELETE CASCADE,
  created_at   TIMESTAMPTZ DEFAULT NOW(),
  updated_at   TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(participant1, participant2)
);

CREATE TABLE IF NOT EXISTS public.messages (
  id              UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  conversation_id UUID REFERENCES public.conversations(id) ON DELETE CASCADE,
  sender_id       UUID REFERENCES public.users(id) ON DELETE CASCADE,
  content         TEXT NOT NULL,
  reply_to_id     UUID REFERENCES public.messages(id),
  read_at         TIMESTAMPTZ,
  created_at      TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================
-- NOTIFICATIONS
-- ============================================================
CREATE TABLE IF NOT EXISTS public.notifications (
  id         UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id    UUID REFERENCES public.users(id) ON DELETE CASCADE,
  title      TEXT NOT NULL,
  body       TEXT,
  type       TEXT DEFAULT 'info',
  read       BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================
-- RESSOURCES PÉDAGOGIQUES
-- ============================================================
CREATE TABLE IF NOT EXISTS public.resources (
  id          UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  title       TEXT NOT NULL,
  description TEXT,
  url         TEXT,
  type        TEXT DEFAULT 'document',
  course_id   UUID REFERENCES public.courses(id),
  teacher_id  UUID REFERENCES public.users(id),
  created_at  TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================
-- SERVICES CAMPUS
-- ============================================================
CREATE TABLE IF NOT EXISTS public.services (
  id          UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  name        TEXT NOT NULL,
  description TEXT,
  icon        TEXT,
  category    TEXT,
  is_active   BOOLEAN DEFAULT true,
  created_at  TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================
-- SALLES
-- ============================================================
CREATE TABLE IF NOT EXISTS public.rooms (
  id          UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  name        TEXT NOT NULL,
  capacity    INTEGER,
  building    TEXT,
  floor       INTEGER,
  is_available BOOLEAN DEFAULT true,
  created_at  TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================
-- CALENDRIER ACADÉMIQUE
-- ============================================================
CREATE TABLE IF NOT EXISTS public.academic_calendar (
  id          UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  title       TEXT NOT NULL,
  description TEXT,
  start_date  DATE NOT NULL,
  end_date    DATE,
  type        TEXT DEFAULT 'event',
  created_at  TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================
-- LOGS ADMIN
-- ============================================================
CREATE TABLE IF NOT EXISTS public.admin_activity_logs (
  id          UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  admin_id    UUID REFERENCES public.users(id),
  action      TEXT NOT NULL,
  target_type TEXT,
  target_id   UUID,
  details     JSONB,
  created_at  TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================
-- INDEX pour les performances
-- ============================================================
CREATE INDEX IF NOT EXISTS idx_grades_student ON public.grades(student_id);
CREATE INDEX IF NOT EXISTS idx_grades_course ON public.grades(course_id);
CREATE INDEX IF NOT EXISTS idx_attendance_student ON public.attendance(student_id);
CREATE INDEX IF NOT EXISTS idx_attendance_course ON public.attendance(course_id);
CREATE INDEX IF NOT EXISTS idx_messages_conversation ON public.messages(conversation_id);
CREATE INDEX IF NOT EXISTS idx_notifications_user ON public.notifications(user_id);
CREATE INDEX IF NOT EXISTS idx_schedules_course ON public.schedules(course_id);
CREATE INDEX IF NOT EXISTS idx_schedules_teacher ON public.schedules(teacher_id);
