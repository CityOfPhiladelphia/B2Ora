create or replace
PACKAGE        "PHLS0005" as
/*
TO Replace blank lines in files using perl regular expression  in ULTRA edit
^(?:[\t ]*(?:\r?\n|\r))+
In Ultra edit go to advance --> Search --> Regular Expresion Engine and Select Perl Compatiable Regular Expresion
In Actual Find/Replace window select above string and replace it with nothing (also select regular expresion check box)
*/
/*
**  This report message handling package
**  The package can decide which if any message an account requires for a given message type
**
            w_version         varchar2(20) := '3.0.0.22';  -- MUST MATCH LATEST 'VERS' IN HISTORY BELOW!
**
**  BUG       WHO   VERS      MM/DD/YYYY   Description
** 11413      RNN   3.0.0.22  02/01/2022   LIHWAP (Low Income Household Water Assistance Program) basis2 changes. 
** 10495      RNN   3.0.0.21  01/05/2021   AMI eBilling: basis2 bill messages
** 9984       RNN   3.0.0.20  07/21/2020   TAP: Sept. 1, 2020 principal forgiveness updates to bills
** 9106       RNN   3.0.0.19  03/03/2020   AMI project: billing messages for deployment of Sensus devices
** 8020D      RNN   3.0.0.18  07/20/2019   Make the body of the Kubra auto pay bill message dynamic.
** 9454      	RNN   3.0.0.17  07/14/2019   Kubra auto pay paper bills go into ZipCheck bill files for mail room and AutoPay Messages
** 9297B      RNN   3.0.0.10  06/08/2019   Add Tap Bill messages
** 7762       RNN   3.0.0.09  01/18/2019   Add bill message for customers who are charged Sheriff Sale fees and expenses
** 7349       RNN   3.0.0.08  01/31/2018   Agency debt (but not meters): to be liened quarterly at any amount
** 7164       RNN   3.0.0.07  10/12/2017   Remove dispute amount from please pay and display dispute message on bill.
** 6971				RNN   3.0.0.06  08/03/2017   LIEN MESSAGE ON TAP BILLS.
** 6495       RNN   3.0.0.05  04/24/2017   Add bankruptcy message to bills
** 4398       RNN   3.0.0.04  03/02/2016   New Messages for Help Loan
** 4563A      RNN   3.0.0.03  07/15/2015   Modidied the message conditions for Message_Num 77
** 3659       RNN   3.0.0.02  09/08/2014   New Bill Design
** 3706       RNN   3.0.0.01  08/27/2014   New Bill Design -- Change
*/
   w_ref_data_loaded             boolean := false;
   w_message_trace_level         pls_integer := 0;
   w_get_billmssg_type            varchar2(8) := 'BILLMSSG';
   w_get_bonwdrop_type           varchar2(8) := 'BONWDROP';
--   w_get_bovermtr_type           varchar2(8) := 'BOVERMTR';     -- Del PJT
   w_get_bovermtr_type           varchar2(8) := 'BILLMSSG';       -- Add PJT
   w_get_pyagremd_type           varchar2(8) := 'PYAGREMD';
   w_get_pyagshut_type           varchar2(8) := 'PYAGSHUT';
   w_shutoff_code                varchar2(8) := 'SHUT-OFF';
-- Accepted message replacement tokens
-- A fixed set of string replacement keys are supported
-- The full name of the string varaible plus the ampersand indicates
-- the number of characters that will be replaced.
-- TOKEN             CHARS  MEANING
-- DUE_AGREE_AMNT   15     Amount overdue on a payment plan for the current bill
   w_token_due_agree_amnt      varchar2(15) := chr(38) || 'due_agree_amnt';
-- DD_DATE           8     Date DD scheduled to be paid.
   w_dd_date                   varchar2(15) := chr(38) || 'dd_date';
   gp_tkn_key_auto_pay_str1		 varchar2(15) := chr(38) || 'str_b2_cd1';	 --Add 8020D
   gp_tkn_key_auto_pay_str2		 varchar2(15) := chr(38) || 'str_b2_cd2';	 --Add 8020D
   gp_tkn_key_auto_pay_str3		 varchar2(15) := chr(38) || 'str_b2_cd3';	 --Add 8020D
-- SHUTOFF DATE      15    Date Amount overdue on a payment plan for the current bill
   w_token_shutoff_date        varchar2(15) := chr(38) || 'shut_date';
-- Payment due Amount which not included in the balance but can be due any time in future.
   w_token_pymt_due_amnt       		varchar2(15) := chr(38) || 'pymt_due_amnt';
-- We are awaiting for a grant payment of GRANT_AMNT.
   w_token_grant_amnt          		varchar2(15) := chr(38) || 'grant_amnt';
-- From Date                              -- Add 2730
	 --Start Add 9984
	 gp_pnlty_frgv_dt_str						varchar2(15) := chr(38) || 'tpen_frgv_dt';
	 gp_pnlty_frgv_amnt_str					varchar2(15) := chr(38) || 'tpen_frgv_amt';
	 gp_prin_frgv_dt_str            varchar2(15) := chr(38) || 'tprn_frgv_dt';
	 gp_prin_frgv_amnt_str					varchar2(15) := chr(38) || 'tprn_frgv_amnt';
	 --End Add 9984
	 --Start Add 10495
	 gp_tgt_dt_str  								varchar2(15) := chr(38) || 'tgt_dt';
	 --End Add 10495
   gp_s17_grnt_amnt_str						varchar2(15) := chr(38) || 'lihwap_grnt';		-- Add 11413	
   
   w_period_date               		varchar2(15) := chr(38) || 'period_date';   -- Add 2730
   w_token_hdr_grant_name      		varchar2(15) := chr(38) || 'grant_name';    -- Add 3706
   w_token_hl_curr_ppln_tot_amnt 	varchar2(15) := chr(38) || 'cur_tot_amnt';  -- Add 4398
   w_token_hl_curr_ppln_bal_amnt 	varchar2(15) := chr(38) || 'cur_bal_amnt';  -- Add 4398
   w_token_hl_cure_amnt          	varchar2(15) := chr(38) || 'cure_amnt';     -- Add 4398
   w_prio_multi                		number := 1000;  --Add 3327b/3338
   w_num_chr_per_line          		number := 53;    --Chg 3706 from 90 to 53   -- Add 3352
   w_tot_lines_per_bill        		number := 12;    --Chg 3706 from  9 to  12  -- Add 3352
   gp_ttid_5									 		varchar2(20) := '9106';                     -- Add 9106
   
function get_version return varchar2;
procedure init;
procedure get_billmssg  (
 p_cust_id               in   cis_customers.cust_id%type                        -- Add 542
,p_inst_id               in   cis_installations.inst_id%type                    -- Add 542
,p_tran_id               in   cis_transactions.tran_id%type                     -- Add 542
,p_mesg_date             in   phl_report_messages.from_date%type
,p_acct_pay_method       in   cis_bill_lines.acct_pay_method%type
--,p_ebill_auto_pay_ind		 in 	phl_bill_print_hist.ebill_auto_pay_ind%type 			--Del 8020D Add 9454
,p_ebill_auto_pay_ind		 in 	varchar2 																					--Add 8020D
,p_incid_code            in   cis_incidents.incid_code%type
,p_ppln_id               in   cis_bill_trans.ppln_id%type
,p_ppln_due_amnt         in   number
,p_dd_earliest_date      in   cis_transactions.dd_earliest_date%type            --Add 542
,p_shutoff_date			 		 in   date												           --Add 2775
,p_estimates_cnt         in   cis_meter_regs.estimates_cnt%type                 --Add 542
,p_previous_balance_amnt in 	phl_bill_print_hist.previous_balance_amnt%type    --Chg 3706 phl_tmg_bill_master.previous_balance_amnt%type    --Add 542
,p_ppln_no_due           in   number                                            --Add 542
,p_cust_own_reading_ind  in  	cis_reading_types.cust_own_reading_ind%type       --Add 542
,p_est_reading_ind       in   cis_debit_lines.est_reading_ind%type
,p_sur_cst_fct_mssg		 	 in	varchar2														  					--Add 2.0.0.1
,p_factor_message        in   varchar2                                      --Add 3706
,p_est_rev_messg			 	 in   varchar2 													  					--Add 2.0.0.2
,p_debt_bal_not_incl     in 	number 													     					--Add 2.0.0.1
,p_bnkrptcy_bal_amnt_wat in 	number 													     					--Add 6495 If Active Bankruptcy Balance is greater than Zero, display message.
--,p_debt_bal_grants		 in   number                                        --Add 3706
,p_fault_code            in   cis_debit_lines.fault_code%type
,p_sw_chg_fr_dt		    	 in   cis_debit_lines.period_from_date%type		      --Chg 3659 -- Add 2730
,p_sw_chg_to_dt		    	 in   cis_debit_lines.period_upto_date%type		      --Chg 3659 -- Add 2730
,p_nb_code		           in   cis_installations.revu1_code%type			        --Add 2730
,p_debt_bal_amnt_ues     in   number                                        --Add 3706
,p_grnt_rcvd             in   number                                        --Add 3706
,p_pay_profile_code      in   cis_accounts.attribute15%type                 --Add 3327
,p_pay_profile_code_orig in   cis_accounts.pay_profile_code%type			 			--Add 9297B
,p_arrears_letter_no     in   cis_accounts.letter_no%type                   --Add 4563
,p_un_paid_prv_bal       in   number                                        --Add 4563A
,p_tap_disc       			 in   number																		 		--Add 6971
,p_dispute_amnt				   in   number                                    		--Add 7164
,p_agn_acct_opn_bal      in   number 																				--Add 7349
,p_ss_fee_mssg				   in   char																					--Add 7762
,p_round_key						 in   cis_rounds.round_key%type											--Add 9106
,p_outreader_type_code	 in		cis_meters.outreader_type_code%type		 	  		--Add 9106
,p_pnlty_frgv_dt				 in   date																					--Add 9984
,p_pnlty_frgv_amnt 			 in   number																				--Add 9984
,p_prin_frgv_dt					 in   date																					--Add 9984
,p_prin_frgv_amnt 			 in   number																				--Add 9984
,p_tgt_dt								 in   date																					--Add 10495
,p_s17_grnt_amnt				 in   number                                        --Add 11413
,p_full_text_1           out  phl_bill_mssg_dtl.full_text%type              --chg 3706--phl_report_messages.full_text%type
,p_full_text_2           out  phl_bill_mssg_dtl.full_text%type              --chg 3706--phl_report_messages.full_text%type
,p_full_text_3           out  phl_bill_mssg_dtl.full_text%type              --chg 3706--phl_report_messages.full_text%type
,p_full_text_4           out  phl_bill_mssg_dtl.full_text%type              --chg 3706--phl_report_messages.full_text%type
,p_hdr_full_text_1       out  phl_bill_mssg_hdr.hdr_full_text%type          --Add 3706
,p_hdr_full_text_2       out  phl_bill_mssg_hdr.hdr_full_text%type          --Add 3706
,p_hdr_full_text_3       out  phl_bill_mssg_hdr.hdr_full_text%type          --Add 3706
,p_hdr_full_text_4       out  phl_bill_mssg_hdr.hdr_full_text%type          --Add 3706
);
/* Start Add 4398 */
procedure get_helploanmssg
(
 p_cust_id                    in   cis_customers.cust_id%type
,p_inst_id                    in   cis_installations.inst_id%type
,p_mesg_date                  in   phl_report_messages.from_date%type
,p_hl_ppln_id                 in   cis_bill_trans.ppln_id%type
,p_hl_ppln_due_amnt           in   number
,p_hl_curr_std_ppln           in   cis_payment_plans.std_ppln%type
--,p_hl_curr_ppln_status        in   cis_payment_plans.ppln_status%type
,p_hl_superseded              in   boolean
,p_hl_curr_ppln_tot_amnt      in   number
,p_hl_curr_ppln_bal_amnt      in   number
,p_hl_ppln_no_due             in   number
,p_hl_curr_due_amnt           in   number
,p_hl_5th_fpg_inv_desc        in   phl_agrv_rc_hlpln_st_dtl.agrv_hl_5th_inv_desc%type
,p_hl_4th_fpg_inv_desc        in   phl_agrv_rc_hlpln_st_dtl.agrv_hl_4th_inv_desc%type
,p_hl_3rd_fpg_inv_desc        in   phl_agrv_rc_hlpln_st_dtl.agrv_hl_3rd_inv_desc%type
,p_hl_2nd_fpg_inv_desc        in   phl_agrv_rc_hlpln_st_dtl.agrv_hl_2nd_inv_desc%type
,p_hl_full_text_1             out  phl_agrv_rc_hlpln_st_dtl.agrv_hl_mssg1_dtl%type
,p_hl_full_text_2             out  phl_agrv_rc_hlpln_st_dtl.agrv_hl_mssg2_dtl%type
,p_hl_full_text_3             out  phl_agrv_rc_hlpln_st_dtl.agrv_hl_mssg3_dtl%type
,p_hl_full_text_4             out  phl_agrv_rc_hlpln_st_dtl.agrv_hl_mssg4_dtl%type
,p_hl_hdr_full_text_1         out  phl_agrv_rc_hlpln_st_dtl.agrv_hl_mssg1_hdr%type
,p_hl_hdr_full_text_2         out  phl_agrv_rc_hlpln_st_dtl.agrv_hl_mssg2_hdr%type
,p_hl_hdr_full_text_3         out  phl_agrv_rc_hlpln_st_dtl.agrv_hl_mssg3_hdr%type
,p_hl_hdr_full_text_4         out  phl_agrv_rc_hlpln_st_dtl.agrv_hl_mssg4_hdr%type
);
/* End Add 4398 */
end phls0005;
