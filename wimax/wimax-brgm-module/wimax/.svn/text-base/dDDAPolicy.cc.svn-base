#include "dDDAPolicy.h"

///A Paltrinieri Debug
#include "Log/logger.h"
///////////


namespace PerceptionManagement {

	dDDAPolicy::~dDDAPolicy() {

	}

	void dDDAPolicy::newBWREQReceived (const bw_req_header_t& req) {
		/////A Paltrinieri DEBUG
		if ( (req.type & 0x7) == 0x001)
			apaltrinieri::logger::getInstance()->write<<"AGGREGATE";
		else
			apaltrinieri::logger::getInstance()->write<<"INCREMENTAL";
		apaltrinieri::logger::getInstance()->write<<"NEW BW-REQ "<<" SIZE: "<<req.br<<std::endl<<std::flush;
		/////
		delayedRequest.push_back(req);
	}

	int dDDAPolicy::getPeerBWNeeds (PeerNode * peer) {

		/////A Paltrinieri DEBUG
		apaltrinieri::logger::getInstance()->write<<"PROCESING DELAYED REQ"<<std::endl<<std::flush;
		/////

		if (!delayedRequest.empty()) {
			std::list<bw_req_header_t>::const_iterator iterador;
			for (iterador = delayedRequest.begin(); iterador != delayedRequest.end(); iterador++) {
				BWPerceptionManagementPolicy::newBWREQReceived(*iterador);
			}
			delayedRequest.clear();
		}

		return BWPerceptionManagementPolicy::getPeerBWNeeds(peer);
	}

	void dDDAPolicy::updateSSPerception (PeerNode * peer,int value) {
		//Nothing to do here in this policy
	}

	void dDDAPolicy::updateConnectionPerception (int cid,int value) {
		this->trafficManagementTable[cid] += value;
		if (this->trafficManagementTable[cid]<0)
			this->trafficManagementTable[cid]=0;
		/////A Paltrinieri DEBUG
		apaltrinieri::logger::getInstance()->write<<"UPDATE CONNECTION PERCEPTION "<<this->trafficManagementTable[cid]<<std::endl<<std::flush;
		/////
	}

}
