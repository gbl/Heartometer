if Heartometer then
	print ("Heartometer already loaded")
	return
end

Heartometer = {
	version = 0.1
}

local function L(x) return Translations.Heartometer.L(x) end

local function ensureVariablesInited()
	if not HeartometerChar then HeartometerChar={} end
	HeartometerChar.width=HeartometerChar.width or 300
	HeartometerChar.height=HeartometerChar.height or 20
	if not HeartometerChar.xpos then HeartometerChar.xpos = 200 end
	if not HeartometerChar.ypos then HeartometerChar.ypos = 200 end
	if HeartometerChar.show==nil then HeartometerChar.show=true end
	
	if not HeartometerShard then HeartometerShard={} end
	if not HeartometerGlobal then HeartometerGlobal={} end
end

local function factionChanged(factions)
	for k, v in pairs(factions) do
		if not Heartometer.StartNotoriety[k] then
			Heartometer.StartNotoriety[k]=v
		end
		if not Heartometer.CurrentNotoriety[k] then
			Heartometer.CurrentNotoriety[k]=v
		end
		if Heartometer.CurrentNotoriety[k] ~= v then
			Heartometer.CurrentNotoriety[k]=v
			HeartometerUI.UpdateFactionWindow(k, v)
		end
	end
end

function Heartometer.printVersion()
	print(L("Heartometer Version ") .. (Heartometer.version) .. L(" installed!"))
end

function Heartometer.SlashHandler(args)
	local r = {}
	local numargs = 0
	for token in string.gmatch(args, "[^%s]+") do
		r[numargs] = token
		numargs=numargs+1
	end
	if numargs>0 then
		if r[0] == "version" then
			Heartometer.printVersion()
		end
		if r[0] == "show" then
			HeartometerUI.show()
		end
		if r[0] == "hide" then
			HeartometerUI.hide()
		end
		if r[0] == "width" then
			HeartometerChar.width=tonumber(r[1])
			HeartometerUI.newSize()
		end
		if r[0] == "height" then
			HeartometerChar.height=tonumber(r[1])
			HeartometerUI.newSize()
		end
	end
end

local function addonLoaded(addon) 
	if (addon == "Heartometer") then
		ensureVariablesInited()
		Heartometer.StartNotoriety=Inspect.Faction.List()
		Heartometer.CurrentNotoriety=Inspect.Faction.List()
		HeartometerUI.create()
		Heartometer.printVersion()
	end
end

table.insert(Event.Faction.Notoriety, 	  		{factionChanged, "Heartometer", "factionChanged"})
table.insert(Command.Slash.Register("heart"), 	{Heartometer.SlashHandler, "Heartometer", "SlashHandler" })
table.insert(Event.Addon.Load.End, 				{addonLoaded, "Heartometer", "AddonLoaded" })
