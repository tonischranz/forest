FROM node:24-alpine AS build

COPY . /app
WORKDIR /app
RUN yarn  build

FROM nginx:alpine

COPY --from=build /app/dist/ /usr/share/nginx/html/
