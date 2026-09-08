import FeedParser from 'feedparser';
import axios from 'axios';
import { IncomingMessage } from 'http';
import { Readable } from 'stream';
import { gfm } from '@/tools/turndown-plugin-gfm.js';
import { JSDOM } from 'jsdom';
import { Readability } from '@mozilla/readability';
import TurndownService from 'turndown';
import { Article, BaseCrawler, FeedArticle } from '../base.js';

const feedUrl = 'https://techcrunch.com/feed/';

export class TechCrunchCrawler extends BaseCrawler {
    async fetchFeed(): Promise<FeedArticle[]> {
        const response = await axios.get<IncomingMessage>(feedUrl, { responseType: 'stream' });
        const feedparser = new FeedParser({});
        const articles: FeedArticle[] = [];

        return new Promise<FeedArticle[]>((resolve, reject) => {
            response.data.on('error', reject);
            feedparser.on('error', reject);

            feedparser.on('readable', function (this: FeedParser) {
                let item: FeedParser.Item | null;
                while ((item = this.read())) {
                    articles.push({
                        title: item.title || '',
                        link: item.link || '',
                        published: item.pubdate || new Date(),
                        summary: item.summary || ''
                    });
                }
            });

            feedparser.on('end', () => resolve(articles));

            (response.data as Readable).pipe(feedparser);
        });
    }
    async getArticleFromFeed(feed: FeedArticle): Promise<Article> {
        // 获取 HTML
        const response = await axios.get(feed.link)
        const html = response.data

        // DOM 化
        const dom = new JSDOM(html, { url: feed.link })

        // 获取作者
        let authorName = '';
        let authorAvatar = '';
        let authorHomepage = '';
        let authorBio = null;
        let headerImage = '';
        const script = dom.window.document.querySelector('.yoast-schema-graph');
        if (script) {
            try {
                const json = JSON.parse(script.textContent || '');
                const graph = json['@graph'];
                if (Array.isArray(graph)) {
                    // Find NewsArticle node
                    const newsArticle = graph.find((node: any) => node['@type'] === 'NewsArticle');
                    // Find Person node
                    let person: any = null;
                    if (newsArticle && newsArticle.author && Array.isArray(newsArticle.author)) {
                        const authorId = newsArticle.author[0]['@id'];
                        person = graph.find((node: any) => node['@id'] === authorId && node['@type'] === 'Person');
                    }
                    if (person) {
                        authorName = person.name || '未知作者';
                        authorAvatar = person.image?.url || '';
                        authorHomepage = person.url || '';
                        authorBio = person.description || null;
                    }
                    // Find ImageObject node
                    const imageObject = graph.find((node: any) => node['@type'] === 'ImageObject');
                    headerImage = imageObject['url'];
                }
            } catch (e) {
                // ignore JSON parse errors
            }
        }

        // 获取标签
        let tags: Array<string> = [];
        const tagsElement = dom.window.document.querySelector('.tc23-post-relevant-terms__terms');
        if (tagsElement) {
            tags = Array.from(tagsElement.querySelectorAll('a[rel="tag"]')).map(a => a.textContent?.trim() || '').filter(Boolean);
        }

        // 抽取正文
        let contentElement = dom.window.document.querySelector('.entry-content');
        let content = '';
        if (contentElement == null) {
            const reader = new Readability(document);
            const parsed = reader.parse()

            if (!parsed) {
                throw new Error('正文提取失败')
            }
            content = parsed.content!;
        }
        else {
            contentElement.querySelectorAll('div.wp-block-techcrunch-inline-cta').forEach(el => el.remove());
            content = contentElement.innerHTML;
        }

        // HTML → Markdown
        const turndownService = new TurndownService({
            headingStyle: 'atx',
            codeBlockStyle: 'fenced'
        })
        turndownService.use(gfm)

        const markdown = turndownService.turndown(content);

        const author = {
            name: authorName,
            avatar: authorAvatar,
            bio: authorBio,
            homepage: authorHomepage,
        };

        return {
            titleEn: feed.title,
            subtitleEn: feed.summary,
            contentEn: markdown,
            image: headerImage,
            tags: tags,
            link: feed.link,
            published: feed.published,
            author: author,
            publisher: 'TechCrunch',
        }
    }
}
