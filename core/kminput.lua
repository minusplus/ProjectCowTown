function kmInputBeginStep(dt)
	--temporary functions
	if love.keyboard.isDown("s") and scene == "build" then --save
		currentCity:save("testlevel")
	end
	if love.keyboard.isDown("b") then --enter build mode
		scene = "build"
	end
	if love.keyboard.isDown("v") then --enter play mode
		scene = "play"
	end
	
	--convert window mouse coordinates with absolute mouse coordinates
	mx = (love.mouse.getX() * cam.scaleX) + cam.x
	my = (love.mouse.getY() * cam.scaleY) + cam.y
	mtx = math.min(math.max(math.floor(mx/32),1),table.maxn(currentCity.mapW[1][1]))
	mty = math.min(math.max(math.floor(my/32),1),table.maxn(currentCity.mapW[1]))
	
	-- pan camera with keyboard
	if love.keyboard.isDown(keyboardControls["left"]) then
		cam.following = nil
		cam:move(-cam.spd * dt, 0)
	elseif love.keyboard.isDown(keyboardControls["right"]) then
		cam.following = nil
		cam:move(cam.spd * dt, 0)
	end		
	if love.keyboard.isDown(keyboardControls["up"]) then
		cam.following = nil
		cam:move(0, -cam.spd * dt)
	elseif love.keyboard.isDown(keyboardControls["down"]) then
		cam.following = nil
		cam:move(0, cam.spd * dt)
	end
	
	-- zoom in and out
	if love.keyboard.isDown(keyboardControls["zoomout"]) then
		cam.scaleX = cam.scaleX + 1*dt
		cam.scaleY = cam.scaleY + 1*dt
		if cam.scaleX > 4 then cam.scaleX = 4 cam.scaleY = 4 end
	elseif love.keyboard.isDown(keyboardControls["zoomin"]) then
		cam.scaleX = cam.scaleX - 1*dt
		cam.scaleY = cam.scaleY - 1*dt
		if cam.scaleX < .2 then cam.scaleX = .2 cam.scaleY = .2 end
	end
end

function kmInputEndStep()
	--turn off mouse pressed and released variables
	mousePressed = false
	mouseReleased = false
end

function love.mousepressed(x, y, button, touched, clicks)
	--set mouse pressed variables
	mousePressed = true
	mouseButton = button
	mouseClicks = clicks
	mouseTouched = touched
	if button == 3 and mouseHeld == false then
		gx = (x * cam.scaleX) + cam.x
		gy = (y * cam.scaleY) + cam.y
		mouseHeld = true
	end
end

function love.mousereleased(x, y, button, touched, clicks)
	--set mouse released variables
	mouseReleased = true
	mouseButton = button
	mouseClicks = clicks
	mouseTouch = touched
	if button == 3 and mouseHeld == true then
		rx = (x * cam.scaleX) + cam.x
		ry = (y * cam.scaleY) + cam.y
		mouseHeld = false
	end
end

function love.wheelmoved(x,y)
	
	if y ~= 0 then
		if love.keyboard.isDown("lctrl") or love.keyboard.isDown("rctrl") then
			-- change z level
			cam.z = cam.z + y
			if cam.z < 1 then cam.z = 1 end
			if cam.z > table.maxn(currentCity.mapW) then cam.z = table.maxn(currentCity.mapW) end
			currentCity:tsBatchUpdateAll()
		else
			-- zoom with scrollwheel
			cam.scaleX = cam.scaleX - y/10
			cam.scaleY = cam.scaleY - y/10
			if cam.scaleX > 4 then cam.scaleX = 4 cam.scaleY = 4 end
			if cam.scaleX < .125 then cam.scaleX = .125 cam.scaleY = .125 end
		end
	end
end

function love.keypressed(key,scancode,isrepeat)
	--toggle fullscreen
	if key == keyboardControls["togglefullscreen"] then
		love.window.setFullscreen(not love.window.getFullscreen())
	end
	if scene == "play" then--change speeds
		if key == keyboardControls["speed1x"] then paused = false gameSpeed = 1 end
		if key == keyboardControls["speed2x"] then paused = false gameSpeed = 2 end
		if key == keyboardControls["speed3x"] then paused = false gameSpeed = 4 end
		if key == keyboardControls["speed4x"] then paused = false gameSpeed = 8 end
		if key == keyboardControls["showPaths"] then showPaths = not showPaths end
	elseif scene == "build" then
		if key == keyboardControls["speed1x"] then mode = "point" end
		if key == keyboardControls["speed2x"] then mode = "line" end
		if key == keyboardControls["speed3x"] then mode = "rect" end
		if key == keyboardControls["speed4x"] then mode = "fill" end
		if key == keyboardControls["buildcharacter"] then --build characters
			buildObject = {"character","William"}
		elseif key == keyboardControls["buildwall"] then --build walls
			if buildObject[1] ~= "wall" then
				buildObject = {"wall",0}
			else
				buildObject[2] = buildObject[2] + 1
				if buildObject[2] > table.maxn(tsWallQuads)/16-1 then buildObject[2] = 0 end
			end
		elseif key == keyboardControls["buildupstairs"] then --build stairs up
			buildObject = {"stair",2}
		elseif key == keyboardControls["builddownstairs"] then --build stairs down
			buildObject = {"stair",1}
		elseif key == keyboardControls["buildfloor"] then --build floor
			if buildObject[1] ~= "floor" then
				buildObject = {"floor",0}
			else
				buildObject[2] = buildObject[2] + 1
				if buildObject[2] > table.maxn(tsFloorQuads)/16-1 then buildObject[2] = 0 end
			end
		end
	end
	if key == keyboardControls["pause"] then paused = not paused end
	
end