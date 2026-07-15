import { NextFunction, Request, Response } from "express";

export function requestLogger(
  req: Request,
  res: Response,
  next: NextFunction,
): void {
  const start = Date.now();
  const { method, url } = req;

  res.on("finish", () => {
    const duration = Date.now() - start;
    const status = res.statusCode;
    // Hêmû log li console, li prod de dikare bi tool-ên din were guhdar kirin
    console.log(`${method} ${url} -> ${status} (${duration}ms)`);
  });

  next();
}
