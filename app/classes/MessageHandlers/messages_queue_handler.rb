require_relative 'message_sender'
require_relative '../../../app/classes/constants'
require_relative 'message_initializer'
require_relative 'message_generator'
require_relative 'received_message_handler'

class MessagesQueueHandler


  def initialize(node, network)
    @node = node
    @network = network
    @message_sender = MessageSender.new(network)
    @message_receiver = ReceivedMessageHandler.new(network)
  end


  def send_messages
    @node.channels.each do |channel|
      buffer = (@node.id == channel.first_node) ? channel.first_buffer : channel.second_buffer
      next if buffer.empty?
      message = next_message(buffer)

      if message.receiver_node == @node.id
        # handle_received_message
        @message_receiver.receive_message(@node, message)
      else
        next_node = next_receiver_node(message.receiver_node)
        next_channel = @network.find_channel(@node.id, next_node)

        # check if message in out buffer already
        if next_channel.has_message?(message)
          @message_sender.send_message(@node.id, next_node, message)
        else
          add_message_to_out_buffer(message, next_channel, buffer)
        end
      end
    end
  end


  def next_message(buffer)
    if @network.message_sending_mode == :logical_connection
      if @network.established_connection?(buffer[0].sender_node, buffer[0].receiver_node)
        return buffer[0]
      else
        return MessageGenerator.new(@network).create_manage_message(
                  :request, buffer[0].sender_node, buffer[0].receiver_node
               )
      end
    else
      buffer[0]
    end
  end


  def next_receiver_node(final_receiver_node)
    @node.routes_table[final_receiver_node.to_s][0].to_i
  end


  def add_message_to_out_buffer(message, channel, previous_buffer=nil)
    unless (buffer = channel.get_buffer_by_node(@node.id)).nil?
      message.delivery_time += Constants.node_ping_time
      if [:info, :update_routes_tables].include?(message.type)
        buffer << message
      else
        buffer.insert(0, message)
      end

      unless previous_buffer.nil? or message.type != :request
        previous_buffer.delete(message)
        if channel.is_busy
          MessageGenerator.new(@network).create_manage_message(
              :negative_response, @node.id, message.sender_node
          )
          buffer.delete(message)
        else
          receiver = @node.routes_table[message.sender_node.to_s][0]
          MessageGenerator.new(@network).create_manage_message(
              :positive_response, @node.id, receiver
          )
        end
      end
    end
  end


  def add_message_to_queue(message)
    initial_channel = @network.find_channel(@node.id, next_receiver_node(message.receiver_node))
    add_message_to_out_buffer(message, initial_channel)
  end
end
