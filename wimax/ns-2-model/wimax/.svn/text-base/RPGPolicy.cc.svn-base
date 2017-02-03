#include "RPGPolicy.h"

///A Paltrinieri Debug
//#include "Log/logger.h"
///////////


namespace PerceptionManagement {

	RPGPolicy::~RPGPolicy() {

	}

	void RPGPolicy::updateSSPerception (PeerNode * peer,int value) {

		if (peer->getBasic(IN_CONNECTION))
			trafficManagementTable[peer->getBasic(IN_CONNECTION)->get_cid()] = 0;

		if (peer->getPrimary(IN_CONNECTION))
			trafficManagementTable[peer->getPrimary(IN_CONNECTION)->get_cid()] = 0;

		if (peer->getSecondary(IN_CONNECTION))
			trafficManagementTable[peer->getSecondary(IN_CONNECTION)->get_cid()] = 0;

		if (peer->getInData())
			trafficManagementTable[peer->getInData()->get_cid()] = 0;

		/////A Paltrinieri DEBUG
		//apaltrinieri::logger::getInstance()->write<<"PERCEPTION RESET "<<this->getPeerBWNeeds(peer)<<std::endl<<std::flush;
		/////

	}

	void RPGPolicy::updateConnectionPerception (int cid,int value) {
		//Nothing to do here in this policy
	}

}
