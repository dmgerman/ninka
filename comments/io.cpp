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
#define CLASS_ERROR_PRE "io"

io::io(char* in, char* out, char *comments, bool testing)
{
  file_open=false;
  first_init=true;
  init(in,out,comments, testing);
};

io::io()
{
  file_open=false;
  first_init=true;
  ready=false; // We didn't init a file, so we're not ready
};

io::~io() // Done, just take care of the files
{
  i.close();
  o.close();
  co.close();
};

// Initialize variables and set everything up for a new file
void io::init(char* in, char* out, char * comments, bool testing)
{
  if(file_open) // dumbo didn't call done()
    done(testing);

  ready=true; // we are ready unless otherwise changed

  // (re)init variables
  memset(buf,'\0',BUF_LENGTH);
  memset(last_written,'\0',LAST_WRITTEN_LENGTH);
  memset(last_read,'\0',LAST_READ_LENGTH);
  memset(o_name,'\0',FILE_NAME_LENGTH);
  memset(i_name,'\0',FILE_NAME_LENGTH);
  memset(c_name,'\0',FILE_NAME_LENGTH);
  icounter=0.0; ocounter=0.0;
  buf_count=0; // reset # of bytes in buffer
  if(first_init) // only on first init set global_counter to 0.0
  {
    first_init=false;
    iglobal_counter=0.0;
    oglobal_counter=0.0;
    addMarkers = 0;
    regionsCount = 0;
  }
  outputRegions = 0;
  input_line=0; input_column=0;
  inComment = -1;
  doneOutput = 0;
  inCode = -1;
  output_line=0; output_column=0;

//  removed because of strange bug causing input_from_stdin to always set to TRUE
//  if(!input_from_stdin)
//  {
    i.open(in/*, ios::nocreate*/);
    if(!i)
    {
      ready=false;
      cerr << "Could not open (input) [" << in << "]" << endl;
    }
#ifdef DEBUG
    else
      cerr << CLASS_ERROR_PRE << "::init() Opened (input) ["
           << in << "]" << endl;
#endif
//  }

  if(!output_to_stdout)
  {
    o.open(out);
    if(!o)
    {
      ready=false;
      cerr << CLASS_ERROR_PRE << "::init() Could not open (output) \""
           << out << "\"" << endl;
    }
    co.open(comments);
    if(!co)
    {
      ready=false;
      cerr << CLASS_ERROR_PRE << "::init() Could not open (comments) \""
           << comments << "\"" << endl;
    }

  }
  else
    output_to_stdout=true;

  strcpy(i_name,in);
  if(output_to_stdout){
    strcpy(o_name,"");
    strcpy(c_name,"");
  } else {
    strcpy(c_name,comments);
    strcpy(o_name,out);
  }

  file_open=true;
};

void io::done(bool testing)
{
  if(!file_open) // your calling me without a open file?
    return;

  // close the files
// removed next if because of strange bug causing input_from_stdin to be set when the code designates otherwise
//  if(!input_from_stdin)
    i.close();
    if(!output_to_stdout) {
    o.close();
    co.close();
    }
  file_open=false;
}

int io::get_input_line()
{
  return input_line;
}

int io::get_input_column()
{
  return input_column;
}

int io::get_output_line()
{
  return output_line;
}

int io::get_output_column()
{
  return output_column;
}

// Get data
int io::in()
{
  memmove((last_read+1),last_read,(LAST_READ_LENGTH-1));
  last_read[0]=buf[0];
  memmove(buf,(buf+1),(BUF_LENGTH-1));

  i.get(buf[(BUF_LENGTH-1)]); // get the next char
  if(i.eof()) // EOF found, cancel that last read
  {
    buf[(BUF_LENGTH-1)]='\0';
    if(buf[0] || buf_count==1) // if there is data at the front, then we erased some
      buf_count--;
  }
  else
    buf_count+=(buf_count<BUF_LENGTH ? (buf_count ? 1 : 2) : 0);

#ifdef IODEBUG
    if(!i.eof())
      cout << i_name << " >> \"" << buf[(BUF_LENGTH-1)] << "\"" << endl;
    else
      cout << CLASS_ERROR_PRE << "::in() " << i_name << " [EOF] " << buf[(BUF_LENGTH-1)] << endl;
#endif

  if(buf[0]=='\n' || buf[0]=='\r')
  {
    input_column=0;
    input_line++;
  }
  else
    input_column++;

  if(buf[(BUF_LENGTH-1)]!='\0')
  {
    icounter++;
    iglobal_counter++;
  }

  return 1;
};

// see if we still have data in the buffer
bool io::data_waiting()
{
  return (buf_count ? true : false);
};


// Output data
void io::out(char c)
{
  if(!c) // replace '\0' with the value of buf[0]
     c=buf[0];
  if(c) // Make sure we have something to spit
  {
    if (inCode == 0 && addMarkers) {
      if(output_to_stdout)
        cout << "/****/";
      else
        o << "/****/";
    }
    inCode = 1;
    // only reset code marker if not a space...
    if (c != ' ' && c!= '\t' &&c!= '\n' && c!= '\r')
      inComment = 0;
    if(output_to_stdout)
      cout << c;
    else
      o << c;

    // keep track of sizes
    ocounter++; // this file
    oglobal_counter++; // all the files
  }

#ifdef IODEBUG
    cout << o_name << " << \"" << c << "\"" << endl;
#endif

  if(c=='\n' || c=='\r') // new line, return column to 0
  {
    output_line++;
    output_column=0;
  }
  else
    output_column++;

  memmove(last_written,(last_written+1),(LAST_WRITTEN_LENGTH-1));
  last_written[(LAST_WRITTEN_LENGTH-1)]=c;
};

// Output data
void io::commentOut(char c)
{
  if (inComment == 0) {
    if (regionsCount > 0 && outputRegions+1 == regionsCount)  {
      doneOutput = 1;
      return;
    }
    if (addMarkers) {
      if(output_to_stdout)
        cerr << "\nCODE\n ";
      else
        co << "\nCODE\n";
    }
    outputRegions++;
  }

  inComment = 1;
  inCode = 0;
  if(!c) // replace '\0' with the value of buf[0]
     c=buf[0];
  if(output_to_stdout)
    cerr << c;
  else
    co << c;

};



bool io::ok()
{
  return (ready ? true : false);
};

double io::input_bytes()
{
  return icounter;
};

double io::output_bytes()
{
  return ocounter;
};

double io::global_input_bytes()
{
  return iglobal_counter;
};

double io::global_output_bytes()
{
  return oglobal_counter;
};
