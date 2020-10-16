create or replace package cdrhua_pkg as
-- ASN.1 tags with types
 type atag  is record ( tag varchar2(80), tp number );
 type atags is table of atag index by varchar2(12);

-- List of traffic volumes - parsed
 type lotv is record ( dataU number, dataD number, chCnd number, changeTime timestamp(0) with time zone, userloc varchar2(30) );
 type lotvs is table of lotv index by PLS_INTEGER; 
-- List of Service Data - parsed
 type losd is record ( RGroup number, LocalSeqNum number, TimeFirst date, TimeLast date, TimeUsage number, SrvCondCh varchar2(8), 
                       SgsnAddress varchar2(20), dataU number, dataD number, TimeRep date, Userloc varchar2(30),
                       RATtype number, ChRuleName varchar2(30), SrvIdentifier number );
 type losds is table of losd index by PLS_INTEGER; 
  
-- TAG lists 
-- hua pgw + sgw BEFORE
 huap atags; 
-- hua sgsn BEFORE
 huas atags; 
-- sgsn AFTER
 sgsna atags;
-- pgw AFTER
 pgwa atags;
-- sgw AFTER
 sgwa atags;

 procedure init;
-- parse HUA BEFORE
 function hua ( rbody in varchar2, info out nocopy varchar2 ) return date ;
-- parse HUA to SGSN AFTER
 function sgsn ( rbody in varchar2, wmode in number, osgsn out cdrhua_sgsn%ROWTYPE, olotvs out lotvs ) return  varchar2 ;
-- parse HUA to PGW AFTER
 function pgw ( rbody in varchar2, wmode in number, opgw out cdrhua_pgw%ROWTYPE, olotvs out lotvs, olosds out losds ) return  varchar2 ;

-- parsed values array
 type arec  is record ( tag varchar2(12), i number, cbuf varchar2(800), nbuf number, dbuf date, tbuf timestamp(0) with time zone );
 type arecs is table of arec index by varchar2(80);
-- select value by name
 function selpgw ( rbody in varchar2, tag in varchar2 ) return varchar2 ;
 
end;
/
