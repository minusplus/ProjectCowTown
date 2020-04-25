-- settings
function defaultSettings()
	local str = "maxThreads = 4\
maxThreadPause = true\
keyboardControls = {left = \"left\", right = \"right\", up = \"up\", down = \"down\", zoomin = \"=\", zoomout = \"-\", layerup = \"[\", layerdown = \"]\", togglefullscreen = \"f4\",\
speed1x = \"1\", speed2x = \"2\", speed3x = \"3\", speed4x = \"4\", pause = \"space\", buildcharacter = \"c\", buildwall = \"w\", buildupstairs = \"u\",builddownstairs = \"d\", buildfloor = \"f\",\
showPaths = \"p\"}\
debugMessages = {path = \"off\"}\
thinkingStatus = false\
path = love.filesystem.getSaveDirectory()"
	loadstring(str)()
	return str
end

-- initialize variables
love.filesystem.createDirectory("/levels/")
font = {
	love.graphics.newFont("/gfx/font/cour.ttf",14,"normal"),
	love.graphics.newFont("/gfx/font/cour.ttf",20,"normal"),
	love.graphics.newFont("/gfx/font/cour.ttf",24,"normal"),
	love.graphics.newFont("/gfx/font/cour.ttf",32,"normal"),
	love.graphics.newFont("/gfx/font/cour.ttf",36,"normal"),
	love.graphics.newFont("/gfx/font/cour.ttf",40,"normal")
	}
love.graphics.setFont(font[1])
mx, my = love.mouse.getPosition()
mtx, mty = 0,0
gx, gy = 0, 0
rx, ry = 0, 0
groundLevel = 3
mousePressed = false
mouseHeld = false
mouseReleased = false
mouseButton = 0
gameSpeed=1
paused=false
scene="build"
mode="point"
buildObject={"wall",0}
hitching=0 -- temporarily pauses the game if delta time becomes too large
cTable = {}
buttons = {}
threads = 1
fillChannel = nil
fillOn = true
lineX, lineY = -1, -1
lineHeld = false
clockTime = {3,33}
sunColor = {1,1,1}
initializeColors()
maxThreadPaused = false
showPaths = false

err=nil

function titleScreen()
	table.insert(buttons,Button(55,55,"Quit"))
end

-- load settings
if love.filesystem.getInfo("/settings.lua") ~= nil then
	love.filesystem.load("/settings.lua")(self)
else
	love.filesystem.write("/settings.lua",defaultSettings())
end
-- create debug log
if love.filesystem.getInfo("/debug.txt") == nil then
	love.filesystem.write("/debug.txt","")
end
QAlog = {}
ch = love.thread.getChannel("QA")