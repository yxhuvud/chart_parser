require 'set'

class Marpa
  attr_accessor :earley_items, :source, :state_machine, :state_size
  attr_accessor :previous_items

  def initialize grammar
    @state_machine = StateMachine.new(grammar)
    @state_size = state_machine.size
    reset
  end

  def reset
    @earley_items = EarleyItems.new(0, state_size)
    @previous_items = nil
    earley_items.add state_machine.starting_state, nil
    self
  end

  def parse source
    @source = source
    consumer = method(:marpa_pass)
    if source.kind_of?(Enumerator)
      source.each &consumer
    else
      source.each_char &consumer
    end
    success?
  end

  def marpa_pass sym
    @previous_items = earley_items
    @previous_items.memoize_transitions

    @earley_items = EarleyItems.new(@previous_items.index.succ, state_size)
    consume sym
  end
  
  def consume sym
    scan_pass sym
    #TODO: Slippers
    return  if earley_items.empty? 
    reduction_pass
  end

  def success?
    earley_items.accept?
  end

  def scan_pass sym
    @previous_items.scan(sym, earley_items)
  end

  def reduction_pass
    earley_items.reduce
   # earley_items.memoize_transitions
  end
end
