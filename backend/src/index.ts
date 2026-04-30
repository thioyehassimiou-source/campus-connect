import express from 'express';
import cors from 'cors';
import helmet from 'helmet';
import morgan from 'morgan';
import dotenv from 'dotenv';
import path from 'path';

dotenv.config();

import authRoutes from './routes/auth.routes';
import scheduleRoutes from './routes/schedule.routes';
import announcementRoutes from './routes/announcement.routes';
import courseRoutes from './routes/course.routes';
import notificationRoutes from './routes/notification.routes';
import campusRoutes from './routes/campus.routes';
import resourceRoutes from './routes/resource.routes';
import chatRoutes from './routes/chat.routes';
import uploadRoutes from './routes/upload.routes';
import gradeRoutes from './routes/grade.routes';
import attendanceRoutes from './routes/attendance.routes';
import assignmentRoutes from './routes/assignment.routes';
import universityRoutes from './routes/university.routes';

import { Server } from 'socket.io';
import http from 'http';

const app = express();
const server = http.createServer(app);
const io = new Server(server, {
  cors: {
    origin: '*',
  }
});
const PORT = process.env.PORT || 3000;
// Middlewares
app.use(helmet());
app.use(cors());
app.use(morgan('dev'));
app.use(express.json());

// Servir les fichiers uploadés statiquement
app.use('/uploads', express.static(path.join(__dirname, '../uploads')));

// Routes
app.get('/', (req, res) => {
  res.json({ message: 'CampusConnect API v1.0 is running 🚀', status: 'OK' });
});

app.use('/auth', authRoutes);
app.use('/schedule', scheduleRoutes);
app.use('/announcements', announcementRoutes);
app.use('/courses', courseRoutes);
app.use('/notifications', notificationRoutes);
app.use('/campus', campusRoutes);
app.use('/resources', resourceRoutes);
app.use('/chat', chatRoutes);
app.use('/upload', uploadRoutes);
app.use('/grades', gradeRoutes);
app.use('/attendance', attendanceRoutes);
app.use('/assignments', assignmentRoutes);
app.use('/universities', universityRoutes);

// Socket.io configuration
io.on('connection', (socket) => {
  console.log(`🔌 Nouvel utilisateur connecté: ${socket.id}`);

  // Rejoindre une room (conversation)
  socket.on('join_conversation', (conversationId) => {
    socket.join(conversationId);
    console.log(`User ${socket.id} joined conversation: ${conversationId}`);
  });

  // Envoyer un message
  socket.on('send_message', (data) => {
    // data devrait contenir: conversationId, message, senderId, etc.
    console.log('Nouveau message reçu:', data);
    
    // On broadcast le message à tous les utilisateurs dans la room (sauf l'expéditeur)
    // ou à tout le monde si on le renvoie tel quel
    if (data.conversationId) {
       io.to(data.conversationId).emit('receive_message', data);
    }
  });

  socket.on('disconnect', () => {
    console.log(`❌ Utilisateur déconnecté: ${socket.id}`);
  });
});

// 404
app.use((req, res) => {
  res.status(404).json({ error: `Route ${req.method} ${req.path} non trouvée` });
});

server.listen(PORT, () => {
  console.log(`✅ Serveur CampusConnect démarré sur http://localhost:${PORT}`);
});
