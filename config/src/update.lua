-- Copyright 2018 Yahoo Inc.
-- Licensed under the terms of the Apache license. Please see LICENSE.md file distributed with this work for terms.

local parser = require("utils.jsonParser")
local dimension_utils = require("utils.dimensionUtils")
local metrics_utils = require("utils.metricUtils")
local table_utils = require("utils.tableUtils")

require("dimension")
require("metrics")
require("tables")

local dimensionConfig = dimension_utils.build_dimensions_config(
    DIMENSIONS
)

local metricConfig = metrics_utils.build_metric_config(
    SIMPLE_MAKERS,
    COMPLEX_MAKERS,
    METRICS
)

local tableConfig = table_utils.build_table_config(
    PHYSICALTABLES,
    LOGICALTABLES
)

parser.save("../external/DimensionConfig.json", dimensionConfig)
parser.save("../external/MetricConfig.json", metricConfig)
parser.save("../external/TableConfig.json", tableConfig)