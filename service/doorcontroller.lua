DoorState={OPEN=0;CLOSED=1;OPENING=2;CLOSING=3;STOPPED=4;};

local loadDoorStateConfig = function(doorId)
  local doorState
  file.open("config/door." .. doorId .. ".status", "r")
  doorState = tonumber(file.readline())
  file.close()
  return {doorId = doorId, doorState = doorState}
end


local writeDoorStateConfig = function(doorId, doorState)
  file.open("config/door." .. doorId .. ".status", "w")
  file.writeline(tostring(doorState))
  file.flush()
  file.close()
end


local getConfiguredDoorList = function()
  local numberOfDoors = 1
  local doorList = {}
  -- Determine number of doors
  file.open("config/doors.conf", "r")
  numberOfDoors = tonumber(file.readline())
  file.close()
  -- Open doors configuration files
  for door = 1, numberOfDoors do
    file.open("config/door." .. door .. ".conf", "r")
    local currentDoor = {}
    -- Add door to door list
    currentDoor["doorName"] = file.readline()
    currentDoor["doorId"] = tonumber(file.readline())
    currentDoor["doorRelayGpio"] = tonumber(file.readline())
    currentDoor["doorStateGpio"] = tonumber(file.readline())
    currentDoor["doorOpenTime"] = tonumber(file.readline())
    currentDoor["doorCloseTime"] = tonumber(file.readline())
    file.close()
    table.insert(doorList, currentDoor)
  end
  return {doorList = doorList}
end


local init = function()
  local numberOfDoors = 1

  if file.open("config/doors.conf", "r") then
    numberOfDoors = tonumber(file.readline())
    print("Found doors configuration, controlling " .. numberOfDoors .. " doors")
    file.close()
  else
    -- Create file and set number of doors to 1
    print("No doors configured, set defaults to 1 door")
    file.open("config/doors.conf", "w")
    file.write(tostring(numberOfDoors))
    file.flush()
    file.close()
  end

  -- Open doors configuration files
  for door = 1, numberOfDoors do
    file.open("config/door." .. door .. ".conf", "r")
    -- Add door to door list
    local currentDoor = {}
    currentDoor["doorName"] = file.readline()
    currentDoor["doorId"] = tonumber(file.readline())
    currentDoor["doorRelayGpio"] = tonumber(file.readline())
    currentDoor["doorStateGpio"] = tonumber(file.readline())
    currentDoor["doorOpenTime"] = tonumber(file.readline())
    currentDoor["doorCloseTime"] = tonumber(file.readline())
    file.close()

    -- Init matching GPIOs
    gpio.mode(currentDoor.doorRelayGpio, gpio.OUTPUT)
    gpio.mode(currentDoor.doorStateGpio, gpio.INPUT, gpio.PULLUP)

    -- Setting startup status
    writeDoorStateConfig(door, gpio.read(currentDoor.doorStateGpio))
    print("Startup config for door " .. door .. " done")

    -- Monitor door status every 5 sec
    tmr.alarm(-1 + door, 5000, tmr.ALARM_AUTO, function()
      local stateGpio = currentDoor.doorStateGpio
      local doorStateConfig = loadDoorStateConfig(door)
      local doorId = currentDoor.doorId
      local sensorValue = gpio.read(stateGpio)
      local strPart
      if sensorValue ~= doorStateConfig.doorState then
        if sensorValue == 1 then strPart = "CLOSED" else strPart = "OPEN" end
        if file.exists("config/door." .. doorId .. ".operating") then
          -- Application action
          print("APP ACTION : Door " .. doorId .. " state changed to " .. strPart)
        else
          -- Exterior action, updating file
          print("EXTERIOR ACTION : Door " .. doorId .. " state changed to " .. strPart)
          -- Only two exterior cases managed because of magnetic switch
          if doorStateConfig.doorState == DoorState.OPEN then
            doorStateConfig.doorState = DoorState.CLOSED
          else
            doorStateConfig.doorState = DoorState.OPEN
          end
          writeDoorStateConfig(doorId, doorStateConfig.doorState)
        end
      end
    end)
  end
end


local setState = function(doorId, state, doorGpio, doorSensorGpio, duration)
  local door = loadDoorStateConfig(doorId)
  if (state == DoorState.CLOSED and door.doorState == DoorState.OPEN) or (state == DoorState.OPEN and door.doorState == DoorState.CLOSED) then
    file.open("config/door." .. doorId .. ".operating", "w")
    file.flush()
    file.close()
    if state == DoorState.CLOSED then
      writeDoorStateConfig(doorId, DoorState.CLOSING)
    else
      writeDoorStateConfig(doorId, DoorState.OPENING)
    end
    gpio.write(doorGpio, gpio.HIGH)
    -- Wait for 500ms to simulate a button push
    tmr.alarm(doorId*2, 500, tmr.ALARM_SINGLE, function()
      gpio.write(doorGpio, gpio.LOW)
      tmr.alarm(1 + (doorId*2), duration * 1000, tmr.ALARM_SINGLE, function()
        if gpio.read(doorSensorGpio) == 0 then
          writeDoorStateConfig(doorId, DoorState.CLOSED)
        else
          writeDoorStateConfig(doorId, DoorState.STOPPED)
        end
        file.remove("config/door." .. doorId .. ".operating")
      end)
    end)
  end
end


return { init = init, setState = setState, getConfiguredDoorList = getConfiguredDoorList, loadDoorStateConfig = loadDoorStateConfig, writeDoorStateConfig = writeDoorStateConfig }
