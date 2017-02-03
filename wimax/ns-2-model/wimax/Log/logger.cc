/*
 * logger.cpp
 *
 *  Created on: Nov 4, 2008
 *      Author: drworm
 */

#include "logger.h"

namespace apaltrinieri {

logger::~logger() {
	write.close();
}

logger* logger::getInstance () {
	static logger instance;
	return &instance;
}


logger::logger() {
	write.open ("UlSubFrameDebug.txt");
}

}
