require 'json'
require_relative '../../../app/classes/MessageHandlers/messages_stack'

class MyNetwork

  attr_accessor :nodes, :channels, :nodes_number, :average_channels_num,
                :channel_weights, :message_sending_mode, :is_initialized,
                :messages_stack

  def initialize
    @nodes = []
    @channels = []
    @channel_weights = []
    @nodes_number = 0
    @average_channels_num = 0
    @message_sending_mode = :datagram_mode
    @is_initialized = false
    @messages_stack = MessagesStack.new
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
      if !channel.first_buffer.empty? or !channel.second_buffer.empty? or !channel.channel_buffer.empty?
        return_value = true
        break
      end
    end
    return_value
  end


  def delete_all_messages
    if has_messages?
      @channels.each do |channel|
        channel.first_buffer.clear
        channel.second_buffer.clear
        channel.channel_buffer.clear
      end
    end
  end


  def established_connection?(node_id_1, node_id_2)
    return_value = true
    current_node_id = node_id_1
    find_node(node_id_1).routes_table[node_id_2.to_s].each do |id|
      unless find_channel(current_node_id, id).is_busy
        return_value = false
        break
      end
      current_node_id = id
    end
    return_value
  end


  def can_send?(node_id_1, node_id_2)
    return_value = true
    current_node_id = node_id_1
    find_node(node_id_1).routes_table[node_id_2.to_s].each do |id|
      channel = find_channel(current_node_id, id)
      unless channel.channel_buffer.empty?
        return_value = false
        break
      end
      (channel.first_buffer + channel.second_buffer).each do |message|
        if [:positive_response, :negative_response, :request].include?(message.type)
          return_value = false
          break
        end
      end
      current_node_id = id
    end
    return_value
    established_connection?(node_id_1, node_id_2) and return_value
  end


  def to_json(*a)
    as_json.to_json(*a)
  end


  def as_json(options = {})
    {
        json_class: self.class.name,
        data:
        {
            nodes: @nodes.map(&:as_json), channels: @channels.map(&:as_json),
            messages_stack: @messages_stack
        }
    }
  end


  def self.json_create(o)
    net_from_json = new
    net_from_json.nodes = o['data']['nodes']
    net_from_json.channels = o['data']['channels']
    net_from_json.messages_stack = o['data']['messages_stack']
    net_from_json
  end
end