import { Request, Response } from 'express';
import { sendSuccess, sendError } from '../utils/response.util';
import prisma from '../lib/prisma';

export const getFilieres = async (req: Request, res: Response) => {
  try {
    // Dans le schéma migré, les filières correspondent aux départements
    const departments = await prisma.departments.findMany({
      orderBy: { name: 'asc' },
      include: { faculties: true }
    });
    // On renvoie un format compatible avec le frontend
    const result = departments.map(d => ({
      id: d.id,
      nom: d.name,
      faculty: d.faculties?.name
    }));
    sendSuccess(res, result);
  } catch (error) {
    console.error('Erreur getFilieres:', error);
    sendError(res, 'Erreur lors de la récupération des départements');
  }
};

export const getFaculties = async (req: Request, res: Response) => {
  try {
    const faculties = await prisma.faculties.findMany({
      orderBy: { name: 'asc' }
    });
    sendSuccess(res, faculties);
  } catch (error) {
    sendError(res, 'Erreur lors de la récupération des facultés');
  }
};

export const getServices = async (req: Request, res: Response) => {
  try {
    const services = await prisma.services.findMany({
      orderBy: { name: 'asc' }
    });
    // Formater pour que le frontend reçoive 'nom' au lieu de 'name'
    const result = services.map(s => ({
      ...s,
      nom: s.name
    }));
    sendSuccess(res, result);
  } catch (error) {
    sendError(res, 'Erreur lors de la récupération des services');
  }
};
