import { Router, Request, Response } from "express";

import prisma from "../lib/prisma";

const router = Router();

type Period = "allTime" | "daily" | "weekly" | "monthly";

function getDateFilter(period: Period): Date | null {
  const now = new Date();
  switch (period) {
    case "daily":
      return new Date(now.getTime() - 24 * 60 * 60 * 1000);
    case "weekly":
      return new Date(now.getTime() - 7 * 24 * 60 * 60 * 1000);
    case "monthly":
      return new Date(now.getTime() - 30 * 24 * 60 * 60 * 1000);
    default:
      return null;
  }
}

router.get("/", async (req: Request, res: Response) => {
  const { period = "allTime" } = req.query;
  const filterDate = getDateFilter(period as Period);

  const sessions = await prisma.gameSession.findMany({
    where: filterDate ? { createdAt: { gte: filterDate } } : undefined,
    include: { user: true },
    orderBy: { score: "desc" },
  });

  const uniqueByUser = new Map<string, typeof sessions[number]>();
  for (const session of sessions) {
    if (!uniqueByUser.has(session.userId)) {
      uniqueByUser.set(session.userId, session);
    }
  }

  const top = Array.from(uniqueByUser.values()).slice(0, 10);
  res.json(
    top.map((session) => ({
      userId: session.userId,
      nickname: session.user.nickname,
      score: session.score,
      createdAt: session.createdAt,
    })),
  );
});

export default router;
