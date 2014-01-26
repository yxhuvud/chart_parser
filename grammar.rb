require 'set'

class Grammar
  attr_reader :rules, :terminals, :start_symbols

  def initialize rules, terminals, *start_symbols
    @rules = Set.new(rules)
    @terminals = Set.new(terminals)
    @start_symbols = GrammarSymbol.builder(*start_symbols)
  end

  def rules= arr
    @rules = Set.new(arr)
  end

  def terminals= arr
    @terminals = Set.new(arr)
  end

  def add_rule lhs, *rhs
    new = ProductionRule.new(lhs, rhs)
    unless rules.find {|r| r == new }
      rules << new
    end
    new
  end

  def remove_rule rule
    rules.delete(rule)
  end

  def null_rules
    rules.select &:empty?
  end

  def print_rules
    puts rules.sort_by(&:sort_key).map(&:to_s).join("\n")
  end

  def matching_rules sym
    rs = rules.select do |rule|
      sym == rule.lhs
    end
    rs.each do |r|
      pos = 0
      while GrammarSymbol::e_non_terminal?(r.rhs[pos])
        pos += 1
      end
      r.pos = pos
    end
    rs
  end

  def to_nihilist_normal_form
    NihilistNormalForm.new self
  end
  alias to_nnf to_nihilist_normal_form


  class NihilistNormalForm < Grammar

    def initialize grammar
      super([], grammar.terminals, grammar.start_symbols)
      add_nullables_from grammar
      foo = 0
      begin
        previous = rules.dup
        add_split_rules_from grammar
        swap_e_productions
        foo += 1
      end while previous.to_a != rules.to_a
    end

    def add_nullables_from grammar
      grammar.null_rules.each do |rule|
        lhs = rule.lhs
        GrammarSymbol::e_non_terminal!(GrammarSymbol::e(lhs))
      end
    end

    def add_split_rules_from grammar
      grammar.rules.each do |rule|
        rhss = split_nullable rule.rhs
        rhss.each do |rhs|
          add_rule rule.lhs, *rhs
        end
      end
    end

    def swap_e_productions
      rules_to_add = []
      rules_to_remove = []
      rules.each do |rule|
        next  if rule.lhs.e_non_terminal?
        lhs, rhs = rule.lhs, rule.rhs
        if rhs.all?(&:e_non_terminal?) ||
            rhs == [GrammarSymbol.new(GrammarSymbol::EMPTY)]
          rules_to_remove << rule
          rules_to_add << [lhs.to_e_non_terminal, rhs]
        end
      end
      rules_to_add.map do |lhs, rhs|
         add_rule lhs, *rhs
      end
      rules_to_remove.map do |r|
        remove_rule r
        # If this was the last with this lhs, remove all rules that
        # produce lhs in its rhs.
        # Todo: Make less horribly inefficient.
        unless rules.any? {|rr| rr.lhs == r.lhs }
          rules.each do |rr|
            remove_rule rr  if rr.rhs.include? r.lhs
          end
        end
      end
    end

    def split_nullable rhs
      return []  if rhs.empty?
      first, *rest = rhs
      partial_results = split_nullable(rest)
      current = if first.has_e_non_terminal?
                  [first, first.to_e_non_terminal]
                else
                  [first]
                end
      current.flat_map do |sym|
        if partial_results.empty?
          [[sym]]
        else
          partial_results.map do |partial|
            [sym] + partial
          end
        end
      end
    end
  end

end
