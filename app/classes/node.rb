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
    @channels << value unless @channels.include?(value)
  end

end