require_relative 'message_sender'
require_relative '../../../app/classes/constants'

class MessagesQueueHandler


  def initialize(node, network)
    @node = node
    @network = network
    @message_sender = MessageSender.new(network)
  end


  def send_messages
    @node.channels.each do |channel|
      buffer = (@node.id == channel.first_node) ? channel.first_buffer : channel.second_buffer
      next if buffer.empty?
      message = next_message(buffer)

      unless message.receiver_node == @node.id
        next_node = next_receiver_node(message.receiver_node)
        next_channel = @network.find_channel(@node.id, next_node)

        # check if message in out buffer already
        if next_channel.has_message?(message)
          @message_sender.send_message(@node.id, next_node, message)
        else
          add_message_to_out_buffer(message, next_channel)
        end
      end
    end
  end


  def next_message(buffer)
    buffer.delete_at(0)
  end


  def next_receiver_node(final_receiver_node)
    @node.routes_table[final_receiver_node.to_s][0].to_i
  end


  def add_message_to_out_buffer(message, channel)
    unless (buffer = channel.get_buffer_by_node(@node.id)).nil?
      message.delivery_time += Constants.node_ping_time
      buffer << message
    end
  end


  def add_message_to_queue(message)
    initial_channel = @network.find_channel(@node.id, next_receiver_node(message.receiver_node))
    add_message_to_out_buffer(message, initial_channel)
  end
end
