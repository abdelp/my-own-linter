#!/usr/bin/env ruby

require_relative '../lib/commicop'

branch = ARGV.first
commicop = Commicop.new(branch)
commicop.check_params
puts commicop.formatted_result
