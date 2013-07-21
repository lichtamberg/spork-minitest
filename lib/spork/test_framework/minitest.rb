class Spork::TestFramework::MiniTest < Spork::TestFramework
  DEFAULT_PORT = 8988
  DEFAULT_HELPER_FILES = %w[test/minitest_helper.rb test/test_helper.rb spec/spec_helper.rb]

  def self.helper_file
    ENV['HELPER_FILE'] || DEFAULT_HELPER_FILES.find{ |f| File.exist?(f) }
  end

  def run_tests(argv, stderr, stdout)
    require "minitest/unit"
    ::MiniTest::Unit.output = stdout

    argv.each_with_index do |arg, idx|
      if arg =~ /-I(.*)/
        if $1 == ''
          # Path is next argument.
          include_path = argv[idx + 1]
          argv[idx + 1] = nil # Will be squashed when compact called.
        else
          include_path = $1
        end
        $LOAD_PATH << include_path
        argv[idx] = nil
      elsif arg =~ /-r(.*)/
        if $1 == ''
          # File is next argument.
          require_file = argv[idx + 1]
          argv[idx + 1] = nil # Will be squashed when compact called.
        else
          require_file = $1
        end
        require require_file
        argv[idx] = nil
      elsif arg =~ /^-e$/
        eval argv[idx + 1]
        argv[idx] = argv[idx + 1] = nil
      elsif arg == '--'
        argv[idx] = nil
        break
      elsif !arg.nil?
        require arg
        argv[idx] = nil
      end
    end
    argv.compact!

    ::MiniTest::Unit.new.run(argv)
  end
end