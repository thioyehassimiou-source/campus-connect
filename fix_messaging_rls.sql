-- 🛠️ FIX RLS FOR MESSAGING SYSTEM
-- OBJECTIVE: Allow users to create and participate in conversations

BEGIN;

-- 1. Table: conversations
ALTER TABLE public.conversations ENABLE ROW LEVEL SECURITY;

-- Delete old policies to start clean
DROP POLICY IF EXISTS "Users can view their conversations" ON public.conversations;
DROP POLICY IF EXISTS "Users can create conversations" ON public.conversations;

-- Allow users to view conversations they are part of
-- (This requires the conversation_participants table to be checked)
CREATE POLICY "Users can view their conversations" 
ON public.conversations FOR SELECT 
USING (
  EXISTS (
    SELECT 1 FROM public.conversation_participants 
    WHERE conversation_id = id AND user_id = auth.uid()
  )
);

-- Allow users to create conversations
-- (When creating a conversation, the user becomes a participant)
CREATE POLICY "Users can create conversations" 
ON public.conversations FOR INSERT 
WITH CHECK (true); -- We rely on participants table to tie them together

-- 2. Table: conversation_participants
ALTER TABLE public.conversation_participants ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Participants can view their entries" ON public.conversation_participants;
DROP POLICY IF EXISTS "Users can join conversations" ON public.conversation_participants;

CREATE POLICY "Participants can view their entries" 
ON public.conversation_participants FOR SELECT 
USING (user_id = auth.uid());

CREATE POLICY "Users can join conversations" 
ON public.conversation_participants FOR INSERT 
WITH CHECK (user_id = auth.uid());

-- 3. Table: messages
ALTER TABLE public.messages ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users can view messages in their conversations" ON public.messages;
DROP POLICY IF EXISTS "Users can send messages" ON public.messages;

CREATE POLICY "Users can view messages in their conversations" 
ON public.messages FOR SELECT 
USING (
  EXISTS (
    SELECT 1 FROM public.conversation_participants 
    WHERE conversation_id = messages.conversation_id AND user_id = auth.uid()
  )
);

CREATE POLICY "Users can send messages" 
ON public.messages FOR INSERT 
WITH CHECK (sender_id = auth.uid());

COMMIT;
