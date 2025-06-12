/* 
 * P4 Blackjack Simulator
 *
 * Need 4 bits for cards value 2-10, J, Q, K, A 
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
 * |      P         |       4        |     Version    |     Op        |
 * +----------------+----------------+----------------+---------------+
 * |   Card 1   |   Card 2   |   Card 3   |   Card 4  |   Card 5  |   |
 * +----------------+----------------+----------------+---------------+
 * |   Card 6   |   Card 7   |   Card 8   |   Card 9  |   Card 10 |   |
 * +----------------+----------------+----------------+---------------+
 * |   Card 11  |   Card 12  |   Card 13  |   Card 14 |   Card 15 |   |
 * +----------------+----------------+----------------+---------------+
 *
 * P is an ASCII Letter 'P' (0x50)
 * 4 is an ASCII Letter '4' (0x34)
 * Version is currently 0.1 (0x01)
 * Op is an operation to Perform:
 *	'Hit'
 *	'Stand'
 
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


header blackjack_t {
/*TODO*/

}













/*
 * All headers, used in the program needs to be assembled into a single struct.
 * We only need to declare the type, but there is no need to instantiate it,
 * because it is done "by the architecture", i.e. outside of P4 functions
 */
struct headers {
    ethernet_t   ethernet;
    blackjack_t     blackjack;
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
    action send_back(bit<32> result) {
        /* TODO
         * - put the result back in hdr.blackjack.res
         * - swap MAC addresses in hdr.ethernet.dstAddr and
         *   hdr.ethernet.srcAddr using a temp variable
         * - Send the packet back to the port it came from
             by saving standard_metadata.ingress_port into
             standard_metadata.egress_spec
         
         hdr.blackjack.res = result;
         */
         bit<48> tmp_mac;
         tmp_mac = hdr.ethernet.dstAddr;
         hdr.ethernet.dstAddr = hdr.ethernet.srcAddr;
         hdr.ethernet.srcAddr = tmp_mac;
         standard_metadata.egress_spec = standard_metadata.ingress_port;
    }

    action operation_hit() {
        /* TODO call send_back with operand_a + operand_b */
        send_back();       
    }

    action operation_stand() {
        /* TODO call send_back with operand_a - operand_b */
        send_back();
    }

        action operation_drop() {
        mark_to_drop(standard_metadata);
    }

    table calculate {
        key = {
            hdr.blackjack.op        : exact;
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
