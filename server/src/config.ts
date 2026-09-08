import dotenv from 'dotenv';
dotenv.config();

export const config = {
    development: process.env.NODE_ENV === 'development' ? true : false,
    domain: process.env.DOMAIN!,
    port: process.env.PORT || 3000,
    redisUrl: process.env.REDIS_URL || 'redis://localhost:6379',
    deepseekApiKey: process.env.DEEPSEEK_API_KEY!,
    supabaseUrl: process.env.SUPABASE_URL!,
    supabaseKey: process.env.SUPABASE_SERVICE_ROLE_KEY!, // 使用 Service Role 绕过 RLS
    statsSyncInterval: 1000 * 60 * 1, // 状态数同步间隔
    crawlerInterval: 1000 * 60 * 30, // 爬虫间隔
    jwtSecret: process.env.JWT_SECRET!,
    imageBucketName: process.env.IMAGE_BUCKET_NAME || 'public_images',
};

if (!config.supabaseUrl || !config.supabaseKey) {
    throw new Error('❌ 环境变量配置不足，请检查 .env 文件');
}
