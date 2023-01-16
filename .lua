local module = {}
module.__index = module

--[[
	attempts: adds 1 for each attempt (FAIL)
	closeAfterX: closes UI after X amount of attempts, put 0 if you dont want it. (FAILS)
]]

module.SETTINGS = {
	attempts = 0,
	closeAfterX = 0	
}

function module.window(config: {
	Properties: {
		body: Color3,
		key: { textcolor: Color3, backgroundcolor: Color3, outlinecolor: Color3 },
		button: { textcolor: Color3, backgroundcolor: Color3 }
	}?
	})
	
	local Players = game:GetService("Players")
	
	local Player = Players.LocalPlayer
	local PlayerGui = Player:WaitForChild("PlayerGui")
	
	-- GUI - ELEMENTs
	local Gui = Instance.new("ScreenGui", PlayerGui)
	local body = Instance.new("Frame", Gui)
	
	local key = Instance.new("TextBox", body)
	local trigger = Instance.new("TextButton", body)
	
	Gui.Name = "wl"
	
	body.Name = "body"
	key.Name = "key"
	trigger.Name = "callback"
	
	body.AnchorPoint = Vector2.new(0.5, 0.5)
	body.Position = UDim2.fromScale(0.5, 0.5)
	body.Size = UDim2.fromOffset(400, 105)
	
	body.BorderSizePixel = 0
	
	key.Size = UDim2.fromOffset(378, 35)
	key.Position = UDim2.fromScale(0.027, 0.146)
	
	key.PlaceholderText = "Enter key"
	key.BorderSizePixel = 0
	
	trigger.Size = UDim2.fromOffset(378, 41)
	trigger.Position = UDim2.fromScale(0.027, 0.539)
	
	trigger.BorderSizePixel = 0
	trigger.FontSize = Enum.FontSize.Size18
	
	body.BackgroundColor3 = config.Properties and config.Properties.body or Color3.fromRGB(25, 25, 25)
	
	key.TextColor3 = config.Properties and config.Properties.key.textcolor or Color3.fromRGB(178, 178, 178)
	key.BackgroundColor3 = config.Properties and config.Properties.key.backgroundcolor or Color3.fromRGB(20, 20, 20)
	key.BorderColor3 = config.Properties and config.Properties.key.outlinecolor or Color3.fromRGB(15, 15, 15)
	
	trigger.TextColor3 = config.Properties and config.Properties.button.textcolor or Color3.fromRGB(229, 229, 229)
	trigger.BackgroundColor3 = config.Properties and config.Properties.button.backgroundcolor or Color3.fromRGB(35, 35, 35)
	
	local TweenService = game:GetService("TweenService")
	local self = setmetatable({}, module)
	
	
	self.properties = config.Properties
	function self:TweenState(obj, state)
		if obj:IsA("TextBox") then
			TweenService:Create(obj, TweenInfo.new(0.5, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, false, true, 0
				), {BorderColor3 = self.states[state]}):Play()
		elseif obj:IsA("TextButton") then
			TweenService:Create(obj, TweenInfo.new(0.5, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, false, true, 0
				), {BorderColor3 = self.states[state]}):Play()
		end
	end
	self.states = {
		successfull = Color3.fromRGB(33, 255, 40),
		unsuccessfull = Color3.fromRGB(250, 40, 100),
		pressed = Color3.fromRGB(82, 134, 255)
	}
	
	function self:LoadUrl(url)
		return loadstring(game:HttpGet(url))()
	end
	
	return self
	
end

local gui = script.ScreenGui
local body = gui.body

local tbox = body.key
local trigger = body.callback

function module:Whitelist(keys: {}, callback: (user: Player, IsWhitelisted: boolean, IsKeyValid: boolean, HasSubscription: boolean)->())
	local user = game:GetService("Players").LocalPlayer
	trigger.MouseButton1Click:Connect(function()
		self:TweenState(trigger, "pressed")
		if module.SETTINGS.attempts >= module.SETTINGS.closeAfterX then return gui:Destroy(); end
		module.SETTINGS.attempts += 1
		for _, v: {Id: number, key: string, Subscription: boolean} in next, keys do
			if user.UserId ~= v.Id then
				continue else
				local tbox_key = string.lower(tbox.Text)
				local key = string.lower(v.key)
				if tbox_key ~= key then
					continue else
					if not v.Subscription then
						self:TweenState(tbox, "unsuccessfull")
						continue;
					else
						self:TweenState(key, "successfull");
						callback(user, user.UserId == v.Id, tbox_key == key, v.Subscription)
						gui:Destroy()
					end
				end
			end
		end
	end)
	self.logged = {
		user = user,
		keys = keys
	}
end

function module:Retry()
	if not self.logged then return warn("Whitelist hasn't runned!") end
	return module:Whitelist(self.logged.keys)
end

return module
