import { Request, Response, NextFunction } from 'express';
import jwt, { JwtPayload } from 'jsonwebtoken';
import { AppError } from './errorHandler.js';
import { config } from '@/config.js';

export interface AuthUser {
    sub: string;
    userId: string;
    scope?: string[];
}

declare module 'express-serve-static-core' {
    interface Request {
        user?: AuthUser;
    }
}

export function jwtAuth(required = true) {
    return (req: Request, _: Response, next: NextFunction) => {
        const auth = req.headers.authorization;

        if (!auth) {
            if (required) return next(new AppError(401, 'Missing Authorization'));
            return next();
        }

        const token = auth.replace(/^Bearer\s+/i, '');

        try {
            const payload = jwt.verify(
                token,
                config.jwtSecret,
                {
                    algorithms: ['HS256'],
                    issuer: 'supabase',
                }
            ) as JwtPayload;
            payload.
                req.user = {
                sub: payload.sub!,
                role: payload.role,
            };
            next();
        } catch {
            next(new AppError(401, 'Invalid token'));
        }
    };
}
