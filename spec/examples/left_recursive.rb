LEFT_RECURSIVE = GrammarDefinition.define do 
  start :Start

  rule :Start, :S
  rule :S, :S, 'x'
  rule :S, 'x'  
end
