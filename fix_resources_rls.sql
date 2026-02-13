-- Enable RLS on the public.resources table
ALTER TABLE public.resources ENABLE ROW LEVEL SECURITY;

-- Allow read access to all authenticated users
CREATE POLICY "Enable read access for all users" ON "public"."resources"
AS PERMISSIVE FOR SELECT
TO public
USING (true);

-- Allow insert access to authenticated users (e.g. teachers)
CREATE POLICY "Enable insert for authenticated users" ON "public"."resources"
AS PERMISSIVE FOR INSERT
TO authenticated
WITH CHECK (true);

-- Allow update/delete for owners
-- Assuming 'author_id' matches auth.uid()
CREATE POLICY "Enable update for owners" ON "public"."resources"
AS PERMISSIVE FOR UPDATE
TO authenticated
USING (auth.uid() = author_id)
WITH CHECK (auth.uid() = author_id);

CREATE POLICY "Enable delete for owners" ON "public"."resources"
AS PERMISSIVE FOR DELETE
TO authenticated
USING (auth.uid() = author_id);
