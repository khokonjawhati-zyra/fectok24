# Stage 1: Build the Flutter Web Application
FROM debian:latest AS build-env

# Install dependencies for Flutter
RUN apt-get update && apt-get install -y \
    curl \
    git \
    unzip \
    xz-utils \
    libglu1-mesa \
    python3 \
    && rm -rf /var/lib/apt/lists/*

# Install Flutter SDK
RUN git clone https://github.com/flutter/flutter.git /usr/local/flutter
ENV PATH="/usr/local/flutter/bin:/usr/local/flutter/bin/cache/dart-sdk/bin:${PATH}"

# Run flutter doctor to initialize
RUN flutter doctor -v
RUN flutter config --enable-web

# Set working directory
WORKDIR /app

# Copy pubspec.yaml and get dependencies
COPY pubspec.yaml .
RUN flutter pub get

# Copy the rest of the source code
COPY . .

# Build the web application
RUN flutter build web --release --base-href /admin/

# Stage 2: Serve the application using Nginx
FROM nginx:alpine

# Copy the build output to the Nginx HTML directory
COPY --from=build-env /app/build/web /usr/share/nginx/html

# Expose the internal port (Ghost-Locked)
EXPOSE 8108

# Update Nginx config to listen on 8108
RUN sed -i 's/listen \(.*\)80;/listen 8108;/' /etc/nginx/conf.d/default.conf

CMD ["nginx", "-g", "daemon off;"]
