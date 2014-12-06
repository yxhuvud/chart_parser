require 'spec_helper'

describe ParseGenerator do
  subject { ParseGenerator.new(parser) }

  describe :left do
    let!(:parser) { Parser.new(LEFT_RECURSIVE) }
    before { parser.parse "x" }

    it "generate tree for one char input" do
    end
  end

  describe :leo do
    let!(:parser) { Parser.new(RIGHT_RECURSIVE) }
  end

  describe :a_palindrome do
    let!(:parser) { Parser.new(A_PALINDROME) }
  end

end
