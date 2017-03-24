require 'jekyll'
require 'jekyll_frontmatter_tests/jekyll_frontmatter_tests_rules'
require 'pry'

RSpec.describe FrontmatterRules do
  before(:each) do
    @rules_service = FrontmatterRules
  end

  describe 'FrontmatterRules#dashless?' do
    context 'receives a sting' do
      it 'does not have dashes' do
        expect(@rules_service.dashless?('value')).to be true
      end

      it 'has dashes' do
        expect(@rules_service.dashless?('value-with-dashes')).to be false
      end

      it 'has dashes, but is in the list of exceptions' do
        expect(@rules_service.dashless?('test-exception')).to be true
      end
    end

    context 'receives an array' do
      it 'does not have dashes' do
        expect(@rules_service.dashless?(%w(value value2))).to be true
      end

      it 'has some with dashes, some without dashes' do
        expect(@rules_service.dashless?(['value', 'value2', 'value-3'])).to be false
      end

      it 'all with dashes' do
        expect(@rules_service.dashless?(['value-1', 'value-2', 'value-3'])).to be false
      end

      it 'all have dashes, but some in the list of exceptions' do
        expect(@rules_service.dashless?(['value-1', 'test-exception', 'value-3'])).to be false
      end

      it 'one has dashes, but it is in the list of exceptions' do
        expect(@rules_service.dashless?(['value1', 'test-exception', 'value3'])).to be true
      end
    end
  end

  describe 'FrontmatterRules#lowercase?' do
    context 'receives a sting' do
      it 'does not have dashes' do
        expect(@rules_service.lowercase?('value')).to be true
      end

      it 'has uppercase' do
        expect(@rules_service.lowercase?('Value')).to be false
      end

      it 'has uppercase, but is in the list of exceptions' do
        expect(@rules_service.lowercase?('Test')).to be true
      end
    end

    context 'receives an array' do
      it 'does not have uppercase' do
        expect(@rules_service.lowercase?(%w(value value2))).to be true
      end

      it 'has some with uppercase' do
        expect(@rules_service.lowercase?(%w(value value2 Value3))).to be false
      end

      it 'all with uppercase' do
        expect(@rules_service.lowercase?(%w(Value1 Value2 Value3))).to be false
      end

      it 'all uppercase, but some in the list of exceptions' do
        expect(@rules_service.lowercase?(%w(Value1 Test))).to be false
      end

      it 'one is uppercase, but it is in the list of exceptions' do
        expect(@rules_service.lowercase?(%w(value1 Test value3))).to be true
      end
    end
  end
end
