FROM node:22-bookworm-slim AS builder

WORKDIR /app

COPY src ./src

RUN node -e "require('node:fs').cpSync('src', 'dist', { recursive: true })"

FROM node:22-bookworm-slim

WORKDIR /app

ENV NODE_ENV=production \
    SQLITE_DB_LOCATION=/data/todo.db

COPY package*.json ./
RUN npm ci --omit=dev && npm cache clean --force

COPY --from=builder /app/dist ./dist

RUN mkdir -p /data && chown node:node /data

USER node

VOLUME ["/data"]
EXPOSE 3000

CMD ["node", "dist/index.js"]
