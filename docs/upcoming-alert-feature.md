# Upcoming Alert Feature

## Context

MBQ currently uses pulses to generate/manage alerts. It shares one pulse per many queries. This would work fine, but metabase announced that they will be deprecating pulses for dashboard subscriptions. Unfortunately for MBQ, dashboard subscriptions would be difficult to manage and not actually work as one would expect.

To mitigate the pulse the deprecation, we're going to introduce an alert model that will work just like our pulses do but will automatically sync as an individual alert for that card.

We'll still be able to define one alert schedule for a set of queries, but we'll make sure we'll sync each of those for each query accordingly.