-- Scroll Module
-- Toggles continuous scrolling with a fixed speed

local Scroll = {}

-- 内部状态
local scrollSpeed = 1 -- Pixels per frame
local scrolling = false
local timer = nil

-- 检查是否在滚动
function Scroll.isScrolling()
    return scrolling
end

-- 切换滚动状态
function Scroll.toggleScroll(menubar, getMenuCallback)
    if scrolling then
        scrolling = false
        if timer then
            timer:stop()
            timer = nil
        end
    else
        scrolling = true
        timer = hs.timer.doEvery(1/60, function()
            hs.eventtap.event.newScrollEvent({0, -scrollSpeed}, {}, "pixel"):post()
        end)
    end
    -- 更新菜单
    if menubar and getMenuCallback then
        menubar:setMenu(getMenuCallback())
    end
end

-- 清理函数（用于重新加载）
function Scroll.cleanup()
    if scrolling then
        scrolling = false
        if timer then
            timer:stop()
            timer = nil
        end
    end
end

-- 返回模块
return Scroll