/*
 * Copyright (C) 2011 Song Wei
 *
 * Licensed under the GNU GENERAL PUBLIC LICENSE, Version 3.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.gnu.org/licenses/gpl-3.0.html
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

// #import <Cocoa/Cocoa.h>
// #include <sys/types.h> 
// #include <sys/socket.h>
// #include <netinet/in.h>

#import <Cocoa/Cocoa.h>
#import "cmds.h"

#include "mac_agent.h"
#include <protocol/TBinaryProtocol.h>
#include <server/TSimpleServer.h>
#include <transport/TServerSocket.h>
#include <transport/TBufferTransports.h>

using namespace ::apache::thrift;
using namespace ::apache::thrift::protocol;
using namespace ::apache::thrift::transport;
using namespace ::apache::thrift::server;

using boost::shared_ptr;

class mac_agentHandler : virtual public mac_agentIf {
 public:
  mac_agentHandler() {
    // Your initialization goes here
  }

  int32_t handle_mouse_cmd(const std::string& window_name, const mouse_button::type button, const mouse_event::type event, const int32_t x, const int32_t y) {
    // Your implementation goes here
    printf("handle_mouse_cmd\n");
  }

  int32_t handle_key_cmd(const std::string& window_name, const std::string& key, const key_event::type event) {
    NSString *WindowName = [[NSString alloc] initWithUTF8String:window_name.c_str()];
    NSString *ns_key = [[NSString alloc] initWithUTF8String:window_name.c_str()];
    int ret = key_cmd(WindowName, ns_key, event);
    [WindowName release];
    [ns_key release];
    return ret;
  }

  int32_t handle_screenshot_cmd(const std::string& window_name, const std::string& screenshot_path) {
    // Your implementation goes here
    NSString *WindowName = [[NSString alloc] initWithUTF8String:window_name.c_str()];
    NSString *path = [[NSString alloc] initWithUTF8String:screenshot_path.c_str()];
    int ret = screen_cmd(WindowName, path);
    [WindowName release];
    [path release];
    return ret;
  }

};

int main(int argc, char **argv) {
  int port = 9090;
  shared_ptr<mac_agentHandler> handler(new mac_agentHandler());
  shared_ptr<TProcessor> processor(new mac_agentProcessor(handler));
  shared_ptr<TServerTransport> serverTransport(new TServerSocket(port));
  shared_ptr<TTransportFactory> transportFactory(new TBufferedTransportFactory());
  shared_ptr<TProtocolFactory> protocolFactory(new TBinaryProtocolFactory());

  TSimpleServer server(processor, serverTransport, transportFactory, protocolFactory);
  server.serve();
  return 0;
}
