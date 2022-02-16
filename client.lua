-- Variables

local QBCore = exports['qb-core']:GetCoreObject()
local GarageLocation = {}
local inGarageStation = false
local currentgarage = nil
local nearspawnpoint = nil
local lastjobveh = nil
local OutsideVehicles = {}
local PlayerData = {}
local inJobStation = {}
local hasHouseKey = false
local HouseKeys = {}
local Blips = {}

-- Functions

local function GetVehicleModifications(vehicle) --Get all vehicle information
    if DoesEntityExist(vehicle) then
		local colorPrimary, colorSecondary = GetVehicleColours(vehicle)
		local pearlescentColor, wheelColor = GetVehicleExtraColours(vehicle)
		local extras = {}
		for extraId = 0, 20 do
            if DoesExtraExist(vehicle, extraId) then
                local state = IsVehicleExtraTurnedOn(vehicle, extraId) == 1
                extras[tostring(extraId)] = state
            end
        end
		if GetVehicleMod(vehicle, 48) == -1 and GetVehicleLivery(vehicle) ~= -1 then
            modLivery = GetVehicleLivery(vehicle)
        else
            modLivery = GetVehicleMod(vehicle, 48)
        end
		local tiresBurst = {}
		for id = 0, 5 do
			if (IsVehicleTyreBurst(vehicle, id, true)) then
				tiresBurst[tostring(id)] = true
			elseif (IsVehicleTyreBurst(vehicle, id, false)) then
				tiresBurst[tostring(id)] = false
			end
		end
		local windowsBroken = {}
		for id = 0, 7 do
			if IsVehicleWindowIntact(vehicle, id) then
				windowsBroken[tostring(id)] = true
			else
				windowsBroken[tostring(id)] = false
			end
		end
		local doorsMissing = {}
		for id = 0, 5 do 
			if IsVehicleDoorDamaged(vehicle, id) then
				doorsMissing[tostring(id)] = true
			else
				doorsMissing[tostring(id)] = false
			end
		end
		local hasCustomPrimaryColor = GetIsVehiclePrimaryColourCustom(vehicle)
		local customPrimaryColor = nil
		if (hasCustomPrimaryColor) then
			local r, g, b = GetVehicleCustomPrimaryColour(vehicle)
			customPrimaryColor = {
				r = r,
				g = g,
				b = b
			}
		end
		local hasCustomSecondaryColor = GetIsVehicleSecondaryColourCustom(vehicle)
		local customSecondaryColor = nil
		if (hasCustomSecondaryColor) then
			local r, g, b = GetVehicleCustomSecondaryColour(vehicle)
			customSecondaryColor = {
				r = r,
				g = g,
				b = b
			}
		end
		return {
			model = GetEntityModel(vehicle),
			plate = QBCore.Functions.GetPlate(vehicle),
			plateIndex = GetVehicleNumberPlateTextIndex(vehicle),
			lockstatus = GetVehicleDoorLockStatus(vehicle),
			health = QBCore.Shared.Round(GetEntityHealth(vehicle), 0.1),
			bodyHealth = QBCore.Shared.Round(GetVehicleBodyHealth(vehicle), 0.1),
			engineHealth = QBCore.Shared.Round(GetVehicleEngineHealth(vehicle), 0.1),
			tankHealth = QBCore.Shared.Round(GetVehiclePetrolTankHealth(vehicle), 0.1),
			fuelLevel = QBCore.Shared.Round(GetVehicleFuelLevel(vehicle), 0.1),
			dirtLevel = QBCore.Shared.Round(GetVehicleDirtLevel(vehicle), 0.1),
			color1 = colorPrimary,
			color2 = colorSecondary,
			pearlescentColor = pearlescentColor,
			interiorColor = GetVehicleInteriorColor(vehicle),
			dashboardColor = GetVehicleDashboardColour(vehicle),
			wheelColor = wheelColor,
			wheels = GetVehicleWheelType(vehicle),
			windowTint = GetVehicleWindowTint(vehicle),
			xenonColor = GetVehicleXenonLightsColour(vehicle),
			neonEnabled = {
                IsVehicleNeonLightEnabled(vehicle, 0),
                IsVehicleNeonLightEnabled(vehicle, 1),
                IsVehicleNeonLightEnabled(vehicle, 2),
                IsVehicleNeonLightEnabled(vehicle, 3)
            },
			neonColor = table.pack(GetVehicleNeonLightsColour(vehicle)),
			extras = extras,
			tyreSmokeColor = table.pack(GetVehicleTyreSmokeColor(vehicle)),
			modSpoilers = GetVehicleMod(vehicle, 0),
            modFrontBumper = GetVehicleMod(vehicle, 1),
            modRearBumper = GetVehicleMod(vehicle, 2),
            modSideSkirt = GetVehicleMod(vehicle, 3),
            modExhaust = GetVehicleMod(vehicle, 4),
            modFrame = GetVehicleMod(vehicle, 5),
            modGrille = GetVehicleMod(vehicle, 6),
            modHood = GetVehicleMod(vehicle, 7),
            modFender = GetVehicleMod(vehicle, 8),
            modRightFender = GetVehicleMod(vehicle, 9),
            modRoof = GetVehicleMod(vehicle, 10),
			modEngine = GetVehicleMod(vehicle, 11),
            modBrakes = GetVehicleMod(vehicle, 12),
            modTransmission = GetVehicleMod(vehicle, 13),
            modHorns = GetVehicleMod(vehicle, 14),
            modSuspension = GetVehicleMod(vehicle, 15),
            modArmor = GetVehicleMod(vehicle, 16),
			modTurbo = IsToggleModOn(vehicle, 18),
            modSmokeEnabled = IsToggleModOn(vehicle, 20),
            modXenon = IsToggleModOn(vehicle, 22),
			modFrontWheels = GetVehicleMod(vehicle, 23),
            modBackWheels = GetVehicleMod(vehicle, 24),
			modCustomTiresF = GetVehicleModVariation(vehicle, 23),
            modCustomTiresR = GetVehicleModVariation(vehicle, 24),
			modPlateHolder = GetVehicleMod(vehicle, 25),
            modVanityPlate = GetVehicleMod(vehicle, 26),
            modTrimA = GetVehicleMod(vehicle, 27),
            modOrnaments = GetVehicleMod(vehicle, 28),
            modDashboard = GetVehicleMod(vehicle, 29),
            modDial = GetVehicleMod(vehicle, 30),
            modDoorSpeaker = GetVehicleMod(vehicle, 31),
            modSeats = GetVehicleMod(vehicle, 32),
            modSteeringWheel = GetVehicleMod(vehicle, 33),
            modShifterLeavers = GetVehicleMod(vehicle, 34),
            modAPlate = GetVehicleMod(vehicle, 35),
            modSpeakers = GetVehicleMod(vehicle, 36),
            modTrunk = GetVehicleMod(vehicle, 37),
            modHydrolic = GetVehicleMod(vehicle, 38),
            modEngineBlock = GetVehicleMod(vehicle, 39),
            modAirFilter = GetVehicleMod(vehicle, 40),
            modStruts = GetVehicleMod(vehicle, 41),
            modArchCover = GetVehicleMod(vehicle, 42),
            modAerials = GetVehicleMod(vehicle, 43),
            modTrimB = GetVehicleMod(vehicle, 44),
            modTank = GetVehicleMod(vehicle, 45),
            modWindows = GetVehicleMod(vehicle, 46),
			modLivery = modLivery,
			tiresburst = tiresBurst,
			windowsbroken = windowsBroken,
			doorsmissing = doorsMissing,
			bulletprooftires = not GetVehicleTyresCanBurst(vehicle),
			customprimarycolor = customPrimaryColor,
			customsecondarycolor = customSecondaryColor,
		}
	else
        return
    end
end

local function SetVehicleModifications(vehicle, props)-- Apply all modifications to a vehicle entity
    if DoesEntityExist(vehicle) then
		SetVehicleModKit(vehicle, 0)
		-- plate:
		if props.plate then
            SetVehicleNumberPlateText(vehicle, props.plate)
        end
        if props.plateIndex then
            SetVehicleNumberPlateTextIndex(vehicle, props.plateIndex)
        end
		-- lockStatus:
		if props.lockstatus then
			SetVehicleDoorsLocked(vehicle, props.lockstatus)
		end
		-- colours:
		if props.color1 and props.color2 then
			SetVehicleColours(vehicle, props.color1, props.color2)
		end
		if props.customprimarycolor then
			SetVehicleCustomPrimaryColour(vehicle, props.customprimarycolor.r, props.customprimarycolor.g, props.customprimarycolor.b)
		end
		if props.customsecondarycolor then
			SetVehicleCustomSecondaryColour(vehicle, props.customsecondarycolor.r, props.customsecondarycolor.g, props.customsecondarycolor.b)
		end
		if props.interiorColor then
            SetVehicleInteriorColor(vehicle, props.interiorColor)
        end
		if props.dashboardColor then
            SetVehicleDashboardColour(vehicle, props.dashboardColor)
        end
		if props.pearlescentColor and props.wheelColor then
			SetVehicleExtraColours(vehicle, props.pearlescentColor, props.wheelColor)
		end
		if props.tyreSmokeColor then
            SetVehicleTyreSmokeColor(vehicle, props.tyreSmokeColor[1], props.tyreSmokeColor[2], props.tyreSmokeColor[3])
        end
		-- wheels:
		if props.wheels then
            SetVehicleWheelType(vehicle, props.wheels)
        end
		-- windows:
		if props.windowTint then
            SetVehicleWindowTint(vehicle, props.windowTint)
        end
		-- neonlight:
		if props.neonEnabled then
            SetVehicleNeonLightEnabled(vehicle, 0, props.neonEnabled[1])
            SetVehicleNeonLightEnabled(vehicle, 1, props.neonEnabled[2])
            SetVehicleNeonLightEnabled(vehicle, 2, props.neonEnabled[3])
            SetVehicleNeonLightEnabled(vehicle, 3, props.neonEnabled[4])
        end
		if props.neonColor then
            SetVehicleNeonLightsColour(vehicle, props.neonColor[1], props.neonColor[2], props.neonColor[3])
        end
		-- mods:
		if props.modSpoilers then
            if props.modCustomTiresF then
				SetVehicleMod(vehicle, 0, props.modSpoilers, props.modCustomTiresF)
			else
				SetVehicleMod(vehicle, 0, props.modSpoilers, false)
			end
        end
		if props.modFrontBumper then
            if props.modCustomTiresF then
				SetVehicleMod(vehicle, 1, props.modFrontBumper, props.modCustomTiresF)
			else
				SetVehicleMod(vehicle, 1, props.modFrontBumper, false)
			end
        end
		if props.modRearBumper then
            if props.modCustomTiresF then
				SetVehicleMod(vehicle, 2, props.modRearBumper, props.modCustomTiresF)
			else
				SetVehicleMod(vehicle, 2, props.modRearBumper, false)
			end
        end
		if props.modSideSkirt then
            if props.modCustomTiresF then
				SetVehicleMod(vehicle, 3, props.modSideSkirt, props.modCustomTiresF)
			else
				SetVehicleMod(vehicle, 3, props.modSideSkirt, false)
			end
        end
		if props.modExhaust then
            if props.modCustomTiresF then
				SetVehicleMod(vehicle, 4, props.modExhaust, props.modCustomTiresF)
			else
				SetVehicleMod(vehicle, 4, props.modExhaust, false)
			end
        end
		if props.modFrame then
            if props.modCustomTiresF then
				SetVehicleMod(vehicle, 5, props.modFrame, props.modCustomTiresF)
			else
				SetVehicleMod(vehicle, 5, props.modFrame, false)
			end
        end
		if props.modGrille then
            if props.modCustomTiresF then
				SetVehicleMod(vehicle, 6, props.modGrille, props.modCustomTiresF)
			else
				SetVehicleMod(vehicle, 6, props.modGrille, false)
			end
        end
		if props.modHood then
            if props.modCustomTiresF then
				SetVehicleMod(vehicle, 7, props.modHood, props.modCustomTiresF)
			else
				SetVehicleMod(vehicle, 7, props.modHood, false)
			end
        end
		if props.modFender then
            if props.modCustomTiresF then
				SetVehicleMod(vehicle, 8, props.modFender, props.modCustomTiresF)
			else
				SetVehicleMod(vehicle, 8, props.modFender, false)
			end
        end
		if props.modRightFender then
            if props.modCustomTiresF then
				SetVehicleMod(vehicle, 9, props.modRightFender, props.modCustomTiresF)
			else
				SetVehicleMod(vehicle, 9, props.modRightFender, false)
			end
        end
		if props.modRoof then
            if props.modCustomTiresF then
				SetVehicleMod(vehicle, 10, props.modRoof, props.modCustomTiresF)
			else
				SetVehicleMod(vehicle, 10, props.modRoof, false)
			end
        end
		if props.modEngine then
            if props.modCustomTiresF then
				SetVehicleMod(vehicle, 11, props.modEngine, props.modCustomTiresF)
			else
				SetVehicleMod(vehicle, 11, props.modEngine, false)
			end
        end
		if props.modBrakes then
            if props.modCustomTiresF then
				SetVehicleMod(vehicle, 12, props.modBrakes, props.modCustomTiresF)
			else
				SetVehicleMod(vehicle, 12, props.modBrakes, false)
			end
        end
		if props.modTransmission then
            if props.modCustomTiresF then
				SetVehicleMod(vehicle, 13, props.modTransmission, props.modCustomTiresF)
			else
				SetVehicleMod(vehicle, 13, props.modTransmission, false)
			end
        end
		if props.modHorns then
            if props.modCustomTiresF then
				SetVehicleMod(vehicle, 14, props.modHorns, props.modCustomTiresF)
			else
				SetVehicleMod(vehicle, 14, props.modHorns, false)
			end
        end
		if props.modSuspension then
            if props.modCustomTiresF then
				SetVehicleMod(vehicle, 15, props.modSuspension, props.modCustomTiresF)
			else
				SetVehicleMod(vehicle, 15, props.modSuspension, false)
			end
        end
		if props.modArmor then
            if props.modCustomTiresF then
				SetVehicleMod(vehicle, 16, props.modArmor, props.modCustomTiresF)
			else
				SetVehicleMod(vehicle, 16, props.modArmor, false)
			end
        end
		if props.modTurbo then
            ToggleVehicleMod(vehicle, 18, props.modTurbo)
        end
		if props.modSmokeEnabled then
            ToggleVehicleMod(vehicle, 20, props.modSmokeEnabled)
        end
		if props.modXenon then
            ToggleVehicleMod(vehicle, 22, props.modXenon)
        end
		if props.modFrontWheels then
            if props.modCustomTiresF then
				SetVehicleMod(vehicle, 23, props.modFrontWheels, props.modCustomTiresF)
			else
				SetVehicleMod(vehicle, 23, props.modFrontWheels, false)
			end
        end
		if props.modBackWheels then
            if props.modCustomTiresR then
				SetVehicleMod(vehicle, 24, props.modBackWheels, props.modCustomTiresR)
			else
				SetVehicleMod(vehicle, 24, props.modBackWheels, false)
			end
        end
		if props.modPlateHolder then
            if props.modCustomTiresF then
				SetVehicleMod(vehicle, 25, props.modPlateHolder, props.modCustomTiresF)
			else
				SetVehicleMod(vehicle, 25, props.modPlateHolder, false)
			end
        end
		if props.modVanityPlate then
            if props.modCustomTiresF then
				SetVehicleMod(vehicle, 26, props.modVanityPlate, props.modCustomTiresF)
			else
				SetVehicleMod(vehicle, 26, props.modVanityPlate, false)
			end
        end
		if props.modTrimA then
            if props.modCustomTiresF then
				SetVehicleMod(vehicle, 27, props.modTrimA, props.modCustomTiresF)
			else
				SetVehicleMod(vehicle, 27, props.modTrimA, false)
			end
        end
		if props.modOrnaments then
            if props.modCustomTiresF then
				SetVehicleMod(vehicle, 28, props.modOrnaments, props.modCustomTiresF)
			else
				SetVehicleMod(vehicle, 28, props.modOrnaments, false)
			end
        end
		if props.modDashboard then
            if props.modCustomTiresF then
				SetVehicleMod(vehicle, 29, props.modDashboard, props.modCustomTiresF)
			else
				SetVehicleMod(vehicle, 29, props.modDashboard, false)
			end
        end
		if props.modDial then
            if props.modCustomTiresF then
				SetVehicleMod(vehicle, 30, props.modDial, props.modCustomTiresF)
			else
				SetVehicleMod(vehicle, 30, props.modDial, false)
			end
        end
		if props.modDoorSpeaker then
            if props.modCustomTiresF then
				SetVehicleMod(vehicle, 31, props.modDoorSpeaker, props.modCustomTiresF)
			else
				SetVehicleMod(vehicle, 31, props.modDoorSpeaker, false)
			end
        end
		if props.modSeats then
            if props.modCustomTiresF then
				SetVehicleMod(vehicle, 32, props.modSeats, props.modCustomTiresF)
			else
				SetVehicleMod(vehicle, 32, props.modSeats, false)
			end
        end
		if props.modSteeringWheel then
            if props.modCustomTiresF then
				SetVehicleMod(vehicle, 33, props.modSteeringWheel, props.modCustomTiresF)
			else
				SetVehicleMod(vehicle, 33, props.modSteeringWheel, false)
			end
        end
		if props.modShifterLeavers then
            if props.modCustomTiresF then
				SetVehicleMod(vehicle, 34, props.modShifterLeavers, props.modCustomTiresF)
			else
				SetVehicleMod(vehicle, 34, props.modShifterLeavers, false)
			end
        end
		if props.modAPlate then
            if props.modCustomTiresF then
				SetVehicleMod(vehicle, 35, props.modAPlate, props.modCustomTiresF)
			else
				SetVehicleMod(vehicle, 35, props.modAPlate, false)
			end
        end
		if props.modSpeakers then
            if props.modCustomTiresF then
				SetVehicleMod(vehicle, 36, props.modSpeakers, props.modCustomTiresF)
			else
				SetVehicleMod(vehicle, 36, props.modSpeakers, false)
			end
        end
		if props.modTrunk then
            if props.modCustomTiresF then
				SetVehicleMod(vehicle, 37, props.modTrunk, props.modCustomTiresF)
			else
				SetVehicleMod(vehicle, 37, props.modTrunk, false)
			end
        end
		if props.modHydrolic then
            if props.modCustomTiresF then
				SetVehicleMod(vehicle, 38, props.modHydrolic, props.modCustomTiresF)
			else
				SetVehicleMod(vehicle, 38, props.modHydrolic, false)
			end
        end
		if props.modEngineBlock then
            if props.modCustomTiresF then
				SetVehicleMod(vehicle, 39, props.modEngineBlock, props.modCustomTiresF)
			else
				SetVehicleMod(vehicle, 39, props.modEngineBlock, false)
			end
        end
		if props.modAirFilter then
            if props.modCustomTiresF then
				SetVehicleMod(vehicle, 40, props.modAirFilter, props.modCustomTiresF)
			else
				SetVehicleMod(vehicle, 40, props.modAirFilter, false)
			end
        end
		if props.modStruts then
            if props.modCustomTiresF then
				SetVehicleMod(vehicle, 41, props.modStruts, props.modCustomTiresF)
			else
				SetVehicleMod(vehicle, 41, props.modStruts, false)
			end
        end
		if props.modArchCover then
            if props.modCustomTiresF then
				SetVehicleMod(vehicle, 42, props.modArchCover, props.modCustomTiresF)
			else
				SetVehicleMod(vehicle, 42, props.modArchCover, false)
			end
        end
		if props.modAerials then
            if props.modCustomTiresF then
				SetVehicleMod(vehicle, 43, props.modAerials, props.modCustomTiresF)
			else
				SetVehicleMod(vehicle, 43, props.modAerials, false)
			end
        end
		if props.modTrimB then
            if props.modCustomTiresF then
				SetVehicleMod(vehicle, 44, props.modTrimB, props.modCustomTiresF)
			else
				SetVehicleMod(vehicle, 44, props.modTrimB, false)
			end
        end
		if props.modTank then
            if props.modCustomTiresF then
				SetVehicleMod(vehicle, 45, props.modTank, props.modCustomTiresF)
			else
				SetVehicleMod(vehicle, 45, props.modTank, false)
			end
        end
		if props.modWindows then
            if props.modCustomTiresF then
				SetVehicleMod(vehicle, 46, props.modWindows, props.modCustomTiresF)
			else
				SetVehicleMod(vehicle, 46, props.modWindows, false)
			end
        end
		if props.modLivery then
            if props.modCustomTiresF then
				SetVehicleMod(vehicle, 48, props.modLivery, props.modCustomTiresF)
				SetVehicleLivery(vehicle, props.modLivery)
			else
				SetVehicleMod(vehicle, 48, props.modLivery, false)
				SetVehicleLivery(vehicle, props.modLivery)
			end
        end
		-- extras:
		if props.extras then
            for id, enabled in pairs(props.extras) do
                if enabled then
                    SetVehicleExtra(vehicle, tonumber(id), 0)
                else
                    SetVehicleExtra(vehicle, tonumber(id), 1)
                end
            end
        end
		-- stats:
		if props.health then
            SetEntityHealth(vehicle, props.health + 0.0)
        end
		if props.bodyHealth then
            SetVehicleBodyHealth(vehicle, props.bodyHealth + 0.0)
        end
		if props.engineHealth then
            SetVehicleEngineHealth(vehicle, props.engineHealth + 0.0)
        end
		if props.engineHealth and renderScorched and props.engineHealth < -3999.0 then
			TriggerServerEvent('MojiaGarages:server:renderScorched', NetworkGetNetworkIdFromEntity(vehicle), true)
		end
		if props.tankHealth then
            SetVehiclePetrolTankHealth(vehicle, props.tankHealth + 0.0)
        end
		if props.tankHealth and renderScorched and props.tankHealth < -999.0 then
			TriggerServerEvent('MojiaGarages:server:renderScorched', NetworkGetNetworkIdFromEntity(vehicle), true)
		end
		if props.dirtLevel then
            SetVehicleDirtLevel(vehicle, props.dirtLevel + 0.0)
        end
		if props.fuelLevel then
            SetVehicleFuelLevel(vehicle, props.fuelLevel + 0.0)
        end
		-- doors:
		if props.doorsmissing then
            for id, state in pairs(props.doorsmissing) do
				if state then
					SetVehicleDoorBroken(vehicle, tonumber(id), state)
					
				end
			end
        end
		-- tires
		SetVehicleTyresCanBurst(vehicle, not props.bulletprooftires)
		if not props.bulletprooftires and props.tiresburst then
			for id, state in pairs(props.tiresburst) do
				SetVehicleTyreBurst(vehicle, tonumber(id), state, 1000.0)
			end
		end
		-- windows:
		if props.windowsbroken then
            for id, state in pairs(props.windowsbroken) do
				if not state then
					SmashVehicleWindow(vehicle, tonumber(id))
				end
			end
        end
		-- xenon lights:
		if props.xenonColor then
            SetVehicleXenonLightsColor(vehicle, props.xenonColor)
        end
	end
end

local function GetRotationDifference(r1, r2) -- returns the difference in degrees from the axis with the highest difference
    local x = math.abs(r1.x - r2.x)
    local y = math.abs(r1.y - r2.y)
    local z = math.abs(r1.z - r2.z)
    if (x > y and x > z) then
        return x
    elseif (y > z) then
        return y
    else
        return z
    end
end

local function CreateBlip() -- Create Garages blip
	if Garages then
		for k, v in pairs(Garages) do
			if v.showBlip then
				if v.job ~= nil then
					if PlayerData.job and PlayerData.job.name == v.job or PlayerData.gang and PlayerData.gang.name == v.job then
						if not DoesBlipExist(Blips[k]) then
							Blips[k] = AddBlipForCoord(v.blippoint)
							SetBlipSprite(Blips[k], v.blipsprite)
							SetBlipDisplay(Blips[k], 4)
							SetBlipScale(Blips[k], v.blipscale)
							SetBlipAsShortRange(Blips[k], true)
							SetBlipColour(Blips[k], v.blipcolour)
							SetBlipAlpha(Blips[k], 0.7)
							BeginTextCommandSetBlipName('STRING')
							if CustomFont ~= nil then
								AddTextComponentString('<font face=\'' .. CustomFont ..'\'>' .. v.label .. '</font>')
							else
								AddTextComponentString(v.label)
							end							
							EndTextCommandSetBlipName(Blips[k])
						end
					else
						if DoesBlipExist(Blips[k]) then
							RemoveBlip(Blips[k])
						end
					end
				else
					if v.isHouseGarage then
						if HouseKeys[k] then
							if not DoesBlipExist(Blips[k]) then
								Blips[k] = AddBlipForCoord(v.blippoint)
								SetBlipSprite(Blips[k], v.blipsprite)
								SetBlipDisplay(Blips[k], 4)
								SetBlipScale(Blips[k], v.blipscale)
								SetBlipAsShortRange(Blips[k], true)
								SetBlipColour(Blips[k], v.blipcolour)
								SetBlipAlpha(Blips[k], 0.7)
								BeginTextCommandSetBlipName('STRING')
								if CustomFont ~= nil then
									AddTextComponentString('<font face=\'' .. CustomFont ..'\'>' .. v.label .. '</font>')
								else
									AddTextComponentString(v.label)
								end	
								EndTextCommandSetBlipName(Blips[k])
							end
						else
							if DoesBlipExist(Blips[k]) then
								RemoveBlip(Blips[k])
							end
						end
					else
						if not DoesBlipExist(Blips[k]) then
							Blips[k] = AddBlipForCoord(v.blippoint)
							SetBlipSprite(Blips[k], v.blipsprite)
							SetBlipDisplay(Blips[k], 4)
							SetBlipScale(Blips[k], v.blipscale)
							SetBlipAsShortRange(Blips[k], true)
							SetBlipColour(Blips[k], v.blipcolour)
							SetBlipAlpha(Blips[k], 0.7)
							BeginTextCommandSetBlipName('STRING')
							if CustomFont ~= nil then
								AddTextComponentString('<font face=\'' .. CustomFont ..'\'>' .. v.label .. '</font>')
							else
								AddTextComponentString(v.label)
							end	
							EndTextCommandSetBlipName(Blips[k])
						end
					end
				end
			else
				if DoesBlipExist(Blips[k]) then
					RemoveBlip(Blips[k])
				end
			end
		end
	end
end

local function IsInGarage() -- Check if the player is in the garage area and if the garage is open for parking
	local checkIsingarage, checkCanStoreVehicle = false, false
	if inGarageStation and currentgarage ~= nil then
		checkIsingarage = true
		checkCanStoreVehicle = Garages[currentgarage].canStoreVehicle
	end
	return checkIsingarage, checkCanStoreVehicle
end

local function isInJobStation(job) -- Check player is in job gagage location or not
	return inJobStation[job], lastjobveh
end

local function EnumerateEntitiesWithinDistance(entities, isPlayerEntities, coords, maxDistance)
	local nearbyEntities = {}
	if coords then
		coords = vector3(coords.x, coords.y, coords.z)
	else
		local playerPed = PlayerPedId()
		coords = GetEntityCoords(playerPed)
	end
	for k, entity in pairs(entities) do
		local distance = #(coords - GetEntityCoords(entity))
		if distance <= maxDistance then
			nearbyEntities[#nearbyEntities+1] = isPlayerEntities and k or entity
		end
	end
	return nearbyEntities
end

local function GetVehiclesInArea(coords, maxDistance) -- Vehicle inspection in designated area
	return EnumerateEntitiesWithinDistance(QBCore.Functions.GetVehicles(), false, coords, maxDistance) 
end

local function IsSpawnPointClear(coords, maxDistance) -- Check the spawn point to see if it's empty or not:
	return #GetVehiclesInArea(coords, maxDistance) == 0 
end

local function GetNearSpawnPoint() -- Get nearest spawn point
	local near = nil
	local distance = 10000
	if inGarageStation and currentgarage ~= nil then
		for k, v in pairs(Garages[currentgarage].spawnPoint) do
			if IsSpawnPointClear(vector3(v.x, v.y, v.z), 2.5) then
				local ped = PlayerPedId()
				local pos = GetEntityCoords(ped)
				local cur_distance = #(pos - vector3(v.x, v.y, v.z))
				if cur_distance < distance then
					distance = cur_distance
					near = k
				end
			end
		end
	end
	return near
end

local function GetNearJobSpawnPoint() -- Get nearest spawn point for job garage
	local near = nil
	local distance = 10000
	PlayerData = QBCore.Functions.GetPlayerData()
	if inGarageStation and inJobStation[PlayerData.job.name] then
		for k, v in pairs(JobVeh[PlayerData.job.name][currentgarage].spawnPoint) do
			if IsSpawnPointClear(vector3(v.x, v.y, v.z), 2.5) then
				local ped = PlayerPedId()
				local pos = GetEntityCoords(ped)
				local cur_distance = #(pos - vector3(v.x, v.y, v.z))
				if cur_distance < distance then
					distance = cur_distance
					near = k
				end
			end
		end
	end
	return near
end

local function SetJobVehItems(job) -- Set trunk item for job vehicle
	local items = {}
	for k, item in pairs(VehJobItems[job]) do
		local itemInfo = QBCore.Shared.Items[item.name:lower()]
		items[item.slot] = {
			name = itemInfo['name'],
			amount = tonumber(item.amount),
			info = item.info,
			label = itemInfo['label'],
			description = itemInfo['description'] and itemInfo['description'] or '',
			weight = itemInfo['weight'],
			type = itemInfo['type'],
			unique = itemInfo['unique'],
			useable = itemInfo['useable'],
			image = itemInfo['image'],
			slot = item.slot,
		}
	end
	VehJobItems[job] = items
end

local function Deleteveh(plate) -- Delete the vehicle if it is somewhere outside
	local gameVehicles = QBCore.Functions.GetVehicles()
    for i = 1, #gameVehicles do
        local vehicle = gameVehicles[i]
        if DoesEntityExist(vehicle) then
            if QBCore.Functions.GetPlate(vehicle) == plate then
				QBCore.Functions.DeleteVehicle(vehicle)
            end
        end
    end
end

local function isVehicleExistInRealLife(plate)
	local gameVehicles = QBCore.Functions.GetVehicles()
	local check = false
    for i = 1, #gameVehicles do
        local vehicle = gameVehicles[i]
        if DoesEntityExist(vehicle) then
            if QBCore.Functions.GetPlate(vehicle) == plate then
				check = true
            end
        end
    end
	return check
end

local function CheckPlayers(vehicle) -- Check if there is someone in the car, if so, get that person out of the car
    for i = -1, 5,1 do                
        seat = GetPedInVehicleSeat(vehicle,i)
        if seat ~= 0 then
            TaskLeaveVehicle(seat,vehicle,0)
            SetVehicleDoorsLocked(vehicle)			
            Wait(3000)
			local networkId = NetworkGetNetworkIdFromEntity(vehicle)
			TriggerEvent('MojiaGarages:client:updateVehicle', networkId)
			Wait(100)
            QBCore.Functions.DeleteVehicle(vehicle)
        end
   end
end

-- Events
RegisterNetEvent('MojiaGarages:client:renderScorched', function(vehicleNetId, scorched)
	local vehicle = NetworkGetEntityFromNetworkId(vehicleNetId)
	if (DoesEntityExist(vehicle)) then
		SetEntityRenderScorched(vehicle, scorched)
	end
end)

RegisterNetEvent('MojiaGarages:client:updateVehicle', function(netId)
	local vehicle = NetworkGetEntityFromNetworkId(netId)
	if (vehicle == nil) then
		return
	end
	local plate = QBCore.Functions.GetPlate(vehicle)
	if NetworkGetEntityIsNetworked(vehicle) and DoesEntityExist(vehicle) then
		QBCore.Functions.TriggerCallback('MojiaGarages:server:checkHasVehicleOwner', function(hasowned)
			if hasowned then					
				QBCore.Functions.TriggerCallback('MojiaGarages:server:getVehicleData', function(VehicleData)
					if VehicleData then					
						local modifications = GetVehicleModifications(vehicle)
						local oldmodifications = json.decode(VehicleData.mods)
						local vehpos = GetEntityCoords(vehicle)
						local vehRot = GetEntityRotation(vehicle)
						if (#(vector3(VehicleData.posX, VehicleData.posY, VehicleData.posZ) - vehpos) > 1.0 
							or GetRotationDifference(vector3(VehicleData.rotX, VehicleData.rotY, VehicleData.rotZ), vehRot) > 15.0
							or modifications.lockstatus ~= oldmodifications.lockstatus
							or math.abs(modifications.bodyHealth - oldmodifications.bodyHealth) > 5.0
							or math.abs(modifications.engineHealth - oldmodifications.engineHealth) > 5.0
							or math.abs(modifications.tankHealth - oldmodifications.tankHealth) > 5.0
						) then
							local networkId = NetworkGetNetworkIdFromEntity(vehicle)
							TriggerServerEvent('MojiaGarages:server:updateVehicle', networkId, plate, modifications)
						end
					end
				end, plate)
			end
		end, plate)
	end
end)

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function() -- Event when player has successfully loaded
    TriggerEvent('MojiaGarages:client:DestroyingZone') -- Destroying all zone
	Wait(100)
	PlayerData = QBCore.Functions.GetPlayerData() -- Reload player information
	Wait(100)
	TriggerServerEvent('MojiaGarages:server:updateHouseKeys') 	-- Reload house key information	
	Wait(100)
	TriggerServerEvent('MojiaGarages:server:UpdateGaragesZone') -- Reload garage information
	Wait(100)
	CreateBlip() --Reload blips
end)

RegisterNetEvent('QBCore:Client:OnPlayerUnload', function() -- Event when the player has left --Reset all variables
	TriggerEvent('MojiaGarages:client:DestroyingZone') -- Destroying all zone
	GarageLocation = {} 
	inGarageStation = false
	currentgarage = nil
	nearspawnpoint = nil
	lastjobveh = nil
	OutsideVehicles = {}
	PlayerData = {}
	inJobStation = {}
	hasHouseKey = false
	HouseKeys = {}
	Blips = {}
end)

AddEventHandler('onResourceStart', function(resource) -- Event when resource is reloaded
    if resource == GetCurrentResourceName() then -- Reload player information
        TriggerEvent('MojiaGarages:client:DestroyingZone') -- Destroying all zone
		Wait(100)
		PlayerData = QBCore.Functions.GetPlayerData() -- Reload player information
		Wait(100)
		TriggerServerEvent('MojiaGarages:server:updateHouseKeys') 	-- Reload house key information	
		Wait(100)
		TriggerServerEvent('MojiaGarages:server:UpdateGaragesZone') -- Reload garage information
		Wait(100)
		CreateBlip() --Reload blips
    end
end)

RegisterNetEvent('QBCore:Client:OnJobUpdate', function(JobInfo) --Events when players change jobs
	TriggerEvent('MojiaGarages:client:DestroyingZone') -- Destroying all zone
	Wait(100)
	PlayerData = QBCore.Functions.GetPlayerData() -- Reload player information
	Wait(100)
	TriggerServerEvent('MojiaGarages:server:updateHouseKeys') 	-- Reload house key information	
	Wait(100)
	TriggerServerEvent('MojiaGarages:server:UpdateGaragesZone') -- Reload garage information
	Wait(100)
	CreateBlip() --Reload blips
end)

RegisterNetEvent('QBCore:Client:OnGangUpdate', function(GangInfo) -- Reload player information
	TriggerEvent('MojiaGarages:client:DestroyingZone') -- Destroying all zone
	Wait(100)
	PlayerData = QBCore.Functions.GetPlayerData() -- Reload player information
	Wait(100)
	TriggerServerEvent('MojiaGarages:server:updateHouseKeys') 	-- Reload house key information	
	Wait(100)
	TriggerServerEvent('MojiaGarages:server:UpdateGaragesZone') -- Reload garage information
	Wait(100)
	CreateBlip() --Reload blips
end)

RegisterNetEvent('MojiaGarages:client:UpdateGaragesZone', function(garageConfig) -- Update Garages Zone
	if garageConfig then		
		Garages = garageConfig
		for k, v in pairs(Garages) do
			if Garages[k].job ~= nil then
				if PlayerData.job and PlayerData.job.name == Garages[k].job or PlayerData.gang and PlayerData.gang.name == Garages[k].job then
					GarageLocation[k] = PolyZone:Create(v.zones, {
						name='GarageStation '..k,
						minZ = 	v.minz,
						maxZ = v.maxz,
						debugPoly = false
					})
				end
			else
				if Garages[k].isHouseGarage then
					if HouseKeys[k] then
						GarageLocation[k] = PolyZone:Create(v.zones, {
							name='GarageStation '..k,
							minZ = 	v.minz,
							maxZ = v.maxz,
							debugPoly = false
						})
					end
				else
					GarageLocation[k] = PolyZone:Create(v.zones, {
						name='GarageStation '..k,
						minZ = 	v.minz,
						maxZ = v.maxz,
						debugPoly = false
					})
				end
			end
		end
	end
end)

RegisterNetEvent('MojiaGarages:client:DestroyingZone', function() -- Destroying all zone
	if GarageLocation then
		for k, v in pairs(GarageLocation) do
			GarageLocation[k]:destroy()
		end
	end
	inJobStation = {}
	GarageLocation = {}
end)

RegisterNetEvent('MojiaGarages:client:updateGarage', function() -- Update Garages
	TriggerEvent('MojiaGarages:client:DestroyingZone') -- Destroying all zone
	Wait(100)
	PlayerData = QBCore.Functions.GetPlayerData() -- Reload player information
	Wait(100)
	TriggerServerEvent('MojiaGarages:server:updateHouseKeys') 	-- Reload house key information	
	Wait(100)
	TriggerServerEvent('MojiaGarages:server:UpdateGaragesZone') -- Reload garage information
	Wait(100)
	CreateBlip() --Reload blips
end)

RegisterNetEvent('MojiaGarages:client:updateHouseKeys', function(keylist) --Update House Keys
	if keylist then
		HouseKeys = keylist
	end
end)

RegisterNetEvent('MojiaGarages:client:openGarage', function() -- Garages Menu
    if inGarageStation and currentgarage ~= nil then
		if currentgarage == 'impound' and PlayerData.job.name == 'police' then
			QBCore.Functions.TriggerCallback('MojiaGarages:server:GetimpoundVehicles', function(result)
				if result then
					local MenuGaraOptions = {
						{
							header = Lang:t('info.garage_menu_header', {header = Garages[currentgarage].label}),
							isMenuHeader = true
						},
					}
					MenuGaraOptions[#MenuGaraOptions + 1] = {
						header = Lang:t('info.close_menu'),
						txt = '',
						params = {
							event = 'qb-menu:closeMenu',
						}
					}
					for i, v in pairs(result) do
						if v.state == 2 then
							local modifications = json.decode(v.mods)
							bodyPercent = QBCore.Shared.Round(modifications.bodyHealth / 10, 0)
							enginePercent = QBCore.Shared.Round(modifications.engineHealth / 10, 0)								
							petrolTankPercent = QBCore.Shared.Round(modifications.tankHealth / 10, 0)
							dirtPercent = QBCore.Shared.Round((modifications.dirtLevel/15)*100, 0)
							currentFuel = QBCore.Shared.Round(modifications.fuelLevel, 0)
							if Garages[currentgarage].fullfix then
								modifications.bodyHealth = 1000
								modifications.engineHealth = 1000
								modifications.tankHealth = 1000
								modifications.dirtLevel = 0
								modifications.fuelLevel = 100
								v.mods = json.encode(modifications)
							end
							MenuGaraOptions[#MenuGaraOptions + 1] = {
								header = QBCore.Shared.Vehicles[v.vehicle].name,
								txt = Lang:t('info.vehicle_info', {plate = v.plate, fuel = currentFuel, engine = enginePercent, body = bodyPercent, tank = petrolTankPercent, dirt = dirtPercent}),
								params = {
									event = 'MojiaGarages:client:TakeOutVehicle',
									args = v
								}
							}
						end
					end
					exports['qb-menu']:openMenu(MenuGaraOptions)
				else
					QBCore.Functions.Notify(Lang:t('error.there_are_no_vehicles_in_the_garage'), 'error', 5000)
				end
			end)
		else
			QBCore.Functions.TriggerCallback('MojiaGarages:server:GetUserVehicles', function(result)
				if result then
					local MenuGaraOptions = {
						{
							header = Lang:t('info.garage_menu_header', {header = Garages[currentgarage].label}),
							isMenuHeader = true
						},
					}
					MenuGaraOptions[#MenuGaraOptions + 1] = {
						header = Lang:t('info.close_menu'),
						txt = '',
						params = {
							event = 'qb-menu:closeMenu',
						}
					}
					for i, v in pairs(result) do
						if v.state == Garages[currentgarage].garastate then
							if v.state == 1 then
								if v.garage == currentgarage then
									local modifications = json.decode(v.mods)
									bodyPercent = QBCore.Shared.Round(modifications.bodyHealth / 10, 0)
									enginePercent = QBCore.Shared.Round(modifications.engineHealth / 10, 0)								
									petrolTankPercent = QBCore.Shared.Round(modifications.tankHealth / 10, 0)
									dirtPercent = QBCore.Shared.Round((modifications.dirtLevel/15)*100, 0)
									currentFuel = QBCore.Shared.Round(modifications.fuelLevel, 0)
									if Garages[currentgarage].fullfix then
										modifications.bodyHealth = 1000
										modifications.engineHealth = 1000
										modifications.tankHealth = 1000
										modifications.dirtLevel = 0
										modifications.fuelLevel = 100
										v.mods = json.encode(modifications)
									end
									MenuGaraOptions[#MenuGaraOptions + 1] = {
										header = QBCore.Shared.Vehicles[v.vehicle].name,
										txt = Lang:t('info.vehicle_info', {plate = v.plate, fuel = currentFuel, engine = enginePercent, body = bodyPercent, tank = petrolTankPercent, dirt = dirtPercent}),
										params = {
											event = 'MojiaGarages:client:TakeOutVehicle',
											args = v
										}
									}
								end
							elseif v.state == 0 then
								if v.depotprice > 0 then
									if OutsideVehicles ~= nil and next(OutsideVehicles) ~= nil and OutsideVehicles[v.plate] ~= nil and isVehicleExistInRealLife(v.plate) then
									
									else
										if not isVehicleExistInRealLife(v.plate) then
											local modifications = json.decode(v.mods)
											bodyPercent = QBCore.Shared.Round(modifications.bodyHealth / 10, 0)
											enginePercent = QBCore.Shared.Round(modifications.engineHealth / 10, 0)								
											petrolTankPercent = QBCore.Shared.Round(modifications.tankHealth / 10, 0)
											dirtPercent = QBCore.Shared.Round((modifications.dirtLevel/15)*100, 0)
											currentFuel = QBCore.Shared.Round(modifications.fuelLevel, 0)
											if Garages[currentgarage].fullfix then
												modifications.bodyHealth = 1000
												modifications.engineHealth = 1000
												modifications.tankHealth = 1000
												modifications.dirtLevel = 0
												modifications.fuelLevel = 100
												v.mods = json.encode(modifications)
											end
											MenuGaraOptions[#MenuGaraOptions + 1] = {
												header = QBCore.Shared.Vehicles[v.vehicle].name,
												txt = Lang:t('info.vehicle_info_and_price', {price = v.depotprice, plate = v.plate, fuel = currentFuel, engine = enginePercent, body = bodyPercent, tank = petrolTankPercent, dirt = dirtPercent}),
												params = {
													event = 'MojiaGarages:client:TakeOutVehicle',
													args = v
												}
											}
										end
									end
								end
							else
								local modifications = json.decode(v.mods)
								bodyPercent = QBCore.Shared.Round(modifications.bodyHealth / 10, 0)
								enginePercent = QBCore.Shared.Round(modifications.engineHealth / 10, 0)								
								petrolTankPercent = QBCore.Shared.Round(modifications.tankHealth / 10, 0)
								dirtPercent = QBCore.Shared.Round((modifications.dirtLevel/15)*100, 0)
								currentFuel = QBCore.Shared.Round(modifications.fuelLevel, 0)
								if Garages[currentgarage].fullfix then
									modifications.bodyHealth = 1000
									modifications.engineHealth = 1000
									modifications.tankHealth = 1000
									modifications.dirtLevel = 0
									modifications.fuelLevel = 100
									v.mods = json.encode(modifications)
								end
								MenuGaraOptions[#MenuGaraOptions + 1] = {
									header = QBCore.Shared.Vehicles[v.vehicle].name,
									txt = Lang:t('info.vehicle_info', {plate = v.plate, fuel = currentFuel, engine = enginePercent, body = bodyPercent, tank = petrolTankPercent, dirt = dirtPercent}),
									params = {
										event = 'MojiaGarages:client:TakeOutVehicle',
										args = v
									}
								}
							end
						end
					end				
					exports['qb-menu']:openMenu(MenuGaraOptions)
				else
					QBCore.Functions.Notify(Lang:t('error.there_are_no_vehicles_in_the_garage'), 'error', 5000)
				end
			end)
		end
	end
end)

RegisterNetEvent('MojiaGarages:client:TakeOutVehicle', function(vehicle) -- Option to take the vehicle out
    if inGarageStation and currentgarage ~= nil and nearspawnpoint ~= nil then
		if vehicle.state == 0 and vehicle.depotprice > 0 then
			TriggerServerEvent('MojiaGarages:server:PayDepotPrice', vehicle)
			Wait(1000)
		else
			TriggerEvent('MojiaGarages:client:doTakeOutVehicle', vehicle)
		end
	end
end)

RegisterNetEvent('MojiaGarages:client:doTakeOutVehicle', function(vehicle) -- Take the vehicle out
    if inGarageStation and currentgarage ~= nil and nearspawnpoint ~= nil then
		local lastnearspawnpoint = nearspawnpoint		
		if not IsSpawnPointClear(vector3(Garages[currentgarage].spawnPoint[lastnearspawnpoint].x, Garages[currentgarage].spawnPoint[lastnearspawnpoint].y, Garages[currentgarage].spawnPoint[lastnearspawnpoint].z), 2.5) then
			QBCore.Functions.Notify(Lang:t('error.the_receiving_area_is_obstructed_by_something'), 'error', 2500)
			return
		else
			local properties = json.decode(vehicle.mods)
			Deleteveh(vehicle.plate)
			QBCore.Functions.SpawnVehicle(vehicle.vehicle, function(veh)
				SetVehicleModifications(veh, properties)
				if vehicle.plate ~= nil then
					OutsideVehicles[vehicle.plate] = veh
				end
				SetEntityHeading(veh, Garages[currentgarage].spawnPoint[lastnearspawnpoint].w)
				exports['LegacyFuel']:SetFuel(veh, properties.fuelLevel)
				TriggerServerEvent('MojiaGarages:server:updateVehicleState', 0, vehicle.plate, vehicle.garage)
				QBCore.Functions.Notify(Lang:t('success.take_out_x_out_of_x_garage', {vehicle = QBCore.Shared.Vehicles[vehicle.vehicle].name, garage = Garages[currentgarage].label}), 'success', 4500)
				TriggerEvent('vehiclekeys:client:SetOwner', QBCore.Functions.GetPlate(veh))
			end, Garages[currentgarage].spawnPoint[lastnearspawnpoint], true)
		end
	end
end)

RegisterNetEvent('MojiaGarages:client:trackVehicle', function(plate) -- Track Vehicle
    QBCore.Functions.TriggerCallback('MojiaGarages:server:getVehicleData', function(location)
		if location then
			if location.state == 1 then
				SetNewWaypoint(Garages[location.garage].blippoint.x, Garages[location.garage].blippoint.y)
				QBCore.Functions.Notify(Lang:t('success.your_vehicle_has_been_marked'), 'success')
			elseif location.state == 0 then
				if location.depotprice == 0 then
					SetNewWaypoint(location.posX, location.posY)
					QBCore.Functions.Notify(Lang:t('success.your_vehicle_has_been_marked'), 'success')
				else
					SetNewWaypoint(Garages['depot'].blippoint.x, Garages['depot'].blippoint.y)
					QBCore.Functions.Notify(Lang:t('success.your_vehicle_has_been_marked'), 'success')
				end
			else
				SetNewWaypoint(Garages['impound'].blippoint.x, Garages['impound'].blippoint.y)
				QBCore.Functions.Notify(Lang:t('success.your_vehicle_has_been_marked'), 'success')
			end
		end
	end, plate)
end)

RegisterNetEvent('MojiaGarages:client:storeVehicle', function() -- Store Vehicle
    if inGarageStation and currentgarage ~= nil then
		local lastcurrentgarage = currentgarage
		if Garages[lastcurrentgarage].garastate == 1 then
			local ped = PlayerPedId()
			local pos = GetEntityCoords(ped)
			local curVeh = QBCore.Functions.GetClosestVehicle(pos)
			if IsPedInAnyVehicle(ped) then
				curVeh = GetVehiclePedIsIn(ped)
			end
			local plate = QBCore.Functions.GetPlate(curVeh)
			local vehpos = GetEntityCoords(curVeh)
			if UsingMojiaVehiclekeys then 
				if exports['MojiaVehicleKeys']:CheckHasKey(plate) then
					if curVeh and #(pos - vehpos) < 7.5 then
						QBCore.Functions.TriggerCallback('MojiaGarages:server:checkVehicleOwner', function(owned)
							if owned then
								
								if IsPedInAnyVehicle(ped) then
									CheckPlayers(curVeh)
								else
									local networkId = NetworkGetNetworkIdFromEntity(curVeh)
									TriggerEvent('MojiaGarages:client:updateVehicle', networkId)
									Wait(100)
									QBCore.Functions.DeleteVehicle(curVeh)
								end
								TriggerServerEvent('MojiaGarages:server:updateVehicleState', 1, plate, lastcurrentgarage)
								if plate ~= nil then
									OutsideVehicles[plate] = nil
								end
								QBCore.Functions.Notify(Lang:t('success.vehicle_parked_in_x', {garage = Garages[lastcurrentgarage].label}), 'success', 4500)
							else
								QBCore.Functions.Notify(Lang:t('error.nobody_owns_this_vehicle'), 'error', 3500)
							end
						end, plate)
					end
				end
			else
				if exports['qb-vehiclekeys']:HasVehicleKey(plate) then
					if curVeh and #(pos - vehpos) < 7.5 then
						QBCore.Functions.TriggerCallback('MojiaGarages:server:checkVehicleOwner', function(owned)
							if owned then
								
								if IsPedInAnyVehicle(ped) then
									CheckPlayers(curVeh)
								else
									local networkId = NetworkGetNetworkIdFromEntity(curVeh)
									TriggerEvent('MojiaGarages:client:updateVehicle', networkId)
									Wait(100)
									QBCore.Functions.DeleteVehicle(curVeh)
								end
								TriggerServerEvent('MojiaGarages:server:updateVehicleState', 1, plate, lastcurrentgarage)
								if plate ~= nil then
									OutsideVehicles[plate] = nil
								end
								QBCore.Functions.Notify(Lang:t('success.vehicle_parked_in_x', {garage = Garages[lastcurrentgarage].label}), 'success', 4500)
							else
								QBCore.Functions.Notify(Lang:t('error.nobody_owns_this_vehicle'), 'error', 3500)
							end
						end, plate)
					end
				end
			end
		end
	end
end)

RegisterNetEvent('MojiaGarages:client:openJobVehList', function() --Job Vehicles Menu
	PlayerData = QBCore.Functions.GetPlayerData()
	if lastjobveh ~= nil then
		QBCore.Functions.Notify(Lang:t('error.you_need_to_return_the_car_you_received_before_so_you_can_get_a_new_one'), 'error', 3500)
	else
		local vehicleMenu = {
			{
				header = Lang:t('info.job_vehicle_menu_header', {grade = PlayerData.job.grade.name}),
				isMenuHeader = true
			}
		}
		vehicleMenu[#vehicleMenu + 1] = {
			header = Lang:t('info.close_menu'),
			txt = '',
			params = {
				event = 'qb-menu:closeMenu',
			}
		}
		for k, v in pairs(JobVeh[PlayerData.job.name][currentgarage].vehicle[PlayerData.job.grade.level]) do
			local plate = JobVeh[PlayerData.job.name][currentgarage].plate .. tostring(math.random(1000, 9999))
			vehicleMenu[#vehicleMenu + 1] = {
				header = v.name,
				txt = Lang:t('info.vehicle_info', {plate = plate, fuel = 100, engine = 100, body = 100, tank = 100, dirt = 0}),
				params = {
					event = 'MojiaGarages:client:SpawnJobVeh',
					args = {
						model = k,
						plate = plate,
						livery = v.livery,
						modType = v.modType,
						modIndex = v.modIndex,
					}
				}
			}
		end		
		exports['qb-menu']:openMenu(vehicleMenu)
	end
end)

RegisterNetEvent('MojiaGarages:client:SpawnJobVeh', function(data) -- Take vehicle for job
	local pos = nil
	local header = nil
	local lastnearspawnpoint = nearspawnpoint
	local lastnearjobspawnpoint = GetNearJobSpawnPoint()
	if JobVeh[PlayerData.job.name][currentgarage].useJobspawnPoint then
		pos = JobVeh[PlayerData.job.name][currentgarage].spawnPoint[lastnearjobspawnpoint]
		header = JobVeh[PlayerData.job.name][currentgarage].spawnPoint[lastnearjobspawnpoint].w
	else
		pos = Garages[currentgarage].spawnPoint[lastnearspawnpoint]
		header = Garages[currentgarage].spawnPoint[lastnearspawnpoint].w
	end
	QBCore.Functions.SpawnVehicle(data.model, function(veh)
        SetJobVehItems(PlayerData.job.name)
		if data.livery ~= nil then
			SetVehicleLivery(veh, data.livery)
		end
		if data.modType ~= nil and data.modIndex ~= nil then
			SetVehicleMod(veh, data.modType, data.modIndex)
		end
		SetVehicleNumberPlateText(veh, data.plate)
        SetEntityHeading(veh, header)
        exports['LegacyFuel']:SetFuel(veh, 100.0)
        TriggerEvent('vehiclekeys:client:SetOwner', QBCore.Functions.GetPlate(veh))
		TriggerServerEvent('inventory:server:addTrunkItems', QBCore.Functions.GetPlate(veh), VehJobItems[PlayerData.job.name])
		lastjobveh = veh
    end, pos, true)
end)

RegisterNetEvent('MojiaGarages:client:HideJobVeh', function() -- Hide vehicle for job
	local ped = PlayerPedId()
	local pos = GetEntityCoords(ped)
	local curVeh = QBCore.Functions.GetClosestVehicle(pos)
	if IsPedInAnyVehicle(ped) then
		curVeh = GetVehiclePedIsIn(ped)
	end
	local plate = QBCore.Functions.GetPlate(curVeh)
	if UsingMojiaVehiclekeys then 
		if exports['MojiaVehicleKeys']:CheckHasKey(plate) then
			if IsPedInAnyVehicle(ped) then
				CheckPlayers(curVeh)
			else
				QBCore.Functions.DeleteVehicle(curVeh)
			end
			lastjobveh = nil
		end
	else
		if exports['qb-vehiclekeys']:HasVehicleKey(plate) then
			if IsPedInAnyVehicle(ped) then
				CheckPlayers(curVeh)
			else
				QBCore.Functions.DeleteVehicle(curVeh)
			end
			lastjobveh = nil
		end
	end
end)

RegisterNetEvent('MojiaGarages:client:updateVehicleKey', function(plate) -- Update vehicle key for qb-vehiclekey
	QBCore.Functions.TriggerCallback('MojiaGarages:server:getVehicleData', function(owner)
		if owner ~= nil then
			TriggerServerEvent('MojiaGarages:server:updateOutSiteVehicleKeys', plate, owner.citizenid)
		end
	end, plate)
end)

-- Thread

CreateThread(function() -- Get nearest spawn point
	while true do
		Wait(1000)
		if inGarageStation and currentgarage ~= nil then
			nearspawnpoint = GetNearSpawnPoint()
		end
	end
end)

CreateThread(function() --Save vehicle data on real times
	while (true) do
		local ped = PlayerPedId()
		if IsPedInAnyVehicle(ped) then
			local curVeh = GetVehiclePedIsIn(ped)
			local plate = QBCore.Functions.GetPlate(curVeh)
			if NetworkGetEntityIsNetworked(curVeh) and DoesEntityExist(curVeh) then
				QBCore.Functions.TriggerCallback('MojiaGarages:server:checkHasVehicleOwner', function(hasowned)
					if hasowned then					
						QBCore.Functions.TriggerCallback('MojiaGarages:server:getVehicleData', function(VehicleData)
							if VehicleData then					
								local networkId = NetworkGetNetworkIdFromEntity(curVeh)
								TriggerEvent('MojiaGarages:client:updateVehicle', networkId)
							end
						end, plate)
					end
				end, plate)
			end
		end
		Wait(3000)
	end
end)

CreateThread(function() -- loop to spawn vehicles near players
	while (true) do
		local Ped = PlayerPedId()		
		if DoesEntityExist(Ped) then
			local gameVehicles = QBCore.Functions.GetVehicles()
			local PedCoord = GetEntityCoords(Ped)
			QBCore.Functions.TriggerCallback('MojiaGarages:server:getAllVehicle', function(allvehicles)
				if allvehicles then					
					for k, v in pairs(allvehicles) do
						if not isVehicleExistInRealLife(v.plate) then
							if v.state == 0 and v.depotprice == 0 then
								if #(PedCoord - vector3(v.posX, v.posY, v.posZ)) < spawnDistance then
									local properties = json.decode(v.mods)
									QBCore.Functions.SpawnVehicle(v.vehicle, function(veh)
										SetVehicleModifications(veh, properties)
										SetEntityRotation(veh, vector3(v.rotX, v.rotY, v.rotZ))
										exports['LegacyFuel']:SetFuel(veh, properties.fuelLevel)
									end, vector3(v.posX, v.posY, v.posZ), true)
								end
							end							
						else
							if v.state ~= 0 or v.depotprice ~= 0 then
								Deleteveh(v.plate)
							end
						end
					end
				end
			end)
		end
		Wait(3000)
	end
end)

CreateThread(function() -- Check if the player is in the garage area or not
	while true do
		local Ped = PlayerPedId()
		local coord = GetEntityCoords(Ped)
		if Ped and coord and GarageLocation and next(GarageLocation) ~= nil then
			for k, v in pairs(GarageLocation) do
				if GarageLocation[k] then
					if GarageLocation[k]:isPointInside(coord) then
						inGarageStation = true
						currentgarage = k
						if Garages[k].job ~= nil then
							if PlayerData.job and not inJobStation[PlayerData.job.name] and k ~= 'impound' then
								inJobStation[PlayerData.job.name] = true
							end
						end				
						while inGarageStation do
							local InZoneCoordS = GetEntityCoords(Ped)
							if GarageLocation[k] and not GarageLocation[k]:isPointInside(InZoneCoordS) then
								inGarageStation = false
								currentgarage = nil
								if PlayerData.job and inJobStation[PlayerData.job.name] then
									inJobStation[PlayerData.job.name] = false
								end
							end
							Wait(1000)
						end
					end
				end
			end
		end
		Wait(1000)
	end
end)

-- export

exports('IsInGarage', IsInGarage)
exports('isInJobStation', isInJobStation)
