-- Copyright 2018 Yahoo Inc.
-- Licensed under the terms of the Apache license. Please see LICENSE.md file distributed with this work for terms.

local parser = require("utils.jsonParser")
local dimension_utils = require("utils.dimensionUtils")
local metrics_utils = require("utils.metricUtils")
local table_utils = require("utils.tableUtils")
local utils = require("utils.utils")

require("dimension")
local metricConfig = require("metrics")
require("tables")

local dimensionConfig = dimension_utils.add_dimensions(
    DIMENSIONS
)

local tableConfig = table_utils.add_tables(
    table_utils.generate_physical_tables(PHYSICALTABLES),
    table_utils.generate_logical_tables(LOGICALTABLES)
)

parser.save("../external/DimensionConfig.json", dimensionConfig)
parser.save("../external/MetricConfig.json", metricConfig.update())
parser.save("../external/TableConfig.json", tableConfig)