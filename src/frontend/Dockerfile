FROM node:21-alpine AS dependencies
WORKDIR /app
COPY package.json package-lock.json ./
RUN npm ci --prefer-offline

FROM dependencies AS builder
WORKDIR /app
COPY . .
ENV NODE_ENV=production
RUN npm run build

FROM nginx:1.25-alpine AS runtime
RUN rm /etc/nginx/conf.d/default.conf
COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY --from=builder /app/dist /usr/share/nginx/html
RUN chown -R nginx:nginx /usr/share/nginx/html && \
    chown -R nginx:nginx /var/cache/nginx && \
    chown -R nginx:nginx /var/log/nginx && \
    chown -R nginx:nginx /etc/nginx/conf.d && \
    touch /var/run/nginx.pid && \
    chown nginx:nginx /var/run/nginx.pid
USER nginx
EXPOSE 8080
HEALTHCHECK --interval=30s --timeout=10s --start-period=10s --retries=3 \
  CMD wget -qO- http://localhost:8080/health || exit 1
CMD ["nginx", "-g", "daemon off;"]
