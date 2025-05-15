FROM node:18-slim
WORKDIR /usr/src/app

# 1) Install backend deps
COPY app/backend/package*.json ./
RUN npm install

# 2) Copy backend code
COPY app/backend/. .

# 3) Copy frontend static files
COPY app/frontend ./frontend

# 4) Start the server
CMD ["node", "server.js"]
