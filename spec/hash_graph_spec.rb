require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
require 'set'

describe HashGraph do
  module HashGraph
    describe DirectedGraph do
      it "should not create a top-level key on top-level access" do
        h = DirectedGraph.new
        h[:foo]
        h.should == {}
      end

      it "should not create a top-level key on second-level access" do
        h = DirectedGraph.new
        h[:foo][:bar]
        h.should == {}
      end

      it "should create a top-level key for new target nodes" do
        h = DirectedGraph.new
        h[:foo][:bar] = 1
        h.should == {:foo=>{:bar=>1}, :bar=>{}}
      end

      it "should create new edges on existing top-level keys" do
        h = DirectedGraph.new
        h[:foo][:bar] = 1
        h[:bar][:baz] = 5
        h.should == {:foo=>{:bar=>1}, :bar=>{:baz=>5}, :baz=>{}}
      end

      describe "to_undirected_graph" do
        it "should convert a directed graph with bi-directional edges to an undirected graph" do
          h = DirectedGraph.new
          h[:foo][:bar] = 1
          h[:bar][:foo] = 3
          h.to_undirected_graph do |a,b,wab,wba| 
            [a,b].to_set.should == [:foo,:bar].to_set
            [wab,wba].to_set.should == [1,3].to_set
            wab+wba
          end.should=={:foo=>{:bar=>4}, :bar=>{:foo=>4}}
        end

        it "should convert a directed graph with asymmetric edges to an undirected graph" do
          h = DirectedGraph.new
          h[:foo][:bar] = 1
          h.to_undirected_graph do |a,b,wab,wba| 
            [a,b].should == [:foo,:bar]
            [wab,wba].should == [1,nil]
            wab
          end.should=={:foo=>{:bar=>1}, :bar=>{:foo=>1}}
        end

        it "should not create undirected edges if the proc returns nil" do
          h = DirectedGraph.new
          h[:foo][:bar] = 1
          h.to_undirected_graph do |a,b,wab,wba| 
            [a,b].should == [:foo,:bar]
            [wab,wba].should == [1,nil]
            nil
          end.should=={}
        end
      end
    end

    describe UndirectedGraph do
      it "should not create a top-level key on top-level access" do
        h = UndirectedGraph.new
        h[:foo]
        h.should == {}
      end

      it "should not create a top-leve key on second level acces" do
        h = UndirectedGraph.new
        h[:foo][:bar]
        h.should == {}
      end

      it "should create the reverse edge on edge creation" do
        h = UndirectedGraph.new
        h[:foo][:bar]=1
        h.should == {:foo=>{:bar=>1}, :bar=>{:foo=>1}}
      end

      it "should extract components from an UndirectedGraph" do
        h=UndirectedGraph.new
        h[:foo][:bar]=1
        h[:foo][:baz]=1
        h[:boo][:woo]=1
        h.components.map(&:to_set).to_set.should == [[:foo, :bar, :baz].to_set, 
                                                     [:boo, :woo].to_set].to_set
      end
    end

  end
end
