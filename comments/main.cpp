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


#include "main.h"
#include "dformat.h"
#include <sys/time.h>
#include <sys/resource.h>

#define MSG_PRE "main()"

int main(int argc, char** argv)
{
  dformat dformat(argc,argv);
  struct rlimit Limit;

  Limit.rlim_cur = 10;
  Limit.rlim_max = 10;
  if (setrlimit(RLIMIT_CPU, &Limit) == -1) {
    perror("eror");
    exit(1);
  }
  /*
  getrlimit(RLIMIT_CPU, &Limit);
  cerr << Limit.rlim_cur << "\n";
  cerr << Limit.rlim_max << "\n";
  */
  if(!dformat.ok())
  {
#ifdef DEBUG
    cerr << "main() - dformat not ok." << endl;
#endif
    return 1;
  }

  while(dformat.next())
  {
    dformat.format();
    dformat.done();
  }

  if(!dformat.ok())
  {
    cerr << MSG_PRE << " Errors occured while trying to complete requests."
	 << endl;
  }

  return 0;
}
