FROM ghcr.io/cirruslabs/flutter:stable AS build
WORKDIR /app
COPY CivicAI/ .
RUN flutter pub get
RUN flutter build web --release

FROM nginx:alpine
COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY --from=build /app/build/web /usr/share/nginx/html
EXPOSE 8080
CMD ["sh", "-c", "sed -i \"s/__PORT__/${PORT:-8080}/\" /etc/nginx/conf.d/default.conf && exec nginx -g 'daemon off;'"]
