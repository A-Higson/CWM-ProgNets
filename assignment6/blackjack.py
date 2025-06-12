#!/usr/bin/env python3

import re

from scapy.all import *

class P4blackjack(Packet):
    name = "P4blackjack"
    fields_desc = [ StrFixedLenField("P", "P", length=1),
                    StrFixedLenField("Four", "4", length=1),
                    XByteField("version", 0x01),
                    StrFixedLenField("op", "+", length=1),
                    IntField("card1", 0),
                    IntField("card2", 0),
                    IntField("card3", 0),
                    IntField("card4", 0),
                    IntField("card5", 0),
                    IntField("card6", 0),
                    IntField("card7", 0),
                    IntField("card8", 0),
                    IntField("card9", 0),
                    IntField("card10", 0),
                    IntField("card11", 0),
                    IntField("card12", 0),
                    IntField("card13", 0),
                    IntField("card14", 0),
                    IntField("card15", 0),
                    IntField("Player_count", 2),
                    IntField("Dealer_count", 15),
                    IntField("result", 0xDEADBABE)]

bind_layers(Ether, P4blackjack, type=0x1234)

class NumParseError(Exception):
    pass

class OpParseError(Exception):
    pass

class Token:
    def __init__(self,type,value = None):
        self.type = type
        self.value = value

if Player_count
