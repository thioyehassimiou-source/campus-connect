import { Response } from 'express';

export const sendSuccess = (res: Response, data: any, message?: string, statusCode: number = 200) => {
  return res.status(statusCode).json({
    success: true,
    data,
    message,
  });
};

export const sendError = (res: Response, message: string, statusCode: number = 500, details?: string[]) => {
  return res.status(statusCode).json({
    success: false,
    error: {
      code: statusCode,
      message,
      details,
    },
  });
};
