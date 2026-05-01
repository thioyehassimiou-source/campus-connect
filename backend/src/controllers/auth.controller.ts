import { Request, Response } from 'express';
import bcrypt from 'bcryptjs';
import jwt from 'jsonwebtoken';
import prisma from '../lib/prisma';
import { sendSuccess, sendError } from '../utils/response.util';

const JWT_SECRET = process.env.JWT_SECRET || 'campusconnect_secret_key_change_in_production';
const JWT_EXPIRES_IN = process.env.JWT_EXPIRES_IN || '7d';

// Fonction utilitaire pour transformer et enrichir un utilisateur DB en UserModel Frontend
const transformUser = async (dbUser: any) => {
  const profile = dbUser.profiles;
  if (!profile) return null;

  const nameParts = (profile.full_name || '').split(' ');
  const firstName = nameParts[0] || '';
  const lastName = nameParts.slice(1).join(' ') || '';

  const userData: any = {
    id: dbUser.id,
    email: dbUser.email,
    first_name: firstName,
    last_name: lastName,
    role: dbUser.role.toLowerCase().replace('é', 'e'),
    phone: profile.phone || "",
    profile_image_url: profile.avatar_url || "",
    department: profile.filiere || "",
    student_id: profile.matricule || "",
    created_at: dbUser.created_at,
    updated_at: dbUser.updated_at,
    is_active: true,
    niveau: profile.niveau || "",
  };

  // Si c'est un étudiant, on pourrait ajouter ses stats ici
  if (dbUser.role === 'Étudiant') {
    const grades = await prisma.grades.findMany({
      where: { student_id: dbUser.id }
    });
    
    if (grades.length > 0) {
      let totalPoints = 0;
      let totalCoeff = 0;
      let earnedCredits = 0;

      for (const grade of grades) {
        const val = Number(grade.grade || 0);
        const coeff = 1;
        totalPoints += val * coeff;
        totalCoeff += coeff;
        if (val >= 10) earnedCredits += coeff;
      }

      userData.moyenne = Number((totalPoints / totalCoeff).toFixed(2));
      userData.credits_valides = earnedCredits;
    }
  }

  return userData;
};

// POST /auth/register
export const register = async (req: Request, res: Response): Promise<void> => {
  try {
    const { email, password, first_name, last_name, role = 'Étudiant', filiere, niveau, student_id } = req.body;

    if (!email || !password || !first_name) {
      sendError(res, 'Email, mot de passe et prénom sont requis', 400);
      return;
    }

    const existingUser = await prisma.users.findUnique({ where: { email } });
    if (existingUser) {
      sendError(res, 'Un compte avec cet email existe déjà', 409);
      return;
    }

    const password_hash = await bcrypt.hash(password, 12);
    const full_name = `${first_name} ${last_name || ''}`.trim();

    const user = await prisma.users.create({
      data: {
        email,
        password_hash,
        role: role.charAt(0).toUpperCase() + role.slice(1).toLowerCase(),
        profiles: {
          create: { 
            full_name, 
            role: role.charAt(0).toUpperCase() + role.slice(1).toLowerCase(),
            filiere: filiere,
            niveau: niveau,
            matricule: student_id 
          },
        },
      },
      include: { profiles: true },
    });

    const token = jwt.sign(
      { id: user.id, email: user.email, role: user.role },
      JWT_SECRET,
      { expiresIn: JWT_EXPIRES_IN } as any
    );

    sendSuccess(res, {
      token,
      refreshToken: token,
      user: await transformUser(user),
    }, 'Inscription réussie', 201);
  } catch (error) {
    console.error('Register error:', error);
    sendError(res, 'Erreur interne du serveur');
  }
};

// POST /auth/login
export const login = async (req: Request, res: Response): Promise<void> => {
  try {
    const { email, password } = req.body;

    if (!email || !password) {
      sendError(res, 'Email et mot de passe requis', 400);
      return;
    }

    const user = await prisma.users.findUnique({
      where: { email },
      include: { profiles: true },
    });

    if (!user) {
      sendError(res, 'Identifiants incorrects', 401);
      return;
    }

    const isValid = await bcrypt.compare(password, user.password_hash);
    if (!isValid) {
      sendError(res, 'Identifiants incorrects', 401);
      return;
    }

    const token = jwt.sign(
      { id: user.id, email: user.email, role: user.role },
      JWT_SECRET,
      { expiresIn: JWT_EXPIRES_IN } as any
    );

    sendSuccess(res, {
      token,
      refreshToken: token,
      user: await transformUser(user),
    }, 'Connexion réussie');
  } catch (error) {
    console.error('Login error:', error);
    sendError(res, 'Erreur interne du serveur');
  }
};

// GET /auth/me
export const getMe = async (req: any, res: Response): Promise<void> => {
  try {
    const user = await prisma.users.findUnique({
      where: { id: req.user.id },
      include: { profiles: true },
    });

    if (!user) {
      sendError(res, 'Utilisateur non trouvé', 404);
      return;
    }

    sendSuccess(res, await transformUser(user));
  } catch (error) {
    console.error('GetMe error:', error);
    sendError(res, 'Erreur interne du serveur');
  }
};
