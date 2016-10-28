require_relative 'network'

class NetworkBuilder

  def initialize(nodes_number=0, average_channels_num=0)
    @network = Network.new
    @network.nodes_number = nodes_number
    @network.average_channels_num = average_channels_num
  end

  # adds node to the network and returns its instance
  def add_node(coord_x, coord_y, channel=nil)
    node = Node.new(coord_x, coord_y)
    node.add_channel(channel) unless channel.nil?
    @network.nodes << node
    node
  end

  # adds channel to the network and returns its instance
  def add_channel(weight, error_prob, type= :duplex, first_node=nil, second_node=nil)
    channel = Channel.new(weight, error_prob, type)
    channel.first_node = first_node unless first_node.nil?
    channel.second_node = second_node unless second_node.nil?
    @network.channels << channel
    channel
  end

  def network
    @network
  end
end