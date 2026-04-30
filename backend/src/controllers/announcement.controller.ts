import { Response } from 'express';
import prisma from '../lib/prisma';
import { sendSuccess, sendError } from '../utils/response.util';
import { AuthRequest } from '../middlewares/auth.middleware';

// GET /announcements
export const getAnnouncements = async (req: AuthRequest, res: Response) => {
  try {
    const announcements = await prisma.announcements.findMany({
      orderBy: [
        { is_pinned: 'desc' },
        { created_at: 'desc' }
      ]
    });

    sendSuccess(res, announcements);
  } catch (error) {
    console.error('GetAnnouncements error:', error);
    sendError(res, 'Erreur lors de la récupération des annonces');
  }
};

// POST /announcements
export const createAnnouncement = async (req: AuthRequest, res: Response) => {
  try {
    const user = req.user!;
    const { title, content, category, priority, scope, facultyId, departmentId, niveau } = req.body;

    const profile = await prisma.profiles.findUnique({ where: { id: user.id } });
    const authorName = profile?.full_name || 'Administration';

    const announcement = await prisma.announcements.create({
      data: {
        title,
        content,
        category,
        priority: priority || 'Moyenne',
        author_name: authorName,
        author_id: user.id,
        scope: scope || 'university',
        faculty_id: facultyId,
        department_id: departmentId,
        niveau: niveau,
        is_pinned: false
      },
    });

    // TODO: La logique de notification pourrait être ajoutée ici côté serveur
    
    sendSuccess(res, announcement, 'Annonce créée avec succès', 201);
  } catch (error) {
    console.error('CreateAnnouncement error:', error);
    sendError(res, 'Erreur lors de la création de l\'annonce');
  }
};

// DELETE /announcements/:id
export const deleteAnnouncement = async (req: AuthRequest, res: Response) => {
  try {
    const { id } = req.params as Record<string, string>;
    await prisma.announcements.delete({ where: { id } });
    sendSuccess(res, null, 'Annonce supprimée');
  } catch (error) {
    sendError(res, 'Erreur lors de la suppression');
  }
};
