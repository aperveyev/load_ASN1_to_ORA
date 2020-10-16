-- select * from cdr_tags where rec_type='PGWA'
select cdrhua_pkg.selpgw(lower(rbody),'ServedMSISDN') ServedMSISDN, count(*) cnt
-- select count(*) -- 178.000 @ 110 sec
from CDRHUA_RAWBODY t
group by cdrhua_pkg.selpgw(lower(rbody),'ServedMSISDN')
order by 2 desc


select cdrhua_pkg.selpgw(lower(rbody),'ServedMSISDN') ServedMSISDN, 
       cdrhua_pkg.selpgw(lower(rbody),'ListOfServiceData_TimeOfReport') losd_dtm_0,
       cdrhua_pkg.selpgw(lower(rbody),'ListOfServiceData_DatavolumeFBCUplink') losd_up_0,
       cdrhua_pkg.selpgw(lower(rbody),'ListOfServiceData_DatavolumeFBCDownlink') losd_dl_0,
       cdrhua_pkg.selpgw(lower(rbody),'ListOfTrafficVolumes_changeTime') lotv_dtm_0,
       cdrhua_pkg.selpgw(lower(rbody),'ListOfTrafficVolumes_dataVolumeGPRSUplink') lotv_up_0,
       cdrhua_pkg.selpgw(lower(rbody),'ListOfTrafficVolumes_dataVolumeGPRSDownlink') lotv_dl_0,
       cdrhua_pkg.selpgw(lower(rbody),'ListOfTrafficVolumes_changeTime_1') lotv_dtm_1,
       cdrhua_pkg.selpgw(lower(rbody),'ListOfTrafficVolumes_dataVolumeGPRSUplink_1') lotv_up_1,
       cdrhua_pkg.selpgw(lower(rbody),'ListOfTrafficVolumes_dataVolumeGPRSDownlink_1') lotv_dl_1,
       dtm, fid, swid, fname, rnum, rid
from CDRHUA_RAWBODY t
