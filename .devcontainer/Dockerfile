# Use a base Ubuntu image
FROM ubuntu:22.04

# Install dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    unzip \
    wget \
    xz-utils \
    openjdk-17-jdk \
    && rm -rf /var/lib/apt/lists/*

# Create a non-root user
RUN useradd -ms /bin/bash jules
USER jules
WORKDIR /home/jules

# Download and install Android SDK
ENV ANDROID_SDK_ROOT=/home/jules/android-sdk
RUN mkdir -p ${ANDROID_SDK_ROOT}/cmdline-tools && \
    wget -q https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip -O tools.zip && \
    unzip -q tools.zip -d ${ANDROID_SDK_ROOT}/cmdline-tools && \
    rm tools.zip && \
    mv ${ANDROID_SDK_ROOT}/cmdline-tools/cmdline-tools ${ANDROID_SDK_ROOT}/cmdline-tools/latest

# Set up Android SDK environment variables
ENV PATH=${ANDROID_SDK_ROOT}/cmdline-tools/latest/bin:${ANDROID_SDK_ROOT}/platform-tools:${PATH}

# Accept Android licenses and install platform tools
RUN yes | sdkmanager --licenses && \
    sdkmanager "platform-tools" "platforms;android-33" "build-tools;33.0.2"

# Download and install Flutter SDK
ENV FLUTTER_HOME=/home/jules/flutter
RUN curl -o flutter.tar.xz https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.22.0-stable.tar.xz && \
    tar xf flutter.tar.xz && \
    rm flutter.tar.xz

# Set up Flutter environment variables
ENV PATH=${FLUTTER_HOME}/bin:${PATH}

# Run flutter doctor to confirm installation
RUN flutter doctor
