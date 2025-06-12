/* 
 * P4 Blackjack Simulator
 *
 * Need 4 bits for cards value 0, 2-10, J, Q, K, A 
 * Total = 14 (high/low Ace)
 * Need 2 bits for suit ♣(0x2663) ♦(0x2662) ♥(0x2665) ♠(0x2660)
 *
 * This program implements a simple protocol. It can be carried over Ethernet
 * (Ethertype 0x1234).
 *
 * The Protocol header looks like this:
 *
 *        0                1                  2              3
 * +----------------+----------------+----------------+---------------+
 * |      P         |       4        |     Version    |Ply_cnt|Del_cnt|
 * +----------------+----------------+----------------+---------------+
 * |   Card 1   |   Card 2   |   Card 3   |   Card 4  |  Card 5  |mve |
 * +----------------+----------------+----------------+---------------+
 * |   Card 6   |   Card 7   |   Card 8   |   Card 9  |  Card 10 |Bust|
 * +----------------+----------------+----------------+---------------+
 * |   Card 11  |   Card 12  |   Card 13  |   Card 14 |  Card 15 |res |
 * +----------------+----------------+----------------+---------------+
 *
 * P is an ASCII Letter 'P' (0x50)
 * 4 is an ASCII Letter '4' (0x34)
 * Version is currently 0.1 (0x01)
 * Op is an operation to Perform:
 
 * Ch is the operation of:
 *	'Hit'
 *	'Stand'
 * Bust stores if either player busts
 */
 
#include <core.p4>
#include <v1model.p4>


/*
 * Standard Ethernet header
 */
header ethernet_t {
    bit<48> dstAddr;
    bit<48> srcAddr;
    bit<16> etherType;
}

const bit<16> BLACKJACK_ETYPE = 0x1234;
const bit<8>  BLACKJACK_P     = 0x50;   // 'P'
const bit<8>  BLACKJACK_4     = 0x34;   // '4'
const bit<8>  BLACKJACK_VER   = 0x01;   // v0.1

const bit<6>  SPADE_A         = 0x01;
const bit<6>  SPADE_2         = 0x02;
const bit<6>  SPADE_3         = 0x03;
const bit<6>  SPADE_4         = 0x04;
const bit<6>  SPADE_5         = 0x05;
const bit<6>  SPADE_6         = 0x06;
const bit<6>  SPADE_7         = 0x07;
const bit<6>  SPADE_8         = 0x08;
const bit<6>  SPADE_9         = 0x09;
const bit<6>  SPADE_T         = 0x0a;
const bit<6>  SPADE_J         = 0x0b;
const bit<6>  SPADE_Q         = 0x0c;
const bit<6>  SPADE_K         = 0x0d;

const bit<6>  HEART_A         = 0x11;
const bit<6>  HEART_2         = 0x12;
const bit<6>  HEART_3         = 0x13;
const bit<6>  HEART_4         = 0x14;
const bit<6>  HEART_5         = 0x15;
const bit<6>  HEART_6         = 0x16;
const bit<6>  HEART_7         = 0x17;
const bit<6>  HEART_8         = 0x18;
const bit<6>  HEART_9         = 0x19;
const bit<6>  HEART_T         = 0x1a;
const bit<6>  HEART_J         = 0x1b;
const bit<6>  HEART_Q         = 0x1c;
const bit<6>  HEART_K         = 0x1d;

const bit<6>  DIAM_A          = 0x21;
const bit<6>  DIAM_2          = 0x22;
const bit<6>  DIAM_3          = 0x23;
const bit<6>  DIAM_4          = 0x24;
const bit<6>  DIAM_5          = 0x25;
const bit<6>  DIAM_6          = 0x26;
const bit<6>  DIAM_7          = 0x27;
const bit<6>  DIAM_8          = 0x28;
const bit<6>  DIAM_9          = 0x29;
const bit<6>  DIAM_T          = 0x2a;
const bit<6>  DIAM_J          = 0x2b;
const bit<6>  DIAM_Q          = 0x2c;
const bit<6>  DIAM_K          = 0x2d;

const bit<6>  CLUB_A          = 0x31;
const bit<6>  CLUB_2          = 0x32;
const bit<6>  CLUB_3          = 0x33;
const bit<6>  CLUB_4          = 0x34;
const bit<6>  CLUB_5          = 0x35;
const bit<6>  CLUB_6          = 0x36;
const bit<6>  CLUB_7          = 0x37;
const bit<6>  CLUB_8          = 0x38;
const bit<6>  CLUB_9          = 0x39;
const bit<6>  CLUB_T          = 0x3a;
const bit<6>  CLUB_J          = 0x3b;
const bit<6>  CLUB_Q          = 0x3c;
const bit<6>  CLUB_K          = 0x3d;

const bit<6>  null            = 0x00;

header blackjack_t {
/*TODO*/
    bit<8>  p;
    bit<8>  four;
    bit<8>  ver;
    
    bit<4>  player_count;
    bit<4>  dealer_count;
    
    bit<2>  move;
    bit<2>  bust;
    bit<2>  res; 
    
    bit<6>  card1;
    bit<6>  card2;
    bit<6>  card3;
    bit<6>  card4;
    bit<6>  card5;
    bit<6>  card6;
    bit<6>  card7;
    bit<6>  card8;
    bit<6>  card9;
    bit<6>  card10;
    bit<6>  card11;
    bit<6>  card12;
    bit<6>  card13;
    bit<6>  card14;
    bit<6>  card15;
}



/*
 * All headers, used in the program needs to be assembled into a single struct.
 * We only need to declare the type, but there is no need to instantiate it,
 * because it is done "by the architecture", i.e. outside of P4 functions
 */
struct headers {
    ethernet_t   ethernet;
    blackjack_t  blackjack;
}

/*
 * All metadata, globally used in the program, also  needs to be assembled
 * into a single struct. As in the case of the headers, we only need to
 * declare the type, but there is no need to instantiate it,
 * because it is done "by the architecture", i.e. outside of P4 functions
 */

struct metadata {
    /* In our case it is empty */
}

/*************************************************************************
 ***********************  P A R S E R  ***********************************
 *************************************************************************/
parser MyParser(packet_in packet,
                out headers hdr,
                inout metadata meta,
                inout standard_metadata_t standard_metadata) {
    state start {
        packet.extract(hdr.ethernet);
        transition select(hdr.ethernet.etherType) {
            BLACKJACK_ETYPE : check_blackjack;
            default      : accept;
        }
    }

    state check_blackjack {
        /* TODO: just uncomment the following parse block */
        
        transition select(packet.lookahead<blackjack_t>().p,
        packet.lookahead<blackjack_t>().four,
        packet.lookahead<blackjack_t>().ver) {
            (BLACKJACK_P, BLACKJACK_4, BLACKJACK_VER) : parse_blackjack;
            default                          : accept;
        }
        
    }

    state parse_blackjack {
        packet.extract(hdr.blackjack);
        transition accept;
    }
}

/*************************************************************************
 ************   C H E C K S U M    V E R I F I C A T I O N   *************
 *************************************************************************/
control MyVerifyChecksum(inout headers hdr,
                         inout metadata meta) {
    apply { }
}

/*************************************************************************
 **************  I N G R E S S   P R O C E S S I N G   *******************
 *************************************************************************/
control MyIngress(inout headers hdr,
                  inout metadata meta,
                  inout standard_metadata_t standard_metadata) {
    action send_back(bit<2> result, bit<2> bust) {
        /* TODO
         * - put the result back in hdr.blackjack.res
         * - swap MAC addresses in hdr.ethernet.dstAddr and
         *   hdr.ethernet.srcAddr using a temp variable
         * - Send the packet back to the port it came from
             by saving standard_metadata.ingress_port into
             standard_metadata.egress_spec
         */
         hdr.blackjack.res = result;
         hdr.blackjack.bust = bust;
         
         bit<48> tmp_mac;
         tmp_mac = hdr.ethernet.dstAddr;
         hdr.ethernet.dstAddr = hdr.ethernet.srcAddr;
         hdr.ethernet.srcAddr = tmp_mac;
         standard_metadata.egress_spec = standard_metadata.ingress_port;
    }

    action operation_hit() {
        /* TODO call send_back with an extra card for the player */
        new_card()
        
         
        send_back();       
    }

    action operation_stand() {
        /* TODO call send_back with dealers hand and result */
        send_back();
    }
    
    action new_card(num) {
        bit<6> tmp_suit
        bit<6> tmp_card
        
        modify_field_rng_uniform(tmp_suit,1,4)
        modify_field_rng_uniform(tmp_card,1,13)
        
        shift_left(tmp_suit,tmp_suit,4)
        bit_or(tmp_card,tmp_suit,tmp_card)
        
        if tmp_card == card1
            new_card(num)
            else if tmp_card == card2
            new_card(num)
            else if tmp_card == card3
            new_card(num)
            else if tmp_card == card4
            new_card(num)
            else if tmp_card == card5
            new_card(num)
            else if tmp_card == card6
            new_card(num)
            else if tmp_card == card7
            new_card(num)
            else if tmp_card == card8
            new_card(num)
            else if tmp_card == card9
            new_card(num)
            else if tmp_card == card10
            new_card(num)
            else if tmp_card == card11
            new_card(num)
            else if tmp_card == card12
            new_card(num)
            else if tmp_card == card13
            new_card(num)
            else if tmp_card == card14
            new_card(num)
            else if tmp_card == card15
            new_card(num) 
                
        if num == 1
        	hdr.blackjack.card1 = tmp_card
        	else if num == 2
        	new_card(1)
        	hdr.blackjack.card2 = tmp_card
        	else if num == 3
        	hdr.blackjack.card3 = tmp_card
        	else if num == 4
        	hdr.blackjack.card4 = tmp_card
        	else if num == 5
        	hdr.blackjack.card5 = tmp_card
        	else if num == 6
        	hdr.blackjack.card6 = tmp_card
        	else if num == 7
        	hdr.blackjack.card7 = tmp_card
        	else if num == 8
        	hdr.blackjack.card8 = tmp_card
        	else if num == 9
        	hdr.blackjack.card9 = tmp_card
        	else if num == 10
        	hdr.blackjack.card10 = tmp_card
        	else if num == 11
        	hdr.blackjack.card11 = tmp_card
        	else if num == 12
        	hdr.blackjack.card12 = tmp_card
        	else if num == 13
        	hdr.blackjack.card13 = tmp_card
        	else if num == 14
        	hdr.blackjack.card14 = tmp_card
        	else if num == 15
        	hdr.blackjack.card15 = tmp_card   
    }
    
    action check_sum_player(num) {
    	bit<5>
    	if num =< 2
    	    
    	    else if num == 3
    	    
    }

        action operation_drop() {
        mark_to_drop(standard_metadata);
    }

    table calculate {
        key = {
            hdr.blackjack.choice      : exact;
        }
        actions = {
            operation_hit;
            operation_stand;
         }
         
        const default_action = operation_drop();
        const entries = {
            BLACKJACK_PLUS : operation_hit();
            BLACKJACK_MINUS: operation_stand();
            
        }
    }

    apply {
        if (hdr.blackjack.isValid()) {
            calculate.apply();
        } else {
            operation_drop();
        }
    }
}


/*************************************************************************
 ****************  E G R E S S   P R O C E S S I N G   *******************
 *************************************************************************/
control MyEgress(inout headers hdr,
                 inout metadata meta,
                 inout standard_metadata_t standard_metadata) {
    apply { }
}

/*************************************************************************
 *************   C H E C K S U M    C O M P U T A T I O N   **************
 *************************************************************************/

control MyComputeChecksum(inout headers hdr, inout metadata meta) {
    apply { }
}

/*************************************************************************
 ***********************  D E P A R S E R  *******************************
 *************************************************************************/
control MyDeparser(packet_out packet, in headers hdr) {
    apply {
        packet.emit(hdr.ethernet);
        packet.emit(hdr.blackjack);
    }
}

/*************************************************************************
 ***********************  S W I T T C H **********************************
 *************************************************************************/

V1Switch(
MyParser(),
MyVerifyChecksum(),
MyIngress(),
MyEgress(),
MyComputeChecksum(),
MyDeparser()
) main;
