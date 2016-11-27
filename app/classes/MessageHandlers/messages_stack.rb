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
end