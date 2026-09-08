import { Router } from 'express';
import { StatsController } from '@/controllers/stats.controller.js';
import { jwtAuth } from '@/middlewares/auth.middleware.js';

const router = Router();

// 获取统计
router.get('/:id', StatsController.getStats);
// 增加浏览量
router.post('/view/:id', StatsController.trackView);
// 点赞
router.post('/like', jwtAuth(true), StatsController.handleLike);

export default router;
