import { getDb } from '../dbClient.js';
import { ObjectId } from 'mongodb';
import { saveCompletedWorkout, getWorkoutHistory } from '../models/completedWorkoutModel.js';

export async function completeWorkoutController(req, res) {
  try {
    const userId = req.user.id;
    const { workout_id, date_completed, results } = req.body;

    if (!workout_id || !date_completed || !Array.isArray(results) || results.length === 0) {
      return res.status(400).json({ error: 'Неверные параметры для завершения тренировки' });
    }

    const db = getDb();
    const workoutDoc = await db.collection('workouts').findOne({
      _id: new ObjectId(workout_id),
      owner_id: new ObjectId(userId),
      status: 'active',
    });
    if (!workoutDoc) {
      return res.status(404).json({ error: 'Активная тренировка не найдена' });
    }

    await saveCompletedWorkout(workout_id, userId, date_completed, results);
    return res.status(200).json({ success: true });
  } catch (err) {
    console.error('Ошибка completeWorkoutController:', err);
    return res.status(500).json({ error: 'Не удалось сохранить результаты тренировки' });
  }
}

export async function getWorkoutHistoryController(req, res) {
  try {
    const userId = req.user.id;
    const db = getDb();

    const rawList = await getWorkoutHistory(userId);

    const workoutsArray = await Promise.all(
      rawList.map(async (doc) => {
        const workoutDoc = await db
          .collection('workouts')
          .findOne({ _id: new ObjectId(doc.workout_id) });

        return {
          _id: doc._id.toString(),
          name: workoutDoc?.name ?? 'Без названия',
          date_completed: doc.date_completed.toISOString(),
          results: doc.results.map((r) => ({
            exercise_id: r.exercise_id.toString(),
            recommended_reps: r.recommended_reps ?? null,
            recommended_duration: r.recommended_duration ?? null,
            performed_reps: r.performed_reps ?? null,
            performed_duration: r.performed_duration ?? null,
            difficulty: r.difficulty,
            avg_heart_rate: r.avg_heart_rate,
          })),
        };
      })
    );

    return res.status(200).json({ workouts: workoutsArray });
  } catch (err) {
    console.error('Ошибка getWorkoutHistoryController:', err);
    return res.status(500).json({ error: 'Не удалось получить историю тренировок' });
  }
}
