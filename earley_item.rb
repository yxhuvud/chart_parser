class EarleyItem
  attr_accessor :state, :origin, :scanned

  def to_s
    if scanned
      "Earley[%s, %s](%s)" % [state, (origin && origin.index), scanned]
    else
      "Earley[%s, %s]" % [state, (origin && origin.index)]
    end
  end

  def initialize state, origin
    raise ArgumentError, "state missing"  unless state
    @state = state
    @origin = origin
  end

  def goto sym
    state.goto(sym)
  end

  def accept?
    state.accept? && (origin.index == 0)
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
    chart.add_item(EarleyItem.new(cont, chart))
    cont.completed.each do |lhs|
      chart.add_item(EarleyItem.new(cont.goto(lhs), origin))
    end
  end

  def to_s
    "Leo[%s, %s, %s]" %
      [state, (origin && origin.index), trans]
  end
end
