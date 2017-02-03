#pragma once

#include "BWPerceptionManagementPolicy.h"
#include <list>

namespace PerceptionManagement {

	/**
	 *
	 */
	class iDDAPolicy: public BWPerceptionManagementPolicy {
	public:
		/**
		 * Destructor
		 */
		virtual ~iDDAPolicy();

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

	};

}
