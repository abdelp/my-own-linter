#!/usr/bin/env ruby

require_relative '../lib/linter'

branch = ARGV.first
linter = Linter.new(branch)
linter.check_params
puts linter.formatted_result
