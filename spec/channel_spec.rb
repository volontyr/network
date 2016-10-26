require 'rspec/core'
require_relative '../app/classes/channel'
require_relative '../app/classes/satellite_channel'
require_relative '../app/classes/usual_channel'

describe 'Channels' do

  it 'must be duplex or half duplex type only' do
    channel_1 = Channel.new(10, 0.3, :duplex)
    channel_2 = Channel.new(10, 0.3, :half_duplex)
    channel_3 = Channel.new(10, 0.3)
    expect(channel_1.type).to eq(:duplex)
    expect(channel_2.type).to eq(:half_duplex)
    expect(channel_3.type).to eq(:duplex)
  end

  it 'raises exception when set wrong type' do
    channel = Channel.new(10, 0.2)
    expect { channel.type = :not_duplex }.to raise_exception(ArgumentError)
  end

  it 'raises exception when set not numeric or negative weight' do
    channel = Channel.new(10, 0.2)
    channel.weight = 17
    expect(channel.weight).to eq(17)
    expect { channel.weight = -5 }.to raise_exception(ArgumentError)
    expect { channel.weight = 'five' }.to raise_exception(ArgumentError)
  end

  it 'raises exception when set probability not in range 0..1' do
    channel = Channel.new(10, 0.2)
    channel.error_prob = 0.1
    expect(channel.error_prob).to eq(0.1)
    expect { channel.error_prob = 1.1 }.to raise_error(ArgumentError)
  end
end