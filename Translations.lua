if not Translations then Translations = {} end
if not Translations.Heartometer then Translations.Heartometer = {} end

local translationTable = {
	["German"] = {
		["Heartometer"]		   = "Heartometer",
		["Heartometer Version "]	   = "Heartometer Version ",
		[" installed!"] 	   = " installiert!",
		
		hated			= "verhasst",
		neutral			= "neutral",
		friendly		= "verbündet",
		decorated		= "dekoriert",
		honored			= "geschätzt",
		revered			= "verehrt",
		glorified		= "verherrlicht",
	}
}

function Translations.Heartometer.L(x)
	local lang=Inspect.System.Language()
	if  translationTable[lang]
	and translationTable[lang][x] then
		return translationTable[lang][x]
	elseif lang == "English"  then
		return x
	else
		print ("No translation yet for '" .. lang .. "'/'" .. x .. "'")
		return x
	end
end
