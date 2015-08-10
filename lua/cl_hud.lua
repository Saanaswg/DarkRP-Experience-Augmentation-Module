--DarkRP Experience Augmentation Module

augment = {
	Add = function(self, cmd, func)
		self.Command[cmd] = func
		if not self.State[cmd] then self.State[cmd] = false end
	end, 
	Command = {},
	State = (augment and augment.State or {})
} 

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
				if entities[i]:IsPlayer() and entities[i]:GetFriendStatus() == "friend" and entities[i] ~= LocalPlayer() then
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
				if v:IsPlayer() then table.insert(players, v) end
			end
			
			halo.Add(players, Color(0, 255, 255), .5, .5, 1, true, true) 
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
				elseif entities[i].GetWeaponClass and entities[i]:GetWeaponClass():Left(7) == "weapon_" then
					local pos = entities[i]:GetPos():ToScreen()
					surface.DrawOutlinedRect(pos.x, pos.y, 8, 8)
					local name = entities[i]:GetWeaponClass():gsub("weapon_", ""):gsub("_", " ")
					draw.DrawText(name:SetChar(1, name:Left(1):upper()), "DebugFixedSmall", pos.x - 2, pos.y + 6, Color(200, 200, 0, 200))	
				elseif entities[i]:GetClass():Left(7) == "weapon_"  and not entities[i].Owner then
					local pos = entities[i]:GetPos():ToScreen()
					surface.DrawOutlinedRect(pos.x, pos.y, 8, 8)
					local name = entities[i]:GetClass():gsub("weapon_", ""):gsub("_", " ")
					draw.DrawText(name:SetChar(1, name:Left(1):upper()), "DebugFixedSmall", pos.x - 2, pos.y + 6, Color(200, 200, 0, 200))	
				end
			end			
		end)
	else
		hook.Remove("HUDPaint", "augment.Weapons")
	end
end)