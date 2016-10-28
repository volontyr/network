class Channel
  attr_accessor :type, :weight, :error_prob, :first_node, :second_node
  attr_reader :time_coefficient

  def initialize(weight = 0, error_prob = 0, type = :duplex)
    self.type = type
    self.weight = weight
    self.error_prob = error_prob
    @first_node = nil
    @second_node = nil
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

  def first_node=(value)
    raise 'Node must differ from another one' unless value != @second_node
    raise ArgumentError, 'Argument must be Node type' unless value.is_a?(Node)
    @first_node = value
    value.add_channel(self) unless value.channels.include?(self)
  end

  def second_node=(value)
    raise 'Node must differ from another one' unless value != @first_node
    raise ArgumentError, 'Argument must be Node type' unless value.is_a?(Node)
    @second_node = value
    value.add_channel(self) unless value.channels.include?(self)
  end

  def set_time_coefficient(coefficient)
    @time_coefficient = coefficient
  end
end