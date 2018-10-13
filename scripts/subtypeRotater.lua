local Time       = Game.Time;
local Delay      = 1; -- game seconds
local Ready      = Time() + Delay



function Create()
    
end

function Update()
    
    if Time() > Ready then
        PerformUpdate( Delay )
        Ready = Time() + Delay
    end
    
end

function PerformUpdate( elapsedTime )
    this.SubType = this.SubType + 1
end

function debug(t)
    Game.DebugOut(t)
end

