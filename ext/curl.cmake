include(ExternalProject)

if (NOT CURL_EXT_EXTRA_OPTIONS)
    set(CURL_EXT_EXTRA_OPTIONS )
endif()

if (APPLE)
    list(APPEND CURL_EXT_EXTRA_OPTIONS "-DCURL_USE_SECTRANSP=ON")
else()
    find_package(OpenSSL REQUIRED COMPONENTS SSL Crypto)
    if (DEFINED OPENSSL_ROOT_DIR)
        list(APPEND CURL_EXT_EXTRA_OPTIONS "-DOPENSSL_ROOT_DIR=${OPENSSL_ROOT_DIR}")
    endif()
endif()

if(OWN_CURL_SOURCE_DIR)
    set(CURL_EXT_PROPERTIES SOURCE_DIR ${OWN_CURL_SOURCE_DIR})
else()
    set(CURL_EXT_PROPERTIES URL "http://curl.haxx.se/download/curl-8.0.1.tar.gz")
endif()

# -DCMAKE_INSTALL_LIBDIR=lib is required to find libcurl.a on fedora, default is lib64
ExternalProject_Add(
        curl_ext
        ${CURL_EXT_PROPERTIES}
        INSTALL_DIR ${CMAKE_BINARY_DIR}/ext/curl
        CMAKE_ARGS "-DCMAKE_INSTALL_PREFIX=${CMAKE_BINARY_DIR}/ext/curl" "-DBUILD_CURL_EXE=OFF" "-DBUILD_SHARED_LIBS=OFF" "-DCURL_STATICLIB=ON" "-DCURL_DISABLE_LDAP=ON" "-DCURL_USE_LIBSSH2=OFF" "-DCURL_USE_OPENLDAP=OFF" "-DUSE_LIBIDN2=OFF" "-DCURL_USE_LIBPSL=OFF" "-DENABLE_WEBSOCKETS=ON" "-DCMAKE_INSTALL_LIBDIR=lib" "-DCMAKE_C_FLAGS=${CMAKE_C_FLAGS}" "-DCMAKE_LINK_FLAGS=${CMAKE_LINK_FLAGS}" "-DCMAKE_LIBRARY_ARCHITECTURE=${CMAKE_LIBRARY_ARCHITECTURE}" ${CURL_EXT_EXTRA_OPTIONS}
)
file(MAKE_DIRECTORY ${CMAKE_BINARY_DIR}/ext/curl/include/)
add_library(curl STATIC IMPORTED)
add_dependencies(curl curl_ext)
set_property(TARGET curl PROPERTY IMPORTED_LOCATION ${CMAKE_BINARY_DIR}/ext/curl/lib/libcurl.a)
set_property(TARGET curl PROPERTY INTERFACE_INCLUDE_DIRECTORIES ${CMAKE_BINARY_DIR}/ext/curl/include/)
if (APPLE)
    set_property(TARGET curl PROPERTY INTERFACE_LINK_LIBRARIES "-framework SystemConfiguration -framework Security -framework CoreFoundation")
else()
    set_property(TARGET curl PROPERTY INTERFACE_LINK_LIBRARIES OpenSSL::SSL OpenSSL::Crypto)
endif()

set(CURL_FOUND TRUE)
set(CURL_LIBRARIES curl)
set(CURL_INCLUDE_DIRS ${CMAKE_BINARY_DIR}/ext/curl/include/)

file(MAKE_DIRECTORY ${CMAKE_BINARY_DIR}/ext/cmake_find_stubs)
file(WRITE ${CMAKE_BINARY_DIR}/ext/cmake_find_stubs/FindCURL.cmake "")
set(CMAKE_MODULE_PATH "${CMAKE_BINARY_DIR}/ext/cmake_find_stubs" ${CMAKE_MODULE_PATH})
