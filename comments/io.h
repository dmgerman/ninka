/*
**  This program is free software; you can redistribute it and/or modify
**  it under the terms of the GNU General Public License as published by
**  the Free Software Foundation; either version 2 of the License, or
**  (at your option) any later version.
**
**  This program is distributed in the hope that it will be useful,
**  but WITHOUT ANY WARRANTY; without even the implied warranty of
**  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
**  GNU General Public License for more details.
**
**  You should have received a copy of the GNU General Public License
**  along with this program; if not, write to the Free Software
**  Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
*/

#ifndef IO_H
#define IO_H

#include "main.h"

class io
{
  private:
  int input_line, input_column, output_line, output_column, buf_count;
  int inComment;
  int inCode;
  int outputRegions;
  double icounter, iglobal_counter, ocounter, oglobal_counter;
  bool ready;
  ifstream i;
  ofstream o;
  ofstream co;

  public:
  char i_name[FILE_NAME_LENGTH], o_name[FILE_NAME_LENGTH],c_name[FILE_NAME_LENGTH];
  char buf[BUF_LENGTH], last_written[LAST_WRITTEN_LENGTH],
           last_read[LAST_READ_LENGTH];
  // io source/destination modifications
  bool input_from_stdin, output_to_stdout,
       first_init, file_open;
  int addMarkers;
  int regionsCount;
  int doneOutput;

  io(char* in, char* out, char *comments, bool testing=false);
  io();
  ~io();
  void init(char* in, char* out, char *comments, bool testing=false);
  void done(bool testing=false);
  int get_input_line();
  int get_input_column();
  int get_output_line();
  int get_output_column();
  int in();
  bool data_waiting();
  double input_bytes();
  double output_bytes();
  double global_input_bytes();
  double global_output_bytes();
  void out(char c='\0');
  void commentOut(char c='\0');
  bool ok();
};

#endif
