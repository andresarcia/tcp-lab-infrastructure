/*
 * logger.h
 *
 *  Created on: Nov 4, 2008
 *      Author: drworm
 */

#ifndef LOGGER_H_
#define LOGGER_H_

#include <iostream>
#include <fstream>

namespace apaltrinieri {

class logger {
public:
	virtual ~logger();

	static logger* getInstance ();
	std::ofstream write;

private:
	logger();
};

}

#endif /* LOGGER_H_ */
