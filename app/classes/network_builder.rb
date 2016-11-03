require_relative 'my_network'
require_relative 'channel_creator'
require_relative 'coordinates_ellipse_calculator'

class NetworkBuilder
  attr_accessor :network_generator, :channel_creator, :coordinates_calculator

  def initialize(nodes_number=0, average_channels_num=0)
    @network = MyNetwork.new
    @network.nodes_number = nodes_number
    @network.average_channels_num = average_channels_num
    @network.channel_weights = [2, 4, 5, 7, 8, 12, 15, 17, 18, 22, 25, 32]
    @network_generator = nil
    @coordinates_calculator = CoordinatesEllipseCalculator.new
  end

  # adds node to the network and returns its instance
  def add_node(coord_x, coord_y, channel=nil)
    node = Node.new(coord_x, coord_y)
    node.add_channel(channel) unless channel.nil?
    @network.nodes << node
    node
  end

  def remove_node(node_id)
    raise ArgumentError, "Such node id doesn't exist" unless @network.nodes.any? { |n| n.id == node_id }
    @network.nodes.each do |node|
      node.channels.delete_if { |c| [c.first_node, c.second_node].include?(node_id) }
    end
    @network.channels.delete_if { |c| [c.first_node, c.second_node].include?(node_id) }
    @network.nodes.delete_if { |n| n.id == node_id }
  end

  # adds channel to the network and returns its instance
  def add_channel(weight, error_prob, type= :duplex, first_node=nil, second_node=nil, channel_type= :usual)
    message = "#{channel_type}_channel"
    channel = ChannelCreator.send(message, weight, error_prob, type)
    channel.first_node = first_node unless first_node.nil?
    channel.second_node = second_node unless second_node.nil?
    @network.channels << channel
    channel
  end

  def remove_channel(node_id_1, node_id_2)
    @network.nodes.each do |node|
      if node.id == node_id_1 or node.id == node_id_2
        node.channels.delete_if do |c|
          (c.first_node == node_id_1 and c.second_node == node_id_2) or
              (c.first_node == node_id_2 and c.second_node == node_id_1)
        end
      end
    end
    @network.channels.delete_if do |c|
      (c.first_node == node_id_1 and c.second_node == node_id_2) or
          (c.first_node == node_id_2 and c.second_node == node_id_1)
    end
  end

  def add_random_channel(type= :duplex, first_node=nil, second_node=nil, channel_type= :usual)
    weights_len = @network.channel_weights.size
    weight = @network.channel_weights[rand(0...weights_len)]
    error_prob = (rand(0..99) / 100).to_f
    add_channel(weight, error_prob, type, first_node, second_node, channel_type)
  end

  def generate_network
    Node.num = 0 # set node's id counter to zero
    @network_generator.generate(self, @network.nodes_number, @network.average_channels_num)
  end

  def change_nodes_number(value)
    raise ArgumentError, 'Argument must be numeric type' unless value.is_a?(Numeric)
    @network.nodes_number = value
  end

  def change_average_channels_num(value)
    raise ArgumentError, 'Argument must be numeric type' unless value.is_a?(Numeric)
    @network.average_channels_num = value
  end

  def network
    @network
  end
end
