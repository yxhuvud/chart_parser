LEFT_RECURSIVE = GrammarDefinition.define do 
  start :S

  rule :S, :S, 'x'
  rule :S, 'x'  
end
