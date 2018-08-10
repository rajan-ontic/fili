// Copyright 2016 Yahoo Inc.
// Licensed under the terms of the Apache license. Please see LICENSE.md file distributed with this work for terms.
package com.yahoo.bard.webservice.druid.model.metadata;

import com.fasterxml.jackson.annotation.JsonCreator;
import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.fasterxml.jackson.annotation.JsonProperty;

import io.druid.timeline.partition.NoneShardSpec;

/**
 * NumberedShardSpec class. Reflects the current shardspec type that is used in druid datasource metadata endpoints.
 */
@JsonIgnoreProperties(ignoreUnknown = true)
public class NumberedShardSpec extends IdOnlyShardSpec {

    private final int partitions;

    /**
     * Creates a numbered shard specification given a type, a partition number and the total number of partitions.
     *
     * @param type  The type of this shard spec.
     * @param partitionNum  The partition number of this shard spec.
     * @param partitions  The total number of partitions of the segment that this shard spec belongs to.
     */
    @JsonCreator
    public NumberedShardSpec(
            @JsonProperty("type") String type,
            @JsonProperty("partitionNum") int partitionNum,
            @JsonProperty("partitions") int partitions
    ) {
        super(type, partitionNum);
        this.partitions = partitions;
    }

    /**
     * Creates numbered shard spec from an unsharded spec.
     * Consequently the numbered shard spec will have type: "none", partition number equal to zero and number of
     * partitions equal to one.
     *
     * @param spec  The spec corresponding to unsharded segment.
     */
    public NumberedShardSpec(NoneShardSpec spec) {
        super("none", spec.getPartitionNum());
        this.partitions = spec.getPartitionNum() + 1;
    }

    /**
     * Getter for the number of partitions.
     *
     * @return The number of partitions of the segment that this shard belongs to.
     */
    public int getPartitions() {
        return partitions;
    }
}
