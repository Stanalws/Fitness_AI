import { getAllConstraints } from '../models/constraintModel.js';

export async function listConstraints(req, res) {
  try {
    const contraindications = await getAllConstraints();
    res.json(contraindications);
  } catch (error) {
    console.error('Ошибка получения противопоказаний:', error);
    res.status(500).json({ error: 'Ошибка сервера' });
  }
}