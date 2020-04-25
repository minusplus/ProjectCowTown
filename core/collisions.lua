function isColliding(a,b)
	-- create bounding boxes
	local a_left = a.x - a.width/2
	local a_right = a.x + a.width/2
	local a_top = a.y - a.height
	local a_bottom = a.y
	
	local b_left = b.x - b.width/2
	local b_right = b.x + b.width/2
	local b_top = b.y - b.height
	local b_bottom = b.y
	
	-- check if boxes overlap
	if a_right > b_left and
	  a_left < b_right and
	  a_bottom > b_top and
	  a_top < b_bottom then
		return true
	else
		return false
	end
end

function onCam(a)
	-- create camera boundary
	local a_left = a.x - a.iWidth/2
	local a_right = a.x + a.iWidth/2
	local a_top = a.y - a.iHeight
	local a_bottom = a.y
	
	local b_left = cam.x
	local b_right = cam.x + cam.width
	local b_top = cam.y
	local b_bottom = cam.y + cam.height
	
	-- check if boxes overlap
	if a_right > b_left and
	  a_left < b_right and
	  a_bottom > b_top and
	  a_top < b_bottom then
		return true
	else
		return false
	end
end

function pointCollision(x,y,object)
	-- create bounding box
	local a_left = object.x - object.width/2
	local a_right = object.x + object.width/2
	local a_top = object.y - object.height
	local a_bottom = object.y
	
	-- check if point is within box
	if a_right > x and
	  a_left < x and
	  a_bottom > y and
	  a_top < y then
		return true
	else
		return false
	end
end

function charClick(object)
	-- create bounding box
	local a_left = object.x - object.iWidth/2
	local a_right = object.x + object.iWidth/2
	local a_top = object.y - object.iHeight
	local a_bottom = object.y
	
	-- check if point is within box
	if a_right > mx and
	  a_left < mx and
	  a_bottom > my and
	  a_top < my then
		return true
	else
		return false
	end
end

function buttonHover(object)
	local mouse_x, mouse_y = love.mouse.getPosition()
	-- create bounding box
	local a_left = object.x
	local a_right = object.x + object.width
	local a_top = object.y
	local a_bottom = object.y + object.height
	
	-- check if point is within box
	if a_right > mouse_x and
	  a_left < mouse_x and
	  a_bottom > mouse_y and
	  a_top < mouse_y then
		return true
	else
		return false
	end
end