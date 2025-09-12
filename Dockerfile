FROM node:16.17.0-alpine as builder
LABEL name="harshith" version="1.0.0"
WORKDIR /app
COPY ./package.json ./yarn.lock ./
RUN yarn install && yarn add -D @types/react-slick@0.23.10 @types/react@18 @types/react-dom@18 && yarn add @mui/base@5.0.0-beta.40
COPY . .
ARG TMDB_V3_API_KEY
ENV VITE_APP_TMDB_V3_API_KEY=${TMDB_V3_API_KEY}
ENV VITE_APP_API_ENDPOINT_URL="https://api.themoviedb.org/3"
RUN yarn build

FROM nginx:stable-alpine
WORKDIR /usr/share/nginx/html
RUN rm -rf ./*
COPY --from=builder --chown=nginx:nginx /app/dist .
EXPOSE 80
ENTRYPOINT ["nginx", "-g", "daemon off;"]