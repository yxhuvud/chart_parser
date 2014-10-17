require 'rspec/its'
require 'rspec/collection_matchers'
RSpec.configure do |config|
  config.expect_with :rspec do |c|
    c.syntax = [:should, :expect]
  end
end


require_relative '../symbol_table'
require_relative '../grammar'
require_relative '../grammar_definition'
require_relative '../production_rule'
require_relative '../state'
require_relative '../state_machine'
require_relative '../earley_item'
require_relative '../chart'
require_relative '../marpa'

require_relative 'examples/palindrome'
require_relative 'examples/a_palindrome'
require_relative 'examples/ambigous_a'
require_relative 'examples/right_recursive'
require_relative 'examples/left_recursive'
