require 'spec_helper'
include ProductionRule::Alias

S_prim = GrammarSymbol.new("S_prim")
S = GrammarSymbol.new("S")
A = GrammarSymbol.new("A")
E = GrammarSymbol.new("E")
PRODUCTION_RULES = [
                    rule(S_prim, S),
                    rule(S, A, A, A, A),
                    rule(A, 'a'),
                    rule(A, E),
                    rule(E, GrammarSymbol::EMPTY)
                   ]
TERMINALS = %w(a)

describe Grammar do

  let(:empty_grammar) { Grammar.new([], [], S_prim) }
  let(:grammar) { Grammar.new(PRODUCTION_RULES, TERMINALS, S_prim) }
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
        E.to_e_non_terminal!
        g.split_nullable([E]).should == [[E],
                                         [E.to_e_non_terminal]]
      end

      it "handle multiples" do
        syms = [GrammarSymbol.new('a'), GrammarSymbol.new('b')]
        g.split_nullable(syms).
          should == [syms]
      end

      it "return all permutations" do
        e2 = E.to_e_non_terminal!
        g.split_nullable([E, E]).should == [[E, E],
                                            [E, e2],
                                            [e2, E],
                                            [e2, e2]]
      end
    end

    it "swaps_e_productions" do
      E.to_e_non_terminal

      g.rules = [
                 rule(S, GrammarSymbol::EMPTY),
                 rule(S, GrammarSymbol::e(E)),
                 rule(S, E),
                 rule(S, GrammarSymbol::e(E), E),
                 rule(S, GrammarSymbol::e(E), GrammarSymbol::e(E))
                ]

      g.swap_e_productions
      g.rules.sort_by(&:sort_key).
        should == [
                   rule(GrammarSymbol::e(S), GrammarSymbol::EMPTY),
                   rule(GrammarSymbol::e(S), GrammarSymbol::e(E)),
                   rule(S, E),
                   rule(S, GrammarSymbol::e(E), E),
                   rule(GrammarSymbol::e(S), GrammarSymbol::e(E),
                        GrammarSymbol::e(E))
                  ].sort_by(&:sort_key)
    end
  end
end
