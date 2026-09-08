import { config } from '@/config.js';
import { redis } from '@/lib/redis.js';
import { supabase } from '@/lib/supabase.js';

export async function warmup() {
    const IS_READY = 'cache:initialized';
    if (!(await redis.get(IS_READY))) {
        console.log('🔄 开始从 Supabase 恢复缓存...');
        const { data, error } = await supabase.from('article_stats').select('article_id, likes, views');
        if (data) {
            const pipe = redis.pipeline();
            data.forEach(s => pipe.hset(`stats:${s.article_id}`, { likes: s.likes, views: s.views }));
            pipe.set(IS_READY, 'true');
            await pipe.exec();
            console.log(`✅ 缓存恢复完成，共 ${data?.length} 项`);
        }
        else {
            console.log(error);
        }
    }
}

import { startSyncTask } from './sync.task.js';
import { startCrawlerTask } from './crawler.task.js';

export function startCronJobs() {
    startSyncTask();
    startCrawlerTask();
}
