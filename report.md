# Ride Knox Analysis Report

## Summary

Ride Knox ridership and station demand vary across the network, with some locations showing much greater use than others.

## Data Cleaning

Trips lasting less than 2 minutes were excluded because they were considered likely dock fumbles rather than meaningful rides.

Trips lasting more than 24 hours were excluded because they were viewed as likely docking errors.

## Limitations

The analysis depends on the quality and completeness of the trip records. The minimum trip-duration rule may remove some genuine very short rides, while the 24-hour maximum-duration rule may also exclude unusual but valid trips.

The raw trip and station data are stored outside the Git repository and are not included in version control.