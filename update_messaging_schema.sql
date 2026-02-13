-- Add new columns to conversations table for status tracking
ALTER TABLE conversations ADD COLUMN IF NOT EXISTS last_message_sender_id UUID REFERENCES profiles(id);
ALTER TABLE conversations ADD COLUMN IF NOT EXISTS is_last_message_read BOOLEAN DEFAULT true;

-- RPC to get or check existence of a private (1-1) conversation
CREATE OR REPLACE FUNCTION get_private_conversation(user1 UUID, user2 UUID)
RETURNS UUID AS $$
DECLARE
    conv_id UUID;
BEGIN
    SELECT cp1.conversation_id INTO conv_id
    FROM conversation_participants cp1
    JOIN conversation_participants cp2 ON cp1.conversation_id = cp2.conversation_id
    JOIN conversations c ON cp1.conversation_id = c.id
    WHERE cp1.user_id = user1 
      AND cp2.user_id = user2 
      AND c.is_group = false
    LIMIT 1;
    
    RETURN conv_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
