FROM node:18-alpine

# Install curl for the HEALTHCHECK
RUN apk add --no-cache curl

WORKDIR /usr/src/app

# Install app dependencies
COPY package*.json ./
RUN npm install

# Bundle app source
COPY . .

EXPOSE 3000

HEALTHCHECK --interval=30s --timeout=10s --start-period=20s --retries=3 \
  CMD curl -f http://localhost:3000/health || exit 1

CMD ["node", "app.js"]
