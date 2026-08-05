ReUIComponent = ReUIComponent or {}

function ReUIComponent.apply(component, options)
    options = options or {}

    component.reuiId = options.id
    component.reuiEnabled = options.enabled ~= false
    component.reuiVisible = options.visible ~= false
    component.reuiEvents = {}
    component.reuiClasses = {}
    component.reuiState = {
        hovered = false,
        focused = false,
        pressed = false,
        selected = false
    }

    function component:setId(id)
        self.reuiId = id
        return self
    end

    function component:getId()
        return self.reuiId
    end

    function component:setReUIEnabled(enabled)
        self.reuiEnabled = enabled == true
        if self.setEnabled then
            self:setEnabled(self.reuiEnabled)
        elseif self.setEnable then
            self:setEnable(self.reuiEnabled)
        elseif self.enable ~= nil then
            self.enable = self.reuiEnabled
        end
        return self
    end

    function component:isReUIEnabled()
        return self.reuiEnabled
    end

    function component:setReUIVisible(visible)
        self.reuiVisible = visible == true
        if self.setVisible then
            self:setVisible(self.reuiVisible)
        end
        return self
    end

    function component:isReUIVisible()
        return self.reuiVisible
    end

    function component:addClass(className)
        if not className or self:hasClass(className) then
            return self
        end
        table.insert(self.reuiClasses, className)
        return self
    end

    function component:removeClass(className)
        for i = #self.reuiClasses, 1, -1 do
            if self.reuiClasses[i] == className then
                table.remove(self.reuiClasses, i)
            end
        end
        return self
    end

    function component:hasClass(className)
        for _, value in ipairs(self.reuiClasses) do
            if value == className then
                return true
            end
        end
        return false
    end

    function component:on(eventName, callback, target)
        if not eventName or not callback then
            return self
        end

        self.reuiEvents[eventName] = self.reuiEvents[eventName] or {}
        table.insert(self.reuiEvents[eventName], {
            callback = callback,
            target = target
        })
        return self
    end

    function component:off(eventName, callback)
        local listeners = self.reuiEvents[eventName]
        if not listeners then
            return self
        end

        for i = #listeners, 1, -1 do
            if callback == nil or listeners[i].callback == callback then
                table.remove(listeners, i)
            end
        end
        return self
    end

    function component:emit(eventName, ...)
        local listeners = self.reuiEvents[eventName]
        if not listeners then
            return self
        end

        for _, listener in ipairs(listeners) do
            if listener.target then
                listener.callback(listener.target, self, ...)
            else
                listener.callback(self, ...)
            end
        end
        return self
    end

    function component:setState(name, value)
        self.reuiState[name] = value
        self:emit("stateChanged", name, value)
        return self
    end

    function component:getState(name)
        return self.reuiState[name]
    end

    return component
end
