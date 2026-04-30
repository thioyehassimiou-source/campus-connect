import { Router } from 'express';
import { 
  getConversations, 
  getMessages, 
  getContacts, 
  sendMessage, 
  getOrCreateConversation, 
  markAsRead,
  deleteConversation
} from '../controllers/chat.controller';
import { authenticate } from '../middlewares/auth.middleware';

const router = Router();

router.get('/conversations', authenticate, getConversations);
router.get('/messages/:conversationId', authenticate, getMessages);
router.get('/contacts', authenticate, getContacts);
router.post('/messages', authenticate, sendMessage);
router.post('/conversations', authenticate, getOrCreateConversation);
router.patch('/conversations/:conversationId/read', authenticate, markAsRead);
router.delete('/conversations/:conversationId', authenticate, deleteConversation);

export default router;
