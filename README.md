# PL/SQL parser for some ASN.1 telecom files

[START FROM HERE](https://github.com/aperveyev/load_ASN1_to_ORA/blob/main/early_concept.md) to feel what I feel when spent 20 years with telecommunication Mediation Task.

**What's this about**

Here I promote the idea of **Oracle database centric offline Mediation**, which may be good choice when:
- you already have an enough-licensed Oracle-cenric information system (Customer Billing and Interconnect Billing first of all), information exchange via database links is common to you
- you are unhappy with current offline Mediation: it's too expensive (costs much more than hadrware), too black-boxed and changes are too hard to implement, vendor is too impudent etc
- you have not overwhelming offline EDR amounts and ready to triple equipment power to Mediate on fingertips
- you are ready to do some in-house development to fully control your offline Mediation till the network shutdown

With Oracle database as Mediation core you get, out of the box:
- scalability and paralellism without specific coding efforts
- native SQL-centric business logic description
- data protection and security for SOX404 and other audits
- very easy-to-do and effective information exchange (including dictionaries) with other corporate information systems
- and don't care about PL/SQL unefficiency, do the things right and it will be OK

One valuable thing I have to note now : **you must agree with my balance beetween flexibility and hardcoding**.

If you ready to build fixed-maximum-length processing workflow, reserve limited number of fields for the enrichment results 
and not fear about several specific table structures (for every distinct type of EDR data) - my concept **"static structures - flexible algorithms"** is for you.

But if you want flexible-steps-graph workflow with unbounded CreateAsSelect intermediate structures - this is another task, closer to generic ETL, and Oracle not the best for it. Try to find something else.

**What's here**

Here I present some solution (ideas and code) for jumpstart the Proof Of Concept for **Oracle database centric offline Mediation**.

Here are (now for two specific type of EDR - HUAWEI PGW & HUAWEI SGSN - both coded with ASN.1 ):
- data structures DDL for two specific type of EDRs
- supporting data structures (register, logs, metrics) for the loading and parsing process
- simple and dummy binary file parsers "to the records level" (language - C)
- not so simple and dummy records parser "to the attribute level" (language - PL/SQL)
- an example of enrichment algorithms including long-sessions partial records correlation (language - PL/SQL)
- some supporting code for repetitive loading (language - PL/SQL)
- not too complex Windows BATch for single-file and loop-files-in-folder loading

Whats not here (yet):
- any tools to massive downloading of files from everywhere and creating queue for loading ( simple FOR %%F in ( * ) LOOP emulate it )
- anything about data distribution ( just select it )
- anything abount data lifecycle management ( partitioning is a must, but final architecture is on your choice )
- any GUI
