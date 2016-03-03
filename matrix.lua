-- Copyright 2016 Yat Hin Wong

matrix = {}

function matrix.print(m)
	for i, r in ipairs(m) do
		for j, v in ipairs(r) do
			io.write(v .. " ")
		end
		io.write("\n")
	end
end

function matrix.createIdentityMatrix()
	local m = {}
	for i=1,4 do
		m[i] = {}
		for j=1,4 do
			if i == j then
				m[i][j] = 1
			else
				m[i][j] = 0
			end
		end
	end
	return m
end

-- perspective projection
function matrix.createProjectionMatrix(fov, near, far)
	local m = matrix.createIdentityMatrix()
	local scale = 1 / math.tan(fov * 0.5 * math.pi / 180)
	m[1][1] = scale
	m[2][2] = scale
	m[3][3] = -far / (far - near)
	m[4][3] = -far * near / (far - near)
	m[3][4] = -1
	m[4][4] = 0
	return m
end

-- rotation around an axis by an angle (in radians)
function matrix.createRotationMatrix(axis, angle)
	local x, y, z, c, s = axis.x, axis.y, axis.z, math.cos(angle), math.sin(angle)
	local m = matrix.createIdentityMatrix()
	m[1][1] = c + x*x * (1-c)
	m[1][2] = y*x * (1-c) + z * s
	m[1][3] = z*x * (1-c) - y * s
	m[2][1] = x*y * (1-c) - z * s
	m[2][2] = c + y*y * (1-c)
	m[2][3] = z*y * (1-c) + x * s
	m[3][1] = x*z * (1-c) + y * s
	m[3][2] = y*z * (1-c) - x * s
	m[3][3] = c + z*z * (1-c)
	return m
end

-- translate by a vector
function matrix.createTranslationMatrix(v)
	local m = matrix.createIdentityMatrix()
	m[4][1] = v.x
	m[4][2] = v.y
	m[4][3] = v.z
	return m
end

function matrix.multiply(a, b)
	local c = matrix.createIdentityMatrix()
	local sum
	for i=1,4 do
		for j=1,4 do
			sum = 0
			for k=1,4 do
				sum = sum + a[i][k] * b[k][j]
			end
			c[i][j] = sum
		end
	end
	return c
end

-- ugly but simple
function matrix.inverse(a)
	local det = a[1][1]*a[2][2]*a[3][3]*a[4][4] + a[1][1]*a[2][3]*a[3][4]*a[4][2] + a[1][1]*a[2][4]*a[3][2]*a[4][3]
			  + a[1][2]*a[2][1]*a[3][4]*a[4][3] + a[1][2]*a[2][3]*a[3][1]*a[4][4] + a[1][2]*a[2][4]*a[3][3]*a[4][1]
			  + a[1][3]*a[2][1]*a[3][2]*a[4][4] + a[1][3]*a[2][2]*a[3][4]*a[4][1] + a[1][3]*a[2][4]*a[3][1]*a[4][2]
			  + a[1][4]*a[2][1]*a[3][3]*a[4][2] + a[1][4]*a[2][2]*a[3][1]*a[4][3] + a[1][4]*a[2][3]*a[3][2]*a[4][1]
			  - a[1][1]*a[2][2]*a[3][4]*a[4][3] - a[1][1]*a[2][3]*a[3][2]*a[4][4] - a[1][1]*a[2][4]*a[3][3]*a[4][2]
			  - a[1][2]*a[2][1]*a[3][3]*a[4][4] - a[1][2]*a[2][3]*a[3][4]*a[4][1] - a[1][2]*a[2][4]*a[3][1]*a[4][3]
			  - a[1][3]*a[2][1]*a[3][4]*a[4][2] - a[1][3]*a[2][2]*a[3][1]*a[4][4] - a[1][3]*a[2][4]*a[3][2]*a[4][1]
			  - a[1][4]*a[2][1]*a[3][2]*a[4][3] - a[1][4]*a[2][2]*a[3][3]*a[4][1] - a[1][4]*a[2][3]*a[3][1]*a[4][2]

	if det == 0 then
		return nil
	end
	
	det = 1.0 / det
	local b = matrix.createIdentityMatrix()
	b[1][1] = det * (a[2][2]*a[3][3]*a[4][4] + a[2][3]*a[3][4]*a[4][2] + a[2][4]*a[3][2]*a[4][3] - a[2][2]*a[3][4]*a[4][3] - a[2][3]*a[3][2]*a[4][4] - a[2][4]*a[3][3]*a[4][2])
	b[1][2] = det * (a[1][2]*a[3][4]*a[4][3] + a[1][3]*a[3][2]*a[4][4] + a[1][4]*a[3][3]*a[4][2] - a[1][2]*a[3][3]*a[4][4] - a[1][3]*a[3][4]*a[4][2] - a[1][4]*a[3][2]*a[4][3])
	b[1][3] = det * (a[1][2]*a[2][3]*a[4][4] + a[1][3]*a[2][4]*a[4][2] + a[1][4]*a[2][2]*a[4][3] - a[1][2]*a[2][4]*a[4][3] - a[1][3]*a[2][2]*a[4][4] - a[1][4]*a[2][3]*a[4][2])
	b[1][4] = det * (a[1][2]*a[2][4]*a[3][3] + a[1][3]*a[2][2]*a[3][4] + a[1][4]*a[2][3]*a[3][2] - a[1][2]*a[2][3]*a[3][4] - a[1][3]*a[2][4]*a[3][2] - a[1][4]*a[2][2]*a[3][3])
	b[2][1] = det * (a[2][1]*a[3][4]*a[4][3] + a[2][3]*a[3][1]*a[4][4] + a[2][4]*a[3][3]*a[4][1] - a[2][1]*a[3][3]*a[4][4] - a[2][3]*a[3][4]*a[4][1] - a[2][4]*a[3][1]*a[4][3])
	b[2][2] = det * (a[1][1]*a[3][3]*a[4][4] + a[1][3]*a[3][4]*a[4][1] + a[1][4]*a[3][1]*a[4][3] - a[1][1]*a[3][4]*a[4][3] - a[1][3]*a[3][1]*a[4][4] - a[1][4]*a[3][3]*a[4][1])
	b[2][3] = det * (a[1][1]*a[2][4]*a[4][3] + a[1][3]*a[2][1]*a[4][4] + a[1][4]*a[2][3]*a[4][1] - a[1][1]*a[2][3]*a[4][4] - a[1][3]*a[2][4]*a[4][1] - a[1][4]*a[2][1]*a[4][3])
	b[2][4] = det * (a[1][1]*a[2][3]*a[3][4] + a[1][3]*a[2][4]*a[3][1] + a[1][4]*a[2][1]*a[3][3] - a[1][1]*a[2][4]*a[3][3] - a[1][3]*a[2][1]*a[3][4] - a[1][4]*a[2][3]*a[3][1])
	b[3][1] = det * (a[2][1]*a[3][2]*a[4][4] + a[2][2]*a[3][4]*a[4][1] + a[2][4]*a[3][1]*a[4][2] - a[2][1]*a[3][4]*a[4][2] - a[2][2]*a[3][1]*a[4][4] - a[2][4]*a[3][2]*a[4][1])
	b[3][2] = det * (a[1][1]*a[3][4]*a[4][2] + a[1][2]*a[3][1]*a[4][4] + a[1][4]*a[3][2]*a[4][1] - a[1][1]*a[3][2]*a[4][4] - a[1][2]*a[3][4]*a[4][1] - a[1][4]*a[3][1]*a[4][2])
	b[3][3] = det * (a[1][1]*a[2][2]*a[4][4] + a[1][2]*a[2][4]*a[4][1] + a[1][4]*a[2][1]*a[4][2] - a[1][1]*a[2][4]*a[4][2] - a[1][2]*a[2][1]*a[4][4] - a[1][4]*a[2][2]*a[4][1])
	b[3][4] = det * (a[1][1]*a[2][4]*a[3][2] + a[1][2]*a[2][1]*a[3][4] + a[1][4]*a[2][2]*a[3][1] - a[1][1]*a[2][2]*a[3][4] - a[1][2]*a[2][4]*a[3][1] - a[1][4]*a[2][1]*a[3][2])
	b[4][1] = det * (a[2][1]*a[3][3]*a[4][2] + a[2][2]*a[3][1]*a[4][3] + a[2][3]*a[3][2]*a[4][1] - a[2][1]*a[3][2]*a[4][3] - a[2][2]*a[3][3]*a[4][1] - a[2][3]*a[3][1]*a[4][2])
	b[4][2] = det * (a[1][1]*a[3][2]*a[4][3] + a[1][2]*a[3][3]*a[4][1] + a[1][3]*a[3][1]*a[4][2] - a[1][1]*a[3][3]*a[4][2] - a[1][2]*a[3][1]*a[4][3] - a[1][3]*a[3][2]*a[4][1])
	b[4][3] = det * (a[1][1]*a[2][3]*a[4][2] + a[1][2]*a[2][1]*a[4][3] + a[1][3]*a[2][2]*a[4][1] - a[1][1]*a[2][2]*a[4][3] - a[1][2]*a[2][3]*a[4][1] - a[1][3]*a[2][1]*a[4][2])
	b[4][4] = det * (a[1][1]*a[2][2]*a[3][3] + a[1][2]*a[2][3]*a[3][1] + a[1][3]*a[2][1]*a[3][2] - a[1][1]*a[2][3]*a[3][2] - a[1][2]*a[2][1]*a[3][3] - a[1][3]*a[2][2]*a[3][1])
	
	return b
end

return matrix
