/*
 * BWPerceptionManagementPolicy.h
 *
 *  Created on: Feb 10, 2009
 *      Author: A Paltrinieri
 */

#pragma once

#include <map>
#include "mac802_16pkt.h"
#include "connectionmanager.h"
#include "peernode.h"

namespace PerceptionManagement {

	/**
	 * Abstract class that manage the BS bandwidth perception of the SSs needs
	 */
	class BWPerceptionManagementPolicy {
	public:

		/**
		 * Constructor
		 */
		BWPerceptionManagementPolicy() {
			connectionManager_ = NULL;
		}

		/**
		 * Destructor
		 */
		virtual ~BWPerceptionManagementPolicy();

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
		virtual void updateSSPerception (PeerNode * peer,int value) = 0;

		/**
		 * Update the bandwidth perception of a given Connection
		 * @param cid CID of the connection to update
		 * @param value the update value in bytes. If the value is negative then the current perception is decreased.
		 */
		virtual void updateConnectionPerception (int cid,int value) = 0;

		void setConnectionManager (ConnectionManager * connManager) {
			connectionManager_ = connManager;
		}

	protected:
		/**
		 * Map which holds the bandwidth perceptions needs of the SSs
		 */
		std::map</*ID*/int,/*BW (bytes)*/int>	trafficManagementTable;
		ConnectionManager * connectionManager_;
	};

}
