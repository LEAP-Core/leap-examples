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
// @file edit-distance.cpp
// @brief Edit Distance App
//
// @author Daniel Lustig
//

#include <cstdlib>
#include <iostream>
#include <cassert>
#include <sstream>
#include <stack>
#include "li.hpp"

/**
 * EditDistance workload written in libLI.
 *
 * Given two strings S and T, calculate the edit distance between them.
 * e.g., for the example strings S="SHESELLS" and T="SEASHELLS", the 
 * editDistance is 3.  The set of operations that results in this score is
 *
 * SHES ELLS
 * SEASHELLS
 *  ^^ ^
 *  SS I
 */

char s[] = "SHESELLS";
char t[] = "SEASHELLS";
const int M = sizeof(s);
const int N = sizeof(t);

const int INSERT_COST = 1;
const int DELETE_COST = 1;
const int SUBSTITUTE_COST = 1;

class Module
{
	public:
		Module();

	protected:
		li::LINC_SEND<std::string> debug_messages;

		#define DEBUG_MSG(_msg) \
		{ \
			std::stringstream ss; \
			ss << _msg; \
			debug_messages.Enqueue(ss.str()); \
		}
};

/**
 * Each EditDistanceCell calculates the score as the minimum of
 *    s == t -> diag
 *    s != t -> left + INSERT_COST
 *              top  + DELETE_COST
 *              diag + SUBST_COST,
 *     then sends score, s, and t out on the appropriate channels.
 */
class EditDistanceCell
{
	public:
		EditDistanceCell(int x, int y);

		li::LINC_SEND<char> s_out;
		li::LINC_SEND<char> t_out;
		li::LINC_SEND<int> score_out_right;
		li::LINC_SEND<int> score_out_diag;
		li::LINC_SEND<int> score_out_down;

		li::LINC_RECV<char> s_in;
		li::LINC_RECV<char> t_in;
		li::LINC_RECV<int> score_in_top;
		li::LINC_RECV<int> score_in_diag;
		li::LINC_RECV<int> score_in_left;

	private:
		li::Scheduler<EditDistanceCell> *scheduler;

		li::LINC_SEND<std::string> debug_messages;

		bool canCalculate() const;
		void doCalculate();
		
		bool canOriginate() const;
		void doOriginate();
		
		int x;
		int y;
};

/**
 * Feeder takes in a stream of values, sends the first to data_out, sends a
 * predetermined score value to two output LINCs (one for right/down and one
 * for diag), and sends the rest to its stream_out LINC.
 */
template <class T>
class Feeder
{
	public:
		typedef std::pair<bool, T> bool_plus_T;

		Feeder(int score);

		li::LINC_RECV<bool_plus_T> stream_in;
		li::LINC_SEND<bool_plus_T> stream_out;
		li::LINC_SEND<T> data_out;
		li::LINC_SEND<int> score_out;
		li::LINC_SEND<int> score_out_diag;

	protected:
		li::Scheduler<Feeder> *scheduler;

		bool CanSendFirst() const;
		void DoSendFirst();

		bool CanSendOther() const;
		void DoSendOther();

		li::LINC_SEND<std::string> debug_messages;

		bool sent_first;
		int score;
};

/**
 * ZeroSender has the simple job of feeding a zero to the score input of
 * cells[0][0].score_in_diag.  This input isn't fed by either set of feeders.
 */
class ZeroSender
{
	public:
		ZeroSender();

		li::LINC_SEND<int> score_out;

	protected:
		li::Scheduler<ZeroSender> *scheduler;

		bool CanSendFirst() const;
		void DoSendFirst();
};

/**
 * OutputCell receives the final output score value and then prints a report
 * of the calculation
 */
class OutputCell
{
	public:
		OutputCell();

		li::LINC_RECV<int> score_in;

	private:
		li::Scheduler<OutputCell> *scheduler;

		li::LINC_SEND<std::string> message_out;

		bool canReceive() const;
		void doReceive();
};

/**
 * Definition of the actual workload context.  We inherit from the standard
 * libli context, and we only need to implement Elaborate().
 */
class EditDistanceWorkload : public li::StandardContext
{
	public:
		void Elaborate();
};

void EditDistanceWorkload::Elaborate()
{
	// Declare all of the modules we will use
	Feeder<char> *s_feeders[M];
	Feeder<char> *t_feeders[N];
	ZeroSender *zero_sender;
	EditDistanceCell *cells[N][M];
	OutputCell *output;
	li::ReadStreamer<char> *s_streamer, *t_streamer;

	// Instantiate all of the modules
	for (int m = 0; m < M; m++)
	{
		for (int n = 0; n < N; n++)
		{
			if (n == 0) // first column
				s_feeders[m] = new Feeder<char>(m);
			if (m == 0) // first row
				t_feeders[n] = new Feeder<char>(n);
			cells[n][m] = new EditDistanceCell(n, m);
		}
	}
	zero_sender = new ZeroSender();
	output = new OutputCell();
	s_streamer = new li::ReadStreamer<char>(s, sizeof(s));
	t_streamer = new li::ReadStreamer<char>(t, sizeof(t));

	// Connect the streamers
	li::Connect(s_streamer->data, s_feeders[0]->stream_in);
	li::Connect(t_streamer->data, t_feeders[0]->stream_in);

	// Connect the first cell
	li::Connect(zero_sender->score_out, cells[0][0]->score_in_diag);

	// Connect the first column
	for (int m = 0; m < M; m++)
	{
		li::Connect(s_feeders[m]->data_out, cells[0][m]->s_in);
		li::Connect(s_feeders[m]->score_out, cells[0][m]->score_in_left);
		if (m != M-1)
		{
			li::Connect(s_feeders[m]->stream_out, s_feeders[m+1]->stream_in);
			li::Connect(s_feeders[m]->score_out_diag,
					cells[0][m+1]->score_in_diag);
		}
	}

	// Connect the first row
	for (int n = 0; n < N; n++)
	{
		li::Connect(t_feeders[n]->data_out, cells[n][0]->t_in);
		li::Connect(t_feeders[n]->score_out, cells[n][0]->score_in_top);
		if (n != N-1)
		{
			li::Connect(t_feeders[n]->stream_out, t_feeders[n+1]->stream_in);
			li::Connect(t_feeders[n]->score_out_diag,
					cells[n+1][0]->score_in_diag);
		}
	}

	// Connect the rest of the grid
	for (int m = 0; m < M; m++)
	{
		for (int n = 0; n < N; n++)
		{
			// Check if we are in the last row
			if (m < M-1)
			{
				// If not in the last row
				li::Connect(cells[n][m]->score_out_down,
						cells[n][m+1]->score_in_top);
				li::Connect(cells[n][m]->t_out, cells[n][m+1]->t_in);
			}

			// Check if we are in the last column
			if (n < N-1)
			{
				// If not in the last column
				li::Connect(cells[n][m]->score_out_right,
						cells[n+1][m]->score_in_left);
				li::Connect(cells[n][m]->s_out, cells[n+1][m]->s_in);
			}

			// Check if we are in the last row and last column
			if (m < M-1 && n < N-1)
			{
				// If not at the last corner
				li::Connect(cells[n][m]->score_out_diag,
						cells[n+1][m+1]->score_in_diag);
			}
		}
	}

	li::Connect(cells[N-1][M-1]->score_out_diag, output->score_in);
}

/**
 * Instantiate an EditDistanceWorkload and set it as the global libli context
 */
EditDistanceWorkload workload;
li::Context *li::context = &workload;

/******************************************************************************/
// Implementation                                                             //
/******************************************************************************/

template <class T>
Feeder<T>::Feeder(int score) : sent_first(false), score(score)
{
	scheduler = new li::StaticPriorityScheduler<Feeder>(this);
	scheduler->RegisterRule(&Feeder::CanSendFirst, &Feeder::DoSendFirst);
	scheduler->RegisterRule(&Feeder::CanSendOther, &Feeder::DoSendOther);

	li::Name(debug_messages, "STDERR");
}

template <class T>
bool Feeder<T>::CanSendFirst() const
{
	return !sent_first && !stream_in.IsEmpty() && !data_out.IsFull() &&
		!score_out.IsFull() && !score_out_diag.IsFull();
}

template <class T>
void Feeder<T>::DoSendFirst()
{
	bool_plus_T head = stream_in.Peek();
	data_out.Enqueue(head.second);
	score_out.Enqueue(score);
	score_out_diag.Enqueue(score);
	stream_in.Dequeue();

	sent_first = true;
	DEBUG_MSG("Feeder " << score << " did SendFirst");
}

template <class T>
bool Feeder<T>::CanSendOther() const
{
	return sent_first && !stream_in.IsEmpty() && !stream_out.IsFull();
}

template <class T>
void Feeder<T>::DoSendOther()
{
	bool_plus_T head = stream_in.Peek();
	if (head.first)
	{
		scheduler->Finish();
		DEBUG_MSG("Feeder " << score << " did SendOther and finished");
	}
	else
	{
		stream_out.Enqueue(head);
		DEBUG_MSG("Feeder " << score << " did SendOther");
	}
	stream_in.Dequeue();
}

/******************************************************************************/

ZeroSender::ZeroSender()
{
	scheduler = new li::StaticPriorityScheduler<ZeroSender>(this);
	scheduler->RegisterRule(&ZeroSender::CanSendFirst, &ZeroSender::DoSendFirst);
}

bool ZeroSender::CanSendFirst() const
{
	return !score_out.IsFull();
}

void ZeroSender::DoSendFirst()
{
	score_out.Enqueue(0);
	scheduler->Finish();
}

/******************************************************************************/

EditDistanceCell::EditDistanceCell(int x, int y) : x(x), y(y)
{
	scheduler = new li::StaticPriorityScheduler<EditDistanceCell>(this);
	scheduler->RegisterRule(&EditDistanceCell::canCalculate,
			&EditDistanceCell::doCalculate);

	li::Name(debug_messages, "STDERR");
}

bool EditDistanceCell::canCalculate() const
{
	return !s_in.IsEmpty() && !t_in.IsEmpty() &&
		!score_in_top.IsEmpty() && !score_in_diag.IsEmpty() &&
		!score_in_left.IsEmpty() &&
		!s_out.IsFull() && !t_out.IsFull() &&
		!score_out_down.IsFull() && !score_out_diag.IsFull() &&
		!score_out_right.IsFull();
}

void EditDistanceCell::doCalculate()
{
	int match_cost = score_in_diag.Peek();
	int subst_cost = score_in_diag.Peek() + SUBSTITUTE_COST;
	int ins_cost = score_in_left.Peek() + INSERT_COST;
	int del_cost = score_in_top.Peek() + DELETE_COST;

	// If S and T are equal
	if (s_in.Peek() == t_in.Peek())
	{
		score_out_down.Enqueue(match_cost);
		score_out_diag.Enqueue(match_cost);
		score_out_right.Enqueue(match_cost);

		//parents.Enqueue(make_triple(x, y, 'M'));
		//scores.Enqueue(make_triple(x, y, match_cost));

		DEBUG_MSG("doCalculate (" << x << ", " << y << ") " <<
			"s=" << s_in.Peek() << " t=" << t_in.Peek() <<
			" score_in_left,diag,top=" << score_in_left.Peek() << "," <<
			score_in_diag.Peek() << "," << score_in_top.Peek() << "," <<
			" match: " << match_cost);
	}
	else // if S and T are not equal
	{
		int score = std::min(std::min(ins_cost, del_cost), subst_cost);
		char parent =
			(score == subst_cost ? 'S' :
			 score == ins_cost ? 'I' :
			 score == del_cost ? 'D' : 'E');

		score_out_down.Enqueue(score);
		score_out_diag.Enqueue(score);
		score_out_right.Enqueue(score);

		DEBUG_MSG("doCalculate (" << x << ", " << y << ") " <<
			"s=" << s_in.Peek() << " t=" << t_in.Peek() <<
			" score_in_left,diag,top=" << score_in_left.Peek() << "," <<
			score_in_diag.Peek() << "," << score_in_top.Peek() << "," <<
			" no match: " << parent << ": " << score);
	}

	// Write the results to the output channels
	s_out.Enqueue(s_in.Peek());
	t_out.Enqueue(t_in.Peek());

	s_in.Dequeue();
	t_in.Dequeue();
	score_in_top.Dequeue();
	score_in_diag.Dequeue();
	score_in_left.Dequeue();

	scheduler->Finish();
}

/******************************************************************************/

OutputCell::OutputCell()
{
	scheduler = new li::StaticPriorityScheduler<OutputCell>(this);
	scheduler->RegisterRule(&OutputCell::canReceive, &OutputCell::doReceive);

	li::Name(message_out, "STDOUT");
}

bool OutputCell::canReceive() const
{
	return !score_in.IsEmpty() && !message_out.IsFull();
}

void OutputCell::doReceive()
{
	std::stringstream s;
	s << "Final score is " << score_in.Peek() << std::endl;
	message_out.Enqueue(s.str());

	/*
	score.Dequeue();

	// Print the (score, parent) matrix
	std::cout << "    ";
	for (int x = 0; x < N; x++)
	{
		std::cout << t[x] << "  ";
	}
	std::cout << '\n';
	for (int y = 1; y <= M; y++)
	{
		std::cout << s[y - 1] << "  ";
		for (int x = 1; x <= N; x++)
		{
			std::cout << (*scores_)[y][x] << (*parents_)[y][x] << " ";
		}
		std::cout << '\n';
	}

	// Print the backtrace
	int x = N;
	int y = M;

	std::stack<char> trace;

	while (x > 0 && y > 0)
	{
		char step = (*parents_)[y][x];
		trace.push(step);

		std::cout << "(" << x << ", " << y << "): " << step << std::endl;

		if (x == 1)
		{
			y--;
		}
		else if (y == 1)
		{
			x--;
		}
		else if (step == 'M' || step == 'S')
		{
			x--;
			y--;
		}
		else if (step == 'I')
		{
			x--;
		}
		else if (step == 'D')
		{
			y--;
		}
		else
		{
			std::cout << "Unknown parent value " << step << std::endl;
			x--;
			y--;
		}
	}

	// Print S
	for (int i = 0; i < M; i++)
		std::cout << s[i];
	std::cout << '\n';

	// Print T
	for (int i = 0; i < N; i++)
		std::cout << t[i];
	std::cout << '\n';

	// Print the trace
	while(!trace.empty())
	{
		char c = trace.top();
		std::cout << (c == 'M' ? ' ' : c);
		trace.pop();
	}
	std::cout << std::endl;
	*/

	li::Quiesce();
}

