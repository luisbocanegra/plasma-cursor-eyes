cmake_minimum_required(VERSION 3.20)
set(PROJECT_NAME "plasma-cursor-eyes")
project(${PROJECT_NAME})
option(INSTALL_SCRIPT_QML "Install KWin Script" OFF)
option(PACKAGE_SCRIPT_QML "Package KWin Script" OFF)

set(KF6_MIN_VERSION "6.0.0")

find_package(ECM ${KF6_MIN_VERSION} REQUIRED NO_MODULE)
set(CMAKE_MODULE_PATH ${ECM_MODULE_PATH})

# Get id and version from metadata
file(READ ${CMAKE_CURRENT_SOURCE_DIR}/package/metadata.json METADATA)
string(JSON PLUGIN_ID GET ${METADATA} KPlugin Id)
string(JSON CUR_VERSION GET ${METADATA} KPlugin Version)
message("Plugin Id: ${PLUGIN_ID}")
message("Version: ${CUR_VERSION}")

if(INSTALL_SCRIPT_QML)
    find_package(KF6 ${KF6_MIN_VERSION} REQUIRED COMPONENTS
        Package
    )
    kpackage_install_package(package ${PLUGIN_ID} scripts kwin)
endif()

if(PACKAGE_SCRIPT_QML)
    # genreate kwinscript file
    set(SCRIPT_FILE ${CMAKE_SOURCE_DIR}/${PROJECT_NAME}-v${CUR_VERSION}-qml.kwinscript)
    add_custom_target(script_qml ALL
        COMMAND rm -rf "${SCRIPT_FILE}"
        COMMAND ${CMAKE_COMMAND} -E chdir ${CMAKE_CURRENT_SOURCE_DIR}/package zip -r ${SCRIPT_FILE} ./
        COMMENT "Generating ${SCRIPT_FILE}"
    )
endif()
