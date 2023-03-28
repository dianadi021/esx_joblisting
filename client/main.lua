local menuIsShowed, hasAlreadyEnteredMarker, isInMarker = false, false, false

ESX = nil
local PlayerData = {}
local dead = false
CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		PlayerData = ESX.GetPlayerData()
		Citizen.Wait(0)
	end

	Citizen.Wait(2000)
    ESX.TriggerServerCallback('esx_ambulancejob:getDeathStatus', function(isDead)
        dead = isDead
    end)
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
	for i=1, #Config.whitelistedJobs, 1 do
		if job.name == Config.whitelistedJobs[i] then
			TriggerServerEvent('esx_joblisting:setFirstJob', job.name, job.grade)
			--print(job.name.." - "..job.label.." - "..job.grade)
		end
	end
end)


function ShowJobListingMenu()
	ESX.TriggerServerCallback('esx_joblisting:getJobsList', function(jobs)
		local elements = {}

		for i=1, #jobs, 1 do
			table.insert(elements, {
				label = jobs[i].label,
				job   = jobs[i].job
			})
		end

		ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'joblisting', {
			title    = _U('job_center'),
			align    = 'top-left',
			elements = elements
		}, function(data, menu)
			TriggerServerEvent('esx_joblisting:setSecJob', data.current.job)
			exports['mythic_notify']:SendAlert('inform', _U('new_job'))
			--ESX.ShowNotification(_U('new_job'))
			menu.close()
		end, function(data, menu)
			menu.close()
		end)

	end)
end

AddEventHandler('esx_joblisting:hasExitedMarker', function(zone)
	ESX.UI.Menu.CloseAll()
end)

-- Activate menu when player is inside marker, and draw markers
CreateThread(function()
	while true do
		Wait(0)

		local coords = GetEntityCoords(PlayerPedId())
		isInMarker = false

		for i=1, #Config.Zones, 1 do
			local distance = #(coords - Config.Zones[i])

			if distance < Config.DrawDistance then
				DrawMarker(Config.MarkerType, Config.Zones[i], 0.0, 0.0, 0.0, 0, 0.0, 0.0, Config.ZoneSize.x, Config.ZoneSize.y, Config.ZoneSize.z, Config.MarkerColor.r, Config.MarkerColor.g, Config.MarkerColor.b, 100, false, true, 2, false, false, false, false)
			end

			if distance < (Config.ZoneSize.x / 2) then
				isInMarker = true
				ESX.ShowHelpNotification(_U('access_job_center'))
			end
		end

		if isInMarker and not hasAlreadyEnteredMarker then
			hasAlreadyEnteredMarker = true
		end

		if not isInMarker and hasAlreadyEnteredMarker then
			hasAlreadyEnteredMarker = false
			TriggerEvent('esx_joblisting:hasExitedMarker')
		end
	end
end)

-- Create blips
CreateThread(function()
	for i=1, #Config.Zones, 1 do
		local blip = AddBlipForCoord(Config.Zones[i])

		SetBlipSprite (blip, 407)
		SetBlipDisplay(blip, 4)
		SetBlipScale  (blip, 0.75)
		SetBlipColour (blip, 27)
		SetBlipAsShortRange(blip, true)

		BeginTextCommandSetBlipName("STRING")
		AddTextComponentSubstringPlayerName(_U('job_center'))
		EndTextCommandSetBlipName(blip)
	end
end)

local open = false
-- Menu Controls
CreateThread(function()
	while true do
		Wait(30)

		if IsControlJustReleased(0, 38) and isInMarker and not menuIsShowed then
			ESX.UI.Menu.CloseAll()
			ShowJobListingMenu()
		end
	end
end)

function openChangeJobs(tempopen)
	ESX.TriggerServerCallback('esx_joblisting:haveSecJob', function(hasJobs, isEmpty)
		if isEmpty then
			for i=1, #hasJobs, 1 do
				SendNUIMessage({
					action = tempopen;
					firstJobName = hasJobs[i].firstJob;
					firstJob = hasJobs[i].firstJobLabel;
					firstGrade = hasJobs[i].firstGrade;
					secJobName = hasJobs[i].secJob;
					secJob = hasJobs[i].secJobLabel;
				})
			end
		else
			SendNUIMessage({
				action = tempopen;
			})
		end
		
		if tempopen then
			SetNuiFocus(true, true)
		else
			SetNuiFocus(false, false)
		end
	end)
end

RegisterCommand('cJobs', function()
	if not isDead then
		open = not open
		openChangeJobs(open)
	end
end, false)

RegisterNUICallback('cJobs', function(data, cb)
    -- Clear focus and destroy UI
    open = false
	openChangeJobs(open)
end)

RegisterNUICallback('setFirstJobs', function(data, cb)
    -- Clear focus and destroy UI
	--print(data.jobsName.." - "..data.jobsGrade)
	TriggerServerEvent('esx_joblisting:setJobFromButton', data.jobsName, data.jobsGrade)
end)

RegisterNUICallback('setSecJobs', function(data, cb)
    -- Clear focus and destroy UI
	--print(data.jobsName)
	TriggerServerEvent('esx_joblisting:setJobFromButton', data.jobsName, 0)
end)

RegisterKeyMapping('cJobs', 'Open Change Jobs', 'keyboard', 'F6')