-- Copyright 2018 Yahoo Inc.
-- Licensed under the terms of the Apache license. Please see LICENSE.md file distributed with this work for terms.

--- a module provides util functions for dimension config.
-- @module dimensionUtils

local M = {}

-------------------------------------------------------------------------------
-- Fields
-------------------------------------------------------------------------------

--- Parse a field and add a "primaryKey" tag for this field.
--
-- @param name  the field's name
-- @return a formatted field with a "primarykey" tag
function M.pk(name)
    return { name = name, tags = { "primaryKey" } }
end

--- Parse a set of fields without tags.
--
-- @param ...  a set of fields
-- @return a set of formatted field without tags
function M.field(...)
    local args = { ... }
    local fields = {}
    for index, name in pairs(args) do
        table.insert(fields, { name = name })
    end
    return table.unpack(fields)
end

-------------------------------------------------------------------------------
-- Build Config
-------------------------------------------------------------------------------

--- Parse a group of config dimensions and add them into a table.
--
-- @param dimensions  A group of dimensions
-- @return dimension config, ready for parsing into json
function M.build_dimensions_config(dimensions)
    local t = {
        dimensions = {}
    }
    for database, dimension_config in pairs(dimensions) do
        for name, dimension in pairs(dimension_config) do
            table.insert(t.dimensions, {
                apiName = name,
                longName = dimension.longName,
                description = dimension.desc,
                fields = dimension.fields,
                category = dimension.category,
            })
        end
    end
    return t
end

return M
