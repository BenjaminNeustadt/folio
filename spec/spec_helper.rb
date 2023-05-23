ENV['RACK_ENV'] = 'test'

RSpec.configure do |config|

  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true # 1/
  end

  # 2/
  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  # 3/
  config.shared_context_metadata_behavior = :apply_to_host_groups

  # Allows the use of session in the tests,
  # giving the return values of a session object
  def session
    last_request.env['rack.session']
  end

  # config.order = :random

  # This setting enables warnings. It's recommended, but in some cases may
  # be too noisy due to issues in dependencies.
  # config.warnings = true

end

# 1/
# This option will default to `true` in RSpec 4. It makes the `description`
# and `failure_message` of custom matchers include text for helper methods
# defined using `chain`, e.g.:
#     be_bigger_than(2).and_smaller_than(4).description
#     # => "be bigger than 2 and smaller than 4"
# ...rather than:
#     # => "be bigger than 2"

# 2/
# rspec-mocks config goes here. You can use an alternate test double
# library (such as bogus or mocha) by changing the `mock_with` option here.

# 3/

# Prevents you from mocking or stubbing a method that does not exist on
# a real object. This is generally recommended, and will default to
# `true` in RSpec 4.

# The settings below are suggested to provide a good initial experience
# with RSpec, but feel free to customize to your heart's content.
=begin

  # Print the 10 slowest examples and example groups at the
  # end of the spec run, to help surface which specs are running
  # particularly slow.
  config.profile_examples = 10

  # This allows you to limit a spec run to individual examples or groups
  # you care about by tagging them with `:focus` metadata. When nothing
  # is tagged with `:focus`, all examples get run. RSpec also provides
  # aliases for `it`, `describe`, and `context` that include `:focus`
  # metadata: `fit`, `fdescribe` and `fcontext`, respectively.
  config.filter_run_when_matching :focus

  # Allows RSpec to persist some state between runs in order to support
  # the `--only-failures` and `--next-failure` CLI options. We recommend
  # you configure your source control system to ignore this file.
  config.example_status_persistence_file_path = "spec/examples.txt"

  # Limits the available syntax to the non-monkey patched syntax that is
  # recommended. For more details, see:
  # https://rspec.info/features/3-12/rspec-core/configuration/zero-monkey-patching-mode/
  config.disable_monkey_patching!


  # Seed global randomization in this process using the `--seed` CLI option.
  # Setting this allows you to use `--seed` to deterministically reproduce
  # test failures related to randomization by passing the same `--seed` value
  # as the one that triggered the failure.
  Kernel.srand config.seed
=end