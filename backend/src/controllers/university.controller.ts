import { Request, Response } from 'express';
import { sendSuccess } from '../utils/response.util';

// Mock data since tables are missing in the current schema
const MOCK_FACULTIES = [
  { id: '1', nom: 'Faculté des Sciences et Techniques', code: 'FST' },
  { id: '2', nom: 'Faculté des Lettres et Sciences Humaines', code: 'FLSH' },
  { id: '3', nom: 'Faculté des Sciences de Gestion', code: 'FSG' },
];

const MOCK_DEPARTMENTS: Record<string, any[]> = {
  '1': [
    { id: '101', nom: 'Informatique', code: 'INFO' },
    { id: '102', nom: 'Mathématiques', code: 'MATH' },
    { id: '103', nom: 'Physique', code: 'PHYS' },
  ],
  '2': [
    { id: '201', nom: 'Sociologie', code: 'SOC' },
    { id: '202', nom: 'Anglais', code: 'ANG' },
  ],
  '3': [
    { id: '301', nom: 'Comptabilité', code: 'COMPTA' },
    { id: '302', nom: 'Marketing', code: 'MKT' },
  ],
};

const MOCK_FILIERES: Record<string, any[]> = {
  '101': [
    { id: '1011', nom: 'Génie Logiciel', code: 'GL' },
    { id: '1012', nom: 'Systèmes et Réseaux', code: 'SR' },
  ],
};

export const getFaculties = async (req: Request, res: Response) => {
  sendSuccess(res, MOCK_FACULTIES);
};

export const getDepartments = async (req: Request, res: Response) => {
  const { facultyId } = req.params as Record<string, string>;
  const departments = MOCK_DEPARTMENTS[facultyId as string] || [];
  sendSuccess(res, departments);
};

export const getFilieres = async (req: Request, res: Response) => {
  const { departmentId } = req.params as Record<string, string>;
  const filieres = MOCK_FILIERES[departmentId as string] || [];
  sendSuccess(res, filieres);
};
