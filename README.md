## PL/SQL parser for some ASN.1 telecom files

**What's this about**

Mediation is one of the telecom operator's tasks.
Online Mediation is event-by-event processing with subsecond delays.
Offline Mediation is file-based batch processor with in-out times from minutes to an hour.
ALL THE FOLLOWING IS ABOUT OFFLINE MEDIATION.

One of the valuable steps in Mediation is EDR (Event Data Records) file conversion from proprietary formats of equipment vendors to delimited text or database structures for further processing.
The good practice is not to make valuable processing directly during conversion.
Such converters - for the sake of efficiency - usually made with low level tools : C++, Java etc.

Next big question whether to use database for Mediation transformation (format adjustments, filtering, enrichment, correlation, splitting) or do all that things
with native processors over files. 
Traditionally Big Mediation Vendors use second method for the efficiency and scalability, creating proprietary clustering, scaling, load balancing, fault recovery etc.
As a side (?) effect that solutions are quite expensive and create "vendor locks" for telecom operators.
Note that industrial RDBMS (Oracle etc) not came for free, it may be expensive too.

The method of Mediation inside RDBMS is much less effective but gives operator "free hands" to process data with SQL and/or stored procedures.
The only question remains - how to parse proprienary telecom equipment formats (Big Mediation Vendors gives that function out on the box).
In most cases documentation for file formats comes with telecom equipment - but without any software for conversion. Operator need to create and support it.

Here I promote the idea of Oracle database centric offline Mediation

**Main steps and tools here**
