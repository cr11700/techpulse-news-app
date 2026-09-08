import express from 'express';
import cors from 'cors';
import { config } from '@/config.js';
import statsRoutes from '@/routes/stats.routes.js';
import { errorHandler } from '@/middlewares/errorHandler.js';
import { warmup, startCronJobs } from '@/tasks/init.js';

const app = express();

app.use(express.json());

const corsOptions = {
    origin: (origin: string | undefined, callback: (err: Error | null, allow?: boolean) => void) => {
        if (!origin) return callback(null, true); // allow non-browser or same-origin requests
        try {
            const hostname = new URL(origin).hostname;
            if (hostname === 'localhost' || hostname.endsWith(config.domain)) {
                return callback(null, true);
            }
        } catch {}
        callback(new Error('Not allowed by CORS'));
    },
};

app.use(cors(corsOptions));

// 路由挂载
app.use('/api/stats', statsRoutes);

// 错误处理 (必须放在路由之后)
app.use(errorHandler);

async function bootstrap() {
    try {
        // 1. 预热缓存
        await warmup();

        // 2. 启动定时任务
        startCronJobs();

        // 3. 监听端口
        app.listen(config.port, () => {
            console.log(`
  🚀 Counter Service Ready
  📡 Port: ${config.port}
  🔗 Redis: Connected
  🔥 Persistence: Supabase Enabled
            `);
        });
    } catch (err) {
        console.error('❌ 服务启动失败:', err);
        process.exit(1);
    }
}

bootstrap();
