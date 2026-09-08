# TechPulse

TechPulse is a course project for browsing English technology news. It consists of a Flutter client and a TypeScript backend that crawls TechCrunch RSS content, extracts article details, writes normalized records to Supabase, and uses an LLM service to generate Chinese translations, summaries, and predefined tags.

## Architecture

- `mobile/`: Flutter client for article browsing, authentication, comments, likes, subscriptions, and cached reading.
- `server/`: Node.js and Express backend for scheduled crawling, article persistence, image uploading, AI translation and summarization, and article statistics.

## Crawler and persistence flow

1. The backend reads the TechCrunch RSS feed and skips articles already stored by English title.
2. The crawler retrieves article pages, extracts the author, cover image, tags, and body, and converts article HTML to Markdown.
3. It uploads images, resolves author and publisher records, then writes the article and article-tag relationships to Supabase.
4. The AI service translates the article, produces a Chinese summary, and selects predefined tags before persistence.

## Run locally

The project depends on Supabase, Redis, and an LLM API. Do not commit real credentials.

```text
mobile/
  cp .env.example .env
  flutter pub get
  flutter run

server/
  cp .env.example .env
  npm ci
  npm run dev
```

The backend starts the crawler and scheduled tasks at startup. Configure the external services before running it.

## Team contribution note

This repository is an archival copy of a collaborative software engineering course project. The repository documents the system as a team deliverable. Individual contributions should be described precisely: the uploader contributed to the crawler module and its database integration, including article extraction and persistence flow; other modules were completed collaboratively by the team.

## Security

Configuration files are deliberately excluded. Use the provided `.env.example` files and replace every placeholder with your own development credentials. Never commit Supabase service-role keys, LLM API keys, Redis URLs containing passwords, or JWT secrets.
