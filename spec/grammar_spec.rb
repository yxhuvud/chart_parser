require 'spec_helper'

include ProductionRule::Alias

describe Grammar do
  let(:e) { GrammarSymbol.new(:E) }
  let(:start) { GrammarSymbol.new(:Start) }
  let(:s) { GrammarSymbol.new(:S) }
  
  let(:empty_grammar) { Grammar.new([], start) }
  let(:grammar) { AMBIGOUS_A }

  subject { grammar }

  its(:rules) { should_not be_empty }

  it "transform to nnf" do
    subject.to_nnf.should be_kind_of(Grammar::NihilistNormalForm)
  end

  describe Grammar::NihilistNormalForm do
    let(:g) { empty_grammar.to_nnf }
    subject { grammar.to_nnf }

    its(:rules) do
      should have(21).items
    end

    context :split_nullables do
      it "return non-e-syms unchanged" do
        syms = [GrammarSymbol.new('a')]
        g.split_nullable(syms).should == [syms]
      end

      it "splits on e-syms" do
        e.to_e_non_terminal!
        g.split_nullable([e]).should == [[e],
                                         [e.to_e_non_terminal]]
      end

      it "handle multiples" do
        syms = [GrammarSymbol.new('a'), GrammarSymbol.new('b')]
        g.split_nullable(syms).
          should == [syms]
      end

      it "return all permutations" do
        e2 = e.to_e_non_terminal!
        g.split_nullable([e, e]).should == [[e, e],
                                            [e, e2],
                                            [e2, e],
                                            [e2, e2]]
      end
    end

    it "swaps_e_productions" do
      e.to_e_non_terminal

      g.rules = [
                 rule(s, GrammarSymbol::EMPTY),
                 rule(s, GrammarSymbol::e(e)),
                 rule(s, e),
                 rule(s, GrammarSymbol::e(e), e),
                 rule(s, GrammarSymbol::e(e), GrammarSymbol::e(e))
                ]

      g.swap_e_productions
      g.rules.sort_by(&:sort_key).
        should == [
                   rule(GrammarSymbol::e(s), GrammarSymbol::EMPTY),
                   rule(GrammarSymbol::e(s), GrammarSymbol::e(e)),
                   rule(s, e),
                   rule(s, GrammarSymbol::e(e), e),
                   rule(GrammarSymbol::e(s), GrammarSymbol::e(e),
                        GrammarSymbol::e(e))
                  ].sort_by(&:sort_key)
    end
  end
end
