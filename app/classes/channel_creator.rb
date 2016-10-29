require_relative 'satellite_channel'
require_relative 'usual_channel'
require_relative 'channel'

class ChannelCreator

  def self.satellite_channel(weight, error_prob, type)
    SatelliteChannel.new(weight, error_prob, type)
  end

  def self.usual_channel(weight, error_prob, type)
    UsualChannel.new(weight, error_prob, type)
  end
end