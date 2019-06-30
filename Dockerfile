FROM ubuntu:18.04
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update && \
	apt-get install -qy \
		curl unzip rsync \
		cmake golang ninja-build swig \
		openjdk-8-jdk-headless \
		&& \
	rm -rf /var/lib/apt/lists/*
	
ENV ANDROID_HOME=/opt/android/sdk \
	ANDROID_SDK_VERSION=4333796 \
	ANDROID_NDK_HOME=/opt/android/ndk \
	ANDROID_NDK_VERSION=r18 \
	ANDROID_NDK_ROOT=/opt/android/ndk

RUN curl -s https://dl.google.com/android/repository/sdk-tools-linux-${ANDROID_SDK_VERSION}.zip -o /tmp/android_tools.zip && \
	mkdir -p ${ANDROID_HOME} && \
	cd ${ANDROID_HOME} && unzip -q /tmp/android_tools.zip && rm -f /tmp/android_tools.zip
RUN curl -s https://dl.google.com/android/repository/android-ndk-${ANDROID_NDK_VERSION}-linux-x86_64.zip -o /tmp/android_ndk.zip && \
	(mkdir -p /tmp/ndk-base && cd /tmp/ndk-base && unzip -q /tmp/android_ndk.zip && mv * ${ANDROID_NDK_HOME}) && \
	rm -rf /tmp/ndk-base /tmp/android_ndk.zip
    
ENV PATH ${PATH}:${ANDROID_HOME}/tools:${ANDROID_HOME}/tools/bin:${ANDROID_HOME}/platform-tools:${ANDROID_NDK_HOME}
RUN yes | ${ANDROID_HOME}/tools/bin/sdkmanager --licenses
RUN (${ANDROID_HOME}/tools/bin/sdkmanager --list | awk '$1~/cmake/{print$1}'; \
	echo \
		"platform-tools" \
		"platforms;android-28" \
		"platforms;android-29" \
		"build-tools;28.0.3" \
		"build-tools;29.0.0" \
	) | xargs ${ANDROID_HOME}/tools/bin/sdkmanager
ENV GRADLE_USER_HOME=/tmp/gradle-cache GRADLE_OPTS=-Dorg.gradle.daemon=false
RUN mkdir -p $GRADLE_USER_HOME && chmod 777 $GRADLE_USER_HOME
VOLUME $GRADLE_USER_HOME
