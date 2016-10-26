require 'rspec/core'
require_relative '../app/classes/node'

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

end