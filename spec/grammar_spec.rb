require 'spec_helper'

describe Grammar do
  let(:e) { :E }
  let(:start) { :Start }
  let(:s) { :S }
  
  let(:empty_grammar) { Grammar.new([], [start], SymbolTable.new) }
  let(:grammar) { AMBIGOUS_A }

  subject { grammar }

  its(:rules) { should_not be_empty }

  it "transform to nnf" do
   subject.to_nnf.should be_kind_of(Grammar::NihilistNormalForm)
  end

  describe Grammar::NihilistNormalForm do
    let(:g) { empty_grammar.to_nnf }
    subject { grammar.to_nnf }
    let(:gst) { g.symbol_table }
    let(:st) { subject.symbol_table }

   its(:rules) do
     should have(21).items
   end

    context "split_nullables" do
     it "return non-e-syms unchanged" do
       syms = ['a']
       g.split_nullable(syms).should == [syms]
     end

      it "splits on e-syms" do
        gst.e_non_terminal! e
        g.split_nullable([e]).should == [[e], 
                                         [gst.to_e_non_terminal(e)]]
      end

      it "handle multiples" do
        syms = ['a', 'b']
        g.split_nullable(syms).
          should == [syms]
      end

      it "return all permutations" do
        e2 = gst.to_e_non_terminal(e)
        g.split_nullable([e, e]).should == [[e, e],
                                            [e, e2],
                                            [e2, e],
                                            [e2, e2]]
      end
    end

    it "swaps_e_productions" do
      gst.to_e_non_terminal(e)

      g.rules = []
      g.add_rule s, ProductionRule::EMPTY
      g.add_rule(s, gst.e(e))
      g.add_rule(s, e)
      g.add_rule(s, gst.e(e), e)
      g.add_rule(s, gst.e(e), gst.e(e))
      g.swap_e_productions
      swapped = g.rules.sort_by(&:sort_key)

      g.rules = []
      g.add_rule(gst.e(s), ProductionRule::EMPTY)
      g.add_rule(gst.e(s), gst.e(e))
      g.add_rule(s, e)
      g.add_rule(s, gst.e(e), e)
      g.add_rule(gst.e(s), gst.e(e), gst.e(e))
   
      swapped.should == g.rules.sort_by(&:sort_key)
    end
   end
end
