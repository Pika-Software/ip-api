local http_GetStatusDescription = http.GetStatusDescription
local util_JSONToTable = util.JSONToTable
local promise_Reject = promise.Reject
local promise_Async = promise.Async
local http_Fetch = http.Fetch
local select = select

local function handleRequest( path )
    local ok, result = http_Fetch( "http://ip-api.com/json/" .. path ):SafeAwait()
    if not ok then return promise_Reject( result ) end

    local code = result.code
    if code ~= 200 then
        return promise_Reject( select( -1, http_GetStatusDescription( code ) ) )
    end

    result = util_JSONToTable( result.body )
    if not result then
        return promise_Reject( "JSONToTable failed.")
    end

    if result.status ~= "success" then
        return promise_Reject( result.message )
    end

    return result
end

local lib = {}

lib.GetAll = promise_Async( function( ip )
    return handleRequest( ip .. "?fields=status,message,continent,continentCode,country,countryCode,region,regionName,city,zip,lat,lon,timezone,offset,currency,isp,org,as,asname,reverse,proxy,hosting,query" )
end )

lib.IsProxy = promise_Async( function( ip )
    return handleRequest( ip .. "?fields=status,message,proxy" ).proxy == true
end )

lib.IsHosting = promise_Async( function( ip )
    return handleRequest( ip .. "?fields=status,message,hosting" ).hosting == true
end )

lib.GetReverseDNS = promise_Async( function( ip )
    return handleRequest( ip .. "?fields=status,message,reverse" ).reverse
end )

lib.GetCurrency = promise_Async( function( ip )
    return handleRequest( ip .. "?fields=status,message,currency" ).currency
end )

lib.GetLocation = promise_Async( function( ip )
    return handleRequest( ip .. "?fields=status,message,continent,continentCode,country,countryCode,region,regionName,city,district,zip,lat,lon" )
end )

lib.GetTimezone = promise_Async( function( ip )
    return handleRequest( ip .. "?fields=status,message,timezone,offset" )
end )

lib.GetISP = promise_Async( function( ip )
    return handleRequest( ip .. "?fields=status,message,isp,org,as,asname" )
end )

return lib