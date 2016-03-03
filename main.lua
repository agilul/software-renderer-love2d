-- Copyright 2016 Yat Hin Wong

vector = require "vector"
matrix = require "matrix"

function love.load()
	imgWidth, imgHeight = 600, 600
	love.window.setMode(imgWidth, imgHeight)
	screenCenter = vector(imgWidth/2, imgHeight/2)
	love.mouse.setPosition(screenCenter.x, screenCenter.y)
	love.mouse.setVisible(false)
	
	-- loads the vertex list of a Newell teapot
	local index = 1
	teapot = {}
	for line in love.filesystem.lines("teapot") do
		local _, _, x, y, z = string.find(line, "(%-?%d+%.%d+),(%-?%d+%.%d+),(%-?%d+%.%d+)")
		teapot[index] = vector(x, y, z)
		index = index + 1
	end
	
	forwardVec = vector(0, 0, -1)
	upVec = vector(0, 1, 0)
	leftVec = upVec:cross(forwardVec)
	cameraMatrix = matrix.createIdentityMatrix()
	cameraMatrix[4][2] = 5
	cameraMatrix[4][3] = 10
	worldToCamera = matrix.inverse(cameraMatrix)
	
	-- creates a perspective projection matrix with FoV, near and far planes
	projMatrix = matrix.createProjectionMatrix(90, 0.1, 100)
	
	instructions = true
	instructionsTimeout = 10
end

function love.update(dt)
	if love.keyboard.isDown("escape") then
		love.event.quit()
	end
	
	local rotationVec, rotationAngle = vector(1, 0, 0), 0
	local dMousePos = vector(love.mouse.getPosition()) - screenCenter
	love.mouse.setPosition(imgWidth/2, imgHeight/2)
	
	-- yaw
	if math.abs(dMousePos.x) > 0 then
		rotationVec = upVec
		rotationAngle = -dMousePos.x * dt / 30
	end
	cameraMatrix = matrix.multiply(matrix.createRotationMatrix(rotationVec, rotationAngle), cameraMatrix)
	
	-- pitch
	if math.abs(dMousePos.y) > 0 then
		rotationVec = leftVec
		rotationAngle = -dMousePos.y * dt / 30
	end
	cameraMatrix = matrix.multiply(matrix.createRotationMatrix(rotationVec, rotationAngle), cameraMatrix)
	
	-- roll
	if love.keyboard.isDown("q") then
		rotationVec = forwardVec
		rotationAngle = 1 * dt
	elseif love.keyboard.isDown("e") then
		rotationVec = forwardVec
		rotationAngle = -1 * dt
	end
	cameraMatrix = matrix.multiply(matrix.createRotationMatrix(rotationVec, rotationAngle), cameraMatrix)
	
	-- panning controls
	local translateVec = vector(0, 0, 0)
	
	if love.keyboard.isDown("w") or love.keyboard.isDown("up") then
		translateVec = translateVec - upVec * dt
	elseif love.keyboard.isDown("s") or love.keyboard.isDown("down") then
		translateVec = translateVec + upVec * dt
	end
	
	if love.keyboard.isDown("a") or love.keyboard.isDown("left") then
		translateVec = translateVec + leftVec * dt
	elseif love.keyboard.isDown("d") or love.keyboard.isDown("right") then
		translateVec = translateVec - leftVec * dt
	end
	
	if love.keyboard.isDown("r") then
		translateVec = translateVec - forwardVec * dt
	elseif love.keyboard.isDown("f") then
		translateVec = translateVec + forwardVec * dt
	end
	
	translateVec:normalizeInplace()
	cameraMatrix = matrix.multiply(matrix.createTranslationMatrix(translateVec), cameraMatrix)

	-- move by moving the rest
	-- http://futurama.wikia.com/wiki/Dark_matter_engine
	worldToCamera = matrix.inverse(cameraMatrix)

	-- transforms the world from 3D space to 2D screen
	points = {}
	index = 0 
	for i, v in ipairs(teapot) do
		local cameraVert = v:multVecMatrix(worldToCamera)
		if cameraVert * forwardVec > 0 then
			local projected = cameraVert:multVecMatrix(projMatrix)
			if projected.x >= -1 and projected.x <= 1 and projected.y >= -1 and projected.y <= 1 then
				local screen_x = math.min(imgWidth - 1, math.floor((projected.x + 1) * 0.5 * imgWidth))
				local screen_y = math.min(imgHeight - 1, math.floor((projected.y + 1) * 0.5 * imgHeight))
				points[index] = {screen_x, screen_y}
				index = index + 1
			end
		end
	end
	
	if instructions then
		if instructionsTimeout < 0 then
			instructions = false
		end
		instructionsTimeout = instructionsTimeout - dt
	end
end

function love.draw()
	love.graphics.setPointSize(2)
	love.graphics.points(points);
	
	if instructions then
		love.graphics.setColor(255, 255, 255)
		love.graphics.printf("WASD to move up/left/down/right\nF/R to move forward/backward\nMouse to yaw/pitch\nQ/E to roll\nESC to exit", 0, 0, imgWidth, "left", 0, 2)
	end
end
