require 'rspec/core'
require_relative '../app/classes/node'
require_relative '../app/classes/channel'

describe 'Switching Node' do
  let(:node) { Node.new }

  it 'should has unique id' do
    node = Node.new
    node1 = Node.new
    expect(node.id).to eq(0)
    expect(node1.id).to eq(1)
  end

  it 'should have coordinates initially' do
    another_node = Node.new(1, 1)
    expect(node.coord_x).to eq(node.coord_y) and eq(0)
    expect(another_node.coord_x).to eq(another_node.coord_y) and eq(1)
  end

  it 'should have a list of different channels' do
    node = Node.new
    channel_1 = Channel.new
    channel_2 = Channel.new
    node.add_channel(channel_1)
    node.add_channel(channel_2)
    node.add_channel(channel_2)
    expect(node.channels.size).to eq(2)
  end

  it 'adds channels not busy with two nodes' do
    some_node = Node.new
    another_node = Node.new
    node = Node.new
    channel_1 = Channel.new
    channel_2 = Channel.new

    channel_1.first_node = some_node
    channel_1.second_node = another_node
    expect(some_node.channels.size).to eq(1)
    expect(another_node.channels.size).to eq(1)

    channel_2.first_node = some_node
    expect(channel_2.first_node).to eq(some_node.id)
    expect { node.add_channel(channel_1) }.to raise_error('Channel is busy')
    node.add_channel(channel_2)
    expect(channel_2.second_node).to eq(node.id)
  end

  it "may re-assign channels's nodes" do
    some_node = Node.new
    another_node = Node.new
    channel = Channel.new
    channel.first_node = some_node
    expect(channel.first_node).to eq(some_node.id)
    channel.first_node = another_node
    expect(channel.first_node).to eq(another_node.id)
  end

  it "adds node to channel when channel's added to node" do
    node_1 = Node.new
    node_2 = Node.new
    channel = Channel.new
    node_1.add_channel(channel)
    expect(channel.first_node).to eq(node_1.id)
    node_2.add_channel(channel)
    expect(channel.second_node).to eq(node_2.id)
  end
end