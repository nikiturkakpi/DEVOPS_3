#include <iostream>
#include "FuncA.h"

int main() {
    FuncA object;

    double x = 2.0;
    int n = 5;

    std::cout << "Result of FuncA: " << object.solve(x, n) << std::endl;
    return 0;
}