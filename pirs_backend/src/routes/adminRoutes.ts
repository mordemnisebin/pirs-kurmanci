import { NextFunction, Router, Response } from "express";

import prisma from "../lib/prisma";
import {
  authenticate,
  AuthenticatedRequest,
} from "../middleware/authMiddleware";

const router = Router();

function isAdminEmail(email: string | null | undefined): boolean {
  const adminEnv = process.env.ADMIN_EMAIL;
  if (!email || !adminEnv) return false;
  return email.toLowerCase() === adminEnv.toLowerCase();
}

async function requireAdmin(
  req: AuthenticatedRequest,
  res: Response,
  next: NextFunction,
): Promise<void> {
  if (!req.userId) {
    res.status(401).json({ message: "Token tune" });
    return;
  }

  const user = await prisma.user.findUnique({ where: { id: req.userId } });
  if (!user || !isAdminEmail(user.email)) {
    res.status(403).json({ message: "Destûr tune" });
    return;
  }

  next();
}

// Kategorî çêke
router.post(
  "/categories",
  authenticate,
  requireAdmin,
  async (req: AuthenticatedRequest, res: Response) => {
    try {
      const { name } = req.body;
      if (!name || typeof name !== "string" || name.trim().length < 2) {
        res.status(400).json({ message: "Navê kategoriyê çewt e" });
        return;
      }

      const category = await prisma.category.create({
        data: { name: name.trim() },
      });

      res.status(201).json(category);
    } catch (error) {
      res.status(500).json({ message: "Çewtiyek çêbû" });
    }
  },
);

// Pirs çêke
router.post(
  "/questions",
  authenticate,
  requireAdmin,
  async (req: AuthenticatedRequest, res: Response) => {
    try {
      const {
        text,
        optionA,
        optionB,
        optionC,
        optionD,
        correctOption,
        difficulty,
        categoryId,
      } = req.body;

      if (
        !text ||
        !optionA ||
        !optionB ||
        !optionC ||
        !optionD ||
        !["A", "B", "C", "D"].includes(String(correctOption).toUpperCase()) ||
        !difficulty ||
        !categoryId
      ) {
        res.status(400).json({ message: "Zêdetir agahî hewce ye" });
        return;
      }

      const question = await prisma.question.create({
        data: {
          text: String(text),
          optionA: String(optionA),
          optionB: String(optionB),
          optionC: String(optionC),
          optionD: String(optionD),
          correctOption: String(correctOption).toUpperCase(),
          difficulty: String(difficulty),
          categoryId: String(categoryId),
          authorId: req.userId,
        },
      });

      res.status(201).json(question);
    } catch (error) {
      res.status(500).json({ message: "Çewtiyek çêbû" });
    }
  },
);

// Pirs jê bibe
router.delete(
  "/questions/:id",
  authenticate,
  requireAdmin,
  async (req: AuthenticatedRequest, res: Response) => {
    try {
      const { id } = req.params;

      await prisma.question.delete({ where: { id } });
      res.status(204).end();
    } catch (error) {
      res.status(404).json({ message: "Pirs nehat dîtin" });
    }
  },
);

export default router;
