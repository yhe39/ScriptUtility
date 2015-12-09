#!/bin/bash

#
#   This script aims to pack the test suites involved to the Crosswalk
#   for compatibility tests.
#   
#   Written by: Zhong Qiu(zhongx.qiu@intel.com)
#   Date:       2015-11-25
#


CWD=$(pwd)
source ${CWD}/config

###############################################################################
# Update the code!
###############################################################################
update_code() {

    if [[ $1 == "N" ]];then
        cd ${WORKSPACE}/crosswalk-test-suite
    elif [[ $1 == "N1" ]]; then
        cd ${WORKSPACE}/crosswalk-test-suite-${N1}
    elif [[ $1 == "N2" ]]; then
        cd ${WORKSPACE}/crosswalk-test-suite-${N2}
    elif [[ $1 == "N3" ]]; then
        cd ${WORKSPACE}/crosswalk-test-suite-${N3}
    else
        echo "Params Error!"
        exit 1
    fi

    git reset --hard HEAD
    git pull
    
    cd -
}

update_version() {

    if [[ $1 == "N" ]];then
        cd ${WORKSPACE}/crosswalk-test-suite
    elif [[ $1 == "N1" ]]; then
        cd ${WORKSPACE}/crosswalk-test-suite-${N1}
    elif [[ $1 == "N2" ]]; then
        cd ${WORKSPACE}/crosswalk-test-suite-${N2}
    elif [[ $1 == "N3" ]]; then
        cd ${WORKSPACE}/crosswalk-test-suite-${N3}
    fi 

    sed -i "s|\"main-version\": \"\([^\"]*\)\"|\"main-version\": \"$2\"|g" VERSION
    if [[ $2 == ${N_PLUS_1_VER} ]]; then
        sed -i "s/beta/canary/" $CTS_DIR/VERSION
    fi
    cd -
}

copy_sdk() {

    if [[ $1 == "N" ]];then
        cd ${WORKSPACE}/crosswalk-test-suite/tools
    elif [[ $1 == "N1" ]]; then
        cd ${WORKSPACE}/crosswalk-test-suite-${N1}/tools
    elif [[ $1 == "N2" ]]; then
        cd ${WORKSPACE}/crosswalk-test-suite-${N2}/tools
    elif [[ $1 == "N3" ]]; then
        cd ${WORKSPACE}/crosswalk-test-suite-${N3}/tools
    else
        echo "Params Error!"
        exit 1
    fi        

    rm -fr crosswalk
    if [[ -d ${PKG_TOOLS_DIR}/crosswalk-$2 ]]; then
        cp -a ${PKG_TOOLS_DIR}/crosswalk-$2 ./crosswalk
    else
        echo "${PKG_TOOLS_DIR}/crosswalk-$2 does not exists!"
        exit 1        
    fi
    cd -
}

copy_sdk_webview() {

    if [[ $1 == "N" ]]; then
        cd ${WORKSPACE}/crosswalk-test-suite/tools
    elif [[ $1 == "N1" ]]; then
        cd ${WORKSPACE}/crosswalk-test-suite-${N1}/tools
    elif [[ $1 == "N2" ]]; then
        cd ${WORKSPACE}/crosswalk-test-suite-${N2}/tools
    elif [[ $1 == "N3" ]]; then
        cd ${WORKSPACE}/crosswalk-test-suite-${N3}/tools
    else
        echo "Param Error!"
        exit 1
    fi

    rm -fr crosswalk-webview
    if [[ -d ${PKG_TOOLS_DIR}/crosswalk-webview-$2-$3 ]]; then
        cp -a ${PKG_TOOLS_DIR}/crosswalk-webview-$2-$3 ./crosswalk-webview 
    else
        echo "${PKG_TOOLS_DIR}/crosswalk-webview-$2-$3 does not exists!"
        exit 1
    fi
    
    find ./crosswalk-webview/ -name "libxwalkcore.so" -exec rm -f {} \;
    find ./crosswalk-webview/ -name "xwalk_core_library_java_library_part.jar" -exec rm -f {} \;

    cd -
}

copy_demo_express() {

    if [[ $1 == "N" ]]; then
        cd ${WORKSPACE}/crosswalk-test-suite
    elif [[ $1 == "N1" ]]; then
        cd ${WORKSPACE}/crosswalk-test-suite-${N1}
    elif [[ $1 == "N2" ]]; then
        cd ${WORKSPACE}/crosswalk-test-suite-${N2}
    elif [[ $1 == "N3" ]]; then
        cd ${WORKSPACE}/crosswalk-test-suite-${N3}
    fi

    cd usecase/usecase-webapi-xwalk-tests
    cp -dpR $DEMOEX_DIR/samples/* ./samples/
    cp -dpR $DEMOEX_DIR/res/* ./res/
    cp -a ${WORKSPACE}/patch/usecase/usecase-webapi-xwalk-tests/samples/Advertising/res/ad ./samples/Advertising/res/
    cp -a ${WORKSPACE}/patch/usecase/usecase-webapi-xwalk-tests/samples/InAppPayment/iap/* ./samples/InAppPayment/iap/
    cd -

    cd usecase/usecase-wrt-android-tests
    cp -dpR $DEMOEX_DIR/samples-wrt/* ./samples/
    sed -i "s|--enable-lzma||g" suite.json
    cd -

    cd usecase/usecase-cordova-android-tests
    cp -dpR $DEMOEX_DIR/samples-cordova/* ./samples/
    cd -

    cd ${WORKSPACE}
}

copy_webrunner() {

    if [[ $1 == "N" ]]; then
        cd ${WORKSPACE}/crosswalk-test-suite
    elif [[ $1 == "N1" ]]; then
        cd ${WORKSPACE}/crosswalk-test-suite-${N1}
    elif [[ $1 == "N2" ]]; then
        cd ${WORKSPACE}/crosswalk-test-suite-${N2}
    elif [[ $1 == "N3" ]]; then
        cd ${WORKSPACE}/crosswalk-test-suite-${N3}
    fi    

    for aio in ${XWALK_WEBAPI_TC}
    do
        cd $aio
        rm -fv *.zip
        mkdir -p webrunner
        cp ../../tools/resources/webrunner/* webrunner -a
        cd -
    done

    cd ${WORKSPACE}
}

pack_sampleapp_tc() {
    
    if [[ $1 == "N" ]];then
        cd ${WORKSPACE}/crosswalk-test-suite
    elif [[ $1 == "N1" ]]; then
        cd ${WORKSPACE}/crosswalk-test-suite-${N1}
    elif [[ $1 == "N2" ]]; then
        cd ${WORKSPACE}/crosswalk-test-suite-${N2}
    elif [[ $1 == "N3" ]]; then
        cd ${WORKSPACE}/crosswalk-test-suite-${N3}
    else
        echo "Params Error!"
        exit 1
    fi 

    for tc in ${XWALK_SAMPLE_APPS_TC}
    do
        cd $tc
        rm -fv *.zip
        ../../tools/build/pack.py -t apk -a $2 -m $3
        tc_name=$(echo $tc | awk -F '/' '{print $2}')
        mv -fv *.zip ${tc_name}-00.$4-$3.apk.zip
        mv -fv ${tc_name}-00.$4-$3.apk.zip ${DEST_DIR}/test_suites/crosswalk/crosswalk-$4/$2/
        cd -
    done

    cd ${WORKSPACE}
}

pack_usecase_tc() {

    if [[ $1 == "N" ]];then
        cd ${WORKSPACE}/crosswalk-test-suite
    elif [[ $1 == "N1" ]]; then
        cd ${WORKSPACE}/crosswalk-test-suite-${N1}
    elif [[ $1 == "N2" ]]; then
        cd ${WORKSPACE}/crosswalk-test-suite-${N2}
    elif [[ $1 == "N3" ]]; then
        cd ${WORKSPACE}/crosswalk-test-suite-${N3}
    else
        echo "Params Error!"
        exit 1
    fi

    for tc in ${XWALK_USECASE_TC}
    do
        cd $tc
        rm -fv *.zip
        ../../tools/build/pack.py -t apk -a $2 -m $3
        tc_name=$(echo $tc | awk -F '/' '{print $2}')
        BRANCH=$(eval echo \${$1})
        mv -fv *.zip ${tc_name}-${BRANCH}.$4-$3.apk.zip
        mv -fv ${tc_name}-${BRANCH}.$4-$3.apk.zip ${DEST_DIR}/test_suites/crosswalk/crosswalk-$4/$2/
        cd -
    done

    for etc in ${XWALK_USECASE_EMBEDDING_TC}
    do
        cd $etc
        rm -fv *.zip
        ../../tools/build/pack.py -t embeddingapi --pack-type ant
        tc_name=$(echo $etc | awk -F '/' '{print $2}')
        BRANCH=$(eval echo \${$1})
        mv -fv *.zip ${tc_name}-${BRANCH}.$4-$3.embeddingapi.zip
        mv -fv ${tc_name}-${BRANCH}.$4-$3.embeddingapi.zip ${DEST_DIR}/test_suites/crosswalk/crosswalk-$4/$2/
        cd -
    done

    cd ${WORKSPACE}
}


pack_webapi_tc() {
    
    if [[ $1 == "N" ]];then
        cd ${WORKSPACE}/crosswalk-test-suite
    elif [[ $1 == "N1" ]]; then
        cd ${WORKSPACE}/crosswalk-test-suite-${N1}
    elif [[ $1 == "N2" ]]; then
        cd ${WORKSPACE}/crosswalk-test-suite-${N2}
    elif [[ $1 == "N3" ]]; then
        cd ${WORKSPACE}/crosswalk-test-suite-${N3}
    else
        echo "Params Error!"
        exit 1
    fi    

    for tc in ${XWALK_WEBAPI_TC}
    do
        if [[ -d $tc ]]; then
            cd $tc
            rm -fv *.zip
            ./pack.sh -t apk -a $2 -m $3
            tc_name=$(echo $tc | awk -F '/' '{print $2}')
            BRANCH=$(eval echo \${$1})
            mv -fv *.zip ${tc_name}-${BRANCH}.$4-$3.apk.zip
            mv -fv ${tc_name}-${BRANCH}.$4-$3.apk.zip ${DEST_DIR}/test_suites/crosswalk/crosswalk-$4/$2
            cd -
        else
            echo "$tc does not exist!" 
        fi
    done

    cd ${WORKSPACE}
}

pack_embeddingapi_tc() {
    if [[ $1 == "N" ]];then
        cd ${WORKSPACE}/crosswalk-test-suite
    elif [[ $1 == "N1" ]]; then
        cd ${WORKSPACE}/crosswalk-test-suite-${N1}
    elif [[ $1 == "N2" ]]; then
        cd ${WORKSPACE}/crosswalk-test-suite-${N2}
    elif [[ $1 == "N3" ]]; then
        cd ${WORKSPACE}/crosswalk-test-suite-${N3}
    else
        echo "Params Error!"
        exit 1
    fi    

    for tc in ${XWALK_EMBEDDINGAPI_TC}
    do
        if [[ -d $tc ]]; then
            cd $tc
            rm -fv *.zip
            ../../tools/build/pack.py -t embeddingapi --pack-type ant
            tc_name=$(echo $tc | awk -F '/' '{print $2}')
            BRANCH=$(eval echo \${$1})
            mv -fv *.zip ${tc_name}-${BRANCH}.$4-$3.embeddingapi.zip
            mv -fv ${tc_name}-${BRANCH}.$4-$3.embeddingapi.zip ${DEST_DIR}/test_suites/crosswalk/crosswalk-$4/$2
            cd -
        else
            echo "$tc does not exist!"
        fi
    done

}

###############################################################################
# Update all repositories
###############################################################################
# update_code N
# copy_demo_express N
# copy_webrunner N

# update_code N1
# copy_demo_express N1
# copy_webrunner N1

# update_code N2
# copy_demo_express N2
# copy_webrunner N2

# update_code N3
# copy_demo_express N3
# copy_webrunner N3

###############################################################################
# Sample Apps Test Suites
###############################################################################

# 17.16

# update_version N ${N_1_VER}
# copy_sdk N ${N_1_VER}
# # pack_sampleapp_tc N arm shared ${N1}
# pack_sampleapp_tc N x86 shared ${N1}


# 17.15

# update_version N ${N_2_VER}
# copy_sdk N ${N_2_VER}
# # pack_sampleapp_tc N arm shared ${N2}
# pack_sampleapp_tc N x86 shared ${N2}


# 17.14

# update_version N ${N_3_VER}
# copy_sdk N ${N_3_VER}
# # pack_sampleapp_tc N arm shared ${N3}
# pack_sampleapp_tc N x86 shared ${N3}


###############################################################################
# Usecase Test Suites...
###############################################################################
# 17.17

# update_version N ${N_VER}
# copy_sdk N ${N_VER}
# # copy_sdk_webview N ${N_VER} arm
# # pack_usecase_tc N arm shared ${N}
# copy_sdk_webview N ${N_VER} x86
# pack_usecase_tc N x86 shared ${N}


# 17.16

# update_version N1 ${N_VER}
# copy_sdk N1 ${N_VER}
# # copy_sdk_webview N1 ${N_VER} arm
# # pack_usecase_tc N1 arm shared ${N}
# copy_sdk_webview N1 ${N_VER} x86
# pack_usecase_tc N1 x86 shared ${N}


# 17.15

# update_version N2 ${N_VER}
# copy_sdk N2 ${N_VER}
# # copy_sdk_webview N2 ${N_VER} arm
# # pack_usecase_tc N2 arm shared ${N}
# copy_sdk_webview N2 ${N_VER} x86
# pack_usecase_tc N2 x86 shared ${N}


# 17.14

# update_version N3 ${N_VER}
# copy_sdk N3 ${N_VER}
# # copy_sdk_webview N3 ${N_VER} arm
# # pack_usecase_tc N3 arm shared ${N}
# copy_sdk_webview N3 ${N_VER} x86
# pack_usecase_tc N3 x86 shared ${N}


# 16.16

# update_version N1 ${N_1_VER}
# copy_sdk N1 ${N_1_VER}
# # copy_sdk_webview N1 ${N_1_VER} arm
# # pack_usecase_tc N1 arm shared ${N1}
# copy_sdk_webview N1 ${N_1_VER} x86
# pack_usecase_tc N1 x86 shared ${N1}


# 15.15

# update_version N2 ${N_2_VER}
# copy_sdk N2 ${N_2_VER}
# # copy_sdk_webview N2 ${N_2_VER} arm
# # pack_usecase_tc N2 arm shared ${N2}
# copy_sdk_webview N2 ${N_2_VER} x86
# pack_usecase_tc N2 x86 shared ${N2}


# 14.14

# update_version N3 ${N_3_VER}
# copy_sdk N3 ${N_3_VER}
# # copy_sdk_webview N3 ${N_3_VER} arm
# # pack_usecase_tc N3 arm shared ${N3}
# copy_sdk_webview N3 ${N_3_VER} x86
# pack_usecase_tc N3 x86 shared ${N3}

# N=16

# update_version N2 ${N_1_VER}
# copy_sdk N2 ${N_1_VER}
# copy_sdk_webview N2 ${N_1_VER} arm
# pack_usecase_tc N2 arm shared ${N1}
# copy_sdk_webview N2 ${N_1_VER} x86
# pack_usecase_tc N2 x86 shared ${N1}

# update_version N3 ${N_1_VER}
# copy_sdk N3 ${N_1_VER}
# copy_sdk_webview N3 ${N_1_VER} arm
# pack_usecase_tc N3 arm shared ${N1}
# copy_sdk_webview N3 ${N_1_VER} x86
# pack_usecase_tc N3 x86 shared ${N1}

# End N=16

###############################################################################
# WebAPI Test Suites
###############################################################################
# 16.16

# update_version N1 ${N_1_VER}
# copy_sdk N1 ${N_1_VER}
# # pack_webapi_tc N1 arm shared ${N1}
# pack_webapi_tc N1 x86 shared ${N1}


# 15.15

# update_version N2 ${N_2_VER}
# copy_sdk N2 ${N_2_VER}
# # pack_webapi_tc N2 arm shared ${N2}
# pack_webapi_tc N2 x86 shared ${N2}


###############################################################################
# Embedding API Test Suites
###############################################################################

# 17.17

# update_version N ${N_VER}
# # copy_sdk_webview N ${N_VER} arm
# # pack_embeddingapi_tc N arm shared ${N}
# copy_sdk_webview N ${N_VER} x86
# pack_embeddingapi_tc N x86 shared ${N}


# 16.17

update_version N1 ${N_VER}
# copy_sdk_webview N1 ${N_VER} arm
# pack_embeddingapi_tc N1 arm shared ${N}
copy_sdk_webview N1 ${N_VER} x86
pack_embeddingapi_tc N1 x86 shared ${N}


# 15.17

# update_version N2 ${N_VER} 
# # copy_sdk_webview N2 ${N_VER} arm
# # pack_embeddingapi_tc N2 arm shared ${N}
# copy_sdk_webview N2 ${N_VER} x86
# pack_embeddingapi_tc N2 x86 shared ${N}


# # 14.17

# update_version N3 ${N_VER}
# # copy_sdk_webview N3 ${N_VER} arm
# # pack_embeddingapi_tc N3 arm shared ${N}
# copy_sdk_webview N3 ${N_VER} x86
# pack_embeddingapi_tc N3 x86 shared ${N}


# # 16.16

# update_version N1 ${N_1_VER}
# # copy_sdk_webview N1 ${N_1_VER} arm
# # pack_embeddingapi_tc N1 arm shared ${N1}
# copy_sdk_webview N1 ${N_1_VER} x86
# pack_embeddingapi_tc N1 x86 shared ${N1}


# # 15.15
# update_version N2 ${N_2_VER}
# # copy_sdk_webview N2 ${N_2_VER} arm
# # pack_embeddingapi_tc N2 arm shared ${N2}
# copy_sdk_webview N2 ${N_2_VER} x86
# pack_embeddingapi_tc N2 x86 shared ${N2}


# # 14.14

# update_version N3 ${N_3_VER}
# # copy_sdk_webview N3 ${N_3_VER} arm
# # pack_embeddingapi_tc N3 arm shared ${N3}
# copy_sdk_webview N3 ${N_3_VER} x86
# pack_embeddingapi_tc N3 x86 shared ${N3}


# 15.16
# update_version N2 ${N_1_VER}
# copy_sdk_webview N2 ${N_1_VER} arm
# pack_embeddingapi_tc N2 arm shared ${N1}
# copy_sdk_webview N2 ${N_1_VER} x86
# pack_embeddingapi_tc N2 x86 shared ${N1}

# 14.16
# update_version N3 ${N_1_VER}
# copy_sdk_webview N3 ${N_1_VER} arm
# pack_embeddingapi_tc N3 arm shared ${N1}
# copy_sdk_webview N3 ${N_1_VER} x86
# pack_embeddingapi_tc N3 x86 shared ${N1}
