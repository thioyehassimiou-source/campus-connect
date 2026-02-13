-- Create courses table
CREATE TABLE IF NOT EXISTS public.courses (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    title TEXT NOT NULL,
    description TEXT,
    teacher_id UUID REFERENCES auth.users(id) NOT NULL,
    level TEXT NOT NULL, -- L1, L2, L3, M1, M2
    color TEXT DEFAULT '#2563EB',
    status TEXT DEFAULT 'Actif',
    students_count INTEGER DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Enable RLS
ALTER TABLE public.courses ENABLE ROW LEVEL SECURITY;

-- Policies

-- Everyone can view courses
DO $$ BEGIN
    CREATE POLICY "Public courses are viewable by everyone" ON public.courses
        FOR SELECT USING (true);
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

-- Teachers can insert their own courses
DO $$ BEGIN
    CREATE POLICY "Teachers can insert their own courses" ON public.courses
        FOR INSERT WITH CHECK (auth.uid() = teacher_id);
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

-- Teachers can update their own courses
DO $$ BEGIN
    CREATE POLICY "Teachers can update their own courses" ON public.courses
        FOR UPDATE USING (auth.uid() = teacher_id);
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

-- Teachers can delete their own courses
DO $$ BEGIN
    CREATE POLICY "Teachers can delete their own courses" ON public.courses
        FOR DELETE USING (auth.uid() = teacher_id);
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

-- Grant access to authenticated users
GRANT ALL ON TABLE public.courses TO authenticated;
GRANT ALL ON TABLE public.courses TO service_role;

-- Note: Sample data can be added via the app UI after table creation
-- auth.uid() returns null when running SQL scripts directly in the SQL Editor

