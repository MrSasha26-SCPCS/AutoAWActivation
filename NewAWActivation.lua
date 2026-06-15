local GameObject = CS.UnityEngine.GameObject
local Vector3 = CS.UnityEngine.Vector3

local function FindInactiveObj(name)
    local objs = CS.UnityEngine.Resources.FindObjectsOfTypeAll(typeof(GameObject))
    for i = 0, objs.Length - 1 do
        local obj = objs[i]
        if obj.name == name then
            return obj
        end
    end
    return nil
end

local time_const = 120

---@class NewAWActivation:CS.Akequ.Base.Room
NewAWActivation = {}

NewAWActivation.time = time_const
NewAWActivation.ACES = nil
NewAWActivation.AW = nil
NewAWActivation.isLCZBlocked = false

function NewAWActivation:Init()
    if self.main.netEvent.isServer then
        self.ACES = GameObject.FindObjectOfType(typeof(CS.ACES))
        self.AW = GameObject.FindObjectOfType(typeof(CS.AlphaWarhead))
        CS.HookManager.Add("onLCZDecontBegun", function()
            self.main:Invoke(function()
                self.ACES:AddPhraseToQueue("By order of O5 command starting activation Alpha warhead detonation", false, false, false, false)
                self.main:Invoke(function()
                    self.isLCZBlocked = true
                    self:TryActivate()
                end, 6.5)
            end, 10)
        end)
    end
end

function NewAWActivation:Update()
    if self.main.netEvent.isServer and self.isLCZBlocked then
        if self.time > 0 then
            self.time = self.time - CS.UnityEngine.Time.deltaTime
        else
            self.time = time_const
            self:TryActivate()
        end
    end
end

function NewAWActivation:TryActivate()
    if self.isLCZBlocked then  
        if self.AW:GetStatus() == CS.AlphaWarhead.AlphaWarheadStatus.ENABLED then
            CS.HookManager.Run("onAWPanelPress")
        elseif self.AW:GetStatus() ~= CS.AlphaWarhead.AlphaWarheadStatus.ACTIVE and 
        self.AW:GetStatus() ~= CS.AlphaWarhead.AlphaWarheadStatus.DETONATED then 
            self.ACES:AddPhraseToQueue("Alpha warhead detonation failure . Next attempt in 2 minutes", false, false, false, false)
        end
    end
end

return NewAWActivation