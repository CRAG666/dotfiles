// Date:  {{_date_}}
// Autor: {{_author_}}
// Email: {{_email_}}

#include <iostream>
using namespace std;

void duplicate(int *num) { *num *= 2; }

int main() {
  int x = 5;

  duplicate(&x);

  // Ahora x = 10
  return 0;
}
