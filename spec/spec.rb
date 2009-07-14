#!/usr/bin/ruby

require 'rubygems'
require 'bacon'
require File.dirname(__FILE__) + '/../lib/construct'

describe "An open Construct" do
  before do
    @c = Construct.new

    @complex = Construct.new
    @complex.foo = "hi"
    @complex.bar = {:baz => 2}
    @complex.bar.zoom = [1,2,3]

    @yaml = <<HERE
--- 
foo: hi
bar: 
  baz: 2
  zoom: 
  - 1
  - 2
  - 3
HERE



  end

  it 'should not respond to unspecified keys' do
    should.raise(NoMethodError) { @c.foo }
  end

  it 'should accept assignments' do
    @c[:foo] = 1
    @c.include?(:foo).should.be.true
    @c[:foo].should.equal 1

    @c.bar = 2
    @c.bar.should.equal 2
  end

  it 'should not accept keys other than symbols and strings' do
    should.raise(ArgumentError) do
      @c[2] = "zoom"
    end
  end

  it 'should be indifferent to strings vs. symbols' do
    @c[:foo].should.equal @c['foo']
  end

  it 'should delete keys' do
    @c.delete :foo
    should.raise(NoMethodError) { @c.foo }
  end

  it 'should transparently convert hashes to constructs on assignment' do
    @c.people = {
      :mary => true,
      :joe => false
    }
    @c.people.mary.should.equal true
  end

  it 'should not convert inappropriate hashes on assignment' do
    @c.numbers = {
      2 => 1
    }
    @c.numbers.should.equal({2 => 1})
  end

  it 'should serialize to YAML' do
    @complex.to_yaml.should.equal @yaml
  end

  it 'should load from YAML' do
    yaml = YAML::dump @complex
    @loaded = Construct.load(yaml)
    @complex.should.equal @loaded
  end
end

describe 'A structured construct' do
  before do
    @c = Construct.new
    @c.define :foo, :default => 'hello world', :desc => 'A field for foos.'
  end

  it 'should use default values from the schema' do
    @c.foo.should.equal 'hello world'
  end

  it 'should allow the schema to be overridden by assignment' do
    @c.foo = 'hey'
    @c.foo.should.equal 'hey'
  end

  it 'should preserve nested schemas on load' do
    class Conf < Construct
      def initialize(*args)
        super *args
        define :db, :default => Construct.new
        db.define :host, :default => '127.0.0.1'
      end
    end
  
    c = Conf.new
    c.db.host.should.equal '127.0.0.1'

    c = Conf.new(:db => {:user => 'username'})
    c.db.host.should.equal '127.0.0.1'
    c.db.user.should.equal 'username'
    
    c = Conf.new(:db => {:host => 'zoom'})
    c.db.host.should.equal 'zoom'
  end
end

describe 'A subclassed Construct with a schema' do
  it 'should support a DSL for schema setting' do
    class Conf < Construct
      define :people,
        :default => []
    end
    Conf.schema.should.equal({:people => {:default => []}})
    Conf.new.people.should.equal []
  end
end
