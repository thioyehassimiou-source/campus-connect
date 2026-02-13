-- Create the 'resources' bucket if it doesn't exist
INSERT INTO storage.buckets (id, name, public)
VALUES ('resources', 'resources', true)
ON CONFLICT (id) DO NOTHING;

-- Enable RLS on the bucket
-- (Storage uses the 'storage.objects' table for RLS)

-- Policy: Allow public read access to all files in 'resources' bucket
CREATE POLICY "Public Access"
ON storage.objects FOR SELECT
USING ( bucket_id = 'resources' );

-- Policy: Allow authenticated users (teachers/admins) to upload files
-- Adjust this logic if you want strict role-based checks. 
-- For now, allowing any authenticated user to upload is a good start, 
-- or you can restrict based on metadata if you have role info in auth.users (which we might not have easily accessible here without a join).
-- simpler: Allow any authenticated user to insert.
CREATE POLICY "Authenticated Upload"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK ( bucket_id = 'resources' );

-- Policy: Allow users to update/delete their own files (optional specific logic)
CREATE POLICY "Owner Update"
ON storage.objects FOR UPDATE
TO authenticated
USING ( bucket_id = 'resources' AND auth.uid() = owner );

CREATE POLICY "Owner Delete"
ON storage.objects FOR DELETE
TO authenticated
USING ( bucket_id = 'resources' AND auth.uid() = owner );
