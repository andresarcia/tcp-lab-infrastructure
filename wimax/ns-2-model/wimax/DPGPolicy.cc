#include "DPGPolicy.h"

#include <algorithm>
///A Paltrinieri Debug
//#include "Log/logger.h"
///////////


namespace PerceptionManagement {

	DPGPolicy::~DPGPolicy() {

	}

	void DPGPolicy::newBWREQReceived (const bw_req_header_t& req) {

		assert(connectionManager_);
		int peerAddr = connectionManager_->get_connection(req.cid, IN_CONNECTION)->getPeerNode()->getAddr();

		if ( (req.type & 0x7) == 0x001) {
			 //aggregate
		     //Reset the BW every two Req from the same CID --> Aggregate emulation from CID to Peers
			std::list<int>::const_iterator exist;
			exist = std::find( peerReqUpManager[peerAddr].begin(), peerReqUpManager[peerAddr].end(), req.cid);

			if ( exist != peerReqUpManager[peerAddr].end() ) {
		    	trafficManagementTable[peerAddr] = (req.br & 0x7FFFF); //masks 19 bits
		    	peerReqUpManager[peerAddr].clear();
			} else {
				trafficManagementTable[peerAddr] += (req.br & 0x7FFFF);
				peerReqUpManager[peerAddr].push_back(req.cid);
			}
		} else if ( (req.type & 0x7) == 0x000) {
			 //incremental
			 trafficManagementTable[peerAddr] += (req.br & 0x7FFFF);
		}

		/////A Paltrinieri DEBUG
		//apaltrinieri::logger::getInstance()->write<<"NEW BW-REQ "<<" SIZE: "<<req.br<<" NEW-TMT-VALUE: "<<trafficManagementTable[req.cid]<<std::endl<<std::flush;
		/////

	}

	int DPGPolicy::getPeerBWNeeds (PeerNode * peer) {
		/////A Paltrinieri DEBUG
		//apaltrinieri::logger::getInstance()->write<<"GET PERCEPTION "<<trafficManagementTable[peer->getAddr()]<<std::endl<<std::flush;
		/////
		return trafficManagementTable[peer->getAddr()];
	}

	void DPGPolicy::updateSSPerception (PeerNode * peer,int value) {

		trafficManagementTable[peer->getAddr()] += value;
		if (trafficManagementTable[peer->getAddr()]<0)
			trafficManagementTable[peer->getAddr()]=0;
		/////A Paltrinieri DEBUG
		//apaltrinieri::logger::getInstance()->write<<"UPDATE PERCEPTION NEW VALUE "<<trafficManagementTable[peer->getAddr()]<<std::endl<<std::flush;
		/////
	}

	void DPGPolicy::updateConnectionPerception (int cid,int value) {
		//Nothing to do here in this policy
	}

}
