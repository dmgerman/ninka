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
*
 * mangle.cpp - Removes ALL comments and/or formatting from C/C++ code while
 *              keeping what is needed so that the program still operates
 *              the same exact way as before the conversion.
 *
 */

#include "main.h"
#define CLASS_ERROR_PRE "dformat"

dformat::dformat(int a, char** av)
{
  ready=true; // We're ok unless otherwise changed
  current_arg=1; // Start at argument 1
  current_file=0;
  argc=a; argv=av;
  io.regionsCount = 0;
  io.doneOutput = 0;

  if(!load_arguments((char *)"-x")) cerr << "Programmer goofed, you should not see this. Error clearing out arguments." << endl;
  test_args=true; // Lets make sure the arg syntax is good first
  while(next()) ;

#ifdef DEBUG
  cerr << CLASS_ERROR_PRE << "::dformat() argument syntax ok." << endl;
#endif

  current_arg=1;
  io.done(test_args);
  test_args=false;
  // Clear out the settings
  if(!load_arguments((char *)"-x")) cerr << "Programmer goofed, you should not see this. Error clearing out arguments." << endl;
};

dformat::~dformat() {};

bool dformat::next()
{
  char temp[FILE_NAME_LENGTH]={"\0"};
  char temp2[FILE_NAME_LENGTH]={"\0"};

  if(!ready) // Can't work if I'm not ready.
    return false;

#ifdef DEBUG
  if(test_args)
    cerr << CLASS_ERROR_PRE << "::next() testing argument ["
         << argv[current_arg] << "]" << endl;
#endif

  if(current_arg<argc)
  {
    if(argv[current_arg][0]=='-') // we have args waiting
    {
      if((current_arg+1)<argc || argv[current_arg][1]=='v')
      {
        // load args and move to next
        if(!load_arguments(argv[current_arg++]))
        {
          usage();
          return false;
        }
      }
      else
      {
#ifdef DEBUG
	cerr << CLASS_ERROR_PRE << "::next() Argument included without a file." << endl;
#endif
	ready=false;
	usage();
	return false;
      }
    }

    io.done(test_args); // Finish it off if needed.
    
    strcpy(temp,argv[current_arg]);
    strcat(temp,DEFAULT_MANGLED_POSTFIX);
    strcpy(temp2,argv[current_arg]);
    strcat(temp2,DEFAULT_COMMENTS_POSTFIX);
    io.init(argv[current_arg],temp, temp2);
    
    if(!io.ok())
    {
#ifdef DEBUG
      cerr << CLASS_ERROR_PRE << "::next() io object not ok." << endl;
#endif
      ready=false;
      return false;
    }
    current_arg++; // Done messing with this one, move to next
  }
  else if(argc==1) // tisk tisk...you need atleast 2 arguments
  {
    usage();
    ready=false;
    return false;
  }
  else
    return false;

  if(!test_args)
    current_file++;

  return true; // all is good
};

void dformat::done()
{
  if(append_newline)
    io.out('\n');

  if(!tabular_delimited_result && !comma_delimited_result)
  {
    if (!io.output_to_stdout) {
      cerr << "[" << current_file << "] \"" << io.i_name << "\" (" << io.input_bytes() << "b) ";
      
      cerr << ">> \"" << io.o_name << "\" (" << io.output_bytes() << "b) (" << (100.0-(100.0*(io.output_bytes()/io.input_bytes()))) << "% reduced)";
      cerr << endl;
    }
  }
  else if(tabular_delimited_result) // print in tabular form
    cerr << current_file
         << "\t" << io.i_name
         << "\t" << io.o_name
         << "\t" << io.input_bytes()
         << "\t" << io.output_bytes()
         << "\t" << (100.0-(100.0*(io.output_bytes()/io.input_bytes())))
         << endl;
  else if(comma_delimited_result)
    cerr << current_file
         << "," << io.i_name
         << "," << io.o_name
         << "," << io.input_bytes()
         << "," << io.output_bytes()
         << "," << (100.0-(100.0*(io.output_bytes()/io.input_bytes())))
         << endl;

  io.done();
};

void dformat::usage()
{
  cerr << "Usage: " << NAME << " <options> [file1] <options> <file2> <etc>"
       << endl << "       -r            Leave CR/LF's"
       << endl << "       -o            output to STDOUT"
       << endl << "       -n            Append newline"
       << endl << "       -x            Use default options (nulls all previous ones)"
       << endl << "       -d            Leave in preprocessor whitespace"
    //       << endl << "       -w            Write over original"
//       << endl << "       -i            input from STDIN"
       << endl << "       -l            Do no mangling"
       << endl << "       -m            Do not add  markers to output"
       << endl << "       -t            Print summary in tab delimited form"
       << endl << "       -C            Print summary in comma delimited form"
       << endl << "       -v            Print version"
       << endl << "       -c<Number>    Number of comment regions"
       << endl;
}

bool dformat::ok()
{
  return (ready ? true : false);
};

bool dformat::load_arguments(char* str)
{
  if(strlen(str)==0)
    return false;

  for(unsigned int x=1; x<strlen(str); x++)
  {
    switch(str[x])
    {
      case 'x':
        io.input_from_stdin=false;
        io.output_to_stdout=false;
        io.addMarkers=true;
        io.regionsCount = 0;
        append_newline=false;
        comments_only=true;
        keep_preprocessor_whitespace=false;
        tabular_delimited_result=false;
        comma_delimited_result=false;
        leave_newline=false;
        no_modify=false;
        break;

#ifdef asdfasd
      case 'w':
        io.write_over_original=true;
        break;

#endif
      case 'm':
        io.addMarkers=false;
        break;

      case 'n':
        append_newline=true;
        break;
      case 'c':
        // next token should be an integer..
        {
          int i=1;
          char temp[256];
          while ((x+i < strlen(str)) &&
                 str[x+i] >= '0' &&
                 str[x+i] <= '9' &&
                 x+i < 256
                 ) {
            temp[i-1] = str[x+i];
            i++;
          }
          temp[i-1] =0;
          if (i == 1 || i > 255) {
            cerr << "Illegal number of comment regions for -c option" << i
                 << endl;
            exit(1);
          }
          io.regionsCount = atoi(temp);
          //          cerr << "Number of regions [" << io.regionsCount << "]" << endl;
          x+=i-1;
        }
        break;

      case 'r':
        leave_newline=true;
        break;

      case 'd':
        keep_preprocessor_whitespace=true;
        break;

      case 't':
        tabular_delimited_result=true;
        break;

      case 'C':
        comma_delimited_result=true;
        break;

      case 'v':
        version();
        exit(0);
        break;

      case 'l':
        no_modify=true;
        break;

      case 'o':
        io.output_to_stdout=true;
        break;

//      case 'i':
//        io.input_from_stdin=true;
//        break;

      default: // Unknown option
        usage();
        return false;
        break;
    }
  }
  return true;
};

// And now...the meat and potatos
bool dformat::format()
{
  int x=0;
  char c='\0';
  bool tbool=false;

#ifdef DEBUG
  cerr << CLASS_ERROR_PRE << "::format() Now formatting [" << io.i_name << "]"
       << endl;
#endif

  // Reset the variables
  for(x=0; x<FLAG_HISTORY_MAX; x++)
  {
    flag_history[x].in_single_quote=false;
    flag_history[x].in_double_quote=false; 
    flag_history[x].in_line_comment=false;
    flag_history[x].in_star_comment=false;
    flag_history[x].in_preprocessor=false;
    flag_history[x].in_hex=false;
    flag_history[x].num_backslashes=0;
  }

  // keep grabbing data as long as its there
  while(io.in() && io.data_waiting())
  {
    if (io.doneOutput) {
      break;
    }
    if(no_modify)
    {
      io.out();
      continue;
    }

    switch(io.buf[0])
    {
      case '\'':
      case '\"':
        if(!flag_history[0].in_line_comment && !flag_history[0].in_star_comment)
        {
          if(!flag_history[0].in_single_quote && !flag_history[0].in_double_quote)
          {
            if(io.buf[0]=='\'')
              flag_history[0].in_single_quote=true;
            else if(io.buf[0]=='\"')
              flag_history[0].in_double_quote=true;
          }
          else if(flag_history[0].in_single_quote || flag_history[0].in_double_quote)
          {
            if((flag_history[0].num_backslashes%2)) ; // just an escaped quote, reset number of backslashes
            else
            {
              if(io.buf[0]=='\'' && flag_history[0].in_single_quote)
                flag_history[0].in_single_quote=false;
              if(io.buf[0]=='\"' && flag_history[0].in_double_quote)
                flag_history[0].in_double_quote=false;
            }
          }
          io.out();

          flag_history[0].num_backslashes=0; // null out number of backslashes
          flag_history[0].in_hex=false; // we're not in a hex value anymore
        } else {
          io.commentOut(); //dmg
        }
        
      break;

      case '/':
        if(!flag_history[0].in_single_quote && !flag_history[0].in_double_quote)
        {
          if(io.buf[1]=='/' && !flag_history[0].in_line_comment && !flag_history[0].in_star_comment) {
            flag_history[0].in_line_comment=true;
            io.commentOut(); //dmg
          }
          else if(io.buf[1]=='*' && !flag_history[0].in_star_comment) {
            flag_history[0].in_star_comment=true;
            io.commentOut(); //dmg
          }
          else if(!flag_history[0].in_line_comment && !flag_history[0].in_star_comment)
            io.out();
          else 
            io.commentOut(); //dmg
        }
        else
          io.out();

        if(!flag_history[0].in_line_comment && !flag_history[0].in_star_comment)
        {
          flag_history[0].in_hex=false; // we're not in a hex value anymore
          flag_history[0].num_backslashes=0; // Null out number of backslashes
        }
      break;

      case '*':
        if(!flag_history[0].in_single_quote && !flag_history[0].in_double_quote)
        {
          if(io.buf[1]=='/' && flag_history[0].in_star_comment &&
             flag_history[2].in_star_comment)
          {
            io.commentOut(); 
            /* We need to write a \n after the comment... otherwise it gets very, very messy */

            flag_history[0].in_star_comment=false;
            io.in(); // Jump ahead one, we dont want the '/' used
            io.commentOut();
            io.commentOut('\n'); 
            continue;
          } else if(!flag_history[0].in_star_comment && !flag_history[0].in_line_comment) {
            io.out();
          } else {
            io.commentOut();
          }
        }
        else
          io.out();

        if(!flag_history[0].in_line_comment && !flag_history[0].in_star_comment)
        {
          flag_history[0].in_hex=false; // we're not in a hex value anymore
          flag_history[0].num_backslashes=0; // Null out number of backslashes
        }
      break;

      case '#':
        if(!flag_history[0].in_line_comment && !flag_history[0].in_star_comment)
        {
          if(!flag_history[0].in_single_quote && !flag_history[0].in_double_quote)
          {
            tbool=contain_preprocessor((io.buf+1));
            // Make sure we have the required carriage return before the preprocessor (if it really is a preprocessor)
            if(io.last_written[(LAST_WRITTEN_LENGTH-1)] &&
               (c=last_non_whitespace(io.last_written,(LAST_WRITTEN_LENGTH-1)))!='\r' && c!='\n' &&
               tbool)
              io.out('\n');

            if(tbool)
              flag_history[0].in_preprocessor=true;
          }
          io.out();
          flag_history[0].num_backslashes=0; // null out number of backslashes
          flag_history[0].in_hex=false; // we're not in a hex value anymore
        } else {
          io.commentOut();
        }
      break;

      case '\n':
      case '\r':
        if(!flag_history[0].in_star_comment)
        {
          if((((is_letter(io.last_written[(LAST_WRITTEN_LENGTH-1)]) || is_number(io.last_written[(LAST_WRITTEN_LENGTH-1)]) ||
                io.last_written[(LAST_WRITTEN_LENGTH-1)]=='_') &&
             (is_letter(io.buf[1]) || is_number(io.buf[1]) || io.buf[1]=='_'))
             || flag_history[0].in_preprocessor || io.buf[1]=='#') && !flag_history[0].in_single_quote &&
             !flag_history[0].in_double_quote && !comments_only)
          {
            if(flag_history[0].in_preprocessor)
            {
              if(io.last_written[(LAST_WRITTEN_LENGTH-1)]!='\\') // make sure its not multi-line
              {
                flag_history[0].in_preprocessor=false;
                io.out();
              }
              else if(io.last_written[(LAST_WRITTEN_LENGTH-1)]!=' ' && io.last_written[(LAST_WRITTEN_LENGTH-1)]!='\t' &&
                      !leave_newline)
                io.out(' '); // need atleast one space inbetween preprocessor items
              else
                io.out();
            }
            else if(io.buf[1]=='#')
            {
              if(io.last_written[(LAST_WRITTEN_LENGTH-1)]!='\0' && (io.last_written[(LAST_WRITTEN_LENGTH-1)]!='\r' &&
                 io.last_written[(LAST_WRITTEN_LENGTH-1)]!='\n'))
                io.out();
            }
            else
              io.out(' ');
          }
          else if(comments_only && !flag_history[0].in_line_comment)
            io.out();
          else if(leave_newline && !flag_history[0].in_line_comment)
            io.out();
          else if(flag_history[0].in_hex) // hex values need a space after them, so put a space in place of the crlf
          {
            io.out(' ');
            flag_history[0].in_hex=false; // not in the hex value anymore
          }
          else if(flag_history[0].in_single_quote || flag_history[0].in_double_quote)
            io.out();

          if(flag_history[0].in_line_comment && io.last_read[0]!='\\')
          {
            if(comments_only && (io.last_written[(LAST_WRITTEN_LENGTH-1)]!='\r' ||
                                 io.last_written[(LAST_WRITTEN_LENGTH-1)]!='\n')) {
              io.out();
              io.commentOut(); //dmg print end of line also
            }
            flag_history[0].in_line_comment=false;
          }

          if(!flag_history[0].in_line_comment)
          {
            flag_history[0].in_hex=false; // we're not in a hex value anymore
            flag_history[0].num_backslashes=0; // Null out number of backslashes
          }
        } else { // we are in a start ca
          io.commentOut();
#ifdef DUMPSPACES
          io.out();
#endif
        }
      break;

      case ' ':
      case '\t':
        if(!flag_history[0].in_line_comment && !flag_history[0].in_star_comment)
        {
          if(flag_history[0].in_single_quote || 
             flag_history[0].in_double_quote || 
             comments_only) { // the only cases where we always output all of them
            io.out(); 
          }
          else if( (flag_history[0].in_preprocessor || flag_history[0].in_hex) &&
                   ((io.last_written[(LAST_WRITTEN_LENGTH-1)]!='\n' && io.last_written[(LAST_WRITTEN_LENGTH-1)]!='\r') || 
                   (keep_preprocessor_whitespace && flag_history[0].in_preprocessor)))
          {
            /* preprocessors require atleast a single whitespace char preserved both in front and behind non-whitespace 
               characters. Hex values require a space afterwards. */
            if((!is_whitespace(io.last_written[(LAST_WRITTEN_LENGTH-1)]) && !is_whitespace(io.buf[1]) && 
                !(io.last_written[(LAST_WRITTEN_LENGTH-1)]=='#' && contain_preprocessor(io.buf)))
               || keep_preprocessor_whitespace) {
              io.out(); 
            } else {
              io.commentOut();
            }

            if(flag_history[0].in_hex) // get out of hex if we are in one
              flag_history[0].in_hex=false;
          }
          else if(((!is_whitespace(io.last_written[(LAST_WRITTEN_LENGTH-1)]) && (is_letter(io.last_written[(LAST_WRITTEN_LENGTH-1)])
                  || io.last_written[(LAST_WRITTEN_LENGTH-1)]=='_')) || is_number(io.last_written[(LAST_WRITTEN_LENGTH-1)]))
                  &&
                  (!is_whitespace(io.buf[1]) && ((is_letter(io.buf[1])
                                                 || io.buf[1]=='_') || is_number(io.buf[1]))) ) 
            io.out();  
          else if(!strncmp((io.buf+1),"...",3) || !strncmp((io.last_written+(LAST_WRITTEN_LENGTH-3)),"...",3))
            io.out(); // need space before (and after) these if already there
          else if(io.last_written[(LAST_WRITTEN_LENGTH-1)]=='/' && io.buf[1]=='*')
            io.out(); // preserve whitespace so that if the file is mangled again it isn't construed as the start of a comment
          else {
            io.commentOut();
          }
        } else {
          io.commentOut();
        }
      break;

      default:
        if(!flag_history[0].in_line_comment && !flag_history[0].in_star_comment)
        {
          // increase num_backslashes if this is a backslash, else set to 0
          flag_history[0].num_backslashes=(io.buf[0]=='\\' ? (flag_history[0].num_backslashes+1) : 0);

          // colons pre-separated by whitespace or a cr/lf still need separation (c++ specific)
          if(io.last_written[(LAST_WRITTEN_LENGTH-1)]==':' &&
             (is_whitespace(io.last_read[0]) || io.last_read[0]=='\r' || io.last_read[0]=='\n')
             && io.buf[0]==':')
            io.out(' ');

          if(io.buf[0]=='\\' && (io.buf[1]=='\n' || io.buf[1]=='\r') && !comments_only && !leave_newline)
          {
            flag_history[x].num_backslashes=0;
            io.in(); // skip over newline
          }
          else
          {
            // check to see if we are getting into a hex value as it needs a space after it
            if((!flag_history[0].in_single_quote && !flag_history[0].in_double_quote) &&
                io.buf[0]=='0' && (io.buf[1]=='x' || io.buf[1]=='X') && (is_letter(io.buf[2]) || is_number(io.buf[2])))
            flag_history[0].in_hex=true;

            io.out();
          }

          if(flag_history[0].in_hex && (!is_letter(io.buf[0]) && !is_number(io.buf[0])))
            flag_history[0].in_hex=false;
        } else {
          io.commentOut();
        }
      break;
    }

    // Remember the flags of previous iterations so we may reference them
    for(x=(FLAG_HISTORY_MAX-1); x; x--)
      flag_history[x]=flag_history[(x-1)];
  }

  return true;
}

void dformat::version()
{
  cerr << NAME << " v" << VERSION
#ifdef BETA
       << "b"
#endif
       << " by Jon Newman, and adapted by Daniel M. German, based on Mangle" << endl;
};
