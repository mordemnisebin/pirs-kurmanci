import { Router, Response } from "express";

import prisma from "../lib/prisma";
import { authenticate, AuthenticatedRequest } from "../middleware/authMiddleware";

const router = Router();

router.post("/finish", authenticate, async (req: AuthenticatedRequest, res: Response) => {
  const { score, totalQuestions, correctAnswers } = req.body;

  if (
    typeof score !== "number" ||
    typeof totalQuestions !== "number" ||
    typeof correctAnswers !== "number"
  ) {
    res.status(400).json({ message: "Agahîya lêdan çewt e" });
    return;
  }

  const session = await prisma.gameSession.create({
    data: {
      userId: req.userId!,
      score,
      totalQuestions,
      correctAnswers,
    },
  });

  res.status(201).json(session);
});

router.get("/stats", authenticate, async (req: AuthenticatedRequest, res: Response) => {
  const userId = req.userId!;

  const [aggregate, bestSession, totalSessions] = await Promise.all([
    prisma.gameSession.aggregate({
      where: { userId },
      _avg: { score: true },
      _sum: { score: true, correctAnswers: true, totalQuestions: true },
    }),
    prisma.gameSession.findFirst({
      where: { userId },
      orderBy: { score: "desc" },
    }),
    prisma.gameSession.count({ where: { userId } }),
  ]);

  if (!totalSessions) {
    res.json({
      totalSessions: 0,
      bestScore: 0,
      averageScore: 0,
      correctRate: 0,
    });
    return;
  }

  const sum = aggregate._sum;
  const avgScore = aggregate._avg.score ?? 0;
  const correct = sum?.correctAnswers ?? 0;
  const totalQ = sum?.totalQuestions ?? 0;

  res.json({
    totalSessions,
    bestScore: bestSession?.score ?? 0,
    averageScore: Math.round(avgScore),
    correctRate: totalQ > 0 ? correct / totalQ : 0,
  });
});

export default router;
