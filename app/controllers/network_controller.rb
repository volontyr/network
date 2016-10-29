# require "#{Rails.root}/app/classes/network_builder"

class NetworkController < ApplicationController
  def new
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
      redirect_to root_path
    else
      builder = NetworkBuilder.new(nodes_number, avg_channels_num)
      builder.generate_network
    end
  end
end
