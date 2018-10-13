local Time       = Game.Time;
local Delay      = 1; -- game seconds
local Ready      = Time();

local UIDelay      = 0.1; -- game seconds
local UIReady      = Time();
local UIcur = 0
local following

function Create()
    this.fr = false;
end

function Update() 
    if Time() > UIReady then
        if UIcur == 0 then
            UI = Object.Spawn("UIStarter",0,0)
            ens = this.GetNearbyObjects("Workman",9999999999)
            for i,v in pairs(ens) do
                following = i
            end
        end
        if UIcur == 1 then
            UI.posX = 50
            UI.posY = 50

            UI.ele = "Caption"
            UI.termText = "Haha Yes!"
            UI.newEle = true
        end
        if UIcur == 2 then
            UI.ele = "Patch"
            UI.termWidth = 5
            UI.termHeight = 2
            UI.termSubType = 6
            UI.batchEle = true
        end
        if UIcur > 2 then
            UI.posX = following.Pos.x + 1
            UI.posY = following.Pos.y 
            UI.relocate = true
            
            UI.editAt = true
            UI.targetIndex = 1
            UI.termText = math.floor(following.Pos.x) .. "," .. math.floor(following.Pos.y) 
        end
        UIcur = UIcur + 1
        PerformUpdate( UIDelay )
        UIReady = Time() + UIDelay
        
    end  
    
    if Time() > Ready then
        PerformUpdate( Delay )
        Ready = Time() + Delay
    end   
    
    
end

function PerformUpdate( elapsedTime )
end

function debug(t)
    Game.DebugOut(t)
end
