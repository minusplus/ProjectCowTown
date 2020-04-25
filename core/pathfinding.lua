function metaPath(startX,startY,startZ,endX,endY,endZ)
	local ret = {}
	queue={endX,endY,endZ}
	local b_queue = {startX,startY,startZ}
	local c_queue = {}
	if startZ ~= endZ and distanceBetweenPoints(startX,startY,endX,endY) > 7 then
		queue={startX,startY,startZ}
		if groundLevel ~= queue[3] then
			while groundLevel > queue[3] do
				table.sort(currentCity.mapS,stairSort)
				local _i = 1
				while currentCity.mapS[_i][3] ~= queue[3]+1 or currentCity.mapS[_i][4] ~= 1 do
					_i = _i + 1
				end
				queue = {currentCity.mapS[_i][1],currentCity.mapS[_i][2],currentCity.mapS[_i][3]}
				table.insert(ret,queue)
			end
			while groundLevel < queue[3] do
				table.sort(currentCity.mapS,stairSort)
				local _i = 1
				while currentCity.mapS[_i][3] ~= queue[3]-1 or currentCity.mapS[_i][4] ~= 2 do
					_i = _i + 1
				end
				queue = {currentCity.mapS[_i][1],currentCity.mapS[_i][2],currentCity.mapS[_i][3]}
				table.insert(ret,queue)
			end
		end
		b_queue = queue
		queue = {endX,endY,endZ}
		if groundLevel ~= queue[3] then
			while groundLevel > queue[3] do
				table.sort(currentCity.mapS,stairSort)
				local _i = 1
				while currentCity.mapS[_i][3] ~= queue[3]+1 or currentCity.mapS[_i][4] ~= 1 do
					if table.maxn(currentCity.mapS) > _i then _i = _i + 1 else break end
				end
				queue = {currentCity.mapS[_i][1],currentCity.mapS[_i][2],currentCity.mapS[_i][3]}
				table.insert(c_queue,1,queue)
			end
			while groundLevel < queue[3] do
				table.sort(currentCity.mapS,stairSort)
				local _i = 1
				while currentCity.mapS[_i][3] ~= queue[3]-1 or currentCity.mapS[_i][4] ~= 2 do
					if table.maxn(currentCity.mapS) > _i then _i = _i + 1 else break end
				end
				queue = {currentCity.mapS[_i][1],currentCity.mapS[_i][2],currentCity.mapS[_i][3]}
				table.insert(c_queue,1,queue)
			end
		end
	end
	local dpp = distanceBetweenPoints(b_queue[1],b_queue[2],queue[1],queue[2])
	while dpp > 30 do
		local d_queue = b_queue
		b_queue = {math.ceil((b_queue[1]+queue[1])/2),math.ceil((b_queue[2]+queue[2])/2),groundLevel}
		while distanceBetweenPoints(b_queue[1],b_queue[2],d_queue[1],d_queue[2]) > 25 do
			b_queue = {math.ceil((b_queue[1]+d_queue[1])/2),math.ceil((b_queue[2]+d_queue[2])/2),groundLevel}
		end
		while currentCity.mapW[b_queue[3]][b_queue[2]][b_queue[1]] ~= -1 do
			b_queue[1] = round(math.random(math.max(b_queue[1]-2,1),math.min(b_queue[1]+2,table.maxn(currentCity.mapW[1][1]))))
			b_queue[2] = round(math.random(math.max(b_queue[2]-2,1),math.min(b_queue[2]+2,table.maxn(currentCity.mapW[1]))))
		end
		dpp = distanceBetweenPoints(b_queue[1],b_queue[2],queue[1],queue[2])
		table.insert(ret,b_queue)	
	end
	for i=1,table.maxn(c_queue) do
		if type(c_queue[i]) == "table" then table.insert(ret,c_queue[i]) end
	end
	table.insert(ret,{endX,endY,endZ})
	return ret
end

function findPath(startX,startY,startZ,endX,endY,endZ)
	local thread = love.thread.newThread("core/pathfinding_thread.lua")
	threads = threads + 1
	local thread_channel = love.thread.getChannel("threads")
	local channel = love.thread.newChannel()
	thread:start()
	thread_channel:push(channel)
	channel:push({startX,startY,startZ,endX,endY,endZ,currentCity.mapW,currentCity.mapF,currentCity.mapS})
	return channel
end

function returnPath(channel)
	local ret = channel:pop()
	if ret then
		threads = math.max(threads - 1, 1)
		channel:release()
		return ret[1],ret[2],ret[3]
	end
end

function moveTowardsPoint(dt, x, y, z, obj)
	if currentCity.mapW[z][math.max((y-obj.oY/2)/32,1)][math.max((x-obj.oX/2)/32,1)] ~= -1 then
		return 0
	end
	angle = math.atan2(y - obj.y, x - obj.x)
	cos = math.cos(angle)
	sin = math.sin(angle)
	if obj.z ~= z then
		obj.z = z
	end
	if distanceToPoint(x, y, obj) <= obj.spd * dt * gameSpeed then
		obj.x = x
		obj.y = y
		return 1
	else
		obj.x = obj.x + obj.spd * cos * dt * gameSpeed
		obj.y = obj.y + obj.spd * sin * dt * gameSpeed
		return -1
	end
end

function bucketFill(startX,startY,startZ)
	local thread = love.thread.newThread("core/fill_thread.lua")
	threads = threads + 1
	local thread_channel = love.thread.getChannel("threads")
	local channel = love.thread.newChannel()
	thread:start()
	thread_channel:push(channel)
	channel:push({startX,startY,startZ,currentCity.mapW,currentCity.mapF,currentCity.mapS})
	return channel
end

function returnFill(channel)
	local ret = channel:pop()
	if ret then
		threads = math.max(threads - 1, 1)
		channel:release()
		return ret[1],ret[2]
	end
end

function stairSort(a,b)
	return distanceBetweenPoints(a[1],a[2],queue[1],queue[2]) < distanceBetweenPoints(b[1],b[2],queue[1],queue[2])
end