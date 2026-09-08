import { Request, Response, NextFunction } from 'express';
import { StatsService } from '@/services/stats.service.js';
import { AppError } from '@/middlewares/errorHandler.js';

export class StatsController {
    static async getStats(req: Request, res: Response, next: NextFunction) {
        try {
            const stats = await StatsService.getArticleStats(req.params.id!);
            res.json(stats);
        } catch (e) { next(e); }
    }

    static async trackView(req: Request, res: Response, next: NextFunction) {
        try {
            const views = await StatsService.incrementView(req.params.id!);
            res.json({ success: true, views });
        } catch (e) { next(e); }
    }

    static async handleLike(req: Request, res: Response, next: NextFunction) {
        try {
            const { articleId, userId } = req.body;
            if (!articleId || !userId) throw new AppError(400, 'Missing params');

            // const likes = await StatsService.processLike(articleId, userId);
            console.log(articleId, userId);
            const likes = 100;
            res.json({ success: true, likes });
        } catch (e) { next(e); }
    }
}
