local miniWindow
HeartometerUI={}

local function L(x) return Translations.Heartometer.L(x) end

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
	if (value <= 23000) then		-- not seen yet but let's at least handle this case
		width=(maxwidth)
		frame:SetBackgroundColor(1, 0, 0, 0.5)		-- red
	elseif (value <= 26000) then	-- neutral
		width=(maxwidth*(value-23000)/(26000-23000))
		frame:SetBackgroundColor(1, 1, 0, 0.5)		-- yellow
	elseif (value <= 36000) then	-- "friendly"
		width=(maxwidth*(value-26000)/(36000-26000))
		frame:SetBackgroundColor(0, 1/3, 1, 0.5)	-- dark blue
	elseif (value <= 56000) then	-- "decorated"
		width=(maxwidth*(value-36000)/(56000-36000))
		frame:SetBackgroundColor(0.5, 2/3, 1, 0.5)	-- bluish
	elseif (value <= 91000) then	-- "honored"
		width=(maxwidth*(value-56000)/(91000-56000))
		frame:SetBackgroundColor(0, 1, 1, 0.5)		-- cyan
	elseif (value <= 151000) then	-- "revered"
		width=(maxwidth*(value-91000)/(151000-91000))
		frame:SetBackgroundColor(0, 1, 1, 0.5)		-- blue/green
	else   				-- "glorified"
		width=(maxwidth)
		frame:SetBackgroundColor(0, 1, 0, 0.5)		-- green
	end
--	print("width="..width)
	if (value==23000 or value==26000 or value==36000 or value==56000 or value==91000 or value==151000) then
		width=maxwidth
	end
	frame:SetWidth(math.floor(width))
end

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
	miniWindow.title:SetFontSize(HeartometerChar.height*0.75)
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
	
	function miniWindow.Event:RightClick()
		local k,v,n, lastCategory
		local list={}
		
		if miniWindow.allFactionWindow and miniWindow.allFactionWindow:GetVisible() then
			miniWindow.allFactionWindow:SetVisible(false)
			HeartometerChar.fixedFactionID = nil
			miniWindow.title:SetFontColor(1, 1, 1, 0)
			if HeartometerChar.lastFactionID then
				HeartometerUI.UpdateFactionWindow(HeartometerChar.lastFactionID)
			end
			return
		end
		
		local details=Inspect.Faction.Detail(Inspect.Faction.List())
		for k,v in pairs(Heartometer.StartNotoriety) do
			if details[k] then
				table.insert(list, k)
			end
		end
		table.sort(list, function(a, b)
			if details[a].categoryName ~= details[b].categoryName then
				return details[a].categoryName < details[b].categoryName
			else
				return details[a].name < details[b].name
			end
		end)
		if not miniWindow.allFactionWindow then
			miniWindow.allFactionWindow=UI.CreateFrame("Frame", "Heartometer", miniWindow)
			miniWindow.allFactionWindow:SetPoint("BOTTOMCENTER", miniWindow, "TOPCENTER", 0, 0)
			miniWindow.allFactionWindow:SetWidth(HeartometerChar.width)
			miniWindow.allFactionWindow:SetBackgroundColor(0.1, 0.1, 0.1, 0.8)
		end
		n=0
		lastCategory=""
		for i, k in ipairs(list) do
			if details[k].categoryName ~= lastCategory then
				lastCategory=details[k].categoryName
				if not miniWindow.categoryWindow[lastCategory] then
					miniWindow.categoryWindow[lastCategory]=UI.CreateFrame("Text", "Heartometer", miniWindow.allFactionWindow)
					miniWindow.categoryWindow[lastCategory]:SetWidth(HeartometerChar.width)
					miniWindow.categoryWindow[lastCategory]:SetHeight(HeartometerChar.height)
					miniWindow.categoryWindow[lastCategory]:SetBackgroundColor(0.1, 0.7, 0.7, 0.8)
					miniWindow.categoryWindow[lastCategory]:SetText(lastCategory)
				end
				miniWindow.categoryWindow[lastCategory]:SetPoint("TOPCENTER", miniWindow.allFactionWindow, "TOPCENTER", 0, n*HeartometerChar.height)
				n=n+1
			end
			if not miniWindow.factionWindow[k] then
				miniWindow.factionWindow[k]=UI.CreateFrame("Text", "Heartometer", miniWindow.allFactionWindow)
				miniWindow.factionWindow[k]:SetWidth(HeartometerChar.width)
				miniWindow.factionWindow[k]:SetHeight(HeartometerChar.height)
				miniWindow.factionWindow[k]:SetBackgroundColor(0.1, 0.1, 0.1, 0.8)

				miniWindow.factionWindow[k].title = UI.CreateFrame("Text", "HeartometerTitle", miniWindow.factionWindow[k])
				miniWindow.factionWindow[k].title:SetPoint("TOPLEFT", miniWindow.factionWindow[k], "TOPLEFT", 0, 0)
				miniWindow.factionWindow[k].title:SetFontSize(HeartometerChar.height*0.75)
				miniWindow.factionWindow[k].title:SetWidth(HeartometerChar.width)
				miniWindow.factionWindow[k].title:SetHeight(HeartometerChar.height)
				miniWindow.factionWindow[k].title:SetBackgroundColor(0, 0, 0, 1)
				miniWindow.factionWindow[k].title:SetLayer(1)

				miniWindow.factionWindow[k].bar = UI.CreateFrame("Frame", "HeartometerBar", miniWindow.factionWindow[k])
				miniWindow.factionWindow[k].bar:SetPoint("TOPLEFT", miniWindow.factionWindow[k], "TOPLEFT", 0, 0)
				miniWindow.factionWindow[k].bar:SetWidth(HeartometerChar.width)
				miniWindow.factionWindow[k].bar:SetHeight(HeartometerChar.height)
				miniWindow.factionWindow[k].bar:SetBackgroundColor(0.2, 0.2, 0.7, 0.5)
				miniWindow.factionWindow[k].bar:SetLayer(2)
				
				miniWindow.factionWindow[k].Event.LeftClick = function()
					HeartometerChar.fixedFactionID = k
					miniWindow.title:SetFontColor(1, 0.7, 0.7, 0)
					miniWindow.allFactionWindow:SetVisible(false)
					HeartometerUI.UpdateFactionWindow(k)
				end
				
			end
			miniWindow.factionWindow[k].title:SetText(notoriety(details[k].name, details[k].notoriety) ..
				"   " .. formatfaction(details[k].name, details[k].notoriety) .. "  (+" ..
				(details[k].notoriety - Heartometer.StartNotoriety[k]) .. ")"
				)
			setColorAndWidth(miniWindow.factionWindow[k].bar, details[k].notoriety)
			miniWindow.factionWindow[k]:SetPoint("TOPCENTER", miniWindow.allFactionWindow, "TOPCENTER", 0, n*HeartometerChar.height)
			n=n+1
		end
		miniWindow.allFactionWindow:SetHeight(HeartometerChar.height*n)
		miniWindow.allFactionWindow:SetVisible(true)
	end

	miniWindow.title = UI.CreateFrame("Text", "HeartometerTitle", miniWindow)
	miniWindow.title:SetText(L("Heartometer"))
	miniWindow.title:SetPoint("TOPLEFT", miniWindow, "TOPLEFT", 0, 0)
	miniWindow.title:SetFontSize(HeartometerChar.height*0.75)
	miniWindow.title:SetWidth(HeartometerChar.width)
	miniWindow.title:SetHeight(HeartometerChar.height)
	miniWindow.title:SetBackgroundColor(0, 0, 0, 0)
	if HeartometerChar.fixedFactionID then
		miniWindow.title:SetFontColor(1, 0.7, 0.7, 0)
	else
		miniWindow.title:SetFontColor(1, 1, 1, 0)
	end
	miniWindow.title:SetLayer(2)

	miniWindow.bar = UI.CreateFrame("Frame", "HeartometerBar", miniWindow)
	miniWindow.bar:SetPoint("TOPLEFT", miniWindow, "TOPLEFT", 0, 0)
	miniWindow.bar:SetWidth(HeartometerChar.width)
	miniWindow.bar:SetHeight(HeartometerChar.height)
	miniWindow.bar:SetBackgroundColor(0.2, 0.2, 0.7, 0.5)
	miniWindow.bar:SetLayer(1)
	
	miniWindow.categoryWindow={}
	miniWindow.factionWindow={}
	
	if HeartometerChar.fixedFactionID then
		HeartometerUI.UpdateFactionWindow(HeartometerChar.fixedFactionID)
	elseif HeartometerChar.lastFactionID then
		HeartometerUI.UpdateFactionWindow(HeartometerChar.lastFactionID)
	end
end

function HeartometerUI.UpdateFactionWindow(factionID)
	-- print("updateFactionWindow("..factionID..")")
	if miniWindow then if Heartometer.StartNotoriety[factionID] then
		local faction=Inspect.Faction.Detail(factionID)
		miniWindow.title:SetText(notoriety(faction.name, faction.notoriety) ..
			"   " .. formatfaction(faction.name, faction.notoriety) .. "  (+" ..
			(faction.notoriety - Heartometer.StartNotoriety[factionID]) .. ")"
			)
		setColorAndWidth(miniWindow.bar, faction.notoriety)
	end end
end

function HeartometerUI.create()
	local context=UI.CreateContext("Heartometer")
	
	if (miniWindow == nil) then
		buildMiniWindow(context)
	end
end
