---Öbject - Base superclass that implements ÖØP.
---
---Key features of this library:
---
---+ metamethods inheritance;
---+ store all metadata in metatables (no `__junk` in actual tables);
---+ can subtly identify class membership;
---+ tiny and fast, readable source.
---@class lib.object
local Object = {
	classname = "lib.object",
	super = {},
}

---Adds all metamethods from self and all parents to the specified table.
---Maintains the order of the hierarchy: Rect > Point > Object.
---@param self lib.object Apply from.
---@param apply_here table Apply to.
local function apply_meta_from_parents(self, apply_here)
	for key, value in self:iter() do
		if apply_here[key] == nil and key:find("__") == 1 then
			apply_here[key] = value
		end
	end
end

---Adds `__index` metamethods from self or closest parent to the table.
---@param self lib.object Apply from.
---@param apply_here table Apply to.
local function apply_closest_meta_index(self, apply_here)
	local i = self.__index
	if i == nil then
		apply_here.__index = self
		return
	end
	apply_here.__index = function(instance, key)
		local t = type(i)
		local v
		if t == "function" then
			v = i(instance, key)
		elseif t == "table" then
			v = i[key]
		else
			error('"__index" must be a function or table', 2)
		end
		if v ~= nil then
			return v
		end
		if key == "new" or key == "extend" then
			error("attempt to use instance as class", 2)
		end
		return self[key]
	end
end

---Creates **uninitialized** instance of the class.
---
---After calling this method you have to initialize the instance:
---```lua
---local rect = Rectangle:new():init(2, 4, 6, 8)
---```
---Why I can't mix `new()` with `init()`? - I can an this is just a single line
---of code, but in this case you will not see hints from LSP :(
---@generic T
---@param self T
---@return T
function Object:new()
	local obj_mt = {
		__index = self,
		__tostring = function()
			return "instance of " .. self.classname
		end,
	}
	local obj = setmetatable({}, obj_mt)
	apply_meta_from_parents(self, obj_mt)
	apply_closest_meta_index(self, obj_mt)
	return obj
end

---Initializes the class.
---
---By default an object takes a table with fields and applies them to itself.
---You can (and probably should) replace this method with your own in subclass.
---@param fields? table New fields.
function Object:init(fields)
	local t = type(fields)
	if t ~= "table" then
		error('"Object:init()" expected a table, but got ' .. t, 3)
	end
	for key, value in pairs(fields) do
		self[key] = value
	end
end

---Creates a new class by inheritance.
---@generic T
---@param self T
---@param name string New class name.
---@vararg table|lib.object? Additional properties.
---@return T
function Object:extend(name, ...)
	if type(name) ~= "string" then
		error("class must have a name", 2)
	end

	local cls, cls_mt = {}, {}
	for key, value in pairs(getmetatable(self)) do
		cls_mt[key] = value
	end
	for _, extra in ipairs({ ... }) do
		for key, value in pairs(extra) do
			cls[key] = value
		end
	end

	cls.classname = name
	cls.super = self
	cls_mt.__index = self
	cls_mt.__tostring = function()
		return "class " .. name
	end
	return setmetatable(cls, cls_mt)
end

---Returns the "membership range" between self and the checking class.
---Returns `0` if belongs to it or `false` if there is no membership.
---Positive number means number of subclasses between `self` and `Test`.
---@param Test string|lib.object Test class.
---@param limit? integer Check depth (default unlimited).
---@return integer|boolean
function Object:has(Test, limit)
	local t = type(Test)
	local searchedname
	if t == "string" then
		searchedname = Test
	else
		if t ~= "table" then
			return false
		end
		searchedname = Test.classname
	end

	local i = 0
	while self.super do
		if self.classname == searchedname then
			return i
		end
		if i == limit then
			return false
		end
		self = self.super
		i = i + 1
	end
	return false
end

---Identifies affiliation to class.
---@param Test string|lib.object
---@return boolean
function Object:is(Test)
	return self:has(Test, 0) == 0
end

---Loop iterator.
---Goes through all fields and methods (including extended)
---except those belonging to Object itself.
---@generic T, K, V
---@param self T<K, V>
---@param key? K
---@return fun(): K, V, T
function Object:iter(key)
	local value
	local returned = {}
	local function next_iter()
		key, value = next(self, key)
		if key ~= nil then
			if returned[key] then
				return next_iter()
			else
				returned[key] = true
				return key, value, self
			end
		else
			if self ~= Object then
				self = self.super
				return next_iter()
			end
		end
	end
	return next_iter
end

return setmetatable(Object, {
	__tostring = function(self)
		return "class " .. self.classname
	end,
	__call = Object.new,
})
