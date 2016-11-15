require 'rspec/core'
require_relative '../app/classes/network_builder'
require_relative '../app/classes/node'
require_relative '../app/classes/channel'
require_relative '../app/classes/network_random_generator'
require_relative '../app/classes/routes_finder'

describe 'Network' do
  let(:builder) { NetworkBuilder.new }

  it 'can add nodes and channels and link them in a network' do
    node_1 = builder.add_node(0, 0)
    node_2 = builder.add_node(5, 5)
    builder.add_channel(10, 0.15, :duplex, node_1, node_2)
    network = builder.network
    expect(network.nodes.size).to eq(2)
    expect(network.channels.size).to eq(1)
    expect(network.channels[0].first_node).to eq(node_1.id)
    expect(network.channels[0].second_node).to eq(node_2.id)
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

  it 'remove node with some id' do
    builder = NetworkBuilder.new(5, 4)
    builder.network_generator = NetworkRandomGenerator.new
    builder.generate_network
    channels_all = builder.network.channels.size
    channels_of_node_3 = builder.network.nodes[3].channels.size
    builder.remove_node(3)
    expect(builder.network.nodes.size).to eq(4)
    expect(builder.network.channels.size).to eq(channels_all - channels_of_node_3)
  end

  it "raises exception if node with such id doesn't exist while removing" do
    builder = NetworkBuilder.new(5, 4)
    builder.network_generator = NetworkRandomGenerator.new
    builder.generate_network
    expect { builder.remove_node(6) }.to raise_error("Such node id doesn't exist")
    expect(builder.network.nodes.size).to eq(5)
    expect(builder.network.channels.size).to eq(10)
  end

  it 'removes channel between two nodes' do
    node_1 = builder.add_node(0, 0)
    node_2 = builder.add_node(5, 5)
    builder.add_channel(10, 0.15, :duplex, node_1, node_2)
    builder.remove_channel(node_1.id, node_2.id)
    network = builder.network
    expect(network.nodes.size).to eq(2)
    expect(network.channels.size).to eq(0)
  end

  it "can update channel's parameters" do
    node_1 = builder.add_node(0, 0)
    node_2 = builder.add_node(5, 5)
    channel = builder.add_channel(10, 0.15, :duplex, node_1, node_2)
    builder.update_channel(node_1.id, node_2.id, 17, 0.17, :half_duplex)
    expect(channel.weight).to eq(17)
    expect(channel.error_prob).to eq(0.17)
    expect(channel.type).to eq(:half_duplex)
  end

  it 'create routes tables for each node' do
    Node.num = 0
    node_1 = builder.add_node(0, 0)
    node_2 = builder.add_node(5, 5)
    node_3 = builder.add_node(0, 0)
    node_4 = builder.add_node(5, 5)
    node_5 = builder.add_node(0, 0)
    builder.add_channel(1, 0.1, :duplex, node_1, node_2)
    builder.add_channel(3, 0.1, :duplex, node_2, node_3)
    builder.add_channel(2, 0.1, :duplex, node_3, node_4)
    builder.add_channel(3, 0.1, :duplex, node_4, node_5)
    builder.add_channel(5, 0.1, :duplex, node_1, node_5)
    builder.add_channel(5, 0.1, :duplex, node_1, node_3)
    builder.add_channel(4, 0.1, :duplex, node_4, node_2)
    routes_finder = RoutesFinder.new(builder.network)
    routes_finder.find_routes
    expect(builder.network.nodes[0].routes_table['1']).to eq([1])
    expect(builder.network.nodes[0].routes_table['2']).to eq([1, 2])
    expect(builder.network.nodes[0].routes_table['3']).to eq([1, 3])
    expect(builder.network.nodes[0].routes_table['4']).to eq([4])
    expect(builder.network.nodes[2].routes_table['0']).to eq([1, 0])
    expect(builder.network.nodes[3].routes_table['0']).to eq([1, 0])
  end

end