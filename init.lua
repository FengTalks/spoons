-- Hammerspoon 主配置文件

-- 加载模块
local Scroll = dofile(hs.fs.pathToAbsolute(hs.configdir .. "/scroll.lua"))
local WindowResize = dofile(hs.fs.pathToAbsolute(hs.configdir .. "/window_resize.lua"))
local KeyDisplay = dofile(hs.fs.pathToAbsolute(hs.configdir .. "/key_display.lua"))

-- 菜单栏
local menubar = nil

-- 更新菜单的函数
local function getMenu()
    return {
        { title = Scroll.isScrolling() and "Stop Scrolling" or "Start Scrolling", fn = function() Scroll.toggleScroll(menubar, getMenu) end },
        { title = "Center Window", fn = WindowResize.resizeAndCenterWindow },
        { title = KeyDisplay.isListening() and "Hide Keys" or "Show Keys", fn = function() KeyDisplay.toggleKeyDisplay(menubar, getMenu) end }
    }
end

-- 初始化菜单栏
menubar = hs.menubar.new()
--menubar:setTitle("Hammerspoon")
local iconPath = hs.fs.pathToAbsolute(hs.configdir .. "/icon.png")
menubar:setIcon(iconPath)
menubar:setMenu(getMenu())

-- 提示配置加载
hs.alert.show("Hammerspoon Config Loaded")