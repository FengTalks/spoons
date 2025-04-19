-- Window Resize Module
-- Resizes and centers the focused window to 1920x1080

local WindowResize = {}

-- 调整并居中窗口
function WindowResize.resizeAndCenterWindow()
    local window = hs.window.focusedWindow()
    if not window then return end
    
    local screen = window:screen()
    local screenFrame = screen:frame()
    
    local newFrame = {
        x = screenFrame.x + (screenFrame.w - 1920) / 2,
        y = screenFrame.y + (screenFrame.h - 1080) / 2,
        w = 1920,
        h = 1080
    }
    
    window:setFrame(newFrame)
end

-- 返回模块
return WindowResize