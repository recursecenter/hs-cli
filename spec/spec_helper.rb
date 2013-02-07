require_relative '../lib/hs'

Dir.glob('../lib/hs/commands/*') do |rel_path|
  if rel_path.end_with? '.rb'
    require_relative rel_path.chomp('.rb')
  end
end

require 'rspec'
require 'webmock/rspec'
require 'vcr'

VCR.configure do |c|
  c.cassette_library_dir = "spec/cassettes"
  c.hook_into :webmock
  c.configure_rspec_metadata!
end

RSpec.configure do |c|
  c.treat_symbols_as_metadata_keys_with_true_values = true
end

module Helpers
  def hash_with_keys(keys)
    Hash[keys.map { |key| [key, true] }]
  end
end
