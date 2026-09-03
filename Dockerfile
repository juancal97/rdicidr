# --- Build stage -------------------------------------------------------------
# Debian-based node:15 (matches .nvmrc / package.json engines). The Alpine
# variant cannot install node-sass@5 (no musl prebuilt binary, no build deps).
FROM node:15 AS build

WORKDIR /app

# Install dependencies from the lockfile for reproducible builds.
COPY package.json package-lock.json ./
RUN npm ci

# Build the CRA bundle. REACT_APP_API_URL is baked in at build time.
ARG REACT_APP_API_URL
ENV REACT_APP_API_URL=$REACT_APP_API_URL

COPY . .
RUN npm run build

# --- Runtime stage ----------------------------------------------------------
FROM nginx:1.21-alpine

# Served as a site config under the stock nginx.conf http{} block.
COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY --from=build /app/build /usr/share/nginx/html

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
