#!/bin/bash

set -o errexit

APP_DIR="$(dirname `readlink -f $0`)/meteor-app"
ARCH="$(uname -m)"

METEOR_VERSION="1.1.0.2"
BUNDLE_VERSION="0.4.18"

if [ $ARCH == 'armv6l' ] || [ $ARCH == 'armv7l' ]; then
    ARM_UNVERSAL_NAME="release-${METEOR_VERSION}-universal"
    ARM_UNIVERSAL_URL="https://github.com/4commerce-technologies-AG/meteor/archive/${ARM_UNVERSAL_NAME}.tar.gz"
    ARM_UNIVERSAL_DIR="meteor-${ARM_UNVERSAL_NAME}"
    ARM_UNIVERSAL_PKG="meteor.tar.gz"

    ARM_BUNDLE_NAME="dev_bundle_Linux_${ARCH}_universal_${METEOR_VERSION}_RASPBIAN-WHEEZY_${BUNDLE_VERSION}"
    ARM_BUNDLE_URL="https://github.com/4commerce-technologies-AG/meteor/releases/download/release%2F${METEOR_VERSION}-universal/${ARM_BUNDLE_NAME}.tar.gz"
    ARM_BUNDLE_DIR="${ARM_BUNDLE_NAME}"
    ARM_BUNDLE_PKG="dev_bundle.tar.gz"

    wget https://archive.raspbian.org/raspbian.public.key -O - | apt-key add -
    echo "deb http://mirrordirector.raspbian.org/raspbian/ jessie main contrib non-free rpi" > /etc/apt/sources.list.d/raspbian-jessie.list

    apt-get -q update
    apt-get install -y build-essential debian-keyring autoconf automake libtool flex bison mongodb

    cd /
    wget $ARM_UNIVERSAL_URL -O $ARM_UNIVERSAL_PKG
    tar xzf $ARM_UNIVERSAL_PKG
    rm -f $ARM_UNIVERSAL_PKG
    mv $ARM_UNIVERSAL_DIR meteor
    cd meteor

    # Works only if /meteor directory is a git repo. Make sure meteor --version is working
    git init
    git config --global user.email "whatever@whatever.com"
    git config --global user.name "Does Not Matter"
    git add ./meteor
    git commit -m"version"

    wget $ARM_BUNDLE_URL -O $ARM_BUNDLE_PKG
    mkdir dev_bundle
    tar xzf $ARM_BUNDLE_PKG -C dev_bundle
    rm -f $ARM_BUNDLE_PKG

    ln -s /meteor/meteor /usr/bin/meteor
fi

if [ $ARCH == 'i386' ]; then
    curl https://install.meteor.com/ | sh
    ln -s /usr/local/bin/meteor /usr/bin/meteor
fi

ln -s /usr/local/bin/node /usr/bin/node
ln -s /usr/local/bin/npm /usr/bin/npm

cd $APP_DIR
meteor update