#!/bin/sh
set -e

mkdir -p "${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}"

RESOURCES_TO_COPY=${PODS_ROOT}/resources-to-copy-${TARGETNAME}.txt
> "$RESOURCES_TO_COPY"

install_resource()
{
  case $1 in
    *.storyboard)
      echo "ibtool --reference-external-strings-file --errors --warnings --notices --output-format human-readable-text --compile ${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename \"$1\" .storyboard`.storyboardc ${PODS_ROOT}/$1 --sdk ${SDKROOT}"
      ibtool --reference-external-strings-file --errors --warnings --notices --output-format human-readable-text --compile "${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename \"$1\" .storyboard`.storyboardc" "${PODS_ROOT}/$1" --sdk "${SDKROOT}"
      ;;
    *.xib)
        echo "ibtool --reference-external-strings-file --errors --warnings --notices --output-format human-readable-text --compile ${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename \"$1\" .xib`.nib ${PODS_ROOT}/$1 --sdk ${SDKROOT}"
      ibtool --reference-external-strings-file --errors --warnings --notices --output-format human-readable-text --compile "${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename \"$1\" .xib`.nib" "${PODS_ROOT}/$1" --sdk "${SDKROOT}"
      ;;
    *.framework)
      echo "mkdir -p ${CONFIGURATION_BUILD_DIR}/${FRAMEWORKS_FOLDER_PATH}"
      mkdir -p "${CONFIGURATION_BUILD_DIR}/${FRAMEWORKS_FOLDER_PATH}"
      echo "rsync -av ${PODS_ROOT}/$1 ${CONFIGURATION_BUILD_DIR}/${FRAMEWORKS_FOLDER_PATH}"
      rsync -av "${PODS_ROOT}/$1" "${CONFIGURATION_BUILD_DIR}/${FRAMEWORKS_FOLDER_PATH}"
      ;;
    *.xcdatamodel)
      echo "xcrun momc \"${PODS_ROOT}/$1\" \"${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename "$1"`.mom\""
      xcrun momc "${PODS_ROOT}/$1" "${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename "$1" .xcdatamodel`.mom"
      ;;
    *.xcdatamodeld)
      echo "xcrun momc \"${PODS_ROOT}/$1\" \"${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename "$1" .xcdatamodeld`.momd\""
      xcrun momc "${PODS_ROOT}/$1" "${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename "$1" .xcdatamodeld`.momd"
      ;;
    *.xcmappingmodel)
      echo "xcrun mapc \"${PODS_ROOT}/$1\" \"${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename "$1" .xcmappingmodel`.cdm\""
      xcrun mapc "${PODS_ROOT}/$1" "${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename "$1" .xcmappingmodel`.cdm"
      ;;
    *.xcassets)
      ;;
    /*)
      echo "$1"
      echo "$1" >> "$RESOURCES_TO_COPY"
      ;;
    *)
      echo "${PODS_ROOT}/$1"
      echo "${PODS_ROOT}/$1" >> "$RESOURCES_TO_COPY"
      ;;
  esac
}
          install_resource "../../Pod/Assets/HPPPActiveCircle@2x.png"
                    install_resource "../../Pod/Assets/HPPPDoNoEnter.png"
                    install_resource "../../Pod/Assets/HPPPDoNoEnter@2x.png"
                    install_resource "../../Pod/Assets/HPPPGear@2x.png"
                    install_resource "../../Pod/Assets/HPPPInactiveCircle@2x.png"
                    install_resource "../../Pod/Assets/HPPPMagnify@2x.png"
                    install_resource "../../Pod/Assets/HPPPMeasurementArrowDown@2x.png"
                    install_resource "../../Pod/Assets/HPPPMeasurementArrowLeft@2x.png"
                    install_resource "../../Pod/Assets/HPPPMeasurementArrowRight@2x.png"
                    install_resource "../../Pod/Assets/HPPPMeasurementArrowUp@2x.png"
                    install_resource "../../Pod/Assets/HPPPMultipage.png"
                    install_resource "../../Pod/Assets/HPPPMultipageLandscape.png"
                    install_resource "../../Pod/Assets/HPPPPrint@2x~ipad.png"
                    install_resource "../../Pod/Assets/HPPPPrint@2x~iphone.png"
                    install_resource "../../Pod/Assets/HPPPPrintLater@2x~ipad.png"
                    install_resource "../../Pod/Assets/HPPPPrintLater@2x~iphone.png"
                    install_resource "../../Pod/Assets/HPPPSelected@2x.png"
                    install_resource "../../Pod/Assets/HPPPSelected@3x.png"
                    install_resource "../../Pod/Assets/HPPPUnselected@2x.png"
                    install_resource "../../Pod/Assets/HPPPUnselected@3x.png"
                    install_resource "../../Pod/Classes/Private/HPPPKeyboardView.xib"
                    install_resource "../../Pod/Classes/Private/HPPPMultiPageView.xib"
                    install_resource "../../Pod/Classes/Private/HPPPPageRangeView.xib"
                    install_resource "../../Pod/Classes/Private/HPPPPageView.xib"
                    install_resource "../../Pod/Classes/Private/HPPPPrintJobsActionView.xib"
                    install_resource "../../Pod/Classes/Private/HPPPRuleView.xib"
                    install_resource "../../Pod/Classes/HPPP.storyboard"
                    install_resource "../../Pod/Libraries/XBPageCurl/Resources/BackPageGradient.png"
                    install_resource "../../Pod/Libraries/XBPageCurl/Resources/BackFragmentShader.glsl"
                    install_resource "../../Pod/Libraries/XBPageCurl/Resources/BackVertexShader.glsl"
                    install_resource "../../Pod/Libraries/XBPageCurl/Resources/FrontFragmentShader.glsl"
                    install_resource "../../Pod/Libraries/XBPageCurl/Resources/FrontVertexShader.glsl"
                    install_resource "../../Pod/Libraries/XBPageCurl/Resources/NextPageFragmentShader.glsl"
                    install_resource "../../Pod/Libraries/XBPageCurl/Resources/NextPageNoTextureFragmentShader.glsl"
                    install_resource "../../Pod/Libraries/XBPageCurl/Resources/NextPageNoTextureVertexShader.glsl"
                    install_resource "../../Pod/Libraries/XBPageCurl/Resources/NextPageVertexShader.glsl"
                    install_resource "../../Pod/HPPhotoPrintLocalizable.bundle"
          
rsync -avr --copy-links --no-relative --exclude '*/.svn/*' --files-from="$RESOURCES_TO_COPY" / "${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}"
if [[ "${ACTION}" == "install" ]]; then
  rsync -avr --copy-links --no-relative --exclude '*/.svn/*' --files-from="$RESOURCES_TO_COPY" / "${INSTALL_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}"
fi
rm -f "$RESOURCES_TO_COPY"

if [[ -n "${WRAPPER_EXTENSION}" ]] && [ "`xcrun --find actool`" ] && [ `find . -name '*.xcassets' | wc -l` -ne 0 ]
then
  case "${TARGETED_DEVICE_FAMILY}" in
    1,2)
      TARGET_DEVICE_ARGS="--target-device ipad --target-device iphone"
      ;;
    1)
      TARGET_DEVICE_ARGS="--target-device iphone"
      ;;
    2)
      TARGET_DEVICE_ARGS="--target-device ipad"
      ;;
    *)
      TARGET_DEVICE_ARGS="--target-device mac"
      ;;
  esac
  find "${PWD}" -name "*.xcassets" -print0 | xargs -0 actool --output-format human-readable-text --notices --warnings --platform "${PLATFORM_NAME}" --minimum-deployment-target "${IPHONEOS_DEPLOYMENT_TARGET}" ${TARGET_DEVICE_ARGS} --compress-pngs --compile "${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}"
fi
