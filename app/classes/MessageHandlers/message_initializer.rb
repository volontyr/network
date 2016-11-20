class MessageInitializer
  attr_reader :message_size, :service_size, :message_type

  def initialize(message_size, service_size, message_type)
    @message_size = message_size
    @service_size = service_size
    @message_type = message_type
  end
end
