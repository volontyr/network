require 'json'

class MyNetwork

  attr_accessor :nodes, :channels, :nodes_number, :average_channels_num,
                :channel_weights, :message_sending_mode, :is_initialized

  def initialize
    @nodes = []
    @channels = []
    @channel_weights = []
    @nodes_number = 0
    @average_channels_num = 0
    @message_sending_mode = :datagram_mode
    @is_initialized = false
  end


  def find_node(node_id)
    found_node = nil
    @nodes.each do |node|
      if node.id == node_id
        found_node = node
        break
      end
    end
    found_node
  end


  def central_node
    found_node = nil
    @nodes.each do |node|
      if node.type == :central
        found_node = node
        break
      end
    end
    found_node
  end


  def find_channel(node_id_1, node_id_2)
    found_channel = nil
    @channels.each do |channel|
      if [channel.first_node, channel.second_node].to_set == [node_id_1, node_id_2].to_set
        found_channel = channel
        break
      end
    end
    found_channel
  end


  def has_messages?
    return_value = false
    @channels.each do |channel|
      if !channel.first_buffer.empty? or !channel.second_buffer.empty?
        return_value = true
        break
      end
    end
    return_value
  end


  def to_json(*a)
    as_json.to_json(*a)
  end

  def as_json(options = {})
    {
        json_class: self.class.name,
        data: { nodes: @nodes.map(&:as_json), channels: @channels.map(&:as_json) }
    }
  end


  def self.json_create(o)
    net_from_json = new
    net_from_json.nodes = o['data']['nodes']
    net_from_json.channels = o['data']['channels']
    net_from_json
  end
end