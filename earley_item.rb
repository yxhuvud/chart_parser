class EarleyItem
  attr_accessor :state, :origin

  def to_s
    "Earley[%s, %s]" % [state, (origin && origin.index)]
  end

  def initialize state, origin
    raise  unless state

    @state = state
    @origin = origin
  end

  def goto sym
    state.goto(sym)
  end

  def accept?
    state.accept?
  end

  def completed
    state.completed
  end

  def postdot_symbols
    state.postdot_symbols
  end
  
  def reduce chart
    completed.each do |lhs|
      origin.transitions[lhs].each do |item|
        chart.add(item)
      end
    end
  end
end

class LeoItem < EarleyItem
  attr_accessor :trans

  def initialize state, origin, trans
    raise  unless state
    self.origin = origin
    self.state = state
    self.trans = trans
  end  

  def reduce chart
    cont = goto(trans)
    cont.completed.each do |lhs|
      chart.add(EarleyItem.new(cont.goto(lhs), chart))
    end
  end

  def to_s
    "Leo[%s, %s, %s]" % 
      [state, (origin && origin.index), trans]
  end
end

