require 'jekyll_frontmatter_tests_helper'
require 'pry'

RSpec.describe JekyllFrontmatterTestsHelper do
  before(:each) do
    @helper = JekyllFrontmatterTestsHelper.new
    @schema = ['value', 'value2', 'value3']
    @schema_string = 'value'
    @schema_config = 'tags.yml'
  end

  describe 'JekyllFrontmatterTestsHelper#one_of?' do
    context 'using an Array as the schema' do
      it 'detects passes valid values' do
        data = ['value', 'value2']
        expect(@helper.one_of?(data, @schema)).to be true
      end

      it 'detects invalid values' do
        data = ['value', 'val']
        expect(@helper.one_of?(data, @schema)).to be false
      end

      it 'detects extra values' do
        data = ['value', 'value2', 'value3', 'value4']
        expect(@helper.one_of?(data, @schema)).to be false
      end
    end

    context 'using a String as the schema' do
      it 'detects passes valid value' do
        data = 'value'
        expect(@helper.one_of?(data, @schema_string)).to be true
      end

      it 'detects invalid values' do
        data = 'val2'
        expect(@helper.one_of?(data, @schema_string)).to be false
      end

      it 'detects extra values' do
        data = ['value', 'value2']
        expect(@helper.one_of?(data, @schema_string)).to be false
      end
    end

    context "using a config file as the schema" do
      it 'detects passes valid values' do
        tags = ['tag', 'tag2']
        expect(@helper.one_of?(tags, @schema_config)).to be true
      end

      it 'detects invalid values' do
        tags = ['tag', 'tigger']
        expect(@helper.one_of?(tags, @schema_config)).to be false
      end

      it 'detects extra values' do
        tags = ['tag', 'tag2', 'tag3', 'tag4', 'tag5']
        expect(@helper.one_of?(tags, @schema_config)).to be false
      end
    end
  end
end
