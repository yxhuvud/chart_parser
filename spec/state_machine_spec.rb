describe StateMachine do
  let(:e) { GrammarSymbol.new("E") } 
  let(:start) { GrammarSymbol.new("Start") } 
  let(:s) { GrammarSymbol.new("S") } 
  
  let(:empty_grammar) { Grammar.new([], [], start) }
  let(:grammar) { AMBIGOUS_A }

  let(:state_machine) { StateMachine.new(grammar) }
  subject { state_machine }

  its(:states) { should_not be_empty }
  its(:states) { should have(9).items }

  describe(:transitions) do 
    subject { state_machine.states.values.map(&:transitions).inject(&:merge) }
    it { should_not be_empty }
    it { should_not have(12).items }
  end
  
  describe(:start_state) do
    subject { state_machine.starting_state }
    its(:transitions) { should have(2).items }
  end
end
