cmake_minimum_required (VERSION 2.6)
project(mac_agent)
FIND_LIBRARY(COCOA_LIBRARY Cocoa)
FIND_LIBRARY(CARBON_LIBRARY Carbon)

set(CMAKE_CXX_FLAGS "-g -Wall")
# add the executable
add_executable(mac_agent cmds.m  main.m  utility.m)
TARGET_LINK_LIBRARIES(mac_agent ${COCOA_LIBRARY} ${CARBON_LIBRARY})
