# Android Dockerfile

FROM ubuntu:16.04

MAINTAINER Yongde Pan "panyongde@gmail.com"

# required to use add-apt-repository
RUN buildDeps='software-properties-common'; \
    set -x && \
    apt-get update && apt-get install -y $buildDeps --no-install-recommends && \
    add-apt-repository ppa:webupd8team/java -y && \
    apt-get update -y && \
    echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections && \
    apt-get install -y oracle-java8-installer && \
    apt-get install -y oracle-java8-set-default && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    apt-get purge -y --auto-remove $buildDeps && \
    apt-get autoremove -y && apt-get clean

ENV JAVA_HOME /usr/lib/jvm/java-8-oracle


# Installs i386 architecture required for running 32 bit Android tools
RUN dpkg --add-architecture i386 && \
    apt-get update -y && \
    apt-get install -y libc6:i386 zlib1g:i386 libncurses5:i386 libstdc++6:i386 lib32z1 wget unzip && \
    rm -rf /var/lib/apt/lists/* && \
    apt-get autoremove -y && \
    apt-get clean

WORKDIR /opt

# Gradle
ENV GRADLE_HOME /opt/gradle
ENV GRADLE_VERSION 4.1
ENV GRADLE_HASH 3014f027ae08bf3d9f7360e4e4352e80

ENV PATH $PATH:$GRADLE_HOME/bin
RUN wget -q "https://downloads.gradle.org/distributions/gradle-${GRADLE_VERSION}-bin.zip" && \
    echo "${GRADLE_HASH} gradle-${GRADLE_VERSION}-bin.zip" > gradle-${GRADLE_VERSION}-bin.zip.md5 && \
    md5sum -c gradle-${GRADLE_VERSION}-bin.zip.md5 && \
    unzip -q "gradle-${GRADLE_VERSION}-bin.zip" && \
    ln -s "gradle-${GRADLE_VERSION}" "${GRADLE_HOME}" && \
    rm "gradle-${GRADLE_VERSION}-bin.zip"*

# Installs Android SDK
RUN dpkg --add-architecture i386 && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    apt-get update && \
    apt-get install -yq build-essential libssl-dev ruby ruby-dev --no-install-recommends && \
    apt-get clean
    
RUN gem install bundler

# Download and untar Android SDK tools
RUN mkdir -p /usr/local/android-sdk-linux
RUN wget https://dl.google.com/android/repository/tools_r25.2.3-linux.zip -O tools.zip
RUN unzip tools.zip -d /usr/local/android-sdk-linux
RUN rm tools.zip

# Set environment variable
ENV ANDROID_HOME /usr/local/android-sdk-linux
ENV PATH ${ANDROID_HOME}/tools:$ANDROID_HOME/platform-tools:$PATH

RUN mkdir $ANDROID_HOME/licenses
RUN echo 8933bad161af4178b1185d1a37fbf41ea5269c55 > $ANDROID_HOME/licenses/android-sdk-license
RUN echo d56f5187479451eabf01fb78af6dfcb131a6481e >> $ANDROID_HOME/licenses/android-sdk-license
RUN echo 84831b9409646a918e30573bab4c9c91346d8abd > $ANDROID_HOME/licenses/android-sdk-preview-license

# Update and install using sdkmanager 
RUN $ANDROID_HOME/tools/bin/sdkmanager "tools" "platform-tools"
RUN $ANDROID_HOME/tools/bin/sdkmanager "build-tools;26.0.2" "build-tools;25.0.3"
RUN $ANDROID_HOME/tools/bin/sdkmanager "platforms;android-26" "platforms;android-25" "platforms;android-24" "platforms;android-23"
RUN $ANDROID_HOME/tools/bin/sdkmanager "extras;android;m2repository" "extras;google;m2repository"
RUN $ANDROID_HOME/tools/bin/sdkmanager "extras;m2repository;com;android;support;constraint;constraint-layout;1.0.2"
RUN $ANDROID_HOME/tools/bin/sdkmanager "extras;m2repository;com;android;support;constraint;constraint-layout-solver;1.0.2"

# 安装 node ---------------------------------------------
ENV NODEJS_VERSION=8.9.3 \
    PATH=$PATH:/opt/node/bin

WORKDIR "/opt/node"

RUN apt-get update && apt-get install -y curl ca-certificates --no-install-recommends && \
    curl -sL https://nodejs.org/dist/v${NODEJS_VERSION}/node-v${NODEJS_VERSION}-linux-x64.tar.gz | tar xz --strip-components=1 && \
    rm -rf /var/lib/apt/lists/* && \
    apt-get clean

RUN npm install -g cnpm

# 安装 cordova----------------------------------------------
ENV CORDOVA_VERSION 7.1.0

WORKDIR "/tmp"

RUN npm i -g --unsafe-perm cordova@${CORDOVA_VERSION}

# 安装 ionic-----------------------------------------------------
ENV IONIC_VERSION 3.19.0

RUN apt-get update && \
    npm i -g --unsafe-perm ionic@${IONIC_VERSION} && \
    ionic --no-interactive config set -g daemon.updates false && \
    rm -rf /var/lib/apt/lists/* && apt-get clean

# 其他 ----------------------------------------------------
RUN apt-get update && apt-get install -y git vim && apt-get clean

RUN gem install fir-cli
RUN cnpm install android-versions --save