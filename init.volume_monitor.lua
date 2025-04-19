-- 监控系统音量并确保音量不低于50%，包括静音状态
local volumeWatcher = nil

-- 获取当前系统音量和静音状态
function getCurrentVolume()
    local output = hs.execute("osascript -e 'output volume of (get volume settings)'")
    return tonumber(output)
end

function isMuted()
    local output = hs.execute("osascript -e 'output muted of (get volume settings)'")
    return output:match("true") ~= nil
end

-- 设置系统音量并取消静音
function setVolume(level)
    hs.execute("osascript -e 'set volume with output muted false'")
    hs.execute(string.format("osascript -e 'set volume output volume %d'", level))
end

-- 检查音量并调整
function checkVolume()
    local currentVolume = getCurrentVolume()
    if isMuted() or (currentVolume and currentVolume < 50) then
        setVolume(50)
    end
end

-- 初始化函数
function init()
    -- 每2秒检查一次音量
    volumeWatcher = hs.timer.new(2, checkVolume)
    volumeWatcher:start()
end

-- 启动监控
init()
