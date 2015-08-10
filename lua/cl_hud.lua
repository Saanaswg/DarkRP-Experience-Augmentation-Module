--DarkRP Experience Augmentation Module

local fn = function() end

augment = {
	Add = function(self, cmd, func)
		self.Command[cmd] = func
		if not self.State[cmd] then self.State[cmd] = false end
	end, 
	Command = {},
	State = (augment and augment.State or {}),
	Scoreboard = {
		Open = function(self)
			local ScrW, ScrH, scrollbar, tiles, info = ScrW(), ScrH(), nil, 0
			local w, h, scroll = ScrW / 2.4, ScrH / 1.2, function(self, dlta)	
				return scrollbar:AddScroll( dlta * -2 )
			end
			
			self.Frame = vgui.Create("DPanel")
			self.Frame:SetSize(w, h)
			self.Frame:MakePopup()
			self.Frame:Center()
			self.Frame:SetKeyboardInputEnabled(false)
			self.Frame.OnRemove = function()
				info:Remove()
			end
			self.Frame.OnMouseWheeled = scroll
			
			info = vgui.Create("DPanel")
			local x, y = self.Frame:GetPos()
			info:SetPos(x - 16, y - 32)
			info:SetSize(w + 32, 64)
			info.Paint = function() 
				draw.DrawText("DarkRP Experience Augmentation Module", "DermaLarge", 0, 0, Color(255, 255, 255))
				draw.DrawText(GetHostName(), "Trebuchet24", 24, 32, Color(255, 255, 255))
				draw.DrawText("coded by Saana", "CenterPrintText", 506, 12, Color(200, 200, 200, 150))
				draw.DrawText(#player.GetAll() .. "/" .. game.MaxPlayers(), "DermaLarge", w + 8, 2, Color(255, 255, 255), TEXT_ALIGN_RIGHT)
				draw.DrawText("PING : " .. LocalPlayer():Ping(), "DermaDefaultBold", w + 6, 38, Color(255, 255, 255), TEXT_ALIGN_RIGHT)
			end
			
			local canvasframe = vgui.Create("DPanel", self.Frame)
			canvasframe:SetSize(w - 128, h - 64)
			canvasframe:SetPos(64, 32)	
			canvasframe.Paint = fn
			
			local canvas = vgui.Create("DPanel", canvasframe)
			canvas:SetSize(w - 128, (tiles * 44) - 4)
			canvas.Paint = fn
			canvas.OnMouseWheeled = scroll
			
			self.Frame.Paint = function(frame)
				draw.RoundedBox(8, 0, 0, w, h, Color(0, 0, 0, 80))
				
				for index in pairs(team.GetAllTeams()) do
					for k, ply in pairs(team.GetPlayers(index)) do
						if not scrollbar then
							local tile = vgui.Create("DButton", canvas)
							tile:SetPos(0, tiles * 44)
							tile:SetSize(w - 128, 40)
							tile:SetText("")
							tile.OnMouseWheeled = scroll
							tile.Paint = function()
								draw.RoundedBox(8, 0, 0, w - 128, 40, ColorAlpha(team.GetColor(index), 200))

								draw.DrawText(ply:Nick(), "Trebuchet24", 6, 0, Color(255, 255, 255))
								
								surface.SetTextPos(12, 6)
								
								surface.SetTextColor(255, 255, 255, 0)
								surface.SetFont("Trebuchet24")
								surface.DrawText(ply:Nick())
								
								surface.SetTextColor(200, 200, 200, 150)
								surface.SetFont("CenterPrintText")
								surface.DrawText(ply:GetUserGroup() == "user" and "" or ply:GetUserGroup():upper())
								
								draw.DrawText(team.GetName(index), "CenterPrintText", 7, 22, Color(255, 255, 255))
								
								draw.DrawText("HP : " .. ply:Health(), "DermaDefaultBold", 300, 11, Color(255, 255, 255))
								
								local weapons, hasweapons = ply:GetWeapons()
								local y, col, id = 0, 1, 0
								
								for k, v in pairs(weapons) do
									if v:GetClass():Left(4) == "m9k_" then
										id = id + 1
									
										hasweapons = true
										local name = v:GetClass():gsub("m9k_", ""):gsub("_", " ")
										draw.DrawText(name:SetChar(1, name:Left(1):upper()), "DermaDefault", 420 + (64 * col), y + 5, Color(255, 255, 255))	
										
										y = ((id - 1) % 2 == 0 and 1 or 0) * 15
										col = col + (id - 1) % 2
										
									end
								end
								
								if hasweapons then 
									draw.DrawText("Weapons : ", "DermaDefaultBold", 410, 11, Color(255, 255, 255)) 
								end
							end
							
							tiles = tiles + 1
							canvas:SetSize(w, tiles * 44)
						end
					end
				end
				
				if not scrollbar then								
					scrollbar = vgui.Create("DVScrollBar", frame) 
					scrollbar:SetSize(24, h - 20) 
					scrollbar:SetPos(64 + (w - 124), 8)
					scrollbar:SetUp(h - 64, tiles * 44)
					
					local temp = scrollbar:GetChildren()
					temp[1].Paint = fn
					temp[2].Paint = fn
					temp[3]:GetParent().Paint = fn
					temp[3].Paint = function(self)
						local w, h = self:GetSize()
						draw.RoundedBox(4, 0, 0, w, h, Color(255, 255, 255, 80))
					end
				else
					canvas:SetPos(0, scrollbar:GetOffset())
				end
			end
		end,
		
		Close = function(self)
			self.Frame:Remove()
		end,
	}
} 

hook.Add("PlayerBindPress", "augment.Scoreboard", function(ply, bind, pressed)
	if bind == "+showscores" and pressed then
		augment.Scoreboard:Open()
		return true
	elseif bind == "+showscores" and not pressed then
		augment.Scoreboard:Close()
		return true	
	end
end)

local frame = vgui.Create("DFrame")
frame:SetPos(64, 64)
frame:SetTitle("Augments")
frame:SetVisible(false)
frame.OnRemove = function()
	hook.Remove("CalcView", "augment.FreeCam")
	hook.Remove("Think", "augment.FreeCam")
end

timer.Simple(0.05, function()
	local y = 28
	for cmd, func in pairs(augment.Command) do
		local button = vgui.Create("DButton", frame)
		button:SetSize(128, 32) 
		button:SetPos(4, y)
		button:SetText(cmd)
		button.PaintOver = function()
			draw.RoundedBox(2, 0, 0, 128, 32, Color(augment.State[cmd] and 0 or 255, augment.State[cmd] and 255 or 0, 0, 50))
		end
		button.DoClick = func

		y = y + 36
		frame:SetSize(136, y)
	end
	frame:SetVisible(true)
	frame:MakePopup()
	
	-- Clientside flight is enabled aslong as the player is in the augment menu
	local camangle, camposition = LocalPlayer():EyeAngles(), LocalPlayer():EyePos()
	hook.Add("CalcView", "augment.FreeCam", function()
		return {
			angles = camangle,
			origin = camposition, 
			w = ScrW(),
			h = ScrH() 
		}
	end)
	hook.Add("Think", "augment.FreeCam", function()
		if input.IsKeyDown(KEY_W) then camposition = camposition + (camangle:Forward() * (input.IsKeyDown(KEY_LSHIFT) and 64 or 32)) end
		if input.IsKeyDown(KEY_A) then camposition = camposition - (camangle:Right() * 32) end
		if input.IsKeyDown(KEY_S) then camposition = camposition - (camangle:Forward() * 32) end
		if input.IsKeyDown(KEY_D) then camposition = camposition + (camangle:Right() * 32) end
		if input.IsKeyDown(KEY_UP) then camangle:RotateAroundAxis(camangle:Right(), 8)	end
		if input.IsKeyDown(KEY_LEFT) then camangle:RotateAroundAxis(Vector(0,0,1), 8) end
		if input.IsKeyDown(KEY_DOWN) then camangle:RotateAroundAxis(camangle:Right(), -8) end
		if input.IsKeyDown(KEY_RIGHT) then camangle:RotateAroundAxis(Vector(0,0,1), -8) end
	end)
end)

augment:Add("Players", function() 
	augment.State.Players = not augment.State.Players 
	
	if augment.State.Players then
		hook.Add("HUDPaint", "augment.Players", function()
			local players = player.GetAll()
			for i=1, #players do 
				local pos = players[i]:GetPos():ToScreen()
				if players[i]:GetFriendStatus() == "friend" and players[i] ~= LocalPlayer() then
					surface.SetDrawColor(255, 50, 80, 150)
					surface.DrawOutlinedRect(pos.x, pos.y, 8, 8)
					draw.DrawText(players[i]:GetName(), "DebugFixedSmall", pos.x - 2, pos.y + 6, Color(255, 50, 80, 200))
				else
					surface.SetDrawColor(0, 255, 255, 75)
					surface.DrawOutlinedRect(pos.x, pos.y, 8, 8)			
				end
			end			
		
			local entities = ents.FindInSphere(LocalPlayer():GetPos(), 1024)
			surface.SetDrawColor(0, 255, 255, 75)
			for i=1, #entities do 	
				if entities[i]:IsPlayer() and entities[i]:GetFriendStatus() ~= "friend" and entities[i] ~= LocalPlayer() then
					local pos = entities[i]:GetPos():ToScreen()
					surface.DrawOutlinedRect(pos.x, pos.y, 8, 8)
					draw.DrawText(entities[i]:GetName(), "DebugFixedSmall", pos.x - 2, pos.y + 6, Color(0, 255, 255, 200))
					draw.DrawText(entities[i]:GetUserGroup(), "DebugFixedSmall", pos.x - 2, pos.y + 18, Color(0, 255, 255, 50))
				end
			end
		end)
		
		hook.Add("PreDrawHalos", "augment.Players", function()
			local players = {}
			for k, v in pairs(ents.FindInSphere(LocalPlayer():GetPos(), 1024)) do
				if v:IsPlayer() and v:GetFriendStatus() ~= "friend" then table.insert(players, v) end
			end
			halo.Add(players, Color(0, 255, 255), .5, .5, 1, true, true) 
			
			local friends = {}
			for k, v in pairs(ents.FindInSphere(LocalPlayer():GetPos(), 1024)) do
				if v:IsPlayer() and v:GetFriendStatus() == "friend" then table.insert(friends, v) end
			end
			halo.Add(friends, Color(255, 50, 80), .5, .5, 1, true, true) 
		end)
	else
		hook.Remove("HUDPaint", "augment.Players")
		hook.Remove("PreDrawHalos", "augment.Players")
	end
end)

augment:Add("Printers", function() 
	augment.State.Printers = not augment.State.Printers 
	
	if augment.State.Printers then
		hook.Add("HUDPaint", "augment.Printers", function()
			local entities = ents.FindByClass("*printer*")
			surface.SetDrawColor(0, 255, 0, 150)
			for i=1, #entities do 
				local pos = entities[i]:GetPos():ToScreen()
				surface.DrawOutlinedRect(pos.x, pos.y, 8, 8)
				draw.DrawText("Money Printer", "DebugFixedSmall", pos.x - 2, pos.y + 6, Color(0, 255, 0, 200))
			end			
		end)
	else
		hook.Remove("HUDPaint", "augment.Printers")
	end
end)

augment:Add("Shipments", function() 
	augment.State.Shipments = not augment.State.Shipments 
	
	if augment.State.Shipments then
		hook.Add("HUDPaint", "augment.Shipments", function()
			local entities = ents.FindByClass("spawned_shipment")
			surface.SetDrawColor(255, 0, 0, 150)
			for i=1, #entities do 
				local pos = entities[i]:GetPos():ToScreen()
				surface.DrawOutlinedRect(pos.x, pos.y, 8, 8)
				draw.DrawText("Shipment", "DebugFixedSmall", pos.x - 2, pos.y + 6, Color(255, 0, 0, 200))
				draw.DrawText(CustomShipments[entities[i]:Getcontents() or ""].name, "DebugFixedSmall", pos.x - 2, pos.y + 18, Color(255, 0, 0, 50))
			end			
		end)
	else
		hook.Remove("HUDPaint", "augment.Shipments")
	end
end)

augment:Add("Drugs", function() 
	augment.State.Drugs = not augment.State.Drugs 
	
	if augment.State.Drugs then
		hook.Add("HUDPaint", "augment.Drugs", function()
			local entities = ents.GetAll()
			surface.SetDrawColor(200, 0, 200, 150)
			for i=1, #entities do 
				if entities[i].GetWeaponClass and entities[i]:GetWeaponClass():Left(6) == "durgz_" then
					local pos = entities[i]:GetPos():ToScreen()
					surface.DrawOutlinedRect(pos.x, pos.y, 8, 8)
					local name = entities[i]:GetWeaponClass():gsub("durgz_", "")
					draw.DrawText(name:SetChar(1, name:Left(1):upper()), "DebugFixedSmall", pos.x - 2, pos.y + 6, Color(200, 0, 200, 200))
				elseif entities[i]:GetClass():Left(6) == "durgz_" then
					local pos = entities[i]:GetPos():ToScreen()
					surface.DrawOutlinedRect(pos.x, pos.y, 8, 8)
					local name = entities[i]:GetClass():gsub("durgz_", "")
					draw.DrawText(name:SetChar(1, name:Left(1):upper()), "DebugFixedSmall", pos.x - 2, pos.y + 6, Color(200, 0, 200, 200))				
				end
			end			
		end)
	else
		hook.Remove("HUDPaint", "augment.Drugs")
	end
end)

augment:Add("Weapons", function() 
	augment.State.Weapons = not augment.State.Weapons 
	
	if augment.State.Weapons then
		hook.Add("HUDPaint", "augment.Weapons", function()
			local entities = ents.GetAll()
			surface.SetDrawColor(200, 200, 0, 150)
			for i=1, #entities do 
				if entities[i].GetWeaponClass and entities[i]:GetWeaponClass():Left(4) == "m9k_" then
					local pos = entities[i]:GetPos():ToScreen()
					surface.DrawOutlinedRect(pos.x, pos.y, 8, 8)
					local name = entities[i]:GetWeaponClass():gsub("m9k_", ""):gsub("_", " ")
					draw.DrawText(name:SetChar(1, name:Left(1):upper()), "DebugFixedSmall", pos.x - 2, pos.y + 6, Color(200, 200, 0, 200))
				elseif entities[i]:GetClass():Left(4) == "m9k_" and not entities[i].Owner then
					local pos = entities[i]:GetPos():ToScreen()
					surface.DrawOutlinedRect(pos.x, pos.y, 8, 8)
					local name = entities[i]:GetClass():gsub("m9k_", ""):gsub("_", " ")
					draw.DrawText(name:SetChar(1, name:Left(1):upper()), "DebugFixedSmall", pos.x - 2, pos.y + 6, Color(200, 200, 0, 200))
				end
			end			
		end)
	else
		hook.Remove("HUDPaint", "augment.Weapons")
	end
end)

-- Removing regular errors and effects that ruin gameplay
local mt = FindMetaTable('Entity')
mt.ManipulateBoneAngles = fn
mt.ManipulateBoneScale = fn
mt.ManipulateBonePosition = fn

-- notification on when thief is available
-- Damage markers
-- inherit drug abilities via usermsg calls