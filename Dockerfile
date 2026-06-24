# ==========================================
# Stage 1: Build the Flutter Web Application
# ==========================================
FROM ubuntu:24.04 AS flutter-builder

# Install system dependencies required by Flutter
RUN apt-get update && apt-get install -y \
    curl \
    git \
    unzip \
    xz-utils \
    && rm -rf /var/lib/apt/lists/*

# Clone the stable Flutter SDK
RUN git clone https://github.com/flutter/flutter.git -b stable /opt/flutter
ENV PATH="/opt/flutter/bin:${PATH}"

# Ensure Flutter is ready and web is enabled
RUN flutter config --enable-web
RUN flutter doctor

# Set up working directory for the Flutter build
WORKDIR /build

# Copy your Flutter project directory into the container
# (Assumes 'kalaallisutdictionary' is in the same folder as this Dockerfile)
COPY kalaallisutdictionary/ ./kalaallisutdictionary/

# Change to the Flutter project directory and build for web
WORKDIR /build/kalaallisutdictionary
RUN flutter build web --release

# ==========================================
# Stage 2: Final Python Runtime Environment
# ==========================================
FROM python:3.11-slim

# Changed from "." to "/app" to keep the filesystem clean and predictable
WORKDIR /app

# Install Python dependencies
RUN pip install --no-cache-dir fastapi uvicorn hfst

# Copy your Python application code
COPY . .

# Copy the compiled Flutter web assets from Stage 1 into a 'static' folder
COPY --from=flutter-builder /build/kalaallisutdictionary/build/web ./static

# Run your API
CMD ["python", "analyzer/api.py"]