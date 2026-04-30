import { Response } from 'express';
import prisma from '../lib/prisma';
import { sendSuccess, sendError } from '../utils/response.util';
import { AuthRequest } from '../middlewares/auth.middleware';

// GET /chat/conversations
export const getConversations = async (req: AuthRequest, res: Response) => {
  try {
    const userId = req.user!.id;

    // Récupérer les conversations où l'utilisateur participe
    const participations = await prisma.conversation_participants.findMany({
      where: { user_id: userId },
      select: { conversation_id: true }
    });

    const conversationIds = participations.map(p => p.conversation_id);

    // Récupérer les détails des conversations
    const conversations = await prisma.conversations.findMany({
      where: { id: { in: conversationIds } },
      orderBy: { last_message_time: 'desc' },
      include: {
        conversation_participants: {
          where: { user_id: { not: userId } },
          include: {
            profiles: {
              select: { full_name: true, avatar_url: true }
            }
          },
          take: 1
        }
      }
    });

    // Formater pour le frontend
    const result = conversations.map(c => {
      const otherPart = c.conversation_participants[0];
      return {
        id: c.id,
        name: c.name || (otherPart?.profiles?.full_name ?? 'Chat'),
        avatar_url: otherPart?.profiles?.avatar_url,
        is_group: c.is_group,
        last_message: c.last_message,
        last_message_time: c.last_message_time,
        last_message_sender_id: c.last_message_sender_id,
        is_last_message_read: c.is_last_message_read,
      };
    });

    sendSuccess(res, result);
  } catch (error) {
    console.error('GetConversations error:', error);
    sendError(res, 'Erreur lors de la récupération des conversations');
  }
};

// GET /chat/messages/:conversationId
export const getMessages = async (req: AuthRequest, res: Response) => {
  try {
    const { conversationId } = req.params as Record<string, string>;

    const messages = await prisma.messages.findMany({
      where: { conversation_id: conversationId },
      orderBy: { created_at: 'asc' },
      include: {
        profiles: { // Sender
          select: { full_name: true }
        },
        messages: { // Replied message (self-relation)
          include: {
            profiles: { select: { full_name: true } }
          }
        }
      }
    });

    // Formater pour le frontend
    const result = messages.map(m => ({
      id: m.id,
      conversation_id: m.conversation_id,
      sender_id: m.sender_id,
      sender_name: m.profiles?.full_name,
      content: m.content,
      created_at: m.created_at,
      is_read: m.is_read,
      type: m.type,
      reply_to_id: m.reply_to_id,
      replied_content: m.messages?.content,
      replied_sender_name: m.messages?.profiles?.full_name
    }));

    sendSuccess(res, result);
  } catch (error) {
    console.error('GetMessages error:', error);
    sendError(res, 'Erreur lors de la récupération des messages');
  }
};

// GET /chat/contacts
export const getContacts = async (req: AuthRequest, res: Response) => {
  try {
    const userId = req.user!.id;
    const userRole = req.user!.role;

    let where: any = { id: { not: userId } };
    
    // Filtre : Les étudiants ne voient que les profs/admin
    if (userRole === 'Étudiant') {
      where.role = { not: 'Étudiant' };
    }

    const contacts = await prisma.profiles.findMany({
      where,
      select: { id: true, full_name: true, avatar_url: true, role: true },
      orderBy: { full_name: 'asc' }
    });

    sendSuccess(res, contacts);
  } catch (error) {
    sendError(res, 'Erreur lors de la récupération des contacts');
  }
};

// POST /chat/messages
export const sendMessage = async (req: AuthRequest, res: Response) => {
  try {
    const userId = req.user!.id;
    const { conversationId, content, type, replyToId } = req.body;

    if (!conversationId || !content) {
      return sendError(res, 'Conversation ID et contenu requis');
    }

    // Créer le message
    const message = await prisma.messages.create({
      data: {
        conversation_id: conversationId,
        sender_id: userId,
        content,
        type: type || 'text',
        reply_to_id: replyToId,
      },
      include: {
        profiles: { select: { full_name: true } }
      }
    });

    // Mettre à jour la conversation (last_message, updated_at, etc.)
    await prisma.conversations.update({
      where: { id: conversationId },
      data: {
        last_message: content,
        last_message_time: new Date(),
        last_message_sender_id: userId,
        is_last_message_read: false,
        updated_at: new Date()
      }
    });

    sendSuccess(res, message, 'Message envoyé', 201);
  } catch (error) {
    console.error('SendMessage error:', error);
    sendError(res, 'Erreur lors de l\'envoi du message');
  }
};

// POST /chat/conversations
export const getOrCreateConversation = async (req: AuthRequest, res: Response) => {
  try {
    const userId = req.user!.id;
    const { otherUserId } = req.body;

    if (!otherUserId) return sendError(res, 'ID de l\'autre utilisateur requis');

    // Chercher une conversation privée existante entre ces deux utilisateurs
    const existingConv = await prisma.conversations.findFirst({
      where: {
        is_group: false,
        conversation_participants: {
          some: { user_id: userId }
        },
        AND: {
          conversation_participants: {
            some: { user_id: otherUserId }
          }
        }
      },
      include: {
        conversation_participants: {
          where: { user_id: { not: userId } },
          include: { profiles: { select: { full_name: true, avatar_url: true } } }
        }
      }
    });

    if (existingConv) {
      // Formater pour le frontend (même structure que getConversations)
      const otherPart = existingConv.conversation_participants[0];
      return sendSuccess(res, {
        id: existingConv.id,
        name: otherPart?.profiles?.full_name ?? 'Chat',
        avatar_url: otherPart?.profiles?.avatar_url,
        is_group: false,
        last_message: existingConv.last_message,
        last_message_time: existingConv.last_message_time,
      });
    }

    // Créer une nouvelle conversation
    const newConv = await prisma.conversations.create({
      data: {
        is_group: false,
        conversation_participants: {
          create: [
            { user_id: userId },
            { user_id: otherUserId }
          ]
        }
      },
      include: {
        conversation_participants: {
          where: { user_id: { not: userId } },
          include: { profiles: { select: { full_name: true, avatar_url: true } } }
        }
      }
    });

    const otherPart = newConv.conversation_participants[0];
    sendSuccess(res, {
      id: newConv.id,
      name: otherPart?.profiles?.full_name ?? 'Chat',
      avatar_url: otherPart?.profiles?.avatar_url,
      is_group: false,
    }, 'Conversation créée', 201);
  } catch (error) {
    console.error('GetOrCreateConversation error:', error);
    sendError(res, 'Erreur lors de la création de la conversation');
  }
};

// PATCH /chat/conversations/:conversationId/read
export const markAsRead = async (req: AuthRequest, res: Response) => {
  try {
    const { conversationId } = req.params as Record<string, string>;
    const userId = req.user!.id;

    // Marquer les messages comme lus
    await prisma.messages.updateMany({
      where: {
        conversation_id: conversationId,
        sender_id: { not: userId },
        is_read: false
      },
      data: {
        is_read: true,
        read_at: new Date()
      }
    });

    // Mettre à jour l'état de la conversation
    await prisma.conversations.update({
      where: { id: conversationId },
      data: { is_last_message_read: true }
    });

    sendSuccess(res, null, 'Marqué comme lu');
  } catch (error) {
    sendError(res, 'Erreur lors du marquage de lecture');
  }
};

// DELETE /chat/conversations/:conversationId
export const deleteConversation = async (req: AuthRequest, res: Response) => {
  try {
    const { conversationId } = req.params as Record<string, string>;
    await prisma.conversations.delete({ where: { id: conversationId } });
    sendSuccess(res, null, 'Conversation supprimée');
  } catch (error) {
    sendError(res, 'Erreur lors de la suppression de la conversation');
  }
};
