import express from 'express';
import { fetchAllExercises } from '../controllers/exerciseController.js';

const router = express.Router();

router.get('/', fetchAllExercises);

export default router;
