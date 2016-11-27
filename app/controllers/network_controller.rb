require 'json'
require 'oj'
require 'oj_mimic_json'
require_relative '../../app/classes/Network/network_builder'
require_relative '../../app/classes/Network/network_random_generator'
require_relative '../../app/classes/routes_finder'
require_relative '../../app/classes/Network/network_initializer'
require_relative '../../app/classes/constants'
require_relative '../../app/classes/MessageHandlers/channel_buffer_handler'
require_relative '../../app/classes/MessageHandlers/message_initializer'
require_relative '../../app/classes/MessageHandlers/message_generator'
require_relative '../../app/classes/MessageHandlers/messages_queue_handler'

class NetworkController < ApplicationController
  def new
  end

  def index
    @network = @@builder.network
  end

  # saves nodes' coordinates on canvas
  def network_update
    if (network = params[:network])
      network = JSON.load(network)
      network['nodes'].each do |node|
        @@builder.network.find_node(node.id).coord_x = node.coord_x
        @@builder.network.find_node(node.id).coord_y = node.coord_y
      end
      # @@builder.network.nodes.replace network['nodes']
      Node.num = @@builder.network.nodes.size
    end
  end

  def create
    nodes_number = params[:nodes_number].to_i
    avg_channels_num = params[:average_channels_num].to_f

    if not_valid_params?(nodes_number, avg_channels_num)
      flash[:danger] = "Couldn't create network with these parameters"
      render 'new'
    else
      @@builder = NetworkBuilder.new(nodes_number, avg_channels_num)
      @@builder.network_generator = NetworkRandomGenerator.new
      @@builder.generate_network
      NetworkInitializer.new(@@builder.network).initialize_network
      redirect_to network_path
    end
  end

  def add_node
    if (node_id = params[:node].to_i)
      coord_x = @@builder.coordinates_calculator.last_coord_x
      coord_x = @@builder.coordinates_calculator.calculate_x(coord_x)
      coord_y = @@builder.coordinates_calculator.calculate_y(coord_x)
      new_node = @@builder.add_node(coord_x, coord_y)
      existed_node = @@builder.network.find_node(node_id)
      @@builder.add_random_channel(:duplex, new_node, existed_node)
    end
    redirect_to network_path
  end

  def update_node
    node = params[:node].to_i
    activity = params[:activity].to_sym
    if @@builder.update_node(node, activity)
      NetworkInitializer.new(@@builder.network).initialize_network
    end
    redirect_to network_path
  end

  def remove_node
    if (node_id = params[:node].to_i)
      @@builder.remove_node(node_id)
      NetworkInitializer.new(@@builder.network).initialize_network
    end
    redirect_to network_path
  end

  def add_channel
    node_id_1 = params[:node_1].to_i
    node_id_2 = params[:node_2].to_i
    channels = @@builder.network.channels
    if node_id_1 and node_id_2
      if node_id_1 == node_id_2
        flash[:danger] = 'Nodes must differ from each other'
      elsif channels.any? {|c| [c.first_node, c.second_node].to_set == [node_id_1, node_id_2].to_set}
        flash[:danger] = 'Channel between these nodes already exists'
      else
        existed_node_1 = @@builder.network.find_node(node_id_1)
        existed_node_2 = @@builder.network.find_node(node_id_2)

        weight = params[:weight].to_i
        error_prob = params[:error_prob].to_f
        type = params[:type].to_sym
        connection_type = params[:connection_type].to_sym
        if [weight, error_prob, type, connection_type].include?(nil)
          connection_type = :usual if connection_type.nil?
          channel = @@builder.add_random_channel(:duplex, existed_node_1, existed_node_2, connection_type)
          channel.weight = weight unless weight.nil?
          channel.error_prob = error_prob unless error_prob.nil?
          channel.type = type unless type.nil?
        else
          @@builder.add_channel(weight, error_prob, type, existed_node_1, existed_node_2, connection_type)
        end

      end
    end
    redirect_to network_path
  end

  def remove_channel
    node_id_1 = params[:node_1].to_i
    node_id_2 = params[:node_2].to_i
    if node_id_1 and node_id_2
      if node_id_1 == node_id_2
        flash[:danger] = 'Nodes must differ from each other'
      elsif !@@builder.network.find_channel(node_id_1, node_id_2).nil?
        @@builder.remove_channel(node_id_1, node_id_2)
        NetworkInitializer.new(@@builder.network).initialize_network
      else
        flash[:danger] = "There's no channel between these nodes"
      end
    end
    redirect_to network_path
  end

  def update_channel
    node_1 = params[:first_node].to_i
    node_2 = params[:second_node].to_i
    weight = params[:weight].to_i
    error_prob = params[:error_prob].to_f
    type = params[:type].to_sym
    activity = params[:activity].to_sym
    if @@builder.update_channel(node_1, node_2, weight, error_prob, type, activity)
      NetworkInitializer.new(@@builder.network).initialize_network
    end
    redirect_to network_path
  end

  def send_message
    node_id_1 = params[:node_1].to_i
    node_id_2 = params[:node_2].to_i
    @@builder.network.message_sending_mode = params[:mode].to_sym
    size = params[:size].to_i
    if node_id_1 and node_id_2
      if node_id_1 == node_id_2
        flash[:danger] = 'Nodes must differ from each other'
      else
        initializer = MessageInitializer.new(size, Constants.service_size, :info)
        msg_generator = MessageGenerator.new(@@builder.network)
        msg_generator.create_message(initializer, node_id_1, node_id_2)

        while @@builder.network.has_messages?
          @@builder.network.nodes.each do |node|
            queue_handler = MessagesQueueHandler.new(node, @@builder.network)
            queue_handler.send_messages
            channels_handler = ChannelBufferHandler.new(@@builder.network)
            channels_handler.handle_buffers
          end
        end
      end
    end
    redirect_to network_path
  end

  def generate_messages

  end

  def statistics
    @network = @@builder.network
  end

  private
    def not_valid_params?(nodes_number, avg_channels_num)
      max_channels_num = (nodes_number - 1) * nodes_number / 2
      actual_channels_num = nodes_number * avg_channels_num / 2
      conditions = []
      conditions << (avg_channels_num * nodes_number % 2 == 0)
      conditions << (actual_channels_num >= nodes_number - 1)
      conditions << (actual_channels_num <= max_channels_num)
      conditions.include?(false)
    end

end
