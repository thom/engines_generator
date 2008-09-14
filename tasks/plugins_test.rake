require 'spec/rake/spectask'

namespace :plugins do
  Rake::TestTask.new(:test) do |t|
    t.libs << "test"
    t.pattern = "vendor/plugins/#{ENV['PLUGIN'] || '**'}/**/*_test.rb"
    t.verbose = true
  end

  Spec::Rake::SpecTask.new(:test) do |t|
    t.libs << "spec"
    t.spec_opts = ['--options', "\"#{RAILS_ROOT}/spec/spec.opts\""]
    t.pattern = "vendor/plugins/#{ENV['PLUGIN'] || '**'}/**/*_spec.rb"
  end

  Rake::Task['plugins:test'].comment = "Run the plugin tests and specs in vendor/plugins/** (or specify with PLUGIN=name)"

  desc "Run all specs in spec directory with RCov (excluding plugin specs)"
  Spec::Rake::SpecTask.new(:rcov) do |t|
    t.spec_opts = ['--options', "\"#{RAILS_ROOT}/spec/spec.opts\""]
    t.pattern = "vendor/plugins/#{ENV['PLUGIN'] || '**'}/**/*_spec.rb"
    t.rcov = true
    t.rcov_opts = lambda do
      IO.readlines("#{RAILS_ROOT}/spec/rcov.opts").map {|l| l.chomp.split " "}.flatten
    end
  end

  desc "Report code statistics (KLOCs, etc) from the plugin"
  task :stats do
    require 'code_statistics'
    path = "#{RAILS_ROOT}/vendor/plugins/#{ENV['PLUGIN'] || '**'}/"
    dirs = [
            %w(Controllers        app/controllers),
            %w(Helpers            app/helpers),
            %w(Models             app/models),
            %w(Libraries          lib/),
            %w(APIs               app/apis),
            %w(Components         components),
            %w(Integration\ tests test/integration),
            %w(Functional\ tests  test/functional),
            %w(Unit\ tests        test/unit),
            %w(Model\ specs       spec/models),
            %w(View\ specs        spec/views),
            %w(Controller\ specs  spec/controllers),
            %w(Helper\ specs      spec/helpers),
            %w(Library\ specs     spec/lib)
           ].collect { |name, dir| [ name, "#{path}/#{dir}" ] }.select { |name, dir| File.directory?(dir) }

    ::CodeStatistics::TEST_TYPES << "Model specs" if File.exist?(path + 'spec/models')
    ::CodeStatistics::TEST_TYPES << "View specs" if File.exist?(path + 'spec/views')
    ::CodeStatistics::TEST_TYPES << "Controller specs" if File.exist?(path + 'spec/controllers')
    ::CodeStatistics::TEST_TYPES << "Helper specs" if File.exist?(path + 'spec/helpers')
    ::CodeStatistics::TEST_TYPES << "Library specs" if File.exist?(path + 'spec/lib')

    CodeStatistics.new(*dirs).to_s
  end

  namespace :test do
    desc "Test all plugins in config/plugins_to_test.yml"
    task :all do
      require "yaml"
      rake_plugins = YAML.load_file(RAILS_ROOT + "/config/plugins_to_test.yml")
      errored_plugins = []
      rake_plugins.each do |plugin|
        p "Testing plugin #{plugin}"
        cmd = "rake plugins:test PLUGIN=#{plugin}"
        results = `#{cmd}`
        puts results
        lines = results.split("\n")

        found_status_line = false
        tests, specs, assertions, failures, errors = 0
        lines.reverse.each do |line|
          if matches = line.match(/(\d+) tests?, (\d+) assertions?, (\d+) failures?, (\d+) errors?/)
            found_status_line = true
            blah, tests, assertions, failures, errors = matches.to_a.collect {|match| match.to_i}
            break
          elsif matches = line.match(/(\d+) examples?, (\d+) failures?/)
            blah, specs, failures = matches.to_a.collect {|match| match.to_i}
            errors = 0
            found_status_line = true
            break
          end
        end
        raise "Could not find status line for plugin: #{plugin}" unless found_status_line
        errored_plugins << plugin if failures > 0 || errors > 0
      end
      raise "Test failures in the following plugins: #{errored_plugins.join(', ')}" unless errored_plugins.empty?
    end
  end
end
