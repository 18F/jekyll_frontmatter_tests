require 'pry'
require 'yaml'


class JekyllFrontmatterTestsHelper
  def one_of?(data, schema)
    if schema.instance_of?(Array) && data.instance_of?(Array)
      (schema & data).count == data.count
    elsif schema.include? '.yml'
      schema_list = YAML.load_file(File.join(Dir.pwd, 'tests', 'schema', schema))
      (schema_list & data).count == data.count
    elsif schema.instance_of?(String) && data.instance_of?(Array)
      false
    else
      schema == data
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
