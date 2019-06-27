FROM bitriseio/android-ndk

FROM ubuntu:18.04
RUN apt-get update && apt-get install -qy cmake golang ninja-build swig && rm -rf /var/lib/apt/lists/*
ENV ANDROID_HOME=/opt/android-sdk-linux \
	ANDROID_NDK_HOME=/opt/android-ndk \
	ANDROID_NDK_VERSION=r19
COPY --from=0 /opt /opt
RUN "${ANDROID_HOME}/tools/bin/sdkmanager" --list | awk '$1~/cmake/{print$1}' | xargs "${ANDROID_HOME}/tools/bin/sdkmanager"
