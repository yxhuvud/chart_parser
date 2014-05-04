RIGHT_RECURSIVE = GrammarDefinition.define do 
  start :S
  
  rule :S, 'x', :S
  rule :S, 'x'
end
