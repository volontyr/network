class RoutesFinder

  def initialize(network)
    @network = network
  end

  def find_routes
    if @network.criteria_for_routes == :min_amount_of_nodes
      true_channels = []
      true_channels = @network.channels.map { |c| c.weight }
      @network.channels.each { |c| c.weight = 1 }
    end

    @network.nodes.reject { |n| n.activity == :non_active }.each do |node|
      node.routes_table = Hash.new
      marked_nodes = Hash.new
      nodes_labels = Hash.new
      @network.nodes.reject { |n| n.activity == :non_active }.each do |n|
        nodes_labels[n.id.to_s] = 1000000000
        marked_nodes[n.id.to_s] = false
        node.routes_table[n.id.to_s] = [] unless n == node
      end
      nodes_labels[node.id.to_s] = 0

      while marked_nodes.values.include?(false)
        current_node = find_min_node_label(nodes_labels, marked_nodes).to_i
        @network.find_node(current_node).channels.each do |c|
          next_node_id = (c.first_node == current_node) ? c.second_node : c.first_node

          next if c.activity == :non_active or @network.find_node(next_node_id).activity == :non_active or
                  marked_nodes[next_node_id.to_s]

          if nodes_labels[current_node.to_s] + c.weight < nodes_labels[next_node_id.to_s]
            nodes_labels[next_node_id.to_s] = nodes_labels[current_node.to_s] + c.weight
            if current_node == node.id
              node.routes_table[next_node_id.to_s] << next_node_id
            else
              node.routes_table[next_node_id.to_s] = node.routes_table[current_node.to_s].clone
              node.routes_table[next_node_id.to_s] << next_node_id
            end
          end
        end
        marked_nodes[current_node.to_s] = true
      end
    end


    @network.nodes.reject { |n| n.activity == :non_active }.each do |node|
      node.routes_table.each do |k, v|
        unless v[0..-2].reverse == @network.find_node(k.to_i).routes_table[node.id.to_s][0..-2]
          if v[0..-2].size <= @network.find_node(k.to_i).routes_table[node.id.to_s][0..-2].size
            @network.find_node(k.to_i).routes_table[node.id.to_s] = v[0..-2].reverse + [node.id]
          else
            node.routes_table[k] = @network.find_node(k.to_i).routes_table[node.id.to_s][0..-2].reverse + [k.to_i]
          end
        end
      end
    end


    if @network.criteria_for_routes == :min_amount_of_nodes
      i = 0
      @network.channels.each do |channel|
        channel.weight = true_channels[i]
        i += 1
      end
    end
  end

  private
    def find_min_node_label(node_labels, nodes_marked)
      min_label = 10000000000
      min_node_id = 0
      node_labels.each do |node_id, label|
        if label < min_label and !nodes_marked[node_id]
          min_label = label
          min_node_id = node_id
        end
      end
      min_node_id
    end
end