#!/bin/bash

DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer
xcodebuild -workspace MobilePrintSDK.xcworkspace/ -scheme MobilePrintSDK-cal -configuration Debug -sdk iphonesimulator  ONLY_ACTIVE_ARCH=NO CONFIGURATION_BUILD_DIR="/Users/Shared/Jenkins/Home/jobs/mp-example-app-ios/workspace/build" clean build
