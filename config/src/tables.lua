-- Copyright 2018 Yahoo Inc.
-- Licensed under the terms of the Apache license. Please see LICENSE.md file distributed with this work for terms.

-------------------------------------------------------------------------------
-- Physical Tables
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
        metrics = {"CO", "NO2", "Temp", "relativeHumidity", "absoluteHumidity", "O3"},
        dimensions = DIMENSIONS.air_quality,
        granularity = "HOUR"
    }
}

-------------------------------------------------------------------------------
-- Logical Tables
-------------------------------------------------------------------------------

LOGICALTABLES = {
    WIKIPEDIA = {
        desc = nil,
        metrics =  {"count", "added", "delta", "deleted", "averageAddedPerHour", "averageDeletedPerHour",
            "plusAvgAddedDeleted", "MinusAddedDelta", "cardOnPage", "bigThetaSketch"},
        dimensions = DIMENSIONS.wikipedia,
        granularity = {"ALL", "HOUR", "DAY"},
        physicaltable = {"wikiticker" }
    },
    air_quality = {
        desc = nil,
        metrics = {"Temp", "relativeHumidity", "absoluteHumidity", "averageCOPerDay", "O3M"},
        dimensions = DIMENSIONS.air_quality,
        granularity = {"ALL", "HOUR", "DAY"},
        physicaltable = {"air" }
    }
}




