return function(req, res)
 local doorcontroller = loadfile("service/doorcontroller.lc")()
 local doors = doorcontroller.getConfiguredDoorList()
 local resData = {}

 for i, door in ipairs(doors.doorList) do
   local stateData = doorcontroller.loadDoorStateConfig(door.doorId)
   local currentElement = {}
   currentElement["name"] = door.doorName
   currentElement["id"] = door.doorId

   if stateData.doorState == DoorState.OPEN then
     currentElement["state"] = "open"
   elseif stateData.doorState == DoorState.CLOSED then
     currentElement["state"] = "closed"
   elseif stateData.doorState == DoorState.CLOSING then
     currentElement["state"] = "closing"
   elseif stateData.doorState == DoorState.OPENING then
     currentElement["state"] = "opening"
   else
     currentElement["state"] = "stopped"
   end
   table.insert(resData, currentElement)
 end

 ok, json = pcall(cjson.encode, resData)
 res:addheader("Content-Type", "application/json; charset=utf-8")
 res:send(json)
end
