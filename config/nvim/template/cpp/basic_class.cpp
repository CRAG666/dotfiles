// Date:  {{_date_}}
// Autor: {{_author_}}
// Email: {{_email_}}

#include <iostream>
using namespace std;

class HelloWorld {
public:
    void sayHello() {
        cout << "Hola Mundo" << endl;
        {{_cursor_}}
    }
};

int main() {
    HelloWorld hello;
    hello.sayHello();
    return 0;
}
