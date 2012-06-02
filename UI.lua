local miniWindow
HeartometerUI={}

local function L(x) return Translations.Heartometer.L(x) end

function HeartometerUI.show()
	HeartometerChar.show=true
	miniWindow:SetVisible(true)
end

function HeartometerUI.hide()
	HeartometerChar.show=false
	miniWindow:SetVisible(false)
end

function HeartometerUI.newSize()
	miniWindow:SetWidth(HeartometerChar.width)
	miniWindow:SetHeight(HeartometerChar.height)
	miniWindow.title:SetWidth(HeartometerChar.width)
	miniWindow.title:SetHeight(HeartometerChar.height)
	miniWindow.bar:SetWidth(HeartometerChar.width)
	miniWindow.bar:SetHeight(HeartometerChar.height)
end

local function buildMiniWindow(context)
	miniWindow=UI.CreateFrame("Frame", "Heartometer", context)
	miniWindow:SetPoint("TOPLEFT", UIParent, "TOPLEFT", HeartometerChar.xpos, HeartometerChar.ypos)
	miniWindow:SetWidth(HeartometerChar.width)
	miniWindow:SetHeight(HeartometerChar.height)
	miniWindow:SetBackgroundColor(0.1, 0.1, 0.1, 0.8)
	miniWindow:SetVisible(HeartometerChar.show)
	miniWindow.state={}
	function miniWindow.Event:LeftDown()
		miniWindow.state.mouseDown = true
		local mouse = Inspect.Mouse()
		miniWindow.state.startX = miniWindow:GetLeft()
		miniWindow.state.startY = miniWindow:GetTop()
		miniWindow.state.mouseStartX = mouse.x
		miniWindow.state.mouseStartY = mouse.y
		miniWindow:SetBackgroundColor(0.4, 0.4, 0.4, 0.8)
	end

	function miniWindow.Event:MouseMove()
		if miniWindow.state.mouseDown then
			local mouse = Inspect.Mouse()
			HeartometerChar.xpos=mouse.x - miniWindow.state.mouseStartX + miniWindow.state.startX
			HeartometerChar.ypos=mouse.y - miniWindow.state.mouseStartY + miniWindow.state.startY
			miniWindow:SetPoint("TOPLEFT", UIParent, "TOPLEFT",
				HeartometerChar.xpos, HeartometerChar.ypos)
		end
	end

	function miniWindow.Event:LeftUp()
		if miniWindow.state.mouseDown then
			miniWindow.state.mouseDown = false
			miniWindow:SetBackgroundColor(0.1, 0.1, 0.1, 0.8)
		end
	end

	miniWindow.title = UI.CreateFrame("Text", "HeartometerTitle", miniWindow)
	miniWindow.title:SetText(L("Heartometer"))
	miniWindow.title:SetPoint("TOPLEFT", miniWindow, "TOPLEFT", 0, 0)
	miniWindow.title:SetFontSize(10)
	miniWindow.title:SetWidth(HeartometerChar.width)
	miniWindow.title:SetHeight(HeartometerChar.height)
	miniWindow.title:SetBackgroundColor(0, 0, 0, 1)
	miniWindow.title:SetLayer(1)

	miniWindow.bar = UI.CreateFrame("Frame", "HeartometerBar", miniWindow)
	miniWindow.bar:SetPoint("TOPLEFT", miniWindow, "TOPLEFT", 0, 0)
	miniWindow.bar:SetWidth(HeartometerChar.width)
	miniWindow.bar:SetHeight(HeartometerChar.height)
	miniWindow.bar:SetBackgroundColor(0.2, 0.2, 0.7, 0.5)
	miniWindow.bar:SetLayer(2)
end

local function formatfaction(name, amount)
	if (amount < 23000) then
		return (amount).."/23000"
	elseif (amount < 26000) then
		return (amount-23000).."/3000"
	elseif (amount < 36000) then
		return (amount-26000).."/10000"
	elseif (amount < 56000) then
		return (amount-36000).."/20000"
	elseif (amount < 91000) then
		return (amount-56000).."/35000"
	elseif (amount < 151000) then
		return (amount-91000).."/60000"
	else
		return ""
	end
end

local function notoriety(name, amount)
	if (amount < 23000) then	-- not in game
		return name .. ": " .. L("hated")
	elseif (amount < 26000) then
		return name .. ": " .. L("neutral")
	elseif (amount < 36000) then
		return name .. ": " .. L("friendly")
	elseif (amount < 56000) then
		return name .. ": " .. L("decorated")
	elseif (amount < 91000) then
		return name .. ": " .. L("honored")
	elseif (amount < 151000) then
		return name .. ": " .. L("revered")
	else
		return name .. ": " .. L("glorified")
	end
end

local function setColorAndWidth(frame, value)
	local width
	local maxwidth=HeartometerChar.width
--	print("value="..value)
	if (value < 23000) then		-- not seen yet but let's at least handle this case
		width=(maxwidth)
		frame:SetBackgroundColor(1, 0, 0, 0.5)		-- red
	elseif (value < 26000) then	-- neutral
		width=(maxwidth*(value-23000)/(26000-23000))
		frame:SetBackgroundColor(1, 1, 0, 0.5)		-- yellow
	elseif (value < 36000) then	-- "friendly"
		width=(maxwidth*(value-26000)/(36000-26000))
		frame:SetBackgroundColor(0, 1/3, 1, 0.5)	-- dark blue
	elseif (value < 56000) then	-- "decorated"
		width=(maxwidth*(value-36000)/(56000-36000))
		frame:SetBackgroundColor(0.5, 2/3, 1, 0.5)	-- bluish
	elseif (value < 91000) then	-- "honored"
		width=(maxwidth*(value-56000)/(91000-56000))
		frame:SetBackgroundColor(0, 1, 1, 0.5)		-- cyan
	elseif (value < 151000) then	-- "revered"
		width=(maxwidth*(value-91000)/(151000-91000))
		frame:SetBackgroundColor(0, 1, 1, 0.5)		-- blue/green
	else   				-- "glorified"
		width=(maxwidth)
		frame:SetBackgroundColor(0, 1, 0, 0.5)		-- green
	end
--	print("width="..width)
	frame:SetWidth(math.floor(width))
end

function HeartometerUI.UpdateFactionWindow(factionID, value)
	if miniWindow then if Heartometer.StartNotoriety[factionID] then
		local faction=Inspect.Faction.Detail(factionID)
		miniWindow.title:SetText(notoriety(faction.name, value) ..
			"   " .. formatfaction(faction.name, value) .. "  (+" ..
			(value - Heartometer.StartNotoriety[factionID]) .. ")"
			)
		setColorAndWidth(miniWindow.bar, value)
	end end
end

function HeartometerUI.create()
	local context=UI.CreateContext("Heartometer")
	
	if (miniWindow == nil) then
		buildMiniWindow(context)
	end
end
