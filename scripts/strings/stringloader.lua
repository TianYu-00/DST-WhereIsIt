local EnglishStrings = require("strings/language_en")
local ChineseStrings = require("strings/language_cn")

local function DetectLanguage()
	local language = "en"

	if LOC and LOC.GetLocaleCode then
		language = LOC.GetLocaleCode() or "en"
	end

	if language == "zhr" or language == "zht" then
		language = "zh"
	end

	return language
end

local function GetTextStrings()
	local lang = DetectLanguage()
	if lang == "zh" then
		return ChineseStrings
	else
		return EnglishStrings
	end
end

return GetTextStrings

----------------------------------- Comment -----------------------------------

-- This is written for compatibility reasons as i don't want to mess with the base STRINGS from DST
