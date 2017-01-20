require 'yaml'
require 'jekyll'
require 'pry'
require 'rb-readline'

require_relative 'jekyll_frontmatter_tests/jekyll_frontmatter_tests_config'
require_relative 'jekyll_frontmatter_tests/jekyll_frontmatter_tests_initializer'
require_relative 'jekyll_frontmatter_tests/jekyll_frontmatter_tests_tester'
require_relative 'jekyll_frontmatter_tests/jekyll_frontmatter_tests_loader'
require_relative 'jekyll_frontmatter_tests/jekyll_frontmatter_tests_processor'
require_relative 'jekyll_frontmatter_tests/jekyll_frontmatter_tests_validator'
require_relative 'jekyll_frontmatter_tests/jekyll_frontmatter_tests_helper'

module Boolean; end
class TrueClass; include Boolean; end
class FalseClass; include Boolean; end
