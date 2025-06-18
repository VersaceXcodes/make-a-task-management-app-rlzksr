# Use Node.js LTS
FROM node:20-slim AS builder

# Set working directory
WORKDIR /app

# Copy package files
COPY package*.json ./
COPY vitereact/package*.json ./vitereact/
COPY backend/package*.json ./backend/

# Install dependencies
RUN npm install
RUN cd vitereact && npm install
RUN cd backend && npm install

# Copy source code
COPY . .

# Build frontend
RUN cd vitereact && npm run build

# Production stage
FROM node:20-slim

WORKDIR /app

# Copy built frontend and backend
COPY --from=builder /app/vitereact/dist /app/backend/public
COPY --from=builder /app/backend ./backend

# Install production dependencies for backend
WORKDIR /app/backend
RUN npm install --production

# Set environment variables
ENV NODE_ENV=production
ENV PORT=8080

# Expose port
EXPOSE 8080

# Start the application
CMD ["node", "server.js"]