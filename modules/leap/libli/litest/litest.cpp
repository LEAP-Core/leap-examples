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
// @file litest.cpp
// @brief LI Test App
//
// @author Daniel Lustig
//

#include <li.hpp>
#include <iostream>

/**
 * Workload: a simple test case demonstrating the use of libli.
 *
 * This workload connects four modules: Source, Forwarder, Forwarder, Sink.
 * The first generates a few messages, and the Forwarders pass them along.
 * The Sink converts the message into a string and passes it to a Printer
 * module (generated as part of a StandardContext), which prints the message
 * strings.
 *
 *                                              
 *  Workload Modules:                             Named LINC_SENDs
 *                                               
 *  /------\  /---------\  /---------\  /----\    ---------------
 *  |Source|->|Forwarder|->|Forwarder|->|Sink|---> "STDOUT" | | | - - - \
 *  \------/  \---------/  \---------/  \----/    ---------------
 *                 |            |                                        |
 *                 |            |                 ---------------
 *                 |            \----------------> "STDERR" | | | - - \  |
 *                 |                              ---------------
 *                 |                                                  |  |
 *                 |                              ---------------
 *                 \-----------------------------> "STDERR" | | | - - |  |
 *                                                ---------------    \|
 *                                                                    |  |
 *                           (connections with the same name merged)
 *                                                                    |  |
 *
 *       Connections made by the elaborator (by matching names)       / /
 *     /- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
 *       /- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - /
 *   /
 *     /
 *  |
 *    |
 *  |       Standard Ctx.      StandardContext
 *    |     Named LINC_RECVs   Modules: 
 *  |     
 *    \     ---------------    /-------\
 *  |   - -> "STDOUT" | | |--->|Printer|--> stdout
 *          ---------------    \-------/
 *  |
 *  \       ---------------    /-------\
 *    - - -> "STDERR" | | |--->|Printer|--> stderr
 *          ---------------    \-------/
 */

/**
 * Source: send 'initial_count' values to 'out'
 */
class Source
{
	public:
		// Constructor
		Source(int initial_count);

		// Externally-visible LINCs
		li::LINC_SEND<int> out;

	private:
		// Guards and Actions
		bool CanSend() const;
		void DoSend();

		// Private member variables
		int count;
};

/**
 * Forwarder: forward message from 'in' to 'out'
 */
class Forwarder
{
	public:
		// Constructor
		Forwarder();

		// Externally-visible LINCs
		li::LINC_SEND<int> out;
		li::LINC_RECV<int> in;
		
	private:
		// Guards and Actions
		bool CanForward() const;
		void DoForward();

		// Private LINCs
		li::LINC_SEND<std::string> debug;
};

/**
 * Sink: receive 'max' message and print them out (by forwarding them on to a
 *  Printer, via a named LINC)
 */
class Sink
{
	public:
		// Constructor
		Sink(int max);

		// Externally-visible LINCs
		li::LINC_RECV<int> in;

	private:
		// Guards and Actions
		bool CanSink() const;
		void DoSink();

		// Private LINCs
		li::LINC_SEND<std::string> messages;

		// Private member variables
		int count;
		int max;
};




/*
 * Definitions
 */

Source::Source(int initial_count) : count(initial_count)
{
	/* 's' is a Scheduler (in particular, a StaticPriorityScheduler) for a
	 * module of type 'Source' */
	li::Scheduler<Source> *s =
		new li::StaticPriorityScheduler<Source>(this);

	//Register a Guard+Action pair as a rule in the scheduler
	s->RegisterRule(&Source::CanSend, &Source::DoSend);
}

bool Source::CanSend() const
{
	// Guard: returns a bool, and cannot modify anything
	return !out.IsFull() && count > 0;
}

void Source::DoSend()
{
	// Action: Write at most once to each LINC_SEND, and update state
	out.Enqueue(count);
	count--;
}

Forwarder::Forwarder()
{
	/* 's' is a Scheduler (in particular, a StaticPriorityScheduler) for a
	 * module of type 'Forwarder' */
	li::Scheduler<Forwarder> *s =
		new li::StaticPriorityScheduler<Forwarder>(this);

	//Register a Guard+Action pair as a rule in the scheduler
	s->RegisterRule(&Forwarder::CanForward, &Forwarder::DoForward);

	/* Give LINC_SEND 'debug' the name "STDERR", and let the elaborator
	 * connect it (to the Printer defined in the StandardContext) */
	li::Name(debug, "STDERR");
}

bool Forwarder::CanForward() const
{
	// Guard: returns a bool, and cannot modify anything
	return !in.IsEmpty() && !out.IsFull();
}

void Forwarder::DoForward()
{
	// Action: Write at most once to each LINC_SEND, and update state
	debug.Enqueue("Forwarding a message");
	out.Enqueue(in.Peek());
	in.Dequeue();
}

Sink::Sink(int max) : count(0), max(max)
{
	/* 's' is a Scheduler (in particular, a StaticPriorityScheduler) for a
	 * module of type 'Sink' */
	li::Scheduler<Sink> *s =
		new li::StaticPriorityScheduler<Sink>(this);

	//Register a Guard+Action pair as a rule in the scheduler
	s->RegisterRule(&Sink::CanSink, &Sink::DoSink);

	/* Give LINC_SEND 'debug' the name "STDERR", and let the elaborator
	 * connect it (to the Printer defined in the StandardContext) */
	li::Name(messages, "STDOUT");
}

bool Sink::CanSink() const
{
	// Guard: returns a bool, and cannot modify anything
	return count < max && !in.IsEmpty();
}

void Sink::DoSink()
{
	// Action: Write at most once to each LINC_SEND, and update state

	// Generate a message based on the received value
	std::stringstream s;
	s << "Sink received " << in.Peek();
	in.Dequeue();

	// Send the message out
	messages.Enqueue(s.str());

	// Update the state
	count++;
	if (count >= max)
		li::Quiesce();
}




/*
 * Main
 */

/* li::StandardContext is a subclass of li::Context that provides some
 *  modules constructed by default, including
 *  - a Printer with named LINC_RECV "STDOUT"
 *  - a Printer with named LINC_RECV "STDERR"
 *
 *  Our job is to implement Elaborate()
 */
class MyContext : public li::StandardContext
{
	public:
		void Elaborate();
};

void MyContext::Elaborate()
{
	// Instantiate four modules
	Source *source = new Source(3);
	Forwarder *f1 = new Forwarder();
	Forwarder *f2 = new Forwarder();
	Sink *sink = new Sink(3);
	
	// Connect the modules together directly (as opposed to using names)
	li::Connect(source->out, f1->in);
	li::Connect(f1->out, f2->in);
	li::Connect(f2->out, sink->in);
}

/* Export our newly-defined context to libli by 1) instantiating it, and
 * 2) assigning it to the global variable li::context. */
MyContext ctx;
li::Context *li::context = &ctx;
