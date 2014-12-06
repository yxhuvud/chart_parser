class EarleyItem
  attr_accessor :state, :origin, :node

  def to_s
    if scanned
      "Earley[%s, %s](%s)" % [state, (origin && origin.index), scanned]
    else
      "Earley[%s, %s]" % [state, (origin && origin.index)]
    end
  end

  def hash
    state.hash + origin.index.hash
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
      new_node = SPPFNode.new(lhs, origin.index, chart.index)
      origin.transitions[lhs].each do |item|
        item.node = new_node
        item.node.family node
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
    # First add the current leaf of the recursion.
    # FIXME: origin.index should be previous item of the leo recursion.
    node = SPPFNode.new(trans, origin.index, chart.index)

    leaf_item = EarleyItem.new(cont, chart)
    chart.add_item(leaf_item)
    # Then reduce from the root.
    cont.completed.each do |lhs|
      node = SPPFNode.new(lhs, origin.index, chart.index)
      recursion_root_item = EarleyItem.new(cont.goto(lhs), origin)
      chart.add_item(recursion_root_item)
    end
  end

  def to_s
    "Leo[%s, %s, %s]" %
      [state, (origin && origin.index), trans]
  end
end
