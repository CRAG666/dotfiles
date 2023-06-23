// Date:  {{_date_}}
// Autor: {{_author_}}
// Email: {{_email_}}

#include <iostream>
using namespace std;

void swap(int *a, int *b) {
  int temp = *a;
  *a = *b;
  *b = temp;
}

int main() {
  int x = 5;
  int y = 10;

  swap(&x, &y);

  // Ahora x = 10, y = 5
  return 0;
}
