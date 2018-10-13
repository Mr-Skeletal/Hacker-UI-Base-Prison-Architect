local Time       = Game.Time;
local Delay      = 1; -- game seconds
local Ready      = Time();
local UIElements = {"caption","patch","button","icon","portrait","portraitIcon"}

local InstructionArr = {}


local size = {0,0} --SIZE WILL BE REPLACED WITH batchElement("Patch") REFRAIN FROM USING IT
local prevSize = size

local position = {0,0}
local container = {} --reserved for the Patch element because thats the one your gonna hate being mixed into items (see editAtIndex)
local items = {}
local interactives = {} --stores interactive object (interactive objects still get stored in items)
local firstEle = false;

local blob = {} --resets
local textBackground = false --might go away

local jumbleText = {"a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z","?","!",".",",",":","/","-","+","=","%","#","$","<",">","^","*","&","'","(",")"," ","1","2","3","4","5","6","7","8","9","0"} --text used to furthur make the UID harder to have twice in a game

function split(string,sep) --got to the the worst way to split a string but eh it only does it when it reloads a save 
    
    rt = {}
    cur = #rt+1
    
    for i = 1, #string do
        if rt[cur] == nil then
            rt[cur] = {}
        end
        
        local v = string:sub(i,i)
        
        if v == sep then
            rt[cur] = table.concat(rt[cur],"")
            cur = cur + 1
        else
            table.insert(rt[cur],v)
        end
                
        if i == #string then
            if rt[cur] ~= nil then
                rt[cur] = table.concat(rt[cur],"")
            end
        end
    end
    return rt
end

function recoverUI()
    if this.InstructionString == nil and this.RecoverOld == false then
        return
    end
    
    --string.gmatch(example, "%S+")
    --caption && "text" END
    instruct = split(this.InstructionString,"E")
    terms = {}
    for i,v in pairs(instruct) do
        terms[i] = {}
        for a,b in pairs(split(v,"A")) do 
            terms[i][a] = b;
        end 
    end
    for i,v in pairs(terms) do
        t = {}
        for a=2, #v do
            if v[a] == "nil" then --make sure nil does not stay a string
                v[a] = nil
            end
            table.insert(t,v[a])
        end
        recoverElement(v[1],t)
    end
end

function removeOldUI()
    UIobjects = {"Letters_Capital_NoStroke","Numbers_NoStroke","BackGround_Blue","Icon_UI"}
	for i,v in pairs(UIobjects) do
	debug(v)
        ens = this.GetNearbyObjects(v,9999999999)
        for a,b in pairs(ens) do 
			debug(a)
			debug(a.UID)
			debug(this.UID)
            if a.UID == this.UID then 
				a.Delete()
			end
        end 
    end
end

function arrToStringReadable(arr)
    for i,v in pairs(arr) do
        for a,b in pairs(arr[i]) do
            --update
            
            --convert to string
            if a ~= #arr[i] then
                arr[i][a] = tostring(arr[i][a]) .. "A"
            else
                arr[i][a] = tostring(arr[i][a]) .. "E"
            end
        end
    end
    
    return arr
end


function recoverElement(Etype,Eprops)
    newElement(Etype,{Eprops[1],Eprops[2]},Eprops[3],Eprops[4])
end

function firstRun()
	removeOldUI()
    recoverUI()
end

function batchElement(width,height,ele,posArr,text,subtype) --will replace the background system
    temp = {posArr[1],posArr[2]}
    for i=1, height do
        newElement(ele,temp,text,subtype)
        for i2=1, (width) do
            newElement(ele,temp,text,subtype)
            temp[1] = temp[1] + 1
        end
        temp[1] = posArr[1]
        temp[2] = temp[2] + 1
    end
end

function newElement(ele,posArr,text,subtype,buttonArgs) --This is where the magic happens. You specify an element and it shows up
    if ele == nil then
        return;
    else
        ele = ele:lower()
    end
    
    if firstEle == false then
        position = posArr
    end
    
    if subtype == nil then
        subtype = 0
    end
    --Handles text, numbers, and some other text elements
    if ele == "caption" then --arguments {posArr,text}
        blob = {} --used when your element produces more than one object
        convertText(tostring(text),posArr)
        
        table.insert(InstructionArr, {"caption",posArr[1],posArr[2],tostring(text):lower()})
    end
    --Icons (i.e guns, tools, items)
    if ele == "icon" then --arguments {posArr,subtype}
        obj = Object.Spawn("Icon_UI", posArr[1], posArr[2]+1)
        obj.UID = this.UID
        table.insert(items,obj); 
        obj.SubType = subtype
        table.insert(InstructionArr, {"icon",posArr[1],posArr[2],subtype})
    end
    --Colored background
    if ele == "patch" then --arguments {posArr,subtype}
        obj = Object.Spawn("BackGround_Blue", posArr[1], posArr[2]+1)
        obj.UID = this.UID
        if subtype > 7 then
            subtype = 7 --so you cant go over the 7 colors
        end
        obj.SubType = subtype
        table.insert(container,obj); 
        
        table.insert(InstructionArr, {"patch",posArr[1],posArr[2]})
    end
    
    --UNFINISHED BELOW
    
    --Button that returns a true or false value that gets set as a property on the chosen object by the button
    --Button is underpowered atm :(
    if ele == "button" then --arguments posArr,subtype,{returnValueName,objectToGiveValue}
        obj = Object.Spawn("Button_UI", posArr[1], posArr[2]+1)
        obj.UID = this.UID
        if subtype > 7 then
            subtype = 7 --so you cant go over the 7 colors
        end
        obj.SubType = subtype
        table.insert(items,obj); 
        table.insert(interactives,obj); 
        obj.returnName = buttonArgs[1]
        obj.targetObject = buttonArgs[2]
    end
    --Portraits are meant to be the little pictures ontop a phone call when you get one during an event or campaign
    if ele == "portrait" then --arguments {posArr,subtype}
        obj = Object.Spawn("Portrait_UI", posArr[1], posArr[2])
        obj.UID = this.UID
        obj.SubType = subtype
    end
    --Portrait but smaller (think of incomming call)
    if ele == "portraiticon" then --arguments {posArr,subtype}
        obj = Object.Spawn("PortraitIcon_UI", posArr[1], posArr[2])
        obj.UID = this.UID
        obj.SubType = subtype
    end
end

function deleteUI() 
    for i,v in pairs(container) do
        v.Delete()
    end
    for a,b in pairs(items) do
        --get rid of blob if its a blob
        if items[a][1] ~= nil then
            for i,v in pairs(items[a]) do
                v.Delete()
            end
        end
        --get rid of it if its not a blob
        if items[a][1] == nil then
            it = items[a]
            it.Delete()
        end
    end
    
    container = {}
    items = {}
    
end

function getBackground() --WILL BE REPLACED WITH batchElement("Patch") REFRAIN FROM USING IT
    --if it exsists get rid of the old background
    for i,v in pairs(container) do
        v.Delete()
    end
    --
    for i=1, size[2] do
        obj = Object.Spawn("BackGround_Blue", position[1], position[2] + (i))
        table.insert(container,obj); 
        for i2=1, (size[1]-1) do
            obj = Object.Spawn("BackGround_Blue", position[1] + (i2), position[2] + (i))
            table.insert(container,obj); 
        end
    end
end

function editElementAtIndex(array,index,text,ele,posArr,subtype) --edits an element at x position of the items array. Keep in mind patch elements go into the container array not item array
    if array == nil then
        array = items
    end
    
    if array[index] == nil then
        return;
    end
    --get rid of blob if its a blob
    if array[index][1] ~= nil then
        for i,v in pairs(array[index]) do
            if posArr == undefined and i == 1 then
                posArr = {v.Pos.x,(v.Pos.y-1)}
            end
            if ele == undefined then
                ele = "Caption"
            end
            v.Delete()
        end
    end
    --get rid of it if its not a blob
    if array[index][1] == nil then
        it = array[index]
        if posArr == undefined then
            posArr = {it.Pos.x,it.Pos.y}
        end
        
        if subtype == nil then
            subtype = it.subtype
        end
        it.Delete()
    end
    
    table.remove(array,index)
    --make new element with updated settings
    newElement(ele,posArr,text,subtype)
end

function deleteElementAtIndex(array,index) --untested
    if array[index] == nil then
        return;
    end
    --get rid of blob if its a blob
    if array[index][1] ~= nil then
        for i,v in pairs(array[index]) do
            v.Delete()
        end
    end
    
    --get rid of it if its not a blob
    if array[index][1] == nil then
        it = array[index].Delete()
    end
end
local fr = true;
function Create()
    this.UID = math.random(0,99999999) -- used to destroy the old ui on a reload
    for i=1, math.random(1,100) do
        this.UID = tostring(this.UID) .. jumbleText[math.random(1,#jumbleText)]
    end

    this.InstructionString = "" --E = END, A = AND 
    this.RecoverOld = false --makes it so the UI is remade after a reload instead of deleted
    
    this.following = nil --makes it so you can have the UI follow an object (set it to an object)
    
    --function Bools (if true they exectute a function using the terms and get set to false after)
    this.newEle = false
    this.batchEle = false
    this.editAt = false
    this.del = false
    this.delAt = false
    this.relocate = false
    
    --you need to set these before executing a bool
    this.termText = nil
    this.ele = nil
    this.posX = nil
    this.posY = nil
    this.termSubType = nil
    this.termWidth = nil
    this.termHeight = nil
    this.targetArray = nil
    this.targetIndex = nil
    --("Caption",position,"haha yes!")
end

function Update() 
    if fr then
        firstRun()
        fr = false
    end
    --cross object functionality 
    if this.newEle == true then
        newElement(this.ele,{this.posX,this.posY},this.termText,this.termSubType)
        this.newEle = false
    end
    if this.batchEle == true then
        batchElement(this.termWidth,this.termHeight,this.ele,{this.posX,this.posY},this.termText,this.termSubType)
        this.batchEle = false
    end
    if this.editAt == true then
        editElementAtIndex(this.targetArray,this.targetIndex,this.termText)
        this.editAt = false
    end
    if this.del == true then
        deleteUI()
        this.del = false
    end
    if this.delAt == true then
        deleteElementAtIndex(this.targetArray,this.targetIndex)
        this.delAt = false
    end
    if this.relocate == true then
        RelocateUI({this.posX,this.posY})
        this.relocate = false
    end
    --
    if Time() > Ready then
        PerformUpdate( Delay )
        Ready = Time() + Delay
    end   
    if this.following ~= nil and this.following.Pos.x ~= nil then
        RelocateUI({this.following.Pos.y,this.following.Pos.y})
    end
    
    if prevSize[1]+prevSize[2] ~= size[1]+size[2] then
        getBackground()
        prevSize = size
    end
    
    
end

function PerformUpdate( elapsedTime )
    this.InstructionString = arrToStringReadable(InstructionArr)
end

function debug(t)
    Game.DebugOut(t)
end

function convertText(text,posArr) --this converts strings into a line of objects
    local acceptedNums = {"1","2","3","4","5","6","7","8","9","0"}
    local acceptedChars = {"a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z","?","!",".",",",":","/","-","+","=","%","#","$","<",">","^","*","&","'","(",")"," "}
    
    local subTypeConvertsNum = {1,2,3,4,5,6,7,8,9,10}
    local subTypeConvertsChar = {1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47}
    local pos = {posArr[1],posArr[2]}
    text = text:lower()
    for i = 1, #text do
        local c = text:sub(i,i)
        Distance = 0.8
        
        textPak = CompareArr(c,acceptedChars)
        if textPak ~= nil then
            obj = Object.Spawn("Letters_Capital_NoStroke", pos[1], pos[2] + 1)
            obj.UID = this.UID
            obj.SubType = subTypeConvertsChar[(textPak[2]-1)]
            pos[1] = pos[1] + Distance
            
            if textBackground then
                bg = Object.Spawn("BackGround_Blue",pos[1] - Distance, pos[2] + 1)
                bg.UID = this.UID
                table.insert(blob,bg)
            end
            
            if (textPak[2]) ~= 47 then
                table.insert(blob,obj)
                
            else
                obj.Delete()
            end
        end
        textPak = CompareArr(c,acceptedNums)
        if textPak ~= nil then
            obj = Object.Spawn("Numbers_NoStroke", pos[1], pos[2] + 1)
            obj.UID = this.UID
            obj.SubType = subTypeConvertsChar[(textPak[2]-1)]
            pos[1] = pos[1] + Distance
            
            if textBackground then
                bg = Object.Spawn("BackGround_Blue",pos[1] - Distance, pos[2] + 1)
                bg.UID = this.UID
                table.insert(blob,bg)
            end
            
            if (textPak[2]) ~= 11 then
                table.insert(blob,obj)
            else
                obj.Delete()
            end
        end
    end
    table.insert(items,blob);
end

function CompareArr(item,arr) --used to see if an array has an value matching item
    for i,v in pairs(arr) do
        if item == v then
            return {v,i}
        end
    end
    return nil
end

function RelocateUI(posArr) --changes the position of the entire UI spawned by the tester object
    --position
    for i,v in pairs(container) do
        if v ~= nil then
            v.Pos.x = posArr[1] + math.abs(position[1] - v.Pos.x)
            v.Pos.y = posArr[2] + math.abs(position[2] - v.Pos.y)
        end
    end
    
    for i,v in pairs(items) do
        if v[1] ~= nil then
            for a,b in pairs(v) do
                if b ~= nil then
                    b.Pos.x = (posArr[1] + math.abs(position[1] - b.Pos.x))
                    b.Pos.y = (posArr[2] + math.abs(position[2] - b.Pos.y))
                end
            end
        else
            v.Pos.x = (posArr[1] + math.abs(position[1] - v.Pos.x))
            v.Pos.y = (posArr[2] + math.abs(position[2] - v.Pos.y))
        end
    end
    position = posArr
end