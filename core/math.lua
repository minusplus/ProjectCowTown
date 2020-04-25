function round(num)
	return num + 0.5 - (num + 0.5) % 1
end

function clamp(num,mini,maxi)
	if num < mini then num = mini
	elseif num > maxi then num = maxi end
	return num
end

function tableContainsCoordinates(tab,val) --looks for a set of {x,y,z} coordinates in a table and returns the location
	if type(tab) == "table" then
		for i, v in ipairs(tab) do
			if v[1] == val[1] and v[2] == val[2] and v[3] == val[3] then return i end
		end
	end
	return false
end

function tableContainsCoordinatesH(tab,val) --looks for a set of {x,y,z,cost} coordinates in a table and returns the location
	if type(tab) == "table" then
		for i, v in ipairs(tab) do
			if v[1] == val[1] and v[2] == val[2] and v[3] == val[3] and v[4] == val[4] then return i end
		end
	end
	return false
end

function distanceToPoint(x, y, obj)
	local h_distance = math.abs(x - obj.x)
	local v_distance = math.abs(y - obj.y)
	
	local a = h_distance ^2
	local b = v_distance ^2
	
	local c = a + b
	
	return math.sqrt(c)
end

function distanceBetweenPoints(x1, y1, x2, y2)
	local h_distance = math.abs(x1 - x2)
	local v_distance = math.abs(y1 - y2)
	
	--local a = h_distance ^2
	--local b = v_distance ^2
	
	--local c = a + b
	
	return (h_distance + v_distance) --+ (8) * math.min(h_distance,v_distance)
end

function distanceBetweenPoints3D(x1, y1, z1, x2, y2, z2)
	local h_distance = math.abs(x1 - x2)
	local v_distance = math.abs(y1 - y2)
	local d_distance = math.abs(z1 - z2)
	
	--local a = h_distance ^2
	--local b = v_distance ^2
	--local d = d_distance
	
	--local c = a + b
	
	return (h_distance + v_distance + d_distance*3) --+ (8) * math.min(h_distance,v_distance) + d_distance
end