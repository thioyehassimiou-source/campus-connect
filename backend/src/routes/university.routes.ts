import { Router } from 'express';
import { getFilieres, getServices, getFaculties } from '../controllers/university.controller';

const router = Router();

router.get('/filieres', getFilieres);
router.get('/faculties', getFaculties);
router.get('/services', getServices);

export default router;
