class Constants

  class << self
    attr_accessor :packet_size, :message_size, :update_tables_message_size, :service_size,
                  :node_ping_time, :service_message_size
  end

  self.packet_size = 1000
  # self.message_size = 100
  self.update_tables_message_size = 100
  self.service_message_size = 100
  self.service_size = 100
  self.node_ping_time = 5

end
