local availableJobs = {}
local availableJobsWhitelisted = {}
local haveSecJob = {}

MySQL.ready(function()
	MySQL.query('SELECT name, label FROM jobs WHERE whitelisted = @whitelisted', {
		['@whitelisted'] = false
	}, function(result)
		for i=1, #result, 1 do
			table.insert(availableJobs, {
				job = result[i].name,
				label = result[i].label
			})
		end
	end)
end)

MySQL.ready(function()
	MySQL.query('SELECT name, label FROM jobs WHERE whitelisted = @whitelisted', {
		['@whitelisted'] = true
	}, function(result)
		for i=1, #result, 1 do
			table.insert(availableJobsWhitelisted, {
				job = result[i].name,
				label = result[i].label
			})
		end
	end)
end)

ESX.RegisterServerCallback('esx_joblisting:getJobsList', function(source, cb)
	cb(availableJobs)
end)

ESX.RegisterServerCallback('esx_joblisting:haveSecJob', function(source, cb)
	local xPlayer = ESX.GetPlayerFromId(source)
	MySQL.query('SELECT identifier, firstJob, firstJobLabel, firstGrade, secJob, secJobLabel FROM sec_jobs WHERE identifier = @identifier', {
		['@identifier'] = xPlayer.identifier
	}, function(result)
		for i=1, #result, 1 do
			table.insert(haveSecJob, {
				identifier = result[i].identifier,
				firstJob = result[i].firstJob,
				firstJobLabel = result[i].firstJobLabel,
				firstGrade = result[i].firstGrade,
				secJob = result[i].secJob,
				secJobLabel = result[i].secJobLabel,
			})
		end
		if result ~= nil then
			cb(haveSecJob, true)
		else
			cb(haveSecJob, false)
		end
	end)
end)

RegisterServerEvent('esx_joblisting:setSecJob')
AddEventHandler('esx_joblisting:setSecJob', function(setJob)
	local xPlayer = ESX.GetPlayerFromId(source)

	local _xPlayers = ESX.GetExtendedPlayers()
	local count = #_xPlayers
	local parameters = {}
	for i=1, count do
		local xPlayer = _xPlayers[i]
		parameters[#parameters+1] = {
			setJob,
			xPlayer.identifier
		}
	end

	if xPlayer then
		for k,v in ipairs(availableJobs) do
			if v.job == setJob then
				xPlayer.setJob(setJob, 0)
				MySQL.scalar('SELECT secJob FROM sec_jobs WHERE identifier = ?', {xPlayer.identifier},
				function(getIsHaveSecJob)
					if getIsHaveSecJob ~= nil then
						MySQL.Sync.execute('UPDATE sec_jobs SET secJob = @secJob, secJobLabel = @secJobLabel WHERE identifier = @identifier', {['@identifier'] = xPlayer.identifier, ['@secJob'] = setJob, ['@secJobLabel'] = v.label})
					else
						MySQL.insert('INSERT INTO sec_jobs (identifier, firstJob, secJob, secJobLabel) VALUES (?, ?, ?, ?)', {xPlayer.identifier, false, setJob, v.label}, function(rowsChanged)if cb then end end)
					end
				end)
				MySQL.prepare("UPDATE `users` SET `job` = ? WHERE `identifier` = ?", parameters, function(results)if results then end end)
				break
			end
		end
	end
end)

RegisterServerEvent('esx_joblisting:setFirstJob')
AddEventHandler('esx_joblisting:setFirstJob', function(setJob, jobGrade)
	local xPlayer = ESX.GetPlayerFromId(source)

	local _xPlayers = ESX.GetExtendedPlayers()
	local count = #_xPlayers
	local parameters = {}
	for i=1, count do
		local xPlayer = _xPlayers[i]
		parameters[#parameters+1] = {
			setJob,
			xPlayer.identifier
		}
	end

	if xPlayer then
		for k,v in ipairs(availableJobsWhitelisted) do
			if v.job == setJob then
				MySQL.scalar('SELECT firstJob FROM sec_jobs WHERE identifier = ?', {xPlayer.identifier},
				function(getIsHaveSecJob)
					if getIsHaveSecJob ~= nil then
						MySQL.Sync.execute('UPDATE sec_jobs SET firstJob = @firstJob, firstJobLabel = @firstJobLabel, firstGrade = @firstGrade WHERE identifier = @identifier', {['@identifier'] = xPlayer.identifier, ['@firstJob'] = setJob, ['@firstJobLabel'] = v.label, ['@firstGrade'] = jobGrade})
					else
						MySQL.insert('INSERT INTO sec_jobs (identifier, firstJob, firstJobLabel, firstGrade) VALUES (?, ?, ?, ?)', {xPlayer.identifier, setJob, v.label, jobGrade}, function(rowsChanged)if cb then end end)
					end
				end)
				MySQL.prepare("UPDATE `users` SET `job` = ? WHERE `identifier` = ?", parameters, function(results)if results then end end)
				break
			elseif setJob == 'unemployed' then
				MySQL.scalar('SELECT firstJob FROM sec_jobs WHERE identifier = ?', {xPlayer.identifier},
				function(getIsHaveSecJob)
					if getIsHaveSecJob ~= nil then
						MySQL.Sync.execute('UPDATE sec_jobs SET firstJob = @firstJob, firstJobLabel = @firstJobLabel, firstGrade = @firstGrade WHERE identifier = @identifier', {['@identifier'] = xPlayer.identifier, ['@firstJob'] = setJob, ['@firstJobLabel'] = "Warga", ['@firstGrade'] = jobGrade})
					else
						MySQL.insert('INSERT INTO sec_jobs (identifier, firstJob, firstJobLabel, firstGrade) VALUES (?, ?, ?, ?)', {xPlayer.identifier, setJob, "Warga", jobGrade}, function(rowsChanged)if cb then end end)
					end
				end)
				MySQL.prepare("UPDATE `users` SET `job` = ? WHERE `identifier` = ?", parameters, function(results)if results then end end)
				break
			end
		end
	end
end)

--[[
	if v1.job == "unemployed" then
	for k2,v2 in ipairs(haveFirstJob) do
		if v2.hasJob == nil then
			MySQL.insert('INSERT INTO sec_jobs (identifier, secJob, hasJob) VALUES (?, ?, ?)', {xPlayer.identifier, setJob, 1},
			function(rowsChanged)
				if cb then
					print(v1.job)
					print(setJob)
					cb()
				end
			end)
			break
		else
			MySQL.Sync.execute('UPDATE sec_jobs SET secJob = @secJob WHERE identifier = @identifier', {
				['@identifier'] = xPlayer.identifier,
				['@secJob'] = setJob
			})
			break
		end
	end
else
	MySQL.Sync.execute('UPDATE sec_jobs SET secJob = @secJob WHERE identifier = @identifier', {
		['@identifier'] = xPlayer.identifier,
		['@secJob'] = setJob
	})
	break
end

for k1,v1 in ipairs(haveJob) do
	if v1.job == "unemployed" then
		
		break
	else
		MySQL.Sync.execute('UPDATE sec_jobs SET secJob = @secJob WHERE identifier = @identifier', {
			['@identifier'] = xPlayer.identifier,
			['@secJob'] = setJob
		})
		break
	end
end
]]