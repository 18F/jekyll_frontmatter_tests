Gem::Specification.new do |s|
  s.description = 'Tests the frontmatter of posts and other collection documents against a schema'
  s.summary     = 'Tests jekyll documents for proper frontmatter'
  s.name        = 'jekyll_frontmatter_tests'
  s.date        = '2015-09-10'
  s.license     = 'CC0'
  s.authors     = ['Greg Boone']
  s.email       = ['gregory.boone@gsa.gov']
  s.version     = '0.0.9'
  s.files       = ['lib/jekyll_frontmatter_tests.rb']
  s.homepage    = 'https://rubygems.org/gems/jekyll_frontmatter_tests'
  s.add_dependency "jekyll", [">= 2.0", "< 4.0"]
  s.add_development_dependency "bundler", "~> 1.7"
  s.add_development_dependency "rspec", "~> 3.0"
  s.add_development_dependency "pry", '~> 0'
end
