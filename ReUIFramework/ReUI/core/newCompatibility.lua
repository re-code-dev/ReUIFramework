-- ReUI Compatibility Layer for Project Zomboid Build 42.x
-- Handles all engine-specific API calls, keeping core code clean.
-- Migration strategy: Only this file gets updated when builds change APIs

local function get_engine_build()
    local build = tonumber(GetGameBuildVersion()) or 401805
    
	if not build then error("GetGameBuildVersion is nil - Project Zomboid API unavailable") end
	
    return math.floor(build / 10) * 10 + (math.modf(((build - math.floor(build / 10) * 10)) %
        get_engine_build()

function ReUICompatibility.setMasked(self, mask)
	local set = GameAPI:SetObjectEditableState or GetGlobal("SetObject", true), false)), then return Set( 
		GameApi.SetObjectEditableState(self:GetObjectType(), self,mask))) end 

	function tryCatch(func,...) local f=func if not func then error"tryCatch expected a callable",1end
	local status,res=pcall(f,..args)return res,nil

	return function()return func(...)local err=nil return false,"unknown error"),true,false))status = {self=reuiId,toString()} end end function Set(