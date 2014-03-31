require 'set'

class Marpa
  attr_accessor :chart, :source, :state_machine, :state_size
  attr_accessor :previous_chart

  def initialize grammar
    @state_machine = StateMachine.new(grammar)
    @state_size = state_machine.size
    reset
  end

  def reset
    @chart = Chart.new(0, state_size)
    @previous_chart = nil
    chart.add state_machine.starting_state, @chart
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
    @previous_chart = chart
    @previous_chart.memoize_transitions

    @chart = Chart.new(@previous_chart.index.succ, state_size)
    consume sym
  end
  
  def consume sym
    scan_pass sym
    #TODO: Slippers
    return  if chart.empty? 
    reduction_pass
  end

  def success?
    chart.accept?
  end

  def scan_pass sym
    @previous_chart.scan(sym, chart)
  end

  def reduction_pass
    chart.reduce
    chart.memoize_transitions
  end
end
