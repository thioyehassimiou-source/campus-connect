-- 🛠️ FINAL FIX FOR MESSAGING RLS
-- PROBLEM: When creating a conversation, the client does "INSERT ... SELECT".
-- The SELECT fails because the user is not yet a participant (that happens in the next step).
-- SOLUTION: Track who created the conversation and allow them to see it.

BEGIN;

-- 1. Add 'created_by' column if it doesn't exist
DO $$ 
BEGIN 
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'conversations' AND column_name = 'created_by') THEN
        ALTER TABLE public.conversations ADD COLUMN created_by UUID REFERENCES auth.users(id);
    END IF;
END $$;

-- 2. Create a function to automatically set 'created_by' on insert
CREATE OR REPLACE FUNCTION public.set_conversation_created_by()
RETURNS TRIGGER AS $$
BEGIN
    NEW.created_by := auth.uid();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 3. Create Trigger (drop first to be safe)
DROP TRIGGER IF EXISTS trigger_set_conversation_created_by ON public.conversations;
CREATE TRIGGER trigger_set_conversation_created_by
    BEFORE INSERT ON public.conversations
    FOR EACH ROW
    EXECUTE FUNCTION public.set_conversation_created_by();

-- 4. Update the RLS Policy for SELECT
-- Drop old policy to ensure we don't have conflicts
DROP POLICY IF EXISTS "Users can view their conversations" ON public.conversations;

-- New Policy: You can view if you are a participant OR if you created it
CREATE POLICY "Users can view their conversations" 
ON public.conversations FOR SELECT 
USING (
    auth.uid() = created_by 
    OR 
    EXISTS (
        SELECT 1 FROM public.conversation_participants 
        WHERE conversation_id = id AND user_id = auth.uid()
    )
);

-- 5. Ensure INSERT policy is still open (it usually is, but let's be sure)
DROP POLICY IF EXISTS "Users can create conversations" ON public.conversations;
CREATE POLICY "Users can create conversations" 
ON public.conversations FOR INSERT 
WITH CHECK (true);

-- 6. Grant permissions just in case
GRANT ALL ON public.conversations TO authenticated;
GRANT ALL ON public.conversation_participants TO authenticated;
GRANT ALL ON public.messages TO authenticated;

COMMIT;

-- ✅ Verification Instructions:
-- 1. Run this script in Supabase SQL Editor.
-- 2. Restart the App.
-- 3. Try creating a new conversation.
