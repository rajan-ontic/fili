-- Copyright 2018 Yahoo Inc.
-- Licensed under the terms of the Apache license. Please see LICENSE.md file distributed with this work for terms.

--- a module provides util functions for table config.
-- @module tableUtils

local M = {}

--- Generate a list of dimension name from dimension config
--
-- @param dimensions  A list of dimension config
-- @return A list of dimension name
local _generate_dimensions = function(dimensions)
    local t = {}
    for name, dimension in pairs(dimensions) do
        table.insert(t, name)
    end
    return t
end

--- Parse a group of physical tables configs
--
-- @param tables  A group of physical tables
function M.generate_physical_tables(tables)
    for name, physical_table in pairs(tables) do
        physical_table.dimensions = _generate_dimensions(physical_table.dimensions)
    end
    return tables
end

--- Parse a group of logical tables configs
--
-- @param tables  A group of logical tables
function M.generate_logical_tables(tables)
    for name, logical_table in pairs(tables) do
        logical_table.dimensions = _generate_dimensions(logical_table.dimensions)
    end
    return tables
end

--- Add physical table configs and logical table configs into table t.
--
-- @param physical_table A group of physical table config
-- @param logical_table A group of logical table config
-- @return The table for storing table configs and ready be parsed into json
function M.add_tables(physical_table, logical_table)

    local t = {
        physicalTables = {},
        logicalTables = {}
    }

    for name, physical_table in pairs(physical_table) do
        table.insert(t.physicalTables, {
            name = name,
            description = physical_table.desc,
            metrics = physical_table.metrics,
            dimensions = physical_table.dimensions,
            granularity = physical_table.granularity
        })
    end

    for name, logical_table in pairs(logical_table) do
        table.insert(t.logicalTables, {
            name = name,
            description = logical_table.desc,
            apiMetricNames = logical_table.metrics,
            dimensions = logical_table.dimensions,
            granularity = logical_table.granularity,
            physicalTables = logical_table.physicaltable
        })
    end

    return t
end

return M
