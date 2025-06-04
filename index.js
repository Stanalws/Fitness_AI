import express from 'express';
import dotenv from 'dotenv';
import userRoutes from './routes/userRoutes.js';
import constraintRoutes from './routes/constraintRoutes.js';
import exerciseRoutes from './routes/exerciseRoutes.js';
import workoutRoutes from './routes/workoutRoutes.js';
import { connectDb } from './dbClient.js';

dotenv.config();

async function main() {
  const app = express();
  app.use(express.json());

  await connectDb();

  app.use('/', userRoutes);
  app.use('/profile/contraindications', constraintRoutes);
  app.use('/exercises', exerciseRoutes);
  app.use('/workouts', workoutRoutes);

  const PORT = process.env.PORT || 3000;
  app.listen(PORT, () => {
    console.log(`Server on http://localhost:${PORT}`);
  });
}

main().catch(err => console.error(err));