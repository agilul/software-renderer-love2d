-- Copyright 2016 Yat Hin Wong

local sqrt = math.sqrt

local vector = {}
vector.__index = vector

local function new(x, y, z)
	return setmetatable({x = x or 0, y = y or 0, z = z or 0}, vector)
end

local zero = new(0, 0, 0)

local function isvector(v)
	return type(v) == 'table' and type(v.x) == 'number' and type(v.y) == 'number' and type(v.z) == 'number'
end
	
function vector:clone()
	return new(self.x, self.y, self.z)
end

function vector:unpack()
	return self.x, self.y, self.z
end

function vector:__tostring()
	return "(" .. tonumber(self.x) .. "," .. tonumber(self.y) .. "," .. tonumber(self.z) .. ")"
end

-- unary minus operator
function vector.__unm(a)
	return new(-a.x, -a.y, -a.z)
end

function vector.__add(a, b)
	return new(a.x + b.x, a.y + b.y, a.z + b.z)
end

function vector.__sub(a, b)
	return new(a.x - b.x, a.y - b.y, a.z - b.z)
end

-- dot product
function vector.__mul(a, b)
	if type(a) == "number" then
		return new(a * b.x, a * b.y, a * b.z)
	elseif type(b) == "number" then
		return new(b * a.x, b * a.y, b * a.z)
	else
		return a.x * b.x + a.y * b.y + a.z * b.z
	end
end

function vector.__div(a, b)
	return new(a.x / b, a.y / b, a.z / b)
end

function vector.__eq(a, b)
	return a.x == b.x and a.y == b.y and a.z == b.z
end

-- squared length
function vector:len2()
	return self.x * self.x + self.y * self.y + self.z * self.z
end

function vector:len()
	return sqrt(self.x * self.x + self.y * self.y + self.z * self.z)
end

-- squared distance
function vector.dist2(a, b)
	local dx = a.x - b.x
	local dy = a.y - b.y
	local dz = a.z - b.z
	return dx * dx + dy * dy + dz * dz
end

function vector.dist(a, b)
	local dx = a.x - b.x
	local dy = a.y - b.y
	local dz = a.z - b.z
	return sqrt(dx * dx + dy * dy + dz * dz)
end

function vector:normalizeInplace()
	local l = self:len()
	if l > 0 then
		self.x, self.y, self.z = self.x / l, self.y / l, self.z / l
	end
	return self
end

function vector:normalized()
	return self:clone():normalizeInplace()
end

-- cross product
function vector:cross(v)
	return new(self.y * v.z - self.z * v.y, self.z * v.x - self.x * v.z, self.x * v.y - self.y * v.x)
end

-- using homogeneous representation
function vector.multVecMatrix(v, m)
	local a, b, c, w
	a = v.x * m[1][1] + v.y * m[2][1] + v.z * m[3][1] + m[4][1]
	b = v.x * m[1][2] + v.y * m[2][2] + v.z * m[3][2] + m[4][2]
	c = v.x * m[1][3] + v.y * m[2][3] + v.z * m[3][3] + m[4][3]
	w = v.x * m[1][4] + v.y * m[2][4] + v.z * m[3][4] + m[4][4]
	return new(a, b, c) / w
end

return setmetatable({new = new, isvector = isvector, zero = zero},
	{__call = function(_, ...) return new(...) end})
	
