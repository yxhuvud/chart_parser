include ProductionRule::Alias

production_rules = [
                    rule(:Start, :S),

                    rule(:S, :A, :A, :A, :A),

                    rule(:A, 'a'),
                    rule(:A, :e),

                    rule(:e, GrammarSymbol::EMPTY)
                   ]

AMBIGOUS_A = Grammar.new(production_rules, :Start)
