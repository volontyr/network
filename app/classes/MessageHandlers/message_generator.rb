require_relative 'message'
require_relative 'message_initializer'
require_relative 'messages_queue_handler'
require_relative 'message_sender'
require_relative '../../../app/classes/constants'

class MessageGenerator
  attr_accessor :network, :message_sending_mode


  def initialize(network)
    @network = network
    @message_sending_mode = network.message_sending_mode
  end


  def create_message(initializer, sender_node=nil, receiver_node=nil)
    sender = sender_node
    receiver = receiver_node

    if sender.nil?
      sender = @network.nodes[rand(0...@network.nodes.size)].id
    end

    if receiver.nil?
      begin
        rand_ind = rand(0...@network.nodes.size)
      end while @network.nodes[rand_ind].id == sender
      receiver = @network.nodes[rand_ind].id
    end

    unless @network.find_node(sender).routes_table[receiver.to_s].empty?
      message = Message.new(sender, receiver, initializer.message_size,
                            initializer.service_size, initializer.message_type)

      if @message_sending_mode == :datagram_mode and initializer.message_type == :info
        divide_message_on_packets(message)
      else
        sender_node = @network.find_node(message.sender_node)
        queue_handler = MessagesQueueHandler.new(sender_node, @network)
        queue_handler.add_message_to_queue(message)
      end

      message
    end
  end


  def create_manage_message(message_type, sender=nil, receiver=nil)
    unless sender == @network.central_node.id or message_type != :update_routes_tables
      sender = @network.central_node.id
    end

    if message_type == :update_routes_tables
      message_size = Constants.update_tables_message_size
    elsif [:request, :positive_response, :negative_response].include?(message_type)
      message_size = Constants.service_message_size
    else
      message_size = 0
    end

    message_initializer = MessageInitializer.new(message_size, Constants.service_size, message_type)
    create_message(message_initializer, sender, receiver)
  end


  def divide_message_on_packets(message)
    sender_node = @network.find_node(message.sender_node)
    message_size = message.info_size

    while message_size > 0
      if message_size < Constants.packet_size
        initializer = MessageInitializer.new(message_size, Constants.service_size,
                                                 message.type)
      else
        initializer = MessageInitializer.new(Constants.packet_size, Constants.service_size,
                                                 message.type)
      end
      small_message = Message.new(message.sender_node, message.receiver_node,
                                  initializer.message_size, initializer.service_size,
                                  initializer.message_type)
      queue_handler = MessagesQueueHandler.new(sender_node, @network)

      queue_handler.add_message_to_queue(small_message)

      message_size -= Constants.packet_size
    end
  end

end
