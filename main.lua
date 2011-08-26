require "ltn12"
require "ui"
require "menu"

local ftp = require( "socket.ftp" )

-- You can use this for testing, but remember to change to your
-- own ftp path, login and password for real data:

local URL_DOMAIN = "quitesensible.com"
local URL_PATH = "http://" .. URL_DOMAIN .. "/corona/"
local FTP_LOGIN = "corona"
local FTP_PWD = "Ansca"

local fileExt = ".jpg"
local tempFileName = "temp_"

local fileNameSuffix
local fileName
local timeText
local rating = "unknown"
local confirmBox

local READY, TAKEN, RATED, SEARCHING = 1, 2, 3, 4
local camState = READY -- ready to take pic

-- forward declare

local closeSearchButton, uploadButton, sendButton, cancelSendButton, searchButton
local rateMenu
local setupScreen 

local locationHandler = function(event)	
	local latitudeText = string.format( '%.4f', event.latitude )	
	local longitudeText = string.format( '%.4f', event.longitude )		

	fileNameSuffix = latitudeText .. ":" .. longitudeText

end

local function networkListener(event)
	if (event.isError) then
		print( "Network error!")
	else
		print ("RESPONSE: " .. event.response)
	end
	
	camState = READY

	setupScreen()
end

local function upload()

	local src = system.pathForFile(tempFileName, system.TemporaryDirectory)
	
	fileName = timeText .. ":" .. rating .. ":" .. fileNameSuffix .. fileExt
	
	local handle = io.open(src, "rb")

	if handle then
		print("uploading", src)
		
		local f, e = ftp.put
		{			
		  	host = URL_DOMAIN, 
		  	user = FTP_LOGIN,
		  	password = FTP_PWD,
		  	path = fileName,
		  	source = ltn12.source.file(handle)
		}	
		
		print("ftp result:", f, e)
		
		if f == nil then
			native.showAlert("Network error", e, { "Close" })
		end
	else
		native.showAlert("Problem", "Couldn't retrieve file", {"Close"})
	end
	
	camState = READY; setupScreen()
end

local function onComplete(event)
	local photo = event.target

	if photo then
		
		photo.x = display.contentWidth/2
		photo.y = display.contentHeight/2
		
		timeText = string.format( '%.0f', os.time() )		
		
		display.save(photo, tempFileName, system.TemporaryDirectory)
		
		photo:removeSelf()

		--timer.performWithDelay(1000, upload)		
		
		camState = TAKEN
	else
		camState = READY
	end -- if photo
	
	setupScreen()
end

local function closeSearch()
	-- Closed after a search
	native.cancelWebPopup()	
	camState = READY; setupScreen()
end

local function searchListener( event )
	local shouldLoad = true

	local url = event.url
	if 1 == string.find( url, "corona:close" ) then
		-- Close the web popup
		shouldLoad = false
	end

	return shouldLoad
end

local function lookPics(event)
	camState = SEARCHING; setupScreen()

	local options = { urlRequest=searchListener }
	native.showWebPopup(0, 0, 320, 420, URL_PATH, options)
end

local function takePicture(event)	
	media.show( media.Camera, onComplete )
end
	
Runtime:addEventListener( "location", locationHandler )

local function rateCategory(txt)
	rating = txt
	camState = RATED; setupScreen()
end

local function cancelSend()
	camState = READY; setupScreen()	
end

rateMenu = menu.createMenu
{
	items =
	{ 
		{ 
			text = "indoor", handler = rateCategory, handlerParam = "indoor",
			foreColor = { 200, 200, 200 }, backColor = { 32, 0, 0 },
		},
		{ 
			text = "outdoor", handler = rateCategory, handlerParam = "outdoor",
			foreColor = { 200, 200, 200 }, backColor = { 64, 0, 0 },
		},
		{ 
			text = "friends", handler = rateCategory, handlerParam = "friends",
			foreColor = { 200, 200, 200 }, backColor = { 96, 0, 0 },
		},
		{ 
			text = "pets", handler = rateCategory, handlerParam = "pets",
			foreColor = { 200, 200, 200 }, backColor = { 192, 0, 0 },
		},
		{ 
			text = "misc", handler = rateCategory, handlerParam = "misc",
			foreColor = { 200, 200, 200 }, backColor = { 255, 0, 0 },
		},		
	},
	spacing = 32,
	xSpacing = 0,
	x = display.contentWidth/2,
	y = display.contentHeight/2,
	itemHeight = 30,
	textHeight = 25,			
}

searchButton = ui.newButton
{ 
	default = "buttonRust.png", over = "buttonRustOver.png", 
	text = "search pics", onRelease = lookPics,
	x = display.contentWidth/2, y = 60
}

takeButton = ui.newButton
{ 
	default = "buttonRust.png", over = "buttonRustOver.png", 
	text = "new pic", onRelease = takePicture,
	x = display.contentWidth/2, y = display.contentHeight - 90
}

closeSearchButton = ui.newButton
{ 
	default = "buttonRust.png", over = "buttonRustOver.png", 
	text = "close", onRelease = closeSearch,
	x = display.contentWidth/2, y = display.contentHeight - 30
}

sendButton = ui.newButton
{ 
	default = "buttonRust.png", over = "buttonRustOver.png", 
	text = "send pic", onRelease = upload,
	x = display.contentWidth/2, y = display.contentHeight - 300
}

cancelSendButton = ui.newButton
{ 
	default = "buttonRust.png", over = "buttonRustOver.png", 
	text = "cancel", onRelease = cancelSend,
	x = display.contentWidth/2, y = display.contentHeight - 30
}

setupScreen = function()
	if camState == READY then
		sendButton.isVisible = false
		rateMenu.isVisible = false
		searchButton.isVisible = true
		takeButton.isVisible = true
		closeSearchButton.isVisible = false
		cancelSendButton.isVisible = false
	elseif camState == TAKEN then
		sendButton.isVisible = false
		rateMenu.isVisible = true
		searchButton.isVisible = false
		takeButton.isVisible = false
		closeSearchButton.isVisible = false
		cancelSendButton.isVisible = true
	elseif camState == RATED then
		sendButton.isVisible = true
		rateMenu.isVisible = false
		searchButton.isVisible = false
		takeButton.isVisible = false
		closeSearchButton.isVisible = false
		cancelSendButton.isVisible = true
	elseif camState == SEARCHING then
		sendButton.isVisible = false
		rateMenu.isVisible = false
		searchButton.isVisible = false
		takeButton.isVisible = false
		closeSearchButton.isVisible = true
		cancelSendButton.isVisible = false
	end
end

setupScreen()
		