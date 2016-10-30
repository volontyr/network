class NetworkRandomGenerator

  def generate(builder, nodes_number, avg_channels_num)
    add_nodes(builder, nodes_number)

    nodes = builder.network.nodes
    (0...2 * avg_channels_num.floor).each do |i|
      ind_1 = (i >= nodes_number) ? i % nodes_number : i
      ind_2 = (i + 1 >= nodes_number) ? (i + 1) % nodes_number : i + 1
      add_channel(builder, nodes[ind_1], nodes[ind_2])
    end

    nodes_len = builder.network.nodes.size
    builder.network.nodes.each do |node|
      if node.channels.empty?
        begin
          rand_ind = rand(0...nodes_len)
        end while builder.network.nodes[rand_ind].channels.empty?
        add_channel(builder, node, builder.network.nodes[rand_ind])
      end
    end

    channels_num = builder.network.channels.size
    channels_num_must_be = avg_channels_num * nodes_number / 2

    (channels_num_must_be.to_i - channels_num.to_i).times do
      begin
        rand_ind_1 = rand(0...nodes_len)
        rand_ind_2 = rand(0...nodes_len)
        condition = (builder.network.nodes[rand_ind_1].channels &
            builder.network.nodes[rand_ind_2].channels != [] || rand_ind_1 == rand_ind_2)
      end while condition
      add_channel(builder, builder.network.nodes[rand_ind_1], builder.network.nodes[rand_ind_2])
    end

  end

  private
    def add_nodes(builder, nodes_number)
      x, y = 0, 0
      (1..nodes_number).each do
        builder.add_node(x, y)
        # TO CHANGE
        x += 50
        # TO CHANGE
        y += 50
      end
    end

    def add_channel(builder, node_1, node_2)
      weights_len = builder.network.channel_weights.size
      weight = builder.network.channel_weights[rand(0...weights_len)]
      error_prob = rand(0..99) / 100
      builder.add_channel(weight, error_prob, :duplex, node_1, node_2)
    end
end