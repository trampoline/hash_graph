require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

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
    end

  end
end
