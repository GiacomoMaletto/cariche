local pShader = love.graphics.newShader([[
  uniform mat4 MVP;

	vec4 position(mat4 transform_projection, vec4 vertex_position){
		return MVP * vec4(vertex_position.xyz, 1.0);
	}
]])

local V, M = unpack(require "vector")

love.mouse.setRelativeMode(true)
love.graphics.setDefaultFilter("nearest", "nearest")
love.graphics.setPointSize(1)

local sw, sh = love.graphics.getDimensions()

local camera = {}
camera.xyz = {-2, 0, 0.5}
camera.phi = 0
camera.theta = math.rad(90)
function camera.dir()
  return V.spherical(1, camera.theta, camera.phi)
end
function camera.right()
  return V.unit(V.cross(camera.dir(), {0,0,1}))
end
function camera.up()
  return V.unit(V.cross(camera.right(), camera.dir()))
end
local projection_matrix = M.perspective(math.rad(70), sw/sh, 0.1, 100)
function camera.mvp()
  local view_matrix = M.lookAt(camera.xyz, V.add(camera.xyz, camera.dir()), camera.up())
  local mvp = M.mulm(projection_matrix, view_matrix)
  return mvp
end

local points = {}
local N = 10000
for i = 1, N do
  points[i] = {love.math.random(), love.math.random(), love.math.random()}
end
local mesh = love.graphics.newMesh({{"VertexPosition", "float", 3}}, points, "points", "stream")

function love.mousemoved(x, y, dx, dy, istouch)
  camera.phi = camera.phi - dx/200
  local new_theta = camera.theta + dy/200
  if 0 <= new_theta and new_theta <= math.rad(180) then camera.theta = new_theta end
end

local dt = 1/60
local t = 0

function love.update(Dt)
  dt = Dt
  t = t + dt
  if love.keyboard.isDown("escape") then
    love.event.quit()
  end

  if love.keyboard.isDown("w") then
    camera.xyz = V.add(camera.xyz, V.mul(dt, camera.dir()))
  end
  if love.keyboard.isDown("s") then
    camera.xyz = V.add(camera.xyz, V.mul(-dt, camera.dir()))
  end
  if love.keyboard.isDown("d") then
    camera.xyz = V.add(camera.xyz, V.mul(dt, camera.right()))
  end
  if love.keyboard.isDown("a") then
    camera.xyz = V.add(camera.xyz, V.mul(-dt, camera.right()))
  end
  if love.keyboard.isDown("z") then
    camera.xyz = V.add(camera.xyz, V.mul(dt, {0,0,1}))
  end
  if love.keyboard.isDown("x") then
    camera.xyz = V.add(camera.xyz, V.mul(-dt, {0,0,1}))
  end
end

function love.draw()
  love.graphics.setShader(pShader)
  pShader:send("MVP", camera.mvp())
	love.graphics.draw(mesh)
	love.graphics.setShader()
end