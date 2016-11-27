class Message
  attr_accessor :delivery_time
  attr_reader :sender_node, :receiver_node, :info_size, :service_size, :type
  @@num = 0

  def initialize(sender_node, receiver_node, info_size, service_size, msg_type)
    @id = @@num
    @@num += 1
    @sender_node = sender_node
    @receiver_node = receiver_node
    @info_size = info_size
    @service_size = service_size
    @type = msg_type
    @delivery_time = 0
  end


end