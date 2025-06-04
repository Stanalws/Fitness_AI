import { getAllExercises } from '../models/exerciseModel.js';

export async function fetchAllExercises(req, res) {
  try {
    const exercises = await getAllExercises();
    return res.status(200).json(exercises);
  } catch (err) {
    console.error('Ошибка fetchAllExercises:', err);
    return res.status(500).json({ error: 'Ошибка получения упражнений' });
  }
}
