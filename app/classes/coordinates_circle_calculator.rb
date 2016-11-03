require_relative 'coordinates_calculator'

class CoordinatesCircleCalculator < CoordinatesCalculator

  def initialize
    @param_a = 600
    @param_b = 300
    @p = 1
    @radius = 250
    super
  end

  def initial_x
    @param_a - @radius
  end

  def calculate_y(x)
    y = @param_b + @p * Math.sqrt(@radius*@radius + 2*@param_a*x - @param_a*@param_a - x*x)
    @p *= -1
    y
  end

  def nodes_number=(value)
    @nodes_number = value
    @step = 2 * @radius / @nodes_number - 10
  end
end