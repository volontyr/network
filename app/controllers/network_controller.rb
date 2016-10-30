require 'json'
require 'oj'
require 'oj_mimic_json'

class NetworkController < ApplicationController
  def new
  end

  def index
    @network = $network
  end

  def create
    nodes_number = params[:nodes_number].to_i
    avg_channels_num = params[:average_channels_num].to_i
    max_channels_num = (nodes_number - 1) * nodes_number / 2
    actual_channels_num = nodes_number * avg_channels_num / 2
    conditions = []
    conditions << (avg_channels_num * nodes_number % 2 == 0)
    conditions << (actual_channels_num >= nodes_number - 1)
    conditions << (actual_channels_num <= max_channels_num)

    if conditions.include?(false)
      render 'new'
    else
      builder = NetworkBuilder.new(nodes_number, avg_channels_num)
      builder.network_generator = NetworkRandomGenerator.new
      builder.generate_network
      $network = builder.network.to_json
      # puts JSON.load(JSON.dump(builder.network))
      # puts Oj.dump(builder.network, indent: 2)
      redirect_to network_path
    end
  end

end
