require 'jekyll'
require 'jekyll_frontmatter_tests.rb'
require 'pry'

RSpec.describe Jekyll::Command::FrontmatterTests do
  before(:each) do
    @helper = Jekyll::Command::FrontmatterTests
    @schema = { 'path' => 'spec/support/tests/schema/' }
    @schema_config = '_tests.yml'
    file_path = File.join(Dir.pwd, 'spec', 'support', 'tests', 'schema', @schema_config)
    @schema_file = YAML.load_file(file_path)

    @schema_array = %w(value value2 value3)
    @schema_string = 'value'
    @schema_config = 'tags.yml'
  end

  describe 'JekyllFrontmatterTestsHelper#one_of?' do
    context 'using an Array as the schema' do
      it 'detects passes valid values' do
        data = %w(value value2)
        expect(@helper.one_of?(data, @schema_array)).to be true
      end

      it 'detects invalid values' do
        data = %w(value val)
        expect(@helper.one_of?(data, @schema_array)).to be false
      end

      it 'detects extra values' do
        data = %w(value value2 value3 value4)
        expect(@helper.one_of?(data, @schema_array)).to be false
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
        data = %w(value value2)
        expect(@helper.one_of?(data, @schema_string)).to be false
      end
    end

    context 'using a config file as the schema' do
      it 'detects passes valid values' do
        tags = %w(tag tag2)
        expect(@helper.one_of?(tags, @schema_config)).to be true
      end

      it 'detects invalid values' do
        tags = %w(tag tigger)
        expect(@helper.one_of?(tags, @schema_config)).to be false
      end

      it 'detects extra values' do
        tags = %w(tag tag2 tag3 tag4 tag5)
        expect(@helper.one_of?(tags, @schema_config)).to be false
      end
    end
  end

  describe 'JekyllFrontmatterTestsHelper#required?' do
    context 'not specified as optional, and is in the primary frontmatter' do
      it 'is required' do
        expect(@helper.required?('name', @schema_file)).to be true
      end
    end

    context 'not specified as optional, and is not in the primary frontmatter' do
      it 'gets an error' do
        expect { @helper.required?('fake', @schema_file) }.
          to raise_error(RuntimeError, 'The key provided is not in the schema.')
      end
    end

    context 'specified as optional, and is in the primary frontmatter' do
      it 'is not required' do
        expect(@helper.required?('role', @schema_file)).to be false
        expect(@helper.required?('city', @schema_file)).to be false
      end
    end

    context 'specified as optional, and is not in the primary frontmatter' do
      it 'is not required' do
        expect(@helper.required?('github', @schema_file)).to be false
      end
    end
  end
end
