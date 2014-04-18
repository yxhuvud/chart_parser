RIGHT_RECURSIVE = GrammarDefinition.define do 
  start :Start

  rule :Start, :S
  
  rule :S, 'x', :S
  rule :S, 'x'
end
