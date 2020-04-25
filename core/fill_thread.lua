require "core.math"

thread_channel = love.thread.getChannel("threads")
channel = thread_channel:demand()

values = channel:demand()
mapW = values[4]
mapF = values[5]
mapS = values[6]

function runPath(startX,startY,startZ)
	local open_list = {{startX,startY,startZ}}
	local closed_list = {}
	local queue = {{startX,startY,startZ}}
	local checked = {}
	local crumbs = {}
	local ret_x = {}
	local ret_y = {}
	local ret_z = {}
	local val = {mapW[startZ][startY][startX],mapF[startZ][startY][startX]}
	ch = love.thread.getChannel("QA")

	table.insert(closed_list,{startX,startY,startZ})
		
	local done = false
	
	while queue[1] ~= nil do -- as long as something's in the queue, keep going
		if tableContainsCoordinates(checked,queue[1]) == false then -- make sure this coordinate hasn't already been checked
			table.insert(checked,queue[1]) -- mark that this coordinate has been checked
			local t_queue = {}
			for i=-1,1 do
				for j=-1,1 do
					--if i ~= 0 or j ~= 0 then
						if i == 0 or j == 0 then
							t_queue = {queue[1][1]+j,queue[1][2]+i,queue[1][3]}

							if t_queue[1] < 1 then t_queue[1] = 1 elseif t_queue[1] > table.maxn(mapW[1][1]) then t_queue[1] = table.maxn(mapW[1][1]) end
							if t_queue[2] < 1 then t_queue[2] = 1 elseif t_queue[2] > table.maxn(mapW[1]) then t_queue[2] = table.maxn(mapW[1]) end

							if tableContainsCoordinates(closed_list,t_queue) == false then -- as long as it's not already listed as closed
								if  mapW[t_queue[3]][t_queue[2]][t_queue[1]] == val[1] and mapF[t_queue[3]][t_queue[2]][t_queue[1]] == val[2] then
									local v = tableContainsCoordinates(open_list,t_queue)
									if  v == false then
										table.insert(open_list,t_queue)
										table.insert(queue,t_queue)
									end
								else
									table.insert(closed_list,t_queue)
								end
							end
						end
					--end
				end
			end
		end
		table.remove(queue,1)
	end
	for i,v in ipairs(open_list) do
		table.insert(ret_x,v[1])
		table.insert(ret_y,v[2])
		--ch:push(mapW[v[3]][v[2]][v[1]] .. ", " .. mapF[v[3]][v[2]][v[1]] .. ": " .. v[1] .. ", " .. v[2])
	end
	return ret_x,ret_y
end

local r_x, r_y = runPath(values[1],values[2],values[3])

channel:push({r_x,r_y})