-- load character
chB = {love.graphics.newImage("gfx/characters/b1.png")}
cAnimFrames = {}
love.graphics.setBackgroundColor(.2,.2,.2)
sunColorTable = {}

shLighting = love.graphics.newShader[[
										extern float redC;
										extern float greenC;
										extern float blueC;
										vec4 effect( vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords ){
											vec4 pixel = Texel(texture, texture_coords );
											pixel.r = pixel.r + redC/2;
											pixel.g = pixel.g + greenC/2;
											pixel.b = pixel.b + blueC/2;
											return pixel;
										}
									]]
shLighting:send("redC",0)
shLighting:send("greenC",0)
shLighting:send("blueC",0)

for i=1,8 do
	table.insert(cAnimFrames, love.graphics.newQuad((i-1)*64,0,64,64,512,256))
end
for i=9,16 do
	table.insert(cAnimFrames, love.graphics.newQuad((i-9)*64,65,64,64,512,256))
end
for i=17,24 do
	table.insert(cAnimFrames, love.graphics.newQuad((i-17)*64,129,64,64,512,256))
end
for i=25,32 do
	table.insert(cAnimFrames, love.graphics.newQuad((i-25)*64,193,64,64,512,256))
end

--load tilesets
tsWalls = love.graphics.newImage("gfx/tilesets/walls.png")
tsWallQuads = {}
local i_width = tsWalls:getWidth()
local i_height = tsWalls:getHeight()
for h=0,i_height/128-1 do
	for i=0,i_width/128-1 do
		for j=0,3 do
			for k=0,3 do
				table.insert(tsWallQuads,love.graphics.newQuad(128*i + k*32, 128*h + j*32, 32, 32, i_width, i_height))
			end
		end
	end
end

tsFloors = love.graphics.newImage("gfx/tilesets/floors.png")
tsFloorQuads = {}
local i_width = tsFloors:getWidth()
local i_height = tsFloors:getHeight()

for h=0,i_height/128-1 do
	for i=0,i_width/128-1 do
		for j=0,3 do
			for k=0,3 do
				table.insert(tsFloorQuads,love.graphics.newQuad(128*i + k*32, 128*h + j*32, 32, 32, i_width, i_height))
			end
		end
	end
end


tsStairs = love.graphics.newImage("gfx/tilesets/stairs.png")
tsStairQuads = {}
table.insert(tsStairQuads,love.graphics.newQuad(0,0,32,32,64,32))
table.insert(tsStairQuads,love.graphics.newQuad(32,0,32,32,64,32))

function autoTile(tile,s_tiles) --does auto tiling
	-- standalone piece
	local empty=true
	for i=1,4 do
		if s_tiles[i] == tile then empty=false end
	end
	if empty then
		return 1
	end
	
	-- surrounded piece
	empty=false
	for i=1,4 do
		if s_tiles[i] ~= tile then empty=true end
	end
	if empty == false then -- if the tile is neither fully isolated nor fully surrounded
		return 11
	end
		
	-- horizontal left
	if s_tiles[1] ~= tile and s_tiles[2] ~= tile and s_tiles[3] == tile
	and s_tiles[4] ~= tile then
		return 2
		
	-- horizontal middle
	elseif s_tiles[1] ~= tile and s_tiles[2] == tile and s_tiles[3] == tile
	and s_tiles[4] ~= tile then
		return 3
		
	-- horizontal right
	elseif s_tiles[1] ~= tile and s_tiles[2] == tile and s_tiles[3] ~= tile
	and s_tiles[4] ~= tile then
		return 4
		
	-- vertical top
	elseif s_tiles[1] ~= tile and s_tiles[2] ~= tile and s_tiles[3] ~= tile
	and s_tiles[4] == tile then
		return 5
		
	-- vertical middle
	elseif s_tiles[1] == tile and s_tiles[2] ~= tile and s_tiles[3] ~= tile
	and s_tiles[4] == tile then
		return 9
		
	-- vertical bottom
	elseif s_tiles[1] == tile and s_tiles[2] ~= tile and s_tiles[3] ~= tile
	and s_tiles[4] ~= tile then
		return 13
		
	-- top-left
	elseif s_tiles[1] ~= tile and s_tiles[2] ~= tile and s_tiles[3] == tile
	and s_tiles[4] == tile then
		return 6
		
	-- top-middle
	elseif s_tiles[1] ~= tile and s_tiles[2] == tile and s_tiles[3] == tile
	and s_tiles[4] == tile then
		return 7
		
	-- top-right
	elseif s_tiles[1] ~= tile and s_tiles[2] == tile and s_tiles[3] ~= tile
	and s_tiles[4] == tile then
		return 8
		
	-- left
	elseif s_tiles[1] == tile and s_tiles[2] ~= tile and s_tiles[3] == tile
	and s_tiles[4] == tile then
		return 10
		
	-- right
	elseif s_tiles[1] == tile and s_tiles[2] == tile and s_tiles[3] ~= tile
	and s_tiles[4] == tile then
		return 12
		
	-- bottom-left
	elseif s_tiles[1] == tile and s_tiles[2] ~= tile and s_tiles[3] == tile
	and s_tiles[4] ~= tile then
		return 14
		
	-- bottom-middle
	elseif s_tiles[1] == tile and s_tiles[2] == tile and s_tiles[3] == tile
	and s_tiles[4] ~= tile then
		return 15
		
	-- bottom-right
	elseif s_tiles[1] == tile and s_tiles[2] == tile and s_tiles[3] ~= tile
	and s_tiles[4] ~= tile then
		return 16
		
	else return 11
	end
end

function initializeColors()
	sunColorTable = {{-.5,-.5,-.5},{-.5,-.5,-.3},{-.5,-.4,-.3},{-.4,-.4,-.1},{-.3,-.4,-.1},{-.2,-.4,-.1},{-.1,-.3,0},{-.1,-.2,0},
					{-.1,-.1,0},{0,-.1,0},{0,0,0},{.1,0,0},{.1,0,.1},{.2,.1,.1},{.2,.1,.2},{.2,0,.2},
					{.3,0,.1},{.3,0,0},{.2,-.1,-.1},{.1,-.2,-.2},{-.1,-.3,-.2},{-.2,-.4,-.3},{-.3,-.5,-.4},{-.4,-.5,-.5},}
	sunColor = sunColorTable[clockTime[1]+1]
	sunColorChange = sunColor
	shLighting:send("redC",sunColor[1])
	shLighting:send("greenC",sunColor[2])
	shLighting:send("blueC",sunColor[3])
end

function updateColors()
	if math.floor(clockTime[2]) == 0 and sunColor == sunColorChange then
		sunColorChange = sunColorTable[clockTime[1]+1]
	end
end