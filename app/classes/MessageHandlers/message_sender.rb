class MessageSender

  attr_accessor :network

  def initialize(network)
    @network = network
  end


  def send_message(current_node, next_node, message)
    if @network.message_sending_mode == :datagram_mode
      send_in_datagram_mode(current_node, next_node, message)
    else
      send_in_logical_connect_mode(current_node, next_node, message)
    end
  end


  def send_in_datagram_mode(current_node, next_node, message)
    channel = @network.find_channel(current_node, next_node)
    delivery_time = get_delivery_time(message, channel)
    put_message_in_channel(channel, message, delivery_time, current_node)
  end


  def send_in_logical_connect_mode(current_node, next_node, message)
    channel = @network.find_channel(current_node, next_node)
    delivery_time = get_delivery_time(message, channel)
    # !!!!!!!!!!!!!!!!!!!!!
    case message.type
      when :info, :update_routes_tables
        if @network.can_send?(current_node, next_node)
          put_message_in_channel(channel, message, delivery_time, current_node)
        end
      else
        put_message_in_channel(channel, message, delivery_time, current_node)
    end
  end


  def put_message_in_channel(channel, message, delivery_time, current_node)
    if try_to_put_message_in_channel(channel, message, delivery_time)
      # message.delivery_time += delivery_time
      buffer_from = channel.get_buffer_by_node(current_node)
      buffer_from.delete(message)
    end
  end


  def try_to_put_message_in_channel(channel, message, delivery_time)
    return_value = false
    if channel.type == :duplex and @network.message_sending_mode == :datagram_mode
      if channel.channel_buffer.size < 2
        if channel.channel_buffer.empty?
          channel.channel_buffer << [message, delivery_time]
          return_value = true
        else
          existed_message = channel.channel_buffer[0][0]
          direction_of_existed_message = get_direction(existed_message, channel)
          direction_of_new_message = get_direction(message, channel)
          unless direction_of_existed_message == direction_of_new_message
            channel.channel_buffer << [message, delivery_time]
            return_value = true
          end
        end
      end
    else
      if channel.channel_buffer.size < 1
        channel.channel_buffer << [message, delivery_time]
        return_value = true
      end
    end

    return_value
  end


  def get_direction(message, channel)
    sender_node = @network.find_node(message.sender_node)
    receiver_node = @network.find_node(message.receiver_node)
    array_direction = []
    sender_node.routes_table[receiver_node.id.to_s].each do |node|
      if [channel.first_node, channel.second_node].include?(node)
        array_direction << node
      end
    end
    array_direction
  end


  def get_delivery_time(message, channel)
    message_size = message.info_size + message.service_size
    traffic_capacity = 100.0 / channel.weight
    (message_size.to_f / traffic_capacity).round
  end
end
