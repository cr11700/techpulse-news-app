import { config } from '@/config.js';
import { supabase } from '../lib/supabase.js';
import { TechCrunchCrawler } from './crawler/techcrunch/parser.js';
import { PredefinedTag } from './crawler/ai.js';
import { ImageUploader } from './crawler/image_uploader.js';

async function doCrawl() {
    const imageUploader = new ImageUploader(
        supabase, config.imageBucketName
    );
    let { data: tags, error } = await supabase
        .from('tag')
        .select('tag_id, value_cn, value_en');
    if (tags != null) {
        const predefinedTags: PredefinedTag[] = tags.map((tag, index, array) => {
            return {
                id: tag.tag_id,
                value_cn: tag.value_cn,
                value_en: tag.value_en,
            }
        });
        const techcrunchCrawler = new TechCrunchCrawler();
        await techcrunchCrawler.fetchAndWriteToDB(supabase, imageUploader, predefinedTags);
    }
}

export const startCrawlerTask = () => {
    doCrawl();
    setInterval(async () => {
        doCrawl();
    }, config.crawlerInterval); // 半小时1次
};
