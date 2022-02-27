	/************************************************************************
** 
** CALL:           
**
** DESCRIPTION:  New table PHL_GOLD_DATA_MSSG_DTL
**
** TIMING:       N/A 
**
** AUTHOR:       Raj Naik
** DATE:         
**
** CHECKED:       
** DATE: 02/01/2022
** Tickets 11413
** RELEASE VERSION:  3.0.0.01
**
*************************************************************************/
define apps_connect="&apps"
define tns_connect="&tns"
define tns_user   ="&usr"
undefine apps
undefine tns
undefine usr
connect &apps_connect@&tns_connect
set serveroutput on size 1000000 format word_wrapped

declare
   w_count number;
   w_sql       varchar2(4000);
   w_sql1      varchar2(4000);
   w_user_id   number;
   
begin

    begin
      select user_id into w_user_id
      from fnd_user
      where user_name = upper('&tns_user');
    exception
      when others then 
      w_user_id := -1;
    end;

--
-- 
--
Insert into CIS.PHL_BILL_MSSG_HDR
(
 MESG_HDR_ID            
,MESG_HDR_TYPE          
,MESG_HDR_NUM           
,FROM_DATE              
,UPTO_DATE              
,HDR_PRIORITY           
,HDR_FULL_TEXT          
,CREATED_BY             
,CREATION_DATE          
,LAST_UPDATED_BY        
,LAST_UPDATE_DATE       
,LAST_UPDATE_LOGIN
)
select
   95
 , 'BILLMSSG'
 , 95
 , trunc(sysdate)
 , NULL
 , 100000 
 , 'LIHWAP Grant'
 , w_user_id
 , trunc(sysdate)
 , w_user_id
 , trunc(sysdate)
 , '1'
 from CIS.PHL_BILL_MSSG_HDR
 where mesg_hdr_type = 'BILLMSSG'  
   and mesg_hdr_num = 95
 having count(*) = 0;

Insert into CIS.PHL_BILL_MSSG_DTL
   ( MESG_ID
   , MESG_TYPE
   , MESG_NUM
   , FROM_DATE
   , UPTO_DATE
   , PRIORITY
   , FULL_TEXT
   , MESG_HDR_ID
   , CREATED_BY
   , CREATION_DATE
   , LAST_UPDATED_BY
   , LAST_UPDATE_DATE
   , LAST_UPDATE_LOGIN
   )
 select
     95
   , 'BILLMSSG'
   , 95
   , trunc(sysdate)
   , NULL
   , 102500 
   , 'Congratulations! The Commonwealth of Pennsylvania has provided you with a &'|| 'lihwap_grnt Low Income Household Water Assistance Program (LIHWAP) grant.'
   , 95
   , w_user_id
   , trunc(sysdate)
   , w_user_id
   , trunc(sysdate)
   , '1'
   from CIS.PHL_BILL_MSSG_DTL
   where mesg_type = 'BILLMSSG'  
     and mesg_num = 95
   having count(*) = 0;

commit;

end;
/
