class ChannelBufferHandler

  def initialize(network)
    @network = network
  end


  def handle_buffers
    @network.channels.reject { |c| c.channel_buffer.empty? }.each do |channel|
      channel.channel_buffer.each do |elem| # elem: 0 - message, 1 - delivery_time
        elem[1] -= 1 # !!!!!!!!!!!!!!!!!!!!!!!!!!!!
        if elem[1] == 0
          buffer_move_to = get_next_buffer(elem[0], channel)
          if [:request, :positive_response, :negative_response].include?(elem[0].type)
            buffer_move_to.insert(0, elem[0])
          else
            buffer_move_to << elem[0]
          end
          channel.channel_buffer.delete(elem)
        end

        if rand(0...1.0) < channel.error_prob
          channel.channel_buffer.delete(elem)
          buffer_move_from = get_previous_buffer(elem[0], channel)
          buffer_move_from.insert(0, elem[0])
        end
      end
    end
  end


  def get_next_buffer(message, channel)
    sender_node = @network.find_node(message.sender_node)

    sender_node.routes_table[message.receiver_node.to_s].reverse_each do |node|
      if [channel.first_node, channel.second_node].include?(node)
        return channel.get_buffer_by_node(node)
      end
    end
  end


  def get_previous_buffer(message, channel)
    buffer_move_to = get_next_buffer(message, channel)
    (channel.first_buffer == buffer_move_to) ? channel.second_buffer : channel.first_buffer
  end
end