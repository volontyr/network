require 'rspec/core'
require_relative '../app/classes/network_builder'
require_relative '../app/classes/node'
require_relative '../app/classes/channel'

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
end