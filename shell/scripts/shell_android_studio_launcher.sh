#!/bin/bash
newestAsApp=$(ls /Applications | grep "Android Studio" | sort | tail -1)
newestAs=$(echo $newestAsApp | sed "s/.app//g")

export ANDROID_STUDIO_APP_NAME=$newestAs

unset newestAsApp
unset newestAs