require 'json'

class Message
  attr_accessor :delivery_time, :is_last_packet,
                :id, :sender_node, :receiver_node, :info_size, :service_size, :type
  @@num = 0

  def initialize(sender_node, receiver_node, info_size, service_size, msg_type)
    @id = @@num
    @@num += 1
    @sender_node = sender_node
    @receiver_node = receiver_node
    @info_size = info_size
    @service_size = service_size
    @type = msg_type
    @is_last_packet = false
    @delivery_time = 0
  end


  def is_last_packet?
    @is_last_packet
  end


  def to_json(*a)
    as_json.to_json(*a)
  end


  def as_json(options = {})
    {
        json_class: self.class.name,
        data:
            {
                id: @id, sender_node: @sender_node, receiver_node: @receiver_node,
                info_size: @info_size, service_size: @service_size, type: @type,
                is_last_packet: @is_last_packet, delivery_time: @delivery_time
            }
    }
  end


  def self.json_create(o)
    net_from_json = new
    net_from_json.id = o['data']['id'].to_i
    net_from_json.sender_node = o['data']['sender_node'].to_i
    net_from_json.receiver_node = o['data']['receiver_node'].to_i
    net_from_json.info_size = o['data']['info_size'].to_i
    net_from_json.service_size = o['data']['service_size'].to_i
    net_from_json.type = o['data']['type'].to_sym
    net_from_json.is_last_packet = o['data']['is_last_packet']
    net_from_json.delivery_time = o['data']['delivery_time'].to_i
    net_from_json
  end
end