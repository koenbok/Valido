sys = require "util"
assert = require "assert"

_ = require "underscore"
nodeunit = require "nodeunit"

valido = require "../src/valido"
P = valido.property

testSchema = (p, value, errorKeys) ->
	errors = []
	p.validate value, errors
	assert.deepEqual _.keys(errors), errorKeys, sys.inspect(errors)

module.exports.utilities = nodeunit.testCase

	testGetValue: (test) ->
		
		a =
			age: 29
			name: ["Koen", "Bok"]
		
		assert.equal valido.getValue(a, "age"), 29
		assert.deepEqual valido.getValue(a, "name"), ["Koen", "Bok"]
		assert.equal valido.getValue(a, "name.0"), "Koen"
		assert.equal valido.getValue(a, "name.1"), "Bok"
		
		test.done() 


module.exports.properties = nodeunit.testCase
	
	testString: (test) ->
			
		p = new valido.StringProperty()
		testSchema p, "name", []
	
		p = new valido.StringProperty()
		testSchema p, null, []
			
		p = new valido.StringProperty(allowEmpty:false)
		testSchema p, null, ["."]
	
		p = new valido.StringProperty()
		testSchema p, 1, ["."]
	
		p = new valido.StringProperty()
		testSchema p, {}, ["."]
	
		p = new valido.StringProperty()
		testSchema p, [], ["."]
		
		test.done() 
		
	testObject: (test) ->
	
		nameSchema = P("object", {}, 
			first: P("string", {isRequired: true}),
			last: P("string", {isRequired: true}),
		)
	
		testSchema nameSchema, {first:"Koen", last:"Bok"}, []
		# testSchema nameSchema, {first:"Koen"}, [".last"]
		
		test.done()
		
	testArray: (test) ->
	
		schema = P("array", {},
			P("string", {}),
		)
		
		testSchema schema, "one", ["."]
		testSchema schema, 12, ["."]
		testSchema schema, ["one", "two", 1], [".2"]
		testSchema schema, {first:"Koen"}, ["."]
		
		test.done()
	
	testBoolean: (test) ->
		
		p = new valido.BooleanProperty()
		
		testSchema p, true, []
		testSchema p, false, []
		
		testSchema p, "yes", ["."]
		testSchema p, 0, ["."]
		testSchema p, 22.33, ["."]
	
		test.done()
	
	testInteger: (test) ->
	
		p = new valido.IntegerProperty()
	
		testSchema p, 1, []
		testSchema p, 2, []
		testSchema p, -500, []
		
		testSchema p, "yes", ["."]
		testSchema p, "1.4", ["."]
		testSchema p, "1", ["."]
		testSchema p, 1.0, [] # js can't handle this 
		testSchema p, 1.01, ["."]
		testSchema p, 22.33, ["."]
	
		test.done()
	
	testFloat: (test) ->
	
		p = new valido.FloatProperty()
	
		testSchema p, 1.0, []
		testSchema p, 2.0, []
		testSchema p, -500.00, []
		testSchema p, -500, []
		testSchema p, 1, []
		
		testSchema p, "yes", ["."]
		testSchema p, "1.4", ["."]
		testSchema p, "1", ["."]
	
		test.done()