require 'yaml'
require 'pry'

class FrontmatterTests < Jekyll::Command
  class << self
    # Public: Load a schema from file.
    #
    # file - a string containing a filename
    #
    # Used throughout to load a specific file. In the future the directories
    # where these schema files are located could be loaded from _config.yml
    #
    # Returns a hash loaded from the YAML doc or exits 1 if no schema file
    # exists.
    def loadschema(file)
      schema = File.join(@schema['path'], file)
      if File.exist?(schema)
        YAML.load_file(schema)
      else
        puts "No schema for #{file}"
        exit 1
      end
    end

    # Public: processes a collection against a schema
    #
    # schema - the hash-representation of a schema file
    #
    # Opens each file in the collection's expected directory and checks the
    # file's frontmatter for the expected keys and the expected format of the
    # values.
    #
    # NOTE - As it iterates through files, subdirectories will be ignored
    #
    # Returns true or false depending on the success of the check.
    def process(schema)
      dir = File.join(schema['config']['path'])
      passfail = []
      Dir.open(dir).each do |f|
        next if File.directory?(File.join(dir, f))
        file = File.open(File.join(dir, f))
        next if schema['config']['ignore'].include?(f)
        data = YAML.load_file(file)

        passfail.push check_keys(data, schema.keys, f)
        passfail.push check_types(data, schema, File.join(dir, f))
      end
      passfail.keep_if { |p| p == false }
      if passfail.empty?
        return true
      else
        puts "There were #{passfail.count} errors".red
        return false
      end
    end

    # Public: checks a hash for expected keys
    #
    # target - the hash under test
    # keys - an array of keys the data is expected to have, usually loaded from
    #        a schema file by loadschema()
    # title - A string representing `data`'s name
    def check_keys(target, keys, title)
      keys -= ['config']
      unless target.respond_to?('keys')
        puts "The file #{title} is missing all frontmatter.".red
        return false
      end
      diff = keys - target.keys
      if diff.empty?
        return true
      else
        puts "\nThe file #{title} is missing the following keys:".red
        for k in diff
          puts "    * #{k}".red
        end
        return false
      end
    end

    # Public: tests all documents that are "posts"
    #
    # Loads a schema called _posts.yml and processes all post documents against
    # it.
    def test_posts
      puts 'testing posts'.green
      yepnope = [].push process(loadschema('_posts.yml'))
      puts 'Finished testing'.green
      yepnope
    end

    # Public: Tests only specific collection documents
    #
    # collections - a comma separated string of collection names.
    #
    # `collections` is split into an array and each document is loaded and
    # processed against its respective schema.
    def test_collections(collections)
      yepnope = []
      for c in collections
        puts "Testing #{c}".green
        yepnope.push process(loadschema("_#{c}.yml"))
        puts "Finished testing #{c}".green
      end
      yepnope
    end

    # Public: Tests all collections described by a schema file at
    # `deploy/tests/scema`
    def test_everything
      schema = Dir.open(@schema['path'])
      yepnope = []
      schema.each do |s|
        next unless s.start_with?('_')
        puts "Testing #{s}".green
        yepnope.push process(loadschema(s))
        puts "Finished testing #{s}".green
      end
      yepnope
    end

    # Public: Processes options passed throguh the command line, runs
    # the appropriate tests.
    #
    # args - command line arguments (example: jekyll test [ARG])
    # options - command line options (example: jekyll test -[option] [value])
    #
    # Depending on the flag passed (see `init_with_program`), runs the expected # test.
    #
    # Example: the following comamnd `jekyll test -p` will pass ``{'posts' =>
    #          true}` as `options`. This will cause `test_frontmatter` to
    #          compare all docs in _posts with the provided schema.
    #
    # The test runner pushes the result of each test into a `results` array and # exits `1` if any tests fail or `0` if all is well.
    def test_frontmatter(_args, options)
      puts 'starting tests'
      if options['posts']
        results = test_posts
      elsif options['collections']
        collections = options['collections'].split(',')
        results = test_collections(collections)
      else
        results = test_everything
      end
      if results.find_index { |r| r == false }
        puts 'The test exited with errors, see above.'
        exit 1
      else
        puts 'Tests finished!'
        exit 0
      end
    end

    # Internal: fired when `jekyll test` is run.
    #
    # When `jekyll test` runs, `test_frontmatter` is fired with options and args
    # passed from the command line.
    def init_with_program(prog)
      config = Jekyll.configuration
      unless config.key?('frontmatter_tests')
        config['frontmatter_tests'] = { 'path' => File.join('deploy', 'tests', 'schema') }
      end
      @schema ||= config['frontmatter_tests']
      prog.command(:test) do |c|
        c.syntax 'test [options]'
        c.description 'Test your site for frontmatter.'

        c.option 'posts', '-p', 'Target only posts'
        c.option 'collections', '-c [COLLECTION]', 'Target a specific collection'
        c.option 'all', '-a', 'Test all collections (Default)'

        c.action do |args, options|
          options = { 'all' => true } if options.empty?
          test_frontmatter(args, options)
        end
      end
    end

    # Internal: eventually, validate that the *values* match expected types
    #
    # For example, if we expect the `date` key to be in yyyy-mm-dd format, validate
    # that it's been entered in that format. If we expect authors to be an array,
    # make sure we're getting an array.
    def check_types(data, schema, file)
      return false unless data.respond_to?('keys')
      schema.each do |s|
        key = s[0]
        value = s[1]
        type = if value.class == Hash
                 value['type']
               else
                 value
               end
        next unless required?(key, schema)
        if key == 'config'
          next
        elsif value.class == Hash
          if value.keys.include? 'one_of'
            if !one_of?(data[key], value['one_of'])
              puts "    * '#{data[key]}' was not in the list of expected values in #{file}.".red
              puts "      expected one of the following: #{s[1]['one_of']}\n".red
              return false
            else
              next
            end
          else
            next
          end
        elsif type == 'Array' && data[key].class == Array
          next
        elsif type == 'Boolean' && data[key].is_a?(Boolean)
          next
        elsif type == 'String' && data[key].class == String
          next
        elsif type == 'Date'
          next
        else
          puts "    * '#{key}' is not a valid key in #{file}. Expected #{type} but was #{data[key].class}\n\n"
          return false
        end
      end
    end

    private

    def one_of?(data, schema)
      if schema.instance_of?(Array) && data.instance_of?(Array)
      elsif schema.include? '.yml'
        schema_list = YAML.load_file(File.join(Dir.pwd, 'tests', 'schema', schema))
        (schema_list & data).count == data.count
      else
        schema.include? data
      end
    end

    def required?(key, schema)
      if schema['config']
        !schema['config']['optional'].include? key
      else
        true
      end
    end
  end
end

module Boolean; end
class TrueClass; include Boolean; end
class FalseClass; include Boolean; end
