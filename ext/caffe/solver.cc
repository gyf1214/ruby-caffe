#include "solver.hpp"
#include "net.hpp"
#include "util.hpp"
#include <iostream>
#include <rice/Data_Type.hpp>
#include <rice/Constructor.hpp>
#include <rice/String.hpp>

using namespace Rice;

struct SolverConstructor {
    static void construct(Object self, String path) {
        caffe::SolverParameter param;
        caffe::ReadSolverParamsFromTextFileOrDie(path.str(), &param);
        Solver *solver = SolverRegistry::CreateSolver(param);
        DATA_PTR(self.value()) = solver;
    }
};

static Object getNet(Object self) {
    Solver *solver = from_ruby<Solver *>(self);
    Net *net = solver -> net().get();

    if (net) {
        return objectNoGC(net);
    } else {
        return Qnil;
    }
}

static Object getTestNets(Object self) {
    Solver *solver = from_ruby<Solver *>(self);
    const std::vector<boost::shared_ptr<Net> > &nets = solver -> test_nets();
    return mapArray(nets.begin(), nets.end(),
                    sharedToObj<Net, boost::shared_ptr<Net> >);
}

static void restore(Object self, String path) {
    Solver *solver = from_ruby<Solver *>(self);
    solver -> Restore(path.c_str());
}

static void solve(Object self) {
    Solver *solver = from_ruby<Solver *>(self);
    solver -> Solve(NULL);
}

void Init_solver() {
    Module rb_mCaffe = define_module("Caffe");

    Data_Type<Solver> rb_cSolver = rb_mCaffe
        .define_class<Solver>("Solver")
        .define_constructor(SolverConstructor())
        .define_method("net", getNet)
        .define_method("test_nets", getTestNets)
        .define_method("iter", &Solver::iter)
        .define_method("step!", &Solver::Step)
        .define_method("snapshot", &Solver::Snapshot)
        .define_method("restore!", restore)
        .define_method("solve!", solve);
}
