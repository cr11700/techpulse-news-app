import { createHash } from "crypto";
import sharp from "sharp";
import axios from "axios";
import { SupabaseClient } from "@supabase/supabase-js";
import { config } from "@/config.js";

export class ImageUploader {
    private supabase: SupabaseClient;
    private supabaseUrl: string;
    private bucketName: string;
    private bucketPublicBase: string;

    constructor(supabase: SupabaseClient, bucketName: string) {
        this.supabase = supabase;
        this.supabaseUrl = config.supabaseUrl;
        this.bucketName = bucketName;
        this.bucketPublicBase = `${this.supabaseUrl}/storage/v1/object/public/${bucketName}/`;
    }

    private getMd5(content: Buffer): string {
        return createHash("md5").update(content).digest("hex");
    }

    private async resizeImage(imageBytes: Buffer, size = { width: 640, height: 480 }): Promise<Buffer> {
        return sharp(imageBytes)
            .resize(size.width, size.height, { fit: "inside" })
            .jpeg({ quality: 85 })
            .toBuffer();
    }

    private getExtension(contentType: string): string {
        switch (contentType) {
            case "image/jpeg":
                return ".jpg";
            case "image/png":
                return ".png";
            case "image/webp":
                return ".webp";
            case "image/gif":
                return ".gif";
            default:
                return "";
        }
    }

    private async uploadImage(
        basePath: string,
        data: Buffer,
        contentType: string = "image/jpeg"
    ): Promise<string> {
        const md5Hash = this.getMd5(data);
        const subdir = md5Hash.slice(0, 2);
        const fileName = `${md5Hash}${this.getExtension(contentType)}`;
        const path = `${basePath}/${subdir}/${fileName}`;
        await this.supabase.storage.from(this.bucketName).upload(path, data, {
            upsert: true,
            contentType: contentType
        });
        return this.bucketPublicBase + path;
    }

    private async downloadImage(
        url: string
    ): Promise<[string, Buffer] | null> {
        try {
            const resp = await axios.get(url, { responseType: "arraybuffer", maxRedirects: 5 });
            const contentType = resp.headers["content-type"];
            if (!contentType || this.getExtension(contentType) === "") {
                throw new Error(`Unknown content type: ${contentType}`);
            }
            return [contentType, Buffer.from(resp.data)];
        } catch (e) {
            console.error(`Failed to download image ${url}: ${e}`);
            return null;
        }
    }

    async storeImage(url: string, doResize: boolean): Promise<{ original: string, resized: string }> {
        const downloadResult = await this.downloadImage(url);
        if (!downloadResult) return {
            original: url,
            resized: url,
        };
        const [contentType, originalImg] = downloadResult;
        const urlOriginal = await this.uploadImage("article_images", originalImg, contentType);
        if (doResize) {
            const resizedImg = await this.resizeImage(originalImg);
            const urlResized = await this.uploadImage("article_images", resizedImg);
            return {
                original: urlOriginal,
                resized: urlResized,
            };
        }
        else {
            return {
                original: urlOriginal,
                resized: urlOriginal,
            };
        }
    }

    // 将爬取到的外部图片上传到对象存储，并更新原图URL
    async storeExternalImages() {
        const { data: response, error } = await this.supabase
            .from("article")
            .select("article_id, header_img, thumb_img")
            .not("header_img", "like", `${this.supabaseUrl}%`);

        if (response === null) return;
        for (const item of response) {
            const result = await this.storeImage(
                item.header_img,
                true
            );
            await this.supabase
                .from("article")
                .update({ header_img: result?.original, thumb_img: result?.resized })
                .eq("article_id", item.article_id);
            console.log(`已转存图片 ${item.article_id}`);
        }
    }

    async storeExternalAvatars() {
        const { data: response, error } = await this.supabase
            .from("author")
            .select("author_id, avatar")
            .not("avatar", "like", `${this.supabaseUrl}%`);

        if (response === null) return;
        for (const item of response) {
            const downloadResult = await this.downloadImage(item.avatar);
            if (!downloadResult) continue;
            const [contentType, imageData] = downloadResult;
            const imgUrl = await this.uploadImage("author_avatars", imageData, contentType);
            await this.supabase
                .from("author")
                .update({ avatar: imgUrl })
                .eq("author_id", item.author_id);
            console.log(`Changed ${item.author_id}`);
        }
    }
}
