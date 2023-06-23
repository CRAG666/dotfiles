// Date:  {{_date_}}
// Autor: {{_author_}}
// Email: {{_email_}}

#include <iostream>
using namespace std;

void findMinMax(const int *arr, int size, int *min, int *max) {
  *min = *max = arr[0];

  for (int i = 1; i < size; i++) {
    if (arr[i] < *min) {
      *min = arr[i];
    }
    if (arr[i] > *max) {
      *max = arr[i];
    }
  }
}

int main() {
  int numbers[] = {5, 2, 9, 1, 7};
  int minValue, maxValue;

  findMinMax(numbers, sizeof(numbers) / sizeof(numbers[0]), &minValue,
             &maxValue);

  // minValue = 1, maxValue = 9
  return 0;
}
