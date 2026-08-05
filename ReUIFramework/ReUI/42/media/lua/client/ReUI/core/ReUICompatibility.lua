-- ReUI Compatibility Layer for Project Zomboid Build 42.x
-- Wraps engine-specific API calls (currently ISTextEntryBox) so callers
-- don't touch self.javaObject directly.

ReUICompatibility = {}

function ReUICompatibility.setTextBoxMasked(textBox, masked)
    textBox:setMasked(masked == true)
end

function ReUICompatibility.setTextBoxEditable(textBox, editable)
    textBox:setEditable(editable == true)
end

function ReUICompatibility.setTextBoxMaxLength(textBox, length)
    textBox:setMaxTextLength(tonumber(length) or 0)
end

function ReUICompatibility.setTextBoxOnlyNumbers(textBox, onlyNumbers)
    textBox:setOnlyNumbers(onlyNumbers == true)
end

function ReUICompatibility.applyTextBoxOptions(textBox)
    ReUICompatibility.setTextBoxMasked(textBox, textBox.password)
    ReUICompatibility.setTextBoxEditable(textBox, not textBox.readOnly and textBox.enabled)
    ReUICompatibility.setTextBoxMaxLength(textBox, textBox.maxLength)
    ReUICompatibility.setTextBoxOnlyNumbers(textBox, textBox.numbersOnly and not textBox.allowFloat)
end
