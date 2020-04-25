Character = Object:extend()

function Character:new(coord,homecoord,name)
	self.name = name or "Willy"
	self.oX=32 --x and y origin values
	self.oY=64
	self.x=coord[1] --current x and y values
	self.y=coord[2]
	self.z=coord[3]
	self.homeX=homecoord[1]
	self.homeY=homecoord[2]
	self.homeZ=homecoord[3]
	self.px=self.x --previous x and y values
	self.py=self.y
	self.nx={} --x and y pathfinding nodes
	self.ny={}
	self.nz={}
	self.tx=math.ceil((self.x-self.oX/2)/32)  --x and y target
	self.ty=math.ceil((self.y-self.oY/2)/32)
	self.tz=self.z
	self.chB=chB[1]
	self.spd=96
	self.width=32
	self.height=32
	self.iWidth = 64
	self.iHeight = 64
	self.iFrame=1
	self.face=0
	self.qa=false
	self.say = {}
	self.state = {"Nothing",0}
	self:goals()
	self.pChannel = nil
	self.pNodes = {}
	self.tClick = false
end

function Character:goals() --behavior things
	if type(self.nx) == "table" and self.nx[1] == nil and self.tx == math.ceil((self.x-self.oX/2)/32) and self.ty == math.ceil((self.y-self.oY/2)/32) and self.tz == self.z then
		--ch:push()
		if self.state[2] <= 0 then
			self.state = {"Nothing",1}
		end
		self.nx = {}
		self.ny = {}
		self.nz = {}
		if self.state[1] == "Nothing" then
			local rand = math.random(0,100)
			if rand < 15 then self.state = {"Relaxing",5}
			elseif rand < 95 then self.state = {"Wandering",1}
			else
				if math.ceil((self.x-self.oX/2)/32) > 100 then
					self.state = {"Going home",1}
				else
					self.state = {"Shopping",1}
				end
			end
		elseif self.state[1] == "Wandering" then
			self.tx = round(math.random(math.max(math.ceil((self.x-self.oX/2)/32)-7,1),math.min(math.ceil((self.x-self.oX/2)/32)+7,table.maxn(currentCity.mapW[1][1]))))
			self.ty = round(math.random(math.max(math.ceil((self.y-self.oY/2)/32)-7,1),math.min(math.ceil((self.y-self.oY/2)/32)+7,table.maxn(currentCity.mapW[1]))))
			self.tz = round(math.random(math.max(self.z-1,1),math.min(self.z+1,table.maxn(currentCity.mapW))))
			while currentCity.mapW[self.tz][self.ty][self.tx] ~= -1 or currentCity.mapF[self.tz][self.ty][self.tx] == -1 do
				self.tx = round(math.random(math.max(math.ceil((self.x-self.oX/2)/32)-7,1),math.min(math.ceil((self.x-self.oX/2)/32)+7,table.maxn(currentCity.mapW[1][1]))))
				self.ty = round(math.random(math.max(math.ceil((self.y-self.oY/2)/32)-7,1),math.min(math.ceil((self.y-self.oY/2)/32)+7,table.maxn(currentCity.mapW[1]))))
				self.tz = round(math.random(math.max(self.z-1,1),math.min(self.z+1,table.maxn(currentCity.mapW))))
			end
		elseif self.state[1] == "Shopping" then
			self.tx = round(math.random(100,table.maxn(currentCity.mapW[1][1])-2))
			self.ty = round(math.random(2,table.maxn(currentCity.mapW[1])-2))
			self.tz = round(math.random(math.max(self.z-1,1),math.min(self.z+1,table.maxn(currentCity.mapW))))
			while currentCity.mapW[self.tz][self.ty][self.tx] ~= -1 or currentCity.mapF[self.tz][self.ty][self.tx] == -1 do
				self.tx = round(math.random(100,table.maxn(currentCity.mapW[1][1])-2))
				self.ty = round(math.random(2,table.maxn(currentCity.mapW[1])-2))
				self.tz = round(math.random(math.max(self.z-1,1),math.min(self.z+1,table.maxn(currentCity.mapW))))
			end
		elseif self.state[1] == "Going home" then
			self.tx = self.homeX
			self.ty = self.homeY
			self.tz = self.homeZ
		--elseif self.state[1] == "Relaxing" then
		end
	end
end

function Character:beginStep(dt)
	if scene == "play" then
		for i,v in ipairs(self.say) do
			if paused == false then v[2] = v[2] - dt * gameSpeed end
			if v[2] <= 0 then table.remove(self.say,i) end
		end
		if self.pChannel ~= nil then
			self.nx,self.ny,self.nz = returnPath(self.pChannel)
			if self.nx ~= nil then
				self.pChannel = nil
			end
		else
			if type(self.nx) == "table" and self.nx[1] ~= nil then
				local _switch = -1
				if paused == false then _switch = moveTowardsPoint(dt,self.nx[1]*32+self.oX/2,self.ny[1]*32+self.oY/2,self.nz[1],self) end
				if _switch == 1 then
					table.remove(self.nx,1)
					table.remove(self.ny,1)
					table.remove(self.nz,1)
					if self.nx[1] ~= nil and table.maxn(self.pNodes) > 1 then
						if self.z == self.pNodes[2][3] and distanceBetweenPoints(math.ceil((self.x-self.oX/2)/32),math.ceil((self.y-self.oY/2)/32),self.pNodes[2][1],self.pNodes[2][2]) < 33 then
							self.nx = {}
							self.ny = {}
							self.nz = {}
							table.remove(self.pNodes,1)
						end
					end
				elseif _switch == 0 then
					if threads < maxThreads then
						self.nx = {}
						self.ny = {}
						self.nz = {}
						self.pChannel = findPath(math.ceil((self.x-self.oX/2)/32),math.ceil((self.y-self.oY/2)/32),self.z,self.pNodes[1][1],self.pNodes[1][2],self.pNodes[1][3])
					elseif maxThreadPause and paused == false then
						paused = true
						maxThreadPaused = true
					end
				end
			elseif threads < maxThreads then
				if self.tx ~= math.ceil((self.x-self.oX/2)/32) or self.ty ~= math.ceil((self.y-self.oY/2)/32) or self.tz ~= self.z then
					if self.pNodes[1] == nil then 
						self.pChannel = nil
						self.pNodes = metaPath(math.ceil((self.x-self.oX/2)/32),math.ceil((self.y-self.oY/2)/32),self.z,self.tx,self.ty,self.tz)
					else
						if self.pNodes[1][1] ~= math.ceil((self.x-self.oX/2)/32) or self.pNodes[1][2] ~= math.ceil((self.y-self.oY/2)/32) or self.pNodes[1][3] ~= self.z then
							self.pChannel = findPath(math.ceil((self.x-self.oX/2)/32),math.ceil((self.y-self.oY/2)/32),self.z,self.pNodes[1][1],self.pNodes[1][2],self.pNodes[1][3])
						else
							if table.maxn(self.pNodes) <= 1 then self.pNodes = {} else table.remove(self.pNodes,1) end
						end
					end
					if self.pNodes[1] == nil then
						
					end
				end
			elseif maxThreadPause and paused == false then
				paused = true
				maxThreadPaused = true
			end
			self:goals()
			self.state[2] = self.state[2] - dt * gameSpeed
		end
	end
end

function Character:Step(dt)
	if scene == "play" then
		if paused == false then
			if self.x ~= self.px or self.y ~= self.py then
				if math.abs(self.y-self.py)*.8 > math.abs(self.x-self.px) then
					if self.y>self.py then self.face=0 else self.face=1 end --Face down or up
				else
					if self.x>self.px then self.face=2 else self.face=3 end --Face left or right
				end
			
				self.iFrame = self.iFrame + self.spd/10*dt*gameSpeed --Animate
			
				if self.iFrame>=9+(8*self.face) or self.iFrame<1+(8*self.face) then
					self.iFrame=1+(8*self.face) -- loop within facing direction
				end	
			else
				if self.face==0 then self.iFrame=1
				elseif self.face==1 then self.iFrame=9 end
			end
		end
		
		if mousePressed and mouseButton == 1 and self.z == cam.z and charClick(self)then
			self.tClick = true
		end
		if mouseReleased and mouseButton == 1 then
			if self.tClick then
				self.tClick = false
				if charClick(self) then cam.following = self end
			end
		end
	end
end

function Character:endStep()
	if scene == "play" then
		if self.say[1] == nil then
			for i,v in ipairs(cTable) do
				if v ~= self and v.z == self.z and distanceToPoint(v.x,v.y,self) < 128 then		
					table.insert(self.say, {"Hi, " .. v.name,2})
				end
			end
		end
		self.px=self.x
		self.py=self.y
	end
end

function Character:draw()
	local _path = {}
	local _last = 0
	if showPaths then
		if type(self.nx) == "table" then
			for i,l in ipairs(self.nx) do
				_last = i
				if self.nz[i] == cam.z then
					table.insert(_path,self.oX/2+self.nx[i]*32)
					table.insert(_path,self.oY/2+self.ny[i]*32)
				end
			end
		end
		love.graphics.setColor(1,0,0,.5)
		local mp = table.maxn(_path)
		if mp >= 4 then
			love.graphics.line(_path) 
			if cam.z == self.nz[_last] then
				love.graphics.circle("fill",_path[mp-1],_path[mp],4)
			end
		end
	end
	love.graphics.setColor(1,1,1,1)
	
	if self.z == cam.z and onCam(self) then
		local nameFont = 1
		if cam.scaleX < 1 then
			nameFont = 1
		elseif cam.scaleX < 1.5 then
			nameFont = 2
		elseif cam.scaleX < 2.5 then
			nameFont = 3
		elseif cam.scaleX < 3.5 then
			nameFont = 4
		else
			nameFont = 5
		end
		love.graphics.setFont(font[nameFont])
		if scene == "play" then love.graphics.setShader(shLighting) end
		love.graphics.draw(self.chB, cAnimFrames[math.floor(self.iFrame)], self.x, self.y, 0, 1, 1, self.oX, self.oY)
		love.graphics.setShader()
		if cam.following == self then
			love.graphics.setColor(.1,.5,.1,1)
		elseif self.tClick then
			love.graphics.setColor(.7,.1,.1,1)
		end
		local str = self.name
		local str_width = 160
		local str_height = font[nameFont]:getHeight("D")
		--str = str .. "\n" .. math.floor(self.x/32) .. ", " .. math.floor(self.y/32) .. ", " .. self.z .. "\n" .. self.tx .. ", " .. self.ty .. ", " .. self.tz
		--if type(self.nx) == "table" and self.nx[1] ~= nil then
		--	str = str .. "\n\n" .. self.nx[1] .. ", " .. self.ny[1] .. ", " .. self.nz[1]
		--end
		--if type(self.pNodes) == "table" and type(self.pNodes[1]) == "table" then str = str .. "\n\n" .. self.pNodes[1][1] .. "," .. self.pNodes[1][2] .. "," .. self.pNodes[1][3] end
		str_width = font[nameFont]:getWidth(str)
		love.graphics.printf(str,self.x-str_width/2,self.y+2,str_width,"center")
		love.graphics.setColor(1,1,1,1)
		if self.say[1] ~= nil then
			str = ""
			local _count = 0
			for i,v in ipairs(self.say) do
				_count = _count + 1
				str = str .. v[1] .. "\n"
			end
			str_width = font[nameFont]:getWidth(str)
			love.graphics.rectangle("fill",self.x-str_width/2-4,self.y-self.oY-26*_count-2,str_width+8,str_height+8,4,4)
			love.graphics.setColor(0,0,0,1)
			love.graphics.rectangle("line",self.x-str_width/2-4,self.y-self.oY-26*_count-2,str_width+8,str_height+8,4,4)
			love.graphics.printf(str,self.x-str_width/2,self.y-self.oY-26*_count,str_width,"center")
			love.graphics.setColor(1,1,1,1)
		end
		if thinkingStatus then
			if self.pChannel ~= nil then
				str_width = font[nameFont]:getWidth("Thinking")
				love.graphics.printf("Thinking",self.x-str_width/2,self.y+2+str_height,str_width,"center")
			elseif type(self.nx) == "table" and self.nx[1] == nil then
				if self.tx ~= math.ceil((self.x-self.oX/2)/32) or self.ty ~= math.ceil((self.y-self.oY/2)/32) or self.tz ~= self.z then
					if thinkingStatus then
						str_width = font[nameFont]:getWidth("Idling")
						love.graphics.printf("Idling",self.x-str_width/2,self.y+2+str_height,str_width,"center")
					end
				end
			end
		else
			str_width = font[nameFont]:getWidth(self.state[1])
			love.graphics.printf(self.state[1],self.x-str_width/2,self.y+2+str_height,str_width,"center")
		end
		love.graphics.setFont(font[1])
	end
end

function sortCharacters(a,b)
	return a.y < b.y
end