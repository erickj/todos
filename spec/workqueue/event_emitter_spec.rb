require 'workqueue'

RSpec.describe WQ::EventEmitter, :wq do

  class Emitter
    include WQ::EventEmitter
  end

  let(:emitter) { Emitter.new }

  it 'allows subscribing with +on+' do
    foo_handler_fired = false
    handle_foo = lambda { foo_handler_fired = true }
    emitter.on(:foo, &handle_foo)

    emitter.emit :foo
    expect(foo_handler_fired).to be
  end

  it 'passes arguments to handlers' do
    foo_handler_args = []
    handle_foo = lambda { |*args| foo_handler_args = args }
    emitter.on(:foo, &handle_foo)

    emitter.emit :foo, 1, 2, 3, 'abc'
    expect(foo_handler_args).to eql [1, 2, 3, 'abc']
  end
end
