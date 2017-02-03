#pragma once

#include "BWPerceptionManagementPolicy.h"
#include <list>

namespace PerceptionManagement {

	/**
	 *
	 */
	class DPGPolicy: public BWPerceptionManagementPolicy {
	public:
		/**
		 * Destructor
		 */
		virtual ~DPGPolicy();

		/**
		 * Updates the current perception based on a BW-REQ
		 * @param req BW-REQ
		 */
		virtual void newBWREQReceived (const bw_req_header_t& req);

		/**
		 * Return the current bandwidth perception of a given SS
		 * @param peer SS form which get the BW perception
		 * @return The bandwidth perception of the given peer in bytes
		 */
		virtual int getPeerBWNeeds (PeerNode * peer);

		/**
		 * Update the bandwidth perception of a given SS
		 * @param peer SS to update
		 * @param value the update value in bytes. If the value is negative then the current perception is decreased.
		 */
		virtual void updateSSPerception (PeerNode * peer,int value);

		/**
		 * Update the bandwidth perception of a given Connection
		 * @param cid CID of the connection to update
		 * @param value the update value in bytes. If the value is negative then the current perception is decreased.
		 */
		virtual void updateConnectionPerception (int cid,int value);
	private:
		std::map<int,std::list<int> > peerReqUpManager;
	};

}
