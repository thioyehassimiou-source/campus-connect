-- Create a secure function to check participation without triggering RLS recursion
CREATE OR REPLACE FUNCTION public.is_conversation_participant(_conversation_id UUID)
RETURNS BOOLEAN AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1 FROM public.conversation_participants
    WHERE conversation_id = _conversation_id
    AND user_id = auth.uid()
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Drop existing recursive policies for ALL tables that might loop
DROP POLICY IF EXISTS "Users can view participants" ON public.conversation_participants;
DROP POLICY IF EXISTS "Users can view messages" ON public.messages;
DROP POLICY IF EXISTS "Users can send messages" ON public.messages;
DROP POLICY IF EXISTS "Users can view their conversations" ON public.conversations;
DROP POLICY IF EXISTS "Users can update their conversations" ON public.conversations;


-- Re-create policies using the secure function

-- Conversations
CREATE POLICY "Users can view their conversations" ON public.conversations
    FOR SELECT USING (
        public.is_conversation_participant(id)
    );

CREATE POLICY "Users can update their conversations" ON public.conversations
    FOR UPDATE USING (
        public.is_conversation_participant(id)
    );

-- Participants
CREATE POLICY "Users can view participants" ON public.conversation_participants
    FOR SELECT USING (
        public.is_conversation_participant(conversation_id)
    );

-- Messages
CREATE POLICY "Users can view messages" ON public.messages
    FOR SELECT USING (
        public.is_conversation_participant(conversation_id)
    );

CREATE POLICY "Users can send messages" ON public.messages
    FOR INSERT WITH CHECK (
        auth.uid() = sender_id AND
        public.is_conversation_participant(conversation_id)
    );
