cmake_minimum_required (VERSION 2.6)
project(mac_agent)
FIND_LIBRARY(COCOA_LIBRARY Cocoa)
FIND_LIBRARY(CARBON_LIBRARY Carbon)
FIND_LIBRARY(THRIFT_LIBRARY thrift)
add_custom_target(thrift-cpp thrift --gen cpp mac_agent.thrift DEPENDS mac_agent.thrift)

include_directories ("/usr/local/include/thrift/")
set(CMAKE_CXX_FLAGS "-g -Wall")
# add the executable
add_executable(mac_agent cmds.mm  main.mm  utility.mm gen-cpp/mac_agent.cpp gen-cpp/mac_agent_constants.cpp  gen-cpp/mac_agent_types.cpp)
add_dependencies(mac_agent thrift-cpp)
TARGET_LINK_LIBRARIES(mac_agent ${COCOA_LIBRARY} ${CARBON_LIBRARY} ${THRIFT_LIBRARY})
