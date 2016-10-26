class Node
  attr_reader :id
  attr_accessor :coord_x, :coord_y
  @@num = 0

  def initialize(coord_x = 0, coord_y = 0)
    @id = @@num
    @@num += 1
    @coord_x ||= 0
    @coord_y ||= 0
  end

end