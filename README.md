## PL/SQL parser for some ASN.1 telecom files

**What's this about**

Mediation is one of the telecom operator's tasks.

One of the valuable steps in Mediation is file conversion from proprietary formats of equipment vendors to delimited text or database structures for further processing.

Such converters often - for the sake of efficiency - usually made with low level tools : C++, Java etc.
The good practice is not to make valuable processing directly during conversion.

Also it's a big dispute whether to use database for Mediation transformation (format adjustments, filtering, enrichment, correlation, splitting) or do all that things
with native processors over files. 
Traditionally Big Mediation Vendors use second method for the efficiency and scalability, creating proprietary clustering, scaling, load balancing and fault recovery.
As a side (?) effect that solutions are quite expensive and create "vendor locks" for telecom operators.

The method of Mediation inside RDBMS is much less effective but gives operator "free hands" to process data with SQL and/or stored procedures.


**Main steps and tools here**
