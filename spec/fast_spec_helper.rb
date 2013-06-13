$LOAD_PATH.unshift("#{Dir.pwd}/app")
Dir['app/**/'].each do |dir|
  path = "#{Dir.pwd}/#{dir}"
  $LOAD_PATH.unshift(path) unless path =~ %r{^app/(assets|views)}
end

ENV['RAILS_ENV'] ||= 'test'

require 'bundler/setup'
require 'dotenv'
Dotenv.load
require_relative 'config/rspec'

FakeEnv = Struct.new(:env) do
  def to_s; env end
  def test?; env == 'test' end
end

unless defined?(Rails)
  module Rails
    def self.root; Pathname.new(File.expand_path('')); end
    def self.env; FakeEnv.new('test'); end
  end
  puts "Let's define Rails... => #{Rails.root}"
end

RSpec.configure do |config|
  config.before :each do
    unless defined?(Rails)
      puts "Let's define Rails again..."
      Rails = mock('Rails')
      Rails.stub(:root) { Pathname.new(File.expand_path('')) }
      Rails.stub(:env) { FakeEnv.new('test') }
    end
  end
end

unless defined?(Librato)
  module Librato
    def self.method_missing(*args)
      true
    end
  end
end
