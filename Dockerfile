FROM ubuntu:xenial

RUN apt-get update && apt-get install -y \
chrpath diffstat gawk texinfo doxygen graphviz \
python python3 wget unzip build-essential cpio \
git-core libssl-dev default-jdk ninja-build \
sudo locales

RUN apt-get install -y vim
RUN cat ~/.bashrc
RUN echo "alias ls='ls -la'" >> ~/.bashrc
RUN cat ~/.bashrc

# Locale settings
RUN sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen && \
echo 'LANG="en_US.UTF-8"'>/etc/default/locale && \
dpkg-reconfigure --frontend=noninteractive locales && \
update-locale LANG=en_US.UTF-8

ENV LC_ALL en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US.UTF-8

RUN useradd --uid 1000 --create-home builder
RUN echo "builder ALL=(ALL) NOPASSWD: ALL" | tee -a /etc/sudoers

USER builder
WORKDIR /home/builder

# Prepare OE-Core
RUN cd /home/builder \
&& git clone git://git.openembedded.org/openembedded-core -b rocko oe-core \
&& cd oe-core \
&& git checkout 1b18cdf6b8bdb00ff5df165b9ac7bc2b10c87d57 \
&& git clone git://git.openembedded.org/bitbake -b 1.36

ENV OE_CORE_PATH /home/builder/oe-core

# Additional packages
RUN sudo apt-get update && sudo apt-get install -y quilt \
libsqlite3-dev libarchive-dev python3-dev \
libdb-dev libpopt-dev

# Audio dependencies
RUN sudo apt-get update && sudo apt-get install -y \
libgstreamer1.0-dev libgstreamer-plugins-base1.0-dev

# Coverage support
RUN sudo apt-get update && sudo apt-get install -y lcov

# Install Gradle
ENV JAVA_HOME=/usr/lib/jvm/default-java GRADLE_HOME=/usr/lib/gradle GRADLE_VERSION=6.7 ANDROID_HOME=/home/builder/android/sdk ANDROID_NDK_HOME=/workdir/android/ndk/ndk-bundle/android-ndk-r20

RUN echo "Downloading Gradle" \
&& wget --no-verbose --output-document=gradle.zip "https://services.gradle.org/distributions/gradle-${GRADLE_VERSION}-bin.zip" \
&& echo "Installing Gradle" \
&& unzip gradle.zip \
&& rm gradle.zip \
&& sudo mv "gradle-${GRADLE_VERSION}" "${GRADLE_HOME}/" \
&& sudo ln --symbolic "${GRADLE_HOME}/bin/gradle" /usr/bin/gradle

# Android SDK
# https://developer.android.com/studio/index.html#command-tools
# 7302050
ARG ANDROID_SDK_TOOLS=7583922

RUN wget -q -O android-sdk.zip https://dl.google.com/android/repository/commandlinetools-linux-${ANDROID_SDK_TOOLS}_latest.zip

RUN mkdir -p ${ANDROID_HOME} \
 && unzip -qo android-sdk.zip -d ${ANDROID_HOME} \
 && chmod -R +x ${ANDROID_HOME} \
 && rm android-sdk.zip \
 && mv ${ANDROID_HOME}/cmdline-tools ${ANDROID_HOME}/latest \
 && mkdir ${ANDROID_HOME}/cmdline-tools \
 && mv ${ANDROID_HOME}/latest ${ANDROID_HOME}/cmdline-tools/latest

ENV PATH=${PATH}:${ANDROID_HOME}/cmdline-tools/latest
ENV PATH=${PATH}:${ANDROID_HOME}/cmdline-tools/latest/bin
ENV PATH=${PATH}:${ANDROID_NDK}
ARG ANDROID_TARGET_SDK=31
ARG ANDROID_BUILD_TOOLS=31.0.0

# accept license
RUN yes | sdkmanager --licenses \
 && sdkmanager --update

RUN sdkmanager "platforms;android-${ANDROID_TARGET_SDK}" "build-tools;${ANDROID_BUILD_TOOLS}" platform-tools tools

RUn sudo chown builder:builder .

# git helper to see where we are
#RUN wget https://github.com/git/git/blob/master/contrib/completion/git-completion.bash
#RUN chmod +x ~/git-completion.bash && ~/git-completion.bash

ENV PS1="\u@\h \W\[\033[32m\]\$(git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ (\1)/')\[\033[00m\] $ "

CMD "/bin/bash"
