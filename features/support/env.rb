# Generated by cucumber-sinatra. (Sat Jul 31 13:07:05 +0200 2010)

require File.join(File.dirname(__FILE__), '..', '..', 'app.rb')

require 'capybara'
require 'capybara/cucumber'
require 'spec'

RubyOres.set(:environment, :test)

Capybara.app = RubyOres

class RubyOresWorld
  include Capybara
  include Spec::Expectations
  include Spec::Matchers
end

World do
  RubyOresWorld.new
end
