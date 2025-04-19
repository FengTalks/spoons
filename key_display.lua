-- Key Display Module
-- Displays any key combination (Ctrl, Opt, Shift, Cmd) in a centered canvas

local KeyDisplay = {}

-- 全局变量（模块内部）
local keyDisplayCanvas = nil
local keyDisplayTimer = nil
local eventTap = nil
local isListening = false

-- 快捷键映射，将修饰键转换为符号
local modifierSymbols = {
    cmd = "⌘",
    shift = "⇧",
    alt = "⌥",
    ctrl = "⌃"
}

-- 创建显示窗口
function KeyDisplay.createKeyDisplay()
    if keyDisplayCanvas then
        keyDisplayCanvas:delete()
    end

    keyDisplayCanvas = hs.canvas.new({
        x = 0,
        y = 0,
        w = 300,
        h = 100
    })

    -- 设置窗口居中
    local screen = hs.screen.mainScreen()
    local frame = screen:frame()
    keyDisplayCanvas:frame({
        x = (frame.w - 300) / 2,
        y = (frame.h - 100) / 2,
        w = 300,
        h = 100
    })

    -- 添加半透明背景
    keyDisplayCanvas:appendElements({
        type = "rectangle",
        action = "fill",
        fillColor = { red = 0, green = 0, blue = 0, alpha = 0.7 },
        roundedRectRadii = { xRadius = 10, yRadius = 10 }
    })

    -- 添加文字占位
    keyDisplayCanvas:appendElements({
        type = "text",
        action = "fill",
        text = "",
        textSize = 24,
        textColor = { red = 1, green = 1, blue = 1, alpha = 1 },
        textAlignment = "center",
        frame = { x = 0, y = 30, w = 300, h = 40 }
    })
end

-- 显示按下的键
function KeyDisplay.showKeys(modifiers, key)
    -- 过滤仅 Shift + 单键的组合
    local modCount = (modifiers.ctrl and 1 or 0) + (modifiers.alt and 1 or 0) + (modifiers.shift and 1 or 0) + (modifiers.cmd and 1 or 0)
    if modCount == 1 and modifiers.shift then
        return -- 不显示 Shift + 单键
    end

    if not keyDisplayCanvas then
        KeyDisplay.createKeyDisplay()
    end

    -- 构建显示的键字符串（修饰键间无 +，修饰键与主键间有 +）
    local keyString = ""
    local mods = { "ctrl", "alt", "shift", "cmd" } -- 按顺序显示修饰键
    for _, mod in ipairs(mods) do
        if modifiers[mod] and modifierSymbols[mod] then
            keyString = keyString .. modifierSymbols[mod]
        end
    end
    if keyString ~= "" then
        keyString = keyString .. " + "
    end
    keyString = keyString .. string.upper(key)

    -- 更新 Canvas 文字
    keyDisplayCanvas[2].text = keyString
    keyDisplayCanvas:show()

    -- 重置定时器，1秒后隐藏
    if keyDisplayTimer then
        keyDisplayTimer:stop()
    end
    keyDisplayTimer = hs.timer.doAfter(1, function()
        if keyDisplayCanvas then
            keyDisplayCanvas:hide()
        end
    end)
end

-- 清理 Canvas 和定时器
function KeyDisplay.clearKeyDisplay()
    if keyDisplayCanvas then
        keyDisplayCanvas:delete()
        keyDisplayCanvas = nil
    end
    if keyDisplayTimer then
        keyDisplayTimer:stop()
        keyDisplayTimer = nil
    end
end

-- 使用 hs.eventtap 监听所有按键
function KeyDisplay.bindKeyEvents()
    if eventTap then
        eventTap:stop()
    end

    eventTap = hs.eventtap.new({hs.eventtap.event.types.keyDown}, function(event)
        local keyCode = event:getKeyCode()
        local modifiers = event:getFlags()
        local key = hs.keycodes.map[keyCode]

        -- 确保 key 有效（避免特殊键或未映射键）
        if key then
            -- 构建修饰键表
            local modTable = {
                ctrl = modifiers.ctrl,
                alt = modifiers.alt,
                shift = modifiers.shift,
                cmd = modifiers.cmd
            }

            -- 只有当至少有一个修饰键或有效主键时显示
            if modTable.ctrl or modTable.alt or modTable.shift or modTable.cmd then
                KeyDisplay.showKeys(modTable, key)
            end
        end

        -- 不阻止事件，允许系统处理
        return false
    end)

    eventTap:start()
end

-- 检查是否在监听
function KeyDisplay.isListening()
    return isListening
end

-- 切换监听状态
function KeyDisplay.toggleKeyDisplay(menubar, getMenuCallback)
    if isListening then
        KeyDisplay.cleanup()
        isListening = false
        hs.alert.show("Key Display Stopped") -- 调试信息
    else
        KeyDisplay.init()
        isListening = true
        hs.alert.show("Key Display Started") -- 调试信息
    end
    -- 更新菜单
    if menubar and getMenuCallback then
        menubar:setMenu(getMenuCallback())
    end
end

-- 初始化函数
function KeyDisplay.init()
    KeyDisplay.clearKeyDisplay()
    KeyDisplay.createKeyDisplay()
    KeyDisplay.bindKeyEvents()
    isListening = true
end

-- 清理函数（用于重新加载或卸载）
function KeyDisplay.cleanup()
    KeyDisplay.clearKeyDisplay()
    if eventTap then
        eventTap:stop()
        eventTap = nil
    end
    isListening = false
end

-- 返回模块
return KeyDisplay