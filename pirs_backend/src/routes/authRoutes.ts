import { Router, Request, Response } from "express";
import bcrypt from "bcryptjs";

import prisma from "../lib/prisma";
import { authenticate, AuthenticatedRequest } from "../middleware/authMiddleware";
import { signToken } from "../utils/jwt";

const router = Router();

router.post("/register", async (req: Request, res: Response) => {
  const { email, password, nickname } = req.body;

  if (!email || !password || !nickname) {
    res.status(400).json({ message: "Zêdetir agahî hewce ye" });
    return;
  }

  const existing = await prisma.user.findUnique({ where: { email } });
  if (existing) {
    res.status(409).json({ message: "Ev e-peyam jixwe tomar bûye" });
    return;
  }

  const passwordHash = await bcrypt.hash(password, 10);
  const user = await prisma.user.create({
    data: { email, passwordHash, nickname },
  });

  const token = signToken({ userId: user.id });
  res.status(201).json({ token, user: { id: user.id, nickname, email } });
});

router.post("/login", async (req: Request, res: Response) => {
  const { email, password } = req.body;

  const user = await prisma.user.findUnique({ where: { email } });
  if (!user) {
    res.status(401).json({ message: "Agahî çewt e" });
    return;
  }

  const isValid = await bcrypt.compare(password, user.passwordHash);
  if (!isValid) {
    res.status(401).json({ message: "Agahî çewt e" });
    return;
  }

  const token = signToken({ userId: user.id });
  res.json({ token, user: { id: user.id, nickname: user.nickname, email: user.email } });
});

router.get("/me", authenticate, async (req: AuthenticatedRequest, res: Response) => {
  const user = await prisma.user.findUnique({ where: { id: req.userId } });
  if (!user) {
    res.status(404).json({ message: "Bikarhêner nehat dîtin" });
    return;
  }

  res.json({ id: user.id, email: user.email, nickname: user.nickname, avatarUrl: user.avatarUrl });
});

export default router;
