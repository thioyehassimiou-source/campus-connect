import { Server, Socket } from 'socket.io';
import jwt from 'jsonwebtoken';
import prisma from './prisma';

const JWT_SECRET = process.env.JWT_SECRET || 'campusconnect_secret_key_change_in_production';

interface AuthenticatedSocket extends Socket {
  user?: any;
}

export const setupSocket = (server: any) => {
  const io = new Server(server, {
    cors: {
      origin: '*',
      methods: ['GET', 'POST'],
    },
  });

  // Middleware d'authentification
  io.use((socket: AuthenticatedSocket, next) => {
    const token = socket.handshake.auth.token || socket.handshake.headers['authorization'];
    
    if (!token) {
      return next(new Error('Authentication error: Token missing'));
    }

    try {
      // Nettoyer le format "Bearer <token>" si présent
      const cleanToken = token.startsWith('Bearer ') ? token.slice(7) : token;
      const decoded = jwt.verify(cleanToken, JWT_SECRET);
      socket.user = decoded;
      next();
    } catch (err) {
      return next(new Error('Authentication error: Invalid token'));
    }
  });

  io.on('connection', async (socket: AuthenticatedSocket) => {
    const userId = socket.user?.id;
    console.log(`🔌 Utilisateur connecté: ${userId} (${socket.id})`);

    // L'utilisateur rejoint sa propre room pour les notifications privées
    if (userId) {
      socket.join(`user:${userId}`);
    }

    // Rejoindre une conversation
    socket.on('join_conversation', (conversationId: string) => {
      socket.join(`conv:${conversationId}`);
      console.log(`👤 User ${userId} rejoint la conversation: ${conversationId}`);
    });

    // Quitter une conversation
    socket.on('leave_conversation', (conversationId: string) => {
      socket.leave(`conv:${conversationId}`);
      console.log(`👤 User ${userId} quitte la conversation: ${conversationId}`);
    });

    // Gérer l'envoi de message
    socket.on('send_message', async (data: { conversationId: string; content: string; type?: string }) => {
      try {
        const { conversationId, content, type = 'text' } = data;

        // 1. Sauvegarder dans la base de données
        const message = await prisma.messages.create({
          data: {
            conversation_id: conversationId,
            sender_id: userId,
            content,
            type,
          },
          include: {
            users: {
              select: {
                id: true,
                email: true,
                profiles: {
                  select: {
                    full_name: true,
                    avatar_url: true,
                  },
                },
              },
            },
          },
        });

        // 2. Mettre à jour la date du dernier message dans la conversation
        await prisma.conversations.update({
          where: { id: conversationId },
          data: {
            last_message: content,
            last_message_time: new Date(),
            last_message_sender_id: userId,
          },
        });

        // 3. Diffuser le message à tous les membres de la conversation
        io.to(`conv:${conversationId}`).emit('new_message', message);
        
        // 4. (Optionnel) Envoyer une notification aux membres qui ne sont pas dans la room
        // On pourrait le faire via les rooms 'user:userId'
      } catch (error) {
        console.error('Erreur Socket message:', error);
        socket.emit('error', { message: 'Failed to send message' });
      }
    });

    // Indicateur "En train d'écrire"
    socket.on('typing_start', (conversationId: string) => {
      socket.to(`conv:${conversationId}`).emit('user_typing_start', {
        conversationId,
        userId,
      });
    });

    socket.on('typing_stop', (conversationId: string) => {
      socket.to(`conv:${conversationId}`).emit('user_typing_stop', {
        conversationId,
        userId,
      });
    });

    socket.on('disconnect', () => {
      console.log(`❌ Déconnexion de l'utilisateur: ${userId}`);
    });
  });

  return io;
};
