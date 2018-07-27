-- Copyright 2018 Yahoo Inc.
-- Licensed under the terms of the Apache license. Please see LICENSE.md file distributed with this work for terms.

--[[
This is where we define the metrics for Fili. Metrics in Fili are 
effectively formulas (for example, formulas of aggregations and 
post-aggregations that we send down to Druid). These formulas are constructed
by taking Makers (which, for the purposes of configuration, can be thought of
as operators and operands, i.e.  bits of formulas) and combining them to create
metrics.

For example, the ArithmeticMaker defines the operators +, -, /, so you
can think of the ArithmeticMaker as defining the bits _ + _, _ - _, _ * _,
and _ / _. 

Meanwhile, the LongSumMaker defines basic longsums in Druid, which can be 
thought of as a simple number when building them up with other Makers. So 
bits of formulas like x or y.

We can build a metric by "building up" a formula using the ArithmeticMaker and
the LongSumMaker:

LongSumMaker("metric1") + LongSumMaker("metric2")

This is specified in Lua as:

METRICS = {
 metric1 = {nil, nil, maker_dict.longSum, {"metric1"},
 metric2 = {nil, nil, maker_dict.longSum, {"metric2"},
 sum = {nil, nil, maker_dict.arithmeticPLUS, {"metric1", "metric2"}
}


Naturally of course these can be nested like any formula. So we could add
the following to METRICS above:

METRICS = {
 metric1 = {nil, nil, maker_dict.longSum, {"metric1"},
 metric2 = {nil, nil, maker_dict.longSum, {"metric2"},
 sum = {nil, nil, maker_dict.arithmeticPLUS, {"metric1", "metric2"},
 division = {nil, nil, maker_dict.arithmeticMinus, {"sum", "metric1"}}
}

This gives us the (rather silly) formula:
(LongSum("metric1") + LongSum("metric2")) - LongSum("metric1")
--]]

local metrics_utils = require("utils.metricUtils")
local parser = require("utils.jsonParser")


local M = {
    makers = {},
    metrics = {}
}

local maker_dict = {}

-------------------------------------------------------------------------------
-- Default
-------------------------------------------------------------------------------

DEFAULT = {
    CLASS_BASE_PATH = "com.yahoo.bard.webservice.data.config.metric.makers."
}

-------------------------------------------------------------------------------
-- Makers
--[[
    Makers are templates for metrics. Most map directly to a single aggregation
    or post-aggregation in Druid (like the LongSumMaker for the longSum
    aggregation, or the ArithmeticMaker for the arithmetic post-aggregation).
    Others may be more complex and contain any number of complex aggregations
    and post-aggregations.

    Note that some makers are "simple" in that they don't depend on any other
    Fili metrics, only on a single metric in Druid. For example, the 
    LongSumMaker is simple, because it depends only on a metric in Druid (which
    it computes the longsum of). Meanwhile, the ArithmeticMaker is "complex"
    because it's computing the sum of two other Fili metrics. For example,
    it might compute the LongSum of metric1 and the LongSum of metric2.


    Makers themselves are define in Java, as a part of your program using
    Fili. Therefore, all references to makers are fully-qualified Java class
    names. 

    TODO: Insert documentation describing the structure of makers once we've
    got that finalized.
--]]
-------------------------------------------------------------------------------

-- makerName = {classPath, parameters}
DEFAULT_MAKERS = {
    count = {DEFAULT.CLASS_BASE_PATH .. "CountMaker"},
    constant = {DEFAULT.CLASS_BASE_PATH .. "ConstantMaker"},
    longSum = {DEFAULT.CLASS_BASE_PATH .. "LongSumMaker"},
    doubleSum = {DEFAULT.CLASS_BASE_PATH .. "DoubleSumMaker"}
}

-- makerName = {classPath, {parameter's name = {parameters, suffix}}}
COMPLEX_MAKERS = metrics_utils.generate_makers(
    {
        arithmetic = {
            DEFAULT.CLASS_BASE_PATH .. "ArithmeticMaker",
            {_function = {{"PLUS","MINUS","MULTIPLY","DIVIDE"}, {"PLUS", "MINUS","MULTIPLY","DIVIDE"}}}
        },
        aggregateAverage = {
            DEFAULT.CLASS_BASE_PATH .. "AggregationAverageMaker",
            {innerGrain = {{"HOUR", "DAY"}, {"byHour", "byDay"}}}
        },
        cardinal = {
            DEFAULT.CLASS_BASE_PATH .. "CardinalityMaker",
            {byRow = {{"true", "false"}, {"byRow", "byColumn"}}}
        },
        ThetaSketch = {
            DEFAULT.CLASS_BASE_PATH .. "ThetaSketchMaker",
            {sketchSize= {{"4096", "2048", "1024"}, {"Big", "Medium", "Small"}}}
        }
    }
)

metrics_utils.add_makers(DEFAULT_MAKERS, maker_dict)
metrics_utils.add_makers(COMPLEX_MAKERS, maker_dict)

-------------------------------------------------------------------------------
-- Metrics
--[[
    Metrics are formulas, and built from makers. They're defined
    in a table that maps names to metrics. Each metric is itself a table with
    the following keys:
        apiName - The name used to query the metric in Fili. Automatically set
            to the metric's name.
        longName - A longer, more human friendly name for the metric. Defaults
            to the metric name.
        description - Short documentation about the metric. Defaults to the 
            metric name
        maker - The maker to use to define the metric.
        dependencies - A list of names of metrics that this metric depends on
--]]
-------------------------------------------------------------------------------

-- metric's name = {longName, description, maker, dependency metrics}
M.metrics = metrics_utils.generate_metrics(
    {
        count = {nil, nil, maker_dict.count, nil},
        added = {nil, nil, maker_dict.doubleSum, {"added"}},
        delta = {nil, nil, maker_dict.doubleSum, {"delta"}},
        deleted = {nil, nil, maker_dict.doubleSum, {"deleted"}},
        averageAddedPerHour = {nil, nil, maker_dict.aggregateAveragebyHour, {"added"}},
        averageDeletedPerHour = {nil, nil, maker_dict.aggregateAveragebyHour, {"deleted"}},
        plusAvgAddedDeleted = {nil, nil, maker_dict.arithmeticPLUS, {"averageAddedPerHour", "averageDeletedPerHour"}},
        MinusAddedDelta = {nil, nil, maker_dict.arithmeticMINUS, {"added", "delta"}},
        cardOnPage = {nil, nil, maker_dict.cardinalbyRow, {"page"}},
        bigThetaSketch = {nil, nil, maker_dict.ThetaSketchBig, {"page"}},
        inlineMakerMetric = {nil, nil, {DEFAULT.CLASS_BASE_PATH .. "ThetaSketchMaker", {sketchSize = "4096"}}, {"page"}},
        COM = {nil, nil, maker_dict.doubleSum, {"CO"}},
        NO2M = {nil, nil, maker_dict.doubleSum, {"NO2"}},
        O3M = {nil, nil, maker_dict.doubleSum, {"O3"}},
        Temp = {nil, nil, maker_dict.doubleSum, {"Temp"}},
        relativeHumidity = {nil, nil, maker_dict.doubleSum, {"relativeHumidity"}},
        absoluteHumidity = {nil, nil, maker_dict.doubleSum, {"absoluteHumidity"}},
        averageCOPerDay = {nil, nil, maker_dict.aggregateAveragebyDay, {"COM"} }
    }
)

metrics_utils.add_makers(metrics_utils.cache_makers, maker_dict)
metrics_utils.clean_cache_makers()

metrics_utils.insert_makers_into_table(maker_dict, M.makers)
parser.save("../external/MetricConfig.json", M)

return M
