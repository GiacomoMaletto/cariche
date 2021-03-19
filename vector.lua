local Vector = {}
local Matrix = {}

function Vector.add(v1, v2)
	local result = {}
	for i = 1, #v1 do
		result[i] = v1[i]+v2[i]
	end
	return result
end

function Vector.sub(v1, v2)
	local result = {}
	for i = 1, #v1 do
		result[i] = v1[i]-v2[i]
	end
	return result
end

function Vector.len(v)
	local result = 0
	for i = 1, #v do
		result = result + v[i]^2
	end
	return math.sqrt(result)
end

local function atan2(y, x)
	if x > 0 then
		return math.atan(y/x)
	elseif x < 0 then
		if y >= 0 then
			return math.atan(y/x) + math.pi
		else
			return math.atan(y/x) - math.pi
		end
	else
		if y > 0 then return math.pi/2
		elseif y < 0 then return -math.pi/2
		else error() end
	end
end

function Vector.angle(v)
	if v[1] == 0 then
		if v[2] > 0 then return math.pi/2 end
		if v[2] < 0 then return -math.pi/2 end
		if v[2] == 0 then error() end
	end
	return atan2(v[2], v[1])
end

function Vector.len2(v)
	local result = 0
	for i = 1, #v do
		result = result + v[i]^2
	end
	return result
end

function Vector.dist(v1, v2)
	return Vector.len(Vector.sub(v1, v2))
end

function Vector.mul(c, v)
	local result = {}
	for i = 1, #v do
		result[i] = c*v[i]
	end
	return result
end

function Vector.dot(v1, v2)
	local result = 0
	for i = 1, #v1 do
		result = result + v1[i]*v2[i]
	end
	return result
end

function Vector.cross(v1, v2)
	local result = {}
	result[1] = v1[2]*v2[3] - v1[3]*v2[2]
	result[2] = v1[3]*v2[1] - v1[1]*v2[3]
	result[3] = v1[1]*v2[2] - v1[2]*v2[1]
	return result
end

function Vector.nul(l)
	local result = {}
	for i = 1, l do
		result[i] = 0
	end
	return result
end

function Vector.unit(v)
	if Vector.len(v) == 0 then 
		error()
	else 
		return Vector.mul(1/Vector.len(v), v) 
	end
end

function Vector.projection(v1, v2)
	if Vector.len2(v2) == 0 then 
		return Vector.nul(#v2)
	else 
		return Vector.mul(Vector.dot(v1, v2)/Vector.len2(v2), v2) 
	end
end

function Vector.plane_projection(v1, v2)
	return Vector.sub(v1, Vector.projection(v1, v2))
end

function Vector.rotate2D(v, a)
	local result = {}
	result[1] = v[1]*math.cos(a) - v[2]*math.sin(a)
	result[2] = v[1]*math.sin(a) + v[2]*math.cos(a)
	return result
end

function Vector.spherical(r, theta, phi)
	--https://en.wikipedia.org/wiki/Spherical_coordinate_system
	--r in [0, +infinity)
	--theta in [0, pi]
	--phi in [0, 2pi)
	local result = {}
	result[1] = r*math.sin(theta)*math.cos(phi)
	result[2] = r*math.sin(theta)*math.sin(phi)
	result[3] = r*math.cos(theta)
	return result
end

function Vector.print(v)
	local str = "{"
	for i = 1, #v-1 do
		str = str .. v[i] .. ", "
	end
	str = str .. v[#v] .. "}"
	print(str)
end

function Vector.copy(v)
	local result = {}
	for i = 1, #v do
		result[i] = v[i]
	end
	return result
end

function Matrix.mulv(m, v)
	local result = {}
	for i = 1, #m do
		result[i] = Vector.dot(m[i], v)
	end
	return result
end

function Matrix.mulm(m1, m2)
	local result = {}
	local I = #m1
	local J = #m2[1]
	local K = #m2
	for i = 1, I do
		result[i] = {}
		for j = 1, J do
			result[i][j] = 0
			for k = 1, K do
				result[i][j] = result[i][j] + m1[i][k]*m2[k][j]
			end
		end
	end
	return result
end

function Matrix.perspective(fovy, aspect, zNear, zFar)
  local f = 1/math.tan(fovy / 2)
  local result = {
    {f/aspect, 0, 0                        , 0 							            },
    {0       , f, 0                        , 0 							            },
    {0       , 0, (zFar+zNear)/(zNear-zFar), (2*zFar*zNear)/(zNear-zFar)},
    {0       , 0, -1					             , 0 							            }
  }
  return result
end

function Matrix.lookAt(eye, center, up)
  local F = Vector.sub(center, eye)
  local f = Vector.unit(F)
  local up2 = Vector.unit(up)
  local s = Vector.cross(f, up2)
  local u = Vector.cross(Vector.unit(s), f)
  local m = {
    {s[1] , s[2] , s[3] , 0},
    {u[1] , u[2] , u[3] , 0},
    {-f[1], -f[2], -f[3], 0},
    {0    , 0    , 0    , 1}
  }
	local t = {
		{1, 0, 0, -eye[1]},
		{0, 1, 0, -eye[2]},
		{0, 0, 1, -eye[3]},
		{0, 0, 0, 1      }
	}
	local result = Matrix.mulm(m, t)
    return result
end

function Matrix.print(m)
	local str = "{"
	local I = #m
	local J = #m[1]
	for i = 1, I do
		str = str .. "{"
		for j = 1, J do
			str = str .. m[i][j] .. ", "
		end
		str = str:sub(1, -3)
		str = str .. "},\n"
	end
	str = str:sub(1, -3)
	str = str .. "}"
	print(str)
end

return {Vector, Matrix}