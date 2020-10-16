create or replace package body cdrhua_pkg as

gpgwrecs arecs; -- ext array

procedure init is begin
-- sgsna
  if sgsna.count>0 then sgsna.delete; end if;
  for c in (select tagc, tag, tp from cdr_tags where tag_domain='HUA' and rec_type='SGSNA' and rec_version=1)
  loop
    sgsna(c.tagc).tp:=c.tp;  sgsna(c.tagc).tag:=c.tag;
  end loop;
-- pgwa
  if pgwa.count>0 then pgwa.delete; end if;
  for c in (select tagc, tag, tp from cdr_tags where tag_domain='HUA' and rec_type='PGWA' and rec_version=1)
  loop
    pgwa(c.tagc).tp:=c.tp;  pgwa(c.tagc).tag:=c.tag;
  end loop;
end init;

-- HUA record fields transformation to CHAR (return) and sometimes date and number
function parselet ( buf in varchar2, tp in number, dbuf out date, nbuf out number, tbuf out timestamp with time zone ) return varchar2 is
  cbuf varchar2(600);
begin
    if    tp=1 then if length(buf)=2 then nbuf:=to_number(upper(buf),'xx');
                    elsif length(buf)=4 then nbuf:=to_number(upper(buf),'xxxx');
                    elsif length(buf)=6 then nbuf:=to_number(upper(buf),'xxxxxx');
                    elsif length(buf)=8 then nbuf:=to_number(upper(buf),'xxxxxxxx'); end if;
                    cbuf:=to_char(nbuf);
    elsif tp=2 then cbuf:=UTL_I18N.RAW_TO_CHAR(hextoraw(upper(buf)),'AL32UTF8');
    elsif tp=4 then cbuf:=ASCIISTR(REGEXP_REPLACE(UTL_I18N.RAW_TO_CHAR(hextoraw(upper(buf)),'AL32UTF8'),'[^[:print:]]',''));
    elsif tp=3 then dbuf:=to_date(substr(buf,1,12),'RRMMDDHH24MISS'); -- ignore UTC offset
                    cbuf:=to_char(dbuf,'DD-MM-YYYY HH24:MI:SS');
    elsif tp=6 then cbuf:=to_number(upper(substr(buf,1,2)),'xx')||'.'||to_number(upper(substr(buf,3,2)),'xx')||'.'||
                          to_number(upper(substr(buf,5,2)),'xx')||'.'||to_number(upper(substr(buf,7,2)),'xx');
    elsif tp=5 then tbuf:=to_timestamp_tz(substr(buf,1,12)||substr(buf,15,4),'RRMMDDHH24MISSTZH:TZM');
                    cbuf:=to_char(tbuf,'DD-MM-YYYY HH24:MI:SS TZH:TZM');
    elsif tp=7 then for i in 1..length(buf)/2 loop cbuf:=cbuf||substr(buf,2*i,1)||substr(buf,2*i-1,1); end loop;
                    cbuf:=rtrim(cbuf,'f');
    else            cbuf:=buf;
    end if;
  return cbuf;
end parselet;

procedure putsgsn ( tag in varchar2, buf in varchar2, tp in number, idx in varchar2, wmode in number,
                    oinfo in out nocopy varchar2, osgsn in out nocopy cdrhua_sgsn%ROWTYPE, olotvs in out nocopy lotv ) is
  cbuf varchar2(600);
  tbuf timestamp with time zone;
  dbuf date;
  nbuf number;
begin
  if wmode=0 then
    if oinfo is null then oinfo:='{'; else oinfo:=oinfo||','; end if;
    oinfo:=oinfo||'"'||tag||'":"'||buf||'"'||chr(10);
  else
    cbuf:=parselet(buf,tp,dbuf,nbuf,tbuf);
    if bitand(wmode,2)!=0 then
      if    idx='83'       then osgsn.servedimsi:=cbuf;
      elsif idx='84'       then osgsn.servedimei:=cbuf;
      elsif idx='a5.80'    then osgsn.sgsnaddress:=cbuf;
      elsif idx='88'       then osgsn.locationareacode:=cbuf;
      elsif idx='89'       then osgsn.cellidentifier:=cbuf;
      elsif idx='ab.80'    then osgsn.ggsnaddress:=cbuf;
      elsif idx='8c'       then osgsn.apnameni:=cbuf;
      elsif idx='ae.a0.80' then osgsn.servedpdpaddress:=cbuf;
      elsif idx='9b'       then osgsn.servedmsisdn:=cbuf;
      elsif idx='8a'       then osgsn.chargingid:=nbuf; -- numbers
      elsif idx='91'       then osgsn.duration:=nbuf;
      elsif idx='93'       then osgsn.causeforrecclosing:=nbuf;
      elsif idx='95'       then osgsn.recordseqnumber:=nbuf;
      elsif idx='9d'       then osgsn.rattype:=nbuf;
      elsif idx='90'       then null; -- RecordOpeningTime already parsed
      elsif idx='af.86'    then olotvs.changeTime:=tbuf;
      elsif idx='af.83'    then olotvs.dataU:=nbuf;
      elsif idx='af.84'    then olotvs.dataD:=nbuf;
      elsif idx='af.85'    then olotvs.chCnd:=nbuf;
      else
        if oinfo is null then oinfo:='{'; else oinfo:=oinfo||','; end if;
        oinfo:=oinfo||'"'||tag||'":"'||cbuf||'"'||chr(10);
      end if;
    else
      if oinfo is null then oinfo:='{'; else oinfo:=oinfo||','; end if;
      oinfo:=oinfo||'"'||tag||'":"'||cbuf||'"'||chr(10);
    end if;
  end if;
exception
  when others then
    if osgsn.errs is null then osgsn.errs:='{'; else osgsn.errs:=rtrim(osgsn.errs,'}')||','; end if;
    osgsn.errs:=rtrim(osgsn.errs,'}')||chr(10)||'"ERROR":"'||tag||'#'||tp||' - '||buf||' >> '||SQLERRM||'"'||chr(10)||'}';
end putsgsn;

function hua ( rbody in varchar2, info out nocopy varchar2 ) return date is
  buf1 varchar2(4000);
  tag1 varchar2(6);
  len1 number;
  dtm  date;
begin
-- skip constants at beginning of record
  if    substr(rbody,1,6) in ('bf4f82','bf4e82')    then  buf1:=substr(rbody,11);
  elsif substr(rbody,1,4) in ('bf4f','bf4e','b482') then  buf1:=substr(rbody,9);
  else                                                    buf1:=substr(rbody,7); end if;
-- PARSER BY ITSELT
if substr(rbody,1,4) in ('bf4f','bf4e') then  -- PGW, SGW
  while ( length(buf1)>0 ) loop
    if huap.exists(substr(buf1,1,2)) then -- 1-byte tag
      tag1:=substr(buf1,1,2);
      if buf1 like 'ac81__30%' then
        len1:=to_number(substr(buf1,5,2),'xx'); -- long sequence ac
      else
        len1:=to_number(substr(buf1,3,2),'xx');
      end if;
      if tag1='8d' then -- direct date (without timezone) conversion
        dtm:=to_date(substr(buf1,5,12),'RRMMDDHH24MISS');
        info:=info||',"'||huap(tag1).tag||'":"'||substr(buf1,5,12)||'"'||chr(10)||'}';
        exit;
      else
        if info is null then info:='{'; else info:=info||','; end if;
        info:=info||'"'||huap(tag1).tag||'":"'||substr(buf1,5,len1*2)||'"'||chr(10);
      end if;
      if buf1 like 'ac81__30%' then
        buf1:=substr(buf1,7+len1*2);
      else
        buf1:=substr(buf1,5+len1*2);
      end if;
    else
      if info is null then info:='{'; else info:=info||','; end if;
      info:=rtrim(info,'}')||chr(10)||'"ERROR":"PGW/SGW group not_found - '||buf1||'"'||chr(10)||'}';
      exit;
    end if;
  end loop;
else -- SGSN
  while ( length(buf1)>0 ) loop
    if huas.exists(substr(buf1,1,2)) then -- 1-byte tag
      tag1:=substr(buf1,1,2);
      len1:=to_number(substr(buf1,3,2),'xx');
      if tag1='90' then -- direct date (without timezone) conversion
        dtm:=to_date(substr(buf1,5,12),'RRMMDDHH24MISS');
        info:=info||',"'||huas(tag1).tag||'":"'||substr(buf1,5,12)||'"'||chr(10)||'}';
        exit;
      else
        if info is null then info:='{'; else info:=info||','; end if;
        info:=info||'"'||huas(tag1).tag||'":"'||substr(buf1,5,len1*2)||'"'||chr(10);
      end if;
      buf1:=substr(buf1,5+len1*2);
    else
      if info is null then info:='{'; else info:=info||','; end if;
      info:=rtrim(info,'}')||chr(10)||'"ERROR":"HUA group not_found - '||buf1||'"'||chr(10)||'}';
      exit;
    end if;
  end loop;
end if;
-- NO DATE FOUND
  if dtm is null then
     dtm:=trunc(sysdate);
     if info is null then info:='{'; else info:=info||','; end if;
     info:=rtrim(info,'}')||chr(10)||'"ERROR":"date tag not found - using trunc(sysdate) instead"'||chr(10)||'}';
  end if;
  return dtm;
end hua;

function sgsn ( rbody in varchar2, wmode in number, osgsn out cdrhua_sgsn%ROWTYPE, olotvs out lotvs ) return varchar2 is
  buf1 varchar2(2000);   buf2 varchar2(800);   buf3 varchar2(400);
  tag1 varchar2(6);      tag2 varchar2(10);    tag3 varchar2(14);
  len1 number;           len2 number;          len3 number;
  loti number:=0;
begin
-- skip beginning of record
  if    substr(rbody,1,4)='b481' then buf1:=substr(rbody,7);
  elsif substr(rbody,1,4)='b482' then buf1:=substr(rbody,9);
  else                                return '-';             end if;
-- how to clear all ??
  osgsn.errs:=null;
  osgsn.info:=null;
  olotvs(loti).dataU:=0;
-- PARSE
  while ( length(buf1)>0 ) loop
    if cdrhua_pkg.sgsna.exists(substr(buf1,1,2)) then -- 1-byte tag
      tag1:=substr(buf1,1,2);
      len1:=to_number(substr(buf1,3,2),'xx');
      if cdrhua_pkg.sgsna(tag1).tp>20 then -- level-2 SEQUENCE OF
        buf2:=substr(buf1,5,len1*2);
        while ( length(buf2)>0 ) loop
          if substr(buf2,1,2)='30' then
            len3:=to_number(substr(buf2,3,2),'xx');
            buf3:=substr(buf2,5,len3*2);
            buf2:=substr(buf2,5+len3*2);
            olotvs(loti).dataU:=0;
            while ( length(buf3)>0 ) loop -- N-th sequence block
               if cdrhua_pkg.sgsna.exists(tag1||'.'||substr(buf3,1,2)) then -- 1-byte L3
                 tag3:=tag1||'.'||substr(buf3,1,2);
                 len3:=to_number(substr(buf3,3,2),'xx');
                 putsgsn(cdrhua_pkg.sgsna(tag3).tag,substr(buf3,5,len3*2),cdrhua_pkg.sgsna(tag3).tp,tag3,wmode,osgsn.info,osgsn,olotvs(loti));
               else
                 if osgsn.errs is null then osgsn.errs:='{'; else osgsn.errs:=osgsn.errs||','; end if;
                 osgsn.errs:=rtrim(osgsn.errs,'}')||chr(10)||'"SEQUENCEOF_TAG":"'||buf3||'"'||chr(10)||'}';
                 exit;
               end if;
               buf3:=substr(buf3,5+len3*2);
            end loop;
            loti:=loti+1;
          else
            if osgsn.errs is null then osgsn.errs:='{'; else osgsn.errs:=osgsn.errs||','; end if;
            osgsn.errs:=rtrim(osgsn.errs,'}')||chr(10)||'"SEQUENCEOF_BLOCK":"'||buf2||'"'||chr(10)||'}';
            exit;
          end if;
        end loop;
      elsif cdrhua_pkg.sgsna(tag1).tp>10 then -- level-2
        buf2:=substr(buf1,5,len1*2);
        while ( length(buf2)>0 ) loop
          if cdrhua_pkg.sgsna.exists(tag1||'.'||substr(buf2,1,2)) then -- 1-byte L2
            tag2:=tag1||'.'||substr(buf2,1,2);
            len2:=to_number(substr(buf2,3,2),'xx');
            if cdrhua_pkg.sgsna(tag2).tp>10 then -- level-3
               buf3:=substr(buf2,5,len2*2);
               while ( length(buf3)>0 ) loop
                 if cdrhua_pkg.sgsna.exists(tag2||'.'||substr(buf3,1,2)) then -- 1-byte L3
                   tag3:=tag2||'.'||substr(buf3,1,2);
                   len3:=to_number(substr(buf3,3,2),'xx');
                   putsgsn(cdrhua_pkg.sgsna(tag3).tag,substr(buf3,5,len3*2),cdrhua_pkg.sgsna(tag3).tp,tag3,wmode,osgsn.info,osgsn,olotvs(0));
                 else
                   if osgsn.errs is null then osgsn.errs:='{'; else osgsn.errs:=osgsn.errs||','; end if;
                   osgsn.errs:=rtrim(osgsn.errs,'}')||chr(10)||'"TAG_LEVEL3":"'||buf3||'"'||chr(10)||'}';
                   exit;
                 end if;
                 buf3:=substr(buf3,5+len3*2);
               end loop;
            else
               putsgsn(cdrhua_pkg.sgsna(tag2).tag,substr(buf2,5,len2*2),cdrhua_pkg.sgsna(tag2).tp,tag2,wmode,osgsn.info,osgsn,olotvs(0));
            end if;
            buf2:=substr(buf2,5+len2*2);
          else
            if osgsn.errs is null then osgsn.errs:='{'; else osgsn.errs:=osgsn.errs||','; end if;
            osgsn.errs:=rtrim(osgsn.errs,'}')||chr(10)||'"TAG_LEVEL2":"'||buf2||'"'||chr(10)||'}';
            exit;
          end if;
        end loop;
      else
        putsgsn(cdrhua_pkg.sgsna(tag1).tag,substr(buf1,5,len1*2),cdrhua_pkg.sgsna(tag1).tp,tag1,wmode,osgsn.info,osgsn,olotvs(0));
      end if;
      buf1:=substr(buf1,5+len1*2);
    elsif cdrhua_pkg.sgsna.exists(substr(buf1,1,4)) then -- 2-byte tag
      tag1:=substr(buf1,1,4);
      len1:=to_number(substr(buf1,5,2),'xx'); -- level-2 not inmlemented
      putsgsn(cdrhua_pkg.sgsna(tag1).tag,substr(buf1,7,len1*2),cdrhua_pkg.sgsna(tag1).tp,tag1,wmode,osgsn.info,osgsn,olotvs(0));
      buf1:=substr(buf1,7+len1*2);
    else
      if osgsn.errs is null then osgsn.errs:='{'; else osgsn.errs:=osgsn.errs||','; end if;
      osgsn.errs:=rtrim(osgsn.errs,'}')||chr(10)||'"TAG_LEVEL1":"'||buf1||'"'||chr(10)||'}';
      exit;
    end if;
  end loop;
  if osgsn.info is not null then osgsn.info:=osgsn.info||'}'; end if;
  return osgsn.errs;
end sgsn;

procedure putpgw ( tag in varchar2, buf in varchar2, tp in number, idx in varchar2, wmode in number,
                   oinfo in out nocopy varchar2, opgw in out nocopy cdrhua_pgw%ROWTYPE, 
                   olotvs in out nocopy lotv, olosds in out nocopy losd, ilotv number, ilosd number ) is
  cbuf varchar2(800);
  tbuf timestamp with time zone;
  dbuf date;
  nbuf number;
begin
  if wmode=0 then
    if oinfo is null then oinfo:='{'; else oinfo:=oinfo||','; end if;
    oinfo:=oinfo||'"'||tag||'":"'||buf||'"'||chr(10);
  else
    cbuf:=parselet(buf,tp,dbuf,nbuf,tbuf);
    
    declare
      cind varchar2(4);
    begin
      if greatest(ilotv,ilosd)>0 then cind:='_'||greatest(ilotv,ilosd); end if;
      gpgwrecs(tag||cind).tag:=idx;
      gpgwrecs(tag||cind).i:=greatest(ilotv,ilosd);
      gpgwrecs(tag||cind).cbuf:=cbuf;
      gpgwrecs(tag||cind).nbuf:=nbuf;
      gpgwrecs(tag||cind).dbuf:=dbuf;
      gpgwrecs(tag||cind).tbuf:=tbuf;
    end;
    
    if bitand(wmode,2)!=0 then
/*****/
if    idx='83' then opgw.servedimsi:=cbuf;
elsif    idx='85' then opgw.chargingid:=nbuf;
elsif    idx='87' then opgw.apnameni:=cbuf;
elsif    idx='8e' then opgw.duration:=nbuf;
elsif    idx='8f' then opgw.causeforrecclosing:=nbuf;
elsif    idx='91' then opgw.recordseqnumber:=nbuf;
elsif    idx='94' then opgw.localseqnum:=nbuf;
elsif    idx='96' then opgw.servedmsisdn:=cbuf;
elsif    idx='9b' then opgw.srvnodeplmnid:=cbuf;
elsif    idx='9d' then opgw.servedimeisv:=cbuf;
elsif    idx='9e' then opgw.rattype:=nbuf;
elsif    idx='9f20' then opgw.userloc:=cbuf;
elsif    idx='a4.80' then opgw.pgwaddress:=cbuf;
elsif    idx='a6.80' then opgw.srvnodeaddress:=cbuf;
elsif    idx='a9.a0.80' then opgw.servedpdnaddress:=cbuf;
elsif    idx='ac.83' then olotvs.datau:=nbuf;
elsif    idx='ac.84' then olotvs.datad:=nbuf;
elsif    idx='ac.85' then olotvs.chcnd:=nbuf;
elsif    idx='ac.86' then olotvs.changetime:=tbuf;
elsif    idx='ac.88' then olotvs.userloc:=cbuf;
elsif    idx='bf22.81' then olosds.rgroup:=nbuf;
elsif    idx='bf22.82' then olosds.chrulename:=cbuf;
elsif    idx='bf22.84' then olosds.localseqnum:=nbuf;
elsif    idx='bf22.85' then olosds.timefirst:=dbuf;
elsif    idx='bf22.86' then olosds.timelast:=dbuf;
elsif    idx='bf22.87' then olosds.timeusage:=nbuf;
elsif    idx='bf22.88' then olosds.srvcondch:=cbuf;
elsif    idx='bf22.8c' then olosds.datau:=nbuf;
elsif    idx='bf22.8d' then olosds.datad:=nbuf;
elsif    idx='bf22.8e' then olosds.timerep:=dbuf;
elsif    idx='bf22.8f' then olosds.rattype:=nbuf;
elsif    idx='bf22.91' then olosds.srvidentifier:=nbuf;
elsif    idx='bf22.94' then olosds.userloc:=nbuf;
elsif    idx='bf22.aa.80' then olosds.sgsnaddress:=cbuf;
/*****/
      else
        if oinfo is null then oinfo:='{'; else oinfo:=oinfo||','; end if;
        oinfo:=oinfo||'"'||tag||'":"'||cbuf||'"'||chr(10);
      end if;
    else
      if oinfo is null then oinfo:='{'; else oinfo:=oinfo||','; end if;
      oinfo:=oinfo||'"'||tag||'":"'||cbuf||'"'||chr(10);
    end if;
  end if;
exception
  when others then
    if length(opgw.errs)<2000 then
      if opgw.errs is null then opgw.errs:='{'; else opgw.errs:=rtrim(opgw.errs,'}')||','; end if;
      opgw.errs:=rtrim(opgw.errs,'}')||chr(10)||'"ERROR":"'||tag||'#'||tp||' - '||buf||' >> '||SQLERRM||'"'||chr(10)||'}';
    end if;
end putpgw;

-- parse HUA to PGW AFTER
function pgw ( rbody in varchar2, wmode in number, opgw out cdrhua_pgw%ROWTYPE, olotvs out lotvs, olosds out losds ) return  varchar2 IS
  buf1 varchar2(4000);   buf2 varchar2(3200);   buf3 varchar2(2200);  buf4 varchar2(400);
  tag1 varchar2(8);      tag2 varchar2(12);     tag3 varchar2(16);    tag4 varchar2(20);
  len1 number;           len2 number;           len3 number;          len4 number;
  loti number:=0;
  lots number:=0;
  erecs arecs;
begin
  gpgwrecs:=erecs; -- clear global array by assigning
-- skip constants at beginning of record
  if    substr(rbody,1,6) in ('bf4f82','bf4e82')    then  buf1:=substr(rbody,11);
  elsif substr(rbody,1,4) in ('bf4f','bf4e')        then  buf1:=substr(rbody,9);
  else                                                    return '-';             end if;
-- how to clear all ??
  opgw.errs:=null;
  opgw.info:=null;
  olotvs(loti).dataU:=0;
  olosds(lots).dataU:=0;
-- PARSE
  while ( length(buf1)>0 ) loop
    if cdrhua_pkg.pgwa.exists(substr(buf1,1,2)) then -- 1-byte tag
      tag1:=substr(buf1,1,2);
      if buf1 like 'ac81__30%' then
        len1:=to_number(substr(buf1,5,2),'xx'); -- long sequence ac
      else
        len1:=to_number(substr(buf1,3,2),'xx');
      end if;
      if cdrhua_pkg.pgwa(tag1).tp>20 then -- level-2 SEQUENCE OF
        if buf1 like 'ac81__30%' then
          buf2:=substr(buf1,7,len1*2);
        else
          buf2:=substr(buf1,5,len1*2);
        end if;
        while ( length(buf2)>0 ) loop
          if substr(buf2,1,2)='30' then
            len3:=to_number(substr(buf2,3,2),'xx');
            buf3:=substr(buf2,5,len3*2);
            buf2:=substr(buf2,5+len3*2);
            olotvs(loti).dataU:=0;
            while ( length(buf3)>0 ) loop -- N-th sequence block
               if cdrhua_pkg.pgwa.exists(tag1||'.'||substr(buf3,1,2)) then -- 1-byte L3
                 tag3:=tag1||'.'||substr(buf3,1,2);
                 len3:=to_number(substr(buf3,3,2),'xx');
                 if cdrhua_pkg.pgwa(tag3).tp>10 then -- level-4
                   buf4:=substr(buf3,5,len3*2);
                   while ( length(buf4)>0 ) loop
                     if cdrhua_pkg.pgwa.exists(tag3||'.'||substr(buf4,1,2)) then -- 1-byte L4
                       tag4:=tag3||'.'||substr(buf4,1,2);
                       len4:=to_number(substr(buf4,3,2),'xx');
                       putpgw(cdrhua_pkg.pgwa(tag4).tag,substr(buf4,5,len4*2),cdrhua_pkg.pgwa(tag4).tp,tag4,wmode,opgw.info,opgw,olotvs(loti),olosds(0),loti,0);
                     else
                       if opgw.errs is null then opgw.errs:='{'; else opgw.errs:=opgw.errs||','; end if;
                       opgw.errs:=rtrim(opgw.errs,'}')||chr(10)||'"TAG_LEVEL4":"'||buf4||'"'||chr(10)||'}';
                       exit;
                     end if;
                     buf4:=substr(buf4,5+len4*2);
                   end loop;
                 else
                   putpgw(cdrhua_pkg.pgwa(tag3).tag,substr(buf3,5,len3*2),cdrhua_pkg.pgwa(tag3).tp,tag3,wmode,opgw.info,opgw,olotvs(loti),olosds(0),loti,0);
                 end if;
               else
                 if opgw.errs is null then opgw.errs:='{'; else opgw.errs:=opgw.errs||','; end if;
                 opgw.errs:=rtrim(opgw.errs,'}')||chr(10)||'"SEQUENCEOF_TAG":"'||buf3||'"'||chr(10)||'}';
                 exit;
               end if;
               buf3:=substr(buf3,5+len3*2);
            end loop;
            loti:=loti+1;
          else
            if opgw.errs is null then opgw.errs:='{'; else opgw.errs:=opgw.errs||','; end if;
            opgw.errs:=rtrim(opgw.errs,'}')||chr(10)||'"SEQUENCEOF_BLOCK":"'||buf2||'"'||chr(10)||'}';
            exit;
          end if;
        end loop;
      elsif cdrhua_pkg.pgwa(tag1).tp>10 then -- level-2
        buf2:=substr(buf1,5,len1*2);
        while ( length(buf2)>0 ) loop
          if cdrhua_pkg.pgwa.exists(tag1||'.'||substr(buf2,1,2)) then -- 1-byte L2
            tag2:=tag1||'.'||substr(buf2,1,2);
            len2:=to_number(substr(buf2,3,2),'xx');
            if cdrhua_pkg.pgwa(tag2).tp>10 then -- level-3
               buf3:=substr(buf2,5,len2*2);
               while ( length(buf3)>0 ) loop
                 if cdrhua_pkg.pgwa.exists(tag2||'.'||substr(buf3,1,2)) then -- 1-byte L3
                   tag3:=tag2||'.'||substr(buf3,1,2);
                   len3:=to_number(substr(buf3,3,2),'xx');
                   putpgw(cdrhua_pkg.pgwa(tag3).tag,substr(buf3,5,len3*2),cdrhua_pkg.pgwa(tag3).tp,tag3,wmode,opgw.info,opgw,olotvs(0),olosds(0),0,0);
                 else
                   if opgw.errs is null then opgw.errs:='{'; else opgw.errs:=opgw.errs||','; end if;
                   opgw.errs:=rtrim(opgw.errs,'}')||chr(10)||'"TAG_LEVEL3":"'||buf3||'"'||chr(10)||'}';
                   exit;
                 end if;
                 buf3:=substr(buf3,5+len3*2);
               end loop;
            else
               putpgw(cdrhua_pkg.pgwa(tag2).tag,substr(buf2,5,len2*2),cdrhua_pkg.pgwa(tag2).tp,tag2,wmode,opgw.info,opgw,olotvs(0),olosds(0),0,0);
            end if;
            buf2:=substr(buf2,5+len2*2);
          else
            if opgw.errs is null then opgw.errs:='{'; else opgw.errs:=opgw.errs||','; end if;
            opgw.errs:=rtrim(opgw.errs,'}')||chr(10)||'"TAG_LEVEL2":"'||buf2||'"'||chr(10)||'}';
            exit;
          end if;
        end loop;
      else
        putpgw(cdrhua_pkg.pgwa(tag1).tag,substr(buf1,5,len1*2),cdrhua_pkg.pgwa(tag1).tp,tag1,wmode,opgw.info,opgw,olotvs(0),olosds(0),0,0);
      end if;
      if buf1 like 'ac81__30%' then
        buf1:=substr(buf1,7+len1*2);
      else
        buf1:=substr(buf1,5+len1*2);
      end if;
    elsif cdrhua_pkg.pgwa.exists(substr(buf1,1,4)) then -- 2-byte tag
      tag1:=substr(buf1,1,4);
      if buf1 like 'bf2282____30%' then
        len1:=to_number(substr(buf1,7,4),'xxxx'); -- very long sequence bf22
      elsif buf1 like 'bf2281__30%' then
        len1:=to_number(substr(buf1,7,2),'xx');
      else
        len1:=to_number(substr(buf1,5,2),'xx');
      end if;
      if cdrhua_pkg.pgwa(tag1).tp>20 then -- level-2 SEQUENCE OF
        if buf1 like 'bf2282____30%' then
          buf2:=substr(buf1,11,len1*2); -- very long sequence bf22
        elsif buf1 like 'bf2281__30%' then
          buf2:=substr(buf1,9,len1*2);
        else
          buf2:=substr(buf1,7,len1*2);
        end if;
        while ( length(buf2)>0 ) loop
          if substr(buf2,1,2)='30' then
            len3:=to_number(substr(buf2,3,2),'xx');
            buf3:=substr(buf2,5,len3*2);
            buf2:=substr(buf2,5+len3*2);
            olosds(lots).dataU:=0;
            while ( length(buf3)>0 ) loop -- N-th sequence block
               if cdrhua_pkg.pgwa.exists(tag1||'.'||substr(buf3,1,2)) then -- 1-byte L3
                 tag3:=tag1||'.'||substr(buf3,1,2);
                 len3:=to_number(substr(buf3,3,2),'xx');
                 if cdrhua_pkg.pgwa(tag3).tp>10 then -- level-4
                   buf4:=substr(buf3,5,len3*2);
                   while ( length(buf4)>0 ) loop
                     if cdrhua_pkg.pgwa.exists(tag3||'.'||substr(buf4,1,2)) then -- 1-byte L4
                       tag4:=tag3||'.'||substr(buf4,1,2);
                       len4:=to_number(substr(buf4,3,2),'xx');
                       putpgw(cdrhua_pkg.pgwa(tag4).tag,substr(buf4,5,len4*2),cdrhua_pkg.pgwa(tag4).tp,tag4,wmode,opgw.info,opgw,olotvs(0),olosds(lots),0,lots);
                     else
                       if opgw.errs is null then opgw.errs:='{'; else opgw.errs:=opgw.errs||','; end if;
                       opgw.errs:=rtrim(opgw.errs,'}')||chr(10)||'"TAG_LEVEL4":"'||buf4||'"'||chr(10)||'}';
                       exit;
                     end if;
                     buf4:=substr(buf4,5+len4*2);
                   end loop;
                 else
                   putpgw(cdrhua_pkg.pgwa(tag3).tag,substr(buf3,5,len3*2),cdrhua_pkg.pgwa(tag3).tp,tag3,wmode,opgw.info,opgw,olotvs(0),olosds(lots),0,lots);
                 end if;
               else
                 if opgw.errs is null then opgw.errs:='{'; else opgw.errs:=opgw.errs||','; end if;
                 opgw.errs:=rtrim(opgw.errs,'}')||chr(10)||'"SEQUENCEOF_TAG":"'||buf3||'"'||chr(10)||'}';
                 exit;
               end if;
               buf3:=substr(buf3,5+len3*2);
            end loop;
            lots:=lots+1;
          else
            if opgw.errs is null then opgw.errs:='{'; else opgw.errs:=opgw.errs||','; end if;
            opgw.errs:=rtrim(opgw.errs,'}')||chr(10)||'"SEQUENCEOF_BLOCK":"'||buf2||'"'||chr(10)||'}';
            exit;
          end if;
        end loop;
      else
        putpgw(cdrhua_pkg.pgwa(tag1).tag,substr(buf1,7,len1*2),cdrhua_pkg.pgwa(tag1).tp,tag1,wmode,opgw.info,opgw,olotvs(0),olosds(0),0,0);
      end if;
      if buf1 like 'bf2282____30%' then
        buf1:=substr(buf1,11+len1*2); -- very long sequence bf22
      elsif buf1 like 'bf2281__30%' then
        buf1:=substr(buf1,9+len1*2);
      else
        buf1:=substr(buf1,7+len1*2);
      end if;
    else
      if opgw.errs is null then opgw.errs:='{'; else opgw.errs:=opgw.errs||','; end if;
      opgw.errs:=rtrim(opgw.errs,'}')||chr(10)||'"TAG_LEVEL1":"'||buf1||'"'||chr(10)||'}';
      exit;
    end if;
  end loop;
  if opgw.info is not null then opgw.info:=opgw.info||'}'; end if;
  return opgw.errs;
end;

function selpgw ( rbody in varchar2, tag in varchar2 ) return varchar2 IS
  b varchar2(4000);
  l cdrhua_pkg.lotvs;
  d cdrhua_pkg.losds;
  p cdrhua_pgw%rowtype;
begin
  b:=pgw(rbody,2,p,l,d);
  return gpgwrecs(tag).cbuf;
end;

begin
-- HUA pgw + sgw BEFORE
  huap('80').tp:=0;    huap('80').tag:='RecordType';
  huap('83').tp:=2;    huap('83').tag:='ServedIMSI';
  huap('a4').tp:=0;    huap('a4').tag:='huapddress';
  huap('85').tp:=4;    huap('85').tag:='ChargingID';
  huap('a6').tp:=0;    huap('a6').tag:='ServingNodeAddress';
  huap('87').tp:=2;    huap('87').tag:='AccessPointNameNI';
  huap('88').tp:=4;    huap('88').tag:='pdpPDNType';
  huap('a9').tp:=0;    huap('a9').tag:='ServedPDPPDNAddress';
  huap('8b').tp:=2;    huap('8b').tag:='DynamicAddressFlag';
  huap('ac').tp:=0;    huap('ac').tag:='ListOfTrafficVolumes';
  huap('8d').tp:=3;    huap('8d').tag:='RecordOpeningTime';
-- HUA sgsn BEFORE
  huas('80').tp:=1;    huas('80').tag:='RecordType';
  huas('81').tp:=1;    huas('81').tag:='NetworkInitiation';
  huas('83').tp:=4;    huas('83').tag:='ServedIMSI';
  huas('84').tp:=4;    huas('84').tag:='ServedIMEI';
  huas('a5').tp:=0;    huas('a5').tag:='SgsnAddress';
  huas('86').tp:=4;    huas('86').tag:='msNetworkCapability';
  huas('87').tp:=2;    huas('87').tag:='RoutingArea';
  huas('88').tp:=4;    huas('88').tag:='LocationAreaCode';
  huas('89').tp:=4;    huas('89').tag:='CellIdentifier';
  huas('8a').tp:=0;    huas('8a').tag:='ChargingID';
  huas('ab').tp:=0;    huas('ab').tag:='ggsnAddressUsed';
  huas('8c').tp:=0;    huas('8c').tag:='AccessPointNameNI';
  huas('8d').tp:=3;    huas('8d').tag:='pdpType';
  huas('ae').tp:=0;    huas('ae').tag:='ServedPDPAddress';
  huas('af').tp:=0;    huas('af').tag:='ListOfTrafficVolumes';
  huas('90').tp:=3;    huas('90').tag:='RecordOpeningTime';
-- sgsn AFTER
  init;
end;
/
