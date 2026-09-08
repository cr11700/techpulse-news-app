import { redis } from '@/lib/redis.js';
import { supabase } from '@/lib/supabase.js';

export class StatsService {
  static async getArticleStats(id: string) {
    const key = `stats:${id}`;
    const cached = await redis.hgetall(key);
    
    if (Object.keys(cached).length > 0) {
      return { likes: Number(cached.likes), views: Number(cached.views) };
    }

    // 缓存未命中，回源到 Supabase
    const { data } = await supabase.from('article_stats').select('*').eq('id', id).single();
    if (data) {
      await redis.hset(key, data); // 回填
    }
    return data;
  }

  static async incrementView(id: string) {
    await redis.hincrby(`stats:${id}`, 'views', 1);
    await redis.sadd('sync:pending_views', id); // 标记待同步
  }

  static async handleLike(id: string) {
    
  }
}
