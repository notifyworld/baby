FROM node:18-alpine

# Install system dependencies
RUN apk add --no-cache curl bash docker-cli

# Install Bun
RUN curl -fsSL https://bun.sh/install | bash
ENV PATH="/root/.bun/bin:$PATH"

WORKDIR /app

# Copy package files
COPY package.json bun.lock* ./

# Install dependencies
RUN bun install --frozen-lockfile

# Copy source code
COPY . .

# Copy config file
COPY config.ts ./

# Create non-root user
RUN addgroup -g 1001 -S nodejs
RUN adduser -S soul -u 1001

# Change ownership
RUN chown -R soul:nodejs /app
USER soul

EXPOSE 4000

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:4000/health || exit 1

CMD ["bun", "src/index.ts"]