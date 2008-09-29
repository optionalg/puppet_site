require 'autotest'
require 'autotest/rspec'

Autotest.add_hook :initialize do |at|
    at.clear_mappings

    # the libraries under lib/puppet
    at.add_mapping(%r%^lib/scaffold/(.*)\.rb$%) { |filename, m|
        at.files_matching %r!spec/(unit|integration)/#{m[1]}.rb!
    }

    # the actual spec files themselves
    at.add_mapping(%r%^spec/(unit|integration)/.*\.rb$%) { |filename, _|
        filename
    }

    # force a complete re-run for all of these:

	# main puppet lib
	at.add_mapping(%r!^lib/scaffold\.rb$!) { |filename, _|
        at.files_matching %r!spec/(unit|integration)/.*\.rb!
	}

	# the spec_helper
	at.add_mapping(%r!^spec/spec_helper\.rb$!) { |filename, _|
        at.files_matching %r!spec/(unit|integration)/.*\.rb!
	}
end

class Autotest::ScaffoldRspec < Autotest::Rspec
  # Autotest will look for spec commands in the following
  # locations, in this order:
  #
  #   * bin/spec
  #   * default spec bin/loader installed in Rubygems
  #   * our local vendor/gems/rspec/bin/spec
  def spec_commands
    [
      File.join('vendor', 'gems', 'rspec', 'bin', 'spec') ,
      File.join('bin', 'spec'),
      File.join(Config::CONFIG['bindir'], 'spec')
    ]
  end

end
