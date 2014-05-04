require 'set'

class Marpa
  attr_accessor :chart, :source, :state_machine, :state_size
  attr_accessor :previous_chart, :charts

  def initialize grammar
    @state_machine = StateMachine.new(grammar)
    @state_size = state_machine.size
    @charts = []
    reset
  end

  def reset
    charts[0] = @chart = Chart.new(0, state_size)
    @previous_chart = nil
    chart.add(EarleyItem.new(state_machine.starting_state, @chart))
    self
  end

  def parse source
    @source = source
    consumer = method(:marpa_pass)
    generator = source.kind_of?(Enumerator) ?  source : source.each_char
    generator.each.with_index &consumer
    success?
  end

  def marpa_pass sym, index
    @previous_chart = chart
    @previous_chart.memoize_transitions
    @chart = Chart.new(@previous_chart.index.succ, state_size)
    charts[index + 1] = chart
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
  end
end
