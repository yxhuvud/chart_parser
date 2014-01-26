class StateMachine
  attr_accessor :grammar, :states, :transitions, :starting_state

  def initialize grammar
    @grammar = grammar.to_nnf
    @states = []
    @transitions = Hash.new {|h,k| h[k] = {} }
    generate_states
    @starting_state = @states.first
  end

  def goto state, sym
    transitions[state][sym]
  end

  def add_transition from, to, sym
    transitions[from][sym] = to
  end

  def generate_state from, sym, dotted, queue
    unless (new_state = State.get(dotted))
      new_state = State.new(dotted)
      queue.push new_state
      @states << new_state
    end
    add_transition(from, new_state, sym)
  end

  def generate_states
    start_productions =
      grammar.start_symbols.flat_map {|sym| grammar.matching_rules sym }
    state = State.new(start_productions)
    @states << state
    queue = [state]
    while(state = queue.pop)
      unless state.nonkernels(grammar).empty?
        generate_state(state, GrammarSymbol::EMPTY,
                       state.nonkernels(grammar), queue)
      end
      transitions = state.transitions
      transitions.each do |symbol, dotted_rules|
        generate_state(state, symbol,
                       dotted_rules, queue)
      end
    end
  end

  class State
    class << self
      attr_accessor :states

      def get dotted
        @states ||= {}
        @states[dotted.sort_by(&:sort_key)]
      end
    end

    attr_accessor :dotted_rules, :timestamp

    def to_str
      dotted_rules.inspect
    end

    def initialize dotted_rules
      raise  if dotted_rules.empty?
      raise  unless dotted_rules.all? {|r| r.kind_of? ProductionRule}
      @dotted_rules = dotted_rules.sort_by &:sort_key
      self.class.states ||= {}
      self.class.states[@dotted_rules] = self
    end

    def nonkernels grammar
      expanded_rules = Set.new
      visited = Set.new
      lhss_to_find = dotted_rules.map(&:current).compact.uniq
      while (lhs = lhss_to_find.pop)
        next  if visited.include?(lhs)
        next  if GrammarSymbol::e_non_terminal?(lhs)
        visited << lhs
        expansions = grammar.matching_rules(lhs)
        expansions.each do |exp|

          lhss_to_find << exp.rhs.first
          expanded_rules << exp
        end
      end
      expanded_rules.to_a
    end

    def transitions
      nexts = @dotted_rules.group_by(&:current)
      nexts.each {|k, v|
        nexts[k] = v.map(&:next).compact
      }
      nexts.reject {|k, v| v.empty? }
    end
  end
end
