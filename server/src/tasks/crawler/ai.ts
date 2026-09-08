import { config } from "@/config.js";
import { Article } from "./base.js";
import OpenAI from "openai";

export type PredefinedTag = {
    id: number;
    value_cn: string;
    value_en: string;
};

export type AiSummaryResult = {
    titleCn: string;
    subtitleCn: string;
    contentCn: string;
    summaryCn: string;
    predefinedTags: PredefinedTag[];
};

const openai = new OpenAI({
    baseURL: 'https://api.deepseek.com',
    apiKey: config.deepseekApiKey,
});

// Parse the AI response content (not JSON, but custom tag format)
function parseAIContent(content: string, predefinedTags: PredefinedTag[]): AiSummaryResult {
    try {
        const titleMatch = content.match(/<title>([\s\S]*?)<\/title>/);
        const subtitleMatch = content.match(/<subtitle>([\s\S]*?)<\/subtitle>/);
        const contentMatch = content.match(/<content>([\s\S]*?)<\/content>/);
        const summaryMatch = content.match(/<summary>([\s\S]*?)<\/summary>/);
        const tagMatches = [...content.matchAll(/<tag>([\s\S]*?)<\/tag>/g)];

        if (!titleMatch || !subtitleMatch || !contentMatch || !summaryMatch || tagMatches.length === 0) {
            throw new Error("AI response format error: missing required fields");
        }

        return {
            titleCn: titleMatch[1]!.trim(),
            subtitleCn: subtitleMatch[1]!.trim(),
            contentCn: contentMatch[1]!.trim(),
            summaryCn: summaryMatch[1]!.trim(),
            predefinedTags: tagMatches.map((m) => {
                const valueCn = m[1]!.trim();
                const matchedTag = predefinedTags.find(tag => tag.value_cn === valueCn);
                if (!matchedTag) {
                    throw new Error(`Tag "${valueCn}" not found in predefinedTags`);
                }
                return {
                    id: matchedTag.id,
                    value_cn: matchedTag.value_cn,
                    value_en: matchedTag.value_en,
                };
            }),
        };
    } catch (e) {
        throw new Error("Failed to parse AI response: " + e + "\nContent: " + content);
    }
}

async function generateAISummary(article: Article, predefinedTags: PredefinedTag[], temperature: number = 1.3): Promise<AiSummaryResult> {
    let predefinedTagsStr = ''
    for (const predefinedTag of predefinedTags) {
        predefinedTagsStr += `<tag>${predefinedTag.value_cn}</tag>`;
    }
    const systemPrompt = `你是一个AI翻译+总结工具。请对用户给出的文章进行翻译。`;
    const contentFiltered = `
你是一个AI翻译+总结工具。请按要求把下面的英文文章翻译成中文。
我将给出下列格式的文章：
<title>English Title</title>
<subtitle>English subtitle</subtitle>
<content>
Content of the article. Markdown.
</content>
首先你需要对文章标题、副标题、正文进行翻译，内容贴合原文，不能做概括。然后总结整篇文章，生成100-200字的总结，最后根据总结内容从下列预定义标签中选择1-3个最符合文章的标签。
${predefinedTagsStr}

完成后，请按照下列格式输出。只输出下列内容，不要做解释与分析：

<title>文章标题</title>
<subtitle>文章副标题</subtitle>
<content>
文章正文，翻译时需要保证Markdown格式的正确性，并且与原文中的Markdown换行一一对应。
</content>
<summary>文章内容的中文总结</summary>
<tag>预定义标签</tag>
<tag>另一个预定义标签</tag>
文章内容从这里开始：
<title>${article.titleEn}</title>
<subtitle>${article.subtitleEn}</subtitle>
<content>
${article.contentEn}
</content>
`;
    const completion = await openai.chat.completions.create({
        messages: [
            { role: "system", content: systemPrompt },
            { role: "user", content: contentFiltered }
        ],
        model: "deepseek-chat",
        temperature: temperature,
    });

    const content = completion.choices[0]?.message.content ?? null;
    if (!content) {
        throw new Error("AI response is empty");
    }

    let result: AiSummaryResult = parseAIContent(content, predefinedTags);

    return result;
}

export async function generateAISummaryWithRetry(article: Article, predefinedTags: PredefinedTag[]): Promise<AiSummaryResult> {
    let result: AiSummaryResult = {
        titleCn: '',
        subtitleCn: '',
        contentCn: '',
        summaryCn: '',
        predefinedTags: [],
    };
    let temperature = 1.3;
    for (let i = 0; i < 3; i++) {
        try {
            console.log(`第 ${i + 1} 次尝试翻译: ${article.titleEn}`);
            result = await generateAISummary(article, predefinedTags, temperature);
            console.log(`翻译成功！`);
            return result;
        }
        catch {
            temperature -= 0.3;
        }
    }
    return result;
}
