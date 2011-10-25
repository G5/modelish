require 'bundler'
Bundler::GemHelper.install_tasks

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec)

task :default => :spec

namespace :doc do
  require 'yard'
  YARD::Rake::YardocTask.new do |task|
    task.files   = ['README.md', 'CHANGELOG.md', 'LICENSE', 'lib/**/*.rb']
    task.options = [
      '--markup', 'markdown',
    ]
  end
end
