#!/usr/bin/env ruby
require 'json'

unless ARGV.size > 0
  ARGV.concat Dir['./**/*.sdf.json']
end

jps = %w[
 sdfRef
 sdfRequired
 sdfInputData
 sdfRequiredInputData
 sdfOutputData
]

# Walk down a path of map keys $[label1][label2] and return failing index
def walk(position, labels)
  labels.each_with_index do |l, i|
    if position.has_key?(l)
      position = position[l]
    else
      return i
    end
  end
  false
end

# Search for a map key and return value, $..["label"]
# mutating "input"!
def descend(input, position, label)
  # p [input, position, label]
  case position
  when Hash
    if position.has_key?(label)
      input << position[label]
    end
    position.each { |k, v|
      descend(input, v, label)
    }
  when Array
    position.each { |v|
      descend(input, v, label)
    }
  end
  input
end

ARGV.each do |fn|
  begin
    spec = JSON.load(File.read(fn))
  rescue Exception => e
    puts [fn, e].inspect
    next
  end
  copr = spec["info"]["copyright"].sub(/Copyright ?(\(c\))? ?(20..(-20..)?)?,? ?/, "")
           .sub(/ ?All rights reserved./, "")
  bad = []
  pointers = jps.map {|jp| descend([], spec, jp)}.flatten
  pointers.each { |pt|
    pl = pt.split("/")
    f = nil
    unless pl[0] == "#"
      f = -1
    else
      f = walk(spec, pl[1..-1])
    end
    if f
      f += 1
      pl[f] = ">>#{pl[f]}<<"
      bad << pl.join("/")
    end
  }
  if bad != []
    puts "#{fn} (#{copr}):"
    bad.each {|b| puts "- #{b}"}
    puts
  end
end
