RSpec.configure do |config|
  config.order = :random

  Kernel.srand config.seed

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.backtrace_exclusion_patterns << %r{/gems/}
end
