FROM node:20-alpine
RUN apk add --no-cache openssl
WORKDIR /app
COPY backend/ ./
RUN npm install
EXPOSE 3000
CMD ["node", "src/index.js"]
