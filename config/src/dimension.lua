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
    wikipedia = {
        comment = {
            longName = "wiki comment",
            desc = "Comment for the edit to the wiki page",
            fields = FIELDSETS.DEFAULT,
            category = nil
        },
        countryIsoCode = {
            longName = "wiki countryIsoCode",
            desc = "Iso Code of the country to which the wiki page belongs",
            fields = FIELDSETS.COUNTRY,
            category = "General"
        },
        regionIsoCode = {
            longName = "wiki regionIsoCode",
            desc = "Iso Code of the region to which the wiki page belongs",
            fields = FIELDSETS.DEFAULT,
            category = nil
        },
        page = {
            longName = "wiki page",
            desc = "Page is a document that is suitable for World Wide Web and web browsers",
            fields = FIELDSETS.PAGE,
            category = nil
        },
        user = {
            longName = "wiki user",
            desc = "User is a person who generally use or own wiki services",
            fields = { pk "ID", field("DESC", "AGE", "SEX") },
            category = nil
        },
        isUnpatrolled = {
            longName = "wiki isUnpatrolled",
            desc = "Unpatrolled are class of pages that are not been patrolled",
            fields = FIELDSETS.DEFAULT,
            category = nil
        },
        isNew = {
            longName = "wiki isNew",
            desc = "New Page is the first page that is created in wiki",
            fields = FIELDSETS.DEFAULT,
            category = nil
        },
        isRobot = {
            longName = "wiki isRobot",
            desc = "Robot is an tool that carries out repetitive and mundane tasks",
            fields = FIELDSETS.DEFAULT,
            category = nil
        },
        isAnonymous = {
            longName = "wiki isAnonymous",
            desc = "Anonymous are individual or entity whose identity is unknown",
            fields = FIELDSETS.DEFAULT,
            category = nil
        },
        isMinor = {
            longName = "wiki isMinor",
            desc = "Minor is a person who is legally considered a minor",
            fields = FIELDSETS.DEFAULT,
            category = nil
        },
        namespace = {
            longName = "wiki namespace",
            desc = "Namespace is a set of wiki pages that begins with a reserved word",
            fields = FIELDSETS.DEFAULT,
            category = nil},
        channel = {
            longName = "wiki channel",
            desc = "Channel is a set of wiki pages on a certain channel",
            field = FIELDSETS.DEFAULT,
            category = nil
        },
        countryName = {
            longName = "wiki countryName",
            desc = "Name of the Country to which the wiki page belongs",
            fields = FIELDSETS.DEFAULT,
            category = nil
        },
        regionName = {
            longName = "wiki regionName",
            desc = "Name of the Region to which the wiki page belongs",
            fields = FIELDSETS.DEFAULT,
            category = nil
        },
        metroCode = {
            longName = "wiki metroCode",
            desc = "Metro Code to which the wiki page belongs",
            fields = FIELDSETS.DEFAULT,
            category = nil
        },
        cityName = {
            longName = "wiki cityName",
            desc = "Name of the City to which the wiki page belongs",
            fields = FIELDSETS.DEFAULT,
            category = nil
        }
    },
    air_quality = {
        ["PT08.S2(NMHC)"] = {
            longName = "PT08.S2(NMHC)",
            desc = "PT08.S2(NMHC)",
            fields = FIELDSETS.DEFAULT,
            category = nil
        },
        ["PT08.S4(NO2)"] = {
            longName = "PT08.S4(NO2)",
            desc = "PT08.S4(NO2)",
            fields = FIELDSETS.DEFAULT,
            category = nil
        },
        ["PT08.S4(NO2)"] = {
            longName = "NO2(GT)",
            desc = "NO2(GT)",
            fields = FIELDSETS.DEFAULT,
            category = nil
        },
        ["C6H6(GT)"] = {
            longName = "C6H6(GT)",
            desc = "C6H6(GT)",
            fields = FIELDSETS.DEFAULT,
            category = nil
        },
        ["PT08.S1(CO)"] = {
            longName = "PT08.S1(CO)",
            desc = "PT08.S1(CO)",
            fields = FIELDSETS.DEFAULT,
            category = nil
        },
        ["NOx(GT)"] = {
            longName = "NOx(GT)",
            desc = "NOx(GT)",
            fields = FIELDSETS.DEFAULT,
            category = nil
        },
        RH = {
            longName = "RH",
            desc = "RH",
            fields = FIELDSETS.DEFAULT,
            category = nil
        },
        AH = {
            longName = "AH",
            desc = "AH",
            fields = FIELDSETS.DEFAULT,
            category = nil
        },
        ["NMHC(GT)"] = {
            longName = "NMHC(GT)",
            desc = "NMHC(GT)",
            fields = FIELDSETS.DEFAULT,
            category = nil
        },
        T = {
            longName = "T",
            desc = "T",
            fields = FIELDSETS.DEFAULT,
            category = nil
        },
        ["PT08.S3(NOx)"] = {
            longName = "PT08.S3(NOx)",
            desc = "PT08.S3(NOx)",
            fields = FIELDSETS.DEFAULT,
            category = nil
        },
        ["PT08.S5(O3)"] = {
            longName = "PT08.S5(O3)",
            desc = "PT08.S5(O3)",
            fields = FIELDSETS.DEFAULT,
            category = nil
        },
        ["CO(GT)"] = {
            longName = "CO(GT)",
            desc = "CO(GT)",
            fields = FIELDSETS.DEFAULT,
            category = nil
        },
    }
}

