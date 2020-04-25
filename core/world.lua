City = Object:extend()

function City:new(levelfile,setCurrent,width,height,depth)
	if not width then width = 100 end
	if not height then height = 100 end
	if not depth then depth = 8 end
	cam.z = math.ceil(depth / 3)
	groundLevel = cam.z
	if setCurrent then currentCity=self end
	if levelfile ~= "blank" then
		if love.filesystem.getInfo("/levels/" .. levelfile .. ".lua") ~= nil then
			love.filesystem.load("/levels/" .. levelfile .. ".lua")(self)
		elseif love.filesystem.getInfo("mnt/levels/" .. levelfile .. ".lua") ~= nil then
			love.filesystem.load("mnt/levels/" .. levelfile .. ".lua")(self)
		end
		width = table.maxn(self.mapF[1][1])
		height = table.maxn(self.mapF[1])
	else
		self.mapW = {} -- walls
		self.mapF = {} -- floors
		self.mapS = {} -- stairs
		self.mapR = {} -- rooms
		self.mapP = {} -- properties
		for k=1,depth do
			self.mapW[k] = {}
			self.mapF[k] = {}
			for i=1,height do
				self.mapW[k][i] = {}
				self.mapF[k][i] = {}
				for j=1,width do
					self.mapW[k][i][j] = -1
					if k == cam.z then self.mapF[k][i][j] = 1 else self.mapF[k][i][j] = 0 end
				end
			end
		end
	end
	
	self.tsWallBatch = {}

	for i=1,math.ceil(height/100)+1 do
		self.tsWallBatch[i] = {}
		for j=1,math.ceil(width/100)+1 do
			self.tsWallBatch[i][j] = love.graphics.newSpriteBatch(tsWalls,1000)
		end
	end
	
	self.tsFloorBatch = {}
	
	for i=1,math.ceil(height/100)+1 do
		self.tsFloorBatch[i] = {}
		for j=1,math.ceil(width/100)+1 do
			self.tsFloorBatch[i][j] = love.graphics.newSpriteBatch(tsFloors,1000)
		end
	end
	
	self.tsStairBatch = {}
	
	for i=1,math.ceil(height/100)+1 do
		self.tsStairBatch[i] = {}
		for j=1,math.ceil(width/100)+1 do
			self.tsStairBatch[i][j] = love.graphics.newSpriteBatch(tsStairs,1000)
		end
	end

	self:tsBatchUpdateAll()
end

function City:Step()
	if scene == "build" then
		if fillChannel == nil and lineHeld == false then
			if buildObject[1] == "wall" then
				if love.mouse.isDown(1) then
					if mode == "point" then self.mapW[cam.z][mty][mtx] = buildObject[2]
					elseif mode == "line" or mode == "rect" and mousePressed then lineX,lineY,lineHeld,fillOn = mtx,mty,true,true
					elseif mode == "fill" and mousePressed then fillChannel, fillOn = bucketFill(mtx,mty,cam.z),true end
					self:tsBatchUpdate(mtx,mty)
				elseif love.mouse.isDown(2) then
					if mode == "point" then self.mapW[cam.z][mty][mtx] = -1
					elseif mode == "line" or mode == "rect" and mousePressed then lineX,lineY,lineHeld,fillOn = mtx,mty,true,false
					elseif mode == "fill" and mousePressed then fillChannel,fillOn = bucketFill(mtx,mty,cam.z),false end
					self:tsBatchUpdate(mtx,mty)
				end
			elseif buildObject[1] == "floor" then
				if love.mouse.isDown(1) then
					if mode == "point" then self.mapF[cam.z][mty][mtx] = buildObject[2]
					elseif mode == "line" or mode == "rect" and mousePressed then lineX,lineY,lineHeld,fillOn = mtx,mty,true,true
					elseif mode == "fill" and mousePressed then fillChannel, fillOn = bucketFill(mtx,mty,cam.z),true end
					self:tsBatchUpdate(mtx,mty)
				elseif love.mouse.isDown(2) then
					if mode == "point" then self.mapF[cam.z][mty][mtx] = -1
					elseif mode == "line" or mode == "rect" and mousePressed then lineX,lineY,lineHeld,fillOn = mtx,mty,true,false
					elseif mode == "fill" and mousePressed then fillChannel,fillOn = bucketFill(mtx,mty,cam.z),false end
					self:tsBatchUpdate(mtx,mty)
				end
			elseif buildObject[1] == "character" then
				if love.mouse.isDown(1) then
					local banged = false
					for i,j in ipairs(cTable) do
						if charClick(j) then
							banged = true
						end
					end
					if banged == false then
						local coord_place = {16+mtx*32,32+mty*32,cam.z}
						table.insert(cTable,Character(coord_place,{mtx,mty,cam.z},"William"))
					end
				elseif love.mouse.isDown(2) then
					for i,j in ipairs(cTable) do
						if charClick(j) then
							table.remove(cTable,i)
						end
					end
				end
			elseif buildObject[1] == "stair" then
				local v = tableContainsCoordinates(self.mapS,{mtx,mty,cam.z})
				if love.mouse.isDown(1) and v == false then
					if buildObject[2] == 1 and cam.z ~= 1 then
						table.insert(self.mapS,{mtx,mty,cam.z,1})
						table.insert(self.mapS,{mtx,mty,cam.z-1,2})
						self:tsBatchUpdate(mtx,mty)
					elseif buildObject[2] == 2 and cam.z ~= table.maxn(self.mapW) then
						table.insert(self.mapS,{mtx,mty,cam.z,2})
						table.insert(self.mapS,{mtx,mty,cam.z+1,1})
						self:tsBatchUpdate(mtx,mty)
					end
				elseif love.mouse.isDown(2) and v then
					if self.mapS[v][4] == 1 then
						table.remove(self.mapS,v)
						local vv = tableContainsCoordinates(self.mapS,{mtx,mty,cam.z-1})
						if vv then table.remove(self.mapS,vv) end
						self:tsBatchUpdate(mtx,mty)
					elseif self.mapS[v][4] == 2 then
						table.remove(self.mapS,v)
						local vv = tableContainsCoordinates(self.mapS,{mtx,mty,cam.z+1})
						if vv then table.remove(self.mapS,vv) end
						self:tsBatchUpdate(mtx,mty)
					end
				end	
			end
		elseif fillChannel ~= nil then
			local f_x, f_y = returnPath(fillChannel)
			if f_x ~= nil then
				for i=1,table.maxn(f_x) do
					if buildObject[1] == "floor" then
							if fillOn then self.mapF[cam.z][f_y[i]][f_x[i]] = buildObject[2] else self.mapF[cam.z][f_y[i]][f_x[i]] = -1 end
						elseif buildObject[1] == "wall" then
							if fillOn then self.mapW[cam.z][f_y[i]][f_x[i]] = buildObject[2] else self.mapW[cam.z][f_y[i]][f_x[i]] = -1 end
						end
				end
				self:tsBatchUpdateAll()
				fillChannel = nil
			end
		else
			if mouseReleased then
				if mode == "line" then
					if math.abs(mtx-lineX) > math.abs(mty-lineY) then
						for i=math.min(mtx,lineX),math.max(mtx,lineX) do
							if buildObject[1] == "floor" then
								if fillOn then self.mapF[cam.z][lineY][i] = buildObject[2] else self.mapF[cam.z][lineY][i] = -1 end
							elseif buildObject[1] == "wall" then
								if fillOn then self.mapW[cam.z][lineY][i] = buildObject[2] else self.mapW[cam.z][lineY][i] = -1 end
							end
						end
					else
						for i=math.min(mty,lineY),math.max(mty,lineY) do
							if buildObject[1] == "floor" then
								if fillOn then self.mapF[cam.z][i][lineX] = buildObject[2] else self.mapF[cam.z][i][lineX] = -1 end
							elseif buildObject[1] == "wall" then
								if fillOn then self.mapW[cam.z][i][lineX] = buildObject[2] else self.mapW[cam.z][i][lineX] = -1 end
							end
						end
					end
				else
					for j=math.min(mtx,lineX),math.max(mtx,lineX) do
						for i=math.min(mty,lineY),math.max(mty,lineY) do
							if buildObject[1] == "floor" then
								if fillOn then self.mapF[cam.z][i][j] = buildObject[2] else self.mapF[cam.z][i][j] = -1 end
							elseif buildObject[1] == "wall" then
								if fillOn then self.mapW[cam.z][i][j] = buildObject[2] else self.mapW[cam.z][i][j] = -1 end
							end
						end
					end
				end
			lineHeld = false
			self:tsBatchUpdateAll()
			end
		end
	end
end

function City:endStep(dt)
	if scene == "play" and paused == false then
		clockTime[2] = clockTime[2] + (dt * gameSpeed)/2
		if clockTime[2] >= 60 then
			clockTime[2] = 0
			clockTime[1] = clockTime[1] + 1
			if clockTime[1] >= 24 then clockTime[1] = 0 end
		end
	end
end

function City:tsBatchUpdate(q_x,q_y)
	q_x = math.ceil(q_x/100)
	q_y = math.ceil(q_y/100)
	local xpairs = table.maxn(self.mapW[1][1])
	local ypairs = table.maxn(self.mapW[1])
	local c_x = 100*(q_x-1)+1
	local c_y = 100*(q_y-1)+1
	
	self.tsFloorBatch[q_x][q_y]:clear()
	for i=c_x, math.min(c_x + 100,xpairs) do
		for j=c_y, math.min(c_y + 100,ypairs) do
			if self.mapF[cam.z][j][i] ~= -1 then
				--local ch = love.thread.getChannel("QA")
				--ch:push (cam.z)
				local s_tiles = {}
				if j > 1 then s_tiles[1] = self.mapF[cam.z][j-1][i] else s_tiles[1] = 0 end
				if i > 1 then s_tiles[2] = self.mapF[cam.z][j][i-1] else s_tiles[2] = 0 end
				if i < xpairs then s_tiles[3] = self.mapF[cam.z][j][i+1] else s_tiles[3] = 0 end
				if j < ypairs then s_tiles[4] = self.mapF[cam.z][j+1][i] else s_tiles[4] = 0 end
				local a_tile = autoTile(self.mapF[cam.z][j][i],s_tiles)+(self.mapF[cam.z][j][i]*16)
				self.tsFloorBatch[q_x][q_y]:add(tsFloorQuads[a_tile],i*32,j*32)
			end
		end
	end
	
	self.tsWallBatch[q_x][q_y]:clear()
	for i=c_x, math.min(c_x + 100,xpairs) do
		for j=c_y, math.min(c_y + 100,ypairs) do
			if self.mapW[cam.z][j][i] ~= -1 then
				--local ch = love.thread.getChannel("QA")
				--ch:push (cam.z)
				local s_tiles = {}
				if j > 1 then s_tiles[1] = self.mapW[cam.z][j-1][i] else s_tiles[1] = 0 end
				if i > 1 then s_tiles[2] = self.mapW[cam.z][j][i-1] else s_tiles[2] = 0 end
				if i < xpairs then s_tiles[3] = self.mapW[cam.z][j][i+1] else s_tiles[3] = 0 end
				if j < ypairs then s_tiles[4] = self.mapW[cam.z][j+1][i] else s_tiles[4] = 0 end
				local a_tile = autoTile(self.mapW[cam.z][j][i],s_tiles)+(self.mapW[cam.z][j][i]*16)
				self.tsWallBatch[q_x][q_y]:add(tsWallQuads[a_tile],i*32,j*32)
			end
		end
	end
	
	self.tsStairBatch[q_x][q_y]:clear()
	for i=c_x, math.min(c_x + 100,xpairs) do
		for j=c_y, math.min(c_y + 100,ypairs) do
			local v = tableContainsCoordinates(self.mapS,{i,j,cam.z})
			if v then
				self.tsStairBatch[q_x][q_y]:add(tsStairQuads[self.mapS[v][4]],i*32,j*32)
			end
		end
	end
end

function City:tsBatchUpdateAll()
	for i,row in ipairs(self.tsFloorBatch) do
		for j,pair in ipairs(self.tsFloorBatch[i]) do
			self:tsBatchUpdate(i*100,j*100)
		end
	end
end

function City:draw()
	if scene == "play" then love.graphics.setShader(shLighting) end
	for i,row in ipairs(self.tsFloorBatch) do
		for j,pair in ipairs(self.tsFloorBatch[i]) do
			love.graphics.draw(self.tsFloorBatch[i][j])
		end
	end
	for i,row in ipairs(self.tsWallBatch) do
		for j,pair in ipairs(self.tsWallBatch[i]) do
			love.graphics.draw(self.tsWallBatch[i][j])
		end
	end
	for i,row in ipairs(self.tsStairBatch) do
		for j,pair in ipairs(self.tsStairBatch[i]) do
			love.graphics.draw(self.tsStairBatch[i][j])
		end
	end
	love.graphics.setShader()
	
	if scene == "build" then
		love.graphics.setColor(1,1,1,.5)
		if lineHeld then
			if mode == "line" then
				if math.abs(mtx-lineX) > math.abs(mty-lineY) then
					if lineX > mtx then
						love.graphics.rectangle("fill",(mtx)*32,lineY*32,32*(lineX-mtx+1),32)
					else
						love.graphics.rectangle("fill",lineX*32,lineY*32,32*(mtx-lineX+1),32)
					end
					love.graphics.setColor(0,0,0,1)
					love.graphics.print(math.abs(mtx-lineX)+1,((mtx+lineX)/2)*32,lineY*32+16)
				else
					if lineY > mty then
						love.graphics.rectangle("fill",lineX*32,(mty)*32,32,32*(lineY-mty+1))
					else
						love.graphics.rectangle("fill",lineX*32,lineY*32,32,32*(mty-lineY+1))
					end
					love.graphics.setColor(0,0,0,1)
					love.graphics.print(math.abs(mty-lineY)+1,lineX*32+16,((mty+lineY)/2)*32)
				end
			else
				local _x1,_x2 = math.min(mtx,lineX),math.max(mtx,lineX)
				local _y1,_y2 = math.min(mty,lineY),math.max(mty,lineY)
				love.graphics.rectangle("fill",_x1*32,_y1*32,32*(_x2-_x1+1),32*(_y2-_y1+1))
				love.graphics.setColor(0,0,0,1)
				love.graphics.print(_x2-_x1+1 .. "\n" .. _y2-_y1+1,((_x1 + _x2)/2)*32,((_y1 + _y2)/2)*32)
			end
		else
			love.graphics.setColor(1,1,1,1)
			if buildObject[1] == "wall" then
				local t_ile = 1+buildObject[2]*16
				love.graphics.draw(tsWalls,tsWallQuads[t_ile],mtx*32,mty*32)
			elseif buildObject[1] == "floor" then
				local t_ile = 1+buildObject[2]*16
				love.graphics.draw(tsFloors,tsFloorQuads[t_ile],mtx*32,mty*32)
			else
				love.graphics.setColor(1,1,1,.5)
				love.graphics.rectangle("fill",mtx*32,mty*32,32,32)
			end
			love.graphics.setColor(0,0,0,1)
			love.graphics.print(mtx .. "\n" .. mty, mtx*32, mty*32)
		end
		love.graphics.setColor(1,1,1,1)
	end
end

function City:save(lname)
	--paused = true
	local ypairs = table.maxn(self.mapW[1])
	local zpairs = table.maxn(self.mapW)
	local filestring = "local city = ... \nlocal tm = {"
	love.filesystem.write("/levels/" .. lname .. ".lua",filestring)
	--file, err = io.open(path .. "/levels/" .. lname .. ".lua","w")
	--if file ~= nil then
	--	file:write(filestring)
	--	file:close()
	--end
	
	--save floors
	for k=1,zpairs do
		filestring = "{\n"
		for i,row in ipairs(self.mapF[k]) do
			filestring = filestring .. "{ " .. table.concat(self.mapF[k][i],", ") .. "}"
			if i < ypairs then filestring = filestring .. "," end
			filestring = filestring .. "\n"
		end
		filestring = filestring .. "}"
		if k <= zpairs then filestring = filestring .. "," end
		filestring = filestring .. "\n"
		
		file, err = io.open(path .. "/levels/" .. lname .. ".lua","a")
		if file ~= nil then
			file:write(filestring)
			file:close()
		end
	end
	
	filestring = "}\n\ncity.mapF = tm\n\n tm = {"

	file, err = io.open(path .. "/levels/" .. lname .. ".lua","a")
	if file ~= nil then
		file:write(filestring)
		file:close()
	end
	
	--save walls
	for k=1,zpairs do
		filestring = "{\n"
		for i,row in ipairs(self.mapW[k]) do
			filestring = filestring .. "{ " .. table.concat(self.mapW[k][i],", ") .. "}"
			if i < ypairs then filestring = filestring .. "," end
			filestring = filestring .. "\n"
		end
		filestring = filestring .. "}"
		if k < zpairs then filestring = filestring .. "," end
		filestring = filestring .. "\n"
		
		file, err = io.open(path .. "/levels/" .. lname .. ".lua","a")
		if file ~= nil then
			file:write(filestring)
			file:close()
		end
	end
	
	filestring = "\n}\ncity.mapW = tm\n\n"
	
	file, err = io.open(path .. "/levels/" .. lname .. ".lua","a")
	if file ~= nil then
		file:write(filestring)
		file:close()
	end
	
	--save stairs
	if type(self.mapS) == "table" then
		filestring = "tm = {\n"
		for i,v in ipairs(self.mapS) do
			filestring = filestring .. "{ " .. table.concat(v,", ") .. "}"
			if i < table.maxn(self.mapS) then filestring = filestring .. "," end
			filestring = filestring .. "\n"
		end
	
		filestring = filestring .. "}\ncity.mapS = tm\n\n"
	else
		filestring = "city.mapS = {}\n\n"
	end
	file, err = io.open(path .. "/levels/" .. lname .. ".lua","a")
	if file ~= nil then
		file:write(filestring)
		file:close()
	end
	
	filestring = ""
	
	--save characters
	for i,j in ipairs(cTable) do
		if scene == "build" then
			filestring = filestring .. "table.insert(cTable,Character({" .. j.homeX*32+j.oX/2 .. "," .. j.homeY*32+j.oY/2 .. "," .. j.homeZ .. "},{" .. j.homeX .. "," .. j.homeY .. "," .. j.homeZ .. "},\"" .. j.name .. "\"))\n"
		elseif scene == "play" then
			filestring = filestring .. "table.insert(cTable,Character({" .. j.x .. "," .. j.y .. "," .. j.z .. "},{" .. j.homeX .. "," .. j.homeY .. "," .. j.homeZ .. "},\"" .. j.name .. "\"))\n"
		end
	end
	
	--save position and time
	if scene == "build" then
		filestring = filestring .. "cam.x = 1\ncam.y = 1\ncam.z = " .. groundLevel
		filestring = filestring .. "\nclockTime = {6,55}\nsunColor = {1,1,1}\ninitializeColors()\n"
	elseif scene == "play" then
		filestring = filestring .. "cam.x = " .. cam.x .. "\ncam.y = " .. cam.y .. "\ncam.z = " .. cam.z
		filestring = filestring .. "\nclockTime = {" .. clockTime[1] .. "," .. clockTime[2] ..  "}\nsunColor = {1,1,1} initializeColors()\n"
	end
	filestring = filestring .. "\n" .. "groundLevel = " .. groundLevel

	file, err = io.open(path .. "/levels/" .. lname .. ".lua","a")
	if file ~= nil then
		file:write(filestring)
		file:close()
	end
	
	--hitching = 2
end