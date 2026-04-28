-- ==============================================================================
-- 🔔 SYSTÈME DE NOTIFICATIONS
-- ==============================================================================

CREATE TABLE IF NOT EXISTS public.notifications (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    content TEXT NOT NULL,
    type TEXT NOT NULL, -- 'assignment', 'grade', 'message', 'announcement', 'service'
    related_id TEXT, -- ID de l'objet lié (ex: ID du devoir)
    is_read BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Index pour la performance
CREATE INDEX IF NOT EXISTS idx_notifications_user ON public.notifications(user_id);
CREATE INDEX IF NOT EXISTS idx_notifications_is_read ON public.notifications(is_read);
CREATE INDEX IF NOT EXISTS idx_notifications_created_at ON public.notifications(created_at DESC);

-- SECURITY (RLS)
ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can see their own notifications"
ON public.notifications FOR SELECT
TO authenticated
USING (user_id = auth.uid());

CREATE POLICY "Users can update their own notifications"
ON public.notifications FOR UPDATE
TO authenticated
USING (user_id = auth.uid());

-- Activer Realtime
ALTER PUBLICATION supabase_realtime ADD TABLE public.notifications;

-- ==============================================================================
-- ⚡ TRIGGERS POUR NOTIFICATIONS AUTOMATIQUES
-- ==============================================================================

-- 1. Notification lors d'un nouveau devoir
CREATE OR REPLACE FUNCTION public.notify_new_assignment()
RETURNS TRIGGER AS $$
BEGIN
    -- On notifie tous les étudiants (ou une cible plus précise si on avait des classes/groupes)
    -- Pour la démo, on simule une notification vers les profils 'Student'
    INSERT INTO public.notifications (user_id, title, content, type, related_id)
    SELECT id, 'Nouveau devoir : ' || NEW.title, 'Un nouveau devoir de ' || NEW.course || ' a été publié.', 'assignment', NEW.id
    FROM public.profiles
    WHERE role = 'Student';
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER tr_on_new_assignment
AFTER INSERT ON public.assignments
FOR EACH ROW
EXECUTE FUNCTION public.notify_new_assignment();

-- 2. Notification lors d'une note publiée
CREATE OR REPLACE FUNCTION public.notify_new_grade()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.status = 'graded' AND (OLD.status IS NULL OR OLD.status != 'graded') THEN
        INSERT INTO public.notifications (user_id, title, content, type, related_id)
        VALUES (
            NEW.student_id, 
            'Devoir noté !', 
            'Votre travail pour le devoir "' || (SELECT title FROM public.assignments WHERE id = NEW.assignment_id) || '" a été corrigé.', 
            'grade', 
            NEW.assignment_id
        );
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER tr_on_new_grade
AFTER UPDATE ON public.submissions
FOR EACH ROW
EXECUTE FUNCTION public.notify_new_grade();

-- 3. Notification pour nouvelle annonce
CREATE OR REPLACE FUNCTION public.notify_new_announcement()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO public.notifications (user_id, title, content, type, related_id)
    SELECT id, 'Nouvelle annonce : ' || NEW.title, NEW.content, 'announcement', NEW.id
    FROM public.profiles;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER tr_on_new_announcement
AFTER INSERT ON public.announcements
FOR EACH ROW
EXECUTE FUNCTION public.notify_new_announcement();
