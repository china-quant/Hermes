#include <iostream>
#include <vector>
#include <fstream>
#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <string.h>
#include "level2.h"

using namespace std;

int main()
{
  vector<Level2Data> data;

  ifstream fin;
  fin.open("test.csv");
  while (true)
  {
    char line[2048];
    fin.getline(line, sizeof(line));

    if (line[0] == '\0')
      break;

    data.push_back(Level2Data(string(line)));
  }

  fin.close();

  ofstream fout;
  fout.open("result.csv");

  int numOfLines = data.size();
  for (int i = 0; i < numOfLines; ++i) {
    fout << data[i].toCsv() << endl;
  }

  fout.close();

  return 0;
}
