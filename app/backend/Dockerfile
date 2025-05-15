# Stage 1: compile & bundle backend + frontend
FROM node:18-slim AS build

# Set working dir
WORKDIR /usr/src/app

# 1) Copy and install only server dependencies
COPY app/backend/package*.json ./
RUN npm install --production

# 2) Copy server source
COPY app/backend/server.js ./

# 3) Copy the styled frontend assets
COPY app/frontend ./frontend

# Stage 2: create a minimal runtime image
FROM node:18-slim

WORKDIR /usr/src/app

# 1) Copy in the server and deps from build stage
COPY --from=build /usr/src/app/server.js ./
COPY --from=build /usr/src/app/node_modules ./node_modules

# 2) Copy in the frontend folder
COPY --from=build /usr/src/app/frontend ./frontend

# Set the port your app listens on
ENV PORT=8080
EXPOSE 8080

# Start your Express server
CMD ["node", "server.js"]
