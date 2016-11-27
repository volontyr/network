require_relative 'message_generator'

class ReceivedMessageHandler

  def initialize(network)
    @network = network
  end


  def receive_message(node, message)
    channel = @network.find_channel(node.id, node.routes_table[message.sender_node.to_s][0])

    case message.type
      when :request, :info
        if @network.message_sending_mode == :logical_connection
          MessageGenerator.new(@network).create_manage_message(:positive_response, node.id,
                                                              message.sender_node)
        end
      when :positive_response
        channel.is_busy = true unless channel.is_busy
      when :negative_response
        channel.is_busy = false if channel.is_busy
      else
    end

    buffer = channel.get_buffer_by_node(node.id)
    buffer.delete(message)
    @network.messages_stack.push(message)
  end
end