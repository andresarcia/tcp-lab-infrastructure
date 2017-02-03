#include "iDDAPolicy.h"

///A Paltrinieri Debug
//#include "Log/logger.h"
///////////


namespace PerceptionManagement {

	iDDAPolicy::~iDDAPolicy() {

	}

	void iDDAPolicy::updateSSPerception (PeerNode * peer,int value) {
		//Nothing to do here in this policy
	}

	void iDDAPolicy::updateConnectionPerception (int cid,int value) {
		this->trafficManagementTable[cid] += value;
		if (this->trafficManagementTable[cid] <0)
			this->trafficManagementTable[cid] = 0;

		/////A Paltrinieri DEBUG
		//apaltrinieri::logger::getInstance()->write<<"UPDATE CONNECTION PERCEPTION - NEW VALUE "<<this->trafficManagementTable[cid]<<std::endl<<std::flush;
		/////
	}

}
