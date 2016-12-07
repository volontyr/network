require 'json'

class MessagesStack
  attr_accessor :canceled_messages, :received_messages, :info_messages, :service_messages

  def initialize
    @canceled_messages = []
    @received_messages = []
    @info_messages = []
    @service_messages = []
  end


  def push(message, status=:received)
    if status == :canceled
      @canceled_messages << message
    elsif status == :received
      @received_messages << message
    end

    if message.type == :info
      @info_messages << message
    else
      @service_messages << message
    end
  end


  def to_json(*a)
    as_json.to_json(*a)
  end


  def as_json(options = {})
    {
        json_class: self.class.name,
        data:
            {
                canceled_messages: @canceled_messages, received_messages: @received_messages,
                info_messages: @info_messages, service_messages: @service_messages
            }
    }
  end


  def self.json_create(o)
    net_from_json = new
    net_from_json.canceled_messages = o['data']['canceled_messages']
    net_from_json.received_messages = o['data']['received_messages']
    net_from_json.info_messages = o['data']['info_messages']
    net_from_json.service_messages = o['data']['service_messages']
    net_from_json
  end
end