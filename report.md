# Ride Knox Analysis Report

## Summary

This analysis reviews Ride Knox trip data and summarizes ridership patterns, station activity, and data-quality decisions used in the analysis.

## Data Cleaning

Trips lasting less than 2 minutes were excluded because they were considered likely dock fumbles rather than meaningful rides.

Trips lasting more than 24 hours were excluded because they were viewed as likely docking errors.

## Limitations

The analysis depends on the quality and completeness of the trip records. The minimum trip-duration rule may remove some genuine very short rides, while the 24-hour maximum-duration rule may also exclude unusual but valid trips.