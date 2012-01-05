valido ?= {}

_ ?= require "underscore"



############################################################
# UTILITIES

getValue = (obj, path) ->
	
	if not _.isArray path
		path = path.split(".")
	
	obj = obj[path[0]]
	
	if path.length == 1
		return obj
	
	return getValue(obj, path[1..])


############################################################
# BASE PROPERTY CLASS

class Property

	constructor: (info, contents) ->
		@info = _.extend @defaults, info
		@contents = contents
		
	isEmpty: (value) ->
		return value in ["", undefined, null]
	
	addError: (errors, path, description) ->
		
		key = ".#{path.join '.'}"
		
		if not errors
			throw "#{key}: #{description}"
		
		errors[key] = description
		
	validate: (value, errors, path) ->
		
		path = path or []
		
		if @isEmpty value
			if @info.allowEmpty == false
				@addError errors, path, "Value may not be empty"
			return @info.defaultValue
		
		else
			if @isValidType(value) == false
				@addError errors, path, "Value is type #{typeof value} and should be #{@defaults.type}"
		
		return value
		

############################################################
# BOOLEAN PROPERTY

class BooleanProperty extends Property
	
	defaults:
		isRequired: false
		allowEmpty: false
		type: "boolean"
	
	isValidType: (value) ->
		return typeof value == @info.type

############################################################
# STRING PROPERTY

class StringProperty extends Property

	defaults:
		isRequired: false
		allowEmpty: true
		defaultValue: ""
		type: "string"

	isValidType: (value) ->
		return _.isString(value)

############################################################
# INTEGER PROPERTY

class IntegerProperty extends Property

	defaults:
		isRequired: false
		allowEmpty: true
		defaultValue: 0
		type: "string"

	isValidType: (n) ->
		if _.isNumber n
			# http://stackoverflow.com/questions/3885817/how-to-check-if-a-number-is-float-or-integer
			return `n===+n && n===(n|0)`
		return false

############################################################
# FLOAT PROPERTY

class FloatProperty extends Property

	defaults:
		isRequired: false
		allowEmpty: true
		defaultValue: 0.0
		type: "float"

	isValidType: (value) ->
		return _.isNumber value

############################################################
# OBJECT PROPERTY



class ObjectProperty extends Property

	defaults:
		isRequired: false,
		allowEmpty: true,
		defaultValue: {},
		type: "object"

	isValidType: (value) ->
		
		if not typeof value is "object"
			return false
		
		if _.isArray(value)
			return false
		
		return true

	validate: (value, errors, path) ->
		
		path = [] if not path
		value = super value, errors, path
		
		cleanValue = {}
		
		for k, validator of @contents
			
			itemPath = _.clone path
			itemPath.push k
			
			itemValue = value[k]
			
			if not itemValue
				
				if validator.info["isRequired"] is true
					@addError errors, itemPath, "Attribute required"
				
				itemValue = validator.info["defaultValue"]
			
			cleanValue[k] = validator.validate itemValue, itemPath, errors
		
		return cleanValue



class ArrayProperty extends Property

	defaults:
		isRequired: false
		allowEmpty: true
		defaultValue: []
		type: "array"
	
	isValidType: (value) ->
		return _.isArray(value)
	
	validate: (value, errors, path) ->
		
		path = [] if not path
		value = super value, errors, path
		
		for index in [0..value.length-1]
			itemPath = _.clone path
			itemPath.push index.toString()
			value[index] = @contents.validate value[index], errors, itemPath
		
		return value

############################################################
# EXPORTS

valido = {}

valido.getValue = getValue
valido.BooleanProperty = BooleanProperty
valido.StringProperty = StringProperty
valido.IntegerProperty = IntegerProperty
valido.FloatProperty = FloatProperty
valido.ObjectProperty = ObjectProperty
valido.ArrayProperty = ArrayProperty

valido.properties =
	boolean: BooleanProperty
	integer: IntegerProperty
	float: FloatProperty
	string: StringProperty
	object: ObjectProperty
	array: ArrayProperty

valido.property = (type, options, contents) ->
	return new valido.properties[type](options, contents)

if window?
	window.valido = valido
else
	_.extend exports, valido
