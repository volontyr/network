class CoordinatesCalculator
  attr_accessor :nodes_number, :last_coord_x

  def initialize
    @nodes_number = 1
    @step = 1
    @last_coord_x = initial_x
  end

  def initial_x
    rand(0..1000)
  end

  def calculate_x(old_x)
    @last_coord_x = old_x + @step
  end

end