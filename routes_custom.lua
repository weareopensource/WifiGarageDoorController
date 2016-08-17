local f = loadfile('router.lc')
-- load router
local router = f()
f = nil
collectgarbage("collect")
router.get("/state", "routes/state.get.lc")
local h = router.handler
router = nil
return h
