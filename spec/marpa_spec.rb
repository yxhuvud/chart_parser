require 'spec_helper'

describe Marpa do 
  let!(:palindrome) { PALINDROME }
  let!(:ambigous_a) { AMBIGOUS_A }

  describe :palindrome do 
    let(:parser) { Marpa.new(palindrome) }
    subject { parser }
    its(:earley_items) { should have(2).items }
    
    describe :empty do
      before { @result = parser.parse("") }
      it("fails") { @result.should be_false }
      
      describe :items do 
        subject { parser.earley_items}
        its(:items) { should have(2).items }
      end
    end

    describe :one_char do 
      before { @result = parser.parse("a") }
      it("succeds") { @result.should be_true }
    end

    it "parse 'ab'" do 
      subject.parse("ab").should be_false
    end

    it "parse 'ab'" do 
      subject.parse("ab").should be_false
    end

    it "parse 'abc'" do 
      subject.parse("abc").should be_false
    end

    it "parse 'aba'" do 
      subject.parse("a")
      r.should be_true
      r = subject.parse("b")
      r.should be_false
      r = subject.parse("a")
      r.should be_true
      r = subject.parse("a")
      r.should be_false
      r = subject.parse("b")
      r.should be_false
      r = subject.parse("a")
      r.should be_true
    end

    describe :multiple_chars do 
      before { @result = parser.parse("abaab") }
      it("fails") { @result.should be_false }
      it("succeeds after continuing") do
        result = parser.parse("a")
        puts
        p subject.previous_items
        p subject.previous_items.transitions
        
        p subject.earley_items
        
        result.should be_true 
      end

    end

    it "parse 'abaaba'" do 
      subject.parse("abaaba").should be_true
    end

    it "parse 'abcba'" do 
      subject.parse("abcba").should be_true
    end
  end
end
