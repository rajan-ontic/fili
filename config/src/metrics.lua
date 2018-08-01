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
SIMPLE_MAKERS = {
    count = {
        classPath = DEFAULT.CLASS_BASE_PATH .. "CountMaker"
    },
    constant = {
        classPath = DEFAULT.CLASS_BASE_PATH .. "ConstantMaker"
    },
    longSum = {
        classPath = DEFAULT.CLASS_BASE_PATH .. "LongSumMaker"
    },
    doubleSum = {
        classPath = DEFAULT.CLASS_BASE_PATH .. "DoubleSumMaker"
    }
}

-- makerName = {classPath, {parameter's name = {parameters, suffix}}}
COMPLEX_MAKERS = {
    arithmetic = {
        classPath = DEFAULT.CLASS_BASE_PATH .. "ArithmeticMaker",
        params_and_suffix = {
            _function = {{"PLUS","MINUS","MULTIPLY","DIVIDE"}, {"PLUS", "MINUS","MULTIPLY","DIVIDE"} }
        }
    },
    aggregateAverage = {
        classPath = DEFAULT.CLASS_BASE_PATH .. "AggregationAverageMaker",
        params_and_suffix = {
            innerGrain = {{"HOUR", "DAY"}, {"byHour", "byDay"} }
        }
    },
    cardinal = {
        classPath = DEFAULT.CLASS_BASE_PATH .. "CardinalityMaker",
        params_and_suffix = {
            byRow = {{"true", "false"}, {"byRow", "byColumn"} }
        }
    },
    ThetaSketch = {
        classPath = DEFAULT.CLASS_BASE_PATH .. "ThetaSketchMaker",
        params_and_suffix = {
            sketchSize= {{"4096", "2048", "1024"}, {"Big", "Medium", "Small"} }
        }
    }
}

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

METRICS = {
    count = {
        longName = nil,
        desc = nil,
        maker = "count",
        dependencies = nil
    },
    added = {
        longName = nil,
        desc = nil,
        maker = "doubleSum",
        dependencies = {"added" }
    },
    delta = {
        longName = nil,
        desc = nil,
        maker = "doubleSum",
        dependencies = {"delta" }
    },
    deleted = {
        longName = nil,
        desc = nil,
        maker = "doubleSum",
        dependencies = {"deleted" }
    },
    averageAddedPerHour = {
        longName = nil,
        desc = nil,
        maker = "aggregateAveragebyHour",
        dependencies = {"added" }
    },
    averageDeletedPerHour = {
        longName = nil,
        desc = nil,
        maker = "aggregateAveragebyHour",
        dependencies = {"deleted" }
    },
    plusAvgAddedDeleted = {
        longName = nil,
        desc = nil,
        maker = "arithmeticPLUS",
        dependencies = {"averageAddedPerHour", "averageDeletedPerHour" }
    },
    MinusAddedDelta = {
        longName = nil,
        desc = nil,
        maker = "arithmeticMINUS",
        dependencies = {"added", "delta" }
    },
    cardOnPage = {
        longName = nil,
        desc = nil,
        maker = "cardinalbyRow",
        dependencies = {"page" }
    },
    bigThetaSketch = {
        longName = nil,
        desc = nil,
        maker = "ThetaSketchBig",
        dependencies = {"page" }
    },
    inlineMakerMetric = {
        longName = nil,
        desc = nil,
        maker = {
            classPath = DEFAULT.CLASS_BASE_PATH .. "ThetaSketchMaker",
            params = {sketchSize = "4096" }
        },
        dependencies = {"page" }
    },
    COM = {
        longName = nil,
        desc = nil,
        maker = "doubleSum",
        dependencies = {"CO" }
    },
    NO2M = {
        longName = nil,
        desc = nil,
        maker = "doubleSum",
        dependencies = {"NO2" }
    },
    O3M = {
        longName = nil,
        desc = nil,
        maker = "doubleSum",
        dependencies = {"O3" }
    },
    Temp = {
        longName = nil,
        desc = nil,
        maker = "doubleSum",
        dependencies = {"Temp" }
    },
    relativeHumidity = {
        longName = nil,
        desc = nil,
        maker = "doubleSum",
        dependencies = {"relativeHumidity" }
    },
    absoluteHumidity = {
        longName = nil,
        desc = nil,
        maker = "doubleSum",
        dependencies = {"absoluteHumidity" }
    },
    averageCOPerDay = {
        longName = nil,
        desc = nil,
        maker = "aggregateAveragebyDay",
        dependencies = {"COM"}
    }
}
