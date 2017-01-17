require 'jekyll'
require 'jekyll/command'
require 'jekyll_frontmatter_tests.rb'
require 'pry'

RSpec.describe Jekyll::Command::FrontmatterTests do
  before(:each) do
    @helper = Jekyll::Command::FrontmatterTests
    @config = 'tests/schema/'
  end

  describe 'JekyllFrontmatterTestsConfig#schema_config' do
    context 'frontmatter_tests attribute is not specified' do
      it 'returns the appropriate path' do
        config = { 'path' => 'deploy/tests/schema' }
        expect(@helper.schema_config).to eq config
      end
    end

    context 'frontmatter_tests attribute is specified' do
      it 'returns the appropriate path' do
        test_config = {
          'frontmatter_tests' => {
            'path' => 'deploy/tests/schema'
          }
        }

        allow(Jekyll).to receive(:configuration).
          and_return(test_config)

        config = { 'path' => 'deploy/tests/schema' }
        expect(@helper.schema_config).to eq config
      end
    end
  end
end
