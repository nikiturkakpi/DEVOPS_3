#include <iostream>
#include <cassert>
#include <cmath>
#include "../FuncA.h"

void testFuncA() {
    FuncA func;

    // Test case 1: x = 0.0, n = 10
    assert(func.solve(0.0, 10) == 0.0);

    // Test case 2: x = 0.5, n = 10
    double result = func.solve(0.5, 10);
    double expected = std::asin(0.5); // Значення arcsin(0.5)
    assert(std::abs(result - expected) < 0.0001);

    // Test case 3: x = -0.5, n = 15
    result = func.solve(-0.5, 15);
    expected = std::asin(-0.5); // Значення arcsin(-0.5)
    assert(std::abs(result - expected) < 0.0001);

    std::cout << "All tests were successfully completed" << std::endl;
}


int main() {
    testFuncA();
    return 0;
}
