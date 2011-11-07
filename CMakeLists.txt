cmake_minimum_required (VERSION 2.6)
project(mac_agent)
FIND_LIBRARY(COCOA_LIBRARY Cocoa)

#set(CMAKE_CXX_FLAGS "-g -x objective-c -framework Cocoa -Wall")
# add the executable
add_executable(mac_agent main.m)
TARGET_LINK_LIBRARIES(mac_agent ${COCOA_LIBRARY})
