import { Server as HttpServer } from "http";
import { Server, Socket } from "socket.io";
import prisma from "../lib/prisma";

interface Player {
  odaId: string;
  odaKod: string;
  odaAd?: string;
  lîstikvan: Array<{
    id: string;
    socketId: string;
    name: string;
    avatar?: string;
    score: number;
    isReady: boolean;
    team?: string;
  }>;
  xwedî: string;
  maxPlayers: number;
  gameMode?: string;
  rewş: "waiting" | "playing" | "finished";
  difficulty?: string;
  categoryId?: string;
  currentQuestion: number;
  questions: any[];
}

// Aktif odalar
const rooms: Map<string, Player> = new Map();

// Rastgele oda kodu üret
function generateRoomCode(): string {
  const chars = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789";
  let code = "";
  for (let i = 0; i < 6; i++) {
    code += chars[Math.floor(Math.random() * chars.length)];
  }
  return code;
}

export function setupSocketIO(httpServer: HttpServer) {
  const io = new Server(httpServer, {
    cors: {
      origin:
        process.env.NODE_ENV === "production"
          ? [
              "https://pirs-kurmanci.vercel.app",
              "https://pirs-flutter.vercel.app",
              /\.vercel\.app$/,
              /\.netlify\.app$/,
            ]
          : "*",
      methods: ["GET", "POST"],
      credentials: true,
    },
  });

  io.on("connection", (socket: Socket) => {
    console.log(`🔌 Lîstikvan hate girêdan: ${socket.id}`);

    // Yeni oda oluştur
    socket.on(
      "createRoom",
      async (data: {
        userId: string;
        name: string;
        categoryId?: string;
        difficulty?: string;
        maxPlayers?: number;
        gameMode?: string; // 1vs1, team, ffa
      }) => {
        try {
          const roomCode = generateRoomCode();
          const roomId = `room_${roomCode}_${Date.now()}`;
          const gameMode = data.gameMode || "ffa";

          // Soruları çek
          const where: any = {};
          if (data.categoryId) {
            where.categoryId = data.categoryId;
          }

          const allQuestions = await prisma.question.findMany({ where });

          // Rastgele karıştır ve 10 soru seç
          const shuffled = allQuestions.sort(() => Math.random() - 0.5);
          const questions = shuffled.slice(0, 10);

          let teamAssignment: string | undefined;
          if (gameMode === "team") {
            teamAssignment = "A"; // Oda kurucusu Takım A
          }

          const room: Player = {
            odaId: roomId,
            odaKod: roomCode,
            lîstikvan: [
              {
                id: data.userId,
                socketId: socket.id,
                name: data.name,
                score: 0,
                isReady: true,
                team: teamAssignment,
              },
            ],
            xwedî: data.userId,
            maxPlayers: gameMode === "1vs1" ? 2 : data.maxPlayers || 4,
            gameMode: gameMode,
            rewş: "waiting",
            categoryId: data.categoryId,
            difficulty: data.difficulty,
            currentQuestion: 0,
            questions: questions,
          };

          rooms.set(roomCode, room);
          socket.join(roomCode);

          console.log(`🏠 Oda hat afirandin: ${roomCode} ji ${data.name}`);

          socket.emit("roomCreated", {
            success: true,
            roomCode,
            room: {
              ...room,
              questions: undefined, // Soruları istemciye gönderme
            },
          });
        } catch (error) {
          console.error("❌ Oda afirandin çewtî:", error);
          socket.emit("error", { message: "Oda nehate afirandin" });
        }
      },
    );

    // Odaya katıl
    socket.on(
      "joinRoom",
      (data: { roomCode: string; userId: string; name: string }) => {
        const room = rooms.get(data.roomCode.toUpperCase());

        if (!room) {
          socket.emit("error", { message: "Oda nehate dîtin" });
          return;
        }

        if (room.rewş !== "waiting") {
          socket.emit("error", { message: "Lîstik dest pê kiriye" });
          return;
        }

        if (room.lîstikvan.length >= room.maxPlayers) {
          socket.emit("error", { message: "Oda tijî ye" });
          return;
        }

        // Takım belirleme
        let assignedTeam: string | undefined;
        if (room.gameMode === "team") {
          const teamA = room.lîstikvan.filter((p) => p.team === "A").length;
          const teamB = room.lîstikvan.filter((p) => p.team === "B").length;
          assignedTeam = teamA <= teamB ? "A" : "B";
        }

        // Oyuncuyu ekle
        room.lîstikvan.push({
          id: data.userId,
          socketId: socket.id,
          name: data.name,
          score: 0,
          isReady: false,
          team: assignedTeam,
        });

        socket.join(data.roomCode.toUpperCase());
        console.log(`👤 ${data.name} odayê ${data.roomCode} hat`);

        // Tüm odadakilere bildir
        io.to(data.roomCode.toUpperCase()).emit("playerJoined", {
          players: room.lîstikvan.map((p) => ({
            id: p.id,
            name: p.name,
            isReady: p.isReady,
            score: p.score,
          })),
          newPlayer: data.name,
        });

        socket.emit("roomJoined", {
          success: true,
          roomCode: data.roomCode.toUpperCase(),
          players: room.lîstikvan.map((p) => ({
            id: p.id,
            name: p.name,
            isReady: p.isReady,
            score: p.score,
          })),
          isOwner: false,
        });
      },
    );

    // Hazır ol
    socket.on("setReady", (data: { roomCode: string; userId: string }) => {
      const room = rooms.get(data.roomCode);
      if (!room) return;

      const player = room.lîstikvan.find((p) => p.id === data.userId);
      if (player) {
        player.isReady = true;
        io.to(data.roomCode).emit("playerReady", {
          playerId: data.userId,
          players: room.lîstikvan.map((p) => ({
            id: p.id,
            name: p.name,
            isReady: p.isReady,
            score: p.score,
          })),
        });
      }
    });

    // Oyunu başlat (sadece oda sahibi)
    socket.on("startGame", (data: { roomCode: string; userId: string }) => {
      const room = rooms.get(data.roomCode);
      if (!room) return;

      if (room.xwedî !== data.userId) {
        socket.emit("error", {
          message: "Tenê xwediyê odayê dikare dest pê bike",
        });
        return;
      }

      if (room.lîstikvan.length < 2) {
        socket.emit("error", { message: "Herî kêm 2 lîstikvan lazim in" });
        return;
      }

      const allReady = room.lîstikvan.every((p) => p.isReady);
      if (!allReady) {
        socket.emit("error", { message: "Hemû lîstikvan amade ne" });
        return;
      }

      room.rewş = "playing";
      room.currentQuestion = 0;

      console.log(`🎮 Lîstik dest pê kir li oda ${data.roomCode}`);

      // İlk soruyu gönder
      const question = room.questions[0];
      io.to(data.roomCode).emit("gameStarted", {
        question: {
          id: question.id,
          text: question.text,
          optionA: question.optionA,
          optionB: question.optionB,
          optionC: question.optionC,
          optionD: question.optionD,
          difficulty: question.difficulty,
        },
        questionNumber: 1,
        totalQuestions: room.questions.length,
        timeLimit: 15,
      });
    });

    // Cevap ver
    socket.on(
      "submitAnswer",
      (data: {
        roomCode: string;
        userId: string;
        answer: string;
        timeSpent: number;
      }) => {
        const room = rooms.get(data.roomCode);
        if (!room || room.rewş !== "playing") return;

        const question = room.questions[room.currentQuestion];
        const isCorrect = data.answer === question.correctOption;

        const player = room.lîstikvan.find((p) => p.id === data.userId);
        if (player && isCorrect) {
          // Zaman bonusu: hızlı cevap daha çok puan
          const timeBonus = Math.max(0, 15 - data.timeSpent) * 10;
          player.score += 100 + timeBonus;
        }

        // Tüm oyunculara güncelleme gönder
        io.to(data.roomCode).emit("answerResult", {
          playerId: data.userId,
          isCorrect,
          correctAnswer: question.correctOption,
          explanation: question.explanation,
          scores: room.lîstikvan.map((p) => ({
            id: p.id,
            name: p.name,
            score: p.score,
          })),
        });
      },
    );

    // Sonraki soru
    socket.on("nextQuestion", (data: { roomCode: string }) => {
      const room = rooms.get(data.roomCode);
      if (!room || room.rewş !== "playing") return;

      room.currentQuestion++;

      if (room.currentQuestion >= room.questions.length) {
        // Oyun bitti
        room.rewş = "finished";

        const sortedPlayers = [...room.lîstikvan].sort(
          (a, b) => b.score - a.score,
        );

        io.to(data.roomCode).emit("gameEnded", {
          winner: sortedPlayers[0],
          rankings: sortedPlayers.map((p, i) => ({
            rank: i + 1,
            id: p.id,
            name: p.name,
            score: p.score,
          })),
        });

        // 30 saniye sonra odayı temizle
        setTimeout(() => {
          rooms.delete(data.roomCode);
          console.log(`🗑️ Oda hate jêbirin: ${data.roomCode}`);
        }, 30000);

        return;
      }

      // Sonraki soru
      const question = room.questions[room.currentQuestion];
      io.to(data.roomCode).emit("newQuestion", {
        question: {
          id: question.id,
          text: question.text,
          optionA: question.optionA,
          optionB: question.optionB,
          optionC: question.optionC,
          optionD: question.optionD,
          difficulty: question.difficulty,
        },
        questionNumber: room.currentQuestion + 1,
        totalQuestions: room.questions.length,
        timeLimit: 15,
      });
    });

    // Odadan ayrıl
    socket.on("leaveRoom", (data: { roomCode: string; userId: string }) => {
      const room = rooms.get(data.roomCode);
      if (!room) return;

      room.lîstikvan = room.lîstikvan.filter((p) => p.id !== data.userId);
      socket.leave(data.roomCode);

      if (room.lîstikvan.length === 0) {
        rooms.delete(data.roomCode);
        console.log(`🗑️ Oda vala ma û hate jêbirin: ${data.roomCode}`);
      } else {
        // Oda sahibi ayrıldıysa yeni sahip ata
        if (room.xwedî === data.userId && room.lîstikvan.length > 0) {
          room.xwedî = room.lîstikvan[0].id;
        }

        io.to(data.roomCode).emit("playerLeft", {
          playerId: data.userId,
          players: room.lîstikvan.map((p) => ({
            id: p.id,
            name: p.name,
            isReady: p.isReady,
            score: p.score,
          })),
          newOwner: room.xwedî,
        });
      }
    });

    // Bağlantı koptuğunda
    socket.on("disconnect", () => {
      console.log(`🔌 Lîstikvan qut bû: ${socket.id}`);

      // Oyuncuyu tüm odalardan çıkar
      rooms.forEach((room, roomCode) => {
        const playerIndex = room.lîstikvan.findIndex(
          (p) => p.socketId === socket.id,
        );
        if (playerIndex !== -1) {
          const player = room.lîstikvan[playerIndex];
          room.lîstikvan.splice(playerIndex, 1);

          if (room.lîstikvan.length === 0) {
            rooms.delete(roomCode);
          } else {
            if (room.xwedî === player.id) {
              room.xwedî = room.lîstikvan[0].id;
            }
            io.to(roomCode).emit("playerDisconnected", {
              playerId: player.id,
              playerName: player.name,
              players: room.lîstikvan.map((p) => ({
                id: p.id,
                name: p.name,
                isReady: p.isReady,
                score: p.score,
              })),
            });
          }
        }
      });
    });
  });

  console.log("🎮 Socket.IO amade ye ji bo multiplayer");
  return io;
}
