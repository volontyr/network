require_relative '../MessageHandlers/message_generator'
require_relative '../MessageHandlers/messages_queue_handler'
require_relative '../MessageHandlers/channel_buffer_handler'
require_relative '../../../app/classes/routes_finder'

class NetworkInitializer


  def initialize(network)
    @network = network
    @network.message_sending_mode = :datagram_mode
  end


  def initialize_network(criteria_for_routes=:time)
    @network.delete_all_messages
    @network.criteria_for_routes = criteria_for_routes
    RoutesFinder.new(@network).find_routes

    central_node = @network.central_node

    @network.nodes.each.reject { |n| n == @network.central_node or n.activity == :non_active }.each do |node|
      msg_generator = MessageGenerator.new(@network)
      msg_generator.create_manage_message(:update_routes_tables, central_node.id, node.id)
    end

    while @network.has_messages?
      @network.nodes.each do |node|
        queue_handler = MessagesQueueHandler.new(node, @network)
        queue_handler.send_messages
        channels_handler = ChannelBufferHandler.new(@network)
        channels_handler.handle_buffers
      end
    end

    @network.is_initialized = true
  end
end