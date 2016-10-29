class MyNetwork
  attr_accessor :nodes, :channels, :nodes_number, :average_channels_num,
                :channel_weights

  def initialize
    @nodes = []
    @channels = []
    @channel_weights = []
    @nodes_number = 0
    @average_channels_num = 0
  end
end