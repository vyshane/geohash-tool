# Geohash Tool

A Cocoa application for working with Geohashes. Written in Swift.

This is very much a work in progress.


## Cell Dimensions for Geohash Lengths

The table below shows the metric dimensions for cells covered by various string
lengths of geohash. Cell dimensions vary with latitude and so the table is for
the worst-case scenario at the equator.

| Geohash length | Area width x height   |
| -------------------------------------- |
| 1              | 5,009.4km x 4,992.6km |
| 2              | 1,252.3km x 624.1km   |
| 3              | 156.5km x 156km       |
| 4              | 39.1km x 19.5km       |
| 5              | 4.9km x 4.9km         |
| 6              | 1.2km x 609.4m        |
| 7              | 152.9m x 152.4m       |
| 8              | 38.2m x 19m           |
| 9              | 4.8m x 4.8m           |
| 10             | 1.2m x 59.5cm         |
| 11             | 14.9cm x 14.9cm       |
| 12             | 3.7cm x 1.9cm         |

Source: [Elasticsearch Guide for Geohash Grid Aggregation API](http://www.elasticsearch.org/guide/en/elasticsearch/reference/current/search-aggregations-bucket-geohashgrid-aggregation.html#_cell_dimensions_at_the_equator)

