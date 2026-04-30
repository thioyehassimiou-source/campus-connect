import { Router } from 'express';
import multer from 'multer';
import path from 'path';
import { v4 as uuidv4 } from 'uuid';
import { authenticate } from '../middlewares/auth.middleware';

const router = Router();

// Configuration de Multer pour stocker les fichiers localement
const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, 'uploads/'); // Les fichiers seront sauvegardés dans le dossier 'uploads/' à la racine du backend
  },
  filename: (req, file, cb) => {
    const ext = path.extname(file.originalname);
    const filename = `${uuidv4()}${ext}`; // Nom unique
    cb(null, filename);
  }
});

const upload = multer({
  storage,
  limits: { fileSize: 10 * 1024 * 1024 }, // Limite de 10 MB par fichier
});

// Endpoint d'upload (protégé)
router.post('/', authenticate, upload.single('file'), (req, res) => {
  try {
    if (!req.file) {
      return res.status(400).json({ success: false, error: 'Aucun fichier uploadé.' });
    }

    // On retourne l'URL locale du fichier
    // Exemple: /uploads/abc-123.jpg
    const fileUrl = `/uploads/${req.file.filename}`;
    
    res.json({
      success: true,
      url: fileUrl,
      fileName: req.file.originalname,
      mimeType: req.file.mimetype,
      size: req.file.size
    });
  } catch (error) {
    console.error('Erreur lors de l\'upload:', error);
    res.status(500).json({ success: false, error: 'Erreur serveur lors de l\'upload du fichier.' });
  }
});

export default router;
