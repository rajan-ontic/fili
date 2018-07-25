-- Copyright 2018 Yahoo Inc.
-- Licensed under the terms of the Apache license. Please see LICENSE.md file distributed with this work for terms.
--[[
This is where we define dimensions to be used in Fili. Dimensions provide a 
means of attaching context to metrics. They may be used to slice and dice
metrics. For example, with dimensions we don't just know how many "pageViews"
our website has had. We can also partition "pageViews" into the number of men
who've seen our pages, the number of women, and the number of people whose
gender is unknown.

Dimensions are defined in a table DIMENSIONS that maps dimension names to 
a list of top-level information about that dimension:
    {longName, description, fields, categories}

    * longName - A longer human friendly name for the dimension
    * description - Brief documentation about the dimension
    * fields - A fieldset (see FieldSets below) describing the fields attached
        to the dimension
    * categories - An arbitrary category to put the dimension in. This is not
        used directly by Fili, but rather exists as a marker for UI's should
        they desire to use it to organize dimensions.
]]

local parser = require("utils.jsonParser")
local dimension_utils = require("utils.dimensionUtils")

local M = {
    dimensions = {}
}

-------------------------------------------------------------------------------
-- Default
-------------------------------------------------------------------------------

DEFAULT = {
    CATEGORY = "General"
}

-------------------------------------------------------------------------------
-- FieldSets
--[[
    Fields define a dimension's "metadata." For example, the country dimension
    may have the fields id, name, desc, and ISO. id is a unique identifier for
    the country (typically this is the primary key in your dimension database),
    name is a human readable name of the country, desc is a brief description
    of the country, and ISO is the country' ISO code.

    Fieldsets are lists of fields that may be attached to dimensions.

    A field is a table with at least one parameter: 
        1. name - The name of the field
    Fields may also have the optional parameter:
        1. tags - A list of tags that may provide additional information about
            a field. For example, the "primaryKey" tag is used to mark a field
            as the dimension's primary key.

    To aid in configuration, we provide two utility functions for creating 
    fields:
        1. pk - Takes a name and returns a primary key field (i.e. a table with
            two keys:
                a. name - The name of the field
                b. tags - A singleton list containing the value "primaryKey"
        2. field - A function that takes a variable number of field names and
                returns an equal number of fields. Each field is a table with
                one key:
                a. name - The name passed in for that field
]]
-------------------------------------------------------------------------------

-- fieldSet name = {pk(field as primary key), f(other fields)}
FIELDSETS = {
    DEFAULT = { pk "ID", field "DESC" },
    COUNTRY = { pk "ID", field ("DESC", "COUNTY", "STATE")},
    PAGE = { pk "ID", field "DESC" }
}

-------------------------------------------------------------------------------
-- Dimensions
-------------------------------------------------------------------------------

-- dimension name = {longName, description, fields, categories}
DIMENSIONS = {
    comment = {"wiki comment", "Comment for the edit to the wiki page", FIELDSETS.DEFAULT, nil},
    countryIsoCode = { "wiki countryIsoCode", "Iso Code of the country to which the wiki page belongs", FIELDSETS.COUNTRY, DEFAULT.CATEGORY },
    regionIsoCode = { "wiki regionIsoCode", "Iso Code of the region to which the wiki page belongs", FIELDSETS.DEFAULT, nil },
    page = { "wiki page", "Page is a document that is suitable for World Wide Web and web browsers", FIELDSETS.PAGE, nil },
    user = { "wiki user", "User is a person who generally use or own wiki services", { pk "ID", field("DESC", "AGE", "SEX") }, nil },
    isUnpatrolled = {"wiki isUnpatrolled", "Unpatrolled are class of pages that are not been patrolled", FIELDSETS.DEFAULT, nil},
    isNew = {"wiki isNew", "New Page is the first page that is created in wiki", FIELDSETS.DEFAULT, nil},
    isRobot = {"wiki isRobot", "Robot is an tool that carries out repetitive and mundane tasks", FIELDSETS.DEFAULT, nil},
    isAnonymous = {"wiki isAnonymous", "Anonymous are individual or entity whose identity is unknown", FIELDSETS.DEFAULT, nil},
    isMinor = {"wiki isMinor", "Minor is a person who is legally considered a minor", FIELDSETS.DEFAULT, nil},
    namespace = {"wiki namespace", "Namespace is a set of wiki pages that begins with a reserved word", FIELDSETS.DEFAULT, nil},
    channel = {"wiki channel", "Channel is a set of wiki pages on a certain channel", FIELDSETS.DEFAULT, nil},
    countryName = {"wiki countryName", "Name of the Country to which the wiki page belongs", FIELDSETS.DEFAULT, nil},
    regionName = {"wiki regionName", "Name of the Region to which the wiki page belongs", FIELDSETS.DEFAULT, nil},
    metroCode = {"wiki metroCode", "Metro Code to which the wiki page belongs", FIELDSETS.DEFAULT, nil},
    cityName = {"wiki cityName", "Name of the City to which the wiki page belongs", FIELDSETS.DEFAULT, nil}
}

dimension_utils.add_dimensions(DIMENSIONS, M.dimensions)
parser.save("../DimensionConfig.json", M)

return M
