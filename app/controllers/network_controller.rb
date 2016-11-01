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
      existed_node = nil
      @@builder.network.nodes.each do |node|
        if node.id == node_id
          existed_node = node
          break
        end
      end
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
