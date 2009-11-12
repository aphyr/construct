class Construct
  # Construct is extensible, persistent, structured configuration for
  # Ruby and humans with text editors.
 
  APP_NAME = 'Construct'
  APP_VERSION = '0.1.3'
  APP_AUTHOR = 'Kyle Kingsbury'
  APP_EMAIL = 'aphyr@aphyr.com'
  APP_URL = 'http://aphyr.com'
  APP_COPYRIGHT = 'Copyright (c) 2009 Kyle Kingsbury <aphyr@aphyr.com>. All rights reserved.'

  require 'yaml'

  class << self
    attr_writer :schema
  end

  # Define a schema for a key on the class. The class schema is used as the
  # defaults on initialization of a new instance.
  def self.define(key, schema)
    key = key.to_sym if String === key
    @schema[key] = schema
  end 

  # Load a construct from a YAML string
  def self.load(yaml)
    hash = YAML::load(yaml)
    new(hash)
  end

  # Returns the class schema
  def self.schema
    @schema ||= {}
  end

  attr_accessor :schema, :data

  def initialize(data = {}, schema = {})
    @data = Hash.new
    data.each do |key, value|
      self[key] = value
    end
    @schema = self.class.schema.merge(schema)
  end

  def ==(other)
    other.respond_to? :schema and other.respond_to? :data and
      @schema == other.schema and @data == other.data
  end

  def [](key)
    key = key.to_sym if String === key

    if @data.include? key
      @data[key]
    elsif @schema.include? key and @schema[key].include? :default
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

  # Defines a new field in the schema. Fields are :default and :desc.
  def define(key, options = {})
    key = key.to_sym if String === key
    @schema[key] = options
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
    @data.include?(*args) or (@schema.include?(*args) and @schema[*args].include? :default)
  end

  # Returns the keys, both set in the construct and specified in the schema.
  def keys
    @data.keys | @schema.keys
  end

  def load(yaml)
    data = YAML::load(yaml)

    data.each do |key, value|
      self[key] = value
    end
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
      raise NoMethodError.new("no such key #{meth} in construct")
    end
  end

  # Dumps the data (not the schema!) of this construct to YAML. Keys are
  # expressed as strings.
  # 
  # This gets a little complicated.
  #
  # If you define a schema where the default is a Construct
  #
  #   conf.define :sub, :default => Construct
  #
  # and then try to write to it:
  #
  #   conf.sub.opt = 2
  #
  # That opt gets stored on the *schema* sub. Everything works fine... except
  # that when it comes time to serialize there's now *data* buried in the
  # schema tree. Therefore, we write out schema objects as well when they are
  # non-empty.
  def to_yaml(opts = {})
    hash = {}
    @schema.each do |key, value|
      if value[:default].kind_of? Construct
        hashed = YAML::load(value[:default].to_yaml)
        next if hashed.empty?
        hash[key.to_s] = hashed
      end
    end

    @data.each do |key, value|
      hash[key.to_s] = value
    end
    hash.to_yaml(opts)
  end
end
