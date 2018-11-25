FROM bitriseio/android-ndk
RUN echo "deb http://archive.ubuntu.com/ubuntu/ bionic main restricted" > /etc/apt/sources.list.d/bionic.list
RUN apt-get update && apt-get install -qy cmake golang ninja-build swig && rm -rf /var/lib/apt/lists/*
RUN "${ANDROID_HOME}/tools/bin/sdkmanager" --list | awk '$1~/cmake/{print$1}' | xargs "${ANDROID_HOME}/tools/bin/sdkmanager"
