--DarkRP Experience Augmentation Module

if not meme then meme = {
		halos = {
			players = false,
			weapons = false,
			printers = false,
			weapons_m9k = false,
			shipments = false,
		},
		entities = {
			players = "player",
			weapons = "spawned_weapon",
			weapons_m9k = "m9k_*",
			printers = "*printer*",
			shipments = "spawned_shipment",
		},
		colours = {
			players = Color(0, 0, 255), -- blue
			weapons = Color(255, 255, 0), -- yellow
			weapons_m9k = Color(255, 255, 0), -- yellow
			printers = Color(0, 255, 0), -- green
			shipments = Color(255, 0, 0), -- red	
		}
	}
end

local frame = vgui.Create("DFrame")
frame:SetPos(64, 64)
frame:SetSize(256, 512)
frame:SetTitle("Halo Selection")
frame:MakePopup()
frame.OnRemove = function()
hook.Remove("Think", "test123")
hook.Remove("CalcView", "test123")
end

function hud()
	local ply
	local camangle, camposition = LocalPlayer():EyeAngles(), LocalPlayer():EyePos()
	hook.Add("CalcView", "test123", function()
		return {
			angles = camangle,
			origin = camposition, 
			w = ScrW(),
			h = ScrH() 
		}
	end)
	hook.Add("Think", "test123", function()
		if input.IsKeyDown(KEY_W) then camposition = camposition + (camangle:Forward() * (input.IsKeyDown(KEY_LSHIFT) and 64 or 32)) end
		if input.IsKeyDown(KEY_A) then camposition = camposition - (camangle:Right() * 32) end
		if input.IsKeyDown(KEY_S) then camposition = camposition - (camangle:Forward() * 32) end
		if input.IsKeyDown(KEY_D) then camposition = camposition + (camangle:Right() * 32) end
		if input.IsKeyDown(KEY_UP) then camangle:RotateAroundAxis(camangle:Right(), 8)	end
		if input.IsKeyDown(KEY_LEFT) then camangle:RotateAroundAxis(Vector(0,0,1), 8) end
		if input.IsKeyDown(KEY_DOWN) then camangle:RotateAroundAxis(camangle:Right(), -8) end
		if input.IsKeyDown(KEY_RIGHT) then camangle:RotateAroundAxis(Vector(0,0,1), -8) end
	end)
end
hud()

local y = 28
for button in pairs(meme.halos) do
	frame[button] = vgui.Create("DButton", frame)
	frame[button]:SetSize(128, 32) 
	frame[button]:SetPos(4, y)
	frame[button]:SetText("Highlight " .. button)
	frame[button].PaintOver = function()
		draw.RoundedBox(2, 0, 0, 128, 32, Color(meme.halos[button] and 0 or 255, meme.halos[button] and 255 or 0, 0, 50))
	end
	frame[button].DoClick = function()
		meme.halos[button] = not meme.halos[button]
		
		if meme.halos[button] then
			hook.Add("PreDrawHalos", "meme.halo." .. button, function()
				halo.Add(ents.FindByClass(meme.entities[button]), meme.colours[button], 5, 5, 1, true, true) 
			end)
		else
			hook.Remove("PreDrawHalos", "meme.halo." .. button)
		end
	end
	y = y + 36
	frame:SetSize(136, y + 0)
end


