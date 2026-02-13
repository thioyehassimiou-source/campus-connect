-- Create the 'campus_blocs' table
CREATE TABLE IF NOT EXISTS public.campus_blocs (
    id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
    name text NOT NULL,
    description text,
    icon_name text, -- We'll map this string to an IconData in Flutter
    color_hex text, -- e.g. "0xFF2563EB"
    services text[], -- Array of service names
    position_x float8 NOT NULL, -- Relative X position (0.0 to 1.0)
    position_y float8 NOT NULL, -- Relative Y position (0.0 to 1.0)
    created_at timestamptz DEFAULT now()
);

-- Enable RLS
ALTER TABLE public.campus_blocs ENABLE ROW LEVEL SECURITY;

-- Policy: Everyone can read
CREATE POLICY "Enable read access for all users" ON "public"."campus_blocs"
AS PERMISSIVE FOR SELECT
TO public
USING (true);

-- Policy: Only admins/service_role can insert/update/delete (adjusted for now to authenticated for simplicity if needed, but keeping it safe)
-- For now, letting authenticated users insert might be too open, but let's stick to public read.
-- We will insert initial data via this script.

-- Insert Initial Data (Bloc A, B, C, D)
INSERT INTO public.campus_blocs (name, description, icon_name, color_hex, services, position_x, position_y)
VALUES
(
    'Bloc A',
    'Administration & Rectorat',
    'account_balance',
    '0xFF2563EB',
    ARRAY['Scolarité', 'Examens', 'Rectorat', 'Direction'],
    0.2,
    0.2
),
(
    'Bloc B',
    'Faculté des Sciences',
    'science',
    '0xFF10B981',
    ARRAY['Informatique', 'Mathématiques', 'Physique', 'Chimie'],
    0.7,
    0.2
),
(
    'Bloc C',
    'Faculté des Lettres & Langues',
    'menu_book',
    '0xFFF59E0B',
    ARRAY['Lettres', 'Langues', 'Histoire', 'Philosophie'],
    0.2,
    0.7
),
(
    'Bloc D',
    'Bibliothèque & Services',
    'local_library',
    '0xFFEF4444',
    ARRAY['Bibliothèque', 'Cafétéria', 'Sport', 'Santé'],
    0.7,
    0.7
);
