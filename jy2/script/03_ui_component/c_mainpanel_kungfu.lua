--[[3001

]]

local G = require "gf"
local t = G.com()

local PAGE_SIZE = 6

local function 创建分页文字(parent, name, left, right, text, canClick)
    local ui = G.TextQuad()
    parent.addChild(ui)
    ui.name = name
    ui.left = left
    ui.right = right
    ui.bottom = -145
    ui.top = -119
    ui.scaleX = 0.500
    ui.scaleY = 0.500
    ui.shadowX = 1
    ui.shadowAlpha = 192
    ui.text = text
    ui.font = 0x63340000
    ui.align = 5
    ui.mouseEnabled = canClick == true
    return ui
end

function t:init()
    for i, v in ipairs({'列表', '关闭'}) do
        self[v] = self.obj.getChildByName(v);
    end

    self.上一页 = 创建分页文字(self.obj, '上一页', -190, -50, '上一页', true)
    self.页码 = 创建分页文字(self.obj, '页码', -50, 50, '1/1', false)
    self.下一页 = 创建分页文字(self.obj, '下一页', 50, 190, '下一页', true)

    self.武功数据 = {}
    self.武功页 = 1
    self:刷新武功页()
end

function t:刷新武功页()
    local data = self.武功数据 or {}
    local totalPage = math.max(1, math.ceil(#data / PAGE_SIZE))
    self.武功页 = math.max(1, math.min(self.武功页 or 1, totalPage))

    local startIndex = (self.武功页 - 1) * PAGE_SIZE + 1
    for i = 1, PAGE_SIZE do
        local ui = self.列表.getChildAt(i - 1)
        local o_kungfu_武功 = data[startIndex + i - 1]
        if o_kungfu_武功 and (o_kungfu_武功.等级 or 0) > 0 then
            ui.getChildAt(0).img = o_kungfu_武功.图标
            ui.getChildAt(1).text = o_kungfu_武功.名称
            ui.getChildAt(2).text = o_kungfu_武功.等级 .. ''
            ui.getChildAt(1).visible = true
            ui.getChildAt(2).visible = true
        else
            ui.getChildAt(0).img = 0x5601100d
            ui.getChildAt(1).visible = false
            ui.getChildAt(2).visible = false
        end
    end

    self.页码.text = self.武功页 .. '/' .. totalPage
    self.上一页.visible = totalPage > 1
    self.下一页.visible = totalPage > 1
    self.页码.visible = totalPage > 1
    self.上一页.alpha = self.武功页 > 1 and 255 or 96
    self.下一页.alpha = self.武功页 < totalPage and 255 or 96
end

function t:setData(_o_kungfu_武功)
    self.武功数据 = _o_kungfu_武功 or {}
    self.武功页 = 1
    self:刷新武功页()
    self.obj.visible = true
end

function t:click(tar)
    if tar == self.关闭 then
        self.obj.visible = false;
        if self.obj.parent then
            local c = self.obj.parent.c_mainpanel
            if c then
                c.透明遮挡.visible = false
            end
        end
    elseif tar == self.上一页 then
        if self.武功页 > 1 then
            self.武功页 = self.武功页 - 1
            self:刷新武功页()
        end
    elseif tar == self.下一页 then
        local totalPage = math.max(1, math.ceil(#(self.武功数据 or {}) / PAGE_SIZE))
        if self.武功页 < totalPage then
            self.武功页 = self.武功页 + 1
            self:刷新武功页()
        end
    end
end
return t
