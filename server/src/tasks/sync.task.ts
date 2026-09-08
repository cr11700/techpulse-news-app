// src/tasks/sync.task.ts
import { config } from '@/config.js';
import { redis } from '../lib/redis.js';
import { supabase } from '../lib/supabase.js';

export const startSyncTask = () => {
    setInterval(async () => {
        const ids = await redis.smembers('sync:pending_views');
        if (ids.length === 0) return;

        console.log(`⏰ 同步中: ${ids.length} 篇文章...`);
        for (const article_id of ids) {
            const views = await redis.hget(`stats:${article_id}`, 'views');
            await supabase.from('article_stats').update({ views: Number(views) }).eq('article_id', article_id);
            await redis.srem('sync:pending_views', article_id);
        }
    }, config.statsSyncInterval);
};
