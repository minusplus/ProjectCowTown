Menu = Object:extend()
Toolbar = Menu:extend()

function Menu:new(x,y,options)
	self.x = x
	self.y = y
	self.options = options
	if self.options[1] == "table" then self.twoD = true else self.twoD = false end
end

function clearButtons()
	while buttons[1] ~= nil do
		table.remove(buttons,1)
	end
end