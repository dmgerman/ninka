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


/*
 * mangle.cpp - Removes ALL comments and/or formatting from C/C++ code while
 *              keeping what is needed so that the program still operates
 *              the same exact way as before the conversion.
 *
 * This program has been vigourously tested, if you find any logic errors
 * where something should have been taken out that wasn't, please email me
 * - mangle@biz0r.biz
 *
 */

#ifndef DFORMAT_H
#define DFORMAT_H
#include "main.h"

class dformat
{
  private:
  ::io io;
  int current_arg, current_file, argc;
  char** argv;
  bool ready, test_args, tabular_delimited_result, comma_delimited_result;
  // boolean variables used in the deformatting process
  bool append_newline, leave_newline, comments_only,
    keep_preprocessor_whitespace, no_modify;
  struct fhist {
    bool in_line_comment, in_star_comment, in_single_quote,
         in_double_quote, in_preprocessor, in_hex;
    int num_backslashes;
  } flag_history[FLAG_HISTORY_MAX];

  // Private functions
  bool load_arguments(char* str);
  void usage();
  void version();

  public:

  dformat(int argc, char** argv);
  ~dformat();
  bool next();
  void done();
  bool ok();
  bool format();
};

#endif
