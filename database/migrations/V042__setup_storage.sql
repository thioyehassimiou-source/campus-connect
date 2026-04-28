-- Create a new bucket for chat attachments if it doesn't exist
-- Note: This must be run in the Supabase SQL Editor.
-- Some Supabase projects require creating buckets via the UI or a specific RPC.
-- Here is the SQL to enable public access and create the bucket if supported:

INSERT INTO storage.buckets (id, name, public)
VALUES ('chat_attachments', 'chat_attachments', true)
ON CONFLICT (id) DO NOTHING;

-- Set up RLS for the bucket
DROP POLICY IF EXISTS "Public Access chat_attachments" ON storage.objects;
CREATE POLICY "Public Access chat_attachments" ON storage.objects FOR SELECT USING (bucket_id = 'chat_attachments');

DROP POLICY IF EXISTS "Authenticated Upload chat_attachments" ON storage.objects;
CREATE POLICY "Authenticated Upload chat_attachments" ON storage.objects FOR INSERT WITH CHECK (bucket_id = 'chat_attachments' AND auth.role() = 'authenticated');
