require 'pry'
require 'yaml'

class FrontmatterTests < Jekyll::Command
  class << self
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
              puts "    * '#{data[key]}' was not in the list " \
                   "of expected values in #{file}.".red
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
          puts "    * '#{key}' is not a valid key in #{file}. " \
               "Expected #{type} but was #{data[key].class}\n\n"
          return false
        end
      end
    end
  end
end
