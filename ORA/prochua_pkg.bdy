create or replace package body prochua_pkg as
-- m=0 return
function decode_pgw_finalism ( p_losd_srvcondch in varchar2, p_causeforrecordclosing in number, rmode number default 0) return varchar2 IS
  snum number(20);
  ret  varchar2(200);
begin
  if p_losd_srvcondch is not null then
    snum:=to_number(rpad(substr(p_losd_srvcondch,3),8,'0'),'xxxxxxxx');
    if bitand(to_number(substr(p_losd_srvcondch,3,1),'x'),8)!=0 then if rmode=1 then ret:=ret||','||'QoSChange'; elsif rmode=2 then return 0; else return 'continue'; end if; end if; -- integer overflow
    if bitand(snum,256*256*256*64)!=0 then if rmode=1 then ret:=ret||','||'SGSNChange'; elsif rmode=2 then return 1; else return 'continue'; end if; end if;
    if bitand(snum,256*256*256*32)!=0 then if rmode=1 then ret:=ret||','||'SGSNPLMNIDChange'; elsif rmode=2 then return 2; else return 'continue'; end if; end if;
    if bitand(snum,256*256*256*16)!=0 then if rmode=1 then ret:=ret||','||'TariffTimeSwitch'; elsif rmode=2 then return 3; else return 'last/first'; end if; end if;
    if bitand(snum,256*256*256*8)!=0 then if rmode=1 then ret:=ret||','||'PDPContextRelease'; elsif rmode=2 then return 4; else return 'last'; end if; end if;
    if bitand(snum,256*256*256*4)!=0 then if rmode=1 then ret:=ret||','||'RATChange'; elsif rmode=2 then return 5; else return 'continue'; end if; end if;
    if bitand(snum,256*256*256*2)!=0 then if rmode=1 then ret:=ret||','||'ServiceIdledOut'; elsif rmode=2 then return 6; else return 'last'; end if; end if;
    if bitand(snum,256*256*256)!=0 then if rmode=1 then ret:=ret||','||'QCTExpiry'; elsif rmode=2 then return 7; else return 'last'; end if; end if;
    if bitand(snum,256*256*128)!=0 then if rmode=1 then ret:=ret||','||'ConfigurationChange'; elsif rmode=2 then return 8; else return 'continue'; end if; end if;
    if bitand(snum,256*256*64)!=0 then if rmode=1 then ret:=ret||','||'ServiceStop'; elsif rmode=2 then return 9; else return 'last'; end if; end if;
    if bitand(snum,256*256*32)!=0 then if rmode=1 then ret:=ret||','||'TimeThresholdReached'; elsif rmode=2 then return 10; else return 'continue'; end if; end if;
    if bitand(snum,256*256*16)!=0 then if rmode=1 then ret:=ret||','||'VolumeThresholdReached'; elsif rmode=2 then return 11; else return 'continue'; end if; end if;
    if bitand(snum,256*256*8)!=0 then if rmode=1 then ret:=ret||','||'ServiceSpecificUnitThresholdReached'; elsif rmode=2 then return 12; else return 'continue'; end if; end if;
    if bitand(snum,256*256*4)!=0 then if rmode=1 then ret:=ret||','||'TimeExhausted'; elsif rmode=2 then return 13; else return 'continue'; end if; end if;
    if bitand(snum,256*256*2)!=0 then if rmode=1 then ret:=ret||','||'VolumeExhausted'; elsif rmode=2 then return 14; else return 'continue'; end if; end if;
    if bitand(snum,256*256)!=0 then if rmode=1 then ret:=ret||','||'ValidityTimeout'; elsif rmode=2 then return 15; else return 'last'; end if; end if;
    if bitand(snum,256*128)!=0 then if rmode=1 then ret:=ret||','||'ReturnRequested'; elsif rmode=2 then return 16; else return 'last'; end if; end if;
    if bitand(snum,256*64)!=0 then if rmode=1 then ret:=ret||','||'ReauthorisationRequest'; elsif rmode=2 then return 17; else return 'continue'; end if; end if;
    if bitand(snum,256*32)!=0 then if rmode=1 then ret:=ret||','||'ContinueOngoingSession'; elsif rmode=2 then return 18; else return 'continue'; end if; end if;
    if bitand(snum,256*16)!=0 then if rmode=1 then ret:=ret||','||'RetryAndTerminateOngoingSession'; elsif rmode=2 then return 19; else return 'last'; end if; end if;
    if bitand(snum,256*8)!=0 then if rmode=1 then ret:=ret||','||'TerminateOngoingSession'; elsif rmode=2 then return 20; else return 'last'; end if; end if;
    if bitand(snum,256*4)!=0 then if rmode=1 then ret:=ret||','||'CGI-SAIChange'; elsif rmode=2 then return 21; else return 'continue'; end if; end if;
    if bitand(snum,256*2)!=0 then if rmode=1 then ret:=ret||','||'RAIChange'; elsif rmode=2 then return 22; else return 'continue'; end if; end if;
    if bitand(snum,256)!=0 then if rmode=1 then ret:=ret||','||'ServiceSpecificUnitExhausted'; elsif rmode=2 then return 23; else return 'continue'; end if; end if;
    if bitand(snum,128)!=0 then if rmode=1 then ret:=ret||','||'RecordClosure'; elsif rmode=2 then return 24; else return 'last'; end if; end if;
    if bitand(snum,64)!=0 then if rmode=1 then ret:=ret||','||'TimeLimit'; elsif rmode=2 then return 25; else return 'continue'; end if; end if;
    if bitand(snum,32)!=0 then if rmode=1 then ret:=ret||','||'VolumeLimit'; elsif rmode=2 then return 26; else return 'continue'; end if; end if;
    if bitand(snum,16)!=0 then if rmode=1 then ret:=ret||','||'ServiceSpecificUnitLimit'; elsif rmode=2 then return 27; else return 'continue'; end if; end if;
    if bitand(snum,8)!=0 then if rmode=1 then ret:=ret||','||'EnvelopeClosure'; elsif rmode=2 then return 28; else return 'last'; end if; end if;
    if bitand(snum,4)!=0 then if rmode=1 then ret:=ret||','||'ECGIChange'; elsif rmode=2 then return 29; else return 'continue'; end if; end if;
    if bitand(snum,2)!=0 then if rmode=1 then ret:=ret||','||'TAIChange'; elsif rmode=2 then return 30; else return 'continue'; end if; end if;
    if bitand(snum,1)!=0 then if rmode=1 then ret:=ret||','||'UserLocationChange'; elsif rmode=2 then return 31; else return 'continue'; end if; end if;
    ret:=ltrim(ret,',');
  elsif p_causeforrecordclosing is not null then
    if rmode=2 then return -1; end if;
    if    p_causeforrecordclosing=0  then if rmode=1 then return 'NormalRelease'; else return 'last'; end if;
    elsif p_causeforrecordclosing=1  then if rmode=1 then return 'PartialRecord'; else return 'continue'; end if;
    elsif p_causeforrecordclosing=2  then if rmode=1 then return 'PartialRecordCallReestablishment'; else return 'continue'; end if;
    elsif p_causeforrecordclosing=3  then if rmode=1 then return 'UnsuccessfulCallAttempt'; else return 'last'; end if;
    elsif p_causeforrecordclosing=4  then if rmode=1 then return 'AbnormalRelease'; else return 'last'; end if;
    elsif p_causeforrecordclosing=5  then if rmode=1 then return 'CAMELInitCallRelease'; else return 'last'; end if;
    elsif p_causeforrecordclosing=6  then if rmode=1 then return 'CAMELCPHCallConfigurationChange'; else return 'last'; end if;
    elsif p_causeforrecordclosing=16 then if rmode=1 then return 'VolumeLimit'; else return 'continue'; end if;
    elsif p_causeforrecordclosing=17 then if rmode=1 then return 'TimeLimit'; else return 'continue'; end if;
    elsif p_causeforrecordclosing=18 then if rmode=1 then return 'ServingNodeChange (sGSNChange)'; else return 'continue'; end if;
    elsif p_causeforrecordclosing=19 then if rmode=1 then return 'MaxChangeCond'; else return 'continue'; end if;
    elsif p_causeforrecordclosing=20 then if rmode=1 then return 'ManagementIntervention'; else return 'continue'; end if;
    elsif p_causeforrecordclosing=21 then if rmode=1 then return 'IntraSGSNIntersystemChange'; else return 'continue'; end if;
    elsif p_causeforrecordclosing=22 then if rmode=1 then return 'RATChange'; else return 'continue'; end if;
    elsif p_causeforrecordclosing=23 then if rmode=1 then return 'MSTimeZoneChange'; else return 'continue'; end if;
    elsif p_causeforrecordclosing=24 then if rmode=1 then return 'SGSNPLMNIDChange'; else return ' continue'; end if;
    elsif p_causeforrecordclosing=25 then if rmode=1 then return 'SGWChange'; else return 'continue'; end if;
    elsif p_causeforrecordclosing=26 then if rmode=1 then return 'APNAMBRChange'; else return 'continue'; end if;
    elsif p_causeforrecordclosing=27 then if rmode=1 then return 'AbsentSubscriber'; else return 'last'; end if;
    elsif p_causeforrecordclosing=34 then if rmode=1 then return 'SystemFailure'; else return 'last'; end if;
    elsif p_causeforrecordclosing=35 then if rmode=1 then return 'DataMissing'; else return 'last'; end if;
    elsif p_causeforrecordclosing=36 then if rmode=1 then return 'UnexpectedData'; else return 'last'; end if;
    elsif p_causeforrecordclosing=52 then if rmode=1 then return 'UnauthorizedRequestingNetwork'; else return 'last'; end if;
    elsif p_causeforrecordclosing=53 then if rmode=1 then return 'UnauthorizedLCSClient'; else return 'last'; end if;
    elsif p_causeforrecordclosing=54 then if rmode=1 then return 'PositionMethodFailure'; else return 'last'; end if;
    elsif p_causeforrecordclosing=58 then if rmode=1 then return 'UnknownOrUnreachableLCSClient'; else return 'last'; end if;
    elsif p_causeforrecordclosing=59 then if rmode=1 then return 'ListofDownstreamNodeChange'; else return 'continue'; end if;
    else if rmode=1 then return 'UNSPECIFIED'; else return 'last'; end if;
    end if;
  else
    return null;
  end if;
  return ret;
end decode_pgw_finalism;

PROCEDURE WRITE_LOGA ( p_log_type IN varchar2, p_log_level IN number, p_module_name IN varchar2, p_module_key IN varchar2, p_module_info IN varchar2 default null ) IS
  PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN
  insert into log_data ( log_type, log_id, log_level, module_name, module_key, module_info )
  values               ( p_log_type, SEQ_LOG.NEXTVAL, p_log_level, p_module_name, p_module_key, p_module_info );
-- TODO if parameter set  
  dbms_output.put_line(p_module_key||' -> '||p_module_info);
-- TODO write progress to   
  COMMIT;
END WRITE_LOGA ;

function fdm_pgw ( p_spnum in varchar2, p_dtm in date, p_rid2 in number ) return varchar2 IS
  t_loop number:=0;
BEGIN  
  for ca in ( select dtm, rid_day, rid_mon
                from PROC_FDM 
               where spnum=p_spnum and dtm between trunc(p_dtm,'MM') and trunc(p_dtm,'DD')
            order by dtm ) loop
    if    ca.rid_mon=p_rid2        then return 'M'; 
    elsif ca.rid_day=p_rid2        then return 'D';
    elsif ca.dtm<trunc(p_dtm,'DD') then t_loop:=t_loop+1;
    elsif ca.dtm=trunc(p_dtm,'DD') then return '-';  
    end if;
  end loop;
-- if we get here there is first 
  if t_loop>0 then -- daily
    insert into PROC_FDM ( spnum, dtm, tab, rid_day ) values (p_spnum, trunc(p_dtm,'DD'), 'HUA_PGW', p_rid2 );
    return 'D';
  else -- or monthly    
    insert into PROC_FDM ( spnum, dtm, tab, rid_day, rid_mon ) values (p_spnum, trunc(p_dtm,'DD'), 'HUA_PGW', p_rid2, p_rid2 );
    return 'M';    
  end if;
  return '-';
end fdm_pgw;


-- TODO: flags/parameters for breaking groups
procedure proc_pgw ( p_swid in number, p_min_dtm in date, p_max_dtm in date, p_over in number, 
                     p_singles in number default 0, p_restart in number default 0 ) IS
--  first_roid         rowid;
--  first_rid          number:=0;
--  first_dtm          date;
--  first_losd_timerep date;  
--  prev_roid            rowid;    
--  prev_servedmsisdn    varchar2(32);
--  prev_losd_rgroup     number:=0;
--  prev_losd_chrulename varchar2(64);
--  prev_losd_localseqnum number:=0;
--  prev_losd_timerep     date;
  sum_dur number:=0;  
  sum_ul  number:=0;
  sum_dl  number:=0;
  t_spnum cdrhua_pgw.e#spnum%TYPE;
  t_spton cdrhua_pgw.e#spton%TYPE;
  t_spocs cdrhua_pgw.e#spocs%TYPE;
  t_sptos cdrhua_pgw.e#sptos%TYPE;
  t_day number;
  t_mon number;
  t_uni char(1);
  t_dm  char(1);
--  first_swid number;
--  first_src varchar2(64);
--  first_dst varchar2(64);
  l_module_key LOG_DATA.MODULE_KEY%TYPE:='{"SWID"="'||p_swid||'",'||
                                          '"MIN_DTM"="'||to_char(p_min_dtm,'YYYYMMDD-HH24:MI')||'",'||
                                          '"MAX_DTM"="'||to_char(p_max_dtm,'YYYYMMDD-HH24:MI')||'",'||
                                          '"OVER"="'||p_over||'"SINGLES"="'||p_singles||'"RESTART"="'||p_restart||'"}';
  l_module_info LOG_DATA.MODULE_INFO%TYPE;
  l_cnt    number:=0; -- all records 
  l_cnt_gr number:=0; -- break groups
  l_cnt_ch number:=0; -- updated
  l_cnt_sn number:=0; -- singles
  l_cnt_dm number:=0; -- day/mon first
  t_tstart timestamp;
  t_tenter timestamp;  
  r_first  cdrpgw_v%rowtype;  
  r_prev   cdrpgw_v%rowtype;
BEGIN
----
  WRITE_LOGA('PB',1,'PROC_PGW',l_module_key);
  t_tstart:=systimestamp;
----  
  proc_pkg.init;  
  for ca in ( select rowid roid, rid, 
                     servedmsisdn, losd_rgroup, losd_chrulename,
                     losd_srvcondch, causeforrecclosing,
                     dtm, losd_timerep, losd_localseqnum,
                     losd_datau, losd_datad, swid, src, dst,
                     a#dtm, a#dur, a#datau, a#datad, a#partid, e#spnum, e#spocs, e#sptos
                from cdrpgw_v
               where dtm between p_min_dtm and p_max_dtm and swid=p_swid
                 and losd_chrulename is not null 
                 and ((p_over=0 and x#status like '-%') -- not processed
                    or p_over=1) -- overwrite
            order by servedmsisdn, losd_rgroup, losd_chrulename, losd_timerep, losd_localseqnum, dtm, losd_datad ) loop
--            
    if r_first.rid is null or -- FIRST record
       nvl(r_prev.servedmsisdn,'X')!=ca.servedmsisdn or nvl(r_prev.losd_rgroup,-1)!=ca.losd_rgroup or nvl(r_prev.losd_chrulename,'X')!=ca.losd_chrulename or -- group change
       (ca.losd_localseqnum-r_prev.losd_localseqnum)!=1 or nvl(to_char(r_prev.losd_timerep,'DDHH24'),'0000')!=to_char(ca.losd_timerep,'DDHH24') 
         or ( bitand(p_restart,1)!=0 and (sum_dl>200000000 or sum_ul>200000000 or decode_pgw_finalism(ca.losd_srvcondch,ca.causeforrecclosing)='last/first')) then
       if r_first.rid is not null then -- complete processing, flush previous start record
-- write first and last=prev (NO CONDITIONS to avoid identical rewrites YET)
          if r_first.roid!=r_prev.roid then
/* do enrichment etc */
            t_spnum:=proc_pkg.UNI_MSISDN('HUAPGW',r_first.swid,r_first.dtm,r_prev.servedmsisdn,5,r_first.src,r_first.dst,0);
            if    t_spnum is null then t_uni:='U'; -- not unified
            elsif t_sptos is null then t_uni:='G'; -- not in GSR
            else                       t_uni:='-'; end if;
            proc_pkg.GET_TOSOCS(t_spnum,r_first.dtm,t_spocs,t_sptos);
            if t_spnum is null then t_dm:='-';
            else                    t_dm:=fdm_pgw(t_spnum,r_first.dtm,r_first.rid);  end if;
            if t_dm!='-' then l_cnt_dm:=l_cnt_dm+1; end if;
/* end of enrichment */
            update cdrpgw_v set x#features='L'||substr(x#features,2), x#lru=sysdate 
              where rowid=r_prev.roid AND (nvl(a#partid,-1)!=r_first.rid or x#features!='L'||substr(x#features,2));
            l_cnt_ch:=l_cnt_ch+SQL%ROWCOUNT;            
            update cdrpgw_v set x#status='+'||substr(x#status,2), x#features='F'||t_uni||t_dm||substr(x#features,4), 
                                a#dtm=r_first.losd_timerep, a#dur=sum_dur, a#datau=sum_ul, a#datad=sum_dl, a#partid=r_first.rid, x#lru=sysdate,
                                e#spnum=t_spnum, e#spton=1, e#spocs=t_spocs, e#sptos=t_sptos
              where rowid=r_first.roid AND 
                  (x#status!='+'||substr(x#status,2) OR x#features!='F'||t_uni||t_dm||substr(x#features,4) OR
                   nvl(a#dtm,sysdate)!=r_first.losd_timerep OR nvl(a#dur,-1)!=sum_dur OR
                   nvl(a#datau,-1)!=sum_ul OR nvl(a#datad,-1)!=sum_dl OR nvl(a#partid,-1)!=r_first.rid OR
                   nvl(e#spnum,'X')!=nvl(t_spnum,'X') OR nvl(e#spocs,-1)!=nvl(t_spocs,-1) OR nvl(e#sptos,-1)!=nvl(t_sptos,-1));
            l_cnt_ch:=l_cnt_ch+SQL%ROWCOUNT;
          else -- single group = do nothing yet but conditional Single processing possible
            l_cnt_sn:=l_cnt_sn+1;
            if p_singles!=0 then
/* do enrichment etc */
              t_spnum:=proc_pkg.UNI_MSISDN('HUAPGW',r_first.swid,r_first.dtm,r_first.servedmsisdn,5,r_first.src,r_first.dst,0);
              if    t_spnum is null then t_uni:='U'; -- not unified
              elsif t_sptos is null then t_uni:='G'; -- not in GSR
              else                       t_uni:='-'; end if;
              proc_pkg.GET_TOSOCS(t_spnum,r_first.dtm,t_spocs,t_sptos);
              if t_spnum is null then t_dm:='-';
              else                    t_dm:=fdm_pgw(t_spnum,r_first.dtm,r_first.rid);  end if;
              if t_dm!='-' then l_cnt_dm:=l_cnt_dm+1; end if;
/* end of enrichment */
              update cdrpgw_v set x#status='+'||substr(x#status,2), x#features='S'||t_uni||t_dm||substr(x#features,4), 
                                  a#dtm=r_first.losd_timerep, a#dur=sum_dur, a#datau=sum_ul, a#datad=sum_dl, a#partid=r_first.rid, x#lru=sysdate,
                                  e#spnum=t_spnum, e#spton=1, e#spocs=t_spocs, e#sptos=t_sptos
                where rowid=r_first.roid AND 
                   (x#status!='+'||substr(x#status,2) OR x#features!='S'||t_uni||t_dm||substr(x#features,4) OR
                    nvl(a#dtm,sysdate)!=r_first.losd_timerep OR nvl(a#dur,-1)!=sum_dur OR
                    nvl(a#datau,-1)!=sum_ul OR nvl(a#datad,-1)!=sum_dl OR nvl(a#partid,-1)!=r_first.rid OR
                    nvl(e#spnum,'X')!=nvl(t_spnum,'X') OR nvl(e#spocs,-1)!=nvl(t_spocs,-1) OR nvl(e#sptos,-1)!=nvl(t_sptos,-1));
              l_cnt_ch:=l_cnt_ch+SQL%ROWCOUNT;
            end if;
          end if;
          l_cnt_gr:=l_cnt_gr+1;
          commit;
       else
          t_tenter:=systimestamp;
          WRITE_LOGA('PP',0,'PROC_PGW',l_module_key,to_char(extract(SECOND FROM(t_tenter - t_tstart))));
       end if;
       sum_dur:=round((ca.losd_timerep-ca.dtm)*86400); -- fill next start
       sum_ul:=ca.losd_datau; 
       sum_dl:=ca.losd_datad; 
       t_uni:='-';
       t_dm:='-';
       
       r_prev.roid:=ca.roid; r_prev.rid:=ca.rid; 
       r_prev.servedmsisdn:=ca.servedmsisdn;
       r_prev.losd_rgroup:=ca.losd_rgroup;
       r_prev.losd_chrulename:=ca.losd_chrulename;
       r_prev.losd_srvcondch:=ca.losd_srvcondch;
       r_prev.causeforrecclosing:=ca.causeforrecclosing;
       r_prev.dtm:=ca.dtm; r_prev.losd_timerep:=ca.losd_timerep; r_prev.losd_localseqnum:=ca.losd_localseqnum;
       r_prev.src:=ca.src; r_prev.dst:=ca.dst;
       r_prev.a#dtm:=ca.a#dtm; r_prev.a#dur:=ca.a#dur; r_prev.a#datau:=ca.a#datau; r_prev.a#datad:=ca.a#datad;
       r_prev.a#partid:=ca.a#partid; r_prev.e#spnum:=ca.e#spnum; r_prev.e#spocs:=ca.e#spocs; r_prev.e#sptos:=ca.e#sptos;
       r_first:=r_prev;
       
    else 
       update cdrpgw_v set x#status='+'||substr(x#status,2), x#features='I'||substr(x#features,2), a#dtm=r_prev.losd_timerep, 
                           a#partid=r_first.rid, x#lru=sysdate 
        where rowid=ca.roid AND nvl(a#partid,-1)!=r_first.rid;
       l_cnt_ch:=l_cnt_ch+SQL%ROWCOUNT;
       sum_dur:=sum_dur+round((ca.losd_timerep-r_prev.losd_timerep)*86400);
       sum_ul:=sum_ul+ca.losd_datau;
       sum_dl:=sum_dl+ca.losd_datad;
       
       r_prev.roid:=ca.roid; r_prev.rid:=ca.rid; 
       r_prev.servedmsisdn:=ca.servedmsisdn;
       r_prev.losd_rgroup:=ca.losd_rgroup;
       r_prev.losd_chrulename:=ca.losd_chrulename;
       r_prev.losd_srvcondch:=ca.losd_srvcondch;
       r_prev.causeforrecclosing:=ca.causeforrecclosing;
       r_prev.dtm:=ca.dtm; r_prev.losd_timerep:=ca.losd_timerep; r_prev.losd_localseqnum:=ca.losd_localseqnum;
       r_prev.src:=ca.src; r_prev.dst:=ca.dst;
       r_prev.a#dtm:=ca.a#dtm; r_prev.a#dur:=ca.a#dur; r_prev.a#datau:=ca.a#datau; r_prev.a#datad:=ca.a#datad;
       r_prev.a#partid:=ca.a#partid; r_prev.e#spnum:=ca.e#spnum; r_prev.e#spocs:=ca.e#spocs; r_prev.e#sptos:=ca.e#sptos;
       
    end if;
    l_cnt:=l_cnt+1;    
  end loop;
-- FINAL ENTRY
  if r_first.rid is not null then -- complete processing, flush previous start record
    if r_first.roid!=r_prev.roid then
/* do enrichment etc */
      t_spnum:=proc_pkg.UNI_MSISDN('HUAPGW',r_first.swid,r_first.dtm,r_first.servedmsisdn,1,r_first.src,r_first.dst,0);
      if    t_spnum is null then t_uni:='U'; -- not unified
      elsif t_sptos is null then t_uni:='G'; -- not in GSR
      else                       t_uni:='-'; end if;
      proc_pkg.GET_TOSOCS(t_spnum,r_first.dtm,t_spocs,t_sptos);
      if t_spnum is null then t_dm:='-';
      else                    t_dm:=fdm_pgw(t_spnum,r_first.dtm,r_first.rid);  end if;  
      if t_dm!='-' then l_cnt_dm:=l_cnt_dm+1; end if;      
-- end of last enrich -> WRITE
      update cdrpgw_v set x#features='L'||substr(x#features,2) where rowid=r_prev.roid AND nvl(a#partid,-1)!=r_first.rid;
      l_cnt_ch:=l_cnt_ch+SQL%ROWCOUNT;      
      update cdrpgw_v set x#status='+'||substr(x#status,2), x#features='F'||t_uni||t_dm||substr(x#features,4), 
                          a#dtm=r_first.losd_timerep, a#dur=sum_dur, a#datau=sum_ul, a#datad=sum_dl, a#partid=r_first.rid, x#lru=sysdate,
                          e#spnum=t_spnum, e#spton=1, e#spocs=t_spocs, e#sptos=t_sptos
        where rowid=r_first.roid AND 
              (x#status!='+'||substr(x#status,2) OR x#features!='F'||t_uni||t_dm||substr(x#features,4) OR
               nvl(a#dtm,sysdate)!=r_first.losd_timerep OR nvl(a#dur,-1)!=sum_dur OR
               nvl(a#datau,-1)!=sum_ul OR nvl(a#datad,-1)!=sum_dl OR nvl(a#partid,-1)!=r_first.rid OR
               nvl(e#spnum,'X')!=nvl(t_spnum,'X') OR nvl(e#spocs,-1)!=nvl(t_spocs,-1) OR nvl(e#sptos,-1)!=nvl(t_sptos,-1));
      l_cnt_ch:=l_cnt_ch+SQL%ROWCOUNT;  
    else -- last single group
      null;
    end if;
    l_cnt_gr:=l_cnt_gr+1;
    commit;         
  end if;
----
  l_module_info:='{"CNT":"'||l_cnt||'","CNT_GR":"'||l_cnt_gr||'","CNT_SN":"'||l_cnt_sn||'","CNT_CH":"'||l_cnt_ch||'","CNT_DM":"'||l_cnt_dm||'","TPS":"'||round(l_cnt/(extract(SECOND FROM(systimestamp - t_tenter))))||'"}';
  WRITE_LOGA('PE',1,'PROC_PGW',l_module_key,l_module_info);
  commit;
end proc_pgw;


end prochua_pkg;
/
