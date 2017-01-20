require 'jekyll'
require 'yaml'
require 'jekyll_frontmatter_tests/jekyll_frontmatter_tests_loader'
require 'jekyll_frontmatter_tests/jekyll_frontmatter_tests_config'
require 'pry'

RSpec.describe Jekyll::Command::FrontmatterTests do
  before(:each) do
    @helper = Jekyll::Command::FrontmatterTests
    @schema = { 'path' => 'spec/support/tests/schema/' }
    @schema_config = '_tests.yml'
  end

  describe 'JekyllFrontmatterTestsHelper#load_schema' do
    context 'accepts an argument `file`' do
      it 'detects passes valid values' do
        data = %w(value value2)

        allow(Jekyll::Command::FrontmatterTests).to receive(:schema_config).
          and_return(@schema)

        file_path = File.join(Dir.pwd, 'spec', 'support', 'tests', 'schema/_tests.yml')
        file = YAML.load_file(file_path)

        expect(@helper.load_schema(@schema_config)).to eq file
      end
    end
  end
end
