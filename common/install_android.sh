#!/bin/bash

set -ex

[ -n "${ANDROID_NDK}" ]

apt-get update
apt-get install -y --no-install-recommends autotools-dev autoconf unzip
apt-get autoclean && apt-get clean
rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

pushd /tmp
curl -Os https://dl.google.com/android/repository/android-ndk-${ANDROID_NDK}-linux-x86_64.zip
popd
_ndk_dir=/opt/ndk
mkdir -p "$_ndk_dir"
unzip -qo /tmp/android*.zip -d "$_ndk_dir"
_versioned_dir=$(find "$_ndk_dir/" -mindepth 1 -maxdepth 1 -type d)
mv "$_versioned_dir"/* "$_ndk_dir"/
rmdir "$_versioned_dir"
rm -rf /tmp/*

# Install OpenJDK
# https://hub.docker.com/r/picoded/ubuntu-openjdk-8-jdk/dockerfile/

sudo apt-get update && \
	apt-get install -y openjdk-8-jdk && \
	apt-get install -y ant && \
	apt-get clean && \
	rm -rf /var/lib/apt/lists/* && \
	rm -rf /var/cache/oracle-jdk8-installer;

# Fix certificate issues, found as of
# https://bugs.launchpad.net/ubuntu/+source/ca-certificates-java/+bug/983302

sudo apt-get update && \
	apt-get install -y ca-certificates-java && \
	apt-get clean && \
	update-ca-certificates -f && \
	rm -rf /var/lib/apt/lists/* && \
	rm -rf /var/cache/oracle-jdk8-installer;

export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64/

# Installing android sdk
# https://github.com/circleci/circleci-images/blob/staging/android/Dockerfile.m4

_sdk_version=sdk-tools-linux-3859397.zip
_android_home=/opt/android/sdk

rm -rf $_android_home
sudo mkdir -p $_android_home
curl --silent --show-error --location --fail --retry 3 --output /tmp/$_sdk_version https://dl.google.com/android/repository/$_sdk_version
sudo unzip -q /tmp/$_sdk_version -d $_android_home
rm /tmp/$_sdk_version

sudo chmod -R 777 $_android_home

export ANDROID_HOME=$_android_home
export ADB_INSTALL_TIMEOUT=120

export PATH="${ANDROID_HOME}/emulator:${ANDROID_HOME}/tools:${ANDROID_HOME}/tools/bin:${ANDROID_HOME}/platform-tools:${PATH}"
echo "PATH:${PATH}"
alias sdkmanager="$ANDROID_HOME/tools/bin/sdkmanager"

sudo mkdir ~/.android && sudo echo '### User Sources for Android SDK Manager' > ~/.android/repositories.cfg
sudo chmod -R 777 ~/.android

yes | sdkmanager --licenses
yes | sdkmanager --update

sdkmanager \
  "tools" \
  "platform-tools" \
  "emulator"

sdkmanager \
  "build-tools;28.0.3" \
  "build-tools;29.0.2"

sdkmanager \
  "platforms;android-28" \
  "platforms;android-29"
sdkmanager --list

# Installing Gradle
echo "GRADLE_VERSION:${GRADLE_VERSION}"
_gradle_home=/opt/gradle
sudo rm -rf $gradle_home
sudo mkdir -p $_gradle_home

wget --no-verbose --output-document=/tmp/gradle.zip \
"https://services.gradle.org/distributions/gradle-${GRADLE_VERSION}-bin.zip"

sudo unzip -q /tmp/gradle.zip -d $_gradle_home
rm /tmp/gradle.zip

sudo chmod -R 777 $_gradle_home

export GRADLE_HOME=$_gradle_home/gradle-$GRADLE_VERSION
alias gradle="${GRADLE_HOME}/bin/gradle"

export PATH="${GRADLE_HOME}/bin/:${PATH}"
echo "PATH:${PATH}"

gradle --version

_gradledeps=/tmp/gradledeps

rm -rf "$_gradledeps"
mkdir -p "$_gradledeps"

cat <<EOF >"$_gradledeps/AndroidManifest.xml"
<manifest package="org.pytorch" />
EOF

cat <<EOF >"$_gradledeps/build.gradle"
buildscript {
    ext {
        minSdkVersion = 21
        targetSdkVersion = 28
        compileSdkVersion = 28
        buildToolsVersion = '28.0.3'

        coreVersion = "1.2.0"
        extJUnitVersion = "1.1.1"
        runnerVersion = "1.2.0"
        rulesVersion = "1.2.0"
        junitVersion = "4.12"
    }

    repositories {
        google()
        mavenLocal()
        mavenCentral()
        jcenter()
    }

    dependencies {
        classpath 'com.android.tools.build:gradle:3.3.2'
        classpath "com.jfrog.bintray.gradle:gradle-bintray-plugin:1.8.0"
        classpath "com.github.dcendents:android-maven-gradle-plugin:2.1"
        classpath "org.jfrog.buildinfo:build-info-extractor-gradle:4.9.8"
    }
}

repositories {
    google()
    jcenter()
}

apply plugin: 'com.android.library'

android {
    compileSdkVersion rootProject.compileSdkVersion
    buildToolsVersion rootProject.buildToolsVersion

    defaultConfig {
        minSdkVersion minSdkVersion
        targetSdkVersion targetSdkVersion
    }

    sourceSets {
        main {
            manifest.srcFile 'AndroidManifest.xml'
        }
    }
}

dependencies {
    implementation 'com.android.support:appcompat-v7:28.0.0'

    implementation 'com.facebook.fbjni:fbjni-java-only:0.0.3'
    implementation 'com.google.code.findbugs:jsr305:3.0.1'
    implementation 'com.facebook.soloader:nativeloader:0.8.0'

    testImplementation 'junit:junit:' + rootProject.junitVersion
    testImplementation 'androidx.test:core:' + rootProject.coreVersion

    androidTestImplementation 'junit:junit:' + rootProject.junitVersion
    androidTestImplementation 'androidx.test:core:' + rootProject.coreVersion
    androidTestImplementation 'androidx.test.ext:junit:' + rootProject.extJUnitVersion
    androidTestImplementation 'androidx.test:rules:' + rootProject.rulesVersion
    androidTestImplementation 'androidx.test:runner:' + rootProject.runnerVersion
}
EOF

gradle -p $_gradledeps --refresh-dependencies --debug --stacktrace assemble

