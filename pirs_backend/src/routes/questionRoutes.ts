import { Router, Request, Response } from "express";

import prisma from "../lib/prisma";

const router = Router();

// Soruları rastgele karıştıran yardımcı fonksiyon
function shuffleArray<T>(array: T[]): T[] {
  const shuffled = [...array];
  for (let i = shuffled.length - 1; i > 0; i--) {
    const j = Math.floor(Math.random() * (i + 1));
    [shuffled[i], shuffled[j]] = [shuffled[j], shuffled[i]];
  }
  return shuffled;
}

router.get("/", async (req: Request, res: Response) => {
  const { categoryId, limit = "10", difficulty } = req.query;
  const take = Math.min(parseInt(limit as string, 10) || 10, 20);

  const where: any = {};

  if (categoryId) {
    where.categoryId = categoryId as string;
  }

  if (difficulty) {
    where.difficulty = difficulty as string;
  }

  // Daha fazla soru çek ve rastgele seç
  const allQuestions = await prisma.question.findMany({
    where,
    include: {
      category: {
        select: {
          name: true,
          nameKu: true,
          icon: true,
          color: true,
        }
      }
    }
  });

  // Rastgele karıştır ve limit kadar al
  const shuffled = shuffleArray(allQuestions);
  const questions = shuffled.slice(0, take);

  // Oynanma sayısını güncelle
  await prisma.question.updateMany({
    where: {
      id: { in: questions.map(q => q.id) }
    },
    data: {
      timesPlayed: { increment: 1 }
    }
  });

  res.json(questions);
});

// Tek soru getir
router.get("/:id", async (req: Request, res: Response) => {
  const question = await prisma.question.findUnique({
    where: { id: req.params.id },
    include: {
      category: {
        select: {
          name: true,
          nameKu: true,
          icon: true,
        }
      }
    }
  });

  if (!question) {
    return res.status(404).json({ error: "Pirs nehate dîtin" });
  }

  res.json(question);
});

export default router;
