#include "BWPerceptionManagementPolicy.h"

///A Paltrinieri Debug
#include "Log/logger.h"
///////////

namespace PerceptionManagement {

	BWPerceptionManagementPolicy::~BWPerceptionManagementPolicy() {

	}

	void BWPerceptionManagementPolicy::newBWREQReceived (const bw_req_header_t& req) {

		if ( (req.type & 0x7) == 0x001) {
			 //aggregate
		     trafficManagementTable[req.cid] = (req.br & 0x7FFFF); //masks 19 bits
		     //apaltrinieri::logger::getInstance()->write<<"AGGREGATE";
		  } else if ( (req.type & 0x7) == 0x000) {
			  //incremental
			  trafficManagementTable[req.cid] += (req.br & 0x7FFFF);
			  //apaltrinieri::logger::getInstance()->write<<"INCREMENTAL";
		  }

		/////A Paltrinieri DEBUG
		apaltrinieri::logger::getInstance()->write<<" NEW BW-REQ "<<" SIZE: "<<(req.br & 0x7FFFF)<<" NEW-TMT-VALUE: "<<trafficManagementTable[req.cid]<<std::endl<<std::flush;
		/////
	}

	int BWPerceptionManagementPolicy::getPeerBWNeeds (PeerNode * peer) {
		int bw=0;
		if (peer->getBasic(IN_CONNECTION)!= NULL) {
			bw += trafficManagementTable[peer->getBasic(IN_CONNECTION)->get_cid()];
		}
		if (peer->getPrimary(IN_CONNECTION)!= NULL) {
			bw += trafficManagementTable[peer->getPrimary(IN_CONNECTION)->get_cid()];
		}
		if (peer->getSecondary(IN_CONNECTION)!= NULL) {
			bw += trafficManagementTable[peer->getSecondary(IN_CONNECTION)->get_cid()];
		}
		if (peer->getInData()!=NULL) {
			bw += trafficManagementTable[peer->getInData()->get_cid()];
		}

		/////A Paltrinieri DEBUG
		apaltrinieri::logger::getInstance()->write<<"GET PERCEPTION "<<bw<<std::endl<<std::flush;
		/////

		return bw;
	}

}
