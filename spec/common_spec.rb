RSpec.describe Caffe do
  it 'contains constant shortcuts of enum' do
    expect(Caffe::TRAIN).to eq(Caffe::Phase::TRAIN)
    expect(Caffe::TEST).to eq(Caffe::Phase::TEST)
    expect(Caffe::CPU).to eq(Caffe::SolverParameter::SolverMode::CPU)
    expect(Caffe::GPU).to eq(Caffe::SolverParameter::SolverMode::GPU)
  end

  it 'can change mode' do
    expect(Caffe.mode).to eq(Caffe::CPU)
    Caffe.mode = Caffe::GPU
    expect(Caffe.mode).to eq(Caffe::GPU)
  end

  it 'can get / set parallel settings' do
    expect(Caffe.solver_count).to eq(1)
    expect(Caffe.solver_rank).to eq(0)
    expect(Caffe.multiprocess).to eq(false)
    Caffe.solver_count = 2
    Caffe.solver_rank = 1
    Caffe.multiprocess = true
    expect(Caffe.solver_count).to eq(2)
    expect(Caffe.solver_rank).to eq(1)
    expect(Caffe.multiprocess).to eq(true)
    Caffe.solver_count = 1
    Caffe.solver_rank = 0
    Caffe.multiprocess = false
  end
end
