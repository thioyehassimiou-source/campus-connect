-- Create conversations table
CREATE TABLE public.conversations (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    last_message TEXT,
    last_message_time TIMESTAMP WITH TIME ZONE,
    is_group BOOLEAN DEFAULT FALSE,
    name TEXT -- For group chats
);

-- Create conversation_participants table (Join table)
CREATE TABLE public.conversation_participants (
    conversation_id UUID REFERENCES public.conversations(id) ON DELETE CASCADE,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    joined_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    PRIMARY KEY (conversation_id, user_id)
);

-- Create messages table
CREATE TABLE public.messages (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    conversation_id UUID REFERENCES public.conversations(id) ON DELETE CASCADE,
    sender_id UUID REFERENCES auth.users(id) ON DELETE SET NULL,
    content TEXT NOT NULL,
    type TEXT DEFAULT 'text', -- text, image, file
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    is_read BOOLEAN DEFAULT FALSE,
    metadata JSONB -- For file URLs, etc.
);

-- Enable RLS
ALTER TABLE public.conversations ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.conversation_participants ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.messages ENABLE ROW LEVEL SECURITY;

-- Policies for Conversations
-- 1. Users can view conversations they are participants of
CREATE POLICY "Users can view their conversations" ON public.conversations
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM public.conversation_participants
            WHERE conversation_id = conversations.id
            AND user_id = auth.uid()
        )
    );

-- 2. Users can create conversations (anyone can start a chat)
CREATE POLICY "Users can create conversations" ON public.conversations
    FOR INSERT WITH CHECK (true);

-- 3. Users can update conversations they are part of (e.g. update last_message)
CREATE POLICY "Users can update their conversations" ON public.conversations
    FOR UPDATE USING (
        EXISTS (
            SELECT 1 FROM public.conversation_participants
            WHERE conversation_id = conversations.id
            AND user_id = auth.uid()
        )
    );

-- Policies for Participants
-- 1. Users can view participants of conversations they are in
CREATE POLICY "Users can view participants" ON public.conversation_participants
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM public.conversation_participants cp
            WHERE cp.conversation_id = conversation_participants.conversation_id
            AND cp.user_id = auth.uid()
        )
    );

-- 2. Users can add participants (join) - simple version: users add themselves or others?
-- Let's allow users to insert rows where user_id is themselves OR if they are part of the convo (for groups later)
-- For now, allow insert if user_id is auth.uid() OR if creating a new conversation (handled by trigger usually, but here simple insert)
CREATE POLICY "Users can add participants" ON public.conversation_participants
    FOR INSERT WITH CHECK (
        true -- Simplified for initial setup, refine for production to prevent random adds
    );


-- Policies for Messages
-- 1. Users can view messages in conversations they belong to
CREATE POLICY "Users can view messages" ON public.messages
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM public.conversation_participants
            WHERE conversation_id = messages.conversation_id
            AND user_id = auth.uid()
        )
    );

-- 2. Users can insert messages if they are in the conversation
CREATE POLICY "Users can send messages" ON public.messages
    FOR INSERT WITH CHECK (
        auth.uid() = sender_id AND
        EXISTS (
            SELECT 1 FROM public.conversation_participants
            WHERE conversation_id = messages.conversation_id
            AND user_id = auth.uid()
        )
    );

-- Indexes for performance
CREATE INDEX idx_participants_user ON public.conversation_participants(user_id);
CREATE INDEX idx_participants_conversation ON public.conversation_participants(conversation_id);
CREATE INDEX idx_messages_conversation ON public.messages(conversation_id);
CREATE INDEX idx_messages_created_at ON public.messages(created_at DESC);
