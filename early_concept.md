# RDBMS-centric postpaid mediation for Telecom CDR-s

## PREFACE

Every modern Telecom carrier have to have mediation information system sitting between network and major information systems (customer billing, interconnect billing, traffic and service analytic systems etc). Even in the “prepaid and internet era” this mediation remains valuable and serves substantial part of the revenue stream.

Last decades, most (starting from the big) Telecoms driven by “convergent” hype have implemented mediation solutions, uniform for every services and service data types. Struggling with enormous data amount from IP-network usage those solutions made with low-level (Java, in-memory processing over file system data or “any RDBMS”) and proprietary architectures. This approach (by intention or as the side effect) tied telecom to mediation provider and didn’t took into account very big difference in basic processing principles and relative data cost between traditional “call-like” services and IP network services. Also such “convergent” mediation must have some provisioning properties and high availabitity to reliably affects on the network layer in some cases. So traditional postpaid mediation found it’s end swallowed by the convergent one. Is it really a happy end ?

Lately in document term CDR will mean usage data from telecommunication network, mostly devoted to 1-record-for-event description (partial records for long calls and conference records correlation exists too but they are not dominant). Beside calls this case cover most VAS events (SMS etc) and opposed to IPDR usage data (Netflows etc) where incoming records vastly partial and requires massive aggregation (reduction). Also in most examples later RDBMS means Oracle, but general ideas remains the same.

## WHATS WRONG WITH CONVERGENT MEDIATION

Before continuing we have to summarize some facts, clearly seen from decades:
- hardware become more and more inexpensive, massively parallel clustering of commodity nodes became usual, unbelievable amounts of RAM, SSD and storage became available
- software technologies evolves (including open source ones) with new in-memory db-engines, simple and effective programming languages, easy-to-use developer and administrative toolchains etc
- traditional services consumption (so amount of CDR generated) in most cases saturated whilst data traffic continue to grow and it’s usage data interpretation became more sophisticated. This is widening (already very large) gap in relative usage data cost.
At the same time:
- effective “low level” proprietary architecture with “hand-made” pseudo-language, data structuring and navigation, security, monitoring and productivity control etc. leaves high entry requirements for operation personnel and expensive requests for changes
- CDR and IPDR processing remain uncorrelated due to very different service data presentation principles and uncorrelated business requirements  (really ?)
- proprietary mediation solution’s licensing remains mostly the same (really ?)
- CDR usage data already (re-)loaded into RDBMS for analytic processing (anti-fraud, revenue assurance, quality control, legal requests etc). And into the postpaid billing and interconnect billing, of cause, too. This is a natural result of quite high relative CDR data cost and unpredictable variety of it’s usage.

Also, it’s not nesessary to promote modern RDBMS as a storage and processing tool for table-like multicolumn data (the nature or CDR) – they give plenty of corporate-grade quality properties “out of box” along with SQL (and stored procedures language) for business rules.

The idea of all story is to discuss “de-convergence” possibilities for mediation solution with the main goal to reduce long-term TCO and unbind Telecoms from way-too-complex proprietary convergent solutions. 
What if separate CDR mediation into RDBMS and combine it with warehousing, where access to every CDR required ?
What if leave convergent mediation with the things it do the best - aggregate ever-growing amounts of IPDRs in the resource constrained conditions and to provisioning required – or maybe unload/replace it with the modern open source scalable solutions ? 

## RDBMS-CENTRIC PROCESSING OF CDR DATA

Let’s look at postpaid CDR mediation tasks in general:

- first on all it’s collection or CDR data files from everywhere to the limited count of cites. Audit (SOX, revenue assurance) requirements must be taken in account (CRC, readonly access to source etc). Maybe (if not made anywhere else) centralized archival natural at this point. Besides of all operation done on file server level – all settings have to be taken from database and all log and statistics are placed in database immediately. Human eyes normally have never seen log files.

- convertion data from file formats to relational database structures and turn from “files with records” paradigm into the “records stream” one. The main idea is to extract and store maximum information (maybe even with HEX record body for complex binary format) so files by itself will be never in need. Database structures have to be CDR-format-dependent “primary format” to hold all of that. Minimum transformation (some additional fields - Id etc – added) and maximum possible stability is a goal at this moment. Maximum statistic/log information from file-based operation must be loaded to database to avoid any need to use any files. Plenty of format checks naturally happened and rejected records collected with supporting error info – and loaded to devoted database structures.
Almost all errors at this stage are unrecoverable because they originated from certified source (switch) and any correction have to have strong approve.
Some explicit parallelism has to be set at this stage to distinguish records with very different life-cycles to different tables. The “conventional” method of loading have to assure “constant readiness” all data to use (except of that explicitly marked as unaccessible – partial recodrs not joined yet – for exanple).
No temporary object, no DDL (data definition actions) as a part of loading process. All possible infrastructure (network/storage/etc) errors have to have “auto try to load again” recovery method.

NOTE: all other algorithms mentioned later expect to be stored procedures (yes, database dependent). No database independence, no external-Java-over-everything. All settings are in database, dynamic SQL is a language of choice, database links used wherever possible, API or dictionary snapshot – use right tool for right task.

- after conversion and loading, the most general action with CDR records is “enrichment” - filling additional fields for the sake of normalization of information for later usage. Enrichment fields set is common for any records format for given service class (telephony, for example, VAS enrichment may differ). Enrichment fields make records longer and better. Any re-enrichment make records “even better” (with last actual settings) or left them the same and may be painlessly repeated.
Yes, joining of partial records is a some sort of aggregation but it’s not massive and may be done as a part of process of enrichment (for example – partial records firstly inaccessible for later use and only after records “completion” last partial record “presents” all event).
From this moment any usage of CDR data with external systems (except billings, discussed later) agreed with CDR atomicity became possible. Those systems can “delegate” additional (uniform) fields set to CDR structures and fill them (or present dictionaries/API for fill).

NOTE: every enriched CDR has it’s own fate. It may or may not to pass via more deep preprocessing (consolidation), may be transferred to any combination of target billing systems. Everything about it’s lifecycle marked in dedicated fields, database record became longer and longer.
