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

#define NUM_PREPROCESSOR_STR 14
char *preprocessors[]={(char *)"define",
                       (char *)"include",
                       (char *)"undef",
                       (char *)"pragma",
                       (char *)"if",
                       (char *)"error",
                       (char *)"warning",
                       (char *)"else",
                       (char *)"elseif",
                       (char *)"elif",
                       (char *)"endif",
                       (char *)"ifdef",
                       (char *)"ifndef",
                       (char *)"ifdefine"};

bool is_letter(char ch)
{
  if((ch>='a' && ch<='z') || (ch>='A' && ch<='Z'))
    return true;
  else
    return false;
}

bool is_number(char ch, char next)
{
  if((ch>='0' && ch<='9') || (ch=='-' && is_number(next)))
    return true;
  else
    return false;
}

bool move(char* from, char* to)
{
  if(rename(from,to))
    return false;
  else
    return true;
}

bool is_whitespace(char c)
{
  return ((c==' ' || c=='\t') ? true : false);
}

bool contain_preprocessor(char* str)
{
  int x, y;
  bool ret=false;

  for(x=0; x<((signed)strlen(str)-DEFINE_SEARCH_PRECISION); x++)
  {
    for(y=0; y<NUM_PREPROCESSOR_STR; y++)
    {
      if(!strncasecmp((str+x),preprocessors[y],((strlen(str)-x)>strlen(preprocessors[y]) ? strlen(preprocessors[y]) : (strlen(str)-x))))
        return true; // identified as a preprocessor, return true
    }
    if(!ret && !is_whitespace(*(str+x))) // preprocessor not found, and current char is not whitespace so this isnt a preprocessor
        return false;
  }

  return ret;
}

char last_non_whitespace(char* string, int start)
{
  int x;
  if(start>0) // start from inside array and work backwards
  {
    for(x=start; x; x--)
    {
      if(!is_whitespace(string[x]))
        return string[x];
    }
  }
  else // start from beginning and work forwards
  {
    for(x=0; x<(signed)strlen(string); x++)
    {
      if(!is_whitespace(string[x]))
        return string[x];
    }
  }
  return 'x';
}
