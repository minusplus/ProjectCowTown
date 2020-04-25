Button = Object:extend()

function Button:new(x,y,text)
	self.x = x
	self.y = y
	self.text = text
	self.hover = false
	self.tClick = false
	self.width = font[5]:getWidth(self.text)+4
	self.height = font[5]:getHeight(self.text)+4
end

function Button:Step()
	self.hover = buttonHover(self)
	
	if mousePressed and mouseButton == 1 and self.hover then
			self.tClick = true
		end
	if mouseReleased and mouseButton == 1 then
		if self.tClick then
			self.tClick = false
			if self.hover then love.event.quit() end
		end
	end
end

function Button:draw()
	if self.tClick then
		love.graphics.setColor(.1,.1,.1,1)
	elseif self.hover then
		love.graphics.setColor(.5,.5,.5,1)
	else
		love.graphics.setColor(.3,.3,.3,1)
	end
	love.graphics.rectangle("fill",self.x,self.y,self.width,self.height)
	love.graphics.setColor(1,1,1,1)
	love.graphics.setFont(font[5])
	love.graphics.print(self.text,self.x+2,self.y+2)
	love.graphics.setFont(font[1])
end