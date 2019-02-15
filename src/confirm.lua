local Class  = require "hump.class"
local colors = require "term".colors

local Prompt = require "prompt"
local List   = require "list"

local Confirm = Class {

    __includes = List,

    init = function(self, options)
        options.items = {
            {
                value = true,
                label = "Yes"
            },
            {
                value = false,
                label = "No"
            },
        }

        options.multiple = false

        List.init(self, options)

        self.currentChoice = #self.chosen > 0
            and self.chosen[1]
            or 1
    end

}

function Confirm:registerKeybinding()
    List.registerKeybinding(self)

    -- up/down -> left/right
    self.keybinding[Prompt.escapeCodes.cursor_left] = self.keybinding[Prompt.escapeCodes.cursor_up]
    self.keybinding[Prompt.escapeCodes.cursor_up] = false

    self.keybinding[Prompt.escapeCodes.cursor_right] = self.keybinding[Prompt.escapeCodes.cursor_down]
    self.keybinding[Prompt.escapeCodes.cursor_down] = false
end


function Confirm:render()
    Prompt.render(self)

    self.output:write(
        " "
        .. (self.currentChoice == 1
            and colors.underscore
            or "")
        .. self.items[1].label
        .. colors.reset
        .. " / "
        .. (self.currentChoice == 2
            and colors.underscore
            or "")
        .. self.items[2].label
        .. colors.reset
    )
end

function Confirm:endCondition()
    self.chosen = {
        [self.currentChoice] = true
    }

    return List.endCondition(self)
end

function Confirm:after(result)
    -- Show selected label
    self:setCursor(self.promptPosition.x, self.promptPosition.y)

    -- Clear down
    self.output:write(Prompt.escapeCodes.clr_eos)

    self.output:write(" " .. (result[1] and "Yes" or "No"))

    -- Show cursor
    self.output:write(Prompt.escapeCodes.cursor_visible)

    Prompt.after(self)
end

return Confirm