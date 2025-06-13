#!/usr/bin/env python3

import re

from scapy.all import *

class P4blackjack(Packet):
    name = "P4blackjack"
    fields_desc = [ StrFixedLenField("P", "P", length=1),
                    StrFixedLenField("Four", "4", length=1),
                    XByteField("version", 0x01),
                    StrFixedLenField("move", "hit", length=1),
                    XByteField("card1", 0x00),
                    XByteField("card2", 0x00),
                    XByteField("card3", 0x00),
                    XByteField("card4", 0x00),
                    XByteField("card5", 0x00),
                    XByteField("card6", 0x00),
                    XByteField("card7", 0x00),
                    XByteField("card8", 0x00),
                    XByteField("card9", 0x00),
                    XByteField("card10", 0x00),
                    XByteField("card11", 0x00),
                    XByteField("card12", 0x00),
                    XByteField("card13", 0x00),
                    XByteField("card14", 0x00),
                    XByteField("card15", 0x00),
                    IntField("Player_count", 2),
                    IntField("Dealer_count", 15),
                    IntField("res", 0xDEADBABE),
                    IntField("bust", 0xDEADBABE)]

bind_layers(Ether, P4blackjack, type=0x1234)

class NumParseError(Exception):
    pass

class Token:
    def __init__(self,type,value = None):
        self.type = type
        self.value = value

def move_parser(s, i, ts):
    pattern = "^\s*(['hit' 'stand']+)\s*"
    match = re.match(pattern,s[i:])
    if match:
        ts.append(Token('move', match.group(1)))
        return i + match.end(), ts
    raise NumParseError('Expected response is hit or stand.')


def make_seq(p1, p2):
    def parse(s, i, ts):
        i,ts2 = p1(s,i,ts)
        return p2(s,i,ts2)
    return parse


def get_if():
    ifs=get_if_list()
    iface= "enx0c37965f8a22" # "h1-eth0"
    #for i in get_if_list():
    #    if "eth0" in i:
    #        iface=i
    #        break;
    #if not iface:
    #    print("Cannot find eth0 interface")
    #    exit(1)
    #print(iface)
    return iface
    
def main():

    p = make_seq(num_parser, make_seq(op_parser,num_parser))
    s = ''
    #iface = get_if()
    iface = "enx0c37965f8a22"

    while True:
        s = input('> ')
        if s == "quit":
            break
        print(s)
        try:
            i,ts = p(s,0,[])
            pkt = Ether(dst='00:04:00:00:00:00', type=0x1234) / P4blackjack(move=ts[0].value)

            pkt = pkt/' '

            #pkt.show()
            resp = srp1(pkt, iface=iface,timeout=5, verbose=False)
            if resp:
                blackjack=resp[P4blackjack]
                
                if blackjack.res == 0
                	
                else if blackjack.res == 1
                	if blackjack.bust == 2
                		print('Dealer busts')
                    print('You Win!')
                else if blackjack.res == 2
                	if blackjack.bust == 1
                		print("You're Bust")
                	print('You Lose')
                else if blackjack.res == 3
                	print('Draw')
                	
                else:
                    print("cannot find P4blackjack header in the packet")
            else:
                print("Didn't receive response")
        except Exception as error:
            print(error)


if __name__ == '__main__':
    main()


