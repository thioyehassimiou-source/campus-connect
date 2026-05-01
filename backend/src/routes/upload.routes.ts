import { Router } from 'express';
import { upload } from '../lib/multer';
import { authenticate } from '../middlewares/auth.middleware';
import prisma from '../lib/prisma';

const router = Router();

/**
 * @route   POST /upload/avatar
 * @desc    Uploader une image de profil
 * @access  Private
 */
router.post('/avatar', authenticate, upload.single('avatar'), async (req: any, res) => {
  try {
    if (!req.file) {
      return res.status(400).json({ error: 'Aucun fichier uploadé.' });
    }

    const fileUrl = `/uploads/avatars/${req.file.filename}`;
    const userId = req.user.id;

    // Mettre à jour le profil de l'utilisateur
    await prisma.profiles.update({
      where: { id: userId },
      data: { avatar_url: fileUrl }
    });

    res.json({
      success: true,
      url: fileUrl,
      message: 'Avatar mis à jour avec succès'
    });
  } catch (error) {
    console.error('Upload avatar error:', error);
    res.status(500).json({ error: 'Erreur lors de l\'upload de l\'avatar' });
  }
});

/**
 * @route   POST /upload/resource
 * @desc    Uploader une ressource de cours (PDF, etc.)
 * @access  Private (Enseignants/Admin)
 */
router.post('/resource', authenticate, upload.single('resource'), async (req: any, res) => {
  try {
    if (!req.file) {
      return res.status(400).json({ error: 'Aucun fichier uploadé.' });
    }

    const fileUrl = `/uploads/resources/${req.file.filename}`;
    
    // Note: Dans une v2 plus avancée, on créerait l'entrée 'resources' en base ici
    // si l'utilisateur envoie aussi title, description, course_id etc.

    res.json({
      success: true,
      url: fileUrl,
      fileName: req.file.originalname,
      mimeType: req.file.mimetype,
      size: req.file.size
    });
  } catch (error) {
    console.error('Upload resource error:', error);
    res.status(500).json({ error: 'Erreur lors de l\'upload de la ressource' });
  }
});

/**
 * @route   POST /upload/generic
 * @desc    Upload générique pour le chat
 * @access  Private
 */
router.post('/', authenticate, upload.single('file'), (req, res) => {
  try {
    if (!req.file) {
      return res.status(400).json({ error: 'Aucun fichier uploadé.' });
    }

    // Déterminer le dossier final (par défaut uploads/ si non classé)
    const folder = req.file.destination.split('/').pop() || '';
    const fileUrl = `/uploads/${folder ? folder + '/' : ''}${req.file.filename}`;
    
    res.json({
      success: true,
      url: fileUrl,
      fileName: req.file.originalname,
      mimeType: req.file.mimetype
    });
  } catch (error) {
    res.status(500).json({ error: 'Erreur lors de l\'upload du fichier.' });
  }
});

export default router;
