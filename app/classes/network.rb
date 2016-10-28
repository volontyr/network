class Network
  attr_accessor :nodes, :channels, :nodes_number, :average_channels_num

  def initialize
    @nodes = []
    @channels = []
    @nodes_number = 0
    @average_channels_num = 0
  end
end