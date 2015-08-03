require 'yaml'
class FrontmatterTests < Jekyll::Command
  class << self
    def config
    	@config ||= YAML.load_file '_config.yml'
    end
    def loadschema(file)
      schema = File.join("deploy", "tests", "schema", file)
    	if File.exists?(schema)
        YAML.load_file(schema)
      else
        puts "No schema for #{file}"
        exit 1
      end
    end

    def process(schema)
    	dir = File.join(schema['config']['path'])
    	passfail = nil
    	Dir.open(dir).each do |f|
    		file = File.open(File.join(dir, f))
    		unless schema['config']['ignore'].include?(f)
    			data = YAML.load_file(file)
    			passfail = check_keys(data, schema.keys, f)
    			passfail = check_types(data, schema)
    		end
    	end
    	if passfail
    		return true
    	else
    		return false
    	end
    end

    def check_keys(data, keys, title)
    	keys = keys - ['config']
    	unless data.respond_to?('keys')
    		puts "The file #{title} is missing all frontmatter.".red
    		return false
    	end
    	diff = keys - data.keys
    	if diff == []
    		return true
    	else
    		puts "The file #{title} is missing the following keys:".red
    		for k in diff
    			puts "    * #{k}\n".red
    		end
    		return false
    	end
    end

    # Works in progress: eventually, validate that the *values* match expected types
    #
    # For example, if we expect the `date` key to be in yyyy-mm-dd format, validate
    # that it's been entered in that format. If we expect authors to be an array,
    # make sure we're getting an array.
    def check_types(data, schema)
    	unless data.respond_to?('keys')
    		return false
    	end
    	for s in schema
    		key  = s[0]
    		if s[1].class == Hash
    			type = s[1]['type']
    		else
    			type = s[1]
    		end

    		if type == "Array" and data[key].class == Array
    			return true
    		elsif type == "String" and data[key].class == String
    			return true
    		elsif type == "Date"
          require 'pry'; binding.pry
    			return true
    		else
    			puts "    * Data is of the wrong type for key #{key}, expected #{type} but was #{data[key].class}\n\n"
    			return false
    		end
    	end
    end

    def test_posts
      puts 'testing posts'.green
      yepnope = process(loadschema('_posts.yml'))
      puts 'Finished testing'.green
      yepnope
    end

    def test_collections(collections)
      yepnope = Array.new
      unless collections.class == Array
        require 'pry'; binding.pry
      end
      for c in collections
        puts "Testing #{c}".green
        yepnope.push process(loadschema("_#{c}.yml"))
        puts "Finished testing #{c}".green
      end
      yepnope
    end

    def test_everything
      schema = Dir.open('deploy/tests/schema')
      yepnope = Array.new
      schema.each { |s|
        if s.start_with?('_')
          puts "Testing #{s}".green
          yepnope.push process(loadschema(s))
          puts "Finished testing #{s}".green
        end
      }
      yepnope
    end

    def test_frontmatter(args, options)
      puts 'starting tests'
      results = Array.new
      if options['posts']
        results.push test_posts
      elsif options['collections']
        collections = options['collections'].split(',')
        results.push test_collections(collections)
      else
        results.push test_everything
      end
      results.keep_if { |t| t == false }
      if results[0]
        puts 'Tests finished!'
        exit 0
      else
        puts "The test exited with errors, see above."
        exit 1
      end
    end

    def init_with_program(prog)
      prog.command(:test) do |c|
        c.syntax "test [options]"
        c.description 'Test your site for frontmatter.'

        c.option 'posts', '-p', 'Target only posts'
        c.option 'collections', '-c [COLLECTION]', 'Target a specific collection'
        c.option 'all', '-a', 'Test all collections (Default)'

        c.action do |args, options|
          if options.empty?
            options = {"all" => true}
          end
          test_frontmatter(args, options)
        end
      end
    end
  end
end
