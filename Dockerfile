FROM node:16.17.0-alpine as builder
LABEL name="harshith" version="1.0.0"
WORKDIR /app
COPY ./package.json .
COPY ./yarn.lock .
RUN yarn install && yarn add -D @types/react@18 @types/react-dom@18 && yarn add @mui/material @emotion/react @emotion/styled
RUN yarn add react-slick slick-carousel && yarn add -D @types/react-slick
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