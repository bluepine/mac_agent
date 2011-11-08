# Echo client program
import socket

def exec_cmd(s, cmd):
    data = ''
    s.send(cmd)
    while True:
        r = s.recv(1024)
        if len(r) == 0:
            break
        if r[-1] == '!':
            return None
        data = data+r
        if r[-1] == '}':
            break
    return data
    
HOST = 'localhost'
PORT = 50008
s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
s.connect((HOST, PORT))
print exec_cmd(s, 'screenshot,EVE Online,1.png');
print exec_cmd(s, 'mouse,EVE Online,left,move,150,150')
print exec_cmd(s, 'mouse,EVE Online,left,down,150,150')
print exec_cmd(s, 'mouse,EVE Online,left,drag,250,250')
print exec_cmd(s, 'mouse,EVE Online,left,up,250,250')
print exec_cmd(s, 'key,EVE Online,f1,down')
print exec_cmd(s, 'key,EVE Online,f1,up')
print exec_cmd(s, 'mouse,EVE Online,right,down,250,250')
print exec_cmd(s, 'mouse,EVE Online,right,up,250,250')
print exec_cmd(s, 'mouse,EVE Online,left,down,250,250')
print exec_cmd(s, 'mouse,EVE Online,left,up,250,250')
print exec_cmd(s, 'screenshot,EVE Online,2.png')

s.send("quit")
s.close()
