# Use official Node.js 22 Alpine image
FROM node:22-alpine

# Create application directory
WORKDIR /app

# Copy package files first
COPY package*.json ./

# Install production dependencies
RUN npm ci --omit=dev

# Copy application source
COPY . .

# Generate Prisma Client
RUN npx prisma generate

# Expose application port
EXPOSE 5000

# Start the application
CMD ["npm", "start"]