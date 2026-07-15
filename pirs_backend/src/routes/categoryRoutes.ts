import { Router, Request, Response } from "express";

import prisma from "../lib/prisma";

const router = Router();

router.get("/", async (_req: Request, res: Response) => {
  const categories = await prisma.category.findMany({
    orderBy: { name: "asc" },
    include: {
      _count: {
        select: { questions: true },
      },
    },
  });
  res.json(categories);
});

export default router;
