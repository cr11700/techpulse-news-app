# TechPulse TypeScript后端
## 项目文件结构（计划）
```
counter-service/
├── src/
│   ├── config/             # 配置管理 (dotenv, 环境变量校验)
│   ├── constants/          # 常量定义 (Redis Key 前缀, 错误码)
│   ├── controllers/        # Express 路由处理器 (解析输入, 调用 Service)
│   ├── lib/                # 外部服务客户端初始化 (Redis, Supabase)
│   ├── middlewares/        # 权限校验、日志、错误处理中间件
│   ├── routes/             # 路由定义 (将 URL 映射到 Controller)
│   ├── services/           # 核心业务逻辑层 (协调 Redis 和 DB)
│   ├── tasks/              # 定时任务 (数据同步, 预热脚本)
│   ├── types/              # TypeScript 接口和类型声明
│   ├── utils/              # 通用工具函数
│   └── index.ts            # 程序入口 (启动服务器, 初始化缓存)
├── .env                    # 环境变量
├── .gitignore
├── package.json
└── tsconfig.json
```
## 文章状态数的存储与维护
创建文章状态数表，专用于存储频繁变化的数据：
```sql
CREATE TABLE public.article_stats (
  article_id integer GENERATED ALWAYS AS IDENTITY NOT NULL,
  views bigint NOT NULL DEFAULT '0'::bigint,
  likes bigint NOT NULL DEFAULT '0'::bigint,
  CONSTRAINT article_stats_pkey PRIMARY KEY (article_id),
  CONSTRAINT article_stats_article_id_fkey FOREIGN KEY (article_id) REFERENCES public.article(article_id)
);
```

当插入新文章时，需要同时为这篇文章插入一个状态数记录，采用触发器实现：
```sql
-- 1. 创建触发器函数
CREATE OR REPLACE FUNCTION public.fn_sync_article_stats()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO public.article_stats (article_id, likes, views)
    VALUES (NEW.article_id, 0, 0)
    ON CONFLICT (article_id) DO NOTHING; -- 防止主键冲突
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 2. 绑定触发器到 article 表
-- 使用 AFTER INSERT 保证文章先创建成功
CREATE TRIGGER tr_after_article_insert
AFTER INSERT ON public.article
FOR EACH ROW
EXECUTE FUNCTION public.fn_sync_article_stats();
```

如果数据库中已有文章，使用下列语句添加空记录：
```sql
INSERT INTO public.article_stats (article_id, likes, views)
    SELECT a.article_id, 0, 0
    FROM public.article a
    LEFT JOIN public.article_stats s ON a.article_id = s.article_id
    WHERE s.article_id IS NULL;
```

为了实现点赞状态数的自动更新，此处采用触发器保证数据一致性。
```sql
-- 1. 创建触发器函数
CREATE OR REPLACE FUNCTION update_article_likes_count()
RETURNS TRIGGER AS $$
BEGIN
    IF (TG_OP = 'INSERT') THEN
        UPDATE article_stats 
        SET likes = likes + 1 
        WHERE article_id = NEW.article_id;
    ELSIF (TG_OP = 'DELETE') THEN
        UPDATE article_stats 
        SET likes = likes - 1 
        WHERE article_id = OLD.article_id;
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

-- 2. 绑定触发器到 like_article 表
CREATE TRIGGER tr_update_article_likes
AFTER INSERT OR DELETE ON like_article
FOR EACH ROW
EXECUTE FUNCTION update_article_likes_count();
```
