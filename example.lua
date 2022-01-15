local Object = require("init")

---Extra subclass. Just for test.
---@class lib.object.example-proto-point:lib.object
---@field super lib.object
local ProtoPoint = Object:extend("lib.object.example-proto-point")

---@class lib.object.example-point:lib.object.example-proto-point
---@field super lib.object
local Point = ProtoPoint:extend("lib.object.example-point")

Point.scale = 2 -- Class field!

function Point:init(x, y)
	self.x = x or 0
	self.y = y or 0
	return self
end

function Point:resize()
	self.x = self.x * self.scale
	self.y = self.y * self.scale
	return self
end

function Point.__call()
	return "called"
end

---@class lib.object.example-rect:lib.object.example-point
---@field super lib.object.example-point
---@field width integer
---@field height integer
local Rectangle = Point:extend("lib.object.example-rect")

function Rectangle:resize()
	Rectangle.super.resize(self) -- Extend Point's `resize()`.
	self.w = self.w * self.scale
	self.h = self.h * self.scale
	return self
end

function Rectangle:init(x, y, w, h)
	Rectangle.super.init(self, x, y) -- Initialize Point first!
	self.w = w or 0
	self.h = h or 0
	return self
end

function Rectangle:__index(key)
	if key == "width" then
		return self.w
	end
	if key == "height" then
		return self.h
	end
	return rawget(self, key)
end

function Rectangle:__newindex(key, value)
	if key == "width" then
		self.w = value
	elseif key == "height" then
		self.h = value
	end
	return rawset(self, key, value)
end

-- local rect = Rectangle:new():init(2, 4, 6, 8)
local rect = Rectangle(2, 4, 6, 8)

-- rect:new() -- Error: rect is not a class.

rect.new = "wtf"
assert(rect.new == "wtf")

function rect:new()
	return self
end
rect:new() -- No errors. Own `new()` and `extend()` are allowed.

assert(rect.w == 6)
assert(rect:is(Rectangle))
assert(rect:is("lib.object.example-rect"))
assert(not rect:is(Point))
assert(rect:has("lib.object.example-point") == 1)
assert(Rectangle:has(Object) == 3)
assert(rect() == "called")

rect.width = 666
assert(rect.w == 666)
assert(rect.height == 8)

for k, v, t in rect:iter() do
	print(k, v, t)
end
