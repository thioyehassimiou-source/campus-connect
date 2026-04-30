import { Response } from 'express';
import prisma from '../lib/prisma';
import { sendSuccess, sendError } from '../utils/response.util';
import { AuthRequest } from '../middlewares/auth.middleware';

// GET /schedule
export const getSchedules = async (req: AuthRequest, res: Response) => {
  try {
    const user = req.user;
    if (!user) return sendError(res, 'Non authentifié', 401);

    let where: any = {};

    // Filtres selon le rôle
    if (user.role === 'Étudiant') {
      where.status = 0; // Uniquement validés
      // On pourrait filtrer par filière/niveau ici si besoin
    } else if (user.role === 'Enseignant') {
      where.teacher_id = user.id;
    }

    const schedules = await prisma.schedules.findMany({
      where,
      orderBy: { start_time: 'asc' },
    });

    sendSuccess(res, schedules);
  } catch (error) {
    console.error('GetSchedules error:', error);
    sendError(res, 'Erreur lors de la récupération de l\'emploi du temps');
  }
};

// POST /schedule
export const createSchedule = async (req: AuthRequest, res: Response) => {
  try {
    const user = req.user!;
    const { 
      subject, // This is course_id from frontend
      day, 
      start_time, 
      end_time, 
      room, 
      niveau, 
      semester,
      filiere
    } = req.body;

    // Convert day number to string if needed
    const days = ['Dimanche', 'Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi', 'Samedi'];
    const dayOfWeek = typeof day === 'number' ? days[day] : day;

    const schedule = await prisma.schedules.create({
      data: {
        course_id: subject,
        teacher_id: user.id,
        day_of_week: dayOfWeek || 'Lundi',
        start_time: new Date(start_time),
        end_time: new Date(end_time),
        room,
        niveau,
        semester,
        filiere,
        status: user.role === 'Admin' ? 0 : 3, // 0: Validé, 3: En attente
      },
    });

    sendSuccess(res, schedule, 'Cours ajouté avec succès', 201);
  } catch (error) {
    console.error('CreateSchedule error:', error);
    sendError(res, 'Erreur lors de la création du cours');
  }
};

// PATCH /schedule/:id
export const updateScheduleStatus = async (req: AuthRequest, res: Response) => {
  try {
    const { id } = req.params as Record<string, string>;
    const { status, notes } = req.body;

    const schedule = await prisma.schedules.update({
      where: { id },
      data: { status, notes },
    });

    sendSuccess(res, schedule, 'Statut mis à jour');
  } catch (error) {
    sendError(res, 'Erreur lors de la mise à jour');
  }
};
