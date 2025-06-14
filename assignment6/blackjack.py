#!/usr/bin/env python3

import re
import random
from scapy.all import *

class P4blackjack(Packet):
    name = "P4blackjack"
    fields_desc = [
        StrFixedLenField("P", "P", length=1),
        StrFixedLenField("Four", "4", length=1),
        XByteField("version", 0x01),
        BitField("move", 0x00, 2),
        BitField("card1", 0x00, 6),
        BitField("card2", 0x00, 6),
        BitField("card3", 0x00, 6),
        BitField("card4", 0x00, 6),
        BitField("card5", 0x00, 6),
        BitField("card6", 0x00, 6),
        BitField("card7", 0x00, 6),
        BitField("card8", 0x00, 6),
        BitField("card9", 0x00, 6),
        BitField("card10", 0x00, 6),
        BitField("card11", 0x00, 6),
        BitField("card12", 0x00, 6),
        BitField("card13", 0x00, 6),
        BitField("card14", 0x00, 6),
        BitField("card15", 0x00, 6),
        BitField("Player_count", 0, 4),
        BitField("Dealer_count", 0, 4),
        BitField("res", 0x0, 2),
        BitField("bust", 0xaa, 2)
    ]

bind_layers(Ether, P4blackjack, type=0x1234)

class NumParseError(Exception):
    pass

class Token:
    def __init__(self, type, value=None):
        self.type = type
        self.value = value

def move_parser(s, i, ts):
    pattern = "^\s*([0-9]+)\s*"
    match = re.match(pattern, s[i:])
    if match:
        ts.append(Token('move', match.group(1)))
        return i + match.end(), ts
    raise NumParseError('Expected response is hit or stand.')

def make_seq(p1, p2):
    def parse(s, i, ts):
        i, ts2 = p1(s, i, ts)
        return p2(s, i, ts2)
    return parse

def get_if():
    ifs = get_if_list()
    iface = "enx0c37965f8a22"  # Use a static iface for now
    return iface

def main():
    card_values = {
        0x01: "SPADE_A", 0x02: "SPADE_2", 0x03: "SPADE_3", 0x04: "SPADE_4",
        0x05: "SPADE_5", 0x06: "SPADE_6", 0x07: "SPADE_7", 0x08: "SPADE_8",
        0x09: "SPADE_9", 0x0a: "SPADE_T", 0x0b: "SPADE_J", 0x0c: "SPADE_Q", 0x0d: "SPADE_K",
        0x11: "HEART_A", 0x12: "HEART_2", 0x13: "HEART_3", 0x14: "HEART_4",
        0x15: "HEART_5", 0x16: "HEART_6", 0x17: "HEART_7", 0x18: "HEART_8",
        0x19: "HEART_9", 0x1a: "HEART_T", 0x1b: "HEART_J", 0x1c: "HEART_Q", 0x1d: "HEART_K",
        0x21: "DIAM_A", 0x22: "DIAM_2", 0x23: "DIAM_3", 0x24: "DIAM_4",
        0x25: "DIAM_5", 0x26: "DIAM_6", 0x27: "DIAM_7", 0x28: "DIAM_8",
        0x29: "DIAM_9", 0x2a: "DIAM_T", 0x2b: "DIAM_J", 0x2c: "DIAM_Q", 0x2d: "DIAM_K",
        0x31: "CLUB_A", 0x32: "CLUB_2", 0x33: "CLUB_3", 0x34: "CLUB_4",
        0x35: "CLUB_5", 0x36: "CLUB_6", 0x37: "CLUB_7", 0x38: "CLUB_8",
        0x39: "CLUB_9", 0x3a: "CLUB_T", 0x3b: "CLUB_J", 0x3c: "CLUB_Q", 0x3d: "CLUB_K"
    }

    new_card_values = {
        1: 0x01, 2: 0x02, 3: 0x03, 4: 0x04,
        5: 0x05, 6: 0x06, 7: 0x07, 8: 0x08,
        9: 0x09, 10: 0x0a, 11: 0x0b, 12: 0x0c, 13: 0x0d,
        14: 0x11, 15: 0x12, 16: 0x13, 17: 0x14,
        18: 0x15, 19: 0x16, 20: 0x17, 21: 0x18,
        22: 0x19, 23: 0x1a, 24: 0x1b, 25: 0x1c, 26: 0x1d,
        27: 0x21, 28: 0x22, 29: 0x23, 30: 0x24,
        31: 0x25, 32: 0x26, 33: 0x27, 34: 0x28,
        35: 0x29, 36: 0x2a, 37: 0x2b, 38: 0x2c, 39: 0x2d,
        40: 0x31, 41: 0x32, 42: 0x33, 43: 0x34,
        44: 0x35, 45: 0x36, 46: 0x37, 47: 0x38,
        48: 0x39, 49: 0x3a, 50: 0x3b, 51: 0x3c, 52: 0x3d
    }

    random_numbers = random.sample(range(1, 52), 15)

    p = move_parser
    s = ''
    iface = "enx0c37965f8a22"  # Static interface
    player_move = 0x00 
    counter = 0

    while True:
        s = input('Enter 0 to start HIT(1) STAND(2): ')
        if s == "quit":
            break
        print(s)
        try:
            pkt = Ether(dst='00:04:00:00:00:00', type=0x1234) / P4blackjack(
                move=int(s),
                card1=new_card_values[random_numbers[0]],
                card2=new_card_values[random_numbers[1]],
                card3=new_card_values[random_numbers[2]],
                card4=new_card_values[random_numbers[3]],
                card5=new_card_values[random_numbers[4]],
                card6=new_card_values[random_numbers[5]],
                card7=new_card_values[random_numbers[6]],
                card8=new_card_values[random_numbers[7]],
                card9=new_card_values[random_numbers[8]],
                card10=new_card_values[random_numbers[9]],
                card11=new_card_values[random_numbers[10]],
                card12=new_card_values[random_numbers[11]],
                card13=new_card_values[random_numbers[12]],
                card14=new_card_values[random_numbers[13]],
                card15=new_card_values[random_numbers[14]]
            )
            pkt = pkt / ' '
            resp = srp1(pkt, iface=iface, timeout=5, verbose=False)
            if resp:
                blackjack = resp[P4blackjack]
                if blackjack.res == 0:
                    #print("Player:")
                    if blackjack.Player_count >= 2 and blackjack.Player_count <= 11:
                        # Loop through each player's card based on Player_count
                        for i in range(1, blackjack.Player_count):  # Loop over each card number
                            card_field = getattr(blackjack, f"card{i}")  # Fetch card{i} dynamically
                            print(card_values[card_field])
                	#print("Dealer:")
                	if blackjack.Dealer_count >= 4 and blackjack.Dealer_count <= 15:
                        # Loop through each player's card based on Player_count
                        for i in range(1, 16 - blackjack.Dealer_count):  # Loop over each card number
                            card_field = getattr(blackjack, f"card{16-i}")  # Fetch card{i} dynamically
                            print(card_values[card_field])
                elif blackjack.res == 1:
                    if blackjack.bust == 2:
                        print('Dealer busts')
                    print('You Win!')
                elif blackjack.res == 2:
                    if blackjack.bust == 1:
                        print("You're Bust")
                    print('You Lose')
                elif blackjack.res == 3:
                    print('Draw')
                else:
                    print("Cannot find P4blackjack header in the packet")
            else:
                print("Didn't receive response")
        except Exception as error:
            print(error)

if __name__ == '__main__':
    main()

