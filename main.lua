function love.load()
	-- load third-party libraries
    tick = require "libraries.tick"
	Object = require "libraries.classic"
	
	-- load core scripts
	require "core.graphics"
	require "core.init"
	
	require "core.camera"
	require "core.math"
	require "core.collisions"
	require "core.pathfinding"
	require "core.character"
	require "core.world"
	require "core.kminput"
	require "core.menu"
	require "core.button"
	
	-- mount source folder
	local dir = love.filesystem.getSourceBaseDirectory()
	mnt = love.filesystem.mount(dir, "src")
	-- load level
	if love.filesystem.getInfo("/levels/testlevel.lua") ~= nil or love.filesystem.getInfo("mnt/levels/testlevel.lua") ~= nil then
		nCity = City("testlevel",true)
	else
		nCity = City("blank",true,200,100,8) end
	--titleScreen()
end

function love.update(dt)
	-- any QA messages go here
	local _msg = ch:pop()
	while _msg do
		table.insert(QAlog,{_msg,10})
		_msg = ch:pop()
	end
	while table.maxn(QAlog) > 38 do
		table.remove(QAlog,1)
	end
	for i,v in ipairs(QAlog) do
		if paused == false then v[2] = v[2] - 1 * dt end
		if v[2] <= 0 then table.remove(QAlog,i) end
	end
	-- handle hitching
	if dt > .5 then
		paused = true
		hitching = 2
	end
	-- thread pausing if enabled
	if maxThreadPaused and threads < maxThreads then
		paused = false
		maxThreadPaused = false
	end
	-- Begin Step
	
	if scene == "play" then
		if sunColor[1] ~= sunColorChange[1] or sunColor[2] ~= sunColorChange[2] or sunColor[3] ~= sunColorChange[3] then
			local tock = sunColor[1] - sunColorChange[1]
			local tick = (.025 * dt * gameSpeed)
			if math.abs(tock) <= tick then sunColor[1] = sunColorChange[1]
			else sunColor[1] = sunColor[1] - (tick * (tock/math.abs(tock))) end
			tock = sunColor[2] - sunColorChange[2]
			if math.abs(tock) <= tick then sunColor[2] = sunColorChange[2]
			else sunColor[2] = sunColor[2] - (tick * (tock/math.abs(tock))) end
			tock = sunColor[3] - sunColorChange[3]
			if math.abs(tock) <= tick then sunColor[3] = sunColorChange[3]
			else sunColor[3] = sunColor[3] - (tick * (tock/math.abs(tock))) end
			shLighting:send("redC",sunColor[1])
			shLighting:send("greenC",sunColor[2])
			shLighting:send("blueC",sunColor[3])
		end
	end
	
	tick.update(dt)
	kmInputBeginStep(dt)
	
	for i,v in ipairs(cTable) do
		v:beginStep(dt)
	end
		
	-- Step
	currentCity:Step()
	for i,v in ipairs(cTable) do
		v:Step(dt)
	end
	cam:Step(dt)
	
	for i,v in ipairs(buttons) do
		v:Step()
	end
	
	-- End Step
	kmInputEndStep()
	currentCity:endStep(dt)
	for i,v in ipairs(cTable) do
		v:endStep()
	end
	table.sort(cTable,sortCharacters)
	
	cam:endStep()
	if hitching > 0 then
		hitching = hitching - 1
		if hitching == 0 then paused = false end
	end
	
	updateColors()
end

function love.draw()
	cam:set()
	currentCity:draw()
	
	for i,v in ipairs(cTable) do
		v:draw()
	end
	cam:unset()
	
	for i,v in ipairs(buttons) do
		v:draw()
	end
	
	local debug_string = love.timer.getFPS() .. "\n" .. threads .. "\n" .. scene
	if scene == "play" then
		if paused then
			debug_string = debug_string .. " ||"
		else
			debug_string = debug_string .. " " .. gameSpeed .. "x"
		end
	elseif scene == "build" then
		debug_string = debug_string .. " " .. buildObject[1] .. " " .. buildObject[2]
		if mode == "point" then
			debug_string = debug_string .. " point"
		elseif mode == "line" then
			debug_string = debug_string .. " line"
		elseif mode == "rect" then
			debug_string = debug_string .. " rectangle"
		elseif mode == "fill" then
			debug_string = debug_string .. " fill"
		end
	end
	debug_string = debug_string .. "\n" .. string.format("%02d:%02d",clockTime[1],math.floor(clockTime[2]))
	--debug_string = debug_string .. "\n" .. table.concat(sunColor,", ") .. "\n" .. table.concat(sunColorChange,", ")
	love.graphics.print(debug_string)
	if err ~= nil then
		love.graphics.print(err, 5, 20)
	end
	if QAlog[1] ~= nil then
		str = ""
		local _count = 0
		for i,v in ipairs(QAlog) do
			_count = _count + 1
			str = str .. v[1] .. "\n"
		end
		love.graphics.printf(str,8,love.graphics.getHeight()-16*_count,1024,"left")
	end
end

function love.quit()
	currentCity:save("testlevel")
end
