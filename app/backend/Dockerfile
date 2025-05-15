# Stage 1: build & bundle
FROM node:18-slim AS build

WORKDIR /usr/src/app

# 1) install server deps
COPY app/backend/package*.json ./
RUN npm install --production

# 2) copy server code
COPY app/backend/server.js ./

# 3) copy the frontend static assets
COPY app/frontend ./frontend

# Final image
FROM node:18-slim

WORKDIR /usr/src/app

# copy only what's needed
COPY --from=build /usr/src/app/server.js ./
COPY --from=build /usr/src/app/node_modules ./node_modules
COPY --from=build /usr/src/app/frontend ./frontend

# expose the port
ENV PORT=8080
EXPOSE 8080

CMD ["node", "server.js"]
