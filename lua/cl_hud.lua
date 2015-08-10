--DarkRP Experience Augmentation Module
--Initial Release v1.0

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


