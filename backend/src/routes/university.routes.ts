import { Router } from 'express';
import { getFilieres } from '../controllers/university.controller';

const router = Router();

router.get('/filieres', getFilieres);

export default router;
