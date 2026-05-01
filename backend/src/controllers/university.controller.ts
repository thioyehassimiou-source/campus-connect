import { Request, Response } from 'express';
import { sendSuccess, sendError } from '../utils/response.util';
import prisma from '../lib/prisma';

export const getFilieres = async (req: Request, res: Response) => {
  try {
    const filieres = await prisma.filieres.findMany({
      orderBy: { nom: 'asc' }
    });
    sendSuccess(res, filieres);
  } catch (error) {
    sendError(res, 'Erreur lors de la récupération des filières');
  }
};
