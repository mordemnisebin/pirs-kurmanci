import express, { Request, Response } from "express";
import cors from "cors";
import rateLimit from "express-rate-limit";

import authRoutes from "./routes/authRoutes";
import categoryRoutes from "./routes/categoryRoutes";
import questionRoutes from "./routes/questionRoutes";
import gameRoutes from "./routes/gameRoutes";
import leaderboardRoutes from "./routes/leaderboardRoutes";
import adminRoutes from "./routes/adminRoutes";
import { requestLogger } from "./middleware/requestLogger";

const app = express();

// CORS ayarları - production ve development için
const corsOptions = {
  origin:
    process.env.NODE_ENV === "production"
      ? [
          "https://pirs-kurmanci.vercel.app",
          "https://pirs-flutter.vercel.app",
          "https://pirs-kurmanci.onrender.com",
          /\.vercel\.app$/,
          /\.netlify\.app$/,
          /\.onrender\.com$/,
        ]
      : [
          "http://localhost:3000",
          "http://localhost:5000",
          "http://localhost:8080",
        ],
  credentials: true,
  methods: ["GET", "POST", "PUT", "DELETE", "OPTIONS"],
  allowedHeaders: ["Content-Type", "Authorization"],
};

app.use(cors(corsOptions));
app.use(express.json());
app.use(requestLogger);

// Rate limiter
const apiLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 dakika
  max: 100, // Her IP için 15 dakikada en fazla 100 istek
  message: {
    message:
      "Gelek daxwaz hatin kirin, ji kerema xwe piştî demekê dîsa biceribînin.",
  },
  standardHeaders: true,
  legacyHeaders: false,
});
app.use("/", apiLimiter);

app.get("/health", (_req: Request, res: Response) => {
  res.json({ status: "ok" });
});

app.use("/auth", authRoutes);
app.use("/categories", categoryRoutes);
app.use("/questions", questionRoutes);
app.use("/games", gameRoutes);
app.use("/leaderboard", leaderboardRoutes);
app.use("/admin", adminRoutes);

export default app;
