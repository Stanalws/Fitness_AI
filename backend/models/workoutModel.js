import { getDb } from '../dbClient.js';
import { ObjectId } from 'mongodb';

export async function createWorkout(userId, name, exercises) {
  const db = getDb();
  const doc = {
    owner_id: new ObjectId(userId),
    name: name.trim(),
    exercises: exercises.slice(),
    status: 'active',               
    created_at: new Date(),
    updated_at: new Date()
  };

  const result = await db.collection('workouts').insertOne(doc);
  return {
    workout_id: result.insertedId.toString(),
    owner_id: userId,
    name: doc.name,
    exercises: doc.exercises,
    status: doc.status,
    created_at: doc.created_at
  };
}

export async function getLatestWorkout(userId) {
  const db = getDb();
  const doc = await db
    .collection('workouts')
    .find({ owner_id: new ObjectId(userId) })
    .sort({ created_at: -1 })
    .limit(1)
    .next();

  if (!doc) return null;

  return {
    workout_id: doc._id.toString(),
    owner_id: doc.owner_id.toString(),
    name: doc.name,
    exercises: doc.exercises,
    status: doc.status,
    created_at: doc.created_at
  };
}