{exec} = require "child_process"
nodeunit = require "nodeunit"

# task("build", "Build project from src/*.coffee to lib/*.js", ->
# exec "nodeunit tests", (err, stdout, stderr) ->
# 	throw err if err
# 	console.log stderr, stdout	


task "test", "Run unit tests", ->
	reporter = nodeunit.reporters.default
	reporter.run ["tests"]
	
