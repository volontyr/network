require 'json'

class Node
  attr_accessor :id, :channels, :coord_x, :coord_y, :routes_table, :routes_lengths_table
  @@num = 0

  def initialize(coord_x = 0, coord_y = 0)
    @id = @@num
    @@num += 1
    @coord_x = coord_x
    @coord_y = coord_y
    @channels = []
    @routes_table = {}
    @routes_lengths_table = {}
  end

  def add_channel(value)
    raise ArgumentError, 'Argument must be Channel type' unless value.is_a?(Channel)
    raise ArgumentError,
          'Channel is busy' unless [value.first_node, value.second_node].any? do |member|
          [@id, nil].include?(member)
    end
    @channels << value unless @channels.include?(value)

    # add link with this node to channel (value)
    unless [value.first_node, value.second_node].include?(@id)
      if value.first_node.nil?
        value.first_node = self
      elsif value.second_node.nil?
        value.second_node = self
      end
    end
  end

  def self.num=(value)
    @@num = value
  end

  def to_json(*a)
    as_json.to_json(*a)
  end

  def as_json(options = {})
    {
        json_class: self.class.name,
        id: @id, coord_x: @coord_x, coord_y: @coord_y, channels: @channels.map(&:as_json)
    }
  end

  def self.json_create(o)
    node_from_json = new
    node_from_json.id = o['id'].to_i
    node_from_json.coord_x = o['coord_x'].to_f
    node_from_json.coord_y = o['coord_y'].to_f
    node_from_json.channels = o['channels']
    node_from_json
  end

end