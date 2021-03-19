local pShader = love.graphics.newShader([[
  uniform mat4 MVP;

	vec4 position(mat4 transform_projection, vec4 vertex_position){
		return MVP * vec4(vertex_position.xyz, 1.0);
	}
]])

local V, M = unpack(require "vector")

love.mouse.setRelativeMode(true)
love.graphics.setDefaultFilter("nearest", "nearest")
love.graphics.setPointSize(4)

local sw, sh = love.graphics.getDimensions()

local camera = {}
camera.xyz = {-40, 0, 20}
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

local N = 200
local points1 = {}
local points2 = {}
local force = {}
for i = 1, N do
  points1[i] = {love.math.random()*10, love.math.random()*10, love.math.random()*10}
  points2[i] = {points1[i][1], points1[i][2], points1[i][3]}
  force[i] = {0, 0, 0}
end
local mesh = love.graphics.newMesh({{"VertexPosition", "float", 3}}, points1, "points", "stream")
local distance3, dx, dy, dz = 0, 0, 0, 0
local new_i = 1

function love.mousemoved(x, y, dx, dy, istouch)
  camera.phi = camera.phi - dx/200
  local new_theta = camera.theta + dy/200
  if 0 <= new_theta and new_theta <= math.rad(180) then camera.theta = new_theta end
end

local dt = 1/60
local t = 0

local function update_points(p, op)
  for i = 1, N do
    for j = 1, i-1 do
      dx = p[i][1] - p[j][1]
      dy = p[i][2] - p[j][2]
      dz = p[i][3] - p[j][3]
      distance3 = math.pow(dx*dx + dy*dy + dz*dz, 3/2)
      force[i][1] = force[i][1] + dx/distance3
      force[i][2] = force[i][2] + dy/distance3
      force[i][3] = force[i][3] + dz/distance3
    end
    for j = i+1, N do
      dx = p[i][1] - p[j][1]
      dy = p[i][2] - p[j][2]
      dz = p[i][3] - p[j][3]
      distance3 = math.pow(dx*dx + dy*dy + dz*dz, 3/2)
      force[i][1] = force[i][1] + dx/distance3
      force[i][2] = force[i][2] + dy/distance3
      force[i][3] = force[i][3] + dz/distance3
    end
  end

  for i = 1, N do
    op[i][1] = 2*p[i][1] - op[i][1] + force[i][1]*0.00001
    op[i][2] = 2*p[i][2] - op[i][2] + force[i][2]*0.00001
    op[i][3] = 2*p[i][3] - op[i][3] + force[i][3]*0.00001
  end

  for i = 1, N do
    distance3 = math.pow(op[i][1]*op[i][1] + op[i][2]*op[i][2] + op[i][3]*op[i][3], 1/2)
    op[i][1] = op[i][1]/distance3*10
    op[i][2] = op[i][2]/distance3*10
    op[i][3] = op[i][3]/distance3*10
  end
end

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
  if love.keyboard.isDown("space") then
    camera.xyz = V.add(camera.xyz, V.mul(dt, {0,0,1}))
  end
  if love.keyboard.isDown("lctrl") then
    camera.xyz = V.add(camera.xyz, V.mul(-dt, {0,0,1}))
  end

  local start = love.timer.getTime()

  for i = 1, N do
    force[i][1] = 0
    force[i][2] = 0
    force[i][3] = 0
  end

  new_i = 3 - new_i
  if new_i == 1 then
    update_points(points2, points1)
    mesh:setVertices(points1)
  else
    update_points(points1, points2)
    mesh:setVertices(points2)
  end

  local result = love.timer.getTime() - start
  print( string.format( "It took %.3f milliseconds", result * 1000 ))
end

function love.draw()
  love.graphics.setShader(pShader)
  pShader:send("MVP", camera.mvp())
  love.graphics.draw(mesh)
  love.graphics.setShader()
end