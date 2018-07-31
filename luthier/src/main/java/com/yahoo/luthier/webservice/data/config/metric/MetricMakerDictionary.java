// Copyright 2018 Yahoo Inc.
// Licensed under the terms of the Apache license. Please see LICENSE.md file distributed with this work for terms.
package com.yahoo.luthier.webservice.data.config.metric;

import com.google.inject.Singleton;
import com.yahoo.bard.webservice.data.config.metric.makers.MetricMaker;
import com.yahoo.bard.webservice.data.dimension.DimensionDictionary;
import com.yahoo.bard.webservice.data.metric.MetricDictionary;

import com.yahoo.bard.webservice.data.time.DefaultTimeGrain;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.core.DefaultParameterNameDiscoverer;

import java.lang.reflect.Constructor;
import java.lang.reflect.InvocationTargetException;
import java.util.*;
import java.util.stream.IntStream;

/**
 * Metric maker dictionary.
 * <p>
 * map metric maker name to metric maker instance
 */
@Singleton
public class MetricMakerDictionary {

    private static final Logger LOG = LoggerFactory.getLogger(MetricMakerDictionary.class);

    /**
     * Maps from metric maker names to metric makers.
     */
    private final LinkedHashMap<String, MetricMaker> nameToMetricMaker;

    private MetricDictionary metricDictionary;
    private DimensionDictionary dimensionDictionary;

    /**
     * Constructor.
     */
    public MetricMakerDictionary() {
        this.nameToMetricMaker = new LinkedHashMap<>();
    }

    /**
     * Constructor, initial map from all maker names to maker instances in dictionary.
     *
     * @param metricMakers        a list of metric makers
     * @param metricDictionary    metric dictionary as parameter for makers
     * @param dimensionDictionary dimension dictionary as parameter for makers
     */
    public MetricMakerDictionary(Set<MetricMakerTemplate> metricMakers,
                                 MetricDictionary metricDictionary,
                                 DimensionDictionary dimensionDictionary) {

        this.nameToMetricMaker = new LinkedHashMap<>();
        this.metricDictionary = metricDictionary;
        this.dimensionDictionary = dimensionDictionary;

        metricMakers.forEach(maker -> {

            try {
                DefaultParameterNameDiscoverer discoverer = new DefaultParameterNameDiscoverer();
                Constructor<?> constructor = findConstructor(maker, discoverer);
                assert constructor != null;

                Class<?>[] paramsTypes = constructor.getParameterTypes();
                String[] paramsNames = discoverer.getParameterNames(constructor);

                Object[] args = IntStream.range(0, paramsTypes.length)
                        .mapToObj(i -> parseParams(paramsTypes[i], paramsNames[i], maker))
                        .toArray();

                add(maker.getName(), (MetricMaker) constructor.newInstance(args));

            } catch (IllegalAccessException | InstantiationException e) {
                LOG.error("The constructor of maker's class is inaccessible", e);
            } catch (InvocationTargetException e) {
                LOG.error(e.getCause().getMessage(), e);
            }
        });
    }

    /**
     * Find a metric maker given a metric maker Name.
     *
     * @param metricMakerName Name to search
     * @return the first metric maker found (if exists)
     */
    public MetricMaker findByName(String metricMakerName) {
        return nameToMetricMaker.get(metricMakerName.toLowerCase(Locale.ENGLISH));
    }

    /**
     * Get all metric makers available in metric maker dictionary.
     *
     * @return a set of metric makers
     */
    public Set<MetricMaker> getAll() {
        return Collections.unmodifiableSet(new HashSet<>(nameToMetricMaker.values()));
    }

    /**
     * Adds the specified element to the dictionary if it is not already present.
     *
     * @param name        key to add to dictionary
     * @param metricMaker value to add to dictionary
     * @return <tt>true</tt> if the dictionary did not already contain the specified metric maker
     */
    public boolean add(String name, MetricMaker metricMaker) {
        if (nameToMetricMaker.containsKey(name.toLowerCase(Locale.ENGLISH))) {
            return false;
        }
        MetricMaker metricMakers = nameToMetricMaker.put(name.toLowerCase(Locale.ENGLISH), metricMaker);
        if (metricMakers != null) {
            // should never happen unless multiple loaders are running in race-condition
            ConcurrentModificationException e = new ConcurrentModificationException();
            LOG.error("Multiple loaders updating MetricMakerDictionary", e);
            throw e;
        }
        return true;
    }

    /**
     * Adds all of the metric makers in the specified collection to the dictionary.
     *
     * @param metricMakers collection of metric makers to add
     * @return <tt>true</tt> if the dictionary changed as a result of the call
     */
    public boolean addAll(Collection<MetricMaker> metricMakers) {
        boolean flag = false;
        for (MetricMaker metricMaker : metricMakers) {
            flag = add(metricMaker.toString(), metricMaker) || flag;
        }
        return flag;
    }

    @Override
    public String toString() {
        return "MetricMaker Dictionary: " + nameToMetricMaker;
    }

    @Override
    public int hashCode() {
        return Objects.hashCode(nameToMetricMaker);
    }

    @Override
    public boolean equals(Object obj) {
        if (this == obj) {
            return true;
        }
        if (obj instanceof MetricMakerDictionary) {
            MetricMakerDictionary that = (MetricMakerDictionary) obj;
            return nameToMetricMaker.equals(that.nameToMetricMaker);
        }
        return false;
    }

    /**
     * Find appropriate constructor for a metric maker.
     *
     * @param maker a metric maker template instance
     * @param discoverer Used for finding parameters' names for a constructor
     * @return the appropriate constructor for this metric maker
     */
    private Constructor<?> findConstructor(MetricMakerTemplate maker, DefaultParameterNameDiscoverer discoverer) {

        Class<?> makerClass;
        Constructor<?> selectedConstructor = null;

        try {
            makerClass = Class.forName(maker.getFullyQualifiedClassName());
        } catch (ClassNotFoundException e) {
            LOG.error("The constructor of maker's class is inaccessible", e);
            return null;
        }

        for (Constructor<?> candidateConstructor : makerClass.getDeclaredConstructors()) {

            Class<?>[] pTypes = candidateConstructor.getParameterTypes();
            String[] pNames = discoverer.getParameterNames(candidateConstructor);
            int paramsOfConstructor = pTypes.length;
            int paramsOfMaker = maker.getParams().size();

            while (paramsOfConstructor > 0 && paramsOfMaker >= 0) {
                if ("MetricDictionary".equals(pTypes[paramsOfConstructor - 1].getSimpleName())
                        || "DimensionDictionary".equals(pTypes[paramsOfConstructor - 1].getSimpleName())) {
                    paramsOfConstructor--;
                } else if (maker.getParams().containsKey(pNames[paramsOfConstructor - 1])) {
                    paramsOfConstructor--;
                    paramsOfMaker--;
                } else {
                    break;
                }
            }

            if (paramsOfConstructor == 0 && paramsOfMaker == 0) {
                selectedConstructor = candidateConstructor;
                break;
            }
        }

        return selectedConstructor;
    }

    /**
     * Parse parameters for maker's constructor based on parameter's name and type.
     *
     * @param paramType type of the parameter in maker's constructor
     * @param paramName name of the parameter in maker's constructor
     * @param maker the maker template used to find parameter's value by name
     * @return the value of parameter (can be any type)
     *
     * Todo: Not a good implementation now but can work, use other strategy such as binding map instead
     */
    private Object parseParams(Class<?> paramType, String paramName, MetricMakerTemplate maker) {

        Object param = maker.getParams().get(paramName);

        if ("MetricDictionary".equals(paramType.getSimpleName())) {
            return metricDictionary;
        }
        if ("DimensionDictionary".equals(paramType.getSimpleName())) {
            return dimensionDictionary;
        }
        if ("ZonelessTimeGrain".equals(paramType.getSimpleName())) {
            return DefaultTimeGrain.valueOf((String) param);
        }

        if (paramType.isInstance(param)) {
            return param;
        }

        if (paramType.isPrimitive())
        {
            switch (paramType.getSimpleName()) {
                case "boolean":
                    return Boolean.parseBoolean((String) param);
                case "byte":
                    return Byte.parseByte((String) param);
                case "short":
                    return Short.parseShort((String) param);
                case "int":
                    return Integer.parseInt((String) param);
                case "long":
                    return Long.parseLong((String) param);
                case "float":
                    return Float.parseFloat((String) param);
                case "double":
                    return Double.parseDouble((String) param);
                case "char":
                    return param;
            }
        }

        if (paramType.isEnum()) {
            try {
                return Enum.valueOf((Class<Enum>) paramType, (String) param);
            } catch (IllegalArgumentException e) {
                LOG.error("None enum value " + param + " found in enum class: " + paramType.getSimpleName(), e);
            }
        }

        return null;
    }
}
