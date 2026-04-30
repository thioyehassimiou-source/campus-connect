import { Router } from 'express';
import { getCampusBlocs, getInstitutionalServices } from '../controllers/campus.controller';

const router = Router();

router.get('/blocs', getCampusBlocs);
router.get('/services', getInstitutionalServices);

export default router;
