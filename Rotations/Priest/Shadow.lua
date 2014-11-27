if select(3, UnitClass("player")) == 5 then
	function PriestShadow()

		if currentConfig ~= "Shadow ragnar" then
			ShadowConfig();
			ShadowToggles();
			currentConfig = "Shadow ragnar";
		end
		-- Head End

		-- Locals / Globals--
			GCD = 1.5/(1+UnitSpellHaste("player")/100)
			hasTarget = UnitExists("target")
			hasMouse = UnitExists("mouseover")
			php = getHP("player")
			thp = getHP("target")
			ORBS = UnitPower("player", SPELL_POWER_SHADOW_ORBS)

			MBCD = getSpellCD(MB)
			SWDCD = getSpellCD(SWD)

			-- DP
			DPTIME = 6.0/(1+UnitSpellHaste("player")/100)
			DPTICK = DPTIME/6
			-- SWP (18sec)
			SWPTICK = 18.0/(1+UnitSpellHaste("player")/100)/6
			-- VT (15sec)
			VTTICK = 16.0/(1+UnitSpellHaste("player")/100)/5
			VTCASTTIME = 1.5/(1+UnitSpellHaste("player")/100)

			if lastVT==nil then lastVT=0 end
			if lastDP==nil then	lastDP=99 end

		-- Set Enemies Table
			makeEnemiesTable(60)



		-------------
		-- TOGGLES --
		-------------

		-- Pause toggle
		if isChecked("Pause Toggle") and SpecificToggle("Pause Toggle") == 1 then
			ChatOverlay("|cffFF0000BadBoy Paused", 0);
			return;
		end

		-- Focus Toggle
		if isChecked("Focus Toggle") and SpecificToggle("Focus Toggle") == 1 then
			RunMacroText("/focus mouseover");
		end

		-- -- Auto Resurrection
		if isChecked("Auto Rez") then
			if not isInCombat("player") and UnitIsDeadOrGhost("mouseover") and UnitIsFriend("player","mouseover") then
				if castSpell("mouseover",Rez,true,true) then return; end
			end
		end

		------------
		-- CHECKS --
		------------

		-- Food/Invis Check
		if canRun() ~= true then return false;
		end

		-- Mounted Check
		if IsMounted("player") then return false;
		end

		-- Do not Interrupt "player" while GCD (61304)
		if getSpellCD(61304) > 0 then return false;
		end

		-------------------
		-- OUT OF COMBAT --
		-------------------

		-- Power Word: Fortitude
		if not isInCombat("player") then
			if isChecked("PW: Fortitude") and (lastPWF == nil or lastPWF <= GetTime() - 5) then
				for i = 1, #nNova do
			  		if isPlayer(nNova[i].unit) == true and not isBuffed(nNova[i].unit,{21562,109773,469,90364}) and (UnitInRange(nNova[i].unit) or UnitIsUnit(nNova[i].unit,"player")) then
			  			if castSpell("player",PWF,true) then lastPWF = GetTime(); return; end
					end
				end
			end
		end

		---------------------------------------
		-- Shadowform and AutoSpeed Selfbuff --
		---------------------------------------

		-- Shadowform outfight
		if not UnitBuffID("player",Shadowform) and isChecked("Shadowform Outfight") then
			if castSpell("player",Shadowform,true,false) then return; end
		end

		-- Angelic Feather
		if isKnown(AngelicFeather) and isChecked("Angelic Feather") and getGround("player") and IsMovingTime(0.33) and not UnitBuffID("player",AngelicFeatherBuff) then
			if castGround("player",AngelicFeather,30) then
				SpellStopTargeting();
				return;
			end
		end

		-- Body and Soul
		if isKnown(BodyAndSoul) and isChecked("Body And Soul") and getGround("player") and IsMovingTime(0.75) and not UnitBuffID("player",PWS) and not UnitDebuffID("player",PWSDebuff) then
			if castSpell("player",PWS,true,false) then
				return;
			end
		end

		---------------
		-- IN COMBAT --
		---------------
		-- AffectingCombat, Pause, Target, Dead/Ghost Check
		if UnitAffectingCombat("player") then

			-- Shadowform outfight
			if not UnitBuffID("player",Shadowform) then
				if castSpell("player",Shadowform,true,false) then return; end
			end

			-------------------
			-- Dummy Testing --
			-------------------
			if isChecked("DPS Testing") then
				if UnitExists("target") then
					if getCombatTime() >= (tonumber(getValue("DPS Testing"))*60) and isDummy() then
						StopAttack()
						ClearTarget()
						print("____ " .. tonumber(getValue("DPS Testing")) .." Minute Dummy Test Concluded - Profile Stopped ____")
					end
				end
			end


			----------------
			-- Defensives --
			----------------
			ShadowDefensive()

			----------------
			-- Offensives --
			----------------
			ShadowCooldowns()

			---------------
			-- Interrupt --
			---------------
			if BadBoy_data['Kicks'] == 2 then
				ShadowKicks()
			end

			--------------
			-- Decision --
			--------------
				-- Aoe
				if BadBoy_data['AoE'] == 2 then
					if UnitExists("target") and getNumEnemiesInRange("target",10)>=5 then
						ShadowAoE()
					end
				end

				-- Rotation
					-- Break MF for MB
				if getSpellCD(MB)<0.5 and select(1,UnitChannelInfo("player")) == "Mind Flay" then
					--print("--- BREAK MF ---")
					RunMacroText("/stopcasting")
				end
					-- Burn
				if isKnown(CoP) and getHP("target")<=20 then
					ShadowCoPBurn()
				end
					-- standard rotation
				if isKnown(CoP) then
					ShadowH2PCoP()
				end
		end -- AffectingCombat, Pause, Target, Dead/Ghost Check
	end
end



-- Mindbender isboss
-- do pause if dispersion
-- Auto Rez

---------------------------
-- Mindbender: 			12	k
-- Insanity (SWP,VT):	12.5k
-- Insanity (SWP):		12.2k
-- Insanity (noWeave):	