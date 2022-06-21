local wfixing, wturn = false, false
local wcoords, wcolor = 0.0, 0
local positionwash = 0

Citizen.CreateThread(function()	
    while true do
		Citizen.Wait(5)	
		local playerPed = PlayerPedId()
		local pos = GetEntityCoords(playerPed, true)		
		for k,v in pairs(Config.WashStations) do
			if not wfixing then
				if(Vdist(pos.x, pos.y, pos.z, v.x, v.y, v.z) < 100) then
					if IsPedInAnyVehicle(playerPed, false) then
						DrawMarker(23, v.x, v.y, v.z-0.4, 0.0, 0.0, 0.0, 0, 0.0, 0.0, 1.2, 1.2, 1.2, 240, 200, 80, 100, false, true, 2, false, false, false, false)
						if(Vdist(pos.x, pos.y, pos.z, v.x, v.y, v.z) < 2.5) then							
							positionwash = k
							hintToDisplay('Appuyez sur ~o~[E]~w~ pour réparer le véhicule.')
							if IsControlJustPressed(0, 38) then	
								TriggerEvent('carwashfix:fixCar')						
								SetPedCoordsKeepVehicle(playerPed, v.x, v.y, v.z)
							end								
						end
					end
				end
			end
		end
    end
end)

RegisterNetEvent('carwashfix:markAnimation')
AddEventHandler('carwashfix:markAnimation', function()
    while true do
		Citizen.Wait(25)	
		if wfixing then
			if wcoords < 0.5 and not wturn then
				wcoords = wcoords + 0.03
				wcolor = wcolor + 2
			else
				wturn = true
				wcoords = wcoords - 0.051
				wcolor = wcolor + 2
				if wcoords <= -0.4 then
					wturn = false
				end
			end
		else
			break
		end
	end
end)

RegisterNetEvent('carwashfix:fixCar')
AddEventHandler('carwashfix:fixCar', function()
	local playerPed = PlayerPedId()
	local vehicle = GetVehiclePedIsIn(playerPed, false)
	wfixing = true
	TriggerEvent('carwashfix:markAnimation')
	FreezeEntityPosition(vehicle, true)
	SetVehicleEngineOn(GetVehiclePedIsIn(playerPed), false, false, true)
	SetVehicleDoorOpen(vehicle, 0, false, false)
	SetVehicleDoorOpen(vehicle, 1, false, false)
	SetVehicleDoorOpen(vehicle, 2, false, false)
	SetVehicleDoorOpen(vehicle, 3, false, false)
	Wait(Config.RepairTime)
	wfixing = false
	SetVehicleEngineOn(GetVehiclePedIsIn(playerPed), true, false, true)
	WashDecalsFromVehicle(vehicle, 0.8)
	SetVehicleDirtLevel(vehicle)
	SetVehicleDoorShut(vehicle, 0, false)
	SetVehicleDoorShut(vehicle, 1, false)
	SetVehicleDoorShut(vehicle, 2, false)
	SetVehicleDoorShut(vehicle, 3, false)
	FreezeEntityPosition(vehicle, false)
    notify('Le véhicule est ~y~nettoyer~w~.')
	wcoords, wcolor, wturn = 0.0, 0, false
end)

if Config.Blips then
	Citizen.CreateThread(function()
		for i=1, #Config.WashStations, 1 do
			local blip = AddBlipForCoord(Config.WashStations[i].x, Config.WashStations[i].y, Config.WashStations[i].z)

			SetBlipSprite (blip, 100)
			SetBlipScale  (blip, 0.6)
			SetBlipColour (blip, 5)
			SetBlipAsShortRange(blip, true)

			BeginTextCommandSetBlipName("STRING")
			AddTextComponentSubstringPlayerName('Lavage Automobile')
			EndTextCommandSetBlipName(blip)
		end
	end)
end

function hintToDisplay(text)
	SetTextComponentFormat("STRING")
	AddTextComponentString(text)
	DisplayHelpTextFromStringLabel(0, 0, 1, -1)
end

--notification
function notify(text)
    SetNotificationTextEntry("STRING")
    AddTextComponentString(text)
    DrawNotification(true, true)
end