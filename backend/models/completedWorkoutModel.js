import { getDb } from '../dbClient.js';
import { ObjectId } from 'mongodb';

export async function saveCompletedWorkout(workoutId, userId, dateCompleted, results) {
  const db = getDb();
  const completedAt = new Date(dateCompleted);

  const doc = {
    workout_id: new ObjectId(workoutId),
    owner_id: new ObjectId(userId),
    date_completed: completedAt,
    results: results.map(r => ({
      exercise_id: new ObjectId(r.exercise_id),
      recommended_reps: r.recommended_reps ?? null,
      recommended_duration: r.recommended_duration ?? null,
      performed_reps: r.performed_reps ?? null,
      performed_duration: r.performed_duration ?? null,
      difficulty: r.difficulty,
      avg_heart_rate: r.avg_heart_rate,
    })),
  };

  await db.collection('completed_workouts').insertOne(doc);

  await db.collection('workouts').updateOne(
    { _id: new ObjectId(workoutId), owner_id: new ObjectId(userId) },
    { $set: { status: 'completed', date_completed: completedAt } }
  );
}

export async function getWorkoutHistory(userId) {
  const db = getDb();
  return db
    .collection('completed_workouts')
    .find({ owner_id: new ObjectId(userId) })
    .toArray();
}
