require 'spec_helper'

describe Chart do 
  let!(:right_recursive_stm) { StateMachine.new(RIGHT_RECURSIVE) }
  let!(:left_recursive_stm) { StateMachine.new(LEFT_RECURSIVE) }
  let!(:palindrome_stm) { StateMachine.new(PALINDROME) }

  describe "scan" do 
  end

  describe "reduce" do 
  end

  pending "transitions"
  pending "psl"
  
end
