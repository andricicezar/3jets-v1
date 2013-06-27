require 'rubygems'
require 'closure-compiler'

cl = Closure::Compiler.new(:compilation_level => "ADVANCED_OPTIMIZATIONS")
f = File.open('vv.js', 'w')
f.write( cl.compile(File.open('public/assets/application.js', 'r')) )
f.close
