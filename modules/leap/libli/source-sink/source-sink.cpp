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
// @file source-sink.cpp
// @brief LI Source/Sink App
//
// @author Daniel Lustig
//

#include <cstdlib>
#include <iostream>
#include <cassert>
#include <sstream>
#include <set>
#include "linc.hpp"
#include "module.hpp"

/******************************************************************************/

class Source : public li::Module<Source>
{
	public:
		Source();
		li::LINC_SEND<int> out;
	protected:
		bool canSend() const;
		void doSend();
		bool sent_once;
};

Source::Source() : sent_once(false)
{
	registerRule(&Source::canSend, &Source::doSend);
}

bool Source::canSend() const
{
	return !sent_once;
}

void Source::doSend()
{
	std::cout << "Sending" << std::endl;
	out.enqueue(1);
	sent_once = true;
}

/******************************************************************************/

class Sink : public li::Module<Sink>
{
	public:
		Sink(li::LINC_SEND<int> &_in);
	private:
		li::LINC_RECV<int> *in;
	public:
		bool canSink() const;
		void doSink();
};

Sink::Sink(li::LINC_SEND<int> &_in) : in(_in)
{
	registerRule(&Sink::canSink, &Sink::doSink);
}

bool Sink::canSink() const
{
	return !in->isEmpty();
}

void Sink::doSink()
{
	std::cout << "Sink received " << in->peek() << std::endl;
	in->dequeue();
	li::globally_finished = true;
}

/******************************************************************************/

int main(int argc, char *argv[])
{
	Source source;
	Sink   sink(source.out);

	source.spawn();
	sink.spawn();

	li::run();
}
