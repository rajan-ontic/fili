// Copyright 2018 Yahoo Inc.
// Licensed under the terms of the Apache license. Please see LICENSE.md file distributed with this work for terms.
package com.yahoo.bard.webservice.druid.model.metadata;

import com.fasterxml.jackson.annotation.JsonCreator;
import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.fasterxml.jackson.annotation.JsonProperty;

import org.apache.commons.lang3.NotImplementedException;

import io.druid.data.input.InputRow;
import io.druid.timeline.partition.NoneShardSpec;
import io.druid.timeline.partition.PartitionChunk;
import io.druid.timeline.partition.ShardSpec;
import io.druid.timeline.partition.ShardSpecLookup;

import java.util.List;

/**
 * NumberedShardSpec class. Reflects the current shardspec type that is used in druid datasource metadata endpoints.
 */
@JsonIgnoreProperties(ignoreUnknown = true)
public class IdOnlyShardSpec implements ShardSpec {

    private final String type;
    private final int partitionNum;

    /**
     * Creates a numbered shard specification given a type, a partition number and the total number of partitions.
     *
     * @param type  The type of this shard spec.
     * @param partitionNum  The partition number of this shard spec.
     */
    @JsonCreator
    public IdOnlyShardSpec(
            @JsonProperty("type") String type,
            @JsonProperty("partitionNum") int partitionNum
    ) {
        this.type = type;
        this.partitionNum = partitionNum;
    }

    /**
     * Creates numbered shard spec from an unsharded spec.
     * Consequently the numbered shard spec will have type: "none", partition number equal to zero
     *
     * @param spec  The spec corresponding to unsharded segment.
     */
    public IdOnlyShardSpec(NoneShardSpec spec) {
        this.type = "none";
        this.partitionNum = spec.getPartitionNum();
    }

    /**
     * Creates numbered shard spec from an arbitrary shard spec.
     * Consequently the numbered shard spec will have type: "other",
     *
     * @param spec  The spec corresponding to unsharded segment.
     */
    public IdOnlyShardSpec(ShardSpec spec) {
        this.type = "idOnly";
        this.partitionNum = spec.getPartitionNum();
    }

    /**
     * Getter for type.
     *
     * @return type  The type of this shard spec.
     */
    public String getType() {
        return this.type;
    }

    @Override
    public <T> PartitionChunk<T> createChunk(T obj) {
        throw new NotImplementedException("createChunk method is not implemented");
    }

    @Override
    public boolean isInChunk(long timestamp, InputRow inputRow) {
        throw new NotImplementedException("isInChunk method is not implemented");
    }

    /**
     * Getter for partition number.
     *
     * @return The partition number of this shard spec.
     */
    @Override
    public int getPartitionNum() {
        return partitionNum;
    }

    @Override
    public ShardSpecLookup getLookup(List<ShardSpec> shardSpecs) {
        throw new NotImplementedException("getLookup method is not implemented");
    }
}
