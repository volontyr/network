class RoutesFinder

  def initialize(network)
    @network = network
  end

  def find_routes(network = nil)
    @network = network unless network.nil?
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