#include "FuncA.h"
#include <cmath>

double FuncA::solve(double x, int n) {
    double sum = 0.0;

    for (int i = 0; i < n; ++i) {
        double factorial_2n = 1;
        for (int j = 1; j <= 2 * i; ++j) {
            factorial_2n *= j;
        }

        double factorial_n = 1;
        for (int j = 1; j <= i; ++j) {
            factorial_n *= j;
        }

        double term = (factorial_2n / (std::pow(4, i) * factorial_n * factorial_n * (2 * i + 1))) * std::pow(x, 2 * i + 1);

        sum += term;
    }

    return sum;
}