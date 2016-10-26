class Channel
  attr_accessor :type, :weight, :error_prob
  attr_reader :time_coefficient

  def initialize(weight, error_prob, type = :duplex)
    raise ArgumentError,
          'Argument is wrong' unless [:duplex, :half_duplex].include?(type)
    raise ArgumentError,
          'Argument is not numeric or negative' unless weight.is_a?(Numeric) and weight >= 0
    raise ArgumentError,
          'Argument is wrong' unless error_prob.is_a?(Numeric) and error_prob >= 0 and error_prob <= 1
    @type = type
    @weight = weight
    @error_prob = error_prob
  end

  def type=(value)
    raise ArgumentError, 'Argument is wrong' unless [:duplex, :half_duplex].include?(value)
    @type = value
  end

  def weight=(value)
    raise ArgumentError,
          'Argument is not numeric or negative' unless value.is_a?(Numeric) and value >= 0
    @weight = value
  end

  def error_prob=(value)
    raise ArgumentError,
          'Argument is wrong' unless value.is_a?(Numeric) and value >= 0 and value <= 1
    @error_prob = value
  end

  def set_time_coefficient(coefficient)
    @time_coefficient = coefficient
  end
end