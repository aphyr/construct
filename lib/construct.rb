module Construct
  # Construct is extensible, persistent, structured configuration for
  # Ruby and humans with text editors.
  
  require 'yaml'

  LIB_DIR = File.dirname(__FILE__) 
  require LIB_DIR + '/construct/construct' 

  YAML::add_domain_type("aphyr.com,2009", "construct") do |type, val|
    # Not implemented ;)
    ::Construct.load(val)
  end

  # Load a construct from a YAML string
  def self.load(yaml)
    hash = YAML::load(yaml)
    ::Construct::Construct.new(hash)
  end

  # Create a new construct
  def self.new(*args)
    ::Construct::Construct.new(*args)
  end
end
