cam = {}
cam.x = 0
cam.y = 0
cam.z=3
cam.px = 0
cam.py = 0
cam.scaleX = 1
cam.scaleY = 1
cam.ps = 1
cam.rotation = 0
cam.spd = 512
cam.following = nil
cam.width=love.graphics.getWidth()*cam.scaleX
cam.height=love.graphics.getHeight()*cam.scaleY

function cam:set()
	love.graphics.push()
	love.graphics.rotate(-self.rotation)
	love.graphics.scale(1 / self.scaleX, 1 / self.scaleY)
	love.graphics.translate(-self.x, -self.y)
end

function cam:unset()
	love.graphics.pop()
end

function cam:move(dx, dy)
	self.x = self.x + (dx or 0)
	self.y = self.y + (dy or 0)
end

function cam:rotate(dr)
	self.rotation = self.rotation + dr
end

function cam:scale(sx, sy)
	sx = sx or 1
	self.scaleX = self.scaleX * sx
	self.scaleY = self.scaleY * (sy or sx)
end

function cam:setPosition(x, y)
	self.x = x or self.x
	self.y = y or self.y
end

function cam:setScale(sx, sy)
  self.scaleX = sx or self.scaleX
  self.scaleY = sy or self.scaleY
end

function cam:Step(dt)
	self.width=love.graphics.getWidth()*cam.scaleX
	self.height=love.graphics.getHeight()*cam.scaleY
	-- follow if following
	if self.following ~= nil then
		cam:setPosition(self.following.x - self.width/2,self.following.y - self.height/2)
		if self.z ~= self.following.z then
			self.z = self.following.z
			currentCity:tsBatchUpdateAll()
		end
	end
end

function cam:endStep()
	if mouseHeld then
		if mx ~= gx or my ~= gy then
			local bx = mx - gx
			local by = my - gy
			cam:move(-bx, -by)
			--gx = mx
			--gy = my
			cam.following = nil
		end
	end
	local xpairs = table.maxn(currentCity.mapW[1][1]) + 1
	local ypairs = table.maxn(currentCity.mapW[1]) + 1
	if self.x > xpairs*32-self.width then self.x = xpairs*32-self.width end
	if self.x < 32 then self.x = 32 end
	if self.y > ypairs*32-self.height then self.y = ypairs*32-self.height end
	if self.y < 32 then self.y = 32 end
	
	--if self.px ~= self.x or self.py ~= self.y or self.ps ~= self.scaleX then tsBatchUpdate() end
	self.px = self.x
	self.py = self.y
	self.ps = self.scaleX
end