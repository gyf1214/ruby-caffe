#ifndef __SOLVER
#define __SOLVER

#include <caffe/caffe.hpp>

typedef caffe::Solver<float> Solver;
typedef caffe::SolverRegistry<float> SolverRegistry;

void Init_solver(void);

#endif
