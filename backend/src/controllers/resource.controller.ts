import { Response } from 'express';
import prisma from '../lib/prisma';
import { sendSuccess, sendError } from '../utils/response.util';
import { AuthRequest } from '../middlewares/auth.middleware';

// GET /resources
export const getResources = async (req: AuthRequest, res: Response) => {
  try {
    const { subject } = req.query as Record<string, string>;
    let where: any = {};
    
    if (subject && subject !== 'Tout') {
      where.subject = subject as string;
    }

    const resources = await prisma.resources.findMany({
      where,
      orderBy: { created_at: 'desc' },
    });
    sendSuccess(res, resources);
  } catch (error) {
    sendError(res, 'Erreur lors de la récupération des ressources');
  }
};

// POST /resources
export const createResource = async (req: AuthRequest, res: Response) => {
  try {
    const user = req.user!;
    const { title, description, url, type, subject, scope, departmentId, facultyId, niveau } = req.body;

    const profile = await prisma.profiles.findUnique({ where: { id: user.id } });
    const authorName = profile?.full_name || 'Enseignant';

    const resource = await prisma.resources.create({
      data: {
        title,
        description,
        url,
        type: type || 'PDF',
        course_id: subject,
        teacher_id: user.id,
        author_name: authorName,
        scope: scope || 'license',
        department_id: departmentId,
        faculty_id: facultyId,
        niveau: niveau,
      },
    });
    sendSuccess(res, resource, 'Ressource ajoutée', 201);
  } catch (error) {
    sendError(res, 'Erreur lors de l\'ajout de la ressource');
  }
};
