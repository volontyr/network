require 'json'
require 'oj'
require 'oj_mimic_json'

class NetworkController < ApplicationController
  def new
  end

  def index
    @network_json = @@builder.network.to_json
    @network = @@builder.network
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
      # @@network = @@builder.network.to_json
      # puts JSON.load(JSON.dump(builder.network))
      # puts Oj.dump(builder.network, indent: 2)
      redirect_to network_path
    end
  end

  def add_node
    if (node_id = params[:node].to_i)
      new_node = @@builder.add_node(50, 50)
      existed_node = @@builder.network.find_node(node_id)

      weights_len = @@builder.network.channel_weights.size
      weight = @@builder.network.channel_weights[rand(0...weights_len)]
      error_prob = rand(0..99) / 100
      @@builder.add_channel(weight, error_prob, :duplex, new_node, existed_node)
    end
    redirect_to network_path
  end

  def remove_node
    if (node_id = params[:node].to_i)
      @@builder.remove_node(node_id)
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

        weights_len = @@builder.network.channel_weights.size
        weight = @@builder.network.channel_weights[rand(0...weights_len)]
        error_prob = rand(0..99) / 100
        @@builder.add_channel(weight, error_prob, :duplex, existed_node_1, existed_node_2)
      end
    end
    redirect_to network_path
  end

  def remove_channel
    node_id_1 = params[:node_1].to_i
    node_id_2 = params[:node_2].to_i
    channels = @@builder.network.channels
    if node_id_1 and node_id_2
      if node_id_1 == node_id_2
        flash[:danger] = 'Nodes must differ from each other'
      elsif channels.any? {|c| [c.first_node, c.second_node].to_set == [node_id_1, node_id_2].to_set}
        @@builder.remove_channel(node_id_1, node_id_2)
      else
        flash[:danger] = "There's no channel between these nodes"
      end
    end
    redirect_to network_path
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
