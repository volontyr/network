require 'set'

class Node
  attr_reader :id, :channels
  attr_accessor :coord_x, :coord_y
  @@num = 0

  def initialize(coord_x = 0, coord_y = 0)
    @id = @@num
    @@num += 1
    @coord_x = coord_x
    @coord_y = coord_y
    @channels = []
  end

  def add_channel(value)
    raise ArgumentError, 'Argument must be Channel type' unless value.is_a?(Channel)
    raise ArgumentError,
          'Channel is busy' unless [value.first_node, value.second_node].any? do |member|
          [self, nil].include?(member)
    end
    @channels << value unless @channels.include?(value)

    # add link with this node to channel (value)
    unless [value.first_node, value.second_node].include?(self)
      if value.first_node.nil?
        value.first_node = self
      elsif value.second_node.nil?
        value.second_node = self
      end
    end
  end

end