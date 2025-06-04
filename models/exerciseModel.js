import { getDb } from '../dbClient.js';

export async function getAllExercises() {
  const db = getDb();
  return db.collection('exercises').find({}).toArray();
}
