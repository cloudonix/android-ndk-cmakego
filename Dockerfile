FROM bitriseio/docker-android
ENV DEBIAN_FRONTEND noninteractive
ENV ANDROID_NDK_HOME /opt/android-ndk
ENV ANDROID_NDK_VERSION r18
ENV CMAKE_VERSION 3.6
ENV CMAKE_PATCH_VERSION 0
# ------------------------------------------------------
# --- Install required tools

RUN apt-get update &&  apt-get -yq install ninja-build swig

# ------------------------------------------------------
# --- Android NDK

# download
RUN mkdir /opt/android-ndk-tmp
RUN cd /opt/android-ndk-tmp && wget -q http://dl.google.com/android/repository/android-ndk-${ANDROID_NDK_VERSION}-linux-x86_64.zip
# uncompress
RUN cd /opt/android-ndk-tmp && unzip -q android-ndk-${ANDROID_NDK_VERSION}-linux-x86_64.zip
# move to it's final location
RUN cd /opt/android-ndk-tmp && mv ./android-ndk-${ANDROID_NDK_VERSION} /opt/android-ndk
# remove temp dir
RUN rm -rf /opt/android-ndk-tmp
# add to PATH
ENV PATH ${PATH}:${ANDROID_NDK_HOME}
# ------------------------------------------------------
# --- Cleanup and rev num

# Cleaning
RUN apt-get clean

RUN wget -qO- "https://cmake.org/files/v${CMAKE_VERSION}/cmake-${CMAKE_VERSION}.${CMAKE_PATCH_VERSION}-Linux-x86_64.tar.gz" | tar --strip-components=1 -xz -C /usr/local

ARG user=jenkins
ARG group=jenkins
ARG uid=3000
ARG gid=3000
RUN groupadd -g ${gid} ${group} && useradd -u ${uid} -g ${gid} -m -s /bin/bash ${user}
RUN chown -R 3000:3000 /opt/android-sdk-linux
RUN touch /root/.android/repositories.cfg
RUN CMAKE_AND_VER=$(/opt/android-sdk-linux/tools/bin/sdkmanager --list  | grep cmake | tail -1 | awk '{print $1; exit}') ;  (echo y | /opt/android-sdk-linux/tools/bin/sdkmanager $CMAKE_AND_VER)
RUN echo y | /opt/android-sdk-linux/tools/bin/sdkmanager --licenses
~                                                                    
