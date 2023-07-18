FROM ubuntu:latest
ENV DEBIAN_FRONTEND noninteractive
# JDK 8 is used to build while we need JDK 11 for the new Android command-line tools
RUN apt-get update && \
	apt-get install -qy software-properties-common \
		curl unzip rsync file uuid-dev \
		cmake golang ninja-build swig autoconf \
		openjdk-8-jdk-headless openjdk-11-jdk-headless \
		&& \
	add-apt-repository -y universe && apt-get install -qy libncurses5
	rm -rf /var/lib/apt/lists/*

ENV ANDROID_HOME=/opt/android/sdk \
	TOOLS_VERSION=9477386 \
	ANDROID_NDK_HOME=/opt/android/ndk \
	ANDROID_NDK_VERSION=r16b \
	ANDROID_NDK_ROOT=/opt/android/ndk

RUN curl -f# https://dl.google.com/android/repository/commandlinetools-linux-${TOOLS_VERSION}_latest.zip -o /tmp/android_tools.zip && \
	mkdir -p ${ANDROID_HOME} && \
	cd ${ANDROID_HOME} && unzip -q /tmp/android_tools.zip && rm -f /tmp/android_tools.zip && \
	mv ${ANDROID_HOME}/cmdline-tools latest && mkdir -p ${ANDROID_HOME}/cmdline-tools && mv latest ${ANDROID_HOME}/cmdline-tools/
RUN curl -f# https://dl.google.com/android/repository/android-ndk-${ANDROID_NDK_VERSION}-linux-x86_64.zip -o /tmp/android_ndk.zip && \
	(mkdir -p /tmp/ndk-base && cd /tmp/ndk-base && unzip -q /tmp/android_ndk.zip && mv * ${ANDROID_NDK_HOME}) && \
	rm -rf /tmp/ndk-base /tmp/android_ndk.zip && echo "Installed Android NDK $(grep Revision ${ANDROID_NDK_HOME}/source.properties)"

ENV PATH ${PATH}:${ANDROID_HOME}/cmdline-tools:${ANDROID_HOME}/tools:${ANDROID_HOME}/tools/bin:${ANDROID_HOME}/platform-tools:${ANDROID_NDK_HOME}
RUN yes | ${ANDROID_HOME}/cmdline-tools/latest/bin/sdkmanager --licenses >/dev/null
RUN (${ANDROID_HOME}/cmdline-tools/latest/bin/sdkmanager --list | awk '$1~/cmake/{print$1}'; \
	echo \
		"platform-tools" \
		"platforms;android-28" \
		"platforms;android-29" \
		"platforms;android-31" \
		"platforms;android-33" \
		"build-tools;28.0.3" \
		"build-tools;29.0.2" \
		"build-tools;31.0.0" \
		"build-tools;33.0.0" \
) | xargs ${ANDROID_HOME}/cmdline-tools/latest/bin/sdkmanager
ENV GRADLE_USER_HOME=/tmp/gradle-cache GRADLE_OPTS=-Dorg.gradle.daemon=false
RUN mkdir -p $GRADLE_USER_HOME && chmod 777 $GRADLE_USER_HOME
VOLUME $GRADLE_USER_HOME
