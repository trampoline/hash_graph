require 'tsort'

module HashGraph
  # a simple directed graph representation for TSort,
  # [ TSort implements tarjan's algorithm for finding the
  #   strongly connected components of a graph ]
  # DirectedGraph extends Hash, all nodes have a key in the top-level
  # Hash, and a possibly empty child-hash of node to weight
  # mappings, thus the structure is :
  # {from_v*=>{to_v*=>weight}} and all keys used in the child hashes
  # are guaranteed to also be present in the top-level hash
  class DirectedGraph < Hash
    include TSort

    def self.new_lower_hash(top_hash,from_vertex)
      tos = Hash.new()
      tos.instance_eval do
        ec = class << self ; self ; end
        ec.send(:alias_method, :uhg_store, :store)
        ec.send(:define_method, :store) do |to_vertex,weight|
          top_hash[from_vertex]=tos if !top_hash.key?(from_vertex)
          uhg_store(to_vertex,weight)
          top_hash[to_vertex]=DirectedGraph::new_lower_hash(top_hash,to_vertex) if !top_hash.key?(to_vertex)
        end
        ec.send(:alias_method, :[]=, :store)
      end
      tos
    end

    # construct a DirectedGraph which ensures that all destination node keys
    # are present in the top level Hash
    def initialize()
      super() do |h,from_vertex|
        DirectedGraph::new_lower_hash(h,from_vertex)
      end
    end

    alias tsort_each_node each_key

    def tsort_each_child(node,&block)
      fetch(node).keys.each(&block)
    end
  end

  # an undirected graph representation based on Hash,
  # which ensures that h[a][b]==h[b][a]
  class UndirectedGraph < Hash
    def self.new_lower_hash(top_hash,a_vertex)
      tos = Hash.new()
      tos.instance_eval do
        ec = class << self ; self ; end
        ec.send(:alias_method, :uhg_store, :store)
        ec.send(:define_method, :store) do |b_vertex,weight|
          top_hash[a_vertex]=tos if !top_hash.key?(a_vertex)
          uhg_store(b_vertex,weight)
          if top_hash.key?(b_vertex)
            top_hash[b_vertex]
          else
            top_hash[b_vertex]=UndirectedGraph::new_lower_hash(top_hash,b_vertex)
          end.uhg_store(a_vertex,weight) # ensure reverse link added too
        end
        ec.send(:alias_method, :[]=, :store)
      end
      tos
    end

    def initialize()
      super() do |h,a_vertex|
        UndirectedGraph::new_lower_hash(h,a_vertex)
      end
    end
  end
end
