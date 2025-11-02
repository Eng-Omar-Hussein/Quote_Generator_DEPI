# Stage 1: Build the React application
FROM node:18-alpine AS builder

WORKDIR /frontend

COPY package*.json ./
RUN npm install --production=false

COPY . .

# Allow overriding the API base URL at build time
ARG API_BASE_URL=http://localhost:3000
ENV VITE_API_BASE_URL=${API_BASE_URL}

RUN npm run build

# Stage 2: Serve with Nginx
FROM nginx:1.27-alpine

COPY --from=builder /frontend/dist /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80


CMD ["nginx", "-g", "daemon off;"]
