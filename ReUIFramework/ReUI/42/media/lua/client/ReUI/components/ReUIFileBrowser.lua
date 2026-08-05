require "ReUI/components/ReUITreeView"
require "ReUI/core/ReUITheme"

-- Project Zomboid's sandboxed Lua has no function to enumerate arbitrary
-- files/directories on disk (only getFileReader/getFileWriter, both scoped
-- to a single, caller-known filename). ReUIFileBrowser therefore browses a
-- caller-supplied virtual tree of {name, isDirectory, children, data}
-- entries rather than the real filesystem. Use getFileReader/getFileWriter
-- inside an onSelectFile callback to actually load/save the chosen entry's
-- sandboxed content.
ReUIFileBrowser = ReUITreeView:derive("ReUIFileBrowser")

function ReUIFileBrowser:new(x, y, width, height, options)
    options = options or {}
    local o = ReUITreeView.new(self, x, y, width, height, options)
    setmetatable(o, self)
    self.__index = self

    o.onSelectFile = options.onSelectFile
    o.selectFileTarget = options.target

    return o
end

function ReUIFileBrowser:buildNode(parent, entry)
    local node = {
        label = entry.name,
        data = entry,
        children = {},
        expanded = false,
        parent = parent
    }

    if parent then
        table.insert(parent.children, node)
    else
        table.insert(self.roots, node)
    end

    if entry.isDirectory and entry.children then
        for _, child in ipairs(entry.children) do
            self:buildNode(node, child)
        end
    end

    return node
end

-- entries: array of {name, isDirectory, children, data}
function ReUIFileBrowser:setRoot(entries)
    self.roots = {}
    self.selectedNode = nil

    for _, entry in ipairs(entries or {}) do
        self:buildNode(nil, entry)
    end

    self:rebuild()
    return self
end

function ReUIFileBrowser:getSelectedEntry()
    return self.selectedNode and self.selectedNode.data or nil
end

function ReUIFileBrowser:selectNode(node, notify)
    ReUITreeView.selectNode(self, node, notify)

    local entry = node and node.data
    if entry and not entry.isDirectory and self.onSelectFile then
        if self.selectFileTarget then
            self.onSelectFile(self.selectFileTarget, self, entry)
        else
            self.onSelectFile(self, entry)
        end
    end

    return self
end
