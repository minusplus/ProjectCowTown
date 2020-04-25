require "core.math"
require "love.timer"
if love.filesystem.getInfo("/settings.lua") ~= nil then
	love.filesystem.load("/settings.lua")(self)
end

thread_channel = love.thread.getChannel("threads")
channel = thread_channel:demand()

values = channel:demand()
mapW = values[7]
mapF = values[8]
mapS = values[9]
ch = love.thread.getChannel("QA")
qbc = 0
qbt = love.timer.getTime()
t_queue = {}
dist = 0

function runPath(startX,startY,startZ,endX,endY,endZ)
	local open_list = {}
	local closed_list = {}
	local queue = {{endX,endY,endZ,0}}
	local checked = {}
	local crumbs = {}
	local ret_x = {}
	local ret_y = {}
	local ret_z = {}

	table.insert(closed_list,{endX,endY,endZ})
		
	local done = false
	
	while queue[1] ~= nil do -- as long as something's in the queue, keep going
		qbc = qbc + 1
		table.sort(queue,costSort)
		if queue[1][1] == startX and queue[1][2] == startY and queue[1][3] == startZ then
			local _count = 0
			local r_x = {queue[1][1]}
			local r_y = {queue[1][2]}
			local r_z = {queue[1][3]}
			while queue[1][1] ~= endX or queue[1][2] ~= endY or queue[1][3] ~= endZ do
				_count = _count + 1
				queue[1] = crumbs[queue[1]]
				table.insert(ret_x,queue[1][1])
				table.insert(ret_y,queue[1][2])
				table.insert(ret_z,queue[1][3])
			end
			if _count == 0 then
				table.insert(ret_x,r_x[1])
				table.insert(ret_y,r_y[1])
				table.insert(ret_z,r_z[1])
			end
			if debugMessages["path"] ~= "off" then
				local timed = love.timer.getTime()-qbt
				debugString = os.date("%y-%m-%d %X") .. ": " .. endX .. ", " .. endY .. ", " ..  endZ .. ", " .. " < " .. startX .. ", " .. startY .. ", " .. startZ ..
							  " || distance: " .. math.ceil(distanceBetweenPoints3D(endX,endY,endZ,startX,startY,startZ)) .. " || loops: " .. qbc .. " || time: " .. string.format("%.2f ms",timed*1000) ..
							  " || tpl: " .. string.format("%.2f ms",timed*1000/qbc)
				if debugMessages["path"] == "log" or debugMessages["path"] == "both" then
					file, err = io.open(path .. "/debug.txt","a")
					if file ~= nil then
						file:write(debugString .. "\n")
						file:close()
					end
				end
				if debugMessages["path"] == "both" then
					ch:push(debugString)
				end
			end
			
			return ret_x,ret_y,ret_z
		end
		if tableContainsCoordinatesH(checked,queue[1]) == false then -- make sure this coordinate hasn't already been checked
			table.insert(checked,queue[1]) -- mark that this coordinate has been checked
			for i=-1,1 do
				for j=-1,1 do
					if i ~= 0 or j ~= 0 then
						t_queue = {queue[1][1]+i,queue[1][2]+j,queue[1][3],queue[1][4]+1}
						if t_queue[1] < 1 then t_queue[1] = -1 elseif t_queue[1] > table.maxn(mapW[1][1]) then t_queue[1] = -1 end
						if t_queue[2] < 1 then t_queue[2] = -1 elseif t_queue[2] > table.maxn(mapW[1]) then t_queue[2] = -1 end
						dist = distanceBetweenPoints3D(t_queue[1],t_queue[2],t_queue[3],startX,startY,startZ)
						if t_queue[1] ~= -1 and t_queue[2] ~= -1 then
							if i ~= 0 and j ~= 0 then -- add cost to off-cardinal directions
								t_queue[4] = t_queue[4] + 8
							else -- add 1 cost to cardinal directions
								t_queue[4] = t_queue[4] + 1
							end
							if mapF[t_queue[3]][t_queue[2]][t_queue[1]] == -1 then --add cost to empty floors
								if dist > 50 then
									t_queue[4] = t_queue[4] + 1
								else
									t_queue[4] = t_queue[4] + 2
								end
							end
							t_queue[4] = t_queue[4] + dist --add distance heuristic

							if tableContainsCoordinates(closed_list,t_queue) == false and tableContainsCoordinatesH(checked,t_queue) == false then -- as long as it's not already listed as closed
								if mapW[t_queue[3]][t_queue[2]][t_queue[1]] == -1 then
									crumbs[t_queue] = queue[1]
									local v = tableContainsCoordinates(open_list,t_queue)
									if  v == false then
										table.insert(open_list,t_queue)
										table.insert(queue,t_queue)
									elseif open_list[v][4] > t_queue[4] then
										table.insert(queue,t_queue)
									end
								else
									table.insert(closed_list,t_queue)
								end
							end
						end
					end
				end
			end
			local v = tableContainsCoordinates(mapS,queue[1])
			if v then
				if mapS[v][4] == 1 then -- look downstairs
					t_queue = {queue[1][1],queue[1][2],queue[1][3]-1,queue[1][4]}
					if tableContainsCoordinates(closed_list,t_queue) == false then -- as long as it's not already listed
						crumbs[t_queue] = queue[1]
						table.insert(open_list,t_queue)
						table.insert(queue,t_queue)
					end
				elseif mapS[v][4] == 2 then -- look upstairs
					t_queue = {queue[1][1],queue[1][2],queue[1][3]+1,queue[1][4]}
					if tableContainsCoordinates(closed_list,t_queue) == false then -- as long as it's not already listed
						crumbs[t_queue] = queue[1]
						table.insert(open_list,t_queue)
						table.insert(queue,t_queue)				
					end
				end
			end
		end
		table.remove(queue,1)
	end
	local ret_x = {endX,endX}
	local ret_y = {endY,endY}
	local ret_z = {endZ,endZ}
	return ret_x,ret_y,ret_z
end

function costSort(a,b)
	return a[4] < b[4]
end

local r_x, r_y, r_z = runPath(values[1],values[2],values[3],values[4],values[5],values[6])
channel:push({r_x,r_y,r_z})