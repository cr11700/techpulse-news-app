import { redis } from '@/lib/redis.js';
import { supabase } from '@/lib/supabase.js';

const CACHE_INIT_KEY = 'cache:initialized';

/**
 * 启动预热：若 Redis 重启（标志位消失），从 DB 加载所有 likes 和 views
 */
async function warmupCache() {
    const isReady = await redis.get(CACHE_INIT_KEY);
    if (!isReady) {
        console.log('🔄 Redis 标志位缺失，正在从数据库热机...');
        const { data, error } = await supabase.from('article_stats').select('id, likes, views');
        if (error) return console.error('热机失败:', error);

        const pipeline = redis.pipeline();
        data.forEach(item => {
            pipeline.hset(`stats:${item.id}`, { likes: item.likes, views: item.views });
        });
        pipeline.set(CACHE_INIT_KEY, 'true');
        await pipeline.exec();
        console.log(`✅ 成功同步 ${data.length} 条数据到 Redis`);
    }
}

/**
 * 获取文章数据：优先 Redis，未命中查 DB 并回填
 */
async function getStats(articleId: string) {
    const key = `stats:${articleId}`;
    let data = await redis.hgetall(key);

    if (Object.keys(data).length === 0) {
        const { data: dbData } = await supabase.from('article_stats')
            .select('likes, views').eq('id', articleId).single();
        if (dbData) {
            await redis.hset(key, dbData);
            return dbData;
        }
        return { likes: 0, views: 0 };
    }
    return { likes: parseInt(data.likes!), views: parseInt(data.views!) };
}


export default {
    warmupCache,
    getStats,
};
