require 'chefspec'
require 'chef-dk/generator'

RSpec.configure do |config|
  config.color = true
  config.formatter = 'doc'
end
