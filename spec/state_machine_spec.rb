describe StateMachine do
  let(:empty_grammar) { Grammar.new([], [], S_prim) }
  let(:grammar) { Grammar.new(PRODUCTION_RULES, TERMINALS, S_prim) }
  let(:state_machine) { StateMachine.new(grammar) }
  subject { state_machine }

  its(:states) { should_not be_empty }
  its(:states) { should have(9).items }
  its(:transitions) { should_not be_empty }
  its(:transitions) { should_not have(12).items }

  describe(:start_state) do
    subject { state_machine.starting_state }
    it { state_machine.transitions[subject].should have(2).items }
  end
end
