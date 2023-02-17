local m = {}
--plugins
local json = require("json")
--
local myPublicCode
local myPrivateCode
local isHttps = "http://www."
local showAlerts = false
local theEndpoint = "dreamlo.com/lb/"
--get verison
m.version = "1.0.3"
--split strings
function string:split( inSplitPattern, outResults )

   if not outResults then
      outResults = {}
   end
   local theStart = 1
   local theSplitStart, theSplitEnd = string.find( self, inSplitPattern, theStart )
   while theSplitStart do
      table.insert( outResults, string.sub( self, theStart, theSplitStart-1 ) )
      theStart = theSplitEnd + 1
      theSplitStart, theSplitEnd = string.find( self, inSplitPattern, theStart )
   end
   table.insert( outResults, string.sub( self, theStart ) )
   return outResults
end
-- print tables
local function print_r ( t )
    local print_r_cache={}
    local function sub_print_r(t,indent)
        if (print_r_cache[tostring(t)]) then
            print(indent.."*"..tostring(t))
        else
            print_r_cache[tostring(t)]=true
            if (type(t)=="table") then
                for pos,val in pairs(t) do
                    if (type(val)=="table") then
                        print(indent.."["..pos.."] => "..tostring(t).." {")
                        sub_print_r(val,indent..string.rep(" ",string.len(pos)+8))
                        print(indent..string.rep(" ",string.len(pos)+6).."}")
                    elseif (type(val)=="string") then
                        print(indent.."["..pos..'] => "'..val..'"')
                    else
                        print(indent.."["..pos.."] => "..tostring(val))
                    end
                end
            else
                print(indent..tostring(t))
            end
        end
    end
    if (type(t)=="table") then
        print(tostring(t).." {")
        sub_print_r(t,"  ")
        print("}")
    else
        sub_print_r(t,"  ")
    end
    print()
end
function string.urlEncode( str )
   if ( str ) then
      str = string.gsub( str, "\n", "\r\n" )
      str = string.gsub( str, "([^%w ])",
         function (c) return string.format( "%%%02X", string.byte(c) ) end )
      str = string.gsub( str, " ", "+" )
   end
   return str
end
--

function m.init( publicCode, privateCode, alerts ,httpsOn )
	if (publicCode) then
		myPublicCode = publicCode
	elseif showAlerts == true then
		print( "Dreamlo Plugin: No Public Code" )
	end
	if (privateCode) then
		myPrivateCode = privateCode
	elseif showAlerts == true then
		print( "Dreamlo Plugin: No Private Code" )
	end
	if (httpsOn == true) then
		isHttps = "https://www."
		if (showAlerts == true) then
			print( "Dreamlo Plugin: Https is On" )
		end
	else
		isHttps = "http://www."
	end
end
m.int = m.init
function m.add( playerName, myData, lis )
	if showAlerts == true and (myPublicCode== nil or myPrivateCode== nil) then
		print( "Dreamlo Plugin: Missing publicCode and/or privateCode" )
	end
	local myStringData = ""
	if (myData) then
		for i=1,#myData do
			myStringData = myStringData..myData[i].."/"
		end
	end
	local function handleGet( e )
		if (e.isError) then
			lis({isError = true, isDone = false})
			print( "Dreamlo Plugin: No Connection" )
		else
			if (e.response == "OK") then
				lis({isError = false, isDone = true})
				if (showAlerts == true) then
					print( "Dreamlo Plugin: Add/Updated Player Data" )
				end
			else
				lis({isError = false, isDone = false})
				if (showAlerts == true) then
					print( "Dreamlo Plugin: No Error, but action was not completed" )
				end
			end
		end
	end
	network.request( isHttps..theEndpoint..myPrivateCode.."/add/"..string.urlEncode(playerName).."/"..string.urlEncode(myStringData), "GET", handleGet  )
end
function m.delete( playerName, lis )
	if showAlerts == true and (myPublicCode== nil or myPrivateCode== nil) then
		print( "Dreamlo Plugin: Missing publicCode and/or privateCode" )
	end
	local function handleGet( e )
		if (e.isError) then
			lis({isError = true, isDone = false})
			print( "Dreamlo Plugin: No Connection" )
		else
			if (e.response == "OK") then
				lis({isError = false, isDone = true})
				if (showAlerts == true) then
					print( "Dreamlo Plugin: Deleted Player and all there data" )
				end
			else
				lis({isError = false, isDone = false})
				if (showAlerts == true) then
					print( "Dreamlo Plugin: No Error, but action was not completed" )
				end
			end
		end
	end
	network.request( isHttps..theEndpoint..myPrivateCode.."/delete/"..string.urlEncode(playerName), "GET", handleGet  )
end
function m.deleteAll( lis )
	if showAlerts == true and (myPublicCode== nil or myPrivateCode== nil) then
		print( "Dreamlo Plugin: Missing publicCode and/or privateCode" )
	end
	local function handleGet( e )
		if (e.isError) then
			lis({isError = true, isDone = false})
			print( "Dreamlo Plugin: No Connection" )
		else
			if (e.response == "OK") then
				lis({isError = false, isDone = true})
				if (showAlerts == true) then
					print( "Dreamlo Plugin: Deleted All" )
				end
			else
				lis({isError = false, isDone = false})
				if (showAlerts == true) then
					print( "Dreamlo Plugin: No Error, but action was not completed" )
				end
			end
		end
	end
	network.request( isHttps..theEndpoint..myPrivateCode.."/clear", "GET", handleGet  )
end
-- sort(string), ascending(true or false), amount(num), ending(num), name
function m.getScores( myData, lis )
	if showAlerts == true and (myPublicCode== nil or myPrivateCode== nil) then
		print( "Dreamlo Plugin: Missing publicCode and/or privateCode" )
	end
	local myStringData = ""
	if (myData) then
		if (myData.name ~= nil) then
			myStringData = "pipe-get/"..myData.name
			if (showAlerts == true) then
				print( "Dreamlo Plugin: Getting Only One Player Info" )
			end
		else
			if (myData.ascending == true and myData.sort ~= nil ) then
				if (myData.amount ~= nil and myData.ending == nil) then
					myStringData = "json-"..myData.sort.."-ascending/"..myData.amount
				elseif (myData.amount ~= nil and myData.ending ~= nil) then
					myStringData = "json-"..myData.sort.."-ascending/"..myData.amount.."/"..myData.ending
				elseif (myData.amount == nil and myData.ending ~= nil) then
					error( "Make sure you add 'amount' to your table in getScores.")
				else
					myStringData = "json-"..myData.sort.."-ascending/"
				end
			elseif ((myData.ascending == false or myData.ascending == nil) and myData.sort ~= nil) then
				if (myData.amount ~= nil and myData.ending == nil) then
					myStringData = "json-"..myData.sort.."/"..myData.amount
				elseif (myData.amount ~= nil and myData.ending ~= nil) then
					myStringData = "json-"..myData.sort.."/"..myData.amount.."/"..myData.ending
				elseif (myData.amount == nil and myData.ending ~= nil) then
					error( "Make sure you add 'amount' to your table in getScores.")
				else
					myStringData = "json-"..myData.sort
				end

			elseif (myData.ascending == true and myData.sort ~= nil ) then
				if (myData.amount ~= nil and myData.ending == nil) then
					myStringData = "json-ascending/"..myData.amount
				elseif (myData.amount ~= nil and myData.ending ~= nil) then
					myStringData = "json-ascending/"..myData.amount.."/"..myData.ending
				elseif (myData.amount == nil and myData.ending ~= nil) then
					error( "Make sure you add 'amount' to your table in getScores.")
				else
					myStringData = "json-ascending/"
				end
			end
      if (myData and myData.amount ~= nil and myData.ending == nil) then
  			myStringData = "json/"..myData.amount
  		elseif (myData and myData.amount ~= nil and myData.ending ~= nil) then
  			myStringData = "json/"..myData.amount.."/"..myData.ending
  		elseif (myData and myData.amount == nil and myData.ending ~= nil) then
  			error( "Make sure you add 'amount' to your table in getScores.")
  		else
  			myStringData = "json"
  		end
		end

	end
	local function handleGet( e )
		if (e.isError) then

			if (showAlerts == true) then
				print( "Dreamlo Plugin: Cannot Make Connection" )
			end
			lis({isError = true, error= "Cannot Make Connection", isData = false})
		else
      local tempTable

      if myData and myData.name ~= nil and e.response ~= nil then
        local dataFromRequest = e.response
        local tempTable5 = dataFromRequest:split("|")
        
        tempTable = {["seconds"] = tempTable5[3], ["name"] =tempTable5[1] , ["date"] =tempTable5[5], ["text"] =tempTable5[4], ["score"]= tempTable5[2]}
        lis({isError = true, error= nil, isData = true, data = tempTable})
        return true
      else
        tempTable = json.decode( e.response)
        
      end

			if (tempTable and tempTable.dreamlo) then
				if tempTable.dreamlo.leaderboard == nil then
					if (showAlerts == true) then
						print( "Dreamlo Plugin: No Scores" )
					end
					lis({isError = false, error= nil, isData = false})
				else
					if (showAlerts == true) then
						print( "Dreamlo Plugin: Got Scores" )
						print_r(tempTable.dreamlo.leaderboard.entry)
					end
					lis({isError = true, error= nil, isData = true, data = tempTable.dreamlo.leaderboard.entry})
				end
			else
				if (showAlerts == true) then
					print( "Dreamlo Plugin: Cannot Make Connection" )
				end
				lis({isError = true, error= "Cannot Make Connection", isData = false})
			end
		end
	end
	if (myData == nil) then
		network.request( isHttps..theEndpoint..myPublicCode.."/json", "POST", handleGet  )
	else
    if myData.name ~= nil then

      network.request( isHttps..theEndpoint..myPublicCode.."/"..myStringData, "POST", handleGet  )
      print( isHttps..theEndpoint..myPublicCode.."/"..myStringData )
    else
      network.request( isHttps..theEndpoint..myPublicCode.."/"..string.urlEncode(myStringData), "POST", handleGet  )
    end

	end
end
return m
