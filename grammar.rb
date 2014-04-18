require 'set'

class Grammar
  attr_reader :rules, :start_symbols, :symbol_table

  def initialize rules, start_symbols, symbol_table
    @rules = Set.new(rules)
    @symbol_table = symbol_table
    @start_symbols = start_symbols.map {|s| symbol_table.add(s) }
  end

  def rules= arr
    @rules = Set.new(arr)
  end

  def add_rule lhs, *rhs
    new = ProductionRule.new(lhs, rhs, symbol_table)
    unless rules.detect {|r| r == new }
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
    rs.each &:consume_e_non_terminals
    rs
  end

  def start_productions
    start_symbols.flat_map {|sym| matching_rules(sym) }
  end
  
  def to_nihilist_normal_form
    NihilistNormalForm.new self
  end
  alias to_nnf to_nihilist_normal_form

  class NihilistNormalForm < Grammar

    def initialize grammar
      super([], grammar.start_symbols, grammar.symbol_table)
      add_nullables_from grammar
      begin
        previous = rules.dup
        add_split_rules_from grammar
        swap_e_productions
      end while previous.to_a != rules.to_a
    end

    def add_nullables_from grammar
      grammar.null_rules.each do |rule|
        lhs = rule.lhs
        symbol_table.e_non_terminal!(symbol_table.e(lhs))
      end
    end

    def add_split_rules_from grammar
      grammar.rules.each do |rule|
        rhss = split_nullable(rule.rhs)
        rhss.each do |rhs|
          add_rule rule.lhs, *rhs
        end
      end
    end

    def swap_e_productions
      rules_to_add = []
      rules_to_remove = []
      rules.each do |rule|
        next  if symbol_table.e_non_terminal? rule.lhs
        lhs, rhs = rule.lhs, rule.rhs
        if rhs.all? {|s| symbol_table.e_non_terminal?(s) } ||
            rhs == [ProductionRule::EMPTY]
          rules_to_remove << rule
          rules_to_add << [symbol_table.to_e_non_terminal(lhs), rhs]
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
      current = if symbol_table.has_e_non_terminal? first
                  [first, symbol_table.to_e_non_terminal(first)]
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
