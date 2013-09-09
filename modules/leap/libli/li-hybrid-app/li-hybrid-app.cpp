//
// Copyright (C) 2013 Intel Corporation
//
// This program is free software; you can redistribute it and/or
// modify it under the terms of the GNU General Public License
// as published by the Free Software Foundation; either version 2
// of the License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program; if not, write to the Free Software
// Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
//

//
// @file li-hybrid-app.cpp
// @brief LI Hybrid App
//
// @author Michael Pellauer
//

#include "awb/provides/connected_application.h"

// constructor
CONNECTED_APPLICATION_CLASS::CONNECTED_APPLICATION_CLASS(VIRTUAL_PLATFORM vp)
{
}

// destructor
CONNECTED_APPLICATION_CLASS::~CONNECTED_APPLICATION_CLASS()
{
}

void CONNECTED_APPLICATION_CLASS::Init()
{
	if (!li::context)
		exit(1);

	// Have the library connect any named LINCs, and validate the result
	li::Elaborate();

	// Perform the user-defined instantiation and connections
	li::Route();
}

void CONNECTED_APPLICATION_CLASS::Main()
{
	// Launch the module schedulers, and run until the workload completes
	li::Execute();
        
        // Wait for hardware to finish (if it's not done already)
        STARTER_DEVICE_CLASS::GetInstance()->WaitForHardware();
        return;
}
