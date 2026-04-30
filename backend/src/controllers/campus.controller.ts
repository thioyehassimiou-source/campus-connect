import { Request, Response } from 'express';
import prisma from '../lib/prisma';
import { sendSuccess, sendError } from '../utils/response.util';

// GET /campus/blocs
export const getCampusBlocs = async (req: Request, res: Response) => {
  try {
    const rooms = await prisma.rooms.findMany({
      select: { building: true },
      distinct: ['building'],
    });
    
    const blocs = rooms
      .filter(r => r.building)
      .map(r => ({ id: r.building, name: r.building }));

    sendSuccess(res, blocs);
  } catch (error) {
    console.error('GetCampusBlocs error:', error);
    sendError(res, 'Erreur lors de la récupération des blocs');
  }
};

// GET /campus/services
export const getInstitutionalServices = async (req: Request, res: Response) => {
  try {
    const { category } = req.query as Record<string, string>;
    let where: any = { is_active: true };
    
    if (category) {
      where.category = category as string;
    }

    const services = await prisma.services.findMany({
      where,
      orderBy: { name: 'asc' },
    });
    sendSuccess(res, services);
  } catch (error) {
    console.error('GetServices error:', error);
    sendError(res, 'Erreur lors de la récupération des services');
  }
};
