# Android Alexa Docker 

[![supportLib](https://img.shields.io/badge/targetApi-30-green)](https://opensource.google.com/projects/material-components-android)
[![supportLib](https://img.shields.io/badge/NDK-22-yellow.svg)](https://developer.android.com/ndk/downloads)

Docker image for building Alexa Android with NDK

## Build

``docker build -t alexa-android-ndk .``

## Tag

``docker tag alexa-android-ndk  hannesa2/alexa-android-ndk:api28``

## Publish

``docker push hannesa2/alexa-android-ndk:api28``

maybe you need a ``docker login`` in advance

## Usage

``docker run -it -v buildervolume:/workdir -v <Users//BMW/BETA-labs/path-to-alexa-auto-sdk>:/home/builder/aac -e ANDROID_TOOLCHAIN="/workdir/android" hannesa2/alexa-android-ndk:1.1``


## Docker hub

https://hub.docker.com/repository/docker/hannesa2/alexa-android-ndk
