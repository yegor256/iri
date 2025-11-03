# frozen_string_literal: true

# SPDX-FileCopyrightText: Copyright (c) 2019-2025 Yegor Bugayenko
# SPDX-License-Identifier: MIT

require 'rubygems'
require 'rake'
require 'rake/clean'

CLEAN.include('coverage')

def name
  @name ||= File.basename(Dir['*.gemspec'].first, '.*')
end

def version
  Gem::Specification.load(Dir['*.gemspec'].first).version
end

task default: %i[clean test rubocop yard]

require 'rake/testtask'
Rake::TestTask.new do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/test_*.rb'
  test.verbose = false
end

require 'yard'
desc 'Build Yard documentation'
YARD::Rake::YardocTask.new do |t|
  t.files = ['lib/**/*.rb']
  t.options = ['--fail-on-warning']
end

require 'rubocop/rake_task'
RuboCop::RakeTask.new do |task|
  task.fail_on_error = true
end
