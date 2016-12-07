require_relative 'channel'

class UsualChannel < Channel
  def initialize(weight = 0, error_prob = 0, type = :duplex)
    super(weight, error_prob, type)
    @time_coefficient = 1000.0
  end
end