require_relative 'message_generator'

class ReceivedMessageHandler

  def initialize(network)
    @network = network
  end


  def receive_message(node, message)
    channel = @network.find_channel(node.id, node.routes_table[message.sender_node.to_s][0])

    case message.type
      when :request
        if @network.message_sending_mode == :logical_connection
          MessageGenerator.new(@network).create_manage_message(:positive_response, node.id,
                                                              message.sender_node)
          # @network.established_connections << [message.sender_node, message.receiver_node]
        end
      when :info
        if @network.message_sending_mode == :logical_connection
          if connection_to_close?(node.id, message.sender_node, message)
            MessageGenerator.new(@network).create_manage_message(:positive_response, node.id,
                                                                 message.sender_node)
            # free_channels(node.id, message.sender_node)
          end
        elsif message.is_last_packet?
          MessageGenerator.new(@network).create_manage_message(:positive_response, node.id,
                                                               message.sender_node)
        end
      when :negative_response
        free_channels(node.id, message.sender_node)
      when :positive_response
        if connection_to_close?(message.sender_node, node.id, message)
          free_channels(node.id, message.sender_node)
          @network.established_connections.delete([node.id, message.sender_node])
        else
          unless @network.established_connections.include?([node.id, message.sender_node])
            @network.established_connections << [node.id, message.sender_node]
          end
        end
      else
    end

    buffer = channel.get_buffer_by_node(node.id)
    buffer.delete(message)
    @network.messages_stack.push(message)

    puts message.sender_node.to_s + ' -----------------> ' + message.receiver_node.to_s + message.type.to_s
  end


  def free_channels(node_id_1, node_id_2)
    receiver = @network.find_node(node_id_1)
    current_node = receiver.id
    receiver.routes_table[node_id_2.to_s].each do |node_id|
      @network.find_channel(current_node, node_id).is_busy = false
      current_node = node_id
    end
  end


  def connection_to_close?(node_id_1, node_id_2, message)
    return_value = true
    sender = @network.find_node(node_id_2)
    current_node = sender.id
    sender.routes_table[node_id_1.to_s].each do |node_id|
      current_channel = @network.find_channel(current_node, node_id)
      channel_buffers = current_channel.first_buffer + current_channel.second_buffer +
                        current_channel.channel_buffer.map { |c| c[0] }

      if current_node == sender.id
        sender_buffer = current_channel.get_buffer_by_node(sender.id)
        first_info_msg_index = 0
        sender_buffer.each do |m|
          if m.type == :info
            first_info_msg_index = sender_buffer.index(m)
            break
          end
        end
        channel_buffers -= sender_buffer[(first_info_msg_index + 1)..-1] unless sender_buffer.empty?
      end

      channel_buffers.reject { |m| m == message }.each do |msg|
        if msg.type == :info and msg.sender_node == sender.id and msg.receiver_node == node_id_1
          return_value = false
          break
        end
      end
      break unless return_value
      current_node = node_id
    end
  end
end