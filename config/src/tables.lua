-- Copyright 2018 Yahoo Inc.
-- Licensed under the terms of the Apache license. Please see LICENSE.md file distributed with this work for terms.
--[[
This is where we define tables for Fili. Physical tables contains dataset in druid,
with physical metrics and dimensions defined in druid's configuration file. Logical
tables are tables defined by users, every logical table has their dependency physical
table, api metric names that are references of metrics definitions defined in metric
config file, dimensions for this logical table, and a set of available time granularity
for this logical table.
]]

-------------------------------------------------------------------------------
-- Physical Tables
--[[
    Physical tables are defined in table PHYSICALTABLES that map physical table's
    name (should be the same as dataset's name defined in druid's config file) to
    a dictionary of physical tables' detail:

    * description - Brief documentation about the physical table.
    * metrics - A set of physical metrics for this physical table, the name of a
                metric should be the same as it defined in druid's config file.
    * dimensions - A set of dimensions for this physical table, the name of a
                dimension should be the same as it defined in druid's config file.
    * granularity - The granularity of this physical table.
]]
-------------------------------------------------------------------------------

PHYSICALTABLES = {
    wikiticker = {
        desc = nil,
        metrics = {"added", "delta", "deleted"},
        dimensions = DIMENSIONS.wikipedia,
        granularity = "HOUR"
    },
    air = {
        desc = nil,
        metrics = {"CO", "NO2"},
        dimensions = DIMENSIONS.air_quality,
        granularity = "HOUR"
    }
}

-------------------------------------------------------------------------------
-- Logical Tables
--[[
    Logical tables are defined in table LOGICALTABLES that map logical table's
    name to a dictionary of logical tables' detail:

    * description - Brief documentation about the logical table.
    * metrics - A set of API metrics' name for this logical table, the names are
                used as API for fili query.
    * dimensions - A set of dimensions for this logical table, the set of dimensions
                should be the subset of dimensions in it's dependent physical table.
    * granularity - A group of available granularities of this logical table, the
                granularity can be "ALL", "HOUR" or "DAY". For each granularity,
                Fili would generate a corresponding logical table.
    * physical table - the physical table that this logical table depends on
]]
-------------------------------------------------------------------------------

LOGICALTABLES = {
    WIKIPEDIA = {
        desc = nil,
        metrics =  {"count", "added", "delta", "deleted"},
        dimensions = DIMENSIONS.wikipedia,
        granularity = {"ALL", "HOUR", "DAY"},
        physicaltable = {"wikiticker" }
    },
    air_quality = {
        desc = nil,
        metrics = {"averageCOPerDay", "averageNO2PerDay"},
        dimensions = DIMENSIONS.air_quality,
        granularity = {"ALL", "HOUR", "DAY"},
        physicaltable = {"air" }
    }
}




