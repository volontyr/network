class NetworkRandomGenerator

  def generate(builder, nodes_number, avg_channels_num)
    satellite_channels = 0
    add_nodes(builder, nodes_number)

    nodes = builder.network.nodes
    (0...2 * avg_channels_num.floor).each do |i|
      ind_1 = (i >= nodes_number) ? i % nodes_number : i
      ind_2 = (i + 1 >= nodes_number) ? (i + 1) % nodes_number : i + 1
      if satellite_channels < 3
        builder.add_random_channel(:duplex, nodes[ind_1], nodes[ind_2], :satellite)
        satellite_channels += 1
      else
        builder.add_random_channel(:duplex, nodes[ind_1], nodes[ind_2])
      end
      break if ind_2 == 0
    end

    builder.network.nodes.each do |node|
      if node.channels.empty?
        begin
          rand_ind = rand(0...nodes_number)
        end while builder.network.nodes[rand_ind].channels.empty?
        builder.add_random_channel(:duplex, node, builder.network.nodes[rand_ind])
      end
    end

    channels_num = builder.network.channels.size
    channels_num_must_be = avg_channels_num * nodes_number / 2

    (channels_num_must_be.to_i - channels_num.to_i).times do
      begin
        rand_ind_1 = rand(0...nodes_number)
        rand_ind_2 = rand(0...nodes_number)
        condition = (builder.network.nodes[rand_ind_1].channels &
            builder.network.nodes[rand_ind_2].channels != [] || rand_ind_1 == rand_ind_2)
      end while condition
      if satellite_channels < 3
        builder.add_random_channel(:duplex, builder.network.nodes[rand_ind_1],
                                   builder.network.nodes[rand_ind_2], :satellite)
        satellite_channels += 1
      else
        builder.add_random_channel(:duplex, builder.network.nodes[rand_ind_1],
                                   builder.network.nodes[rand_ind_2])
      end
    end

    builder.network.nodes[rand(0...nodes_number)].type = :central
  end

  private
    def add_nodes(builder, nodes_number)
      calculator = builder.coordinates_calculator
      calculator.nodes_number = nodes_number
      x = calculator.initial_x
      y = calculator.calculate_y(x)
      (1..nodes_number).each do
        builder.add_node(x, y)
          x = calculator.calculate_x(x)
          y = calculator.calculate_y(x)
      end
    end
end