require "ReUI/components/ReUIWindow"
require "ReUI/components/ReUIButton"
require "ReUI/components/ReUILabel"
require "ReUI/components/ReUITextBox"
require "ReUI/components/ReUITabs"
require "ReUI/components/ReUIListView"
require "ReUI/managers/ReUIWindowManager"
require "ReUI/core/ReUITheme"

-- A small, genuinely useful example app built entirely from ReUI parts:
-- a dockable survivor journal with a persistent quick note and a
-- persistent task list, both saved to disk via getFileReader/getFileWriter
-- (the same sandboxed-file API used by the Visual Designer's Save/Load).
-- Meant as a template for "how do I actually build a UI with this
-- framework" — see docs/API-Reference.md.
local JournalWindow = ReUIWindow:derive("ReUIJournalWindow")
ReUI.Journal = ReUI.Journal or {}
ReUI.Journal.instance = nil

local NOTE_FILE = "ReUI_Journal_Note.txt"
local TASKS_FILE = "ReUI_Journal_Tasks.txt"

function JournalWindow:new()
    local o = ReUIWindow.new(self, 0, 0, 340, 420, "Survivor Journal")
    o.subtitle = "Notes & Tasks"
    o.tasks = {}
    return o
end

function JournalWindow:createChildren()
    ReUIWindow.createChildren(self)

    local top = self:getTitleBarHeight() + 8
    local inset = 10
    local width = self.width - inset * 2
    local height = self.height - top - inset

    self.tabs = ReUITabs:new(inset, top, width, height, {})
    self.tabs:initialise()
    self.tabs:instantiate()
    self:addChild(self.tabs)

    self:buildNotesTab(self.tabs:addTab("Notes"))
    self:buildTasksTab(self.tabs:addTab("Tasks"))

    self:loadNote()
    self:loadTasks()
end

function JournalWindow:buildNotesTab(page)
    local label = ReUILabel:new(8, 8, page.width - 16, 20, "Quick note (autosaves on Enter):", {
        colorRole = "textMuted"
    })
    label:initialise()
    label:instantiate()
    page:addChild(label)

    self.noteBox = ReUITextBox:new(8, 32, page.width - 16, ReUITheme.metric("controlHeight", 32), {
        placeholder = "Type a note and press Enter...",
        target = self,
        onEnter = JournalWindow.onNoteEntered
    })
    self.noteBox:initialise()
    self.noteBox:instantiate()
    page:addChild(self.noteBox)

    self.noteStatus = ReUILabel:new(8, 72, page.width - 16, 20, "", { colorRole = "success" })
    self.noteStatus:initialise()
    self.noteStatus:instantiate()
    page:addChild(self.noteStatus)
end

function JournalWindow:onNoteEntered(control, text)
    local writer = getFileWriter(NOTE_FILE, true, false)
    writer:write(text .. "\n")
    writer:close()
    self.noteStatus:setText("Saved.")
end

function JournalWindow:loadNote()
    local reader = getFileReader(NOTE_FILE, true)
    local line = reader:readLine()
    reader:close()
    if line then
        self.noteBox:setText(line)
    end
end

function JournalWindow:buildTasksTab(page)
    local inputHeight = ReUITheme.metric("controlHeight", 32)

    self.taskInput = ReUITextBox:new(8, 8, page.width - 16 - 70, inputHeight, {
        placeholder = "New task...",
        target = self,
        onEnter = JournalWindow.onTaskEntered
    })
    self.taskInput:initialise()
    self.taskInput:instantiate()
    page:addChild(self.taskInput)

    self.addTaskButton = ReUIButton:new(page.width - 70, 8, 62, inputHeight, "Add", self, JournalWindow.onAddTask)
    self.addTaskButton:setVariant("primary")
    self.addTaskButton:initialise()
    self.addTaskButton:instantiate()
    page:addChild(self.addTaskButton)

    self.taskList = ReUIListView:new(8, 8 + inputHeight + 8, page.width - 16, page.height - inputHeight - 60, {})
    self.taskList:initialise()
    self.taskList:instantiate()
    page:addChild(self.taskList)
    self.taskList:on("select", function() end)

    local buttonY = page.height - 38
    self.completeButton = ReUIButton:new(8, buttonY, (page.width - 16 - 8) / 2, 32,
        "Toggle Done", self, JournalWindow.onToggleTask)
    self.completeButton:setVariant("secondary")
    self.completeButton:initialise()
    self.completeButton:instantiate()
    page:addChild(self.completeButton)

    self.removeButton = ReUIButton:new(8 + (page.width - 16 - 8) / 2 + 8, buttonY, (page.width - 16 - 8) / 2, 32,
        "Remove", self, JournalWindow.onRemoveTask)
    self.removeButton:setVariant("danger")
    self.removeButton:initialise()
    self.removeButton:instantiate()
    page:addChild(self.removeButton)
end

function JournalWindow:onTaskEntered(control, text)
    if text == "" then return end
    self:addTask(text, false)
    self.taskInput:setText("")
    self:saveTasks()
end

function JournalWindow:onAddTask()
    local text = self.taskInput:getText()
    if text == "" then return end
    self:addTask(text, false)
    self.taskInput:setText("")
    self:saveTasks()
end

function JournalWindow:addTask(text, done)
    table.insert(self.tasks, { text = text, done = done == true })
    self:refreshTaskList()
end

function JournalWindow:refreshTaskList()
    self.taskList:clear()
    for i, task in ipairs(self.tasks) do
        local label = (task.done and "[x] " or "[ ] ") .. task.text
        self.taskList:addItem(label, i)
    end
end

function JournalWindow:onToggleTask()
    local selected = self.taskList:getSelected()
    if not selected then return end
    local task = self.tasks[selected.data]
    if task then
        task.done = not task.done
        self:refreshTaskList()
        self:saveTasks()
    end
end

function JournalWindow:onRemoveTask()
    local selected = self.taskList:getSelected()
    if not selected then return end
    table.remove(self.tasks, selected.data)
    self:refreshTaskList()
    self:saveTasks()
end

function JournalWindow:saveTasks()
    local writer = getFileWriter(TASKS_FILE, true, false)
    for _, task in ipairs(self.tasks) do
        writer:write((task.done and "1" or "0") .. "\t" .. task.text .. "\n")
    end
    writer:close()
end

function JournalWindow:loadTasks()
    local reader = getFileReader(TASKS_FILE, true)
    self.tasks = {}

    local line = reader:readLine()
    while line ~= nil do
        if line ~= "" then
            local done, text = line:match("^(%d)\t(.*)$")
            if text then
                table.insert(self.tasks, { text = text, done = done == "1" })
            end
        end
        line = reader:readLine()
    end
    reader:close()

    self:refreshTaskList()
end

function ReUI.Journal.show()
    if ReUI.Journal.instance then
        ReUIWindowManager:open(ReUI.Journal.instance, { center = false })
        return ReUI.Journal.instance
    end

    local window = JournalWindow:new()
    window:initialise()
    window:addToUIManager()
    window:setX(getCore():getScreenWidth() - window:getWidth() - 20)
    window:setY(80)
    ReUIWindowManager:register(window)
    ReUI.Journal.instance = window
    return window
end

function ReUI.Journal.hide()
    if ReUI.Journal.instance then
        ReUI.Journal.instance:setVisible(false)
    end
end

function ReUI.Journal.toggle()
    if ReUI.Journal.instance and ReUI.Journal.instance:getIsVisible() then
        ReUI.Journal.hide()
    else
        ReUI.Journal.show()
    end
end
