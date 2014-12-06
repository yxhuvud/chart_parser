RIGHT_RECURSIVE = ChartParser::grammar do
  start :S

  rule :S, 'x', :S
  rule :S, 'x'
end
