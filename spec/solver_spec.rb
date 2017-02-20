RSpec.describe Caffe::Solver do
  before :example do
    path = File.expand_path '../net/test_solver.prototxt', __FILE__
    @solver = Caffe::Solver.new path
  end

  it '#net returns the train net' do
    net = @solver.net
    expect(net).to be_a(Caffe::Net)
    expect(net.inputs.size).to eq(0)
    expect(net.outputs.size).to eq(1)
  end

  it '#test_nets returns an array of test nets' do
    nets = @solver.test_nets
    expect(nets).to be_an(Array)
    expect(nets.size).to eq(1)
    net = nets[0]
    expect(net).to be_a(Caffe::Net)
    expect(net.outputs.size).to eq(2)
  end

  it '#iter returns the current iteration' do
    expect(@solver.iter).to eq(0)
  end

  it '#step! steps the iteration' do
    net = @solver.net
    loss = net.forward!
    @solver.step! 100
    expect(@solver.iter).to eq(100)
    expect(net.forward!).to be < loss
  end

  def snapshot_path
    state = File.expand_path "../net/test_iter_#{@solver.iter}.solverstate",
                             __FILE__
    model = File.expand_path "../net/test_iter_#{@solver.iter}.caffemodel",
                             __FILE__
    [state, model]
  end

  it '#snapshot & #restore! can save & load the current state' do
    state, model = snapshot_path
    begin
      @solver.snapshot
      expect(File.exist?(state)).to be true
      @solver.restore! state
    ensure
      File.unlink state
      File.unlink model
    end
  end

  it '#solve! solves the net' do
    begin
      @solver.solve!
      net = @solver.net
      expect(net.forward!).to be_within(1e-2).of(0.0)
    ensure
      state, model = snapshot_path
      File.unlink state
      File.unlink model
    end
  end
end
