# Echo client program
import socket

def exec_cmd(s, cmd):
    data = ''
    s.send(cmd)
    while True:
        r = s.recv(1024)
        if len(r) == 0:
            break
        data = data+r
        if r[-1] == '}':
            break
    return data
    
HOST = 'localhost'
PORT = 50008
s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
s.connect((HOST, PORT))
data = exec_cmd(s, 'screenshot,e.png');
s.send("quit")
s.close()
