module Construct
  class Construct

    attr_accessor :schema, :data

    yaml_as "tag:aphyr.com,2009:construct"
    yaml_as "tag:yaml.org,2002:map"

    def initialize(data = {}, schema = {})
      @data = Hash.new
      data.each do |key, value|
        self[key] = value
      end
      @schema = schema
    end

    def ==(other)
      @schema == other.schema and @data == other.data
    end

    def [](key)
      key = key.to_sym if String === key

      if @data.include? key
        @data[key]
      elsif @schema.include? key
        @schema[key][:default]
      end 
    end

    # Assign a value to a key. Constructs accept only symbols as values,
    # and will convert strings to symbols when necessary. They will also
    # implicitly convert Hashes as values into Constructs when possible. Hence
    # you can do:
    #
    # construct.people = {:mary => 'Awesome', :joe => 'suspicious'}
    # construct.people.mary # => 'Awesome'
    def []=(key, value)
      key = key.to_sym if String === key
      raise ArgumentError.new('construct only accepts symbols (and strings) as keys.') unless key.is_a? Symbol

      # Convert suitable hashes into Constructs
      if value.is_a? Hash
        if value.keys.all? { |k| 
              k.is_a? String or k.is_a? Symbol
            }
          value = Construct.new(value)
        end
      end

      @data[key] = value
    end

    # Clears the data in the construct.
    def clear
      @data.clear
    end

    # delete simply removes the value from the data hash, but leaves the schema
    # unchanged.  Hence the construct may still respond to include? if the
    # schema defines that field. Use #schema.delete(:key) to remove the key
    # entirely.
    def delete(key)
      key = key.to_sym if String === key
      @data.delete key
    end

    # Returns true if the construct has a value set for, or the schema defines,
    # the key.
    def include?(*args)
      @data.include?(*args) or @schema.include?(*args)
    end

    # Returns the keys, both set in the construct and specified in the schema.
    def keys
      @data.keys | @schema.keys
    end

    def load(str)
    end

    def method_missing(meth, *args)
      meth_s = meth.to_s
      if meth_s[-1..-1] == '='
        # Assignment
        if args.size != 1
          raise ArgumentError.new("#{meth} takes exactly one argument")
        end

        self[meth_s[0..-2]] = args[0]
      elsif include? meth
        self[meth]
      else
        raise NoMethodError.new('no such key in construct')
      end
    end

    # Dumps the data (not the schema!) of this construct to YAML. Keys are
    # expressed as strings.
    def to_yaml(opts = {})
      YAML::quick_emit(self, opts) do |out|
        out.map(taguri, to_yaml_style) do |map|
          @data.each do |key, value|
            map.add(key.to_s, value)
          end
        end
      end
    end
  end
end
