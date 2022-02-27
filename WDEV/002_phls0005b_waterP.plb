create or replace
package body "PHLS0005" as
/*
TO Replace blank lines in files using perl regular expression  in ULTRA edit
^(?:[\t ]*(?:\r?\n|\r))+
*/
/*
**  NAME        phls0005
**
**  copyright (c) 2007 Philadelphia Water
**
**  FILENAME    phls0005B.pls
**
**  DESCRIPTION
**      Procedures for PHL report messaging.
**
**        PROCEDURES, FUNCTIONS
**        function      get_version
**         procedure    trace_label
**         procedure    debug_trace
**         procedure    debug_trace
**         function     datec
**         function     booleanc
**         procedure    load_ref_data
**         procedure    init
**         procedure    reset_vars
**         procedure    get_message_type
**         procedure    set_pyagremd
**         procedure    set_pyagshut
**         procedure    get_billmssg
**         procedure    set_bill_message
**         procedure    get_mssg_details
**         procedure    get_message
**/
   w_version                     varchar2(20) := '3.0.0.25';  -- MUST MATCH LATEST 'VERS' IN HISTORY BELOW!
/**
** BUG       	WHO   VERS      MM/DD/YYYY   Description
** 11413      RNN   3.0.0.25  02/01/2022   LIHWAP (Low Income Household Water Assistance Program) basis2 changes. 
** 10495      RNN   3.0.0.24  01/05/2021   AMI eBilling: basis2 bill messages
** 9984       RNN   3.0.0.23  07/20/2020   TAP: Sept. 1, 2020 principal forgiveness updates to bills
** 9106b      RNN   3.0.0.22  06/18/2020   Change the day from 30 to 45 for 1st Message..
** 9106 			RNN   3.0.0.21  02/23/2020   AMI project: billing messages for deployment of Sensus devices
** 8020F      RNN   3.0.0.20  07/30/2019   Issue with parsing of messages for Bill Print [Make the body of the Kubra auto pay bill message dynamic]
** 8020E      RNN   3.0.0.19  07/30/2019   Issue with parsing of messages for Bill Print [Make the body of the Kubra auto pay bill message dynamic]
** 8020D      RNN   3.0.0.18  07/20/2019   Make the body of the Kubra auto pay bill message dynamic.
** 9454      	RNN   3.0.0.17  07/14/2019   Kubra auto pay paper bills go into ZipCheck bill files for mail room and AutoPay Messages
** 9297B      RNN   3.0.0.16  06/08/2019   TAP Bill messages
** 9297		    RNN	  3.0.0.15  05/28/2019	 TAP create liens on TAP accounts
** 7762       RNN   3.0.0.14  01/18/2018   Add bill message for customers who are charged Sheriff Sale fees and expenses
** 7180       RNN   3.0.0.13  12/28/2018   Bill shows a message that Help Loan is "at risk of default" this is incorrect
** 8550       RNN   3.0.0.12  10/05/2018   Add 'Unity Cup Championship Day' to Bill Message
** 7349       RNN   3.0.0.11  02/01/2018   Agency debt (but not meters): to be liened quarterly at any amount
** 7164				RNN   3.0.0.10  10/12/2017   Remove dispute amount from please pay and display dispute message on bill.
** 6971				RNN   3.0.0.09  08/03/2017   LIEN MESSAGE ON TAP BILLS.
** 6495       RNN   3.0.0.08  04/21/2017   Add bankruptcy message to bills
** 6035       RNN   3.0.0.07  03/02/2016   HELPLOAN Bill message for Agreement Default needs text correction
** 4398       RNN   3.0.0.06  03/02/2016   Help Loan Message Routines
** 4563A      RNN   3.0.0.05  07/15/2015   Modified the message conditions for Message_Num 77
** 4611       RNN   3.0.0.04  07/13/2015   Add new message (mssg_num 80)
** 4563       RNN   3.0.0.03  05/04/2015   Add Delinquent Message on the new bill.
** 3659       RNN   3.0.0.02  09/08/2014   New Bill Design
** 3706       RNN   3.0.0.01  08/27/2014   New Bill Design -- Change
*********************************************************************************************************************
** 3528       RNN   2.0.0.19  04/02/2013   Remove ERT battery message code from bill print
** 3352       RNN   2.0.0.18  06/05/2011   New bill message for Mayor's Office of Sustainability for August 2012
** 3327b/3338 RNN   2.0.0.17  06/05/2011   Allow new residential messages (MSGNUM 77) and allow gaps between priorities of existing messages by 1000
** 3327b/3338 RNN   2.0.0.16  06/05/2011   Allow new residential messages (MSGNUM 77) and allow gaps between priorities of existing messages by 1000
** 3327       RNN   2.0.0.15  06/01/2012   Allow bill message (MSGNUM 76)to be included only on commercial properties
** 2657       CCR   2.0.0.14  10/24/2011   Add bill message for NB5 SW only accounts. Will appear only in their first bill.
** 3025       LR    2.0.0.13  09/12/2011   Remove exclusion of Fault Code NOT-REG in the bill message processing.
** 2914       CCR   2.0.0.11  02/07/2011   Add bill message for AMR Battery Upgrade
** 2730       CCR   2.0.0.10  10/22/2010   Add stormwater period coverage
**                            11/11/2010   Add bill message for NB3 and NB8 for their first bill - Jan 2011.
** 2775       RNN   2.0.0.09  09/03/2010   New bill message for payment agreements with missed payment
** 2775       RNN   2.0.0.08  08/31/2010   Changed the secification procedure get_billmssg added one of more parameter p_shutoff_date
** 2638       RNN   2.0.0.07  07/09/2010   Add police message to bills
** 2477       RNN   2.0.0.06  01/15/2009   Create new bill message for 2010 Census
**                                         Put always Message Num 18 in Message4.
** 2428       RNN   2.0.0.05  11/24/2009   Lien messages continuing to appear on bills
**   2264     RNN   2.0.0.04  08/03/2009   Bankruptcy Balances are being mentioned in Message line field
**            CR    2.0.0.03  07/22/2009   Bill print failed in prod, increasing size of message variables w_est_rev_messg and w_sur_cst_fct_mssg to 1000
**            RNN   2.0.0.02  06/25/2009   Add New Message
**            RNN   2.0.0.01  06/12/2009   Modify the messages
**            RNN   2.0.0.00  01/28/2009   Messages for New Bill - Creation
******************************************************************************************************************************
** 1772       PJT   1.0.0.9   09/26/2008   Restrict lien message selection clause
**            PJT   1.0.0.8   04/10/2008   Add message 71 for new rates
**            AWT   1.0.0.7   02/08/2008   Remove the "you are about to be shut-off" and the "you have been shut-off" messages
**            RNN   1.0.0.6   01/25/2008   Add new message for SHUTOFF BILL
**            PJT   1.0.0.5   01/18/2008   Add new message for Only 1 Plan Payment
**            AWT   1.0.0.4   01/04/2008   Change default tear drop message from 14 to 10 (null message).
**            AWT   1.0.0.3   12/24/2007   Need to be able to print messages for Jan 2008 bills for specific dates.
**  542       AWT   1.0.0.2   11/14/2007   Adjust message requirements now that BP90's are complete and the rules
**                                         are known.These changes are not tagged with Chg / Add comments.
**            PJT   1.0.0.1   04/11/2007   Package creation
**
*/
   w_count                       number;
   w_doing_init                  boolean := false;
   w_found                       boolean;
   w_index                       binary_integer;
   w_init_called                 boolean := false;
   w_label                       varchar2(4);
   w_lo_date                     date := to_date('01011900','ddmmyyyy');
   w_hi_date                     date := to_date('31122099','ddmmyyyy');
   w_null_parameter_found        boolean;
   w_token_key                   varchar2(50);
   w_token_val                   varchar2(50);
   w_mesg_num                    phl_report_messages.mesg_num%type;
   w_mesg_date                   phl_report_messages.from_date%type;
   w_est_reading_ind             cis_debit_lines.est_reading_ind%type;
   w_fault_code                  cis_debit_lines.fault_code%type;
   w_acct_pay_method             cis_bill_lines.acct_pay_method%type;
	 --g_ebill_auto_pay_ind		 			 phl_bill_print_hist.ebill_auto_pay_ind%type; 	--Del 8020D --Add 9454
	 g_ebill_auto_pay_ind		 			 varchar2(20); 																		--Add 8020F --Add 8020D
	 g_str_by_access_cd1					 varchar2(100);																		--Add 8020D
	 g_str_by_access_cd2					 varchar2(100);																		--Add 8020D
	 g_str_by_access_cd3					 varchar2(100);																		--Add 8020D
   w_incid_code                  cis_incidents.incid_code%type;
   w_ppln_id                     cis_bill_trans.ppln_id%type;
   w_ppln_due_amnt               number;
   w_cust_id                     cis_customers.cust_id%type;                     -- Add 542
   w_inst_id                     cis_installations.inst_id%type;                 -- Add 542
   w_tran_id                     cis_transactions.tran_id%type;                  -- Add 542
   w_dd_earliest_date            cis_transactions.dd_earliest_date%type;         -- Add 542
   w_estimates_cnt               cis_meter_regs.estimates_cnt%type;              -- Add 542
   --w_previous_balance_amnt       phl_tmg_bill_master.previous_balance_amnt%type; --Del 3706 -- Add 542
   w_previous_balance_amnt       phl_bill_print_hist.previous_balance_amnt%type; -- Add 3706 Add 542
   w_ppln_no_due                 number;                                         -- Add 542
   w_cust_own_reading_ind        cis_reading_types.cust_own_reading_ind%type;    -- Add 542
   w_sur_cst_fct_mssg            varchar2(1000);                                 -- Add 2.0.0.3
   w_factor_message              varchar2(200);                                  -- Add 3706
   --w_est_rev_messg               varchar2(1000);                               --Del 3706  -- Add 2.0.0.3
   w_debt_bal_not_incl           number;                                         -- Add 2.0.0.1
   w_bnkrptcy_bal_amnt_wat       number;                                         -- Add 6495
   w_dispute_amnt				   			 number; 																				 -- Add 7164
   --w_debt_bal_grants           number;
   w_idx_msg_priority_99         binary_integer := 0;                            -- Add 2.0.0.1
   w_shutoff_date                date;                                           -- Add 2775
   --w_act_mtr_wrk_dt            date;                                           -- Add 4398
   w_period                      varchar2(50);                                 -- Add 2730
   w_sw_chg_fr_dt			           cis_debit_lines.period_from_date%type;		      --Chg 3659 refer phls0001 -- Add 2730
   w_sw_chg_to_dt			           cis_debit_lines.period_upto_date%type;		      --Chg 3659 refer phls0001 -- Add 2730
   w_nb_code                     cis_installations.revu1_code%type;              -- Add 2730
   w_sw_only                     cis_installations.ext_org_code%type;            -- Add 2657
   w_min_tran_id                 cis_transactions.tran_id%type;               -- Add 2657
   w_sw_nb5_fnd                  boolean := false;                               -- Add 2657
   --w_cday                        number;                                       -- Del 3528 -- Add 2914
   --w_ert_msg_fnd                 boolean := false;                             -- Del 3351 -- Add 2914
   w_from_date                   date;                                         	 -- Add 2914
   --w_no_mons                    number;                                        -- Del 3528 -- Add 2914
   w_pay_profile_code            cis.cis_accounts.attribute8%type;               -- Add 3327
	 w_pay_profile_code_orig			 cis.cis_accounts.pay_profile_code%type;				 -- Add 9297B
   w_arrears_letter_no           cis.cis_accounts.letter_no%type;                -- Add 4563
   w_un_paid_prv_bal             number;                                         -- Add 4563A
   w_meter_work_date             cis_meter_wos.meter_work_date%TYPE;             -- Add 1.0.0.6
	 w_debt_bal_amnt_ues           number;                                         -- Add 3706
   w_grant_hdr_value             varchar2(100);                                  -- Add 3706
   w_grnt_rcvd                   number;                                         -- Add 3706
   w_tap_disc										 number;																				 -- Add 6971
   w_agn_acct_opn_bal						 number;																				 -- Add 7349
	 w_ss_fee_mssg								 char(1);                                        -- Add 7762
	 w_round_key									 cis_rounds.round_key%type;											 -- Add 9106
	 g_outreader_type_code	 			 cis_meters.outreader_type_code%type;						 -- Add 9106
	 g_pnlty_frgv_dt  						 date;														 							 -- Add 9984
	 g_pnlty_frgv_amnt						 number;	                         							 -- Add 9984
	 g_prin_frgv_dt   						 date;															 						 -- Add 9984
	 g_prin_frgv_amnt 						 number;														 						 -- Add 9984
	 g_tgt_dt											 date;																	 				 -- Add 10495
	 g_s17_grnt_amnt							 number;																				 -- Add 11413
   -- Records
   w_acct                        cis_ta_acct_v%rowtype;
   w_tran                        cis_ta_tran_v%rowtype;
   w_bltr                        cis_ta_bltr_v%rowtype;
   --
   --  Message Types
   type t_mtyps is table of phl_cv_zphlmtyp_v%rowtype index by binary_integer;
   w_mtyps                       t_mtyps;
   w_mtyp                        phl_cv_zphlmtyp_v%rowtype;
   -- Messages
   w_phl_report_messages         cis.phl_report_messages%rowtype;
   --
   -- Priority would be indexed
   --
   type sort_mssg_rec is record
		(
		 mesg_id    		phl_bill_mssg_dtl.mesg_id%type    --Add 3706 --phl_report_messages.mesg_id%type
		,mesg_num   		phl_bill_mssg_dtl.mesg_num%type   --Add 3706 --phl_report_messages.mesg_num%type
		,full_text			phl_bill_mssg_dtl.full_text%type  --Add 3706 --phl_report_messages.full_text%type
		,token_key  		varchar2(15)
		,token_value 		varchar2(25)											--8020D Changed length from 20 to 25
		,token_key2  		varchar2(15)								   		--Add 2775
		,token_value2 	varchar2(25)											--8020D Changed length from 20 to 25				   --Add 2775
		,token_key3  		varchar2(15)								   		--Add 2775
		,token_value3 	varchar2(25)											--8020D Changed length from 20 to 25				   --Add 2775
    ,hdr_full_text 	phl_bill_mssg_hdr.hdr_full_text%type   --Add 3706
		);
		--
		--Sort record
		--
	type sort_mssg_tbl is table of sort_mssg_rec index by binary_integer;
   --
   -- Priority would be indexed
   --
   w_sort_mssg_tbl               sort_mssg_tbl;
   w_line_cnt                    number;                                               --Add 3352
   w_tot_line_cnt                number;                                               --Add 3352
   w_supply_type                 cis_accounts.supply_type%type;                        --Add 4398
   w_hl_5th_fpg_inv_desc         phl_agrv_rc_hlpln_st_dtl.agrv_hl_5th_inv_desc%type;   --Add 4398
   w_hl_4th_fpg_inv_desc         phl_agrv_rc_hlpln_st_dtl.agrv_hl_4th_inv_desc%type;   --Add 4398
   w_hl_3rd_fpg_inv_desc         phl_agrv_rc_hlpln_st_dtl.agrv_hl_3rd_inv_desc%type;   --Add 4398
   w_hl_2nd_fpg_inv_desc         phl_agrv_rc_hlpln_st_dtl.agrv_hl_2nd_inv_desc%type;   --Add 4398
   w_hl_ppln_id                  cis_bill_trans.ppln_id%type;                          --Add 4398
   w_hl_ppln_due_amnt            number;                                               --Add 4398
   w_hl_ppln_no_due              number;                                               --Add 4398
   w_2nd_max_ppln_id             cis_bill_trans.ppln_id%type;                          --add 4398
   w_hl_superseded               boolean;                                              --Add 4398
   w_hl_curr_std_ppln            cis_payment_plans.std_ppln%type;                      --Add 4398
   w_hl_curr_ppln_status         cis_payment_plans.ppln_status%type;                   --Add 4398
   w_hl_curr_ppln_tot_amnt       number;                                               --Add 4398
   w_hl_curr_ppln_bal_amnt       number;                                               --Add 4398
   w_hl_cure_amnt                number;                                               --Add 4398
   --w_hl_prv_ppln_tot_amnt        number;                                               --Add 4398
   --w_hl_prv_ppln_bal_amnt        number;                                               --Add 4398
   --w_hl_prv_tot_pymts            number;                                               --Add 4398
   --w_hl_prv_lst_paym_dt          date;                                                 --Add 4398
   --w_no_of_helploans             number;                                               --Add 4398
   deadlock_detected             exception;
   resource_busy                 exception;
   dbp_fatal                     exception;
   dbp_error                     exception;
   pragma exception_init(deadlock_detected, -60); -- Deadlock
   pragma exception_init(resource_busy, -54);     -- Resource Busy
   pragma exception_init(dbp_fatal, -20998);      -- Database Package Fatal Error
   pragma exception_init(dbp_error, -20999);      -- Database Package Error
/*************************************************************************************\
   Add 1251
   public function get_version
\*************************************************************************************/
function get_version return varchar2 is
begin
   return w_version;
end get_version;
--Start Add 9106
 --*************************************************************************************
    -- public procedure debug_ttid
 --*************************************************************************************
 procedure debug_ttid(p_ttid varchar2 default null, p_procedure_name varchar2 default null,p_label in varchar2, p_param varchar2)
 is
   w_procedure_name       varchar2(20) := 'phls0001.debug';
 begin
	 if gp_ttid_5 = '-1' then
	   if w_message_trace_level  >= 10 then
	     ciss0074.trace(nvl(p_procedure_name, w_procedure_name), p_label, nvl(p_param,'...'));
	   end if;
	 else
   	 if nvl(p_ttid,-1) = gp_ttid_5 then
		   if w_message_trace_level  >= 7 then
		     ciss0074.trace(nvl(p_procedure_name, w_procedure_name),p_label, nvl(p_param,'...'));
		   end if;
		 end if;
	 end if;
 end debug_ttid;
 --Start Add 9106
--*************************************************************************************
   -- public procedure debug
--*************************************************************************************
procedure debug(p_procedure_name varchar2 default null,p_label in varchar2, p_param varchar2)
is
  w_procedure_name       varchar2(50) := 'phls0005.debug';
begin
	w_label := p_label;
  if w_message_trace_level  >= 10 then
      ciss0074.trace(nvl(p_procedure_name, w_procedure_name), w_label, nvl(p_param,'...'));
  end if;
end debug;
/*************************************************************************************\
   procedure trace_label
\*************************************************************************************/
procedure trace_label(p_label in varchar2, p_procedure_name varchar2 default null) is
   w_procedure_name              varchar2(50) := 'phls0005.trace_label';
begin
   w_label := p_label;
   if w_message_trace_level >= 10 then
      ciss0074.trace(nvl(p_procedure_name, w_procedure_name), w_label, 'trace point');
   end if;
end trace_label;
/*************************************************************************************
   private procedure debug_trace
*************************************************************************************/
procedure debug_trace
  (p_procedure_name varchar2 default null, msg in varchar2
  )
is
   w_procedure_name              varchar2(50) := 'phls0005.debug_trace';
begin
  if w_message_trace_level >= 10 then
     ciss0074.trace(nvl(p_procedure_name,w_procedure_name), w_label, msg);
  end if;
end debug_trace;
/*************************************************************************************\
   function datec (convert date to character for debug messages only)
\*************************************************************************************/
function datec(p_date in date) return varchar2 is
begin
   return to_char(p_date,'mm/dd/yyyy');
end datec;
/*************************************************************************************\
   function booleanc (convert boolean to character for debug messages only)
\*************************************************************************************/
function booleanc(p_boolean in boolean) return varchar2 is
begin
   if p_boolean then
      return 'true';
   else
      return 'false';
   end if;
end booleanc;
/*************************************************************************************
   private procedure load_ref_data
************************************************************************************/
procedure load_ref_data is
   w_procedure_name              varchar2(50) := 'phls0005.load_ref_data';
begin
   trace_label('e001', w_procedure_name);
   if w_ref_data_loaded then
      return;
   end if;
   --  Load Message Types
   trace_label('e002', w_procedure_name);
   w_mtyps.delete;
   w_index := 0;
   for c_rec in (select * from phl_cv_zphlmtyp_v)
   loop
      w_index := w_index + 1;
      w_mtyps(w_index) := c_rec;
   end loop;
   --  Load Messages
   w_label := 'e004';
   --Start Add 9106
   if phls0001.gp_dev_mode = false then
     phls0005.gp_ttid_5 := '-1';
   end if;
   --End Add 9106
   w_label := 'e004';
   w_ref_data_loaded := true;
end load_ref_data;
/*************************************************************************************\
   procedure init
\*************************************************************************************/
procedure init is
   w_procedure_name              varchar2(50) := 'phls0005.init';
begin
   w_label := 'e005';
   trace_label(w_label, w_procedure_name);
   if w_doing_init then
      -- prevents recursive loops due to this init being called by procedures called below
      return;
   end if;
   w_doing_init := true;
   if fnd_global.user_id <> -1 and w_message_trace_level <= 0 then
      w_message_trace_level := nvl(FND_PROFILE.VALUE('CIS_TRACE_LEVEL'), 0);
   end if;
   if w_message_trace_level > 0 then
      ciss0074.trace(w_procedure_name, w_label, 'version='||w_version ||', message_trace_level='||w_message_trace_level);
   end if;
   w_label := 'e006';
   trace_label(w_label, w_procedure_name);
   load_ref_data;
   w_doing_init := false;
   w_init_called := true;
exception
   when deadlock_detected then
      raise;
   when resource_busy then
      raise;
   when dbp_fatal then
      raise;
   when dbp_error then
      raise;
   when others then
      ciss0047.raise_exception(w_procedure_name, w_label, 'cis_internal_error',
                               'error', sqlerrm, p_severity=>'f');
end init;
/*************************************************************************************\
   procedure reset_vars
\*************************************************************************************/
procedure reset_vars is
   w_procedure_name             varchar2(50) := 'phls0005.reset_vars';
begin
   --trace_label('e007', w_procedure_name);
   w_mesg_num     				:= 0;
   w_mesg_date    				:= null;
   w_token_key    				:= null;
   w_token_val    				:= null;
   w_cust_id      				:= null; --Add 4398 --Global Variables
   w_inst_id      				:= null; --Add 4398 --Global Variables
   w_supply_type  				:= null; --Add 4398 --Global Variables
   g_str_by_access_cd1		:= null; --Add 8020F
   g_str_by_access_cd2		:= null; --Add 8020F
   g_str_by_access_cd3		:= null; --Add 8020F
	 w_round_key						:= null; --Add 9106
	 g_outreader_type_code	:= null; --Add 9106
end reset_vars;
/*************************************************************************************\
   procedure get_message_type (internal procedure)
\*************************************************************************************/
procedure get_message_type (p_message_type   phl_cv_zphlmtyp_v.message_type%type) is
   w_procedure_name             varchar2(50) := 'phls0005.get_message_type';
begin
   trace_label('e008', w_procedure_name);
   w_found := true;
   if w_mtyp.message_type <> upper(p_message_type) then
      w_found := false;
      for i in 1..w_mtyps.count loop
         if w_mtyps(i).message_type  = upper(p_message_type) then
            w_found := true;
            w_mtyp := w_mtyps(i);
            exit;
         end if;
      end loop;
   end if;
   if not w_found then
      raise no_data_found;
   end if;
exception
   when no_data_found then
      ciss0047.raise_exception(w_procedure_name, w_label, 'phl_not_found_message_type'
                              ,'message_type', p_message_type
                              , p_severity=>'f'
                              );
end get_message_type;
/*************************************************************************************\
   procedure get_message (internal procedure)
\*************************************************************************************/
procedure get_message(
							  p_full_text_1	   out  phl_bill_mssg_dtl.full_text%type     --Chg 3706 phl_report_messages.full_text%type
							 ,p_full_text_2	   out  phl_bill_mssg_dtl.full_text%type     --Chg 3706 phl_report_messages.full_text%type
							 ,p_full_text_3	   out  phl_bill_mssg_dtl.full_text%type     --Chg 3706 phl_report_messages.full_text%type
							 ,p_full_text_4	   out  phl_bill_mssg_dtl.full_text%type     --Chg 3706 phl_report_messages.full_text%type
							 ,p_hdr_full_text_1  out  phl_bill_mssg_hdr.hdr_full_text%type --Add 3706
							 ,p_hdr_full_text_2  out  phl_bill_mssg_hdr.hdr_full_text%type --Add 3706
							 ,p_hdr_full_text_3  out  phl_bill_mssg_hdr.hdr_full_text%type --Add 3706
							 ,p_hdr_full_text_4  out  phl_bill_mssg_hdr.hdr_full_text%type --Add 3706
                      )
is
   w_procedure_name  varchar2(30) := 'phls0005.get_message';
	j                 number 		 := 1;
	indx					number;
	w_full_text			phl_report_messages.full_text%type;
begin
   w_label := 'e009';
   trace_label(w_label, w_procedure_name);
	debug_trace(w_procedure_name,'<-- w_sort_mssg_tbl.first -->'||w_sort_mssg_tbl.first);
	debug_trace(w_procedure_name,'<-- w_sort_mssg_tbl.last  -->'||w_sort_mssg_tbl.last);
	indx := w_sort_mssg_tbl.first;
	--w_ert_msg_fnd := false;		-- Add 2914    --Del 3352
   w_tot_line_cnt := 0;       -- Add 3352
   --debug(w_procedure_name, w_label, 'in get_message       ==> indx ' || indx );
   --debug(w_procedure_name, w_label, 'w_sort_mssg_tbl.first==>      ' || w_sort_mssg_tbl.first);
   --debug(w_procedure_name, w_label, 'w_sort_mssg_tbl.last==>       ' || w_sort_mssg_tbl.last);
	loop
     w_label := 'e010';
		 if j > w_sort_mssg_tbl.count then 	--Chg 2638
		 	 exit;			 							--Chg 2638
		 end if;		 								--Chg 2638
	   debug(w_procedure_name, w_label, 'indx										  '|| indx);
	   debug(w_procedure_name, w_label, 'w_sort_mssg_tbl(indx).mesg_num==> '|| w_sort_mssg_tbl(indx).mesg_num);
	   debug(w_procedure_name, w_label, 'w_sort_mssg_tbl(indx).token_key==>'|| w_sort_mssg_tbl(indx).token_key);
	   debug(w_procedure_name, w_label, 'w_sort_mssg_tbl(indx).token_value==>'|| w_sort_mssg_tbl(indx).token_value);
	   debug(w_procedure_name, w_label, 'w_sort_mssg_tbl(indx).token_key2==>'|| w_sort_mssg_tbl(indx).token_key2);
	   debug(w_procedure_name, w_label, 'w_sort_mssg_tbl(indx).token_value2==>'|| w_sort_mssg_tbl(indx).token_value2);
	   debug(w_procedure_name, w_label, 'w_sort_mssg_tbl(indx).token_key3==>'|| w_sort_mssg_tbl(indx).token_key3);
	   debug(w_procedure_name, w_label, 'w_sort_mssg_tbl(indx).token_value3==>'|| w_sort_mssg_tbl(indx).token_value3);
	   debug(w_procedure_name, w_label, 'Before *** w_sort_mssg_tbl(indx).full_text==>'|| w_sort_mssg_tbl(indx).full_text);
		if w_sort_mssg_tbl(indx).token_key is not null then
         w_label := 'e011';
         trace_label(w_label, w_procedure_name);
			if instr(w_sort_mssg_tbl(indx).full_text, w_sort_mssg_tbl(indx).token_key) > 0  then
				w_full_text := replace(w_sort_mssg_tbl(indx).full_text, w_sort_mssg_tbl(indx).token_key, w_sort_mssg_tbl(indx).token_value);
				--Start Add 2775
				if instr(w_sort_mssg_tbl(indx).full_text, w_sort_mssg_tbl(indx).token_key2) > 0  and w_sort_mssg_tbl(indx).token_value2 is not null then
					w_full_text := replace(w_full_text, w_sort_mssg_tbl(indx).token_key2, w_sort_mssg_tbl(indx).token_value2);
					if instr(w_sort_mssg_tbl(indx).full_text, w_sort_mssg_tbl(indx).token_key3) > 0  and w_sort_mssg_tbl(indx).token_value3 is not null then
						w_full_text := replace(w_full_text, w_sort_mssg_tbl(indx).token_key3, w_sort_mssg_tbl(indx).token_value3);
					end if;
				end if;
				--End Add 2775
			else
            w_label := 'e012';
            --trace_label(w_label, w_procedure_name);
				w_full_text := null;
			end if;
			--Start Add 8020E
			if instr(w_sort_mssg_tbl(indx).full_text, w_sort_mssg_tbl(indx).token_key2) > 0 and w_sort_mssg_tbl(indx).token_value2 is null then
				 w_full_text := replace(w_full_text, w_sort_mssg_tbl(indx).token_key2, w_sort_mssg_tbl(indx).token_value2);
			end if;
			if instr(w_sort_mssg_tbl(indx).full_text, w_sort_mssg_tbl(indx).token_key3) > 0 and w_sort_mssg_tbl(indx).token_value3 is null then
				 w_full_text := replace(w_full_text, w_sort_mssg_tbl(indx).token_key3, w_sort_mssg_tbl(indx).token_value3);
			end if;
			--End Add 8020E
		else
         --w_label := 'e013';
         --trace_label(w_label, w_procedure_name);
			w_full_text := w_sort_mssg_tbl(indx).full_text;
		end if;
	  debug(w_procedure_name, w_label, 'After *** Pasrsing w_full_text==>'|| w_full_text);
      /* Start del for Number of lines for Bill Messages Per Bill --Del 3706
      --w_line_cnt := ceil(length(w_full_text)/w_num_chr_per_line); --Del 3706 --Add 3352
      --w_tot_line_cnt := w_tot_line_cnt + w_line_cnt;              --Del 3706 --Add 3352
      w_label := 'e014';
	   debug(w_procedure_name, w_label, 'j ==> '|| j);
	   debug(w_procedure_name, w_label, 'w_line_cnt     ==> '|| w_line_cnt);
	   debug(w_procedure_name, w_label, 'After w_tot_line_cnt ==> '|| w_tot_line_cnt);
      debug(w_procedure_name, w_label, '<indx>< ' || indx || ' >w_sort_mssg_tbl(indx).hdr_full_text   --> ' || w_sort_mssg_tbl(indx).hdr_full_text);
      debug(w_procedure_name, w_label, '<indx>< ' || indx || ' >w_sort_mssg_tbl(indx).full_text       --> ' || w_sort_mssg_tbl(indx).full_text    );
		if    j = 1 then
         if w_tot_line_cnt > w_tot_lines_per_bill then                  --Add 3352
            w_tot_line_cnt := w_tot_line_cnt - w_line_cnt;              --Add 3352
         else                                                           --Add 3352
		      p_full_text_1     := w_full_text;
		      p_hdr_full_text_1 := w_sort_mssg_tbl(indx).hdr_full_text;   --Add 3706
		      j  := j + 1;
		   end if;                                                        --Add 3352
		elsif j = 2 then
         if w_tot_line_cnt > w_tot_lines_per_bill then                  --Add 3352
            w_tot_line_cnt := w_tot_line_cnt - w_line_cnt;              --Add 3352
         else                                                           --Add 3352
   		   p_full_text_2     := w_full_text;
		      p_hdr_full_text_2 := w_sort_mssg_tbl(indx).hdr_full_text;   --Add 3706
   		   j := j + 1;
   		end if;                                                        --Add 3352
		elsif j = 3 then
         if w_tot_line_cnt > w_tot_lines_per_bill then                  --Add 3352
            w_tot_line_cnt := w_tot_line_cnt - w_line_cnt;              --Add 3352
         else                                                           --Add 3352
   		   p_full_text_3     := w_full_text;
		      p_hdr_full_text_3 := w_sort_mssg_tbl(indx).hdr_full_text;   --Add 3706
   		   j := j + 1;
   		end if;                                                        --Add 3352
		elsif j = 4 then
         if w_tot_line_cnt > w_tot_lines_per_bill then                  --Add 3352
            w_tot_line_cnt := w_tot_line_cnt - w_line_cnt;              --Add 3352
         else                                                           --Add 3352
   		   p_full_text_4     := w_full_text;
		      p_hdr_full_text_4 := w_sort_mssg_tbl(indx).hdr_full_text;   --Add 3706
   		   j := j + 1;
   		end if;                                                        --Add 3352
		end if;
		--end if;   --Del 3327b/3338
      End of Del 3706 Deletion of Number of line / Bill logic..*/
      --Start Add 3706 for Bill message number of lines logic.
      w_line_cnt := ceil(length(w_full_text)/w_num_chr_per_line);
      w_tot_line_cnt := w_tot_line_cnt + w_line_cnt;
		if j = 1 then
         if w_tot_line_cnt > w_tot_lines_per_bill then
            w_tot_line_cnt := w_tot_line_cnt - w_line_cnt;
         else
		      	p_full_text_1     := w_full_text;
		      	p_hdr_full_text_1 := w_sort_mssg_tbl(indx).hdr_full_text;
		      	j  := j + 1;
		   	 end if;
		elsif j = 2 then
         if w_tot_line_cnt > w_tot_lines_per_bill then
            w_tot_line_cnt := w_tot_line_cnt - w_line_cnt;
         else
   		      p_full_text_2     := w_full_text;
		        p_hdr_full_text_2 := w_sort_mssg_tbl(indx).hdr_full_text;
   		      j := j + 1;
   			 end if;
		elsif j = 3 then
         if w_tot_line_cnt > w_tot_lines_per_bill then
            w_tot_line_cnt := w_tot_line_cnt - w_line_cnt;
         else
   		     p_full_text_3     := w_full_text;
		       p_hdr_full_text_3 := w_sort_mssg_tbl(indx).hdr_full_text;
   		     j := j + 1;
   		   end if;
		elsif j = 4 then
         if w_tot_line_cnt > w_tot_lines_per_bill then
            w_tot_line_cnt := w_tot_line_cnt - w_line_cnt;
         else
   		      p_full_text_4     := w_full_text;
		        p_hdr_full_text_4 := w_sort_mssg_tbl(indx).hdr_full_text;
   		      j := j + 1;
   		end if;
		end if;
		-- Start Add 2914 --
		-- remove message 18 whe ERT Battery replacement message is used. The texts do not fit message box and overlaps to the bill stub
		--if w_sort_mssg_tbl(indx).mesg_num = 5 or                  --Del 3352
		--   w_sort_mssg_tbl(indx).mesg_num = 6 or                  --Del 3352
		--   w_sort_mssg_tbl(indx).mesg_num = 7 then                --Del 3352
		--   w_ert_msg_fnd := true;                                 --Del 3352
		--end if;                                                   --Del 3352
		-- End Add 2914 --
		-- Start Add 2657 --
		-- show only msg 1 and 9
		--if w_sw_nb5_fnd then                                      --Del 3352
		--   if w_sort_mssg_tbl(indx).mesg_num = 1 then             --Del 3352
		--      p_full_text_1 := w_full_text;                       --Del 3352
		--   elsif w_sort_mssg_tbl(indx).mesg_num = 9 then          --Del 3352
		--         p_full_text_2 := w_full_text;                    --Del 3352
		--         p_full_text_3 := null;                           --Del 3352
		--         p_full_text_4 := null;                           --Del 3352
		--   end if;                                                --Del 3352
		--end if;                                                   --Del 3352
		-- End Add 2657 --
		exit when indx = w_sort_mssg_tbl.last;
		indx := w_sort_mssg_tbl.next(indx);
   end loop;
   -- Start Add 2914 --
   -- remove message 18 whe ERT Battery replacement message is used. The texts do not fit message box and overlaps to the bill stub
   --if w_ert_msg_fnd and                                                                 --Del 3352
   --   substr(p_full_text_4,1,43) = 'THE TIME TO START PLANNING FOR AN EMERGENCY' then   --Del 3352
   --   p_full_text_4 := null;                                                            --Del 3352
   --end if;                                                                              --Del 3352
   -- End Add 2914 --
exception
   when no_data_found then
      ciss0047.raise_exception(w_procedure_name, w_label, 'phl_not_found_message'
                              ,'mesg_num', to_char(w_mesg_num)
                              , p_severity=>'f'
                              );
end get_message;
--Start Add 3706
/*************************************************************************************\
   procedure get_mssg_hdr
\*************************************************************************************/
function get_mssg_hdr( p_msg_num      in number
                      ,p_msg_hdr      in varchar2
                      ,p_token_key    in varchar2 default null
                      ,p_token_value  in varchar2 default null
                      ,p_token_key2   in varchar2 default null      --Add 2775
                      ,p_token_value2 in varchar2 default null      --Add 2775
                      ,p_token_key3   in varchar2 default null      --Add 2775
                      ,p_token_value3 in varchar2 default null      --Add 2775
                      ) return varchar2 is
   w_procedure_name  varchar2(30) := 'phls0005.get_mssg_hdr';
   w_hdr_full_text   phl_bill_mssg_hdr.hdr_full_text%type;
begin
   w_label := 'e015';
   --debug(w_procedure_name, w_label, '..phls0001.w_bill_mssg_tbl.count    =' || phls0001.w_bill_mssg_tbl.count);
   --debug(w_procedure_name, w_label, '..Message Num to be found           =' || p_msg_num);
      w_hdr_full_text := trim(p_msg_hdr);
      if p_msg_num = 73 and w_factor_message is null then      --Add 3706
         w_label := 'e016';
         w_hdr_full_text  := 'Duplicate Bill';
      else
	   		if p_token_key is not null then
	            w_label := 'e017';
	            debug(w_procedure_name, w_label, '..w_hdr_full_text =' || w_hdr_full_text);
	            debug(w_procedure_name, w_label, '..p_msg_hdr       =' || p_msg_hdr);
	            debug(w_procedure_name, w_label, '..p_token_key     =' || p_token_key);
	   			if instr(p_msg_hdr, p_token_key) > 0  then
	   				w_hdr_full_text := replace(w_hdr_full_text,p_token_key,trim(p_token_value));
	   				--Start Add 2775
	               w_label := 'e018';
	               debug(w_procedure_name, w_label, '..w_hdr_full_text    =' || w_hdr_full_text);
	   				if instr(w_hdr_full_text,p_token_key2) > 0 and p_token_value2 is not null then
	   					w_hdr_full_text := replace(w_hdr_full_text, p_token_key2, trim(p_token_value2));
	                  w_label := 'e019';
	                  debug(w_procedure_name, w_label, '..w_hdr_full_text    =' || w_hdr_full_text);
	   					if instr(w_hdr_full_text, p_token_key3) > 0 and p_token_key3 is not null then
	   						w_hdr_full_text := replace(w_hdr_full_text, p_token_key3, trim(p_token_value3));
	                     w_label := 'e020';
	                     --debug(w_procedure_name, w_label, '..w_hdr_full_text    =' || w_hdr_full_text);
	   					end if;
	   				end if;
	   				--End Add 2775
	   			else
	               w_label := 'e021';
	   				w_hdr_full_text := trim(p_msg_hdr);
	               --debug(w_procedure_name, w_label, '..w_hdr_full_text    =' || w_hdr_full_text);
	   			end if;
	   		else
	            w_label := 'e022';
	            --trace_label(w_label, w_procedure_name);
	   			w_hdr_full_text  := trim(p_msg_hdr);
	            debug(w_procedure_name, w_label, '..w_hdr_full_text    =' || w_hdr_full_text);
	   		end if;
      end if;
      return w_hdr_full_text;
end;
--End Add 3706
/*************************************************************************************\
   procedure get_mssg_details      -- in order to get priority
\*************************************************************************************/
procedure get_mssg_details(p_msg_num          in number
                         , p_token_key        in varchar2 default null
                         , p_token_value      in varchar2 default null
                         , p_token_key2       in varchar2 default null      --Add 2775
                         , p_token_value2     in varchar2 default null      --Add 2775
                         , p_token_key3       in varchar2 default null      --Add 2775
                         , p_token_value3     in varchar2 default null      --Add 2775
                         , p_hdr_token_key    in varchar2 default null      --Add 3706
                         , p_hdr_token_value  in varchar2 default null      --Add 3706
                         , p_hdr_token_key2   in varchar2 default null      --Add 3706
                         , p_hdr_token_value2 in varchar2 default null      --Add 3706
                         , p_hdr_token_key3   in varchar2 default null      --Add 3706
                         , p_hdr_token_value3 in varchar2 default null      --Add 3706
                         )  is
   w_procedure_name  varchar2(30) := 'phls0005.get_mssg_details';
   j                 binary_integer;
begin
   w_label := 'e023';
   --debug(w_procedure_name, w_label, '..phls0001.w_bill_mssg_tbl.count    =' || phls0001.w_bill_mssg_tbl.count);
   debug(w_procedure_name, w_label, '..w_supply_type    =' || w_supply_type);
   --debug(w_procedure_name, w_label, '..Message Num to be found           =' || p_msg_num);
   w_label := 'e024';
   if w_supply_type = 'WATER' then --Add 4398
      for i in 1 .. phls0001.w_bill_mssg_tbl.count
      loop
         --debug(w_procedure_name, w_label, 'w_mesg_date                          ' || datec(w_mesg_date)                        );
         --debug(w_procedure_name, w_label, 'phls0001.w_bill_mssg_tbl(i).mesg_num ' || phls0001.w_bill_mssg_tbl(i).mesg_num        );
         --debug(w_procedure_name, w_label, 'p_msg_num                             ' || p_msg_num        );
         --
         --debug(w_procedure_name, w_label, 'phls0001.w_bill_mssg_tbl(i).from_date' || datec(phls0001.w_bill_mssg_tbl(i).from_date));
         --debug(w_procedure_name, w_label, 'phls0001.w_bill_mssg_tbl(i).upto_date' || datec(phls0001.w_bill_mssg_tbl(i).upto_date));
         w_label := 'e025';
         if  phls0001.w_bill_mssg_tbl(i).mesg_num = p_msg_num
         and w_mesg_date >= phls0001.w_bill_mssg_tbl(i).from_date
         and w_mesg_date <= phls0001.w_bill_mssg_tbl(i).upto_date
         and phls0001.w_bill_mssg_tbl(i).full_text is not null
         then
            debug(w_procedure_name, w_label, 'Found in pl/sql table phls0001.w_bill_mssg_tbl(i).mesg_num ' || phls0001.w_bill_mssg_tbl(i).mesg_num );
            w_label := 'e026';
            if phls0001.w_bill_mssg_tbl(i).priority != (99*w_prio_multi) then  --Mod 3327b Was 99 mod to 99000
               j := phls0001.w_bill_mssg_tbl(i).priority;
            else
               w_idx_msg_priority_99   := w_idx_msg_priority_99 + 1;
               j := phls0001.w_bill_mssg_tbl(i).priority + w_idx_msg_priority_99;
            end if;
            w_label := 'e027';
            w_sort_mssg_tbl(j).mesg_num      := p_msg_num;
            --debug(w_procedure_name, w_label, 'Before phls0001.w_bill_mssg_tbl(i).hdr_full_text --> ' || phls0001.w_bill_mssg_tbl(i).hdr_full_text);
      			w_sort_mssg_tbl(j).hdr_full_text := get_mssg_hdr(p_msg_num      => p_msg_num
      		                                                ,p_msg_hdr        => phls0001.w_bill_mssg_tbl(i).hdr_full_text
      		                                                ,p_token_key      => p_hdr_token_key
      		                                                ,p_token_value    => p_hdr_token_value
                                                          ,p_token_key2     => p_hdr_token_key2
                                                          ,p_token_value2   => p_hdr_token_value2
                                                          ,p_token_key3     => p_hdr_token_key3
                                                          ,p_token_value3   => p_hdr_token_value3
                                                          );
            w_label := 'e028';
            debug(w_procedure_name, w_label, 'After phls0001.w_bill_mssg_tbl(i).hdr_full_text --> ' || phls0001.w_bill_mssg_tbl(i).hdr_full_text);
            debug(w_procedure_name, w_label, 'w_sur_cst_fct_mssg --> ' || w_sur_cst_fct_mssg);
            if p_msg_num = 73 then
               w_sort_mssg_tbl(j).full_text  := w_sur_cst_fct_mssg;
            else
               w_sort_mssg_tbl(j).full_text  := phls0001.w_bill_mssg_tbl(i).full_text;
            end if;
            w_label := 'e029';
            debug(w_procedure_name, w_label, '-->Before assignment w_sort_mssg_tbl(j).full_text  ==> <' || j ||'>' || w_sort_mssg_tbl(j).full_text);
            w_sort_mssg_tbl(j).mesg_id             := phls0001.w_bill_mssg_tbl(i).mesg_id;
            debug(w_procedure_name, w_label, '-->phls0001.w_bill_mssg_tbl(i).mesg_id    ==> <' || j ||'>' || phls0001.w_bill_mssg_tbl(i).mesg_id);
            debug(w_procedure_name, w_label, '-->length p_token_key   <'|| j ||'>'||length(p_token_key));
            debug(w_procedure_name, w_label, '-->length p_token_value <'|| j ||'>'||length(p_token_value));
            debug(w_procedure_name, w_label, '-->length p_token_key2  <'|| j ||'>'||length(p_token_key2));
            debug(w_procedure_name, w_label, '-->length p_token_value2<'|| j ||'>'||length(p_token_value2));
            debug(w_procedure_name, w_label, '-->length p_token_key3  <'|| j ||'>'||length(p_token_key3));
            debug(w_procedure_name, w_label, '-->length p_token_value3<'|| j ||'>'||length(p_token_value3));
            w_sort_mssg_tbl(j).token_key           := p_token_key;
            debug(w_procedure_name, w_label, '-->p_token_key    ==> <' || j ||'>' || p_token_key);
            w_sort_mssg_tbl(j).token_value         := trim(p_token_value);
            debug(w_procedure_name, w_label, '-->p_token_value  ==> <' || j ||'>' || p_token_value);
            w_sort_mssg_tbl(j).token_key2          := p_token_key2;     --Add 2775
            debug(w_procedure_name, w_label, '-->p_token_key2    ==> <' || j ||'>' || p_token_key2);
            w_sort_mssg_tbl(j).token_value2        := trim(p_token_value2);   --Add 2775
            debug(w_procedure_name, w_label, '-->p_token_value2  ==> <' || j ||'>' || p_token_value2);
            w_sort_mssg_tbl(j).token_key3          := p_token_key3;     --Add 2775
            debug(w_procedure_name, w_label, '-->p_token_key3    ==> <' || j ||'>' || p_token_key3);
            w_sort_mssg_tbl(j).token_value3        := trim(p_token_value3);   --Add 2775
            debug(w_procedure_name, w_label, '-->p_token_value3  ==> <' || j ||'>' || p_token_value3);
            debug(w_procedure_name, w_label, '-->After assignment w_sort_mssg_tbl(j).full_text  ==> <' || j ||'>' || w_sort_mssg_tbl(j).full_text);
            debug(w_procedure_name, w_label, '-->Last w_sort_mssg_tbl(j) ==> <' || j ||'>' || w_sort_mssg_tbl(j).hdr_full_text);
            exit;
         end if;
      end loop;
   elsif w_supply_type = 'HELPLOAN' then     --Add 4398
   /* Start Add 4398 */
      w_label := 'e030';
      debug(w_procedure_name, w_label, '..w_supply_type    =' || w_supply_type);
      for i in 1 .. phls0001.w_hpln_mssg_tbl.count
      loop
         w_label := 'e031';
         if    phls0001.w_hpln_mssg_tbl(i).mesg_num = p_msg_num
         and    w_mesg_date >= phls0001.w_hpln_mssg_tbl(i).from_date
         and    w_mesg_date <= phls0001.w_hpln_mssg_tbl(i).upto_date
         and   phls0001.w_hpln_mssg_tbl(i).full_text is not null
         then
            j := phls0001.w_hpln_mssg_tbl(i).priority;
            w_sort_mssg_tbl(j).mesg_num      := p_msg_num;
            w_sort_mssg_tbl(j).hdr_full_text := get_mssg_hdr(p_msg_num        => p_msg_num
      		                                                ,p_msg_hdr        => phls0001.w_hpln_mssg_tbl(i).hdr_full_text
      		                                                ,p_token_key      => p_hdr_token_key
      		                                                ,p_token_value    => p_hdr_token_value
                                                            ,p_token_key2     => p_hdr_token_key2
                                                            ,p_token_value2   => p_hdr_token_value2
                                                            ,p_token_key3     => p_hdr_token_key3
                                                            ,p_token_value3   => p_hdr_token_value3
                                                            );
            if p_msg_num = 11101 then              --Chg 6035 3.0.0.06 the Message Number from 11004 to 11101
               w_sort_mssg_tbl(j).full_text  := w_hl_5th_fpg_inv_desc; --Help Loan Long Invoice Description
            elsif p_msg_num = 11102 then           --Chg 6035 3.0.0.06 the Message Number from 11005 to 11102
               w_sort_mssg_tbl(j).full_text  := w_hl_4th_fpg_inv_desc; --Help Loan Long Invoice Description
            elsif p_msg_num = 11103 then           --Chg 6035 3.0.0.06 the Message Number from 11006 to 11103
               w_sort_mssg_tbl(j).full_text  := w_hl_3rd_fpg_inv_desc; --Help Loan Long Invoice Description
            elsif p_msg_num = 11104 then           --Chg 6035 3.0.0.06 the Message Number from 11007 to 11104
               w_sort_mssg_tbl(j).full_text  := w_hl_2nd_fpg_inv_desc; --Help Loan Long Invoice Description
            else
               w_sort_mssg_tbl(j).full_text  := phls0001.w_hpln_mssg_tbl(i).full_text;
            end if;
            w_sort_mssg_tbl(j).mesg_id       := phls0001.w_hpln_mssg_tbl(i).mesg_id;
            w_sort_mssg_tbl(j).token_key     := p_token_key;
            w_sort_mssg_tbl(j).token_value   := trim(p_token_value);
            w_sort_mssg_tbl(j).token_key2    := p_token_key2;
            w_sort_mssg_tbl(j).token_value2  := trim(p_token_value2);
            w_sort_mssg_tbl(j).token_key3    := p_token_key3;
            w_sort_mssg_tbl(j).token_value3  := trim(p_token_value3);
         end if;
      end loop;
   end if;
   /* End Add 4398 */
end get_mssg_details;
/*************************************************************************************\
   procedure set_bill_message      -- Modifed for New Bills
\*************************************************************************************/
--Start 2.0.0.1    --Chg the code
--Entire Procedure has been modified
procedure set_bill_message
is
   w_procedure_name    varchar2(40) := 'phls0005.set_bill_message';
   l_mnts_btwn         number; --Add 9106
   lrt_num						 number; --Add 9106
begin
   w_label := 'e032';
   trace_label(w_label, w_procedure_name);
   w_sort_mssg_tbl.delete;
   if w_supply_type = 'WATER'  then --Add 4398
      -- Messages are evaluated in order of most important to least important.  This way any disk access
      -- required for the least important messages will only happen if there's a possibility of using that message.
      --Default Messages
      if nvl(w_ss_fee_mssg,'N') = 'Y' then 	--Add 7762
	      w_mesg_num := 85;              			--Add 7762
	      get_mssg_details(w_mesg_num);  			--Add 7762
			end if; 															--Add 7762
      w_mesg_num := 84;              --Add 8550
      get_mssg_details(w_mesg_num);  --Add 8550
      w_mesg_num := 18;
      get_mssg_details(w_mesg_num);
      w_mesg_num := 10;
      get_mssg_details(w_mesg_num);
      w_mesg_num := 14;
      get_mssg_details(w_mesg_num);
      w_mesg_num := 80;                     --Add 4611 susan's added new message Add 3.0.0.21
      get_mssg_details(w_mesg_num);         --Add 4611 susan's added new message Add 3.0.0.21
      --Start add 7164
      if nvl(w_dispute_amnt,0) > 0 then
	      w_mesg_num := 82;
	      get_mssg_details(w_mesg_num);
	    end if;
      --End add 7164
      --Start Add 6495
      if nvl(w_bnkrptcy_bal_amnt_wat,0) > 0 then
         w_mesg_num := 81;
         get_mssg_details(w_mesg_num);
      end if;
      --End Add 6495
      --Start Add 9106
			debug_ttid('9106' , w_procedure_name,w_label,'<phls0001.gp_deply_rts_tbl.count>'|| phls0001.gp_deply_rts_tbl.count);
			debug_ttid('9106' , w_procedure_name,w_label,'<g_outreader_type_code'|| g_outreader_type_code);
      if phls0001.gp_deply_rts_tbl.count <> 0 and nvl(g_outreader_type_code,'XXX') != 'AMI' then
        begin
          lrt_num := to_number(w_round_key);
        exception
        	when others then
        		 lrt_num := 0;
        end;
				debug_ttid('9106' , w_procedure_name,w_label,'<lrt_num'|| lrt_num);
      	if to_number(lrt_num) >= 1 and  to_number(lrt_num) <= 60 then
	         --l_mnts_btwn := months_between(w_mesg_date,phls0001.gp_deply_rts_tbl(lrt_num).planned_start_date); --Del 9106b
           select trunc(w_mesg_date) - trunc(phls0001.gp_deply_rts_tbl(lrt_num).planned_start_date) into l_mnts_btwn from dual; --Chng 9106b moved from months to days
					 debug_ttid('9106' , w_procedure_name,w_label,'<l_mnts_btwn'|| l_mnts_btwn);
      		 if l_mnts_btwn >= -40 and          --Chngd 9106b from -1 to -40 (is equalent to 40 days)
      		    l_mnts_btwn <=  0
      		 then
		         w_mesg_num := 89;
		         get_mssg_details(w_mesg_num);
      		 elsif l_mnts_btwn >=  1 and            --Chng 9106b > 0 to  >= 1
      		       l_mnts_btwn <= 109               --Chngd 9106b chngd from 1 to 109
      		  then
		         w_mesg_num := 90;
		         get_mssg_details(w_mesg_num);
      		 elsif l_mnts_btwn >= 110 and          --Chngd 9106b chngd from 4 to 110
      		       l_mnts_btwn <= 150
      		  then
		         w_mesg_num := 91;
		         get_mssg_details(w_mesg_num);
      		 end if;
	      end if;
				debug_ttid('9106' , w_procedure_name,w_label,'<w_mesg_num'|| w_mesg_num);
	    end if;
      --End Add 9106
      --Start Add 4563
      debug(w_procedure_name, w_label, '--> w_un_paid_prv_bal '  || w_un_paid_prv_bal);
      if w_arrears_letter_no is not null and nvl(w_un_paid_prv_bal,0) > 0 then --Mod 4563A 3.0.0.22
         debug(w_procedure_name, w_label, '--> w_arrears_letter_no '  || w_arrears_letter_no);
         debug(w_procedure_name, w_label, '--> w_un_paid_prv_bal   '  || w_un_paid_prv_bal);
         w_mesg_num := 77;
         get_mssg_details(w_mesg_num);
      end if;
      --End Add 4563
      w_label := 'e033';
      --debug(w_procedure_name, w_label, ' w_pay_profile_code '  || w_pay_profile_code);
      w_label := 'e034';
      --debug(w_procedure_name, w_label, '--> ***0*** ==> w_debt_bal_amnt_ues '  || w_debt_bal_amnt_ues);
      if nvl(w_debt_bal_amnt_ues,0) > 0 then
         w_label := 'e035';
         w_mesg_num := 2;
         w_grant_hdr_value := 'UESF Grant';     --Add 3706
         get_mssg_details(p_msg_num          => w_mesg_num
                        , p_token_key        => w_token_grant_amnt
                        , p_token_value      => trim(to_char(w_debt_bal_amnt_ues,'$99,999,990.00'))
                        , p_hdr_token_key    => w_token_hdr_grant_name
                        , p_hdr_token_value  => w_grant_hdr_value
                        );
      end if;
      w_label := 'e036';
      --debug(w_procedure_name, w_label, '--> ***1*** ==> w_grnt_rcvd '  || w_grnt_rcvd);
      --Start Add 3706
      if nvl(w_grnt_rcvd,0) <> 0 then
         w_label := 'e037';
         w_mesg_num := 76;
         w_grant_hdr_value := 'UESF Grant';
         get_mssg_details(p_msg_num          => w_mesg_num
                        , p_token_key        => w_token_grant_amnt
                        , p_token_value      => trim(to_char(abs(w_grnt_rcvd),'$99,999,990.00'))
                        , p_hdr_token_key    => w_token_hdr_grant_name
                        , p_hdr_token_value  => w_grant_hdr_value
                        );
      end if;
      --End Add 3706
      w_label := 'e038';
      if w_sur_cst_fct_mssg is not null then
         w_mesg_num := 73;
         get_mssg_details(w_mesg_num);
      end if;
      w_label := 'e039';
      w_count := 0;
      --if w_previous_balance_amnt >= phls0017.w_min_lien_bal_amnt then --Del 7349
			w_label := 'e040';
			debug(w_procedure_name, w_label, '--> WAT LIEN ==> w_cust_id '  || w_cust_id);
			debug(w_procedure_name, w_label, '--> WAT LIEN ==> w_inst_id '  || w_inst_id);
			select count(*) into w_count
			  from phl_debt_coll_driver dcdr
			 where dcdr.driver_type = 'L'                         -- Chg 1772
			   and dcdr.action_reqd_ind = 'Y'                     -- Add 1772
			   and dcdr.do_not_action_ind is null                 -- Add 1772
			   and dcdr.cust_id = w_cust_id
			   and dcdr.inst_id = w_inst_id
			   and exists (select null from cis_accounts acct where acct.acct_id = dcdr.acct_id
			   --                                                 and acct.pay_profile_code not like 'TAP%'   --Del 9297 --Add 6971
			                                                      and acct.supply_type = 'WATER') 						--Add 4398
			   and months_between(w_mesg_date,creation_date) <= 1;  --Add 2.0.0.05
      --end if;
      w_label := 'e041';
      if  w_count <> 0
      --and w_tap_disc is null   --Del 9297 --Add 6971
      then
      	 --w_pay_profile_code_orig
         --Use w_pay_profile_code_orig only for WATER accounts as only WATER account is called from phls0001.
      	 if w_pay_profile_code_orig like 'TAP%' then  --Add 9297B
	         w_mesg_num := 86;                     --Add 9297B
	         get_mssg_details(w_mesg_num);         --Add 9297B
      	 else															 			 --Add 9297B
         	 w_mesg_num := 27;                     -- Due for Lien
           get_mssg_details(w_mesg_num);
         end if; 												         --Add 9297B
      end if;
      /* Start add 7349 */
      w_label := 'e042';
      w_count := 0;
			debug(w_procedure_name, w_label, '--> AGN LIEN ==> w_cust_id 		 '  || w_cust_id);
			debug(w_procedure_name, w_label, '--> AGN LIEN ==> w_inst_id 		 '  || w_inst_id);
			debug(w_procedure_name, w_label, '--> AGN LIEN ==> w_count   		 '  || w_count  );
			debug(w_procedure_name, w_label, '--> AGN LIEN ==> w_mesg_date   '  || datec(w_mesg_date)  );
			select count(*) into w_count
			  from phl_debt_coll_driver dcdr
			 where dcdr.driver_type = 'L'
			   and dcdr.action_reqd_ind = 'Y'
			   and dcdr.do_not_action_ind is null
			   and dcdr.cust_id = w_cust_id
			   and dcdr.inst_id = w_inst_id
			   and exists (select null from cis_accounts acct where acct.acct_id = dcdr.acct_id
			                                                    and acct.supply_type = 'AGENCY')
			   and months_between(w_mesg_date,creation_date) <= 1;  --Add 2.0.0.05
			debug(w_procedure_name, w_label, '--> AGN LIEN ==> w_count   '  || w_count  );
      w_label := 'e043';
      if  w_count <> 0
      then
			   debug(w_procedure_name, w_label, '--> In AGENCY [Check WATER PAY_PROFILE] == '  || w_pay_profile_code  ); --Add 9297B
			   debug(w_procedure_name, w_label, '--> In AGENCY [Check WATER w_pay_profile_code_orig] == '  || w_pay_profile_code_orig  ); --Add 9297B
         --use only [Water w_pay_profile_code_orig for BOTH WATER and AGENCY because AGENCY PAY_PROFILE never changes to TAP] --Add 9297B
         --Water w_pay_profile_code_orig Governs if its on TAP or NOT. --Add 9297B
         -- w_pay_profile_code is for WATER accounts and only water a/c pay_profiels are called from phls0001. --Add 9297B
      	 if nvl(w_pay_profile_code_orig,'ERROR') like 'TAP%' then  --Add 9297B
	         w_mesg_num := 87;                     --Add 9297B
	         get_mssg_details(w_mesg_num);         --Add 9297B
      	 else
		       w_label := 'e044';
	         w_mesg_num := 83;                		 -- Due for Agency Lien
	         get_mssg_details(w_mesg_num);
	       end if;  												       --Add 9297B
      end if;
      /* End add 7349 */
      w_label := 'e045';
      if w_acct_pay_method <> 'I' then
         w_mesg_num := 41;                -- Date if Zip Check payment
         get_mssg_details(p_msg_num       => w_mesg_num
                        , p_token_key     => w_dd_date
                        , p_token_value    => to_char(w_dd_earliest_date,'MM/DD/YY'));
			--Start Del 8020D
      --Start Add 9454
      --elsif g_ebill_auto_pay_ind = 'Y' then
      --   w_mesg_num := 88;                -- eBilling Auto Payment Indicator
      --   get_mssg_details(p_msg_num       => w_mesg_num);
      --end if;
      --End Add 9454
			--End Del 8020D
      --Start Add 8020D
      elsif g_ebill_auto_pay_ind is not null  then
      	if  instr(g_ebill_auto_pay_ind,'YES') <> 0 then
						w_mesg_num := 88;                -- eBilling Auto Payment Indicator
						if     instr(substr(g_ebill_auto_pay_ind,4),'W') <> 0 	--First three characters as "YES"
						   and instr(substr(g_ebill_auto_pay_ind,4),'A') <> 0   --First three characters as "YES"
						   and instr(substr(g_ebill_auto_pay_ind,4),'H') <> 0   --First three characters as "YES"
						then
				        w_label := 'e046';
								g_str_by_access_cd1 := 'water/sewer/storm water,';
								g_str_by_access_cd2 := 'meter and repair,';
								g_str_by_access_cd3 := 'and HELP Loan portions'; --of this bill';
						elsif  instr(substr(g_ebill_auto_pay_ind,4),'W') <> 0
						   and instr(substr(g_ebill_auto_pay_ind,4),'A') <> 0
						   and instr(substr(g_ebill_auto_pay_ind,4),'H')  = 0 	--Add 8020F
						then
				        w_label := 'e047';
								g_str_by_access_cd1 := 'water/sewer/storm water';
								g_str_by_access_cd2 := 'and meter and repair';
								g_str_by_access_cd3 := 'portions';
						elsif  instr(substr(g_ebill_auto_pay_ind,4),'W') <> 0
						   and instr(substr(g_ebill_auto_pay_ind,4),'H') <> 0
						   and instr(substr(g_ebill_auto_pay_ind,4),'A') = 0 		--Add 8020F
						then
				        w_label := 'e048';
								g_str_by_access_cd1 := 'water/sewer/storm water';
								g_str_by_access_cd2 := 'and HELP Loan';
								g_str_by_access_cd3 := 'portions';
						elsif  instr(substr(g_ebill_auto_pay_ind,4),'A') <> 0
						   and instr(substr(g_ebill_auto_pay_ind,4),'H') <> 0
						   and instr(substr(g_ebill_auto_pay_ind,4),'W') = 0 			--Add 8020F
						then
				        w_label := 'e049';
								g_str_by_access_cd1 := 'meter and repair';
								g_str_by_access_cd2 := 'and HELP Loan';
								g_str_by_access_cd3 := 'portions';
						elsif     instr(substr(g_ebill_auto_pay_ind,4),'W') <> 0
						   		and instr(substr(g_ebill_auto_pay_ind,4),'H') = 0 	--Add 8020F
						      and instr(substr(g_ebill_auto_pay_ind,4),'A') = 0 	--Add 8020F
						then
				        w_label := 'e050';
								g_str_by_access_cd1 := 'water/sewer/storm water';
								g_str_by_access_cd2 := 'portion';
								g_str_by_access_cd3 := NULL;													--Add 8020F
						elsif      instr(substr(g_ebill_auto_pay_ind,4),'A') <> 0
						       and instr(substr(g_ebill_auto_pay_ind,4),'H') = 0 	--Add 8020F
						       and instr(substr(g_ebill_auto_pay_ind,4),'W') = 0 	--Add 8020F
						then
				        w_label := 'e051';
								g_str_by_access_cd1 := 'meter and repair';
								g_str_by_access_cd2 := 'portion';
								g_str_by_access_cd3 := NULL;													--Add 8020F
						elsif      instr(substr(g_ebill_auto_pay_ind,4),'H') <> 0
						       and instr(substr(g_ebill_auto_pay_ind,4),'A') = 0 	--Add 8020F
						       and instr(substr(g_ebill_auto_pay_ind,4),'W') = 0 	--Add 8020F
						then
				        w_label := 'e052';
								g_str_by_access_cd1 := 'HELP Loan';
								g_str_by_access_cd2 := 'portion';
								g_str_by_access_cd3 := NULL;													--Add 8020F
						end if;
				    debug(w_procedure_name, w_label, '--> g_str_by_access_cd1 == '  || g_str_by_access_cd1);
				    debug(w_procedure_name, w_label, '--> g_str_by_access_cd2 == '  || g_str_by_access_cd2);
				    debug(w_procedure_name, w_label, '--> g_str_by_access_cd3 == '  || g_str_by_access_cd3);
		        get_mssg_details(p_msg_num       => w_mesg_num
		                       , p_token_key     => gp_tkn_key_auto_pay_str1
		                       , p_token_value   => g_str_by_access_cd1
		                       , p_token_key2    => gp_tkn_key_auto_pay_str2
		                       , p_token_value2  => g_str_by_access_cd2
		                       , p_token_key3    => gp_tkn_key_auto_pay_str3
		                       , p_token_value3  => g_str_by_access_cd3
		                        );
        end if;
      end if;
			--End Add 8020D
      w_label := 'e053';
      if  w_ppln_id is not null
      and w_ppln_no_due > 1
      then
         --Start Add 4398 Need to discuss before I put it.
         --begin
         --   w_act_mtr_wrk_dt := null;
         --   select meter_work_date into w_act_mtr_wrk_dt
         --     from cis.cis_meter_wos
         --    where inst_id   = w_inst_id
         --      and work_type = 'SHUT-OFF'
         --      and meter_work_status not in ('C','X','U');
         --when others then
         --   w_act_mtr_wrk_dt := null;
         --end if;
         --End Add 4398
         --if w_shutoff_date is null then --THEN IT PLAN TYPE = I --Del 4398
         if w_shutoff_date is null then --THEN IT PLAN TYPE = I
             w_mesg_num := 75;          -- Payment agreement payments missed. -- Due_Agree_Amnt
             get_mssg_details( p_msg_num     => w_mesg_num                                 --Add 2775
                              ,p_token_key   => w_token_due_agree_amnt                     --Add 2775
                              ,p_token_value => to_char(w_ppln_due_amnt,'$99,999,990.00')  --Add 2775
                             );                                                            --Add 2775
         else
             w_label := 'e054';
             w_mesg_num := 31;          -- Payment agreement payments missed.
             ----Start 4398 Need to discuss before I put it.
             --if w_shutoff_date is not null then
             --   if w_act_mtr_wrk_dt > w_shutoff_date then
             --      w_shutoff_date := w_act_mtr_wrk_dt;
             --   end if;
             --end if;
             --End 4398
             get_mssg_details( p_msg_num          => w_mesg_num                               --Add 2775
                             , p_token_key        => w_token_due_agree_amnt                   --Add 2775
                             , p_token_value    => to_char(w_ppln_due_amnt,'$99,999,990.00')  --Add 2775
                             --, p_token_key2     => w_token_shutoff_date                       --Add 2775
                             --, p_token_value2    => to_char(w_shutoff_date,'MM/DD/YY')        --Add 2775
                             );                                                               --Add 2775
         end if;
      end if;
      w_label := 'e055';
      if w_cust_own_reading_ind = 'Y'
      then
         w_mesg_num := 28;
         get_mssg_details(p_msg_num       => w_mesg_num);
      end if;
      w_label := 'e056';
      if w_ppln_id is not null
      and w_ppln_due_amnt is not null
      then
         w_mesg_num  := 32;
         --w_token_key := w_token_due_agree_amnt;
         --w_token_val := to_char(w_ppln_due_amnt,'$99,999,990.00');   -- optional minus sign takes a space
         get_mssg_details(p_msg_num       => w_mesg_num
                        , p_token_key     => w_token_due_agree_amnt
                        , p_token_value    => to_char(w_ppln_due_amnt,'$99,999,990.00'));
      end if;
      --Start Add 9984
      if g_pnlty_frgv_dt is not null and g_pnlty_frgv_amnt is not null then
         w_mesg_num  := 92;
         --w_token_key := w_token_due_agree_amnt;
         --w_token_val := to_char(w_ppln_due_amnt,'$99,999,990.00');   -- optional minus sign takes a space
	       get_mssg_details(p_msg_num       => w_mesg_num
	                      , p_token_key     => gp_pnlty_frgv_dt_str
	                      , p_token_value   => to_char(g_pnlty_frgv_dt,'mm/dd/yyyy')
	                      , p_token_key2    => gp_pnlty_frgv_amnt_str
	                      , p_token_value2  => to_char(g_pnlty_frgv_amnt,'$99,999,990.00')
	                       );
			end if;
			if g_prin_frgv_dt is not null and g_prin_frgv_amnt is not null then
         w_mesg_num  := 93;
	       get_mssg_details(p_msg_num       => w_mesg_num
	                      , p_token_key     => gp_prin_frgv_dt_str
	                      , p_token_value   => to_char(g_prin_frgv_dt,'mm/dd/yyyy')
	                      , p_token_key2    => gp_prin_frgv_amnt_str
	                      , p_token_value2  => to_char(g_prin_frgv_amnt,'$99,999,990.00')
	                       );
			end if;
      --End Add 9984
      --Start Add 10495
      if g_tgt_dt is not null then
         w_mesg_num  := 94;
	       get_mssg_details(p_msg_num       => w_mesg_num
	                      , p_token_key     => gp_tgt_dt_str
	                      , p_token_value   => to_char(g_tgt_dt,'mm/dd/yyyy')
	                       );
	    end if;
      --End Add 10495
      --Start Add 11413
      if nvl(g_s17_grnt_amnt,0) > 0  then
         w_mesg_num  := 95;
	       get_mssg_details(p_msg_num       => w_mesg_num
	                      , p_token_key     => gp_s17_grnt_amnt_str
	                      , p_token_value   => to_char(g_s17_grnt_amnt,'$99,999,990.00')
	                       );
      end if;
      --End Add 11413 
      -- Start 2.0.0.13 Add new bill message for BUG 3025
      if w_fault_code = 'NOT-REG'        then
         w_mesg_num := 8;
         get_mssg_details(p_msg_num       => w_mesg_num);
      end if;
      -- End 2.0.0.13
      -- Start Add 3352
      w_mesg_num := 78;
      get_mssg_details(p_msg_num       => w_mesg_num);
      -- End Add 3352
      w_label := 'e057';
      if w_estimates_cnt >= 12 then
         w_mesg_num := 12;                 -- No real reading for 1 year
         get_mssg_details(w_mesg_num);
      end if;
      w_label := 'e058';
      if w_meter_work_date is not null then              -- Add 1.0.0.24
         w_mesg_num := 19;                               -- Add 1.0.0.24
         w_meter_work_date := null;                      -- Add 1.0.0.24
         get_mssg_details(p_msg_num       => w_mesg_num);
      end if;
      -- Start Add 2730
      w_label := 'e059';
      -- Message to state the bill period covered by SW charge
      if w_sw_chg_fr_dt is not null then                 --Chg 3659
         w_mesg_num := 1;
         w_period := null;
         w_period := to_char(w_sw_chg_fr_dt,'MM/DD/YY') || ' to ' || to_char(w_sw_chg_to_dt,'MM/DD/YY');    --Chg 3706 Uppercase TO Lowercase to --Chg 3659
         get_mssg_details(p_msg_num     => w_mesg_num
                        , p_token_key   => w_period_date
                        , p_token_value => w_period
                           );
      end if;
      w_label := 'e060';
      -- Message to on first bill of NB3 and NB8 accounts
      if w_nb_code = 'NB3' or w_nb_code = 'NB8' then
         w_mesg_num := 3;
         get_mssg_details(w_mesg_num);
      end if;
      -- End Add 2730
      -- Start Add 2657
      select ext_org_code into w_sw_only
      from cis_installations
      where inst_id = w_inst_id;
      if substr(w_sw_only,1,2) = 'SW' then
         select min(tran_id) into w_min_tran_id
         from cis_transactions
         where cust_id = w_cust_id
         and inst_id = w_inst_id
         and supply_type = 'WATER'
         and task_code = 'BILL'
         and tran_tot_amnt > 0
         and fully_reversed_ind is null;
         if w_tran_id = w_min_tran_id then
            w_mesg_num := 9;
            w_sw_nb5_fnd := true;
            get_mssg_details(w_mesg_num);
         end if;
      end if;
   elsif w_supply_type = 'HELPLOAN'  then --Add 4398
   /* Start Add 4398 */
      w_label := 'e061';
      trace_label(w_label, w_procedure_name);
      if w_hl_ppln_id is null and nvl(w_hl_cure_amnt,0) > 0 then   --NO PLAN and account balance is greater than balance
         w_label := 'e062';
         trace_label(w_label, w_procedure_name);
         w_mesg_num  := 11001;
         get_mssg_details(w_mesg_num);
      else
         /* Start 7180 */
         -- read if issues comes again very important
         -- Check Bill Dated July 03, 2017 --> Bill Number B0601490556
         -- This Bill was showing HELPLOAN defaulted mssg (msg# 11002) for first month itself.
         -- By adding grace perioid to penalty it looks like there would be one installment always due.
         -- Handled the code in 300, so changed back the code back to w_hl_ppln_no_due >= 1. But still keeping these comments to analyze further. If we have issues.
         --if w_hl_ppln_no_due >= 1 then --del  7180
      	 w_label := 'e063';
         debug(w_procedure_name, w_label, '...w_hl_ppln_no_due=w_hl_ppln_no_due');
         if w_hl_ppln_no_due >= 1 then --chng back to >= because handled the code in 300, Keeping these comments 7180  --If issues pops up again refer explanation in above 7 lines
         /* End 7180 */
            w_label := 'e064';
            trace_label(w_label, w_procedure_name);
            debug(w_procedure_name, w_label, '..There should be a message for plan about to breach..=');
            debug(w_procedure_name, w_label, '...w_hl_ppln_no_due=w_hl_ppln_no_due');
            w_mesg_num  := 11002;
            get_mssg_details( p_msg_num       => w_mesg_num
                            , p_token_key     => w_token_hl_cure_amnt
                            , p_token_value   => to_char(w_hl_cure_amnt,'$99,999,990.00')
                            );
         end if;
      end if;
      --Messages for Helpcorr and Superseded
      --if for Supperseded we need separate message
      --use w_ppln_status = 'S' then
      w_label := 'e065';
      if w_hl_superseded then
         w_label := 'e066';
         trace_label(w_label, w_procedure_name);
         debug(w_procedure_name, w_label, '..w_hl_superseded..=' || booleanc(w_hl_superseded));
         if w_hl_superseded and w_hl_curr_std_ppln = 'HELPCORR' then
            w_mesg_num  := 11003;
            w_label := 'e067';
            debug(w_procedure_name, w_label, '..w_mesg_num                       =' || w_mesg_num);
            debug(w_procedure_name, w_label, '..w_token_hl_curr_ppln_tot_amnt    =' || w_token_hl_curr_ppln_tot_amnt);
            debug(w_procedure_name, w_label, '..w_token_hl_curr_ppln_bal_amnt    =' || w_token_hl_curr_ppln_bal_amnt);
            get_mssg_details(p_msg_num       => w_mesg_num
                           , p_token_key     => w_token_hl_curr_ppln_bal_amnt
                           , p_token_value   => to_char(w_hl_curr_ppln_bal_amnt,'$99,999,990.00')
                           , p_token_key2    => w_token_hl_curr_ppln_tot_amnt
                           , p_token_value2  => to_char(w_hl_curr_ppln_tot_amnt,'$99,999,990.00')
                           );
            w_label := 'e068';
            trace_label(w_label, w_procedure_name);
         elsif w_hl_superseded and w_hl_curr_std_ppln = 'HELPLOAN' then
            w_mesg_num  := 11004;
            w_label := 'e069';
            debug(w_procedure_name, w_label, '..w_mesg_num                       =' || w_mesg_num);
            debug(w_procedure_name, w_label, '..w_token_hl_curr_ppln_tot_amnt    =' || w_token_hl_curr_ppln_tot_amnt);
            debug(w_procedure_name, w_label, '..w_token_hl_curr_ppln_bal_amnt    =' || w_token_hl_curr_ppln_bal_amnt);
            get_mssg_details(p_msg_num      => w_mesg_num
                           , p_token_key    => w_token_hl_curr_ppln_tot_amnt
                           , p_token_value  => to_char(w_hl_curr_ppln_tot_amnt,'$99,999,990.00')
                           , p_token_key2   => w_token_hl_curr_ppln_bal_amnt
                           , p_token_value2 => to_char(w_hl_curr_ppln_bal_amnt,'$99,999,990.00')
                           );
            w_label := 'e070';
            trace_label(w_label, w_procedure_name);
         end if;
      end if;
      w_label := 'e071';
      debug(w_procedure_name, w_label, ' w_hl_5th_fpg_inv_desc :- ' || w_hl_5th_fpg_inv_desc);
      if w_hl_5th_fpg_inv_desc is not null then
         trace_label(w_label, w_procedure_name);
         w_mesg_num  := 11101;
         get_mssg_details(w_mesg_num);
      end if;
      w_label := 'e072';
      debug(w_procedure_name, w_label, ' w_hl_4th_fpg_inv_desc :- ' || w_hl_4th_fpg_inv_desc);
      if w_hl_4th_fpg_inv_desc is not null then
         trace_label(w_label, w_procedure_name);
         w_mesg_num  := 11102;
         get_mssg_details(w_mesg_num);
      end if;
      w_label := 'e073';
      debug(w_procedure_name, w_label, ' w_hl_3rd_fpg_inv_desc :- ' || w_hl_3rd_fpg_inv_desc);
      if w_hl_3rd_fpg_inv_desc is not null then
         w_mesg_num  := 11103;
         trace_label(w_label, w_procedure_name);
         get_mssg_details(w_mesg_num);
      end if;
      w_label := 'e074';
      debug(w_procedure_name, w_label, ' w_hl_2nd_fpg_inv_desc :- ' || w_hl_2nd_fpg_inv_desc);
      if w_hl_2nd_fpg_inv_desc is not null then
         w_mesg_num  := 11104;
         trace_label(w_label, w_procedure_name);
         get_mssg_details(w_mesg_num);
      end if;
   end if;
   /* End Add 4398 */
end set_bill_message;
--End 2.0.0.1
/*************************************************************************************\
   procedure set_pyagremd
\*************************************************************************************/
procedure set_pyagremd
is
   w_procedure_name              varchar2(40) := 'phls0005.set_pyagremd';
begin
   trace_label('e075', w_procedure_name);
end set_pyagremd;
/*************************************************************************************\
   procedure set_pyagshut
\*************************************************************************************/
procedure set_pyagshut
is
   w_procedure_name              varchar2(40) := 'phls0005.set_pyagshut';
begin
   trace_label('e076', w_procedure_name);
end set_pyagshut;
/*************************************************************************************\
   procedure get_billmssg
\*************************************************************************************/
procedure get_billmssg  (
 p_cust_id               in   cis_customers.cust_id%type              -- Add 542
,p_inst_id               in   cis_installations.inst_id%type          -- Add 542
,p_tran_id               in   cis_transactions.tran_id%type           -- Add 542
,p_mesg_date             in   phl_report_messages.from_date%type
,p_acct_pay_method       in   cis_bill_lines.acct_pay_method%type
--,p_ebill_auto_pay_ind		 in 	phl_bill_print_hist.ebill_auto_pay_ind%type 	--Del 8020D --Add 9454
,p_ebill_auto_pay_ind		 in 	varchar2 																				--Add 8020D
,p_incid_code            in   cis_incidents.incid_code%type
,p_ppln_id               in   cis_bill_trans.ppln_id%type
,p_ppln_due_amnt         in   number
,p_dd_earliest_date      in   cis_transactions.dd_earliest_date%type  -- Add 542
,p_shutoff_date					 in   date												 -- Add 2775 and 2514
,p_estimates_cnt         in   cis_meter_regs.estimates_cnt%type       -- Add 542
,p_previous_balance_amnt in 	phl_bill_print_hist.previous_balance_amnt%type --Chg 3706 phl_tmg_bill_master.previous_balance_amnt%type    -- Add 542
,p_ppln_no_due           in   number                                  -- Add 542
,p_cust_own_reading_ind  in  	cis_reading_types.cust_own_reading_ind%type       -- Add 542
,p_est_reading_ind       in   cis_debit_lines.est_reading_ind%type
,p_sur_cst_fct_mssg		 	 in	  varchar2
,p_factor_message        in   varchar2                                        --Add 3706
,p_est_rev_messg			   in   varchar2 													--Add 2.0.0.2
,p_debt_bal_not_incl     in 	number
,p_bnkrptcy_bal_amnt_wat in 	number 												--Add 6495 If Active Bankruptcy Balance is greater than Zero, display message. If it's priority allows it.
--,p_debt_bal_grants		 in   number                                    --Del 3706
,p_fault_code            in   cis_debit_lines.fault_code%type
,p_sw_chg_fr_dt		       in   cis_debit_lines.period_from_date%type			--Chg 3659 --Add 2730
,p_sw_chg_to_dt		       in   cis_debit_lines.period_upto_date%type			--Chg 3659 --Add 2730
,p_nb_code		           in   cis_installations.revu1_code%type					--Add 2730
,p_debt_bal_amnt_ues     in   number                                    --Add 3706
,p_grnt_rcvd             in   number                                    --Add 3706
,p_pay_profile_code      in   cis_accounts.attribute15%type             --Add 3327
,p_pay_profile_code_orig in		cis_accounts.pay_profile_code%type				-- Add 9297B
,p_arrears_letter_no     in   cis_accounts.letter_no%type               --Add 4563
,p_un_paid_prv_bal       in   number                                    --Add 4563A
,p_tap_disc       			 in   number																		--Add 6971
,p_dispute_amnt				   in   number                                    --Add 7164
,p_agn_acct_opn_bal      in   number                                    --Add 7349
--,p_acct_id             in   number                                    --Add 4398  --We need to use it for Unwanted Lien Message
,p_ss_fee_mssg				   in   char																			--Add 7762
,p_round_key						 in   cis_rounds.round_key%type									--Add 9106
,p_outreader_type_code	 in		cis_meters.outreader_type_code%type		 	  --Add 9106
,p_pnlty_frgv_dt				 in   date																			--Add 9984
,p_pnlty_frgv_amnt 			 in   number																		--Add 9984
,p_prin_frgv_dt					 in   date																			--Add 9984
,p_prin_frgv_amnt 			 in   number																		--Add 9984
,p_tgt_dt								 in   date																			--Add 10495
,p_s17_grnt_amnt				 in   number                                    --Add 11413
,p_full_text_1           out  phl_bill_mssg_dtl.full_text%type          --Del 3706 phl_report_messages.full_text%type
,p_full_text_2           out  phl_bill_mssg_dtl.full_text%type          --Del 3706 phl_report_messages.full_text%type
,p_full_text_3           out  phl_bill_mssg_dtl.full_text%type          --Del 3706 phl_report_messages.full_text%type
,p_full_text_4           out  phl_bill_mssg_dtl.full_text%type          --Del 3706 phl_report_messages.full_text%type
,p_hdr_full_text_1       out  phl_bill_mssg_hdr.hdr_full_text%type      --Add 3706
,p_hdr_full_text_2       out  phl_bill_mssg_hdr.hdr_full_text%type      --Add 3706
,p_hdr_full_text_3       out  phl_bill_mssg_hdr.hdr_full_text%type      --Add 3706
,p_hdr_full_text_4       out  phl_bill_mssg_hdr.hdr_full_text%type      --Add 3706
)
is
		w_procedure_name              varchar2(40) := 'phls0005.get_billmssg';
begin
		w_label := 'e077';
		debug(w_procedure_name, w_label, ' w_message_trace_level :- ' || w_message_trace_level);
		-- Start of Parameter validation
		w_null_parameter_found := false;
		if p_cust_id is null                    -- Add 542
		or p_inst_id is null                    -- Add 542
		or p_tran_id is null then               -- Add 542
		  w_null_parameter_found := true;      -- Add 542
		end if;                                 -- Add 542
		if w_null_parameter_found or w_message_trace_level >= 5 then
		  debug(w_procedure_name, w_label, w_procedure_name);
		  --debug(w_procedure_name, w_label, '..p_cust_id         		=' || to_char(p_cust_id)					);
		  --debug(w_procedure_name, w_label, '..p_inst_id         		=' || to_char(p_inst_id)					);
		  --debug(w_procedure_name, w_label, '..p_tran_id         		=' || to_char(p_tran_id)					);
		  --debug(w_procedure_name, w_label, '..p_acct_pay_method 		=' || p_acct_pay_method						);
		  --debug(w_procedure_name, w_label, '..p_incid_code      		=' || p_incid_code							);
		  --debug(w_procedure_name, w_label, '..p_ppln_id         		=' || to_char(p_ppln_id)					);
		  --debug(w_procedure_name, w_label, '..p_ppln_due_amnt   		=' || to_char(p_ppln_due_amnt)			);
		  --debug(w_procedure_name, w_label, '..p_ppln_no_due     		=' || to_char(p_ppln_no_due)				);
		  --debug(w_procedure_name, w_label, '..p_estimates_cnt   		=' || to_char(p_estimates_cnt)			);
		  --debug(w_procedure_name, w_label, '..p_previous_balance_amnt	=' || to_char(p_previous_balance_amnt)	);
		  --debug(w_procedure_name, w_label, '..p_cust_own_reading_ind	=' || p_cust_own_reading_ind			);
		  --debug(w_procedure_name, w_label, '..p_mesg_date					=' || datec(p_mesg_date)				);
		  --debug(w_procedure_name, w_label, '..p_dd_earliest_date		=' || datec(p_dd_earliest_date)			);
		  --debug(w_procedure_name, w_label, '..p_est_reading_ind			=' || p_est_reading_ind					);
		  --debug(w_procedure_name, w_label, '..p_fault_code				=' || p_fault_code							);
		end if;
		--debug(w_procedure_name, w_label, ' 1. fnd_global.user_id :- ' || fnd_global.user_id);
		if w_null_parameter_found then
		  ciss0047.raise_exception (w_procedure_name, w_label, 'cis_internal_error', 'error',
		     'Null parameter supplied');
		end if;
		init;
		--ciss0074.trace(w_procedure_name, w_label, ' 2. w_message_trace_level :- ' || w_message_trace_level);
		--debug(w_procedure_name, w_label, ' 2. w_message_trace_level :- ' || w_message_trace_level);
		if not w_init_called then
		  ciss0047.raise_exception (w_procedure_name, w_label, 'cis_internal_error', 'error',
		    'ciss0079.init has not been called');
		end if;
		-- End of parameter validation
		w_label := 'e078';
		reset_vars;
		w_supply_type           							:= 'WATER';             -- Add 4398
		w_cust_id 			 											:= p_cust_id;           -- Add 542
		w_inst_id 			 											:= p_inst_id;           -- Add 542
		w_tran_id 			 											:= p_tran_id;           -- Add 542
		w_dd_earliest_date 										:= p_dd_earliest_date;  -- Add 542
		w_estimates_cnt    										:= p_estimates_cnt;     -- Add 542
		w_previous_balance_amnt 							:= p_previous_balance_amnt; -- Add 542
		w_ppln_no_due      										:= p_ppln_no_due;       -- Add 542
		w_cust_own_reading_ind 								:= p_cust_own_reading_ind; -- Add 542
		w_mesg_date             							:= p_mesg_date;
		w_acct_pay_method       							:= p_acct_pay_method;
		g_ebill_auto_pay_ind		 							:= trim(substr(p_ebill_auto_pay_ind,1,20)); 	--Chg 8020F [Length from 15 to 20] --Chng 8020D --Add 9454
		w_incid_code            							:= p_incid_code;
		w_ppln_id               							:= p_ppln_id;
		w_ppln_due_amnt         							:= p_ppln_due_amnt;
		w_est_reading_ind       							:= p_est_reading_ind;
		w_fault_code            							:= p_fault_code;
		w_sur_cst_fct_mssg       							:= p_sur_cst_fct_mssg;       --Add 2.0.0.1
		--w_est_rev_messg	       							:= p_est_rev_messg;		 	     --Del 3706 --Add 2.0.0.2
		w_debt_bal_not_incl      							:= p_debt_bal_not_incl;      --Add 2.0.0.1
		w_bnkrptcy_bal_amnt_wat  							:= p_bnkrptcy_bal_amnt_wat;  --Add 6495
		w_dispute_amnt												:= p_dispute_amnt; 			     --Add 7164
		--w_debt_bal_grants	      						:= p_debt_bal_grants; 	     --Del 3706		--Add 2.0.0.1
		w_debt_bal_amnt_ues       						:= p_debt_bal_amnt_ues;      --Add 3706
		w_shutoff_date		        						:= p_shutoff_date;           --Add 2775
		w_factor_message          						:= p_factor_message;         --Add 3706
		w_idx_msg_priority_99		  						:= 0;					       		     --Add 2.0.0.1
		w_label := 'e079';			                      								     --Add 2730
		w_sw_chg_fr_dt                       	:= p_sw_chg_fr_dt;		       --Chg 3659 -- Add 2730
		w_sw_chg_to_dt                       	:= p_sw_chg_to_dt;		       --Chg 3659 -- Add 2730
		w_nb_code                            	:= p_nb_code;		             --Add 2730
		w_pay_profile_code                   	:= p_pay_profile_code;       --Add 3327
		w_pay_profile_code_orig								:= p_pay_profile_code_orig;  --Add 9297B
		w_grnt_rcvd                          	:= p_grnt_rcvd;              --Add 3706
		w_arrears_letter_no                  	:= p_arrears_letter_no;      --Add 4563
		w_un_paid_prv_bal                    	:= p_un_paid_prv_bal;        --Add 4563A
		w_agn_acct_opn_bal									  := p_agn_acct_opn_bal;       --Add 7349
		w_ss_fee_mssg												  := p_ss_fee_mssg;            --Add 7762
		w_round_key														:= p_round_key;					     --Add 9106
		g_outreader_type_code									:= p_outreader_type_code;    --Add 9106
		--Start Add 9984
		g_pnlty_frgv_dt  											:= p_pnlty_frgv_dt;
		g_pnlty_frgv_amnt											:= p_pnlty_frgv_amnt;
		g_prin_frgv_dt   											:= p_prin_frgv_dt;
		g_prin_frgv_amnt 											:= p_prin_frgv_amnt;
		--End Add 9984
		g_tgt_dt											 				:= p_tgt_dt;							 		-- Add 10495
		g_s17_grnt_amnt												:= p_s17_grnt_amnt;           -- Add 11413
		--Start Add 6971
		if nvl(P_tap_disc,0) = 0 then
			w_tap_disc := null;
		else
			w_tap_disc := p_tap_disc;
		end if;
		--End Add 6971
		w_label := 'e080';
		--debug(w_procedure_name, w_label, '..Before calling set_bill_message' || w_debt_bal_grants);
		debug(w_procedure_name, w_label, '..w_sw_chg_fr_dt' || to_char(w_sw_chg_fr_dt,'MM/DD/YY'));
		set_bill_message;
		w_label := 'e081';
		debug(w_procedure_name, w_label, '..w_sort_mssg_tbl.count    =' || to_char(w_sort_mssg_tbl.count));
   if w_sort_mssg_tbl.count > 0 then
      get_message(
					   p_full_text_1     => p_full_text_1
					  ,p_full_text_2     => p_full_text_2
					  ,p_full_text_3     => p_full_text_3
					  ,p_full_text_4     => p_full_text_4
					  ,p_hdr_full_text_1 => p_hdr_full_text_1
					  ,p_hdr_full_text_2 => p_hdr_full_text_2
					  ,p_hdr_full_text_3 => p_hdr_full_text_3
					  ,p_hdr_full_text_4 => p_hdr_full_text_4
                 );
   else
      if w_message_trace_level >= 7 then
         debug(w_procedure_name, w_label, 'No Messages-->');
         debug(w_procedure_name, w_label, '..w_sort_mssg_tbl.count    =' || to_char(w_sort_mssg_tbl.count));
      end if;
   end if;
   --debug(w_procedure_name, w_label, 'p_full_text_1==>'|| p_full_text_1);
   --debug(w_procedure_name, w_label, 'p_full_text_2==>'|| p_full_text_2);
   --debug(w_procedure_name, w_label, 'p_full_text_3==>'|| p_full_text_3);
   --debug(w_procedure_name, w_label, 'p_full_text_4==>'|| p_full_text_4);
exception
   when deadlock_detected then
      raise deadlock_detected;
   when resource_busy then
      raise resource_busy;
   when dbp_fatal then
      raise dbp_fatal;
   when dbp_error then
      raise dbp_error;
   when others then
      ciss0047.raise_exception(w_procedure_name, w_label, 'cis_internal_error',
                               'error', sqlerrm, p_severity=>'F');
end get_billmssg;
/* Start Add 4398 */
procedure get_helploanmssg
(
 p_cust_id               in  cis_customers.cust_id%type
,p_inst_id               in  cis_installations.inst_id%type
,p_mesg_date             in  phl_report_messages.from_date%type
,p_hl_ppln_id            in  cis_bill_trans.ppln_id%type
,p_hl_ppln_due_amnt      in  number
,p_hl_curr_std_ppln      in  cis_payment_plans.std_ppln%type
--,p_hl_curr_ppln_status   in  cis_payment_plans.ppln_status%type
,p_hl_superseded         in  boolean
,p_hl_curr_ppln_tot_amnt in  number
,p_hl_curr_ppln_bal_amnt in  number
,p_hl_ppln_no_due        in  number
,p_hl_curr_due_amnt      in  number
,p_hl_5th_fpg_inv_desc   in  phl_agrv_rc_hlpln_st_dtl.agrv_hl_5th_inv_desc%type
,p_hl_4th_fpg_inv_desc   in  phl_agrv_rc_hlpln_st_dtl.agrv_hl_4th_inv_desc%type
,p_hl_3rd_fpg_inv_desc   in  phl_agrv_rc_hlpln_st_dtl.agrv_hl_3rd_inv_desc%type
,p_hl_2nd_fpg_inv_desc   in  phl_agrv_rc_hlpln_st_dtl.agrv_hl_2nd_inv_desc%type
,p_hl_full_text_1        out phl_agrv_rc_hlpln_st_dtl.agrv_hl_mssg1_dtl%type
,p_hl_full_text_2        out phl_agrv_rc_hlpln_st_dtl.agrv_hl_mssg2_dtl%type
,p_hl_full_text_3        out phl_agrv_rc_hlpln_st_dtl.agrv_hl_mssg3_dtl%type
,p_hl_full_text_4        out phl_agrv_rc_hlpln_st_dtl.agrv_hl_mssg4_dtl%type
,p_hl_hdr_full_text_1    out phl_agrv_rc_hlpln_st_dtl.agrv_hl_mssg1_hdr%type
,p_hl_hdr_full_text_2    out phl_agrv_rc_hlpln_st_dtl.agrv_hl_mssg2_hdr%type
,p_hl_hdr_full_text_3    out phl_agrv_rc_hlpln_st_dtl.agrv_hl_mssg3_hdr%type
,p_hl_hdr_full_text_4    out phl_agrv_rc_hlpln_st_dtl.agrv_hl_mssg4_hdr%type
)is
   w_procedure_name              varchar2(40) := 'phls0005.get_helploanmssg';
begin
   w_label := 'e082';
   debug(w_procedure_name, w_label, ' w_message_trace_level :- ' || w_message_trace_level);
   -- Start of Parameter validation
   w_null_parameter_found := false;
   if p_cust_id is null
   or p_inst_id is null then
      w_null_parameter_found := true;
   end if;
   if w_null_parameter_found or w_message_trace_level >= 5 then
     debug(w_procedure_name, w_label, w_procedure_name);
     debug(w_procedure_name, w_label, '..p_cust_id     =' || to_char(p_cust_id));
     debug(w_procedure_name, w_label, '..p_inst_id     =' || to_char(p_inst_id));
     debug(w_procedure_name, w_label, '..w_supply_type =' || w_supply_type);
     debug(w_procedure_name, w_label, '..p_hl_ppln_id  =' || to_char(p_hl_ppln_id));
     debug(w_procedure_name, w_label, '..p_hl_ppln_due_amnt =' || to_char(p_hl_ppln_due_amnt));
     debug(w_procedure_name, w_label, '..p_mesg_date	  =' || datec(p_mesg_date));
   end if;
   --debug(w_procedure_name, w_label, ' 1. fnd_global.user_id :- ' || fnd_global.user_id);
   if w_null_parameter_found then
      ciss0047.raise_exception (w_procedure_name, w_label, 'cis_internal_error', 'error','Null parameter supplied');
   end if;
	init;
	--ciss0074.trace(w_procedure_name, w_label, ' 2. w_message_trace_level :- ' || w_message_trace_level);
   --debug(w_procedure_name, w_label, ' 2. w_message_trace_level :- ' || w_message_trace_level);
   if not w_init_called then
      ciss0047.raise_exception (w_procedure_name, w_label, 'cis_internal_error', 'error',
        'ciss0079.init has not been called');
   end if;
   -- End of parameter validation
   w_label := 'e083';
   reset_vars;
   debug(w_procedure_name, w_label, ' After reset_vars :- ');
   debug(w_procedure_name, w_label, ' p_mesg_date :- ' || to_char(p_mesg_date,'MM/DD/YYYY'));
   w_label := 'e084';
   w_supply_type 			 	 := 'HELPLOAN';
   w_cust_id 			 		 := p_cust_id;
   w_inst_id 			 		 := p_inst_id;
   w_mesg_date              := p_mesg_date;
   w_hl_ppln_id             := p_hl_ppln_id;
   w_hl_ppln_due_amnt       := p_hl_ppln_due_amnt;
   w_hl_ppln_no_due         := p_hl_ppln_no_due;
   w_hl_cure_amnt           := p_hl_curr_due_amnt;
   w_hl_superseded          := p_hl_superseded;
   --w_hl_std_ppln            := p_hl_std_ppln;
   w_hl_curr_std_ppln       := p_hl_curr_std_ppln;
   --w_hl_ppln_status         := p_hl_ppln_status;
   --w_hl_curr_ppln_status    := p_hl_curr_ppln_status;
   --w_hl_ppln_tot_amnt       := p_hl_ppln_tot_amnt;
   w_hl_curr_ppln_tot_amnt  := p_hl_curr_ppln_tot_amnt;
   w_hl_curr_ppln_bal_amnt  := p_hl_curr_ppln_bal_amnt;
   w_label := 'e085';
   debug(w_procedure_name, w_label, ' p_mesg_date :- ' || to_char(p_mesg_date,'MM/DD/YYYY'));
   debug(w_procedure_name, w_label, ' w_cust_id 		 :- ' || w_cust_id 		);
   debug(w_procedure_name, w_label, ' w_inst_id 		 :- ' || w_inst_id 		);
   debug(w_procedure_name, w_label, ' w_ppln_id        :- ' || w_hl_ppln_id      );
   debug(w_procedure_name, w_label, ' w_ppln_due_amnt  :- ' || w_hl_ppln_due_amnt);
   w_hl_5th_fpg_inv_desc    := p_hl_5th_fpg_inv_desc;
   w_hl_4th_fpg_inv_desc    := p_hl_4th_fpg_inv_desc;
   w_hl_3rd_fpg_inv_desc    := p_hl_3rd_fpg_inv_desc;
   w_hl_2nd_fpg_inv_desc    := p_hl_2nd_fpg_inv_desc;
   w_label := 'e086';
   debug(w_procedure_name, w_label, ' w_hl_5th_fpg_inv_desc :- ' || w_hl_5th_fpg_inv_desc);
   debug(w_procedure_name, w_label, ' w_hl_4th_fpg_inv_desc :- ' || w_hl_4th_fpg_inv_desc);
   debug(w_procedure_name, w_label, ' w_hl_3rd_fpg_inv_desc :- ' || w_hl_3rd_fpg_inv_desc);
   debug(w_procedure_name, w_label, ' w_hl_2nd_fpg_inv_desc :- ' || w_hl_2nd_fpg_inv_desc);
   w_label := 'e087';
   debug(w_procedure_name, w_label, ' Before set_bill-messsage :- ');
   set_bill_message;
   w_label := 'e088';
   if w_sort_mssg_tbl.count > 0 then
      get_message(
					   p_full_text_1     => p_hl_full_text_1
					  ,p_full_text_2     => p_hl_full_text_2
					  ,p_full_text_3     => p_hl_full_text_3
					  ,p_full_text_4     => p_hl_full_text_4
					  ,p_hdr_full_text_1 => p_hl_hdr_full_text_1
					  ,p_hdr_full_text_2 => p_hl_hdr_full_text_2
					  ,p_hdr_full_text_3 => p_hl_hdr_full_text_3
					  ,p_hdr_full_text_4 => p_hl_hdr_full_text_4
                 );
   else
      if w_message_trace_level >= 7 then
         debug(w_procedure_name, w_label, 'No Messages-->');
         debug(w_procedure_name, w_label, '..w_sort_mssg_tbl.count    =' || to_char(w_sort_mssg_tbl.count));
      end if;
   end if;
end get_helploanmssg;
/* End Add 4398 */
end phls0005;
