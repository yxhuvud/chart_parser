class EarleyItem
  
  attr_accessor :state, :origin

  def to_s
    "Earley[%s, %s]" % [state, (origin && origin.index)]
  end

  def initialize state, origin
    @state = state
    @origin = origin
  end

  def goto sym
    state.goto(sym)
  end

  def accept?
    origin == nil && 
      state.accept?
  end

  def completed
    state.completed
  end

  def postdot_symbols
    state.postdot_symbols
  end
  
  def scan sym, chart
    chart.add goto(sym), origin
  end
  
  def reduce sym, chart
    chart.add(goto(sym), origin)
  end
end

class LeoItem < EarleyItem
  attr_accessor :trans

  def initialize eim, trans
    self.origin = eim.origin
    self.state = eim.state
    self.trans = trans
  end
  
  def reduce sym, chart
    chart.add_item(goto(trans), origin)
  end

  def to_s
    "Leo[%s, %s, %s]" % 
      [state, (origin && origin.index), trans]
  end
end

