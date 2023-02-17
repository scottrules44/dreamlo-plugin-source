-- How to setup: 1. go to http://www.dreamlo.com/ 2. save your url(notes, evernote, etc) 3. (optional) if you want ssl make sure you donate 5 or more to Carmine T. Guida
-- 4. paste in Public Code , Private Code
local dreamlo = require("plugin.dreamlo")
local widget = require("widget")

dreamlo.init("5a14c80c6b2b65640888869c", "HaiEuwggGkq8WRqOqzIL5AzM8ylA5JXUOvMd1qyc-ppg", true)
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
local nameInput = native.newTextField( display.contentCenterX, display.contentCenterY-120, 200, 30 )
local nameText = display.newText( "Enter Name", nameInput.x, nameInput.y-40, nil, 20 )
local scoreInput = native.newTextField( display.contentCenterX, display.contentCenterY-50, 200, 30 )
local scoreText = display.newText( "Enter Score", scoreInput.x, scoreInput.y-40, nil, 20 )
local button1 = display.newGroup( )
local button2 = display.newGroup( )
local button3 = display.newGroup( )
local function makeButton ( name, group )
    local box = display.newRoundedRect(display.contentCenterX, display.contentCenterY, 140, 50, 10 )
    local myText = display.newText( name, display.contentCenterX, display.contentCenterY, nil, 20 )
    myText:setFillColor( 0 )
    function box:touch( e )

        if (e.phase == "began") then
            if (name == "Submit Score") then
                local function handleScore( ev )
                    if (not ev.error) then
                        myText.text = "Score Sent"
                    else
                        myText.text = "Error"
                    end
                    timer.performWithDelay( 1000, function (  )
                           myText.text = name
                    end )
                end
                dreamlo.add(nameInput.text, {tonumber(scoreInput.text)}, handleScore)
            elseif (name == "Delete All") then
                local function handleScore( ev )
                    if (not ev.error) then
                        myText.text = "Scores Erased"
                    else
                        myText.text = "Error"
                    end
                    timer.performWithDelay( 1000, function (  )
                           myText.text = name
                    end )
                end
                dreamlo.deleteAll(handleScore)
            elseif (name == "Print Score") then
                
                local function handleScore( ev )
                    if (not ev.error) then
                        myText.text = "Scores Printed"
                    else
                        myText.text = "Error"
                    end
                    if (ev.data == nil) then
                        print( "no scores" )
                    else
                        print_r(ev.data)
                    end
                    timer.performWithDelay( 1000, function (  )
                        myText.text = name
                    end )
                end
                dreamlo.getScores({name = "bob"}, handleScore)
            end
            box:setFillColor( 0,0,1 )
        elseif e.phase == "moved" or e.phase == "ended" or e.phase == "cancelled" then
            box:setFillColor( 1,1,1 )
        end
    end
    box:addEventListener( "touch", box )
    if (name == "Delete All") then
        box.x, box.y = box.x, box.y+60
        myText.x, myText.y = myText.x, myText.y+60
    elseif (name == "Print Score") then
        box.x, box.y = box.x, box.y+120
        myText.x, myText.y = myText.x, myText.y+120
    end
end
makeButton("Submit Score",button1)
makeButton("Delete All",button2)
makeButton("Print Score",button3)

--other commands

--dreamlo.getScores(nil, handleScore)
--dreamlo.add("bob", {1234, 123, "sdasd"}, handleScore)
--dreamlo.add("jim", {1234}, handleScore)
--dreamlo.delete( "bob", handleScore )
--dreamlo.delete( "jim", handleScore )
--dreamlo.getScores(nil, handleScore)
--dreamlo.deleteAll( handleScore)
