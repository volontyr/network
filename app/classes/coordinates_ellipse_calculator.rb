require_relative 'coordinates_calculator'

class CoordinatesEllipseCalculator < CoordinatesCalculator

  def initialize
    @param_a = 700
    @param_b = -250
    @param_c = 750
    @param_d = -280
    @p = 1
    super
  end

  def initial_x
    @param_c-@param_a
  end

  def calculate_y(x)
    sqrt = Math.sqrt(@param_a*@param_a*@param_a*@param_a*@param_b*@param_b -
                         @param_a*@param_a*@param_b*@param_b*@param_c*@param_c +
                         2*@param_a*@param_a*@param_b*@param_b*@param_c*x -
                         @param_a*@param_a*@param_b*@param_b*x*x)
    y = (-@param_a*@param_a*@param_d + @p * sqrt) / (@param_a*@param_a)
    @p *= -1
    y
  end

  def nodes_number=(value)
    @nodes_number = value
    @step = 2 * @param_a / (@nodes_number + 5) - 10
  end
end