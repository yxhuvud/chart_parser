
class StateMachine
  attr_accessor :grammar, :states, :starting_state

  def initialize grammar
    @grammar = grammar.to_nnf
    @states = {}
    generate_states
    mark_accept_states
    mark_recursions
    mark_penults
  end

  def to_s
    states.values.sort_by(&:index).map(&:inspect).join("\n\n")
  end

  def size
    @states.size
  end

  def get dotted
    @states[dotted.sort_by(&:sort_key)]
  end

  def add_state dotted
    new_state = State.new(self, dotted, size + 1)
    @states[dotted.sort_by(&:sort_key)] = new_state
    new_state
  end

  def generate_state from, sym, dotted, queue
    return  if dotted.empty?
    unless (new_state = get(dotted))
      new_state = add_state(dotted)
      queue.unshift new_state
    end
    from.add_transition(sym, new_state)
  end

  def generate_states
    queue = []
    @starting_state = add_state(grammar.start_productions)
    queue.unshift @starting_state
    while(state = queue.shift)
      generate_state(state, ProductionRule::EMPTY,
                     state.nonkernels(grammar), queue)
      transition_states state, queue
    end
  end

  def mark_accept_states
    grammar.start_productions.each do |prod|
      state = @starting_state
      until prod.completed?
        state = state.goto(prod.current)
        prod = prod.next
      end
      state.accept = true
    end
  end

  def mark_recursions
    states.values.each &:mark_recursive
  end

  def mark_penults
    states.values.each &:mark_penult
  end

  def transition_states state, queue
    transitions = state.generate_transitions
    transitions.each do |symbol, dotted_rules|
      generate_state(state, symbol,
                     dotted_rules, queue)
    end
  end
end
