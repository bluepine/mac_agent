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

#import <Cocoa/Cocoa.h>
#import "cmds.h"
#include <sys/types.h> 
#include <sys/socket.h>
#include <netinet/in.h>

struct cmd_entry{
  const char * cmd;
  int (*handler)(int fd, char * args);
};

static struct cmd_entry cmd_list[]={
  {"screenshot", handle_screenshot},
  {"key", handle_keyevent},
  {NULL, NULL}
};

static void error(const char *msg)
{
  perror(msg);
  exit(1);
}

static int handle_cmd(int fd, char * cmd){
  char *token, *string;
  int i;
  printf("cmd %s received\n", cmd);
  string = cmd;
  token = strsep(&string, " ");
  if(token == NULL){
    error("wrong command");      
  }
  if(strlen(token)==0){
    return -1;
  }
  if(!strcmp(token, "quit")){
    return 1;
  }
  for(i=0; cmd_list[i].cmd; i++){
    if(!strcmp(token, cmd_list[i].cmd)){
      write(fd, "{", 1);
      int ret = cmd_list[i].handler(fd, string);
      write(fd, "}", 1);
      return ret;
    }
  }
  printf("cmd %s not supported\n", token);
  return 0;
}

int main (int argc, const char * argv[]){
  int fd;
  char cmd_buf[1024];
  const char *output = "output";
  //const char * output = "output";
  //sprintf(cmd_buf, "%s", "screenshot e.png");
  sprintf(cmd_buf, "%s", "key z down");
  fd = open(output, O_WRONLY | O_CREAT, 0777);
  if(fd < 0){
    perror("error opening ");
    return -1;
  }
  handle_cmd(fd, cmd_buf);
  close(fd);
  return 0;
}

int test_main (int argc, const char * argv[])
{
  int sockfd, newsockfd, portno;
  socklen_t clilen;
  char buffer[1024];
  struct sockaddr_in serv_addr, cli_addr;
  int n;
  int tr = 1;
  if (argc < 2) {
    fprintf(stderr,"ERROR, no port provided\n");
    exit(1);
  }
  sockfd = socket(AF_INET, SOCK_STREAM, 0);
  if (sockfd < 0) 
    error("ERROR opening socket");
  bzero((char *) &serv_addr, sizeof(serv_addr));
  portno = atoi(argv[1]);
  serv_addr.sin_family = AF_INET;
  serv_addr.sin_addr.s_addr = INADDR_ANY;
  serv_addr.sin_port = htons(portno);
  // kill "Address already in use" error message
  if (setsockopt(sockfd,SOL_SOCKET,SO_REUSEADDR,&tr,sizeof(int)) == -1) {
    perror("setsockopt");
    exit(1);
  }
  if (bind(sockfd, (struct sockaddr *) &serv_addr,
	   sizeof(serv_addr)) < 0) 
    error("ERROR on binding");
  listen(sockfd,5);
  clilen = sizeof(cli_addr);
  newsockfd = accept(sockfd, 
		     (struct sockaddr *) &cli_addr, 
		     &clilen);
  if (newsockfd < 0) 
    error("ERROR on accept");
  while(1){
    bzero(buffer,1023);
    n = read(newsockfd,buffer,1023);
    if (n < 0) error("ERROR reading from socket");
    //    printf("Here is the message: %s\n",buffer);
    if(handle_cmd(newsockfd, buffer)){
      break;
    }
  }
  close(newsockfd);
  close(sockfd);
  return 0; 
}

