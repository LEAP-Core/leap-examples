//
// Copyright (c) 2014, Intel Corporation
// All rights reserved.
//
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions are met:
//
// Redistributions of source code must retain the above copyright notice, this
// list of conditions and the following disclaimer.
//
// Redistributions in binary form must reproduce the above copyright notice,
// this list of conditions and the following disclaimer in the documentation
// and/or other materials provided with the distribution.
//
// Neither the name of the Intel Corporation nor the names of its contributors
// may be used to endorse or promote products derived from this software
// without specific prior written permission.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
// AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
// IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
// ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
// LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
// CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
// SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
// INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
// CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
// ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
// POSSIBILITY OF SUCH DAMAGE.
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
