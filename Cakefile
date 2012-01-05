{exec} = require "child_process"
nodeunit = require "nodeunit"

task "build", "Build for browser and node", ->
	exec "
		rm -Rf build; 
		mkdir -p build; 
		coffee -c -o build src/valido.coffee
		", (err, stdout, stderr) ->
		throw err if err
		console.log stderr, stdout	


task "test", "Run unit tests", ->
	reporter = nodeunit.reporters.default
	reporter.run ["tests"]