Battered = CreateFrame("frame",nil,UIParent)
Battered.t = CreateFrame("GameTooltip", "Battered_T", UIParent, "GameTooltipTemplate")
Battered_Settings = {
	["dodge"] = 0,
}

Battered:RegisterEvent("CHAT_MSG_COMBAT_SELF_MISSES")
Battered:RegisterEvent("CHAT_MSG_SPELL_DAMAGESHIELDS_ON_SELF")
Battered:RegisterEvent("ADDON_LOADED")
Battered:SetScript("OnEvent", function()
	if event == "ADDON_LOADED" and arg1 == "Battered" then
		DEFAULT_CHAT_FRAME:AddMessage("|cff0066ff Battered system loaded, use /Battered ftw!|r")
		Battered:UnregisterEvent("ADDON_LOADED")
	elseif event == "CHAT_MSG_COMBAT_SELF_MISSES" then
		if string.find(arg1,"dodge") then
			Battered_Settings["dodge"] = GetTime()
		end		
	elseif event == "CHAT_MSG_SPELL_DAMAGESHIELDS_ON_SELF" then
		if string.find(arg1,"dodge") then
			Battered_Settings["dodge"] = GetTime()
		end
	end
end)

function Battered:GetBuff(name,buff,stacks)
	local a=1
	while UnitBuff(name,a) do
		local _, s = UnitBuff(name,a)
		Battered_T:SetOwner(WorldFrame, "ANCHOR_NONE")
		Battered_T:ClearLines()
		Battered_T:SetUnitBuff(name,a)
		local text = Battered_TTextLeft1:GetText()
		if text == buff then 
			if stacks == 1 then
				return s
			else
				return true 
			end
		end
		a=a+1
	end
	a=1
	while UnitDebuff(name,a) do
		local _, s = UnitDebuff(name,a)
		Battered_T:SetOwner(WorldFrame, "ANCHOR_NONE")
		Battered_T:ClearLines()
		Battered_T:SetUnitDebuff(name,a)
		local text = Battered_TTextLeft1:GetText()
		if text == buff then 
			if stacks == 1 then
				return s
			else
				return true 
			end
		end
		a=a+1
	end	
	
	return false
end

function Battered:GetActionSlot(a)
	for i=1, 100 do
		Battered_T:SetOwner(UIParent, "ANCHOR_NONE")
		Battered_T:ClearLines()
		Battered_T:SetAction(i)
		local ab = Battered_TTextLeft1:GetText()
		Battered_T:Hide()
		if ab == a then
			return i;
		end
	end
	return 2;
end

function Battered:OnCooldown(Spell)
	if Spell then
		local spellID = 1
		local spell = GetSpellName(spellID, "BOOKTYPE_SPELL")
		while (spell) do	
			if Spell == spell then
				if GetSpellCooldown(spellID, "BOOKTYPE_SPELL") == 0 then
					return false
				else
					return true
				end
			end
		spellID = spellID+1
		spell = GetSpellName(spellID, "BOOKTYPE_SPELL")
		end
	end
end

function Battered:GetSpell(name)
	local spellID = 1
	local spell = GetSpellName(spellID, BOOKTYPE_SPELL)
	while (spell) do
		if spell == name then
			return true
		end
		spellID = spellID + 1
		spell = GetSpellName(spellID, BOOKTYPE_SPELL)
	end
	return false
end		

function Battered:AutoAttack()
	for i=1,120 do 
		if IsCurrentAction(i) then 
			return 
		end 
	end 
	CastSpellByName("Attack")
	return
end


function Battered:Original()
	local c = CastSpellByName
	if UnitClass("player") == "Warrior" then 
	
		Battered:AutoAttack()
		
		--Prot Stance
		--Stay in Prot, Sunder to 5
		local _,_,isActive = GetShapeshiftFormInfo(2)
		if isActive then 
			if Battered:GetSpell("Bloodrage") and UnitAffectingCombat("player") and UnitMana("player") < 40 and not Battered:OnCooldown("Bloodrage") then 
				c("Bloodrage") 
				return
			end
			if Battered:GetSpell("Revenge") and not Battered:OnCooldown("Revenge") and UnitMana("player") > 4 then
				c("Revenge")
			end
			if Battered:GetSpell("Bloodthirst") and not Battered:OnCooldown("Bloodthirst") and UnitMana("player") > 29 then
				c("Bloodthirst")
				return
			end

			if not Battered:GetBuff("target","Sunder Armor") then
				c("Sunder Armor")
			else
				if Battered:GetBuff("target","Sunder Armor",1) < 5 then
					c("Sunder Armor")
				end
			end

			if Battered:GetSpell("Heroic Strike") and UnitMana("player") > 30 then
				c("Heroic Strike")
			end
			return
		end

		--Execute After Prot Stance so rage is not blown on a target before another, switch stance to execute or call manually
		if (UnitHealth("target") / UnitHealthMax("target")) <= 0.2 and UnitMana("player") > 9 then 
			c("Execute") 
			return
		end

		--If rage under 30 and dodged attack, swap and over power
		if GetTime()-Battered_Settings["dodge"] < 5 then
			if Battered:GetSpell("Overpower") and not Battered:OnCooldown("Overpower") and UnitMana("player") < 30 and UnitMana("player") > 4 then
				c("Battle Stance");
				c("Overpower")
			end
		end
		
		c("Berserker Stance")
		
		if Battered:GetSpell("Battle Shout") and not Battered:GetBuff("player","Battle Shout") then 
			if UnitExists("target") and (UnitHealth("target") / UnitHealthMax("target")) > 0.2 and UnitMana("player") > 9 then
				c("Battle Shout") 
				return
			elseif not UnitExists("target") and UnitMana("player") > 9 then
				c("Battle Shout") 
				return
			end
		end
		
		if Battered:GetSpell("Bloodrage") and UnitAffectingCombat("player") and UnitMana("player") < 40 and not Battered:OnCooldown("Bloodrage") then 
			c("Bloodrage") 
			return
		end
		
		if Battered:GetSpell("Bloodthirst") and not Battered:OnCooldown("Bloodthirst") and UnitMana("player") > 29 then
			c("Bloodthirst")
			return
		elseif Battered:GetSpell("Whirlwind") and not Battered:OnCooldown("Whirlwind") and UnitMana("player") > 29 then 
			if CheckInteractDistance("target", 1 ) ~= nil then 
				c("Whirlwind") 
				return
			end 
		elseif Battered:GetSpell("Heroic Strike") and UnitMana("player") > 29 then
				c("Heroic Strike")
		end			
	
	end
end


function Battered:BatteredCleave()
	local c = CastSpellByName
	if UnitClass("player") == "Warrior" then 
	
		Battered:AutoAttack()
			
		if Battered:GetSpell("Battle Shout") and not Battered:GetBuff("player","Battle Shout") then 
			if UnitExists("target") and (UnitHealth("target") / UnitHealthMax("target")) > 0.2 and UnitMana("player") > 9 then
				c("Battle Shout") 
				return
			elseif not UnitExists("target") and UnitMana("player") > 9 then
				c("Battle Shout") 
				return
			end
		end
		
		if Battered:GetSpell("Bloodrage") and UnitAffectingCombat("player") and UnitMana("player") < 40 and not Battered:OnCooldown("Bloodrage") then 
			c("Bloodrage") 
			return
		end
		
		if Battered:GetSpell("Whirlwind") and not Battered:OnCooldown("Whirlwind") and UnitMana("player") > 24 then 
			if CheckInteractDistance("target", 1 ) ~= nil then 
				c("Whirlwind") 
				return
			end 
		end			
	
		c("Cleave")
		return
	end
end

function Battered:BatteredZerk(sunders)
	local c = CastSpellByName
	if UnitClass("player") == "Warrior" then 
	
		Battered:AutoAttack()
		
		--Execute After Prot Stance so rage is not blown on a target before another, switch stance to execute or call manually
		if (UnitHealth("target") / UnitHealthMax("target")) <= 0.2 and UnitMana("player") > 9 then 
			c("Execute") 
			return
		end

		--If rage under 30 and dodged attack, swap and over power
		if GetTime()-Battered_Settings["dodge"] < 5 then
			if Battered:GetSpell("Overpower") and not Battered:OnCooldown("Overpower") and UnitMana("player") < 30 and UnitMana("player") > 4 then
				c("Battle Stance");
				c("Overpower")
				return
			end
		end
		
		c("Berserker Stance")
		
		if Battered:GetSpell("Battle Shout") and not Battered:GetBuff("player","Battle Shout") then 
			if UnitExists("target") and (UnitHealth("target") / UnitHealthMax("target")) > 0.2 and UnitMana("player") > 9 then
				c("Battle Shout") 
				return
			elseif not UnitExists("target") and UnitMana("player") > 9 then
				c("Battle Shout") 
				return
			end
		end
		
		if(sunders > 0) then
			if not Battered:GetBuff("target","Sunder Armor") then
				c("Sunder Armor")
			else
				if Battered:GetBuff("target","Sunder Armor",1) < sunders then
					c("Sunder Armor")
				end
			end
		end
		
		if Battered:GetSpell("Bloodrage") and UnitAffectingCombat("player") and UnitMana("player") < 40 and not Battered:OnCooldown("Bloodrage") then 
			c("Bloodrage") 
			return
		end
		
		if Battered:GetSpell("Bloodthirst") and not Battered:OnCooldown("Bloodthirst") and UnitMana("player") > 29 then
			c("Bloodthirst")
			return
		elseif Battered:GetSpell("Whirlwind") and not Battered:OnCooldown("Whirlwind") and UnitMana("player") > 29 then 
			if CheckInteractDistance("target", 1 ) ~= nil then 
				c("Whirlwind") 
				return
			end 
		elseif Battered:GetSpell("Heroic Strike") and UnitMana("player") > 29 then
				c("Heroic Strike")
				return
		end		
	end
end

function Battered:BatteredZerk0()
	Battered:BatteredZerk(0)
end

function Battered:BatteredZerk2()
	Battered:BatteredZerk(2)
end

function Battered:BatteredZerk5()
	Battered:BatteredZerk(5)
end

function Battered:BatteredDef()
	local c = CastSpellByName
	if UnitClass("player") == "Warrior" then 
	
		Battered:AutoAttack()
		
		--If rage under 30 and dodged attack, swap and over power
		if GetTime()-Battered_Settings["dodge"] < 5 then
			if Battered:GetSpell("Overpower") and not Battered:OnCooldown("Overpower") and UnitMana("player") < 30 and UnitMana("player") > 4 then
				c("Battle Stance");
				c("Overpower")
			end
		end
		
		c("Defensive Stance")
		
		if Battered:GetSpell("Battle Shout") and not Battered:GetBuff("player","Battle Shout") then 
			if UnitExists("target") and (UnitHealth("target") / UnitHealthMax("target")) > 0.2 and UnitMana("player") > 9 then
				c("Battle Shout") 
				return
			elseif not UnitExists("target") and UnitMana("player") > 9 then
				c("Battle Shout") 
				return
			end
		end
				
		if Battered:GetSpell("Bloodrage") and UnitAffectingCombat("player") and UnitMana("player") < 40 and not Battered:OnCooldown("Bloodrage") then 
			c("Bloodrage") 
			return
		end
		
		if not Battered:GetBuff("target","Sunder Armor") then
			c("Sunder Armor")
		else
			if Battered:GetBuff("target","Sunder Armor",1) < 5 then
				c("Sunder Armor")
			end
		end
		
		if Battered:GetSpell("Bloodthirst") and not Battered:OnCooldown("Bloodthirst") and UnitMana("player") > 29 then
			c("Bloodthirst")
			return
		elseif Battered:GetSpell("Heroic Strike") and UnitMana("player") > 29 then
				c("Heroic Strike")
		end	
		
		if Battered:GetSpell("Revenge") and not Battered:OnCooldown("Revenge") and UnitMana("player") > 4 then
			c("Revenge")
			return
		end
		
	end
end


SlashCmdList['BATTERED_CLEAVE_SLASH'] = Battered.BatteredCleave
SLASH_BATTERED_CLEAVE_SLASH1 = '/BatteredCleave'

SlashCmdList['BATTERED_ZERK0_SLASH'] = Battered.BatteredZerk0
SLASH_BATTERED_ZERK0_SLASH1 = '/BatteredZerk0'

SlashCmdList['BATTERED_ZERK2_SLASH'] = Battered.BatteredZerk2
SLASH_BATTERED_ZERK2_SLASH1 = '/BatteredZerk2'

SlashCmdList['BATTERED_ZERK5_SLASH'] = Battered.BatteredZerk5
SLASH_BATTERED_ZERK5_SLASH1 = '/BatteredZerk5'

SlashCmdList['BATTERED_DEF_SLASH'] = Battered.BatteredDef
SLASH_BATTERED_DEF_SLASH1 = '/BatteredDef'
