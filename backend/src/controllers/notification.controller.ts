import { Response } from 'express';
import prisma from '../lib/prisma';
import { sendSuccess, sendError } from '../utils/response.util';
import { AuthRequest } from '../middlewares/auth.middleware';

// GET /notifications
export const getNotifications = async (req: AuthRequest, res: Response) => {
  try {
    const user = req.user!;
    const notifications = await prisma.notifications.findMany({
      where: { user_id: user.id },
      orderBy: { created_at: 'desc' },
    });
    sendSuccess(res, notifications);
  } catch (error) {
    sendError(res, 'Erreur lors de la récupération des notifications');
  }
};

// PATCH /notifications/:id/read
export const markAsRead = async (req: AuthRequest, res: Response) => {
  try {
    const { id } = req.params as Record<string, string>;
    const notification = await prisma.notifications.update({
      where: { id },
      data: { read: true },
    });
    sendSuccess(res, notification);
  } catch (error) {
    sendError(res, 'Erreur lors de la mise à jour');
  }
};

// PATCH /notifications/read-all
export const markAllAsRead = async (req: AuthRequest, res: Response) => {
  try {
    const user = req.user!;
    await prisma.notifications.updateMany({
      where: { user_id: user.id, read: false },
      data: { read: true },
    });
    sendSuccess(res, null, 'Toutes les notifications marquées comme lues');
  } catch (error) {
    sendError(res, 'Erreur lors de la mise à jour groupée');
  }
};

// DELETE /notifications/:id
export const deleteNotification = async (req: AuthRequest, res: Response) => {
  try {
    const { id } = req.params as Record<string, string>;
    await prisma.notifications.delete({ where: { id } });
    sendSuccess(res, null, 'Notification supprimée');
  } catch (error) {
    sendError(res, 'Erreur lors de la suppression');
  }
};
