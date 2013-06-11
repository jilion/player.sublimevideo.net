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

# def force_define_rails!
#   puts "Let's define Rails..."
#   Rails.stub(:root) { Pathname.new(File.expand_path('')) }
#   Rails.stub(:env) { FakeEnv.new('test') }
# end

unless defined?(Rails)
  RSpec.configure do |config|
    config.before :each do
      Rails = mock('Rails')
      Rails.stub(:root) { Pathname.new(File.expand_path('')) }
      Rails.stub(:env) { FakeEnv.new('test') }
      # force_define_rails!
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
