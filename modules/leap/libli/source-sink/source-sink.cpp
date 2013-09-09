/*****************************************************************************
 *
 * @author daniel.j.lustig,11339344
 *
 * Copyright (c) 2013 Intel Corporation, all rights reserved.
 * THIS PROGRAM IS AN UNPUBLISHED WORK FULLY PROTECTED BY COPYRIGHT LAWS AND
 * IS CONSIDERED A TRADE SECRET BELONGING TO THE INTEL CORPORATION.
 *
 *****************************************************************************/

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
