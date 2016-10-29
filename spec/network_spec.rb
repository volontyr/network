require 'rspec/core'
require_relative '../app/classes/network_builder'
require_relative '../app/classes/node'
require_relative '../app/classes/channel'
require_relative '../app/classes/network_random_generator'

describe 'Network' do
  let(:builder) { NetworkBuilder.new }

  it 'can add nodes and channels and link them in a network' do
    node_1 = builder.add_node(0, 0)
    node_2 = builder.add_node(5, 5)
    builder.add_channel(10, 0.15, :duplex, node_1, node_2)
    network = builder.network
    expect(network.nodes.size).to eq(2)
    expect(network.channels.size).to eq(1)
    expect(network.channels[0].first_node).to eq(node_1)
    expect(network.channels[0].second_node).to eq(node_2)
  end

  it 'can change nodes number' do
    builder = NetworkBuilder.new(4, 2)
    old_nodes_number = builder.network.nodes_number
    expect(old_nodes_number).to eq(4)
    builder.change_nodes_number(3)
    new_nodes_number = builder.network.nodes_number
    expect(new_nodes_number).to eq(3)
  end

  it 'raise argument error when set not numeric nodes number' do
    builder = NetworkBuilder.new(4, 2)
    expect { builder.change_nodes_number('3') }.to raise_error('Argument must be numeric type')
  end

  it 'can generate a random network' do
    builder = NetworkBuilder.new(35, 4)
    builder.network_generator = NetworkRandomGenerator.new
    builder.generate_network
    expect(builder.network.channels.size).to eq(70)
    builder.network.nodes.each do |node|
      expect(node.channels.size).to be > 0
    end
  end
end