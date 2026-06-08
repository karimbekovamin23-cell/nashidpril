FROM node:20-alpine
RUN apk add --no-cache openssl
WORKDIR /app
COPY backend/ ./
RUN npm install
EXPOSE 3000
CMD ["sh", "-c", "npx prisma migrate deploy && node src/index.js"]
