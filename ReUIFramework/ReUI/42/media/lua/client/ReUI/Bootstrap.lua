require "ReUI/core/ReUI"
require "ReUI/demo/ReUIDemoWindow"
require "ReUI/designer/ReUIDesignerWindow"
require "ReUI/examples/ReUIJournal"

local function onKeyPressed(key)
    if key == Keyboard.KEY_F8 then
        ReUI.Demo.toggle()
    elseif key == Keyboard.KEY_F9 then
        ReUI.Designer.toggle()
    elseif key == Keyboard.KEY_F10 then
        ReUI.Journal.toggle()
    end
end

Events.OnKeyPressed.Add(onKeyPressed)

Events.OnGameStart.Add(function()
    print("[Re:UI] v" .. ReUI.getVersion()
        .. " loaded. F8 Showcase, F9 Visual Designer, F10 Survivor Journal (example app).")
end)
