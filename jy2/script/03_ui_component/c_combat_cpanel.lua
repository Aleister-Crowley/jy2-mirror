--[[3006

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
    ui.bottom = -111
    ui.top = -81
    ui.scaleX = 0.500
    ui.scaleY = 0.500
    ui.shadowX = 1
    ui.shadowAlpha = 192
    ui.text = text
    ui.font = 0x60200000
    ui.align = 5
    ui.mouseEnabled = canClick == true
    return ui
end

function t:init()
    for i, v in ipairs({'气槽', '按钮_查看属性', '按钮_逃跑', '按钮_切换', '按钮_攻击', '切换武功类型', '选择武功'}) do
        self[v] = self.obj.getChildByName(v);
    end
    for i, v in ipairs({'按钮_拳', '按钮_掌', '按钮_指', '按钮_剑', '按钮_内'}) do
        self[v] = self.切换武功类型.getChildByName(v);
    end
    for i = 1, 6 do
        self['武功' .. i] = self.选择武功.getChildByName('武功' .. i);
    end
    ----------------
    self.武功属性 = self.obj.getChildByName('武功属性');
    self.武功属性.visible = false;

    self.上一页 = 创建分页文字(self.obj, '上一页', -120, -20, '上一页', true)
    self.页码 = 创建分页文字(self.obj, '页码', -20, 60, '1/1', false)
    self.下一页 = 创建分页文字(self.obj, '下一页', 60, 160, '下一页', true)

    self.武功数据 = {}
    self.武功页 = 1
    self.当前武功类型 = nil
    self.当前游戏数据 = nil
end
function t:开启(boolean_允许逃跑)
    self.武功页 = 1
    self.武功数据 = {}
    self.当前武功类型 = nil
    self.当前游戏数据 = nil
    self.上一页.visible = false
    self.下一页.visible = false
    self.页码.visible = false
    self.气槽.width = 0;
    self.按钮_查看属性.visible = true
    self.按钮_逃跑.c_button:disable()
    self.按钮_逃跑.c_handle_click.允许点击事件 = false
    self.按钮_切换.visible = true
    self.按钮_攻击.c_button:disable()
    self.按钮_攻击.c_handle_click.允许点击事件 = false
    for i = 0, self.切换武功类型.childCount - 1 do
        local ui = self.切换武功类型.getChildAt(i);
        if 0 == i then
            ui.c_button.state = 'c'
            ui.mouseEnabled = false
        else
            ui.c_button.state = ''
            ui.mouseEnabled = true
        end
    end
    for i = 0, self.选择武功.childCount - 1 do
        local ui = self.选择武功.getChildAt(i);
        ui.img = 0x5601100d;
        ui.mouseEnabled = false;
    end
    if G.GetOS() == 1 then
        self.obj.scaleX = 1
        self.obj.scaleY = 1
        self.obj.x = -300
    else
        self.obj.scaleX = 1.25
        self.obj.scaleY = 1.25
        local offset = self.obj.width * (self.obj.scaleX - 1)
        offset = math.min(offset, 64, self.obj.parent.width - 600)
        self.obj.x = -300 - offset
    end
end
function t:关闭()
    -- self.气槽.width = 0;
    self.按钮_查看属性.visible = false
    self.按钮_逃跑.c_button:disable()
    self.按钮_逃跑.c_handle_click.允许点击事件 = false
    self.按钮_切换.visible = false
    self.按钮_攻击.c_button:disable()
    for i = 0, self.切换武功类型.childCount - 1 do
        local ui = self.切换武功类型.getChildAt(i);
        ui.mouseEnabled = false
    end
    for i = 0, self.选择武功.childCount - 1 do
        local ui = self.选择武功.getChildAt(i);
        -- ui.mouseEnabled = false;
        ui.c_handle_click.允许点击事件 = false
    end
end
function t:切换武功类型(string_武功类型)
    if self.当前武功类型 ~= string_武功类型 then
        self.当前武功类型 = string_武功类型
        self.武功页 = 1
    end
end

function t:设置武功数据(o_base_游戏数据, _o_kungfu_可用武功)
    self.当前游戏数据 = o_base_游戏数据
    self.武功数据 = _o_kungfu_可用武功 or {}
    self:刷新武功页()
end

function t:刷新武功页()
    if not self.当前游戏数据 then return end

    local data = self.武功数据 or {}
    local skillCount = math.max(0, #data - 1)
    local totalPage = math.max(1, math.ceil(skillCount / PAGE_SIZE))
    self.武功页 = math.max(1, math.min(self.武功页 or 1, totalPage))

    local int_集气 = self.当前游戏数据.主角.集气
    local int_内力 = self.当前游戏数据.主角.内力
    local o_kungfu_基础武功 = data[1]

    if o_kungfu_基础武功 then
        if int_集气 >= o_kungfu_基础武功.需集气 and int_内力 >= o_kungfu_基础武功.需内力 * o_kungfu_基础武功.等级 then
            self.按钮_攻击.c_button:enable()
            self.按钮_攻击.c_handle_click.允许点击事件 = true
        else
            self.按钮_攻击.c_button:disable()
            self.按钮_攻击.c_handle_click.允许点击事件 = false
        end
    end

    local firstSkillOffset = (self.武功页 - 1) * PAGE_SIZE
    for i = 1, PAGE_SIZE do
        local ui = self['武功' .. i]
        local globalOffset = firstSkillOffset + i
        local o_kungfu_武功 = data[globalOffset + 1]

        if o_kungfu_武功 then
            ui.img = o_kungfu_武功.图标
            if o_kungfu_武功.需物品 ~= nil then
                ui.getChildAt(0).text = o_kungfu_武功.需物品.数量
                ui.getChildAt(0).visible = true
            else
                ui.getChildAt(0).visible = false
            end

            ui.mouseEnabled = true
            if int_集气 < o_kungfu_武功.需集气 or int_内力 < o_kungfu_武功.需内力 * o_kungfu_武功.等级 then
                ui.color = 0x808080
                ui.c_handle_click.允许点击事件 = false
            else
                ui.color = 0xFFFFFF
                ui.c_handle_click.允许点击事件 = true
            end
            -- 事件参数一必须对应完整武功列表中的偏移量。
            ui.c_handle_click.事件参数一 = tostring(globalOffset)
            ui.c_handle_click.事件参数二 = o_kungfu_武功.name
        else
            ui.getChildAt(0).visible = false
            ui.img = 0x5601100d
            ui.color = 0xFFFFFF
            ui.mouseEnabled = false
            ui.c_handle_click.允许点击事件 = false
            ui.c_handle_click.事件参数一 = tostring(globalOffset)
            ui.c_handle_click.事件参数二 = 0
        end
    end

    self.页码.text = self.武功页 .. '/' .. totalPage
    self.上一页.visible = totalPage > 1
    self.下一页.visible = totalPage > 1
    self.页码.visible = totalPage > 1
    self.上一页.alpha = self.武功页 > 1 and 255 or 96
    self.下一页.alpha = self.武功页 < totalPage and 255 or 96

    if self.当前游戏数据.对手.允许逃跑 then
        if int_集气 >= 2 then
            self.按钮_逃跑.c_button:enable()
            self.按钮_逃跑.c_handle_click.允许点击事件 = true
        else
            self.按钮_逃跑.c_button:disable()
            self.按钮_逃跑.c_handle_click.允许点击事件 = false
        end
    end
end

function t:click(tar)
    if tar == self.上一页 then
        if self.武功页 > 1 then
            self.武功页 = self.武功页 - 1
            self:刷新武功页()
        end
    elseif tar == self.下一页 then
        local skillCount = math.max(0, #(self.武功数据 or {}) - 1)
        local totalPage = math.max(1, math.ceil(skillCount / PAGE_SIZE))
        if self.武功页 < totalPage then
            self.武功页 = self.武功页 + 1
            self:刷新武功页()
        end
    end
end
------------------
function t:显示武功属性(o_kungfu_武功)
    if not o_kungfu_武功 then return end
    local lv = o_kungfu_武功.等级
    local hurt = G.call('通用_计算武功伤害', o_kungfu_武功)
    local experience = 100
    if o_kungfu_武功.升级 then
        if o_kungfu_武功.升级[lv] then
            if o_kungfu_武功.升级[lv - 1] then
                experience = 100 * (o_kungfu_武功.经验 - o_kungfu_武功.升级[lv - 1].需经验) / (o_kungfu_武功.升级[lv].需经验 - o_kungfu_武功.升级[lv - 1].需经验)
            else
                experience = 100 * o_kungfu_武功.经验 / o_kungfu_武功.升级[lv].需经验
            end
        else
        end
    end
    local str = string.format('%s Lv%-2d(%2.1f%%)[br]耗内: %-4d  耗气: %d[br]威力: ', o_kungfu_武功.名称, lv, experience, (o_kungfu_武功.需内力 or 0) * lv, o_kungfu_武功.需集气)
    if hurt[1] == hurt[2] then
        str = str .. hurt[1]
    else
        str = str .. hurt[1] .. ' - ' .. hurt[2]
    end
    self.武功属性.text = str
    self.武功属性.visible = true
end
function t:rollOver(tar)
    if tar.parent == self.选择武功 then
        local c = tar.c_handle_click
        if c and c.事件参数二 > 0 then
            self:显示武功属性(G.QueryName(c.事件参数二))
        end
    end
end
function t:rollOut(tar)
    self.武功属性.visible = false
end
return t