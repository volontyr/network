require 'json'

class Channel

  attr_accessor :type, :weight, :error_prob, :first_node, :second_node,
                :first_buffer, :second_buffer, :is_busy, :is_active
  attr_reader :time_coefficient

  def initialize(weight = 0, error_prob = 0, type = :duplex)
    self.type = type
    self.weight = weight
    self.error_prob = error_prob
    @is_busy = false
    @is_active = true
    @first_node = nil
    @second_node = nil
    @first_buffer = []
    @second_buffer = []
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
    raise 'Node must differ from another one' unless value.id != @second_node
    raise ArgumentError, 'Argument must be Node type' unless value.is_a?(Node)
    @first_node = value.id
    value.add_channel(self) unless value.channels.include?(self)
  end


  def second_node=(value)
    raise 'Node must differ from another one' unless value.id != @first_node
    raise ArgumentError, 'Argument must be Node type' unless value.is_a?(Node)
    @second_node = value.id
    value.add_channel(self) unless value.channels.include?(self)
  end


  def set_time_coefficient(coefficient)
    @time_coefficient = coefficient
  end


  def has_message?(message)
    [@first_buffer, @second_buffer].include?(message)
  end


  def get_buffer_by_node(node_id)
    if node_id == @first_node
      @first_buffer
    elsif node_id == @second_node
      return @second_buffer
    else
      nil
    end
  end


  def to_json(*a)
    as_json.to_json(*a)
  end


  def as_json(options = {})
    {
        json_class: self.class.name,
        weight: @weight, error_prob: @error_prob, type: @type,
        first_node: @first_node, second_node: @second_node
    }
  end


  def self.json_create(o)
    channel_from_json = new
    channel_from_json.weight = o['weight'].to_i
    channel_from_json.error_prob = o['error_prob'].to_f
    channel_from_json.type = o['type'].to_sym
    channel_from_json.instance_variable_set(:@first_node, o['first_node'].to_i)
    channel_from_json.instance_variable_set(:@second_node, o['second_node'].to_i)
    channel_from_json
  end

end