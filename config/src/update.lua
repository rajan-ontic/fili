-- Copyright 2018 Yahoo Inc.
-- Licensed under the terms of the Apache license. Please see LICENSE.md file distributed with this work for terms.

--[[
update all configuration
]]
local parser = require("utils.jsonParser")
local dimensionUtils = require("utils.dimensionUtils")
local metricsUtils = require("utils.metricUtils")
local tableUtils = require("utils.tableUtils")

require("dimension")
require("metrics")
require("tables")

local dimensionConfig = dimensionUtils.build_dimensions_config(
    DIMENSIONS
)

local metricConfig = metricsUtils.build_metric_config(
    SIMPLE_MAKERS,
    COMPLEX_MAKERS,
    METRICS
)

local tableConfig = tableUtils.build_table_config(
    PHYSICALTABLES,
    LOGICALTABLES
)

parser.save("../external/DimensionConfig.json", dimensionConfig)
parser.save("../external/MetricConfig.json", metricConfig)
parser.save("../external/TableConfig.json", tableConfig)