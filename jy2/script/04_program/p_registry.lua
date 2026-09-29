--[[4004

加强版注册中心
第一阶段用于消除武功固定 ID，并为后续 NPC、任务、状态系统提供统一入口。
]]

local G = require "gf"
local t = G.api

local function 获取对象ID(o)
    if o == nil then return nil end
    return o.root or o.name
end

local function 获取兼容武功分类(o_kungfu_武功)
    if o_kungfu_武功 == nil then return nil end
    if o_kungfu_武功.分类 ~= nil and o_kungfu_武功.分类 ~= '' then
        return o_kungfu_武功.分类
    end

    local id = 获取对象ID(o_kungfu_武功)
    if id == nil then return nil end

    if id == 0x10040001 or id == 0x10040002 then
        return '基础'
    elseif id >= 0x10040003 and id <= 0x10040008 then
        return '拳'
    elseif id >= 0x10040009 and id <= 0x1004000e then
        return '掌'
    elseif id >= 0x1004000f and id <= 0x10040014 then
        return '指'
    elseif id >= 0x10040015 and id <= 0x1004001a then
        return '剑'
    elseif id >= 0x1004001b and id <= 0x10040020 then
        return '内'
    elseif id >= 0x10040021 and id <= 0x10040026 then
        return '物品'
    end
    return nil
end

local function 获取武功排序(o_kungfu_武功)
    if o_kungfu_武功 == nil then return 999999 end
    if o_kungfu_武功.排序 ~= nil then
        return o_kungfu_武功.排序
    end
    return 获取对象ID(o_kungfu_武功) or 999999
end

--type=注册表
--hide=false
--private=false
t['注册表_获取武功分类'] = function(o_kungfu_武功)
    return 获取兼容武功分类(o_kungfu_武功)
end

--type=注册表
--hide=false
--private=false
t['注册表_获取基础武功'] = function(string_武功类型)
    if string_武功类型 == '剑' then
        return G.QueryName(0x10040002)
    end
    return G.QueryName(0x10040001)
end

--type=注册表
--hide=false
--private=false
t['注册表_获取武功列表'] = function(string_武功类型, boolean_仅已学, boolean_仅可用)
    local result = {}
    local all = G.DBTable('o_kungfu') or {}

    for i = 1, #all do
        local o_kungfu_武功 = all[i]
        if o_kungfu_武功 ~= nil and 获取兼容武功分类(o_kungfu_武功) == string_武功类型 then
            local 可加入 = true

            if o_kungfu_武功.是否显示 == false then
                可加入 = false
            end

            if 可加入 and boolean_仅已学 and o_kungfu_武功.需物品 == nil then
                可加入 = (o_kungfu_武功.等级 or 0) > 0
            end

            if 可加入 and boolean_仅可用 and o_kungfu_武功.需物品 ~= nil then
                可加入 = (o_kungfu_武功.需物品.数量 or 0) > 0
            end

            if 可加入 then
                result[#result + 1] = o_kungfu_武功
            end
        end
    end

    table.sort(result, function(a, b)
        return 获取武功排序(a) < 获取武功排序(b)
    end)

    return result
end

--type=注册表
--hide=false
--private=false
t['注册表_获取全部武功'] = function()
    return G.DBTable('o_kungfu') or {}
end
