import { SupabaseClient } from '@supabase/supabase-js';
import { generateAISummaryWithRetry, PredefinedTag } from './ai.js';
import { ImageUploader } from './image_uploader.js';

export type FeedArticle = {
    title: string;
    link: string;
    published: Date;
    summary: string;
};

export type Publisher =
    | 'TechCrunch';

export type Author = {
    name: string;
    avatar: string;
    bio: string | null;
    homepage: string;
};

export type Article = {
    titleEn: string;
    subtitleEn: string;
    contentEn: string;
    author: Author;
    tags: Array<string>;
    publisher: Publisher;
    image: string;
    link: string;
    published: Date;
};

export abstract class BaseCrawler {
    abstract fetchFeed(): Promise<FeedArticle[]>;
    abstract getArticleFromFeed(feed: FeedArticle): Promise<Article>;

    // 获取全部没有在数据库中出现过的文章
    // 去重的方法是：检查标题和发布时间是否在数据库中出现过
    async fetchAll(db: SupabaseClient): Promise<Array<Article>> {
        const feeds = await this.fetchFeed();
        const articles: Array<Article> = [];
        for (const feed of feeds) {
            let { data, error } = await db
                .from('article')
                .select('*')
                .eq('title_en', feed.title);
            if (data !== null && data.length > 0) {
                continue;
            }
            await new Promise(resolve => setTimeout(resolve, 1000));
            const article = await this.getArticleFromFeed(feed);
            articles.push(article);
        }
        console.log(`已下载：${articles.length} 篇新闻`);
        return articles;
    }

    async getAuthorId(db: SupabaseClient, imageUploader: ImageUploader, author: Author): Promise<number> {
        let { data, error } = await db
            .from('author')
            .select('author_id')
            .eq('name', author.name);
        if (data != null && data.length > 0) {
            return data[0]!.author_id;
        }
        else {
            // 首先转存头像
            const avatarUploadResult = await imageUploader.storeImage(author.avatar, false);
            // 插入新作者到作者表，并返回作者id
            let { data, error } = await db
                .from('author')
                .insert({
                    name: author.name,
                    avatar: avatarUploadResult.original,
                    description: author.bio,
                })
                .select('author_id');
            if (data != null && data.length > 0) {
                return data[0]!.author_id;
            }
            return 0;   // 0代表未知作者
        }
    }

    async getPublisherId(publisher: Publisher): Promise<number> {
        switch (publisher) {
            case 'TechCrunch':
                return 1;
        }
    }

    async fetchAndWriteToDB(
        db: SupabaseClient,
        imageUploader: ImageUploader,
        predefinedTags: PredefinedTag[],
    ) {
        const articles = await this.fetchAll(db);
        for (const article of articles) {
            const author_id = await this.getAuthorId(db, imageUploader, article.author);
            const publisher_id = await this.getPublisherId(article.publisher);
            const aiResult = await generateAISummaryWithRetry(article, predefinedTags);
            const headerImageUploadResult = await imageUploader.storeImage(article.image, true);
            const { data, error } = await db
                .from('article')
                .insert({
                    title_en: article.titleEn,
                    subtitle_en: article.subtitleEn,
                    content_en: article.contentEn,
                    title_cn: aiResult.titleCn,
                    subtitle_cn: aiResult.subtitleCn,
                    content_cn: aiResult.contentCn,
                    summary_cn: aiResult.summaryCn,
                    url: article.link,
                    pubtime: article.published,
                    author_id: author_id,
                    publisher_id: publisher_id,
                    header_img: headerImageUploadResult.original,
                    thumb_img: headerImageUploadResult.resized,
                    tags_plain: article.tags
                })
                .select('article_id');
            if (error) {
                console.error(error);
            }
            if (data !== null) {
                for (const predefinedTag of aiResult.predefinedTags) {
                    const { error } = await db
                        .from('article_tag')
                        .insert({
                            article_id: data[0]?.article_id,
                            tag_id: predefinedTag.id,
                        });
                    if (error) {
                        console.error(error);
                    }
                }
            }
        }
    }
}

export * as techcrunchParser from './techcrunch/parser.js';
