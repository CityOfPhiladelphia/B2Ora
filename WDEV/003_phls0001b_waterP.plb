create or replace 
package body phls0001 as
/*
--testing for .gitignore
-- CREATE OR REPLACE
-- PACKAGE BODY PHLS0001 as
TO Replace blank lines in files using perl regular expression in ULTRA edit
^(?:[\t ]*(?:\r?\n|\r))+
Advanced --> Configuration -->Regular Expression Engine
In Replace window use Check Regular Expression
*/
/*
** NAME        phls0001
**
** copyright (c) 2006 Prophecy International Pty Ltd, Adelaide, Australia
**
** FILENAME    phls0001B.pls
**
** DESCRIPTION
**    Procedures for PHL bill data collation package
**
**    Functional Dependencies
**    [1] ePay
**    [2] PayAdvice
**    [3] Shutoff Bill
**    [4] Payment Agreements
**    [5] Batch Bill Print
**    [6] Penalties (Optional)
**
**    PROCEDURES, FUNCTIONS
**       function  get_version
**       procedure local_testing
**       procedure trace_label
**       procedure debug_trace
**       procedure debug
**       function  datefullc
**       function  datec
**       function  booleanc
**       procedure load_ref_data
**       procedure init
**       procedure reset
**       procedure get_check_digit
**       procedure scan_string
**       procedure ins_phl_tmg_shutoffnotice
**       procedure collate P_ACCOUNT
**       procedure bg_shut_off_print_string
**       procedure scan_string_shut_off
**       procedure get_shut_off_details
**       procedure assemble_shut_off
**       procedure get_plan_details
**       procedure scan_string_down_payment
**       procedure inst_phl_tmg_down_pay_bill
**       procedure assemble_down_payment
**       procedure inst_phl_tmg_pay_advice
**       procedure get_pay_advice_details
**       procedure scan_string_pay_advice
**       procedure assemble_pay_advice
**       function  scan_string_return_check
**       function  scan_string_group_bill
**       procedure collate
**       procedure performance_statistics
**       procedure background_print_headings
**       procedure background_print_string
**       procedure insert_report_record
**       procedure set_one_bill
**       procedure check_city_suffix
**       procedure get_graph_xaxis
**       procedure get_next_reading_date
**       procedure get_bill_lines
**       procedure am5d(p_msg varchar2)
**       procedure load_holidays
**       function  next_valid_due_date
**
**
**/
    w_version                  varchar2(20) := '3.0.0.96'; -- MUST MATCH LATEST 'VERS' IN HISTORY BELOW!
 --   w_version                     varchar2(20) := '2.0.0.86'; -- MUST MATCH LATEST 'VERS' IN HISTORY BELOW!
 --   w_version                     varchar2(20) := '1.0.0.72';  -- must match latest 'vers' in history below!
/**
**  BUG#           BY   VERS       MM/DD/YYYY   Description
**  11413A         RNN  3.0.0.96   01/31/2021   LIHWAP (Low Income Household Water Assistance Program) basis2 changes. 
**  11137          RNN  3.0.0.95   02/01/2022   Phone number in “two estimated bills in a row” message on the bill will need to be changed 
**  11413          RNN  3.0.0.94   01/31/2021   LIHWAP (Low Income Household Water Assistance Program) basis2 changes. 
**  10483					 RNN  3.0.0.93   10/18/2021   eBilling: Adjust Pending Payment Window from 10 to 20 days.
**  11192          RNN  3.0.0.92   06/24/2021   AMI eBilling: basis2 bill messages appearing on bills prematurely.
--**  10300          RNN  3.0.0.89   06/02/2020   Bill print fails when 3rd Party addesses link to account are NULL.--Solve later when it fails
**  11138          RNN  3.0.0.91   05/21/2021   AMI bill messages appearing on accounts with AMI devices
**  10495          RNN  3.0.0.90   01/05/2021   AMI eBilling: basis2 bill messages
**  10846          RNN  3.0.0.89   11/13/2020   HELP Loan and AGENCY auto pay amounts not deducted starting August 29th
**  9984B          RNN  3.0.0.88   07/20/2020   After changes made by Leena to PHLST007
**  9249LN         LNC  3.0.0.87   07/26/2020   Changes for principal forgiveness in bill print r_tap_bill_print
**  9984           RNN  3.0.0.86   07/20/2020   TAP: Sept. 1, 2020 principal forgiveness updates to bills
**  9792           RNN  3.0.0.85   04/23/2020   Do not unallocate payments from disputed transactions
**  10266          RNN  3.0.0.84   03/24/2020   Bill print performance
**  10212          RNN  3.0.0.83   03/04/2020   Agency Invoices not shown on Bill
**  9106 					 RNN  3.0.0.82   02/23/2020   Bill print: performance issue after code promotion on August 1st.
**  9918c          RNN  3.0.0.81   02/04/2020   Bill print and eBilling report is taking long time, Change pending payment to look for 10 calendar days.
**  10108					 RNN  3.0.0.80   01/27/2020   LOOT indicator loigc is incorrect in KUBRA materelized view
**  9918b          RNN  3.0.0.79   01/10/2020   eBilling: Auto Pay payment amount issue
**  9918           RNN  3.0.0.78   11/18/2019   eBilling: Auto Pay payment amount issue
**  9749           RNN  3.0.0.77   11/14/2019   Delete the code TAP: Create TAP liens, link lien fees to TAPHLD DCRs
**  9695					 RNN  3.0.0.76   09/10/2019   Set 3rd Party Bills to paper only.
**  8936					 LAC  3.0.0.75   08/28/2019   Mod get_shut_off_details to exclude TAP dbcls from shutoff amounts.
**  9620 				   RNN  3.0.0.74   08/12/2019   Bill Performance avoid using fnd_file.put_line
**  8020F/9570     RNN  3.0.0.73	 08/01/2019		Introduce DUP_IND and fix AUTO_PAY_IND dynamic messages	(duplicate, rebill, final bill is a special bill so it will be only R and D)
**  8020D          RNN  3.0.0.72   07/14/2019   Make the body of the Kubra auto pay bill message dynamic.
**  9454           RNN  3.0.0.71   07/14/2019   Kubra auto pay paper bills go into ZipCheck bill files for mail room
**  8020B					 RNN  3.0.0.70   07/08/2019   Add LOOT Indicator to control file
**  9297B          RNN  3.0.0.69   06/08/2019   TAP BILL Messages
**  8020           RNN  3.0.0.68   02/27/2019   Flag water bills for print (add indicator to Basis2 and bill text file) and other fields
**  9146					 RNN  3.0.0.67   04/12/2019   Incorrect Charity Discount on the bill
**  7080           RNN  3.0.0.66   01/24/2019   Shutoff bill
**  7762           RNN  3.0.0.65   01/18/2019   Add bill message for customers who are charged Sheriff Sale fees and expenses
**  8616A          LAC  3.0.0.64   12/07/2018   Mod wait in get_shut_off_details to recount shut-reqs not yet processed
**  8616           PJT  3.0.0.63   12/07/2018   Remove SHUTCST2
**                                              Change shutoff message
**  8000_8044      RNN  3.0.0.62   06/04/2018   Bill contained incorrect lines already covered by a payment plan -- Customer without Sr. Citizen discount has discount appear on bill for positive amount
**  7349           RNN  3.0.0.61   01/30/2018   Agency debt (but not meters): to be liened quarterly at any amount
**  7790           RNN  3.0.0.60   03/14/2018   TAP amount towards account balance and Tap monthly charge are incorrect
**  7769           RNN  3.0.0.59   03/09/2018   Previous TAP balance is shown on non TAP accounts.
**  7164D          RNN  3.0.0.58   12/22/2018   Put disput code back in, disput amounts should be removed from please pay and Previous unpaid TAP balance [PreTAP Dispute Balnaces balances].
**  7164C          RNN  3.0.0.57   11/21/2017   revert the disput code, disput amounts should not be removed from please pay and Previous unpaid TAP balance.
**  7164B          RNN  3.0.0.56   11/16/2017   Remove dispute amount from Payment Agreement Due.
**  7164A          RNN  3.0.0.56   11/16/2017   Remove dispute amount from Payment Agreement Due.
**  7281           RNN  3.0.0.55   10/26/2017   Previous Unpaid TAP Balance is incorrectly calculated on some bills
**  7176           RNN  3.0.0.54   09/25/2017   Split TAP and SCD as two line items.
**  7164           RNN  3.0.0.53   09/25/2017   Remove dispute amount from please pay.
**  6929           RNN  3.0.0.52   08/25/2017   Penalties are added twice in Agreement Amount Due
**  7055           RNN  3.0.0.51   08/25/2017   Bill print changes for new definitions of groups 1 and 2
**  7047           RNN  3.0.0.50   08/22/2017   SHUTOFF bills are failing if adderss line > 29 chrs
**  6971           RNN  3.0.0.49   08/03/2017   LIEN MESSAGE ON TAP BILLS.
**  6721           RNN  3.0.0.48   06/14/2017   Add new line to bill for Total Unpaid Previous Charges for TAP customers
**  6230B          RNN  3.0.0.47   06/08/2017   Senior Citizen discount should be zero and added to TAP Discount. Beside the LienFees and Late Payment Fees should be added to Agreement Amount.
**  6230A          RNN  3.0.0.46   05/24/2017   TAPHLD amount should be removed from the Please Pay balance
**  5828           CB3  3.0.0.45   05/03/2017   There was a request to create a duplicate Shut Off Bill which will
**                                              be sent to the service address in the event the property address and
**                                              mailing address are different. Currently, the Shut Off Bill is being
**                                              sent to the mailing address or essentially the owner. There was a request to
**                                              send this Shut Off Bill to the property address where the Tenant/Occupant
**                                              may reside. The information on this duplicate bill essentially will be the same
**                                              as the original bill. The only information that will change will be the mailing name and the
**                                              mailing address. The mailing name will be replaced by the wording "OWNER/OCCUPANT"
**                                              and the mailing address will be replaced by the service address.
**  5828           CB3  3.0.0.44   05/03/2017   After some testing in the "WQA" environment and the printing of the Shut Off Bill
**                                              with the duplicate copy, there was an observation that some of the bills were
**                                              not printing the owner name or service address and in some cases both. In the
**                                              routine "GET_SHUT_OFF_DETAILS", when the owner name is generated there is some
**                                              coding which is logically flawed. The determination of the owner name is based
**                                              on a comparison of the owner name with the mailing name which is derived from
**                                              the addresss table under the address style of "MISTY". Now when this comparison
**                                              is made and mailing name has null values then the owner name is compared against
**                                              itself with a relational operator of not equal. This condition will never be
**                                              met with a mailing name of null values therefore the owner name will never get
**                                              populated. Now further down in the code where the service address is being retrieved
**                                              this may or may not occur depending on whether the owner name has been populated or
**                                              there is a mailing address. If there is no customer name or there is no mailing
**                                              address then the customer name plus service address will not be populated. If there
**                                              is no customer name and there is a mailing address then the customer name
**                                              will not be populated however the service address will be populated. The best way to
**                                              resolve this is by adding an "else" condition to populate the owner name when the
**                                              mailing name does not exist or the mailing name equals the owner name.
**  6495           RNN  3.0.0.42   04/24/2017   Add bankruptcy message to bills
**  6230           RNN  3.0.0.41   03/16/2017   TAP changes
**  6351           RNN  3.0.0.40   03/07/2017   Opening/Closing balances were incorrect in database.
**  5905           RNN  3.0.0.39   12/29/2016   Do not include Bankruptcy in AGENCY / HELPLOAN Bills
**  6130           RNN  3.0.0.38   12/14/2016   WATER1_ACCT Not proper on the bills.
**  6045           RNN  3.0.0.37   11/21/2016   67th character always should be zero when it is not water 1 account (scan type)..
**  5598           RNN  3.0.0.36   11/07/2016   Generic Scan lien not converting water alphanumeric to numeric.
**  5869           RNN  3.0.0.35   10/03/2016   Check digit on payment coupon scan line is incorrect
**  5659           LAC  3.0.0.34   08/10/2016   Fix 3rd party Shutoff Notices (4956)
**  5609           RNN  3.0.0.33   07/25/2016   Bill showing credit balance instead of actual debit balance of account.
**  4956           GAL  3.0.0.32   06/21/2016   Cater for 3rd party interest Shutoff Notices
**  5247           RNN  3.0.0.31   04/09/2016   UESF grant amount on bill includes a grant that was already paid in 2012
**  4614           PJT  3.0.0.29X1 01/29/2016   Changes for third party bills
**  4398           RNN  3.0.0.30   11/08/2015   Agency Repair Charge / Help Loan Changes.
**  4723           SG   3.0.0.29   08/05/2015   Payment Agreement Report "Due Date" falls on the Weekend
**  4575           RNN  3.0.0.28   09/10/2015   New Bill: "Unpaid" Balance Description
**  4608           RNN  3.0.0.27   08/27/2015   New Bill 2015: Return Current Charge line to bills
**  4779           RNN  3.0.0.26   08/26/2015   Change Next Due Date for Consecutive Holidays
**  4563A          RNN  3.0.0.25   07/16/2015   Past Due Balance: - Bill Message showing even if the account balance is Zero
**  3305           RNN  3.0.0.24   07/10/2015   Automate printing of payment agreements, Correcting the WATER1Acct# for AlphaNumeric A/cs.
**  4561           RNN  3.0.0.23   07/07/2015   Meter Group: readings do not match when there is a meter rotate.
**  4578           RNN  3.0.0.22   05/14/2015   Storm water Charge dotted line printed when is sholdn't have.
--**4560           RNN  3.0.0.21   05/14/2015   Meter Group: readings do not match when there is a meter rotate.
**  4563           RNN  3.0.0.20   05/04/2015   Add Delinquent Message on the new bill.
**  4562           RNN  3.0.0.19   05/04/2015   The graph should indicate the read month not the billed month.
**  4560           RNN  3.0.0.18   05/07/2015   Meter read does not match graph on new bills.
**  4385A          SG   3.0.0.17   03/04/2015   Fixed Issue with PHLR0286 not showing the accurate back debt amount
**  4419           RNN  3.0.0.16   05/04/2015   If most recent two bills are estimated, display message on bills.
**  4385           RNN  3.0.0.15   03/04/2015   Update payment agreement document to match new total payment agreement amount on new bills
**  4084           RNN  3.0.0.14   10/22/2014   Display of information on bill not quite right. The usage is not displayed properly, portion of usage is displayed as Senior Service Charge.
**                                              --Its a known issue and Basis2 upgrade will fix the issue. It's nothing to do with Bill Print.
**  3154           RNN  3.0.0.13   09/23/2014   ERT number not appearing on bills for meter group.
**  3127           RNN  3.0.0.12   09/18/2014   Fire Service Charge not appearing on Printed Bills.
**  3713           RNN  3.0.0.11   09/16/2014   Incorrect display of usage on Bill.
**  3703           RNN  3.0.0.10   09/15/2014   Graph on bill does not match monthly readings for some accounts.
**  3218           RNN  3.0.0.09   09/09/2014   Groundwater bills should have a to and from date range.
**  3908           RNN  3.0.0.08   09/09/2014   Credit rebills should appear on bill graph as zero, not as a line that extends below the graph.
**  3435           RNN  3.0.0.07   09/08/2014   Print $0 usage on Bills.
**  3659           RNN  3.0.0.06   09/08/2014   Stormwater period on bill.
**  3861           RNN  3.0.0.05   09/02/2014   Remove asterisk from stormwater charges on bills.
**  3910           RNN  3.0.0.04   09/07/2014   Include Senior Citizen Discount line on residential bills whether the customer receives the discount or not.
**  3904           SRI  3.0.0.03A  12/03/2014   Exclude disputed amounts from shutoff notices
**  3706           RNN  3.0.0.03   08/07/2014   New Bill Design -- Change
**                 GAL  3.0.0.02   06/13/2014   Correct calls to ciss0047.raise_exception to limit mesg_code to 30 chars.
**                 PJT  3.0.0.01   11/13/2013   R12 and language changes
******************************************************************************************************************************
**  3616           RNN  2.0.0.86   11/04/2013   Senior Citizen Discount should be deducted from "Please Pay this Amount" field
**  3624           CCR  2.0.0.85   08/15/2013   Bankruptcy amount shown on Shut-Off notice
**  3367b/         RNN  2.0.0.84   08/06/2012   Payment Agreement amounts on bills are not correct (lien fees, etc.)
  3367/
  3232                                          Bill "Please Pay" Amount Ignores Senior Citizen Discount
**  3481           RNN  2.0.0.83   03/14/2013   NOT in OceanP
**  3409B          SL   2.0.0.82   01/17/2013   If there are INVALID ZIP codes, then make then 00000
**  3409A          SL   2.0.0.81   01/15/2013   Trim the IMB and handel the ZIP codes without Zips
**  3407           CB3  2.0.0.80   01/03/2013   The wording on shutoff notices were updated.
**                                              Since the table "phl_tmg_shutoffnotice" has
**                                              a column for the Process ID, the value of the
**                                              Process ID was added to the tables output. It will be
**                                              the data section of the detail records which
**                                              will get populated.
**  3133/3423      RNN  2.0.0.79   11/27/2012   Prepare for January 2013 rate increase, including RFSS services
**  3409           SL   2.0.0.78   11/23/2012   Populate Intelligent Mailing Barcode (IMB) field
**  2137           CB3  2.0.0.77   02/29/2012   When the shutoff bill is being generated there are cases
**                                              where the debt collection path "OLD-BNKR" balances are being
**                                              included in the customer current balance.  This should not occur
**                                              because these balances should not be shown on regular as well as
**                                              shutoff bills.  This request was specified by BugID#2137 under comment#63943.
**  3327b/3338     RNN  2.0.0.76   06/14/2011   Allow new residential messages (MSGNUM 77) and allow gaps between priorities of existing messages by 1000
**  3327           RNN  2.0.0.75   06/05/2011   Allow bill message to be included only on commercial properties
**  3097           PJT  2.0.0.74   07/31/2011   Change shutoff message date to match penalty date
**  3098           PJT  2.0.0.73   07/28/2011   Payment agreement amount code should reset number of payments back
**                                              one if the amount is reset to the standard installment amount
**  3257           CCR  2.0.0.72   02/13/2012   Missing digits in bill scanline
**  3093, 3114     PJT  2.0.0.71   07/31/2011   Payment agreement amounts not appearing on bill (3093); Scan line errors on August 2011 bills (3114)
**  3055           RNN  2.0.0.70   06/21/2011   BILLHIST events fails.
**  2640           RNN  2.0.0.69   06/17/2011   Fix PHLS0001 failed in UAT --Claire will raise a Bug
**  2852           RNN  2.0.0.68   05/09/2011   Enhancements for new ePay gateway - including eCheck payment functionality
**  2908           CCR  2.0.0.67   01/25/2011   Customize bill message for stormwater-only customers
**  2903           CCR  2.0.0.66   01/21/2011   January 18, 2011 bill not printed for installation IN001438068
**  2842           LR   2.0.0.65   11/18/2010   Change process to display last actual read information
**                                              after Work Orders (ERP-REPL, REMOVE etc.) when previous bills are on
**                                              estimate and rebilled.
**  2730           CCR  2.0.0.64   10/22/2010   Add stormwater period coverage
**                                 11/11/2010   Add bill message for NB3 and NB8 for their first bill - Jan 2011.
**  2703           RNN  2.0.0.63   10/14/2010   "Care Of" line printing twice on the bill
**  2124/2265      CB3  2.0.0.62   09/24/2010   The calculation of the "PAY AT ONCE"
**                                              balance has been changed to accomodate
**                                              the "CURRENT CHARGES","OVERDUE CHARGES",
**                                              and "DISPUTED CHARGES" a customer may
**                                              owe on a Shutoff Bill. This change
**                                              was included to comply with the comment#36260
**                                              request under BugID#2124.Also The comment#37197
**                                              request under BugID#2265. There was a request
**                                              in BugID#2124 under comment#56618 to exclude
**                                              the "VACANT" Debt Collection Path balances.
**  2514           RNN  2.0.0.61   09/14/2010   WRBCC Enhancements
**  2775           RNN  2.0.0.60   09/02/2010   New bill message for payment agreements with missed payment
**  2809           PJT  2.0.0.59   10/01/2010   Change shutoff notice to use 10 days and then ensure that this is a valid shutoff date
**                                              by using the NEXT_SHUT_DATE routine from PHLS0007
**  2660           RNN  2.0.0.58   07/12/2010   Chargeable Extras not shown on the Bill.
**  2458           LR   2.0.0.57   06/18/2010   Update allocation calculation to show correct amount.
**                                              Remove (-1) multiplier.
**  2666            RNN  2.0.0.56   07/18/2010   Bill not reflecting payment agreement amounts
**  xxxx     RNN  2.0.0.55   07/15/2010   Show cure amount for Payment Agreement
**  2648           SG   2.0.0.54   05/25/2010   Payadvice scanline displays the payadvice amount incorrectly
**  2634           RNN  2.0.0.53   05/25/2010   Advance Service CHEX will result in high credit in July 1 due to new Sewer Rate.
**                Billing shows double discount on Chargeable Extras.
**  2254     RNN  XXXXXXXX   04/15/2010   New ERT start reading displayed on bill as estimate in error [NO Issues].
**  2098     RNN  XXXXXXXX   04/15/2010   Incorrect usage displayed on bill.[NO Issues]
**  2249       RNN  2.0.0.52   04/26/2010   For July 2010 rate increase change text of CHEX adjustment on bill
**                Add Chargeable Extras to Service Charge
**  2361           RNN  2.0.0.51   04/14/2010   Bill showing Total Account Balance in excess of Running Bal.
**  2431           RNN 2.0.0.50   03/17/2010   Penalty amount on bills for charity customers is calculated before discount.
**                same as 2527
**  2248           RNN 2.0.0.49   03/16/2010   payment agreement amounts incorrect on new bill
**                Covered in 2212
**  2211           SG   2.0.0.48   02/15/2010   Debt Collection Paths/Stages and Printers Availability for PayAdvice
**  2527           RNN  2.0.0.47   02/17/2010   Storm Water Charges are Incorrect for Senior Citizen or any kind of Discounted Bills.
**  2524           RNN  2.0.0.46   02/09/2010   Bill Message for Ground Water is appearing on Storm Water Bill.
**                Bill Key = B0096321929 in QA
**                Usage charge from actual reading is $254.47 less credit for previously estimated usage of $5.51
**  1880     RNN  2.0.0.45   02/09/2010   Old Bankruptcy Debt Collection balances are showing on monthly bill.
**  2488      RNN 2.0.0.44   01/21/2010   Estimate Flag on bill should always be 'E'
**  2437     RNN  2.0.0.43   01/16/2010   Bill Usage Graph Data in Error
**  2477     RNN  2.0.0.42   01/15/2010   Create new bill message for 2010 Census
**                  Put always Message Num 18 in Message4.
**                Code modified is in Package phls0005
**  2212     RNN  2.0.0.41   01/15/2010 Prepayment of payment plan does not start arrears process
**  2417           RNN  2.0.0.40   11/26/2009   Senior Citizen account billed for regular charge and discount charge
**  2176           RNN  2.0.0.39   11/25/2009   Penalty printing incorrectly on Owner's Bill when a Tenant is present.
**                --Bug#2176 and Bug#2402 are interlinked, to derive future penalties(Bug#2176)
**                --Tot_Credit was introduce in phls0001
**                --Particularly 5% peanlties would execlude Tot_Credit
**  2402     RNN  2.0.0.38   11/23/2009   Credits section of bill has wrong subtotal
**  2414           RNN  2.0.0.37   11/16/2009 View bill does not work for multiple bill in one bill key
**  2366     RNN  2.0.0.36   11/12/2009   PHA bills displaying wrong amount
**  2301     RNN 2.0.0.35   11/11/2009   Groundwater charges are not appearing on the bill
**  n/a     RNN  2.0.0.34   11/10/2009   Storm Water
**  n/a            RNN  2.0.0.33   10/16/2009  If Zip code is null/or Zero, record appears before header reord
**  2275           RNN  2.0.0.32   10/01/2009  Usage Amount incorrectly displayed on bill statement
**  2350           RNN  2.0.0.31   09/23/2009  Care Of mailing address field not showing on new bill
**  2306           RNN  2.0.0.30   09/19/2009  Balance due on ePay does not match balance due on new bill.
**                Make phl_tmg_bill_master permanant and use it for ePay.
**  2333           RNN  2.0.0.29   09/18/2009  Penalty process updating before due date on bills.
**  2264     RNN  2.0.0.28   09/16/2009 Bankruptcy Balances are being mentioned in Message line field
**  2209           SG   2.0.0.27   09/09/2009   Payment agreement statements printing with wrong monthly payment amount
**  2248           RNN  2.0.0.26   07/27/2009   Undoing bug#2248.
**  2248           RNN  2.0.0.25   07/23/2009   Payment Agreement Amounts incorrect on new bill--
**  n/a            AWT  2.0.0.24A  09/25/2009   Comment out unconditional traces in next_valid_due_date.
**  n/a            RNN  2.0.0.24   07/07/2009   There can be one bill for background batch printing.
**  n/a            RNN  2.0.0.23   07/03/2009   Bill Due Date and Penalty Due dates should't be on sats, suns and holidays
**                -- Penalty date = billling date + 30  --ciss0017.billing_date_plus_freq
**                --We can use Basis2 package ciss0017.billing_date_plus_freq
**                --select ciss0017.billing_date_plus_freq('D1','STANDARD',w_rtn_date) into w_rtn_date from dual
**  n/a            RNN  2.0.0.22   07/02/2009   Chargeable Extras should be part of bill.
**  n/a            RNN  2.0.0.21   06/29/2009   Estimate flags for Current and prior reading, are modified.
**  n/a            RNN  2.0.0.20   06/26/2009   For Standard Paument Plan tota due amount equals to total current charges
**  n/a            RNN  2.0.0.19   06/24/2009   For Standard Paument Plan tota due amount equals to total current charges
**  n/a            RNN  2.0.0.18   06/23/2009   For standard payment plan add show cure amount as agreement amount
**  n/a            RNN  2.0.0.17   06/23/2009   If payment plan is standard, add plan due + total_current_charges (prev_bal+adj+pay+current_charges)
**  n/a            RNN  2.0.0.16   06/22/2009   Base payment plan outstanding on bill due date.
**  n/a     RNN 2.0.0.15   06/18/2009   If payment agreement then show the penalty date and total penalty due amount but penalty should be ZERO.
**                Estimate flags are not correct, change them.
**  n/a     RNN 2.0.0.14   06/17/2009   If payment agreement is not due than show current_balance + agreement due (which ZERO)
              --Don't penalize if the account is in payment plan
**  2199           AWT  2.0.0.13   06/17/2009   Clear w_factor_message at start of bill to stop old message printing on
**           (1.0.0.72)
**  n/a            RNN  2.0.0.12   06/16/2009   Production Issue-- Bill job failed "character string buffer too small"
**           (1.0.0.71)
**  n/a            RNN  2.0.0.11   06/05/2009   Don't include the following Debt Collection:
**                1. Grant
**                2. Low Income
**                3. TRB
**                     --4. We are not including WRBCC as it is done at Open bill lines
**                5. Sheriff's Sale
**                6. Vacant
**                 in total balance for account's in this scenario,
**                 we should have a message saying:
**                 'Total Other Suspended or Pending Charges not included in the Total Above: $9,999.99. These charges may become due or payable.' Where $9,999.99 is the amount in above debt collection.
**  n/a     RNN 2.0.0.10   06/01/2009 Changes to New Bill
**                WRBCC Payment Amount and Payment Plan Amount are Mutually Exclusive.
**  2127           AWT  2.0.0.09A  05/25/2009   Pick quality factor that matches reading period and allow for multiple
**         (1.0.0.70)               quality factors in a reading period.
**
**  n/a            RNN  2.0.0.09   05/19/2009   When balance is credit (negative amount). The box should say 'Please pay this amount $0.00'
**                When there is an agreement show agreement as total_due.
**                Require Grants (LIHEAP/CRISIS/UESEF) to be shown on New bill
**
**  2114           CCR   2.0.0.08   04/29/2009  Correct Scan-Line. Water1 Acct's 14th char is replaced with '0' if value
**        (1.0.0.69)     is '1'-'9'.
**
**
**  2109           AWT   2.0.0.07   04/27/2009  Print message in tear drop area showing est reversal and real reading
**                      (1.0.0.68)              values when a real reading follows an estimate.
**
**
**  n/a     RNN   2.0.0.06   04/14/2009  There are about 4,000 customers in the system who have names that are longer than 30 characters.
**                The bill itself can only handle names that are 30 characters or shorter due to the size of the
**                                              window envelope that's used. Currently, names longer than 30 characters wrap onto the next line
**                and obscure the address which makes them unacceptable for mailing.
**
**
**  1700     PJT   2.0.0.05A  03/27/2009  incorrect usage amount appearing on bill
**                    (1.0.0.67)        Continuing from 1513, qty on a special reading for a meter group bill
**                                              on the additive meter property is incorrect when the other notional only
**                                              property is billed first.
**
**
**  n/a     RNN   2.0.0.05   03/20/2009  Claires changes
**                Missing fields in the BACKGROUND_PRINT_STRING (refer to compare matrix attached)
**                PENALTY_DATE is not included in the BACKGROUND_PRINT_STRING, thus not displayed on the bill (at the payment stub)
**                Total Account Balance does not 'sum' up:
**                LAST_PAID_AMNT, DISCOUNT_AMNT and WRBCCCRED are not negative value
**                USAGE_CHARGE_AMNT and SERVICE_CHARGE_AMNT passed are after discount. Consequently, CURRENT_CHARGE_AMNT is also after discount
**                Bankruptcy and RDA - are still included in the total account balance. They should be excluded.
**
**  n/a     RNN   2.0.0.04   03/18/2009  Change reqst by claire
**                1. Add extra field DISCOUNT_LBL  VARCHAR2(30) to PHL_TMG_BILL_MASTER
**                2. Change SENIOR_DISCOUNT_AMNT to DSICOUNT_AMNT
**                3. Change Bill_Print_Heading from SENI_DISC_AMNT to DISC_AMNT
**                4. Add DISC_LBL before DISC_AMNT for Bill_Print_Heading
**                Following Discount Labels needs to added as per customer type
**                --A - Philadelphia Housing Authority Discount [PHA Discount]
**                --C - Charity Discount [Charity Discount]
**                --D - Senior Citizen Discount [Senior Citizen Discount]
**                --E - Board of Education Discount [Board of Education Discount]
**                --N - University, College, Hospital Discount [University/Hospital Discount]
**
**
**  n/a     RNN   2.0.0.03   03/08/2009  Change reqst by claire
**                                              1. Exclude transaction amounts of any pre-petition bankruptcy (CIS_TRANSACTIONS.IFCE_STATUS_CODE = 'BNKRPT') from the 'Account Balance'
**                2. Exclude transaction amounts of linked to RDA  - Redevelopment Authority (CIS_TRANSACTIONS.IFCE_STATUS_CODE = 'RDA') from 'Account Balance'
**
**  1921           CB3   2.0.0.02   03/04/2009  The text string field "w_ptsh.msg_line" in subroutine "get_shut_off_details"
**                      (1.0.0.66)              was modified to include the area code "215" to the phone number "686-6880".
**
**  1513           AWT   2.0.0.01B  02/27/2009  Meter group surcharge account from reading details are sometimes
**                      (1.0.0.65)              wrong when there are special and / or check readings, especially
**                                              if for example there are 2 specials in a row for one installation
**                                              followed by one or more specials for the other installation in the group.
**
**  1710           PJT   2.0.0.01A  02/27/2009  Add any SH-WATER into overdue amount for shutoff notices
**          (1.0.0.64)
**
**  N/A            PJT   2.0.0.01   02/06/2009  Work order date checking on shutoff bill
**          (1.0.0.63)
**
**  N/C            RNN   2.0.0.0C   02/02/2009  Undo Bug 1164A till claire confirms it.
**
**  1164A          AWT   2.0.0.0B   02/02/2009  Don't include opening debit balance in penalty calculation.
**          (1.0.0.62)
**
**  1934           SG    2.0.0.0A 01/15/2009 Modify PHLS0001 bill print routine to not fail at e093, locate performance issue
**          (1.0.0.61)
**
**  New_BILL       RNN   2.0.0.0    12/10/2008 New Bill
***********************************************************************************************************************
**  1896     RNN 1.0.0.60   12/11/2008 Modify phls0001 bill print routine to not fail at e093, locate performance issue
**  1552           SG   1.0.0.59   09/16/2008   -Pay Advice needs to work on laser printer for scanning
                                              -Scanline change account# to Debt Collection Key - requested by Claire
**  1734           PJT  1.0.0.58   10/02/2008   Allow for same account receipt allocation to debt collection
**  n/a            PJT  1.0.0.57   09/26/2008   For accounts that get inter-account allocations
**                                              but do not use group bill, we must consider these allocations
**                                              when calculating the previous balance
**  1762           CCR  1.0.0.56   09/22/2008   Water1 Acct incorrectly generated in Scan Line for Returned Check Notice
**  1763                                        Alpha 'Z' in Water1 Acct should be translated to '9' instead of '8'
**  1386           RNN  1.0.0.55   09/08/2008   shutoff bill included landlord and tenant balance
**  1386           RNN  1.0.0.54   08/19/2008   shutoff bill included landlord and tenant balance
**  1622           RNN  1.0.0.53   08/04/2008   Shutoff notice sent out with a shutoff date prior to the letter date.
**  1643           SG   1.0.0.52b  07/24/2008   Modification of Time from 5:30 pm to 5:00 pm
**  1613           SG   1.0.0.52a  07/24/2008   Scan is 69 Characters
**  1573           AWT  1.0.0.52   06/24/2008   Get due date from transaction and don't print it if the bill has a creit balance.
**                                              Check the credit balance on what is printed on the bill and not what the basis2
**                                              figure is because some items like bankruptcy are not printed.
**  1411           RNN  1.0.0.51   05/12/2008 Meter Rotate on a Meter Group doesn't print on bill
**                 AWT  1.0.0.50   05/06/2008   Add special message for all route 051 accounts during May 2008.
**  1353           RNN  1.0.0.49   04/30/2008   surcharge bills display incorrectly and calculation incorrectly
**  1255           PJT  1.0.0.48   04/22/2008   Make sure OLD-WRAP is not show on shutoff notices
**                                              Owner bill to show Debt collection except OLD-WRAP as well.
**                                              Discontinued account do not get shutoff notices
**  709            SG   1.0.0.47   04/18/2008   Scan String for Group Bills
**  1263           PJT  1.0.0.46   04/16/2008   Arrears places each ppln letter in the summary file
**                                              Only on notice is requried
**                 SG   1.0.0.45   04/05/2008   Fix for Payment Agreement/Downpayment bill report
**  1129           PJT  1.0.0.44   04/05/2008   Another edition of billing cycle and reading dates and qty
**                                              Cycle based on reading upto date
**                                              Qty to show difference between reading and last reading
**                                              Reading dates to show last reading and this reading dates
**                                              Meter change to show second meter
**  1164           PJT  1.0.0.43   03/24/2008   Change basis for penalty back on to balance
**  1092           PJT  1.0.0.42   03/03/2008   Only set reading dates on reading lines not reversal lines
**                                              Since reading lines occur before reversal lines, this means
**                                              do not set the dates if they are already set.
**                 PJT  1.0.0.41   03/14/2008   Put arrears run date in the last payment date for shutoff notice
**                                              rather than the correct last receipt date as this date prints on the
**                                              notice in a field titled "includes payment received on or before"
**                 SG   1.0.0.40   03/12/2008   Header line for Shut-off does not print as the first line
**                 CCR  1.0.0.39   03/04/2008   Print Aux CDay in Scan Line in Debt Collection Pay Advice
**  1077           PJT  1.0.0.38   02/29/2008   Get period date for fire service charge only bills
**                 AWT  1.0.0.37   03/01/2008   Don't print shut-off bills where the SHUT-OFF work order is completed or cancelled.
**  1067           AWT  1.0.0.36   02/21/2008   Get mail_addr_id from cis_accounts instead of nitlines as deletion of an old
**                                              mail_addr_id which has been stored in ilines
**  1057           AWT  1.0.0.35   02/19/2008   Due date wrong in scan line for credit bills.
**                 AWT  1.0.0.34   02/14/2008   Final shut-off bill formatting and correction of values printed including
**                                              ignore amounts under bankruptcy and ignore installations with no owner or tenant.
**                 AWT  1.0.0.33   02/10/2008   Print shut-off bill for all SHUT% letters.
**                                              If NCO or RCB print mailing name which is the customers name.
**                 AWT  1.0.0.32   02/08/2008   Stop table scan of cis_transactions by supplying cust_id's.
**                 PJT  1.0.0.31   02/01/2008   Base payment plan outstanding on bill due date
**                 PJT  1.0.0.30   01/31/2008   Shutoff AR's in ascending order
**                 PJT  1.0.0.29   01/29/2008   Allow for landlord bills
**                 PJT  1.0.0.28   01/28/2008   Undo 1.0.0.24
**                 PJT  1.0.0.27   01/28/2008   Dynamic performance statistics
**   n/a           PJT  1.0.0.26   01/28/2008   Allow for unallocated cash in receipts
**   922           PJT  1.0.0.25   01/28/2008   Generate bill lines for previous bill if required for shutoff
**   922           RNN  1.0.0.24   01/24/2008   SHUTOFF Bill not getting generated
**   940           PJT  1.0.0.23   01/24/2008   Back debt plans do not affect the ppln id of new bills
**                                              Need to look at the account to get active plan details
**   n/a           PJT  1.0.0.22   01/18/2008   Wrap Message Changes, No background headings for multi-page
**                                              online bill.
**   n/a           PJT  1.0.0.21   01/16/2008   Delinquent Balance Changes,
**   894                                        ZIP Check
**   883           AWT  1.0.0.20   01/14/2008   Add new bill_tran_key field to primary index to allow for multiple bill trans
**                                              for a single bill.
**   n/a           PJT  1.0.0.19   01/13/2008   Correct calculation of previous balance
**   818           AWT  1.0.0.18   01/16/2008   Alter for meter groups and surcharge bills.
**                                              Current balance to show bill total before senior's discount as senior's
**                                              discount shows on a separate line.
**                                              Last Payment amount should be just the last payment not the sum of all
**                                              open items since the last bill..
**   n/a           PJT  1.0.0.17A  01/05/2008   More scan line changes
**                                              Print last receipt irrespective of date
**   n/a           RNN  1.0.0.17   01/04/2008   Scan line change for payadvice/view bill report;
                                              Group bill 'NO-PRINT';
                                              Senoir Citizen related changes
                                              Service Code Inst for set_one_bill
**   n/a           RNN  1.0.0.16   12/31/2007   Bill print with a credit balance
                                              Total_Due_Amnt, penalty_Amnt and Penalty_Due_Amnt can not have
                                              spaces, signs($) or trailing negative signs(-) or spaces
**   n/a           AWT  1.0.0.15   12/20/2007   Adjust more headings as per email from Tom Barr.
**                                              Meter key only 1st 7 chars.
**   n/a           AWT  1.0.0.14   12/19/2007   Alter heading SERVICE_CHARGE_AMNT to SVC_CHARGE_AMNT.
**   n/a           PJT  1.0.0.13   12/19/2007   Alter heading on billed qty
**   n/a           PJT  1.0.0.12   12/17/2007   Ignore GRP-BILL format on background
**   666           RNN  1.0.0.11A  12/12/2007   Bankruptcy pay advice to print Debt Collection key on scan line
**   665           RNN  1.0.0.11   12/12/2007   Amnt posted to RECEIPT-SUSPENSE if inbound acct is in Basis2 format
**   n/a           RNN  1.0.0.10A  11/28/2007   SHUT-OFF BILL
**   542           AWT  1.0.0.10   11/15/2007   Ignore reversed readings, pass extra fields to phls0005 for bill messages.
**   n/a           RNN  1.0.0.9    11/08/2007   Actual develpoment for payadvice
**   468           PJT  1.0.0.8A   11/05/2007   Fix inter-account allocation lines
**   n/a           RNN  1.0.0.8    10/30/2007   Made a public scan routine for bankcruptcy chapter13 and payadvice
**   n/a           RNN  1.0.0.8    10/30/2007   Made a public scan routine for payment downpayment
**   201           PJT  1.0.0.7    10/18/2007   Made a public routine for scan line
**   201           PJT  1.0.0.7    10/18/2007   Made a public routine for scan line
**   201           PJT  1.0.0.6    08/20/2007   Also Show full account balance on final bills
**   n/a           PJT  1.0.0.5    09/06/2007   Allow fir the very first bill for an account
**   201           PJT  1.0.0.4    08/20/2007   Show full account balance on property settlement bills
**   157           RNN  1.0.0.3    07/28/2007   Upgrade bill print routine - ignore debt collection balances
**   n/a           PJT  1.0.0.2    07/04/2007   Penalty date to be blank in the output string
**                                              Bill format code in the print file
**                                              Bill Account = Old water 1 account now comes from the address record
**   n/a           PJT  1.0.0.1    03/19/2007   Package creation
**
** Possible variaties of CITY --> PHILADELPHIA stored in address2 field of cis_addresses table
** 'PHLILADELPHIA','PHLIADELPHIA','PHLIA','PHLADELPHIA','PHLA','PHILLY','PHILLADELPIA','PHILDELPHIA','PHILDELPHIA','PHILDADELPHIA','PHILAP','PHILAELPHIA','PHILADLPHIA','PHILADLHPIA','PHILADLEPHIA','PHILADEPLHIA','PHILADEPHIA','PHILADELPLHIA','PHILADELPIA','PHILADELPHIS','PHILADELPHIOA','PHILADELPHILA','PHILADELPHIIA','PHILADELPHIA','PHILADELPHIAQ','PHILADELPHIAP','PHILADELPHIA','PHILADELPHIA','PHILADELPHHIA','PHILADELPHA','PHILADELLPHIA','PHILADELHPIA','PHILADELHPA','PHILADELHIA','PHILADELEPHIA','PHILADEL;PHIA','PHILAADELPHIA','PHIILADELPHIA','PHIILA','PHIALDELPHIA','PHIADELPHIA','PHHILADELPHIA'
** Contempleting 1. to store these values in cis_code_values and use like clause to fetch these records from cis_addresses
**               2. to store them in pl/sql tables and use at runtime but still need to use like clause against each of these values against cis_addresses.address2 field.
**               3. to parse the above string and use instr to determine the city from address2 field.
*/
		--g_auto_pay_4all_acs        	varchar2(15);																-- Del 8020F	--Add 8020D
		--g_pnlty_frgv_dt							  date;			--Add 9984
		--g_pnlty_frgv_amnt						  number; 	--Add 9984
		--g_prin_frgv_dt								date;			--Add 9984
		--g_prin_frgv_amnt							number;		--Add 9984
		g_tap_pnlty_frgv_mssg					varchar2(500); --Add 9984
		g_tap_prin_frgv_mssg					varchar2(500); --Add 9984
		g_tap_acct_at_some_stage			cis_accounts.attribute3%type;                 -- Add 9984
    --g_prv_bill_in_tap 						cis_transactions.user_reference2%type;			-- Del 9984B	-- Add 9984
    g_trn_ifce_refn						 		cis_transactions.ifce_refn%type;              -- Add 8020F -- Add rebill indicator
    g_trn_scnd_type						    cis_transactions.scnd_type%type;							-- Add 8020F -- Add rebill indicator
		g_final_bill_ind 							char(1); 																			-- Add 8020F
		g_rebill_bill_ind 						char(1); 																			-- Add 8020F
		g_loot_ind										phl_bill_print_hist.loot_ind%type;						-- Add 8020B
		g_inst_revu2_code							cis_installations.revu2_code%type;						-- Add 8020B
		--g_auto_pay_ind							cis_code_values.code_value%type;						  -- Add del 9454	 -- Add 8020B
		g_wtr_access_code							cis_accounts.acct_key%type;								 		 -- Add 7080
    w_tap_bill_print              phlst007.r_tap_bill_print;                     -- Add 6230 3.0.0.41
    w_tap_error_code              varchar2(30);                                  -- Add 6230 3.0.0.41
    w_tap_error_text              varchar2(300);                                 -- Add 6230 3.0.0.41
    w_hlrc_status                 varchar2(20);                                  -- Add 6230 3.0.0.41
    w_billing_dateyyyymmdd        varchar2(8);                                   -- Add 6230 3.0.0.41
    w_ar_acct_bal                 number;                                        -- Add 5905 3.0.0.39
    w_hl_acct_bal                 number;                                        -- Add 5905 3.0.0.39
    w_unpaid_bal_lbl              varchar2(20);                                  -- Add 4575
    w_cur_chg_solid_line_flg      varchar2(1);                                   -- Add 4608
    w_event_id                    cis_events.event_id%type;                      -- Add 2514
    w_msg_shutoff_date            date;                                          -- Add 2775
    c_alphnum_w1_string1          varchar2(26) := 'abcdefghijklmnopqrstuvwxyz';  -- Add 1.0.0.17A
    c_alphnum_w1_string2          varchar2(26) := '12345678912345678912345679';  -- Add 1.0.0.17A  Mod 1.0.0.56
    c_alphnum_w1_string3          varchar2(26) := '11111111122222222233333333';  -- Add 1.0.0.17A
    w_bill_format                 varchar2(8);
    w_count                       number;
    w_city_acct                   varchar2(16);                            -- Add 1.0.0.17A
    w_city_acct_4_WAT             varchar2(16);                            -- Add 6130
    w_city_acct_new_suffix        varchar2(16);                            -- Add 1.0.0.17A
    w_city_acct_new_14            varchar2(1);                             -- Add 1.0.0.17A
    w_city_acct_new_67            varchar2(1);                             -- Add 1.0.0.17A
    w_cust_id                     cis_bill_trans.cust_id%type;
    w_index                       binary_integer;
    w_inst_id                     cis_bill_trans.inst_id%type;
    w_label                       varchar2(4);
    w_low_date                    date;
    w_penalty_percent             number;
    w_penalty_factor              number;
    w_process_id                  cis_process_restart.process_id%type; --cis_bill_lines.process_id%type;
    w_reading_grp_type            cis_bill_trans.reading_grp_type%type;             -- Add 1.0.0.4
    w_final_ownr_bill             boolean;                                          -- Add 1.0.0.6
    w_settl_ownr_bill             boolean;                                          -- Add 1.0.0.4
    w_supply_type                 cis_supply_parameters.supply_type%type;
    w_tran_id                     cis_bill_trans.tran_id%type;
    w_dd_earliest_date            cis_transactions.dd_earliest_date%type;           -- Add 542
    w_estimates_cnt               cis_meter_regs.estimates_cnt%type;                -- Add 542
    w_ppln_no_due                 number;                                           -- Add 542
    w_reading_type                cis_debit_lines.reading_type%type;                -- Add 542
    w_last_reading_type           cis_debit_lines.reading_type%type;                -- Add 542
    w_cust_own_reading_ind        cis_reading_types.cust_own_reading_ind%type;      -- Add 542
    w_last_cust_own_reading_ind   cis_reading_types.cust_own_reading_ind%type;      -- Add 542
    w_in_mtr_grp                  varchar2(1);                                      -- Add 818
    w_unbill_reg_found            varchar2(1);                                      -- Add 818
    w_meter_grp_rdg_id            number(15);                                       -- Add 818
    w_distribution_source         cis_supply_points.distribution_source%type;       -- Add 818
    w_quality_date                date;                                             -- Add 818
    w_quality_factor              cis_quality_factors.quality_factor%type;          -- Add 818
    w_srvc_code_inst_id           cis_bill_trans.inst_id%type;                      -- Add 818
    w_copy_bill_ind               cis_bill_lines.copy_bill_ind%type;                -- Add 818
    w_last_reading_datime         cis_meter_grp_rdg_lines.last_reading_datime%type; -- Add 1513 --2.0.0.01B --1.0.0.65
    w_last_reading                cis_meter_grp_rdg_lines.last_reading%type;        -- Add 1513 --2.0.0.01B --1.0.0.65
    w_real_read_amnt              number;                                           -- Add 2109 --2.0.0.07 --1.0.0.68
    w_est_rev_amnt                number;                                           -- Add 2109 --2.0.0.07 --1.0.0.68
    w_prepare_est_rev_msg         boolean;                                          -- Add 2109 --2.0.0.07 --1.0.0.68
    w_factor_from_date            date;                                             -- Add 2127
    w_factor_upto_date            date;                                             -- Add 2127
    w_factor_message              varchar2(186);                                    -- Add 2127
    w_est_rev_messg               varchar2(300);              -- Add 2.0.0.20
    w_sur_cst_fct_mssg            varchar2(300);              -- Add 2.0.0.11
    -- Messaging
    w_mesg_date                   phl_report_messages.from_date%type;
    w_est_reading_ind             cis_debit_lines.est_reading_ind%type;
    w_fault_code                  cis_debit_lines.fault_code%type;
    w_acct_pay_method             cis_bill_lines.acct_pay_method%type;
    w_incid_code                  cis_incidents.incid_code%type;
    w_ppln_id                     cis_bill_trans.ppln_id%type;
    w_ppln_type                   cis_bill_trans.ppln_type%type;     -- Add 1.0.0.21
    w_ppln_due_amnt               number;
    --w_sw_chg_fr    cis_debit_lines.period_from_date%type;    -Del 3659 Replaced by w_ptbm.sw_chg_fr_dt So now they are part of w_ptbm record variables-- Add 2730
    --w_sw_chg_to    cis_debit_lines.period_upto_date%type;    -Del 3659 Replaced by w_ptbm.sw_chg_to_dt So now they are part of w_ptbm record variables-- Add 2730
    w_nb_code                     cis_installations.revu1_code%type;        -- Add 2730
    w_svc_code                    cis_installations.attribute29%type;       -- Add 2903
    -- Variables for scan string for Down Payment
    w_paym_due_date               varchar2(6); --Add 4723
    w_ppln_plan_due_date          varchar2(6)   ;
    w_ppln_acct_number            varchar2(17)  ;
    w_ppln_agreement_balance      varchar2(11)  ;
    w_ppln_agreement_amount_due   varchar2(10)  ;
    w_ppln_control_day            varchar2(3)   ;
    w_ppln_sewer_charges          varchar2(4)   ;
    w_ppln_last_twelve            varchar2(12)  := '100000000000';
    w_ppln_scan_string            varchar2(68)  ;
    -- Report record for down payment for agreement plan
    w_ppln_phl_tmg_down_pay_bill     phl_tmg_down_pay_bill%rowtype;
    -- Variables for scan string for Pay Advice
    w_padv_due_date               varchar2(6)   ;
    --w_padv_acct_number          varchar2(17)  ;      --1.0.0.11A
    w_padv_debt_coll_key          varchar2(17)  ;      --1.0.0.11A
    w_padv_amnt_w_penalty         varchar2(10)  ;
    w_padv_amnt_wo_penalty        varchar2(10)  ;
    w_padv_control_day            varchar2(3)   ;
    w_padv_sewer_charges          varchar2(4)   ;
    w_padv_29thchar               varchar2(1)   ;
    w_padv_last_twelve            varchar2(12)  := '100000000000';
    w_padv_scan_string            varchar2(68)  ;
    -- Report record for Pay Advice
    w_phl_tmg_pay_advice          phl_tmg_pay_advice%rowtype;
    -- Variables for scan string for Shut off bill
    w_ptsh_acct_number            varchar2(16)  ;
    w_ptsh_29thchar               varchar2(1)   := '7';
    w_ptsh_tot_bill               varchar2(10)  ;
    w_ptsh_tot_principal          varchar2(10)  ;
    w_ptsh_control_day            varchar2(3)   ;
    w_ptsh_last_twelve            varchar2(12)  := '100000000000';
    w_ptsh_scan_string            varchar2(68)  ;
    -- Report record for Shut-off bill
    w_ptsh                        phl_tmg_shutoffnotice%rowtype;
    w_letter_code                 cis_tmp_arrears_summary.letter_code%type;
    w_arrears_process_id          cis_process_restart.process_id%type;
    w_usg_line_hdng               varchar2(20);
    -- Report record
    --w_ptbm                      PHL_TMG_BILL_MASTER%rowtype;          --del 3706
    w_ptbm                        phl_bill_print_hist%rowtype;          --add 3706
    w_rchl                        phl_agrv_rc_hlpln_st_dtl%rowtype;     --add 4398
    w_agr_curr_chgs               number;                               --add 4398
    w_hlp_curr_chgs               number;                               --add 4398
    w_max_crln_creation_date      date;                                 --add 4398
    w_max_crln_id                 cis_credit_lines.credit_line_id%type; --add 4398
    w_lst_pymnt_dt                date;                                 --add 4398
    w_cure_amnt                   number;                         --Add 2212      --Add 2.0.0.18
    --w_frm_date_got      boolean := false;                       --Add 2.0.0.21  --Del 2437
    --w_last_frm_date_got     boolean := false;                   --Add 2.0.0.21  --Del 2437
    -- Bill Message Variables
    w_lo_date                     date := to_date('01011900','ddmmyyyy');
    w_hi_date                     date := to_date('31129999','ddmmyyyy');
    -- Intelligent Mailing Barcode (IMB) Variables
    w_imb_barcode_id              varchar2(2) := '00';          -- add 3409 --2.0.0.78
    w_imb_service_type_id         varchar2(3) := '300';         -- add 3409 --2.0.0.78
    w_imb_mailer_id               varchar2(6) := '107817';      -- add 3409 --2.0.0.78
    w_imb_serial_number           varchar2(9) := '000000000';   -- add 3409 --2.0.0.78
    --w_imb_routing_code             varchar2(11)                -- add 3409 NOT NEEDED --2.0.0.78
    --- To get following flags
    --- est_last_rdg_flag, est_this_rdg_flag, est_repl_last_rdg_flag, and est_repl_this_rdg_flag
    w_prior_estimates_cnt    			number;
    w_dis_per                     number;
    w_pay_profile_code            cis_accounts.attribute8%type;
    w_pay_profile_code_orig       cis_accounts.pay_profile_code%type; --Add 3706
    w_arrears_letter_no           cis_accounts.letter_no%type;        --Add 4563
    w_res_comm_ind                char(1);         --Add 3910
    w_char_stormchg               varchar2(15);    --Add 3327
    w_inst_agr_exists             number :=0;      --Add 3327
    w_ppln_start_date             date;            --Add 3367
    w_prv_bl_nt_inc_ppln          number;          --Add 3367
    --w_prv_bl_nt_inc_ppln_oth      number;        --add 3367
    w_int_tran_bal_prev_bill      number;          --Add 3367
    --w_int_tran_bal_oth            number;        --Add 3367
    w_us_gallons                  number := 748.051948; --Add 3706 --US gallons Converter factor
    --w_sql                       varchar2(500);   --Add 3706
    w_agr_pymnts_cnt              number;          --Add 3706
    w_usec_code                   cis_debit_lines.usec_code%type; --Add 3706
    w_grnt_rcvd                   number;                                  --Add 3706
    w_debt_bal_amnt_ues           cis_debt_collection.debt_bal_amnt%type;  --Add 3706
    w_debt_tot_amnt_ues           cis_debt_collection.debt_tot_amnt%type;  --Add 3706
    w_add_to_tot_qty              number;                                  --Add 3706
    w_max_debt_coll_id_ues        cis_debt_collection.debt_coll_id%type;   --Add 5247
    w_bnk_dischrd_bal_amnt        number;                                  --Add 6495
    w_taphld_bal_amnt             number;                                  --Mod 7055 Add 6230A  Chgd from w_bnk_taphld_bal_amnt to w_taphld_bal_amnt  all over
    w_tappen_bal_amnt             number;                                  --Add 7055
		--g_taphld_bal_amnt_frm_trn			number;																	 --Add 9749
		--g_tappen_bal_amnt_frm_trn     number;																	 --Add 9749
		--g_tap_lien										number;																	 --Add 9749
    w_dev_sid                     varchar2(30);                            -- Add 7055
    w_dev_mode                    boolean := false;                        -- Add 7055
    w_cur_sid                     v$database.name%type;                    -- Add 7055
    w_amnt_disp_n_agr             number;                                  -- Add 7164
    w_amnt_disp_pre_TAP           number;                                  -- Add 7164
    w_amnt_disp_post_TAP          number;                                  -- Add 7164
    w_current_billed_qty          number;                      						 --Add 3706
    w_grph_mesg1                  varchar2(100);               						 --Add 4419
    w_grph_mesg2                  varchar2(100);               						 --Add 3706
    w_grph_mesg3                  varchar2(100);               						 --Add 4419
    g_wtr_total_bal								number;																	 --Add 8020
    g_wtr_total_due_amnt    			number;																	 --Add 8020
    g_wah_total_bal								number;                         		 		 --Add 8020
    g_wah_total_due_amnt					number;	                        				 --Add 8020
    --g_bill_delivery_meth					cis_addresses.bill_delivery_meth%type;	 --Add 8020
    --g_ebill_ind										char(1);																 --Add 8020
		g_city_phila_str						  varchar2(4000);													 --Add 8020
		g_inst_city										cis_addresses.address2%type;						 --Add 8020
		g_inst_addr_id								cis_addresses.addr_id%type;						 	 --Add 8020
	  g_disp_tot_amnt_not_in_agr		number;																	 --Add 9792
	  g_disp_tot_amnt_in_agr  			number;																	 --Add 9792
		g_tgt_dt_001									date;																		 --Add 10495
		g_meter_key_10chr							cis_meters.meter_key%type;							 --Add 11138
		g_repl_meter_key_10chr			  cis_meters.meter_key%type;							 --Add 11138
		g_meter_id										cis_meters.meter_id%type;							 	 --Add 11138
		g_repl_meter_id							  cis_meters.meter_id%type;							 	 --Add 11138
    g_s17_grnt_amnt								number:= 0;      												 --Add 11413
    --
    -- Start Add 10266
    --
    type mtr_rec is record
    (meter_id							        cis_meters.meter_id%type
    ,meter_key                   	cis_meters.meter_key%type
    ,meter_key_7chr               varchar(7)
    ,outreader_type_code 					cis_meters.outreader_type_code%type
    );
    --type mtr_rec_tbl is table of mtr_rec index by cis_meters.meter_key%type; --Chng varchar2(7) to cis_meters.meter_key%type
    type mtr_rec_tbl is table of mtr_rec index by long; --Chng varchar2(7) to varchar2(10)
    g_mtr_rec_tbl  			mtr_rec_tbl;
		cursor gc_mtrs is
		select meter_id,meter_key,substr(meter_key,1,7) meter_key_7chr,outreader_type_code
  	  from cis_meters
  	 where outreader_type_code = 'AMI'
  	   and not_installed_ind is null;
    --
    -- End Add 10266
    --
		g_outreader_type_code 				cis_meters.outreader_type_code%type;		 --Add 9106
    --
    -- Store Qty for all replace meters                     	--Add 2417
    --
    type rpl_qty_rec is record                              	--Add 2417
   (bill_key                        varchar2(20)            	--Add 2417
   ,qty                             number                  	--Add 2417
   ,db_scnd_type                    varchar2(3)             	--Add 2417
   ,from_rdg_date                   date                    	--Add 3706
   ,upto_rdg_date                   date                    	--Add 3706
   ,meter_key                       varchar2(20)            	--Add 3706
	 ,meter_key_10chr								  cis_meters.meter_key%type	--Add 11138
	 ,meter_id												cis_meters.meter_id%type	--Add 11138
   ,ert_no                          varchar2(20)            	--Add 3706
   ,from_reading                    number                  	--Add 3706
   ,meter_advance                   number                  	--Add 3706
   );                                                       	--Add 2417
   type rpl_qty_tbl is table of rpl_qty_rec index by binary_integer;  --Add 2417
   w_rpl_qty_tbl  rpl_qty_tbl;                                        --Add 2417
    --
    -- Store valid dates for raoutes and their billed date  --Add 4562
    --
    type vld_rts_bill_dts_rec is record                     --Add 4562
   (rt#                             varchar2(300)           --Add 4562
   ,vld_low_day                     number                  --Add 4562
   ,vld_upr_day                     number                  --Add 4562
   );                                                       --Add 4562
   type vld_rts_bill_dts_tbl is table of vld_rts_bill_dts_rec index by binary_integer;  --Add 4562
   w_vld_rts_bill_dts_tbl  vld_rts_bill_dts_tbl;                                        --Add 4562
   w_vld_low_day_4_rt      number;                                                      --Add 4562
   w_vld_hgh_day_4_rt      number;                                                      --Add 4562
   w_rt_day                number;                                                      --Add 4562
   w_rec_month             number;                                                      --Add 4562
  -- Data records
    cursor c_blln is
    select
          bll.acct_key
         ,bll.bill_format_code
         ,bll.bill_key
         ,bll.line_type
         ,bll.line_num
         ,bll.text_field
         ,bll.reading_grp_type
         ,bll.other_tran_id
         ,bll.other_tran_key
         ,bll.other_tran_date
         ,bll.other_tran_amnt
         ,dbl.tran_date
         ,dbl.scnd_type as db_scnd_type
         ,dbl.task_code as db_task_code
         ,dbl.sinv_code as db_sinv_code
         ,dbl.line_tot_amnt as db_line_tot_amnt
         ,dbl.retail_amnt as db_amnt
         ,dbl.line_description as db_line_description
         ,dbl.tax1_amnt as db_tax1_amnt
         ,dbl.line_outst_ind as db_line_outst_ind
         ,dbl.ppln_ind as db_ppln_ind
         ,dbl.tran_qty
         ,dbl.orig_tran_qty                                -- Add 818
         ,substr(dbl.meter_key, 1, 7) as meter_key         -- Chg 1.0.0.07
         ,dbl.meter_key as meter_key_10chr   							 -- Add 11138
         ,dbl.meter_reg_num
         ,dbl.reading_type                                 -- add 542
         ,dbl.meter_reading
         ,dbl.reading_datime
         ,dbl.prior_last_billed_reading
         ,dbl.prior_last_billed_rdg_datime                 -- Add 1129
         ,dbl.prior_last_real_bld_rdg_datime               -- Add 2109 --2.0.0.07 --1.0.0.68
         ,dbl.prior_last_real_billed_reading               -- Add 2109 --2.0.0.07 --1.0.0.68
         ,dbl.meter_advance
         ,dbl.prior_last_reading
         ,dbl.prior_estimates_cnt
         ,dbl.prior_estimates_cons_qty                      -- Add 1129
         ,dbl.meter_works_id                                -- Add 1129
         ,dbl.est_reading_ind
         ,dbl.uom_code
         ,dbl.fault_code
         ,dbl.period_from_date
         ,dbl.period_upto_date
         ,dbl.usec_code
         ,dbl.srvc_code
         ,dbl.srvc_size_code
         ,dbl.usec_srvc_disc_code
         ,dbl.usec_srvc_disc_amnt
         ,crl.scnd_type as cr_scnd_type
         ,dbl.task_code as cr_task_code
         ,dbl.sinv_code as cr_sinv_code
         ,crl.tran_date as cr_tran_date
         ,(crl.credit_amnt * -1) as cr_amnt
         ,crl.line_description as cr_line_description
         ,trim(substr(bll.cust_type_code,1,1))  cust_type_code  -- Mod 4398                          --'1.0.0.17'
         ,dbl.unbill_meter_ind                            -- Add 818
         ,dbl.meter_grp_rdg_id                            -- Add 818
         ,bll.copy_bill_ind                               -- Add 818
         ,dbl.meter_id            -- Add 1411  1.0.0.51
         ,bll.task_code            -- Add 2.0.0.0
         ,dbl.outreader_serial_no         -- Add 2.0.0.0
         ,dbl.chex_key            -- Add 2634
    from cis_bill_lines bll
        ,cis_debit_lines dbl
        ,cis_credit_lines crl
    where bll.tran_id = w_tran_id
      and bll.debit_line_id = dbl.debit_line_id(+)
      and bll.credit_line_id = crl.credit_line_id(+)
      and bll.process_id = w_process_id
      and bll.copy_for_3rd_party_ind is null          -- Add 4614
    order by decode(dbl.unbill_meter_ind, null, 'B', 'A'),  -- Add 818
             line_num;
    w_blln                        c_blln%rowtype;
    cursor c_blln_psb is
    select
          bll.acct_key
         ,bll.bill_format_code
         ,bll.bill_key
         ,bll.line_type
         ,bll.line_num
         ,bll.text_field
         ,bll.reading_grp_type
         ,bll.other_tran_id
         ,bll.other_tran_key
         ,bll.other_tran_date
         ,bll.other_tran_amnt
         ,dbl.tran_date
         ,dbl.scnd_type as db_scnd_type
         ,dbl.task_code as db_task_code
         ,dbl.sinv_code as db_sinv_code
         ,dbl.line_tot_amnt as db_line_tot_amnt
         ,dbl.retail_amnt as db_amnt
         ,dbl.line_description as db_line_description
         ,dbl.tax1_amnt as db_tax1_amnt
         ,dbl.line_outst_ind as db_line_outst_ind
         ,dbl.ppln_ind as db_ppln_ind
         ,dbl.tran_qty
         ,dbl.orig_tran_qty                                -- Add 818
         ,substr(dbl.meter_key, 1, 7) as meter_key         -- Chg 1.0.0.07
         ,dbl.meter_key as meter_key_10chr   							 -- Add 11138
         ,dbl.meter_reg_num
         ,dbl.reading_type                                 -- add 542
         ,dbl.meter_reading
         ,dbl.reading_datime
         ,dbl.prior_last_billed_reading
         ,dbl.prior_last_billed_rdg_datime                 -- Add 1129
         ,dbl.prior_last_real_bld_rdg_datime               -- Add 2109 --2.0.0.07 --1.0.0.68
         ,dbl.prior_last_real_billed_reading               -- Add 2109 --2.0.0.07 --1.0.0.68
         ,dbl.meter_advance
         ,dbl.prior_last_reading
         ,dbl.prior_estimates_cnt
         ,dbl.prior_estimates_cons_qty                      -- Add 1129
         ,dbl.meter_works_id                                -- Add 1129
         ,dbl.est_reading_ind
         ,dbl.uom_code
         ,dbl.fault_code
         ,dbl.period_from_date
         ,dbl.period_upto_date
         ,dbl.usec_code
         ,dbl.srvc_code
         ,dbl.srvc_size_code
         ,dbl.usec_srvc_disc_code
         ,dbl.usec_srvc_disc_amnt
         ,crl.scnd_type as cr_scnd_type
         ,dbl.task_code as cr_task_code
         ,dbl.sinv_code as cr_sinv_code
         ,crl.tran_date as cr_tran_date
         ,(crl.credit_amnt * -1) as cr_amnt
         ,crl.line_description as cr_line_description
         ,trim(substr(bll.cust_type_code,1,1)) cust_type_code   -- Add 4398  --'1.0.0.17'
         ,dbl.unbill_meter_ind                            -- Add 818
         ,dbl.meter_grp_rdg_id                            -- Add 818
         ,bll.copy_bill_ind                               -- Add 818
         ,dbl.meter_id            -- Add 1411  1.0.0.51
     ,bll.task_code            -- Add 2.0.0.0
     ,dbl.outreader_serial_no         -- Add 2.0.0.0
     ,dbl.chex_key            -- Add 2634
    from cis_bill_lines bll
        ,cis_psb_debit_lines dbl
        ,cis_psb_credit_lines crl
    where bll.tran_id = w_tran_id
      and bll.debit_line_id = dbl.debit_line_id(+)
      and bll.credit_line_id = crl.credit_line_id(+)
      and bll.process_id = w_process_id
      and bll.copy_for_3rd_party_ind is null              -- Add 4614
    order by decode(dbl.unbill_meter_ind, null, 'B', 'A'),-- Add 818
             line_num;
  --                      --Add 2.0.0.0
  -- Next Read Record                --Add 2.0.0.0
    type nr_rec is record                                             --Add 2.0.0.0
   (round_key       varchar2(20)                             --Add 2.0.0.0
       ,next_mtr_read_date   date                                     --Add 2.0.0.0
   );                                                             --Add 2.0.0.0
  type nr_tbl is table of nr_rec index by binary_integer;           --Add 2.0.0.0
  w_nr_tbl          nr_tbl;                                         --Add 2.0.0.0
  --                       --Add 2.0.0.10
  -- Graph Qty and reading Record             --Add 2.0.0.10
    --Del 2437 type grp_rec is record                                  --Add 2.0.0.10
  --Del 2437  (qty       number                               --Add 2.0.0.10
    --Del 2437    ,est_reading_ind  char(1)                            --Add 2.0.0.10
  --Del 2437  );                                                     --Add 2.0.0.10
  --Del 2437 type grp_tbl is table of grp_rec index by binary_integer; --Add 2.0.0.10
  --Del 2437 w_grp_tbl         grp_tbl;                              --Add 2.0.0.10
  --                      --Add 2.0.0.10
  -- Graph Qty and reading Record                --Add 2.0.0.10
    type grp_rec is record                                            --Add 2.0.0.10
   (qty        number                                --Add 2.0.0.10
       ,est_reading_ind   char(1)                                   --Add 2.0.0.10
   ,month              number            --Add 2437
   ,seq        number            --Add 2437
   );
  type grp_tbl is table of grp_rec index by binary_integer;         --Add 2.0.0.10
  w_grp_tbl         grp_tbl;                                        --Add 2.0.0.10
  ---w_month_not_found  boolean   := true;        --Add 2.0.0.10 --Del 2437
  w_current_month  varchar2(6) := '000000';       --Add 2.0.0.15
  w_tbl_cntr    number      := 0;          --Add 2437
  --                      --Add 2.0.0.23
  --                      --Add 2.0.0.23
  type hol_rec is record                --Add 2.0.0.23
  (                                                                 --Add 2.0.0.23
   cal_code      varchar2(8)                                      --Add 2.0.0.23
   ,hol_date      date                                            --Add 2.0.0.23
   ,hol_desc      varchar2(30)                                    --Add 2.0.0.23
   ,rdg_ind       varchar2(1)                                     --Add 2.0.0.23
   ,bill_ind      varchar2(1)                                     --Add 2.0.0.23
  );                                                                --Add 2.0.0.23
  type hol_tbl is table of hol_rec index by binary_integer;         --Add 2.0.0.23
  w_hol_tbl         hol_tbl;                                        --Add 2.0.0.23
   --Start Add 3706
   w_btrn_ctr                    number := 0;
   indx                          varchar2(30);
   type bill_trn_rec is record
      (
       tran_id       cis_bill_trans.tran_id%type
      ,cust_id       cis_bill_trans.cust_id%type
      ,inst_id       cis_bill_trans.inst_id%type
      ,supply_type   cis_bill_trans.supply_type%type
      );
   type bill_trn_tbl is table of bill_trn_rec index by binary_integer;
   w_bill_trn_tbl    bill_trn_tbl;
   type bill_trn_srt_rec is record
      (
       cust_id             cis_bill_trans.cust_id%type
      ,inst_id             cis_bill_trans.inst_id%type
      ,wtr_supply_type     cis_bill_trans.supply_type%type
      ,wtr_tran_id         cis_bill_trans.tran_id%type
      ,agncy_supply_type   cis_bill_trans.supply_type%type
      ,agncy_tran_id       cis_bill_trans.tran_id%type
      );
   type bill_trn_srt_tbl is table of bill_trn_srt_rec index by varchar2(30);
   w_bill_trn_srt_tbl    bill_trn_srt_tbl;
   --End Add 3706
   w_char_billed_qty_01    varchar2(15);  --Add 3908
   w_char_billed_qty_02    varchar2(15);  --Add 3908
   w_char_billed_qty_03    varchar2(15);  --Add 3908
   w_char_billed_qty_04    varchar2(15);  --Add 3908
   w_char_billed_qty_05    varchar2(15);  --Add 3908
   w_char_billed_qty_06    varchar2(15);  --Add 3908
   w_char_billed_qty_07    varchar2(15);  --Add 3908
   w_char_billed_qty_08    varchar2(15);  --Add 3908
   w_char_billed_qty_09    varchar2(15);  --Add 3908
   w_char_billed_qty_10    varchar2(15);  --Add 3908
   w_char_billed_qty_11    varchar2(15);  --Add 3908
   w_char_billed_qty_12    varchar2(15);  --Add 3908
   w_char_billed_qty_13    varchar2(15);  --Add 3908
   w_char_billed_qty_14    varchar2(15);  --Add 3908
   w_char_billed_qty_15    varchar2(15);  --Add 3908
   w_char_billed_qty_16    varchar2(15);  --Add 3908
   w_char_billed_qty_17    varchar2(15);  --Add 3908
   w_char_billed_qty_18    varchar2(15);  --Add 3908
   w_char_billed_qty_19    varchar2(15);  --Add 3908
   w_char_billed_qty_20    varchar2(15);  --Add 3908
   w_char_billed_qty_21    varchar2(15);  --Add 3908
   w_char_billed_qty_22    varchar2(15);  --Add 3908
   w_char_billed_qty_23    varchar2(15);  --Add 3908
   w_char_billed_qty_24    varchar2(15);  --Add 3908
   w_bad_check_fee         varchar2(20);  --Add 3706
   w_line_items            number;        --Add 3706
   w_big_three_cnt         number;        --Add 3706
   w_othr_fees_crds_flg    varchar2(1);   --Add 3706
   w_agr_exists            varchar2(1);   --Add 3706
   w_int_attr19            cis_ta_inst_v.attribute19%type;    -- Add 3706
   w_int_attr29            cis_ta_inst_v.attribute29%type;    -- Add 3706
   w_conc_4_zeros          number;        --Add 3706
   w_round_key             cis_rounds.round_key%type;         -- Add 3706
   indx_rpl_tbl            number;        --Add 3706
   counter_4_rpl_tbl       number;        --Add 3706
   /* Start Add 4398 */
   l_new_bamnt                   cis_bill_lines.bill_amnt%type;        --Add 4398
   l_new_bcbamnt                 cis_bill_lines.closing_bal_amnt%type; --Add 4398
   l_bill_key                    cis_bill_lines.bill_key%type;         --Add 4398
   w_bill_id                     cis_bills.bill_id%type;               --Add 4398
   w_seq_no                        number       := 0;                  --Add 4398
   /* Start End 4398 */
  --
  --Bill Message Record
  --
		/* Star Add 9918 */
		g_kub_task_cd_str     varchar2(1000); --Add start 9918c
		g_kub_2char_task_cd   varchar2(500);  --Add start 9918c
		g_prev_bill_tran_id		cis_accounts.prev_bill_tran_id%type;
		g_is_auto_auto				number;
		g_prev_bill_pnlty_dt  date;
		g_prev_bill_wt_bal   	number;
		g_prev_bill_ag_bal   	number;
    g_prev_bill_hl_bal 		number;
    g_is_wtr_auto_auto		number;
    g_is_agn_auto_auto		number;
    g_is_hlp_auto_auto		number;
		g_wtr_cnt							number;
		g_agn_cnt							number;
		g_hlp_cnt							number;
		--select * from cis.cis_topt_all where upper(task_desc) like '%KUBRA%' or task_code like '%99%' or task_code like 'KP%'
		cursor gc_kub_pndg_pymnt is
		  select pendpay_id,pendpay_key,creation_date,acct_key,amnt
		    from phl_kubra_pending_payments
		   where acct_key in (w_ptbm.acct_key,w_rchl.agrv_hl_acct_key,w_rchl.agrv_rc_acct_key)
		     and creation_date <= (nvl(w_ptbm.billing_date,sysdate))
		     and creation_date >= (nvl(w_ptbm.billing_date,sysdate)-gp_pnd_pymt_cal_days)  --10483 changed from 10 to 20 days--9918C Steve
		     and type_cd = 'P'	--9918b  from Alina/Steve (you either included the AP or included the pending payment coded with type code 'X' which needs to be ignored, we only want to include pending payments with type code 'P')
		   order by creation_date desc, acct_key;
		/*  --Del 9918C  --Not used
		cursor gc_kub_fut_pndg_pymnt is
		  select acct_key,latestpaymentdate,currautopayamnt,currautopymtdt
		   from phl_stgin_kubra_hist
		   where seq_no in
		  (
		  select max(seq_no) from phl_stgin_kubra_hist
		  where (w_ptbm.acct_key is not null and acct_key = w_ptbm.acct_key)
		    and latestpaymentdate is not null
		    and status = 'PROCESSED'
		    --and latestpaymentdate >= nvl(w_ptbm.billing_date,sysdate) --Billing Date
		    --and latestpaymentdate <= g_prev_bill_pnlty_dt --Take last record but not for current bill
		  union
		  select max(seq_no) from phl_stgin_kubra_hist
		  where (w_rchl.agrv_hl_acct_key is not null and acct_key = w_rchl.agrv_hl_acct_key)
		    and latestpaymentdate is not null
		    and status = 'PROCESSED'
		    and latestpaymentdate >= nvl(w_ptbm.billing_date,sysdate) --Billing Date
		    and latestpaymentdate <= g_prev_bill_pnlty_dt --Take last record but not for current bill
		  union
		  select max(seq_no) from phl_stgin_kubra_hist
		  where (w_rchl.agrv_rc_acct_key is not null and acct_key  = w_rchl.agrv_rc_acct_key)
		    and latestpaymentdate is not null
		    and status = 'PROCESSED'
		    and latestpaymentdate >= nvl(w_ptbm.billing_date,sysdate) --Billing Date
		    and latestpaymentdate <= g_prev_bill_pnlty_dt --Take last record but not for current bill
		  );
		*/ --Del 9918C  --Not used
    type g_pndg_pymt_dt_rec is record
   (
    creation_date    phl_kubra_pending_payments.creation_date%type
   );
   type g_pndg_pymt_dt_tbl is table of g_pndg_pymt_dt_rec index by binary_integer;
	 g_pn_py_cr_dt_wtr_tbl	g_pndg_pymt_dt_tbl;
	 g_pn_py_cr_dt_agn_tbl	g_pndg_pymt_dt_tbl;
	 g_pn_py_cr_dt_hlp_tbl	g_pndg_pymt_dt_tbl;
		/* End Add 9918 */
	 --Start revamp 11192
	 --Start Add 10495
	 --g_type_cd cis.phl_kubra_usage_alerts.type_cd%type;
	 --cursor c_tgt_dt is select max(alert_trigger_dt) alert_trigger_dt --Chng 11192
		--	                  from cis.phl_kubra_usage_alerts
		--	                 where acct_key = w_ptbm.acct_key
		--	                   and type_cd in ('L','Z','H') -- 'X'  --Chng Add 11192
		--	                   and months_between(w_ptbm.billing_date,to_date(trim(substr(alert_trigger_dt,1,10)),'YYYY-MM-DD')) between -0.000001 and 1.000001
		--	                   and (e_alert_sent = 'Y' or paper_alert_needed = 'Y')
   --;
	 --End Add 10495
	 --End revamp 11192
    deadlock_detected             exception;
    resource_busy                 exception;
    dbp_fatal                     exception;
    dbp_error                     exception;
    pragma exception_init(deadlock_detected, -60); -- Deadlock
    pragma exception_init(resource_busy, -54);     -- Resource Busy
    pragma exception_init(dbp_fatal, -20998);      -- Database Package Fatal Error
    pragma exception_init(dbp_error, -20999);      -- Database Package Error
 		--Start Add 9106
 		--*************************************************************************************
    -- public procedure debug_ttid
 		--*************************************************************************************
		procedure debug_ttid(p_ttid varchar2 default null, p_procedure_name varchar2 default null,p_label in varchar2, p_param varchar2)
		is
			w_procedure_name       varchar2(20) := 'phls0001.debug';
		begin
		 	w_label := p_label;
		 	if gp_ttid = '-1' then
		   	if w_message_trace_level  >= 10 then
		     	ciss0074.trace(nvl(p_procedure_name, w_procedure_name), w_label, nvl(p_param,'...'));
		   	end if;
		 	else
		 	 	if nvl(p_ttid,-1) = gp_ttid then
			   	if w_message_trace_level  >= 7 then
			     	ciss0074.trace(nvl(p_procedure_name, w_procedure_name), w_label, nvl(p_param,'...'));
			   	end if;
			 	end if;
		 	end if;
		end debug_ttid;
 		--Start Add 9106
 /*************************************************************************************\
    Add 1251
    public function get_version
 \*************************************************************************************/
 function get_version return varchar2 is
 begin
    return w_version;
 end get_version;
 --Start Add 10846
 /*************************************************************************************\
    public function get_version
 \*************************************************************************************/
 function get_dont_need_dup_id return boolean is
 begin
    return gp_dont_need_dup_id;
 end get_dont_need_dup_id;
 --End Add 10846
 --*************************************************************************************
    -- public procedure debug
 --*************************************************************************************
 procedure debug(p_procedure_name varchar2 default null,p_label in varchar2, p_param varchar2)
 is
   w_procedure_name       varchar2(20) := 'phls0001.debug';
 begin
	 w_label := p_label;
   if w_message_trace_level  >= 10 then
     --fnd_file.put_line(fnd_file.log,nvl(p_procedure_name, w_procedure_name) ||':'||w_label||':'|| nvl(p_param,'...')); --9620 Removed from unconditional tracing Bill Performance
     ciss0074.trace(nvl(p_procedure_name, w_procedure_name), w_label, nvl(p_param,'...'));
   end if;
 end debug;
 /*************************************************************************************\
    procedure trace_label
 \*************************************************************************************/
 procedure trace_label(p_label in varchar2, p_procedure_name varchar2 default null) is
    w_procedure_name              varchar2(50) := 'phls0001.trace_label';
 begin
    w_label := p_label;
    --local_testing(w_label|| ' :-trace point') ;
    if w_message_trace_level >= 10 then
       --fnd_file.put_line(fnd_file.log,nvl(p_procedure_name, w_procedure_name) ||':'||w_label||':'|| 'trace point'); --9620 Removed from unconditional tracing Bill Performance
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
    w_procedure_name              varchar2(50) := 'phls0001.debug_trace';
 begin
   if dbms_flag then
      --dbms_output.put_line(nvl(p_procedure_name, w_procedure_name) ||':'||w_label||':'|| msg ); --9620 Bill Performance
      null;
   end if;
   if log_flag then
      --fnd_file.put_line(fnd_file.log,nvl(p_procedure_name, w_procedure_name) ||':'||w_label||':'|| msg ); --9620 Removed from unconditional tracing Bill Performance
      null;
   end if;
  --
  -- ciss0001.write_message                                                      -- Add 1.0.0.19
  --                    (
  --                     p_procedure_name  => w_procedure_name
  --                    ,p_mesg_code       => 'DEBUG_TRACE'
  --                    ,p_mesg_text       => w_label ||' ' || msg
  --                    ,p_statement_label => w_label
  --                    );
  --
   if w_message_trace_level >= 10 then
      ciss0074.trace(nvl(p_procedure_name,w_procedure_name), w_label, msg);
   end if;
 end debug_trace;
 /*************************************************************************************\
    procedure am5d(p_msg varchar2)
 \*************************************************************************************/
 --procedure am5d(p_msg varchar2) is
 --begin
 -- if dbms_flag or log_flag then
 --  if length(w_ptbm.message_4 || '|'|| p_msg) < 4000 then
 --   w_ptbm.message_5 := w_ptbm.message_5 || '|'|| p_msg;
 --  end if;
 -- end if;
 --end am5d;
 --Start Add 3706
 /*************************************************************************************\
    function date3chrmnth (convert date to 3 character months
 \*************************************************************************************/
 function date3chrmnth(p_date in date) return varchar2 is
 begin
    if p_date is null then
       return null;
    else
       return trim(trim(to_char(p_date,'Mon')) ||' '||trim(to_char(p_date,'DD')) ||', ' ||trim(to_char(p_date,'YYYY'))) ;
    end if;
 end date3chrmnth;
 --End Add 3706
 --Start Add 3706
 /*************************************************************************************\
    function datefullc (convert date to full date character for full date messages only)
 \*************************************************************************************/
 function datefullc(p_date in date) return varchar2 is
 begin
    if p_date is null then
       return null;
    else
       return trim(trim(to_char(p_date,'Month')) ||' '||trim(to_char(p_date,'DD')) ||', ' ||trim(to_char(p_date,'YYYY'))) ;
    end if;
 end datefullc;
 --End Add 3706
 /*************************************************************************************\
    function datec (convert date to character for datec messages only)
 \*************************************************************************************/
 function datec(p_date in date) return varchar2 is
 begin
    if p_date is null then
       return null;
    else
       return to_char(p_date,'mm/dd/yy');
    end if;
 end datec;
 /*Add Start 6230B*/
 procedure suppress_future_pnlty is
   w_procedure_name              varchar2(50) := 'phls0001.supress_future_pnlty';
 begin
   /*
   --No penalties for the TAP_Groups 1,2 and 5
   */
   debug_trace(w_procedure_name,'...w_tap_bill_print.group_num =' || w_tap_bill_print.group_num);
   if nvl(w_tap_bill_print.group_num,-1) in (1,2,5) then
      --
      --Suppress Penalties and
      --
      w_ptbm.penalty_amnt     := 0;
      w_ptbm.penalty_due_amnt := 0;
      --
      --
      --
   end if;
 end;
 /*End Start 6230B*/
 --Add start 6230
 /*************************************************************************************\
    function datec (convert date to character for datec messages only)
 \*************************************************************************************/
 function dateyyyymmdd(p_date in date) return varchar2 is
 begin
    if p_date is null then
       return null;
    else
       return to_char(p_date,'yyyymmdd');
    end if;
 end dateyyyymmdd;
 --End start 6230
 --Start Add 7080
 procedure reset_shut_off_var is
    w_procedure_name              varchar2(50) := 'phls0001.reset_shut_off_var';
 begin
 		g_wtr_access_code := null;
 end reset_shut_off_var;
 --End Add 7080
 --Start Add 8000_8044
 /*************************************************************************************\
    function is_line_not_on_ppln(p_tran_id in number) return boolean
 \*************************************************************************************/
 function is_line_not_on_ppln(p_tran_id in number) return boolean is
      l_line_ppln_id cis_transactions.ppln_id%type;
 begin
      if w_blln.other_tran_id is null then return true; end if;
      select ppln_id into l_line_ppln_id from cis.cis_transactions where tran_id = w_blln.other_tran_id;
      if l_line_ppln_id is not null then
         return false;
      else
         return true;
      end if;
 exception
    when no_data_found then
       return true;
    when others then
       return true;
 end is_line_not_on_ppln;
 --End Add 8000_8044
 /*************************************************************************************\
    function booleanc (convert boolean to character for booleanc messages only)
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
    private procedure performance_statistics       -- Add 1.0.0.27
 ************************************************************************************/
 procedure performance_statistics(p_type varchar2) is
    w_procedure_name              varchar2(50) := 'phls0001.performance_statistics';
 begin
      trace_label('e001', w_procedure_name);
       if w_dev_mode then return; end if;  --Add 7055
       debug_trace(w_procedure_name,'w_dev_mode = ' || booleanc(w_dev_mode));
      trace_label('e002', w_procedure_name);
    if p_type = 'BILLS'
    then
 --      dbms_lock.sleep(120);
       dbms_stats.gather_table_stats(
                                      ownname          => 'CIS'
                                     ,tabname          => 'CIS_BILL_LINES'
                                     ,method_opt       => 'FOR ALL INDEXED COLUMNS SIZE 254'
                                     ,estimate_percent => 35
                                     ,degree           => DBMS_STATS.AUTO_DEGREE
                                     ,cascade          => TRUE
                                     ,granularity      => 'DEFAULT'
                                    );
       w_label := 'e003';
       execute immediate 'alter system flush shared_pool';
       w_label := 'e004';
       /* Start Del 3706
       dbms_stats.gather_table_stats(
                                      ownname          => 'CIS'
                                     ,tabname          => 'PHL_TMG_BILL_MASTER'
                                     ,method_opt       => 'FOR ALL INDEXED COLUMNS SIZE 254'
                                     ,estimate_percent => 35
                                     ,degree           => DBMS_STATS.AUTO_DEGREE
                                     ,cascade          => TRUE
                                     ,granularity      => 'DEFAULT'
                                    );
       --Start Del 3706 */
       --Start Add 3706
       dbms_stats.gather_table_stats(
                                      ownname          => 'CIS'
                                     ,tabname          => 'PHL_BILL_PRINT_HIST'
                                     ,method_opt       => 'FOR ALL INDEXED COLUMNS SIZE 254'
                                     ,estimate_percent => 35
                                     ,degree           => DBMS_STATS.AUTO_DEGREE
                                     ,cascade          => TRUE
                                     ,granularity      => 'DEFAULT'
                                    );
       --End Add 3706
       w_label := 'e005';
       execute immediate 'alter system flush shared_pool';
       w_label := 'e006';
       --dbms_stats.set_table_stats('CIS','PHL_TMG_BILL_MASTER',NUMROWS=>100000000,NUMBLKS=>250000); --Del 3706
       dbms_stats.set_table_stats('CIS','PHL_BILL_PRINT_HIST',NUMROWS=>100000000,NUMBLKS=>250000); --Add 3706
       w_label := 'e007';
       execute immediate 'alter system flush shared_pool';
    elsif p_type = 'ARREARS'
    then
       dbms_stats.gather_table_stats(
                                      ownname          => 'CIS'
                                     ,tabname          => 'CIS_TMP_ARREARS_SUMMARY'
                                     ,method_opt       => 'FOR ALL INDEXED COLUMNS SIZE 254'
                                     ,estimate_percent => 35
                                     ,degree           => DBMS_STATS.AUTO_DEGREE
                                     ,cascade          => TRUE
                                     ,granularity      => 'DEFAULT'
                                    );
       w_label := 'e008';
       execute immediate 'alter system flush shared_pool';
       w_label := 'e009';
       dbms_stats.gather_table_stats(
                                      ownname          => 'CIS'
                                     ,tabname          => 'CIS_METER_WOS'
                                     ,method_opt       => 'FOR ALL INDEXED COLUMNS SIZE 254'
                                     ,estimate_percent => 35
                                     ,degree           => DBMS_STATS.AUTO_DEGREE
                                     ,cascade          => TRUE
                                     ,granularity      => 'DEFAULT'
                                    );
       w_label := 'e010';
       execute immediate 'alter system flush shared_pool';
       w_label := 'e011';
       dbms_stats.set_table_stats('CIS','CIS_TMP_ARREARS_SUMMARY',NUMROWS=>100000000,NUMBLKS=>250000);
       w_label := 'e012';
       execute immediate 'alter system flush shared_pool';
    end if;
 end performance_statistics;
 --Start Add 8020
 function get_onlycity(p_address2 cis_addresses.address2%type) return varchar2
 is
    w_procedure_name              varchar2(50) := 'phls0001.get_onlycity';
    cursor l1 is
		 select regexp_substr(g_city_phila_str,'[^|]+', 1, level) col1
	     from dual
		   connect BY regexp_substr(g_city_phila_str, '[^|]+', 1, level)
		   is not null;
 begin
		if p_address2 is null then
		   return 'PHILADELPHIA';
	  elsif trim(p_address2) = 'HUNTINGDON VALLEY' then
	     return 'HUNTINGDON VALLEY';
	  elsif trim(p_address2) = 'GLENSIDE' then
	  	 return 'GLENSIDE';
	  elsif trim(p_address2) = 'WYNDMOOR' then
	  	 return 'WYNDMOOR';
	  elsif trim(p_address2) = 'LAFAYETTE HILL' then
	  	 return 'LAFAYETTE HILL';
	  else
			--Here string is parsed by | as a delimiter
	    for r1 in l1
	    loop
				if instr(p_address2,r1.col1) <> 0 then
					 return 'PHILADELPHIA';
				end if;
			end loop;
			--Here string is parsed by space as a delimiter
			for r2 in (	select regexp_substr(p_address2,'[^ ]+', 1, level) col1
									  from dual
									connect BY regexp_substr(p_address2, '[^ ]+', 1, level)
									is not null
								)
			loop
					return r2.col1;
			end loop;
		end if;
    return p_address2;
 end get_onlycity;
--End Add 8020
 /*************************************************************************************
    private procedure load_ref_data
 ************************************************************************************/
 procedure load_ref_data is
    w_procedure_name              varchar2(50) := 'phls0001.load_ref_data';
 begin
    w_label := 'e013';
    trace_label(w_label, w_procedure_name);
    if w_ref_data_loaded then
       return;
    end if;
    w_label := 'e014';
    trace_label(w_label, w_procedure_name);
    ciss0034.init(p_who_fields_only=>false);
    w_label := 'e015';
    trace_label(w_label, w_procedure_name);
    w_label := 'e016';
    trace_label(w_label, w_procedure_name);
    phls0005.init;
    if fnd_global.user_id <> -1 then
       w_message_trace_level := nvl(FND_PROFILE.VALUE('CIS_TRACE_LEVEL'), 0);
    end if;
    -- Del PJT    w_message_trace_level := 10; --Comment latter Raj
    if w_message_trace_level > 0 then
       debug_trace (w_procedure_name, 'version='||w_version ||', message_trace_level='||w_message_trace_level);
    end if;
    w_label := 'e017';
    trace_label(w_label, w_procedure_name);
    --Start Add 7055
   --Decide whether to allow test accounts to be slected
   w_dev_sid := nvl(FND_PROFILE.VALUE('PHL_DEV_SID'),'xxx');
   select name into w_cur_sid from v$database;
   debug_trace(w_procedure_name,'w_cur_sid = ' || w_cur_sid);
	 gp_dev_sid := w_dev_sid; --Add 9106
   gp_cur_sid := w_cur_sid; --Add 9106
   if instr(w_dev_sid,w_cur_sid) <> 0
   then
      w_dev_mode := true;
      gp_dev_mode := true;    --Add 9106
   else                     	--Add 9106
      w_dev_mode  := false;		--Add 9106
      gp_dev_mode := false;   --Add 9106
      gp_ttid     := '-1';   	--Add 9106
   end if;
    --End Add 7055
    /* start del 11138
    --Start Add  10266
    w_label := 'e018';
    trace_label(w_label, w_procedure_name);
    debug_trace (w_procedure_name, 'phls0001.gp_deply_rts_tbl.count 	-->' || phls0001.gp_deply_rts_tbl.count);
    if phls0001.gp_deply_rts_tbl.count <> 0 then
	    begin
		    g_mtr_rec_tbl.delete;
		    for lc_mtrs in gc_mtrs
		    loop
		    	 g_mtr_rec_tbl(lc_mtrs.meter_id).meter_id  						:= lc_mtrs.meter_id;								--Chng 11138	Chng Index from lc_mtrs.meter_key_7chr to lc_mtrs.meter_id
		    	 g_mtr_rec_tbl(lc_mtrs.meter_id).meter_key 						:= lc_mtrs.meter_key;								--Chng 11138	Chng Index from lc_mtrs.meter_key_7chr to lc_mtrs.meter_id
		    	 g_mtr_rec_tbl(lc_mtrs.meter_id).meter_key_7chr 			:= lc_mtrs.meter_key_7chr;					--Chng 11138	Chng Index from lc_mtrs.meter_key_7chr to lc_mtrs.meter_id
		    	 g_mtr_rec_tbl(lc_mtrs.meter_id).outreader_type_code 	:= lc_mtrs.outreader_type_code;			--Chng 11138	Chng Index from lc_mtrs.meter_key_7chr to lc_mtrs.meter_id
			     debug_trace (w_procedure_name, 'lc_mtrs.meter_id 					 													-->' || lc_mtrs.meter_id);
			     debug_trace (w_procedure_name, 'lc_mtrs.outreader_type_code 													-->' || lc_mtrs.outreader_type_code);
			     debug_trace (w_procedure_name, 'g_mtr_rec_tbl(lc_mtrs.meter_id).outreader_type_code 	-->' || g_mtr_rec_tbl(lc_mtrs.meter_id).outreader_type_code);
		    end loop;
			exception
				when others then
					g_mtr_rec_tbl.delete;
			end;
		end if;
		--End Add 10266
		--end del 11138 */
    --Start Add 8020
    g_city_phila_str := 'PHILADELPHIA|PHLADELPHIA|PHLILADELPHIA|PHLIADELPHIA|PHLIA|PHLA|PHILLY|PHILLADELPIA|PHILDELPHIA|PHILDADELPHIA|PHILAP|PHILAELPHIA|PHILADLPHIA|PHILADLHPIA|PHILADLEPHIA|PHILADEPLHIA|PHILADEPHIA|PHILADELPLHIA|PHILADELPIA|PHILADELPHIS|PHILADELPHIOA|PHILADELPHILA|PHILADELPHIIA|PHILADELPHIA`|PHILADELPHIAQ|PHILADELPHIAP|PHILADELPHHIA|PHILADELPHA|PHILADELLPHIA|PHILADELHPIA|PHILADELHPA|PHILADELHIA|PHILADELEPHIA|PHILADEL;PHIA|PHILAADELPHIA|PHILA|PHIILADELPHIA|PHIILA|PHIALDELPHIA|PHIADELPHIA|PHHILADELPHIA';
    --End Add 8020
    w_ref_data_loaded := true;
 end load_ref_data;
 --Start Add 7164D
 function TAP_Acct return boolean is
   w_procedure_name              varchar2(50) := 'phls0001.TAP_Acct';
 begin
    debug_trace (w_procedure_name, 'value of w_pay_profile_code_orig ' || w_pay_profile_code_orig);
      if nvl(w_pay_profile_code_orig,'X') != 'TAP-STD' then return true; else return false; end if;
 end;
 --End Add 7164D
 --Start 7164D
 function get_Bill_Hdr return varchar2 is
   w_procedure_name              varchar2(50) := 'phls0001.get_Bill_Hdr';
   l_bill_hdr_str                       cis.phl_bill_print_hist.background_print_string%type;
 begin
    l_bill_hdr_str :=
              'BILL_KEY'                              --BILL_KEY
          || '|BILLING_DATE'                          --BILLING_DATE
          || '|INCL_PAYMENTS_DATE'                    --INCL_PAYMENTS_DATE
          || '|PAYMENT_DUE_DATE'                      --PAYMENT_DUE_DATE
          || '|ACCT_KEY'                              --ACCT_KEY
          || '|BILL_ACCOUNT_NUMBER'                   --BILL_ACCOUNT_NUMBER
          || '|CUST_NAME'                             --CUST_NAME
          || '|CUST_TYPE_CODE'                        --CUST_TYPE_CODE
          || '|INST_TYPE_CODE'                        --INST_TYPE_CODE
          || '|PAYS_BY_ZIPCHECK'                      --PAYS_BY_ZIPCHECK
          || '|MAIL_NAME'                             --MAIL_NAME
          || '|MAIL_ADDR_LINE1'                       --MAIL_ADDR_LINE1
          || '|MAIL_ADDR_LINE2'                       --MAIL_ADDR_LINE2
          || '|MAIL_ADDR_LINE3'                       --MAIL_ADDR_LINE3
          || '|MAIL_ADDR_LINE4'                       --MAIL_ADDR_LINE4
          || '|MAIL_ADDR_LINE5'                       --MAIL_ADDR_LINE5
          || '|MAIL_POSTAL_CODE'                      --MAIL_POSTAL_CODE
          || '|MAIL_POSTAL_BARCODE'                   --MAIL_POSTAL_BARCODE
          || '|INST_ADDR_LINE1'                       --INST_ADDR_LINE1
          || '|METER_KEY'                             --METER_KEY
          || '|SRVC_SIZE_CODE'                        --SRVC_SIZE_CODE
          || '|BILL_SERVICE'                          --BILL_SERVICE
          || '|READING_FROM_DATE'                     --READING_FROM_DATE
          || '|READING_UPTO_DATE'                     --READING_UPTO_DATE
          || '|LAST_BILLED_READING'                   --LAST_BILLED_READING
          || '|THIS_BILLED_READING'                   --THIS_BILLED_READING
          || '|BILLED_QTY'                            --BILLED_QTY
          || '|REPL_METER_KEY'                        --REPL_METER_KEY
          || '|REPL_SRVC_SIZE_CODE'                   --REPL_SRVC_SIZE_CODE
          || '|REPL_BILL_SERVICE'                     --REPL_BILL_SERVICE
          || '|REPL_RDG_FROM_DATE'                    --REPL_RDG_FROM_DATE
          || '|REPL_RDG_UPTO_DATE'                    --REPL_RDG_UPTO_DATE
          || '|REPL_LAST_BILLED_RDG'                  --REPL_LAST_BILLED_RDG
          || '|REPL_THIS_BILLED_RDG'                  --REPL_THIS_BILLED_RDG
          || '|REPL_BILLED_QTY'                       --REPL_BILLED_QTY
          || '|PREVIOUS_BALANCE_AMNT'                 --PREVIOUS_BALANCE_AMNT
          || '|CURRENT_CHARGE_AMNT'                   --CURRENT_CHARGE_AMNT
          || '|USG_CHARGE_AMNT'                       --USG_CHARGE_AMNT
          || '|SVC_CHARGE_AMNT'                       --SVC_CHARGE_AMNT
          || '|DISCOUNT_LABEL'                        --DISCOUNT_LABEL
          || '|DISCOUNT_AMNT'                         --DISCOUNT_AMNT
          || '|LAST_PAID_DATE'                        --LAST_PAID_DATE
          || '|LAST_PAID_AMNT'                        --LAST_PAID_AMNT
          || '|TOTAL_DUE_AMNT'                        --TOTAL_DUE_AMNT
          || '|PENALTY_AMNT'                          --PENALTY_AMNT
          || '|PENALTY_DUE_AMNT'                      --PENALTY_DUE_AMNT
          || '|PENALTY_DATE'                          --PENALTY_DATE
          || '|SCAN_STRING'                           --SCAN_STRING
          || '|HDR_MESG_1'                            --HDR_MESG_1
          || '|HDR_MESG_2'                            --HDR_MESG_2
          || '|HDR_MESG_3'                            --HDR_MESG_3
          || '|HDR_MESG_4'                            --HDR_MESG_4
          || '|MESSAGE_1'                             --MESSAGE_1
          || '|MESSAGE_2'                             --MESSAGE_2
          || '|MESSAGE_3'                             --MESSAGE_3
          || '|MESSAGE_4'                             --MESSAGE_4
          || '|GRPH_MESG1'                            --GRPH_MESG1
          || '|BQTY_01'                               --BQTY_01
          || '|BQTY_02'                               --BQTY_02
          || '|BQTY_03'                               --BQTY_03
          || '|BQTY_04'                               --BQTY_04
          || '|BQTY_05'                               --BQTY_05
          || '|BQTY_06'                               --BQTY_06
          || '|BQTY_07'                               --BQTY_07
          || '|BQTY_08'                               --BQTY_08
          || '|BQTY_09'                               --BQTY_09
          || '|BQTY_10'                               --BQTY_10
          || '|BQTY_11'                               --BQTY_11
          || '|BQTY_12'                               --BQTY_12
          || '|BQTY_13'                               --BQTY_13
          || '|BQTY_14'                               --BQTY_14                                               --Add 3706
          || '|BQTY_15'                               --BQTY_15                                               --Add 3706
          || '|BQTY_16'                               --BQTY_16                                               --Add 3706
          || '|BQTY_17'                               --BQTY_17                                               --Add 3706
          || '|BQTY_18'                               --BQTY_18                                               --Add 3706
          || '|BQTY_19'                               --BQTY_19                                               --Add 3706
          || '|BQTY_20'                               --BQTY_20                                               --Add 3706
          || '|BQTY_21'                               --BQTY_21                                               --Add 3706
          || '|BQTY_22'                               --BQTY_22                                               --Add 3706
          || '|BQTY_23'                               --BQTY_23                                               --Add 3706
          || '|BQTY_24'                               --BQTY_24                                               --Add 3706
          || '|BLBL_01'                               --BLBL_1
          || '|BLBL_02'                               --BLBL_2
          || '|BLBL_03'                               --BLBL_3
          || '|BLBL_04'                               --BLBL_4
          || '|BLBL_05'                               --BLBL_5
          || '|BLBL_06'                               --BLBL_6
          || '|BLBL_07'                               --BLBL_7
          || '|BLBL_08'                               --BLBL_8
          || '|BLBL_09'                               --BLBL_9
          || '|BLBL_10'                               --BLBL_10
          || '|BLBL_11'                               --BLBL_11
          || '|BLBL_12'                               --BLBL_12
          || '|BLBL_13'                               --BLBL_13
          || '|BLBL_14'                               --BLBL_14                                               --Add 3706
          || '|BLBL_15'                               --BLBL_15                                               --Add 3706
          || '|BLBL_16'                               --BLBL_16                                               --Add 3706
          || '|BLBL_17'                               --BLBL_17                                               --Add 3706
          || '|BLBL_18'                               --BLBL_18                                               --Add 3706
          || '|BLBL_19'                               --BLBL_19                                               --Add 3706
          || '|BLBL_20'                               --BLBL_20                                               --Add 3706
          || '|BLBL_21'                               --BLBL_21                                               --Add 3706
          || '|BLBL_22'                               --BLBL_22                                               --Add 3706
          || '|BLBL_23'                               --BLBL_23                                               --Add 3706
          || '|BLBL_24'                               --BLBL_24                                               --Add 3706
          || '|BFLG_01'                               --BFLG_1
          || '|BFLG_02'                               --BFLG_2
          || '|BFLG_03'                               --BFLG_3
          || '|BFLG_04'                               --BFLG_4
          || '|BFLG_05'                               --BFLG_5
          || '|BFLG_06'                               --BFLG_6
          || '|BFLG_07'                               --BFLG_7
          || '|BFLG_08'                               --BFLG_8
          || '|BFLG_09'                               --BFLG_9
          || '|BFLG_10'                               --BFLG_10
          || '|BFLG_11'                               --BFLG_11
          || '|BFLG_12'                               --BFLG_12
          || '|BFLG_13'                               --BFLG_13
          || '|BFLG_14'                               --BFLG_14                                               --Add 3706
          || '|BFLG_15'                               --BFLG_15                                               --Add 3706
          || '|BFLG_16'                               --BFLG_16                                               --Add 3706
          || '|BFLG_17'                               --BFLG_17                                               --Add 3706
          || '|BFLG_18'                               --BFLG_18                                               --Add 3706
          || '|BFLG_19'                               --BFLG_19                                               --Add 3706
          || '|BFLG_20'                               --BFLG_20                                               --Add 3706
          || '|BFLG_21'                               --BFLG_21                                               --Add 3706
          || '|BFLG_22'                               --BFLG_22                                               --Add 3706
          || '|BFLG_23'                               --BFLG_23                                               --Add 3706
          || '|BFLG_24'                               --BFLG_24                                               --Add 3706
          || '|BILLED_YY_01'                          --BILLED_YY_01                                          --Add 3706
          || '|ADJUST'                                --ADJUST
          || '|LIEN'                                  --LIEN
          || '|STORMCHG'                              --STORMCHG
          || '|INDUSCHG'                              --INDUSCHG
          || '|PYMTAGREE'                             --PYMTAGREE
          || '|EST_LAST_RDG_FLAG'                     --EST_LAST_RDG_FLAG
          || '|EST_THIS_RDG_FLAG'                     --EST_THIS_RDG_FLAG
          || '|EST_REPL_LAST_RDG_FLAG'                --EST_REPL_LAST_RDG_FLAG
          || '|EST_REPL_THIS_RDG_FLAG'                --EST_REPL_THIS_RDG_FLAG
          || '|WRBCCCRED'                             --WRBCCCRED
          || '|WRBCCPMT'                              --WRBCCPMT
          || '|LATE_PMT_PENALTY'                      --LATE_PMT_PENALTY
          || '|PAY_ADJ_TOTAL'                         --PAY_ADJ_TOTAL
          || '|TOTAL_BAL'                             --TOTAL_BAL
          || '|ERT_KEY'                               --ERT_KEY
          || '|REPL_ERT_KEY'                          --REPL_ERT_KEY
          || '|TOT_CRED'                              --TOT_CRED                                                           --Add 2402
          || '|IMB_TRACKING'                          --IMB_TRACKING                                                       --Add 3409
          || '|IMB_ROUTING'                           --IMB_ROUTING                                                        --Add 3409
          || '|NUS_CHRG'                              --NUS_CHRG                                                           --Add 3706
          || '|MTR_CHRG'                              --MTR_CHRG                                                           --Add 3706
          || '|HLP_LOAN'                              --HLP_LOAN                                                           --Add 3706
          || '|STRM_WTR_CHG_FR_DT'                    --STRM_WTR_CHG_FR_DT                                                 --Add 3659
          || '|STRM_WTR_CHG_TO_DT'                    --STRM_WTR_CHG_TO_DT                                                 --Add 3659
          || '|FIRE_SRVC_CHG_AMNT'                    --FIRE_SRVC_CHG_AMNT                                                 --Add 3127
          || '|FIR_SRV_CHG_FR_DT'                     --FIR_SRV_CHG_FR_DT                                                  --Add 3706
          || '|FIR_SRV_CHG_TO_DT'                     --FIR_SRV_CHG_TO_DT                                                  --Add 3706
          || '|AGR_DT'                                --AGR_DT                                                             --Add 3706
          || '|AGR_AMNT'                              --AGR_AMNT                                                           --Add 3706
          || '|AGR_DOWNPYM_DT'                        --AGR_DOWNPYM_DT                                                     --Add 3706
          || '|AGR_DOWNPYM_AMNT'                      --AGR_DOWNPYM_AMNT                                                   --Add 3706
          || '|AGR_1STPYM_DT'                         --AGR_1STPYM_DT                                                      --Add 3706
          || '|AGR_1STPYM_AMNT'                       --AGR_1STPYM_AMNT                                                    --Add 3706
          || '|AGR_2NDPYM_DT'                         --AGR_2NDPYM_DT                                                      --Add 3706
          || '|AGR_2NDPYM_AMNT'                       --AGR_2NDPYM_AMNT                                                    --Add 3706
          || '|AGR_3RDPYM_DT'                         --AGR_3RDPYM_DT                                                      --Add 3706
          || '|AGR_3RDPYM_AMNT'                       --AGR_3RDPYM_AMNT                                                    --Add 3706
          || '|AGR_4THPYM_DT'                         --AGR_4THPYM_DT                                                      --Add 3706
          || '|AGR_4THPYM_AMNT'                       --AGR_4THPYM_AMNT                                                    --Add 3706
          || '|AGR_5THPYM_DT'                         --AGR_5THPYM_DT                                                      --Add 3706
          || '|AGR_5THPYM_AMNT'                       --AGR_5THPYM_AMNT                                                    --Add 3706
          || '|AGR_6THPYM_DT'                         --AGR_6THPYM_DT                                                      --Add 3706
          || '|AGR_6THPYM_AMNT'                       --AGR_6THPYM_AMNT                                                    --Add 3706
          || '|AGR_7THPYM_DT'                         --AGR_7THPYM_DT                                                      --Add 3706
          || '|AGR_7THPYM_AMNT'                       --AGR_7THPYM_AMNT                                                    --Add 3706
          || '|AGR_BAL_AMNT'                          --AGR_BAL_AMNT                                                       --Add 3706
          || '|SRVC_PERIOD'                           --SRVC_PERIOD                                                        --Add 3706
          || '|UN_PAID_PRV_BAL'                       --UN_PAID_PRV_BAL                                                    --Add 3706
          || '|GAL_USED_PER_DAY'                      --GAL_USED_PER_DAY                                                   --Add 3706
          || '|REPL_GAL_USED_PER_DAY'                 --REPL_GAL_USED_PER_DAY                                              --Add 3706
          || '|INST_POSTAL_CODE'                      --INST_POSTAL_CODE                                                   --Add 3706
          || '|BAD_CHECK_FEE'                         --BAD_CHECK_FEE                                                      --Add 3706
          || '|CITY_GRANT'                            --CITY_GRANT                                                         --Add 3706
          || '|CRISIS_GRANT'                          --CRISIS_GRANT                                                       --Add 3706
          || '|LIHEAP_GRANT'                          --LIHEAP_GRANT                                                       --Add 3706
          || '|UESF_GRANT'                            --UESF_GRANT                                                         --Add 3706
          || '|NO_OF_LINE_ITEMS'                      --NO_OF_LINE_ITEMS                                                   --Add 3706
          || '|BIG_THREE_CNT'                         --BIG_THREE_CNT                                                      --Add 3706
          || '|OTHR_FEES_CRDS_FLG'                    --OTHR_FEES_CRDS_FLG                                                 --Add 3706
          || '|SEW_REN_FCT_DIS'                       --SEW_REN_FCT_DIS                                                    --Add 3706
          || '|SURCHG_FLG'                            --SURCHG_FLG                                                         --Add 3706
          || '|TOT_BILL_RDG'                          --TOT_BIL_RDG                                                        --Add 3706
          || '|GRP_MSSG_AGR01'                        --GRP_MSSG_AGR01                                                     --Add 3706
          || '|AGR_OTHR_PYMNTS_AMNT'                  --AGR_OTHR_PYMNTS_AMNT                                               --Add 3706
          || '|DCR_FNT_SZ_AMNT_HDRS'                  --DCR_FNT_SZ_AMNT_HDRS                                               --Add 3706
          || '|3_MNT_PYMNT_DUE_DT'                    --3_MNT_PYMNT_DUE_DT                                                 --Add 3706
          || '|USG_LINE_HDNG'                         --USG_LINE_HDNG                                                      --Add 3706
          || '|CUR_CHG_SOLID_LINE_FLG'                --CUR_CHG_SOLID_LINE_FLG                                             --Add 4608
          || '|UNPAID_BAL_LBL'                        --UNPAID_BAL_LBL                                                     --Add 4575
          || '|TP_PRV_UNPAID_BL'                      --TP_PRV_UNPAID_BL         --TAP Previous unpaid balance             --Add 6721
          || '|TP_DISC'                               --TP_DISC                  --TAP Discount                                                              --Add 6230
          || '|TP_CHG'                                --TP_CHG                   --TAP_Charge                                                                --Add 6230
          || '|TP_TOTUSSV_CHG'                        --TP_TOTUSSV_CHG           --Sum total charges from adjustment records for current continuous          --Add 6230
          || '|TP_TOT_CHG'                            --TP_TOT_CHG               --Difference between these two amounts above and below                      --Add 6230
          || '|TP_TOT_SAVD_AMNT'                      --TP_TOT_SAVD_AMNT         --Sum of the adjustment amounts for the same period                         --Add 6230
          || '|TP_TOT_PST_DU_PAID_AMNT'               --TP_TOT_PST_DU_PAID_AMNT  --Sum of all receipts (via allocation records) minus any TAP bills paid     --Add 6230
          || '|TP_EF_CNT'                             --TP_EF_CNT                --Earned Penalty forgiveness counter EF_PAID_FACTOR from history view                                          --Add 6230
          || '|TP_RCTFY_DT'                           --TP_RCTFY_DT              --Expected end date from the current TAP application                        --Add 6230
          || '|TP_PYMS_2_ARRS'                        --TP_PYMS_2_ARRS           --TAP Payments towards Arrears                                                                     --Add 7055
          || '|PYMAGR_DUE_LBL'                        --PYMAGR_DUE_LBL           --Payment Agreement Due Label                                                                     --Add 7055
          || '|DISP_AMNT'                             --DISP_AMNT                --Dispute Amount                                                                                --Add7164D
    			|| '|WTR_TOTAL_BAL'													--WTR_TOTAL_BAL						 --Water Total Balance      							 --Add 8020
    			|| '|WTR_TOTAL_DUE_AMNT'										--WTR_TOTAL_DUE_AMNT			 --Water Total Due Amount 								 --Add 8020
    			|| '|WAH_TOTAL_BAL'													--WAH_TOTAL_BAL						 --Water Agency Helploan Total Balance     --Add 8020
    			|| '|WAH_TOTAL_DUE_AMNT'										--WAH_TOTAL_DUE_AMNT			 --Water Agency Helploan Total Due Amount  --Add 8020
    			|| '|EBILL_IND'															--EBILL_IND								 --eBill Indicator 												 --Add 8020
    			|| '|NO_OF_PGS'                             --NO_OF_PGS                --Number of Pages                         --Add 8020
    			|| '|INST_CITY'															--INST_CITY								 --CITY for Installation Address					 --Add 8020
    			|| '|INST_ADDR_ID'													--ADDR ID for INST ADDR		 --ADDR ID for Installation Address        --Add 8020
          || '|LOOT_IND'															--LOOT IND								 --Landlord, Owner, Occuper and Tenant Ind --Add 8020B
          || '|AUTO_PAY_IND'													--AUTO_PAY_IND						 --Auto Pay Indicator 										 --Add 8020B
          || '|DUP_IND'																--DUP_IND									 --Duplicate Indicator										 --Add 8020F
          || '|NEXT_WTR_AUTO_PAY_AMNT'								--NEXT_WTR_AUTO_PAY_AMNT	 --Next Water Auto Pay Amount              --Add 9918
          || '|NEXT_AGN_AUTO_PAY_AMNT'								--NEXT_AGN_AUTO_PAY_AMNT	 --Next Agency Auto Pay Amount             --Add 9918
          || '|NEXT_HLP_AUTO_PAY_AMNT'								--NEXT_HLP_AUTO_PAY_AMNT	 --Next HelpLoan Auto Pay Amount           --Add 9918
          || '|AR_ACCTKEY'                            --AR_ACCTKEY   						 --AGENCY RECEIVABLES Basis2 Account Key   --Add 4398
          || '|AR_OPNBAL'                             --AR_OPNBAhL    					 --AR Repair Charge Opening Balance        --Add 4398
          || '|AR_ADJAMT'                             --AR_ADJAMT     					 --AR Repair Charge Adjacement Amnt                    --Add 4398
          || '|AR_UNPAMT'                             --AR_UNPAMT     					 --AR UnPaid Amnt
          || '|AR_5INVFPDS'                           --AR_5INVFPDS   					 --AR 5TH Invoice Front Page desc                      --Add 4398
          || '|AR_5INVBPDS'                           --AR_5INVBPDS   					 --AR 5TH Invoice Back Page desc                       --Add 4398
          || '|AR_5INVBAL'                            --AR_5INVBAL    					 --AR 5TH Invoice bal                                  --Add 4398
          || '|AR_5FLG'                               --AR_5FLG       					 --AR 5TH INVOICE FLAG                                 --Add 4398
          || '|AR_4INVFPDS'                           --AR_4INVFPDS   					 --AR 5TH Invoice Front Page desc                      --Add 4398
          || '|AR_4INVBPDS'                           --AR_4INVBPDS   					 --AR 5TH Invoice Back Page desc                       --Add 4398
          || '|AR_4INVBAL'                            --AR_4INVBAL    					 --AR 4TH Invoice bal                                  --Add 4398
          || '|AR_4FLG'                               --AR_4FLG       					 --AR 4TH INVOICE FLAG                                 --Add 4398
          || '|AR_3INVFPDS'                           --AR_3INVFPDS   					 --AR 5TH Invoice Front Page desc                      --Add 4398
          || '|AR_3INVBPDS'                           --AR_3INVBPDS   					 --AR 5TH Invoice Back Page desc                       --Add 4398
          || '|AR_3INVBAL'                            --AR_3INVBAL    					 --AR 3RD Invoice bal                                  --Add 4398
          || '|AR_3FLG'                               --AR_3FLG       					 --AR 3RD INVOICE FLAG                                 --Add 4398
          || '|AR_2INVFPDS'                           --AR_2INVFPDS   					 --AR 2ND Invoice Front Page desc                      --Add 4398
          || '|AR_2INVBPDS'                           --AR_2INVBPDS   					 --AR 2ND Invoice Back Page desc                       --Add 4398
          || '|AR_2INVBAL'                            --AR_2INVBAL    					 --AR 2ND Invoice bal                                  --Add 4398
          || '|AR_2FLG'                               --AR_2FLG       					 --AR 2ND INVOICE FLAG                                 --Add 4398
          || '|AR_1INVFPDS'                           --AR_1INVFPDS   					 --AR 2ND Invoice Front Page desc                      --Add 4398
          || '|AR_1INVBPDS'                           --AR_1INVBPDS   					 --AR 2ND Invoice Back Page desc                       --Add 4398
          || '|AR_1INVBAL'                            --AR_1INVBAL    					 --AR 1ST Invoice bal                                  --Add 4398
          || '|AR_1FLAG'                              --AR_1FLAG      					 --AR 1ST INVOICE FLAG                                 --Add 4398
          || '|AR_RMBLFP'                             --AR_RMBLFP     					 --AR REMAINING BALANC (Only current)                  --Add 4398
          || '|AR_RMBLBP'                             --AR_RMBLBP     					 --AR TOTAL INVOICE BALANCE (current + Previous)       --Add 4398
          || '|AR_TOADBP'                             --AR_TOADBP     					 --AR TOTAL ADJACEMENT                                 --Add 4398
          || '|AR_TOPYBP'                             --AR_TOPYBP     					 --AR TOTAL PAYMENTS                                   --Add 4398
          || '|AR_CLSBAL'                             --AR_CLSBAL     					 --AR Repaire Charge Closing Balance                   --Add 4398
          || '|HL_ACCTKEY'                            --HL_ACCTKEY    					 --HL BASIS2 ACCOUNT KEY                               --Add 4398
          || '|HL_OPNBAL'                             --HL_OPNBAL     					 --HL Opening Balance                                  --Add 4398
          || '|HL_ADJAMT'                             --HL_ADJAMT     					 --HL Adjacement Amnt                                  --Add 4398
          || '|HL_PYMAMT'                             --HL_PYMAMT     					 --HL Adjacement Amnt                                  --Add 4398
          || '|HL_PYMDT'                              --HL_PYMDT      					 --HL Payment Date                                     --Add 4398
          || '|HL_UNPAMT'                             --HL_UNPAMT     					 --HL UnPaid Amnt                                      --Add 4398
          || '|HL_UNPLBL'                             --HL_UNPLBL     					 --HL UnPaid Label                                     --Add 4398
          || '|HL_PLNDUE'                             --HL_PLNDUE     					 --HL Plan Due                                         --Add 4398
          || '|HL_CORR_LBL'                           --HL_CORR_LBL   					 --HL Correction Label                                 --Add 4398
          || '|HL_CORR_PPLN_AMNT'                     --HL_CORR_PPLN_AMNT 			 --HL Correction PPLN AMNT                        	   --Add 4398
          || '|HL_INVBAL'                             --HL_INVBAL    						 --HL Total Invoice Balance                            --Add 4398
          || '|HL_PNLTY'                              --HL_PNLTY     --HL Current penalty for this Bill                    --Add 4398
          || '|HL_CLSBAL'                             --HL_CLSBAL    --HL Closing Balance                                  --Add 4398
          || '|HL_TOTDUE'                             --HL_TOTDUE    --HL Total Duefor Current Bill                        --Add 4398
          || '|HL_AGSTDT'                             --HL_AGSTDT    --HL Plan Agreement Start Date                        --Add 4398
          || '|HL_AGRAMT'                             --HL_AGRAMT    --HL PLAN TOTAL AMOUNT                                --Add 4398
          || '|HL_OTHDBT'                             --HL_OTHDBT    --HL Other debt (Penalty + Adjacement)                --Add 4398
          || '|HL_5MIDT'                              --HL_5MIDT     --HL 5 Monthly Installment Received Date              --Add 4398
          || '|HL_4MIDT'                              --HL_4MIDT     --HL 4 Monthly Installment Received Date              --Add 4398
          || '|HL_3MIDT'                              --HL_3MIDT     --HL 3 Monthly Installment Received Date              --Add 4398
          || '|HL_2MIDT'                              --HL_2MIDT     --HL 2 Monthly Installment Received Date              --Add 4398
          || '|HL_1MIDT'                              --HL_1MIDT     --HL 1 Monthly Installment Received Date              --Add 4398
          || '|HL_5MIAMT'                             --HL_5MIAMT    --HL 5 Monthly Installment Amount Received            --Add 4398
          || '|HL_4MIAMT'                             --HL_4MIAMT    --HL 4 Monthly Installment Amount Received            --Add 4398
          || '|HL_3MIAMT'                             --HL_3MIAMT    --HL 3 Monthly Installment Amount Received            --Add 4398
          || '|HL_2MIAMT'                             --HL_2MIAMT    --HL 2 Monthly Installment Amount Received            --Add 4398
          || '|HL_1MIAMT'                             --HL_1MIAMT    --HL 1 Monthly Installment Amount Received            --Add 4398
          || '|HL_REMAMT'                             --HL_REMAMT    --HL Remaining Monthly Installment Amount  Received   --Add 4398
          || '|HL_PPLN_BAL_AMT'                       --HL_PPLN_BAL_AMT --HL PLAN BALANCE AMOUNT
          || '|HL_MSGHD1'                             --HL_MSGHD1    --HL Message Header 1                                 --Add 4398
          || '|HL_MSGHD2'                             --HL_MSGHD2    --HL Message Header 2                                 --Add 4398
          || '|HL_MSGHD3'                             --HL_MSGHD3    --HL Message Header 3                                 --Add 4398
          || '|HL_MSGHD4'                             --HL_MSGHD4    --HL Message Detail 4                                 --Add 4398
          || '|HL_MSGDT1'                             --HL_MSGDT1    --HL Message Detail 1                                 --Add 4398
          || '|HL_MSGDT2'                             --HL_MSGDT2    --HL Message Detail 2                                 --Add 4398
          || '|HL_MSGDT3'                             --HL_MSGDT3    --HL Message Detail 3                                 --Add 4398
          || '|HL_MSGDT4'                             --HL_MSGDT4    --HL Message Detail 4                                 --Add 4398
          || '|HL_SCANLN'                             --HL_SCANLN    --HL Scan Line                                        --Add 4398
          || '|TOT_DISP_AMNT'													--TOT_DISP_AMNT		--Total Dispute Amount										 				 --Add 10846 Add 9792
          || '|PEN_FRGV_MSSG'													--PEN_FRGV_MSSG	 --Penalty Forgiveness Messages            					 --Add 10846 Add 9984
          || '|PRN_FRGV_MSSG'													--PRN_FRGV_MSSG	 --Principal Forgiveness Messages          					 --Add 10846 Add 9984
          || '|TP_BF_CNT'                             --TP_BF_CNT      --Earned Principal forgiveness counter 						 --Add 10846 Add 9984 	--BF_PAID_FACTOR from history view
          ;
      return l_bill_hdr_str;
   end get_Bill_Hdr;
 --End 7164D
 --Start Add 4562
 /*************************************************************************************
    private procedure ld_vld_rt_bill_days
  ************************************************************************************/
 procedure ld_vld_rt_bill_days is
    w_procedure_name              varchar2(50) := 'phls0001.ld_vld_rt_bill_days';
    j_lcl varchar2(10):=0;
    k_lcl varchar2(10):=0;
    l_lcl varchar2(10):=0;
 begin
    trace_label('e019', w_procedure_name);
    w_vld_rts_bill_dts_tbl.delete;
    for i in 1 .. 20
    loop
      j_lcl := trim(to_char(i,'000'));
      k_lcl := trim(to_char(i+20,'000'));
      l_lcl := trim(to_char(i+40,'000'));
      w_vld_rts_bill_dts_tbl(i).rt# := trim(j_lcl||','||k_lcl||','||l_lcl);
      w_vld_rts_bill_dts_tbl(i).vld_low_day     := i;
      w_vld_rts_bill_dts_tbl(i).vld_upr_day     := i+11;
    	trace_label('e020', w_procedure_name);
      /*
      if     i = 01 then
         w_vld_rts_bill_dts_tbl(i).rt#             := '001,021,041';
         w_vld_rts_bill_dts_tbl(i).vld_low_day     := 1;
         w_vld_rts_bill_dts_tbl(i).vld_upr_day     := 12;
      elsif  i = 02 then
         w_vld_rts_bill_dts_tbl(i).rt#             := '002,022,042';
         w_vld_rts_bill_dts_tbl(i).vld_low_day     := 2;
         w_vld_rts_bill_dts_tbl(i).vld_upr_day     := 13;
      elsif  i = 03 then
         w_vld_rts_bill_dts_tbl(i).rt#             := '003,023,043';
         w_vld_rts_bill_dts_tbl(i).vld_low_day     := 3;
         w_vld_rts_bill_dts_tbl(i).vld_upr_day     := 14;
      elsif  i = 04 then
         w_vld_rts_bill_dts_tbl(i).rt#             := '004,024,044';
         w_vld_rts_bill_dts_tbl(i).vld_low_day     := 4;
         w_vld_rts_bill_dts_tbl(i).vld_upr_day     := 15;
      elsif  i = 05 then
         w_vld_rts_bill_dts_tbl(i).rt#             := '005,025,045';
         w_vld_rts_bill_dts_tbl(i).vld_low_day     := 5;
         w_vld_rts_bill_dts_tbl(i).vld_upr_day     := 16;
      elsif  i = 06 then
         w_vld_rts_bill_dts_tbl(i).rt#             := '006,026,046';
         w_vld_rts_bill_dts_tbl(i).vld_low_day     := 6;
         w_vld_rts_bill_dts_tbl(i).vld_upr_day     := 17;
      elsif  i = 07 then
         w_vld_rts_bill_dts_tbl(i).rt#             := '007,027,047';
         w_vld_rts_bill_dts_tbl(i).vld_low_day     := 7;
         w_vld_rts_bill_dts_tbl(i).vld_upr_day     := 18;
      elsif  i = 08 then
         w_vld_rts_bill_dts_tbl(i).rt#             := '008,028,048';
         w_vld_rts_bill_dts_tbl(i).vld_low_day     := 8;
         w_vld_rts_bill_dts_tbl(i).vld_upr_day     := 19;
      elsif  i = 09 then
         w_vld_rts_bill_dts_tbl(i).rt#             := '009,029,049';
         w_vld_rts_bill_dts_tbl(i).vld_low_day     := 9;
         w_vld_rts_bill_dts_tbl(i).vld_upr_day     := 20;
      elsif  i = 10 then
         w_vld_rts_bill_dts_tbl(i).rt#             := '010,030,050';
         w_vld_rts_bill_dts_tbl(i).vld_low_day     := 10;
         w_vld_rts_bill_dts_tbl(i).vld_upr_day     := 21;
      elsif  i = 11 then
         w_vld_rts_bill_dts_tbl(i).rt#             := '011,031,051';
         w_vld_rts_bill_dts_tbl(i).vld_low_day     := 11;
         w_vld_rts_bill_dts_tbl(i).vld_upr_day     := 22;
      elsif  i = 12 then
         w_vld_rts_bill_dts_tbl(i).rt#             := '012,032,052';
         w_vld_rts_bill_dts_tbl(i).vld_low_day     := 12;
         w_vld_rts_bill_dts_tbl(i).vld_upr_day     := 23;
      elsif  i = 13 then
         w_vld_rts_bill_dts_tbl(i).rt#             := '013,033,053';
         w_vld_rts_bill_dts_tbl(i).vld_low_day     := 13;
         w_vld_rts_bill_dts_tbl(i).vld_upr_day     := 24;
      elsif  i = 14 then
         w_vld_rts_bill_dts_tbl(i).rt#             := '014,034,054';
         w_vld_rts_bill_dts_tbl(i).vld_low_day     := 14;
         w_vld_rts_bill_dts_tbl(i).vld_upr_day     := 25;
      elsif  i = 15 then
         w_vld_rts_bill_dts_tbl(i).rt#             := '015,035,055';
         w_vld_rts_bill_dts_tbl(i).vld_low_day     := 15;
         w_vld_rts_bill_dts_tbl(i).vld_upr_day     := 26;
      elsif  i = 16 then
         w_vld_rts_bill_dts_tbl(i).rt#             := '016,036,056';
         w_vld_rts_bill_dts_tbl(i).vld_low_day     := 16;
         w_vld_rts_bill_dts_tbl(i).vld_upr_day     := 27;
      elsif  i = 17 then
         w_vld_rts_bill_dts_tbl(i).rt#             := '017,037,057';
         w_vld_rts_bill_dts_tbl(i).vld_low_day     := 17;
         w_vld_rts_bill_dts_tbl(i).vld_upr_day     := 28;
      elsif  i = 18 then
         w_vld_rts_bill_dts_tbl(i).rt#             := '018,038,058';
         w_vld_rts_bill_dts_tbl(i).vld_low_day     := 18;
         w_vld_rts_bill_dts_tbl(i).vld_upr_day     := 29;
      elsif  i = 19 then
         w_vld_rts_bill_dts_tbl(i).rt#             := '019,039,059';
         w_vld_rts_bill_dts_tbl(i).vld_low_day     := 19;
         w_vld_rts_bill_dts_tbl(i).vld_upr_day     := 30;
      elsif  i = 20 then
         w_vld_rts_bill_dts_tbl(i).rt#             := '020,040,060';
         w_vld_rts_bill_dts_tbl(i).vld_low_day     := 20;
         w_vld_rts_bill_dts_tbl(i).vld_upr_day     := 31;
      end if;
      */
    end loop;
 end ld_vld_rt_bill_days;
 --End Add 4562
 --Start Add 2.0.0.23
  /*************************************************************************************\
    procedure load_holidays
 \*************************************************************************************/
 procedure load_holidays is
  cursor c1 is
  select * from cis_holidays order by hol_date desc;
  i binary_integer := 1;
 begin
  w_hol_tbl.delete;
  for r1 in c1
  loop
   w_hol_tbl(i).cal_code  :=  r1.cal_code;
   w_hol_tbl(i).hol_date  :=  r1.hol_date;
   w_hol_tbl(i).hol_desc  :=  r1.hol_desc;
   w_hol_tbl(i).rdg_ind   :=  r1.rdg_ind;
   w_hol_tbl(i).bill_ind  :=  r1.bill_ind;
   i := i + 1;
  end loop;
 end load_holidays;
 --End Add 2.0.0.23
 --Start add 5905 3.0.0.39
 /*************************************************************************************\
  function donot_print_rc
  returns true or false, if the
 \*************************************************************************************/
 function  donot_print_rc return boolean is
   w_procedure_name     varchar2(50) := 'phls0001.to_print_rc';
 begin
     if  nvl(w_rchl.agrv_rc_debt_to_exclude,0) = 0 then  --Add 6351
       return false;                                      --Add 6351
     else
        if nvl(w_ar_acct_bal,0) - nvl(w_rchl.agrv_rc_debt_to_exclude,0)  = 0 then  --Chg 6351
           return true;
        else
           return false;
        end if;
     end if;
 end;
 /*************************************************************************************\
  function donot_print_hl
  returns true or false, if the
 \*************************************************************************************/
 function  donot_print_hl return boolean is
   w_procedure_name     varchar2(50) := 'phls0001.to_print_hl';
 begin
     --Start Add 6351
     if nvl(w_rchl.agrv_hl_debt_to_exclude,0) = 0 then
        return false;
     else
        if nvl(w_hl_acct_bal,0) - nvl(w_rchl.agrv_hl_debt_to_exclude,0) <= 0 then  --Purposely, if -ve do not print.
           return true;
        else
           return false;
        end if;
     end if;
     --End Add 6351
     --Start Add del 6351
     /*
     if nvl(w_hl_acct_bal,0) <= nvl(w_rchl.agrv_hl_debt_to_exclude,0) then
        return true;
     else
        return false;
     end if;
     */
     --End Add del 6351
 end;
 --End add 5905 3.0.0.39
 --Start Add 2.0.0.23
  /*************************************************************************************\
    function next_valid_due_date
  We can use Basis2 package ciss0017.billing_date_plus_freq
  select ciss0017.billing_date_plus_freq('D1','STANDARD',w_rtn_date) into w_rtn_date from dual
 \*************************************************************************************/
 function  next_valid_due_date(p_date in date) return date is
   w_rtn_date           date;
   w_procedure_name     varchar2(50) := 'phls0001.next_valid_due_date';
 begin
  /* Start Add 4779 */
  w_rtn_date := p_date;
  if trim(to_char(w_rtn_date,'DAY')) = 'SATURDAY' then w_rtn_date := w_rtn_date + 2; end if;
  if trim(to_char(w_rtn_date,'DAY')) = 'SUNDAY'   then w_rtn_date := w_rtn_date + 1; end if;
  for i in 1 .. w_hol_tbl.count
  loop
      --debug(w_procedure_name,w_label,' w_hol_tbl(i).hol_date ' || w_hol_tbl(i).hol_date); --Del 2.0.0.24A
      if w_hol_tbl(i).hol_date = w_rtn_date then
         select ciss0017.billing_date_plus_freq('D1','STANDARD',w_rtn_date) into w_rtn_date from dual;
      end if;
      if w_hol_tbl(i).hol_date < w_rtn_date then
         exit;
      end if;
  end loop;
  --if trim(to_char(w_rtn_date,'DAY')) = 'SATURDAY' then w_rtn_date := w_rtn_date + 2; end if;
  --if trim(to_char(w_rtn_date,'DAY')) = 'SUNDAY'   then w_rtn_date := w_rtn_date + 1; end if;
  return w_rtn_date;
  /* End Add 4779 */
  /* Start Del 4779
  --debug(w_procedure_name,w_label,' p_date ' || datec(p_date));        --Del 2.0.0.24A
  --debug(w_procedure_name,w_label,' to_char(p_date,DAY) ' || to_char(p_date,'DAY') ); --Del 2.0.0.24A
  if trim(to_char(w_rtn_date,'DAY')) = 'SATURDAY' then w_rtn_date := w_rtn_date + 2; end if;
  if trim(to_char(w_rtn_date,'DAY')) = 'SUNDAY'   then w_rtn_date := w_rtn_date + 1; end if;
  for i in 1 .. w_hol_tbl.count
  loop
   --debug(w_procedure_name,w_label,' w_hol_tbl(i).hol_date ' || w_hol_tbl(i).hol_date); --Del 2.0.0.24A
   if w_hol_tbl(i).hol_date = w_rtn_date then
    w_rtn_date := w_rtn_date + 1;
   end if;
   if trim(to_char(w_rtn_date,'DAY')) = 'SATURDAY' then w_rtn_date := w_rtn_date + 2; end if;
   if trim(to_char(w_rtn_date,'DAY')) = 'SUNDAY'   then w_rtn_date := w_rtn_date + 1; end if;
   if w_rtn_date > w_hol_tbl(i).hol_date then
    exit;
   end if;
  end loop;
  --debug(w_procedure_name,w_label,' w_rtn_date ' || datec(w_rtn_date)); --Del 2.0.0.24A
    return w_rtn_date;
  --End Del 4779 */
 end  next_valid_due_date;
 --Strat Add 9918
  /*************************************************************************************\
    procedure load_kubra_tsk_cds
 \*************************************************************************************/
procedure load_kubra_tsk_cds is
 	 cursor l_kub_task_code is
     select * from cis.cis_topt_all where upper(task_desc) like '%KUBRA%' or task_code like '%99%' or task_code like 'KP%';
     l_task_code cis_topt_all.task_code%type := '<>#@!';
     l_2char     char(2);
   w_procedure_name		varchar2(50) := 'phls0001.load_kubra_tsk_cds';
begin
   trace_label('e021', w_procedure_name);
   for r1 in l_kub_task_code
   loop
      trace_label('e022', w_procedure_name);
		  if l_kub_task_code%rowcount = 1 then
		    g_kub_task_cd_str   := ''''||r1.task_code ||'''';
		    g_kub_2char_task_cd := ''''||substr(r1.task_code,1,2)||'''';
		    l_2char             := substr(r1.task_code,1,2);
		    debug_trace(w_procedure_name,'...KUBRA_TASKCD_STR   =' || g_kub_task_cd_str);
		    debug_trace(w_procedure_name,'...KUBRA_TASKCD_2CHAR =' || g_kub_2char_task_cd);
		  else
			  g_kub_task_cd_str :=  g_kub_task_cd_str ||','||''''||r1.task_code || '''';
			  if l_2char != substr(r1.task_code,1,2) then
			     l_2char := substr(r1.task_code,1,2);
			     g_kub_2char_task_cd := g_kub_2char_task_cd ||','||''''||substr(r1.task_code,1,2)||'''';
			  end if;
			  debug_trace(w_procedure_name,'...KUBRA_TASKCD_STR   =' || g_kub_task_cd_str);
			  debug_trace(w_procedure_name,'...KUBRA_TASKCD_2CHAR =' || g_kub_2char_task_cd);
		  end if;
   end loop;
   trace_label('e023', w_procedure_name);
end load_kubra_tsk_cds;
 -- End Add 9918
 --Start Add 2.0.0.23
  /*************************************************************************************\
    procedure load bill messages
 \*************************************************************************************/
 procedure load_bill_mssg is
  cursor c1 is
     select
            dtl.mesg_id mesg_id
           ,dtl.mesg_type
           ,dtl.mesg_num
           ,nvl(dtl.from_date,w_lo_date) from_date
           ,nvl(dtl.upto_date,w_hi_date) upto_date
           ,dtl.priority
           ,dtl.full_text
           ,(select hdr_full_text from phl_bill_mssg_hdr hdr where hdr.mesg_hdr_id = dtl.mesg_hdr_id) hdr_full_text --Add 3706
     --from phl_report_messages  --del 3706
     from phl_bill_mssg_dtl dtl     --Add 3706
     where dtl.mesg_type = w_get_billmssg_type -- w_get_bovermtr_type  ---'BILLMSSG'
       and nvl(dtl.priority,0) > 0
     order by dtl.priority;
  i  binary_integer := 1;
 begin
  w_bill_mssg_tbl.delete;      --Add 2.0.0.0 --Delete all preloaded messages
  for r1 in c1
  loop
   w_bill_mssg_tbl(i).mesg_id       := r1.mesg_id ;
   w_bill_mssg_tbl(i).mesg_type     := r1.mesg_type;
   w_bill_mssg_tbl(i).mesg_num      := r1.mesg_num ;
   w_bill_mssg_tbl(i).from_date     := r1.from_date;
   w_bill_mssg_tbl(i).upto_date     := r1.upto_date;
   w_bill_mssg_tbl(i).priority      := r1.priority ;
   w_bill_mssg_tbl(i).full_text     := r1.full_text;
   w_bill_mssg_tbl(i).hdr_full_text := r1.hdr_full_text;   --Add 3706
   i := i + 1;
  end loop;
 end load_bill_mssg;
/* Start Add 4398 */
 /*************************************************************************************\
    procedure load Help Loan messages
 \*************************************************************************************/
 procedure load_hpln_mssg is
  cursor c1 is
     select
            dtl.mesg_id mesg_id
           ,dtl.mesg_type
           ,dtl.mesg_num
           ,nvl(dtl.from_date,w_lo_date) from_date
           ,nvl(dtl.upto_date,w_hi_date) upto_date
           ,dtl.priority
           ,dtl.full_text
           ,(select hdr_full_text from phl_bill_mssg_hdr hdr where hdr.mesg_hdr_id = dtl.mesg_hdr_id) hdr_full_text
     from phl_bill_mssg_dtl dtl
     where dtl.mesg_type = w_get_hplnmssg_type -- ---'HELPLOAN'
       and nvl(dtl.priority,0) > 0
     order by dtl.priority;
  i  binary_integer := 1;
 begin
  w_hpln_mssg_tbl.delete;      --Add 2.0.0.0 --Delete all preloaded messages
  for r1 in c1
  loop
   w_hpln_mssg_tbl(i).mesg_id       := r1.mesg_id ;
   w_hpln_mssg_tbl(i).mesg_type     := r1.mesg_type;
   w_hpln_mssg_tbl(i).mesg_num      := r1.mesg_num ;
   w_hpln_mssg_tbl(i).from_date     := r1.from_date;
   w_hpln_mssg_tbl(i).upto_date     := r1.upto_date;
   w_hpln_mssg_tbl(i).priority      := r1.priority ;
   w_hpln_mssg_tbl(i).full_text     := r1.full_text;
   w_hpln_mssg_tbl(i).hdr_full_text := r1.hdr_full_text;   --Add 3706
   i := i + 1;
  end loop;
 end load_hpln_mssg;
/* Start End 4398 */
 --Start Add  11138
 /*************************************************************************************\
    procedure ld_mtrs
 \*************************************************************************************/
 procedure ld_mtrs is
    w_procedure_name              varchar2(50) := 'phls0001.ld_mtrs';
 begin
    w_label := 'e024';
    trace_label(w_label, w_procedure_name);
    --debug_trace (w_procedure_name, 'phls0001.gp_deply_rts_tbl.count 	-->' || phls0001.gp_deply_rts_tbl.count);
    if phls0001.gp_deply_rts_tbl.count <> 0 then
		    g_mtr_rec_tbl.delete;
		    for lc_mtrs in gc_mtrs
		    loop
			    begin
						g_mtr_rec_tbl(lc_mtrs.meter_id).meter_id  						:= lc_mtrs.meter_id;								--Chng 11138	Chng Index from lc_mtrs.meter_key_7chr to lc_mtrs.meter_id
						g_mtr_rec_tbl(lc_mtrs.meter_id).meter_key 						:= lc_mtrs.meter_key;								--Chng 11138	Chng Index from lc_mtrs.meter_key_7chr to lc_mtrs.meter_id
						g_mtr_rec_tbl(lc_mtrs.meter_id).meter_key_7chr 				:= lc_mtrs.meter_key_7chr;					--Chng 11138	Chng Index from lc_mtrs.meter_key_7chr to lc_mtrs.meter_id
						g_mtr_rec_tbl(lc_mtrs.meter_id).outreader_type_code 	:= lc_mtrs.outreader_type_code;			--Chng 11138	Chng Index from lc_mtrs.meter_key_7chr to lc_mtrs.meter_id
						--debug_trace (w_procedure_name, 'lc_mtrs.meter_id 					 														-->' || lc_mtrs.meter_id);
						--debug_trace (w_procedure_name, 'lc_mtrs.outreader_type_code 													-->' || lc_mtrs.outreader_type_code);
						--debug_trace (w_procedure_name, 'g_mtr_rec_tbl(lc_mtrs.meter_id).outreader_type_code 	-->' || g_mtr_rec_tbl(lc_mtrs.meter_id).outreader_type_code);
					exception
						when others then
					    debug_trace (w_procedure_name, 'Other Errors :: phls0001.gp_deply_rts_tbl.count 	-->' || phls0001.gp_deply_rts_tbl.count);
		  	      debug_trace (w_procedure_name, 'Other Errors :: lc_mtrs.meter_id 					 													-->' || lc_mtrs.meter_id);
					    debug_trace (w_procedure_name, 'Other Errors :: lc_mtrs.outreader_type_code 													-->' || lc_mtrs.outreader_type_code);
		 		   		debug_trace(w_procedure_name,'sqlerrm:' ||sqlerrm || 'sqlcode:' || sqlcode );
					end;
		    end loop;
		end if;
	end ld_mtrs;
	--End Add 11138
/* Start Add 9106 */
 /*************************************************************************************\
    procedure ld_dply_rts
 \*************************************************************************************/
 procedure ld_dply_rts is
    w_procedure_name              varchar2(20) := 'phls0001.ld_dply_rts';
    cursor lc_dply_rts# is
    select * from phl_pwd_dplymnt_pln order by route;
    l1 binary_integer := 1;
 begin
    gp_deply_rts_tbl.delete;
	 	for lr1 in lc_dply_rts#
	 	loop
	 	  begin
		 		l1 := to_number(lr1.route);
			  gp_deply_rts_tbl(l1).route       					:= lr1.route;
			  gp_deply_rts_tbl(l1).planned_start_date  	:= lr1.planned_start_date;
	 			--l1 := l1 + 1;
	 		exception
	 		   when others then
	 		   		debug_trace(w_procedure_name,'lr1.route 						 -->' || lr1.route);
	 		   		debug_trace(w_procedure_name,'sqlerrm:' ||sqlerrm || 'sqlcode:' || sqlcode );
	 		end;
	 	end loop;
 end ld_dply_rts;
/* End Add 9106 */
/* Start Add 9918 */
procedure load_kubra_inb_file is
	w_procedure_name  varchar2(50) := 'phls0001.load_kubra_inb_file';
	w_sql							varchar2(500);
begin
  null;
	/*
	w_sql := 'truncate table cis.phl_stgin_kubra_tmp';
	execute immediate w_sql;
	insert into cis.phl_stgin_kubra_tmp
	select * from phl_stgin_kubra_hist where (seq_no,acct_key)
	in
	(
	select max(seq_no) seq_no,acct_key
	 from phl_stgin_kubra_hist
	where prime_ind = 'Y'
	  and status    = 'PROCESSED'
	group by acct_key
	);
	*/
end load_kubra_inb_file;
/* Start End 9918 */
 /*************************************************************************************\
    procedure init
 \*************************************************************************************/
 procedure init is
    w_procedure_name              varchar2(20) := 'phls0001.init';
 begin
    trace_label('e025', w_procedure_name);
    w_process_id  := null;
    w_bill_format := null;
    w_tran_id := null;
    w_cust_id := null;
    w_inst_id := null;
    w_est_reading_ind := null;
    w_fault_code := null;
    w_last_reading_type := null;           -- Add 542
    w_cust_own_reading_ind := 'N';         -- Add 542
    w_last_cust_own_reading_ind := 'N';    -- Add 542
    w_low_date := to_date('01011900','ddmmyyyy');
    w_label := 'e026';
  	w_nr_tbl.delete;       --Add 2.0.0.0
  	load_bill_mssg;        --Add 2.0.0.0 -- Load all bill messages from phl_report_messages
  	load_hpln_mssg;        --Add 4398
  	load_holidays;         --Add 2.0.0.23
  	ld_vld_rt_bill_days;   --Add 4562
  	load_kubra_tsk_cds;    --Add 9918
  	load_kubra_inb_file;	 --Add 9918C
  	ld_dply_rts;					 --Add 9106
  	debug_trace (w_procedure_name, 'before ld_mtrs 	-->' || phls0001.gp_deply_rts_tbl.count);
  	ld_mtrs;							 --Add 11138
 end init;
 /*************************************************************************************\
    procedure reset
 \*************************************************************************************/
 procedure reset is
    w_procedure_name              varchar2(20) := 'phls0001.reset';
 begin
    trace_label('e027', w_procedure_name);
    w_index                      := 0;
    w_tbl_cntr                   := 0;       -- Add 2437
    w_inst_agr_exists            := 0;       -- Add 3706
    w_ptbm                       := null;
    w_est_reading_ind            := null;
    w_fault_code                 := null;
    w_acct_pay_method            := null;
    w_incid_code                 := null;
    w_ppln_id                    := null;
    w_ppln_type                  := null;    -- Add 1.0.0.21
    w_ppln_due_amnt              := null;
    w_ppln_no_due                := null;    -- Add 2212
    w_int_attr19                 := null;    -- Add 3706
    w_int_attr29                 := null;    -- Add 3706
    w_pay_profile_code_orig      := null;    -- Add 3706
    w_arrears_letter_no          := null;    -- Add 4563
    w_conc_4_zeros               := 0;       -- Add 3706
    w_round_key                  := null;    -- Add 3706
    w_usg_line_hdng              := null;    -- Add 3706
    w_usec_code                  := null;    -- Add 3706
    w_grnt_rcvd                  := 0;       -- Add 3706
    w_debt_bal_amnt_ues          := 0;       -- Add 3706
    w_debt_tot_amnt_ues          := 0;       -- Add 3706
    w_grph_mesg1                 := null;    -- Add 3706
    w_grph_mesg2                 := null;    -- Add 3706
    w_grph_mesg3                 := null;    -- Add 3706
    w_add_to_tot_qty             := 0;       -- Add 3706
    w_rchl                       := null;    -- Add 4398
    w_agr_curr_chgs              := 0;       -- Add 4398
    w_hlp_curr_chgs              := 0;       -- Add 4398
    w_max_crln_creation_date     := null;    -- Add 4398
    w_max_crln_id                := null;    -- Add 4398
    w_lst_pymnt_dt               := null;    -- Add 4398
    w_city_acct_4_WAT            := null;    -- Add 6130
    w_ar_acct_bal                := 0;       -- Add 5905 3.0.0.39
    w_hl_acct_bal                := 0;       -- Add 5905 3.0.0.39
    w_tap_bill_print             := null;    -- Add 6230 3.0.0.41
    w_tap_error_code             := null;    -- Add 6230 3.0.0.41
    w_tap_error_text             := null;    -- Add 6230 3.0.0.41
    w_hlrc_status                := null;    -- Add 6230 3.0.0.41
    w_amnt_disp_n_agr            := null;		 -- Add 7164D
    w_amnt_disp_pre_TAP          := null;		 -- Add 7164D
    w_amnt_disp_post_TAP         := null;    -- Add 7164D
    g_wtr_total_bal							 := null;		 -- Add 8020
    g_wtr_total_due_amnt    		 := null;    -- Add 8020
    g_wah_total_bal							 := null;    -- Add 8020
    g_wah_total_due_amnt				 := null;    -- Add 8020
    --g_bill_delivery_meth				 := null;		 -- Add 8020
    --g_ebill_ind									 := null;    -- Add 8020
    g_inst_city									 := null;		 -- Add 8020
    g_inst_addr_id							 := null;    -- Add 8020
    --g_auto_pay_4all_acs					 := null;		 --Del 8020F -- Add 8020
    g_trn_ifce_refn						 	 := null;		 -- Add 8020F -- Use to find rebill indicator
    g_trn_scnd_type						   := null;		 -- Add 8020F -- Use to find rebill indicator
		g_final_bill_ind 						 := null;		 -- Add 8020F -- Final bill indicator
		g_rebill_bill_ind 					 := null;		 -- Add 8020F -- rebill indicator
		g_loot_ind									 := null;		 -- Add 8020F -- Loot indicator need initialization
    /* End Add 4398 */
		--g_taphld_bal_amnt_frm_trn		 := 0;		   -- Add 9749
		--g_tappen_bal_amnt_frm_trn    := 0;       -- Add 9749
		--g_tap_lien									 := 0;       -- Add 9749
		/* -- Start Add 9918	*/
    g_prev_bill_tran_id					 := null;
		g_is_auto_auto							 := 0;
		g_prev_bill_pnlty_dt 				 := null;
		g_prev_bill_wt_bal   				 := 0;
		g_prev_bill_ag_bal   				 := 0;
    g_prev_bill_hl_bal 					 := 0;
    g_is_wtr_auto_auto				   := 0;
    g_is_agn_auto_auto				   := 0;
    g_is_hlp_auto_auto				   := 0;
		g_wtr_cnt										 := 0;
		g_agn_cnt										 := 0;
		g_hlp_cnt										 := 0;
		g_pn_py_cr_dt_wtr_tbl.delete; --9918b
	  g_pn_py_cr_dt_agn_tbl.delete; --9918b;
	  g_pn_py_cr_dt_hlp_tbl.delete; --9918b;
		g_outreader_type_code				 := null;		 -- Add 9106
	  g_disp_tot_amnt_not_in_agr	 := 0;			 --Add 9792
	  g_disp_tot_amnt_in_agr  		 := 0;			 --Add 9792
		/* -- End Add 9918	*/
		g_tap_pnlty_frgv_mssg					:= null;   --Add 9984
		g_tap_prin_frgv_mssg					:= null;   --Add 9984
		--g_pnlty_frgv_dt							 := null;			--Add 9984
		--g_pnlty_frgv_amnt						 := 0; 				--Add 9984
		--g_prin_frgv_dt							 := null;			--Add 9984
		--g_prin_frgv_amnt						 := 0;				--Add 9984
 	  g_s17_grnt_amnt										 := 0;       --Add 11413
 end reset;
 /*************************************************************************************\
    private procedure `s
 \*************************************************************************************/
 procedure insert_report_record is
    w_procedure_name              varchar2(50) := 'phls0001.insert_report_record';
 begin
    trace_label('e028', w_procedure_name);
    debug_trace(w_procedure_name,'Master');
    debug_trace(w_procedure_name,'...bill_key                 =' ||         w_ptbm.bill_key                   );
    --debug_trace(w_procedure_name,'...billing_date             =' ||   datec(w_ptbm.billing_date)              );
    --debug_trace(w_procedure_name,'...incl_payments_date       =' ||   datec(w_ptbm.incl_payments_date)        );
    --debug_trace(w_procedure_name,'...payment_due_date         =' ||   datec(w_ptbm.payment_due_date)          );
    --debug_trace(w_procedure_name,'...acct_key                 =' ||         w_ptbm.acct_key                   );
    --debug_trace(w_procedure_name,'...bill_format_code         =' ||         w_ptbm.bill_format_code           );   -- Add 1.0.0.2
    --debug_trace(w_procedure_name,'...bill_account_number      =' ||         w_ptbm.bill_account_number        );
    --debug_trace(w_procedure_name,'...cust_name                =' ||         w_ptbm.cust_name                  );
    --debug_trace(w_procedure_name,'...cust_type_code           =' ||         w_ptbm.cust_type_code             );
    --debug_trace(w_procedure_name,'...inst_type_code           =' ||         w_ptbm.inst_type_code             );
    --debug_trace(w_procedure_name,'...inst_locn_code           =' ||         w_ptbm.inst_locn_code             );
    --debug_trace(w_procedure_name,'...pays_by_zipcheck         =' ||         w_ptbm.pays_by_zipcheck           );
    --debug_trace(w_procedure_name,'...mail_name                =' ||         w_ptbm.mail_name                  );
    --debug_trace(w_procedure_name,'...mail_addr_line1          =' ||         w_ptbm.mail_addr_line1            );
    --debug_trace(w_procedure_name,'...mail_addr_line2          =' ||         w_ptbm.mail_addr_line2            );
    --debug_trace(w_procedure_name,'...mail_addr_line3          =' ||         w_ptbm.mail_addr_line3            );
    --debug_trace(w_procedure_name,'...mail_addr_line4          =' ||         w_ptbm.mail_addr_line4            );
    --debug_trace(w_procedure_name,'...mail_addr_line5          =' ||         w_ptbm.mail_addr_line5            );
    --debug_trace(w_procedure_name,'...mail_postal_code         =' ||         w_ptbm.mail_postal_code           );
    --debug_trace(w_procedure_name,'...mail_postal_barcode      =' ||         w_ptbm.mail_postal_barcode        );
    --debug_trace(w_procedure_name,'...inst_addr_line1          =' ||         w_ptbm.inst_addr_line1            );
    --debug_trace(w_procedure_name,'...bill_cycle_yymm          =' ||         w_ptbm.bill_cycle_yymm            );
    --debug_trace(w_procedure_name,'...oldest_debt_cycle_yymm   =' ||         w_ptbm.oldest_debt_cycle_yymm     );
    --debug_trace(w_procedure_name,'...meter_key                =' ||         w_ptbm.meter_key                  );
    --debug_trace(w_procedure_name,'...srvc_size_code           =' ||         w_ptbm.srvc_size_code             );
    --debug_trace(w_procedure_name,'...bill_service             =' ||         w_ptbm.bill_service               );
    --debug_trace(w_procedure_name,'...reading_from_date        =' ||   datec(w_ptbm.reading_from_date)         );
    --debug_trace(w_procedure_name,'...reading_upto_date        =' ||   datec(w_ptbm.reading_upto_date)         );
    --debug_trace(w_procedure_name,'...last_billed_reading      =' || to_char(w_ptbm.last_billed_reading)       );
    --debug_trace(w_procedure_name,'...this_billed_reading      =' || to_char(w_ptbm.this_billed_reading)       );
    --debug_trace(w_procedure_name,'...billed_qty               =' || to_char(w_ptbm.billed_qty)                );
    --debug_trace(w_procedure_name,'...repl_meter_key           =' ||         w_ptbm.repl_meter_key             );
    --debug_trace(w_procedure_name,'...repl_srvc_size_code      =' ||         w_ptbm.repl_srvc_size_code        );
    --debug_trace(w_procedure_name,'...repl_bill_service        =' ||         w_ptbm.repl_bill_service          );
    --debug_trace(w_procedure_name,'...repl_reading_from_date   =' ||   datec(w_ptbm.repl_reading_from_date)    );
    --debug_trace(w_procedure_name,'...repl_reading_upto_date   =' ||   datec(w_ptbm.repl_reading_upto_date)    );
    --debug_trace(w_procedure_name,'...repl_last_billed_reading =' || to_char(w_ptbm.repl_last_billed_reading)  );
    --debug_trace(w_procedure_name,'...repl_this_billed_reading =' || to_char(w_ptbm.repl_this_billed_reading)  );
    --debug_trace(w_procedure_name,'...repl_billed_qty          =' || to_char(w_ptbm.repl_billed_qty)           );
    --debug_trace(w_procedure_name,'...previous_balance_amnt    =' || to_char(w_ptbm.previous_balance_amnt)     );
    --debug_trace(w_procedure_name,'...current_charge_amnt      =' || to_char(w_ptbm.current_charge_amnt)       );
    --debug_trace(w_procedure_name,'...usage_charge_amnt        =' || to_char(w_ptbm.usage_charge_amnt)         );
    --debug_trace(w_procedure_name,'...service_charge_amnt      =' || to_char(w_ptbm.service_charge_amnt)       );
    --debug_trace(w_procedure_name,'...discount_amnt        =' || to_char(w_ptbm.discount_amnt)         );
    --debug_trace(w_procedure_name,'...last_paid_count          =' || to_char(w_ptbm.last_paid_count)           );
    --debug_trace(w_procedure_name,'...last_paid_date           =' ||   datec(w_ptbm.last_paid_date)            );
    --debug_trace(w_procedure_name,'...last_paid_amnt           =' || to_char(w_ptbm.last_paid_amnt)            );
    --debug_trace(w_procedure_name,'...total_due_amnt           =' || to_char(w_ptbm.total_due_amnt)            );
    --debug_trace(w_procedure_name,'...penalty_amnt             =' || to_char(w_ptbm.penalty_amnt)              );
    --debug_trace(w_procedure_name,'...penalty_due_amnt         =' || to_char(w_ptbm.penalty_due_amnt)          );
    --debug_trace(w_procedure_name,'...penalty_date             =' ||   datec(w_ptbm.penalty_date)              );
    --debug_trace(w_procedure_name,'...scan_string              =' ||         w_ptbm.scan_string                );
    --debug_trace(w_procedure_name,'...message_1              =' ||         w_ptbm.message_1                );
    --debug_trace(w_procedure_name,'...message_2              =' ||         w_ptbm.message_2                );
    --debug_trace(w_procedure_name,'...billed_qty_01            =' || to_char(w_ptbm.billed_qty_01)             );
    --debug_trace(w_procedure_name,'...billed_qty_02            =' || to_char(w_ptbm.billed_qty_02)             );
    --debug_trace(w_procedure_name,'...billed_qty_03            =' || to_char(w_ptbm.billed_qty_03)             );
    --debug_trace(w_procedure_name,'...billed_qty_04            =' || to_char(w_ptbm.billed_qty_04)             );
    --debug_trace(w_procedure_name,'...billed_qty_05            =' || to_char(w_ptbm.billed_qty_05)             );
    --debug_trace(w_procedure_name,'...billed_qty_06            =' || to_char(w_ptbm.billed_qty_06)             );
    --debug_trace(w_procedure_name,'...billed_qty_07            =' || to_char(w_ptbm.billed_qty_07)             );
    --debug_trace(w_procedure_name,'...billed_qty_08            =' || to_char(w_ptbm.billed_qty_08)             );
    --debug_trace(w_procedure_name,'...billed_qty_09            =' || to_char(w_ptbm.billed_qty_09)             );
    --debug_trace(w_procedure_name,'...billed_qty_10            =' || to_char(w_ptbm.billed_qty_10)             );
    --debug_trace(w_procedure_name,'...billed_qty_11            =' || to_char(w_ptbm.billed_qty_11)             );
    --debug_trace(w_procedure_name,'...billed_qty_12            =' || to_char(w_ptbm.billed_qty_12)             );
    --debug_trace(w_procedure_name,'...background_print_string  =' ||         w_ptbm.background_print_string    );
    --insert into PHL_TMG_BILL_MASTER   --del 3706
    /* The code for seq_no has moved from the trigger PHL_BILL_PRINT_HIST_D001 */
    select phl_bill_seq_s.nextval into w_seq_no from dual;
    insert into phl_bill_print_hist
    ( bill_key --add 3706
     ,bill_tran_key
     ,acct_key
     ,billing_date
     ,incl_payments_date
     ,payment_due_date
     ,bill_format_code
     ,bill_account_number
     ,cust_name
     ,cust_type_code
     ,inst_type_code
     ,inst_locn_code
     ,pays_by_zipcheck
     ,mail_name
     ,mail_addr_line1
     ,mail_addr_line2
     ,mail_addr_line3
     ,mail_addr_line4
     ,mail_addr_line5
     ,mail_postal_code
     ,mail_postal_barcode
     ,inst_addr_line1
     ,bill_cycle_yymm
     ,oldest_debt_cycle_yymm
     ,meter_key
     ,srvc_size_code
     ,bill_service
     ,reading_from_date
     ,reading_upto_date
     ,last_billed_reading
     ,this_billed_reading
     ,billed_qty
     ,ert_key
     ,est_last_rdg_flag
     ,est_this_rdg_flag
     ,repl_meter_key
     ,repl_srvc_size_code
     ,repl_bill_service
     ,repl_reading_from_date
     ,repl_reading_upto_date
     ,repl_last_billed_reading
     ,repl_this_billed_reading
     ,repl_billed_qty
     ,repl_ert_key
     ,est_repl_last_rdg_flag
     ,est_repl_this_rdg_flag
     ,previous_balance_amnt
     ,adjust
     ,lien
     ,late_pmt_penalty
     ,last_paid_amnt
     ,last_paid_count
     ,last_paid_date
     ,tot_pays_adjs
     ,sub_tot_prev_bal
     ,fire_srvc_chg_amnt
     ,service_charge_amnt
     ,chxext         --Add 2.0.0.55
     ,chxext_wo_disc      --Add 2.0.0.55
     ,stormchg
     ,tot_srvc_chgs
     ,usage_charge_amnt
     ,induschg
     ,tot_usgs_chgs
     ,subtot_curr_chgs
     ,discount_lbl
     ,discount_amnt
     ,sewer_credit
     ,bank_return_item
     ,meter_test_charge
     ,wrbcccred
     ,tot_curr_chgs
     ,pymtagree
     ,wrbccpmt
     ,penalty_amnt
     ,penalty_due_amnt
     ,penalty_date
     ,debt_bal_amnt_bnk
     ,debt_bal_amnt_rda
     ,debt_bal_amnt_vct
     ,debt_bal_amnt_shs
     ,debt_bal_amnt_cty
     ,debt_bal_amnt_cri
     ,debt_bal_amnt_lih
     ,debt_bal_amnt_ues
     ,debt_bal_amnt_trb
     ,debt_bal_not_incl
     ,debt_bal_grants
     ,tot_cred        --Add 2402
     ,total_due_amnt
     ,total_bal                --Add 2.0.0.09
     ,current_charge_amnt
     ,account_balance
     ,next_mtr_read_date
     ,scan_string
     ,billed_qty_01
     ,billed_qty_02
     ,billed_qty_03
     ,billed_qty_04
     ,billed_qty_05
     ,billed_qty_06
     ,billed_qty_07
     ,billed_qty_08
     ,billed_qty_09
     ,billed_qty_10
     ,billed_qty_11
     ,billed_qty_12
     ,billed_qty_13
     ,billed_qty_14    --Add 3706
     ,billed_qty_15    --Add 3706
     ,billed_qty_16    --Add 3706
     ,billed_qty_17    --Add 3706
     ,billed_qty_18    --Add 3706
     ,billed_qty_19    --Add 3706
     ,billed_qty_20    --Add 3706
     ,billed_qty_21    --Add 3706
     ,billed_qty_22    --Add 3706
     ,billed_qty_23    --Add 3706
     ,billed_qty_24    --Add 3706
     ,blbl_01
     ,blbl_02
     ,blbl_03
     ,blbl_04
     ,blbl_05
     ,blbl_06
     ,blbl_07
     ,blbl_08
     ,blbl_09
     ,blbl_10
     ,blbl_11
     ,blbl_12
     ,blbl_13
     ,blbl_14          --Add 3706
     ,blbl_15          --Add 3706
     ,blbl_16          --Add 3706
     ,blbl_17          --Add 3706
     ,blbl_18          --Add 3706
     ,blbl_19          --Add 3706
     ,blbl_20          --Add 3706
     ,blbl_21          --Add 3706
     ,blbl_22          --Add 3706
     ,blbl_23          --Add 3706
     ,blbl_24          --Add 3706
     ,bflg_01
     ,bflg_02
     ,bflg_03
     ,bflg_04
     ,bflg_05
     ,bflg_06
     ,bflg_07
     ,bflg_08
     ,bflg_09
     ,bflg_10
     ,bflg_11
     ,bflg_12
     ,bflg_13
     ,bflg_14         --Add 3706
     ,bflg_15         --Add 3706
     ,bflg_16         --Add 3706
     ,bflg_17         --Add 3706
     ,bflg_18         --Add 3706
     ,bflg_19         --Add 3706
     ,bflg_20         --Add 3706
     ,bflg_21         --Add 3706
     ,bflg_22         --Add 3706
     ,bflg_23         --Add 3706
     ,bflg_24         --Add 3706
     ,billed_yy_01    --Add 3706
     ,imb
     ,message_1
     ,message_2
     ,message_3
     ,message_4
     ,grph_mesg1                 --Add 3706
     ,background_print_string    --Add 3706
     ,hdr_mesg_1                 --Add 3706
     ,hdr_mesg_2                 --Add 3706
     ,hdr_mesg_3                 --Add 3706
     ,hdr_mesg_4                 --Add 3706
     ,nus_chrg                   --Add 3706
     ,mtr_chrg                   --Add 3706
     ,hlp_loan                   --Add 3706
     ,no_of_pages                --Add 3706
     ,sw_chg_fr_dt               --Add 3659
     ,sw_chg_to_dt               --Add 3659
     ,fir_srv_chg_fr_dt          --add 3706
     ,fir_srv_chg_to_dt          --add 3706
     --,fire_srvc_chg_amnt       --Del 3706 Already exists above add 3127
     ,agr_dt                     --Add 3706
     ,agr_amnt                   --Add 3706
     ,agr_downpym_dt             --Add 3706
     ,agr_downpym_amnt           --Add 3706
     ,agr_1stpym_dt              --Add 3706
     ,agr_1stpym_amnt            --Add 3706
     ,agr_2ndpym_dt              --Add 3706
     ,agr_2ndpym_amnt            --Add 3706
     ,agr_3rdpym_dt              --Add 3706
     ,agr_3rdpym_amnt            --Add 3706
     ,agr_4thpym_dt              --Add 3706
     ,agr_4thpym_amnt            --Add 3706
     ,agr_5thpym_dt              --Add 3706
     ,agr_5thpym_amnt            --Add 3706
     ,agr_6thpym_dt              --Add 3706
     ,agr_6thpym_amnt            --Add 3706
     ,agr_7thpym_dt              --Add 3706
     ,agr_7thpym_amnt            --Add 3706
     ,agr_bal_amnt               --Add 3706
     ,srvc_period                --Add 3706
     ,un_paid_prv_bal            --Add 3706
     ,gal_used_per_day           --Add 3706
     ,repl_gal_used_per_day      --Add 3706
     ,inst_postal_code           --Add 3706
     ,no_of_line_items           --Add 3706
     ,big_three_cnt              --Add 3706
     ,othr_fees_crds_flg         --Add 3706
     ,sew_ren_fct_dis            --Add 3706
     ,process_id                 --Add 3706
     ,creation_date              --Add 3706
     ,seq_no                     --Add 4398 --Add 3706
     ,tot_bill_rdg               --Add 3706
     ,grp_mssg_agr01             --Add 3706
     ,dcr_fnt_sz_amnt_hdrs       --Add 3706
     ,agr_othr_pymnts_amnt       --Add 3706
     ,debt_bal_amnt_tnf          --Add 3706
     ,all_flags                  --Add 4608
     ,agrv_rc_st_opening_bal_amnt--Add 4398
     ,agrv_rc_st_closing_bal_amnt--Add 4398
     ,agrv_hl_st_opening_bal_amnt--Add 4398
     ,agrv_hl_st_closing_bal_amnt--Add 4398
     ,bill_tran_id               --Add 4398
     ,tap_prv_unpaid_bl          --Add 6721
     ,tap_group_num              --Add 6230
     ,tap_disc                   --Add 6230
     ,tap_chg                    --Add 6230
     ,tap_tot_act_usg_srv_chg    --Add 6230
     ,tap_tot_chg_amnt           --Add 6230
     ,tap_tot_saved_amnt         --Add 6230
     ,tap_tot_past_due_paid_amnt --Add 6230
     ,tap_ef_count               --Add 6230
     ,tap_recertify_date         --Add 6230
     ,tap_error_text             --Add 6230
     ,bill_status                --Add 6230
     ,tap_pym_2_arrs             --Add 7055
     ,pymagr_due_lbl             --Add 7055
     ,amnt_in_disp               --Add 7164
     ,ebill_ind
     --,amnt_disp_n_agr          --Add 7164
     ,ebill_auto_pay_ind				 --Add 9495
		 ,ebill_auto_pay_str	       --Add 8020F
		 ,dup_ind										 --Add 8020F
		 ,next_wtr_auto_pay_amnt		 --Add 9918
		 ,next_agn_auto_pay_amnt		 --Add 9918
		 ,next_hlp_auto_pay_amnt		 --Add 9918
		 ,tot_disp_amnt							 --Add 9792
     ,tap_bf_count							 --Add 9984
   	 ,tap_bf_max_tot_amnt        --Add 9984
		 ,tap_pnlty_frgv_dt					 --Add 9984
  	 ,tap_pnlty_frgv_amnt 			 --Add 9984
     ,tap_prin_frgv_dt					 --Add 9984
  	 ,tap_prin_frgv_amnt         --Add 9984
    )
  values
    ( w_ptbm.bill_key
     ,w_ptbm.bill_tran_key
     ,w_ptbm.acct_key
     ,w_ptbm.billing_date
     ,w_ptbm.incl_payments_date
     ,w_ptbm.payment_due_date
     ,w_ptbm.bill_format_code
     ,w_ptbm.bill_account_number
     ,w_ptbm.cust_name
     ,w_ptbm.cust_type_code
     ,w_ptbm.inst_type_code
     ,w_ptbm.inst_locn_code
     ,w_ptbm.pays_by_zipcheck
     ,w_ptbm.mail_name
     ,w_ptbm.mail_addr_line1
     ,w_ptbm.mail_addr_line2
     ,w_ptbm.mail_addr_line3
     ,w_ptbm.mail_addr_line4
     ,w_ptbm.mail_addr_line5
     ,w_ptbm.mail_postal_code
     ,w_ptbm.mail_postal_barcode
     ,w_ptbm.inst_addr_line1
     ,w_ptbm.bill_cycle_yymm
     ,w_ptbm.oldest_debt_cycle_yymm
     ,w_ptbm.meter_key
     ,w_ptbm.srvc_size_code
     ,w_ptbm.bill_service
     ,w_ptbm.reading_from_date
     ,w_ptbm.reading_upto_date
     ,w_ptbm.last_billed_reading
     ,w_ptbm.this_billed_reading
     ,w_ptbm.billed_qty
     ,w_ptbm.ert_key
     ,w_ptbm.est_last_rdg_flag
     ,w_ptbm.est_this_rdg_flag
     ,w_ptbm.repl_meter_key
     ,w_ptbm.repl_srvc_size_code
     ,w_ptbm.repl_bill_service
     ,w_ptbm.repl_reading_from_date
     ,w_ptbm.repl_reading_upto_date
     ,w_ptbm.repl_last_billed_reading
     ,w_ptbm.repl_this_billed_reading
     ,w_ptbm.repl_billed_qty
     ,w_ptbm.repl_ert_key
     ,w_ptbm.est_repl_last_rdg_flag
     ,w_ptbm.est_repl_this_rdg_flag
     ,w_ptbm.previous_balance_amnt
     ,w_ptbm.adjust
     ,w_ptbm.lien
     ,w_ptbm.late_pmt_penalty
     ,w_ptbm.last_paid_amnt
     ,w_ptbm.last_paid_count
     ,w_ptbm.last_paid_date
     ,w_ptbm.tot_pays_adjs
     ,w_ptbm.sub_tot_prev_bal
     ,w_ptbm.fire_srvc_chg_amnt
     ,w_ptbm.service_charge_amnt
     ,w_ptbm.chxext              --Add 2.0.0.55
     ,w_ptbm.chxext_wo_disc      --Add 2.0.0.55
     ,w_ptbm.stormchg
     ,w_ptbm.tot_srvc_chgs
     ,w_ptbm.usage_charge_amnt
     ,w_ptbm.induschg
     ,w_ptbm.tot_usgs_chgs
     ,w_ptbm.subtot_curr_chgs
     ,w_ptbm.discount_lbl
     ,w_ptbm.discount_amnt
     ,w_ptbm.sewer_credit
     ,w_ptbm.bank_return_item
     ,w_ptbm.meter_test_charge
     ,w_ptbm.wrbcccred
     ,w_ptbm.tot_curr_chgs
     ,w_ptbm.pymtagree
     ,w_ptbm.wrbccpmt
     ,w_ptbm.penalty_amnt
     ,w_ptbm.penalty_due_amnt
     ,w_ptbm.penalty_date
     ,w_ptbm.debt_bal_amnt_bnk
     ,w_ptbm.debt_bal_amnt_rda
     ,w_ptbm.debt_bal_amnt_vct
     ,w_ptbm.debt_bal_amnt_shs
     ,w_ptbm.debt_bal_amnt_cty
     ,w_ptbm.debt_bal_amnt_cri
     ,w_ptbm.debt_bal_amnt_lih
     ,w_ptbm.debt_bal_amnt_ues
     ,w_ptbm.debt_bal_amnt_trb
     ,w_ptbm.debt_bal_not_incl
     ,w_ptbm.debt_bal_grants
     ,w_ptbm.tot_cred            --Add 2402
     ,w_ptbm.total_due_amnt
     ,w_ptbm.total_bal           --Add 2.0.0.09
     ,w_ptbm.current_charge_amnt
     ,w_ptbm.account_balance
     ,w_ptbm.next_mtr_read_date
     ,w_ptbm.scan_string
     ,w_ptbm.billed_qty_01
     ,w_ptbm.billed_qty_02
     ,w_ptbm.billed_qty_03
     ,w_ptbm.billed_qty_04
     ,w_ptbm.billed_qty_05
     ,w_ptbm.billed_qty_06
     ,w_ptbm.billed_qty_07
     ,w_ptbm.billed_qty_08
     ,w_ptbm.billed_qty_09
     ,w_ptbm.billed_qty_10
     ,w_ptbm.billed_qty_11
     ,w_ptbm.billed_qty_12
     ,w_ptbm.billed_qty_13
     ,w_ptbm.billed_qty_14       --Add 3706
     ,w_ptbm.billed_qty_15       --Add 3706
     ,w_ptbm.billed_qty_16       --Add 3706
     ,w_ptbm.billed_qty_17       --Add 3706
     ,w_ptbm.billed_qty_18       --Add 3706
     ,w_ptbm.billed_qty_19       --Add 3706
     ,w_ptbm.billed_qty_20       --Add 3706
     ,w_ptbm.billed_qty_21       --Add 3706
     ,w_ptbm.billed_qty_22       --Add 3706
     ,w_ptbm.billed_qty_23       --Add 3706
     ,w_ptbm.billed_qty_24       --Add 3706
     ,w_ptbm.blbl_01
     ,w_ptbm.blbl_02
     ,w_ptbm.blbl_03
     ,w_ptbm.blbl_04
     ,w_ptbm.blbl_05
     ,w_ptbm.blbl_06
     ,w_ptbm.blbl_07
     ,w_ptbm.blbl_08
     ,w_ptbm.blbl_09
     ,w_ptbm.blbl_10
     ,w_ptbm.blbl_11
     ,w_ptbm.blbl_12
     ,w_ptbm.blbl_13
     ,w_ptbm.blbl_14             --Add 3706
     ,w_ptbm.blbl_15             --Add 3706
     ,w_ptbm.blbl_16             --Add 3706
     ,w_ptbm.blbl_17             --Add 3706
     ,w_ptbm.blbl_18             --Add 3706
     ,w_ptbm.blbl_19             --Add 3706
     ,w_ptbm.blbl_20             --Add 3706
     ,w_ptbm.blbl_21             --Add 3706
     ,w_ptbm.blbl_22             --Add 3706
     ,w_ptbm.blbl_23             --Add 3706
     ,w_ptbm.blbl_24             --Add 3706
     ,w_ptbm.bflg_01
     ,w_ptbm.bflg_02
     ,w_ptbm.bflg_03
     ,w_ptbm.bflg_04
     ,w_ptbm.bflg_05
     ,w_ptbm.bflg_06
     ,w_ptbm.bflg_07
     ,w_ptbm.bflg_08
     ,w_ptbm.bflg_09
     ,w_ptbm.bflg_10
     ,w_ptbm.bflg_11
     ,w_ptbm.bflg_12
     ,w_ptbm.bflg_13
     ,w_ptbm.bflg_14             --Add 3706
     ,w_ptbm.bflg_15             --Add 3706
     ,w_ptbm.bflg_16             --Add 3706
     ,w_ptbm.bflg_17             --Add 3706
     ,w_ptbm.bflg_18             --Add 3706
     ,w_ptbm.bflg_19             --Add 3706
     ,w_ptbm.bflg_20             --Add 3706
     ,w_ptbm.bflg_21             --Add 3706
     ,w_ptbm.bflg_22             --Add 3706
     ,w_ptbm.bflg_23             --Add 3706
     ,w_ptbm.bflg_24             --Add 3706
     ,w_ptbm.billed_yy_01        --Add 3706
     ,w_ptbm.imb
     ,w_ptbm.message_1
     ,w_ptbm.message_2
     ,w_ptbm.message_3
     ,w_ptbm.message_4
     ,w_ptbm.grph_mesg1                 --Add 3706
     ,w_ptbm.background_print_string    --Add 3706
     ,w_ptbm.hdr_mesg_1                 --Add 3706
     ,w_ptbm.hdr_mesg_2                 --Add 3706
     ,w_ptbm.hdr_mesg_3                 --Add 3706
     ,w_ptbm.hdr_mesg_4                 --Add 3706
     ,w_ptbm.nus_chrg                   --Add 3706
     ,w_ptbm.mtr_chrg                   --Add 3706
     ,w_ptbm.hlp_loan                   --Add 3706
     ,w_ptbm.no_of_pages                --Add 3707
     ,w_ptbm.sw_chg_fr_dt               --add 3659
     ,w_ptbm.sw_chg_to_dt               --add 3659
     ,w_ptbm.fir_srv_chg_fr_dt          --add 3706
     ,w_ptbm.fir_srv_chg_to_dt          --add 3706
     --,w_ptbm.fire_srvc_chg_amnt       --Del 3706 Already exists above add 3127
     ,w_ptbm.agr_dt                     --add 3706
     ,w_ptbm.agr_amnt                   --add 3706
     ,w_ptbm.agr_downpym_dt             --add 3706
     ,w_ptbm.agr_downpym_amnt           --add 3706
     ,w_ptbm.agr_1stpym_dt              --add 3706
     ,w_ptbm.agr_1stpym_amnt            --add 3706
     ,w_ptbm.agr_2ndpym_dt              --add 3706
     ,w_ptbm.agr_2ndpym_amnt            --add 3706
     ,w_ptbm.agr_3rdpym_dt              --add 3706
     ,w_ptbm.agr_3rdpym_amnt            --add 3706
     ,w_ptbm.agr_4thpym_dt              --add 3706
     ,w_ptbm.agr_4thpym_amnt            --add 3706
     ,w_ptbm.agr_5thpym_dt              --add 3706
     ,w_ptbm.agr_5thpym_amnt            --add 3706
     ,w_ptbm.agr_6thpym_dt              --add 3706
     ,w_ptbm.agr_6thpym_amnt            --add 3706
     ,w_ptbm.agr_7thpym_dt              --add 3706
     ,w_ptbm.agr_7thpym_amnt            --add 3706
     ,w_ptbm.agr_bal_amnt               --add 3706
     ,w_ptbm.srvc_period                --add 3706
     ,w_ptbm.un_paid_prv_bal            --add 3706
     ,w_ptbm.gal_used_per_day           --Add 3706
     ,w_ptbm.repl_gal_used_per_day      --Add 3706
     ,w_ptbm.inst_postal_code           --Add 3706
     ,w_ptbm.no_of_line_items           --Add 3706
     ,w_ptbm.big_three_cnt              --Add 3706
     ,w_ptbm.othr_fees_crds_flg         --Add 3706
     ,w_ptbm.sew_ren_fct_dis            --Add 3706
     ,w_process_id                      --Add 3706
     ,sysdate                           --Add 3706
     ,w_seq_no                          --Add 4398 --,cis.phl_bill_seq_s.nextval        --Add 3706
     ,w_ptbm.tot_bill_rdg                 --Add 3706
     ,w_ptbm.grp_mssg_agr01               --Add 3706
     ,w_ptbm.dcr_fnt_sz_amnt_hdrs         --Add 3706
     ,w_ptbm.agr_othr_pymnts_amnt         --Add 3706
     ,w_ptbm.debt_bal_amnt_tnf            --Add 3706
     ,w_ptbm.all_flags                    --Add 4608
     ,w_ptbm.agrv_rc_st_opening_bal_amnt  --Add 4398
     ,w_ptbm.agrv_rc_st_closing_bal_amnt + nvl(w_rchl.agrv_rc_debt_to_exclude,0) --Add 5905  3.0.0.36 --Add 4398
     ,w_ptbm.agrv_hl_st_opening_bal_amnt  --Add 4398
     ,w_ptbm.agrv_hl_st_closing_bal_amnt + nvl(w_rchl.agrv_hl_debt_to_exclude,0) --Add 5905  3.0.0.36 --Add 4398
     ,w_ptbm.bill_tran_id                 --Add 4398
     ,w_ptbm.tap_prv_unpaid_bl            --Add 6721
     ,w_ptbm.tap_group_num                --Add 6230
     ,w_ptbm.tap_disc                     --Add 6230
     ,w_ptbm.tap_chg                      --Add 6230
     ,w_ptbm.tap_tot_act_usg_srv_chg      --Add 6230
     ,w_ptbm.tap_tot_chg_amnt             --Add 6230
     ,w_ptbm.tap_tot_saved_amnt           --Add 6230
     ,w_ptbm.tap_tot_past_due_paid_amnt   --Add 6230
     ,w_ptbm.tap_ef_count                 --Add 6230
     ,w_ptbm.tap_recertify_date           --Add 6230
     ,w_ptbm.tap_error_text               --Add 6230
     ,w_ptbm.bill_status                  --Add 6230
     ,w_ptbm.tap_pym_2_arrs               --Add 7055
     ,w_ptbm.pymagr_due_lbl               --Add 7055
     ,w_ptbm.amnt_in_disp                 --Add 7164
     --,w_ptbm.amnt_disp_n_agr            --Add 7164
     ,w_ptbm.ebill_ind										--Add 8020
     ,w_ptbm.ebill_auto_pay_ind				 		--Add 9495
		 ,w_ptbm.ebill_auto_pay_str	       		--Add 8020F
		 ,w_ptbm.dup_ind										 	--Add 8020F
		 ,w_ptbm.next_wtr_auto_pay_amnt				--Add 9918
		 ,w_ptbm.next_agn_auto_pay_amnt				--Add 9918
		 ,w_ptbm.next_hlp_auto_pay_amnt				--Add 9918
		 ,w_ptbm.tot_disp_amnt							  --Add 9792
     ,w_ptbm.tap_bf_count									--Add 9984
   	 ,w_ptbm.tap_bf_max_tot_amnt          --Add 9984
     ,w_ptbm.tap_pnlty_frgv_dt						--Add 9984
  	 ,w_ptbm.tap_pnlty_frgv_amnt  				--Add 9984
     ,w_ptbm.tap_prin_frgv_dt						  --Add 9984
  	 ,w_ptbm.tap_prin_frgv_amnt						--Add 9984
  );
 end insert_report_record;
 /* Start Add 4398 */
 /*********************0****************************************************************\
    private procedure insert Agency Repiar Charge Help Loan Statements
 \*************************************************************************************/
 procedure insert_agrv_rc_hl_st is
    w_procedure_name              varchar2(50) := 'phls0001.phl_agrv_rc_hlpln_st_dtl';
 begin
    w_label := 'e029';
    trace_label(w_label, w_procedure_name);
   insert into phl_agrv_rc_hlpln_st_dtl
   (
    seq_no
   ,bill_tran_id
   ,process_id
   ,cust_id
   ,inst_id
   ,water1_acct
   ,agrv_rc_acct_key
   ,agrv_rc_st_opening_bal_amnt
   ,agrv_rc_cur_pymnt_amnt
   ,agrv_rc_last_pymnt_dt
   ,agrv_rc_cur_adj_amnt
   ,agrv_rc_unpaid_amnt
   ,agrv_rc_unpaid_lbl
   ,agrv_rc_5th_inv_no
   ,agrv_rc_5th_inv_srv_dt
   ,agrv_rc_5th_inv_lien_no
   ,agrv_rc_5th_inv_bal
   ,agrv_rc_5th_inv_desc
   ,agrv_rc_5th_fpg_inv_desc
   ,agrv_rc_5th_cur_prv_flag
   ,agrv_rc_4th_inv_no
   ,agrv_rc_4th_inv_srv_dt
   ,agrv_rc_4th_inv_lien_no
   ,agrv_rc_4th_inv_bal
   ,agrv_rc_4th_inv_desc
   ,agrv_rc_4th_fpg_inv_desc
   ,agrv_rc_4th_cur_prv_flag
   ,agrv_rc_3rd_inv_no
   ,agrv_rc_3rd_inv_srv_dt
   ,agrv_rc_3rd_inv_lien_no
   ,agrv_rc_3rd_inv_bal
   ,agrv_rc_3rd_inv_desc
   ,agrv_rc_3rd_fpg_inv_desc
   ,agrv_rc_3rd_cur_prv_flag
   ,agrv_rc_2nd_inv_no
   ,agrv_rc_2nd_inv_srv_dt
   ,agrv_rc_2nd_inv_lien_no
   ,agrv_rc_2nd_inv_bal
   ,agrv_rc_2nd_inv_desc
   ,agrv_rc_2nd_fpg_inv_desc
   ,agrv_rc_2nd_cur_prv_flag
   ,agrv_rc_1st_inv_no
   ,agrv_rc_1st_inv_srv_dt
   ,agrv_rc_1st_inv_lien_no
   ,agrv_rc_1st_inv_bal
   ,agrv_rc_1st_inv_desc
   ,agrv_rc_1st_fpg_inv_desc
   ,agrv_rc_1st_cur_prv_flag
   ,agrv_rc_cur_rem_inv_bal
   ,agrv_rc_cur_pnlty_amnt
   ,agrv_rc_prv_rem_inv_bal
   ,agrv_rc_prv_pnlty_amnt
   ,agrv_rc_prv_pymnt_amnt
   ,agrv_rc_prv_adj_amnt
   ,agrv_rc_tot_rem_inv_bal
   ,agrv_rc_tot_pnlty_amnt
   ,agrv_rc_tot_adj_amnt
   ,agrv_rc_tot_pymnt_amnt
   ,agrv_rc_st_closing_bal_amnt
   ,agrv_hl_acct_key
   ,agrv_hl_acct_status
   ,agrv_hl_st_opening_bal_amnt
   ,agrv_hl_cur_pymnt_amnt
   ,agrv_hl_last_pymnt_dt
   ,agrv_hl_cur_adj_amnt
   ,agrv_hl_unpaid_amnt
   ,agrv_hl_unpaid_lbl
   ,agrv_hl_5th_inv_ppln_id
   ,agrv_hl_5th_inv_tran_id
   ,agrv_hl_5th_inv_no
   ,agrv_hl_5th_inv_srv_dt
   ,agrv_hl_5th_inv_lien_no
   ,agrv_hl_5th_inv_bal
   ,agrv_hl_5th_inv_desc
   ,agrv_hl_5th_cur_prv_flag
   ,agrv_hl_4th_inv_no
   ,agrv_hl_4th_inv_srv_dt
   ,agrv_hl_4th_inv_lien_no
   ,agrv_hl_4th_inv_bal
   ,agrv_hl_4th_inv_desc
   ,agrv_hl_4th_cur_prv_flag
   ,agrv_hl_3rd_inv_no
   ,agrv_hl_3rd_inv_srv_dt
   ,agrv_hl_3rd_inv_lien_no
   ,agrv_hl_3rd_inv_bal
   ,agrv_hl_3rd_inv_desc
   ,agrv_hl_3rd_cur_prv_flag
   ,agrv_hl_2nd_inv_no
   ,agrv_hl_2nd_inv_srv_dt
   ,agrv_hl_2nd_inv_lien_no
   ,agrv_hl_2nd_inv_bal
   ,agrv_hl_2nd_inv_desc
   ,agrv_hl_2nd_cur_prv_flag
   ,agrv_hl_1st_inv_no
   ,agrv_hl_1st_inv_srv_dt
   ,agrv_hl_1st_inv_lien_no
   ,agrv_hl_1st_inv_bal
   ,agrv_hl_1st_inv_desc
   ,agrv_hl_1st_cur_prv_flag
   ,agrv_hl_cur_rem_inv_bal
   ,agrv_hl_cur_pnlty_amnt
   ,agrv_hl_prv_rem_inv_bal
   ,agrv_hl_prv_pymnt_amnt
   ,agrv_hl_prv_pnlty_amnt
   ,agrv_hl_prv_adj_amnt
   ,agrv_hl_corr_lbl
   ,agrv_hl_corr_ppln_amnt
   ,agrv_hl_tot_inv_bal
   ,agrv_hl_tot_wo_pnlty
   ,agrv_hl_st_closing_bal_amnt
   ,agrv_hl_plan_exists
   ,agrv_hl_5th_mi_amnt_rcvd
   ,agrv_hl_5th_mi_rcvd_dt
   ,agrv_hl_4th_mi_amnt_rcvd
   ,agrv_hl_4th_mi_rcvd_dt
   ,agrv_hl_3rd_mi_amnt_rcvd
   ,agrv_hl_3rd_mi_rcvd_dt
   ,agrv_hl_2nd_mi_amnt_rcvd
   ,agrv_hl_2nd_mi_rcvd_dt
   ,agrv_hl_1st_mi_amnt_rcvd
   ,agrv_hl_1st_mi_rcvd_dt
   ,agrv_hl_rem_mi_amnt_rcvd
   ,agrv_hl_ppln_id           --Add 6230
   ,agrv_hl_ppln_no_due
   ,agrv_hl_ppln_due_amnt
   ,agrv_hl_ppln_bal_amnt
   ,agrv_hl_total_due_amnt
   ,agrv_hl_mssg1_hdr
   ,agrv_hl_mssg1_dtl
   ,agrv_hl_mssg2_hdr
   ,agrv_hl_mssg2_dtl
   ,agrv_hl_mssg3_hdr
   ,agrv_hl_mssg3_dtl
   ,agrv_hl_mssg4_hdr
   ,agrv_hl_mssg4_dtl
   ,agrv_hl_scan_line
   ,agrv_bkgrnd_prnt_string
   ,agrv_rc_debt_to_exclude      --Add 5905  3.0.0.39
   ,agrv_hl_debt_to_exclude      --Add 5905  3.0.0.39
   ,rc_acct_bal_amnt             --Account balance current                                --Add 6230
   ,rc_cur_xfer_rcpt_in_amnt     --Current xfer in  (Payment came in from other account)  --Add 6230
   ,rc_prv_xfer_rcpt_in_amnt     --Previous xfer in  (Payment came in from other account) --Add 6230
   ,rc_cur_xfer_rcpt_ou_amnt     --Current xfer out (Payment went out to other account)   --Add 6230
   ,rc_prv_xfer_rcpt_ou_amnt     --Previous xfer out (Payment went out to other account)  --Add 6230
   ,rc_tot_debt_till_bill_dt     --Total debt till billing Date                           --Add 6230
   ,rc_bal_not_in_bill           --Balance which is not part of this bill                 --Add 6230
   ,hl_acct_bal_amnt             --Account balance current                                --Add 6230
   ,hl_cur_xfer_rcpt_in_amnt     --Current xfer in  (Payment came in from other account)  --Add 6230
   ,hl_prv_xfer_rcpt_in_amnt     --Previous xfer in  (Payment came in from other account) --Add 6230
   ,hl_cur_xfer_rcpt_ou_amnt     --Current xfer out (Payment went out to other account)   --Add 6230
   ,hl_prv_xfer_rcpt_ou_amnt     --Previous xfer out (Payment went out to other account)  --Add 6230
   ,hl_tot_debt_till_bill_dt     --Total debt till billing Date                           --Add 6230
   ,hl_bal_not_in_bill           --Balance which is not part of this bill                 --Add 6230
   ,hlrc_status                  --HELPLOAN Repair Charge Status                          --Add 6230
   ,prv_bill_tran_id             --Previous Bill Tran ID                                  --Add 6230
   ,prv_bill_creation_dt         --Previous Bill Creation Date                            --Add 6230
   ,rc_inv_tran_ids							 --AR Invoice Tran IDs																		--Add 10212
   ,hl_inv_tran_ids							 --HL Invoice Tran IDs																		--Add 10212
   )
   values
   (
    w_seq_no
   ,w_ptbm.bill_tran_id
   ,w_process_id
   ,w_cust_id
   ,w_inst_id
   ,w_ptbm.bill_account_number
   ,w_rchl.agrv_rc_acct_key
   ,w_rchl.agrv_rc_st_opening_bal_amnt
   ,w_rchl.agrv_rc_cur_pymnt_amnt
   ,w_rchl.agrv_rc_last_pymnt_dt
   ,w_rchl.agrv_rc_cur_adj_amnt
   ,w_rchl.agrv_rc_unpaid_amnt
   ,w_rchl.agrv_rc_unpaid_lbl
   ,w_rchl.agrv_rc_5th_inv_no
   ,w_rchl.agrv_rc_5th_inv_srv_dt
   ,w_rchl.agrv_rc_5th_inv_lien_no
   ,w_rchl.agrv_rc_5th_inv_bal
   ,w_rchl.agrv_rc_5th_inv_desc
   ,w_rchl.agrv_rc_5th_fpg_inv_desc
   ,w_rchl.agrv_rc_5th_cur_prv_flag
   ,w_rchl.agrv_rc_4th_inv_no
   ,w_rchl.agrv_rc_4th_inv_srv_dt
   ,w_rchl.agrv_rc_4th_inv_lien_no
   ,w_rchl.agrv_rc_4th_inv_bal
   ,w_rchl.agrv_rc_4th_inv_desc
   ,w_rchl.agrv_rc_4th_fpg_inv_desc
   ,w_rchl.agrv_rc_4th_cur_prv_flag
   ,w_rchl.agrv_rc_3rd_inv_no
   ,w_rchl.agrv_rc_3rd_inv_srv_dt
   ,w_rchl.agrv_rc_3rd_inv_lien_no
   ,w_rchl.agrv_rc_3rd_inv_bal
   ,w_rchl.agrv_rc_3rd_inv_desc
   ,w_rchl.agrv_rc_3rd_fpg_inv_desc
   ,w_rchl.agrv_rc_3rd_cur_prv_flag
   ,w_rchl.agrv_rc_2nd_inv_no
   ,w_rchl.agrv_rc_2nd_inv_srv_dt
   ,w_rchl.agrv_rc_2nd_inv_lien_no
   ,w_rchl.agrv_rc_2nd_inv_bal
   ,w_rchl.agrv_rc_2nd_inv_desc
   ,w_rchl.agrv_rc_2nd_fpg_inv_desc
   ,w_rchl.agrv_rc_2nd_cur_prv_flag
   ,w_rchl.agrv_rc_1st_inv_no
   ,w_rchl.agrv_rc_1st_inv_srv_dt
   ,w_rchl.agrv_rc_1st_inv_lien_no
   ,w_rchl.agrv_rc_1st_inv_bal
   ,w_rchl.agrv_rc_1st_inv_desc
   ,w_rchl.agrv_rc_1st_fpg_inv_desc
   ,w_rchl.agrv_rc_1st_cur_prv_flag
   ,w_rchl.agrv_rc_cur_rem_inv_bal
   ,w_rchl.agrv_rc_cur_pnlty_amnt
   ,w_rchl.agrv_rc_prv_rem_inv_bal
   ,w_rchl.agrv_rc_prv_pnlty_amnt
   ,w_rchl.agrv_rc_prv_pymnt_amnt
   ,w_rchl.agrv_rc_prv_adj_amnt
   ,w_rchl.agrv_rc_tot_rem_inv_bal
   ,w_rchl.agrv_rc_tot_pnlty_amnt
   ,w_rchl.agrv_rc_tot_adj_amnt
   ,w_rchl.agrv_rc_tot_pymnt_amnt
   ,w_rchl.agrv_rc_st_closing_bal_amnt + nvl(w_rchl.agrv_rc_debt_to_exclude,0) --Add 5905  3.0.0.39
   ,w_rchl.agrv_hl_acct_key
   ,w_rchl.agrv_hl_acct_status
   ,w_rchl.agrv_hl_st_opening_bal_amnt
   ,w_rchl.agrv_hl_cur_pymnt_amnt
   ,w_rchl.agrv_hl_last_pymnt_dt
   ,w_rchl.agrv_hl_cur_adj_amnt
   ,w_rchl.agrv_hl_unpaid_amnt
   ,w_rchl.agrv_hl_unpaid_lbl
   ,w_rchl.agrv_hl_5th_inv_ppln_id
   ,w_rchl.agrv_hl_5th_inv_tran_id
   ,w_rchl.agrv_hl_5th_inv_no
   ,w_rchl.agrv_hl_5th_inv_srv_dt
   ,w_rchl.agrv_hl_5th_inv_lien_no
   ,w_rchl.agrv_hl_5th_inv_bal
   ,w_rchl.agrv_hl_5th_inv_desc
   ,w_rchl.agrv_hl_5th_cur_prv_flag
   ,w_rchl.agrv_hl_4th_inv_no
   ,w_rchl.agrv_hl_4th_inv_srv_dt
   ,w_rchl.agrv_hl_4th_inv_lien_no
   ,w_rchl.agrv_hl_4th_inv_bal
   ,w_rchl.agrv_hl_4th_inv_desc
   ,w_rchl.agrv_hl_4th_cur_prv_flag
   ,w_rchl.agrv_hl_3rd_inv_no
   ,w_rchl.agrv_hl_3rd_inv_srv_dt
   ,w_rchl.agrv_hl_3rd_inv_lien_no
   ,w_rchl.agrv_hl_3rd_inv_bal
   ,w_rchl.agrv_hl_3rd_inv_desc
   ,w_rchl.agrv_hl_3rd_cur_prv_flag
   ,w_rchl.agrv_hl_2nd_inv_no
   ,w_rchl.agrv_hl_2nd_inv_srv_dt
   ,w_rchl.agrv_hl_2nd_inv_lien_no
   ,w_rchl.agrv_hl_2nd_inv_bal
   ,w_rchl.agrv_hl_2nd_inv_desc
   ,w_rchl.agrv_hl_2nd_cur_prv_flag
   ,w_rchl.agrv_hl_1st_inv_no
   ,w_rchl.agrv_hl_1st_inv_srv_dt
   ,w_rchl.agrv_hl_1st_inv_lien_no
   ,w_rchl.agrv_hl_1st_inv_bal
   ,w_rchl.agrv_hl_1st_inv_desc
   ,w_rchl.agrv_hl_1st_cur_prv_flag
   ,w_rchl.agrv_hl_cur_rem_inv_bal
   ,w_rchl.agrv_hl_cur_pnlty_amnt
   ,w_rchl.agrv_hl_prv_rem_inv_bal
   ,w_rchl.agrv_hl_prv_pymnt_amnt
   ,w_rchl.agrv_hl_prv_pnlty_amnt
   ,w_rchl.agrv_hl_prv_adj_amnt
   ,w_rchl.agrv_hl_corr_lbl
   ,w_rchl.agrv_hl_corr_ppln_amnt
   ,w_rchl.agrv_hl_tot_inv_bal
   ,w_rchl.agrv_hl_tot_wo_pnlty
   ,w_rchl.agrv_hl_st_closing_bal_amnt + nvl(w_rchl.agrv_hl_debt_to_exclude,0) --Add 5905  3.0.0.39
   ,w_rchl.agrv_hl_plan_exists
   ,w_rchl.agrv_hl_5th_mi_amnt_rcvd
   ,w_rchl.agrv_hl_5th_mi_rcvd_dt
   ,w_rchl.agrv_hl_4th_mi_amnt_rcvd
   ,w_rchl.agrv_hl_4th_mi_rcvd_dt
   ,w_rchl.agrv_hl_3rd_mi_amnt_rcvd
   ,w_rchl.agrv_hl_3rd_mi_rcvd_dt
   ,w_rchl.agrv_hl_2nd_mi_amnt_rcvd
   ,w_rchl.agrv_hl_2nd_mi_rcvd_dt
   ,w_rchl.agrv_hl_1st_mi_amnt_rcvd
   ,w_rchl.agrv_hl_1st_mi_rcvd_dt
   ,w_rchl.agrv_hl_rem_mi_amnt_rcvd
   ,w_rchl.agrv_hl_ppln_id           --Add 6230
   ,w_rchl.agrv_hl_ppln_no_due
   ,w_rchl.agrv_hl_ppln_due_amnt
   ,w_rchl.agrv_hl_ppln_bal_amnt
   ,w_rchl.agrv_hl_total_due_amnt
   ,w_rchl.agrv_hl_mssg1_hdr
   ,w_rchl.agrv_hl_mssg1_dtl
   ,w_rchl.agrv_hl_mssg2_hdr
   ,w_rchl.agrv_hl_mssg2_dtl
   ,w_rchl.agrv_hl_mssg3_hdr
   ,w_rchl.agrv_hl_mssg3_dtl
   ,w_rchl.agrv_hl_mssg4_hdr
   ,w_rchl.agrv_hl_mssg4_dtl
   ,w_rchl.agrv_hl_scan_line
   ,w_rchl.agrv_bkgrnd_prnt_string
   ,w_rchl.agrv_rc_debt_to_exclude                                                                 --Add 5905  3.0.0.39
   ,w_rchl.agrv_hl_debt_to_exclude                                                                 --Add 5905  3.0.0.39
   ,w_rchl.rc_acct_bal_amnt               --Account balance current                                --Add 6230
   ,w_rchl.rc_cur_xfer_rcpt_in_amnt       --Current xfer in  (Payment came in from other account)  --Add 6230
   ,w_rchl.rc_prv_xfer_rcpt_in_amnt       --Previous xfer in  (Payment came in from other account) --Add 6230
   ,w_rchl.rc_cur_xfer_rcpt_ou_amnt       --Current xfer out (Payment went out to other account)   --Add 6230
   ,w_rchl.rc_prv_xfer_rcpt_ou_amnt       --Previous xfer out (Payment went out to other account)  --Add 6230
   ,w_rchl.rc_tot_debt_till_bill_dt       --Total debt till billing Date                           --Add 6230
   ,w_rchl.rc_bal_not_in_bill             --Balance which is not part of this bill                 --Add 6230
   ,w_rchl.hl_acct_bal_amnt               --Account balance current                                --Add 6230
   ,w_rchl.hl_cur_xfer_rcpt_in_amnt       --Current xfer in  (Payment came in from other account)  --Add 6230
   ,w_rchl.hl_prv_xfer_rcpt_in_amnt       --Previous xfer in  (Payment came in from other account) --Add 6230
   ,w_rchl.hl_cur_xfer_rcpt_ou_amnt       --Current xfer out (Payment went out to other account)   --Add 6230
   ,w_rchl.hl_prv_xfer_rcpt_ou_amnt       --Previous xfer out (Payment went out to other account)  --Add 6230
   ,w_rchl.hl_tot_debt_till_bill_dt       --Total debt till billing Date                           --Add 6230
   ,w_rchl.hl_bal_not_in_bill             --Balance which is not part of this bill                 --Add 6230
   ,w_hlrc_status                         --HELPLOAN Repair Charge Status                          --Add 6230
   ,w_rchl.prv_bill_tran_id               --Previous Bill Tran ID                                  --Add 6230
   ,w_rchl.prv_bill_creation_dt           --Previous Bill Creation Date                            --Add 6230
   ,w_rchl.rc_inv_tran_ids							  --AR Invoice Tran IDs																		 --Add 10212
   ,w_rchl.hl_inv_tran_ids							  --HL Invoice Tran IDs																		 --Add 10212
  );
 end insert_agrv_rc_hl_st;
 /* End Add 4398 */
 --Start Add 4561
 /*************************************************************************************\
    function isZacct returns it's a Z account or NOT
 \*************************************************************************************/
 function isZacct# return boolean is
 begin
    if instr(upper(w_ptbm.bill_account_number),'Z') <> 0 then
       return true;
    else
       return false;
    end if;
 end isZacct#;
 --End Add 4561
-- Start Add 4561
 /*************************************************************************************\
    private procedure cpy_grp_bills_info
 \*************************************************************************************/
 procedure cpy_grp_bills_info is
    w_procedure_name              varchar2(40) := 'phls0001.cpy_grp_bills_info';
 begin
--    null;
   insert into phl_0acc_mtr_grp_bill_hst
   (
    seq_no
   ,process_id
   ,billing_date_yyyymmdd
   ,partial_w1_acct_no
   ,meter_grp_rdg_id
   ,bill_key
   ,cust_id
   ,inst_id
   ,supply_type
   ,creation_date
   ,bill_tran_key
   ,acct_key
   ,billing_date
   ,meter_key
   ,srvc_size_code
   ,bill_service
   ,reading_from_date
   ,reading_upto_date
   ,last_billed_reading
   ,this_billed_reading
   ,billed_qty
   ,ert_key
   ,est_last_rdg_flag
   ,est_this_rdg_flag
   ,gal_used_per_day
   ,repl_meter_key
   ,repl_srvc_size_code
   ,repl_bill_service
   ,repl_reading_from_date
   ,repl_reading_upto_date
   ,repl_last_billed_reading
   ,repl_this_billed_reading
   ,repl_billed_qty
   ,repl_ert_key
   ,est_repl_last_rdg_flag
   ,est_repl_this_rdg_flag
   ,repl_gal_used_per_day
   ,billed_qty_01
   ,billed_qty_02
   ,billed_qty_03
   ,billed_qty_04
   ,billed_qty_05
   ,billed_qty_06
   ,billed_qty_07
   ,billed_qty_08
   ,billed_qty_09
   ,billed_qty_10
   ,billed_qty_11
   ,billed_qty_12
   ,billed_qty_13
   ,blbl_01
   ,blbl_02
   ,blbl_03
   ,blbl_04
   ,blbl_05
   ,blbl_06
   ,blbl_07
   ,blbl_08
   ,blbl_09
   ,blbl_10
   ,blbl_11
   ,blbl_12
   ,blbl_13
   ,bflg_01
   ,bflg_02
   ,bflg_03
   ,bflg_04
   ,bflg_05
   ,bflg_06
   ,bflg_07
   ,bflg_08
   ,bflg_09
   ,bflg_10
   ,bflg_11
   ,bflg_12
   ,bflg_13
   ,grph_mesg1
   ,tot_bill_rdg
   )
   values
   (
    phl_bill_mtr_grp_seq_s.nextval                                --SEQ_NO                          NOT NULL NUMBER
   ,w_process_id                                                  --PROCESS_ID                               NUMBER
   ,trim(to_char(w_ptbm.billing_date,'YYYYMMDD'))                 --BILLING_DATE_YYYYMMDD                    NUMBER
   ,trim(substr(w_ptbm.bill_account_number,1,15))                 --PARTIAL_W1_ACCT_NO                       VARCHAR2(13)
   ,w_meter_grp_rdg_id                                            --METER_GRP_RDG_ID                         NUMBER
   ,w_ptbm.bill_key                                               --BILL_KEY                                 VARCHAR2(20)
   ,w_cust_id                                                     --CUST_ID                                  NUMBER
   ,w_inst_id                                                     --INST_ID                                  NUMBER
   ,w_supply_type                                                 --SUPPLY_TYPE                              VARCHAR2(8)
   ,sysdate                                                       --CREATION_DATE                            DATE
   ,w_ptbm.bill_tran_key                                          --BILL_TRAN_KEY                            VARCHAR2(20)
   ,w_ptbm.acct_key                                               --ACCT_KEY                                 VARCHAR2(20)
   ,w_ptbm.billing_date                                           --BILLING_DATE                             DATE
   ,w_ptbm.meter_key                                              --METER_KEY                                VARCHAR2(20)
   ,w_ptbm.srvc_size_code                                         --SRVC_SIZE_CODE                           VARCHAR2(8)
   ,w_ptbm.bill_service                                           --BILL_SERVICE                             VARCHAR2(3)
   ,w_ptbm.reading_from_date                                      --READING_FROM_DATE                        DATE
   ,w_ptbm.reading_upto_date                                      --READING_UPTO_DATE                        DATE
   ,w_ptbm.last_billed_reading                                    --LAST_BILLED_READING                      NUMBER
   ,w_ptbm.this_billed_reading                                    --THIS_BILLED_READING                      NUMBER
   ,w_ptbm.billed_qty                                             --BILLED_QTY                               NUMBER
   ,w_ptbm.ert_key                                                --ERT_KEY                                  VARCHAR2(20)
   ,w_ptbm.est_last_rdg_flag                                      --EST_LAST_RDG_FLAG                        CHAR(1)
   ,w_ptbm.est_this_rdg_flag                                      --EST_THIS_RDG_FLAG                        CHAR(1)
   ,w_ptbm.gal_used_per_day                                       --GAL_USED_PER_DAY                         NUMBER
   ,w_ptbm.repl_meter_key                                         --REPL_METER_KEY                           VARCHAR2(20)
   ,w_ptbm.repl_srvc_size_code                                    --REPL_SRVC_SIZE_CODE                      VARCHAR2(8)
   ,w_ptbm.repl_bill_service                                      --REPL_BILL_SERVICE                        VARCHAR2(3)
   ,w_ptbm.repl_reading_from_date                                 --REPL_READING_FROM_DATE                   DATE
   ,w_ptbm.repl_reading_upto_date                                 --REPL_READING_UPTO_DATE                   DATE
   ,w_ptbm.repl_last_billed_reading                               --REPL_LAST_BILLED_READING                 NUMBER
   ,w_ptbm.repl_this_billed_reading                               --REPL_THIS_BILLED_READING                 NUMBER
   ,w_ptbm.repl_billed_qty                                        --REPL_BILLED_QTY                          NUMBER
   ,w_ptbm.repl_ert_key                                           --REPL_ERT_KEY                             VARCHAR2(20)
   ,w_ptbm.est_repl_last_rdg_flag                                 --EST_REPL_LAST_RDG_FLAG                   CHAR(1)
   ,w_ptbm.est_repl_this_rdg_flag                                 --EST_REPL_THIS_RDG_FLAG                   CHAR(1)
   ,w_ptbm.repl_gal_used_per_day                                  --REPL_GAL_USED_PER_DAY                    NUMBER
   ,w_ptbm.billed_qty_01                                          --BILLED_QTY_01                            NUMBER
   ,w_ptbm.billed_qty_02                                          --BILLED_QTY_02                            NUMBER
   ,w_ptbm.billed_qty_03                                          --BILLED_QTY_03                            NUMBER
   ,w_ptbm.billed_qty_04                                          --BILLED_QTY_04                            NUMBER
   ,w_ptbm.billed_qty_05                                          --BILLED_QTY_05                            NUMBER
   ,w_ptbm.billed_qty_06                                          --BILLED_QTY_06                            NUMBER
   ,w_ptbm.billed_qty_07                                          --BILLED_QTY_07                            NUMBER
   ,w_ptbm.billed_qty_08                                          --BILLED_QTY_08                            NUMBER
   ,w_ptbm.billed_qty_09                                          --BILLED_QTY_09                            NUMBER
   ,w_ptbm.billed_qty_10                                          --BILLED_QTY_10                            NUMBER
   ,w_ptbm.billed_qty_11                                          --BILLED_QTY_11                            NUMBER
   ,w_ptbm.billed_qty_12                                          --BILLED_QTY_12                            NUMBER
   ,w_ptbm.billed_qty_13                                          --BILLED_QTY_13                            NUMBER
   ,w_ptbm.blbl_01                                                --BLBL_01                                  CHAR(3)
   ,w_ptbm.blbl_02                                                --BLBL_02                                  CHAR(3)
   ,w_ptbm.blbl_03                                                --BLBL_03                                  CHAR(3)
   ,w_ptbm.blbl_04                                                --BLBL_04                                  CHAR(3)
   ,w_ptbm.blbl_05                                                --BLBL_05                                  CHAR(3)
   ,w_ptbm.blbl_06                                                --BLBL_06                                  CHAR(3)
   ,w_ptbm.blbl_07                                                --BLBL_07                                  CHAR(3)
   ,w_ptbm.blbl_08                                                --BLBL_08                                  CHAR(3)
   ,w_ptbm.blbl_09                                                --BLBL_09                                  CHAR(3)
   ,w_ptbm.blbl_10                                                --BLBL_10                                  CHAR(3)
   ,w_ptbm.blbl_11                                                --BLBL_11                                  CHAR(3)
   ,w_ptbm.blbl_12                                                --BLBL_12                                  CHAR(3)
   ,w_ptbm.blbl_13                                                --BLBL_13                                  CHAR(3)
   ,w_ptbm.bflg_01                                                --BFLG_01                                  CHAR(1)
   ,w_ptbm.bflg_02                                                --BFLG_02                                  CHAR(1)
   ,w_ptbm.bflg_03                                                --BFLG_03                                  CHAR(1)
   ,w_ptbm.bflg_04                                                --BFLG_04                                  CHAR(1)
   ,w_ptbm.bflg_05                                                --BFLG_05                                  CHAR(1)
   ,w_ptbm.bflg_06                                                --BFLG_06                                  CHAR(1)
   ,w_ptbm.bflg_07                                                --BFLG_07                                  CHAR(1)
   ,w_ptbm.bflg_08                                                --BFLG_08                                  CHAR(1)
   ,w_ptbm.bflg_09                                                --BFLG_09                                  CHAR(1)
   ,w_ptbm.bflg_10                                                --BFLG_10                                  CHAR(1)
   ,w_ptbm.bflg_11                                                --BFLG_11                                  CHAR(1)
   ,w_ptbm.bflg_12                                                --BFLG_12                                  CHAR(1)
   ,w_ptbm.bflg_13                                                --BFLG_13                                  CHAR(1)
   ,w_ptbm.grph_mesg1                                             --GRPH_MESG1                               VARCHAR2(100)
   ,w_ptbm.tot_bill_rdg                                           --TOT_BILL_RDG                             NUMBER
   );
 end cpy_grp_bills_info;
-- End Add 4561
 /*************************************************************************************\
    private procedure check_city_suffix       -- Add 1.0.0.17A
 \*************************************************************************************/
 procedure check_city_suffix is
    w_procedure_name              varchar2(40) := 'phls0001.check_city_suffix';
    w_pos number;
 begin
    trace_label('e030', w_procedure_name);
    debug_trace(w_procedure_name,'...w_city_acct =' || w_city_acct);
    if substr(w_city_acct,14,1) = '0'
    then
       w_city_acct_new_suffix := w_city_acct;
       w_city_acct_new_14     := '0';
       w_city_acct_new_67     := '0';
    else
       --- Until routine available in PHLU0018 ---
       if instr(c_alphnum_w1_string1,lower(substr(w_city_acct,14,1))) > 0
       then
          w_pos := instr(c_alphnum_w1_string1,lower(substr(w_city_acct,14,1)));
          w_city_acct_new_14 := substr(c_alphnum_w1_string2,w_pos,1);
          w_city_acct_new_67 := substr(c_alphnum_w1_string3,w_pos,1);
       else
        --w_city_acct_new_14 := '0';        -- Del 2114 --1.0.0.69 --2.0.0.08
          w_city_acct_new_14 := substr(w_city_acct,14,1); -- Add 2114 --1.0.0.69 --2.0.0.08
          w_city_acct_new_67 := '0';
       end if;
       w_city_acct_new_suffix := substr(w_city_acct,1,13)
                              || w_city_acct_new_14
                              || substr(w_city_acct,15)
                              ;
    end if;
    debug_trace(w_procedure_name,'...w_city_acct_new_suffix =' || w_city_acct_new_suffix);
    debug_trace(w_procedure_name,'...    w_city_acct_new_14 =' || w_city_acct_new_14);
    debug_trace(w_procedure_name,'...    w_city_acct_new_67 =' || w_city_acct_new_67);
 end check_city_suffix;
 /*************************************************************************************\
    private procedure get_check_digit         -- Chg 1.0.0.17A  Move before scan_string
 \*************************************************************************************/
 function get_check_digit(p_scan_string varchar2) return varchar2 is
    w_oddn                        number(15);
    w_even                        number(15);
    w_int1                        number(15);
    w_int2                        number(15);
    w_chkd                        number(15);
    w_ptr                         number;
    w_procedure_name              varchar2(50) := 'phls0001.get_check_digit';
 begin
  --debug_trace(w_procedure_name,'... p_scan_string='  || p_scan_string);
    w_int1 := 0;
    for i in 0..33
    loop
       w_ptr := i*2 + 1;
     w_label := 'e031';
       begin
          w_oddn := to_number(substr(p_scan_string,w_ptr,1));
       exception
          when others then
             w_oddn := 0;
       end;
     w_label := 'e032';
       begin
          w_even := to_number(substr(p_scan_string,w_ptr+1,1));
       exception
          when others then
             w_even := 0;
       end;
     w_label := 'e033';
       if w_oddn < 5 then
          w_int2 := w_oddn * 2;
       else
          w_int2 := (w_oddn * 2) - 9;
       end if;
     w_label := 'e034';
       w_int1 := mod(w_int1 + w_int2,10);
     w_label := 'e035';
       w_int1 := mod(w_int1 + w_even,10);
     w_label := 'e036';
       --debug_trace(w_procedure_name,
       --                     '... ODD='  || substr(p_scan_string,w_ptr,1)   ||
       --                     '... EVEN=' || substr(p_scan_string,w_ptr+1,1) ||
       --                     '... 1: '   || to_char(w_int1)
       --                     );
    end loop;
    w_label := 'e037';
  debug_trace(w_procedure_name,'... mod(10 - w_int1,10): ' || mod(10 - w_int1,10));
    w_chkd := mod(10 - w_int1,10);
    debug_trace(w_procedure_name,'... Check Digit: ' || to_char(w_chkd));
    return   to_char(w_chkd);
 exception
  when others then
    debug_trace(w_procedure_name,'... Error <----------------------> ' );
    return   to_char(w_chkd);
 end get_check_digit;
--Start Modified 5869 -- 3.0.0.35 introduced and change the scanline procedure
--Introduced various scan type to it......
/* Start Add 4398 */
 /*************************************************************************************\
    private procedure get_scan_line --generic routine to get scan line for any account
 \*************************************************************************************/
 procedure get_scan_line(  p_scan_type        in  varchar2  default 'W1_ACCT'   --MULTI_ACCT "MULTI_ACCT_SCANLINE", B2_ACCT "B2_ACCT_SCANLINE", DCR "DCR_SCANLINE" and W1_ACCT "W1_ACCT_SCANLINE"
                          ,p_w1_acct_no       in  varchar2  --16Digit Water1 Account without dashes
                          ,p_acct_key         in  varchar2  --9 Alphacharactder Basis2 Account key/ 10 Digit DCR KEY
                          ,p_supply_type      in  varchar2  --16Digit Water1 Account without dashes
                          ,p_amnt_post_30_39  in  number    --Amount in 30to39th Position. Normally it's Penalty Amount for Bill and Same as Total Due for HelpLoan
                          ,p_amnt_post_40_49  in  number    --Amount in 40to49th Position. Normally it's Total Due Amount for Bill and HelpLoan
                          ,p_due_date         in  date      --Due Date when Bill/Statement is due
                          ,p_scan_line        out varchar2  --Scan Line will be produced
                         )
 is
    l_procedure_name              varchar2(50) := '_public.phls0001.get_scan_line';
    l_discount_digit              varchar2(1);
    l_sewer_percent               varchar2(4);
    l_last_twelve                 varchar2(12);
    l_amnt_post_30_39_str         varchar2(10);
    l_amnt_post_40_49_str         varchar2(10);
    l_ctrl_day                    char(3);
    l_acct_key_string             varchar2(17);
    l_chkd                        number(15);
    l_w1_non_alpha                varchar2(13);
    l_w1_char_67                  varchar2(1);
begin
   if instr(w_valid_scan_types,p_scan_type) <> 0 then
      trace_label('e038', l_procedure_name);
      l_discount_digit := '1';
      l_sewer_percent  := '0000';
      l_last_twelve    := '100000000000';
      --w_city_acct    := p_w1_acct_no; --del 5598 3.0.0.37
      --check_city_suffix;              --del 5598 3.0.0.37
      -- Total due amount as whole number left padded with zeroes to 10 characters, 0 if credit
      if nvl(p_amnt_post_40_49,0) < 0 then
         l_amnt_post_40_49_str := '0000000000';
      else
         l_amnt_post_40_49_str := trim(to_char(nvl(p_amnt_post_40_49,0) * 100,'0999999999'));
      end if;
      -- Penalty due amount as whole number left padded with zeroes to 10 characters, 0 if credit
      if nvl(p_amnt_post_30_39,0) < 0 then
         l_amnt_post_30_39_str := '0000000000';
      else
         l_amnt_post_30_39_str := trim(to_char(nvl(p_amnt_post_30_39,0) * 100,'0999999999'));
      end if;
      debug_trace(l_procedure_name,'...total_due_amnt   = ' || l_amnt_post_40_49_str);
      if p_scan_type = 'MULTI_ACCT' then
         l_ctrl_day       := '999';
         l_acct_key_string  := lpad(substr(p_acct_key,1,10),14,'0') || '999'; --Reference number should always be in basis2 number. Last 3 digit numbers are 999
         w_city_acct          := trim(l_ctrl_day || trim(lpad(substr(p_acct_key,1,10),13,'0'))); --Add 6045 3.0.0.37
         check_city_suffix;                                                                      --Add 6045 3.0.0.37
      elsif p_scan_type = 'B2_ACCT' then
         l_ctrl_day        := '998';
         l_acct_key_string := trim(lpad(substr(p_acct_key,1,9),17,'0'));
         if p_supply_type = 'HELPLOAN' then
            l_amnt_post_30_39_str   := l_amnt_post_40_49_str;
         end if;
         w_city_acct          := trim(l_ctrl_day || trim(lpad(substr(p_acct_key,1,10),13,'0'))); --Add 6045 3.0.0.37
         check_city_suffix;                                                                      --Add 6045 3.0.0.37
      elsif p_scan_type = 'DCR' then
         l_ctrl_day       := '997';
         l_acct_key_string  := lpad(substr(p_acct_key,1,10),17,'0');
         w_city_acct        := trim(l_ctrl_day || trim(lpad(substr(p_acct_key,1,10),13,'0')));   --Add 6045 3.0.0.37
         check_city_suffix;                                                                      --Add 6045 3.0.0.37
      elsif p_scan_type = 'W1_ACCT' then
         w_city_acct      := p_w1_acct_no; --add 5598 3.0.0.37
         check_city_suffix;                --add 5598 3.0.0.37
         --l_acct_key_string  := lpad(substr(p_w1_acct_no,4,13),17,'0');    --del 5598 3.0.0.37
         --l_ctrl_day         := substr(p_w1_acct_no,1,3);                  --del 5598 3.0.0.37
         l_acct_key_string  := lpad(substr(w_city_acct_new_suffix,4,13),17,'0'); --add 5598 3.0.0.37
         l_ctrl_day         := substr(w_city_acct_new_suffix,1,3);  --add 5598 3.0.0.37
      end if;
      w_label := 'e039';
      p_scan_line :=                          -- Posns -- Count
               '333'                          -- 01-03 == 03 fixed string
            || '72'                           -- 04-05 == 02 fixed water bill
            || to_char(p_due_date,'mmddyy')   -- 06-11 == 06
            || l_acct_key_string              -- 12-28 == 17                   -- 12-28 == 17
            || l_discount_digit               -- Dicsount code digit ?   '1'   -- 29-29 == 01
            || l_amnt_post_30_39_str          -- Penalty due amount            -- 30-39 == 10
            || l_amnt_post_40_49_str          -- Total due amount              -- 40-49 == 10
            || l_ctrl_day                     -- Control day equals route key  -- 50-52 == 03
            || l_sewer_percent                -- Sewer Percentage   '0000'     -- 53-56 == 04
            || l_last_twelve                  -- Last Twelve? '100000000000'   -- 57-68 == 12
            ;
      -- Work out the check digit
      w_label := 'e040';
      --debug_trace(w_procedure_name,'...scan_string =' || p_agrv_hl_acct_key);
      l_chkd := get_check_digit(substr(p_scan_line,1,66)|| w_city_acct_new_67||substr(p_scan_line,68,1));
      debug_trace(l_procedure_name,'... Check Digit: ' || to_char(l_chkd));
      w_label := 'e041';
      p_scan_line := substr(p_scan_line,1,66)
                  || w_city_acct_new_67
                  || to_char(l_chkd);
      debug_trace(l_procedure_name,'...w_totamnt_string     = ' || l_amnt_post_40_49_str);
      debug_trace(l_procedure_name,'...w_penamnt_string     = ' || l_amnt_post_30_39_str);
      debug_trace(l_procedure_name,'...p_due_date           = ' || to_char(p_due_date,'mmddyy'));
      debug_trace(l_procedure_name,'...w_city_acct_new_67   = ' || w_city_acct_new_67);
      debug_trace(l_procedure_name,'...Check Digit:         = ' || to_char(l_chkd));
      debug_trace(l_procedure_name,'...scan_string          = ' || p_scan_line);
   else
      -- Raise fatal error if p_proc_code not recognised
      Ciss0047.raise_exception('PHLS0001.GET_SCAN_LINE', NULL, 'SCAN_TYPE_NOT_KNOWN',
                               'SCAN_TYPE', p_scan_type, 'GET_SCAN_LINE', 'P_SCAN_TYPE', p_severity=>'F');
   end if;
 end get_scan_line;
/* End Add 4398 */
--End Modified 5869 -- 3.0.0.35 introduced and change the scanline procedure
-- end get_hl_scan_string;
/* Start Add 4398 */
 /*****************************************************************************************************************************\
    private procedure get_hl_scan_string --This is for Help Loan but we are using generic scan line routine for Help Loan Bills.
 /*****************************************************************************************************************************\
 procedure get_hl_scan_string
 is
    l_procedure_name              varchar2(40) := 'phls0001.scan_string';
    l_hl_discount_digit              varchar2(1);
    l_hl_sewer_percent               varchar2(4);
    l_hl_last_twelve                 varchar2(12);
    l_hl_penamnt_string              varchar2(10);
    l_hl_totamnt_string              varchar2(10);
    l_hl_ctrl_day                    char(3);
    l_hl_chkd                        number(15);
    l_hl_w1_non_alpha                varchar2(13);
    l_hl_w1_char_67                  varchar2(1);
begin
    trace_label('e042', l_procedure_name);
    l_hl_discount_digit := '1';
    l_hl_sewer_percent  := '0000';
    l_hl_last_twelve    := '100000000000';
    l_hl_ctrl_day       := '098';
    debug_trace(l_procedure_name,'...total_due_amnt   = ' || w_rchl.agrv_hl_total_due_amnt);
    -- Penalty due amount as whole number left padded with zeroes to 10 characters, 0 if credit
    -- Total due amount as whole number left padded with zeroes to 10 characters, 0 if credit
    w_label := 'e043';
    -- if w_ptbm.total_due_amnt < 0 then
    if nvl(w_rchl.agrv_hl_total_due_amnt,0) < 0 then
       l_hl_totamnt_string := '0000000000';
    else
       l_hl_totamnt_string := trim(to_char(nvl(w_rchl.agrv_hl_total_due_amnt,0) * 100,'0999999999'));
    end if;
    l_hl_penamnt_string := l_hl_totamnt_string;
    w_label := 'e044';
    w_rchl.agrv_hl_scan_line :=                                                              -- Posns -- Count
             '333'                                                                           -- 01-03 == 03         fixed string
          || '72'                                                                            -- 04-05 == 02         fixed water bill
          || to_char(nvl(w_ptbm.penalty_date, w_ptbm.billing_date+30),'mmddyy')              -- 06-11 == 06
          || lpad(substr(w_rchl.agrv_hl_acct_key,1,10),17,'0')
          || l_hl_discount_digit                                                             -- Dicsount code digit ?   '1'   -- 29-29 == 01
          || l_hl_penamnt_string                                                             -- Penalty due amount            -- 30-39 == 10
          || l_hl_totamnt_string                                                             -- Total due amount              -- 40-49 == 10
          || l_hl_ctrl_day                                                                   -- Control day equals route key  -- 50-52 == 03
          || l_hl_sewer_percent                                                              -- Sewer Percentage   '0000'     -- 53-56 == 04
          || l_hl_last_twelve                                                                -- Last Twelve? '100000000000'   -- 57-68 == 12
          ;
     -- Work out the check digit
    w_label := 'e045';
    --debug_trace(w_procedure_name,'...scan_string =' || w_rchl.agrv_hl_scan_line);
   l_hl_chkd := get_check_digit(substr(w_rchl.agrv_hl_scan_line,1,66)|| w_city_acct_new_67||substr(w_rchl.agrv_hl_scan_line,68,1)); --Chg 1.0.0.61 / 2.0.0.0A
   debug_trace(l_procedure_name,'... Check Digit: ' || to_char(l_hl_chkd));
   w_label := 'e046';
   w_rchl.agrv_hl_scan_line := substr(w_rchl.agrv_hl_scan_line,1,66)
                      || w_city_acct_new_67
                      || to_char(l_hl_chkd);
   debug_trace(l_procedure_name,'...w_totamnt_string     = ' || l_hl_totamnt_string);
   debug_trace(l_procedure_name,'...w_penamnt_string     = ' || l_hl_penamnt_string);
   debug_trace(l_procedure_name,'...penalty_date         = ' || to_char(nvl(w_ptbm.penalty_date, w_ptbm.billing_date+30),'mmddyy')); -- Add 3257
   debug_trace(l_procedure_name,'...w_city_acct_new_67   = ' || w_city_acct_new_67);
   debug_trace(l_procedure_name,'... Check Digit:        = ' || to_char(l_hl_chkd));
   debug_trace(l_procedure_name,'...scan_string          = ' || w_rchl.agrv_hl_scan_line);
 end get_hl_scan_string;
/* End Add 4398 */
-- end get_hl_scan_string;
-- p_agrv_hl_scan_line
 /*************************************************************************************\
    private procedure scan_string --This is for Bill eventually we will be using generic scan line routine
 \*************************************************************************************/
 procedure scan_string is
    w_procedure_name              varchar2(40) := 'phls0001.scan_string';
    w_discount_digit              varchar2(1);
    w_sewer_percent               varchar2(4);
    w_last_twelve                 varchar2(12);
    w_penamnt_string              varchar2(10);
    w_totamnt_string              varchar2(10);
 --   w_oddn                        number(15);                  -- Del 1.0.0.17A
 --   w_even                        number(15);                  -- Del 1.0.0.17A
 --   w_int1                        number(15);                  -- Del 1.0.0.17A
 --   w_int2                        number(15);                  -- Del 1.0.0.17A
    w_chkd                        number(15);
 --   w_ptr                         number;                      -- Del 1.0.0.17A
    w_w1_non_alpha                varchar2(13);                  -- Add 1.0.0.17A
    w_w1_char_67                  varchar2(1);                   -- Add 1.0.0.17A
 begin
    trace_label('e047', w_procedure_name);
    w_discount_digit := '1';
    w_sewer_percent  := '0000';
    w_last_twelve    := '100000000000';
    debug_trace(w_procedure_name,'...penalty_due_amnt = ' || w_ptbm.penalty_due_amnt);  -- Add 3257
    debug_trace(w_procedure_name,'<0><><><>total_due_amnt = ' || w_ptbm.total_due_amnt); -- Add 3257
    -- Penalty due amount as whole number left padded with zeroes to 10 characters, 0 if credit
    w_label := 'e048';
    if nvl(w_ptbm.penalty_due_amnt,0) < 0 then
       w_penamnt_string := '0000000000';
    else
       w_penamnt_string := trim(to_char(nvl(w_ptbm.penalty_due_amnt,0) * 100,'0999999999'));
    end if;
    -- Total due amount as whole number left padded with zeroes to 10 characters, 0 if credit
    w_label := 'e049';
    -- if w_ptbm.total_due_amnt < 0 then    -- Del 3257
    if nvl(w_ptbm.total_due_amnt,0) < 0 then   -- Add 3257
       w_totamnt_string := '0000000000';
    else
       --w_totamnt_string := trim(to_char(w_ptbm.total_due_amnt * 100,'0999999999'));      -- Del 3257
       w_totamnt_string := trim(to_char(nvl(w_ptbm.total_due_amnt,0) * 100,'0999999999'));   -- Add 3257
    end if;
    w_label := 'e050';
    w_ptbm.scan_string :=                                             -- Posns -- Count
             '333'                                                    -- 01-03 == 03         fixed string
          || '72'                                                     -- 04-05 == 02         fixed water bill
 --       || to_char(w_ptbm.penalty_date,'mmddyy')                    -- 06-11 == 06                -- Del 1057
          || to_char(nvl(w_ptbm.penalty_date, w_ptbm.billing_date+30),'mmddyy')  -- 06-11 == 06     -- Chg 2.0.0.23 Add 1057
                -- Account minus 3 char control day on the front
                -- left pad with zeroes to 17 characters
 -- Del         || lpad(w_ptbm.acct_key,17,'0')                                                           -- 12-28 == 17
 -- Del         || lpad(substr(PHLU0018.get_water1_acct_number(w_ptbm.acct_key),4,13),17,'0')  --1.0.0.17 -- 12-28 == 17        -- Del 1.0.0.17A
          || lpad(substr(w_city_acct_new_suffix,4,13),17,'0')     -- 12-28 == 17                         -- Add 1.0.0.17A
          || w_discount_digit                        -- Dicsount code digit ?   '1'  -- 29-29 == 01
          || w_penamnt_string         -- Penalty due amount        -- 30-39 == 10
          || w_totamnt_string                  -- Total due amount          -- 40-49 == 10
          || substr(w_ptbm.bill_account_number,1,3)  -- Control day equals route key -- 50-52 == 03
          || w_sewer_percent                        -- Sewer Percentage   '0000'    -- 53-56 == 04
          || w_last_twelve                           -- Last Twelve? '100000000000' -- 57-68 == 12
          ;
     -- Work out the check digit
    w_label := 'e051';
    --debug_trace(w_procedure_name,'...scan_string =' || w_ptbm.scan_string);
/* Del 1.0.0.61 / 2.0.0.0A
    w_chkd := get_check_digit(w_ptbm.scan_string);                                  -- Add 1.0.0.17A
    debug_trace(w_procedure_name,'... Check Digit: ' || to_char(w_chkd));
    w_label := 'e052';
    w_ptbm.scan_string := substr(w_ptbm.scan_string,1,66)                           -- Chg 1.0.0.17A
                       || w_city_acct_new_67                                        -- Add 1.0.0.17A
                       || to_char(w_chkd);                                          -- Add 1.0.0.17A
    debug_trace(w_procedure_name,'...scan_string =' || w_ptbm.scan_string);
 --Del 1.0.0.61 / 2.0.0.0A
*/
   w_chkd := get_check_digit(substr(w_ptbm.scan_string,1,66)|| w_city_acct_new_67||substr(w_ptbm.scan_string,68,1)); --Chg 1.0.0.61 / 2.0.0.0A
   debug_trace(w_procedure_name,'... Check Digit: ' || to_char(w_chkd));
   w_label := 'e053';
   w_ptbm.scan_string := substr(w_ptbm.scan_string,1,66)                           -- Chg 1.0.0.61 / 2.0.0.0A
                      || w_city_acct_new_67                                        -- Chg 1.0.0.61 / 2.0.0.0A
                      || to_char(w_chkd);                                          -- Chg 1.0.0.61 / 2.0.0.0A
   debug_trace(w_procedure_name,'...w_totamnt_string = ' || w_totamnt_string);  -- Add 3257
   debug_trace(w_procedure_name,'...w_penamnt_string = ' || w_penamnt_string);   -- Add 3257
   debug_trace(w_procedure_name,'...penalty_date = ' || to_char(nvl(w_ptbm.penalty_date, w_ptbm.billing_date+30),'mmddyy')); -- Add 3257
   debug_trace(w_procedure_name,'...w_city_acct_new_67 =' || w_city_acct_new_67);
   debug_trace(w_procedure_name,'... Check Digit: ' || to_char(w_chkd));
   debug_trace(w_procedure_name,'...scan_string =' || w_ptbm.scan_string);
 end scan_string;
 /*************************************************************************************\
    private procedure get_plan_detail
 \*************************************************************************************/
 procedure get_plan_details(p_ppln_id number) is
 /*
    w_ppln_plan_due_date             varchar2(6)   ;
    w_ppln_acct_number                  varchar2(17)  ;
    w_ppln_agreement_balance            varchar2(11)  ;
    w_ppln_agreement_amount_due         varchar2(10)  ;
    w_ppln_control_day                  varchar2(3)   ;
    w_ppln_sewer_charges                varchar2(4)   ;
    w_ppln_check_digit               varchar2(11)  ;   */
    w_ppln_cis_ta_ppln_v             cis_payment_plans%rowtype;-- ;--cis_ta_ppln_v%rowtype;
    w_ppln_acct_key                  cis_ta_acct_v.acct_key%type;
    w_ppln_no_of_payments            number;
    w_ppln_down_payment              cis_ta_pplp_v.paym_bal_amnt%type;
    w_ppln_city_acct                 varchar2(20);
    w_ppln_result                    varchar2(1);
    w_ppln_message                   varchar2(300);
    w_ppln_tot_agr_bal               number;
    w_ppln_mntly_pymt_amnt           number;
    cursor c1
    is
    select paym_amnt
    from cis_ppln_payments
    where ppln_id = p_ppln_id
    and paym_num=2 --2.0.0.27, get monthly payment amnt other than the first, which is the downpayment
    order by paym_num;
    w_procedure_name                 varchar2(50) := 'phls0001.get_plan_details';
 begin
    w_ppln_phl_tmg_down_pay_bill := null; --initialize it to null
    w_label := 'e054';
    select * into  w_ppln_cis_ta_ppln_v from cis_payment_plans
    where ppln_id = p_ppln_id;
    --
    -- Common Variables
    --
    --
    -- Basis2 Account Key  -- Scan Variable
    --
    w_label := 'e055';
    select acct_key into  w_ppln_acct_key
    from cis_accounts
    where inst_id     = w_ppln_cis_ta_ppln_v.inst_id
      and cust_id     = w_ppln_cis_ta_ppln_v.cust_id
      and supply_type = w_ppln_cis_ta_ppln_v.supply_type;
    --
    -- No of payments-1
    --
    select count(*)-1 into w_ppln_no_of_payments
    from cis_ppln_payments
    where ppln_id = p_ppln_id;
    --
    -- Down payment
    --
    w_label := 'e056';
    select paym_bal_amnt
          ,to_char(paym_due_date,'MMDDYY') --Add 4723
      into w_ppln_down_payment
          ,w_paym_due_date --Add 4723
    from cis_ppln_payments
    where ppln_id = p_ppln_id
      and paym_num = 1;
    --
    -- Reprt Variable w_ppln_phl_tmg_down_pay_bill.bal_due_after_down_pymt
    -- Balance Due after Down Payment --Scan String Variable
    --
    w_label := 'e057';
    select to_char(sum(paym_bal_amnt) - w_ppln_down_payment)
    into w_ppln_phl_tmg_down_pay_bill.bal_due_after_down_pymt
    from cis_ppln_payments
    where ppln_id = p_ppln_id;
    w_ppln_agreement_amount_due := lpad(replace(to_char(w_ppln_phl_tmg_down_pay_bill.bal_due_after_down_pymt),'.',''),10,'0');
    debug_trace(w_procedure_name,'...w_ppln_phl_tmg_down_pay_bill.bal_due_after_down_pymt =' || w_ppln_phl_tmg_down_pay_bill.bal_due_after_down_pymt);
    debug_trace(w_procedure_name,'...w_ppln_agreement_amount_due                          =' || w_ppln_agreement_amount_due                         );
    --
    -- Control Days and Water1 Account Scan String
    --
    w_label := 'e058';
    phlu0018.b2_acct_to_city_acct (
                                   p_acct_id   => null
                                  ,p_acct_key  => w_ppln_acct_key
                                  ,p_city_acct => w_ppln_city_acct
                                  ,p_result    => w_ppln_result
                                  ,p_message   => w_ppln_message
                                  );
    if w_ppln_result = 'V' then
       w_label := 'e059';
       w_ppln_control_day := trim(lpad(substr(w_ppln_city_acct, 1,3),3,'0'));
       w_city_acct := w_ppln_city_acct;                                                   -- Add 1.0.0.17A
       check_city_suffix;                                                                 -- Add 1.0.0.17A
       w_ppln_acct_number := trim(lpad(substr(w_city_acct_new_suffix,4),17,'0'));         ----1.0.0.11  -- Chg 1.0.0.17A
    end if;
    debug_trace(w_procedure_name,'...w_ppln_control_day  =' || w_ppln_control_day);
    debug_trace(w_procedure_name,'...w_ppln_acct_number  =' || w_ppln_acct_number);
    w_label := 'e060';
    --
    -- City Account in 3-5-5-3 format
    --
 --   w_ppln_city_acct := phlu0018.get_formatted_water1_acct(w_ppln_city_acct,'3553','-');     -- Del 1.0.0.17A
    w_ppln_city_acct := phlu0018.get_formatted_water1_acct(w_city_acct_new_suffix,'3553','-'); -- Add 1.0.0.17A
    debug_trace(w_procedure_name,'...w_ppln_city_acct  =' || w_ppln_city_acct);
    --
    -- Sewer Charges
    --
    w_ppln_sewer_charges := '0000';
    --
    -- Monthly Payment Amount
    --
    w_label := 'e061';
    for r1 in c1
    loop
       w_ppln_mntly_pymt_amnt := r1.paym_amnt;
       debug_trace(w_procedure_name,'...w_ppln_mntly_pymt_amnt  =' || r1.paym_amnt);
    end loop;
    debug_trace(w_procedure_name,'...w_ppln_mntly_pymt_amnt  =' || w_ppln_mntly_pymt_amnt);
    if w_ppln_cis_ta_ppln_v.ppln_type = 'B' then
       --
       -- Payment Due Date    --Scan String Variable
       --
       w_label := 'e062';
       --w_ppln_plan_due_date := trim(to_char(w_ppln_cis_ta_ppln_v.bdbt_first_payment_date,'MMDDYY')); --Del 4723
       w_ppln_plan_due_date :=w_paym_due_date; --Add 4723
       --
       -- Report Variable in MM/DD/YY
       --
       --w_ppln_phl_tmg_down_pay_bill.due_date := trim(to_char(w_ppln_cis_ta_ppln_v.bdbt_first_payment_date,'MM/DD/YY'));  --Del 4723
          w_ppln_phl_tmg_down_pay_bill.due_date :=to_char(to_date(w_paym_due_date,'MMDDYY'),'MM/DD/YY'); --Add 4723
       debug_trace(w_procedure_name,'...w_ppln_plan_due_date                   =' || w_ppln_plan_due_date);
       debug_trace(w_procedure_name,'...w_ppln_phl_tmg_down_pay_bill.due_date  =' || w_ppln_phl_tmg_down_pay_bill.due_date);
       --
       -- Agreement Balance  --Scan String Variable
       --
       w_label := 'e063';
       w_ppln_agreement_balance := trim(to_char(w_ppln_cis_ta_ppln_v.bdbt_back_debt_amnt));
       w_ppln_agreement_balance := trim(lpad(replace(w_ppln_agreement_balance,'.',''),11,'0'));
       --
       -- Total Agreement Amount
       --
       w_label := 'e064';
       -- w_ppln_tot_agr_bal  :=  w_ppln_cis_ta_ppln_v.bdbt_plan_amnt; --Del 4385
       --w_ppln_tot_agr_bal  :=  w_ppln_cis_ta_ppln_v.ipln_back_debt_amnt; --bdbt_plan_amnt; --Add 4385
       w_ppln_tot_agr_bal  :=  w_ppln_cis_ta_ppln_v.bdbt_back_debt_amnt; --bdbt_plan_amnt; --Add 4385A
       --
       -- Does't give proper value.
       --w_ppln_mntly_pymt_amnt := w_ppln_cis_ta_ppln_v.bdbt_reg_payment_amnt;
    elsif w_ppln_cis_ta_ppln_v.ppln_type = 'I' then
       --
       -- Payment Due Date    --Scan String Variable
       --
       w_label := 'e065';
       --w_ppln_plan_due_date := trim(to_char(w_ppln_cis_ta_ppln_v.ipln_first_payment_date,'MMDDYY'));--Del 4723
       w_ppln_plan_due_date := w_paym_due_date;--Add 4723
       --
       -- Report Variable in MM/DD/YY
       --
       --w_ppln_phl_tmg_down_pay_bill.due_date := trim(to_char(w_ppln_cis_ta_ppln_v.ipln_first_payment_date,'MM/DD/YY')); --Del 4723
       w_ppln_phl_tmg_down_pay_bill.due_date := to_char(to_date(w_paym_due_date,'MMDDYY'),'MM/DD/YY');--Add 4723
       --
       -- Agreement Balance
       --
       w_label := 'e066';
       w_ppln_agreement_balance := trim(to_char(w_ppln_cis_ta_ppln_v.ipln_back_debt_amnt));
       w_ppln_agreement_balance := trim(lpad(replace(w_ppln_agreement_balance,'.',''),11,'0'));
       --
       -- Total Agreement Amount
       --
       w_label := 'e067';
       w_ppln_tot_agr_bal  :=  w_ppln_cis_ta_ppln_v.ipln_plan_amnt;
       --
       -- Monthly Payment Amount
       --
       --w_label := 'e068';
 --DEL --w_ppln_mntly_pymt_amnt := w_ppln_cis_ta_ppln_v.ipln_reg_payment_amnt;
    end if;
    ---
    --- Remaining Report Variables
    ---
    select trim(cust_name) into w_ppln_phl_tmg_down_pay_bill.cust_name
    from cis_customers
    where cust_id = w_ppln_cis_ta_ppln_v.cust_id;
    w_label := 'e069';
    select
        trim(line1)
       ,trim(line2)
       ,trim(line3)
       ,trim(line4)
       ,trim(line5)
       ,trim(line6)
       ,trim(line7)
       ,trim(line8)
    into
       w_ppln_phl_tmg_down_pay_bill.prop_addr_line1
       ,w_ppln_phl_tmg_down_pay_bill.prop_addr_line2
       ,w_ppln_phl_tmg_down_pay_bill.prop_addr_line3
       ,w_ppln_phl_tmg_down_pay_bill.prop_addr_line4
       ,w_ppln_phl_tmg_down_pay_bill.prop_addr_line5
       ,w_ppln_phl_tmg_down_pay_bill.prop_addr_line6
       ,w_ppln_phl_tmg_down_pay_bill.prop_addr_line7
       ,w_ppln_phl_tmg_down_pay_bill.prop_addr_line8
    from
       cis_installations inst,
       cis_addresses     addr
    where
        inst.prop_addr_id = addr.addr_id
    and inst.inst_id      = w_ppln_cis_ta_ppln_v.inst_id;
    w_label := 'e070';
    debug_trace(w_procedure_name,'...w_ppln_phl_tmg_down_pay_bill.bal_due_after_down_pymt =' || w_ppln_phl_tmg_down_pay_bill.bal_due_after_down_pymt);
    w_ppln_phl_tmg_down_pay_bill.cust_id                    :=  w_ppln_cis_ta_ppln_v.cust_id     ;
    w_ppln_phl_tmg_down_pay_bill.inst_id                    :=  w_ppln_cis_ta_ppln_v.inst_id     ;
    w_ppln_phl_tmg_down_pay_bill.tran_id                    :=  null                            ;
    w_ppln_phl_tmg_down_pay_bill.supply_type                :=  w_ppln_cis_ta_ppln_v.supply_type ;
    w_ppln_phl_tmg_down_pay_bill.tot_agr_amnt               :=  w_ppln_tot_agr_bal               ;
    w_ppln_phl_tmg_down_pay_bill.no_of_monthly_pymts        :=  w_ppln_no_of_payments            ;
    w_ppln_phl_tmg_down_pay_bill.monthly_pymt_amnt          :=  w_ppln_mntly_pymt_amnt           ;
    w_ppln_phl_tmg_down_pay_bill.down_pymt_amnt             :=  w_ppln_down_payment                  ;
 -- w_ppln_phl_tmg_down_pay_bill.due_date                   :=  w_ppln_plan_due_date             ;
 -- w_ppln_phl_tmg_down_pay_bill.bill_account_number        :=  w_ppln_city_acct                 ;                         --Del 3305
    w_ppln_phl_tmg_down_pay_bill.bill_account_number        :=  phlu0018.get_formatted_water1_acct(w_city_acct,'3553','-');--Add 3305
    w_ppln_phl_tmg_down_pay_bill.scan_string                :=  null                            ;
 end get_plan_details;
 /*************************************************************************************\
    private procedure scan_string_generic
    --p_acct_plan_debt_flag := 'A' for Account
    --p_acct_plan_debt_flag := 'P' for AGREEMENT PLAN
    --p_acct_plan_debt_flag := 'D' for DEBT COLLECTION
 \*************************************************************************************/
 procedure scan_string_down_payment(p_ppln_id number)
 is
    w_procedure_name   varchar2(50) := 'phls0001.scan_string_generic';
    w_check_digit      varchar2(1);
 begin
    trace_label('e071', w_procedure_name);
    w_label := 'e072';
    get_plan_details(p_ppln_id);
    w_label := 'e073';
    w_ppln_scan_string :=                                         -- Posns -- Count
          '333'                                                   -- 01-03 == 03         FIXED STRING
       || '72'                                                    -- 04-05 == 02         FIXED WATER BILL
       || w_ppln_plan_due_date                                    -- 06-11 == 06         PLAN DUE DATE 'MMDDYY'
       || w_ppln_acct_number                                      -- 12-28 == 17         ACCOUNT NUMBER
       || w_ppln_agreement_balance                                -- 29-39 == 11         AGREEMENT_BALANCE
       || w_ppln_agreement_amount_due                             -- 40-49 == 10         AMOUNT_DUE
       || w_ppln_control_day                                      -- 50-52 == 03         CONTROL_DUE
       || w_ppln_sewer_charges                                    -- 53-56 == 04         SEWER_CHARGES
       || w_ppln_last_twelve;                                     -- 57-68 == 12         FIXED STRING
    w_check_digit := get_check_digit(w_ppln_scan_string);
    w_label := 'e074';
    debug_trace(w_procedure_name,'...w_ppln_plan_due_date        = ' || w_ppln_plan_due_date);
    debug_trace(w_procedure_name,'...w_ppln_acct_number          = ' || w_ppln_acct_number);
    debug_trace(w_procedure_name,'...w_ppln_agreement_balance    = ' || w_ppln_agreement_balance);
    debug_trace(w_procedure_name,'...w_ppln_agreement_amount_due = ' || w_ppln_agreement_amount_due);
    debug_trace(w_procedure_name,'...w_ppln_control_day          = ' || w_ppln_control_day);
    debug_trace(w_procedure_name,'...w_ppln_sewer_charges        = ' || w_ppln_sewer_charges);
    debug_trace(w_procedure_name,'...w_ppln_last_twelve          = ' || w_ppln_last_twelve);
 --   w_ppln_scan_string := substr(w_ppln_scan_string,1,67) || to_char(w_check_digit);  -- Del 1.0.0.17A
    w_ppln_scan_string := substr(w_ppln_scan_string,1,66)                           -- Add 1.0.0.17A
                       || w_city_acct_new_67                                        -- Add 1.0.0.17A
                       || to_char(w_check_digit);                                   -- Add 1.0.0.17A
    debug_trace(w_procedure_name,'...scan_string =' || w_ppln_scan_string);
    --
    -- Report variable
    --
    w_ppln_phl_tmg_down_pay_bill.scan_string :=  trim(w_ppln_scan_string);
    w_label := 'e075';
    debug_trace(w_procedure_name,'...w_ppln_phl_tmg_down_pay_bill.bal_due_after_down_pymt =' || w_ppln_phl_tmg_down_pay_bill.bal_due_after_down_pymt);
 end scan_string_down_payment;
 /*************************************************************************************\
    private procedure inst_phl_tmg_down_pay_bill
 \*************************************************************************************/
    procedure inst_phl_tmg_down_pay_bill(p_process_id number default null)
    is
       w_procedure_name   varchar2(50) := 'phls0001.scan_string_generic';
    begin
       w_label := 'e076';
       debug_trace(w_procedure_name,'p_process_id                                          '||p_process_id                                         );
       debug_trace(w_procedure_name,'w_ppln_phl_tmg_down_pay_bill.cust_id                  '||w_ppln_phl_tmg_down_pay_bill.cust_id                 );
       debug_trace(w_procedure_name,'w_ppln_phl_tmg_down_pay_bill.inst_id                  '||w_ppln_phl_tmg_down_pay_bill.inst_id                 );
       debug_trace(w_procedure_name,'w_ppln_phl_tmg_down_pay_bill.tran_id                  '||w_ppln_phl_tmg_down_pay_bill.tran_id                 );
       debug_trace(w_procedure_name,'w_ppln_phl_tmg_down_pay_bill.supply_type              '||w_ppln_phl_tmg_down_pay_bill.supply_type             );
       debug_trace(w_procedure_name,'w_ppln_phl_tmg_down_pay_bill.tot_agr_amnt             '||w_ppln_phl_tmg_down_pay_bill.tot_agr_amnt            );
       debug_trace(w_procedure_name,'w_ppln_phl_tmg_down_pay_bill.bal_due_after_down_pymt  '||w_ppln_phl_tmg_down_pay_bill.bal_due_after_down_pymt );
       debug_trace(w_procedure_name,'w_ppln_phl_tmg_down_pay_bill.no_of_monthly_pymts      '||w_ppln_phl_tmg_down_pay_bill.no_of_monthly_pymts     );
       debug_trace(w_procedure_name,'w_ppln_phl_tmg_down_pay_bill.monthly_pymt_amnt        '||w_ppln_phl_tmg_down_pay_bill.monthly_pymt_amnt       );
       debug_trace(w_procedure_name,'w_ppln_phl_tmg_down_pay_bill.down_pymt_amnt           '||w_ppln_phl_tmg_down_pay_bill.down_pymt_amnt          );
       debug_trace(w_procedure_name,'w_ppln_phl_tmg_down_pay_bill.due_date                 '||w_ppln_phl_tmg_down_pay_bill.due_date                );
       debug_trace(w_procedure_name,'w_ppln_phl_tmg_down_pay_bill.cust_name                '||w_ppln_phl_tmg_down_pay_bill.cust_name               );
       debug_trace(w_procedure_name,'w_ppln_phl_tmg_down_pay_bill.prop_addr_line1          '||w_ppln_phl_tmg_down_pay_bill.prop_addr_line1         );
       debug_trace(w_procedure_name,'w_ppln_phl_tmg_down_pay_bill.prop_addr_line2          '||w_ppln_phl_tmg_down_pay_bill.prop_addr_line2         );
       debug_trace(w_procedure_name,'w_ppln_phl_tmg_down_pay_bill.prop_addr_line3          '||w_ppln_phl_tmg_down_pay_bill.prop_addr_line3         );
       debug_trace(w_procedure_name,'w_ppln_phl_tmg_down_pay_bill.prop_addr_line4          '||w_ppln_phl_tmg_down_pay_bill.prop_addr_line4         );
       debug_trace(w_procedure_name,'w_ppln_phl_tmg_down_pay_bill.prop_addr_line5          '||w_ppln_phl_tmg_down_pay_bill.prop_addr_line5         );
       debug_trace(w_procedure_name,'w_ppln_phl_tmg_down_pay_bill.prop_addr_line6          '||w_ppln_phl_tmg_down_pay_bill.prop_addr_line6         );
       debug_trace(w_procedure_name,'w_ppln_phl_tmg_down_pay_bill.prop_addr_line7          '||w_ppln_phl_tmg_down_pay_bill.prop_addr_line7         );
       debug_trace(w_procedure_name,'w_ppln_phl_tmg_down_pay_bill.prop_addr_line8          '||w_ppln_phl_tmg_down_pay_bill.prop_addr_line8         );
       debug_trace(w_procedure_name,'w_ppln_phl_tmg_down_pay_bill.bill_account_number      '||w_ppln_phl_tmg_down_pay_bill.bill_account_number     );
       debug_trace(w_procedure_name,'w_ppln_phl_tmg_down_pay_bill.scan_string              '||w_ppln_phl_tmg_down_pay_bill.scan_string             );
       insert into phl_tmg_down_pay_bill
       (
        process_id
       ,cust_id
       ,inst_id
       ,tran_id
       ,supply_type
       ,tot_agr_amnt
       ,bal_due_after_down_pymt
       ,no_of_monthly_pymts
       ,monthly_pymt_amnt
       ,down_pymt_amnt
       ,due_date
       ,cust_name
       ,prop_addr_line1
       ,prop_addr_line2
       ,prop_addr_line3
       ,prop_addr_line4
       ,prop_addr_line5
       ,prop_addr_line6
       ,prop_addr_line7
       ,prop_addr_line8
       ,bill_account_number
       ,scan_string
       )
       values
       (
        p_process_id
       ,w_ppln_phl_tmg_down_pay_bill.cust_id
       ,w_ppln_phl_tmg_down_pay_bill.inst_id
       ,w_ppln_phl_tmg_down_pay_bill.tran_id
       ,w_ppln_phl_tmg_down_pay_bill.supply_type
       ,trim(w_ppln_phl_tmg_down_pay_bill.tot_agr_amnt)
       ,trim(w_ppln_phl_tmg_down_pay_bill.bal_due_after_down_pymt)
       ,trim(w_ppln_phl_tmg_down_pay_bill.no_of_monthly_pymts)
       ,trim(w_ppln_phl_tmg_down_pay_bill.monthly_pymt_amnt)
       ,trim(w_ppln_phl_tmg_down_pay_bill.down_pymt_amnt)
       ,trim(w_ppln_phl_tmg_down_pay_bill.due_date)
       ,trim(w_ppln_phl_tmg_down_pay_bill.cust_name)
       ,trim(w_ppln_phl_tmg_down_pay_bill.prop_addr_line1)
       ,trim(w_ppln_phl_tmg_down_pay_bill.prop_addr_line2)
       ,trim(w_ppln_phl_tmg_down_pay_bill.prop_addr_line3)
       ,trim(w_ppln_phl_tmg_down_pay_bill.prop_addr_line4)
       ,trim(w_ppln_phl_tmg_down_pay_bill.prop_addr_line5)
       ,trim(w_ppln_phl_tmg_down_pay_bill.prop_addr_line6)
       ,trim(w_ppln_phl_tmg_down_pay_bill.prop_addr_line7)
       ,trim(w_ppln_phl_tmg_down_pay_bill.prop_addr_line8)
       ,trim(w_ppln_phl_tmg_down_pay_bill.bill_account_number)
       ,trim(w_ppln_phl_tmg_down_pay_bill.scan_string)
       );
       w_label := 'e077';
    end;
 /*************************************************************************************\
    public procedure print_down_payment
 \*************************************************************************************/
    procedure assemble_down_payment(p_process_id  in   cis_process_restart.process_id%type default null,
                                    p_ppln_id     number)
    is
       w_procedure_name  varchar2(40) := 'phls0001.assemble_down_payment';
    begin
       w_label := 'e078';
       load_ref_data;
       init;
       --debug(w_procedure_name, w_label, 'Message Level ' || w_message_trace_level);
       debug_trace(w_procedure_name,'.. Trace:   scan_string_down_payment ');
       if p_ppln_id is null then
       ciss0047.raise_exception(w_procedure_name, w_label, 'cis_internal_error',
                                'error', 'Null parameter supplied',
--                                   'e079', 'plan id can not be null for PAYMENT PLAN DOWNPAYMENT',  -- del 3.0.0.2
--                                   'PARM', 'RESTART ID',                                            -- del 3.0.0.2
                                    p_severity=>'f');
       end if;
       scan_string_down_payment(p_ppln_id);
       w_label := 'e080';
       debug_trace(w_procedure_name,'.. Trace:   inst_phl_tmg_down_pay_bill ');
       inst_phl_tmg_down_pay_bill(p_process_id);
       w_label := 'e081';
       debug_trace(w_procedure_name,'.. Trace:   Over ');
    end assemble_down_payment;
 /*************************************************************************************\
    private procedure inst_phl_tmg_down_pay_bill
 \*************************************************************************************/
    procedure inst_phl_tmg_pay_advice(p_process_id number default null)
    is
       w_procedure_name  varchar2(40) := 'phls0001.inst_phl_tmg_pay_advice';
    begin
       w_label := 'e082';
       debug_trace(w_procedure_name,'process_id              ' ||p_process_id                                 );
       debug_trace(w_procedure_name,'cust_id                 ' ||w_phl_tmg_pay_advice.cust_id                 );
       debug_trace(w_procedure_name,'inst_id                 ' ||w_phl_tmg_pay_advice.inst_id                 );
       debug_trace(w_procedure_name,'tran_id                 ' ||w_phl_tmg_pay_advice.tran_id                 );
       debug_trace(w_procedure_name,'supply_type             ' ||w_phl_tmg_pay_advice.supply_type             );
       debug_trace(w_procedure_name,'debt_coll_id            ' ||w_phl_tmg_pay_advice.debt_coll_id            );
       debug_trace(w_procedure_name,'pay_adv_amnt            ' ||w_phl_tmg_pay_advice.pay_adv_amnt            );
       debug_trace(w_procedure_name,'principal               ' ||w_phl_tmg_pay_advice.principal               );
       debug_trace(w_procedure_name,'penalty                 ' ||w_phl_tmg_pay_advice.penalty                 );
       debug_trace(w_procedure_name,'lein                    ' ||w_phl_tmg_pay_advice.lein                    );
       debug_trace(w_procedure_name,'pymt_date               ' ||w_phl_tmg_pay_advice.pymt_date               );
       debug_trace(w_procedure_name,'cust_name               ' ||w_phl_tmg_pay_advice.cust_name               );
       debug_trace(w_procedure_name,'prop_addr_line1         ' ||w_phl_tmg_pay_advice.prop_addr_line1         );
       debug_trace(w_procedure_name,'prop_addr_line2         ' ||w_phl_tmg_pay_advice.prop_addr_line2         );
       debug_trace(w_procedure_name,'prop_addr_line3         ' ||w_phl_tmg_pay_advice.prop_addr_line3         );
       debug_trace(w_procedure_name,'prop_addr_line4         ' ||w_phl_tmg_pay_advice.prop_addr_line4         );
       debug_trace(w_procedure_name,'prop_addr_line5         ' ||w_phl_tmg_pay_advice.prop_addr_line5         );
       debug_trace(w_procedure_name,'prop_addr_line6         ' ||w_phl_tmg_pay_advice.prop_addr_line6         );
       debug_trace(w_procedure_name,'prop_addr_line7         ' ||w_phl_tmg_pay_advice.prop_addr_line7         );
       debug_trace(w_procedure_name,'prop_addr_line8         ' ||w_phl_tmg_pay_advice.prop_addr_line8         );
       debug_trace(w_procedure_name,'water1_account          ' ||w_phl_tmg_pay_advice.water1_account          );
       debug_trace(w_procedure_name,'water1_acct_wo_ctrl_day ' ||w_phl_tmg_pay_advice.water1_acct_wo_ctrl_day );
       debug_trace(w_procedure_name,'ctrl_day                ' ||w_phl_tmg_pay_advice.ctrl_day                );
       debug_trace(w_procedure_name,'scan_string             ' ||w_phl_tmg_pay_advice.scan_string             );
       insert into phl_tmg_pay_advice
       (
        process_id
       ,cust_id
       ,inst_id
       ,tran_id
       ,supply_type
       ,print_date
       ,debt_coll_id
       ,pay_adv_amnt
       ,principal
       ,penalty
       ,lein
       ,pymt_date
       ,cust_name
       ,prop_addr_line1
       ,prop_addr_line2
       ,prop_addr_line3
       ,prop_addr_line4
       ,prop_addr_line5
       ,prop_addr_line6
       ,prop_addr_line7
       ,prop_addr_line8
       ,water1_account
       ,water1_acct_wo_ctrl_day
       ,ctrl_day
       ,scan_string
       ,tot_bal_amnt
       ,debt_bal_amnt                                        --1.0.0.59
       ,debt_coll_path                                       --1.0.0.59
       ,debt_coll_path_desc                                  --1.0.0.59
       ,debt_creation_date                                   --1.0.0.59
       ,debt_coll_key                                        --1.0.0.59
       )
       values
       (
        p_process_id
       ,trim(w_phl_tmg_pay_advice.cust_id)
       ,trim(w_phl_tmg_pay_advice.inst_id)
       ,trim(w_phl_tmg_pay_advice.tran_id)
       ,trim(w_phl_tmg_pay_advice.supply_type)
       ,trim(to_char(sysdate,'mm/dd/yyyy'))
       ,trim(w_phl_tmg_pay_advice.debt_coll_id)
       ,trim(w_phl_tmg_pay_advice.pay_adv_amnt)
       ,trim(w_phl_tmg_pay_advice.principal)
       ,trim(w_phl_tmg_pay_advice.penalty)
       ,trim(w_phl_tmg_pay_advice.lein)
       ,trim(w_phl_tmg_pay_advice.pymt_date)
       ,trim(w_phl_tmg_pay_advice.cust_name)
       ,trim(w_phl_tmg_pay_advice.prop_addr_line1)
       ,trim(w_phl_tmg_pay_advice.prop_addr_line2)
       ,trim(w_phl_tmg_pay_advice.prop_addr_line3)
       ,trim(w_phl_tmg_pay_advice.prop_addr_line4)
       ,trim(w_phl_tmg_pay_advice.prop_addr_line5)
       ,trim(w_phl_tmg_pay_advice.prop_addr_line6)
       ,trim(w_phl_tmg_pay_advice.prop_addr_line7)
       ,trim(w_phl_tmg_pay_advice.prop_addr_line8)
       ,trim(w_phl_tmg_pay_advice.water1_account)
       ,trim(w_phl_tmg_pay_advice.water1_acct_wo_ctrl_day)
       ,trim(w_phl_tmg_pay_advice.ctrl_day)
       ,trim(w_phl_tmg_pay_advice.scan_string)
       ,trim(w_phl_tmg_pay_advice.tot_bal_amnt)
       ,trim(w_phl_tmg_pay_advice.debt_bal_amnt)                --1.0.0.59
       ,trim(w_phl_tmg_pay_advice.debt_coll_path)               --1.0.0.59
       ,trim(w_phl_tmg_pay_advice.debt_coll_path_desc)          --1.0.0.59
       ,trim(w_phl_tmg_pay_advice.debt_creation_date)           --1.0.0.59
       ,trim(w_phl_tmg_pay_advice.debt_coll_key)                --1.0.0.59
       );
       w_label := 'e083';
    end inst_phl_tmg_pay_advice;
 /*************************************************************************************\
    private procedure get_pay_advice_details
 \*************************************************************************************/
 procedure get_pay_advice_details(p_debt_coll_id number) is
    --
    -- Variables for Scan String
    --
    /*w_padv_due_date             varchar2(6)   ;
    --w_padv_acct_number          varchar2(17)  ;
    w_padv_debt_coll_key          varchar2(17)  ;
    w_padv_amnt_w_penalty         varchar2(10)  ;
    w_padv_amnt_wo_penalty        varchar2(10)  ;
    w_padv_control_day            varchar2(3)   ;
    w_ppln_sewer_charges          varchar2(4)   ;
    w_ppln_last_twelve            varchar2(12)  := '100000000000';
    w_phl_tmg_pay_advice          phl_tmg_pay_advice%rowtype;
    */
    w_cis_debt_collection   cis_debt_collection%rowtype;
    w_padv_acct_key         cis_ta_acct_v.acct_key%type;
    w_padv_acct_id          cis_ta_acct_v.acct_id%type;
    w_padv_basis2_acct      varchar2(20);
    w_padv_city_acct        varchar2(20);
    w_padv_result           varchar2(1);
    w_padv_message          varchar2(300);
    w_principal_amnt        number;
    w_penalty_amnt          number;
    w_lien_amnt             number;
    w_credit_amnt           number;
    w_total_amnt            number;
    w_tot_bal_amnt          number;
    w_debt_coll_path_desc   varchar2(40);  --1.0.0.59
    w_procedure_name  varchar2(40) := 'phls0001.get_pay_advice_details';
 begin
    trace_label('e084', w_procedure_name);
    if p_debt_coll_id is null then
       ciss0047.raise_exception(w_procedure_name, w_label, 'cis_internal_error',
                                'error', 'Null parameter supplied',
--                                'e085', 'debt collection id can not be null for pay advice',  -- del 3.0.0.2
--                                'PARM', 'RESTART ID',                                         -- del 3.0.0.2
                                 p_severity=>'f');
    end if;
    w_phl_tmg_pay_advice := null;
    select * into w_cis_debt_collection
    from cis_debt_collection
    where debt_coll_id = p_debt_coll_id;
    --
    -- Basis2 Account Key  -- Scan Variable
    --
    w_label := 'e086';
    select acct_id       , acct_key       , acct_bal_amnt  --Mod 5869 3.0.0.35 Moved acct_bal_amnt from below, to avoid quering accts table twice
    into
           w_padv_acct_id, w_padv_acct_key, w_tot_bal_amnt --Mod 5869 3.0.0.35 Moved acct_bal_amnt from below, to avoid quering accts table twice
    from cis_accounts
    where inst_id     = w_cis_debt_collection.inst_id
      and cust_id     = w_cis_debt_collection.cust_id
      and supply_type = w_cis_debt_collection.supply_type;
    --
    -- Scan Variable for Pay Advice -->w_padv_acct_key
    --
    w_label := 'e087';
    phlu0018.b2_acct_to_city_acct (
                                   p_acct_id   => w_padv_acct_id
                                  ,p_acct_key  => w_padv_acct_key   ---Scan Variable for Water1 Account
                                  ,p_city_acct => w_padv_city_acct
                                  ,p_result    => w_padv_result
                                  ,p_message   => w_padv_message
                                  );
    if w_padv_result = 'V' then
       w_label := 'e088';
       --
       -- Scan Variable for Pay Advice -->w_padv_control_day
       -- Scan Variable for Pay Advice -->w_padv_debt_coll_key
       --
       w_padv_basis2_acct := substr(PHLU0018.get_water1_acct_number(w_padv_acct_key),4,13);       --'1.0.0.17'
       --w_padv_control_day := lpad(substr(w_padv_city_acct, 1,3),3,'0');            -- Del 1.0.0.39
       --w_padv_acct_number := lpad(substr(w_padv_city_acct,4),17,'0');              --1.0.0.11A
       --w_padv_debt_coll_key := lpad(w_cis_debt_collection.debt_coll_key,17,'0');  --'1.0.0.59' --'1.0.0.17'  --1.0.0.11A
       --w_padv_debt_coll_key :=  lpad(w_padv_basis2_acct,17,'0');                     --'1.0.0.17'
       /* Start Del 5869  3.0.0.35
       --
       -- Start Add 1.0.0.39 --
       case w_cis_debt_collection.debt_coll_path
        when 'BNKRPT07' then w_padv_control_day := '321';
        when 'BNKRPT11' then w_padv_control_day := '322';
        when 'BNKRPT13' then w_padv_control_day := '323';
        when 'CRISIS'   then w_padv_control_day := '132';
        when 'LIHEAP'   then w_padv_control_day := '133';
        when 'OLD-WRAP' then w_padv_control_day := '220';
        when 'UESF'     then w_padv_control_day := '130';
        when 'VACANT'   then w_padv_control_day := '119';
        else w_padv_control_day := lpad(substr(w_padv_city_acct, 1,3),3,'0');
       end case;
       -- End   1.0.0.39 --
       --End Del 5869  3.0.0.35  */
       w_padv_control_day := '997';  --Add 5869  3.0.0.35
    end if;
    --
    -- Scan Variable for Pay Advice    -->w_padv_due_date
    --
    w_padv_due_date := to_char(w_cis_debt_collection.debt_coll_stage_change_datime,'mmddyy');
    --
    -- Scan Variable for Pay Advice    -->w_padv_amnt_w_penalty
    --
    --w_padv_amnt_w_penalty := to_char(w_cis_debt_collection.pay_advice_amnt); --Del 2.0.0.54
    w_padv_amnt_w_penalty := trim(to_char(w_cis_debt_collection.pay_advice_amnt,'9999999.99')); --Add 2.0.0.54
    w_padv_amnt_w_penalty := lpad(replace(w_padv_amnt_w_penalty,'.',''),10,'0');
    --
    -- Scan Variable for Pay Advice    -->w_padv_amnt_wo_penalty
    --
    --w_padv_amnt_wo_penalty := to_char(w_cis_debt_collection.pay_advice_amnt);
    --w_padv_amnt_wo_penalty := lpad(replace(w_padv_amnt_wo_penalty,'.',''),10,'0');
    w_padv_amnt_wo_penalty   := w_padv_amnt_w_penalty;
    --
    -- Scan Variable for Pay Advice    -->w_padv_29thchar
    --
    w_padv_29thchar := '7';
    --
    -- Scan Variable for Pay Advice    -->w_padv_sewer_charges
    --
    w_padv_sewer_charges := '0000';
    ---------------------------------------------------------------------------------------
    ----------------------------Report Variables-------------------------------------------
    ---------------------------------------------------------------------------------------
    phls0006.debt_split(p_acct_id          => w_padv_acct_id
                      ,p_cust_id           => w_cis_debt_collection.cust_id
                      ,p_inst_id           => w_cis_debt_collection.inst_id
                      ,p_principal_amnt    => w_principal_amnt
                      ,p_penalty_amnt      => w_penalty_amnt
                      ,p_lien_amnt         => w_lien_amnt
                      ,p_credit_amnt       => w_credit_amnt
                      ,p_total_amnt        => w_total_amnt);
    select cust_name into w_phl_tmg_pay_advice.cust_name
    from cis_customers
    where cust_id = w_cis_debt_collection.cust_id;
    w_label := 'e089';
    select
        line1
       ,line2
       ,line3
       ,line4
       ,line5
       ,line6
       ,line7
       ,line8
    into
        w_phl_tmg_pay_advice.prop_addr_line1
       ,w_phl_tmg_pay_advice.prop_addr_line2
       ,w_phl_tmg_pay_advice.prop_addr_line3
       ,w_phl_tmg_pay_advice.prop_addr_line4
       ,w_phl_tmg_pay_advice.prop_addr_line5
       ,w_phl_tmg_pay_advice.prop_addr_line6
       ,w_phl_tmg_pay_advice.prop_addr_line7
       ,w_phl_tmg_pay_advice.prop_addr_line8
    from
       cis_installations inst,
       cis_addresses     addr
    where
        inst.prop_addr_id = addr.addr_id
    and inst.inst_id      = w_cis_debt_collection.inst_id;
   /* Start Del 5869 --Reduandant Select moved up when selecting acct_id
    select acct_bal_amnt
    into w_tot_bal_amnt
    from cis_accounts
    where inst_id   = w_cis_debt_collection.inst_id
    and cust_id     = w_cis_debt_collection.cust_id        --Add 2211 [2.0.0.48]
    and supply_type = w_cis_debt_collection.supply_type;   --Add 5869 3.0.0.35
    EndDel 5869 --Reduandant Select moved up when selecting acct_id
   */
  select desc1.debt_coll_path_desc                         --1.0.0.59
    into w_debt_coll_path_desc                             --1.0.0.59
  from cis_debt_collection coll, cis_debt_coll_path desc1  --1.0.0.59
  where debt_coll_id = p_debt_coll_id                      --1.0.0.59
  and desc1.debt_coll_path=coll.debt_coll_path;            --1.0.0.59
    w_phl_tmg_pay_advice.process_id               :=   null;
    w_phl_tmg_pay_advice.cust_id                  :=   w_cis_debt_collection.cust_id;
    w_phl_tmg_pay_advice.inst_id                  :=   w_cis_debt_collection.inst_id;
    w_phl_tmg_pay_advice.tran_id                  :=   null;
    w_phl_tmg_pay_advice.supply_type              :=   w_cis_debt_collection.supply_type;
    w_phl_tmg_pay_advice.debt_coll_id             :=   p_debt_coll_id;
    w_phl_tmg_pay_advice.print_date               :=   to_char(sysdate,'mm/dd/yyyy');
    w_phl_tmg_pay_advice.principal                :=   to_char(w_principal_amnt);
    w_phl_tmg_pay_advice.tot_bal_amnt             :=   to_char(w_tot_bal_amnt);
    w_phl_tmg_pay_advice.penalty                  :=   to_char(w_penalty_amnt);
    w_phl_tmg_pay_advice.lein                     :=   to_char(w_lien_amnt);
    w_phl_tmg_pay_advice.pay_adv_amnt             :=   to_char(w_cis_debt_collection.pay_advice_amnt);
    w_phl_tmg_pay_advice.pymt_date                :=   to_char(w_cis_debt_collection.debt_coll_stage_change_datime,'mm/dd/yyyy');
    w_phl_tmg_pay_advice.water1_account           :=   w_padv_city_acct;
    w_phl_tmg_pay_advice.water1_acct_wo_ctrl_day  :=   substr(w_padv_city_acct,4);
    w_phl_tmg_pay_advice.ctrl_day                 :=   w_padv_control_day;
    w_phl_tmg_pay_advice.scan_string              :=   null;
    w_phl_tmg_pay_advice.debt_bal_amnt            :=   to_char(w_cis_debt_collection.debt_bal_amnt,'999,999,990.00'); --1.0.0.59
    w_phl_tmg_pay_advice.debt_coll_key            :=   to_char(w_cis_debt_collection.debt_coll_key);                --1.0.0.59
    w_padv_debt_coll_key                          :=   lpad(w_cis_debt_collection.debt_coll_key,17,'0');                --1.0.0.59
    --debug_trace(w_procedure_name,w_label||' phls0001B - w_padv_debt_coll_key '|| w_padv_debt_coll_key);
    w_phl_tmg_pay_advice.debt_coll_path           :=   to_char(w_cis_debt_collection.debt_coll_path);               --1.0.0.59
    w_phl_tmg_pay_advice.debt_coll_path_desc      :=   w_debt_coll_path_desc;                                       --1.0.0.59
    w_phl_tmg_pay_advice.debt_creation_date       :=   to_char(w_cis_debt_collection.creation_date,'mm/dd/yyyy');   --1.0.0.59
 end get_pay_advice_details;
 /*************************************************************************************\
    private procedure scan_string_pay_advice
 \*************************************************************************************/
    procedure scan_string_pay_advice(p_debt_coll_id number)
    is
       w_procedure_name   varchar2(50) := 'phls0001.scan_string_pay_advice';
       w_check_digit      varchar2(1);
    begin
       trace_label('e090', w_procedure_name);
       if p_debt_coll_id is null then
       ciss0047.raise_exception(w_procedure_name, w_label, 'cis_internal_error',
                                'error', 'Null parameter supplied',
--                                   'e091', 'Debt Collection id can not be null for PAY ADVICE',    -- del 3.0.0.2
--                                   'PARM', 'RESTART ID',                                           -- del 3.0.0.2
                                    p_severity=>'f');
       end if;
       w_label := 'e092';
       get_pay_advice_details(p_debt_coll_id);
       w_label := 'e093';
       w_padv_scan_string :=                    -- Posns -- Count
             '333'                              -- 01-03 == 03         FIXED STRING
          || '72'                               -- 04-05 == 02         FIXED WATER BILL
          || w_padv_due_date                    -- 06-11 == 06         PAY ADVICE DATE --debt_coll_stage_change_datime
          || w_padv_debt_coll_key               -- 12-28 == 17         Debt Collection Key --1.0.0.11A
 --       || w_padv_acct_number                 -- 12-28 == 17         ACCOUNT NUMBER      --1.0.0.11A
          || w_padv_29thchar                    -- 29-29 == 01         FIXED STRING -- 7
          || w_padv_amnt_w_penalty              -- 30-39 == 10         AMOUNT WITH PENALTY
          || w_padv_amnt_wo_penalty             -- 40-49 == 10         AMOUNT WITH OUT PENALTY
          || w_padv_control_day                 -- 50-52 == 02         CONTROL DAY
          || w_padv_sewer_charges               -- 53-56 == 04         SEWER_CHARGES
          || w_padv_last_twelve;                -- 57-68 == 12         FIXED STRING
       w_check_digit := get_check_digit(w_padv_scan_string);
       w_label := 'e094';
       debug_trace(w_procedure_name,'...w_padv_due_date         = ' || w_padv_due_date);
 --    debug_trace(w_procedure_name,'...w_padv_acct_number      = ' || w_padv_acct_number);   --1.0.0.11A
       debug_trace(w_procedure_name,'...w_padv_debt_coll_key    = ' || w_padv_debt_coll_key); --1.0.0.11A
       debug_trace(w_procedure_name,'...w_padv_29thchar         = ' || w_padv_29thchar);
       debug_trace(w_procedure_name,'...w_padv_amnt_w_penalty   = ' || w_padv_amnt_w_penalty);
       debug_trace(w_procedure_name,'...w_padv_amnt_wo_penalty  = ' || w_padv_amnt_wo_penalty);
       debug_trace(w_procedure_name,'...w_padv_control_day      = ' || w_padv_control_day);
       debug_trace(w_procedure_name,'...w_padv_sewer_charges    = ' || w_padv_sewer_charges);
       debug_trace(w_procedure_name,'...w_padv_last_twelve      = ' || w_padv_last_twelve);
       --debug_trace(w_procedure_name,w_label||' phls0001B - w_padv_debt_coll_key '|| w_padv_debt_coll_key);
       w_padv_scan_string := substr(w_padv_scan_string,1,67) || to_char(w_check_digit);
       debug_trace(w_procedure_name,'...scan_string =' || w_padv_scan_string);
       --
       -- Report variable
       --
       w_phl_tmg_pay_advice.scan_string :=  w_padv_scan_string;
       w_label := 'e095';
       debug_trace(w_procedure_name,'...w_phl_tmg_pay_advice.scan_string =' || w_phl_tmg_pay_advice.scan_string);
    end scan_string_pay_advice;
 /*************************************************************************************\
    public procedure assemble_pay_advice
 \*************************************************************************************/
    procedure assemble_pay_advice(p_process_id   in   cis_process_restart.process_id%type default null,
                                  p_debt_coll_id in   number)
    is
       w_procedure_name  varchar2(40) := 'phls0001.assemble_pay_advice';
    begin
       w_label := 'e096';
       --debug(w_procedure_name, w_label, 'Message Level ' || w_message_trace_level);
       debug_trace(w_procedure_name,'.. Trace:   scan_string_down_payment ');
       scan_string_pay_advice(p_debt_coll_id);
       w_label := 'e097';
       debug_trace(w_procedure_name,'.. Trace:   inst_phl_pay_advice_bill ');
       inst_phl_tmg_pay_advice(p_process_id);
       w_label := 'e098';
       debug_trace(w_procedure_name,'.. Trace:   Over ');
    end assemble_pay_advice;
/* Start Add 10846 */
 /*************************************************************************************\
    private function get_agrv_null_prnt_string
 \*************************************************************************************/
    function get_agrv_null_prnt_string return varchar2
    is
       w_procedure_name  varchar2(50) := 'phls0001.get_agrv_null_prnt_string';
       l_aghl_null_strg       varchar2(4000);
    begin
            l_aghl_null_strg
            :=         null  --AR_ACCTKEY   AR_ACCTKEY --Agency receivables Basis2 Account Key
            || '|' ||  null  --AR_OPNBAL    AR_OPNBAL  --AR Repair Charge Opening Balance
            || '|' ||  null  --AR_ADJAMT    AR_ADJAMT  --AR Repair Charge Adjacement Amnt
            || '|' ||  null  --AR_UNPAMT    AR_UNPAMT  --AR UnPaid Amnt
            || '|' ||  null  --AR_5INVFPDS  AR_5INVFPDS--AR 5TH Invoice Description Front Page desc
            || '|' ||  null  --AR_5INVBPDS  AR_5INVBPDS--AR 5TH Invoice Description Back Page desc
            || '|' ||  null  --AR_5INVBAL   AR_5INVBAL --AR 5TH Invoice Bal
            || '|' ||  null  --AR_5FLG      AR_5FLG    --AR 5TH INVOICE FLAG
            || '|' ||  null  --AR_4INVFPDS  AR_4INVFPDS--AR 5TH Invoice Description Front Page desc
            || '|' ||  null  --AR_4INVBPDS  AR_4INVBPDS--AR 5TH Invoice Description Back Page desc
            || '|' ||  null  --AR_4INVBAL   AR_4INVBAL --AR 4TH Invoice Bal
            || '|' ||  null  --AR_4FLG      AR_4FLG    --AR 4TH INVOICE FLAG
            || '|' ||  null  --AR_3INVFPDS  AR_3INVFPDS--AR 5TH Invoice Description Front Page desc
            || '|' ||  null  --AR_3INVBPDS  AR_3INVBPDS--AR 5TH Invoice Description Back Page desc
            || '|' ||  null  --AR_3INVBAL   AR_3INVBAL --AR 3RD Invoice Bal
            || '|' ||  null  --AR_3FLG      AR_3FLG    --AR 3RD INVOICE FLAG
            || '|' ||  null  --AR_2INVFPDS  AR_2INVFPDS--AR 2ND Invoice Description Front Page desc
            || '|' ||  null  --AR_2INVBPDS  AR_2INVBPDS--AR 2ND Invoice Description Back Page desc
            || '|' ||  null  --AR_2INVBAL   AR_2INVBAL --AR 2ND Invoice Bal
            || '|' ||  null  --AR_2FLG      AR_2FLG    --AR 2ND INVOICE FLAG
            || '|' ||  null  --AR_1INVFPDS  AR_1INVFPDS--AR 2ND Invoice Description Front Page desc
            || '|' ||  null  --AR_1INVBPDS  AR_1INVBPDS--AR 2ND Invoice Description Back Page desc
            || '|' ||  null  --AR_1INVBAL   AR_1INVBAL --AR 1ST Invoice Bal
            || '|' ||  null  --AR_1FLAG     AR_1FLAG   --AR 1ST INVOICE FLAG
            || '|' ||  null  --AR_RMBLFP    AR_RMBLFP  --AR REMAINING BALANC (Only current)
            || '|' ||  null  --AR_RMBLBP    AR_RMBLBP  --AR TOTAL INVOICE BALANCE (current + Previous)
            || '|' ||  null  --AR_TOADBP    AR_TOADBP  --AR TOTAL ADJACEMENT
            || '|' ||  null  --AR_TOPYBP    AR_TOPYBP  --AR TOTAL PAYMENTS
            || '|' ||  null  --AR_CLSBAL    AR_CLSBAL  --AR Repaire Charge Closing Balance
            ;
            l_aghl_null_strg
            := trim(l_aghl_null_strg)
            || '|' ||  null  --HL_ACCTKEY   HL_ACCTKEY --HL Basis2 Account Key
            || '|' ||  null  --HL_OPNBAL    HL_OPNBAL  --HL Opening Balance
            || '|' ||  null  --HL_ADJAMT    HL_ADJAMT  --HL Adjacement Amnt
            || '|' ||  null  --HL_PYMAMT    HL_PYMAMT  --HL Adjacement Amnt
            || '|' ||  null  --HL_PYMDT     HL_PYMDT   --HL Payment Date
            || '|' ||  null  --HL_UNPAMT    HL_UNPAMT  --HL UnPaid Amnt
            || '|' ||  null  --HL_UNPLBL    HL_UNPLBL  --HL UnPaid Label
            || '|' ||  null  --HL_PLNDUE    HL_PLNDUE  --HL Plan Due
            || '|' ||  null  --HL_CORR_LBL  HL_CORR_LBL--HL Correction Label
            || '|' ||  null  --HL_CORR_PPLN_AMNT       --HL Corrected PPLN AMNT
            || '|' ||  null  --HL_INVBAL    HL_INVBAL  --HL Total Invoice Balance
            || '|' ||  null  --HL_PNLTY     HL_PNLTY   --HL Current penalty for this Bill
            || '|' ||  null  --HL_CLSBAL    HL_CLSBAL  --HL Closing Balance
            || '|' ||  null  --HL_TOTDUE    HL_TOTDUE  --HL Total Duefor Current Bill
            || '|' ||  null  --HL_AGSTDT    HL_AGSTDT  --HL Plan Agreement Start Date
            || '|' ||  null  --HL_AGRAMT    HL_AGRAMT  --HL PLAN TOTAL AMOUNT
            || '|' ||  null  --HL_OTHDBT    HL_OTHDBT  --HL Other debt do not use
            || '|' ||  null  --HL_5MIDT     HL_5MIDT   --HL 5 Monthly Installment Received Date
            || '|' ||  null  --HL_4MIDT     HL_4MIDT   --HL 4 Monthly Installment Received Date
            || '|' ||  null  --HL_3MIDT     HL_3MIDT   --HL 3 Monthly Installment Received Date
            || '|' ||  null  --HL_2MIDT     HL_2MIDT   --HL 2 Monthly Installment Received Date
            || '|' ||  null  --HL_1MIDT     HL_1MIDT   --HL 1 Monthly Installment Received Date
            || '|' ||  null  --HL_5MIAMT    HL_5MIAMT  --HL 5 Monthly Installment Amount Received
            || '|' ||  null  --HL_4MIAMT    HL_4MIAMT  --HL 4 Monthly Installment Amount Received
            || '|' ||  null  --HL_3MIAMT    HL_3MIAMT  --HL 3 Monthly Installment Amount Received
            || '|' ||  null  --HL_2MIAMT    HL_2MIAMT  --HL 2 Monthly Installment Amount Received
            || '|' ||  null  --HL_1MIAMT    HL_1MIAMT  --HL 1 Monthly Installment Amount Received
            || '|' ||  null  --HL_REMAMT    HL_REMAMT  --HL Remaining Monthly Installment Amount  Received
            || '|' ||  null  --HL_PPLN_BAL_AMT         --HL PLAN Balance Amount
            || '|' ||  null  --HL_MSGHD1    HL_MSGHD1  --HL Message Header 1
            || '|' ||  null  --HL_MSGHD2    HL_MSGHD2  --HL Message Header 2
            || '|' ||  null  --HL_MSGHD3    HL_MSGHD3  --HL Message Header 3
            || '|' ||  null  --HL_MSGHD4    HL_MSGHD4  --HL Message Detail 4
            || '|' ||  null  --HL_MSGDT1    HL_MSGDT1  --HL Message Detail 1
            || '|' ||  null  --HL_MSGDT2    HL_MSGDT2  --HL Message Detail 2
            || '|' ||  null  --HL_MSGDT3    HL_MSGDT3  --HL Message Detail 3
            || '|' ||  null  --HL_MSGDT4    HL_MSGDT4  --HL Message Detail 4
            || '|' ||  null  --HL_SCANLN    HL_SCANLN  --HL Scan Line
            ;
						return l_aghl_null_strg;
    end get_agrv_null_prnt_string;
/* End Add 10846 */
 /* Start Add 4398 */
 /*************************************************************************************\
    procedure agrv_bkgrnd_prnt_string
 \*************************************************************************************/
    procedure get_agrv_bkgrnd_prnt_string
    is
       w_procedure_name  varchar2(50) := 'phls0001.agrv_bkgrnd_prnt_string';
       --Start Mod 5905 3.0.0.39
       w_rc_strg       varchar2(4000);
    begin
         --if nvl(w_ar_acct_bal,0) < nvl(w_rchl.agrv_rc_debt_to_exclude,0) then    --Mod 5905 3.0.0.39
         if donot_print_rc then
            w_rc_strg
            :=         null  --AR_ACCTKEY   AR_ACCTKEY --Agency receivables Basis2 Account Key
            || '|' ||  null  --AR_OPNBAL    AR_OPNBAL  --AR Repair Charge Opening Balance
            || '|' ||  null  --AR_ADJAMT    AR_ADJAMT  --AR Repair Charge Adjacement Amnt
            || '|' ||  null  --AR_UNPAMT    AR_UNPAMT  --AR UnPaid Amnt
            || '|' ||  null  --AR_5INVFPDS  AR_5INVFPDS--AR 5TH Invoice Description Front Page desc
            || '|' ||  null  --AR_5INVBPDS  AR_5INVBPDS--AR 5TH Invoice Description Back Page desc
            || '|' ||  null  --AR_5INVBAL   AR_5INVBAL --AR 5TH Invoice Bal
            || '|' ||  null  --AR_5FLG      AR_5FLG    --AR 5TH INVOICE FLAG
            || '|' ||  null  --AR_4INVFPDS  AR_4INVFPDS--AR 5TH Invoice Description Front Page desc
            || '|' ||  null  --AR_4INVBPDS  AR_4INVBPDS--AR 5TH Invoice Description Back Page desc
            || '|' ||  null  --AR_4INVBAL   AR_4INVBAL --AR 4TH Invoice Bal
            || '|' ||  null  --AR_4FLG      AR_4FLG    --AR 4TH INVOICE FLAG
            || '|' ||  null  --AR_3INVFPDS  AR_3INVFPDS--AR 5TH Invoice Description Front Page desc
            || '|' ||  null  --AR_3INVBPDS  AR_3INVBPDS--AR 5TH Invoice Description Back Page desc
            || '|' ||  null  --AR_3INVBAL   AR_3INVBAL --AR 3RD Invoice Bal
            || '|' ||  null  --AR_3FLG      AR_3FLG    --AR 3RD INVOICE FLAG
            || '|' ||  null  --AR_2INVFPDS  AR_2INVFPDS--AR 2ND Invoice Description Front Page desc
            || '|' ||  null  --AR_2INVBPDS  AR_2INVBPDS--AR 2ND Invoice Description Back Page desc
            || '|' ||  null  --AR_2INVBAL   AR_2INVBAL --AR 2ND Invoice Bal
            || '|' ||  null  --AR_2FLG      AR_2FLG    --AR 2ND INVOICE FLAG
            || '|' ||  null  --AR_1INVFPDS  AR_1INVFPDS--AR 2ND Invoice Description Front Page desc
            || '|' ||  null  --AR_1INVBPDS  AR_1INVBPDS--AR 2ND Invoice Description Back Page desc
            || '|' ||  null  --AR_1INVBAL   AR_1INVBAL --AR 1ST Invoice Bal
            || '|' ||  null  --AR_1FLAG     AR_1FLAG   --AR 1ST INVOICE FLAG
            || '|' ||  null  --AR_RMBLFP    AR_RMBLFP  --AR REMAINING BALANC (Only current)
            || '|' ||  null  --AR_RMBLBP    AR_RMBLBP  --AR TOTAL INVOICE BALANCE (current + Previous)
            || '|' ||  null  --AR_TOADBP    AR_TOADBP  --AR TOTAL ADJACEMENT
            || '|' ||  null  --AR_TOPYBP    AR_TOPYBP  --AR TOTAL PAYMENTS
            || '|' ||  null  --AR_CLSBAL    AR_CLSBAL  --AR Repaire Charge Closing Balance
            ;
         else
            w_rc_strg
            := trim(w_rchl.agrv_rc_acct_key)                                                           --AR_ACCTKEY   AR_ACCTKEY --Agency receivables Basis2 Account Key
            || '|' ||  trim(to_char(w_rchl.agrv_rc_st_opening_bal_amnt,'$99,999,990.00'))          --AR_OPNBAL    AR_OPNBAL  --AR Repair Charge Opening Balance
            || '|' ||  trim(to_char(w_rchl.agrv_rc_cur_adj_amnt,'$99,999,990.00'))                 --AR_ADJAMT    AR_ADJAMT  --AR Repair Charge Adjacement Amnt
            || '|' ||  trim(to_char(w_rchl.agrv_rc_unpaid_amnt,'$99,999,990.00'))                  --AR_UNPAMT    AR_UNPAMT  --AR UnPaid Amnt
            || '|' ||  trim(w_rchl.agrv_rc_5th_fpg_inv_desc)                                       --AR_5INVFPDS  AR_5INVFPDS--AR 5TH Invoice Description Front Page desc
            || '|' ||  trim(w_rchl.agrv_rc_5th_inv_desc)                                           --AR_5INVBPDS  AR_5INVBPDS--AR 5TH Invoice Description Back Page desc
            || '|' ||  trim(to_char(w_rchl.agrv_rc_5th_inv_bal,'$99,999,990.00'))                  --AR_5INVBAL   AR_5INVBAL --AR 5TH Invoice Bal
            || '|' ||  trim(w_rchl.agrv_rc_5th_cur_prv_flag)                                       --AR_5FLG      AR_5FLG    --AR 5TH INVOICE FLAG
            || '|' ||  trim(w_rchl.agrv_rc_4th_fpg_inv_desc)                                       --AR_4INVFPDS  AR_4INVFPDS--AR 5TH Invoice Description Front Page desc
            || '|' ||  trim(w_rchl.agrv_rc_4th_inv_desc)                                           --AR_4INVBPDS  AR_4INVBPDS--AR 5TH Invoice Description Back Page desc
            || '|' ||  trim(to_char(w_rchl.agrv_rc_4th_inv_bal,'$99,999,990.00'))                  --AR_4INVBAL   AR_4INVBAL --AR 4TH Invoice Bal
            || '|' ||  trim(w_rchl.agrv_rc_4th_cur_prv_flag)                                       --AR_4FLG      AR_4FLG    --AR 4TH INVOICE FLAG
            || '|' ||  trim(w_rchl.agrv_rc_3rd_fpg_inv_desc)                                       --AR_3INVFPDS  AR_3INVFPDS--AR 5TH Invoice Description Front Page desc
            || '|' ||  trim(w_rchl.agrv_rc_3rd_inv_desc)                                           --AR_3INVBPDS  AR_3INVBPDS--AR 5TH Invoice Description Back Page desc
            || '|' ||  trim(to_char(w_rchl.agrv_rc_3rd_inv_bal,'$99,999,990.00'))                  --AR_3INVBAL   AR_3INVBAL --AR 3RD Invoice Bal
            || '|' ||  trim(w_rchl.agrv_rc_3rd_cur_prv_flag)                                       --AR_3FLG      AR_3FLG    --AR 3RD INVOICE FLAG
            || '|' ||  trim(w_rchl.agrv_rc_2nd_fpg_inv_desc)                                       --AR_2INVFPDS  AR_2INVFPDS--AR 2ND Invoice Description Front Page desc
            || '|' ||  trim(w_rchl.agrv_rc_2nd_inv_desc)                                           --AR_2INVBPDS  AR_2INVBPDS--AR 2ND Invoice Description Back Page desc
            || '|' ||  trim(to_char(w_rchl.agrv_rc_2nd_inv_bal,'$99,999,990.00'))                  --AR_2INVBAL   AR_2INVBAL --AR 2ND Invoice Bal
            || '|' ||  trim(w_rchl.agrv_rc_2nd_cur_prv_flag)                                       --AR_2FLG      AR_2FLG    --AR 2ND INVOICE FLAG
            || '|' ||  trim(w_rchl.agrv_rc_1st_fpg_inv_desc)                                       --AR_1INVFPDS  AR_1INVFPDS--AR 2ND Invoice Description Front Page desc
            || '|' ||  trim(w_rchl.agrv_rc_1st_inv_desc)                                           --AR_1INVBPDS  AR_1INVBPDS--AR 2ND Invoice Description Back Page desc
            || '|' ||  trim(to_char(w_rchl.agrv_rc_1st_inv_bal,'$99,999,990.00'))                  --AR_1INVBAL   AR_1INVBAL --AR 1ST Invoice Bal
            || '|' ||  trim(w_rchl.agrv_rc_1st_cur_prv_flag)                                       --AR_1FLAG     AR_1FLAG   --AR 1ST INVOICE FLAG
            || '|' ||  trim(to_char(w_rchl.agrv_rc_cur_rem_inv_bal,'$99,999,990.00'))              --AR_RMBLFP    AR_RMBLFP  --AR REMAINING BALANC (Only current)
            || '|' ||  trim(to_char(w_rchl.agrv_rc_tot_rem_inv_bal,'$99,999,990.00'))              --AR_RMBLBP    AR_RMBLBP  --AR TOTAL INVOICE BALANCE (current + Previous)
            || '|' ||  trim(to_char(w_rchl.agrv_rc_tot_adj_amnt,'$99,999,990.00'))                 --AR_TOADBP    AR_TOADBP  --AR TOTAL ADJACEMENT
            || '|' ||  trim(to_char(w_rchl.agrv_rc_tot_pymnt_amnt,'$99,999,990.00'))               --AR_TOPYBP    AR_TOPYBP  --AR TOTAL PAYMENTS
            || '|' ||  trim(to_char(w_rchl.agrv_rc_st_closing_bal_amnt,'$99,999,990.00'))          --AR_CLSBAL    AR_CLSBAL  --AR Repaire Charge Closing Balance
            ;
         end if;
         --if nvl(w_hl_acct_bal,0) < nvl(w_rchl.agrv_hl_debt_to_exclude,0) then
         if donot_print_hl then
            w_rchl.agrv_bkgrnd_prnt_string
            := trim(w_rc_strg)
            || '|' ||  null  --HL_ACCTKEY   HL_ACCTKEY --HL Basis2 Account Key
            || '|' ||  null  --HL_OPNBAL    HL_OPNBAL  --HL Opening Balance
            || '|' ||  null  --HL_ADJAMT    HL_ADJAMT  --HL Adjacement Amnt
            || '|' ||  null  --HL_PYMAMT    HL_PYMAMT  --HL Adjacement Amnt
            || '|' ||  null  --HL_PYMDT     HL_PYMDT   --HL Payment Date
            || '|' ||  null  --HL_UNPAMT    HL_UNPAMT  --HL UnPaid Amnt
            || '|' ||  null  --HL_UNPLBL    HL_UNPLBL  --HL UnPaid Label
            || '|' ||  null  --HL_PLNDUE    HL_PLNDUE  --HL Plan Due
            || '|' ||  null  --HL_CORR_LBL  HL_CORR_LBL--HL Correction Label
            || '|' ||  null  --HL_CORR_PPLN_AMNT       --HL Corrected PPLN AMNT
            || '|' ||  null  --HL_INVBAL    HL_INVBAL  --HL Total Invoice Balance
            || '|' ||  null  --HL_PNLTY     HL_PNLTY   --HL Current penalty for this Bill
            || '|' ||  null  --HL_CLSBAL    HL_CLSBAL  --HL Closing Balance
            || '|' ||  null  --HL_TOTDUE    HL_TOTDUE  --HL Total Duefor Current Bill
            || '|' ||  null  --HL_AGSTDT    HL_AGSTDT  --HL Plan Agreement Start Date
            || '|' ||  null  --HL_AGRAMT    HL_AGRAMT  --HL PLAN TOTAL AMOUNT
            || '|' ||  null  --HL_OTHDBT    HL_OTHDBT  --HL Other debt do not use
            || '|' ||  null  --HL_5MIDT     HL_5MIDT   --HL 5 Monthly Installment Received Date
            || '|' ||  null  --HL_4MIDT     HL_4MIDT   --HL 4 Monthly Installment Received Date
            || '|' ||  null  --HL_3MIDT     HL_3MIDT   --HL 3 Monthly Installment Received Date
            || '|' ||  null  --HL_2MIDT     HL_2MIDT   --HL 2 Monthly Installment Received Date
            || '|' ||  null  --HL_1MIDT     HL_1MIDT   --HL 1 Monthly Installment Received Date
            || '|' ||  null  --HL_5MIAMT    HL_5MIAMT  --HL 5 Monthly Installment Amount Received
            || '|' ||  null  --HL_4MIAMT    HL_4MIAMT  --HL 4 Monthly Installment Amount Received
            || '|' ||  null  --HL_3MIAMT    HL_3MIAMT  --HL 3 Monthly Installment Amount Received
            || '|' ||  null  --HL_2MIAMT    HL_2MIAMT  --HL 2 Monthly Installment Amount Received
            || '|' ||  null  --HL_1MIAMT    HL_1MIAMT  --HL 1 Monthly Installment Amount Received
            || '|' ||  null  --HL_REMAMT    HL_REMAMT  --HL Remaining Monthly Installment Amount  Received
            || '|' ||  null  --HL_PPLN_BAL_AMT         --HL PLAN Balance Amount
            || '|' ||  null  --HL_MSGHD1    HL_MSGHD1  --HL Message Header 1
            || '|' ||  null  --HL_MSGHD2    HL_MSGHD2  --HL Message Header 2
            || '|' ||  null  --HL_MSGHD3    HL_MSGHD3  --HL Message Header 3
            || '|' ||  null  --HL_MSGHD4    HL_MSGHD4  --HL Message Detail 4
            || '|' ||  null  --HL_MSGDT1    HL_MSGDT1  --HL Message Detail 1
            || '|' ||  null  --HL_MSGDT2    HL_MSGDT2  --HL Message Detail 2
            || '|' ||  null  --HL_MSGDT3    HL_MSGDT3  --HL Message Detail 3
            || '|' ||  null  --HL_MSGDT4    HL_MSGDT4  --HL Message Detail 4
            || '|' ||  null  --HL_SCANLN    HL_SCANLN  --HL Scan Line
            ;
         else
            w_rchl.agrv_bkgrnd_prnt_string
            := trim(w_rc_strg)
            || '|' ||  trim(w_rchl.agrv_hl_acct_key)                                               --HL_ACCTKEY   HL_ACCTKEY --HL Basis2 Account Key
            || '|' ||  trim(to_char(w_rchl.agrv_hl_st_opening_bal_amnt,'$99,999,990.00'))          --HL_OPNBAL    HL_OPNBAL  --HL Opening Balance
            || '|' ||  trim(to_char(w_rchl.agrv_hl_cur_adj_amnt,'$99,999,990.00'))                 --HL_ADJAMT    HL_ADJAMT  --HL Adjacement Amnt
            || '|' ||  trim(to_char(w_rchl.agrv_hl_cur_pymnt_amnt,'$99,999,990.00'))               --HL_PYMAMT    HL_PYMAMT  --HL Adjacement Amnt
            || '|' ||  trim(datec(w_rchl.agrv_hl_last_pymnt_dt))                                   --HL_PYMDT     HL_PYMDT   --HL Payment Date
            || '|' ||  trim(to_char(w_rchl.agrv_hl_unpaid_amnt,'$99,999,990.00'))                  --HL_UNPAMT    HL_UNPAMT  --HL UnPaid Amnt
            || '|' ||  trim(w_rchl.agrv_hl_unpaid_lbl)                                             --HL_UNPLBL    HL_UNPLBL  --HL UnPaid Label
            || '|' ||  trim(to_char(w_rchl.agrv_hl_ppln_due_amnt,'$99,999,990.00'))                --HL_PLNDUE    HL_PLNDUE  --HL Plan Due
            || '|' ||  trim(w_rchl.agrv_hl_corr_lbl)                                               --HL_CORR_LBL  HL_CORR_LBL--HL Correction Label
            || '|' ||  trim(to_char(w_rchl.agrv_hl_corr_ppln_amnt,'$99,999,990.00'))               --HL_CORR_PPLN_AMNT       --HL Corrected PPLN AMNT
            || '|' ||  trim(to_char(w_rchl.agrv_hl_tot_wo_pnlty,'$99,999,990.00'))                 --HL_INVBAL    HL_INVBAL  --HL Total Invoice Balance
            || '|' ||  trim(to_char(w_rchl.agrv_hl_cur_pnlty_amnt,'$99,999,990.00'))               --HL_PNLTY     HL_PNLTY   --HL Current penalty for this Bill
            || '|' ||  trim(to_char(w_rchl.agrv_hl_st_closing_bal_amnt,'$99,999,990.00'))          --HL_CLSBAL    HL_CLSBAL  --HL Closing Balance
            || '|' ||  trim(to_char(w_rchl.agrv_hl_total_due_amnt,'$99,999,990.00'))               --HL_TOTDUE    HL_TOTDUE  --HL Total Duefor Current Bill
            || '|' ||  trim(datefullc(w_rchl.agrv_hl_ppln_start_dt))                               --HL_AGSTDT    HL_AGSTDT  --HL Plan Agreement Start Date
            || '|' ||  trim(to_char(w_rchl.agrv_hl_ppln_tot_amnt,'$99,999,990.00'))                --HL_AGRAMT    HL_AGRAMT  --HL PLAN TOTAL AMOUNT
            || '|' ||  trim(to_char(w_rchl.agrv_hl_oth_debts ,'$99,999,990.00'))                   --HL_OTHDBT    HL_OTHDBT  --HL Other debt do not use
            || '|' ||  trim(datefullc(w_rchl.agrv_hl_5th_mi_rcvd_dt))                              --HL_5MIDT     HL_5MIDT   --HL 5 Monthly Installment Received Date
            || '|' ||  trim(datefullc(w_rchl.agrv_hl_4th_mi_rcvd_dt))                              --HL_4MIDT     HL_4MIDT   --HL 4 Monthly Installment Received Date
            || '|' ||  trim(datefullc(w_rchl.agrv_hl_3rd_mi_rcvd_dt))                              --HL_3MIDT     HL_3MIDT   --HL 3 Monthly Installment Received Date
            || '|' ||  trim(datefullc(w_rchl.agrv_hl_2nd_mi_rcvd_dt))                              --HL_2MIDT     HL_2MIDT   --HL 2 Monthly Installment Received Date
            || '|' ||  trim(datefullc(w_rchl.agrv_hl_1st_mi_rcvd_dt))                              --HL_1MIDT     HL_1MIDT   --HL 1 Monthly Installment Received Date
            || '|' ||  trim(to_char(w_rchl.agrv_hl_5th_mi_amnt_rcvd,'$99,999,990.00'))             --HL_5MIAMT    HL_5MIAMT  --HL 5 Monthly Installment Amount Received
            || '|' ||  trim(to_char(w_rchl.agrv_hl_4th_mi_amnt_rcvd,'$99,999,990.00'))             --HL_4MIAMT    HL_4MIAMT  --HL 4 Monthly Installment Amount Received
            || '|' ||  trim(to_char(w_rchl.agrv_hl_3rd_mi_amnt_rcvd,'$99,999,990.00'))             --HL_3MIAMT    HL_3MIAMT  --HL 3 Monthly Installment Amount Received
            || '|' ||  trim(to_char(w_rchl.agrv_hl_2nd_mi_amnt_rcvd,'$99,999,990.00'))             --HL_2MIAMT    HL_2MIAMT  --HL 2 Monthly Installment Amount Received
            || '|' ||  trim(to_char(w_rchl.agrv_hl_1st_mi_amnt_rcvd,'$99,999,990.00'))             --HL_1MIAMT    HL_1MIAMT  --HL 1 Monthly Installment Amount Received
            || '|' ||  trim(to_char(w_rchl.agrv_hl_rem_mi_amnt_rcvd,'$99,999,990.00'))             --HL_REMAMT    HL_REMAMT  --HL Remaining Monthly Installment Amount  Received
            || '|' ||  trim(to_char(w_rchl.agrv_hl_ppln_bal_amnt,'$99,999,990.00'))                --HL_PPLN_BAL_AMT         --HL PLAN Balance Amount
            || '|' ||  trim(w_rchl.agrv_hl_mssg1_hdr)                                              --HL_MSGHD1    HL_MSGHD1  --HL Message Header 1
            || '|' ||  trim(w_rchl.agrv_hl_mssg2_hdr)                                              --HL_MSGHD2    HL_MSGHD2  --HL Message Header 2
            || '|' ||  trim(w_rchl.agrv_hl_mssg3_hdr)                                              --HL_MSGHD3    HL_MSGHD3  --HL Message Header 3
            || '|' ||  trim(w_rchl.agrv_hl_mssg4_hdr)                                              --HL_MSGHD4    HL_MSGHD4  --HL Message Detail 4
            || '|' ||  trim(w_rchl.agrv_hl_mssg1_dtl)                                              --HL_MSGDT1    HL_MSGDT1  --HL Message Detail 1
            || '|' ||  trim(w_rchl.agrv_hl_mssg2_dtl)                                              --HL_MSGDT2    HL_MSGDT2  --HL Message Detail 2
            || '|' ||  trim(w_rchl.agrv_hl_mssg3_dtl)                                              --HL_MSGDT3    HL_MSGDT3  --HL Message Detail 3
            || '|' ||  trim(w_rchl.agrv_hl_mssg4_dtl)                                              --HL_MSGDT4    HL_MSGDT4  --HL Message Detail 4
            || '|' ||  trim(w_rchl.agrv_hl_scan_line)                                              --HL_SCANLN    HL_SCANLN  --HL Scan Line
            ;
         end if;
         --End Mod 5905 3.0.0.39
    end get_agrv_bkgrnd_prnt_string;
 /* End Add 4398 */
 /*************************************************************************************\
    private procedure background_print_string
 \*************************************************************************************/
 procedure background_print_string is
    w_procedure_name              varchar2(40) := 'phls0001.background_print_string';
    --w_penalty_amnt_str            varchar2(15);
/*
  w_usage_charge_amnt    varchar2(15);--USG_CHARGE_AMNT
  w_service_charge_amnt   varchar2(15);--SVC_CHARGE_AMNT
  w_discount_amnt     varchar2(15);--DISCOUNT_AMNT
  w_penalty_due_amnt    varchar2(15);--PENALTY_DUE_AMNT
    w_adjust                 varchar2(15);--ADJUST
    w_lien                        varchar2(15);--LIEN
    w_stormchg                    varchar2(15);--STORMCHG
    w_induschg                    varchar2(15);--INDUSCHG
    w_pymtagree                   varchar2(15);--PYMTAGREE
  w_wrbcccred       varchar2(15);--WRBCCCRED
  w_wrbccpmt          varchar2(15);--WRBCCPMT
  w_late_pmt_penalty     varchar2(15);--LATE_PMT_PENALTY
*/
 begin
    trace_label('e099', w_procedure_name);
    --if w_ptbm.penalty_amnt <> 0 then               --del 2.0.0.10
    --   w_penalty_amnt_str := trim(to_char(w_ptbm.penalty_amnt,'99999990.00'));  --del 2.0.0.10 Add--1.0.0.16
    --else                        --del 2.0.0.10
    --   w_penalty_amnt_str := null;                --del 2.0.0.10
    --end if;                       --del 2.0.0.10
  --Add Start 3706
  w_ptbm.tot_bill_rdg := nvl(w_ptbm.billed_qty,0) + nvl(w_ptbm.repl_billed_qty,0) + nvl(w_add_to_tot_qty,0); --w_add_to_tot_qty if there are two meter rotates.
  --Add End 3706
  --USG_CHARGE_AMNT
  --SVC_CHARGE_AMNT
  --if nvl(w_ptbm.usage_charge_amnt,0)   = 0 then w_ptbm.usage_charge_amnt   := null;  end if; --Del 3435
  --w_ptbm.usage_charge_amnt := nvl(w_ptbm.usage_charge_amnt,0);              --Del 3706       --Add 3435
   --Start Add 3706
   if w_ptbm.meter_key is not null then
      w_ptbm.usage_charge_amnt   := nvl(w_ptbm.usage_charge_amnt,0);
      w_ptbm.service_charge_amnt := nvl(w_ptbm.service_charge_amnt,0);
   else
      if nvl(w_ptbm.usage_charge_amnt,0)   = 0 then w_ptbm.usage_charge_amnt   := null; end if; --Add 3706
      if nvl(w_ptbm.service_charge_amnt,0) = 0 then w_ptbm.service_charge_amnt := null; end if; --Add 3706
   end if;
   --End Add 3706
  --DISCOUNT_AMNT
   --Start Add 3910
  debug_trace(w_procedure_name,' **Before Change w_ptbm.cust_type_code --> ' || w_ptbm.cust_type_code );
  debug_trace(w_procedure_name,' **Before Change w_ptbm.discount_lbl   --> ' || w_ptbm.discount_lbl   );
   if w_res_comm_ind = 'R' and w_ptbm.cust_type_code not in ('A','Y','C','E','N') then --Chg from w_blln.cust_type_code Fire Service should not get Senior Citizen Discount for $0.00
       trace_label('e100', w_procedure_name);
      debug_trace(w_procedure_name,' **You are In Change w_ptbm.discount_lbl   --> ' || w_ptbm.discount_lbl );
      debug_trace(w_procedure_name,' **You are In Change w_ptbm.discount_amnt  --> ' || w_ptbm.discount_amnt);
      w_ptbm.discount_lbl  := 'Senior Citizen Discount';
      if w_ptbm.discount_amnt is null then
         w_ptbm.discount_amnt := 0;
      end if;
   else  --End Add 3910
     if nvl(w_ptbm.discount_amnt,0) = 0 then
          trace_label('e101', w_procedure_name);
         w_ptbm.discount_amnt := null;
         w_ptbm.discount_lbl  := null;
     end if;
   end if; --Add 3910
   debug_trace(w_procedure_name,' **You are In Change w_ptbm.discount_lbl   --> ' || w_ptbm.discount_lbl );
   debug_trace(w_procedure_name,' **You are In Change w_ptbm.discount_amnt  --> ' || w_ptbm.discount_amnt);
  --LAST_PAID_AMNT
  --if nvl(w_ptbm.last_paid_amnt,0)    = 0 then w_ptbm.last_paid_amnt    := null;  end if; --Del 3706
  --PENALTY_DUE_AMNT
  --if nvl(w_ptbm.penalty_due_amnt,0)   = 0 then w_ptbm.penalty_due_amnt   := null;  end if; --Del 2.0.0.1
  --ADJUST
  if nvl(w_ptbm.adjust,0)              = 0 then w_ptbm.adjust     := null;  end if;
  --LIEN
  if nvl(w_ptbm.lien,0)                = 0 then w_ptbm.lien       := null;  end if;
  --Start Add 3327
  debug_trace(w_procedure_name,' w_pay_profile_code --> ' || w_pay_profile_code);
  w_char_stormchg       := null;
  /* --Start del 3861
  if w_pay_profile_code = 'COM-STD'
      or w_pay_profile_code = 'COM-STM'
      or w_pay_profile_code = 'COM-GRP'
      or w_pay_profile_code = 'COM-HOLD'
      or w_pay_profile_code = 'SURCHRGE'
      then
         w_char_stormchg := '* ' || trim(to_char(w_ptbm.stormchg,'$99,999,990.00'));
  else
         w_char_stormchg := trim(to_char(w_ptbm.stormchg,'$99,999,990.00'));
      end if;
  */ --End del 3861
  w_char_stormchg := trim(to_char(w_ptbm.stormchg,'$99,999,990.00')); --Add 3861
  if nvl(w_ptbm.stormchg,0) = 0 then w_ptbm.stormchg := null; end if;
  --End Add 3327
  --INDUSCHG
  if nvl(w_ptbm.induschg,0)      = 0 then w_ptbm.induschg      := null;  end if;
  --PYMTAGREE
  --if nvl(w_ptbm.pymtagree,0)     = 0 then w_ptbm.pymtagree     := null;  end if;
  --WRBCCCRED
  if nvl(w_ptbm.wrbcccred,0)     = 0 then w_ptbm.wrbcccred     := null;  end if;
  --WRBCCPMT
  --if nvl(w_ptbm.wrbccpmt,0)      = 0 then w_ptbm.wrbccpmt     := null;  end if;
  --LATE_PMT_PENALTY
  if nvl(w_ptbm.late_pmt_penalty,0)    = 0 then w_ptbm.late_pmt_penalty  := null;  end if;
  --TOT_CRED                             --Add 2402
  if nvl(w_ptbm.tot_cred,0)     = 0 then w_ptbm.tot_cred     := null;  end if;  --Add 2402
  --Start Add 3706
  if w_ptbm.reading_from_date is not null or w_ptbm.repl_reading_from_date is not null then
     w_ptbm.srvc_period := to_char(least(w_ptbm.reading_from_date,nvl(w_ptbm.repl_reading_from_date,to_date('12/31/9999','MM/DD/YYYY'))),'Mon DD, YYYY');
  end if;
  if w_ptbm.reading_upto_date is not null or w_ptbm.repl_reading_upto_date is not null then
     w_ptbm.srvc_period := trim(trim(w_ptbm.srvc_period) || ' - ' || trim(to_char(greatest(w_ptbm.reading_upto_date,nvl(w_ptbm.repl_reading_upto_date,to_date('01/01/1000','MM/DD/YYYY'))),'Mon DD, YYYY')));
  end if;
  --Del 4561 -- Moved to set_one_bill
  --w_ptbm.un_paid_prv_bal :=   nvl(w_ptbm.previous_balance_amnt,0)
  --                          + nvl(w_ptbm.last_paid_amnt,0)
  --                          + nvl(w_ptbm.adjust,0);        --Add 3706
  if w_ptbm.reading_upto_date is not null and  w_ptbm.reading_from_date is not null then
     if (w_ptbm.reading_upto_date - w_ptbm.reading_from_date) != 0 then
      w_ptbm.gal_used_per_day :=  trunc((nvl(w_ptbm.billed_qty,0) / (w_ptbm.reading_upto_date - w_ptbm.reading_from_date)) * w_us_gallons);
      if w_ptbm.gal_used_per_day < 0 then w_ptbm.gal_used_per_day := 0; end if;
     end if;
  end if;
  if w_ptbm.repl_reading_upto_date is not null and  w_ptbm.repl_reading_from_date is not null then
     if (w_ptbm.repl_reading_upto_date - w_ptbm.repl_reading_from_date) != 0 then
      w_ptbm.repl_gal_used_per_day :=  trunc((nvl(w_ptbm.repl_billed_qty,0) / (w_ptbm.repl_reading_upto_date - w_ptbm.repl_reading_from_date)) * w_us_gallons);
      if w_ptbm.repl_gal_used_per_day < 0 then w_ptbm.repl_gal_used_per_day := 0; end if;
     end if;
  end if;
  if  w_ptbm.bank_return_item is null then
    w_bad_check_fee := null;
  else
    w_bad_check_fee := trim(to_char(w_ptbm.bank_return_item,'$99,999,990.00'));
  end if;
  debug_trace(w_procedure_name,'{2.1} w_ptbm.debt_bal_amnt_cty   ' ||w_ptbm.debt_bal_amnt_cty);
  debug_trace(w_procedure_name,'{2.2} w_ptbm.debt_bal_amnt_ues   ' ||w_ptbm.debt_bal_amnt_ues);
  debug_trace(w_procedure_name,'{2.3} w_ptbm.debt_bal_amnt_tnf   ' ||w_ptbm.debt_bal_amnt_tnf);
  if w_ptbm.debt_bal_amnt_cty = 0   then w_ptbm.debt_bal_amnt_cty := null; end if;
  if w_ptbm.debt_bal_amnt_cri = 0   then w_ptbm.debt_bal_amnt_cri := null; end if;
  if w_ptbm.debt_bal_amnt_lih = 0   then w_ptbm.debt_bal_amnt_lih := null; end if;
  if w_ptbm.debt_bal_amnt_ues = 0   then w_ptbm.debt_bal_amnt_ues := null; end if;
  if w_ptbm.debt_bal_amnt_tnf = 0   then w_ptbm.debt_bal_amnt_tnf := null; end if;
  if w_ptbm.last_paid_amnt is null  then w_ptbm.last_paid_amnt    := 0;    end if;
  if w_ptbm.agr_othr_pymnts_amnt = 0 then w_ptbm.agr_othr_pymnts_amnt := null; end if; --Add 3706
  --w_ptbm.previous_balance_amnt    --> w_line_items := 01;             Previous Balance Amount
  --w_ptbm.last_paid_amnt           --> w_line_items := 02;             Last Paid Amount
  --w_ptbm.un_paid_prv_bal          --> w_line_items := 03;             UnPaid Previous Balance
  --w_ptbm.usage_charge_amnt        --> w_line_items := 04;             Usage Charge --> If not there it will be Zero
  --w_ptbm.fire_srvc_chg_amnt       --> w_line_items := 05; ?????       Fire Service Charge  --> It was part of current Service Charge in Previous Bill
  --w_ptbm.induschg                 --> w_line_items := 06; ?????       Industrial Surcharge --> It was part of current Service Charge in Previous Bill
  --w_ptbm.service_charge_amnt      --> w_line_items := 07;             Service Charges
  --w_char_stormchg                 --> w_line_items := 08;             Storm Water Charges
  --subtot_curr_chgs                --> w_line_items := 09;             Current Service + Usage Charge + StormWater Charges
  --w_ptbm.discount_amnt            --> w_line_items := 10;             Discount Amount
  --w_ptbm.late_pmt_penalty         --> w_line_items := 11;             Late Payment Penalty
  --w_ptbm.lien                     --> w_line_items := 12;             Lien Fees
  --w_bad_check_fee                 --> w_line_items := 13;             Bad Check Fee
  --w_ptbm.tot_pays_adjs            --> w_line_items := 14;             Total Payment Adjustments
  --w_ptbm.pymtagree                --> w_line_items := 15;             Total Agreemnet Installment Due for this month
  --w_ptbm.wrbccpmt                 --> w_line_items := 15;             Total WRBCC Installment Due for this month
  --w_ptbm.nus_chrg                 --> w_line_items := 16;             Nuisance Charges --3rd Party
  --w_ptbm.mtr_chrg                 --> w_line_items := 17;             Meter Charges --3rd Party
  --w_ptbm.hlp_loan                 --> w_line_items := 18;             Help Loan --3rd Party
  --w_ptbm.debt_bal_amnt_cty        --> w_line_items := 19;             City Grants
  --w_ptbm.debt_bal_amnt_cri        --> w_line_items := 20;             Crisis Grants
  --w_ptbm.debt_bal_amnt_lih        --> w_line_items := 21;             Liheap Grants
  --w_ptbm.debt_bal_amnt_ues        --> w_line_items := 22;             UESE Grants
  --w_ptbm.total_due_amnt           --> w_line_items := 23;             Total Due Amount for this Bill
  --w_ptbm.penalty_amnt             --> w_line_items := 24;             Penalty Amount if not paid within due date
  --w_ptbm.penalty_due_amnt         --> w_line_items := 25;             Total Due with Penalty Due Amount if not paid within due date
  --w_ptbm.total_bal                --> w_line_items := 26;             Toital Account Balance
  --w_ptbm.previous_balance_amnt    --> w_line_items := 01;             Previous Balance Amount
  --w_ptbm.last_paid_amnt           --> w_line_items := 02;             Last Paid Amount
  --w_ptbm.un_paid_prv_bal          --> w_line_items := 03;             UnPaid Previous Balance
  --w_ptbm.usage_charge_amnt        --> w_line_items := 04;             Usage Charge --> If not there it will be Zero
  --Start Add 4419
  if w_ptbm.bflg_13 is not null and w_ptbm.bflg_12 is not null then
     --w_ptbm.grph_mesg1  := substr('You''ve had two estimated bills in a row - please call customer care',1,100);
     w_grph_mesg3 := substr('You''ve had two estimated bills in a row - please call (215)685-6300',1,100); --Chngd 11137 from:: (215) 686-6880 to:: (215)685-6300 
  end if;
  --End Add 4419
  --Start ADD 3706 Four consecutive Zeros
  w_conc_4_zeros     := 0;
  --w_ptbm.grph_mesg1  := null;
  --if w_conc_4_zeros >= 4 then null; elsif nvl(w_ptbm.billed_qty_24,0) != 0 and w_ptbm.billed_qty_24 is not null then w_conc_4_zeros := 0; else w_conc_4_zeros := nvl(w_conc_4_zeros,0) + 1; end if;
  --if w_conc_4_zeros >= 4 then null; elsif nvl(w_ptbm.billed_qty_23,0) != 0 and w_ptbm.billed_qty_23 is not null then w_conc_4_zeros := 0; else w_conc_4_zeros := nvl(w_conc_4_zeros,0) + 1; end if;
  --if w_conc_4_zeros >= 4 then null; elsif nvl(w_ptbm.billed_qty_22,0) != 0 and w_ptbm.billed_qty_22 is not null then w_conc_4_zeros := 0; else w_conc_4_zeros := nvl(w_conc_4_zeros,0) + 1; end if;
  --if w_conc_4_zeros >= 4 then null; elsif nvl(w_ptbm.billed_qty_21,0) != 0 and w_ptbm.billed_qty_21 is not null then w_conc_4_zeros := 0; else w_conc_4_zeros := nvl(w_conc_4_zeros,0) + 1; end if;
  --if w_conc_4_zeros >= 4 then null; elsif nvl(w_ptbm.billed_qty_20,0) != 0 and w_ptbm.billed_qty_20 is not null then w_conc_4_zeros := 0; else w_conc_4_zeros := nvl(w_conc_4_zeros,0) + 1; end if;
  --if w_conc_4_zeros >= 4 then null; elsif nvl(w_ptbm.billed_qty_19,0) != 0 and w_ptbm.billed_qty_19 is not null then w_conc_4_zeros := 0; else w_conc_4_zeros := nvl(w_conc_4_zeros,0) + 1; end if;
  --if w_conc_4_zeros >= 4 then null; elsif nvl(w_ptbm.billed_qty_18,0) != 0 and w_ptbm.billed_qty_18 is not null then w_conc_4_zeros := 0; else w_conc_4_zeros := nvl(w_conc_4_zeros,0) + 1; end if;
  --if w_conc_4_zeros >= 4 then null; elsif nvl(w_ptbm.billed_qty_17,0) != 0 and w_ptbm.billed_qty_17 is not null then w_conc_4_zeros := 0; else w_conc_4_zeros := nvl(w_conc_4_zeros,0) + 1; end if;
  --if w_conc_4_zeros >= 4 then null; elsif nvl(w_ptbm.billed_qty_16,0) != 0 and w_ptbm.billed_qty_16 is not null then w_conc_4_zeros := 0; else w_conc_4_zeros := nvl(w_conc_4_zeros,0) + 1; end if;
  --if w_conc_4_zeros >= 4 then null; elsif nvl(w_ptbm.billed_qty_15,0) != 0 and w_ptbm.billed_qty_15 is not null then w_conc_4_zeros := 0; else w_conc_4_zeros := nvl(w_conc_4_zeros,0) + 1; end if;
  --if w_conc_4_zeros >= 4 then null; elsif nvl(w_ptbm.billed_qty_14,0) != 0 and w_ptbm.billed_qty_14 is not null then w_conc_4_zeros := 0; else w_conc_4_zeros := nvl(w_conc_4_zeros,0) + 1; end if;
  if w_conc_4_zeros >= 4 then null; elsif nvl(w_ptbm.billed_qty_13,0) != 0 and w_ptbm.billed_qty_13 is not null then w_conc_4_zeros := 0; else w_conc_4_zeros := nvl(w_conc_4_zeros,0) + 1; end if;
  if w_conc_4_zeros >= 4 then null; elsif nvl(w_ptbm.billed_qty_12,0) != 0 and w_ptbm.billed_qty_12 is not null then w_conc_4_zeros := 0; else w_conc_4_zeros := nvl(w_conc_4_zeros,0) + 1; end if;
  if w_conc_4_zeros >= 4 then null; elsif nvl(w_ptbm.billed_qty_11,0) != 0 and w_ptbm.billed_qty_11 is not null then w_conc_4_zeros := 0; else w_conc_4_zeros := nvl(w_conc_4_zeros,0) + 1; end if;
  if w_conc_4_zeros >= 4 then null; elsif nvl(w_ptbm.billed_qty_10,0) != 0 and w_ptbm.billed_qty_10 is not null then w_conc_4_zeros := 0; else w_conc_4_zeros := nvl(w_conc_4_zeros,0) + 1; end if;
  if w_conc_4_zeros >= 4 then null; elsif nvl(w_ptbm.billed_qty_09,0) != 0 and w_ptbm.billed_qty_09 is not null then w_conc_4_zeros := 0; else w_conc_4_zeros := nvl(w_conc_4_zeros,0) + 1; end if;
  if w_conc_4_zeros >= 4 then null; elsif nvl(w_ptbm.billed_qty_08,0) != 0 and w_ptbm.billed_qty_08 is not null then w_conc_4_zeros := 0; else w_conc_4_zeros := nvl(w_conc_4_zeros,0) + 1; end if;
  if w_conc_4_zeros >= 4 then null; elsif nvl(w_ptbm.billed_qty_07,0) != 0 and w_ptbm.billed_qty_07 is not null then w_conc_4_zeros := 0; else w_conc_4_zeros := nvl(w_conc_4_zeros,0) + 1; end if;
  if w_conc_4_zeros >= 4 then null; elsif nvl(w_ptbm.billed_qty_06,0) != 0 and w_ptbm.billed_qty_06 is not null then w_conc_4_zeros := 0; else w_conc_4_zeros := nvl(w_conc_4_zeros,0) + 1; end if;
  if w_conc_4_zeros >= 4 then null; elsif nvl(w_ptbm.billed_qty_05,0) != 0 and w_ptbm.billed_qty_05 is not null then w_conc_4_zeros := 0; else w_conc_4_zeros := nvl(w_conc_4_zeros,0) + 1; end if;
  if w_conc_4_zeros >= 4 then null; elsif nvl(w_ptbm.billed_qty_04,0) != 0 and w_ptbm.billed_qty_04 is not null then w_conc_4_zeros := 0; else w_conc_4_zeros := nvl(w_conc_4_zeros,0) + 1; end if;
  if w_conc_4_zeros >= 4 then null; elsif nvl(w_ptbm.billed_qty_03,0) != 0 and w_ptbm.billed_qty_03 is not null then w_conc_4_zeros := 0; else w_conc_4_zeros := nvl(w_conc_4_zeros,0) + 1; end if;
  if w_conc_4_zeros >= 4 then null; elsif nvl(w_ptbm.billed_qty_02,0) != 0 and w_ptbm.billed_qty_02 is not null then w_conc_4_zeros := 0; else w_conc_4_zeros := nvl(w_conc_4_zeros,0) + 1; end if;
  if w_conc_4_zeros >= 4 then null; elsif nvl(w_ptbm.billed_qty_01,0) != 0 and w_ptbm.billed_qty_01 is not null then w_conc_4_zeros := 0; else w_conc_4_zeros := nvl(w_conc_4_zeros,0) + 1; end if;
  if w_conc_4_zeros >= 4 then
      if w_agr_exists = 'Y' then
         if substr(w_int_attr29,1,2) = '3A' and nvl(w_int_attr19,'XX') != 'Y' then   --Stormwater Only
            --w_ptbm.grph_mesg1 := null;  --Del 4419
            w_grph_mesg1      := null;    --Add 4419
         elsif nvl(w_ptbm.cust_type_code,'XX') = 'Y' or nvl(w_int_attr19,'XX') = 'Y' or trim(w_round_key) = '420' then --Fire Service
            --w_ptbm.grph_mesg1 := null;  --Del 4419
            w_grph_mesg1      := null;    --Add 4419
         elsif nvl(w_ptbm.inst_type_code,'XX') = '19' and nvl(w_pay_profile_code_orig,'XX') = 'SURCHRGE' then --Surcharge Account
            --w_ptbm.grph_mesg1 := null;  --Del 4419
            w_grph_mesg1      := null;    --Add 4419
         elsif w_usec_code = 'GRW-SWCG' then --Ground Water no Message
            --w_ptbm.grph_mesg1 := null;  --Del 4419
            w_grph_mesg1        := null;  --Add 4419
         else
            --w_ptbm.grph_mesg1  := substr('If property was occupied during zero usage please call customer care',1,100); --Del 4419
            w_grph_mesg1       := substr('If property was occupied during zero usage please call (215) 685-6300',1,100);   --Chgd 11137 from 6880 to 6300 -Add 4419 
         end if;
      end if;
  end if;
  --End ADD 3706 Four consecutive Zeros
  --Start Add 3706
  --Fire Service Start Date End Date
  -- * --if nvl(w_ptbm.cust_type_code,'XX') = 'Y' or nvl(w_int_attr19,'XX') = 'Y' or trim(w_round_key) = '420' then
  -- * --    select  min(dbl.period_from_date), max(dbl.period_upto_date)
  -- * --      into  w_ptbm.fir_srv_chg_fr_dt, w_ptbm.fir_srv_chg_to_dt
  -- * --      --into w_sw_chg_fr_dt, w_sw_chg_to_dt
  -- * --      from cis_debit_lines dbl
  -- * --     where dbl.tran_id = w_tran_id
  -- * --       and dbl.task_code = 'BILL'
  -- * --       and dbl.scnd_type = 'AGR' ;
  -- * --end if;
  --End Add 3706
  --Start Add 3706 --First Service Charge From and Upto Dates
  if nvl(w_ptbm.cust_type_code,'XX') = 'Y' or nvl(w_int_attr19,'XX') = 'Y' or trim(w_round_key) = '420' then
     if w_ptbm.reading_from_date is not null then w_ptbm.fir_srv_chg_fr_dt := w_ptbm.reading_from_date; end if;
     if w_ptbm.reading_upto_date is not null then w_ptbm.fir_srv_chg_to_dt := w_ptbm.reading_upto_date; end if;
  end if;
  --End Add 3706
  --Start Add 3706
  if w_ptbm.inst_type_code = 18 then
     w_ptbm.surchg_flg := 'LAUNDRY';
  else
     w_ptbm.surchg_flg := null;
  end if;
  --End Add 3706
  --Start 3706
  --Start 4119
  if w_grph_mesg3 is not null then
     w_ptbm.grph_mesg1 := w_grph_mesg3;
  end if;
  if w_grph_mesg2 is not null then
     w_ptbm.grph_mesg1 := w_grph_mesg2;
  end if;
  if w_grph_mesg1 is not null then
     w_ptbm.grph_mesg1 := w_grph_mesg1;
  end if;
  --End 4119
  --End 3706
  --Start Add 4561
  w_label := 'e102';
  if  w_meter_grp_rdg_id is not null
  and isZacct# = true then  --Then fetch the record from 000 (non Z account) account. For reading and other details..
    debug_trace(w_procedure_name,'...Check for the Meter Reading details from standard accounts...' );
    debug_trace(w_procedure_name,' billing_date_yyyymmdd --> ' || to_char(w_ptbm.billing_date,'YYYYMMDD'));
    debug_trace(w_procedure_name,' w_cust_id --> ' || w_cust_id);
    debug_trace(w_procedure_name,' w_meter_grp_rdg_id    --> ' || w_meter_grp_rdg_id);
    debug_trace(w_procedure_name,' bill_account_number   --> ' || trim(substr(w_ptbm.bill_account_number,1,15)));
    for r1 in (select * from phl_0acc_mtr_grp_bill_hst
                where billing_date_yyyymmdd = to_char(w_ptbm.billing_date,'YYYYMMDD')
                  and cust_id = w_cust_id
                  --and meter_grp_rdg_id = w_meter_grp_rdg_id
                  and partial_w1_acct_no = trim(substr(w_ptbm.bill_account_number,1,15))
                order by seq_no desc
              )
    loop
      debug_trace(w_procedure_name,' *** Inside the loop *** ');
      w_ptbm.reading_from_date        := r1.reading_from_date       ;
      w_ptbm.reading_upto_date        := r1.reading_upto_date       ;
      w_ptbm.last_billed_reading      := r1.last_billed_reading     ;
      w_ptbm.this_billed_reading      := r1.this_billed_reading     ;
      w_ptbm.billed_qty               := r1.billed_qty              ;
      w_ptbm.ert_key                  := r1.ert_key                 ;
      w_ptbm.est_last_rdg_flag        := r1.est_last_rdg_flag       ;
      w_ptbm.est_this_rdg_flag        := r1.est_this_rdg_flag       ;
      w_ptbm.gal_used_per_day         := r1.gal_used_per_day        ;
      w_ptbm.repl_meter_key           := r1.repl_meter_key          ;  --11138 if needed we can add meter_key_10chr, meter_id, repl_meter_key_10chr, repl_meter_id to meter group logic
      w_ptbm.repl_srvc_size_code      := r1.repl_srvc_size_code     ;
      w_ptbm.repl_bill_service        := r1.repl_bill_service       ;
      w_ptbm.repl_reading_from_date   := r1.repl_reading_from_date  ;
      w_ptbm.repl_reading_upto_date   := r1.repl_reading_upto_date  ;
      w_ptbm.repl_last_billed_reading := r1.repl_last_billed_reading;
      w_ptbm.repl_this_billed_reading := r1.repl_this_billed_reading;
      w_ptbm.repl_billed_qty          := r1.repl_billed_qty         ;
      w_ptbm.repl_ert_key             := r1.repl_ert_key            ;
      w_ptbm.est_repl_last_rdg_flag   := r1.est_repl_last_rdg_flag  ;
      w_ptbm.est_repl_this_rdg_flag   := r1.est_repl_this_rdg_flag  ;
      w_ptbm.repl_gal_used_per_day    := r1.repl_gal_used_per_day   ;
      w_ptbm.billed_qty_01            := r1.billed_qty_01           ;
      w_ptbm.billed_qty_02            := r1.billed_qty_02           ;
      w_ptbm.billed_qty_03            := r1.billed_qty_03           ;
      w_ptbm.billed_qty_04            := r1.billed_qty_04           ;
      w_ptbm.billed_qty_05            := r1.billed_qty_05           ;
      w_ptbm.billed_qty_06            := r1.billed_qty_06           ;
      w_ptbm.billed_qty_07            := r1.billed_qty_07           ;
      w_ptbm.billed_qty_08            := r1.billed_qty_08           ;
      w_ptbm.billed_qty_09            := r1.billed_qty_09           ;
      w_ptbm.billed_qty_10            := r1.billed_qty_10           ;
      w_ptbm.billed_qty_11            := r1.billed_qty_11           ;
      w_ptbm.billed_qty_12            := r1.billed_qty_12           ;
      w_ptbm.billed_qty_13            := r1.billed_qty_13           ;
      w_ptbm.blbl_01                  := r1.blbl_01                 ;
      w_ptbm.blbl_02                  := r1.blbl_02                 ;
      w_ptbm.blbl_03                  := r1.blbl_03                 ;
      w_ptbm.blbl_04                  := r1.blbl_04                 ;
      w_ptbm.blbl_05                  := r1.blbl_05                 ;
      w_ptbm.blbl_06                  := r1.blbl_06                 ;
      w_ptbm.blbl_07                  := r1.blbl_07                 ;
      w_ptbm.blbl_08                  := r1.blbl_08                 ;
      w_ptbm.blbl_09                  := r1.blbl_09                 ;
      w_ptbm.blbl_10                  := r1.blbl_10                 ;
      w_ptbm.blbl_11                  := r1.blbl_11                 ;
      w_ptbm.blbl_12                  := r1.blbl_12                 ;
      w_ptbm.blbl_13                  := r1.blbl_13                 ;
      w_ptbm.bflg_01                  := r1.bflg_01                 ;
      w_ptbm.bflg_02                  := r1.bflg_02                 ;
      w_ptbm.bflg_03                  := r1.bflg_03                 ;
      w_ptbm.bflg_04                  := r1.bflg_04                 ;
      w_ptbm.bflg_05                  := r1.bflg_05                 ;
      w_ptbm.bflg_06                  := r1.bflg_06                 ;
      w_ptbm.bflg_07                  := r1.bflg_07                 ;
      w_ptbm.bflg_08                  := r1.bflg_08                 ;
      w_ptbm.bflg_09                  := r1.bflg_09                 ;
      w_ptbm.bflg_10                  := r1.bflg_10                 ;
      w_ptbm.bflg_11                  := r1.bflg_11                 ;
      w_ptbm.bflg_12                  := r1.bflg_12                 ;
      w_ptbm.bflg_13                  := r1.bflg_13                 ;
      w_ptbm.grph_mesg1               := r1.grph_mesg1              ;
      w_ptbm.tot_bill_rdg             := r1.tot_bill_rdg            ;
      exit;
    end loop;
  end if;
  w_label := 'e103';
  if nvl(w_ptbm.billed_qty_01,0) <= 0 then  w_char_billed_qty_01 := '0'; else w_char_billed_qty_01 := to_char(w_ptbm.billed_qty_01); end if;  --Add 3908
  if nvl(w_ptbm.billed_qty_02,0) <= 0 then  w_char_billed_qty_02 := '0'; else w_char_billed_qty_02 := to_char(w_ptbm.billed_qty_02); end if;  --Add 3908
  if nvl(w_ptbm.billed_qty_03,0) <= 0 then  w_char_billed_qty_03 := '0'; else w_char_billed_qty_03 := to_char(w_ptbm.billed_qty_03); end if;  --Add 3908
  if nvl(w_ptbm.billed_qty_04,0) <= 0 then  w_char_billed_qty_04 := '0'; else w_char_billed_qty_04 := to_char(w_ptbm.billed_qty_04); end if;  --Add 3908
  if nvl(w_ptbm.billed_qty_05,0) <= 0 then  w_char_billed_qty_05 := '0'; else w_char_billed_qty_05 := to_char(w_ptbm.billed_qty_05); end if;  --Add 3908
  if nvl(w_ptbm.billed_qty_06,0) <= 0 then  w_char_billed_qty_06 := '0'; else w_char_billed_qty_06 := to_char(w_ptbm.billed_qty_06); end if;  --Add 3908
  if nvl(w_ptbm.billed_qty_07,0) <= 0 then  w_char_billed_qty_07 := '0'; else w_char_billed_qty_07 := to_char(w_ptbm.billed_qty_07); end if;  --Add 3908
  if nvl(w_ptbm.billed_qty_08,0) <= 0 then  w_char_billed_qty_08 := '0'; else w_char_billed_qty_08 := to_char(w_ptbm.billed_qty_08); end if;  --Add 3908
  if nvl(w_ptbm.billed_qty_09,0) <= 0 then  w_char_billed_qty_09 := '0'; else w_char_billed_qty_09 := to_char(w_ptbm.billed_qty_09); end if;  --Add 3908
  if nvl(w_ptbm.billed_qty_10,0) <= 0 then  w_char_billed_qty_10 := '0'; else w_char_billed_qty_10 := to_char(w_ptbm.billed_qty_10); end if;  --Add 3908
  if nvl(w_ptbm.billed_qty_11,0) <= 0 then  w_char_billed_qty_11 := '0'; else w_char_billed_qty_11 := to_char(w_ptbm.billed_qty_11); end if;  --Add 3908
  if nvl(w_ptbm.billed_qty_12,0) <= 0 then  w_char_billed_qty_12 := '0'; else w_char_billed_qty_12 := to_char(w_ptbm.billed_qty_12); end if;  --Add 3908
  if nvl(w_ptbm.billed_qty_13,0) <= 0 then  w_char_billed_qty_13 := '0'; else w_char_billed_qty_13 := to_char(w_ptbm.billed_qty_13); end if;  --Add 3908
  --if nvl(w_ptbm.billed_qty_14,0) <= 0 then  w_char_billed_qty_14 := '0'; else w_char_billed_qty_14 := to_char(w_ptbm.billed_qty_14); end if;  --Add 3908
  --if nvl(w_ptbm.billed_qty_15,0) <= 0 then  w_char_billed_qty_15 := '0'; else w_char_billed_qty_15 := to_char(w_ptbm.billed_qty_15); end if;  --Add 3908
  --if nvl(w_ptbm.billed_qty_16,0) <= 0 then  w_char_billed_qty_16 := '0'; else w_char_billed_qty_16 := to_char(w_ptbm.billed_qty_16); end if;  --Add 3908
  --if nvl(w_ptbm.billed_qty_17,0) <= 0 then  w_char_billed_qty_17 := '0'; else w_char_billed_qty_17 := to_char(w_ptbm.billed_qty_17); end if;  --Add 3908
  --if nvl(w_ptbm.billed_qty_18,0) <= 0 then  w_char_billed_qty_18 := '0'; else w_char_billed_qty_18 := to_char(w_ptbm.billed_qty_18); end if;  --Add 3908
  --if nvl(w_ptbm.billed_qty_19,0) <= 0 then  w_char_billed_qty_19 := '0'; else w_char_billed_qty_19 := to_char(w_ptbm.billed_qty_19); end if;  --Add 3908
  --if nvl(w_ptbm.billed_qty_20,0) <= 0 then  w_char_billed_qty_20 := '0'; else w_char_billed_qty_20 := to_char(w_ptbm.billed_qty_20); end if;  --Add 3908
  --if nvl(w_ptbm.billed_qty_21,0) <= 0 then  w_char_billed_qty_21 := '0'; else w_char_billed_qty_21 := to_char(w_ptbm.billed_qty_21); end if;  --Add 3908
  --if nvl(w_ptbm.billed_qty_22,0) <= 0 then  w_char_billed_qty_22 := '0'; else w_char_billed_qty_22 := to_char(w_ptbm.billed_qty_22); end if;  --Add 3908
  --if nvl(w_ptbm.billed_qty_23,0) <= 0 then  w_char_billed_qty_23 := '0'; else w_char_billed_qty_23 := to_char(w_ptbm.billed_qty_23); end if;  --Add 3908
  --if nvl(w_ptbm.billed_qty_24,0) <= 0 then  w_char_billed_qty_24 := '0'; else w_char_billed_qty_24 := to_char(w_ptbm.billed_qty_24); end if;  --Add 3908
  --End Add 4561
  /* Start Add 7055 */
  w_label := 'e104';
  if w_ptbm.wrbccpmt is not null then
     if w_ppln_type = 'I' then
       w_ptbm.pymagr_due_lbl := trim(substr('WRBCC Payment Due',1,30));
     end if;
  elsif w_ptbm.pymtagree is not null then
     if w_ppln_type != 'I' then
        w_ptbm.pymagr_due_lbl := trim(substr('Payment Agreement Due',1,30));
        /*
       if w_ptbm.tap_group_num is not null then
            w_ptbm.pymagr_due_lbl := trim(substr('Payment Agreement Due',1,30)); --Chng from TAP-BCK Payment Due --Let be If Condition Not sure we may need a diff Label.
       else
            w_ptbm.pymagr_due_lbl := trim(substr('Payment Agreement Due',1,30));
       end if;
       */
     end if;
   end if;
  /* End Add 7055 */
  w_label := 'e105';
  w_line_items          := 0;
  w_ptbm.no_of_pages    := 1;
  w_big_three_cnt          := 0;
  w_othr_fees_crds_flg     := 'N';
  w_cur_chg_solid_line_flg := 'N';
  --Start add 4575
  w_unpaid_bal_lbl    := null;
  w_label := 'e106';
  if nvl(w_ptbm.un_paid_prv_bal,0) <= 0 then
     w_unpaid_bal_lbl := 'Account Balance';
  else
     w_unpaid_bal_lbl := 'Unpaid Balance';
  end if;
  --End add 4575
  w_label := 'e107';
  if w_ptbm.previous_balance_amnt   is not null then w_line_items := w_line_items + 1; end if; --> Previous Balance              -- Line Item# 1
  if w_ptbm.last_paid_amnt          is not null then w_line_items := w_line_items + 1; end if; --> Last Paid Amount              -- Line Item# 2
  if w_ptbm.un_paid_prv_bal         is not null then w_line_items := w_line_items + 1; end if; --> Previous Balance              -- Line Item# 3
  if w_ptbm.usage_charge_amnt       is not null then w_line_items := w_line_items + 1; w_big_three_cnt := nvl(w_big_three_cnt,0)  + 1; end if; --> Usage Charge                  -- Line Item# 4
  if w_ptbm.service_charge_amnt     is not null then w_line_items := w_line_items + 1; w_big_three_cnt := nvl(w_big_three_cnt,0)  + 1; end if; --> Service Charges               -- Line Item# 5
  if w_char_stormchg                is not null then w_line_items := w_line_items + 1; w_big_three_cnt := nvl(w_big_three_cnt,0)  + 1; end if; --> Storm Water Charges           -- Line Item# 6
  /* Start Add 4608
     This are changes for Current_Charge_Amnt.
     Introducing w_cur_chg_solid_line_flg field, to store all future flags
     decode this one field to provide various flag to Brian
  */
  if w_ptbm.discount_amnt           is not null then w_line_items := w_line_items + 1; w_cur_chg_solid_line_flg := 'Y'; end if; --> Discount Amount             --Mod 4608 w_othr_fees_crds_flg := 'Y'; changed to w_cur_chg_solid_line_flg := 'Y'; -- Line Item# 7
  --if w_ptbm.surchg_flg              is not null then w_line_items := w_line_items + 1; w_othr_fees_crds_flg := 'Y'; end if; --> Laundry Surcharge               -- Line Item# --Not required -- Del 4578
  if w_ptbm.fire_srvc_chg_amnt      is not null then w_line_items := w_line_items + 1; w_cur_chg_solid_line_flg := 'Y'; end if; --> Fire Service Charge Amount  --Mod 4608 w_othr_fees_crds_flg := 'Y'; changed to w_cur_chg_solid_line_flg := 'Y'; -- Line Item# 8
  if w_ptbm.induschg                is not null then w_line_items := w_line_items + 1; w_cur_chg_solid_line_flg := 'Y'; end if; --> Industrial Surcharge        --Mod 4608 w_othr_fees_crds_flg := 'Y'; changed to w_cur_chg_solid_line_flg := 'Y'; -- Line Item# 9
  --if w_ptbm.debt_bal_amnt_cty       is not null then w_line_items := w_line_items + 1; w_othr_fees_crds_flg := 'Y'; end if; --> City Grants                   -- Line Item# --NA
  --if w_ptbm.debt_bal_amnt_cri       is not null then w_line_items := w_line_items + 1; w_othr_fees_crds_flg := 'Y'; end if; --> Crisis Grants                 -- Line Item# --NA
  --if w_ptbm.debt_bal_amnt_lih       is not null then w_line_items := w_line_items + 1; w_othr_fees_crds_flg := 'Y'; end if; --> Liheap Grants                 -- Line Item# --NA
  --if w_ptbm.debt_bal_amnt_ues       is not null then w_line_items := w_line_items + 1; w_othr_fees_crds_flg := 'Y'; end if; --> UESE Grants                   -- Line Item# --NA
  --if w_ptbm.adjust                  is not null then w_line_items := w_line_items + 1; w_othr_fees_crds_flg := 'Y'; end if; --> ADJUST                        -- Line Item# --NA --Del 3706 because it moved up
   --w_ptbm.wrbcccred  --It is not counted because it's always linked with WRBCC Payment Agreement and it will be a two page bill.
  --As per Brian include WRBCCCRED IF IT'S NOT NULL SET  w_othr_fees_crds_flg = Y
  --if not(nvl(w_ar_acct_bal,0) < nvl(w_rchl.agrv_rc_debt_to_exclude,0)) then --Add 5905 3.0.0.39
  w_label := 'e108';
  if not(donot_print_rc) then
     --Start Add 4398
     if w_rchl.agrv_rc_5th_fpg_inv_desc is not null then w_line_items := w_line_items + 1; w_cur_chg_solid_line_flg := 'Y'; end if;  -- Line Item# 9
     if w_rchl.agrv_rc_4th_fpg_inv_desc is not null then w_line_items := w_line_items + 1; w_cur_chg_solid_line_flg := 'Y'; end if;  -- Line Item# 9
     if w_rchl.agrv_rc_3rd_fpg_inv_desc is not null then w_line_items := w_line_items + 1; w_cur_chg_solid_line_flg := 'Y'; end if;  -- Line Item# 9
     if w_rchl.agrv_rc_2nd_fpg_inv_desc is not null then w_line_items := w_line_items + 1; w_cur_chg_solid_line_flg := 'Y'; end if;  -- Line Item# 9
     if w_rchl.agrv_rc_1st_fpg_inv_desc is not null then w_line_items := w_line_items + 1; w_cur_chg_solid_line_flg := 'Y'; end if;  -- Line Item# 9
     if w_rchl.agrv_rc_cur_rem_inv_bal  is not null then w_line_items := w_line_items + 1; w_cur_chg_solid_line_flg := 'Y'; end if;  -- Line Item# 9
     if w_rchl.agrv_rc_unpaid_amnt is not null then w_line_items := w_line_items + 1; w_othr_fees_crds_flg := 'Y'; end if;  --Add 5905 3.0.0.39
     --End Add 4398
  end if; --Add 5905 3.0.0.39
  w_label := 'e109';
  if w_ptbm.wrbcccred is  not null then w_line_items := w_line_items + 1; w_othr_fees_crds_flg := 'Y'; end if; --Add 4575
  if w_ptbm.late_pmt_penalty        is not null then w_line_items := w_line_items + 1; w_othr_fees_crds_flg := 'Y'; end if; --> Late Payment Penalty              -- Line Item# 10
  if w_ptbm.lien                    is not null then w_line_items := w_line_items + 1; w_othr_fees_crds_flg := 'Y'; end if; --> Lien Fees                         -- Line Item# 11
  if w_bad_check_fee                is not null then w_line_items := w_line_items + 1; w_othr_fees_crds_flg := 'Y'; end if; --> Bad Check Fee                     -- Line item# 12
  --if w_ptbm.nus_chrg                is not null then w_line_items := w_line_items + 1; w_othr_fees_crds_flg := 'Y'; end if; --Del 4398 --> Nuisance Charges     -- Line item# 13
  --if w_ptbm.mtr_chrg                is not null then w_line_items := w_line_items + 1; w_othr_fees_crds_flg := 'Y'; end if; --Del 4398 --> Meter Charges        -- Line item# 14
  --if w_ptbm.hlp_loan                is not null then w_line_items := w_line_items + 1; w_othr_fees_crds_flg := 'Y'; end if; --Del 4398 --> Help Loan            -- Line item# 15
  --if w_rchl.agrv_rc_unpaid_amnt is not null then w_line_items := w_line_items + 1; w_othr_fees_crds_flg := 'Y'; end if;  --Del 5905 3.0.0.39 --Add 4398
  --if w_ptbm.sew_ren_fct_dis         is not null then w_line_items := w_line_items + 1; w_othr_fees_crds_flg := 'Y'; end if; --> Sew Ren Fct Dis                 -- Line item# 16
  --if w_ptbm.total_due_amnt          is not null then w_line_items := w_line_items + 1; w_othr_fees_crds_flg := 'Y'; end if; --Del 3706 --> Total Due Amount for this Bill-- Line item# --NA
  --if w_ptbm.total_bal               is not null then w_line_items := w_line_items + 1; w_othr_fees_crds_flg := 'Y'; end if; --Del 3706 --> Total Account Balance        -- Line item#  --NA
  --Start Add 6230
  w_label := 'e110';
  if w_ptbm.tap_disc is not null then
     w_line_items := w_line_items + 1;
     w_othr_fees_crds_flg := 'Y';
       --Start Del 7176
     --
     --Not using w_ptbm.cust_type_code = ('D') becuase its do not gurantee its for Residential customers.
     --Hence using discount label, which gurantees that we are looking only at Residential customers
     --
       /*
     if w_ptbm.discount_lbl  = 'Senior Citizen Discount' then                  --Add 6230B
        w_ptbm.tap_disc      := w_ptbm.tap_disc + nvl(w_ptbm.discount_amnt,0); --Add 6230B
        w_ptbm.discount_amnt := 0;                                             --Add 6230B
     end if;                                                                   --Add 6230B
     */
       --End Del 7176
  end if;
  --End Add 6230
  --Start add 7164D
  if nvl(w_ptbm.amnt_in_disp,0) = 0 then
   w_ptbm.amnt_in_disp := null;
  else
   w_line_items := w_line_items + 1;
   w_othr_fees_crds_flg := 'Y';
   end if;
   --End add 7164D
  --if  w_line_items > 9 then --Del 4398
  if  w_line_items > 15 then  --Add 4398
      w_ptbm.no_of_pages := 2;
  end if;
  if w_ptbm.pymtagree is not null or w_ptbm.wrbccpmt is not null then
     w_ptbm.no_of_pages    := 2;
     w_line_items          := 99;
     w_othr_fees_crds_flg  := 'Y';
  end if;
  if w_ptbm.meter_key is not null and w_ptbm.repl_meter_key is not null then
     w_ptbm.no_of_pages := 2;
     w_line_items       := 98;
  end if;
  if w_ptbm.billed_qty is not null and w_ptbm.repl_billed_qty is not null then
     w_ptbm.no_of_pages := 2;
     w_line_items       := 98;
  end if;
  if w_ptbm.reading_from_date is not null and w_ptbm.repl_reading_from_date is not null then
     w_ptbm.no_of_pages := 2;
     w_line_items       := 98;
  end if;
  if w_ptbm.reading_upto_date is not null and w_ptbm.repl_reading_upto_date is not null then
     w_ptbm.no_of_pages := 2;
     w_line_items       := 98;
  end if;
  --Start Add 6230
  w_label := 'e111';
  if w_ptbm.tap_recertify_date is not null
  or w_ptbm.tap_tot_act_usg_srv_chg is not null
  or w_ptbm.tap_tot_chg_amnt is not null
  or w_ptbm.tap_tot_saved_amnt is not null
  or w_ptbm.tap_tot_past_due_paid_amnt is not null
  or w_ptbm.tap_ef_count is not null then
     w_ptbm.no_of_pages := 2;
     w_line_items       := 97;
  end if;
  --End Add 6230
  --if not(nvl(w_ar_acct_bal,0) < nvl(w_rchl.agrv_rc_debt_to_exclude,0)) then --Add 5905 3.0.0.39
  w_label := 'e112';
  if not(donot_print_rc) then
     --Start Add 4398
     if   nvl(w_rchl.agrv_rc_5th_cur_prv_flag,'!@#') in ('C','P' )
       or nvl(w_rchl.agrv_rc_4th_cur_prv_flag,'!@#') in ('C','P' )
       or nvl(w_rchl.agrv_rc_3rd_cur_prv_flag,'!@#') in ('C','P' )
       or nvl(w_rchl.agrv_rc_2nd_cur_prv_flag,'!@#') in ('C','P' )
       or nvl(w_rchl.agrv_rc_1st_cur_prv_flag,'!@#') in ('C','P' )
       or w_rchl.agrv_rc_prv_rem_inv_bal is not null then
        w_ptbm.no_of_pages := 2;
        w_line_items       := 101;
     end if;
  end if;--Add 5905 3.0.0.39
  --if not(nvl(w_hl_acct_bal,0) < nvl(w_rchl.agrv_hl_debt_to_exclude,0)) then --Add 5905 3.0.0.39
  w_label := 'e113';
  if not(donot_print_hl) then
     if w_rchl.agrv_hl_unpaid_lbl is not null then
        w_ptbm.pays_by_zipcheck  := NULL; --We want return check envelopes for HELPLOANS.
        if w_ptbm.no_of_pages = 2 then
           w_ptbm.no_of_pages := 3;
           w_line_items       := 111;
        elsif w_ptbm.no_of_pages = 1 then
           w_ptbm.no_of_pages := 2;
           w_line_items       := 111;
        end if;
     end if;
  end if;--Add 5905 3.0.0.39
  --End Add 4398
  /* Logic for Font Indicator */
  --Please pay $10,003,158.59 by June 25, 2014
  w_label := 'e114';
   w_ptbm.dcr_fnt_sz_amnt_hdrs := 'N';
   if length(trim(to_char(w_ptbm.total_due_amnt,'$99,999,990.00'))) >= 14 then
      if length('Please pay ' || trim(to_char(w_ptbm.total_due_amnt,'$99,999,990.00')) || ' by ' || datefullc(w_ptbm.incl_payments_date)) > 42 or
         length('Total amount due by ' || datefullc(w_ptbm.incl_payments_date)) > 33 or
         length('Late payment penalty (after  ' || datefullc(w_ptbm.incl_payments_date)||')') > 42 then
         w_ptbm.dcr_fnt_sz_amnt_hdrs := 'Y';
      end if;
   end if;
  w_label := 'e115';
  w_ptbm.no_of_line_items     := w_line_items;
  w_ptbm.othr_fees_crds_flg   := w_othr_fees_crds_flg;
  w_ptbm.big_three_cnt        := w_big_three_cnt;
  --End   Add 3706
  w_ptbm.all_flags            := trim(w_othr_fees_crds_flg) || trim(w_cur_chg_solid_line_flg);  --Add 4608
  --Start Add 4398
  w_label := 'e116';
  if w_ptbm.last_paid_date is not null and w_rchl.agrv_rc_last_pymnt_dt is null then
   w_lst_pymnt_dt := w_ptbm.last_paid_date;
  elsif w_ptbm.last_paid_date is null and w_rchl.agrv_rc_last_pymnt_dt is not null then
   w_lst_pymnt_dt := w_rchl.agrv_rc_last_pymnt_dt;
  elsif w_ptbm.last_paid_date is not null and w_rchl.agrv_rc_last_pymnt_dt is not null then
   w_lst_pymnt_dt := greatest(w_ptbm.last_paid_date,w_rchl.agrv_rc_last_pymnt_dt);
  else
   w_lst_pymnt_dt := null;
  end if;
  --End Add 4398
  w_label := 'e117';
	--Start Add 8020--
	/* w_ptbm.total_bal and w_ptbm.total_due_amnt have repaire charges included along with water*/
  g_wah_total_bal	    	:= nvl(w_ptbm.total_bal,0)      + nvl(w_rchl.agrv_hl_st_closing_bal_amnt,0);	--wah_total_bal				--water agency helploan total balance     --add 8020
  g_wah_total_due_amnt	:= nvl(w_ptbm.total_due_amnt,0) + nvl(w_rchl.agrv_hl_total_due_amnt,0); 			--wah_total_due_amnt	--water agency helploan total due amount  --add 8020
	--Start Del 8020D Make the autopay indicator on Call Center Inquiry dynamic.
  --begin
  --	select decode(max(pain.code_value_ind),'ELECTBIL','Y',null)
  --	  into w_ptbm.ebill_ind --g_ebill_ind
	--	    from cis.phl_acct_ind pain
	--	   where pain.acct_key      = w_ptbm.acct_key
	--	     and pain.code_type_ind = 'BDELMETH'
	--	     and trunc(w_ptbm.billing_date) between pain.from_Date and nvl(pain.upto_date,trunc(sysdate)+1);
  --exception
  --   when no_data_found then
  --   		w_ptbm.ebill_ind := NULL;
  --   when others then
  --   		w_ptbm.ebill_ind := NULL;
  --end;
  ----if nvl(g_bill_delivery_meth,'N') = 'ELECTBIL' then g_ebill_ind := 'Y'; else g_ebill_ind := NULL; end if;
	----End Add 8020--
  --
	----Start Add 9454
  --begin
  --	select decode(max(pain.code_value_ind),'YES','Y',null)
  --	  into w_ptbm.ebill_auto_pay_ind --AUTPYIND
	--	  from cis.phl_acct_ind pain
	--	 where pain.acct_key      = w_ptbm.acct_key
  --     and pain.code_type_ind = 'AUTPYIND'
	--     and trunc(w_ptbm.billing_date) between pain.from_Date and nvl(pain.upto_date,trunc(sysdate)+1);
  --exception
  --   when no_data_found then
  --   		w_ptbm.ebill_auto_pay_ind := NULL;
  --   when others then
  --   		w_ptbm.ebill_auto_pay_ind := NULL;
  --end;
	----End Add 9454
	--End Del 8020D Make the autopay indicator on Call Center Inquiry dynamic.
	--Start Del 8020F Needs to be before PHLS0005 other wise bill messages will be wrong
	--Start Add 8020D Make the autopay indicator on Call Center Inquiry dynamic.
	--begin
	--
	--	phls0250.get_ebill_inds(p_acct_key=>w_ptbm.acct_key);
  --
	--	begin
	--		select decode(instr(phls0250.get_ebill_ind,'YES'),0,'N','Y') into w_ptbm.ebill_ind from dual;
	--	exception
	--		when no_data_found then
	--			 w_ptbm.ebill_ind := NULL;
	--	end;
  --
	--	begin
	--
	--		g_auto_pay_4all_acs 			:= null;
	--		w_ptbm.ebill_auto_pay_ind	:= null;
	--
	--	  select trim(substr(phls0250.get_auto_pay_ind,1,15)) into g_auto_pay_4all_acs from dual; --Passed to message routime phls0005
	--
	--		select decode(instr(phls0250.get_auto_pay_ind,'YES'),0,'N','Y') into w_ptbm.ebill_auto_pay_ind from dual; --Passed to Bill file
	--
	--	exception
	--		when no_data_found then
	--			 w_ptbm.ebill_auto_pay_ind := NULL;
	--			 g_auto_pay_4all_acs			 := NULL;
	--	end;
  --
	--exception
	--	when others then
	--		 w_ptbm.ebill_ind 					:= NULL;
	--		 w_ptbm.ebill_auto_pay_ind	:= NULL;
	--end;
	----Start End 8020D Make the autopay indicator on Call Center Inquiry dynamic.
	--End Del 8020F
	--Start Add 8020F
	  --Duplicate bill supersedes rebill and final bill
	  --and rebill supersedes final bill
	  --So it will be D > R > F
    w_label := 'e118';
    if g_trn_ifce_refn is not null and g_trn_scnd_type	= 'BIL' then g_rebill_bill_ind := 'Y'; end if;
    if w_ptbm.dup_ind is null and g_final_bill_ind = 'Y' then
       w_ptbm.dup_ind := 'F';
    end if;
    if nvl(w_ptbm.dup_ind,'F') = 'F' and g_rebill_bill_ind = 'Y' then
       w_ptbm.dup_ind := 'R';
    end if;
    w_label := 'e119';
	--End Add 8020F
	--Start Add 10846
	debug_trace(w_procedure_name,'<gp_dont_need_dup_id>' || booleanc(gp_dont_need_dup_id));
	debug_trace(w_procedure_name,'<w_process_id>' || w_process_id);
	if gp_dont_need_dup_id and w_process_id < 0 then  --Only for testing purpose we can use this variable only from testharness
		 w_ptbm.dup_ind := NULL;
  end if;
	--End Add 10846
  -- Start Add 9918
  w_label := 'e120';
  debug_trace(w_procedure_name,'...w_ptbm.next_wtr_auto_pay_amnt     ...' || w_ptbm.next_wtr_auto_pay_amnt );
  debug_trace(w_procedure_name,'...g_wtr_total_due_amnt              ...' ||g_wtr_total_due_amnt);
  debug_trace(w_procedure_name,'...w_rchl.agrv_hl_total_due_amnt     ...'|| w_rchl.agrv_hl_total_due_amnt);
  debug_trace(w_procedure_name,'...w_ptbm.next_hlp_auto_pay_amnt     ...'|| w_ptbm.next_hlp_auto_pay_amnt);
  debug_trace(w_procedure_name,'...w_rchl.agrv_rc_st_closing_bal_amnt...'|| w_rchl.agrv_rc_st_closing_bal_amnt);
  debug_trace(w_procedure_name,'...w_ptbm.next_agn_auto_pay_amnt     ...'|| w_ptbm.next_agn_auto_pay_amnt);
  debug_trace(w_procedure_name,'...is Water Auto Auto ...' || g_is_wtr_auto_auto );
  if nvl(g_is_wtr_auto_auto,0) > 0 then
    w_label := 'e121';
	  if w_ptbm.next_wtr_auto_pay_amnt is not null then
    	 w_label := 'e122';
	     if (nvl(g_wtr_total_due_amnt,0) - nvl(w_ptbm.next_wtr_auto_pay_amnt,0)) <= 0 then
    	 		w_label := 'e123';
	     		w_ptbm.next_wtr_auto_pay_amnt := 0;
	     else
    	 		w_label := 'e124';
	  	 		w_ptbm.next_wtr_auto_pay_amnt := nvl(g_wtr_total_due_amnt,0) - nvl(w_ptbm.next_wtr_auto_pay_amnt,0);
	  	 end if;
	  elsif w_ptbm.next_wtr_auto_pay_amnt is null  then
    	 w_label := 'e125';
	     w_ptbm.next_wtr_auto_pay_amnt := g_wtr_total_due_amnt;
	  end if;
	end if;
  debug_trace(w_procedure_name,'...Aftr w_ptbm.next_wtr_auto_pay_amnt     ...' || w_ptbm.next_wtr_auto_pay_amnt );
  debug_trace(w_procedure_name,'...is Help Auto Auto  ...' || g_is_hlp_auto_auto );
  if nvl(g_is_hlp_auto_auto,0) > 0 then
    w_label := 'e126';
	  if w_ptbm.next_hlp_auto_pay_amnt is not null  then
    	 w_label := 'e127';
	     if (nvl(w_rchl.agrv_hl_total_due_amnt,0) - nvl(w_ptbm.next_hlp_auto_pay_amnt,0)) <= 0 then
    	 	  w_label := 'e128';
	     		w_ptbm.next_hlp_auto_pay_amnt := 0;
	     else
    	 	  w_label := 'e129';
	     		w_ptbm.next_hlp_auto_pay_amnt := nvl(w_rchl.agrv_hl_total_due_amnt,0) - nvl(w_ptbm.next_hlp_auto_pay_amnt,0);
	     end if;
	  elsif w_ptbm.next_hlp_auto_pay_amnt is null then
    	 w_label := 'e130';
	     w_ptbm.next_hlp_auto_pay_amnt := w_rchl.agrv_hl_total_due_amnt;
	  end if;
	end if;
  debug_trace(w_procedure_name,'...Aftr w_rchl.agrv_hl_total_due_amnt     ...'|| w_rchl.agrv_hl_total_due_amnt);
  debug_trace(w_procedure_name,'...is Agency Auto Auto...' || g_is_agn_auto_auto );
  if nvl(g_is_agn_auto_auto,0) > 0 then
    w_label := 'e131';
	  if w_ptbm.next_agn_auto_pay_amnt is not null  then
    	 w_label := 'e132';
	     if (nvl(w_rchl.agrv_rc_st_closing_bal_amnt,0) - nvl(w_ptbm.next_agn_auto_pay_amnt,0)) <= 0 then
    			w_label := 'e133';
	        w_ptbm.next_agn_auto_pay_amnt := 0;
	     else
    			w_label := 'e134';
	        w_ptbm.next_agn_auto_pay_amnt := nvl(w_rchl.agrv_rc_st_closing_bal_amnt,0) - nvl(w_ptbm.next_agn_auto_pay_amnt,0);
	     end if;
	  elsif w_ptbm.next_agn_auto_pay_amnt is null then
    	 w_label := 'e135';
	     w_ptbm.next_agn_auto_pay_amnt := w_rchl.agrv_rc_st_closing_bal_amnt;
	  end if;
	end if;
  debug_trace(w_procedure_name,'...Aftr w_ptbm.next_agn_auto_pay_amnt     ...'|| w_ptbm.next_agn_auto_pay_amnt);
  -- End Add 9918
	--Start Moved up by 9984B
	if nvl(w_pay_profile_code_orig,'X') = 'TAP-STD' then
	  --Start Add 9984
	  if w_ptbm.tap_pnlty_frgv_dt is not null and w_ptbm.tap_pnlty_frgv_amnt is not null then
	     g_tap_pnlty_frgv_mssg := 'On '|| trim(to_char(w_ptbm.tap_pnlty_frgv_dt,'mm/dd/yyyy')) || ' you earned ' || trim(to_char(w_ptbm.tap_pnlty_frgv_amnt,'$99,999,990.99')) ||' in TAP penalty forgiveness.';
	  end if;
	  if w_ptbm.tap_prin_frgv_dt is not null and w_ptbm.tap_prin_frgv_amnt is not null then
	     g_tap_prin_frgv_mssg := 'On '|| trim(to_char(w_ptbm.tap_prin_frgv_dt,'mm/dd/yyyy')) || ' you earned ' || trim(to_char(w_ptbm.tap_prin_frgv_amnt,'$99,999,990.99')) ||' in TAP principal forgiveness.';
	  end if;
	  --End Add 9984
	end if;
	--End Moved up by 9984B
	--Start add 10846
	if w_rchl.agrv_bkgrnd_prnt_string is null then
		w_rchl.agrv_bkgrnd_prnt_string := get_agrv_null_prnt_string;
	end if;
	--End add 10846
  w_ptbm.background_print_string :=
                           w_ptbm.bill_key                                                     --BILL_KEY / Bill Number                                                               --BILL_KEY
        || '|' ||  datefullc(w_ptbm.billing_date)                                              --Billing Date                                                                         --BILLING_DATE      --Chg 3706
        || '|' ||  datefullc(w_ptbm.incl_payments_date)                                        --Inclusing Payments till this date                                                    --INCL_PAYMENTS_DATE
        || '|' ||  datefullc(w_ptbm.payment_due_date)                                          --Payment Due Date                                                                     --PAYMENT_DUE_DATE  --Chg 3706
        || '|' ||          w_ptbm.acct_key                                                     --Account Key (Customer Account Number in Basis2)                                      --ACCT_KEY
        || '|' ||          w_ptbm.bill_account_number                                          --Bill Account Number (Water1 Account)                                                 --BILL_ACCOUNT_NUMBER
        || '|' ||          substr(w_ptbm.cust_name,1,30)                                       --Customer Name                                                                        --CUST_NAME
        || '|' ||          w_ptbm.cust_type_code                                               --Customer Type Code                                                                   --CUST_TYPE_CODE
        || '|' ||          w_ptbm.inst_type_code                                               --Installation Type Code                                                               --INST_TYPE_CODE
        || '|' ||          w_ptbm.pays_by_zipcheck                                             --Zipcheck indicator                                                                   --PAYS_BY_ZIPCHECK
        || '|' ||          w_ptbm.mail_name                                                    --Mailing Name for Customer                                                            --MAIL_NAME
        || '|' ||          w_ptbm.mail_addr_line1                                              --Mail Address Line1 (it might have C/O name some times)                               --MAIL_ADDR_LINE1
        || '|' ||          w_ptbm.mail_addr_line2                                              --Mail Address Line2                                                                   --MAIL_ADDR_LINE2
        || '|' ||          w_ptbm.mail_addr_line3                                              --Mail Address Line3                                                                   --MAIL_ADDR_LINE3
        || '|' ||          w_ptbm.mail_addr_line4                                              --MaiMaill Address Line4                                                                   --MAIL_ADDR_LINE4
        || '|' ||          w_ptbm.mail_addr_line5                                              -- Address Line5                                                                   --MAIL_ADDR_LINE5
        || '|' ||          w_ptbm.mail_postal_code                                             --Postal Code (Zip Code)                                                               --MAIL_POSTAL_CODE
        || '|' ||          w_ptbm.mail_postal_barcode                                          --POSTAL Barcode (with delivery points)                                                --MAIL_POSTAL_BARCODE
        || '|' ||          w_ptbm.inst_addr_line1                                              --Installation Address only (House No Street No Street Name)                           --INST_ADDR_LINE1
        || '|' ||          w_ptbm.meter_key                                                    --Meter Key                                                                            --METER_KEY
        || '|' ||          w_ptbm.srvc_size_code                                               --Service Size Code for Current Meter                                                  --SRVC_SIZE_CODE
        || '|' ||          w_ptbm.bill_service                                                 --Bill Service Code for Current Meter                                                  --BILL_SERVICE
        || '|' ||  datefullc(w_ptbm.reading_from_date)                                         --Reading From Date for Current Meter                                                  --READING_FROM_DATE --Chg 3706
        || '|' ||  datefullc(w_ptbm.reading_upto_date)                                         --Reading UPTO Date for Current Meter                                                  --READING_UPTO_DATE --Chg 3706
        || '|' ||  to_char(w_ptbm.last_billed_reading)                                         --Last Bill Reading for Current Meter                                                  --LAST_BILLED_READING
        || '|' ||  to_char(w_ptbm.this_billed_reading)                                         --Current Bill Reading for Current Meter                                               --THIS_BILLED_READING
        || '|' ||  to_char(w_ptbm.billed_qty)                                                  --Billed Quantity (Consumption) for Current Meter                                      --BILLED_QTY
        || '|' ||          w_ptbm.repl_meter_key                                               --Replaced Meter Key                                                                   --REPL_METER_KEY
        || '|' ||          w_ptbm.repl_srvc_size_code                                          --Service Size Code for Replaced Meter                                                 --REPL_SRVC_SIZE_CODE
        || '|' ||          w_ptbm.repl_bill_service                                            --Bill Service Code for Replaced Meter                                                 --REPL_BILL_SERVICE
        || '|' ||  datefullc(w_ptbm.repl_reading_from_date)                                    --Reading From Date for Replaced Meter                                                 --REPL_RDG_FROM_DATE --Chg 3706
        || '|' ||  datefullc(w_ptbm.repl_reading_upto_date)                                    --Reading UPTO Date for Replaced Meter                                                 --REPL_RDG_UPTO_DATE --Chg 3706
        || '|' ||  to_char(w_ptbm.repl_last_billed_reading)                                    --Last Bill Reading for Replaced Meter                                                 --REPL_LAST_BILLED_RDG
        || '|' ||  to_char(w_ptbm.repl_this_billed_reading)                                    --Current Bill Reading for Replaced Meter                                              --REPL_THIS_BILLED_RDG
        || '|' ||  to_char(w_ptbm.repl_billed_qty)                                             --Billed Quantity (Consumption) for Replaced Meter                                     --REPL_BILLED_QTY
        || '|' ||  trim(to_char(nvl(w_ptbm.previous_balance_amnt,0),'$99,999,990.00'))         --Previous Balance Amount                                                              --PREVIOUS_BALANCE_AMNT--Right Side
        || '|' ||  trim(to_char(nvl(w_ptbm.subtot_curr_chgs,0),'$99,999,990.00'))              --Subtotal of Current Charge                                                           --CURRENT_CHARGE_AMNT --SUBTOT_CURR_CHGS --Right Side-- Chg from w_ptbm.current_charge_amnt to SUBTOT_CURR_CHGS -->CURRENT_CHARGE_AMNT
        || '|' ||  trim(to_char(w_ptbm.usage_charge_amnt  ,'$99,999,990.00'))                  --Usage Charge Amount                                                                  --USG_CHARGE_AMNT  --Left Side
        || '|' ||  trim(to_char(w_ptbm.service_charge_amnt,'$99,999,990.00'))                  --Service Charge Amount                                                                --SVC_CHARGE_AMNT  --Left Side
        || '|' ||  trim(w_ptbm.discount_lbl)                                                   --Discount Label                                                                       --DISCOUNT_LABEL
        || '|' ||  trim(to_char(w_ptbm.discount_amnt,'$99,999,990.00'))                        --Discount Amount                                                                      --DISCOUNT_AMNT
        || '|' ||  datec(w_lst_pymnt_dt)                                                       --Last Paid Date                                                                       --LAST_PAID_DATE  --Chng 4398 (variable change)
        || '|' ||  trim(to_char(w_ptbm.last_paid_amnt,'$99,999,990.00'))                       --Last Paid Amount                                                                     --LAST_PAID_AMNT--Left Side
        || '|' ||  trim(to_char(w_ptbm.total_due_amnt,'$99,999,990.00'))                       --Please Pay Now TOTAL_DUE_AMNT                                                        --TOTAL_DUE_AMNT
        || '|' ||  trim(to_char(w_ptbm.penalty_amnt,'$99,999,990.00'))                         --Penalty Amount           [On Payment Stub]                                           --PENALTY_AMNT
        || '|' ||  trim(to_char(w_ptbm.penalty_due_amnt,'$99,999,990.00'))                     --Penalty Due Amount       [On Payment Stub]                                           --PENALTY_DUE_AMNT
        || '|' ||  date3chrmnth(w_ptbm.penalty_date)                                           --Penalty Date             [On Payment Stub]                                           --PENALTY_DATE  --3month Date Format
        || '|' ||  w_ptbm.scan_string                                                          --Scan Line String                                                                     --SCAN_STRING
        || '|' ||  trim(w_ptbm.hdr_mesg_1)                                                     --HDR_MESG_1                                                                           --HDR_MESG_1
        || '|' ||  trim(w_ptbm.hdr_mesg_2)                                                     --HDR_MESG_2                                                                           --HDR_MESG_2
        || '|' ||  trim(w_ptbm.hdr_mesg_3)                                                     --HDR_MESG_3                                                                           --HDR_MESG_3
        || '|' ||  trim(w_ptbm.hdr_mesg_4)                                                     --HDR_MESG_4                                                                           --HDR_MESG_4
        || '|' ||  trim(w_ptbm.message_1)                                                      --Bill Message1                                                                        --MESSAGE_1
        || '|' ||  trim(w_ptbm.message_2)                                                      --Bill Message2                                                                        --MESSAGE_2
        || '|' ||  trim(w_ptbm.message_3)                                                      --Bill Message3                                                                        --MESSAGE_3
        || '|' ||  trim(w_ptbm.Message_4)                                                      --Bill Message4                                                                        --MESSAGE_4
        || '|' ||  trim(w_ptbm.grph_mesg1)                                                     --Graph Message1                                                                       --GRPH_MESG1
        || '|' ||  trim(w_char_billed_qty_01)                                                  --Graph Qty for Month 24                                                               --BQTY_01 --Chng 3908 was  to_char(w_ptbm.billed_qty_01)
        || '|' ||  trim(w_char_billed_qty_02)                                                  --Graph Qty for Month 23                                                               --BQTY_02 --Chng 3908 was  to_char(w_ptbm.billed_qty_02)
        || '|' ||  trim(w_char_billed_qty_03)                                                  --Graph Qty for Month 22                                                               --BQTY_03 --Chng 3908 was  to_char(w_ptbm.billed_qty_03)
        || '|' ||  trim(w_char_billed_qty_04)                                                  --Graph Qty for Month 21                                                               --BQTY_04 --Chng 3908 was  to_char(w_ptbm.billed_qty_04)
        || '|' ||  trim(w_char_billed_qty_05)                                                  --Graph Qty for Month 20                                                               --BQTY_05 --Chng 3908 was  to_char(w_ptbm.billed_qty_05)
        || '|' ||  trim(w_char_billed_qty_06)                                                  --Graph Qty for Month 19                                                               --BQTY_06 --Chng 3908 was  to_char(w_ptbm.billed_qty_06)
        || '|' ||  trim(w_char_billed_qty_07)                                                  --Graph Qty for Month 18                                                               --BQTY_07 --Chng 3908 was  to_char(w_ptbm.billed_qty_07)
        || '|' ||  trim(w_char_billed_qty_08)                                                  --Graph Qty for Month 17                                                               --BQTY_08 --Chng 3908 was  to_char(w_ptbm.billed_qty_08)
        || '|' ||  trim(w_char_billed_qty_09)                                                  --Graph Qty for Month 16                                                               --BQTY_09 --Chng 3908 was  to_char(w_ptbm.billed_qty_09)
        || '|' ||  trim(w_char_billed_qty_10)                                                  --Graph Qty for Month 15                                                               --BQTY_10 --Chng 3908 was  to_char(w_ptbm.billed_qty_10)
        || '|' ||  trim(w_char_billed_qty_11)                                                  --Graph Qty for Month 14                                                               --BQTY_11 --Chng 3908 was  to_char(w_ptbm.billed_qty_11)
        || '|' ||  trim(w_char_billed_qty_12)                                                  --Graph Qty for Month 13                                                               --BQTY_12 --Chng 3908 was  to_char(w_ptbm.billed_qty_12)
        || '|' ||  trim(w_char_billed_qty_13)                                                  --Graph Qty for Month 12                                                               --BQTY_13 --Chng 3908 was  to_char(w_ptbm.billed_qty_13)
        || '|' ||  trim(w_char_billed_qty_14)                                                  --Graph Qty for Month 11                                                               --BQTY_14 --Chng 3908     --Add 3706
        || '|' ||  trim(w_char_billed_qty_15)                                                  --Graph Qty for Month 10                                                               --BQTY_15 --Chng 3908     --Add 3706
        || '|' ||  trim(w_char_billed_qty_16)                                                  --Graph Qty for Month 9                                                                --BQTY_16 --Chng 3908     --Add 3706
        || '|' ||  trim(w_char_billed_qty_17)                                                  --Graph Qty for Month 8                                                                --BQTY_17 --Chng 3908     --Add 3706
        || '|' ||  trim(w_char_billed_qty_18)                                                  --Graph Qty for Month 7                                                                --BQTY_18 --Chng 3908     --Add 3706
        || '|' ||  trim(w_char_billed_qty_19)                                                  --Graph Qty for Month 6                                                                --BQTY_19 --Chng 3908     --Add 3706
        || '|' ||  trim(w_char_billed_qty_20)                                                  --Graph Qty for Month 5                                                                --BQTY_20 --Chng 3908     --Add 3706
        || '|' ||  trim(w_char_billed_qty_21)                                                  --Graph Qty for Month 4                                                                --BQTY_21 --Chng 3908     --Add 3706
        || '|' ||  trim(w_char_billed_qty_22)                                                  --Graph Qty for Month 3                                                                --BQTY_22 --Chng 3908     --Add 3706
        || '|' ||  trim(w_char_billed_qty_23)                                                  --Graph Qty for Month 2                                                                --BQTY_23 --Chng 3908     --Add 3706
        || '|' ||  trim(w_char_billed_qty_24)                                                  --Graph Qty for Month 1                                                                --BQTY_24 --Chng 3908     --Add 3706
        || '|' ||  w_ptbm.blbl_01                                                              --Graph Label  for Month 24                                                            --BLBL_01
        || '|' ||  w_ptbm.blbl_02                                                              --Graph Label  for Month 23                                                            --BLBL_02
        || '|' ||  w_ptbm.blbl_03                                                              --Graph Label  for Month 22                                                            --BLBL_03
        || '|' ||  w_ptbm.blbl_04                                                              --Graph Label  for Month 21                                                            --BLBL_04
        || '|' ||  w_ptbm.blbl_05                                                              --Graph Label  for Month 20                                                            --BLBL_05
        || '|' ||  w_ptbm.blbl_06                                                              --Graph Label  for Month 19                                                            --BLBL_06
        || '|' ||  w_ptbm.blbl_07                                                              --Graph Label  for Month 18                                                            --BLBL_07
        || '|' ||  w_ptbm.blbl_08                                                              --Graph Label  for Month 17                                                            --BLBL_08
        || '|' ||  w_ptbm.blbl_09                                                              --Graph Label  for Month 16                                                            --BLBL_09
        || '|' ||  w_ptbm.blbl_10                                                              --Graph Label  for Month 15                                                            --BLBL_10
        || '|' ||  w_ptbm.blbl_11                                                              --Graph Label  for Month 14                                                            --BLBL_11
        || '|' ||  w_ptbm.blbl_12                                                              --Graph Label  for Month 13                                                            --BLBL_12
        || '|' ||  w_ptbm.blbl_13                                                              --Graph Label  for Month 12                                                            --BLBL_13
        || '|' ||  w_ptbm.blbl_14                                                              --Graph Label  for Month 11                                                            --BLBL_14                 --Add 3706
        || '|' ||  w_ptbm.blbl_15                                                              --Graph Label  for Month 10                                                            --BLBL_15                 --Add 3706
        || '|' ||  w_ptbm.blbl_16                                                              --Graph Label  for Month 9                                                             --BLBL_16                 --Add 3706
        || '|' ||  w_ptbm.blbl_17                                                              --Graph Label  for Month 8                                                             --BLBL_17                 --Add 3706
        || '|' ||  w_ptbm.blbl_18                                                              --Graph Label  for Month 7                                                             --BLBL_18                 --Add 3706
        || '|' ||  w_ptbm.blbl_19                                                              --Graph Label  for Month 6                                                             --BLBL_19                 --Add 3706
        || '|' ||  w_ptbm.blbl_20                                                              --Graph Label  for Month 5                                                             --BLBL_20                 --Add 3706
        || '|' ||  w_ptbm.blbl_21                                                              --Graph Label  for Month 4                                                             --BLBL_21                 --Add 3706
        || '|' ||  w_ptbm.blbl_22                                                              --Graph Label  for Month 3                                                             --BLBL_22                 --Add 3706
        || '|' ||  w_ptbm.blbl_23                                                              --Graph Label  for Month 2                                                             --BLBL_23                 --Add 3706
        || '|' ||  w_ptbm.blbl_24                                                              --Graph Label  for Month 1                                                             --BLBL_24                 --Add 3706
        || '|' ||  w_ptbm.bflg_01                                                              --Graph Estimate Flag for Month 24                                                     --BFLG_01
        || '|' ||  w_ptbm.bflg_02                                                              --Graph Estimate Flag for Month 23                                                     --BFLG_02
        || '|' ||  w_ptbm.bflg_03                                                              --Graph Estimate Flag for Month 22                                                     --BFLG_03
        || '|' ||  w_ptbm.bflg_04                                                              --Graph Estimate Flag for Month 21                                                     --BFLG_04
        || '|' ||  w_ptbm.bflg_05                                                              --Graph Estimate Flag for Month 20                                                     --BFLG_05
        || '|' ||  w_ptbm.bflg_06                                                              --Graph Estimate Flag for Month 19                                                     --BFLG_06
        || '|' ||  w_ptbm.bflg_07                                                              --Graph Estimate Flag for Month 18                                                     --BFLG_07
        || '|' ||  w_ptbm.bflg_08                                                              --Graph Estimate Flag for Month 17                                                     --BFLG_08
        || '|' ||  w_ptbm.bflg_09                                                              --Graph Estimate Flag for Month 16                                                     --BFLG_09
        || '|' ||  w_ptbm.bflg_10                                                              --Graph Estimate Flag for Month 15                                                     --BFLG_10
        || '|' ||  w_ptbm.bflg_11                                                              --Graph Estimate Flag for Month 14                                                     --BFLG_11
        || '|' ||  w_ptbm.bflg_12                                                              --Graph Estimate Flag for Month 13                                                     --BFLG_12
        || '|' ||  w_ptbm.bflg_13                                                              --Graph Estimate Flag for Month 12                                                     --BFLG_13
        || '|' ||  w_ptbm.bflg_14                                                              --Graph Estimate Flag for Month 11                                                     --BFLG_14                 --Add 3706
        || '|' ||  w_ptbm.bflg_15                                                              --Graph Estimate Flag for Month 10                                                     --BFLG_15                 --Add 3706
        || '|' ||  w_ptbm.bflg_16                                                              --Graph Estimate Flag for Month 9                                                      --BFLG_16                 --Add 3706
        || '|' ||  w_ptbm.bflg_17                                                              --Graph Estimate Flag for Month 8                                                      --BFLG_17                 --Add 3706
        || '|' ||  w_ptbm.bflg_18                                                              --Graph Estimate Flag for Month 7                                                      --BFLG_18                 --Add 3706
        || '|' ||  w_ptbm.bflg_19                                                              --Graph Estimate Flag for Month 6                                                      --BFLG_19                 --Add 3706
        || '|' ||  w_ptbm.bflg_20                                                              --Graph Estimate Flag for Month 5                                                      --BFLG_20                 --Add 3706
        || '|' ||  w_ptbm.bflg_21                                                              --Graph Estimate Flag for Month 4                                                      --BFLG_21                 --Add 3706
        || '|' ||  w_ptbm.bflg_22                                                              --Graph Estimate Flag for Month 3                                                      --BFLG_22                 --Add 3706
        || '|' ||  w_ptbm.bflg_23                                                              --Graph Estimate Flag for Month 2                                                      --BFLG_23                 --Add 3706
        || '|' ||  w_ptbm.bflg_24                                                              --Graph Estimate Flag for Month 1                                                      --BFLG_24                 --Add 3706
        || '|' ||  trim(to_char(w_ptbm.billed_yy_01,'0000'))                                   --Graph 13th from Current Months Year                                                  --BILLED_YY_01            --Add 3706
        || '|' ||  trim(to_char(w_ptbm.adjust,'$99,999,990.00'))                               --Total Adjustments                                                                    --ADJUST
        || '|' ||  trim(to_char(w_ptbm.lien,'$99,999,990.00'))                                 --Lien Charge                                                                          --LIEN
        || '|' ||  trim(w_char_stormchg)                                                       --Stormwater Charge                                                                    --STORMCHG                --Add 3327
        || '|' ||  trim(to_char(w_ptbm.induschg,'$99,999,990.00'))                             --Insudtrial Surcharge                                                                 --INDUSCHG
        || '|' ||  trim(to_char(w_ptbm.pymtagree,'$99,999,990.00'))                            --Payment Agreement Amount to Pay                                                      --PYMTAGREE
        || '|' ||  w_ptbm.est_last_rdg_flag                                                    --Estimate Flag for Meter Last  Read                                                   --EST_LAST_RDG_FLAG
        || '|' ||  w_ptbm.est_this_rdg_flag                                                    --Estimate Flag for Meter Current Read                                                 --EST_THIS_RDG_FLAG
        || '|' ||  w_ptbm.est_repl_last_rdg_flag                                               --Estimate Flag for Replaced Meter Last  Read                                          --EST_REPL_LAST_RDG_FLAG
        || '|' ||  w_ptbm.est_repl_this_rdg_flag                                               --Estimate Flag for Replaced Meter Current Read                                        --EST_REPL_THIS_RDG_FLAG
        || '|' ||  trim(to_char(w_ptbm.wrbcccred,'$99,999,990.00'))                            --WRBCC Credit                                                                         --WRBCCCRED
        || '|' ||  trim(to_char(w_ptbm.wrbccpmt,'$99,999,990.00'))                             --WRBCC Payment                                                                        --WRBCCPMT
        || '|' ||  trim(to_char(w_ptbm.late_pmt_penalty,'$99,999,990.00'))                     --Late Payment Penalty                                                                 --LATE_PMT_PENALTY
        || '|' ||  trim(to_char(nvl(w_ptbm.tot_pays_adjs,0),'$99,999,990.00'))                 --Payment Adjustment Total                                                             --PAY_ADJ_TOTAL
        || '|' ||  trim(to_char(nvl(w_ptbm.total_bal,0),'$99,999,990.00'))                     --Total Balance  Water + Agency Account Balance                                                                        --TOTAL_BAL               --Mod 2.0.0.09  from w_ptbm.total_due_amnt to w_ptbm.total_bal
        || '|' ||  w_ptbm.ert_key                                                              --ERT Key                                                                              --ERT_KEY
        || '|' ||  w_ptbm.repl_ert_key                                                         --Replace Meter ERT Key                                                                --REPL_ERT_KEY
        || '|' ||  trim(to_char(w_ptbm.tot_cred,'$99,999,990.00'))                             --Total Credit                                                                         --TOT_CRED                --Add 2402
        || '|' ||  trim(substr(w_ptbm.imb,1,20))                                               --Inteligent Mailing Bar Code Tracking Number                                          --IMB_TRACKING            --Add 3409A--Add trim
        || '|' ||  trim(substr(w_ptbm.imb,21,11))                                              --Inteligent Mailing Bar Code Routing Number                                           --IMB_ROUTING             --Add 3409A--Add trim
        --|| '|' ||  trim(to_char(w_ptbm.nus_chrg,'$99,999,990.00'))                           --3rd Party Receivables Nusiance Charges                                               --NUS_CHRG                --Del 7164D--Add 3706
        || '|' ||  NULL                                                                        --w_ptbm.nus_chrg RENAMED TO TAP_PYM_2_ARRS_2ND                                                                  --Add 7164D--Add 3706
        --|| '|' ||  trim(to_char(w_ptbm.mtr_chrg,'$99,999,990.00'))                           --3rd Party Receivables Meter Charges                                                --MTR_CHRG                --Del 7164D--Add 3706
        || '|' ||  NULL                                                                        --w_ptbm.mtr_chrg will be renamed to DISP_PRE_TAP                                                                                       --Add 7164D--Add 3706
        --|| '|' ||  trim(to_char(w_ptbm.hlp_loan,'$99,999,990.00'))                           --3rd Party Receivables Help Loan                                                    --HLP_LOAN                --Del 7164D--Add 3706
        || '|' ||  NULL                                                                        --w_ptbm.hlp_loan will be renamed to DISP_POST_TAP                                                              --Add 7164D--Add 3706
        || '|' ||  datec(w_ptbm.sw_chg_fr_dt)                                                  --Storm water Charge From Date                                                         --STRM_WTR_CHG_FR_DT      --Add 3659
        || '|' ||  datec(w_ptbm.sw_chg_to_dt)                                                  --Stormwater Charge TO Date                                                            --STRM_WTR_CHG_TO_DT      --Add 3659
        || '|' ||  trim(to_char(w_ptbm.fire_srvc_chg_amnt,'$99,999,990.00'))                   --Fire Service Charge Amount                                                           --FIRE_SRVC_CHG_AMNT      --Add 3127
        || '|' ||  datec(w_ptbm.fir_srv_chg_fr_dt)                                             --Fire Service Charge From Date                                                        --FIR_SRV_CHG_FR_DT       --Add 3706
        || '|' ||  datec(w_ptbm.fir_srv_chg_to_dt)                                             --Fire Service Charge upto Date                                                        --FIR_SRV_CHG_TO_DT       --Add 3706
        || '|' ||  trim(to_char(w_ptbm.agr_dt,'Month DD, YYYY'))                               --Agreement Start Date                                                                 --AGR_DT                  --Add 3706
        || '|' ||  trim(to_char(w_ptbm.agr_amnt,'$99,999,990.00'))                             --Total Agrement Amount                                                                --AGR_AMNT                --Add 3706
        || '|' ||  datefullc(w_ptbm.agr_downpym_dt)                                            --Payment Plan Agreement Downpayment Date                                              --AGR_DOWNPYM_DT          --Add 3706
        || '|' ||  trim(to_char(w_ptbm.agr_downpym_amnt,'$99,999,990.00'))                     --Payment Plan Agreement Downpayment                                                   --AGR_DOWNPYM_AMNT        --Add 3706
        || '|' ||  datefullc(w_ptbm.agr_1stpym_dt)                                             --Payment Plan Agreement 1st Installment Date                                          --AGR_1STPYM_DT           --Add 3706
        || '|' ||  trim(to_char(w_ptbm.agr_1stpym_amnt,'$99,999,990.00'))                      --Payment Plan Agreement 1st Installment Amount                                        --AGR_1STPYM_AMNT         --Add 3706
        || '|' ||  datefullc(w_ptbm.agr_2ndpym_dt)                                             --Payment Plan Agreement 2nd Installment Date                                          --AGR_2NDPYM_DT           --Add 3706
        || '|' ||  trim(to_char(w_ptbm.agr_2ndpym_amnt,'$99,999,990.00'))                      --Payment Plan Agreement 2nd Installment Amount                                        --AGR_2NDPYM_AMNT         --Add 3706
        || '|' ||  datefullc(w_ptbm.agr_3rdpym_dt)                                             --Payment Plan Agreement 3rd Installment Date                                          --AGR_3RDPYM_DT           --Add 3706
        || '|' ||  trim(to_char(w_ptbm.agr_3rdpym_amnt,'$99,999,990.00'))                      --Payment Plan Agreement 3rd Installment Amount                                        --AGR_3RDPYM_AMNT         --Add 3706
        || '|' ||  datefullc(w_ptbm.agr_4thpym_dt)                                             --Payment Plan Agreement 4th Installment Date                                          --AGR_4THPYM_DT           --Add 3706
        || '|' ||  trim(to_char(w_ptbm.agr_4thpym_amnt,'$99,999,990.00'))                      --Payment Plan Agreement 4th Installment Amount                                        --AGR_4THPYM_AMNT         --Add 3706
        || '|' ||  datefullc(w_ptbm.agr_5thpym_dt)                                             --Payment Plan Agreement 5th Installment Date                                          --AGR_5THPYM_DT           --Add 3706
        || '|' ||  trim(to_char(w_ptbm.agr_5thpym_amnt,'$99,999,990.00'))                      --Payment Plan Agreement 5th Installment Amount                                        --AGR_5THPYM_AMNT         --Add 3706
        || '|' ||  datefullc(w_ptbm.agr_6thpym_dt)                                             --Payment Plan Agreement 6th Installment Date                                          --AGR_6THPYM_DT           --Add 3706
        || '|' ||  trim(to_char(w_ptbm.agr_6thpym_amnt,'$99,999,990.00'))                      --Payment Plan Agreement 6th Installment Amount                                        --AGR_6THPYM_AMNT         --Add 3706
        || '|' ||  datefullc(w_ptbm.agr_7thpym_dt)                                             --Payment Plan Agreement 7th Installment Date                                          --AGR_7THPYM_DT           --Add 3706
        || '|' ||  trim(to_char(w_ptbm.agr_7thpym_amnt,'$99,999,990.00'))                      --Payment Plan Agreement 7th Installment Amount                                        --AGR_7THPYM_AMNT         --Add 3706
        || '|' ||  trim(to_char(w_ptbm.agr_bal_amnt,'$99,999,990.00'))                         --Payment Plan Agreement Amount                                                        --AGR_BAL_AMNT            --Add 3706
        || '|' ||  w_ptbm.srvc_period                                                          --Service Period Range                                                                 --SRVC_PERIOD             --Add 3706
        || '|' ||  trim(to_char(w_ptbm.un_paid_prv_bal,'$99,999,990.00'))                      --Unpaid Previous Balance                                                              --UN_PAID_PRV_BAL         --Add 3706
        || '|' ||  trim(to_char(w_ptbm.gal_used_per_day))                                      --Current Meter Gallons Used Per Day                                                   --GAL_USED_PER_DAY        --Add 3706
        || '|' ||  trim(to_char(w_ptbm.repl_gal_used_per_day))                                 --Replaced Meter Gallons Used Per Day                                                  --REPL_GAL_USED_PER_DAY   --Add 3706
        || '|' ||  trim(substr(w_ptbm.inst_postal_code,1,5))                                   --Installation Address Zipcode                                                         --INST_POSTAL_CODE        --Add 3706
        || '|' ||  trim(w_bad_check_fee)                                                       --Bad Check Fee                                                                        --BAD_CHECK_FEE           --Add 3706
        || '|' ||  '' --trim(to_char(w_ptbm.debt_bal_amnt_cty,'$99,999,990.00'))               --Del 3706 --City Grant                                                                --CITY_GRANT              --Add 3706
        || '|' ||  '' --trim(to_char(w_ptbm.debt_bal_amnt_cri,'$99,999,990.00'))               --Del 3706 --CRISIS Grant                                                              --CRISIS_GRANT            --Add 3706
        || '|' ||  '' --trim(to_char(w_ptbm.debt_bal_amnt_lih,'$99,999,990.00'))               --Del 3706 --LIHEAP Grant                                                              --LIHEAP_GRANT            --Add 3706
        || '|' ||  '' --trim(to_char(w_ptbm.debt_bal_amnt_ues,'$99,999,990.00'))               --Del 3706 --USEF Grant                                                                --UESF_GRANT              --Add 3706
        || '|' ||  trim(to_char(w_ptbm.no_of_line_items))                                      --NO_OF_LINE_ITEMS                                                                     --NO_OF_LINE_ITEMS        --Add 3706
        || '|' ||  trim(to_char(w_ptbm.big_three_cnt,'99999990'))                              --BIG_THREE_CNT                                                                        --BIG_THREE_CNT           --Add 3706
        || '|' ||  trim(to_char(w_ptbm.othr_fees_crds_flg))                                    --OTHR_FEES_CRDS_FLG                                                                   --OTHR_FEES_CRDS_FLG      --Add 3706
        || '|' ||  trim(to_char(w_ptbm.sew_ren_fct_dis,'$99,999,990.00'))                      --Sewer Rental Factor Discount                                                         --SEW_REN_FCT_DIS         --Add 3706
        || '|' ||  trim(w_ptbm.surchg_flg)                                                     --surcharge flag                                                                       --SURCHG_FLG              --Add 3706
        || '|' ||  trim(to_char(w_ptbm.tot_bill_rdg,'99999990'))                               --total bill reading                                                                   --TOTAL BILL READING      --Add 3706
        || '|' ||  trim(substr(w_ptbm.grp_mssg_agr01,1,100))                                   --group message for payment agreements                                                 --GRP_MSSG_AGR01          --Add 3706
        || '|' ||  trim(to_char(w_ptbm.agr_othr_pymnts_amnt,'$99,999,990.00'))                 --agr_othr_pymnts_amnt                                                                 --AGR_OTHR_PYMNTS_AMNT    --Add 3706
        || '|' ||  trim(w_ptbm.dcr_fnt_sz_amnt_hdrs)                                           --dcr_fnt_sz_amnt_hdrs                                                                 --DCR_FNT_SZ_AMNT_HDRS    --Add 3706
        || '|' ||  date3chrmnth(w_ptbm.payment_due_date)                                       --3_mnt_pymnt_due_dt                                                                   --3MNTH_PYMNT_DUE_DT      --Chg 3706
        || '|' ||  trim(w_usg_line_hdng)                                                       --usg_line_hdng                                                                        --USG_LINE_HDNG           --Chg 3706
        || '|' ||  trim(w_cur_chg_solid_line_flg)                                              --cur_chg_solid_line_flg                                                               --CUR_CHG_SOLID_LINE_FLG  --Add 4608
        || '|' ||  trim(w_unpaid_bal_lbl)                                                      --unpaid_bal_lbl                                                                       --UNPAID_BAL_LBL          --Add 4575
        || '|' ||  trim(to_char(w_ptbm.tap_prv_unpaid_bl,'$99,999,990.00'))                    --TAP previous unpaid balance                                                          --TP_PRV_UNPAID_BL        --Add 6721
        || '|' ||  trim(to_char(w_ptbm.tap_disc,'$99,999,990.00'))                             --TAP Discount                                                                         --TP_DISC                 --Add 6230
        || '|' ||  trim(to_char(w_ptbm.tap_chg,'$99,999,990.00'))                              --TAP_Charge                                                                           --TP_CHG                  --Add 6230
        || '|' ||  trim(to_char(w_ptbm.tap_tot_act_usg_srv_chg,'$99,999,990.00'))              --Sum total charges from adjustment records for current continuous                     --TP_TOTUSSV_CHG          --Add 6230
        || '|' ||  trim(to_char(w_ptbm.tap_tot_chg_amnt,'$99,999,990.00'))                     --Difference between these two amounts above and below                                 --TP_TOT_CHG              --Add 6230
        || '|' ||  trim(to_char(w_ptbm.tap_tot_saved_amnt,'$99,999,990.00'))                   --Sum of the adjustment amounts for the same period                                    --TP_TOT_SAVD_AMNT        --Add 6230
        || '|' ||  trim(to_char(w_ptbm.tap_tot_past_due_paid_amnt,'$99,999,990.00'))           --Sum of all receipts (via allocation records) minus any TAP bills paid                --TP_TOT_PST_DU_PAID_AMNT --Add 6230  --TAP Bills Paid = Sum TAP bill total amount - Sum TAP bill balance
        || '|' ||  trim(to_char(w_ptbm.tap_ef_count,'99,999,990'))                             --Earned Penalty Forgiveness counter --EF_PAID_FACTOR from history view                                                     --TP_EF_CNT               --Add 6230
        || '|' ||  datec(w_ptbm.tap_recertify_date)                                            --Expected end date from the current TAP application                                   --TP_RCTFY_DT             --Add 6230
        || '|' ||  trim(to_char(w_ptbm.tap_pym_2_arrs,'$99,999,990.00'))                       --TAP Payments towards Arrears                                                         --TP_PYMS_2_ARRS          --Add 7055
        || '|' ||  trim(to_char(w_ptbm.pymagr_due_lbl))                                        --Payment Agreement Due Label                                                          --PYMAGR_DUE_LBL          --Add 7055
        || '|' ||  trim(to_char(w_ptbm.amnt_in_disp,'$99,999,990.00'))                         --Dispute Amount                                                                       --DISP_AMNT               --Add 7164D
        || '|' ||  trim(to_char(g_wtr_total_bal,'$99,999,990.00'))														 --water total balance																																	--WTR_TOTAL_BAL						--Add 8020
        || '|' ||  trim(to_char(g_wtr_total_due_amnt,'$99,999,990.00'))												 --water total due																																			--WTR_TOTAL_DUE_AMNT			--Add 8020
  			|| '|' ||  trim(to_char(g_wah_total_bal,'$99,999,990.00'))                         		 --Water Agency Helploan Total Balance     																							--WAH_TOTAL_BAL						--Add 8020
  			|| '|' ||  trim(to_char(g_wah_total_due_amnt,'$99,999,990.00'))                        --Water Agency Helploan Total Due Amount  																							--WAH_TOTAL_DUE_AMNT			--Add 8020
        || '|' ||  trim(w_ptbm.ebill_ind)																									 		 --Bill Delivery Method [eBilling indicator "Y" or NULL]																--EBILL_IND								--Add 8020
        || '|' ||  trim(to_char(w_ptbm.no_of_pages,'99,999,990'))                        		   --Number of Pages  																																		--NO_OF_PGS						    --Add 8020
        || '|' ||  trim(g_inst_city)																													 --City on Inst Address																																	--INST_CITY								--Add 8020
        || '|' ||  trim(g_inst_addr_id)																												 --Addr ID for Inst Address																															--INST_ADDR_ID						--Add 8020
        || '|' ||  trim(g_loot_ind)																												 		 --Landlord Occupant Owner Tenant 																											--LOOT_IND							  --Add 8020B
        || '|' ||  trim(w_ptbm.ebill_auto_pay_ind)																						 --eBilling Recurring payment Indicator 																								--AUTO_PAY_IND					  --Add 9454
        || '|' ||	 trim(w_ptbm.dup_ind)																												 --Duplicate Indicator																																	--DUP_IND									--Add 8020F
        || '|' ||  trim(w_ptbm.next_wtr_auto_pay_amnt)																				 --Next WTR Auto Pay Amnt																																--NEXT_WTR_AUTO_PAY_AMNT	--Add 9918
        || '|' ||  trim(w_ptbm.next_agn_auto_pay_amnt)																				 --Next AGN Auto Pay Amnt																																--NEXT_AGN_AUTO_PAY_AMNT	--Add 9918
        || '|' ||  trim(w_ptbm.next_hlp_auto_pay_amnt)																				 --Next HLP Auto Pay Amnt																																--NEXT_HLP_AUTO_PAY_AMNT	--Add 9918
        || '|' ||  trim(w_rchl.agrv_bkgrnd_prnt_string)                                        --AR/HL Background Print String                                                        --AG/HL Background Strng  --Add 4398
        || '|' ||  trim(to_char(w_ptbm.tot_disp_amnt,'$99,999,990.00'))												 --Total Dispute Amount                                                                 --TOTAL DISPUTE AMOUNT	  --Add 10846--Add 9792
  			|| '|' ||  trim(g_tap_pnlty_frgv_mssg)                  													 		 --TAP Penalty Forgiveness Mssg   																											--TAP_PNLTY_FRGV_MSSG     --Add 10846--Add 9984
  			|| '|' ||  trim(g_tap_prin_frgv_mssg)                  													 			 --TAP Principal Forgiveness Mssg   																										--TAP_PRIN_FRGV_MSSG      --Add 10846--Add 9984
        || '|' ||  trim(to_char(w_ptbm.tap_bf_count,'99,999,990'))                             --Earned Principal Forgiveness counter 																								--TAP_BF_COUNT            --Add 10846--Add 9984
        ;
        w_label := 'e136';
 end background_print_string;
-- The code has been moved to PHLQ0100_MULTIPAGE.sql
 /*************************************************************************************\
    private procedure background_print_headings
 \*************************************************************************************/
 /* --Start Add Del 3706
 procedure background_print_headings is
    w_procedure_name   varchar2(40) := 'phls0001.background_print_headings';
    --w_low_value_bill   phl_tmg_bill_master.bill_key%type    := chr('00');      --Del 3706 -- '00000000'; --add 2.0.0.33
    --w_low_value_post   phl_tmg_bill_master.mail_postal_code%type := chr('00'); --Del 3706 -- '00000';    --add 2.0.0.33
    w_low_value_bill   phl_bill_print_hist.bill_key%type    := chr('00');      --Add 3706 -- '00000000'; --add 2.0.0.33
    w_low_value_post   phl_bill_print_hist.mail_postal_code%type := chr('00'); --Add 3706 -- '00000';    --add 2.0.0.33
 begin
    trace_label('e137', w_procedure_name);
    w_ptbm := null;
    w_ptbm.bill_key           := w_low_value_bill;
    w_ptbm.mail_postal_code   := w_low_value_post;
    w_ptbm.background_print_string :=
              'BILL_KEY'
          || '|BILLING_DATE'
          || '|INCL_PAYMENTS_DATE'
          || '|PAYMENT_DUE_DATE'
          || '|ACCT_KEY'
 --       || '|BILL_FORMAT_CODE'                           -- Add 1.0.0.2  -- Del 1.0.0.15
          || '|BILL_ACCOUNT_NUMBER'
          || '|CUST_NAME'
          || '|CUST_TYPE_CODE'
          || '|INST_TYPE_CODE'
          || '|PAYS_BY_ZIPCHECK'
          || '|MAIL_NAME'
          || '|MAIL_ADDR_LINE1'
          || '|MAIL_ADDR_LINE2'
          || '|MAIL_ADDR_LINE3'
          || '|MAIL_ADDR_LINE4'
          || '|MAIL_ADDR_LINE5'
          || '|MAIL_POSTAL_CODE'
          || '|MAIL_POSTAL_BARCODE'
          || '|INST_ADDR_LINE1'
          || '|BILL_CYCLE_YYMM'
          || '|OLDEST_DEBT_CYCLE_YYMM'
          || '|METER_KEY'
          || '|SRVC_SIZE_CODE'
          || '|BILL_SERVICE'
          || '|READING_FROM_DATE'
          || '|READING_UPTO_DATE'
          || '|LAST_BILLED_READING'
          || '|THIS_BILLED_READING'
          || '|BILLED_QTY'
          || '|REPL_METER_KEY'
          || '|REPL_SRVC_SIZE_CODE'
          || '|REPL_BILL_SERVICE'
          || '|REPL_RDG_FROM_DATE'        -- Chg 1.0.0.15 was REPL_READING_FROM_DATE
          || '|REPL_RDG_UPTO_DATE'        -- Chg 1.0.0.15 was REPL_READING_UPTO_DATE
          || '|REPL_LAST_BILLED_RDG'      -- Chg 1.0.0.15 was REPL_LAST_BILLED_READING
          || '|REPL_THIS_BILLED_RDG'      -- Chg 1.0.0.15 was REPL_THIS_BILLED_READING
          || '|REPL_BILLED_QTY'
          || '|PREVIOUS_BALANCE_AMNT'
          || '|CURRENT_CHARGE_AMNT'
          || '|USG_CHARGE_AMNT'           -- Chg 1.0.0.15 was USAGE_CHARGE_AMNT
          || '|SVC_CHARGE_AMNT'           -- Chg 1.0.0.14
          || '|SENIOR_DISC_AMNT'          -- Chg 1.0.0.15 was discount_amnt
          || '|LAST_PAID_DATE'
          || '|LAST_PAID_AMNT'
          || '|TOTAL_DUE_AMNT'
          || '|PENALTY_AMNT'
          || '|PENALTY_DUE_AMNT'
          || '|PENALTY_DATE'
          || '|SCAN_STRING'
          || '|message_1'
          || '|message_2'
          || '|BQTY_01'
          || '|BQTY_02'
          || '|BQTY_03'
          || '|BQTY_04'
          || '|BQTY_05'
          || '|BQTY_06'
          || '|BQTY_07'
          || '|BQTY_08'
          || '|BQTY_09'
          || '|BQTY_10'
          || '|BQTY_11'
          || '|BQTY_12'
          ;
  */
  /* --Actual code deletion start --3706
     --
     --Code has been moved to PHLQ0100_MULTIPAGE.sql {Generic SQL Report for 1 Page STD, 2 Page STD, 1 Page Zip Check and 2 Page Zip Check....
     --
 end background_print_headings;  --Del 3706
 */--END Del 3706
 /*************************************************************************************\
    private procedure get_bill_lines
 \*************************************************************************************/
 procedure get_bill_lines is
    w_procedure_name              varchar2(40) := 'phls0001.get_bill_lines';
    w_additive_mtr_reg_num   number;                    --Add  2275
    w_max_reading_mtr     varchar2(38);                  --Add  2275
    w_oi_tran_id                  cis_transactions.tran_id%type;
    w_oi_alloc_amnt               cis_transactions.tran_bal_amnt%type;      -- Add 1.0.0.4
    w_oi_unall_amnt               cis_transactions.tran_bal_amnt%type;      -- Add 1.0.0.4
    w_other_tran_amnt             cis_bill_lines.other_tran_amnt%type;      -- Add 1.0.0.4
    w_doing_meter_rotated         boolean;                                  -- Add 1129
    w_doing_meter_current         boolean;                                  -- Add 1129
    w_doing_meter_deleted         boolean;                                  -- Add 1129
    w_rpl_qty_bi      binary_integer := 0;        -- Add 2417
    cursor c_oi_tran is
    select prim_type
         , scnd_type
         , tran_outst_ind
         , ifce_status_code                                         -- Add 1.0.0.4
         , tran_tot_amnt                                            -- Add 1.0.0.26
         , tran_bal_amnt                                            -- Add 1.0.0.4
         , ppln_bal_amnt                                            -- Add 1.0.0.4
         , acct_sign                                                -- Add 1.0.0.4
         , tran_description                                         -- Add 3706 --For grants proof of concept
         , ifce_text                                                -- Add 3706 --For grants at later date
         , tran_key                                                 -- Add 3706 --For grant at later date
         , fully_reversed_ind                                       -- Add 11413B
      from cis_transactions
     where tran_id = w_oi_tran_id;
    w_oi_tran                    c_oi_tran%rowtype;                 -- Add 1.0.0.4
    cursor c_oi_alloc is                                            -- Add 1.0.0.4
    select sum(cr_alloc_amnt)
      from cis_crdr_allocations allc
          ,cis_credit_lines crln
          ,cis_debit_lines dbln
          ,cis_transactions dbtn
     where crln.tran_id = w_oi_tran_id
       and allc.cust_id = crln.cust_id
       and allc.credit_line_id = crln.credit_line_id
       and dbln.debit_line_id = allc.debit_line_id
       and dbtn.tran_id = dbln.tran_id
       --and ( dbtn.ifce_status_code is null                           -- Del 2.0.0.9 Del 1.0.0.21   -- Chg 1.0.0.26  -- Chg 1225
       --      or dbtn.ifce_status_code = 'LL-OCC'                     -- Del 2.0.0.9 Add 1225
       --      or dbtn.ifce_status_code = 'LL-TEN' )                   -- Del 2.0.0.9 Add 1225
    ;                                                                  -- Add 1.0.0.21
  w_additive_inst_id     cis_installations.inst_id%type; --Add   1411 1.0.0.51
  w_additive_period_from_date   date;           --Add   1411 1.0.0.51
  w_additive_meter_id      number;           --Add   1411 1.0.0.51
    cursor c_mwos is                      --Add   1411 1.0.0.51
    select mwos.meter_works_id
    ,mwos.meter_works_key
    ,mwos.meter_work_status
    ,mwos.inst_id
    ,trunc(mwos.complete_datime) complete_datime
    ,mwol.meter_id
    ,mwol.meter_reading
    ,mwol.new_meter_id
    ,mwol.new_meter_reading
  from
    cis_meter_wos mwos
   ,cis_meter_wo_lines mwol
  where mwos.inst_id = w_additive_inst_id
    and mwos.meter_works_id = mwol.meter_works_id
  order by mwos.complete_datime desc;
  w_c_mwos      c_mwos%rowtype; --Add   1411 1.0.0.51
  w_blln_meter_grp_rdg_id number  := null;  --Add   1411 1.0.0.51
  w_blln_tran_qty         number  := null;  --Add   1411 1.0.0.51
  w_notfnd_replacement  boolean := true; --Add   1411 1.0.0.51
  w_notfnd_additive     boolean := true; --Add   1411 1.0.0.51
  w_chx_wo_dis    number  := 0;     --Add 2634
  /*
  SCND_TYPE  SINV_CODE  TASK_CODE USEC_CODE  SRVC_CODE  USEC_SRVC_DISC_CODE
  RSR        NULL       PAYREV     NULL       NULL       NULL
  CBO        BCFEE      AA         LND-SUR    FIR-SRVC   STANDARD
  RTO        DMTFR      DQ         GRW-SWCG   SEW-SRVC   PHA
  IDR        CITYCRED   NOLETTER   SEW-USG    WAT-SRVC
  SIN        ADVFSRVC   DA         IND-SUR
  AGR        CONSMPT    M-DISHNR   WAT-USG
  DIS        CORTCOST   REFZC
  RDS        INVOICE    DT
  SVC        CREDNOTE   REC-TFR
  DBI        WATWSALE   LN
  CHX        CAUP       DI
  RDG        PENALTY    DCC
  RER        ACBALTFR   DM
  REF        ADJ-SEW    DE
             ADVWSRVC   DF
               LIENCOST   BILL
               DEBITTFR   PNLTYINT
               ADJ-WAT    BALTR
               REFUND     DISNOFEE
               TFR-REC    WW
               PAYREVNF   DISONR
               ADJ-FIR    PNLTY-MG
               ADVSSRVC   BC
                          ARBALDB
                          FC
 */
 --
 -- LATE_PMT_PENALTY / LIENS
 --
 begin
    trace_label('e138', w_procedure_name);
    w_cust_own_reading_ind := 'N';                                -- Add 542
    w_in_mtr_grp       := 'N';                                    -- Add 818
    w_unbill_reg_found := 'N';                                    -- Add 818
    w_meter_grp_rdg_id := null;                                   -- Add 818
    w_quality_factor   := null;                                   -- Add 818
    w_copy_bill_ind    := 'N';                                    -- Add 818
    w_factor_message   := null;                                   -- Add 2199
  	w_sur_cst_fct_mssg := null;             -- Add 2199 by Raj
    w_doing_meter_rotated := false;                               -- Add 1129 --2.0.0.07 --1.0.0.68
    w_doing_meter_current := false;                               -- Add 1129 --2.0.0.07 --1.0.0.68
    w_doing_meter_deleted := false;                               -- Add 1129 --2.0.0.07 --1.0.0.68
    w_real_read_amnt := 0;                                        -- Add 2109 --2.0.0.07 --1.0.0.68
    w_est_rev_amnt := 0;                                          -- Add 2109 --2.0.0.07 --1.0.0.68
    w_prepare_est_rev_msg := false;                               -- Add 2109 --2.0.0.07 --1.0.0.68
  	w_rpl_qty_bi := 0;                -- 2417
  	w_rpl_qty_tbl.delete;             -- 2417
    trace_label('e139', w_procedure_name);
  	debug_trace(w_procedure_name,' get_bill_lines ==> w_tran_id   --> ' || w_tran_id);
  	debug_trace(w_procedure_name,' get_bill_lines ==> w_process_id  --> ' || w_process_id);
    if w_settl_ownr_bill then                                     -- Add 1.0.0.4
       open c_blln_psb;
       trace_label('e140', w_procedure_name);
       g_final_bill_ind := 'Y'; --8020F
    else
       open c_blln;
       trace_label('e141', w_procedure_name);
    end if;
    loop
       trace_label('e142', w_procedure_name);
       if w_settl_ownr_bill then                                  -- Add 1.0.0.4
          trace_label('e143', w_procedure_name);
          fetch c_blln_psb into w_blln;
          exit when c_blln_psb%notfound;
       else
          trace_label('e144', w_procedure_name);
          fetch c_blln into w_blln;
          exit when c_blln%notfound;
       end if;
       if nvl(w_blln.copy_bill_ind, 'N') = 'Y'              -- Add 818
       then                                                 -- Add 818
          w_copy_bill_ind := w_blln.copy_bill_ind;          -- Add 818
       end if;                                              -- Add 818
       /* --Add 8020 */
       --The bill line type which stores the ELECTBIL delivery method
       if w_blln.line_type = 'O' then
          trace_label('e145', w_procedure_name);
          --Need to contemplate, if we need to set ebill-flag here at bill lines or at account level.
       end if;
       /* --Add 8020 */
       -- Open items
       if w_blln.line_type = 'O' then
         trace_label('e146', w_procedure_name);
         --Start Add 7762
         --if substr(w_blln.task_code,1,7) = 'SHWOFEE' then
         --		l_ss_fee_mssg := 'Y';
				 --end if;
         --End Add 7762
         debug_trace(w_procedure_name, 'OPEN Item Receipt');
         debug_trace(w_procedure_name, '..w_blln.task_code  =' || w_blln.task_code );
         debug_trace(w_procedure_name, '..Key  =' || w_blln.other_tran_key || '/' || w_oi_tran_id);
         debug_trace(w_procedure_name, '..Amt  =' || w_blln.other_tran_amnt);
         --Start Add 9984B
         --if nvl(w_pay_profile_code_orig,'X') != 'TAP-STD' then
	       if w_blln.task_code = 'TAPCRBF' then --Principal Forgivness amounts
						  if w_ptbm.tap_prin_frgv_dt is null then
						     w_ptbm.tap_prin_frgv_dt		 := w_blln.other_tran_date;
						  else
						     if w_ptbm.tap_prin_frgv_dt < w_blln.other_tran_date then
						     		w_ptbm.tap_prin_frgv_dt		 := w_blln.other_tran_date;
						     end if;
						  end if;
					  w_ptbm.tap_prin_frgv_amnt  := nvl(w_ptbm.tap_prin_frgv_amnt,0) + (-1 * w_blln.other_tran_amnt); --Remove the -ve Sign, its stored as -ve in bill lines
	       end if;
	       if w_blln.task_code = 'TAPCERF' then  --Penalty Fprviness amounts
						if w_ptbm.tap_pnlty_frgv_dt is null then
							 w_ptbm.tap_pnlty_frgv_dt   := w_blln.other_tran_date;
						else
						   if w_ptbm.tap_pnlty_frgv_dt < w_blln.other_tran_date then
						   	  w_ptbm.tap_pnlty_frgv_dt   := w_blln.other_tran_date;
						   end if;
					end if;
					w_ptbm.tap_pnlty_frgv_amnt := nvl(w_ptbm.tap_pnlty_frgv_amnt,0) + ( -1 * w_blln.other_tran_amnt);  --Remove the -ve sign, its stored as -ve in bill lines
	       end if;
	       debug_trace(w_procedure_name, '..w_ptbm.tap_pnlty_frgv_amnt=' || w_ptbm.tap_pnlty_frgv_amnt);
	       debug_trace(w_procedure_name, '..w_ptbm.tap_prin_frgv_amnt =' || w_ptbm.tap_prin_frgv_amnt);
	       --end if;
         --End Add 9984B
         if substr(w_blln.task_code,1,5) = 'PNLTY' then
                  --Start Add 8000_8044
                  if is_line_not_on_ppln(w_blln.other_tran_id) then
                        w_ptbm.late_pmt_penalty := nvl(w_ptbm.late_pmt_penalty,0) + nvl(w_blln.other_tran_amnt,0);
                  end if;
                  --End Add 8000_8044
            --w_ptbm.late_pmt_penalty   := nvl(w_ptbm.late_pmt_penalty,0) + nvl(w_blln.other_tran_amnt,0); --Del 8000_8044
         elsif w_blln.task_code = 'LN' then
								  --Start Add 9749
        					--debug_trace(w_procedure_name,'...w_pay_profile_code_orig    --> ' || w_pay_profile_code_orig);
        					--if w_pay_profile_code_orig = 'TAP-STD' then -----TAP-STD Bill might be having TAP bills.
        					--   w_ptbm.lien          := 0; --Do not display Lien Fees on the Bill for TAP A/C's
        					--   g_tap_lien           := nvl(g_tap_lien,0) + nvl(w_blln.other_tran_amnt,0);
         					--	 debug_trace(w_procedure_name, '..w_ptbm.lien  =' || w_ptbm.lien);
         					--	 debug_trace(w_procedure_name, '..g_tap_lien   =' || g_tap_lien);
        					--else
        					--End Add 9749
	                   --Start Add 8000_8044
	                   if is_line_not_on_ppln(w_blln.other_tran_id) then
	                     w_ptbm.lien           := nvl(w_ptbm.lien,0) + nvl(w_blln.other_tran_amnt,0);
	                   end if;
	                   --End Add 8000_8044
	                --end if; --Add 9749
            --w_ptbm.lien              := nvl(w_ptbm.lien,0) + nvl(w_blln.other_tran_amnt,0);   --Del 8000_8044
         elsif w_blln.task_code = w_meter_test_charge_pks then
                  --Start Add 8000_8044
                  if is_line_not_on_ppln(w_blln.other_tran_id) then
                     w_ptbm.meter_test_charge  := nvl(w_ptbm.meter_test_charge,0) + nvl(w_blln.other_tran_amnt,0);
                  end if;
                  --End Add 8000_8044
                  --w_ptbm.meter_test_charge  := nvl(w_ptbm.meter_test_charge,0) + nvl(w_blln.other_tran_amnt,0); --Del 8000_8044
         elsif w_blln.task_code = 'BC' then
                  --Start Add 8000_8044
                  if is_line_not_on_ppln(w_blln.other_tran_id) then
                     w_ptbm.bank_return_item  := nvl(w_ptbm.bank_return_item,0) + nvl(w_blln.other_tran_amnt,0);
                  end if;
                  --End Add 8000_8044
                  --w_ptbm.bank_return_item  := nvl(w_ptbm.bank_return_item,0) + nvl(w_blln.other_tran_amnt,0);   --Del 8000_8044
         else
            w_oi_tran_id := w_blln.other_tran_id;
            open c_oi_tran;
            fetch c_oi_tran into w_oi_tran;                            -- Chg 1.0.0.4
            close c_oi_tran;
            if w_oi_tran.scnd_type in ('REC','RTI') then
              -- Other tran amount is negative on bill lines for receipts and credits
              if ( w_settl_ownr_bill or w_final_ownr_bill )                           -- Chg 1.0.0.6
              then                                                                    -- Add 1.0.0.4
                 debug_trace(w_procedure_name, '..In REC/RTI [1] w_oi_tran.tran_description =' || w_oi_tran.tran_description);
                 debug_trace(w_procedure_name, '..In REC/RTI [1] w_oi_tran.ifce_text =' || w_oi_tran.ifce_text);
                 w_other_tran_amnt:= w_blln.other_tran_amnt;                          -- Add 1.0.0.4
              else                                                                    -- Add 1.0.0.4
                 -- Assume that any unallocated receipt is going to be used against account debt.
                 -- To be correct for non settlement bills, we should track all
                 -- the allocations for each receipt and only consider allocations
                 -- made against transactions without an ifce_status_code.
                 -- Since these are credit acct sign is negative
                 -- We need to reverse the sign when we add for the bill payment amount.
                 trace_label('e147', w_procedure_name);
                 debug_trace(w_procedure_name, '..In REC/RTI [2] w_oi_tran.tran_description =' || w_oi_tran.tran_description);
                 debug_trace(w_procedure_name, '..In REC/RTI [2] w_oi_tran.ifce_text =' || w_oi_tran.ifce_text);
                 w_oi_unall_amnt := w_oi_tran.tran_bal_amnt + nvl(w_oi_tran.ppln_bal_amnt,0);
                 debug_trace(w_procedure_name, '..Unall Amt  =' || w_oi_unall_amnt);
                 w_oi_alloc_amnt := 0;                                                         -- Add 1.0.0.26
                 if w_oi_unall_amnt <> w_oi_tran.tran_tot_amnt                                 -- Add 1.0.0.26
                 then                                                                          -- Add 1.0.0.26
                    open c_oi_alloc;
                    fetch c_oi_alloc into w_oi_alloc_amnt;
                    close c_oi_alloc;
                 end if;                                                              -- Add 1.0.0.26
                 debug_trace(w_procedure_name, '..In REC/RTI [3] w_oi_alloc_amnt =' || w_oi_alloc_amnt);
                 w_oi_alloc_amnt  := nvl(w_oi_alloc_amnt,0);                          -- Add 1.0.0.58
                 w_other_tran_amnt:= (w_oi_unall_amnt + w_oi_alloc_amnt) * -1;
              end if;                                                                 -- Add 1.0.0.4
              debug_trace(w_procedure_name, '..In REC/RTI [3.3] upper(w_oi_tran.tran_description) =' || upper(w_oi_tran.tran_description));
              debug_trace(w_procedure_name, '..In REC/RTI [3.3] w_list_of_grnts_as_pym_adj =' || w_list_of_grnts_as_pym_adj);
		          
              if regexp_instr(upper(nvl(w_oi_tran.tran_description,'!@#$^*()')),w_list_of_grnts_as_pym_adj) = 0 
							and nvl(w_blln.task_code,'XXX') != 'S17'		--Add 11413
              then --Add 3706
                 debug_trace(w_procedure_name, '..In REC/RTI [3.4] w_oi_alloc_amnt   =' || w_oi_alloc_amnt);
                 debug_trace(w_procedure_name, '..In REC/RTI [3.4] w_other_tran_amnt =' || w_other_tran_amnt);
                 w_ptbm.last_paid_count       := nvl(w_ptbm.last_paid_count,0) + 1;
                 w_ptbm.last_paid_amnt        := nvl(w_ptbm.last_paid_amnt,0) + (w_other_tran_amnt);    -- Chg 2.0.0.05
                 w_ptbm.last_paid_date        := greatest(
                                                          nvl(w_ptbm.last_paid_date,w_low_date)
                                                         ,w_blln.other_tran_date
                                                         );
              else    --Start Add 3706
                 --debug_trace(w_procedure_name, '..In REC/RTI [3.5] w_oi_alloc_amnt   =' || w_oi_alloc_amnt);
                 debug_trace(w_procedure_name, '..In REC/RTI [3.5] w_blln.other_tran_key =' || w_blln.other_tran_key);
                 debug_trace(w_procedure_name, '..In REC/RTI [3.6] w_grnt_rcvd =' || w_grnt_rcvd);

                 w_ptbm.adjust      := nvl(w_ptbm.adjust,0)
                                     + nvl(w_blln.other_tran_amnt,0);
				         --Start Add 11413
                 debug_trace(w_procedure_name, '..w_oi_tran.fully_reversed_ind =' || w_oi_tran.fully_reversed_ind);
				         if nvl(w_blln.task_code,'XXX') = 'S17' and nvl(w_oi_tran.fully_reversed_ind,'X') != 'Y' then --Added 11413A --S17 LIHWAP grant.
				            g_s17_grnt_amnt := nvl(g_s17_grnt_amnt,0) + (-1 * nvl(w_blln.other_tran_amnt,0)); --Since receipt is -ve, multiplying with -1 to make it positive for display purpose.
				         elsif nvl(w_blln.task_code,'XXX') != 'S17' and nvl(w_oi_tran.fully_reversed_ind,'X') != 'Y' then  --Added 11413A 
			         	  	w_grnt_rcvd        := nvl(w_grnt_rcvd,0) + nvl(w_blln.other_tran_amnt,0);	  
								 else
								 		debug_trace(w_procedure_name, '..Please verify if the grant amount is fully reversed ............. ');	--Added 11413A 	
								 		debug_trace(w_procedure_name, '..The grant amount is fully reversed hence not included for message ');	--Added 11413A 
								 		debug_trace(w_procedure_name, '..Please verify if the grant amount is fully reversed ............. ');	--Added 11413A 
				         end if;
				         --End Add 11413
                 debug_trace(w_procedure_name, '..In REC/RTI [3.7] w_grnt_rcvd =' || w_grnt_rcvd);
              end if; --End Add 3706
              debug_trace(w_procedure_name, '..In REC/RTI [3.8] w_grnt_rcvd   =' || w_grnt_rcvd);
           elsif w_oi_tran.prim_type = 'D' then   ----- Do we need it
              debug_trace(w_procedure_name, 'Debit Open Items');
              debug_trace(w_procedure_name, '..Key  =' || w_blln.other_tran_key || '/' || w_oi_tran_id);
              debug_trace(w_procedure_name, '..Amt  =' || w_blln.other_tran_amnt);
              if ( w_settl_ownr_bill or w_final_ownr_bill )                          -- Chg 1.0.0.6
              or w_oi_tran.ifce_status_code is null                                  -- Add 1.0.0.4  -- Chg 1225
              or w_oi_tran.ifce_status_code = 'LL-OCC'                               -- Add 1225
              or w_oi_tran.ifce_status_code = 'LL-TEN'                               -- Add 1225
              or regexp_instr(upper(nvl(w_oi_tran.tran_description,'!@#$^*()')),w_list_of_grnts_as_pym_adj) <> 0 -- Add 3706
              then
                 --debug_trace(w_procedure_name, 'Debit Open Items -Adjustments');
                 --debug_trace(w_procedure_name, '..In REC/RTI [4] w_oi_tran.tran_description =' || w_oi_tran.tran_description);
                 --debug_trace(w_procedure_name, '..In REC/RTI [4] w_oi_tran.ifce_text =' || w_oi_tran.ifce_text);
                  w_ptbm.adjust      := nvl(w_ptbm.adjust,0)            --Add 2.0.0.0
                                     + nvl(w_blln.other_tran_amnt,0);   --Add 2.0.0.0
                  --Start Add 3706
                  if regexp_instr(upper(nvl(w_oi_tran.tran_description,'!@#$^*()')),w_list_of_grnts_as_pym_adj)  <> 0 then --Add 3706
                     w_grnt_rcvd        := nvl(w_grnt_rcvd,0) + nvl(w_blln.other_tran_amnt,0);
                  end if;
                  debug_trace(w_procedure_name, '..In REC/RTI [4.1] w_grnt_rcvd   =' || w_grnt_rcvd);
                  debug_trace(w_procedure_name, '..In REC/RTI [4.1] w_ptbm.adjust =' || w_ptbm.adjust);
                  --End Add 3706
              --Start add 5609
              else
                  w_ptbm.adjust      := nvl(w_ptbm.adjust,0)                           -- Add 2.0.0.0
                                      + nvl(w_blln.other_tran_amnt,0);                 -- Add 2.0.0.0
              --End add 5609
              end if;         --Add 1.0.0.4
           else
              debug_trace(w_procedure_name, 'Credit Open Items -Adjustments');
              debug_trace(w_procedure_name, '..Key  =' || w_blln.other_tran_key || '/' || w_oi_tran_id);
              debug_trace(w_procedure_name, '..Amt  =' || w_blln.other_tran_amnt);
              if w_settl_ownr_bill                                                     -- Add 1.0.0.4
              or w_oi_tran.ifce_status_code is null                                    -- Add 1.0.0.4  -- Chg 1225
              or w_oi_tran.ifce_status_code = 'LL-OCC'                                 -- Add 1225
              or w_oi_tran.ifce_status_code = 'LL-TEN'                                 -- Add 1225
              then                                                                     -- Add 1225
                  --debug_trace(w_procedure_name, 'Credit Open Items -Adjustments');
                  debug_trace(w_procedure_name, '..In REC/RTI [5] w_oi_tran.tran_key =' || w_oi_tran.tran_key);
                  debug_trace(w_procedure_name, '..In REC/RTI [5] w_oi_tran.tran_description =' || w_oi_tran.tran_description);
                  w_ptbm.adjust      := nvl(w_ptbm.adjust,0)                           -- Add 2.0.0.0
                                      + nvl(w_blln.other_tran_amnt,0);                 -- Add 2.0.0.0
                  if regexp_instr(upper(nvl(w_oi_tran.tran_description,'!@#$^*()')),w_list_of_grnts_as_pym_adj)  <> 0 then     --Add 3706
                     debug_trace(w_procedure_name, '..In REC/RTI [5.1] w_grnt_rcvd =' || w_grnt_rcvd);
                     w_grnt_rcvd     := nvl(w_grnt_rcvd,0) + nvl(w_blln.other_tran_amnt,0);     --Add 3706
                  end if;                                                                       --Add 3706
                  debug_trace(w_procedure_name, '..In REC/RTI [5.2] w_grnt_rcvd =' || w_grnt_rcvd);
              --Start add --5609
              else
                  w_ptbm.adjust      := nvl(w_ptbm.adjust,0)                           -- Add 2.0.0.0
                                      + nvl(w_blln.other_tran_amnt,0);                 -- Add 2.0.0.0
              --Start add --5609
              end if;                                                                  -- Add 1.0.0.4
           end if;
       end if;
    --debug(w_procedure_name, w_label,' [0] w_oi_tran.scnd_type    = ' || w_oi_tran.scnd_type   );
    --debug(w_procedure_name, w_label,' [1] w_blln.task_code     = ' || w_blln.task_code   );
    --debug(w_procedure_name, w_label,' [2] w_ptbm.adjust      = ' || w_ptbm.adjust    );
    --debug(w_procedure_name, w_label,' [3] w_ptbm.last_paid_amnt  = ' || w_ptbm.last_paid_amnt );
       -- Usage and service charges for this bill
       elsif w_blln.line_type = 'L' then
         --debug_trace(w_procedure_name, 'BILL LINE');
         --debug_trace(w_procedure_name, '..scnd_type     =' || w_blln.db_scnd_type);
         --debug_trace(w_procedure_name, '..usec_code     =' || w_blln.usec_code);
         --debug_trace(w_procedure_name, '..srvc_code     =' || w_blln.srvc_code);
         --debug_trace(w_procedure_name, '..line_tot_amnt =' || nvl(w_blln.db_line_tot_amnt,w_blln.cr_amnt));
         --Start Add 3154
         w_label := 'e148';
         trace_label(w_label, w_procedure_name);
         debug(w_procedure_name,w_label,' w_blln.outreader_serial_no '|| w_blln.outreader_serial_no);
         debug(w_procedure_name,w_label,' w_blln.line_type           '|| w_blln.line_type);
         debug(w_procedure_name,w_label,' w_blln.db_scnd_type        '|| w_blln.db_scnd_type);
         debug(w_procedure_name,w_label,' w_blln.meter_grp_rdg_id    '|| w_blln.meter_grp_rdg_id);
         debug(w_procedure_name,w_label,' w_blln.line_num            '|| w_blln.line_num);
         debug(w_procedure_name,w_label,' w_tran_id                  '|| w_tran_id);
         debug(w_procedure_name,w_label,' w_process_id               '|| w_process_id);
         --if w_ptbm.ert_key is null and w_blln.outreader_serial_no is not null then   --Del 3706
         --   w_ptbm.ert_key := w_blln.outreader_serial_no;                            --Del 3706
         --end if;                                                                     --Del 3706
         debug(w_procedure_name,w_label,' w_ptbm.ert_key '|| w_ptbm.ert_key);
         --End Add 3154
         if w_blln.db_scnd_type in ('MIN', 'MIS', 'RDG', 'RDS', 'REM', 'RER', 'RSM', 'RSR' , 'AGR')  -- Mod 2.0.0.34 --Added AGR
         then
            if w_blln.meter_grp_rdg_id is not null     ----For Meter Groups               ---Add 1353
            then
               w_label := 'e149';
               trace_label(w_label, w_procedure_name);
               debug(w_procedure_name,w_label,' w_blln_meter_grp_rdg_id '|| w_blln.meter_grp_rdg_id);
               debug(w_procedure_name,w_label,' w_blln.period_from_date '|| to_char(w_blln.period_from_date));
               debug(w_procedure_name,w_label,' w_blln.period_upto_date '|| to_char(w_blln.period_upto_date));
               debug(w_procedure_name,w_label,' w_blln.prior_last_billed_reading '|| w_blln.prior_last_billed_reading);
               debug(w_procedure_name,w_label,' w_blln.meter_reading             '|| w_blln.meter_reading);
               debug(w_procedure_name,w_label,' w_blln.fault_code                '|| w_blln.fault_code);
               debug(w_procedure_name,w_label,' w_blln.meter_key                 '|| w_blln.meter_key);
               debug(w_procedure_name,w_label,' w_blln.meter_key_10chr           '|| w_blln.meter_key_10chr);		 --Add 11138
               debug(w_procedure_name,w_label,' w_blln.meter_id                  '|| w_blln.meter_id);           --Add 11138
               debug(w_procedure_name,w_label,' w_blln.outreader_serial_no       '|| w_blln.outreader_serial_no);
               debug(w_procedure_name,w_label,' w_unbill_reg_found               '|| w_unbill_reg_found);
               debug(w_procedure_name,w_label,' w_blln.unbill_meter_ind          '|| w_blln.unbill_meter_ind);
               --
               -- Valriables used at the bottom of loop for Only Notional Meters.
               --
               w_blln_meter_grp_rdg_id := w_blln.meter_grp_rdg_id;         --Add 1411
               if w_blln.tran_qty is not null then             --Add 1411
                  w_blln_tran_qty  :=  w_blln.tran_qty;
               end if;
               if w_blln.db_scnd_type in ('RDG', 'RER')
               then
                   if w_blln.unbill_meter_ind is null                                       -- Add 818
                   then                                                                     -- Add 818
                          -- Set period dates if not already set by previous RDG            -- Add 1092
                      if w_ptbm.reading_from_date is null                                   -- Add 1092
                      then                                                                  -- Add 1092
                         trace_label('e150', w_procedure_name);
                         w_ptbm.reading_from_date   := w_blln.period_from_date;             -- Add 818
                         w_ptbm.reading_upto_date   := w_blln.period_upto_date;             -- Add 818
                      end if;                                                               -- Add 1092
                   end if;                                                                      -- Add 818
               end if;
               if w_blln.db_scnd_type = 'RDG'
               then
                  w_in_mtr_grp       := 'Y';                                               -- Add 818
                  w_meter_grp_rdg_id := w_blln.meter_grp_rdg_id;                           -- Add 818
                  if w_blln.unbill_meter_ind is not null                                   -- Add 818
                  then                                                                     -- Add 818
                     ---Indicates we have got additive meter
                     w_label := 'e151';
                     trace_label(w_label, w_procedure_name);
                     w_notfnd_additive := false;               -- Add 1411
                     w_unbill_reg_found         := 'Y';                                    -- Add 818
                     w_ptbm.last_billed_reading := w_blln.prior_last_billed_reading;       -- Add 818
                     w_ptbm.this_billed_reading := w_blln.meter_reading;                   -- Add 818
                     w_fault_code               := w_blln.fault_code;                      -- Add 818
                     w_ptbm.meter_key           := w_blln.meter_key;                       -- Add 1353
                     g_meter_key_10chr					:= w_blln.meter_key_10chr;                 -- Add 11138
                     g_meter_id									:= w_blln.meter_id;                 			 -- Add 11138
                     --Start Add 3706
                     debug(w_procedure_name,w_label,'  w_ptbm.ert_key '|| w_ptbm.ert_key);
                     --if w_ptbm.ert_key is null and w_blln.outreader_serial_no is not null then
                     --   if nvl(w_ptbm.repl_ert_key,'xxx') != w_blln.outreader_serial_no then
                     w_ptbm.ert_key := w_blln.outreader_serial_no;
                     --   end if;
                     --end if;
                     --End Add 3706
                     debug(w_procedure_name,w_label,' w_ptbm.ert_key '|| w_ptbm.ert_key);
                     debug(w_procedure_name,w_label,' w_ptbm.this_billed_reading     '|| w_ptbm.this_billed_reading);
                     debug(w_procedure_name,w_label,' w_ptbm.last_billed_reading     '|| w_ptbm.last_billed_reading);
                     --w_ptbm.billed_qty          := nvl(w_blln.tran_qty,0);               -- Add 1353  --Del 1700  --2.0.0.05A --1.0.0.67
                     w_ptbm.billed_qty := nvl(w_ptbm.this_billed_reading,0)                -- Add 1700  --2.0.0.05A --1.0.0.67
                                        - nvl(w_ptbm.last_billed_reading,0)                -- Add 1700  --2.0.0.05A --1.0.0.67
                                        ;
                     w_current_billed_qty  := w_ptbm.this_billed_reading - w_ptbm.last_billed_reading; --Add 3706
                     debug(w_procedure_name,w_label,' w_ptbm.billed_qty    '|| w_ptbm.billed_qty);
                     debug(w_procedure_name,w_label,' w_current_billed_qty '|| w_current_billed_qty);
                     -- Start 2275
                     if w_ptbm.billed_qty < 0 then                -- Add 2275
                        w_label := 'e152';
                        trace_label(w_label, w_procedure_name);
                        w_max_reading_mtr := '9';                 -- Add 2275
                        begin                      -- Add 2275
                           select rpad(w_max_reading_mtr,number_dials,'9') into w_max_reading_mtr -- Add 2275
                             from cis_meter_regs                      -- Add 2275
                            where meter_id      = w_blln.meter_id                                  -- Add 2275
                              and meter_reg_num = w_blln.meter_reg_num;                            -- Add 2275
                           debug(w_procedure_name,w_label,' w_max_reading_mtr            '|| w_max_reading_mtr);
                           debug(w_procedure_name,w_label,' w_ptbm.last_billed_reading   '|| w_ptbm.last_billed_reading);
                           debug(w_procedure_name,w_label,' w_ptbm.this_billed_reading   '|| w_ptbm.this_billed_reading);
                           w_ptbm.billed_qty := (to_number(trim(w_max_reading_mtr))+1) -              -- Add 2275
                                                nvl(w_ptbm.last_billed_reading,(to_number(trim(w_max_reading_mtr))+1) )  + -- Add 2275
                                                w_ptbm.this_billed_reading;           -- Add 2275
                           w_current_billed_qty := w_ptbm.billed_qty;
                           debug(w_procedure_name,w_label,' w_ptbm.billed_qty '|| w_ptbm.billed_qty);
                        exception                      -- Add 2275
                           when others then                   -- Add 2275
                              debug(w_procedure_name,w_label,' Error :- '|| sqlcode || ' ' ||Sqlerrm );   -- Add 2275
                        end;                        -- Add 2275
                     end if;                        -- Add 2275
                     -- End   2275
                     w_est_reading_ind        := w_blln.est_reading_ind;                 -- Add 818
                     w_ptbm.est_this_rdg_flag := w_blln.est_reading_ind;                 -- Add 2.0.0.0
                     if w_blln.prior_estimates_cnt > 0 then            -- Add 2.0.0.0
                        w_ptbm.est_last_rdg_flag   :=  'E';
                     else
                        w_ptbm.est_last_rdg_flag   :=  null;
                     end if;
                     --debug(w_procedure_name,w_label,' w_est_reading_ind     '|| w_est_reading_ind   );
                     --debug(w_procedure_name,w_label,' w_ptbm.est_this_rdg_flag  '|| w_ptbm.est_this_rdg_flag );
                     --debug(w_procedure_name,w_label,' w_prior_estimates_cnt     '|| w_prior_estimates_cnt   );
                     --debug(w_procedure_name,w_label,' w_ptbm.est_last_rdg_flag '|| w_ptbm.est_last_rdg_flag );
                  elsif w_unbill_reg_found = 'N'                                           -- Add 2.0.0.0
                  then                                                                     -- Add 2.0.0.0
                     w_label := 'e153';
                     trace_label(w_label, w_procedure_name);
                     w_additive_mtr_reg_num := null;              -- Add 2275
                     select  min(last_reading)                                             -- Add 818 -- Chg 1513 --2.0.0.01B --1.0.0.65
                            ,min(last_reading_datime)                                      -- Add 1513 --2.0.0.01B --1.0.0.65
                            ,max(meter_reading)                                            -- Add 818
                            ,max(est_reading_ind)                                          -- Add 818
                            ,max(meter_id)                                                 -- Add 1411
                            ,max(inst_id)                                                  -- Add 1411
                            ,max(estimates_cnt)                                            -- Add 2.0.0.0
                            ,max(meter_reg_num)                                            -- Add 2275
                       into  w_ptbm.last_billed_reading                                    -- Add 818
                            ,w_last_reading_datime                                         -- Add 1513 --2.0.0.01B --1.0.0.65
                            ,w_ptbm.this_billed_reading                                    -- Add 818
                            ,w_est_reading_ind                                             -- Add 818
                            ,w_additive_meter_id                                           -- Add 1411
                            ,w_additive_inst_id                                            -- Add 1411
                            ,w_prior_estimates_cnt                                         -- Add 2.0.0.0
                            ,w_additive_mtr_reg_num                                        -- Add 2275
                       from cis_meter_grp_rdg_lines                                        -- Add 818
                      where meter_grp_rdg_id = w_blln.meter_grp_rdg_id                     -- Add 818
                        and meter_reading is not null;                                     -- Add 818
                     if trunc(w_last_reading_datime) + 1 <> trunc(w_blln.period_from_date) -- Add 1513 --2.0.0.01B --1.0.0.65
                     then                                                                  -- Add 1513 --2.0.0.01B --1.0.0.65
                        w_last_reading := null;                                            -- Add 1513 --2.0.0.01B --1.0.0.65
                        w_last_reading_datime := null;                                     -- Add 1513 --2.0.0.01B --1.0.0.65
                        trace_label('e154', w_procedure_name);                             -- Add 1513 --2.0.0.01B --1.0.0.65
                        select min(last_reading),                                          -- Add 1513 --2.0.0.01B --1.0.0.65
                               min(last_reading_datime)                                    -- Add 1513 --2.0.0.01B --1.0.0.65
                          into w_last_reading,                                             -- Add 1513 --2.0.0.01B --1.0.0.65
                               w_last_reading_datime                                       -- Add 1513 --2.0.0.01B --1.0.0.65
                          from cis_meter_grp_rdg_lines                                     -- Add 1513 --2.0.0.01B --1.0.0.65
                         where meter_id = w_additive_meter_id                              -- Add 1513 --2.0.0.01B --1.0.0.65
                           and inst_id = w_additive_inst_id                                -- Add 1513 --2.0.0.01B --1.0.0.65
                           and meter_grp_rdg_id < w_blln.meter_grp_rdg_id                  -- Add 1513 --2.0.0.01B --1.0.0.65
                           and trunc(last_reading_datime) + 1 = trunc(w_blln.period_from_date); -- Add 1513 --2.0.0.01B --1.0.0.65
                        if w_last_reading is not null                                      -- Add 1513 --2.0.0.01B --1.0.0.65
                        then                                                               -- Add 1513 --2.0.0.01B --1.0.0.65
                           w_ptbm.last_billed_reading := w_last_reading;                   -- Add 1513 --2.0.0.01B --1.0.0.65
                        end if;                                                            -- Add 1513 --2.0.0.01B --1.0.0.65
                     end if;                                                               -- Add 1513 --2.0.0.01B --1.0.0.65
                                                                                           -- Add 2.0.0.0
                     w_additive_period_from_date := trunc(w_blln.period_from_date);        -- Add 2.0.0.0
                                                                                           -- Add 2.0.0.0
                     w_ptbm.billed_qty := nvl(w_ptbm.this_billed_reading,0)                -- Add 2.0.0.0
                                        - nvl(w_ptbm.last_billed_reading,0);               -- Add 2.0.0.0
                                                                                           -- Add 2.0.0.0
                     w_current_billed_qty  := w_ptbm.this_billed_reading - w_ptbm.last_billed_reading; --Add 3706
                     debug(w_procedure_name,w_label,' w_ptbm.last_billed_reading   '|| w_ptbm.last_billed_reading);
                     debug(w_procedure_name,w_label,' w_ptbm.this_billed_reading   '|| w_ptbm.this_billed_reading);
                     debug(w_procedure_name,w_label,' w_ptbm.billed_qty '|| w_ptbm.billed_qty);
                     -- Add 2275
                     if w_ptbm.billed_qty < 0 then                                                                  -- Add 2275
                        w_label := 'e155';
                        trace_label(w_label, w_procedure_name);
                        w_max_reading_mtr := '9';                                                                   -- Add 2275
                        begin                                                                                       -- Add 2275
                           select rpad(w_max_reading_mtr,number_dials,'9') into w_max_reading_mtr                   -- Add 2275
                           from cis_meter_regs                                                                      -- Add 2275
                           where meter_id       = w_additive_meter_id                                               -- Add 2275
                           and meter_reg_num    = w_additive_mtr_reg_num;                                           -- Add 2275
                                                                                                                    -- Add 2275
                           debug(w_procedure_name,w_label,' w_max_reading_mtr            '|| w_max_reading_mtr);
                           debug(w_procedure_name,w_label,' w_ptbm.last_billed_reading   '|| w_ptbm.last_billed_reading);
                           debug(w_procedure_name,w_label,' w_ptbm.this_billed_reading   '|| w_ptbm.this_billed_reading);
                           w_ptbm.billed_qty := (to_number(trim(w_max_reading_mtr))+1) -                            -- Add 2275
                                               nvl(w_ptbm.last_billed_reading,(to_number(trim(w_max_reading_mtr))+1)) +  -- Add 2275
                                               w_ptbm.this_billed_reading;                                          -- Add 2275
                           w_current_billed_qty  := w_ptbm.billed_qty; --Add 3706
                           debug(w_procedure_name,w_label,' w_ptbm.billed_qty '|| w_ptbm.billed_qty);
                        exception                                                                                   -- Add 2275
                           when others then                                                                         -- Add 2275
                              debug(w_procedure_name,w_label,' Error :- '|| sqlcode || ' ' ||Sqlerrm );             -- Add 2275
                        end;                               -- Add 2275
                     end if;                               -- Add 2275
                     -- Add 2275
                     w_ptbm.est_this_rdg_flag := w_est_reading_ind;                                                 -- Add 2.0.0.0
                     if w_prior_estimates_cnt > 0 then                                                              -- Add 2.0.0.0
                        w_ptbm.est_last_rdg_flag   :=  'E';
                     else
                        w_ptbm.est_last_rdg_flag   :=  null;
                     end if;
                     --debug(w_procedure_name,w_label,'  w_ptbm.est_this_rdg_flag '|| w_ptbm.est_this_rdg_flag );
                     --debug(w_procedure_name,w_label,'  w_prior_estimates_cnt    '|| w_prior_estimates_cnt   );
                     --debug(w_procedure_name,w_label,'  w_est_reading_ind     '|| w_est_reading_ind   );
                     --debug(w_procedure_name,w_label,'  w_ptbm.est_last_rdg_flag '||w_ptbm.est_last_rdg_flag );
                  end if;                                                                  -- Add 818
                  if w_blln.reading_type <> nvl(w_last_reading_type, 'z') then           -- Add 542
                     --trace_label('e156', w_procedure_name);
                     --select cust_own_reading_ind into w_cust_own_reading_ind             -- Add 542
                     --  from cis_reading_types                                            -- Add 542
                     -- where reading_type = w_blln.reading_type;                          -- Add 542
                     --Start Add --2990
                     for r1 in ( select cust_own_reading_ind
                                 from cis_reading_types
                                where reading_type = w_blln.reading_type
                             )
                     loop
                        if r1.cust_own_reading_ind = 'Y' then
                           w_cust_own_reading_ind  := r1.cust_own_reading_ind;
                           exit;
                        end if;
                     end loop;
                     --End Add --2990
                     w_last_reading_type := w_blln.reading_type;                         -- Add 542
                     w_last_cust_own_reading_ind := w_cust_own_reading_ind;              -- Add 542
                  else                                                                   -- Add 542
                  ---trace_label('e157', w_procedure_name);
                     w_cust_own_reading_ind := w_last_cust_own_reading_ind;              -- Add 542
                  end if;
                  ----
                  ---- Adding 1411 --1.0.0.51
                  ----
                  ---Rotate
                  if w_blln.tran_qty is null and w_blln.meter_works_id is not null
                  then
                     trace_label('e158', w_procedure_name);
                     w_doing_meter_rotated := true;
                     w_doing_meter_current := false;
                     w_doing_meter_deleted := false;
                     debug(w_procedure_name,w_label,'Should be replace w_blln.outreader_serial_no '|| w_blln.outreader_serial_no);
                     -- This is a meter and/or ert rotate
                     -- There may be multiple in a period and if so the most recent comes first in the bill lines
                     if w_ptbm.repl_meter_key is null
                     then
                        w_ptbm.repl_reading_from_date   := trunc(w_blln.prior_last_billed_rdg_datime);
                        w_ptbm.repl_reading_upto_date   := trunc(w_blln.reading_datime);
                        w_ptbm.repl_last_billed_reading := w_blln.prior_last_billed_reading;
                     else
                        w_ptbm.repl_reading_from_date   := trunc(w_blln.prior_last_billed_rdg_datime);
                        w_ptbm.repl_last_billed_reading := w_blln.prior_last_billed_reading;
                     end if;
                     w_ptbm.repl_meter_key  := w_blln.meter_key;
                     g_repl_meter_key_10chr	:= w_blln.meter_key_10chr;                 -- Add 11138
                     g_repl_meter_id				:= w_blln.meter_id;												 -- Add 11138
                     w_ptbm.repl_billed_qty := nvl(w_ptbm.repl_billed_qty,0)
                                             + nvl(w_blln.meter_advance,0);
                     w_ptbm.repl_this_billed_reading := w_ptbm.repl_last_billed_reading
                                                      + nvl(w_ptbm.repl_billed_qty,0);
                     w_ptbm.repl_ert_key := w_blln.outreader_serial_no;  --Add 3706
                     --
                     --
                     --
                     if w_blln.db_scnd_type = 'RDG' then
                        w_label := 'e159';
                        trace_label(w_label, w_procedure_name);
                        w_rpl_qty_bi                                := to_number(to_char(trunc(w_blln.reading_datime),'YYYYMMDD')); --Add 3706 --w_rpl_qty_bi + 1;     --Add 2417
                        w_rpl_qty_tbl(w_rpl_qty_bi).bill_key        := w_ptbm.bill_key;                                                                         --Add 2417
                        w_rpl_qty_tbl(w_rpl_qty_bi).qty             := w_ptbm.repl_billed_qty;                                                                  --Add 2417
                        w_rpl_qty_tbl(w_rpl_qty_bi).db_scnd_type    := w_blln.db_scnd_type;                                                                     --Add 2417
                        w_rpl_qty_tbl(w_rpl_qty_bi).from_rdg_date   := trunc(nvl(w_blln.prior_last_real_bld_rdg_datime,w_blln.prior_last_billed_rdg_datime));   --Add 3706
                        w_rpl_qty_tbl(w_rpl_qty_bi).upto_rdg_date   := trunc(w_blln.reading_datime);                                                            --Add 3706
                        w_rpl_qty_tbl(w_rpl_qty_bi).meter_key       := w_ptbm.repl_meter_key;                                                                   --Add 3706
                        w_rpl_qty_tbl(w_rpl_qty_bi).meter_key_10chr := g_repl_meter_key_10chr;    --Add 11138
                        w_rpl_qty_tbl(w_rpl_qty_bi).meter_id        := g_repl_meter_id;           --Add 11138
                        w_rpl_qty_tbl(w_rpl_qty_bi).ert_no          := w_blln.outreader_serial_no;                                                              --Add 3706
                        w_rpl_qty_tbl(w_rpl_qty_bi).from_reading    := nvl(w_blln.prior_last_real_billed_reading,w_blln.prior_last_billed_reading);             --Add 3706
                        w_rpl_qty_tbl(w_rpl_qty_bi).meter_advance   := w_blln.meter_advance;                                                                    --Add 3706
                        debug(w_procedure_name,w_label,' w_rpl_qty_ bi '|| w_rpl_qty_bi );
                     end if;
                     debug(w_procedure_name,w_label,' w_rpl_qty_bi '|| w_rpl_qty_bi );
                     --w_ptbm.repl_billed_qty := null; --Del 3706 ---Since we are not printing Old Meters consumption.
                     w_ptbm.est_repl_this_rdg_flag   :=  w_blln.est_reading_ind;             -- Add 2.0.0.0
                     debug(w_procedure_name,w_label,' w_blln.prior_estimates_cnt '|| w_blln.prior_estimates_cnt );
                     if w_blln.prior_estimates_cnt > 0 then                                  -- Add 2.0.0.0
                        w_ptbm.est_repl_last_rdg_flag   :=  'E';                             -- Add 2.0.0.0
                     else                                                                    -- Add 2.0.0.0
                        w_ptbm.est_repl_last_rdg_flag   :=  null;                            -- Add 2.0.0.0
                     end if;                                                                 -- Add 2.0.0.0
                     --debug(w_procedure_name,w_label,' w_blln.est_reading_ind        '|| w_blln.est_reading_ind        );
                     --debug(w_procedure_name,w_label,' w_ptbm.est_repl_this_rdg_flag '|| w_ptbm.est_repl_this_rdg_flag );
                     --debug(w_procedure_name,w_label,' w_blln.est_reading_ind        '|| w_blln.est_reading_ind        );
                     --debug(w_procedure_name,w_label,' w_blln.prior_estimates_cnt   '|| w_blln.prior_estimates_cnt  );
                     --debug(w_procedure_name,w_label,' w_ptbm.est_repl_last_rdg_flag '|| w_ptbm.est_repl_last_rdg_flag  );
                  end if;
                  ----
                  ---- Finish 1411 --1.0.0.51
                  ----
               end if;     --end if of if w_blln.db_scnd_type = 'RDG'
            else     --For Not Meter Groups                ---Add 1353
                -- Start Add 1129
                -- Complete re-write of decision process for dates and readings
                -- Include meter group decision and other decisions from above
                -- Allow for meter rotates
                -- Use meter advance
                -- Even though there are gallon meters with factors they are virtual meters
                -- In a bill readings are processed in order
                -- Rotated - Current - Deleted
                -- In each case if there estimate reversals pertinent to a meter they follow it
                w_label := 'e160';
                trace_label(w_label, w_procedure_name);
                if w_blln.db_scnd_type = 'RDG'
                then
                  ---Meter Rotate
                  if w_blln.tran_qty is null and w_blln.meter_works_id is not null
                  then
                     w_label := 'e161';
                     trace_label(w_label, w_procedure_name);
                     w_doing_meter_rotated := true;
                     w_doing_meter_current := false;
                     w_doing_meter_deleted := false;
                     debug(w_procedure_name,w_label,'w_ptbm.repl_meter_key '|| w_ptbm.repl_meter_key);
                     -- This is a meter and/or ert rotate
                     -- There may be multiple in a period and if so the most recent comes first in the bill lines
                     if w_ptbm.repl_meter_key is null
                     then
                        w_label := 'e162';
                        trace_label(w_label, w_procedure_name);
                        w_ptbm.repl_reading_from_date   := trunc(w_blln.prior_last_billed_rdg_datime);
                        w_ptbm.repl_reading_upto_date   := trunc(w_blln.reading_datime);
                        w_ptbm.repl_last_billed_reading := w_blln.prior_last_billed_reading;
                     else
                        w_label := 'e163';
                        trace_label(w_label, w_procedure_name);
                        w_ptbm.repl_reading_from_date   := trunc(w_blln.prior_last_billed_rdg_datime);
                        w_ptbm.repl_last_billed_reading := w_blln.prior_last_billed_reading;
                     end if;
                     if w_blln.est_reading_ind is null  -- Real reading to make w_ptbm.repl_this_billed_reading correct  -- Add 2109 --2.0.0.07 --1.0.0.68
                     and (w_blln.prior_estimates_cnt is null or w_blln.prior_estimates_cnt = 0)      -- Add 2842
                     then                                                                                -- Add 2109 --2.0.0.07 --1.0.0.68
                        w_label := 'e164';
                        trace_label(w_label, w_procedure_name);
                        w_ptbm.repl_reading_from_date   := trunc(w_blln.prior_last_real_bld_rdg_datime); -- Add 2109 --2.0.0.07 --1.0.0.68
                        w_ptbm.repl_last_billed_reading := w_blln.prior_last_real_billed_reading;        -- Add 2109 --2.0.0.07 --1.0.0.68
                     end if;                                                                             -- Add 2109 --2.0.0.07 --1.0.0.68
                     w_ptbm.repl_meter_key  := w_blln.meter_key;
                     g_repl_meter_key_10chr	:= w_blln.meter_key_10chr;                 									-- Add 11138
                     g_repl_meter_id				:= w_blln.meter_id;                 											  -- Add 11138
                     if (w_blln.prior_estimates_cnt is null or w_blln.prior_estimates_cnt = 0) then     -- Add 2842
                        w_label := 'e165';
                        trace_label(w_label, w_procedure_name);
                        w_ptbm.repl_billed_qty := nvl(w_ptbm.repl_billed_qty,0)
                                                + w_blln.meter_advance;
                     else                                                                               -- Add 2842
                        w_label := 'e166';
                        trace_label(w_label, w_procedure_name);
                        w_ptbm.repl_billed_qty := nvl(w_ptbm.repl_billed_qty,0)                         -- Add 2842
                                                + w_blln.meter_advance                                  -- Add 2842
                                                - w_blln.prior_last_billed_reading                      -- Add 2842
                                                + w_blln.prior_last_real_billed_reading;                -- Add 2842
                     end if;                                                                            -- Add 2842
                     w_ptbm.repl_this_billed_reading := w_ptbm.repl_last_billed_reading
                                                      + w_ptbm.repl_billed_qty
                                                      ;
                     --w_ptbm.repl_ert_key     := w_blln.outreader_serial_no;  --Del 3154 --Add 2.0.0.0
                     w_label := 'e167';
                     trace_label(w_label, w_procedure_name);
                     debug_trace(w_procedure_name,'In replace meter w_blln.outreader_serial_no:' ||w_blln.outreader_serial_no);
                     debug(w_procedure_name,w_label,'w_ptbm.repl_ert_key '|| w_ptbm.repl_ert_key);
                     --Start Add 3706 --Start Add 3154
                     --if w_ptbm.repl_ert_key is null and w_blln.outreader_serial_no is not null then
                     --   if nvl(w_ptbm.ert_key,'xxx') != w_blln.outreader_serial_no then
                     w_ptbm.repl_ert_key := w_blln.outreader_serial_no;
                     --   end if;
                     --end if;
                     --End Add 3706 --End Add 3154
                     debug(w_procedure_name,w_label,' w_ptbm.ert_key      '|| w_ptbm.ert_key);
                     debug(w_procedure_name,w_label,' w_ptbm.repl_ert_key '|| w_ptbm.repl_ert_key);
                     debug(w_procedure_name,w_label,' w_blln.prior_estimates_cnt '|| w_blln.prior_estimates_cnt );
                     w_ptbm.est_repl_this_rdg_flag   :=  w_blln.est_reading_ind;              --Chg 3706 -- Add 2.0.0.0
                     if w_blln.prior_estimates_cnt > 0 then                                   --Chg 3706 -- Add 2.0.0.0 --Del 2842
                        w_label := 'e168';
                        trace_label(w_label, w_procedure_name);
                        w_ptbm.est_repl_last_rdg_flag   :=  'E';                              --Chg 3706 -- Add 2.0.0.0 --Del 2842
                     else                                                                     --Chg 3706 -- Add 2.0.0.0 --Del 2842
                        w_label := 'e169';
                        trace_label(w_label, w_procedure_name);
                        w_ptbm.est_repl_last_rdg_flag   :=  null;                             --Chg 3706 -- Add 2.0.0.0 --Del 2842
                     end if;                                                                  --Chg 3706 -- Add 2.0.0.0 --Del 2842
                     if w_blln.db_scnd_type = 'RDG' then
                        w_label := 'e170';
                        trace_label(w_label, w_procedure_name);
                        w_rpl_qty_bi                               := to_number(to_char(trunc(w_blln.reading_datime),'YYYYMMDD')); --Add 3706 --w_rpl_qty_bi + 1;                --Add 2417
                        w_rpl_qty_tbl(w_rpl_qty_bi).bill_key       := w_ptbm.bill_key;                                                              --Add 2417
                        w_rpl_qty_tbl(w_rpl_qty_bi).qty            := w_ptbm.repl_billed_qty;                                                       --Add 2417
                        w_rpl_qty_tbl(w_rpl_qty_bi).db_scnd_type   := w_blln.db_scnd_type;                                                          --Add 2417
                        w_rpl_qty_tbl(w_rpl_qty_bi).from_rdg_date  := trunc(nvl(w_blln.prior_last_real_bld_rdg_datime,w_blln.prior_last_billed_rdg_datime));   --Add 3706
                        w_rpl_qty_tbl(w_rpl_qty_bi).upto_rdg_date  := trunc(w_blln.reading_datime);                                                 --Add 3706
                        w_rpl_qty_tbl(w_rpl_qty_bi).meter_key      := w_ptbm.repl_meter_key;                                                        --Add 3706
                        w_rpl_qty_tbl(w_rpl_qty_bi).meter_key_10chr    := g_repl_meter_key_10chr;    --Add 11138
                        w_rpl_qty_tbl(w_rpl_qty_bi).meter_id           := g_repl_meter_id;           --Add 11138
                        w_rpl_qty_tbl(w_rpl_qty_bi).ert_no         := w_blln.outreader_serial_no;                                                   --Add 3706
                        w_rpl_qty_tbl(w_rpl_qty_bi).from_reading   := nvl(w_blln.prior_last_real_billed_reading,w_blln.prior_last_billed_reading);  --Add 3706
                        w_rpl_qty_tbl(w_rpl_qty_bi).meter_advance  := w_blln.meter_advance;                                                         --Add 3706
                     end if;
                     --bll.line_num
                     --debug(w_procedure_name,w_label,' [4] w_blln.est_reading_ind        '|| w_blln.est_reading_ind        );
                     --debug(w_procedure_name,w_label,' [4] w_blln.est_reading_ind        '|| w_blln.est_reading_ind        );
                     --debug(w_procedure_name,w_label,' [4] w_ptbm.est_repl_this_rdg_flag '|| w_ptbm.est_repl_this_rdg_flag );
                     --debug(w_procedure_name,w_label,' [4] w_blln.prior_estimates_cnt   '|| w_blln.prior_estimates_cnt  );
                     --debug(w_procedure_name,w_label,' [4] w_ptbm.est_repl_last_rdg_flag '|| w_ptbm.est_repl_last_rdg_flag  );
                  end if;
                  ---Meter Current
                  if w_blln.tran_qty is not null and w_blln.meter_works_id is null
                  then
                     w_label := 'e171';
                     trace_label(w_label, w_procedure_name);
                     w_doing_meter_rotated 	:= false;
                     w_doing_meter_current 	:= true;
                     w_doing_meter_deleted 	:= false;
                     w_ptbm.meter_key    		:= w_blln.meter_key;
                     g_meter_key_10chr			:= w_blln.meter_key_10chr;                 -- Add 11138
                     g_meter_id       			:= w_blln.meter_id;                 			 -- Add 11138
                     -- Store deleted meter in repl if it is free
                     w_ptbm.reading_from_date   := trunc(w_blln.prior_last_billed_rdg_datime);
                     w_ptbm.reading_upto_date   := trunc(w_blln.reading_datime);
                     w_ptbm.last_billed_reading := w_blln.prior_last_billed_reading;
                     w_ptbm.this_billed_reading := w_blln.meter_reading;
                     --w_ptbm.billed_qty          := nvl(w_ptbm.billed_qty,0)
                     --                            + w_blln.meter_advance;     --Del 2417
                     w_current_billed_qty       := w_ptbm.this_billed_reading - w_ptbm.last_billed_reading; --Add 3706
                     debug(w_procedure_name,w_label,' Before w_ptbm.billed_qty     '|| w_ptbm.billed_qty);
                     debug(w_procedure_name,w_label,'  w_blln.tran_qty             '|| w_blln.tran_qty);
                     debug(w_procedure_name,w_label,'  w_ptbm.last_billed_reading  '|| w_ptbm.last_billed_reading);
                     debug(w_procedure_name,w_label,'  w_ptbm.this_billed_reading  '|| w_ptbm.this_billed_reading);
                     w_ptbm.billed_qty          := nvl(w_ptbm.billed_qty,0)
                                                 + nvl(w_blln.tran_qty,0);   --Add 2417
                     --w_ptbm.billed_qty            := nvl(w_ptbm.this_billed_reading,0) - nvl(w_ptbm.last_billed_reading,0);
                     debug(w_procedure_name,w_label,'  w_ptbm.billed_qty           '|| w_ptbm.billed_qty);
                     debug(w_procedure_name,w_label,'  w_current_billed_qty        '|| w_current_billed_qty);
                     w_est_reading_ind          := w_blln.est_reading_ind;
                     w_fault_code               := w_blln.fault_code;
                     --w_ptbm.ert_key             := w_blln.outreader_serial_no;  Del 3154 --Add 2.0.0.0
                     --Start Add 3706
                     debug(w_procedure_name,w_label,' w_ptbm.ert_key '|| w_ptbm.ert_key);
                     --if w_ptbm.ert_key is null and w_blln.outreader_serial_no is not null then
                     --   if nvl(w_ptbm.repl_ert_key,'xxx') != w_blln.outreader_serial_no then
                     w_ptbm.ert_key := w_blln.outreader_serial_no;
                     --   end if;
                     --end if;
                     debug(w_procedure_name,w_label,' ptbm.ert_key '|| w_ptbm.ert_key);
                     --End Add 3706
                     if w_blln.reading_type <> nvl(w_last_reading_type, 'z') then
                        select cust_own_reading_ind into w_cust_own_reading_ind
                        from cis_reading_types
                        where reading_type = w_blln.reading_type;
                        w_last_reading_type := w_blln.reading_type;
                        w_last_cust_own_reading_ind := w_cust_own_reading_ind;
                     else
                        w_cust_own_reading_ind := w_last_cust_own_reading_ind;
                     end if;
                     w_ptbm.est_this_rdg_flag   :=  w_blln.est_reading_ind;            -- Add 2.0.0.0
                     if w_blln.prior_estimates_cnt > 0 then                            -- Add 2.0.0.0
                        w_ptbm.est_last_rdg_flag   :=  'E';                            -- Add 2.0.0.0
                     else                                                              -- Add 2.0.0.0
                        w_ptbm.est_last_rdg_flag   :=  null;                           -- Add 2.0.0.0
                     end if;
                     --debug(w_procedure_name,w_label,' [5] w_ptbm.est_this_rdg_flag  '|| ---w_ptbm.est_this_rdg_flag );
                     --debug(w_procedure_name,w_label,' [5] w_blln.est_reading_ind  '|| w_blln.est_reading_ind  );
                     --debug(w_procedure_name,w_label,' [5] w_blln.prior_estimates_cnt '|| w_blln.prior_estimates_cnt);
                     --debug(w_procedure_name,w_label,' [5] w_ptbm.est_last_rdg_flag  '|| w_ptbm.est_last_rdg_flag );
                     --if w_blln.db_scnd_type = 'RDG' then
                     --   w_curr_qty_bi                                := to_number(to_char(trunc(w_blln.reading_datime),'YYYYMMDD')); --Add 3706 --w_rpl_qty_bi + 1;                --Add 2417
                     --   w_curr_qty_tbl(w_curr_qty_bi).bill_key       := w_ptbm.bill_key;                                                              --Add 2417
                     --   w_curr_qty_tbl(w_curr_qty_bi).qty            := w_ptbm.repl_billed_qty;                                                       --Add 2417
                     --   w_curr_qty_tbl(w_curr_qty_bi).db_scnd_type   := w_blln.db_scnd_type;                                                          --Add 2417
                     --   w_curr_qty_tbl(w_curr_qty_bi).from_rdg_date  := trunc(nvl(w_blln.prior_last_real_bld_rdg_datime,w_blln.prior_last_billed_rdg_datime));   --Add 3706
                     --   w_curr_qty_tbl(w_curr_qty_bi).upto_rdg_date  := trunc(w_blln.reading_datime);                                                 --Add 3706
                     --   w_curr_qty_tbl(w_curr_qty_bi).meter_key      := w_ptbm.repl_meter_key;                                                        --Add 3706
                     --   w_curr_qty_tbl(w_curr_qty_bi).ert_no         := w_blln.outreader_serial_no;                                                   --Add 3706
                     --   w_curr_qty_tbl(w_curr_qty_bi).from_reading   := nvl(w_blln.prior_last_real_billed_reading,w_blln.prior_last_billed_reading);  --Add 3706
                     --   w_curr_qty_tbl(w_curr_qty_bi).meter_advance  := w_blln.meter_advance;                                                         --Add 3706
                     --end if;
                  end if;
                  -- Meter Deleted
                  if w_blln.tran_qty is not null and w_blln.meter_works_id is not null
                  then
                     w_label := 'e172';
                     trace_label(w_label, w_procedure_name);
                     w_doing_meter_rotated := false;
                     w_doing_meter_current := false;
                     w_doing_meter_deleted := true;
                     debug(w_procedure_name,w_label,'In Deleted  Should be replace w_blln.outreader_serial_no '|| w_blln.outreader_serial_no);
                     -- Store deleted meter in repl if it is free
                     if w_ptbm.repl_meter_key is null
                     then
                        w_label := 'e173';
                        trace_label(w_label, w_procedure_name);
                        w_ptbm.repl_meter_key       := w_blln.meter_key;
                        g_repl_meter_key_10chr			:= w_blln.meter_key_10chr;                 -- Add 11138
                        g_repl_meter_id       			:= w_blln.meter_id;                 			 -- Add 11138
                        w_ptbm.repl_reading_from_date   := trunc(w_blln.prior_last_billed_rdg_datime);
                        w_ptbm.repl_reading_upto_date   := trunc(w_blln.reading_datime);
                        w_ptbm.repl_last_billed_reading := w_blln.prior_last_billed_reading;
                        w_ptbm.repl_this_billed_reading := w_blln.meter_reading;
                        --w_ptbm.repl_billed_qty          := nvl(w_ptbm.repl_billed_qty,0) --Del 2417
                        --                                 + w_blln.meter_advance;    --Del 2417
                        w_ptbm.repl_billed_qty          := nvl(w_ptbm.repl_billed_qty,0)  --Add 2417
                                                         + nvl(w_blln.tran_qty,0);        --Add 2417
                        w_label := 'e174';
                        debug_trace(w_procedure_name,'In Deleted Replace Meter w_blln.outreader_serial_no:' ||w_blln.outreader_serial_no);
                        debug(w_procedure_name,w_label,' [**999.11**] w_ptbm.ert_key '|| w_ptbm.ert_key);
                        --Start Add 3706 --Start Add 3154
                        --if w_ptbm.repl_ert_key is null and w_blln.outreader_serial_no is not null then
                        --   if nvl(w_ptbm.ert_key,'xxx') != w_blln.outreader_serial_no then
                        w_ptbm.repl_ert_key := w_blln.outreader_serial_no;
                        --   end if;
                        --end if;
                        debug(w_procedure_name,w_label,' [**999.55**] w_ptbm.ert_key '|| w_ptbm.ert_key);
                        --End Add 3706 --End Add 3154
                        --w_ptbm.repl_ert_key             := w_blln.outreader_serial_no;    --Del 3706 --Add 2.0.0.0
                     else
                        w_label := 'e175';
                        trace_label(w_label, w_procedure_name);
                        -- Otherwise just add in advance
                        --w_ptbm.repl_billed_qty          := nvl(w_ptbm.repl_billed_qty,0)   --Del 2417
                        --                                 + w_blln.meter_advance;           --Del 2417
                        w_ptbm.repl_billed_qty          := nvl(w_ptbm.repl_billed_qty,0)  --Add 2417
                                                         + nvl(w_blln.tran_qty,0);        --Add 2417
                     end if;
                     if w_blln.db_scnd_type = 'RDG' then
                        w_label := 'e176';
                        trace_label(w_label, w_procedure_name);
                        w_rpl_qty_bi                               := to_number(to_char(trunc(w_blln.reading_datime),'YYYYMMDD')); --Add 3706 --w_rpl_qty_bi + 1;                --Add 2417
                        w_rpl_qty_tbl(w_rpl_qty_bi).bill_key       := w_ptbm.bill_key;                                                              --Add 2417
                        w_rpl_qty_tbl(w_rpl_qty_bi).qty            := w_ptbm.repl_billed_qty;                                                       --Add 2417
                        w_rpl_qty_tbl(w_rpl_qty_bi).db_scnd_type   := w_blln.db_scnd_type;                                                          --Add 2417
                        w_rpl_qty_tbl(w_rpl_qty_bi).from_rdg_date  := trunc(nvl(w_blln.prior_last_real_bld_rdg_datime,w_blln.prior_last_billed_rdg_datime));   --Add 3706
                        w_rpl_qty_tbl(w_rpl_qty_bi).upto_rdg_date  := trunc(w_blln.reading_datime);                                                 --Add 3706
                        w_rpl_qty_tbl(w_rpl_qty_bi).meter_key      := w_ptbm.repl_meter_key;                                                        --Add 3706
                        w_rpl_qty_tbl(w_rpl_qty_bi).meter_key_10chr    := g_repl_meter_key_10chr;    --Add 11138
                        w_rpl_qty_tbl(w_rpl_qty_bi).meter_id           := g_repl_meter_id;           --Add 11138
                        w_rpl_qty_tbl(w_rpl_qty_bi).ert_no         := w_blln.outreader_serial_no;                                                   --Add 3706
                        w_rpl_qty_tbl(w_rpl_qty_bi).from_reading   := nvl(w_blln.prior_last_real_billed_reading,w_blln.prior_last_billed_reading);  --Add 3706
                        w_rpl_qty_tbl(w_rpl_qty_bi).meter_advance  := w_blln.meter_advance;                                                         --Add 3706
                     end if;
                     w_ptbm.est_repl_this_rdg_flag             := w_blln.est_reading_ind;          --Add 2.0.0.0
                     debug(w_procedure_name,w_label,' [**999.99**] w_blln.prior_estimates_cnt '|| w_blln.prior_estimates_cnt );
                     if w_blln.prior_estimates_cnt > 0 then                                -- Add 2.0.0.0
                        w_ptbm.est_repl_last_rdg_flag   :=  'E';                           -- Add 2.0.0.0
                     else                                                                  -- Add 2.0.0.0
                        w_ptbm.est_repl_last_rdg_flag   :=  null;                          -- Add 2.0.0.0
                     end if;                                                               -- Add 2.0.0.0
                     --debug(w_procedure_name,w_label,' [6] w_ptbm.est_this_rdg_flag      '|| w_ptbm.est_this_rdg_flag    );
                     --debug(w_procedure_name,w_label,' [6] w_ptbm.est_repl_this_rdg_flag  '|| w_ptbm.est_repl_this_rdg_flag);
                     --debug(w_procedure_name,w_label,' [6] w_blln.prior_estimates_cnt   '|| w_blln.prior_estimates_cnt   );
                     --debug(w_procedure_name,w_label,' [6] w_ptbm.est_repl_last_rdg_flag  '|| w_ptbm.est_repl_last_rdg_flag);
                  end if;  -- Meter Deleted
               end if;  --End if of if w_blln.db_scnd_type = 'RDG'
               --
               -- Reversal Entries --
               --
               if w_blln.db_scnd_type = 'RER'
               then
                  if w_doing_meter_current
                  or w_doing_meter_rotated                                                           -- Add 2842
                  then
                     w_label := 'e177';
                     trace_label(w_label, w_procedure_name);
                     debug(w_procedure_name,w_label,' [**4**] w_blln.outreader_serial_no '|| w_blln.outreader_serial_no);
                     debug(w_procedure_name,w_label,' [**4**] w_ptbm.billed_qty          '|| w_ptbm.billed_qty);
                     debug(w_procedure_name,w_label,' [**4**] w_blln.tran_qty            '|| w_blln.tran_qty);
                     debug(w_procedure_name,w_label,' [**4**] w_current_billed_qty       '|| w_current_billed_qty);
                     -- This estiamte reversal belongs to the current meter
                     -- So adjust current meter fields
                     w_ptbm.reading_from_date   := trunc(w_blln.reading_datime);
                     w_ptbm.last_billed_reading := w_blln.meter_reading;
                     --w_ptbm.billed_qty          := nvl(w_ptbm.billed_qty,0)
                     --                            + w_blln.meter_advance;    --Del 2417
                     w_ptbm.billed_qty          := nvl(w_ptbm.billed_qty,0)
                                                 + nvl(w_blln.tran_qty,0);    --Add 2417
                     w_current_billed_qty       := w_ptbm.billed_qty;         --Add 3706
                     debug(w_procedure_name,w_label,' [**4.1**] w_ptbm.billed_qty      '|| w_ptbm.billed_qty);
                     debug(w_procedure_name,w_label,' [**4.1**] w_blln.tran_qty        '|| w_blln.tran_qty);
                     debug(w_procedure_name,w_label,' [**4.1**] w_current_billed_qty   '|| w_current_billed_qty);
                  end if;
                  if w_doing_meter_deleted
                  then
                     w_label := 'e178';
                     trace_label(w_label, w_procedure_name);
                     -- This estiamte reversal belongs to the deleted meter
                     -- So adjust repl meter fields
                     w_ptbm.repl_reading_from_date   := trunc(w_blln.reading_datime);
                     w_ptbm.repl_last_billed_reading := w_blln.meter_reading;
                  end if;
               end if;
               -- End Add 1129
            end if; ----- Meter Group ends here                --Add 1353
            --
            -- Sewer and Water Usages
            if w_blln.usec_code = 'SEW-USG' or w_blln.usec_code = 'WAT-USG' then    -- Add 2.0.0.0
               w_label := 'e179';
               trace_label(w_label, w_procedure_name);
               debug_trace(w_procedure_name, 'Before ..Water and Sewer Usage Charge   =' || w_ptbm.usage_charge_amnt);
               w_ptbm.usage_charge_amnt   := nvl(w_ptbm.usage_charge_amnt,0)   -- Add 2.0.0.0
                                          +  w_blln.db_line_tot_amnt           -- Add 2.0.0.0
                                          +  nvl(w_blln.usec_srvc_disc_amnt,0);-- Chg 2.0.0.05
               debug_trace(w_procedure_name, 'After ..Water and Sewer Usage Charge   =' || w_ptbm.usage_charge_amnt);
               debug_trace(w_procedure_name, '..Usage Service Discount Amount =' || w_blln.usec_srvc_disc_amnt);
            --
            -- Laundary and Industrial surcharge
            elsif w_blln.usec_code = 'LND-SUR' or w_blln.usec_code = 'IND-SUR' then -- Add 2.0.0.0
               w_label := 'e180';
               trace_label(w_label, w_procedure_name);
               w_ptbm.induschg    := nvl(w_ptbm.induschg,0)                -- Add 2.0.0.0
                                   + w_blln.db_line_tot_amnt               -- Add 2.0.0.0
                                   + nvl(w_blln.usec_srvc_disc_amnt,0);    -- Add 2527
            --
            -- Storm Water Charges
            elsif w_blln.usec_code = 'STM-USG' then                        -- Add 2.0.0.34
               w_label := 'e181';
               trace_label(w_label, w_procedure_name);
               w_ptbm.stormchg    := nvl(w_ptbm.stormchg,0)                -- Add 2.0.0.34
                                   + w_blln.db_line_tot_amnt               -- Add 2.0.0.34
                                   + nvl(w_blln.usec_srvc_disc_amnt,0);    -- Add 2527
            --debug_trace(w_procedure_name, '..Storm Usage Charge =' || w_ptbm.stormchg ); -- Add 2.0.0.34
            --null; --Not Implementing Storm Water till 2010
            --
            -- Ground Water Usage Charges
            elsif w_blln.usec_code = 'GRW-SWCG' then            -- Add 2301
               w_label := 'e182';
               debug_trace(w_procedure_name, '..Before Ground Water Usage Charge =' || w_ptbm.usage_charge_amnt ); -- Add 2301
               w_usec_code := w_blln.usec_code;  --Add 3706
               w_usg_line_hdng  := 'Groundwater Usage';
               w_ptbm.usage_charge_amnt := nvl(w_ptbm.usage_charge_amnt,0)      -- Add 2301
                                         + w_blln.db_line_tot_amnt              -- Add 2301
                                         + nvl(w_blln.usec_srvc_disc_amnt,0);   -- Add 2527
               debug_trace(w_procedure_name, '..After Ground Water Usage Charge =' || w_ptbm.usage_charge_amnt ); -- Add 2301
               --Start Add 3218
               if w_ptbm.reading_from_date is null then
                  w_label := 'e183';
                  trace_label(w_label, w_procedure_name);
                  w_ptbm.reading_from_date   := w_blln.period_from_date;
                  w_ptbm.reading_upto_date   := w_blln.period_upto_date;
               end if;
               --End Add 3218
               debug_trace(w_procedure_name, '.....[111].....Set the message for estimate reverse mssg =' || w_ptbm.usage_charge_amnt ); -- Add 2301
               w_prepare_est_rev_msg := true;             --Add 2524 --Moved from Down
            end if;
            -- Senior Discounts                                                     --Add 2.0.0.0
            -- PHA discounts are not considered b'cause PHA are group bills
            w_label := 'e184';
            debug_trace(w_procedure_name, '..w_blln.usec_srvc_disc_code =' || w_blln.usec_srvc_disc_code ); -- Add 2301
            debug_trace(w_procedure_name, '..w_blln.cust_type_code      =' || w_blln.cust_type_code      ); -- Add 2301
             --if (nvl(w_blln.usec_srvc_disc_code,'X') = 'STANDARD'  and    --Del 2366--Add 2.0.0.0
            if  w_blln.cust_type_code in ('A','C','D','E','N')             --Chg 2366--Add 2.0.0.0
            then
               w_label := 'e185';
               debug_trace(w_procedure_name, '..w_ptbm.discount_amnt       =' || w_ptbm.discount_amnt );
               w_ptbm.discount_amnt                                       --Add 2.0.0.0
                                        := nvl(w_ptbm.discount_amnt,0)    --Add 2.0.0.0
                                         + (nvl(w_blln.usec_srvc_disc_amnt,0) * -1);  --Chg 2.0.0.05 Add 2.0.0.0
               debug_trace(w_procedure_name, '..w_blln.usec_srvc_disc_amnt =' || w_blln.usec_srvc_disc_amnt);
               if    w_blln.cust_type_code = 'A' then w_ptbm.discount_lbl := 'PHA Discount';       --Add 2.0.0.04
               elsif w_blln.cust_type_code = 'C' then w_ptbm.discount_lbl := 'Charity Discount';             --Add 2.0.0.04
               elsif w_blln.cust_type_code = 'D' then w_ptbm.discount_lbl := 'Senior Citizen Discount';      --Add 2.0.0.04
               elsif w_blln.cust_type_code = 'E' then w_ptbm.discount_lbl := 'Board of Education Discount';  --Add 2.0.0.04
               elsif w_blln.cust_type_code = 'N' then w_ptbm.discount_lbl := 'University/Hospital Discount'; --Add 2.0.0.04
               end if;
            elsif abs(nvl(w_blln.usec_srvc_disc_amnt,0)) > 0 then                      --Add 2366
               w_label := 'e186';
               debug_trace(w_procedure_name, '..w_ptbm.discount_amnt       =' || w_ptbm.discount_amnt );
               w_ptbm.discount_amnt       := nvl(w_ptbm.discount_amnt,0)               --Add 2366
                                          + (nvl(w_blln.usec_srvc_disc_amnt,0) * -1);  --Add 2366
               w_ptbm.discount_lbl        := 'Discount';                               --Add 2366
               debug_trace(w_procedure_name, '..w_blln.usec_srvc_disc_amnt =' || w_blln.usec_srvc_disc_amnt);
            end if;
            -----
            -----Start of code added for 2109 --2.0.0.07 --1.0.0.68
            -----
            if w_blln.db_scnd_type in ('MIN', 'MIS', 'RDG', 'RDS')
            then
               if (nvl(w_blln.usec_srvc_disc_code,'X') = 'STANDARD'
                              and w_blln.cust_type_code='D')
               then
                  w_label := 'e187';
                  trace_label(w_label, w_procedure_name);
                  w_real_read_amnt := w_real_read_amnt
                                    + w_blln.db_line_tot_amnt
                                    + nvl(w_blln.usec_srvc_disc_amnt,0);
               else
                  w_label := 'e188';
                  trace_label(w_label, w_procedure_name);
                  w_real_read_amnt := w_real_read_amnt
                                    + w_blln.db_line_tot_amnt;
               end if;
            else                    -- ( 'REM', 'RER', 'RSM', 'RSR')
               --w_prepare_est_rev_msg := true; --Del 2524 Moved up in the if w_blln.usec_code = 'GRW-SWCG' condition
               w_label := 'e189';
               trace_label(w_label, w_procedure_name);
               if (nvl(w_blln.usec_srvc_disc_code,'X') = 'STANDARD'
                              and w_blln.cust_type_code='D')
               then
                  w_label := 'e190';
                  trace_label(w_label, w_procedure_name);
                  w_est_rev_amnt := w_est_rev_amnt
                                  + w_blln.db_line_tot_amnt
                                  + nvl(w_blln.usec_srvc_disc_amnt,0);
               else
                  w_label := 'e191';
                  trace_label(w_label, w_procedure_name);
                  w_est_rev_amnt := w_est_rev_amnt
                                  + w_blln.db_line_tot_amnt;
               end if;
               debug_trace(w_procedure_name, '.....w_est_rev_amnt=' || w_est_rev_amnt);
            end if;
            -----
            -----End of code added for 2109 --2.0.0.07 --1.0.0.68
            -----
         --
         -- Services
         elsif w_blln.db_scnd_type = 'SVC' then
            w_ptbm.srvc_size_code := w_blln.srvc_size_code;
            -- Start Add 1.0.0.38
            -- Set period dates for fire service bills
            -- These do not have readingg lines
            -- Where bills have a reading line it will set the dates
            if w_ptbm.reading_from_date is null then
               w_ptbm.reading_from_date   := w_blln.period_from_date;
               w_ptbm.reading_upto_date   := w_blln.period_upto_date;
            end if;
            -- End Add 1.0.0.38
            --
            --Sewer/water/Fire Service charges
            if nvl(w_blln.srvc_code,'XXX-XXXX') = 'SEW-SRVC' or nvl(w_blln.srvc_code,'XXX-XXXX') = 'WAT-SRVC'
            or nvl(w_blln.srvc_code,'XXX-XXXX') = 'SEW-RFSS' or nvl(w_blln.srvc_code,'XXX-XXXX') = 'WAT-RFSS'       --Add 3133/3423
            then  --Add 2.0.0.0
               w_ptbm.service_charge_amnt := nvl(w_ptbm.service_charge_amnt,0)
                                           + w_blln.db_line_tot_amnt                            --Add 2.0.0.0
                                           + nvl(w_blln.usec_srvc_disc_amnt,0);                --Chg 2.0.0.05
            elsif nvl(w_blln.srvc_code,'XXX-XXXX') = 'FIR-SRVC' then                                          --Add 2.0.0.0
               w_ptbm.fire_srvc_chg_amnt := nvl(w_ptbm.fire_srvc_chg_amnt,0)
                                         + w_blln.db_line_tot_amnt              							--Add 2.0.0.0
                                         + nvl(w_blln.usec_srvc_disc_amnt,0);     						--Add 9146.
            end if;                                                                                                 --Add 2.0.0.0
            --                                                                                                      --Add 2.0.0.0
            -- Discounts
            debug_trace(w_procedure_name, '..SVC w_blln.usec_srvc_disc_code =' || w_blln.usec_srvc_disc_code ); -- Add 2301
            debug_trace(w_procedure_name, '..SVC w_blln.cust_type_code      =' || w_blln.cust_type_code      ); -- Add 2301
            --if (nvl(w_blln.usec_srvc_disc_code,'X') = 'STANDARD'  and    --Del 2366--Add 2.0.0.0                         --Add 2.0.0.0
            if w_blln.cust_type_code in ('A','C','D','E','N')  then        --Chg 2366--Add 2.0.0.0
               w_label := 'e192';
               debug_trace(w_procedure_name, '..w_ptbm.discount_amnt       =' || w_ptbm.discount_amnt );
               w_ptbm.discount_amnt     := nvl(w_ptbm.discount_amnt,0)               --Add 2.0.0.0
                                      + (nvl(w_blln.usec_srvc_disc_amnt,0) * -1);  --Chg 2.0.0.05 Add 2.0.0.0
               debug_trace(w_procedure_name, '..w_blln.usec_srvc_disc_amnt       =' || w_blln.usec_srvc_disc_amnt);
               if  w_blln.cust_type_code   = 'A' then w_ptbm.discount_lbl := 'PHA Discount';       --Add 2.0.0.04
               elsif w_blln.cust_type_code = 'C' then w_ptbm.discount_lbl := 'Charity Discount';             --Add 2.0.0.04
               elsif w_blln.cust_type_code = 'D' then w_ptbm.discount_lbl := 'Senior Citizen Discount';      --Add 2.0.0.04
               elsif w_blln.cust_type_code = 'E' then w_ptbm.discount_lbl := 'Board of Education Discount';  --Add 2.0.0.04
               elsif w_blln.cust_type_code = 'N' then w_ptbm.discount_lbl := 'University/Hospital Discount'; --Add 2.0.0.04
               end if;
               --Start Add 3910 --Start Del 3706
               --if w_res_comm_ind = 'R' and w_blln.cust_type_code != 'A'then
               --   w_ptbm.discount_lbl := 'Senior Citizen Discount';
               --end if;
               --End Add 3910  --End Del 3706
            elsif abs(nvl(w_blln.usec_srvc_disc_amnt,0)) > 0 then        --Add 2366
               w_label := 'e193';
               debug_trace(w_procedure_name, '..w_ptbm.discount_amnt       =' || w_ptbm.discount_amnt );
               w_ptbm.discount_amnt     := nvl(w_ptbm.discount_amnt,0)           --Add 2366
                                        + (nvl(w_blln.usec_srvc_disc_amnt,0) * -1);  --Add 2366
               w_ptbm.discount_lbl      := 'Discount';           --Add 2366
               debug_trace(w_procedure_name, '..w_blln.usec_srvc_disc_amnt       =' || w_blln.usec_srvc_disc_amnt);
            end if;
         --
         -- Chargeable Extras
         elsif w_blln.db_scnd_type = 'CHX' then
            ---WRBCC credits
            if nvl(w_blln.db_sinv_code,'XXX') = 'CITYCRED' then           --Add 2.0.0.00
               w_ptbm.wrbcccred     := nvl(w_ptbm.wrbcccred,0)       --Add 2.0.0.00
                                    + (nvl(w_blln.db_line_tot_amnt,0)); --Chg 2.0.0.05 --Add 2.0.0.0
               --w_ptbm.debt_bal_amnt_cty := nvl(w_ptbm.debt_bal_amnt_cty,0) + (nvl(w_blln.db_line_tot_amnt,0)); --Del 3706 --Add 3706 --Bill Message for City Grant.
               -- Stromwater charges --'STRMWTR'             -- Del 2.0.0.34
               --elsif nvl(w_blln.db_sinv_code,'XXX') =  w_stromwat_chgs_pks then    -- Del 2.0.0.34--Add 2.0.0.0
               -- w_ptbm.stormchg     := nvl(w_ptbm.stormchg,0)       -- Del 2.0.0.34--Add 2.0.0.0
               --           + nvl(w_blln.db_line_tot_amnt,0);   -- Del 2.0.0.34--Add 2.0.0.0
               -- All other chargeable extras will be treated as Adjustments.
            else
               --w_ptbm.adjust     := nvl(w_ptbm.adjust,0)      --Del 2249 Add 2.0.0.0
               --         + nvl(w_blln.db_line_tot_amnt,0);   --Del 2249 Add 2.0.0.0
               w_ptbm.chxext    := nvl(w_ptbm.chxext,0)              --Add 2.0.0.22
                                 + nvl(w_blln.db_line_tot_amnt,0);   --Add 2.0.0.22
               w_chx_wo_dis    := 0;                 --Add 2634
               select nvl(min(attribute12),0) into w_chx_wo_dis from cis.cis_chexs     --Add 2634
               where  chex_key = w_blln.chex_key;               --Add 2634
               w_ptbm.chxext_wo_disc   := nvl(w_ptbm.chxext_wo_disc,0) + nvl(w_chx_wo_dis,0);--Add 2634
            end if;
            --
            -- Need to discuss about Sewer Credit
            --
            --w_ptbm.sewer_credit           := 0;
         --Start add 6230 3.0.0.41
         --ONC Online Cost --Discount becuase account is in TAP
         elsif w_blln.db_scnd_type = 'ONC' then
            w_ptbm.tap_disc   :=  nvl(w_blln.db_line_tot_amnt,0);
         --End add 6230 3.0.0.41
         end if;                                                                                                    --Add 2.0.0.0
      -- Messages for this bill
      elsif w_blln.line_type = 'T' then
         --debug_trace(w_procedure_name, 'Bill Message');
         --debug_trace(w_procedure_name, '..text =' || substr(w_blln.text_field,1,200));
         null;
         -- Gatemarks for this bill
      elsif w_blln.line_type = 'G' then
         --debug_trace(w_procedure_name, 'Gatemark Ignored');
         --debug_trace(w_procedure_name, '..text =' || substr(w_blln.text_field,1,200));
         null;
         -- Inter Account receipt allocations for this bill
         -- Treated as a receipt
      elsif w_blln.line_type = 'A' then
         debug_trace(w_procedure_name, 'Inter Account');
         debug_trace(w_procedure_name, '..Key  =' || w_blln.other_tran_key);
         debug_trace(w_procedure_name, '..Amt  =' || w_blln.other_tran_amnt);
         w_ptbm.last_paid_count       := nvl(w_ptbm.last_paid_count,0) + 1;
         --w_ptbm.last_paid_amnt        := nvl(w_ptbm.last_paid_amnt,0) + (w_blln.other_tran_amnt * -1);         -- Del 2.0.0.57 -- Chg 2.0.0.05
         w_ptbm.last_paid_amnt        := nvl(w_ptbm.last_paid_amnt,0) + (w_blln.other_tran_amnt);                -- Add 2.0.0.57
         w_ptbm.last_paid_date        := greatest(
                                                nvl(w_ptbm.last_paid_date,w_low_date)
                                               ,w_blln.other_tran_date
                                               );
      -- Rounding this bill
      elsif w_blln.line_type = 'R' then
         --debug_trace(w_procedure_name, 'Rounding Ignored');
         --debug_trace(w_procedure_name, '..other_tran_amnt =' || nvl(w_blln.other_tran_amnt,0));
         null;
      end if;
    end loop;
  ---- Add 1411 --1.0.0.51
  ----
  ------
  ------ For Meter Groups (Surcharge Accounts)
  ------ i.e. When there is no additive meters and Meter Group ID is not null
   if w_notfnd_additive and w_blln_meter_grp_rdg_id is not null then
      open c_mwos;
      loop
         fetch c_mwos into w_c_mwos;
         exit when c_mwos%notfound;
         ---
         --- Check MWOS Completion date equals to start reading date of New Meter
         ---   and new meter id = current meter id
         ---
         if w_c_mwos.complete_datime >= w_additive_period_from_date and
            w_c_mwos.new_meter_id    = w_additive_meter_id
         then
               begin
                  select substr(mtrs.meter_key,1,7) meter_key
                     ,mtrs.meter_key            			--Add 11138
                     ,mtrs.meter_id										--Add 11138
                     ,trunc(last_reading_datime)
                     ,trunc(reading_datime)
                     ,nvl(last_reading,0)
                     ,nvl(meter_reading,0)
                     --,nvl(meter_reading,0) - nvl(last_reading,0)
                  into
                     w_ptbm.repl_meter_key
                     ,g_repl_meter_key_10chr 							-- Add 11138
                     ,g_repl_meter_id											-- Add 11138
                     ,w_ptbm.repl_reading_from_date
                     ,w_ptbm.repl_reading_upto_date
                     ,w_ptbm.repl_last_billed_reading
                     ,w_ptbm.repl_this_billed_reading
                     --,w_ptbm.repl_billed_qty
                  from cis_wo_ub_meter_regs wumr,
                  cis_meters           mtrs
                     where
                     wumr.meter_id        = mtrs.meter_id
                     and wumr.meter_works_id  = w_c_mwos.meter_works_id
                     and wumr.meter_works_key = w_c_mwos.meter_works_key
                     and wumr.meter_id    = w_c_mwos.meter_id;
                  w_notfnd_replacement := false;
                  --debug(w_procedure_name,w_label,' [**8**] w_blln_tran_qty '|| w_blln_tran_qty);
                  if w_blln_tran_qty is not null then
                     w_ptbm.billed_qty := w_blln_tran_qty;
                     --debug(w_procedure_name,w_label,' [**8**] w_ptbm.billed_qty '|| w_ptbm.billed_qty);
                  end if;
               exception
                  when no_data_found then
                  w_ptbm.repl_meter_key      	:= null;
                  g_repl_meter_key_10chr			:= null;                 -- Add 11138
                  g_repl_meter_id							:= null;                 -- Add 11138
                  w_ptbm.repl_reading_from_date   := null;
                  w_ptbm.repl_reading_upto_date   := null;
                  w_ptbm.repl_last_billed_reading := null;
                  w_ptbm.repl_this_billed_reading := null;
                  --w_ptbm.repl_billed_qty    := null;
                  w_notfnd_replacement       := true;
               end;
         end if;
         exit;
      end loop;
      if c_mwos%isopen then
         close c_mwos;
      end if;
   end if; -- w_got_replacement
  --
  -- From Date for current meter should be workordercompletiondate + 1
  -- for replace meter in meter groups.
  --
  if w_blln_meter_grp_rdg_id is not null then
   if w_ptbm.repl_reading_upto_date is not null then
    w_ptbm.reading_from_date := w_ptbm.repl_reading_upto_date + 1;
   end if;
  end if;
    w_label := 'e194';
    if w_settl_ownr_bill then                                      -- Add 1.0.0.4
       close c_blln_psb;
    else
       close c_blln;
    end if;
   /* --Start Add 8000_8044 */
   debug(w_procedure_name,w_label,' [**Bfr get_bill_lines **] w_ptbm.discount_amnt '|| w_ptbm.discount_amnt);
   if nvl(w_ptbm.discount_amnt,0) > 0 then
   		debug(w_procedure_name,w_label,' [**Aftr get_bill_lines **] w_ptbm.discount_amnt '|| w_ptbm.discount_amnt);
      w_ptbm.usage_charge_amnt   := nvl(w_ptbm.usage_charge_amnt,0) + w_ptbm.discount_amnt;
   		debug(w_procedure_name,w_label,' [**Aftr get_bill_lines **] w_ptbm.discount_amnt '|| w_ptbm.discount_amnt);
      w_ptbm.discount_amnt := 0;
   end if;
   /* --End Add 8000_8044 */
 end get_bill_lines;
 /*************************************************************************************\
 procedure get_next_reading_date      -- Add 2.0.0.0
 \*************************************************************************************/
 procedure get_next_reading_date(p_round_key in varchar2) is                                          -- Add 2.0.0.0
  w_found     boolean    := false;                     -- Add 2.0.0.0
  w_procedure_name  varchar2(50) := 'phls0001.get_next_reading_date';            -- Add 2.0.0.0
 begin                                                                                                -- Add 2.0.0.0
  for i in 1 .. w_nr_tbl.count                                                                      -- Add 2.0.0.0
  loop                                                                                              -- Add 2.0.0.0
   if p_round_key = w_nr_tbl(i).round_key then                                                    -- Add 2.0.0.0
      w_ptbm.next_mtr_read_date := w_nr_tbl(i).next_mtr_read_date;                                -- Add 2.0.0.0
    w_found := true;                                                                            -- Add 2.0.0.0
   end if;                                                                                        -- Add 2.0.0.0
  end loop;                                                                                         -- Add 2.0.0.0
                                                                                                    -- Add 2.0.0.0
  if not w_found then                                                                               -- Add 2.0.0.0
   begin
    select next_reading_date                              -- Add 2.0.0.0
    into  w_ptbm.next_mtr_read_date                      -- Add 2.0.0.0
    from cis_rounds                                                                               -- Add 2.0.0.0
    where round_key  = p_round_key;                      -- Add 2.0.0.0
   exception
    when no_data_found then
     w_ptbm.next_mtr_read_date := null;
   end;
    w_nr_tbl(w_nr_tbl.count + 1).round_key    := p_round_key;           -- Add 2.0.0.0
    w_nr_tbl(w_nr_tbl.count + 1).next_mtr_read_date := w_ptbm.next_mtr_read_date;           -- Add 2.0.0.0
  end if;                                                                                           -- Add 2.0.0.0
  --debug_trace(w_procedure_name,'...w_ptbm.next_mtr_read_date =' || datec(w_ptbm.next_mtr_read_date)); -- Add 2.0.0.0
 end get_next_reading_date;                                                                           -- Add 2.0.0.0
 --Start Add 4562
 /*************************************************************************************\
    function get_prev_month
 \*************************************************************************************/
 function get_prev_month(p_in_month in number) return char is
  w_rtn_year  number;
  w_rtn_month number;
 begin
  w_rtn_year  := to_number(substr(to_char(p_in_month),1,4));
  w_rtn_month := to_number(substr(to_char(p_in_month),5,2));
  if w_rtn_month = 1 then
   w_rtn_year  := w_rtn_year - 1;
   w_rtn_month := 12;
  else
   w_rtn_month := w_rtn_month - 1;
   w_rtn_year  := w_rtn_year;
  end if;
  return  to_number(trim(to_char(w_rtn_year,'0000')) || trim(to_char(w_rtn_month,'00')));
 end get_prev_month;
 /*************************************************************************************\
    function get_next_month
 \*************************************************************************************/
 function get_next_month(p_in_month in number) return char is
  w_rtn_year  number;
  w_rtn_month number;
 begin
  w_rtn_year  := to_number(substr(to_char(p_in_month),1,4));
  w_rtn_month := to_number(substr(to_char(p_in_month),5,2));
  if w_rtn_month = 12 then
   w_rtn_year  := w_rtn_year + 1;
   w_rtn_month := 1;
  else
   w_rtn_month := w_rtn_month + 1;
   w_rtn_year  := w_rtn_year;
  end if;
  return  to_number(trim(to_char(w_rtn_year,'0000')) || trim(to_char(w_rtn_month,'00')));
 end get_next_month;
 --End Add 4562
 --Start Add 3706
 /*************************************************************************************\
    private function get_graph_xasis_labels(p_curr_mnth number)
 \*************************************************************************************/
 function get_graph_xasis_labels(p_curr_mnth number) return char is
 begin
   if p_curr_mnth =  1 then return 'Jan'; end if;
   if p_curr_mnth =  2 then return 'Feb'; end if;
   if p_curr_mnth =  3 then return 'Mar'; end if;
   if p_curr_mnth =  4 then return 'Apr'; end if;
   if p_curr_mnth =  5 then return 'May'; end if;
   if p_curr_mnth =  6 then return 'Jun'; end if;
   if p_curr_mnth =  7 then return 'Jul'; end if;
   if p_curr_mnth =  8 then return 'Aug'; end if;
   if p_curr_mnth =  9 then return 'Sep'; end if;
   if p_curr_mnth = 10 then return 'Oct'; end if;
   if p_curr_mnth = 11 then return 'Nov'; end if;
   if p_curr_mnth = 12 then return 'Dec'; end if;
 end  get_graph_xasis_labels;
 --End Add 3706
 /*************************************************************************************\      --Add 2.0.0.0
   private rocedure get_graph_xaxis                                                      --Add 2.0.0.0
 \*************************************************************************************/         --Add 2.0.0.0
 procedure get_graph_xaxis(p_curr_mnth number) is                                  --Add 2.0.0.0
   w_mnth_array  varchar2(12) := 'JFMAMJJASOND';                                --Add 2.0.0.0
   w_curr_mnth    number:=0;                                                                  --Add 2.0.0.0
 begin                                                                                       --Add 2.0.0.0
   w_curr_mnth  := p_curr_mnth;                                                              --Add 2.0.0.0
   --w_ptbm.blbl_13 :=  substr(w_mnth_array,w_curr_mnth,1);                                  --del 3706 --Add 2.0.0.0
   w_ptbm.blbl_13 :=  get_graph_xasis_labels(w_curr_mnth);                                   --Add 3706
   if w_curr_mnth = 1 then w_curr_mnth := 12; else w_curr_mnth := w_curr_mnth - 1; end if;   --Del 3706 --Add 2.0.0.0
   --w_ptbm.blbl_24 :=  substr(w_mnth_array,w_curr_mnth,1);                                  --Del 3706 --Add 3706
   --w_ptbm.blbl_12 :=  substr(w_mnth_array,w_curr_mnth,1);                                  --Del 3706  --Add 2.0.0.0
   --w_ptbm.blbl_24 :=  get_graph_xasis_labels(w_curr_mnth);                                   --Add 3706
   w_ptbm.blbl_12 :=  get_graph_xasis_labels(w_curr_mnth);                                   --Add 3706
   if w_curr_mnth = 1 then w_curr_mnth := 12; else w_curr_mnth := w_curr_mnth - 1; end if;   --Add 2.0.0.0
   --w_ptbm.blbl_23 :=  substr(w_mnth_array,w_curr_mnth,1);                                  --Del 3706  --Add 3706
   --w_ptbm.blbl_11 :=  substr(w_mnth_array,w_curr_mnth,1);                                    --Del 3706  --Add 2.0.0.0
   --w_ptbm.blbl_23 :=  get_graph_xasis_labels(w_curr_mnth);                                   --Add 3706
   w_ptbm.blbl_11 :=  get_graph_xasis_labels(w_curr_mnth);                                   --Add 3706
   if w_curr_mnth = 1 then w_curr_mnth := 12; else w_curr_mnth := w_curr_mnth - 1; end if;   --Add 2.0.0.0
   --w_ptbm.blbl_22 :=  substr(w_mnth_array,w_curr_mnth,1);                                  --Del 3706 --Add 3706
   --w_ptbm.blbl_10 :=  substr(w_mnth_array,w_curr_mnth,1);                                  --Del 3706 --Add 2.0.0.0
   --w_ptbm.blbl_22 :=  get_graph_xasis_labels(w_curr_mnth);                                   --Add 3706
   w_ptbm.blbl_10 :=  get_graph_xasis_labels(w_curr_mnth);                                   --Add 3706
   if w_curr_mnth = 1 then w_curr_mnth := 12; else w_curr_mnth := w_curr_mnth - 1; end if;   --Add 2.0.0.0
   --w_ptbm.blbl_21 :=  substr(w_mnth_array,w_curr_mnth,1);                                  --Del 3706 --Add 3706
   --w_ptbm.blbl_09 :=  substr(w_mnth_array,w_curr_mnth,1);                                  --Del 3706 --Add 2.0.0.0
   --w_ptbm.blbl_21 :=  get_graph_xasis_labels(w_curr_mnth);                                   --Add 3706
   w_ptbm.blbl_09 :=  get_graph_xasis_labels(w_curr_mnth);                                   --Add 3706
   if w_curr_mnth = 1 then w_curr_mnth := 12; else w_curr_mnth := w_curr_mnth - 1; end if;   --Add 2.0.0.0
   --w_ptbm.blbl_20 :=  substr(w_mnth_array,w_curr_mnth,1);                                  --Del 3706 --Add 3706
   --w_ptbm.blbl_08 :=  substr(w_mnth_array,w_curr_mnth,1);                                  --Del 3706 --Add 2.0.0.0
   --w_ptbm.blbl_20 :=  get_graph_xasis_labels(w_curr_mnth);                                   --Add 3706
   w_ptbm.blbl_08 :=  get_graph_xasis_labels(w_curr_mnth);                                   --Add 3706
   if w_curr_mnth = 1 then w_curr_mnth := 12; else w_curr_mnth := w_curr_mnth - 1; end if;   --Add 2.0.0.0
   --w_ptbm.blbl_19 :=  substr(w_mnth_array,w_curr_mnth,1);                                  --Del 3706 --Add 3706
   --w_ptbm.blbl_07 :=  substr(w_mnth_array,w_curr_mnth,1);                                  --Del 3706 --Add 2.0.0.0
   --w_ptbm.blbl_19 :=  get_graph_xasis_labels(w_curr_mnth);                                   --Add 3706
   w_ptbm.blbl_07 :=  get_graph_xasis_labels(w_curr_mnth);                                   --Add 3706
   if w_curr_mnth = 1 then w_curr_mnth := 12; else w_curr_mnth := w_curr_mnth - 1; end if;   --Add 2.0.0.0
   --w_ptbm.blbl_18 :=  substr(w_mnth_array,w_curr_mnth,1);                                  --Del 3706 --Add 3706
   --w_ptbm.blbl_06 :=  substr(w_mnth_array,w_curr_mnth,1);                                  --Del 3706 --Add 2.0.0.0
   --w_ptbm.blbl_18 :=  get_graph_xasis_labels(w_curr_mnth);                                   --Add 3706
   w_ptbm.blbl_06 :=  get_graph_xasis_labels(w_curr_mnth);                                   --Add 3706
   if w_curr_mnth = 1 then w_curr_mnth := 12; else w_curr_mnth := w_curr_mnth - 1; end if;   --Add 2.0.0.0
   --w_ptbm.blbl_17 :=  substr(w_mnth_array,w_curr_mnth,1);                                  --Del 3706 --Add 3706
   --w_ptbm.blbl_05 :=  substr(w_mnth_array,w_curr_mnth,1);                                  --Del 3706 --Add 2.0.0.0
   --w_ptbm.blbl_17 :=  get_graph_xasis_labels(w_curr_mnth);                                   --Add 3706
   w_ptbm.blbl_05 :=  get_graph_xasis_labels(w_curr_mnth);                                   --Add 3706
   if w_curr_mnth = 1 then w_curr_mnth := 12; else w_curr_mnth := w_curr_mnth - 1; end if;   --Add 2.0.0.0
   --w_ptbm.blbl_16 :=  substr(w_mnth_array,w_curr_mnth,1);                                  --Del 3706 --Add 3706
   --w_ptbm.blbl_04 :=  substr(w_mnth_array,w_curr_mnth,1);                                  --Del 3706 --Add 2.0.0.0
   --w_ptbm.blbl_16 :=  get_graph_xasis_labels(w_curr_mnth);                                   --Add 3706
   w_ptbm.blbl_04 :=  get_graph_xasis_labels(w_curr_mnth);                                   --Add 3706
   if w_curr_mnth = 1 then w_curr_mnth := 12; else w_curr_mnth := w_curr_mnth - 1; end if;   --Add 2.0.0.0
   --w_ptbm.blbl_15 :=  substr(w_mnth_array,w_curr_mnth,1);                                  --Del 3706 --Add 3706
   --w_ptbm.blbl_03 :=  substr(w_mnth_array,w_curr_mnth,1);                                  --Del 3706 --Add 2.0.0.0
   --w_ptbm.blbl_15 :=  get_graph_xasis_labels(w_curr_mnth);                                   --Add 3706
   w_ptbm.blbl_03 :=  get_graph_xasis_labels(w_curr_mnth);                                   --Add 3706
   if w_curr_mnth = 1 then w_curr_mnth := 12; else w_curr_mnth := w_curr_mnth - 1; end if;   --Add 2.0.0.0
   --w_ptbm.blbl_14 :=  substr(w_mnth_array,w_curr_mnth,1);                                  --Del 3706 --Add 3706
   --w_ptbm.blbl_02 :=  substr(w_mnth_array,w_curr_mnth,1);                                  --Del 3706 --Add 2.0.0.0
   --w_ptbm.blbl_14 :=  get_graph_xasis_labels(w_curr_mnth);                                   --Add 3706
   w_ptbm.blbl_02 :=  get_graph_xasis_labels(w_curr_mnth);                                   --Add 3706
   if w_curr_mnth = 1 then w_curr_mnth := 12; else w_curr_mnth := w_curr_mnth - 1; end if;   --Add 2.0.0.0 --Del 3706
   --w_ptbm.blbl_13 :=  substr(w_mnth_array,w_curr_mnth,1);                                  --Del 3706 --Add 3706    --Del 3706
   --w_ptbm.blbl_01 :=  substr(w_mnth_array,w_curr_mnth,1);                                  --Del 3706 --Add 2.0.0.0 --Del 3706
   --w_ptbm.blbl_13 :=  get_graph_xasis_labels(w_curr_mnth);                                   --Add 3706
   w_ptbm.blbl_01 :=  get_graph_xasis_labels(w_curr_mnth);                                   --Add 3706
 end get_graph_xaxis;                                                                        --Add 2.0.0.0
 /*************************************************************************************\
    procedure set_one_bill
 \*************************************************************************************/
 procedure set_one_bill
 is
    w_procedure_name              varchar2(40) := 'phls0001.set_one_bill';
    w_old_debt_tran_date          cis_transactions.tran_date%type;
 --   w_city_acct                 varchar2(20);                         -- Add 1.0.0.2   -- Del 1.0.0.17A
    w_result                      varchar2(1);                          -- Add 1.0.0.2
    w_message                     varchar2(300);                        -- Add 1.0.0.2
    w_max_rec_tran_id             number(15);                           -- Add 1.0.0.17A
    w_prev_bill_tran_id           number(15);                           -- Add 1.0.0.3
    w_prev_bill_creation_date     date;                                 -- Add 1.0.0.4
    w_wrbbc_cur_bal               number;                               -- Add 1.0.0.21
    --w_round_key                   varchar2(20);                       -- Del 3706  -- Add 2.0.0.0
    w_installment_amnt            number;                               -- Add 2212
    w_tot_cur_chgs_pnlty_calc     number:=0;
    w_prev_bal_pnlty_calc         number:=0;
    w_service_code_inst           char(2);                              -- Add 1.0.0.17
    w_bill_owner_cust_id          cis_installations.owner_cust_id%type; -- Add 2176
    w_bill_tenn_cust_id           cis_installations.tenn_cust_id%type;  -- Add 2176
    w_grp_cur_month               number;                               -- Add 2437
    w_3rd_party_count             number;                               -- Add 4614;
    l_ss_fee_mssg								  char(1);															-- Add 7762
    l_kub_sup_ty									cis_accounts.supply_type%type;        -- Add 9918
    l_pymnt_posted								number;																-- Add 9918
    l_lst_five_pndpymts						number;																-- Add 9918
    l_lst_pnd_pymnt_dt						date;																	-- Add 9918
    l_fut_py_acctd								boolean := false;											-- Add 9918
   --Revert the changes for Ticket 3703
   /*
   cursor c_grp_cur is                     --Add 2437
   select min(to_number(to_char(tran_date,'YYYYMM'))) month                 --Add 4562 --Del 3703 --Add 2437
          max(tran_date)                              max_tran_date         --Add 4562
          --min(to_number(to_char(reading_datime,'YYYYMM'))) month          --Add 4560
         ,sum(nvl(orig_tran_qty,tran_qty)) billed_qty                       --Add 3706 --Add 2437
         ,min(decode(est_reading_ind,null,'A','E')) est_reading_ind         --Chg 3706 --Add 2437 --Mod 2488
   from   cis_debit_lines                                                    --Add 2437
   where cust_id = w_cust_id                                                --Add 2437
      and inst_id = w_inst_id                                               --Add 2437
      and supply_type = 'WATER'                                             --Add 3703
      and scnd_type in ('RDG','RER')                                        --Add 2437
      and tran_id <= w_tran_id                                              --Add 2437
      and consumption_sign <> 0                                             --Add 2437
      and to_number(to_char(reading_datime,'YYYYMM')) >= w_grp_cur_month    --Add 3703 --it's the lowest month for the graph
   group by to_number(to_char(reading_datime,'YYYYMM'))     --Add XXXXX --Bill Key B0457725346 and B0457709015 Grapgh not displayed for reversed bills
   order by 1 desc;                                                         --Add 2437
   */
   /* Start Add 4562 */
   cursor c_grp_cur is
   select to_number(to_char(tran_date,'YYYYMM'))             month
         ,tran_date                                          tran_date
          --min(to_number(to_char(reading_datime,'YYYYMM'))) month
         ,nvl(tran_qty,0)                                    billed_qty
         ,decode(est_reading_ind,null,'A','E')               est_reading_ind
         --,bill_key                                         --If Bill Key can be stored in pl/sql table. We can solve the issue of Acct#8452000958001
   from   cis_debit_lines
   where cust_id = w_cust_id
      and inst_id = w_inst_id
      and supply_type = 'WATER'
      and scnd_type in ('RDG','RER')
      and tran_id <= w_tran_id
      and consumption_sign <> 0
      --and to_number(to_char(reading_datime,'YYYYMM')) >= w_grp_cur_month
      and to_number(to_char(tran_date,'YYYYMM')) >= w_grp_cur_month
   order by 1 desc;
   /* End Add 4562 */
 begin
    trace_label('e195', w_procedure_name);
    debug_trace(w_procedure_name,'Doing Bill For:');
    debug_trace(w_procedure_name,'...cust_id      =' || to_char(w_cust_id));
    debug_trace(w_procedure_name,'...inst_id      =' || to_char(w_inst_id));
    debug_trace(w_procedure_name,'...tran_id      =' || to_char(w_tran_id));
    debug_trace(w_procedure_name,'...w_process_id =' || w_process_id);
    reset;
    -- Start Add 4614
    -- Count the number of third party copies for this bill
    w_label := 'e196';
    select count(tran_id)
      into w_3rd_party_count
      from cis_bill_lines
     where tran_id = w_tran_id
       and line_num = 1
       and copy_for_3rd_party_ind = 'Y'
    ;
    w_3rd_party_count := nvl(w_3rd_party_count,0);
    -- End   Add 4614
    -- get the primary data for this bill
    w_label := 'e197';
  begin              --Add 1.0.0.60 Bug#1896
     select
            blt.bill_key
           ,blt.tran_key                                        -- Add 883
           ,blt.bill_date
           ,blt.supply_type
           ,blt.opening_bal_amnt                                      -- Del 1.0.0.3 , re-Add 1.0.0.4
           ,blt.closing_bal_amnt
           ,blt.bill_tran_amnt
           ,blt.ppln_id
           ,blt.ppln_type                                             -- Add 1.0.0.21
           ,trim(substr(upper(trim(iad.line1)) || upper(decode(instr(iad.line2,'PHILADELPHIA'),0,decode(instr(iad.line1,iad.line2),0,' ' || iad.line2,null),null)),1,25))  --Add 3706 --Add 3706
           ,iad.postal_code                                                                          --Add 3706
           --,upper(decode(trim(iad.line1), trim(iad.number2),          -- Chg 818 was [iad.line1]   --Del 3706
           --       substr(trim(iad.number2) ||' '|| iad.line2,1,25), substr(iad.line1,1,25)))       --Del 3706  -- Add 818
           ,bll.acct_key
           ,bll.bill_format_code                                      -- Add 1.0.0.2
           ,bll.acct_pay_method
           ,trn.payment_due_date                                      -- Chg 1573  (was bll.)
           ,substr(upper(bll.cust_name),1,30)    cust_name      --2.0.0.06 Truncate the Customer name to 30 Characters
           ,trim(substr(bll.cust_type_code,1,1)) cust_type_code    --Add 4398
           ,bll.inst_type_code
           ,bll.inst_locn_code
           ,decode(bll.acct_pay_method,'I','N','Y') zip_check
           ,substr(nvl(mad.address4,nvl(mad.address10,upper(bll.cust_name))),1,30)  mail_name --Chng Mail Name --Chng 3706 --2.0.0.06 Truncate the Customer name to 30 Characters
           ,case  --Start Add 3706
              when upper(trim(nvl(mad.address4 ,'!@#'))) != upper(trim(nvl(mad.line1,'!@#')))
               and upper(trim(nvl(mad.address10,'!@#'))) != upper(trim(nvl(mad.line1,'!@#')))
               and upper(trim(nvl(bll.cust_name,'!@#'))) != upper(trim(nvl(mad.line1,'!@#')))
               then upper(trim(substr(mad.line1,1,30)))
               else null
            end line1
           ,case
              when upper(trim(nvl(mad.address4 ,'!@#'))) != upper(trim(nvl(mad.line2,'!@#')))
               and upper(trim(nvl(mad.address10,'!@#'))) != upper(trim(nvl(mad.line2,'!@#')))
               and upper(trim(nvl(bll.cust_name,'!@#'))) != upper(trim(nvl(mad.line2,'!@#')))
               then upper(trim(substr(mad.line2,1,30)))
               else null
            end line2
           ,case
              when upper(trim(nvl(mad.address4 ,'!@#'))) != upper(trim(nvl(mad.line3,'!@#')))
               and upper(trim(nvl(mad.address10,'!@#'))) != upper(trim(nvl(mad.line3,'!@#')))
               and upper(trim(nvl(bll.cust_name,'!@#'))) != upper(trim(nvl(mad.line3,'!@#')))
               then upper(trim(substr(mad.line3,1,30)))
               else null
            end line3
           ,case
              when upper(trim(nvl(mad.address4 ,'!@#'))) != upper(trim(nvl(mad.line4,'!@#')))
               and upper(trim(nvl(mad.address10,'!@#'))) != upper(trim(nvl(mad.line4,'!@#')))
               and upper(trim(nvl(bll.cust_name,'!@#'))) != upper(trim(nvl(mad.line4,'!@#')))
               then upper(trim(substr(mad.line4,1,30)))
               else null
            end line4
           ,case
              when upper(trim(nvl(mad.address4 ,'!@#'))) != upper(trim(nvl(mad.line5,'!@#')))
               and upper(trim(nvl(mad.address10,'!@#'))) != upper(trim(nvl(mad.line5,'!@#')))
               and upper(trim(nvl(bll.cust_name,'!@#'))) != upper(trim(nvl(mad.line5,'!@#')))
               then upper(trim(substr(mad.line5,1,30)))
               else null
            end line5 ----End Add 3706
           ,trim(mad.postal_code) --Add 3409A
           ,upper(substr(mad.delivery_point,1,11))
           --,upper(mad.address5)
           ,w_imb_barcode_id || w_imb_service_type_id || w_imb_mailer_id || w_imb_serial_number || nvl(rpad(replace(trim(decode(sign(nvl(length(translate(trim(mad.postal_code),' -0123456789',' ')),0)),1,'00000',trim(mad.postal_code))),'-',''),11,'0'),'00000000000')    -- 3409B -Added decode(sign(nvl(length(translate(trim(mad.postal_code),' -0123456789',' ')),0)),1,'00000',trim(mad.postal_code)) add 3409A To handel NULL ZIP/with spaces codes--2.0.0.78
           --,w_imb_barcode_id || w_imb_service_type_id || w_imb_mailer_id || w_imb_serial_number ||  nvl(substr(mad.delivery_point,1,11),nvl(rpad(replace(trim(decode(sign(nvl(length(translate(trim(mad.postal_code),' -0123456789',' ')),0)),1,'00000',trim(mad.postal_code))),'-',''),11,'0'),'00000000000')) -----ADD 3481 3409B -Added decode(sign(nvl(length(translate(trim(mad.postal_code),' -0123456789',' ')),0)),1,'00000',trim(mad.postal_code)) add 3409A To handel NULL ZIP/with spaces codes--2.0.0.78
            --the first 5 digits of the mad.postal_code field || the last 4 digits of the mad.postal_code field
            --this string must be 11 digits long and zero-filled on the right if it's shorter than that
           ,bil.bill_printed_date
           ,blt.reading_grp_type                                      -- Add 1.0.0.4
           ,trn.dd_earliest_date                                      -- Add 542
            ,ac.acct_bal_amnt                  -- Add 2.0.0.0
            ,ac.ppln_id                  -- Add 2.0.0.0
            ,ac.active_ppln_type                -- Add 2.0.0.0
            ,blt.round_key                 -- Add 2.0.0.0
            ,trim(nvl(decode(ac.pay_profile_code,'LAWXMPT',ac.attribute8,'PLN-STD',ac.attribute8,ac.pay_profile_code),'~!@#$')) --Add 3327
            ,ac.ppln_bal_amnt                 -- Add 3706
            ,ac.letter_no                     -- Add 4563
            --,iad.bill_delivery_meth					-- Add 8020
            ,iad.address2                     -- Add 8020  --to get City for Inst Address
            ,iad.addr_id											-- Add 8020  --to get Addr_id of Inst Address
            ,trim(substr(ac.attribute15,1,10))-- Add 8020B --to Add loot indicator for landlord and tenannt
            --,capi.auto_pay_ind							--Del 9454	 -- Add 8020B --to Add Auto Pay Indicator
            ,trn.ifce_refn										-- Add 8020F -- Add rebill indicator
            ,trn.scnd_type										-- Add 8020F -- Add rebill indicator
            ,ac.prev_bill_tran_id        			-- Add 9918
            ,ac.attribute3                    -- Add 9984
       into
            w_ptbm.bill_key
           ,w_ptbm.bill_tran_key                                  -- Add 883
           ,w_ptbm.incl_payments_date
           ,w_supply_type
           ,w_ptbm.previous_balance_amnt           -- Del 1.0.0.3 , re-Add 1.0.0.4  -- Initialised here but adjusted by OI trans
           ,w_ptbm.total_due_amnt
           ,w_ptbm.current_charge_amnt
           ,w_ppln_id
           ,w_ppln_type                             -- Add 1.0.0.21
           ,w_ptbm.inst_addr_line1
           ,w_ptbm.inst_postal_code                 -- Add 3706
           ,w_ptbm.acct_key
           ,w_ptbm.bill_format_code                 -- Add 1.0.0.2
           ,w_acct_pay_method
           ,w_ptbm.payment_due_date
           ,w_ptbm.cust_name
           ,w_ptbm.cust_type_code
           ,w_ptbm.inst_type_code
           ,w_ptbm.inst_locn_code
           ,w_ptbm.pays_by_zipcheck
           ,w_ptbm.mail_name
           ,w_ptbm.mail_addr_line1
           ,w_ptbm.mail_addr_line2
           ,w_ptbm.mail_addr_line3
           ,w_ptbm.mail_addr_line4
           ,w_ptbm.mail_addr_line5
           ,w_ptbm.mail_postal_code
           ,w_ptbm.mail_postal_barcode
           ,w_ptbm.imb
           ,w_ptbm.billing_date
           ,w_reading_grp_type                                       -- Add 1.0.0.4
           ,w_dd_earliest_date                                       -- Add 542
           ,w_ptbm.account_balance     -- Add 2.0.0.0
           ,w_ppln_id                  -- Add 2.0.0.0
           ,w_ppln_type                -- Add 2.0.0.0
           ,w_round_key                -- Add 2.0.0.0
           ,w_pay_profile_code         -- Add 3327
           ,w_ptbm.agr_bal_amnt        -- Add 3706
           ,w_arrears_letter_no        -- Add 4563
           --,g_bill_delivery_meth		 -- Add 8020
           ,g_inst_city								 -- Add 8020
           ,g_inst_addr_id						 -- Add 8020
           ,g_loot_ind								 -- Add 8020B
           --,g_auto_pay_ind					 --Del 9454	 -- Add 8020B
           ,g_trn_ifce_refn						 -- Add 8020F -- Add rebill indicator
           ,g_trn_scnd_type						 -- Add 8020F -- Add rebill indicator
           ,g_prev_bill_tran_id        -- Add 9918
           ,g_tap_acct_at_some_stage   -- Add 9984
       from cis_bill_lines bll
           ,cis_bill_trans blt
           ,cis_addresses iad
           ,cis_addresses mad
           ,cis_bills bil
           ,cis_transactions trn                            -- Add 542
           ,cis_accounts ac                                 -- Add 1067
           --,phl_curr_auto_pay_ind_v capi									-- Del 9454	-- Add 8020B
      where blt.tran_id = w_tran_id
        and trn.tran_id = blt.tran_id                       -- Add 542
        and bll.tran_id = blt.tran_id
        and bll.line_num = 1
        and bll.prop_addr_id = iad.addr_id
  --    and bll.mail_addr_id = mad.addr_id                  -- Del 1067
        and blt.cust_id   = ac.cust_id                      -- Add 1067
        and blt.inst_id   = ac.inst_id                      -- Add 1067
        and ac.supply_type  = 'WATER'                       -- Add 3706
        --and blt.suply_type  = 'WATER'                     -- Add 3706
        --and bll.supply_type = 'WATER'                     -- Add 3706
        and ac.mail_addr_id  = mad.addr_id                  -- Add 1067
        and bil.bill_id   = blt.bill_id
        and bll.copy_for_3rd_party_ind is null              -- Add 4614
        --and ac.acct_id      = capi.acct_id(+)							-- Del 9454  -- Add 8020B
        and bll.process_id  = w_process_id;                 -- Del 1.0.0.24   -- Chg Back 1.0.0.28
        --Start Add 8020
        debug_trace(w_procedure_name,'...Before parsing = ' || g_inst_city);
        g_inst_city := get_onlycity(g_inst_city);
        debug_trace(w_procedure_name,'...After parsing  = ' || g_inst_city);
        --End Add 8020
        w_pay_profile_code_orig := w_pay_profile_code;      --Add 3706
        debug_trace(w_procedure_name,'...w_pay_profile_code       = ' || w_pay_profile_code); --Add 4398
        debug_trace(w_procedure_name,'...w_pay_profile_code_orig  = ' || w_pay_profile_code_orig); --Add 4398
        /* --Strat Del 4398 */
        -- The code moved up so that w_city_acct can be used by Help Loan Scan Line routine
        -- Format the bill account number
        phlu0018.b2_acct_to_city_acct (
                                       p_acct_id   => null
                                      ,p_acct_key  => w_ptbm.acct_key
                                      ,p_city_acct => w_city_acct_4_WAT  --Add 6130 --Introduce w_city_acct_4_WAT instead of w_city_acct
                                      ,p_result    => w_result
                                      ,p_message   => w_message
                                      );
        w_city_acct            :=  w_city_acct_4_WAT;     --Add 6130;
        /* --End Del 4398 */
        --Start Add 4398
        --
        -- Penalty date has been moved further up.
        -- So that routines of Agency Receivables / Help Loan can use Penalty Date
        --
        --
        w_label := 'e198';
        --We need to take bill due date from BILL transactions...
        --w_ptbm.penalty_date     := next_valid_due_date(w_ptbm.billing_date + 30);    --De 4397 --Del 4398 --Mod 2212
        --Start add 4398
        if w_ptbm.payment_due_date is not null then
          w_ptbm.penalty_date := next_valid_due_date(w_ptbm.payment_due_date + 8);
        else
          w_ptbm.penalty_date := next_valid_due_date(w_ptbm.billing_date + 30);
        end if;
        --End add 4398
        debug_trace(w_procedure_name,'...Penalty Date  = ' || datec(w_ptbm.penalty_date)); --Add 4398
        for r_st in (select supply_type,acct_bal_amnt,acct_id,ppln_bal_amnt
                      from cis.cis_accounts
                      where supply_type!='WATER'
                        and cust_id = w_cust_id
                        and inst_id = w_inst_id
                    )
        loop
          if r_st.supply_type = 'AGENCY' then
             w_label := 'e199';
             w_max_crln_creation_date  := null;
             w_max_crln_id             := null;
             w_ar_acct_bal             := r_st.acct_bal_amnt;  -- Add 5905 3.0.0.39
             select max(creation_date),max(credit_line_id)
             into   w_max_crln_creation_date,w_max_crln_id
             from cis.cis_credit_lines
             where cust_id = w_cust_id
               and inst_id = w_inst_id
               and supply_type = 'AGENCY';
             w_label := 'e200';
             debug_trace(w_procedure_name, '...  r_st.acct_bal_amnt/w_ar_acct_bal       ...'||w_ar_acct_bal);
             debug_trace(w_procedure_name, '...  w_max_crln_creation_date ...'||datec(w_max_crln_creation_date));
             debug_trace(w_procedure_name, '...  w_ptbm.billing_date      ...'||datec(w_ptbm.billing_date));
             if r_st.acct_bal_amnt = 0 and (w_ptbm.billing_date - w_max_crln_creation_date) > 30 then
                w_label := 'e201';
                debug_trace(w_procedure_name, '...  w_max_crln_creation_date ...'||datec(w_max_crln_creation_date));
                debug_trace(w_procedure_name, '...  w_ptbm.billing_date ...'||datec(w_ptbm.billing_date));
                null; -- Do not print Agency Statement, because its account balance is zero and there no activity(credit trans) reported for last 30 days.
             else
                w_agr_curr_chgs := 0;
                -- Very Important
                -- Check how to avoid accounts quesry in phls0300
                --
                phls0300.get_repair_chg_statement(
                    p_cust_id                       =>  w_cust_id                             --Cust ID                                                                -- p_cust_id
                   ,p_inst_id                       =>  w_inst_id                             --Inst ID                                                                --,p_inst_id
                   ,p_curr_bill_tran_id             =>  w_tran_id                             --Current Water Bill Tran ID                                             --,p_curr_bill_tran_id
                   ,p_water_ppln_id                 =>  w_ppln_id                             --Payment plan on Water Account                                          --,p_water_ppln_id
                   ,p_penalty_date                  =>  nvl(w_ptbm.penalty_date,w_ptbm.billing_date+30) --Penalty Date                                                 --,p_penalty_date
                   ,p_prv_bill_tran_id              =>  w_rchl.prv_bill_tran_id               --Previous Bill Tran ID                                  --Add 6230      --,p_prv_bill_tran_id
                   ,p_prv_bill_creation_dt          =>  w_rchl.prv_bill_creation_dt           --Previous Bill Creation Date                            --Add 6230      --,p_prv_bill_creation_dt
                   ,p_agrv_rc_acct_key              =>  w_rchl.agrv_rc_acct_key               --Agency Receivables Basis2 Account ID                                   --,p_agrv_rc_acct_key
                   ,p_agrv_rc_st_opening_bal_amnt   =>  w_rchl.agrv_rc_st_opening_bal_amnt    --Previous Balance Agency Receivables (Repair Charges)                   --,p_agrv_rc_st_opening_bal_amnt
                   ,p_agrv_rc_cur_pymnt_amnt        =>  w_rchl.agrv_rc_cur_pymnt_amnt                                                                                  --,p_agrv_rc_cur_pymnt_amnt
                   ,p_agrv_rc_last_pymnt_dt         =>  w_rchl.agrv_rc_last_pymnt_dt                                                                                   --,p_agrv_rc_last_pymnt_dt
                   ,p_agrv_rc_cur_adj_amnt          =>  w_rchl.agrv_rc_cur_adj_amnt                                                                                    --,p_agrv_rc_cur_adj_amnt
                   ,p_agrv_rc_unpaid_amnt           =>  w_rchl.agrv_rc_unpaid_amnt                                                                                     --,p_agrv_rc_unpaid_amnt
                   ,p_agrv_rc_unpaid_lbl            =>  w_rchl.agrv_rc_unpaid_lbl                                                                                      --,p_agrv_rc_unpaid_lbl
                   ,p_agrv_rc_5th_inv_no            =>  w_rchl.agrv_rc_5th_inv_no             --Agency Receivables 5th Meter Charge/Nuisance Charge Invoice#           --,p_agrv_rc_5th_inv_no
                   ,p_agrv_rc_5th_inv_srv_dt        =>  w_rchl.agrv_rc_5th_inv_srv_dt         --Agency Receivables 5th Meter Charge/Nuisance Service Date              --,p_agrv_rc_5th_inv_srv_dt
                   ,p_agrv_rc_5th_inv_lien_no       =>  w_rchl.agrv_rc_5th_inv_lien_no        --Agency Receivables 5th Meter Charge/Nuisance Lien#                     --,p_agrv_rc_5th_inv_lien_no
                   ,p_agrv_rc_5th_inv_bal           =>  w_rchl.agrv_rc_5th_inv_bal            --Agency Receivables 5th Meter Charge/Nuisance Balance                   --,p_agrv_rc_5th_inv_bal
                   ,p_agrv_rc_5th_inv_desc          =>  w_rchl.agrv_rc_5th_inv_desc           --Agency Receivables 5th Meter Charge/Nuisance Description               --,p_agrv_rc_5th_inv_desc
                   ,p_agrv_rc_5th_fpg_inv_desc      =>  w_rchl.agrv_rc_5th_fpg_inv_desc                                                                                --,p_agrv_rc_5th_fpg_inv_desc
                   ,p_agrv_rc_5th_cur_prv_flag      =>  w_rchl.agrv_rc_5th_cur_prv_flag       --Agency Receivables 5th Current/Previous flag                           --,p_agrv_rc_5th_cur_prv_flag
                   ,p_agrv_rc_4th_inv_no            =>  w_rchl.agrv_rc_4th_inv_no             --Agency Receivables 4th Meter Charge/Nuisance Charge Invoice#           --,p_agrv_rc_4th_inv_no
                   ,p_agrv_rc_4th_inv_srv_dt        =>  w_rchl.agrv_rc_4th_inv_srv_dt         --Agency Receivables 4th Meter Charge/Nuisance Service Date              --,p_agrv_rc_4th_inv_srv_dt
                   ,p_agrv_rc_4th_inv_lien_no       =>  w_rchl.agrv_rc_4th_inv_lien_no        --Agency Receivables 4th Meter Charge/Nuisance Lien#                     --,p_agrv_rc_4th_inv_lien_no
                   ,p_agrv_rc_4th_inv_bal           =>  w_rchl.agrv_rc_4th_inv_bal            --Agency Receivables 4th Meter Charge/Nuisance Balance                   --,p_agrv_rc_4th_inv_bal
                   ,p_agrv_rc_4th_inv_desc          =>  w_rchl.agrv_rc_4th_inv_desc           --Agency Receivables 4th Meter Charge/Nuisance Description               --,p_agrv_rc_4th_inv_desc
                   ,p_agrv_rc_4th_fpg_inv_desc      =>  w_rchl.agrv_rc_4th_fpg_inv_desc                                                                                --,p_agrv_rc_4th_fpg_inv_desc
                   ,p_agrv_rc_4th_cur_prv_flag      =>  w_rchl.agrv_rc_4th_cur_prv_flag       --Agency Receivables 4th Current/Previous flag                           --,p_agrv_rc_4th_cur_prv_flag
                   ,p_agrv_rc_3rd_inv_no            =>  w_rchl.agrv_rc_3rd_inv_no             --Agency Receivables 3rd Meter Charge/Nuisance Charge Invoice#           --,p_agrv_rc_3rd_inv_no
                   ,p_agrv_rc_3rd_inv_srv_dt        =>  w_rchl.agrv_rc_3rd_inv_srv_dt         --Agency Receivables 3rd Meter Charge/Nuisance Service Date              --,p_agrv_rc_3rd_inv_srv_dt
                   ,p_agrv_rc_3rd_inv_lien_no       =>  w_rchl.agrv_rc_3rd_inv_lien_no        --Agency Receivables 3rd Meter Charge/Nuisance Lien#                     --,p_agrv_rc_3rd_inv_lien_no
                   ,p_agrv_rc_3rd_inv_bal           =>  w_rchl.agrv_rc_3rd_inv_bal            --Agency Receivables 3rd Meter Charge/Nuisance Balance                   --,p_agrv_rc_3rd_inv_bal
                   ,p_agrv_rc_3rd_inv_desc          =>  w_rchl.agrv_rc_3rd_inv_desc           --Agency Receivables 3rd Meter Charge/Nuisance Description               --,p_agrv_rc_3rd_inv_desc
                   ,p_agrv_rc_3rd_fpg_inv_desc      =>  w_rchl.agrv_rc_3rd_fpg_inv_desc                                                                                --,p_agrv_rc_3rd_fpg_inv_desc
                   ,p_agrv_rc_3rd_cur_prv_flag      =>  w_rchl.agrv_rc_3rd_cur_prv_flag       --Agency Receivables 3rd Current/Previous flag                           --,p_agrv_rc_3rd_cur_prv_flag
                   ,p_agrv_rc_2nd_inv_no            =>  w_rchl.agrv_rc_2nd_inv_no             --Agency Receivables 2nd Meter Charge/Nuisance Charge Invoice#           --,p_agrv_rc_2nd_inv_no
                   ,p_agrv_rc_2nd_inv_srv_dt        =>  w_rchl.agrv_rc_2nd_inv_srv_dt         --Agency Receivables 2nd Meter Charge/Nuisance Service Date              --,p_agrv_rc_2nd_inv_srv_dt
                   ,p_agrv_rc_2nd_inv_lien_no       =>  w_rchl.agrv_rc_2nd_inv_lien_no        --Agency Receivables 2nd Meter Charge/Nuisance Lien#                     --,p_agrv_rc_2nd_inv_lien_no
                   ,p_agrv_rc_2nd_inv_bal           =>  w_rchl.agrv_rc_2nd_inv_bal            --Agency Receivables 2nd Meter Charge/Nuisance Balance                   --,p_agrv_rc_2nd_inv_bal
                   ,p_agrv_rc_2nd_inv_desc          =>  w_rchl.agrv_rc_2nd_inv_desc           --Agency Receivables 2nd Meter Charge/Nuisance Description               --,p_agrv_rc_2nd_inv_desc
                   ,p_agrv_rc_2nd_fpg_inv_desc      =>  w_rchl.agrv_rc_2nd_fpg_inv_desc                                                                                --,p_agrv_rc_2nd_fpg_inv_desc
                   ,p_agrv_rc_2nd_cur_prv_flag      =>  w_rchl.agrv_rc_2nd_cur_prv_flag       --Agency Receivables 2nd Current/Previous flag                           --,p_agrv_rc_2nd_cur_prv_flag
                   ,p_agrv_rc_1st_inv_no            =>  w_rchl.agrv_rc_1st_inv_no             --Agency Receivables 1st Meter Charge/Nuisance Charge Invoice#           --,p_agrv_rc_1st_inv_no
                   ,p_agrv_rc_1st_inv_srv_dt        =>  w_rchl.agrv_rc_1st_inv_srv_dt         --Agency Receivables 1st Meter Charge/Nuisance Service Date              --,p_agrv_rc_1st_inv_srv_dt
                   ,p_agrv_rc_1st_inv_lien_no       =>  w_rchl.agrv_rc_1st_inv_lien_no        --Agency Receivables 1st Meter Charge/Nuisance Lien#                     --,p_agrv_rc_1st_inv_lien_no
                   ,p_agrv_rc_1st_inv_bal           =>  w_rchl.agrv_rc_1st_inv_bal            --Agency Receivables 1st Meter Charge/Nuisance Balance                   --,p_agrv_rc_1st_inv_bal
                   ,p_agrv_rc_1st_inv_desc          =>  w_rchl.agrv_rc_1st_inv_desc           --Agency Receivables 1st Meter Charge/Nuisance Description               --,p_agrv_rc_1st_inv_desc
                   ,p_agrv_rc_1st_fpg_inv_desc      =>  w_rchl.agrv_rc_1st_fpg_inv_desc                                                                                --,p_agrv_rc_1st_fpg_inv_desc
                   ,p_agrv_rc_1st_cur_prv_flag      =>  w_rchl.agrv_rc_1st_cur_prv_flag       --Agency Receivables 1st Current/Previous flag                           --,p_agrv_rc_1st_cur_prv_flag
                   ,p_agrv_rc_cur_rem_inv_bal       =>  w_rchl.agrv_rc_cur_rem_inv_bal        --Agency Receivables Current Remaining Meter Charge/Nuisance Balance     --,p_agrv_rc_cur_rem_inv_bal
                   ,p_agrv_rc_cur_pnlty_amnt        =>  w_rchl.agrv_rc_cur_pnlty_amnt         --Agency Receivables Current Penalties Amount for this bill              --,p_agrv_rc_cur_pnlty_amnt
                   ,p_agrv_rc_prv_rem_inv_bal       =>  w_rchl.agrv_rc_prv_rem_inv_bal        --Agency Receivables Previous Remaining Meter Charge/Nuisance Balance    --,p_agrv_rc_prv_rem_inv_bal
                   ,p_agrv_rc_prv_pnlty_amnt        =>  w_rchl.agrv_rc_prv_pnlty_amnt         --Agency Receivables Previous Penalties Amount                           --,p_agrv_rc_prv_pnlty_amnt
                   ,p_agrv_rc_prv_pymnt_amnt        =>  w_rchl.agrv_rc_prv_pymnt_amnt         --Agency Receivables Previous Sum of all Payments                        --,p_agrv_rc_prv_pymnt_amnt
                   ,p_agrv_rc_prv_adj_amnt          =>  w_rchl.agrv_rc_prv_adj_amnt           --Agency Receivables Previous Adjustments                                --,p_agrv_rc_prv_adj_amnt
                   ,p_agrv_rc_tot_rem_inv_bal       =>  w_rchl.agrv_rc_tot_rem_inv_bal        --Agency Receivables Current + Previous Invoice Balance                  --,p_agrv_rc_tot_rem_inv_bal
                   ,p_agrv_rc_tot_pnlty_amnt        =>  w_rchl.agrv_rc_tot_pnlty_amnt         --Agency Receivables Current + Previous Penalties                        --,p_agrv_rc_tot_pnlty_amnt
                   ,p_agrv_rc_tot_adj_amnt          =>  w_rchl.agrv_rc_tot_adj_amnt           --Agency Receivables Current + Previous Adjustments                      --,p_agrv_rc_tot_adj_amnt
                   ,p_agrv_rc_tot_pymnt_amnt        =>  w_rchl.agrv_rc_tot_pymnt_amnt         --Agency Receivables Current + Previous Payments                         --,p_agrv_rc_tot_pymnt_amnt
                   ,p_agrv_rc_st_closing_bal_amnt   =>  w_rchl.agrv_rc_st_closing_bal_amnt    --Please PAY now Current Balance Agency Receivables (Repair Charges)                    --,p_agrv_rc_st_closing_bal_amnt
                   ,p_agrv_rc_debt_to_exclude       =>  w_rchl.agrv_rc_debt_to_exclude        --Bankruptcy debt to be excluded from calculatio, But needs to included i--,p_agrv_rc_debt_to_exclude
                   ,p_rc_acct_bal_amnt              =>  w_rchl.rc_acct_bal_amnt               --Account balance current                                --Add 6230      --,p_rc_acct_bal_amnt
                   ,p_rc_cur_xfer_rcpt_in_amnt      =>  w_rchl.rc_cur_xfer_rcpt_in_amnt       --Current xfer in  (Payment came in from other account)  --Add 6230      --,p_rc_cur_xfer_rcpt_in_amnt
                   ,p_rc_prv_xfer_rcpt_in_amnt      =>  w_rchl.rc_prv_xfer_rcpt_in_amnt       --Previous xfer in  (Payment came in from other account) --Add 6230      --,p_rc_prv_xfer_rcpt_in_amnt
                   ,p_rc_cur_xfer_rcpt_ou_amnt      =>  w_rchl.rc_cur_xfer_rcpt_ou_amnt       --Current xfer out (Payment went out to other account)   --Add 6230      --,p_rc_cur_xfer_rcpt_ou_amnt
                   ,p_rc_prv_xfer_rcpt_ou_amnt      =>  w_rchl.rc_prv_xfer_rcpt_ou_amnt       --Previous xfer out (Payment went out to other account)  --Add 6230      --,p_rc_prv_xfer_rcpt_ou_amnt
                   ,p_rc_tot_debt_till_bill_dt      =>  w_rchl.rc_tot_debt_till_bill_dt       --Total debt till billing Date                           --Add 6230      --,p_rc_tot_debt_till_bill_dt
                   ,p_rc_bal_not_in_bill            =>  w_rchl.rc_bal_not_in_bill             --Balance which is not part of this bill                 --Add 6230      --,p_rc_bal_not_in_bill
                   ,p_hlrc_status                   =>  w_rchl.hlrc_status                    --HELPLOAN Repair Charge Status                          --Add 6230      --,p_hlrc_status
								   ,p_rc_inv_tran_ids								=> 	w_rchl.rc_inv_tran_ids								--Agency Invoice Tran IDs are stored to fix 10212        --Add 10212
                   );
                   if w_hlrc_status  is null then w_hlrc_status := w_rchl.hlrc_status; else w_hlrc_status := w_hlrc_status ||','|| w_rchl.hlrc_status; end if; --Add 6230
                   if w_rchl.agrv_rc_5th_cur_prv_flag = 'C' then w_agr_curr_chgs := nvl(w_agr_curr_chgs,0) + nvl(w_rchl.agrv_rc_5th_inv_bal,0); end if;
                   if w_rchl.agrv_rc_4th_cur_prv_flag = 'C' then w_agr_curr_chgs := nvl(w_agr_curr_chgs,0) + nvl(w_rchl.agrv_rc_4th_inv_bal,0); end if;
                   if w_rchl.agrv_rc_3rd_cur_prv_flag = 'C' then w_agr_curr_chgs := nvl(w_agr_curr_chgs,0) + nvl(w_rchl.agrv_rc_3rd_inv_bal,0); end if;
                   if w_rchl.agrv_rc_2nd_cur_prv_flag = 'C' then w_agr_curr_chgs := nvl(w_agr_curr_chgs,0) + nvl(w_rchl.agrv_rc_2nd_inv_bal,0); end if;
                   if w_rchl.agrv_rc_1st_cur_prv_flag = 'C' then w_agr_curr_chgs := nvl(w_agr_curr_chgs,0) + nvl(w_rchl.agrv_rc_1st_inv_bal,0); end if;
                   w_agr_curr_chgs := nvl(w_agr_curr_chgs,0) + nvl(w_rchl.agrv_rc_cur_rem_inv_bal,0);  --Add other current repair charges
                   --                                                                       --
                   -- Need unpaid Agency Repair Charges only when we have payment agreement --
                   --                                                                       --
                   if nvl(w_rchl.agrv_rc_unpaid_amnt,0) = 0 or w_ppln_id is null then
                      w_rchl.agrv_rc_unpaid_amnt := null;
                   end if;
             end if;
          elsif r_st.supply_type = 'HELPLOAN' then
             w_label := 'e202';
             w_max_crln_creation_date  := null;
             w_max_crln_id             := null;
             w_hl_acct_bal             := r_st.acct_bal_amnt;  -- Add 5905 3.0.0.39
             select max(creation_date),max(credit_line_id)
             into   w_max_crln_creation_date,w_max_crln_id
             from cis.cis_credit_lines
             where cust_id = w_cust_id
               and inst_id = w_inst_id
               and supply_type = 'HELPLOAN';
             if r_st.acct_bal_amnt = 0 and (w_ptbm.billing_date - nvl(w_max_crln_creation_date,sysdate)) > 30 then
                null; -- Do not print HELP Loan Statement, because its account balance is zero and there is no credit activity for last 30 days.
             else
                w_label := 'e203';
                phls0300.get_helploan_statement(
                    p_cust_id                       =>  w_cust_id                                                                                                                                                            --  p_cust_id
                   ,p_inst_id                       =>  w_inst_id                                                                                                                                                            -- ,p_inst_id
                   ,p_penalty_date                  => nvl(w_ptbm.penalty_date,w_ptbm.billing_date+30) --Penalty Date                                                                                                        -- ,p_penalty_date
                   ,p_mesg_date                     => w_ptbm.billing_date                             --HelpLoan Message Date                                                                                               -- ,p_mesg_date
                   ,p_curr_bill_tran_id             => w_tran_id                                       --Current Water Bill Tran ID                                                                                          -- ,p_curr_bill_tran_id
                   ,p_prv_bill_tran_id              => w_rchl.prv_bill_tran_id                         --Previous Bill Tran ID                          --Add 6230                                                           -- ,p_hl_acct_bal
                   ,p_prv_bill_creation_dt          => w_rchl.prv_bill_creation_dt                     --Previous Bill Creation Date                    --Add 6230                                                           -- ,p_prv_bill_tran_id
                   ,p_hl_acct_bal                   => r_st.acct_bal_amnt                              --HELP LOAN Account Balance Amount                                                                                    -- ,p_prv_bill_creation_dt
                   ,p_agrv_hl_ppln_bal_amnt         => w_rchl.agrv_hl_ppln_bal_amnt                    --HelpLoan Balance Amount                                                                                             -- ,p_agrv_hl_ppln_bal_amnt
                   ,p_agrv_hl_acct_key              => w_rchl.agrv_hl_acct_key                         --HelpLoan BasiAccount Key                                                                                            -- ,p_agrv_hl_acct_key
                   ,p_agrv_hl_acct_status           => w_rchl.agrv_hl_acct_status                      --HelpLoan BasiAccount Status                                                                                         -- ,p_agrv_hl_acct_status
                   ,p_agrv_hl_st_opening_bal_amnt   => w_rchl.agrv_hl_st_opening_bal_amnt              --HelpLoan Prevs Balance (Opening Balance)                                                                            -- ,p_agrv_hl_st_opening_bal_amnt
                   ,p_agrv_hl_cur_pymnt_amnt        => w_rchl.agrv_hl_cur_pymnt_amnt                   --HelpLoan Curr Payments                                                                                              -- ,p_agrv_hl_cur_pymnt_amnt
                   ,p_agrv_hl_last_pymnt_dt         => w_rchl.agrv_hl_last_pymnt_dt                    --HelpLoan Lastyments Date                                                                                            -- ,p_agrv_hl_last_pymnt_dt
                   ,p_agrv_hl_cur_adj_amnt          => w_rchl.agrv_hl_cur_adj_amnt                     --HelpLoan Curr Adjustment Amnt                                                                                       -- ,p_agrv_hl_cur_adj_amnt
                   ,p_agrv_hl_unpaid_amnt           => w_rchl.agrv_hl_unpaid_amnt                      --HelpLoan UnpaAmnt                                                                                                   -- ,p_agrv_hl_unpaid_amnt
                   ,p_agrv_hl_unpaid_lbl            => w_rchl.agrv_hl_unpaid_lbl                       --HelpLoan UnpaLabel                                                                                                  -- ,p_agrv_hl_unpaid_lbl
                   ,p_agrv_hl_5th_inv_ppln_id       => w_rchl.agrv_hl_5th_inv_ppln_id                  --HelpLoan latest Invoice ppln ID                                                                                     -- ,p_agrv_hl_5th_inv_ppln_id
                   ,p_agrv_hl_5th_inv_tran_id       => w_rchl.agrv_hl_5th_inv_tran_id                  --HelpLoan latest Tran ID                                                                                             -- ,p_agrv_hl_5th_inv_tran_id
                   ,p_agrv_hl_5th_inv_no            => w_rchl.agrv_hl_5th_inv_no                       --HelpLoan 5th er Charge/Nuisance Charge Invoice#                                                                     -- ,p_agrv_hl_5th_inv_no
                   ,p_agrv_hl_5th_inv_srv_dt        => w_rchl.agrv_hl_5th_inv_srv_dt                   --HelpLoan 5th er Charge/Nuisance Service Date                                                                        -- ,p_agrv_hl_5th_inv_srv_dt
                   ,p_agrv_hl_5th_inv_lien_no       => w_rchl.agrv_hl_5th_inv_lien_no                  --HelpLoan 5th er Charge/Nuisance Lien#                                                                               -- ,p_agrv_hl_5th_inv_lien_no
                   ,p_agrv_hl_5th_inv_bal           => w_rchl.agrv_hl_5th_inv_bal                      --HelpLoan 5th er Charge/Nuisance Charge Invoice Balance                                                              -- ,p_agrv_hl_5th_inv_bal
                   ,p_agrv_hl_5th_inv_desc          => w_rchl.agrv_hl_5th_inv_desc                     --HelpLoan 5th er Charge/Nuisance Invoice Description                                                                 -- ,p_agrv_hl_5th_inv_desc
                   ,p_agrv_hl_5th_cur_prv_flag      => w_rchl.agrv_hl_5th_cur_prv_flag                 --HelpLoan 5th rent/Previous flag                                                                                     -- ,p_agrv_hl_5th_cur_prv_flag
                   ,p_agrv_hl_4th_inv_no            => w_rchl.agrv_hl_4th_inv_no                       --HelpLoan 4th er Charge/Nuisance Charge Invoice#                                                                     -- ,p_agrv_hl_4th_inv_no
                   ,p_agrv_hl_4th_inv_srv_dt        => w_rchl.agrv_hl_4th_inv_srv_dt                   --HelpLoan 4th er Charge/Nuisance Service Date                                                                        -- ,p_agrv_hl_4th_inv_srv_dt
                   ,p_agrv_hl_4th_inv_lien_no       => w_rchl.agrv_hl_4th_inv_lien_no                  --HelpLoan 4th er Charge/Nuisance Lien#                                                                               -- ,p_agrv_hl_4th_inv_lien_no
                   ,p_agrv_hl_4th_inv_bal           => w_rchl.agrv_hl_4th_inv_bal                      --HelpLoan 4th er Charge/Nuisance Balance                                                                             -- ,p_agrv_hl_4th_inv_bal
                   ,p_agrv_hl_4th_inv_desc          => w_rchl.agrv_hl_4th_inv_desc                     --HelpLoan 4th er Charge/Nuisance Description                                                                         -- ,p_agrv_hl_4th_inv_desc
                   ,p_agrv_hl_4th_cur_prv_flag      => w_rchl.agrv_hl_4th_cur_prv_flag                 --HelpLoan 4th rent/Previous flag                                                                                     -- ,p_agrv_hl_4th_cur_prv_flag
                   ,p_agrv_hl_3rd_inv_no            => w_rchl.agrv_hl_3rd_inv_no                       --HelpLoan 3rd er Charge/Nuisance Charge Invoice#                                                                     -- ,p_agrv_hl_3rd_inv_no
                   ,p_agrv_hl_3rd_inv_srv_dt        => w_rchl.agrv_hl_3rd_inv_srv_dt                   --HelpLoan 3rd er Charge/Nuisance Service Date                                                                        -- ,p_agrv_hl_3rd_inv_srv_dt
                   ,p_agrv_hl_3rd_inv_lien_no       => w_rchl.agrv_hl_3rd_inv_lien_no                  --HelpLoan 3rd er Charge/Nuisance Lien#                                                                               -- ,p_agrv_hl_3rd_inv_lien_no
                   ,p_agrv_hl_3rd_inv_bal           => w_rchl.agrv_hl_3rd_inv_bal                      --HelpLoan 3rd Meter Charge/Nuisance Balance                                                                          -- ,p_agrv_hl_3rd_inv_bal
                   ,p_agrv_hl_3rd_inv_desc          => w_rchl.agrv_hl_3rd_inv_desc                     --HelpLoan 3rd Meter Charge/Nuisance Description                                                                      -- ,p_agrv_hl_3rd_inv_desc
                   ,p_agrv_hl_3rd_cur_prv_flag      => w_rchl.agrv_hl_3rd_cur_prv_flag                 --HelpLoan 3rd Current/Previous flag                                                                                  -- ,p_agrv_hl_3rd_cur_prv_flag
                   ,p_agrv_hl_2nd_inv_no            => w_rchl.agrv_hl_2nd_inv_no                       --HelpLoan 2nd Meter Charge/Nuisance Charge Invoice#                                                                  -- ,p_agrv_hl_2nd_inv_no
                   ,p_agrv_hl_2nd_inv_srv_dt        => w_rchl.agrv_hl_2nd_inv_srv_dt                   --HelpLoan 2nd Meter Charge/Nuisance Service Date                                                                     -- ,p_agrv_hl_2nd_inv_srv_dt
                   ,p_agrv_hl_2nd_inv_lien_no       => w_rchl.agrv_hl_2nd_inv_lien_no                  --HelpLoan 2nd Meter Charge/Nuisance Lien#                                                                            -- ,p_agrv_hl_2nd_inv_lien_no
                   ,p_agrv_hl_2nd_inv_bal           => w_rchl.agrv_hl_2nd_inv_bal                      --HelpLoan 2nd Meter Charge/Nuisance Balance                                                                          -- ,p_agrv_hl_2nd_inv_bal
                   ,p_agrv_hl_2nd_inv_desc          => w_rchl.agrv_hl_2nd_inv_desc                     --HelpLoan 2nd Meter Charge/Nuisance Description                                                                      -- ,p_agrv_hl_2nd_inv_desc
                   ,p_agrv_hl_2nd_cur_prv_flag      => w_rchl.agrv_hl_2nd_cur_prv_flag                 --HelpLoan 2nd Current/Previous flag                                                                                  -- ,p_agrv_hl_2nd_cur_prv_flag
                   ,p_agrv_hl_1st_inv_no            => w_rchl.agrv_hl_1st_inv_no                       --HelpLoan 1st Meter Charge/Nuisance Charge Invoice#                                                                  -- ,p_agrv_hl_1st_inv_no
                   ,p_agrv_hl_1st_inv_srv_dt        => w_rchl.agrv_hl_1st_inv_srv_dt                   --HelpLoan 1st Meter Charge/Nuisance Service Date                                                                     -- ,p_agrv_hl_1st_inv_srv_dt
                   ,p_agrv_hl_1st_inv_lien_no       => w_rchl.agrv_hl_1st_inv_lien_no                  --HelpLoan 1st Meter Charge/Nuisance Lien#                                                                            -- ,p_agrv_hl_1st_inv_lien_no
                   ,p_agrv_hl_1st_inv_bal           => w_rchl.agrv_hl_1st_inv_bal                      --HelpLoan 1st Meter Charge/Nuisance Balance                                                                          -- ,p_agrv_hl_1st_inv_bal
                   ,p_agrv_hl_1st_inv_desc          => w_rchl.agrv_hl_1st_inv_desc                     --HelpLoan 1st Meter Charge/Nuisance Description                                                                      -- ,p_agrv_hl_1st_inv_desc
                   ,p_agrv_hl_1st_cur_prv_flag      => w_rchl.agrv_hl_1st_cur_prv_flag                 --HelpLoan 1st Current/Previous flag                                                                                  -- ,p_agrv_hl_1st_cur_prv_flag
                   ,p_agrv_hl_cur_rem_inv_bal       => w_rchl.agrv_hl_cur_rem_inv_bal                  --HelpLoan Current Remaining Meter Charge/Nuisance Balance                                                            -- ,p_agrv_hl_cur_rem_inv_bal
                   ,p_agrv_hl_cur_pnlty_amnt        => w_rchl.agrv_hl_cur_pnlty_amnt                   --HelpLoan Current Penalty Amnt                                                                                       -- ,p_agrv_hl_cur_pnlty_amnt
                   ,p_agrv_hl_prv_rem_inv_bal       => w_rchl.agrv_hl_prv_rem_inv_bal                  --HelpLoan Previous/Current Invoice Balance                                                                           -- ,p_agrv_hl_prv_rem_inv_bal
                   ,p_agrv_hl_prv_pymnt_amnt        => w_rchl.agrv_hl_prv_pymnt_amnt                   --HelpLoan Sum of previous payment Amnt                                                                               -- ,p_agrv_hl_prv_pymnt_amnt
                   ,p_agrv_hl_prv_pnlty_amnt        => w_rchl.agrv_hl_prv_pnlty_amnt                   --HelpLoan Sum of previous penalty Amnt                                                                               -- ,p_agrv_hl_prv_pnlty_amnt
                   ,p_agrv_hl_prv_adj_amnt          => w_rchl.agrv_hl_prv_adj_amnt                     --HelpLoan Previous adjacement Amnt                                                                                   -- ,p_agrv_hl_prv_adj_amnt
                   ,p_agrv_hl_corr_lbl              => w_rchl.agrv_hl_corr_lbl                         --HelpLoan Correction Label                                                                                           -- ,p_agrv_hl_corr_lbl
                   ,p_agrv_hl_corr_ppln_amnt        => w_rchl.agrv_hl_corr_ppln_amnt                   --HelpLoan Corrected LOAN Total Amount                                                                                -- ,p_agrv_hl_corr_ppln_amnt
                   ,p_agrv_hl_tot_inv_bal           => w_rchl.agrv_hl_tot_inv_bal                      --HelpLoan Total Invoice Balance                                                                                      -- ,p_agrv_hl_tot_inv_bal
                   ,p_agrv_hl_tot_wo_pnlty          => w_rchl.agrv_hl_tot_wo_pnlty                     --HelpLoan Total Balance WO Penalties                                                                                 -- ,p_agrv_hl_tot_wo_pnlty
                   ,p_agrv_hl_st_closing_bal_amnt   => w_rchl.agrv_hl_st_closing_bal_amnt              --HelpLoan Closing Balance                                                                                            -- ,p_agrv_hl_st_closing_bal_amnt
                   ,p_agrv_hl_plan_exists           => w_rchl.agrv_hl_plan_exists                      --HelpLoan If Plan do not exists then just create Bill with total outstanding                                         -- ,p_agrv_hl_plan_exists
                   ,p_agrv_hl_5th_mi_amnt_rcvd      => w_rchl.agrv_hl_5th_mi_amnt_rcvd                 --HelpLoan 5th payment installment amount received                                                                    -- ,p_agrv_hl_5th_mi_amnt_rcvd
                   ,p_agrv_hl_5th_mi_rcvd_dt        => w_rchl.agrv_hl_5th_mi_rcvd_dt                   --HelpLoan 5th payment installment received date                                                                      -- ,p_agrv_hl_5th_mi_rcvd_dt
                   ,p_agrv_hl_4th_mi_amnt_rcvd      => w_rchl.agrv_hl_4th_mi_amnt_rcvd                 --HelpLoan 4th payment installment amount received                                                                    -- ,p_agrv_hl_4th_mi_amnt_rcvd
                   ,p_agrv_hl_4th_mi_rcvd_dt        => w_rchl.agrv_hl_4th_mi_rcvd_dt                   --HelpLoan 4th payment installment received date                                                                      -- ,p_agrv_hl_4th_mi_rcvd_dt
                   ,p_agrv_hl_3rd_mi_amnt_rcvd      => w_rchl.agrv_hl_3rd_mi_amnt_rcvd                 --HelpLoan 3rd payment installment amount received                                                                    -- ,p_agrv_hl_3rd_mi_amnt_rcvd
                   ,p_agrv_hl_3rd_mi_rcvd_dt        => w_rchl.agrv_hl_3rd_mi_rcvd_dt                   --HelpLoan 3rd payment installment received date                                                                      -- ,p_agrv_hl_3rd_mi_rcvd_dt
                   ,p_agrv_hl_2nd_mi_amnt_rcvd      => w_rchl.agrv_hl_2nd_mi_amnt_rcvd                 --HelpLoan 2nd payment installment amount received                                                                    -- ,p_agrv_hl_2nd_mi_amnt_rcvd
                   ,p_agrv_hl_2nd_mi_rcvd_dt        => w_rchl.agrv_hl_2nd_mi_rcvd_dt                   --HelpLoan 2nd payment installment received date                                                                      -- ,p_agrv_hl_2nd_mi_rcvd_dt
                   ,p_agrv_hl_1st_mi_amnt_rcvd      => w_rchl.agrv_hl_1st_mi_amnt_rcvd                 --HelpLoan 1st payment installment amount received                                                                    -- ,p_agrv_hl_1st_mi_amnt_rcvd
                   ,p_agrv_hl_1st_mi_rcvd_dt        => w_rchl.agrv_hl_1st_mi_rcvd_dt                   --HelpLoan 1st payment installment received date                                                                      -- ,p_agrv_hl_1st_mi_rcvd_dt
                   ,p_agrv_hl_rem_mi_amnt_rcvd      => w_rchl.agrv_hl_rem_mi_amnt_rcvd                 --HelpLoan remaining monthly installment Payments                                                                     -- ,p_agrv_hl_rem_mi_amnt_rcvd
                   ,p_agrv_hl_ppln_id               => w_rchl.agrv_hl_ppln_id                          --HelpLoan Plan ID                                                                                                    -- ,p_agrv_hl_ppln_id
                   ,p_agrv_hl_ppln_no_due           => w_rchl.agrv_hl_ppln_no_due                      --HelpLoan Plan Due No                                                                                                -- ,p_agrv_hl_ppln_no_due
                   ,p_agrv_hl_ppln_due_amnt         => w_rchl.agrv_hl_ppln_due_amnt                    --HelpLoan Plan Due Amount                                                                                            -- ,p_agrv_hl_ppln_due_amnt
                   ,p_agrv_hl_ppln_tot_amnt         => w_rchl.agrv_hl_ppln_tot_amnt                    --HelpLoan total Agreement Amount                                                                                     -- ,p_agrv_hl_ppln_tot_amnt
                   ,p_agrv_hl_oth_debts             => w_rchl.agrv_hl_oth_debts                        --Help Loan Other debt Not to use. Use Penalty and Adju                                                               -- ,p_agrv_hl_ppln_start_dt
                   ,p_agrv_hl_ppln_start_dt         => w_rchl.agrv_hl_ppln_start_dt                    --HelpLoan Agreement Start Date                                                                                       -- ,p_agrv_hl_total_due_amnt
                   ,p_agrv_hl_total_due_amnt        => w_rchl.agrv_hl_total_due_amnt                   --HelpLoan Total Due Amount for this Bill                                                                             -- ,p_agrv_hl_oth_debts
                   ,p_agrv_hl_mssg1_hdr             => w_rchl.agrv_hl_mssg1_hdr                        --HelpLoan Message1 Header                                                                                            -- ,p_agrv_hl_mssg1_hdr
                   ,p_agrv_hl_mssg1_dtl             => w_rchl.agrv_hl_mssg1_dtl                        --HelpLoan Message1 Detail                                                                                            -- ,p_agrv_hl_mssg1_dtl
                   ,p_agrv_hl_mssg2_hdr             => w_rchl.agrv_hl_mssg2_hdr                        --HelpLoan Message2 Header                                                                                            -- ,p_agrv_hl_mssg2_hdr
                   ,p_agrv_hl_mssg2_dtl             => w_rchl.agrv_hl_mssg2_dtl                        --HelpLoan Message2 Detail                                                                                            -- ,p_agrv_hl_mssg2_dtl
                   ,p_agrv_hl_mssg3_hdr             => w_rchl.agrv_hl_mssg3_hdr                        --HelpLoan Message3 Header                                                                                            -- ,p_agrv_hl_mssg3_hdr
                   ,p_agrv_hl_mssg3_dtl             => w_rchl.agrv_hl_mssg3_dtl                        --HelpLoan Message3 Detail                                                                                            -- ,p_agrv_hl_mssg3_dtl
                   ,p_agrv_hl_mssg4_hdr             => w_rchl.agrv_hl_mssg4_hdr                        --HelpLoan Message4 Header                                                                                            -- ,p_agrv_hl_mssg4_hdr
                   ,p_agrv_hl_mssg4_dtl             => w_rchl.agrv_hl_mssg4_dtl                        --HelpLoan Message4 Detail                                                                                            -- ,p_agrv_hl_mssg4_dtl
                   ,p_agrv_hl_debt_to_exclude       => w_rchl.agrv_hl_debt_to_exclude                  --Bankruptcy debt to be excluded from calculatio, But needs to included in closing balance --Add 5905  3.0.0.39       -- ,p_agrv_hl_debt_to_exclude
                   ,p_hl_cur_xfer_rcpt_in_amnt      => w_rchl.hl_cur_xfer_rcpt_in_amnt                 --Current xfer in  (Payment came in from other account)  --Add 6230                                                   -- ,p_hl_cur_xfer_rcpt_in_amnt
                   ,p_hl_prv_xfer_rcpt_in_amnt      => w_rchl.hl_prv_xfer_rcpt_in_amnt                 --Previous xfer in  (Payment came in from other account) --Add 6230                                                   -- ,p_hl_prv_xfer_rcpt_in_amnt
                   ,p_hl_cur_xfer_rcpt_ou_amnt      => w_rchl.hl_cur_xfer_rcpt_ou_amnt                 --Current xfer out (Payment went out to other account)   --Add 6230                                                   -- ,p_hl_cur_xfer_rcpt_ou_amnt
                   ,p_hl_prv_xfer_rcpt_ou_amnt      => w_rchl.hl_prv_xfer_rcpt_ou_amnt                 --Previous xfer out (Payment went out to other account)  --Add 6230                                                   -- ,p_hl_prv_xfer_rcpt_ou_amnt
                   ,p_hl_tot_debt_till_bill_dt      => w_rchl.hl_tot_debt_till_bill_dt                 --Total debt till billing Date                           --Add 6230                                                   -- ,p_hl_tot_debt_till_bill_dt
                   ,p_hl_bal_not_in_bill            => w_rchl.hl_bal_not_in_bill                       --Balance which is not part of this bill                 --Add 6230                                                   -- ,p_hl_bal_not_in_bill
                   ,p_hl_mnthly_inst_amnt           => w_rchl.hl_mnthly_inst_amnt                      --HELPLOAN Monthly Installment for the Bill              --Add 6230                                                   -- ,p_hl_mnthly_inst_amnt
                   ,p_hl_tot_inst_due               => w_rchl.hl_tot_inst_due                          --HELPLOAN total Due on Bill if not on plan              --Add 6230                                                   -- ,p_hl_tot_inst_due
                   ,p_hlrc_status                   => w_rchl.hlrc_status                              --HELPLOAN Repair Charge Status                          --Add 6230                                                   -- ,p_hlrc_status
                   ,p_hl_inv_tran_ids								=> w_rchl.hl_inv_tran_ids													 --HELPLOAN Invoice Tran IDs are stored to fix 10212      --Add 10212
                   );
                   if w_rchl.agrv_hl_unpaid_lbl is not null then
                      if w_hlrc_status  is null then w_hlrc_status := w_rchl.hlrc_status; else w_hlrc_status := w_hlrc_status ||','||w_rchl.hlrc_status; end if; --Add 6230
                      --w_rchl.agrv_hl_ppln_bal_amnt  := r_st.ppln_bal_amnt;
                      if w_rchl.agrv_hl_5th_cur_prv_flag = 'C' then w_hlp_curr_chgs := w_hlp_curr_chgs + nvl(w_rchl.agrv_hl_5th_inv_bal,0); end if;
                      if w_rchl.agrv_hl_4th_cur_prv_flag = 'C' then w_hlp_curr_chgs := w_hlp_curr_chgs + nvl(w_rchl.agrv_hl_4th_inv_bal,0); end if;
                      if w_rchl.agrv_hl_3rd_cur_prv_flag = 'C' then w_hlp_curr_chgs := w_hlp_curr_chgs + nvl(w_rchl.agrv_hl_3rd_inv_bal,0); end if;
                      if w_rchl.agrv_hl_2nd_cur_prv_flag = 'C' then w_hlp_curr_chgs := w_hlp_curr_chgs + nvl(w_rchl.agrv_hl_2nd_inv_bal,0); end if;
                      if w_rchl.agrv_hl_1st_cur_prv_flag = 'C' then w_hlp_curr_chgs := w_hlp_curr_chgs + nvl(w_rchl.agrv_hl_1st_inv_bal,0); end if;
                      if w_rchl.agrv_hl_cur_rem_inv_bal is not null then  w_hlp_curr_chgs := w_hlp_curr_chgs + nvl(w_rchl.agrv_hl_cur_rem_inv_bal,0); end if;
                      w_label := 'e204';
                      debug_trace(w_procedure_name,'...w_city_acct                                    = ' || w_city_acct);
                      debug_trace(w_procedure_name,'...w_rchl.agrv_hl_acct_key                        = ' || w_rchl.agrv_hl_acct_key);
                      debug_trace(w_procedure_name,'...w_rchl.agrv_hl_total_due_amnt                  = ' || w_rchl.agrv_hl_total_due_amnt);
                      debug_trace(w_procedure_name,'...nvl(w_ptbm.penalty_date,w_ptbm.billing_date+30)= ' || datec(nvl(w_ptbm.penalty_date,w_ptbm.billing_date+30)));
                      debug_trace(w_procedure_name,'...w_rchl.agrv_hl_scan_line                       = ' || w_rchl.agrv_hl_scan_line);
                      w_rchl.hl_acct_bal_amnt :=      r_st.acct_bal_amnt;  --Add 6230 Already passing to helploan routine. store in database
                      get_scan_line(p_scan_type          => 'B2_ACCT'                                        --It decides what control day should be in scan line  --Add 5869 3.0.0.35
                                   ,p_w1_acct_no         => w_city_acct                                      --16Digit Water1 Account without dashes
                                   ,p_acct_key           => w_rchl.agrv_hl_acct_key                          --9 Alphacharactder Basis2 Account key
                                   ,p_supply_type        => r_st.supply_type                                 --Account's Supply Type
                                   --,p_acct_status        => w_rchl.agrv_hl_acct_status                       --Account Status A/D Active/Discontinue del 5869 --3.0.0.35
                                   ,p_amnt_post_30_39    => w_rchl.agrv_hl_total_due_amnt                    --Amount in 30to39th Position. Normally it's Penalty Amount for Bill and Same as Total Due for HelpLoan
                                   ,p_amnt_post_40_49    => w_rchl.agrv_hl_total_due_amnt                    --Amount in 40to49th Position. Normally it's Total Due Amount for Bill and HelpLoan
                                   ,p_due_date           => nvl(w_ptbm.penalty_date,w_ptbm.billing_date+30)  --Due Date when Bill is due
                                   ,p_scan_line          => w_rchl.agrv_hl_scan_line                         --Scan Line will be produced
                                   );
                      w_label := 'e205';
                      debug_trace(w_procedure_name,'...w_rchl.agrv_hl_scan_line   = ' || w_rchl.agrv_hl_scan_line);
                   end if;
             end if;
          end if;
        end loop;
        w_label := 'e206';
        if w_rchl.agrv_rc_acct_key is not null or w_rchl.agrv_hl_acct_key is not null then
           get_agrv_bkgrnd_prnt_string;
        end if;
        w_label := 'e207';
        w_ptbm.agrv_rc_st_opening_bal_amnt  :=  w_rchl.agrv_rc_st_opening_bal_amnt;
        w_ptbm.agrv_rc_st_closing_bal_amnt  :=  w_rchl.agrv_rc_st_closing_bal_amnt;
        w_ptbm.agrv_hl_st_opening_bal_amnt  :=  w_rchl.agrv_hl_st_opening_bal_amnt;
        w_ptbm.agrv_hl_st_closing_bal_amnt  :=  w_rchl.agrv_hl_st_closing_bal_amnt;
        w_ptbm.bill_tran_id                 :=  w_tran_id;
        debug_trace(w_procedure_name,'...w_rchl.agrv_rc_st_opening_bal_amnt =' || w_rchl.agrv_rc_st_opening_bal_amnt); --del 4398
        debug_trace(w_procedure_name,'...w_rchl.agrv_rc_st_closing_bal_amnt =' || w_rchl.agrv_rc_st_closing_bal_amnt); --del 4398
        --End Add 4398
        --Start add 4398 Not needed now
        --update cis_bills
        --set bill_amnt             = bill_amnt             + nvl(w_ptbm.agrv_rc_st_opening_bal_amnt,0)
        --  , bill_closing_bal_amnt = bill_closing_bal_amnt + nvl(w_ptbm.agrv_rc_st_closing_bal_amnt,0)
        --where bill_id = w_bill_id
        --returning bill_amnt, bill_closing_bal_amnt, bill_key into l_new_bamnt, l_new_bcbamnt, l_bill_key;
        --
        --update cis_bill_lines set bill_amnt = l_new_bamnt, closing_bal_amnt= l_new_bcbamnt
        --where bill_key = l_bill_key;
       --End Add 4398
        --debug_trace(w_procedure_name,'...Agency Tran ID = ' || w_agn_tran_id); --del 4398
        -- Start del 4398
        -- --Start Add 3706
        -- if w_agn_tran_id is not null then
        --  w_label := 'e208';
        --  select
        --      blt.opening_bal_amnt
        --     ,blt.closing_bal_amnt
        --     ,blt.bill_tran_amnt
        --  into
        --      w_agn_previous_balance_amnt
        --     ,w_agn_total_due_amnt
        --     ,w_agn_current_charge_amnt
        --  from cis_bill_trans blt
        --  where blt.tran_id = w_agn_tran_id;
        --
        --  w_label := 'e209';
        --  w_ptbm.previous_balance_amnt := nvl(w_ptbm.previous_balance_amnt,0) + nvl(w_agn_previous_balance_amnt,0);
        --  w_ptbm.total_due_amnt        := nvl(w_ptbm.total_due_amnt,0)        + nvl(w_agn_total_due_amnt,0);
        --  w_ptbm.current_charge_amnt   := nvl(w_ptbm.current_charge_amnt,0)   + nvl(w_agn_current_charge_amnt,0);
        --
        -- end if;
        -- --Start End 3706
        -- End del 4398
        w_label := 'e210';
        debug_trace(w_procedure_name,'...w_ptbm.total_due_amnt 		--> ' || w_ptbm.total_due_amnt);
        debug_trace(w_procedure_name,'...w_pay_profile_code_orig  --> ' || w_pay_profile_code_orig);
        --Start Add 6230 3.0.0.41
        if w_pay_profile_code_orig = 'TAP-STD' then -----TAP-STD Bill might be having TAP bills.
           w_label := 'e211';
           debug_trace(w_procedure_name,'...w_pay_profile_code_orig --> ' || w_pay_profile_code_orig);
           debug_trace(w_procedure_name,'...w_pay_profile_code 			--> ' || w_pay_profile_code);
           debug_trace(w_procedure_name,'...w_ptbm.bill_tran_id 		--> ' || w_ptbm.bill_tran_id);
           w_tap_bill_print.tran_id := w_ptbm.bill_tran_id;
           begin
              w_label := 'e212';
              phlst007.get_tap_bill_print
              (
                p_tran_id        => w_tap_bill_print.tran_id
               ,p_tap_bill_print => w_tap_bill_print
               ,p_tap_error_code => w_tap_error_code
               ,p_tap_error_text => w_tap_error_text
              );
              --Start Add 9749
              --if nvl(w_ptbm.lien,0) > 0 then
              --	 w_ptbm.total_due_amnt := w_ptbm.total_due_amnt - nvl(w_ptbm.lien,0);
              --	 w_ptbm.lien           := 0;
              --end if;
              --End Add 9749
           exception
              when others then
                 w_ptbm.tap_group_num := null;
                 w_tap_error_text     := substr(sqlcode || sqlerrm,1,300);
           end;
           w_label := 'e213';
           debug_trace(w_procedure_name,'...w_tap_error_code --> ' || w_tap_error_code);
           debug_trace(w_procedure_name,'...w_tap_error_text --> ' || w_tap_error_text);
           -- w_tap_bill_print (record)
           -- tran_id                      number(15)
           --,bill_date                    date
           --,acct_id                      number(15)
           --,iwbe_appl_id                 number(15)  -- null if ACCT is not in TAP as at bill date
           --,group_num                    number(15)  -- null if ACCT is not in TAP as at bill date
           --,cur_part_from_date           date        -- All TAP applications in the current continuous participation have the same TAP_EF_ID
                                                       -- This is the earliest start date from these applications
                                                       -- The following number fields depend on the continuous TAP participation date range
                                                       -- equals from date to bill date
           if w_tap_error_text is not null then
              w_ptbm.tap_error_text :=  w_tap_error_text;
           end if;
           w_ptbm.tap_group_num                   := w_tap_bill_print.group_num;                         -- null if ACCT is not in TAP as at bill date
           if nvl(w_tap_bill_print.group_num,-1) in (1,2,5) then -- Only Group Num 1,2,5 will have TAP History
              w_ptbm.tap_tot_act_usg_srv_chg      := w_tap_bill_print.tot_act_uas_charges_amnt; 					  --number -- Sum total charges from adjustment records for current continuous
                                                                                                            -- participation from its start up to requested bill tran date
              w_ptbm.tap_tot_chg_amnt             := w_tap_bill_print.tot_tap_charges_amnt;     						--number -- Difference between these two amounts above and below
              w_ptbm.tap_tot_saved_amnt           := w_tap_bill_print.tot_saved_amnt;           					  --number -- Sum of the adjustment amounts for the same period
              w_ptbm.tap_tot_past_due_paid_amnt   := w_tap_bill_print.tot_past_due_paid_amnt;   					  --number -- Sum of all receipts (via allocation records) minus any TAP bills paid
                                                                                                            -- TAP Bills Paid = Sum TAP bill total amount - Sum TAP bill balance
              w_ptbm.tap_recertify_date           := w_tap_bill_print.recertify_date;           					  --date   -- Expected end date from the current TAP application
              w_ptbm.tap_pym_2_arrs               := w_tap_bill_print.bill_diff_amnt;           					  --number -- Positive on Cost --Add 7055
              w_billing_dateyyyymmdd              := dateyyyymmdd(w_ptbm.billing_date);
              w_ptbm.tap_chg                      := w_tap_bill_print.iwbe_bill_amnt;           --Add 7164D
							--ef_count is same as ef_paid_factor
							--bf_count is same as bf_paid_factor
						  --w_ptbm.tap_ef_count                 := w_tap_bill_print.ef_count;               --Del 9984B --number -- EF_PAID_FACTOR from history view  -- Del 9249LN
					   	--w_ptbm.tap_ef_amount 								:= w_tap_bill_print.ef_amount;							--Add 9984 	-- The amount of penalty forgiveness given so far
   						w_ptbm.tap_bf_max_tot_amnt          := w_tap_bill_print.bf_max_tot_amnt;      		--Add 9984  -- Likely maximum total of principal forgiveness that can be earned.               -- Add 9249A
   						--w_ptbm.tap_bf_credit_tot_amnt       := w_tap_bill_print.bf_credit_tot_amnt			--Add 9984  -- Total amount of principal forgiveness given so far                              -- Add 9249A
              w_ptbm.tap_ef_count                 := w_tap_bill_print.ef_paid_factor;           --Add 9984B --number -- EF_PAID_FACTOR from history view  -- Add 9249LN
							w_ptbm.tap_bf_count           			:= w_tap_bill_print.bf_paid_factor;      			--Add 9984B -- The number of bills that have been paid that qualify for principal forgiveness  -- Add 9249A
					   	--w_ptbm.tap_pnlty_frgv_amnt    			:= w_tap_bill_print.ef_amount;							--Del 9984B	--Add 9984 	-- The amount of penalty forgiveness given so far
   						--w_ptbm.tap_prin_frgv_amnt           := w_tap_bill_print.bf_credit_tot_amnt;			--Del 9984B --Add 9984  -- Total amount of principal forgiveness given so far                              -- Add 9249A
							--w_ptbm.tap_pnlty_frgv_dt						:= w_tap_bill_print.ef_paid_factor_date;		--Del 9984B --Add 9984B -- Penalty forgiveness date
						  --w_ptbm.tap_prin_frgv_dt							:= w_tap_bill_print.bf_paid_factor_date;		--Del 9984B --Add 9984B -- Principal forgiveness date
              /* Start Add 7164 */
              if w_ptbm.tap_tot_saved_amnt  < 0 then
                 w_ptbm.tap_tot_saved_amnt := 0;
              end if;
              /* End Add 7164 */
              for r_pppc in ( select prior_pay_profile_code
                                from phl_tap_application_log
                               where cust_id     = w_cust_id --16027000061
                                 and inst_id     = w_inst_id --16027000071
                                 and supply_type = 'WATER'
                                 and w_billing_dateyyyymmdd between start_yyyymmdd and end_yyyymmdd  --'20130130' and '20130609'
                                 order by iwbe_appl_id desc
                            )
              loop
                 w_pay_profile_code := r_pppc.prior_pay_profile_code;
                 exit;
              end loop;
           end if;
        /* --Del 9984B
        else --Add 9984 --When Customer moves out of TAP and gets
	        --Start Add 9984
        	debug_trace(w_procedure_name,'...g_tap_acct_at_some_stage  --> ' || g_tap_acct_at_some_stage);
	        if g_tap_acct_at_some_stage like 'TAP%' then --Account in TAP at some stage. [cis.attribute3 like 'TAP%']
	        	 begin
	        	 	  select user_reference2 into g_prv_bill_in_tap from cis.cis_transactions where tran_id = g_prev_bill_tran_id;
			        	debug_trace(w_procedure_name,'...g_prv_bill_in_tap  --> ' || g_prv_bill_in_tap);
						 		if g_prv_bill_in_tap like 'TAP%' then
		              select max(decode(task_code,'TAPCERF',tran_date,null))
		                    ,max(decode(task_code,'TAPCEBF',tran_date,null))
		              			,sum(decode(task_code,'TAPCERF',tran_tot_amnt,null))
		                    ,sum(decode(task_code,'TAPCEBF',tran_tot_amnt,null))
		                into
												w_ptbm.tap_pnlty_frgv_dt
											 ,w_ptbm.tap_prin_frgv_dt
											 ,w_ptbm.tap_pnlty_frgv_amnt
											 ,w_ptbm.tap_prin_frgv_amnt
										from cis_transactions
		                where cust_id 		= w_cust_id
		                  and inst_id 		= w_inst_id
		                  and supply_type = w_supply_type
		                  and tran_id     < w_ptbm.bill_tran_id
		                  and tran_id     > g_prev_bill_tran_id
		                  and task_code   in ('TAPCERF','TAPCRBF');
		            end if;z
	        	 exception
	        	 	  when others then
	        	 	  	g_prv_bill_in_tap 					:= null;
									w_ptbm.tap_pnlty_frgv_dt		:= null;
									w_ptbm.tap_prin_frgv_dt			:= null;
									w_ptbm.tap_pnlty_frgv_amnt	:= null;
									w_ptbm.tap_prin_frgv_amnt		:= null;
	        	 end;
	        end if;
	        --End Add 9984
	      */ --Del 9984B
        end if;
        debug_trace(w_procedure_name,'...w_pay_profile_code --> ' || w_pay_profile_code);
        --End Add 6230 3.0.0.41
        --Start Add 3910  --Logic from Trigger phl_meter_wos_d0002
        if w_pay_profile_code in ( 'RES-GRP'
                                  ,'RES-HOLD'
                                  ,'RES-STD'
                                  ,'RES-STM'
                                  ,'WRBCC'
                                  ,'USTRA'
                                  ,'TAP-BAK'  --Add 6230A
                                  ,'TAP-PLL'  --Add 6230A
                                  ,'TAP-STD'  --Add 6230A
                                 ) then
         w_res_comm_ind := 'R';
        elsif w_pay_profile_code in ('COM-STD','COM-STM','COM-GRP','COM-HOLD','SURCHRGE') then
         w_res_comm_ind := 'C';
        end if;
        --End Add 3910
         --Mod Start 3327b Start Add 3327
         w_inst_agr_exists := 0;
         debug_trace(w_procedure_name,' w_ptbm.billing_date --> ' || datec(w_ptbm.billing_date));
         debug_trace(w_procedure_name,' w_inst_id --> ' || w_inst_id);
         --if      w_pay_profile_code = 'COM-STD'    --Del 3910 --Take care above
         --     or w_pay_profile_code = 'COM-STM'    --Del 3910
         --     or w_pay_profile_code = 'COM-GRP'    --Del 3910
         --     or w_pay_profile_code = 'COM-HOLD'   --Del 3910
         --     or w_pay_profile_code = 'SURCHRGE'   --Del 3910
         if w_res_comm_ind = 'C'                     --Add 3910
         then
            select count(*) into w_inst_agr_exists from cis.cis_inst_agreements
             where inst_id = w_inst_id
               and supply_type = 'WATER' -- Add 3.0.0.1
               and nvl(w_ptbm.billing_date,sysdate) between nvl(agr_from_date,w_ptbm.billing_date-1) and nvl(agr_upto_date,to_date('12/31/9999','mm/dd/yyyy'));
            debug_trace(w_procedure_name,' w_inst_agr_exists --> ' || w_inst_agr_exists);
            w_agr_exists := 'Y';    --Add 3706
            if w_inst_agr_exists = 0 then
               w_pay_profile_code := 'NOTSTMAG';  --NOT HAVING A STORM WATER AGREEMENT
               w_agr_exists := 'N';  --Add 3706
            end if;
         else     --Start Add 3706
            select count(*) into w_inst_agr_exists from cis.cis_inst_agreements
             where inst_id = w_inst_id
               and supply_type = 'WATER'                    -- Add 3.0.0.1
               and nvl(w_ptbm.billing_date,sysdate) between nvl(agr_from_date,w_ptbm.billing_date-1) and nvl(agr_upto_date,to_date('12/31/9999','mm/dd/yyyy'));
            w_agr_exists := 'Y';    --Add 3706
            if w_inst_agr_exists = 0 then
               w_agr_exists := 'N';    --Add 3706
            end if;
         end if;  --End Add 3706
         --Mod End 3327b End Add 3327
   --debug(w_procedure_name,w_label,' Start w_ptbm.payment_due_date ' || datec(w_ptbm.payment_due_date));
   --w_ptbm.payment_due_date := next_valid_due_date(w_ptbm.payment_due_date);              --Del 2.0.0.23
   --debug(w_procedure_name,w_label,' End w_ptbm.payment_due_date ' || datec(w_ptbm.payment_due_date));
   --debug(w_procedure_name,w_label,' w_process_id    ' || w_process_id);
   --debug(w_procedure_name,w_label,' w_tran_id   ' || w_tran_id);
   --debug(w_procedure_name,w_label,' w_ptbm.mail_name  ' || w_ptbm.mail_name);
   --Start Add 2703 --"Care Of" line printing twice on the bill
   /* --Start Del 3706
   if  w_ptbm.mail_addr_line1 =  w_ptbm.mail_addr_line2 then
       w_ptbm.mail_addr_line2 := w_ptbm.mail_addr_line3;
       w_ptbm.mail_addr_line3 := w_ptbm.mail_addr_line4;
       w_ptbm.mail_addr_line4 := w_ptbm.mail_addr_line5;
       w_ptbm.mail_addr_line5 := null;
   end if;
   --End Del 3706 */
   --End Add 2703 --"Care Of" line printing twice on the bill
     if  w_ptbm.mail_addr_line1 is null and  w_ptbm.mail_addr_line2 is null then
         w_ptbm.mail_addr_line1 := w_ptbm.mail_addr_line3;
         w_ptbm.mail_addr_line2 := w_ptbm.mail_addr_line4;
         w_ptbm.mail_addr_line3 := w_ptbm.mail_addr_line5;
         w_ptbm.mail_addr_line4 := null;
         w_ptbm.mail_addr_line5 := null;
     elsif w_ptbm.mail_addr_line1 is null and  w_ptbm.mail_addr_line2 is not null then
         w_ptbm.mail_addr_line1 := w_ptbm.mail_addr_line2;
         w_ptbm.mail_addr_line2 := w_ptbm.mail_addr_line3;
         w_ptbm.mail_addr_line3 := w_ptbm.mail_addr_line4;
         w_ptbm.mail_addr_line4 := w_ptbm.mail_addr_line5;
         w_ptbm.mail_addr_line5 := null;
     elsif w_ptbm.mail_addr_line1 is not null and  w_ptbm.mail_addr_line2 is null then
         w_ptbm.mail_addr_line2 := w_ptbm.mail_addr_line3;
         w_ptbm.mail_addr_line3 := w_ptbm.mail_addr_line4;
         w_ptbm.mail_addr_line4 := w_ptbm.mail_addr_line5;
         w_ptbm.mail_addr_line5 := null;
     end if;
     if w_cust_id in (3, 4)   -- If NCO or RCB use mailing name as customer name       -- Add 1.0.0.33
     then                                                                              -- Add 1.0.0.33
       w_ptbm.cust_name := substr(w_ptbm.mail_name,1,30);                             -- Add 1.0.0.33 --2.0.0.06
     end if;                                                                           -- Add 1.0.0.33
     w_label := 'e214';
     if w_reading_grp_type = 'SOO' then                                                -- Add 1.0.0.4
        w_settl_ownr_bill := true;                                                     -- Add 1.0.0.4
     else                                                                              -- Add 1.0.0.4
        w_settl_ownr_bill := false;                                                    -- Add 1.0.0.4
     end if;                                                                           -- Add 1.0.0.4
     if w_reading_grp_type = 'FOO' then                                                -- Add 1.0.0.6
        w_final_ownr_bill := true;                                                     -- Add 1.0.0.6
     else                                                                              -- Add 1.0.0.6
        w_final_ownr_bill := false;                                                    -- Add 1.0.0.6
     end if;                                                                           -- Add 1.0.0.6
   -- Add 2.0.0.0
     w_label := 'e215';
     debug_trace(w_procedure_name,'...ppln_id     =' || to_char(w_ppln_id));
     debug_trace(w_procedure_name,'...ppln_type   =' || w_ppln_type);
     /* --Strat Del 4398 --Code has moved above Agency Receivables Routines..
     -- Format the bill account number
     phlu0018.b2_acct_to_city_acct (
                                    p_acct_id   => null
                                   ,p_acct_key  => w_ptbm.acct_key
                                   ,p_city_acct => w_city_acct
                                   ,p_result    => w_result
                                   ,p_message   => w_message
                                   );
     */ --End Del 4398
     --check_city_suffix;                                                       -- Del 6130 Add 1.0.0.17A
    /* Start Del 6130
     w_ptbm.bill_account_number := substr(w_city_acct, 1,3) || '-' -- Mod 1.0.0.2
                                || substr(w_city_acct, 4,5) || '-' -- Mod 1.0.0.2
                                || substr(w_city_acct, 9,5) || '-' -- Mod 1.0.0.2
                                || substr(w_city_acct,14,3)        -- Mod 1.0.0.2
                                ;                                  -- Mod 1.0.0.2
    End Del 6130 */
     w_ptbm.bill_account_number := substr(w_city_acct_4_WAT, 1,3) || '-' -- Add 6130
                                || substr(w_city_acct_4_WAT, 4,5) || '-' -- Add 6130
                                || substr(w_city_acct_4_WAT, 9,5) || '-' -- Add 6130
                                || substr(w_city_acct_4_WAT,14,3)        -- Add 6130
                                ;                                        -- Add 6130
     w_city_acct := w_city_acct_4_WAT;                                   -- Add 6130
     check_city_suffix;                                                  -- Add 6130
   --                                                                                                       -- Add 2.0.0.0
   -- get next reading date                                                                                 -- Add 2.0.0.0
                                                                                                        -- Add 2.0.0.0
     w_label := 'e216';
   get_next_reading_date(w_round_key);                                                                      -- Add 2.0.0.0
   --Start Chg 2.0.0.11
   ----
   ---- Get Debt Collections (debt_bal_amnt)
   ------for Brankruptcy, RDA, Vacant, Sheriff's Sale,TRB
   ----      Low Income (CRISIS,LIHEAP,UESF)
   ----
   select sum(decode(trim(substr(debt_coll_path,1,6)),'BNKRPT',debt_bal_amnt,0))   +
      sum(decode(trim(substr(debt_coll_path,1,8)),'OLD-BNKR',debt_bal_amnt,0))  --Add 1880
     ,sum(decode(trim(substr(debt_coll_path,1,3)),'RDA',debt_bal_amnt,0))
     ,sum(decode(trim(substr(debt_coll_path,1,6)),'VACANT',debt_bal_amnt,0))
     ,sum(decode(trim(substr(debt_coll_path,1,2)),'SH',debt_bal_amnt,0))
     ,sum(decode(trim(substr(debt_coll_path,1,4)),'CITY',debt_bal_amnt ,0))         --Chng 3706
     ,sum(decode(trim(substr(debt_coll_path,1,6)),'CRISIS',debt_bal_amnt ,0))       --Chng 3706
     ,sum(decode(trim(substr(debt_coll_path,1,6)),'LIHEAP',debt_bal_amnt ,0))       --Chng 3706
     ,sum(decode(trim(substr(debt_coll_path,1,4)),'UESF',debt_bal_amnt ,0))         --Chng 3706
     --,sum(decode(trim(substr(debt_coll_path,1,4)),'UESF',debt_tot_amnt ,0))       --Del 5247 --Chng 3706
     ,max(decode(trim(substr(debt_coll_path,1,4)),'UESF',debt_coll_id ,0))          --Add 5247 --Chng 3706
     ,sum(decode(trim(substr(debt_coll_path,1,3)),'TRB',debt_bal_amnt ,0))
     ,sum(decode(trim(substr(debt_coll_path,1,4)),'TANF',debt_bal_amnt ,0))         --Add 3706
     ,sum(decode(trim(substr(debt_coll_path,1,6)),'BNKRPT',decode(debt_coll_stage,'DISCHRGD',debt_bal_amnt,0),0))        --Add 6495
     ,sum(decode(trim(substr(debt_coll_path,1,6)),'TAPHLD',debt_bal_amnt,0))        --Add 6230A
     ,sum(decode(trim(substr(debt_coll_path,1,6)),'TAPPEN',debt_bal_amnt,0))        --Add 7055
   into
      w_ptbm.debt_bal_amnt_bnk
     ,w_ptbm.debt_bal_amnt_rda
     ,w_ptbm.debt_bal_amnt_vct
     ,w_ptbm.debt_bal_amnt_shs
     ,w_ptbm.debt_bal_amnt_cty
     ,w_ptbm.debt_bal_amnt_cri
     ,w_ptbm.debt_bal_amnt_lih
     ,w_ptbm.debt_bal_amnt_ues
     --,w_debt_tot_amnt_ues                  --Del 5247 --Add 3706  6107558076
     ,w_max_debt_coll_id_ues                 --Add 5247
     ,w_ptbm.debt_bal_amnt_trb
     ,w_ptbm.debt_bal_amnt_tnf               --Add 3706
     ,w_bnk_dischrd_bal_amnt                 --Add 6495
     ,w_taphld_bal_amnt                      --Chng 7055 from w_bnk_taphld_bal_amnt to w_taphld_bal_amnt Add 6230A
     ,w_tappen_bal_amnt                      --Add 7055
   from cis_debt_collection                  --Add 2.0.0.05
   where (
      trim(substr(debt_coll_path,1,6)) in (--'BNKRPT',    Mod 5905 3.0.0.39 ---Chng 3706 --Mod 2666 Chg to 6 was 8 --Chng removedBNKRPT
                   'RDA'
                  ,'VACANT'
                  ,'SH'
                  ,'CITY'
                  ,'CRISIS'
                  ,'LIHEAP'
                  ,'UESF'
                  ,'TANF'  --Add 3706
                  ,'TRB'
                  ,'TAPHLD' --Add 6230A
                  ,'TAPPEN' --Add 7055
                  )
      or
      (trim(substr(debt_coll_path,1,8)) = 'OLD-BNKR' and debt_coll_stage != 'CLOSED') --Add 1880
      or
      (trim(substr(debt_coll_path,1,6)) in ('BNKRPT') and debt_coll_stage in ('DISCHRGD', 'PETITION', 'PAYADVCE', 'REFILE', 'REINSTAT')) --Definition of Active Bankruptcy (also in TTID6495) mod 5905  3.0.0.39 --Add 3706 --,
     )
     and cust_id  = w_cust_id
     and inst_id  = w_inst_id
     and supply_type = 'WATER';              -- Add 3.0.0.1
     --and w_ptbm.billing_date between nvl(debt_period_from_date,sysdate) and nvl(debt_period_upto_date,sysdate);
   --Start Add 5247
   if w_max_debt_coll_id_ues is not null then
      select max(debt_tot_amnt) into w_debt_tot_amnt_ues
       from cis_debt_collection
       where debt_coll_id = w_max_debt_coll_id_ues;
   end if;
   --End Add 5247
   w_ptbm.debt_bal_not_incl :=
               nvl(w_ptbm.debt_bal_amnt_bnk,0)  +
--               nvl(w_ptbm.debt_bal_amnt_rda,0) +
--               nvl(w_ptbm.debt_bal_amnt_vct,0) +
--               nvl(w_ptbm.debt_bal_amnt_shs,0) +
--               nvl(w_ptbm.debt_bal_amnt_cty,0) +
--               nvl(w_ptbm.debt_bal_amnt_cri,0) +
--               nvl(w_ptbm.debt_bal_amnt_lih,0) +
--               nvl(w_ptbm.debt_bal_amnt_ues,0) +
               nvl(w_ptbm.debt_bal_amnt_trb,0)  ;
   w_ptbm.debt_bal_grants  := nvl(w_ptbm.debt_bal_amnt_cty,0) +
                              nvl(w_ptbm.debt_bal_amnt_cri,0) +
                              nvl(w_ptbm.debt_bal_amnt_lih,0) +
                              nvl(w_ptbm.debt_bal_amnt_ues,0) +
                              nvl(w_ptbm.debt_bal_amnt_tnf,0) ;
   debug_trace(w_procedure_name,' <w_ptbm.debt_bal_amnt_cty> ' || nvl(w_ptbm.debt_bal_amnt_cty,0));
   debug_trace(w_procedure_name,' <w_ptbm.debt_bal_amnt_ues> ' || nvl(w_ptbm.debt_bal_amnt_ues,0));
   debug_trace(w_procedure_name,' <w_ptbm.debt_bal_amnt_tnf> ' || nvl(w_ptbm.debt_bal_amnt_tnf,0));
   debug_trace(w_procedure_name,' <w_ptbm.previous_balance_amnt> ' || w_ptbm.previous_balance_amnt);   -- Add 2.0.0.0
   debug_trace(w_procedure_name,' <w_ptbm.previous_balance_amnt> ' || w_ptbm.previous_balance_amnt);   -- Add 2.0.0.0
   w_ptbm.previous_balance_amnt := w_ptbm.previous_balance_amnt   -
                                   w_ptbm.debt_bal_not_incl;
   --End Chg 2.0.0.11
       debug_trace(w_procedure_name,' Previous Balance after Debt_Bal_Amnt Deduction .....');              -- Add 2.0.0.0
       debug_trace(w_procedure_name,' <w_ptbm.previous_balance_amnt> ' || w_ptbm.previous_balance_amnt);   -- Add 2.0.0.0
       debug_trace(w_procedure_name,' <w_ptbm.debt_bal_amnt_bnk>     ' || w_ptbm.debt_bal_amnt_bnk    );   -- Add 2.0.0.0
       debug_trace(w_procedure_name,' <w_ptbm.debt_bal_amnt_rda>     ' || w_ptbm.debt_bal_amnt_rda    );   -- Add 2.0.0.0
     -- Store details of the bill lines for this bill
     get_bill_lines;
     -- Start Add 1129
     -- Format the bill cycle
     w_label := 'e217';
     if w_ptbm.reading_upto_date is not null
     then
        w_ptbm.bill_cycle_yymm := to_char(w_ptbm.reading_upto_date ,'YYMM');
     else
        w_ptbm.bill_cycle_yymm := to_char(w_ptbm.incl_payments_date,'YYMM');
     end if;
     -- End Add 1129
     debug_trace(w_procedure_name,' <w_ptbm.incl_payments_date> ' || datec(w_ptbm.incl_payments_date)); --Add 4562
     debug_trace(w_procedure_name,' <w_ptbm.reading_upto_date>  ' || datec(w_ptbm.reading_upto_date));  --Add 4562
     --                               --Add 2.0.0.0
     -- get_graph_xaxis --> w_ptbm.incl_payments_date               --Add 2.0.0.0
     --                               --Add 2.0.0.0
     w_label := 'e218';
     --/* Start Add 4562 */
     w_index              := w_vld_rts_bill_dts_tbl.first;
     w_tbl_cntr           := 1;
     w_vld_low_day_4_rt   := 0;
     w_vld_hgh_day_4_rt   := 0;
     w_rt_day             := 0;
     loop
        debug(w_procedure_name,w_label,' w_round_key                                 ' || w_round_key);
        debug(w_procedure_name,w_label,' w_vld_rts_bill_dts_tbl(w_index).rt#         ' || w_vld_rts_bill_dts_tbl(w_index).rt#);
        debug(w_procedure_name,w_label,' w_vld_rts_bill_dts_tbl(w_index).vld_low_day ' || w_vld_rts_bill_dts_tbl(w_index).vld_low_day);
        if regexp_instr(nvl(w_vld_rts_bill_dts_tbl(w_index).rt#,'xxx'),w_round_key) <> 0 then
           w_vld_low_day_4_rt := w_vld_rts_bill_dts_tbl(w_index).vld_low_day;
           w_vld_hgh_day_4_rt := w_vld_rts_bill_dts_tbl(w_index).vld_upr_day;
           w_rt_day           := w_index;
           exit;
        end if;
        exit when w_index = w_vld_rts_bill_dts_tbl.last;
        w_index := w_vld_rts_bill_dts_tbl.next(w_index);
        w_tbl_cntr := w_tbl_cntr + 1;
     end loop;
     debug(w_procedure_name,w_label,' w_vld_low_day_4_rt ' || w_vld_low_day_4_rt);
     debug(w_procedure_name,w_label,' w_vld_hgh_day_4_rt ' || w_vld_hgh_day_4_rt);
     debug(w_procedure_name,w_label,' Billed route day   ' || w_rt_day);
     --get_graph_xaxis(to_number(to_char(w_ptbm.incl_payments_date,'mm')));
     /* Start Logic as per Reading date
     if w_rt_day >= 1 and w_rt_day <= 10 then         ---First 10 Billing days
        if to_number(to_char(nvl(w_ptbm.reading_upto_date,w_ptbm.incl_payments_date),'DD')) <  w_vld_low_day_4_rt then
           get_graph_xaxis(to_number(to_char(add_months(nvl(w_ptbm.reading_upto_date,w_ptbm.incl_payments_date),-1),'mm')));
           w_current_month := get_prev_month(to_char(nvl(w_ptbm.reading_upto_date,w_ptbm.incl_payments_date),'YYYYMM'));
        else
           get_graph_xaxis(to_number(to_char(nvl(w_ptbm.reading_upto_date,w_ptbm.incl_payments_date),'mm')));
           w_current_month := to_char(nvl(w_ptbm.reading_upto_date,w_ptbm.incl_payments_date),'YYYYMM');
        end if;
     elsif w_rt_day >= 11 and w_rt_day <= 20 then     ---Last  10 Billing days
        if to_number(to_char(nvl(w_ptbm.reading_upto_date,w_ptbm.incl_payments_date),'DD')) <  w_vld_hgh_day_4_rt then
           get_graph_xaxis(to_number(to_char(add_months(nvl(w_ptbm.reading_upto_date,w_ptbm.incl_payments_date),-1),'mm')));
           w_current_month := get_prev_month(to_char(nvl(w_ptbm.reading_upto_date,w_ptbm.incl_payments_date),'YYYYMM'));
        else
           get_graph_xaxis(to_number(to_char(nvl(w_ptbm.reading_upto_date,w_ptbm.incl_payments_date),'mm')));
           w_current_month := to_char(nvl(w_ptbm.reading_upto_date,w_ptbm.incl_payments_date),'YYYYMM');
        end if;
     end if;
     End Logic as per Reading date */
     /* Start Logic as per Billing date */
     if w_rt_day >= 1 and w_rt_day <= 10 then         ---First 10 Billing days
        if to_number(to_char(nvl(w_ptbm.incl_payments_date,w_ptbm.reading_upto_date),'DD')) >  w_vld_hgh_day_4_rt then
           get_graph_xaxis(to_number(to_char(add_months(nvl(w_ptbm.incl_payments_date,w_ptbm.reading_upto_date),+1),'mm')));
           w_current_month := get_next_month(to_char(nvl(w_ptbm.incl_payments_date,w_ptbm.reading_upto_date),'YYYYMM'));
        else
           get_graph_xaxis(to_number(to_char(nvl(w_ptbm.incl_payments_date,w_ptbm.reading_upto_date),'mm')));
           w_current_month := to_char(nvl(w_ptbm.incl_payments_date,w_ptbm.reading_upto_date),'YYYYMM');
        end if;
     elsif w_rt_day >= 11 and w_rt_day <= 20 then     ---Last  10 Billing days
        if to_number(to_char(nvl(w_ptbm.incl_payments_date,w_ptbm.reading_upto_date),'DD')) <  w_vld_low_day_4_rt then
           get_graph_xaxis(to_number(to_char(add_months(nvl(w_ptbm.incl_payments_date,w_ptbm.reading_upto_date),-1),'mm')));
           w_current_month := get_prev_month(to_char(nvl(w_ptbm.incl_payments_date,w_ptbm.reading_upto_date),'YYYYMM'));
        else
           get_graph_xaxis(to_number(to_char(nvl(w_ptbm.incl_payments_date,w_ptbm.reading_upto_date),'mm')));
           w_current_month := to_char(nvl(w_ptbm.incl_payments_date,w_ptbm.reading_upto_date),'YYYYMM');
        end if;
     else
        get_graph_xaxis(to_number(to_char(nvl(w_ptbm.incl_payments_date,w_ptbm.reading_upto_date),'mm')));
        w_current_month := to_char(nvl(w_ptbm.incl_payments_date,w_ptbm.reading_upto_date),'YYYYMM');
     end if;
     /*End Logic as per Billing date */
     --/* End Add 4562 */
     -- Get upto 13 previous billed quantities and estimated reading indicator      -- Add 2.0.0.0
     w_label := 'e219';
     w_index := 0;
   --debug(w_procedure_name,w_label,' w_ptbm.incl_payments_date ' || datec(w_ptbm.incl_payments_date));
   w_grp_tbl.delete;
     w_label := 'e220';
   for i in 1 .. 13                                                        --Del 3706 Add 2437
   --for i in 1 .. 24                                                          --Add 2437
   loop                                  --Add 2437
    w_grp_tbl(w_current_month).month   := w_current_month;                    --Add 2437
    w_grp_tbl(w_current_month).qty     := 0;                                  --Add 2437
    w_grp_tbl(w_current_month).est_reading_ind   := null;                     --Add 2437
    w_grp_tbl(w_current_month).seq     := 14-i;                               --Chg 3706 was 14-i; --Add 2437
    if i = 13 then                                                            --Add 4562
      w_ptbm.billed_YY_01     := trim(substr(w_current_month,1,4));           --Add 4562
    end if;                                                                   --Add 4562
    w_current_month                    := get_prev_month(w_current_month);    --Add 2437
   end loop;                                                                  --Add 2437
   w_grp_cur_month         := w_current_month;                                --Add 2437
   --w_ptbm.billed_YY_01     := trim(substr(w_current_month,1,4));            --Del 4562  --Add 3706
   for rec in c_grp_cur
   loop
       begin
         w_rec_month := 0;
         --if w_rt_day >= 1 and w_rt_day <= 10 then         ---First 10 Billing days
         --   if to_number(to_char(rec.tran_date,'DD')) <  w_vld_low_day_4_rt then
         --     w_rec_month := get_prev_month(rec.month);
         --   else
         --     w_rec_month := rec.month;
         --   end if;
         --end if;
         if w_rt_day >= 1 and w_rt_day <= 10 then         ---First 10 Billing days
            if to_number(to_char(rec.tran_date,'DD')) >  w_vld_hgh_day_4_rt then
              w_rec_month := get_next_month(to_char(rec.tran_date,'YYYYMM'));
            else
              w_rec_month := to_char(rec.tran_date,'YYYYMM');
            end if;
         elsif w_rt_day >= 11 and w_rt_day <= 20 then     ---Last  10 Billing days
            if to_number(to_char(rec.tran_date,'DD')) <  w_vld_low_day_4_rt then
              w_rec_month := get_prev_month(to_char(rec.tran_date,'YYYYMM'));
            else
              w_rec_month := to_char(rec.tran_date,'YYYYMM');
            end if;
         else
           w_rec_month := to_char(rec.tran_date,'YYYYMM');
         end if;
         w_label :='e221';
         debug(w_procedure_name,w_label,' tran_date                  ' || datec(rec.tran_date));
         debug(w_procedure_name,w_label,' w_rec_month                ' || w_rec_month);
         debug(w_procedure_name,w_label,' nvl(rec.billed_qty,0)      ' || nvl(rec.billed_qty,0));
         debug(w_procedure_name,w_label,' Before w_grp_tbl(w_rec_month).qty ' || nvl(w_grp_tbl(w_rec_month).qty,0));
         debug(w_procedure_name,w_label,' w_grp_cur_month            ' || w_grp_cur_month);
         debug(w_procedure_name,w_label,' w_tran_id                  ' || w_tran_id);
         if w_grp_tbl(w_rec_month).month = w_rec_month then
            w_grp_tbl(w_rec_month).qty   := nvl(w_grp_tbl(w_rec_month).qty,0) + nvl(rec.billed_qty,0);
            if rec.est_reading_ind = 'A' then --Real read --Just to sort put as 'A"
               w_grp_tbl(w_rec_month).est_reading_ind   := rec.est_reading_ind;
            else
               if nvl(w_grp_tbl(w_rec_month).est_reading_ind,'Z') != 'A' then
                  w_grp_tbl(w_rec_month).est_reading_ind   := rec.est_reading_ind;
               end if;
            end if;
         end if;
         debug(w_procedure_name,w_label,' After w_grp_tbl(w_rec_month).qty ' || nvl(w_grp_tbl(w_rec_month).qty,0));
       exception
        when others then
         null;
       end;
   end loop;
   w_index   := w_grp_tbl.first;
   w_tbl_cntr  := 1;                                                                --Add 2437
   loop                                                                             --Add 2437
      w_label := 'e222';                                                            --Add 2437
      --if w_tbl_cntr > 13 then exit; end if;                                       --del 3706 --Add 2437
       if w_tbl_cntr > 14 then exit; end if;                                        --Was 25 for 24 months Graph --Add 3706
       --if  w_grp_tbl(w_index).seq =  13 then                                      --del 3706 --Add 2437
       -- if  w_grp_tbl(w_index).seq =  24 then                                     --del 3706 --Add 3706
       --   w_ptbm.billed_qty_24 := w_grp_tbl(w_index).qty;                         --del 3706 --Add 3706
       --   w_ptbm.bflg_24   := w_grp_tbl(w_index).est_reading_ind;                 --del 3706 --Add 3706
       -- elsif w_grp_tbl(w_index).seq =  23 then                                   --del 3706 --Add 3706
       --   w_ptbm.billed_qty_23 := w_grp_tbl(w_index).qty;                         --del 3706 --Add 3706
       --   w_ptbm.bflg_23   := w_grp_tbl(w_index).est_reading_ind;                 --del 3706 --Add 3706
       -- elsif w_grp_tbl(w_index).seq =  22 then                                   --del 3706 --Add 3706
       --   w_ptbm.billed_qty_22 := w_grp_tbl(w_index).qty;                         --del 3706 --Add 3706
       --   w_ptbm.bflg_22   := w_grp_tbl(w_index).est_reading_ind;                 --del 3706 --Add 3706
       -- elsif w_grp_tbl(w_index).seq =  21 then                                   --del 3706 --Add 3706
       --   w_ptbm.billed_qty_21 := w_grp_tbl(w_index).qty;                         --del 3706 --Add 3706
       --   w_ptbm.bflg_21   := w_grp_tbl(w_index).est_reading_ind;                 --del 3706 --Add 3706
       -- elsif w_grp_tbl(w_index).seq =  20 then                                   --del 3706 --Add 3706
       --   w_ptbm.billed_qty_20 := w_grp_tbl(w_index).qty;                         --del 3706 --Add 3706
       --   w_ptbm.bflg_20   := w_grp_tbl(w_index).est_reading_ind;                 --del 3706 --Add 3706
       -- elsif w_grp_tbl(w_index).seq =  19 then                                   --del 3706 --Add 3706
       --   w_ptbm.billed_qty_19 := w_grp_tbl(w_index).qty;                         --del 3706 --Add 3706
       --   w_ptbm.bflg_19   := w_grp_tbl(w_index).est_reading_ind;                 --del 3706 --Add 3706
       -- elsif w_grp_tbl(w_index).seq =  18 then                                   --del 3706 --Add 3706
       --   w_ptbm.billed_qty_18 := w_grp_tbl(w_index).qty;                         --del 3706 --Add 3706
       --   w_ptbm.bflg_18   := w_grp_tbl(w_index).est_reading_ind;                 --del 3706 --Add 3706
       -- elsif w_grp_tbl(w_index).seq =  17 then                                   --del 3706 --Add 3706
       --   w_ptbm.billed_qty_17 := w_grp_tbl(w_index).qty;                         --del 3706 --Add 3706
       --   w_ptbm.bflg_17   := w_grp_tbl(w_index).est_reading_ind;                 --del 3706 --Add 3706
       -- elsif w_grp_tbl(w_index).seq =  16 then                                   --del 3706 --Add 3706
       --   w_ptbm.billed_qty_16 := w_grp_tbl(w_index).qty;                         --del 3706 --Add 3706
       --   w_ptbm.bflg_16   := w_grp_tbl(w_index).est_reading_ind;                 --del 3706 --Add 3706
       -- elsif w_grp_tbl(w_index).seq =  15 then                                   --del 3706 --Add 3706
       --   w_ptbm.billed_qty_15 := w_grp_tbl(w_index).qty;                         --del 3706 --Add 3706
       --   w_ptbm.bflg_15   := w_grp_tbl(w_index).est_reading_ind;                 --del 3706 --Add 3706
       -- elsif w_grp_tbl(w_index).seq =  14 then                                   --del 3706 --Add 3706
       --   w_ptbm.billed_qty_14 := w_grp_tbl(w_index).qty;                         --del 3706 --Add 3706
       --   w_ptbm.bflg_14   := w_grp_tbl(w_index).est_reading_ind;                 --del 3706 --Add 3706
       if w_grp_tbl(w_index).seq =  13 then                                      --Add 3706
         w_ptbm.billed_qty_13 := w_grp_tbl(w_index).qty;                         --Add 2437
         select decode(w_grp_tbl(w_index).est_reading_ind,'A',null,w_grp_tbl(w_index).est_reading_ind) into w_ptbm.bflg_13 from dual;
         --w_ptbm.bflg_13       := w_grp_tbl(w_index).est_reading_ind;             --Add 2437
       elsif w_grp_tbl(w_index).seq =  12 then                                   --Add 2437
         w_ptbm.billed_qty_12 := w_grp_tbl(w_index).qty;                         --Add 2437
         select decode(w_grp_tbl(w_index).est_reading_ind,'A',null,w_grp_tbl(w_index).est_reading_ind) into w_ptbm.bflg_12 from dual;
         --w_ptbm.bflg_12   := w_grp_tbl(w_index).est_reading_ind;                 --Add 2437
       elsif w_grp_tbl(w_index).seq =  11 then                                   --Add 2437
         w_ptbm.billed_qty_11 := w_grp_tbl(w_index).qty;                         --Add 2437
         select decode(w_grp_tbl(w_index).est_reading_ind,'A',null,w_grp_tbl(w_index).est_reading_ind) into w_ptbm.bflg_11 from dual;
         --w_ptbm.bflg_11   := w_grp_tbl(w_index).est_reading_ind;                 --Add 2437
       elsif w_grp_tbl(w_index).seq =  10 then                                   --Add 2437
         w_ptbm.billed_qty_10 := w_grp_tbl(w_index).qty;                         --Add 2437
         select decode(w_grp_tbl(w_index).est_reading_ind,'A',null,w_grp_tbl(w_index).est_reading_ind) into w_ptbm.bflg_10 from dual;
         --w_ptbm.bflg_10   := w_grp_tbl(w_index).est_reading_ind;                 --Add 2437
       elsif w_grp_tbl(w_index).seq =   9 then                                   --Add 2437
         w_ptbm.billed_qty_09 := w_grp_tbl(w_index).qty;                         --Add 2437
         select decode(w_grp_tbl(w_index).est_reading_ind,'A',null,w_grp_tbl(w_index).est_reading_ind) into w_ptbm.bflg_09 from dual;
         --w_ptbm.bflg_09   := w_grp_tbl(w_index).est_reading_ind;                 --Add 2437
       elsif w_grp_tbl(w_index).seq =   8 then                                   --Add 2437
         w_ptbm.billed_qty_08 := w_grp_tbl(w_index).qty;                         --Add 2437
         select decode(w_grp_tbl(w_index).est_reading_ind,'A',null,w_grp_tbl(w_index).est_reading_ind) into w_ptbm.bflg_08 from dual;
         --w_ptbm.bflg_08   := w_grp_tbl(w_index).est_reading_ind;                 --Add 2437
       elsif w_grp_tbl(w_index).seq =   7 then                                   --Add 2437
         w_ptbm.billed_qty_07 := w_grp_tbl(w_index).qty;                         --Add 2437
         select decode(w_grp_tbl(w_index).est_reading_ind,'A',null,w_grp_tbl(w_index).est_reading_ind) into w_ptbm.bflg_07 from dual;
         --w_ptbm.bflg_07   := w_grp_tbl(w_index).est_reading_ind;                 --Add 2437
       elsif w_grp_tbl(w_index).seq =   6 then                                   --Add 2437
         w_ptbm.billed_qty_06 := w_grp_tbl(w_index).qty;                         --Add 2437
         select decode(w_grp_tbl(w_index).est_reading_ind,'A',null,w_grp_tbl(w_index).est_reading_ind) into w_ptbm.bflg_06 from dual;
         --w_ptbm.bflg_06   := w_grp_tbl(w_index).est_reading_ind;                 --Add 2437
       elsif w_grp_tbl(w_index).seq =   5 then                                   --Add 2437
         w_ptbm.billed_qty_05 := w_grp_tbl(w_index).qty;                         --Add 2437
         select decode(w_grp_tbl(w_index).est_reading_ind,'A',null,w_grp_tbl(w_index).est_reading_ind) into w_ptbm.bflg_05 from dual;
         --w_ptbm.bflg_05   := w_grp_tbl(w_index).est_reading_ind;                 --Add 2437
       elsif w_grp_tbl(w_index).seq =   4 then                                   --Add 2437
         w_ptbm.billed_qty_04 := w_grp_tbl(w_index).qty;                         --Add 2437
         select decode(w_grp_tbl(w_index).est_reading_ind,'A',null,w_grp_tbl(w_index).est_reading_ind) into w_ptbm.bflg_04 from dual;
         --w_ptbm.bflg_04   := w_grp_tbl(w_index).est_reading_ind;                 --Add 2437
       elsif w_grp_tbl(w_index).seq =   3 then                                   --Add 2437
         w_ptbm.billed_qty_03 := w_grp_tbl(w_index).qty;                         --Add 2437
         select decode(w_grp_tbl(w_index).est_reading_ind,'A',null,w_grp_tbl(w_index).est_reading_ind) into w_ptbm.bflg_03 from dual;
         --w_ptbm.bflg_03   := w_grp_tbl(w_index).est_reading_ind;                 --Add 2437
       elsif w_grp_tbl(w_index).seq =   2 then                                   --Add 2437
         w_ptbm.billed_qty_02 := w_grp_tbl(w_index).qty;                         --Add 2437
         select decode(w_grp_tbl(w_index).est_reading_ind,'A',null,w_grp_tbl(w_index).est_reading_ind) into w_ptbm.bflg_02 from dual;
         --w_ptbm.bflg_02   := w_grp_tbl(w_index).est_reading_ind;                 --Add 2437
       elsif w_grp_tbl(w_index).seq =   1 then                                   --Add 2437
         w_ptbm.billed_qty_01 := w_grp_tbl(w_index).qty;                         --Add 2437
         select decode(w_grp_tbl(w_index).est_reading_ind,'A',null,w_grp_tbl(w_index).est_reading_ind) into w_ptbm.bflg_01 from dual;
         --w_ptbm.bflg_01   := w_grp_tbl(w_index).est_reading_ind;                 --Add 2437
       end if;                                                                   --Add 2437
    exit when w_index = w_grp_tbl.last;                                          --Add 2437
    w_index := w_grp_tbl.next(w_index);                                          --Add 2437
    w_tbl_cntr := w_tbl_cntr + 1;                                                --Add 2437
   end loop;                                                                     --Add 2437
   --
   -- Discount Amount needs to added with (Difference between Chargeable Extras Original Amnt and Chargeable Extra)
   -- Chargeable Extras are stored discounted for selcode PHA and STANDARD
   -- So while adding to to discount (Actual you supstract because discount is in -ve)
   --
   if nvl(w_ptbm.chxext_wo_disc,0) - nvl(w_ptbm.chxext,0) > 0 then                  --Add 2634
      w_label := 'e223';
      debug_trace(w_procedure_name, '..w_ptbm.discount_amnt       =' || w_ptbm.discount_amnt );
      w_ptbm.discount_amnt  := nvl(w_ptbm.discount_amnt,0) -                        --Add 2634
                              (nvl(w_ptbm.chxext_wo_disc,0) - nvl(w_ptbm.chxext,0));--Add 2634
      debug_trace(w_procedure_name, '..w_ptbm.chxext_wo_disc       =' || w_ptbm.chxext_wo_disc );
      debug_trace(w_procedure_name, '..w_ptbm.chxext       =' || w_ptbm.chxext );
   else                            --Add 2660
      w_ptbm.chxext_wo_disc := nvl(w_ptbm.chxext,0);             --Add 2660
   end if;                            --Add 2634
   --
   -- Previous Balances
   --
   -- w_ptbm.previous_balance_amnt initialized at the select.
   --
   -- Total Payments Adjustments
   --
   w_ptbm.tot_pays_adjs  := nvl(w_ptbm.last_paid_amnt,0)        +   -- Payments always negative        --(Water and Repair Charge) --Add 6351 (Only Comment)
                                    nvl(w_ptbm.adjust,0)        +   -- Adjustments                     --(Water and Repair Charge) --Add 6351 (Only Comment)
                              nvl(w_ptbm.late_pmt_penalty,0)    +   -- Late Payment Penalties
                              nvl(w_ptbm.lien,0);                   -- Lien
   --
   -- Sub Total Prev Balance
   --
   w_ptbm.sub_tot_prev_bal := nvl(w_ptbm.previous_balance_amnt,0)     +  -- sub total previous balance
                                    w_ptbm.tot_pays_adjs     ;         -- Total Payments Adjustments
   --
   -- Total Service Charges
   --
   w_ptbm.service_charge_amnt := nvl(w_ptbm.service_charge_amnt,0) + --Add 2249 Add Chrgeable Extras to Sevice charge Amnt
             nvl(w_ptbm.chxext_wo_disc,0);   --Add 2634 Added Chrgeable Extras from Sevice charge Amnt and Add it to Total Sevice charge Amnt
   w_ptbm.tot_srvc_chgs  := nvl(w_ptbm.fire_srvc_chg_amnt,0)  +  --Add 2634 Fire Service Charge
                            nvl(w_ptbm.service_charge_amnt,0) ;  --Add 2634 Sewer and Water Service Charge
            --nvl(w_ptbm.chxext_wo_disc,0);   --Del 2634 add Chrgeable Extras to Total Sevice charge Amnt
            --nvl(w_ptbm.stormchg,0);     --Del 2.0.0.34
   --
   -- Total Usage Charges
   --
   w_ptbm.tot_usgs_chgs  := nvl(w_ptbm.usage_charge_amnt,0)  +   --Water,  Sewer and Ground Water usage charge
                            nvl(w_ptbm.induschg,0)           ;  --Industrial Surcharge
   --
   -- Sub Total Current Charges
   --
   w_ptbm.subtot_curr_chgs := nvl(w_ptbm.tot_srvc_chgs,0)    +    --Total Service Charge
                              nvl(w_ptbm.tot_usgs_chgs,0)    +    --Total Usage Charge
                              nvl(w_ptbm.stormchg,0)         +    --Storm Water usage Charge --Add 2.0.0.34
                              nvl(w_ptbm.discount_amnt,0)    +    --Add 4608 removed from tot_curr_chgs see below
                              nvl(w_ptbm.tap_disc,0)         ;    --Add 6230 3.0.0.41 TAP Discount
                              --nvl(w_agr_curr_chgs,0);             --Add 4398
   --Start add 6230 3.0.0.41 (We may not need it)
   --
   -- TAP total charges
   --
   /* --Start del 7164D
   --if w_ptbm.tap_disc is not null then
      --w_ptbm.tap_chg          := w_ptbm.subtot_curr_chgs;
   --end if;
   --End add 6230  (We may not need it)
   */
   --
   -- Total Current Charges
   --
   w_ptbm.tot_curr_chgs  := nvl(w_ptbm.subtot_curr_chgs,0)  + -- Sub Total Current Charges
                            nvl(w_ptbm.sub_tot_prev_bal,0)  + -- Sub Total Prev Balance [Payments + adjust + Penalty + Lien]
                            --nvl(w_ptbm.discount_amnt,0)     + -- Discount  --Del 4608 added in subtot_curr_chgs see above
                            nvl(w_ptbm.sewer_credit,0)      + -- Sewer Credit
                            nvl(w_ptbm.bank_return_item,0)  + -- Bank Return Item
                            nvl(w_ptbm.meter_test_charge,0) + -- Meter Test Charge
                            nvl(w_ptbm.wrbcccred,0);
   --
   -- Total Credits
   --
   w_ptbm.tot_cred   := nvl(w_ptbm.sewer_credit,0)       + -- Sewer Credit     --Add 2402
                        --nvl(w_ptbm.discount_amnt,0)      + -- Discount       --Add 2402   --Del discount is taken twice
                        nvl(w_ptbm.wrbcccred,0);              --Add 2402
   --
   -- Penalty Date Moved up so that it can be used to get the Payment Plan Installments after
   -- Bill Due Date
   --
   /* It hsa moved further up, os that HelpLoan and Agency Receivables can use it*/--Add 4398
   --w_ptbm.penalty_date     := next_valid_due_date(w_ptbm.billing_date + 30);     --Del 4398--Mod 2212
     w_label := 'e224';
   w_ptbm.wrbccpmt := null;
   w_ptbm.pymtagree := null;
   if w_ppln_id is not null then
        w_label := 'e225';                                --Add 2.0.0.0
        debug_trace(w_procedure_name,'...tran_id     =' || to_char(w_tran_id));        --Add 2.0.0.0
    --Start Add 3706 --Include 7 latest Payments, Downpayment, Agreement Date, Total Agreement Amnt, Remaining Balance Amnt,
         select start_date
           --,decode(ppln_type,'I',ipln_plan_amnt,bdbt_plan_amnt) --DEL 3706
           ,decode(ppln_type,'I',ipln_plan_amnt,bdbt_back_debt_amnt) --Mod 3706
         into w_ptbm.agr_dt
           ,w_ptbm.agr_amnt
         from cis.cis_payment_plans
         where ppln_id = w_ppln_id;
         w_ppln_start_date := w_ptbm.agr_dt;
    --End Add 3706
    --Start Del 3706
    --get_inst_amnt
    -- select sum(nvl(paym_amnt,0)) into w_installment_amnt            --Add 2212
    -- from  cis_ppln_payments                    --Add 2212
    --         where ppln_id = w_ppln_id                                               --Add 2212
    --   and paym_num = 2;
    --
    -- for r1 in (                                                                    --Add 2.0.0.0
    --     select  paym_due_date , paym_amnt   , paym_bal_amnt          --Add 2.0.0.0
    --     from  cis_ppln_payments
    --                     where ppln_id = w_ppln_id                                           --Add 2.0.0.0
    --       and paym_due_date <= w_ptbm.penalty_date         --Mod 2212   w_ptbm.payment_due_date                       --Add 2.0.0.16 (Again) --Add 1.0.0.31
    --     --and paym_due_date <= w_ptbm.billing_date         --Del 1.0.0.31
    --       and paym_bal_amnt > 0                            --Add 2.0.0.0
    --     order by paym_due_date desc                                         --Add 2.0.0.0
    --      )                                                                   --Add 2.0.0.0
    -- loop
    --  -- WRBCC only first agreement monthly payment amount       --Del 2361
    --  --if w_ptbm.wrbccpmt is null then              --Del 2361
    --  -- w_ptbm.wrbccpmt := nvl(w_ptbm.wrbccpmt,0) + nvl(r1.paym_amnt,0);  --Del 2361
    --   -- WRBCC Plan Exit at first record.            --Del 2361
    --     --if w_ppln_type = 'I' then               --Del 2361
    --    --exit;                    --Del 2361
    --    --null;                    --Del 2361
    --   --end if;                    --Del 2361
    --  --end if;                     --Del 2361
    --
    --  w_ptbm.wrbccpmt  := nvl(w_ptbm.wrbccpmt,0)  + nvl(r1.paym_bal_amnt,0);  --Add 2361
    --  w_ptbm.pymtagree := nvl(w_ptbm.pymtagree,0) + nvl(r1.paym_bal_amnt,0);         -- Add 3093
    --                                                                                           -- Re-added There is no marker to indicate why the next line was deleted.
    --  --w_ptbm.pymtagree := nvl(w_ptbm.pymtagree,0) + nvl(r1.paym_bal_amnt,0);
    --  w_ppln_due_amnt  := nvl(w_ppln_due_amnt,0)  + nvl(r1.paym_bal_amnt,0);
    --  w_ppln_no_due   := nvl(w_ppln_no_due,0)    + 1;
    --
    --  debug(w_procedure_name,w_label,' In the Loop [1] w_ptbm.pymtagree ' || w_ptbm.pymtagree);
    --  debug(w_procedure_name,w_label,' In the Loop [2] w_ptbm.wrbccpmt  ' || w_ptbm.wrbccpmt );
    --
    -- end loop;
    --End Del 3706
    --Start Add 3706
    w_agr_pymnts_cnt := 0;
    for r1 in (
                  select  paym_due_date
                        , paym_amnt
                        , paym_bal_amnt
                        , paym_num
                        , paym_paid_date
                    from  cis_ppln_payments
               where ppln_id = w_ppln_id
                 --and paym_due_date <= w_ptbm.penalty_date --Del 3706
                 --and paym_bal_amnt > 0                    --Del 3706
                order by paym_due_date desc
              )
    loop
      if r1.paym_num = 2 then
         w_installment_amnt := nvl(r1.paym_amnt,0);
      end if;
      if r1.paym_num = 1 then
         w_ptbm.agr_downpym_amnt := nvl(r1.paym_amnt,0) - nvl(r1.paym_bal_amnt,0) ;
         w_ptbm.agr_downpym_dt   := r1.paym_paid_date;
      end if;
      if r1.paym_paid_date is not null and r1.paym_num != 1 then
         --if   (w_ptbm.agr_7thpym_dt is null and r1.paym_paid_date is not null)
         --  or (w_ptbm.agr_7thpym_dt is not null and w_ptbm.agr_7thpym_dt = r1.paym_paid_date)
         --then
         --   w_ptbm.agr_7thpym_dt := r1.paym_paid_date;
         --   w_ptbm.agr_7thpym_amnt := nvl(w_ptbm.agr_7thpym_amnt,0) + nvl(r1.paym_amnt,0) - nvl(r1.paym_bal_amnt,0);
         if (w_ptbm.agr_6thpym_dt is null and r1.paym_paid_date is not null)
           or (w_ptbm.agr_6thpym_dt is not null and w_ptbm.agr_6thpym_dt = r1.paym_paid_date)
         then
            if w_ptbm.agr_6thpym_dt is null then
               w_agr_pymnts_cnt := nvl(w_agr_pymnts_cnt,0) + 1;  --Count total number of payments on this Payment Agreement.
            end if;
            w_ptbm.agr_6thpym_dt := r1.paym_paid_date;
            w_ptbm.agr_6thpym_amnt := nvl(w_ptbm.agr_6thpym_amnt,0) + nvl(r1.paym_amnt,0) - nvl(r1.paym_bal_amnt,0);
            debug(w_procedure_name,w_label,' In the Loop [***6th***] w_agr_pymnts_cnt ' || w_agr_pymnts_cnt);
         elsif (w_ptbm.agr_5thpym_dt is null and r1.paym_paid_date is not null)
           or (w_ptbm.agr_5thpym_dt is not null and w_ptbm.agr_5thpym_dt = r1.paym_paid_date)
         then
            if w_ptbm.agr_5thpym_dt is null then
               w_agr_pymnts_cnt := nvl(w_agr_pymnts_cnt,0) + 1;  --Count total number of payments on this Payment Agreement.
            end if;
            w_ptbm.agr_5thpym_dt := r1.paym_paid_date;
            w_ptbm.agr_5thpym_amnt := nvl(w_ptbm.agr_5thpym_amnt,0) + nvl(r1.paym_amnt,0) - nvl(r1.paym_bal_amnt,0);
            debug(w_procedure_name,w_label,' In the Loop [***5th***] w_agr_pymnts_cnt ' || w_agr_pymnts_cnt);
         elsif (w_ptbm.agr_4thpym_dt is null and r1.paym_paid_date is not null)
           or (w_ptbm.agr_4thpym_dt is not null and w_ptbm.agr_4thpym_dt = r1.paym_paid_date)
         then
            if w_ptbm.agr_4thpym_dt is null then
               w_agr_pymnts_cnt := nvl(w_agr_pymnts_cnt,0) + 1;  --Count total number of payments on this Payment Agreement.
            end if;
            w_ptbm.agr_4thpym_dt := r1.paym_paid_date;
            w_ptbm.agr_4thpym_amnt := nvl(w_ptbm.agr_4thpym_amnt,0) + nvl(r1.paym_amnt,0) - nvl(r1.paym_bal_amnt,0);
            debug(w_procedure_name,w_label,' In the Loop [***4th***] w_agr_pymnts_cnt ' || w_agr_pymnts_cnt);
         elsif (w_ptbm.agr_3rdpym_dt is null and r1.paym_paid_date is not null)
           or (w_ptbm.agr_3rdpym_dt is not null and w_ptbm.agr_3rdpym_dt = r1.paym_paid_date)
         then
            if w_ptbm.agr_3rdpym_dt is null then
               w_agr_pymnts_cnt := nvl(w_agr_pymnts_cnt,0) + 1;  --Count total number of payments on this Payment Agreement.
            end if;
            w_ptbm.agr_3rdpym_dt := r1.paym_paid_date;
            w_ptbm.agr_3rdpym_amnt := nvl(w_ptbm.agr_3rdpym_amnt,0) + nvl(r1.paym_amnt,0) - nvl(r1.paym_bal_amnt,0);
            debug(w_procedure_name,w_label,' In the Loop [***3rd***] w_agr_pymnts_cnt ' || w_agr_pymnts_cnt);
         elsif (w_ptbm.agr_2ndpym_dt is null and r1.paym_paid_date is not null)
           or (w_ptbm.agr_2ndpym_dt is not null and w_ptbm.agr_2ndpym_dt = r1.paym_paid_date)
         then
            if w_ptbm.agr_2ndpym_dt is null then
               w_agr_pymnts_cnt := nvl(w_agr_pymnts_cnt,0) + 1;  --Count total number of payments on this Payment Agreement.
            end if;
            w_ptbm.agr_2ndpym_dt := r1.paym_paid_date;
            w_ptbm.agr_2ndpym_amnt := nvl(w_ptbm.agr_2ndpym_amnt,0) + nvl(r1.paym_amnt,0) - nvl(r1.paym_bal_amnt,0);
            debug(w_procedure_name,w_label,' In the Loop [***2nd***] w_agr_pymnts_cnt ' || w_agr_pymnts_cnt);
         elsif (w_ptbm.agr_1stpym_dt is null and r1.paym_paid_date is not null)
           or (w_ptbm.agr_1stpym_dt is not null and w_ptbm.agr_1stpym_dt = r1.paym_paid_date)
         then
            if w_ptbm.agr_1stpym_dt is null then
               w_agr_pymnts_cnt := nvl(w_agr_pymnts_cnt,0) + 1;  --Count total number of payments on this Payment Agreement.
            end if;
            w_ptbm.agr_1stpym_dt := r1.paym_paid_date;
            w_ptbm.agr_1stpym_amnt := nvl(w_ptbm.agr_1stpym_amnt,0) + nvl(r1.paym_amnt,0) - nvl(r1.paym_bal_amnt,0);
            debug(w_procedure_name,w_label,' In the Loop [***1st***] w_agr_pymnts_cnt ' || w_agr_pymnts_cnt);
         else
            w_ptbm.agr_othr_pymnts_amnt := nvl(w_ptbm.agr_othr_pymnts_amnt,0) + nvl(r1.paym_amnt,0) - nvl(r1.paym_bal_amnt,0);
            w_agr_pymnts_cnt := nvl(w_agr_pymnts_cnt,0) + 1;  --Count total number of payments on this Payment Agreement.
            debug(w_procedure_name,w_label,' In the Loop [***Other***] w_agr_pymnts_cnt ' || w_agr_pymnts_cnt);
         end if;
      else
         if r1.paym_num != 1 then
            w_ptbm.agr_othr_pymnts_amnt := nvl(w_ptbm.agr_othr_pymnts_amnt,0) + nvl(r1.paym_amnt,0) - nvl(r1.paym_bal_amnt,0);
            --w_agr_pymnts_cnt := nvl(w_agr_pymnts_cnt,0) + 1;  --Already included in the above payment dates --Count total number of payments on this Payment Agreement.
            debug(w_procedure_name,w_label,' In the Loop [***Other***] w_agr_pymnts_cnt ' || w_agr_pymnts_cnt);
         end if;
      end if;
      if r1.paym_due_date <= w_ptbm.penalty_date and r1.paym_bal_amnt > 0
      then
         w_ptbm.wrbccpmt  := nvl(w_ptbm.wrbccpmt,0)  + nvl(r1.paym_bal_amnt,0);
         w_ptbm.pymtagree := nvl(w_ptbm.pymtagree,0) + nvl(r1.paym_bal_amnt,0);
         w_ppln_due_amnt  := nvl(w_ppln_due_amnt,0)  + nvl(r1.paym_bal_amnt,0);
         if r1.paym_bal_amnt > 0 then  --Add 3706
            w_ppln_no_due   := nvl(w_ppln_no_due,0)     + 1;
         end if;                       --Add 3706
      end if;
      debug(w_procedure_name,w_label,' In the Loop [1] w_ptbm.pymtagree ' || w_ptbm.pymtagree);
      debug(w_procedure_name,w_label,' In the Loop [2] w_ptbm.wrbccpmt  ' || w_ptbm.wrbccpmt );
      --End Add 3706
    end loop;
    w_ptbm.grp_mssg_agr01  := null;
    debug(w_procedure_name,w_label,' Before Mssg of Agreement -- w_agr_pymnts_cnt ' || w_agr_pymnts_cnt);
    if w_agr_pymnts_cnt > 6 then --More than 6
       w_ptbm.grp_mssg_agr01  := substr('These are the 6 most recent payments for this agreement',1,100);
    end if;
    --End Add 3706
    -- Start added to get new agreement balance for WRBCC
    if w_ppln_type = 'I' then   --Add 3706 again, only for WRBCC
      w_ptbm.agr_bal_amnt  :=  nvl(w_ptbm.agr_amnt,0) -
                        (nvl(w_ptbm.agr_othr_pymnts_amnt,0) +
                         nvl(w_ptbm.agr_1stpym_amnt,0) +
                         nvl(w_ptbm.agr_2ndpym_amnt,0) +
                         nvl(w_ptbm.agr_3rdpym_amnt,0) +
                         nvl(w_ptbm.agr_4thpym_amnt,0) +
                         nvl(w_ptbm.agr_5thpym_amnt,0) +
                         nvl(w_ptbm.agr_6thpym_amnt,0) +
                         nvl(w_ptbm.agr_downpym_amnt,0)
                        );
    end if;
    --
    -- If there no installments available and If there exists next installment show the installment amnt
    -- If partial+next installment > installmentr amnt
    --
    if w_ppln_type = 'I' and nvl(w_ptbm.wrbccpmt,0) < w_installment_amnt then      --Add 2212
        for r1 in (                                                                       --Add 2212
            select  paym_due_date                                 --Add 2212
              , paym_amnt                                         --Add 2212
              , paym_bal_amnt                                     --Add 2212
              , paym_num                                          --Add 2212
            from cis_ppln_payments                                --Add 2212
           where ppln_id = w_ppln_id                              --Add 2212
              and paym_due_date > w_ptbm.penalty_date             --Add 2212
              and paym_bal_amnt > 0                               --Add 2212
            order by paym_due_date                                             --Add 2212
            )                                                                       --Add 2212
        loop                                                                              --Add 2212
                     -- PJT Comment 3093
                     -- I do not believe that this wrbccpmt is null test should be here
                     -- If the customer short pays on a payment that is outstanding then we will only ask for the
                     -- balance instead of asking for a full installment payment.
                     -- if w_ptbm.wrbccpmt is null then                                                --Add 2212  -- Del 3093
          w_ptbm.wrbccpmt := nvl(w_ptbm.wrbccpmt,0) + nvl(r1.paym_amnt,0);     --Add 2212
          if w_ptbm.wrbccpmt >= w_installment_amnt then            --Add 2212
           w_ptbm.wrbccpmt := w_installment_amnt;             --Add 2212
           w_ppln_due_amnt := w_installment_amnt;              -- Add 3093
           w_ppln_no_due   := 1;                               -- Add 3098
           exit;                        --Add 2212
          end if;                        --Add 2212
                     -- end if;                                                                        --Add 2212  -- Del 3093
        end loop;                         --Add 2212
    --elsif w_ppln_type != 'I' and  nvl(w_ptbm.pymtagree,0) < w_installment_amnt then  --Del 3367   --Add 2212
    elsif w_ppln_type != 'I' then                                                      --Mod 3367
      --Start Del 3706
      --Code moved up look for w_ppln_start_date
      /*      --Start Add 3367
      w_label := 'e226';
      w_ppln_start_date := null;
      select min(start_date) into w_ppln_start_date
        from cis.cis_payment_plans
       where ppln_id = w_ppln_id;
      */
      --End Del 3706
      debug_trace(w_procedure_name,'...[1] w_ppln_start_date   =' || datec(w_ppln_start_date));   --Add 3367
      debug_trace(w_procedure_name,'...[1] w_ptbm.billing_date =' || datec(w_ptbm.billing_date)); --Add 3367
      debug_trace(w_procedure_name,'...[2] w_cust_id           =' || w_cust_id);                  --Add 3367
      debug_trace(w_procedure_name,'...[3] w_inst_id           =' || w_inst_id);                  --Add 3367
      debug_trace(w_procedure_name,'...[3] w_tran_id           =' || w_tran_id);                  --Add 6929
      -- To get the previous unpaid balance, after accout went to payment plan
      -- Logic:: Find all the bills after the account went to payment plan and
      -- Include all the outstanding transactions linked to these bills, by bill id
      w_prv_bl_nt_inc_ppln       := 0;
      --w_prv_bl_nt_inc_ppln_oth   := 0;
      --Add 7055B
      --If TAP we dont want previous balance not covered by plan into agreement amount.
      debug_trace(w_procedure_name,'...[x.5]w_pay_profile_code_orig         =' || w_pay_profile_code_orig);       --Add 7750B
      if nvl(w_pay_profile_code_orig,'X') != 'TAP-STD' then --Start Add 7055B
         for r1_prv_bln in (select bill_id,bill_key from cis.cis_transactions
                            where cust_id = w_cust_id
                              and inst_id = w_inst_id
                              and supply_type = 'WATER'                                   -- Add 3.0.0.1
                              and tran_id >= (select min(low_id) from cis_low_id
                                               where table_name  = 'CIS_TRANSACTIONS'
                                                 and column_name = 'TRAN_DATE'
                                                 and date_field >= w_ppln_start_date
                                             )
                              and ppln_id is null
                              and scnd_type = 'BIL'
                              and tran_outst_ind = 'Y'
                              and prim_type      = 'D'
                              and fully_reversed_ind is null
                              and tran_date >=  w_ppln_start_date
                              and tran_date <=  w_ptbm.billing_date
                              and tran_id   <   w_tran_id  -- Add 6929 Do not consider the current bill
                           )
         loop
            w_label := 'e227';
            debug_trace(w_procedure_name,'...[5]bill_id,bill_key     =' ||r1_prv_bln.bill_id || ' , ' ||r1_prv_bln.bill_key);   --Add 3367
            debug_trace(w_procedure_name,'...[5]w_ppln_start_date    =' ||datec(w_ppln_start_date));   --Add 3367
            debug_trace(w_procedure_name,'...[5]w_prv_bl_nt_inc_ppln =' ||w_prv_bl_nt_inc_ppln);   --Add 3367
            debug_trace(w_procedure_name,'...[5]w_tran_id =' ||w_tran_id); --Add 6929
            select sum(nvl(tran_bal_amnt,0))   -- sum(decode(scnd_type,'BIL',tran_bal_amnt,0))
                      --,sum(decode(scnd_type,'BIL',0,tran_bal_amnt))
              into w_int_tran_bal_prev_bill
                      --,w_int_tran_bal_oth
              from cis.cis_transactions
             where cust_id = w_cust_id
               and inst_id = w_inst_id
               and supply_type = 'WATER'                                  -- Add 3.0.0.1
               and tran_id >= (select min(low_id) from cis_low_id
                                where table_name  = 'CIS_TRANSACTIONS'
                                  and column_name = 'TRAN_DATE'
                                  and date_field >= w_ppln_start_date
                              )
               and tran_outst_ind = 'Y'
               and prim_type      = 'D'
               --and task_code      = 'BILL'   --No need single query can return both prev bill and other debts
               --and scnd_type      = 'BIL'    --No need single query can return both prev bill and other debts
               and bill_id        = r1_prv_bln.bill_id
               and ppln_id is null;
               w_prv_bl_nt_inc_ppln     := w_prv_bl_nt_inc_ppln     + w_int_tran_bal_prev_bill;
               --w_prv_bl_nt_inc_ppln_oth := w_prv_bl_nt_inc_ppln_oth + w_int_tran_bal_oth;
         end loop;
       end if;  --End Add 7055B
      debug_trace(w_procedure_name,'...[x.6]w_prv_bl_nt_inc_ppln         =' || w_prv_bl_nt_inc_ppln);       --Add 3367
      --debug_trace(w_procedure_name,'...[7]w_prv_bl_nt_inc_ppln_oth     =' || w_prv_bl_nt_inc_ppln_oth);   --Add 3367
      --End Add 3367
      w_ptbm.pymtagree := 0; --Initialize to Zero --Add 3367
      w_ppln_no_due    := 0; --Initialize to Zero --Add 3367
      for r1 in (                                                                       --Add 2212
                  select  paym_due_date                                                 --Add 2212
                        , paym_amnt                                                     --Add 2212
                        , paym_bal_amnt                                                 --Add 2212
                        , paym_num                                                      --Add 2212
                  from  cis_ppln_payments                                               --Add 2212
                  where ppln_id = w_ppln_id                                             --Add 2212
                    and paym_due_date <= (w_ptbm.penalty_date + 5)                      --Add 3367b +5 was added --Add/Mod 3367 was paym_due_date > w_ptbm.penalty_date chnged to paym_due_date <= (w_ptbm.penalty_date + 3)  --Add 2212 removed + 3
                    and paym_bal_amnt > 0                                               --Add 2212
                  order by paym_due_date                                                --Add 2212
                )                                                                       --Add 2212
      loop                                                                              --Add 2212
         w_ptbm.pymtagree := nvl(w_ptbm.pymtagree,0) + nvl(r1.paym_bal_amnt,0);         --Add 2212
      -- w_ppln_due_amnt  := nvl(w_ppln_due_amnt,0)  + nvl(r1.paym_bal_amnt,0);         --Add 2212 --Del 3093
         --w_ppln_no_due     := nvl(w_ppln_no_due,0)    + 1;                            --Del 3367 Add 2212
         debug(w_procedure_name,w_label,' In the Loop [2] w_ptbm.pymtagree ' || w_ptbm.pymtagree); --Add 2212
         --if w_ptbm.pymtagree >= w_installment_amnt then                     --Del 3367 --Add 2212
         -- w_ptbm.pymtagree := w_installment_amnt;                           --Del 3367 --Add 2212
         -- w_ppln_due_amnt  := w_installment_amnt;                           --Del 3367 -- Add 3093
         --   w_ppln_no_due    := 1;                                          --Del 3367 -- Add 3098
         -- exit;                                                             --Del 3367 --Add 2212
         --end if;                                                            --Del 3367 --Add 2212
      end loop;                                                               --Add 2212
      select count(*) into w_ppln_no_due                                      --Add 3367
        from cis_ppln_payments                                                --Add 3367
       where ppln_id = w_ppln_id                                              --Add 3367
         and paym_due_date <= w_ptbm.billing_date                             --Add 3367
         and paym_bal_amnt > 0;                                               --Add 3367
      --Start Add 3367
      debug_trace(w_procedure_name,'[x.7]...w_ptbm.pymtagree     =' || w_ptbm.pymtagree);             --Add 3367
      debug_trace(w_procedure_name,'[x.7]...w_prv_bl_nt_inc_ppln =' || w_prv_bl_nt_inc_ppln);         --Add 3367
      w_ptbm.pymtagree := nvl(w_ptbm.pymtagree,0) + nvl(w_prv_bl_nt_inc_ppln,0); --Del 4398 it's deducted twice. + (nvl(w_ptbm.discount_amnt,0) * -1) ; --Add 3616 --Multiply discount amount by -1 so that it will be positive. --Added Discount from Current Bill so that Agreement Amount won't be negative if the agreement amnt is paid for full
      debug_trace(w_procedure_name,'[x.8]...w_prv_bl_nt_inc_ppln     =' || w_prv_bl_nt_inc_ppln);             --Add 3367
      debug_trace(w_procedure_name,'[x.8]...w_ptbm.pymtagree     =' || w_ptbm.pymtagree);             --Add 3367
      /* Start Del 6929 */
      /*
      if (nvl(w_ptbm.pymtagree,0) - nvl(w_ptbm.subtot_curr_chgs,0)) > 0 then                        --Add 3367
      w_ptbm.pymtagree := nvl(w_ptbm.pymtagree,0) - nvl(w_ptbm.subtot_curr_chgs,0);                 --Add 3367
      else                                                                                          --Add 3367
         w_ptbm.pymtagree := 0;                                                                     --Add 3367
      end if;                                                                                       --Add 3367
      */
      /* End Del 6929 */
      debug_trace(w_procedure_name,'[x.9]...w_ptbm.subtot_curr_chgs =' || w_ptbm.subtot_curr_chgs);   --Add 3367
      debug_trace(w_procedure_name,'[x.10]...w_ptbm.pymtagree     =' || w_ptbm.pymtagree);            --Add 3367
      --End Add 3367
    end if;                                                                                --Add 2212
   end if;                                                                                 --Add 2212
         /* PJT Suggestion
         -- This code referring to cure amount is only used here.
         -- It is not required because the payment agreement amount is set form the above code
         -- Start Del 3093
   w_cure_amnt := null;                              --Add 2666
   if w_ppln_type != 'I' then                            --Add 2666
      w_label := 'e228';                             --Add 2666
    select sum(tran_bal_amnt) into w_cure_amnt from phl_cure_amount_v              --Add 2666
    where inst_id   = w_inst_id                          --Add 2666
              and cust_id   = w_cust_id                          --Add 2666
              and supply_type = 'WATER'                          --Add 2666
              and payment_due_date <= w_ptbm.penalty_date;                    --Add 2666
                                                                                                                     --Add 2666
    if w_ppln_no_due > 0 then                                                                                --Add 2666
     if nvl(w_cure_amnt,0) > 0 then                         --Add 2666
      w_ptbm.pymtagree := nvl(w_cure_amnt,0) - nvl(w_ptbm.subtot_curr_chgs,0);          --Add 2666
     end if;                                  --Add 2666
    else                                    --Add 2666
     if nvl(w_cure_amnt,0) > 0 then                         --Add 2666
      w_ptbm.pymtagree    := nvl(w_cure_amnt,0) - nvl(w_ptbm.subtot_curr_chgs,0) + w_installment_amnt; --Add 2666
     end if;                                  --Add 2666
     end if;                                 --Add 2666
   end if;                                  --Add 2666
  -- End Del 3093 */
   --debug(w_procedure_name,w_label,' Outside the Loop w_ptbm.pymtagree ' || w_ptbm.pymtagree);
   --debug(w_procedure_name,w_label,' ..1.. w_ptbm.pymtagree   ' || w_ptbm.pymtagree);
   --debug(w_procedure_name,w_label,' ..1.. w_ptbm.wrbccpmt    ' || w_ptbm.wrbccpmt);
   --debug(w_procedure_name,w_label,' ..1.. w_ptbm.pymtagree   ' || w_ptbm.pymtagree);
   --debug(w_procedure_name,w_label,' ..1.. w_ppln_due_amnt    ' || w_ppln_due_amnt);
   --debug(w_procedure_name,w_label,' ..1.. w_ppln_no_due      ' || w_ppln_no_due);
   --
   --Payment Due ---is set at the select for standard bill
   --
       w_label := 'e229';                             --Add 2.0.0.0
   debug(w_procedure_name,w_label,' <1><><><> w_ptbm.total_due_amnt      ' || w_ptbm.total_due_amnt);
   w_ptbm.total_due_amnt  := nvl(w_ptbm.tot_curr_chgs,0);
   debug(w_procedure_name,w_label,' <1><><><> w_ptbm.total_due_amnt      ' || w_ptbm.total_due_amnt);
   if w_ppln_type is not null then
    if w_ppln_type = 'I' then
     w_ptbm.pymtagree   := null;
     if w_ptbm.wrbccpmt is null then w_ptbm.wrbccpmt := 0; end if;     --Add 2.0.0.14
    else
     w_ptbm.wrbccpmt   :=   null;
     if w_ptbm.pymtagree is null then w_ptbm.pymtagree := 0; end if;
    end if;
   else
    w_ptbm.wrbccpmt   :=   null;
    w_ptbm.pymtagree   :=  null;
   end if;
   --debug_trace(w_procedure_name,'...w_ptbm.total_due_amnt --> ' || w_ptbm.total_due_amnt);
   debug(w_procedure_name,w_label,' ..2.. w_ptbm.pymtagree   ' || w_ptbm.pymtagree);
   w_label := 'e230';                                                      --Add 2.0.0.0
   debug(w_procedure_name,w_label,' ..2.. w_ptbm.wrbccpmt    ' || w_ptbm.wrbccpmt);
   debug(w_procedure_name,w_label,' ..2.. w_ptbm.pymtagree   ' || w_ptbm.pymtagree);
   debug(w_procedure_name,w_label,' ..2.. w_ppln_due_amnt    ' || w_ppln_due_amnt);
   debug(w_procedure_name,w_label,' ..2.. w_ppln_no_due      ' || w_ppln_no_due);
   /* Start Del 3706
   -- Need to include this message in message table
   -- Start of code added for 2109 --2.0.0.07 --1.0.0.68
   -- w_est_rev_messg := null;                 --Add 2.0.0.20
   -- if w_prepare_est_rev_msg
   -- and w_est_rev_amnt <> 0       -- Only add message is the estimate total amount is not zero.
   -- then
   --    w_est_rev_messg := substr('Usage charge from actual reading is '
   --              || trim(to_char(w_real_read_amnt, '$999,990.99'))
   --              || ' less credit for previously estimated  usage of '
   --              || trim(to_char(w_est_rev_amnt, '$999,990.99'))
   --              || ' ',1, 243);
   -- end if;
   --                                                                  End of code added for 2109 --2.0.0.07 --1.0.0.68
   --
   */ --End Del 3706
     debug(w_procedure_name,w_label,'{{|}}.w_in_mtr_grp      ' || w_in_mtr_grp);
     debug(w_procedure_name,w_label,'{{|}}.w_unbill_reg_found' || w_unbill_reg_found);
     debug(w_procedure_name,w_label,'{{|}}.w_inst_id         ' || w_inst_id);
     w_label := 'e231';
     if w_in_mtr_grp = 'Y'                                                         -- Add 818
     then                                                                          -- Add 818
        if w_unbill_reg_found = 'N'                                                -- Add 818
        then                                                                       -- Add 818
           select substr(max(m.meter_key), 1, 7)                                   -- Add 818
                 ,max(m.meter_key)																								 -- Add 11138
                 ,max(m.meter_id)																									 -- Add 11138
             into w_ptbm.meter_key                                                 -- Add 818
                 ,g_meter_key_10chr																					 			 -- Add 11138
                 ,g_meter_id																											 -- Add 11138
             from cis_meter_grp_rdg_lines mgr,                                     -- Add 818
                  cis_meters m                                                     -- Add 818
            where mgr.meter_grp_rdg_id = w_meter_grp_rdg_id                        -- Add 818
              and mgr.meter_id = m.meter_id                                        -- Add 818
              and meter_reading is not null;                                       -- Add 818
           w_distribution_source := null;                                          -- Add 818
           select max(distribution_source)                                         -- Add 818
             into w_distribution_source                                            -- Add 818
             from cis_supply_points                                                -- Add 818
            where inst_id = w_inst_id                                              -- Add 818   -- Chg 3.0.0.1
              and supply_type = 'WATER';                                           -- Add 3.0.0.1
           debug(w_procedure_name,w_label,' ..2.1. w_distribution_source    ' || w_distribution_source);
           w_label := 'e232';
           if w_distribution_source is not null                                    -- Add 818
           then
                w_label := 'e233';
                if w_ptbm.repl_reading_from_date is not null                         -- Add 2127
                then                                                                 -- Add 2127
                   w_factor_from_date := w_ptbm.repl_reading_from_date;              -- Add 2127
                else                                                                 -- Add 2127
                   w_factor_from_date := w_ptbm.reading_from_date;                   -- Add 2127
                end if;                                                              -- Add 2127
                debug(w_procedure_name,w_label,' ..2.2. w_factor_from_date    ' || datec(w_factor_from_date));
                w_label := 'e234';
                if w_factor_from_date is null                                        -- Add 2127
                then                                                                 -- Add 2127
                   w_factor_from_date := w_ptbm.billing_date;                        -- Add 2127
                end if;                                                              -- Add 2127
                if w_ptbm.reading_upto_date is not null                              -- Add 2127
                then                                                                 -- Add 2127
                   w_factor_upto_date := w_ptbm.reading_upto_date;                   -- Add 2127
                else                                                                 -- Add 2127
                   w_factor_upto_date := w_factor_from_date;                         -- Add 2127
                end if;                                                              -- Add 2127
                debug(w_procedure_name,w_label,' ..2.3. w_factor_upto_date    ' || datec(w_factor_upto_date));
  --             w_quality_date := null;                                              -- Add 818 -- Del 2127
                w_label := 'e235';
                select nvl(max(quality_date), w_factor_from_date)                    -- Add 818 -- Chg 2127
                  into w_factor_from_date                                            -- Add 818 -- Chg 2127
                  from cis_quality_factors                                           -- Add 818
                 where supply_type = 'WATER'                                         -- Add 818
                   and distribution_source = w_distribution_source                   -- Add 818
                   and quality_date <= w_factor_from_date;                           -- Add 818 -- Chg 2127
  --             if w_quality_date is not null                                        -- Add 818 -- Del 2127
  --             then                                                                 -- Add 818 -- Del 2127
  --                select quality_factor                                             -- Add 818 -- Del 2127
  --                  into w_quality_factor                                           -- Add 818 -- Del 2127
  --                  from cis_quality_factors                                        -- Add 818 -- Del 2127
  --                 where supply_type = 'WATER'                                      -- Add 818 -- Del 2127
  --                   and distribution_source = w_distribution_source                -- Add 818 -- Del 2127
  --                   and quality_date = w_quality_date;                             -- Add 818 -- Del 2127
  --             end if;                                                              -- Add 818 -- Del 2127
              debug(w_procedure_name,w_label,' ..2.4. w_distribution_source ' || w_distribution_source);
              debug(w_procedure_name,w_label,' ..2.4. w_factor_from_date    ' || datec(w_factor_from_date));
              debug(w_procedure_name,w_label,' ..2.4. w_factor_upto_date    ' || datec(w_factor_upto_date));
              w_label := 'e236';
              w_factor_message := null;                                               -- Add 2127
              for r1 in (select quality_factor
                               ,quality_date
                           from cis_quality_factors                                   -- Add 2127
                          where supply_type = 'WATER'                                 -- Add 2127
                            and distribution_source = w_distribution_source           -- Add 2127
                            and quality_date between w_factor_from_date               -- Add 2127
                                                 and w_factor_upto_date               -- Add 2127
                          order by quality_date                                       -- Add 2127
                         )                                                            -- Add 2127
              loop                                                                    -- Add 2127
                 w_factor_message := substr(w_factor_message || 'from ' ||            -- Add 2127
                                     to_char(r1.quality_date, 'MM/DD/YYYY') ||        -- Add 2127
                                     ' = ' ||                                         -- Add 2127
                                     to_char(r1.quality_factor, '990.999') || ' '     -- Add 2127
                                     , 1, 186);                                       -- Add 2127 --Chg 1.0.0.71 --Chg2.0.0.12 from 188 to 186
              end loop;                                                               -- Add 2127
           end if;                                                                 -- Add 818
        end if;                                                                    -- Add 818
     end if;                                                                       -- Add 818
   /* Need to Add this message to Message table */
     w_label := 'e237';
     debug(w_procedure_name,w_label,' ..2.4.0 w_factor_upto_date    ' || datec(w_factor_upto_date));
     debug(w_procedure_name,w_label,' ..2.4.1 w_copy_bill_ind       ' || w_copy_bill_ind);
 --    if w_quality_factor is not null                                         -- Add 818 -- Del 2127
     if w_factor_message is not null                                           -- Add 2127
     then                                                                      -- Add 818
        if nvl(w_copy_bill_ind,'N') = 'Y'                                      -- Add 818
        then                                                                   -- Add 818
           w_label := 'e238';
           debug(w_procedure_name,w_label,' ..2.4.2 w_copy_bill_ind   ' || datec(w_factor_upto_date));
           w_sur_cst_fct_mssg := 'Surcharge Cost Factor ' ||                   -- Add 818 -- Chg 2127 (removed =)
 --                                 to_char(w_quality_factor, '990.999') ||    -- Add 818 -- Del 2127
                                    w_factor_message || ' Duplicate copy as requested.';            -- Add 818
        else                                                                   -- Add 818
           w_label := 'e239';
           debug(w_procedure_name,w_label,' ..2.4.3 w_copy_bill_ind   ' || datec(w_factor_upto_date));
           w_sur_cst_fct_mssg := 'Surcharge Cost Factor ' ||                   -- Add 818 -- Chg 2127 (removed =)
 --                                 to_char(w_quality_factor, '990.999');      -- Add 818 -- Del 2127
                                    w_factor_message;                          -- Add 2127
        end if;                                                                -- Add 818
     else                                                                      -- Add 818
        if nvl(w_copy_bill_ind,'N') = 'Y'                                      -- Add 818
        then                                                                   -- Add 818
           w_label := 'e240';
           debug(w_procedure_name,w_label,' ..2.4.4 w_factor_message  ' || w_factor_message);
           debug(w_procedure_name,w_label,' ..2.4.4 w_copy_bill_ind   ' || w_copy_bill_ind);
           w_sur_cst_fct_mssg := 'Duplicate copy as requested ';               -- Add 818
           w_ptbm.dup_ind := 'D';                                       										-- Add 8020F
           debug(w_procedure_name,w_label,' ..2.4.2 w_copy_bill_ind   ' || w_ptbm.dup_ind); --Add 8020F
        else
           w_label := 'e241';
           debug(w_procedure_name,w_label,' ..2.4.5 w_factor_message  ' || w_factor_message);
           debug(w_procedure_name,w_label,' ..2.4.5 w_copy_bill_ind   ' || w_copy_bill_ind);
           w_sur_cst_fct_mssg := null;                         -- Chg 1.0.0.71 -Chg 2.0.0.12
        end if;                                                                -- Add 818
     end if;                                                                   -- Add 818
                          -- Add 2.0.0.10
     if w_in_mtr_grp = 'Y'                                                 -- Add 818
     and w_unbill_reg_found = 'N'                                          -- Add 818
     then                                                                  -- Add 818
         w_srvc_code_inst_id := null;                                      -- Add 818
         select max(inst_id) into w_srvc_code_inst_id                      -- Add 818
         from cis_meter_grp_rdg_lines                                      -- Add 818
         where meter_grp_rdg_id = w_meter_grp_rdg_id                       -- Add 818
         and inst_id <> w_inst_id;                                         -- Add 818
         if w_srvc_code_inst_id is null                                    -- Add 818
         then                                                              -- Add 818
            w_srvc_code_inst_id := w_inst_id;                              -- Add 818
         end if;                                                           -- Add 818
         select                                                            -- Add 818
             '4' || substr(attribute29,2,2)                                -- Add 818
            ,owner_cust_id                                                 -- Add 2176
            ,tenn_cust_id                                                  -- Add 2176
            ,attribute29                                                   -- Add 3706
            ,attribute19                                                   -- Add 3706
            ,revu2_code																										 -- Add 8020B
         into                                                              -- Add 818
             w_service_code_inst                                           -- Add 818
            ,w_bill_owner_cust_id                                          -- Add 2176
            ,w_bill_tenn_cust_id                                           -- Add 2176
            ,w_int_attr29                                                  -- Add 3706
            ,w_int_attr19                                                  -- Add 3706
         	  ,g_inst_revu2_code																						 -- Add 8020B
         from   cis_installations                                          -- Add 818
         where inst_id = w_srvc_code_inst_id;                              -- Add 818
     else                                                                  -- Add 818
        select
          substr(attribute29,1,2)                                          -- Add 1.0.0.17
         ,owner_cust_id                                                    -- Add 2176
         ,tenn_cust_id                                                     -- Add 2176
         ,attribute29                                                      -- Add 3706
         ,attribute19                                                      -- Add 3706
         ,revu2_code																											 -- Add 8020B
        into
          w_service_code_inst                                              -- Add 1.0.0.17
         ,w_bill_owner_cust_id                                             -- Add 2176
         ,w_bill_tenn_cust_id                                              -- Add 2176
         ,w_int_attr29                                                     -- Add 3706
         ,w_int_attr19                                                     -- Add 3706
         ,g_inst_revu2_code																								 -- Add 8020B
        from   cis_installations                                           -- Add 1.0.0.17
        where inst_id = w_inst_id;                                         -- Add 1.0.0.17
     end if;                                                               -- Add 818
     -- Now format bill service
     w_label := 'e242';
	   --Start Add 8020B
	   debug_trace(w_procedure_name,'...w_bill_owner_cust_id  =' ||TO_CHAR(w_bill_owner_cust_id));
	   debug_trace(w_procedure_name,'...w_bill_tenn_cust_id   =' ||TO_CHAR(w_bill_tenn_cust_id));
	   debug_trace(w_procedure_name,'...w_cust_id       			=' ||TO_CHAR(w_cust_id));
	   debug_trace(w_procedure_name,'...g_loot_ind       		  =' ||g_loot_ind);
	   debug_trace(w_procedure_name,'...g_inst_revu2_code     =' ||g_inst_revu2_code);
		 if (nvl(g_loot_ind,'xxx') = 'LL-TEN' or nvl(g_loot_ind,'xxx') = 'LL-OCC' ) --Chng 10108
		 and w_bill_owner_cust_id != w_bill_tenn_cust_id
		 and w_cust_id = w_bill_owner_cust_id
		 then
		 	 g_loot_ind := 'LANDLORD';
		 elsif (nvl(g_inst_revu2_code,'xxx') = 'TENANT' and w_cust_id = w_bill_tenn_cust_id)
		 then
		 	 g_loot_ind := 'TENANT';
		 --elsif (nvl(g_inst_revu2_code,'xxx') like 'WITH%' or nvl(g_loot_ind,'xxx') = 'LL-OCC')	then --Del 10108
		 elsif nvl(g_inst_revu2_code,'xxx') like 'WITH%' 	then --Chng 10108
		 	 g_loot_ind := 'OCCUPANT';
		 elsif w_bill_owner_cust_id = w_bill_tenn_cust_id then
		 	 g_loot_ind := 'OWNER';
		 else
		 	 g_loot_ind := 'OWNER';
		 end if;
	   debug_trace(w_procedure_name,'...g_loot_ind       		=' ||g_loot_ind);
		 --End Add 8020B
     --w_ptbm.bill_service := substr(w_ptbm.cust_type_code,1,1) || '1' || substr(w_ptbm.srvc_size_code,1,1); --1.0.0.17
     w_ptbm.bill_service := substr(w_ptbm.cust_type_code,1,1) || w_service_code_inst; --1.0.0.17
     if w_ptbm.repl_meter_key is not null                                                        -- Add 1129
     then                                                                                        -- Add 1129
        w_ptbm.repl_bill_service   := w_ptbm.bill_service;                                       -- Add 1129
        w_ptbm.repl_srvc_size_code := w_ptbm.srvc_size_code;                                     -- Add 1129
     end if;                                                                                     -- Add 1129
   debug_trace(w_procedure_name,'w_ppln_type --> ' || w_ppln_type);
   debug_trace(w_procedure_name,'<2><><><> w_ptbm.total_due_amnt --> ' || w_ptbm.total_due_amnt);
   -- Set penalty totals
   w_label := 'e243';
   --Total amount changes, need to remove it from penalty calculations, or can we add it after penalty calc --Add 4398
   w_ptbm.total_bal      := w_ptbm.total_due_amnt;           -- Add 2.0.0.10
   debug_trace(w_procedure_name,'<2.001><><><> w_ptbm.total_due_amnt                --> ' || w_ptbm.total_due_amnt);
   debug_trace(w_procedure_name,'<2.001><><><> w_ptbm.total_bal                     --> ' || w_ptbm.total_bal);
   debug_trace(w_procedure_name,'<2.001><><><> w_tap_bill_print.cur_part_from_date  --> ' || datec(w_tap_bill_print.cur_part_from_date));
   --Start Add 7164
   select  nvl(sum(decode(ppln_id,null,decode(trn.tran_outst_ind,'Y',tran_bal_amnt,0),0)),0)   --Chng 9792 because we removed tran_outst_ind to get tran_tot_amnt..
          ,nvl(sum(decode(ppln_id,null,tran_tot_amnt,0)),0)   --Add 9792
          ,nvl(sum(decode(ppln_id,null,0,tran_bal_amnt)),0)
          ,nvl(sum(decode(ppln_id,null,0,tran_tot_amnt)),0)   --Add 9792
          ,nvl(sum(decode(sign(trn.tran_date - nvl(w_tap_bill_print.cur_part_from_date,trn.tran_date)),-1,trn.tran_bal_amnt,0)),0)   --Add 7164D
          ,nvl(sum(decode(sign(trn.tran_date - nvl(w_tap_bill_print.cur_part_from_date,trn.tran_date)),-1,0,trn.tran_bal_amnt)),0)   --Add 7164D
     into  w_ptbm.amnt_in_disp
					,g_disp_tot_amnt_not_in_agr		--Add 9792
          ,w_amnt_disp_n_agr 																	--w_ptbm.amnt_disp_n_agr --del 7164 kept for future use, remember to remove the trn.ppln_id is null from where clause.
					,g_disp_tot_amnt_in_agr  			--Add 9792
          ,w_amnt_disp_pre_TAP      --Add 7164D
          ,w_amnt_disp_post_TAP  --Add 7164D
     from cis_transactions trn
    where trn.cust_id = w_cust_id
      and trn.inst_id = w_inst_id
      and trn.supply_type = 'WATER'
      and trn.fully_reversed_ind is null      -- not reversed
      --and trn.tran_outst_ind = 'Y'          -- Del 9792  -- tran is outstanding
      and trn.ppln_id is null                 -- ADD 7164A -- IGNORE DISPUTE TRANS LINKED TO PAYENT PLAN.
      and trn.dispute_code is not null
      and trn.dispute_code not like 'PAYTIME%'
      and nvl(trn.debt_coll_id_1,-1) not in (select nvl(dbcl.debt_coll_id,-2) from cis.cis_debt_collection dbcl                    --Add 7164A
                                              where dbcl.cust_id = w_cust_id                                                                            --Add 7164A
                                                and dbcl.inst_id = w_inst_id                                                                               --Add 7164A
                                                and dbcl.supply_type = 'WATER'                                                                          --Add 7164A
                                                and (   (dbcl.debt_coll_path = 'TAPHLD' and dbcl.debt_coll_stage = 'TAPDSHEL')  --Add 7164A
                                                     or (dbcl.debt_coll_path = 'TAPPEN' and dbcl.debt_coll_stage = 'TAPDSHEL')  --Add 7164A
                                                    )                                                                                                               --Add 7164A
                                            );                                                                                                                         --Add 7164A
   --End Add 7164
	 w_ptbm.tot_disp_amnt  := nvl(g_disp_tot_amnt_not_in_agr,0) + nvl(g_disp_tot_amnt_in_agr,0); --Add 9792
	 if w_ptbm.tot_disp_amnt = 0 then w_ptbm.tot_disp_amnt := null; end if; --Add 9792
   debug_trace(w_procedure_name,'<2.0000000001><><><> w_ptbm.amnt_in_disp  --> ' || w_ptbm.amnt_in_disp);
   debug_trace(w_procedure_name,'<2.0000000001><><><> w_ptbm.tot_disp_amnt  --> ' || w_ptbm.tot_disp_amnt); --Add 9792
    --Start Del 7164D
    --Star Add 7164C
    /*
   if TAP_Acct then
         --w_ptbm.amnt_in_disp := nvl(w_amnt_disp_pre_TAP,0); --Only pre TAP Dispute is removed from Please Pay and other places.
   end if;
   */
    --End Add 7164C
    --End Del 7164D
    --Start Add 7164D
    w_ptbm.nus_chrg       := w_ptbm.tap_pym_2_arrs; --Storing TAP charges towards arrears 2nd field [TAP_PYM_2_ARRS_2ND] in this field, will rename it later to TAP_PYM_2_ARRS_2ND
    w_ptbm.mtr_chrg       := w_amnt_disp_pre_TAP;   --Storing DISPUT PRE TAP [DISP_PRE_TAP]
    w_ptbm.hlp_loan       := w_amnt_disp_post_TAP;  --Storing DISPUT POST TAP [DISP_POST_TAP]
    --Start End 7164D
   debug_trace(w_procedure_name,'<2.001><><><> w_cust_id                   --> ' || w_cust_id);
   debug_trace(w_procedure_name,'<2.001><><><> w_inst_id                   --> ' || w_inst_id);
   debug_trace(w_procedure_name,'<2.001><><><> w_ptbm.amnt_in_disp   --> ' || w_ptbm.amnt_in_disp);
   debug_trace(w_procedure_name,'<2.001><><><> w_amnt_disp_n_agr     --> ' || w_amnt_disp_n_agr);
   debug_trace(w_procedure_name,'<2.001><><><> w_amnt_disp_pre_TAP   --> ' || w_amnt_disp_pre_TAP);
   debug_trace(w_procedure_name,'<2.001><><><> w_amnt_disp_post_TAP --> ' || w_amnt_disp_post_TAP);
   debug_trace(w_procedure_name,'<2.001><><><> w_ptbm.total_due_amnt --> ' || w_ptbm.total_due_amnt);
    w_ptbm.total_due_amnt := w_ptbm.total_due_amnt - nvl(w_ptbm.amnt_in_disp,0);  --Add 7164D Del 7164C  --
   debug_trace(w_procedure_name,'<2.002><><><> w_ptbm.total_due_amnt --> ' || w_ptbm.total_due_amnt);
   debug_trace(w_procedure_name,'<2><><><> w_ptbm.total_due_amnt --> ' || w_ptbm.total_due_amnt);
   --if in payment plan we don't penalize             -- Add 2.0.0.14
   if w_ppln_type  is not null then
      if w_ppln_type = 'I' then
         w_label := 'e244';
         w_ptbm.total_due_amnt := nvl(w_ppln_due_amnt,0);          --Chg 2361 w_ptbm.wrbccpmt;-- Add 2.0.0.14
         debug(w_procedure_name,w_label,' <3><><><> w_ptbm.total_due_amnt      ' || w_ptbm.total_due_amnt);
         --debug_trace(w_procedure_name,'...2... w_ptbm.total_due_amnt --> ' || w_ptbm.total_due_amnt);
      else
         w_label := 'e245';
         w_ptbm.total_due_amnt := nvl(w_ptbm.pymtagree,0)
                                + nvl(w_ptbm.subtot_curr_chgs,0)              --Add 2.0.0.55
                                + nvl(w_ptbm.late_pmt_penalty,0)              --Add 6230B --We need to add Liens and [Susan/James/Claire/Shaneeka..etc meeting on TAP bill review 06/08/2017@2:00 to 3:00]
                                + nvl(w_ptbm.lien,0)                          --Add 6230B --Late Payment Penalties   [For Standard Payment Plan]
                                + nvl(w_ptbm.bank_return_item,0)              --Add 7055B
                                + nvl(w_ptbm.meter_test_charge,0)             --Add 7055B
                                + nvl(w_ptbm.sewer_credit,0);                 --Add 7055B
                                --+ nvl(w_prv_bl_nt_inc_ppln_oth,0)           --Add 3367 inclide lien and other charges to please pay amount
                                --+ nvl(w_ptbm.discount_amnt,0)               --Del 4398 remove Add 3616 Remove Discount from the Actual Pay this Amount.
         --debug_trace(w_procedure_name,'...3... w_ptbm.total_due_amnt --> ' || w_ptbm.total_due_amnt);
         debug(w_procedure_name,w_label,' <4><><><> w_ptbm.pymtagree        ' || w_ptbm.pymtagree);
         debug(w_procedure_name,w_label,' <4><><><> w_ptbm.subtot_curr_chgs ' || w_ptbm.subtot_curr_chgs);
         debug(w_procedure_name,w_label,' <4><><><> w_ptbm.late_pmt_penalty ' || w_ptbm.late_pmt_penalty);
         debug(w_procedure_name,w_label,' <4><><><> w_ptbm.lien             ' || w_ptbm.lien);
         debug(w_procedure_name,w_label,' <4><><><> w_ptbm.bank_return_item ' || w_ptbm.bank_return_item);
         debug(w_procedure_name,w_label,' <4><><><> w_ptbm.meter_test_charge' || w_ptbm.meter_test_charge);
         debug(w_procedure_name,w_label,' <4><><><> w_ptbm.sewer_credit     ' || w_ptbm.sewer_credit);
      end if;
      --if w_ptbm.total_due_amnt < 0 then       --Del 4398
      --   w_ptbm.total_due_amnt := 0;          --Del 4398
      --end if;                                 --Del 4398
      --w_ptbm.penalty_date   := w_ptbm.payment_due_date + 8;         --Del 2.0.0.23 -- Add 2.0.0.15 -- Add 2.0.0.14
      -- Del 2122 Moved Up w_ptbm.penalty_date     := next_valid_due_date(w_ptbm.billing_date + 30);   --Chg 2.0.0.23 -- Add 2.0.0.15 -- Add 2.0.0.14
      w_ptbm.penalty_amnt     := 0;                                     -- Add 2.0.0.15
      --w_ptbm.penalty_due_amnt := w_ptbm.total_due_amnt;    --Del 4398 -- Add 2.0.0.15
      debug_trace(w_procedure_name,'<5><><><> w_ptbm.total_due_amnt --> ' || w_ptbm.total_due_amnt);
   else                      -- Add 2.0.0.10
    --Del 2249 --Add 2.0.0.10 Use w_ptbm.current_charge_amnt it will give current charges + chargeable extras
    --Del 2249 --Actual current charges.
    --Del 2249
    --Del 2249 --if (w_ptbm.current_charge_amnt  > 0 or w_ptbm.sub_tot_prev_bal > 0)  and w_ptbm.total_due_amnt > 0 then
    --Del 2249 --Added nvl(w_ptbm.tot_cred,0) Remove Discount from Current Charges to derive future penalty --Mod 2176
    --Del 2249 if ( (w_ptbm.subtot_curr_chgs + nvl(w_ptbm.chxext,0) + nvl(w_ptbm.tot_cred,0) )> 0 or
    --Del 2249      (w_ptbm.sub_tot_prev_bal - nvl(w_ptbm.chxext,0))> 0    )  and w_ptbm.total_due_amnt > 0 then
    --Del 2249    w_label := 'e246';
    --Del 2249    ciss0034.get_supply(w_supply_type);
    --Del 2249
    --Del 2249  ---1/2% Penalty Calculation
    --Del 2249  if (w_ptbm.sub_tot_prev_bal - nvl(w_ptbm.chxext,0) ) > 0 then
    --Del 2249   w_prev_bal_pnlty_calc := w_ptbm.sub_tot_prev_bal - nvl(w_ptbm.chxext,0) ;
    --Del 2249  else
    --Del 2249   w_prev_bal_pnlty_calc := 0;
    --Del 2249  end if;
    --Del 2249
    --Del 2249  ---5% Penalty Calculation
    --Del 2249  ---Remove Discount w_ptbm.tot_cred from Current Charges to derive future penalty --Mod 2176
    --Del 2249  if (w_ptbm.sub_tot_prev_bal - nvl(w_ptbm.chxext,0) ) < 0 then
    --Del 2249   if (w_ptbm.subtot_curr_chgs + w_ptbm.sub_tot_prev_bal + nvl(w_ptbm.tot_cred,0) ) > 0 then
    --Del 2249    w_tot_cur_chgs_pnlty_calc := w_ptbm.subtot_curr_chgs + w_ptbm.sub_tot_prev_bal + nvl(w_ptbm.tot_cred,0); --Mod 2176  --Chargeable Extras are added in w_ptbm.sub_tot_prev_bal so no need to add and substract from current charges and previous balance
    --Del 2249   else
    --Del 2249    w_tot_cur_chgs_pnlty_calc  := 0;
    --Del 2249   end if;
    --Del 2249  else
    --Del 2249   if (w_ptbm.subtot_curr_chgs + nvl(w_ptbm.chxext,0) ) > 0 then
    --Del 2249    w_tot_cur_chgs_pnlty_calc := w_ptbm.subtot_curr_chgs + nvl(w_ptbm.chxext,0) + nvl(w_ptbm.tot_cred,0) ; --Mod 2176  --w_ptbm.current_charge_amnt;
    --Del 2249   else
    --Del 2249    w_tot_cur_chgs_pnlty_calc  := 0;
    --Del 2249   end if;
    --Del 2249  end if;
    --Del 2249
    --Del 2249
    --Del 2249  -- Start 2176
    --Del 2249  if w_bill_owner_cust_id != w_bill_tenn_cust_id then ---Owner ID is not equal to Tenn ID --> Landlord Tennent
    --Del 2249   if w_bill_owner_cust_id = w_cust_id then     ---If Owner ID equals Cust ID --> Owner Account 5% Penalty is not calculated
    --Del 2249      w_ptbm.penalty_amnt := ciss0022.scale_amnt((nvl(w_prev_bal_pnlty_calc,0) * w_penalty_factor2),ciss0034.supply_parameters.supply_currency_code); -- Add 2176
    --Del 2249   else
    --Del 2249      w_ptbm.penalty_amnt := ciss0022.scale_amnt                                                  -- add 2176
    --Del 2249                            (                                                                     -- add 2176
    --Del 2249                             ((nvl(w_tot_cur_chgs_pnlty_calc,0) * w_penalty_factor1) +      -- add 2176
    --Del 2249                                  (nvl(w_prev_bal_pnlty_calc  ,0) * w_penalty_factor2))          -- add 2176
    --Del 2249                            ,ciss0034.supply_parameters.supply_currency_code         -- add 2176
    --Del 2249                            );                         -- add 2176
    --Del 2249   end if;
    --Del 2249  else
    --Del 2249     w_ptbm.penalty_amnt := ciss0022.scale_amnt                                                     -- add 2.0.0.9 Add 2.0.0.0
    --Del 2249                           (                                                                        -- add 2.0.0.9 Add 2.0.0.0
    --Del 2249                            ((nvl(w_tot_cur_chgs_pnlty_calc,0) * w_penalty_factor1) +         -- add 2.0.0.9 Add 2.0.0.0
    --Del 2249                                 (nvl(w_prev_bal_pnlty_calc  ,0) * w_penalty_factor2))             -- add 2.0.0.9 Chg 2.0.0.05
    --Del 2249                           ,ciss0034.supply_parameters.supply_currency_code          -- add 2.0.0.9 Add 2.0.0.0
    --Del 2249                           );                          -- add 2.0.0.9 Add 2.0.0.0
    --Del 2249  end if;
    --Del 2249  -- End 2176
    --Del 2249
    --Del 2249    w_ptbm.penalty_due_amnt := w_ptbm.total_due_amnt + nvl(w_ptbm.penalty_amnt,0);               -- Add 1.0.0.4
    --Del 2249 else
    --Del 2249    w_ptbm.penalty_amnt   := 0;
    --Del 2249    w_ptbm.penalty_due_amnt := 0;
    --Del 2249 end if;
    --Del 2249
    --Del 2249 if w_ptbm.total_due_amnt < 0 then
    --Del 2249  w_ptbm.total_due_amnt := 0;
    --Del 2249 end if;
      --Add 2249 Chargeable extras are added to the current service charges
      --     They are no longer part of Adjustment
      --     Hence they wont be part of Previous Balance
      --     No need to add it to current charges or substract it from previous charges
      --     Please do not delete the lines uncommented by bug#2249 --Del 2249
      --     remove all reference of w_ptbm.chxext in the --Del 2249 code
      --Start Add 2249
      if (  (w_ptbm.subtot_curr_chgs + nvl(w_ptbm.tot_cred,0))> 0 or w_ptbm.sub_tot_prev_bal > 0)
         and w_ptbm.total_due_amnt > 0 then
         w_label := 'e247';
         ciss0034.get_supply(w_supply_type);
         ---1/2% Penalty Calculation
         if w_ptbm.sub_tot_prev_bal > 0 then
            w_prev_bal_pnlty_calc := w_ptbm.sub_tot_prev_bal;
         else
            w_prev_bal_pnlty_calc := 0;
         end if;
         ---5% Penalty Calculation
         ---Remove Discount w_ptbm.tot_cred from Current Charges to derive future penalty --Mod 2176
         --Chargeable Extras are added to Service charges so they are in subtot_curr_chgs
         --Remove all references to w_ptbm.chxext in the --Del 2249 code
         if (w_ptbm.sub_tot_prev_bal  ) < 0 then
            if (w_ptbm.subtot_curr_chgs + w_ptbm.sub_tot_prev_bal + nvl(w_ptbm.tot_cred,0) ) > 0 then
               w_tot_cur_chgs_pnlty_calc := w_ptbm.subtot_curr_chgs + w_ptbm.sub_tot_prev_bal + nvl(w_ptbm.tot_cred,0);
            else
               w_tot_cur_chgs_pnlty_calc  := 0;
            end if;
         else
            if w_ptbm.subtot_curr_chgs  > 0 then
               w_tot_cur_chgs_pnlty_calc := w_ptbm.subtot_curr_chgs + nvl(w_ptbm.tot_cred,0) ;
            else
               w_tot_cur_chgs_pnlty_calc  := 0;
            end if;
         end if;
         -- Start 2176
         if w_bill_owner_cust_id != w_bill_tenn_cust_id then ---Owner ID is not equal to Tenn ID --> Landlord Tennent
            if w_bill_owner_cust_id = w_cust_id then     ---If Owner ID equals Cust ID --> Owner Account 5% Penalty is not calculated
               w_ptbm.penalty_amnt := ciss0022.scale_amnt((nvl(w_prev_bal_pnlty_calc,0) * w_penalty_factor2),ciss0034.supply_parameters.supply_currency_code); -- Add 2176
            else
               w_ptbm.penalty_amnt := ciss0022.scale_amnt                                                  -- add 2176
                                     (                                                                     -- add 2176
                                      ((nvl(w_tot_cur_chgs_pnlty_calc,0) * w_penalty_factor1) +      -- add 2176
                                           (nvl(w_prev_bal_pnlty_calc  ,0) * w_penalty_factor2))          -- add 2176
                                     ,ciss0034.supply_parameters.supply_currency_code         -- add 2176
                                     );                         -- add 2176
            end if;
         else
            w_ptbm.penalty_amnt := ciss0022.scale_amnt                                                     -- add 2.0.0.9 Add 2.0.0.0
                                 (                                                                        -- add 2.0.0.9 Add 2.0.0.0
                                  ((nvl(w_tot_cur_chgs_pnlty_calc,0) * w_penalty_factor1) +         -- add 2.0.0.9 Add 2.0.0.0
                                       (nvl(w_prev_bal_pnlty_calc  ,0) * w_penalty_factor2))             -- add 2.0.0.9 Chg 2.0.0.05
                                 ,ciss0034.supply_parameters.supply_currency_code          -- add 2.0.0.9 Add 2.0.0.0
                                 );                          -- add 2.0.0.9 Add 2.0.0.0
         end if;
         -- End 2176
         -- w_ptbm.penalty_due_amnt := w_ptbm.total_due_amnt + nvl(w_ptbm.penalty_amnt,0);    -- Del 4398           -- Add 1.0.0.4
         --                                                                                   -- Del 4398
         -- --Start Add 3706                                                                  -- Del 4398
         -- if nvl(w_ptbm.penalty_due_amnt,0) < 0 then                                        -- Del 4398
         --    w_ptbm.penalty_due_amnt := 0;                                                  -- Del 4398
         -- end if;                                                                           -- Del 4398
         --End Add 3706
      else
         w_ptbm.penalty_amnt   := 0;
         --w_ptbm.penalty_due_amnt := 0;      --Del 4398
      end if;
      --Start Add 3706
      debug(w_procedure_name,w_label,' <Before 6...><><><>w_ptbm.total_due_amnt    ' || w_ptbm.total_due_amnt);     --Add 3706
      debug(w_procedure_name,w_label,' ..w_debt_tot_amnt_ues      ' || w_debt_tot_amnt_ues);       --Add 3706
      debug(w_procedure_name,w_label,' ..w_grnt_rcvd              ' || w_grnt_rcvd);               --Add 3706
      debug(w_procedure_name,w_label,' ..w_ptbm.debt_bal_amnt_ues ' || w_ptbm.debt_bal_amnt_ues);  --Add 3706
      debug(w_procedure_name,w_label,' ..w_taphld_bal_amnt        ' || w_taphld_bal_amnt);         --Chng 7055 from w_bnk_taphld_bal_amnt to w_taphld_bal_amnt  Add 6230A
      debug(w_procedure_name,w_label,' ..w_tappen_bal_amnt        ' || w_tappen_bal_amnt);         --Add 7055
      if nvl(w_ptbm.debt_bal_amnt_ues,0) <> 0 then
         w_label := 'e248';
         --w_ptbm.total_due_amnt := nvl(w_ptbm.total_due_amnt,0) +   - ( nvl(w_debt_tot_amnt_ues,0) - nvl(w_grnt_rcvd,0));
         w_ptbm.total_due_amnt := nvl(w_ptbm.total_bal,0) - nvl(w_ptbm.debt_bal_amnt_ues,0); --We need to remove grant thats not applied from please pay amount.
         debug(w_procedure_name,w_label,' <8><><><> w_ptbm.total_due_amnt      ' || w_ptbm.total_due_amnt);
         if (nvl(w_prev_bal_pnlty_calc,0)- nvl(w_ptbm.debt_bal_amnt_ues,0)) >= 0 and nvl(w_tot_cur_chgs_pnlty_calc,0) >= 0 then
            w_ptbm.penalty_amnt := ciss0022.scale_amnt
                                 (
                                  ((nvl(w_tot_cur_chgs_pnlty_calc,0) * w_penalty_factor1) +
                                       ((nvl(w_prev_bal_pnlty_calc,0)-nvl(w_ptbm.debt_bal_amnt_ues,0)) * w_penalty_factor2))
                                 ,ciss0034.supply_parameters.supply_currency_code
                                 );
         else
            if nvl(w_tot_cur_chgs_pnlty_calc,0)+(nvl(w_prev_bal_pnlty_calc,0)- nvl(w_ptbm.debt_bal_amnt_ues,0)) >= 0 then
               w_ptbm.penalty_amnt := ciss0022.scale_amnt                                                     -- add 2.0.0.9 Add 2.0.0.0
                                    (                                                                        -- add 2.0.0.9 Add 2.0.0.0
                                     (
                                      ( nvl(w_tot_cur_chgs_pnlty_calc,0) + ( nvl(w_prev_bal_pnlty_calc,0)-nvl(w_ptbm.debt_bal_amnt_ues,0) ) )
                                      * w_penalty_factor1
                                     )
                                     ,ciss0034.supply_parameters.supply_currency_code       -- add 2.0.0.9 Add 2.0.0.0
                                    );
            else
               if ((nvl(w_prev_bal_pnlty_calc,0)- nvl(w_ptbm.debt_bal_amnt_ues,0))+nvl(w_tot_cur_chgs_pnlty_calc,0)) >= 0 then
                  w_ptbm.penalty_amnt := ciss0022.scale_amnt
                                       (
                                        (
                                        ( ( nvl(w_prev_bal_pnlty_calc,0)- nvl(w_ptbm.debt_bal_amnt_ues,0) ) + nvl(w_tot_cur_chgs_pnlty_calc,0) )
                                        * w_penalty_factor2
                                        )
                                       ,ciss0034.supply_parameters.supply_currency_code
                                       );
               else
                  w_ptbm.penalty_amnt := 0;
               end if;
            end if;
         end if;
         if w_ptbm.penalty_amnt < 0 then
            w_ptbm.penalty_amnt := 0;
         end if;
         --w_ptbm.penalty_due_amnt := w_ptbm.total_due_amnt + nvl(w_ptbm.penalty_amnt,0); --Del 4398
         --Start Add 3706
         --if nvl(w_ptbm.penalty_due_amnt,0) < 0 then                                     --Del 4398
            --w_ptbm.penalty_due_amnt := 0;                                               --Del 4398
         --end if;                                                                        --Del 4398
         --End Add 3706
      end if;
      --End Add 3706
      --if w_ptbm.total_due_amnt < 0 then                                                 --Del 4398
      --   w_ptbm.total_due_amnt := 0;                                                    --Del 4398
      --end if;                                                                           --Del 4398
      --End Add 2249
   end if; /*PLAN TYPE*/ --Add 7055B
   /*Start 7055B */ --Moved all the code from top to here. So that TAPBills can have Agreement + other line items
   if w_ppln_type  is null then
      --Start Add 6230A
      debug(w_procedure_name,w_label,' <6><><><> Before TAPHLD/TAPPEN w_ptbm.total_due_amnt      ' || w_ptbm.total_due_amnt);
      /*
      --Start Add 9749
      select sum(decode(dbcl.debt_coll_path,'TAPHLD',tran_bal_amnt,0)) into g_taphld_bal_amnt_frm_trn
            ,sum(decode(dbcl.debt_coll_path,'TAPPEN',tran_bal_amnt,0)) into g_tappen_bal_amnt_frm_trn
        from cis_transactions tran,cis.cis_debt_collection dbcl
       where tran.cust_id = w_cust_id
         and tran.inst_id = w_inst_id
         and tran.supply_type = 'WATER'
				 and dbcl.cust_id = w_cust_id
         and dbcl.inst_id = w_inst_id
         and dbcl.supply_type = 'WATER'
         and tran.task_code != 'LN'
         and tran.debt_coll_id_1 = dbcl.debt_coll_id
         and dbcl.debt_coll_path in ('TAPHLD','TAPPEN');
         w_taphld_bal_amnt	:= nvl(g_taphld_bal_amnt_frm_trn,0);
         w_tappen_bal_amnt	:= nvl(g_tappen_bal_amnt_frm_trn,0);
      debug(w_procedure_name,w_label,' <6> g_taphld_bal_amnt_frm_trn  ' || g_taphld_bal_amnt_frm_trn);
      debug(w_procedure_name,w_label,' <6> g_tappen_bal_amnt_frm_trn  ' || g_tappen_bal_amnt_frm_trn);
      debug(w_procedure_name,w_label,' <6> w_taphld_bal_amnt  ' || w_taphld_bal_amnt);
      debug(w_procedure_name,w_label,' <6> w_tappen_bal_amnt  ' || w_tappen_bal_amnt);
      debug(w_procedure_name,w_label,' <6> g_tap_lien  				' || g_tap_lien);
      --End Add 9749
			*/
      if (nvl(w_taphld_bal_amnt,0) + nvl(w_tappen_bal_amnt,0)) >= 0  then  --Mod 7055 added + nvl(w_tappen_bal_amnt,0) --Chng 7055 from w_bnk_taphld_bal_amnt to w_taphld_bal_amnt
         w_label := 'e249';
         debug(w_procedure_name,w_label,' <6><><><> w_ptbm.total_due_amnt  ' || w_ptbm.total_due_amnt);
         debug(w_procedure_name,w_label,' <6><><><> w_taphld_bal_amnt      ' || w_taphld_bal_amnt);
         debug(w_procedure_name,w_label,' <6><><><> w_tappen_bal_amnt      ' || w_tappen_bal_amnt);
         w_ptbm.total_due_amnt := nvl(w_ptbm.total_due_amnt,0) - ( nvl(w_taphld_bal_amnt,0) + nvl(w_tappen_bal_amnt,0) ) ; --Mod 7055 added + nvl(w_tappen_bal_amnt,0)  Chng 7055 from w_bnk_taphld_bal_amnt to w_taphld_bal_amnt
         debug(w_procedure_name,w_label,' <6><><><> w_ptbm.total_due_amnt      ' || w_ptbm.total_due_amnt);
      end if;
      --End Add 6230A
    end if;
    --Start Add 7164D
    if  nvl(w_amnt_disp_post_TAP,0) > 0 then --If the TAP portion of the debt is under disputes. We wont ask payments towards TAPHLD/PEN Arrears
    --Start Add 7790
          w_ptbm.tap_pym_2_arrs := 0;
    --End Add 7790
    end if;
    --End Add 7164D
   --Start Add 7055A
   if nvl(w_ptbm.tap_pym_2_arrs,0) != 0 then
       debug(w_procedure_name,w_label,' <6.1><><><> Before w_ptbm.total_due_amnt      ' || w_ptbm.total_due_amnt);
       debug(w_procedure_name,w_label,' <6.1><><><> Before w_ptbm.tap_pym_2_arrs      ' || w_ptbm.tap_pym_2_arrs);
      w_ptbm.total_due_amnt := nvl(w_ptbm.total_due_amnt,0) + nvl(w_ptbm.tap_pym_2_arrs,0);
       debug(w_procedure_name,w_label,' <6.1><><><> After w_ptbm.total_due_amnt      ' || w_ptbm.total_due_amnt);
   end if;
   --End Add 7055A
    debug(w_procedure_name,w_label,' <6..5><><><> w_ptbm.tap_pym_2_arrs      ' || w_ptbm.tap_pym_2_arrs);
    debug(w_procedure_name,w_label,' <6..5><><><> w_ptbm.total_due_amnt      ' || w_ptbm.total_due_amnt);
    debug(w_procedure_name,w_label,' <6..5><><><> w_ptbm.total_bal           ' || w_ptbm.total_bal);
    debug(w_procedure_name,w_label,' <6..5><><><> w_taphld_bal_amnt          ' || w_taphld_bal_amnt);
    debug(w_procedure_name,w_label,' <6..5><><><> w_tappen_bal_amnt          ' || w_tappen_bal_amnt);
    debug(w_procedure_name,w_label,' <6..5><><><> w_ptbm.agr_bal_amnt        ' || w_ptbm.agr_bal_amnt);
    debug(w_procedure_name,w_label,' <6..5><><><> w_ptbm.subtot_curr_chgs    ' || w_ptbm.subtot_curr_chgs);
    debug(w_procedure_name,w_label,' <6..5><><><> w_ptbm.late_pmt_penalty    ' || w_ptbm.late_pmt_penalty);
    debug(w_procedure_name,w_label,' <6..5><><><> w_ptbm.lien                ' || w_ptbm.lien);
    debug(w_procedure_name,w_label,' <6..5><><><> w_ptbm.bank_return_item    ' || w_ptbm.bank_return_item);
    debug(w_procedure_name,w_label,' <6..5><><><> w_ptbm.meter_test_charge   ' || w_ptbm.meter_test_charge);
    debug(w_procedure_name,w_label,' <6..5><><><> w_ptbm.sewer_credit        ' || w_ptbm.sewer_credit);
    --debug(w_procedure_name,w_label,' <6..5><><><> w_ptbm.amnt_in_disp      ' || w_ptbm.amnt_in_disp); --Del 7164C
    debug_trace(w_procedure_name,'<2.001><><><> w_ptbm.amnt_in_disp   --> ' || w_ptbm.amnt_in_disp);
    debug_trace(w_procedure_name,'<2.001><><><> w_amnt_disp_n_agr     --> ' || w_amnt_disp_n_agr);
    debug_trace(w_procedure_name,'<2.001><><><> w_amnt_disp_pre_TAP   --> ' || w_amnt_disp_pre_TAP);
    debug_trace(w_procedure_name,'<2.001><><><> w_amnt_disp_post_TAP --> ' || w_amnt_disp_post_TAP);
    if (w_ptbm.tap_chg is not null or w_ptbm.tap_pym_2_arrs is not null) and w_pay_profile_code_orig = 'TAP-STD' then  --Chngd 7769
	    debug(w_procedure_name,w_label,' Bfr PRV TAP UNPAID BL <6..007><><><> w_ptbm.total_due_amnt ' || w_ptbm.total_due_amnt);
	    debug(w_procedure_name,w_label,' Bfr <6..007><><><> w_ptbm.previous_balance_amnt            ' || w_ptbm.previous_balance_amnt);
	    debug(w_procedure_name,w_label,' Bfr <6..007><><><> w_ptbm.adjust                        ' || w_ptbm.adjust);
	    debug(w_procedure_name,w_label,' Bfr <6..007><><><> w_ptbm.last_paid_amnt                ' || w_ptbm.last_paid_amnt);
	    debug(w_procedure_name,w_label,' Bfr <6..007><><><> w_taphld_bal_amnt                    ' || w_taphld_bal_amnt);
	    debug(w_procedure_name,w_label,' Bfr <6..007><><><> w_tappen_bal_amnt                    ' || w_tappen_bal_amnt);
	    debug(w_procedure_name,w_label,' Bfr <6..007><><><> w_ptbm.agr_bal_amnt                  ' || w_ptbm.agr_bal_amnt);
	    debug(w_procedure_name,w_label,' Bfr <6..007> w_ptbm.amnt_in_disp                        ' || w_ptbm.amnt_in_disp);
	    debug(w_procedure_name,w_label,' Bfr <6..007> w_amnt_disp_n_agr                          ' || w_amnt_disp_n_agr);
	    debug(w_procedure_name,w_label,' Bfr <6..007> w_amnt_disp_pre_TAP                        ' || w_amnt_disp_pre_TAP);
	    debug(w_procedure_name,w_label,' Bfr <6..007> w_amnt_disp_post_TAP                       ' || w_amnt_disp_post_TAP);
	     /* Best way to get the UNPAID TAP PREVIOUS BALANCE */
	     --Start Add 7164A
	    w_ptbm.tap_prv_unpaid_bl := nvl(w_ptbm.previous_balance_amnt,0)
	                              + nvl(w_ptbm.adjust,0)
	                              + nvl(w_ptbm.last_paid_amnt,0)  --[Payments always stored as -ve] Its taken before repair charge (Agency Receivables) payments are added to it.
	                              - nvl(w_taphld_bal_amnt,0)
	                              - nvl(w_tappen_bal_amnt,0)
	                              - nvl(w_ptbm.agr_bal_amnt,0)
	                              - nvl(w_ptbm.amnt_in_disp,0);   --Add 7164D remove the dispute from previous unpaid TAP balance.
	    debug(w_procedure_name,w_label,' Bfr DISPUTE is removed <6..007><><><> w_ptbm.tap_prv_unpaid_bl ' || w_ptbm.tap_prv_unpaid_bl);
	    --End Add 7164A
	    --Start Del 7164A
	    --w_ptbm.tap_prv_unpaid_bl := nvl(w_ptbm.total_bal,0)
	    --                          - nvl(w_taphld_bal_amnt,0)
	    --                          - nvl(w_tappen_bal_amnt,0)
	    --                          - nvl(w_ptbm.agr_bal_amnt,0)
	    --                          - nvl(w_ptbm.subtot_curr_chgs,0)
	    --                          /*- nvl(w_ptbm.late_pmt_penalty,0) */ --Del 7281
	    --                          /*- nvl(w_ptbm.lien,0)                */ --Del 7281
	    --                          /*- nvl(w_ptbm.bank_return_item,0) */ --Del 7281
	    --                          /*- nvl(w_ptbm.meter_test_charge,0)*/ --Del 7281
	    --                          /*- nvl(w_ptbm.sewer_credit,0)     */ --Del 7281
	    --                          ;
	    --
	    --
	    --                            --+ nvl(w_ptbm.sewer_credit,0)  --Lets see how the credit will feature in this
	    --                          --+ nvl(w_ptbm.wrbcccred,0);    --Lets see how the credit will feature in this
	    --
	    --End Del 7164A
	    --Start Add 7164C
	    if w_ptbm.tap_prv_unpaid_bl <= 0 then
	       w_ptbm.tap_prv_unpaid_bl := 0;
	    end if;
	    --End Add 7164C
	    --Start Del 9792
	    --Start Add 7164D  --Not Needed at the moment here.
	    --if nvl(w_amnt_disp_post_TAP,0) > 0 then --If TAP bills are in disput than all subsequent TAP bills are in disput. There wont be any unpaid balance
	    --    w_ptbm.tap_prv_unpaid_bl := 0; --If post TAP is disputed then all subsequent TAP bills are disputed. There wont be any unpaid balance
	    --end if;
	    --Start End 7164D
	    --End Del 9792
	    debug(w_procedure_name,w_label,' After DISPUTE amt is removed <6..007><><><> w_ppln_type      ' || w_ppln_type);
	    debug(w_procedure_name,w_label,' Just Afr DISPUTE amt is removed <6..007><><><> w_ptbm.tap_prv_unpaid_bl  = ' || w_ptbm.tap_prv_unpaid_bl);
      if w_ppln_type is not null and w_ppln_type != 'I' then
         w_ptbm.total_due_amnt := w_ptbm.total_due_amnt + w_ptbm.tap_prv_unpaid_bl;
             -- Start Add 7164D --If the payment is in TAP or Any Agreement. Please PAY portion wont be in DISPUT.
         -- Start Add 7164C
         -- Start Add 7164B remove disputes from Please pay --This should be only for Payment Agreements
         ---We assume IF TAP or Normal Agreement Bills, if are in disputes
         ---Transaction covering by agreement wont be in dispute
         /*
         if nvl(w_ptbm.tap_prv_unpaid_bl,0) <= 0 then
            w_ptbm.total_due_amnt := w_ptbm.total_due_amnt - nvl(w_ptbm.amnt_in_disp,0);
                debug(w_procedure_name,w_label,' In IF Condition PLAN verification <6..007><><><> w_ptbm.total_due_amnt      ' || w_ptbm.total_due_amnt);
         end if;
         */
         -- End Add 7164B remove disputes from Please pay
         -- End Add 7164C again reopend 7164D
             -- End Add 7164D --If the payment is in TAP or Any Agreement. Please PAY portion wont be in DISPUT.
      end if;
      debug(w_procedure_name,w_label,' OutSide IF Condition PLAN verification <6..007><><><> w_ptbm.total_due_amnt      ' || w_ptbm.total_due_amnt);
    end if;
    --Start Del 9792
    --Start Add 7164D  --Not Needed at the moment here.
    --if nvl(w_amnt_disp_post_TAP,0) > 0 then --If TAP bills are in disput than all TAP bills are in disput and rest of the debt is under TAPHLD/PLN DCR
    --    w_ptbm.tap_prv_unpaid_bl := 0; --If post TAP is disputed then all subsequent TAP bills are disputed
    --end if;
    --Start End 7164D
    --End Del 9792
    debug(w_procedure_name,w_label,' <6..009><><><> w_ptbm.tap_prv_unpaid_bl        ' || w_ptbm.tap_prv_unpaid_bl);
    --Start Add 6721
    /*
    if (w_ptbm.tap_chg is not null or w_ptbm.tap_pym_2_arrs is not null) then
          if w_ptbm.tap_chg is not null and nvl(w_ptbm.tap_tot_chg_amnt,0) -  nvl(w_ptbm.tap_chg,0) > 0 then
            if (nvl(w_ptbm.total_due_amnt,0) - nvl(w_ptbm.tap_chg,0)) !=0  then
                w_ptbm.tap_prv_unpaid_bl := nvl(w_ptbm.total_due_amnt,0) - nvl(w_ptbm.tap_chg,0);
            end if;
          elsif w_ptbm.tap_pym_2_arrs is not null
             and (   nvl(w_ptbm.total_due_amnt,0)
                  -  nvl(w_ptbm.tap_pym_2_arrs,0)   --Remove +ve on cost
                  -  nvl(w_ptbm.subtot_curr_chgs,0) --Remove current charge
                 ) != 0 then                         --see if its != 0 then
             --Remove current charge from the previous TAP balance because there is not
             --select sum(tran_bal_amnt * acct_sign) from cis.cis_transactions
             --where cust_id     = w_cust_id
             --  and inst_id     = w_inst_id
             --  and supply_type = 'WATER'
             --  and ppln_id is null
             --  and disput_code is null
             --  and debt_coll_id1 is null
             --  and bill_key = w_bill_key;
             --  and tran_id < w_tran_id;  --'B0562828054'
             --w_ptbm.tap_prv_unpaid_bl := nvl(w_ptbm.total_due_amnt,0)
             --                          - nvl(w_ptbm.subtot_curr_chgs,0)
             --                          - nvl(w_ptbm.tap_pym_2_arrs,0)
             --                                     - nvl(w_ptbm.pymtagree,0)
         --                          - nvl(w_ptbm.late_pmt_penalty,0)              --Add 6230B --We need to add Liens and [Susan/James/Claire/Shaneeka..etc meeting on TAP bill review 06/08/2017@2:00 to 3:00]
         --                          + nvl(w_ptbm.lien,0);
             --null;
         end if;
          debug(w_procedure_name,w_label,' <6.5><><><> w_ptbm.tap_prv_unpaid_bl ' || w_ptbm.tap_prv_unpaid_bl);
          debug(w_procedure_name,w_label,' <6.5><><><> w_ptbm.total_due_amnt    ' || w_ptbm.total_due_amnt);
    end if;
     */
    --End Add 6721
    /*End 7055B */
    /* Start Adding 4398 for Agency Closing cost  */
    if not(donot_print_rc) then --Add 5905 3.0.0.39
       w_label := 'e250';
       debug(w_procedure_name,w_label,' Bfr <9><><><> w_ptbm.total_due_amnt      ' || w_ptbm.total_due_amnt);
       debug(w_procedure_name,w_label,' <9><><><> w_ptbm.total_due_amnt          ' || w_ptbm.agrv_rc_st_closing_bal_amnt);
       w_ptbm.last_paid_amnt   := nvl(w_ptbm.last_paid_amnt,0) + nvl(w_rchl.agrv_rc_cur_pymnt_amnt,0);
       w_ptbm.tot_pays_adjs    := nvl(w_ptbm.tot_pays_adjs,0) +  nvl(w_rchl.agrv_rc_cur_pymnt_amnt,0);     --Are we using it anywhere? Moved as it was Del 6351 changed from w_rchl.agrv_rc_cur_pymnt_amnt  to w_rchl.agrv_rc_cur_adj_amnt
       --w_ptbm.adjust             := nvl(w_ptbm.adjust,0) +  nvl(w_rchl.agrv_rc_cur_adj_amnt,0);          --Kept as it was before Add 6351 Better to have on adjust then on tot_pays_adjs.
       w_ptbm.subtot_curr_chgs := nvl(w_ptbm.subtot_curr_chgs,0) + nvl(w_agr_curr_chgs,0);
       --Start Add 8020
       g_wtr_total_bal					:= nvl(w_ptbm.total_bal,0);
       g_wtr_total_due_amnt    := nvl(w_ptbm.total_due_amnt,0);
       --End Add 8020
       w_ptbm.total_bal        := nvl(w_ptbm.total_bal,0) + nvl(w_ptbm.agrv_rc_st_closing_bal_amnt,0);
       w_ptbm.total_due_amnt   := nvl(w_ptbm.total_due_amnt,0) + nvl(w_ptbm.agrv_rc_st_closing_bal_amnt,0);
       debug(w_procedure_name,w_label,' Aftr <9><><><> w_ptbm.total_due_amnt      ' || w_ptbm.total_due_amnt);
    end if; --Add 5905 3.0.0.39
    /*Start Add 6230B */
    suppress_future_pnlty;
    /*ENd Add 6230B */
    w_ptbm.penalty_due_amnt := nvl(w_ptbm.total_due_amnt,0) + nvl(w_ptbm.penalty_amnt,0);
    if nvl(w_ptbm.penalty_due_amnt,0) <= 0 then
       w_ptbm.penalty_due_amnt := 0;
       w_ptbm.penalty_amnt     := 0;
    end if;
    if w_ptbm.total_due_amnt <= 0 then
       w_ptbm.total_due_amnt   := 0;
       w_ptbm.penalty_due_amnt := 0; --Add 4398
       w_ptbm.penalty_amnt     := 0; --Add 4398
    end if;
    /* End of Adding 4398 for Agency Closing cost*/
    debug_trace(w_procedure_name,'<10><><><> w_ptbm.penalty_amnt   --> ' || w_ptbm.penalty_amnt);
    debug_trace(w_procedure_name,'<10><><><> w_ptbm.total_due_amnt --> ' || w_ptbm.total_due_amnt);
    --## Start Del 4398 Changed by Lisa Cooley Del 2825 start
    --## Remove redundant code - Do not change penalty date here.
    --## Penalties records are now created when bill is printed
    --## (instead of when bill is calculated) so the records are created
    --## with the calc_penalty_date based on bill print date.
    --## Del 2825 --
    --## Del 2825 -- If bill print date is other than bill date.
    --## Del 2825 -- Update penalty
    --## Del 2825 --
    --## Del 2825 if trunc(w_ptbm.incl_payments_date) != trunc(w_ptbm.billing_date) then
    --## Del 2825  update phl_penalties_recs                                  -- Add 2.0.0.29 -- 2333
    --## Del 2825     set calc_penalty_date = w_ptbm.penalty_date             -- Add 2.0.0.29 -- 2333
    --## Del 2825        ,last_updated_by   = ciss0034.last_updated_by        -- Add 2.0.0.29 -- 2333
    --## Del 2825        ,last_update_date  = ciss0034.last_update_date       -- Add 2.0.0.29 -- 2333
    --## Del 2825        ,last_update_login = ciss0034.last_update_login      -- Add 2.0.0.29 -- 2333
    --## Del 2825  where  cust_id      = w_cust_id                            -- Add 2.0.0.29 -- 2333
    --## Del 2825    and  inst_id      = w_inst_id                            -- Add 2.0.0.29 -- 2333
    --## Del 2825    and  tran_id      = w_tran_id                            -- Add 2.0.0.29 -- 2333
    --## Del 2825    and process_id is null;
    --## Del 2825 end if;
    --## End Del 4398 Lisa Cooley Del 2825 end
    -- Set the messages                             -- Add 2.0.0.10
    w_label := 'e251';
    select   -- max(substr(mtr.meter_key, 1, 7))       -- Chg 1.0.0.07   -- Del 1129
            max(mrg.estimates_cnt)                     -- Add 542        -- Chg 1129
          , min(inc.incid_code)
      into
            -- w_ptbm.meter_key                                          -- Del 1129
            w_estimates_cnt                            -- Add 542        -- Chg 1129
          , w_incid_code
      from cis_meters mtr
          , cis_incidents inc
          , cis_meter_types mtp                        -- Add 542
          , cis_meter_regs mrg                         -- Add 542
     where mtr.inst_id = w_inst_id
       and inc.meter_id(+) = mtr.meter_id
       and inc.incid_owner_type(+) = 'M'
       and inc.incid_code(+) = w_shutoff_code
       and mtr.meter_type_code = mtp.meter_type_code   -- Add 542
       and mtp.notional_ind = 'N'                      -- Add 542
       and mtr.meter_id = mrg.meter_id                 -- Add 542
       and mrg.reg_inuse_ind = 'Y';                    -- Add 542
    w_label := 'e252';
    select decode(w_ppln_type,null,null,decode(w_ppln_type,'I',w_ptbm.wrbccpmt,w_ptbm.total_due_amnt))
           into w_ppln_due_amnt from dual;
    w_mesg_date := w_ptbm.billing_date;
    --Add 2477 Check the code in Packge phls0005
   --Start Add 2775
   -- If Payment breached is checked by comparing the plan payment details
   -- before billing date
   if w_ppln_id is not null then
            -- PJT Comment 3093
            -- These numbers have already been setup above. SO do not overwrite here
            -- Start Del 3093
               /*
    w_ppln_due_amnt := null;
    for r1 in (
        select  paym_due_date, paym_amnt, paym_bal_amnt
        from  cis_ppln_payments
                        where ppln_id = w_ppln_id
          and paym_due_date <= w_ptbm.billing_date
          and paym_bal_amnt > 0
        order by paym_due_date desc
         )
    loop
     w_ppln_due_amnt := nvl(w_ppln_due_amnt,0) + nvl(r1.paym_amnt,0);
     w_ppln_no_due   := nvl(w_ppln_no_due,0)  + 1;
    end loop;
    */
    -- End Del 3093
      if w_ppln_type != 'I' then
         w_msg_shutoff_date := w_ptbm.penalty_date;                                     -- Add 3097
         -- w_msg_shutoff_date := next_valid_due_date(w_ptbm.billing_date + 22);        -- Del 3097 --Add 2775b
         ---- Add 5 Business days                --Del 2775b
         --for i in 1 .. 5                   --Del 2775b
         --loop                      --Del 2775b
         -- w_msg_shutoff_date := next_valid_due_date(w_msg_shutoff_date + 1); --Del 2775b
         --end loop;                     --Del 2775b
      elsif w_ppln_type = 'I' then
         null;
         w_msg_shutoff_date := null;
         --Del Start 2775 --Not need per comment 63910
         ----Start Add 2514
         --begin
         --  select to_date(field4,'mm/dd/yyyy'),field2 into w_msg_shutoff_date,w_event_id
         --  from cis_events evnt
         --  where  evnt.cust_id    = w_cust_id
         --     and  evnt.inst_id    = w_inst_id
         --    and  evnt.field3     = 1
         --    and  evnt.field2 is not null
         --  and  evnt.event_type = 'WRAPBRCH'
         --    and  evnt.event_id   = field2;
         --
         --  update cis_events evnt
         --     set field5 = field2
         --        , field2 = null
         --   where evnt.event_id   = w_event_id
         --  and  evnt.event_type = 'WRAPBRCH';
         --
         --exception
         -- when others then
         --  w_msg_shutoff_date := null;
         --end;
         ----End Add 2514
         --Del End 2775 --Not need per comment 63910
      end if;
   end if;
   --End Add 2775
   --Add 2775 Additional Changes are in Packge phls0005
   -- Begin Add 2730
     w_label     := 'e253';
     w_nb_code   := null;                       --Add 2903 Moved from below
     w_svc_code  := null;                       --Add 2903
   -- Get the NB code of the installation       --Add 2903 Moved from below
   select  ins.revu1_code                       --Add 2903 Moved from below
          ,substr(ins.attribute29,1,1)          --Add 2903
     into w_nb_code                             --Add 2903 Moved from below
          ,w_svc_code                           --Add 2903
   from cis_installations ins                   --Add 2903 Moved from below
   where ins.inst_id = w_inst_id;               --Add 2903 Moved from below
   --w_sw_chg_fr_dt := null;                    --Del 3659
   --w_sw_chg_to_dt := null;                    --Del 3659
   --w_nb_code   := null;                       --Del 2903 Moved UP
   w_label := 'e254';
     debug(w_procedure_name,w_label,' ..{{|}}.. w_inst_id    ' || w_inst_id);    --Add 2903
     debug(w_procedure_name,w_label,' ..{{|}}.. w_svc_code      ' || w_svc_code);   --Add 2903
     debug(w_procedure_name,w_label,' ..{{|}}.. w_tran_id      ' || w_tran_id);   --Add Claire for 2903
   -- Get the period from and to date of stormwater charge
   -- if w_svc_code = '1' or w_svc_code = '3'   -- Del 2908 -- Add 2903
   -- or w_svc_code = '4'or w_svc_code = '5' then  -- Del 2908 -- Add 2903
   if w_svc_code = '3' then                  -- Add 2908
     select  min(dbl.period_from_date), max(dbl.period_upto_date) --Add 2640 -2.0.0.69
       into  w_ptbm.sw_chg_fr_dt, w_ptbm.sw_chg_to_dt             --Add 3659
       --into w_sw_chg_fr_dt, w_sw_chg_to_dt                      --Del 3659
       from cis_debit_lines dbl
      where dbl.tran_id = w_tran_id
        and dbl.task_code = 'BILL'
        and dbl.scnd_type = 'AGR' ;
   end if;                                      --Add 2903
   w_label := 'e255';
   -- Get the NB code of the installation       --Del 2903 Moved UP
   -- select  ins.revu1_code                    --Del 2903 Moved UP
   --  into w_nb_code                           --Del 2903 Moved UP
   --  from cis_installations ins               --Del 2903 Moved UP
   -- where ins.inst_id = w_inst_id;            --Del 2903 Moved UP
   -- End Add 2730
   -- Start Add 3327
   -- End Add 3327
   -- Start Add 3706
     debug(w_procedure_name,w_label,' ..w_grnt_rcvd         ' || w_grnt_rcvd);         --Add 3706
     debug(w_procedure_name,w_label,' ..w_debt_bal_amnt_ues ' || w_debt_bal_amnt_ues); --Add 3706
     --debug(w_procedure_name,w_label,' ..w_grnt_rcvd      ' || w_grnt_rcvd);   --Add 3706
     --debug(w_procedure_name,w_label,' ..w_grnt_rcvd      ' || w_grnt_rcvd);   --Add 3706
     if nvl(w_ptbm.debt_bal_amnt_ues,0) = 0 and nvl(w_grnt_rcvd,0) <> 0 then
        w_grnt_rcvd                 := w_debt_tot_amnt_ues;
        w_debt_bal_amnt_ues         := null;
     elsif nvl(w_ptbm.debt_bal_amnt_ues,0) <> 0 then
        w_grnt_rcvd                 := null;
        w_debt_bal_amnt_ues         := w_ptbm.debt_bal_amnt_ues; --w_debt_tot_amnt_ues;  --Del
     end if;
     --End Add 3706
    --Add 2477 Check the code in Packge phls0005
    if not(donot_print_rc) then --Add 5905 3.0.0.39
       w_ptbm.un_paid_prv_bal :=   nvl(w_ptbm.previous_balance_amnt,0)
                                 + nvl(w_ptbm.last_paid_amnt,0)                --Modified now it's total paid amount for  RC + WATER
                                 + nvl(w_ptbm.adjust,0)                        --Add 3706
                                 --+ nvl(w_rchl.agrv_rc_unpaid_amnt,0);        --Add 4398 --Not needed because last_paid_amnt has both water and agency
                                 + nvl(w_rchl.agrv_rc_st_opening_bal_amnt,0)   --Add 4398
                                 --+ nvl(w_rchl.agrv_rc_cur_pymnt_amnt,0)      --Add 4398 Payment Already added to last_paid_amnt
                                 + nvl(w_rchl.agrv_rc_cur_adj_amnt,0)          --Moved it as it was before 6351 Add Agency Current Adj to w_ptbm.adjust --
                                 ;
    else   --Start Add 5905 3.0.0.39
       w_ptbm.un_paid_prv_bal :=   nvl(w_ptbm.previous_balance_amnt,0)
                                 + nvl(w_ptbm.last_paid_amnt,0)
                                 + nvl(w_ptbm.adjust,0)
                                 ;
    end if;--End Add 5905 3.0.0.39
    debug(w_procedure_name,w_label,' w_ptbm.un_paid_prv_bal '|| w_ptbm.un_paid_prv_bal);
    --Start Add 4398
    -- Add Agency Receivables (Repair Charge) Closing Balance to w_ptbm.total_due_amnt
    -- Add Agency Receivables (Repair Charge) Closing Balance to w_ptbm.total_due_amnt
    --
    --End Add 4398
    --Start Add 6495
     w_ptbm.debt_bal_amnt_bnk  := nvl(w_ptbm.debt_bal_amnt_bnk,0) - nvl(w_bnk_dischrd_bal_amnt,0); --Remove the amount from Discharge bucket and if the balances fall below zero dont show the message.
    --End Add 6495
    --Start Add 7762
		select max('Y') into l_ss_fee_mssg
		  from dual
		where exists (
  	select 'X'
  	from cis.cis_debt_collection
  	where instr(w_SS_Fee_Valid_Path,debt_coll_path) <> 0
  	  and instr(w_SS_Fee_Valid_Stage,debt_coll_stage) <> 0
  	  and cust_id     = w_cust_id
  	  and inst_id     = w_inst_id
  	  and supply_type = w_supply_type
  	);
    if nvl(l_ss_fee_mssg,'X') = 'Y' then
      l_ss_fee_mssg := 'N';
			select decode(sign(sum(tran_bal_amnt)),0,'N',-1,'N','Y') into l_ss_fee_mssg
			  from cis.cis_transactions
			 where cust_id 		 = w_cust_id
  	     and inst_id 		 = w_inst_id
  	     and supply_type = w_supply_type
  	     and task_code   = 'SHWOFEE'
  	  ;
    end if;
    --End Add 7762
   w_label := 'e256';
	 debug(w_procedure_name,w_label,' l_ss_fee_mssg '|| l_ss_fee_mssg);
	 --Start 8020F moved before bill message otherwise eBill Auto Pay messages will be incorrect
	 begin
			phls0250.init;
			phls0250.get_ebill_inds(p_acct_key=>w_ptbm.acct_key);
			begin
				select decode(instr(phls0250.get_ebill_ind,'YES'),0,'N','Y') into w_ptbm.ebill_ind from dual;
			exception
				when no_data_found then
					 w_ptbm.ebill_ind := NULL;
			end;
			begin
				--g_auto_pay_4all_acs 			:= null;
				--w_ptbm.ebill_auto_pay_ind	:= null;
			  select trim(substr(phls0250.get_auto_pay_ind,1,15))
			    into
			    		 --g_auto_pay_4all_acs  --Del 8020F
			    		 w_ptbm.ebill_auto_pay_str
			    from dual; --Passed to message routime phls0005
				select decode(instr(phls0250.get_auto_pay_ind,'YES'),0,'N','Y') into w_ptbm.ebill_auto_pay_ind from dual; --Passed to Bill file
				--Start Add 9918
				debug(w_procedure_name,w_label,' w_ptbm.ebill_auto_pay_ind '|| w_ptbm.ebill_auto_pay_ind);
				debug(w_procedure_name,w_label,' w_ptbm.acct_key 				   '|| w_ptbm.acct_key);
				debug(w_procedure_name,w_label,' w_rchl.agrv_hl_acct_key   '|| w_rchl.agrv_hl_acct_key);
				debug(w_procedure_name,w_label,' w_rchl.agrv_rc_acct_key   '|| w_rchl.agrv_rc_acct_key);
				debug(w_procedure_name,w_label,' g_kub_task_cd_str 			   '|| g_kub_task_cd_str);
				debug(w_procedure_name,w_label,' g_kub_2char_task_cd 		   '|| g_kub_2char_task_cd);
				if w_ptbm.ebill_auto_pay_ind = 'Y' then
   				w_label := 'e257';
					select sum(decode(auto_pay_ind,'A',1,0)) into g_is_wtr_auto_auto
					from cis.phl_stgin_kubra_hist
					where seq_no
					in
					(
					select max(seq_no)
					  from cis.phl_stgin_kubra_hist
					 where acct_key  = w_ptbm.acct_key
					   and prime_ind = 'Y'
					   and status    = 'PROCESSED'
					);
					select sum(decode(auto_pay_ind,'A',1,0)) into g_is_agn_auto_auto
					from cis.phl_stgin_kubra_hist
					where seq_no
					in
					(
					select max(seq_no)
					  from cis.phl_stgin_kubra_hist
					 where acct_key  = w_rchl.agrv_rc_acct_key
					   and prime_ind = 'Y'
					   and status    = 'PROCESSED'
					);
					select sum(decode(auto_pay_ind,'A',1,0)) into g_is_hlp_auto_auto
					from cis.phl_stgin_kubra_hist
					where seq_no
					in
					(
					select max(seq_no)
					  from cis.phl_stgin_kubra_hist
					 where acct_key = w_rchl.agrv_hl_acct_key
					   and prime_ind = 'Y'
					   and status    = 'PROCESSED'
					);
					if nvl(g_is_wtr_auto_auto,0) > 0 or
					   nvl(g_is_agn_auto_auto,0) > 0 or
					   nvl(g_is_hlp_auto_auto,0) > 0 then -- Its auto auto
	           l_lst_five_pndpymts := 0;
	           l_lst_pnd_pymnt_dt  := null;
						 for lc_kpp in gc_kub_pndg_pymnt
						 loop
	   					  w_label := 'e258';
							  if gc_kub_pndg_pymnt%rowcount=1 then l_lst_pnd_pymnt_dt := lc_kpp.creation_date; end if;
							 	l_lst_five_pndpymts := l_lst_five_pndpymts + 1;
						   	l_pymnt_posted := 0;
						   	l_kub_sup_ty   := 'XXXX';
						   	if lc_kpp.acct_key = w_ptbm.acct_key         and nvl(g_is_wtr_auto_auto,0) > 0 then l_kub_sup_ty := 'WATER';    end if;
						   	if lc_kpp.acct_key = w_rchl.agrv_rc_acct_key and nvl(g_is_agn_auto_auto,0) > 0 then l_kub_sup_ty := 'AGENCY';   end if;
						   	if lc_kpp.acct_key = w_rchl.agrv_hl_acct_key and nvl(g_is_hlp_auto_auto,0) > 0 then l_kub_sup_ty := 'HELPLOAN'; end if;
							 	debug(w_procedure_name,w_label,' l_kub_sup_ty    		'|| l_kub_sup_ty);
							 	debug(w_procedure_name,w_label,' g_kub_task_cd_str  '|| g_kub_task_cd_str);
							 	/*	--Add 9918C
							 	select count(*) into l_pymnt_posted
							  from cis_transactions
							  where cust_id       = w_cust_id
							    and inst_id       = w_inst_id
							    and supply_type   = l_kub_sup_ty
							    and tran_date     = lc_kpp.creation_date --Confirmed by Steve
							    and tran_tot_amnt = lc_kpp.amnt
							    and instr(g_kub_task_cd_str,task_code) <> 0;
								*/  --Add 9918C
	   					 	w_label := 'e259';
							 	debug(w_procedure_name,w_label,' 1 --> l_pymnt_posted    		'|| l_pymnt_posted);
		            /* --Comment this code its causing the issue */  --Add 9918C
		            /*
		           	if l_pymnt_posted = 0 then
							 		debug(w_procedure_name,w_label,' w_cust_id   								'|| w_cust_id);
							 		debug(w_procedure_name,w_label,' w_inst_id   								'|| w_inst_id);
							 		debug(w_procedure_name,w_label,' datec(lc_kpp.creation_date) '|| datec(lc_kpp.creation_date));
							 		debug(w_procedure_name,w_label,' g_kub_2char_task_cd   		  '|| g_kub_2char_task_cd);
							 		debug(w_procedure_name,w_label,' lc_kpp.amnt   		  		    '|| lc_kpp.amnt);
									begin
								 		select count(*) into l_pymnt_posted
								 		  from cis_transactions
								 		 where cust_id    = w_cust_id
								 		   and inst_id    = w_inst_id
								 		    --and sypply_tpe = l_kub_sup_ty
								 		   and tran_date  = lc_kpp.creation_date --Confirmed by Steve
								 		   and task_code  = 'BLKRECPT'
								 		   and instr(g_kub_2char_task_cd,substr(user_reference,1,2)) <> 0
								 		group by cust_id, inst_id, tran_date,task_code,user_reference
								 		having sum(tran_tot_amnt) =  lc_kpp.amnt;
							 		exception
							 		  when no_data_found then
							 		    l_pymnt_posted := 0;
							 		end;
								end if;
								*/
		            /* --Comment this code its causing the issue */  --Add 9918C
							 	debug(w_procedure_name,w_label,' 2 --> l_pymnt_posted    		'|| l_pymnt_posted);
								if l_pymnt_posted = 0 then
								   w_label := 'e260';
								   if l_kub_sup_ty = 'WATER' and nvl(g_is_wtr_auto_auto,0) > 0 then
							   	 		w_ptbm.next_wtr_auto_pay_amnt := nvl(w_ptbm.next_wtr_auto_pay_amnt,0) + nvl(lc_kpp.amnt,0);
							   	 		if w_ptbm.next_wtr_auto_pay_amnt = 0 then w_ptbm.next_wtr_auto_pay_amnt := null; end if;
							   	 elsif 	l_kub_sup_ty = 'AGENCY' and nvl(g_is_agn_auto_auto,0) > 0 then
							   	 		w_ptbm.next_agn_auto_pay_amnt := nvl(w_ptbm.next_agn_auto_pay_amnt,0) + nvl(lc_kpp.amnt,0);
							   	 		if w_ptbm.next_agn_auto_pay_amnt = 0 then w_ptbm.next_agn_auto_pay_amnt := null; end if;
							   	 elsif 	l_kub_sup_ty = 'HELPLOAN' and nvl(g_is_hlp_auto_auto,0) > 0  then
							   	 		w_ptbm.next_hlp_auto_pay_amnt := nvl(w_ptbm.next_hlp_auto_pay_amnt,0) + nvl(lc_kpp.amnt,0);
							   	 		if w_ptbm.next_hlp_auto_pay_amnt = 0 then w_ptbm.next_hlp_auto_pay_amnt := null; end if;
							   	 end if;
								end if;
					  		debug(w_procedure_name,w_label,' Number of payments '|| l_lst_five_pndpymts);
					  		debug(w_procedure_name,w_label,' w_ptbm.next_wtr_auto_pay_amnt '|| w_ptbm.next_wtr_auto_pay_amnt);
								--if l_lst_five_pndpymts >= 5 then
								--   exit;
								--end if;
			  			  debug(w_procedure_name,w_label,' Store dates in PLSQL Table');
					  	  if l_kub_sup_ty = 'WATER' then
						   		 w_label := 'e261';
					  	     g_wtr_cnt := g_wtr_cnt + 1;
					  	 		 g_pn_py_cr_dt_wtr_tbl(g_wtr_cnt).creation_date := lc_kpp.creation_date;
			  					 debug(w_procedure_name,w_label,' g_pn_py_cr_dt_wtr_tbl(g_wtr_cnt).creation_date--> '|| datec(g_pn_py_cr_dt_wtr_tbl(g_wtr_cnt).creation_date));
			  					 debug(w_procedure_name,w_label,' lc_kpp.creation_date--> '|| lc_kpp.creation_date);
					  	  end if;
					  	  if l_kub_sup_ty = 'AGENCY' then
						   		 w_label := 'e262';
					  	     g_agn_cnt := g_agn_cnt + 1;
					  	 		 g_pn_py_cr_dt_agn_tbl(g_agn_cnt).creation_date	:=  lc_kpp.creation_date;
			  					 debug(w_procedure_name,w_label,' g_pn_py_cr_dt_agn_tbl(g_agn_cnt).creation_date--> '|| datec(g_pn_py_cr_dt_agn_tbl(g_agn_cnt).creation_date));
			  					 debug(w_procedure_name,w_label,' lc_kpp.creation_date--> '|| lc_kpp.creation_date);
					  	  end if;
					  	  if l_kub_sup_ty = 'HELPLOAN' then
						   		 w_label := 'e263';
					  	     g_hlp_cnt := g_hlp_cnt + 1;
					  	 		 g_pn_py_cr_dt_hlp_tbl(g_hlp_cnt).creation_date :=  lc_kpp.creation_date;
			  					 debug(w_procedure_name,w_label,' g_pn_py_cr_dt_hlp_tbl(g_agn_cnt).creation_date--> '|| datec(g_pn_py_cr_dt_hlp_tbl(g_hlp_cnt).creation_date));
			  					 debug(w_procedure_name,w_label,' lc_kpp.creation_date--> '|| lc_kpp.creation_date);
					  	  end if;
						end loop;
					  w_label := 'e264';
					  debug(w_procedure_name,w_label,' WATER :- w_ptbm.next_wtr_auto_pay_amnt    '|| w_ptbm.next_wtr_auto_pay_amnt);
					  debug(w_procedure_name,w_label,' AGENCY :- w_ptbm.next_agn_auto_pay_amnt   '|| w_ptbm.next_agn_auto_pay_amnt);
					  debug(w_procedure_name,w_label,' HELPLOAN :- w_ptbm.next_hlp_auto_pay_amnt '|| w_ptbm.next_hlp_auto_pay_amnt);
					  debug(w_procedure_name,w_label,' g_prev_bill_tran_id                       '|| g_prev_bill_tran_id);
						for r1_Prev_Bill in (select penalty_date,agrv_rc_st_closing_bal_amnt,total_due_amnt,seq_no
						                       from phl_bill_print_hist
						                      where bill_tran_id = g_prev_bill_tran_id
						                      order by seq_no desc
						                    )
						loop
						   w_label := 'e265';
							 g_prev_bill_pnlty_dt := r1_Prev_Bill.penalty_date;
							 --g_prev_bill_wt_bal   := r1_Prev_Bill.total_due_amnt - nvl(r1_Prev_Bill.agrv_rc_st_closing_bal_amnt,0);
							 --g_prev_bill_ag_bal   := r1_Prev_Bill.agrv_rc_st_closing_bal_amnt;
							 --begin
						   --	 w_label := 'e266';
							 --	 select agrv_hl_total_due_amnt into g_prev_bill_hl_bal
							 --	   from phl_agrv_rc_hlpln_st_dtl
							 --	  where seq_no = r1_Prev_Bill.seq_no;
							 --exception
							 --	 when no_data_found then
							 --    g_prev_bill_hl_bal := 0;
							 --end;
							 exit;
						end loop;
					  w_label := 'e267';
					  debug(w_procedure_name,w_label,' --Get the future pending Payments ');
					  --debug(w_procedure_name,w_label,' g_prev_bill_wt_bal   	'|| g_prev_bill_wt_bal);
					  --debug(w_procedure_name,w_label,' g_prev_bill_ag_bal   	'|| g_prev_bill_ag_bal);
					  --debug(w_procedure_name,w_label,' g_prev_bill_hl_bal   	'|| g_prev_bill_hl_bal);
					  debug(w_procedure_name,w_label,' w_ptbm.acct_key      	'|| w_ptbm.acct_key);
					  debug(w_procedure_name,w_label,' w_rchl.agrv_hl_acct_key'|| w_rchl.agrv_hl_acct_key);
					  debug(w_procedure_name,w_label,' w_rchl.agrv_rc_acct_key'|| w_rchl.agrv_rc_acct_key);
					  debug(w_procedure_name,w_label,' g_prev_bill_pnlty_dt 	'|| datec(g_prev_bill_pnlty_dt));
					  debug(w_procedure_name,w_label,' w_ptbm.billing_date  	'|| datec(w_ptbm.billing_date));
						if w_ptbm.acct_key is not null and nvl(g_is_wtr_auto_auto,0) > 0 then
							 for r1_fpp in  (select latestpaymentdate,currautopayamnt,currautopymtdt --Add 9918b
							                   from phl_stgin_kubra_hist
							                  where seq_no = ( select max(seq_no) from phl_stgin_kubra_hist
		                                              where acct_key  = w_ptbm.acct_key
		                                                and prime_ind = 'Y'
		                                                and status    = 'PROCESSED'
		                                           )
		                          )
		           loop
							   w_label := 'e268';
					  		 debug(w_procedure_name,w_label,' --Inside future pending Payments Water');
								 if r1_fpp.currautopymtdt is not null and 															--Chng 9918b
								    r1_fpp.currautopymtdt <= g_prev_bill_pnlty_dt and										--Chng 9918b
								    r1_fpp.currautopymtdt >= nvl(w_ptbm.billing_date,sysdate)						--Chng 9918b
								 then
								    w_label := 'e269';
						  		  debug(w_procedure_name,w_label,' --Inside future pending Payments Water Selected');
						  		  debug(w_procedure_name,w_label,' --g_pn_py_cr_dt_wtr_tbl.count 						 -->' || g_pn_py_cr_dt_wtr_tbl.count);
						  		  debug(w_procedure_name,w_label,' --r1_fpp.currautopymtdt      						 -->' || datec(r1_fpp.currautopymtdt));
										l_fut_py_acctd := false;
										for i in 1..g_pn_py_cr_dt_wtr_tbl.count
										loop
										  l_fut_py_acctd := false;
						  		  	debug(w_procedure_name,w_label,' --g_pn_py_cr_dt_wtr_tbl(i).creation_date      						 -->' || datec(g_pn_py_cr_dt_wtr_tbl(i).creation_date));
											if g_pn_py_cr_dt_wtr_tbl(i).creation_date = r1_fpp.currautopymtdt then  --Chng 9918b
												 l_fut_py_acctd := true;
												 exit;
											end if;
										end loop;
								    w_label := 'e270';
					  		 		debug(w_procedure_name,w_label,' --WATER Future Payment Accounted--'||booleanc(l_fut_py_acctd));
										if not (l_fut_py_acctd) then
						   	 			 --w_ptbm.next_wtr_auto_pay_amnt := nvl(w_ptbm.next_wtr_auto_pay_amnt,0) + nvl(g_prev_bill_wt_bal,0); --Del 9918b
						   	 			   w_ptbm.next_wtr_auto_pay_amnt := nvl(w_ptbm.next_wtr_auto_pay_amnt,0) + nvl(r1_fpp.currautopayamnt,0); --Add 9918b
						   	 		end if;
						   	 		if w_ptbm.next_wtr_auto_pay_amnt = 0 then w_ptbm.next_wtr_auto_pay_amnt := null; end if;
								 end if;
		           end loop;
						end if;
				    w_label := 'e271';
		  		  debug(w_procedure_name,w_label,' --Get future pending Payments Agency');
						if w_rchl.agrv_rc_acct_key is not null and nvl(g_is_agn_auto_auto,0) > 0   then
							 for r1_fpp in  (select latestpaymentdate,currautopayamnt,currautopymtdt --Add 9918b
							                   from phl_stgin_kubra_hist
							                  where seq_no = ( select max(seq_no) from phl_stgin_kubra_hist
		                                              where acct_key = w_rchl.agrv_rc_acct_key
		                                                and status = 'PROCESSED'
		                                                and prime_ind = 'Y'
		                                           )
		                          )
		           loop
							   w_label := 'e272';
					  		 debug(w_procedure_name,w_label,' --Inside future pending Payments Agency');
								 if r1_fpp.currautopymtdt is not null and 															--Add 9918b
								    r1_fpp.currautopymtdt <= g_prev_bill_pnlty_dt and										--Add 9918b
								    r1_fpp.currautopymtdt >= nvl(w_ptbm.billing_date,sysdate)						--Add 9918b
								 then
								    w_label := 'e273';
						  		  debug(w_procedure_name,w_label,' --Inside future pending Payments Agency Selected');
						  		  debug(w_procedure_name,w_label,' --g_pn_py_cr_dt_agn_tbl.count -->' || g_pn_py_cr_dt_agn_tbl.count);
										l_fut_py_acctd := false;
										for i in 1..g_pn_py_cr_dt_agn_tbl.count
										loop
										  l_fut_py_acctd := false;
											if trunc(g_pn_py_cr_dt_agn_tbl(i).creation_date) = trunc(r1_fpp.currautopymtdt) then  --Add 9918b
												 l_fut_py_acctd := true;
												 exit;
											end if;
										end loop;
								    w_label := 'e274';
					  		 		debug(w_procedure_name,w_label,' --AGENCY Future Payment Accounted--'||booleanc(l_fut_py_acctd));
										if not (l_fut_py_acctd) then
							   	 		--w_ptbm.next_agn_auto_pay_amnt := nvl(w_ptbm.next_agn_auto_pay_amnt,0) + nvl(g_prev_bill_ag_bal,0);   --Del 9918b
							   	 		w_ptbm.next_agn_auto_pay_amnt := nvl(w_ptbm.next_agn_auto_pay_amnt,0) + nvl(r1_fpp.currautopayamnt,0); --Add 9918b
							   	 	end if;
						   	 		if w_ptbm.next_agn_auto_pay_amnt = 0 then w_ptbm.next_agn_auto_pay_amnt := null; end if;
								 end if;
							 end loop;
						end if;
				    w_label := 'e275';
		  		  debug(w_procedure_name,w_label,' --Get future pending Payments Helploan');
						if w_rchl.agrv_hl_acct_key is not null and nvl(g_is_hlp_auto_auto,0) > 0 then
							 for r1_fpp in  (select latestpaymentdate,currautopayamnt,currautopymtdt --Chng 9918b
							                   from phl_stgin_kubra_hist
							                  where seq_no = ( select max(seq_no) from phl_stgin_kubra_hist
		                                              where acct_key = w_rchl.agrv_hl_acct_key
		                                                and status = 'PROCESSED'
		                                                and prime_ind = 'Y'
		                                           )
		                          )
		           loop
							   w_label := 'e276';
					  	 	 debug(w_procedure_name,w_label,' --Inside future pending Payments Helploan');
							 	 if r1_fpp.currautopymtdt is not null and 												--Chng 9918b
							 	    r1_fpp.currautopymtdt <= g_prev_bill_pnlty_dt and							--Chng 9918b
							 	    r1_fpp.currautopymtdt >= nvl(w_ptbm.billing_date,sysdate)			--Chng 9918b
							 	 then
							 	    w_label := 'e277';
						   		  debug(w_procedure_name,w_label,' --Inside future pending Payments Helploan Selected');
						   		  debug(w_procedure_name,w_label,' --g_pn_py_cr_dt_hlp_tbl.count -->' || g_pn_py_cr_dt_hlp_tbl.count);
							 			l_fut_py_acctd := false;
										for i in 1..g_pn_py_cr_dt_hlp_tbl.count
										loop
										  l_fut_py_acctd := false;
											if trunc(g_pn_py_cr_dt_hlp_tbl(i).creation_date) = trunc(r1_fpp.currautopymtdt) then  --chng 9918b
												 l_fut_py_acctd := true;
												 exit;
											end if;
										end loop;
								    w_label := 'e278';
					  		 		debug(w_procedure_name,w_label,' --HELPLOAN Future Payment Accounted--'||booleanc(l_fut_py_acctd));
							 			if not(l_fut_py_acctd) then
						   	    	 --w_ptbm.next_hlp_auto_pay_amnt := nvl(w_ptbm.next_hlp_auto_pay_amnt,0) + nvl(g_prev_bill_hl_bal,0); --Del 9918b
							   	 		 w_ptbm.next_hlp_auto_pay_amnt := nvl(w_ptbm.next_hlp_auto_pay_amnt,0) + nvl(r1_fpp.currautopayamnt,0); --Add 9918b
						   	    end if;
						   	 		if w_ptbm.next_hlp_auto_pay_amnt = 0 then w_ptbm.next_hlp_auto_pay_amnt := null; end if;
							 	 end if;
							 end loop;
						end if;
				    debug(w_procedure_name,w_label,' w_ptbm.next_wtr_auto_pay_amnt   '|| w_ptbm.next_wtr_auto_pay_amnt);
				    debug(w_procedure_name,w_label,' w_ptbm.next_agn_auto_pay_amnt   '|| w_ptbm.next_agn_auto_pay_amnt);
				    debug(w_procedure_name,w_label,' w_ptbm.next_hlp_auto_pay_amnt   '|| w_ptbm.next_hlp_auto_pay_amnt);
					end if;
				end if;
				--End Add 9918
			exception
				when no_data_found then
					 w_ptbm.ebill_auto_pay_ind := NULL;
					 w_ptbm.ebill_auto_pay_str := NULL;
					 w_ptbm.next_wtr_auto_pay_amnt := NULL; --Add 9918
					 w_ptbm.next_hlp_auto_pay_amnt := NULL; --Add 9918
					 w_ptbm.next_agn_auto_pay_amnt := NULL; --Add 9918
					 --g_auto_pay_4all_acs			 := NULL;	 --Del 8020F
	  		debug(w_procedure_name,w_label,'No 1 --> Data Found Error' );
			end;
		exception
			when others then
				 w_ptbm.ebill_ind 					:= NULL;
				 w_ptbm.ebill_auto_pay_ind	:= NULL;
				 w_ptbm.ebill_auto_pay_str	:= NULL;
	  		 debug(w_procedure_name,w_label,'No 2 --> Data Found Error' );
		end;
	  --End 8020F moved before bill message and initialize phls0250 global variables.
	  begin
 	    w_label := 'e279';
		  --debug_ttid('9106' , w_procedure_name,w_label,'<w_ptbm.meter_key>'|| w_ptbm.meter_key);
		  --debug_ttid('11138' , w_procedure_name,w_label,'<g_meter_key_10chr>'|| g_meter_key_10chr);
		  --debug_ttid('11138' , w_procedure_name,w_label,'<g_meter_id>'|| g_meter_id);
  		--debug(w_procedure_name,w_label,'Before g_mtr_rec_tbl cnt ' || g_mtr_rec_tbl.count() );
		  --debug_ttid('11138' , w_procedure_name,w_label,'g_mtr_rec_tbl(g_meter_id).outreader_type_code'|| g_mtr_rec_tbl(g_meter_id).outreader_type_code);
  		--debug(w_procedure_name,w_label,'After g_mtr_rec_tbl cnt ' || g_mtr_rec_tbl.count() );
      --debug(w_procedure_name,w_label,'g_mtr_rec_tbl(g_meter_id).outreader_type_code '  || g_mtr_rec_tbl(g_meter_id).outreader_type_code);
		  --Start Add 10266
		  --if g_mtr_rec_tbl(substr(w_ptbm.meter_key,1,7)).outreader_type_code = 'AMI' then del 11138
		  if g_mtr_rec_tbl(g_meter_id).outreader_type_code = 'AMI' then --Add 11138
		  	 g_outreader_type_code := 'AMI';
		  else
		  	 g_outreader_type_code := null;
		  end if;
		  --End Add 10266
	    --Start Del 10266
	  	--Start Add 9106
	  	--select outreader_type_code into g_outreader_type_code
	  	--  from cis.cis_meters
	  	-- where substr(meter_key,1,7) = subst(w_ptbm.meter_key,1,7)
	  	--   and outreader_type_code = 'AMI';
			--End Del 10266
	  exception
	  when others then
	  	 g_outreader_type_code := null;
	  end;
	  --Start Add 11192
	  --Start Add 10495
		begin
 	    w_label 			:= 'e280';
		  g_tgt_dt_001 	:= null;
		  select max(to_date(trim(substr(alert_trigger_dt,1,10)),'YYYY-MM-DD'))  into g_tgt_dt_001 --Chng 11192
			  from cis.phl_kubra_usage_alerts
 				where acct_key = w_ptbm.acct_key
   			  and type_cd in ('L','Z','H') -- 'X'  --Chng Add 11192
   				and months_between(w_ptbm.billing_date,to_date(trim(substr(alert_trigger_dt,1,10)),'YYYY-MM-DD')) between -0.000001 and 1.000001
   				and (e_alert_sent = 'Y' or paper_alert_needed = 'Y');
      w_label := 'e281';
		exception
		  when others then --No need max
		    g_tgt_dt_001 := null;
     	  debug_ttid('10495' , w_procedure_name,w_label,'<Exception g_tgt_dt_001 is NULL>');
		end;
		--close c_tgt_dt;    --Add 11192
		--g_type_cd := null; --Add 11192
	  debug_ttid('10495' , w_procedure_name,w_label,'<OUT SIDE THE LOOP g_tgt_dt_001>'|| datec(g_tgt_dt_001));
	  --End Add 10495
	  --End Add 11192
		debug_ttid('9106' , w_procedure_name,w_label,'<g_outreader_type_code>'|| g_outreader_type_code);
		debug_ttid('9106' , w_procedure_name,w_label,'<w_round_key>'|| w_round_key);
	  --End Add 9106
	  debug(w_procedure_name,w_label,'<w_ptbm.acct_key>'|| w_ptbm.acct_key ||'<w_ptbm.ebill_auto_pay_str>'|| w_ptbm.ebill_auto_pay_str);
     phls0005.get_billmssg(
                           p_cust_id                  => w_cust_id
                          ,p_inst_id                  => w_inst_id
                          ,p_tran_id                  => w_tran_id
                          ,p_mesg_date                => w_mesg_date
                          ,p_acct_pay_method          => w_acct_pay_method
                          --,p_ebill_auto_pay_ind				=> w_ptbm.ebill_auto_pay_ind	--Del 8020D --Add 9454
                          ,p_ebill_auto_pay_ind				=> w_ptbm.ebill_auto_pay_str    --Chg 8020F --Del 8020F g_auto_pay_4all_acs      --Add 8020D
                          ,p_incid_code               => w_incid_code
                          ,p_ppln_id                  => w_ppln_id
                          ,p_ppln_due_amnt            => w_ppln_due_amnt               -- Del 2.0.0.0 w_ppln_due_amnt
                          ,p_dd_earliest_date         => w_dd_earliest_date
                          ,p_shutoff_date             => w_msg_shutoff_date            -- Add 2775 and 2514
                          ,p_estimates_cnt            => w_estimates_cnt
                          ,p_previous_balance_amnt    => w_ptbm.previous_balance_amnt
                          ,p_ppln_no_due              => w_ppln_no_due
                          ,p_cust_own_reading_ind     => w_cust_own_reading_ind
                          ,p_est_reading_ind          => w_est_reading_ind
                          ,p_factor_message           => w_factor_message              --Add 3706
                          ,p_sur_cst_fct_mssg         => w_sur_cst_fct_mssg
                          ,p_est_rev_messg            => w_est_rev_messg
                          ,p_debt_bal_not_incl        => w_ptbm.debt_bal_not_incl      --Even though we are passing it to PHLS0005 it's not used --2264
                          ,p_bnkrptcy_bal_amnt_wat    => w_ptbm.debt_bal_amnt_bnk      --Add 6495 If Active Bankruptcy Balance is greater than Zero, display message. If it's priority allows it.
                        --,p_debt_bal_grants          => w_ptbm.debt_bal_grants        --Del 3706
                          ,p_fault_code               => w_fault_code
                          ,p_sw_chg_fr_dt             => w_ptbm.sw_chg_fr_dt           --cng/del 3659 w_sw_chg_fr_dt  --Chg 3659 __see above -- Add 2730
                          ,p_sw_chg_to_dt             => w_ptbm.sw_chg_to_dt           --cng/del 3659 w_sw_chg_to_dt   __see above -- Add 2730
                          ,p_nb_code                  => w_nb_code                     --Add 2730
                          ,p_debt_bal_amnt_ues        => w_debt_bal_amnt_ues           --Add 3706
                          ,p_grnt_rcvd                => w_grnt_rcvd                   --Add 3706
                          ,p_pay_profile_code         => w_pay_profile_code            --Add 3327
    											,p_pay_profile_code_orig    => w_pay_profile_code_orig			 --Add 9297B
                          ,p_arrears_letter_no        => w_arrears_letter_no           --Add 4563
                          ,p_un_paid_prv_bal          => w_ptbm.un_paid_prv_bal        --Add 4563A
                          ,p_tap_disc                 => w_ptbm.tap_disc               --Add 6971
                          ,p_dispute_amnt             => w_ptbm.tot_disp_amnt          --Chng 9792 w_ptbm.amnt_in_disp --Add 7164
                          ,p_agn_acct_opn_bal         => w_rchl.agrv_rc_st_opening_bal_amnt --Add 7349
													,p_ss_fee_mssg						  => l_ss_fee_mssg							   --Add 7762
													,p_round_key								=> w_round_key									 --Add 9106
													,p_outreader_type_code			=> g_outreader_type_code			 	 --Add 9106
													,p_pnlty_frgv_dt				 		=> w_ptbm.tap_pnlty_frgv_dt			 --Add 9984
													,p_pnlty_frgv_amnt 			 		=> w_ptbm.tap_pnlty_frgv_amnt		 --Add 9984
													,p_prin_frgv_dt					 		=> w_ptbm.tap_prin_frgv_dt			 --Add 9984
													,p_prin_frgv_amnt 			 		=> w_ptbm.tap_prin_frgv_amnt		 --Add 9984
													,p_tgt_dt								 		=> g_tgt_dt_001									 --Add 10495
													,p_s17_grnt_amnt						=> g_s17_grnt_amnt							 --Add 11413
                          ,p_full_text_1              => w_ptbm.message_1
                          ,p_full_text_2              => w_ptbm.message_2
                          ,p_full_text_3              => w_ptbm.message_3
                          ,p_full_text_4              => w_ptbm.message_4
                          ,p_hdr_full_text_1          => w_ptbm.hdr_mesg_1             --Add 3706
                          ,p_hdr_full_text_2          => w_ptbm.hdr_mesg_2             --Add 3706
                          ,p_hdr_full_text_3          => w_ptbm.hdr_mesg_3             --Add 3706
                          ,p_hdr_full_text_4          => w_ptbm.hdr_mesg_4             --Add 3706
                          );
   w_label := 'e283';
	 debug(w_procedure_name,w_label,' l_ss_fee_mssg '|| l_ss_fee_mssg);
	 --debug(w_procedure_name,w_label,' g_auto_pay_4all_acs '|| g_auto_pay_4all_acs); --Del 8020F
	 debug(w_procedure_name,w_label,' w_ptbm.ebill_auto_pay_str '|| w_ptbm.ebill_auto_pay_str); --Del 8020F
   --When meters are replaced/rotate
   --Total qty of replace and current meter are stored in w_ptbm.billed_qty (tran_qty)
   --So we have to substract replace billed qty from billed qty.
   --debug(w_procedure_name,w_label,' w_rpl_qty_tbl.count '|| w_rpl_qty_tbl.count);          --Add 2417
   --debug(w_procedure_name,w_label,' w_ptbm.billed_qty   '|| w_ptbm.billed_qty);
   --Start Add 3706
   if w_rpl_qty_tbl.count > 1 then
      indx_rpl_tbl         := w_rpl_qty_tbl.first;
      counter_4_rpl_tbl    := 0;
      loop
         counter_4_rpl_tbl := counter_4_rpl_tbl + 1; --do not use as index
         --debug(w_procedure_name,w_label,' [**987654321.01**] w_rpl_qty_tbl(indx_rpl_tbl).qty            '|| w_rpl_qty_tbl(indx_rpl_tbl).qty);
         --debug(w_procedure_name,w_label,' [**987654321.01**] w_rpl_qty_tbl(indx_rpl_tbl).qty            '|| w_rpl_qty_tbl(indx_rpl_tbl).qty);
         --debug(w_procedure_name,w_label,' [**987654321.02**] w_rpl_qty_tbl(indx_rpl_tbl).meter_key      '|| w_rpl_qty_tbl(indx_rpl_tbl).meter_key);
         --debug(w_procedure_name,w_label,' [**987654321.03**] w_rpl_qty_tbl(indx_rpl_tbl).ert_no         '|| w_rpl_qty_tbl(indx_rpl_tbl).ert_no);
         --debug(w_procedure_name,w_label,' [**987654321.04**] w_rpl_qty_tbl(indx_rpl_tbl).from_rdg_date  '|| to_char(w_rpl_qty_tbl(indx_rpl_tbl).from_rdg_date,'mm/dd'));
         --debug(w_procedure_name,w_label,' [**987654321.05**] w_rpl_qty_tbl(indx_rpl_tbl).upto_rdg_date  '|| to_char(w_rpl_qty_tbl(indx_rpl_tbl).upto_rdg_date,'mm/dd'));
         --debug(w_procedure_name,w_label,' [**987654321.06**] w_rpl_qty_tbl(indx_rpl_tbl).from_reading   '|| w_rpl_qty_tbl(indx_rpl_tbl).from_reading);
         --debug(w_procedure_name,w_label,' [**987654321.07**] w_rpl_qty_tbl(indx_rpl_tbl).meter_advance  '|| w_rpl_qty_tbl(indx_rpl_tbl).meter_advance);
         if counter_4_rpl_tbl = 1 then
            w_grph_mesg2 := 'Prior Meter / ERT '||w_rpl_qty_tbl(indx_rpl_tbl).meter_key||'/'||w_rpl_qty_tbl(indx_rpl_tbl).ert_no||' change on ' || trim(to_char(w_rpl_qty_tbl(indx_rpl_tbl).upto_rdg_date,'mm/dd')) || ' has '||trim(to_char(w_rpl_qty_tbl(indx_rpl_tbl).meter_advance))||' ccf';
            debug(w_procedure_name,w_label,' For counter_4_rpl_tbl '|| counter_4_rpl_tbl || ' '|| w_grph_mesg2);
            w_add_to_tot_qty := w_rpl_qty_tbl(indx_rpl_tbl).meter_advance;
         end if;
         if indx_rpl_tbl = w_rpl_qty_tbl.last then        --Replace Meter
            w_ptbm.repl_meter_key           := w_rpl_qty_tbl(indx_rpl_tbl).meter_key;
            w_ptbm.repl_ert_key             := w_rpl_qty_tbl(indx_rpl_tbl).ert_no;
            w_ptbm.repl_reading_from_date   := trunc(w_rpl_qty_tbl(indx_rpl_tbl).from_rdg_date);
            w_ptbm.repl_reading_upto_date   := trunc(w_rpl_qty_tbl(indx_rpl_tbl).upto_rdg_date);
            w_ptbm.repl_last_billed_reading := w_rpl_qty_tbl(indx_rpl_tbl).from_reading;
            w_ptbm.repl_this_billed_reading := w_rpl_qty_tbl(indx_rpl_tbl).from_reading + nvl(w_rpl_qty_tbl(indx_rpl_tbl).meter_advance,0);
            w_ptbm.repl_billed_qty          := nvl(w_rpl_qty_tbl(indx_rpl_tbl).meter_advance,0);
         end if;
         w_ptbm.billed_qty  :=  w_current_billed_qty; --This is temporary solution.
                                                      --Actual solution is below commented
                                                      --We need to find a fix for this issue.--nvl(w_ptbm.billed_qty,0) - nvl(w_rpl_qty_tbl(indx_rpl_tbl).meter_advance,0);
         --************************************V.V.V.V.V.IMP************************************************--
         --************************************V.V.V.V.V.IMP************************************************--
         --************************************V.V.V.V.V.IMP************************************************--
         --
         -- Do not delete the comment
         -- Please read this will be very important to implement later
         --
         --If we can store all the RDG Lines this can be achieved
         --May be next project
         --if  counter_4_rpl_tbl != 1 and indx_rpl_tbl != w_rpl_qty_tbl.last then        --Replace Meter
         --   w_ptbm.repl_meter_key           := w_rpl_qty_tbl(indx_rpl_tbl).meter_key;
         --   w_ptbm.repl_ert_key             := w_rpl_qty_tbl(indx_rpl_tbl).ert_no;
         --   w_ptbm.repl_reading_from_date   := trunc(w_rpl_qty_tbl(indx_rpl_tbl).from_rdg_date);
         --   w_ptbm.repl_reading_upto_date   := trunc(w_rpl_qty_tbl(indx_rpl_tbl).upto_rdg_date);
         --   w_ptbm.repl_last_billed_reading := w_rpl_qty_tbl(indx_rpl_tbl).from_reading;
         --   w_ptbm.repl_this_billed_reading := w_rpl_qty_tbl(indx_rpl_tbl).from_reading + nvl(w_rpl_qty_tbl(indx_rpl_tbl).meter_advance,0);
         --   w_ptbm.repl_billed_qty          := nvl(w_rpl_qty_tbl(indx_rpl_tbl).meter_advance,0);
         --end if;
         --If we can store all the RDG Lines this can be achieved
         --May be next project
         --if indx_rpl_tbl = w_rpl_qty_tbl.last then --Change Cuurent Meter from_date, to_date and readings
         --   w_ptbm.meter_key           := w_rpl_qty_tbl(indx_rpl_tbl).meter_key;
         --   w_ptbm.ert_key             := w_rpl_qty_tbl(indx_rpl_tbl).ert_no;
         --   w_ptbm.reading_from_date   := trunc(w_rpl_qty_tbl(indx_rpl_tbl).from_rdg_date);
         --   w_ptbm.reading_upto_date   := trunc(w_rpl_qty_tbl(indx_rpl_tbl).upto_rdg_date);
         --   w_ptbm.last_billed_reading := w_rpl_qty_tbl(indx_rpl_tbl).from_reading;
         --   w_ptbm.this_billed_reading := w_rpl_qty_tbl(indx_rpl_tbl).from_reading + nvl(w_rpl_qty_tbl(indx_rpl_tbl).meter_advance,0);
         --   w_ptbm.billed_qty          := nvl(w_rpl_qty_tbl(indx_rpl_tbl).meter_advance,0);
         --end if;
         --************************************V.V.V.V.V.IMP************************************************--
         --************************************V.V.V.V.V.IMP************************************************--
         --************************************V.V.V.V.V.IMP************************************************--
         exit when indx_rpl_tbl = w_rpl_qty_tbl.last;
         indx_rpl_tbl := w_rpl_qty_tbl.next(indx_rpl_tbl);
      end loop;
   else
      debug(w_procedure_name,w_label,' [**99.00**] w_meter_grp_rdg_id '|| w_meter_grp_rdg_id);
      if w_rpl_qty_tbl.count > 0 and w_meter_grp_rdg_id is null  then
         indx_rpl_tbl         := w_rpl_qty_tbl.first;
         loop
            if  w_rpl_qty_tbl(indx_rpl_tbl).db_scnd_type = 'RDG'
            and w_rpl_qty_tbl(indx_rpl_tbl).bill_key     = w_ptbm.bill_key
            then
               debug(w_procedure_name,w_label,' [**99.01**] w_ptbm.billed_qty '|| w_ptbm.billed_qty);
               debug(w_procedure_name,w_label,' [**99.02**] w_rpl_qty_tbl(i).qty '|| w_rpl_qty_tbl(indx_rpl_tbl).qty);
               w_ptbm.billed_qty := nvl(w_ptbm.billed_qty,0) - nvl(w_rpl_qty_tbl(indx_rpl_tbl).qty,0);  --REMOVED ABS function BUT REVERSAL WILL BE AN ISSUE. please check bill B0429897757
               debug(w_procedure_name,w_label,' [**99.03**] w_rpl_qty_tbl(i).qty '|| w_rpl_qty_tbl(indx_rpl_tbl).qty);
               exit; --Only for 1 rotate
            end if;
            exit when indx_rpl_tbl = w_rpl_qty_tbl.last;
            indx_rpl_tbl := w_rpl_qty_tbl.next(indx_rpl_tbl);
         end loop;
      end if;
   end if;
   --Start End 3706
   debug(w_procedure_name,w_label,' [**9.03**After] w_current_billed_qty '|| w_current_billed_qty);
   debug(w_procedure_name,w_label,' w_ptbm.billed_qty   '|| w_ptbm.billed_qty);
   w_rpl_qty_tbl.delete;                           --Add 2417
   ---- Start Del 2.0.0.20
     --
     -- Replace scan string if paying by zip and this is the main message
     -- with the initial part of the main message upt to the paid by date
     --if w_acct_pay_method <> 'I'                                                           -- Add 894
     --and w_ptbm.message_1 like '%ZIPCHECK%'                                                -- Add 894
     --then                                                                                  -- Add 894
     --  w_ptbm.scan_string := substr(w_ptbm.message_1,1,instr(w_ptbm.message_1,',') -1);    -- Add 894
     --else                                                                                  -- Add 894
     --  Now format the office scan string
     --  scan_string;
     --end if;                                                                               -- Add 894
   --
   --Start 2488
          if w_ptbm.est_last_rdg_flag      is not null then w_ptbm.est_last_rdg_flag       := 'E'; end if;
          if w_ptbm.est_this_rdg_flag      is not null then w_ptbm.est_this_rdg_flag       := 'E'; end if;
          if w_ptbm.est_repl_last_rdg_flag is not null then w_ptbm.est_repl_last_rdg_flag  := 'E'; end if;
          if w_ptbm.est_repl_this_rdg_flag is not null then w_ptbm.est_repl_this_rdg_flag  := 'E'; end if;
   --End 2488
     w_city_acct            :=  w_city_acct_4_WAT;  --Add 6130 --So that w_city_acct, is reassigned the water1acct, if it was overwritten by HELPLOAN Scanline.
     w_city_acct_new_suffix :=  w_city_acct_4_WAT;  --Add 6130 --So that w_city_acct, is reassigned the water1acct, if it was overwritten by HELPLOAN Scanline.
     check_city_suffix;                             --Add 6130
     scan_string;
     w_label := 'e284';
     -- Now format the background print string
     background_print_string;
     -- Store the report record
     debug_trace(w_procedure_name,'...Before Insert Report Record  =' );
     w_label := 'e285';
     --Start Add 6230
     --Bill status check
     --w_ptbm.bill_status
     if nvl(w_ptbm.account_balance,0) + nvl(w_rchl.rc_acct_bal_amnt,0) !=  nvl(w_ptbm.total_bal,0)  then
        w_ptbm.bill_status  := 'CHECK-WT';
     end if;
     --End Add 6230
     --debug(w_procedure_name, w_label, ' <<<Insert for w_tran_id >>> ' || w_tran_id  );
     --debug(w_procedure_name, w_label, ' <<<Insert for Bill Key>>> ' || w_ptbm.bill_key  );
     insert_report_record;
     --Start Add 4398
     --Should be conditional
     if nvl(w_rchl.agrv_rc_5th_cur_prv_flag,'!@#') in ('C','P' )
     or w_rchl.agrv_hl_unpaid_lbl is not null then
        insert_agrv_rc_hl_st;
     end if;
     --End Add 4398
     debug_trace(w_procedure_name,'...After Insert Report Record  =' );
     --Start Add 4561
     if  w_meter_grp_rdg_id is not null
     and isZacct# = false then
        w_label := 'e286';
        debug_trace(w_procedure_name,'...Check for the Meter Groups...' );
        cpy_grp_bills_info;
     end if;
     -- Start Add 4614
     -- Duplicate the current bill information in bill print hist
     -- for each 3rd party mailing name and address
     if w_3rd_party_count > 0
     then
        w_label := 'e287';
        debug_trace(w_procedure_name,'...Before 3rd Party Bills' );
        for r3p in
        (
         select
            substr(upper(bll.cust_name_3rd_party),1,30)  NAME
           ,case
              when upper(trim(nvl(mad.address4 ,'!@#'))) != upper(trim(nvl(mad.line1,'!@#')))
               and upper(trim(nvl(mad.address10,'!@#'))) != upper(trim(nvl(mad.line1,'!@#')))
               and upper(trim(nvl(bll.cust_name,'!@#'))) != upper(trim(nvl(mad.line1,'!@#')))
               then upper(trim(substr(mad.line1,1,30)))
               else null
            end LINE1
           ,case
              when upper(trim(nvl(mad.address4 ,'!@#'))) != upper(trim(nvl(mad.line2,'!@#')))
               and upper(trim(nvl(mad.address10,'!@#'))) != upper(trim(nvl(mad.line2,'!@#')))
               and upper(trim(nvl(bll.cust_name,'!@#'))) != upper(trim(nvl(mad.line2,'!@#')))
               then upper(trim(substr(mad.line2,1,30)))
               else null
            end LINE2
           ,case
              when upper(trim(nvl(mad.address4 ,'!@#'))) != upper(trim(nvl(mad.line3,'!@#')))
               and upper(trim(nvl(mad.address10,'!@#'))) != upper(trim(nvl(mad.line3,'!@#')))
               and upper(trim(nvl(bll.cust_name,'!@#'))) != upper(trim(nvl(mad.line3,'!@#')))
               then upper(trim(substr(mad.line3,1,30)))
               else null
            end LINE3
           ,case
              when upper(trim(nvl(mad.address4 ,'!@#'))) != upper(trim(nvl(mad.line4,'!@#')))
               and upper(trim(nvl(mad.address10,'!@#'))) != upper(trim(nvl(mad.line4,'!@#')))
               and upper(trim(nvl(bll.cust_name,'!@#'))) != upper(trim(nvl(mad.line4,'!@#')))
               then upper(trim(substr(mad.line4,1,30)))
               else null
            end LINE4
           ,case
              when upper(trim(nvl(mad.address4 ,'!@#'))) != upper(trim(nvl(mad.line5,'!@#')))
               and upper(trim(nvl(mad.address10,'!@#'))) != upper(trim(nvl(mad.line5,'!@#')))
               and upper(trim(nvl(bll.cust_name,'!@#'))) != upper(trim(nvl(mad.line5,'!@#')))
               then upper(trim(substr(mad.line5,1,30)))
               else null
            end LINE5
           ,trim(mad.postal_code)                   POSTAL_CODE
           ,upper(substr(mad.delivery_point,1,11))  POSTAL_BARCODE
           ,w_imb_barcode_id || w_imb_service_type_id || w_imb_mailer_id || w_imb_serial_number ||
            nvl(rpad(replace(trim(decode(sign(nvl(length(translate(trim(mad.postal_code),' -0123456789',' ')),0)),1,'00000',trim(mad.postal_code))),'-',''),11,'0'),'00000000000')
            IMB
 					 ,dcp.doc_key															--Add 8020
         from cis_bill_lines bll
             ,cis_addresses mad
             ,cis_document_copies dcp 							--Add 8020
         where bll.tran_id 								= w_tran_id
           and bll.line_num 							= 1
           and bll.mail_addr_id  					= mad.addr_id
           and bll.copy_for_3rd_party_ind = 'Y'
           and bll.process_id  						= w_process_id
           and bll.mail_addr_id 					= dcp.mail_addr_id		--Add 8020
           and bll.acct_key    						= dcp.acct_key				--Add 8020
           and bll.bill_key    						= dcp.entity_key			--Add 8020
        )
        loop
           debug_trace(w_procedure_name,'.....3rd Party Bill: ' || r3p.name );
           w_ptbm.bill_key            := r3p.doc_key;           --Add 8020
           w_ptbm.mail_name           := r3p.name;
           w_ptbm.mail_addr_line1     := r3p.line1;
           w_ptbm.mail_addr_line2     := r3p.line2;
           w_ptbm.mail_addr_line3     := r3p.line3;
           w_ptbm.mail_addr_line4     := r3p.line4;
           w_ptbm.mail_addr_line5     := r3p.line5;
           w_ptbm.mail_postal_code    := r3p.postal_code;
           w_ptbm.mail_postal_barcode := r3p.postal_barcode;
           w_ptbm.imb                 := r3p.imb;
           if  w_ptbm.mail_addr_line1 is null and  w_ptbm.mail_addr_line2 is null then
               w_ptbm.mail_addr_line1 := w_ptbm.mail_addr_line3;
               w_ptbm.mail_addr_line2 := w_ptbm.mail_addr_line4;
               w_ptbm.mail_addr_line3 := w_ptbm.mail_addr_line5;
               w_ptbm.mail_addr_line4 := null;
               w_ptbm.mail_addr_line5 := null;
           elsif w_ptbm.mail_addr_line1 is null and  w_ptbm.mail_addr_line2 is not null then
               w_ptbm.mail_addr_line1 := w_ptbm.mail_addr_line2;
               w_ptbm.mail_addr_line2 := w_ptbm.mail_addr_line3;
               w_ptbm.mail_addr_line3 := w_ptbm.mail_addr_line4;
               w_ptbm.mail_addr_line4 := w_ptbm.mail_addr_line5;
               w_ptbm.mail_addr_line5 := null;
           elsif w_ptbm.mail_addr_line1 is not null and  w_ptbm.mail_addr_line2 is null then
               w_ptbm.mail_addr_line2 := w_ptbm.mail_addr_line3;
               w_ptbm.mail_addr_line3 := w_ptbm.mail_addr_line4;
               w_ptbm.mail_addr_line4 := w_ptbm.mail_addr_line5;
               w_ptbm.mail_addr_line5 := null;
           end if;
           /*
           --Start Add 8020
					 --Needs to contemplate if we needs to remove the doc_key from the cursor.
           --End Add 8020
           */
           --Strat Add 9695
           w_ptbm.ebill_ind := NULL; --Its Temporary fix, so that All 3rd Party and Tenant bills to landlords are paper only.
           w_ptbm.dup_ind   := 'C';  --All Copy bills are set to "C" so that Auto Pay won't be set.
           --End Add 9695
           background_print_string;
           insert_report_record;
        end loop;
        debug_trace(w_procedure_name,'...After 3rd Party Bills' );
     end if;
     -- End   Add 4614
     debug_trace(w_procedure_name,'...End of Set One Report Record  =' );
     --End Add 4561
  exception                 --Add 1.0.0.60 Bug#1896
   when no_data_found then            --Add 1.0.0.60 Bug#1896
        debug(w_procedure_name,w_label,' Tran ID is missing from CIS_BILL_LINES  =' || to_char(w_tran_id) || ' And Process ID=' || w_process_id);  --Add 1.0.0.60 Bug#1896
  end;                                              --Add 1.0.0.60 Bug#1896
 end set_one_bill;
-- Changes to collate as per new Agency Receivables / Help Loan --  4398
 /*************************************************************************************\
    procedure collate - bill print process id mode
 \*************************************************************************************/
 procedure collate
 (
  p_process_id  in   cis_process_restart.process_id%type
 ,p_bill_format in   varchar2 default null
 )
 is
    w_procedure_name              varchar2(40) := 'phls0001.collate';
    w_sofar                       number;                               -- Add 1.0.0.17A
    w_progress                    varchar2(300);                        -- Add 1.0.0.19
 begin
    if p_process_id is null then
       ciss0047.raise_exception(w_procedure_name, w_label, 'cis_internal_error',
                                'error', 'Null parameter supplied', p_severity=>'f');
    end if;
    w_label := 'e288';
    debug_trace(w_procedure_name, '..p_process_id   =' || p_process_id );
    debug_trace(w_procedure_name, '..p_bill_format  =' || p_bill_format);
    load_ref_data;
    w_label := 'e289';
    debug_trace(w_procedure_name, '..p_process_id   =' || p_process_id );
    debug_trace(w_procedure_name, '..p_bill_format  =' || p_bill_format);
    init;
    w_label       := 'e290';
    debug_trace(w_procedure_name, '..p_process_id   =' || p_process_id );
    debug_trace(w_procedure_name, '..p_bill_format  =' || p_bill_format);
    w_process_id  := p_process_id;
    w_bill_format := p_bill_format;
    debug_trace(w_procedure_name, '..w_process_id   =' || w_process_id );
    debug_trace(w_procedure_name, '..w_bill_format  =' || w_bill_format);
  --delete from phl_tmg_bill_master where process_id = w_process_id; --Del 2306 -2.0.0.30
  --commit;																													 --Del 9454 Commit is not needed
    w_count := 0;
    w_sofar := 0;                                                     -- Add 1.0.0.17A
    if w_bill_format is null then
       trace_label('e291', w_procedure_name);
       select count(distinct tran_id) into w_count
         from cis_bill_lines
        where process_id = w_process_id
          and bill_format_code NOT IN ('GRP-BILL', 'NO-PRINT');       -- Add 1.0.0.17
    else
       trace_label('e292', w_procedure_name);
       select count(distinct tran_id) into w_count
         from cis_bill_lines
        where process_id = w_process_id
          and bill_format_code = w_bill_format;
    end if;
    debug_trace(w_procedure_name, '..w_count  =' || w_count);
    --Start Add 3706
    trace_label('e293', w_procedure_name);
    --w_sql := 'TRUNCATE TABLE CIS.PHL_TMG_BILL_MASTER';
    --execute immediate w_sql;
    --End Add 3706
    if w_count = 0 then
       trace_label('e294', w_procedure_name);
       --insert into PHL_TMG_BILL_MASTER --del 3706
       insert into PHL_BILL_PRINT_HIST --add 3706
       (
         bill_key
        ,cust_name
        ,mail_addr_line1
        ,process_id
        ,seq_no                                 --Add 8020F/9570 --Add 6230 Comtemplate if we need it or not
       )
       values
       (
         'COPY BILL'
        ,'BILL LINES MISSING'
        ,'PROCESS: ' || to_char(w_process_id)
        ,w_process_id
        ,phl_bill_seq_s.nextval                 --Add 8020F/9570 --Add 8020F --Add 6230 Comtemplate if we need it or not
       );
    else
       -- Deliberate Unconditional Trace to Show Total Bills     Add 1.0.0.17A
       w_progress := 'Format:' || w_bill_format || ': Count=' || w_count;          -- Chg 1.0.0.19
       ciss0001.write_message                                                      -- Add 1.0.0.19
                          (
                           p_procedure_name  => w_procedure_name
                          ,p_mesg_code       => 'PHL_BILL_REPORT_STATUS'
                          ,p_mesg_text       => w_progress
                          ,p_statement_label => w_label
                          );
       if w_count >= 1                                   -- Add 2.0.0.24
       and p_process_id > 0                                                        -- Add 1.0.0.22
       then
          w_label := 'e295';
          performance_statistics('BILLS');                                         -- Add 1.0.0.27
          -- There is more than one bill being printed
          -- so this must be a background print run
          -- format the background print headings string
          --background_print_headings; --Del 3706
          --insert_report_record;      --Del 3706
       end if;
       if w_bill_format is null then
          trace_label('e296', w_procedure_name);
          for bpt in (
                      select bltr.cust_id
                            ,bltr.inst_id
                            ,bltr.tran_id
                            ,bltr.supply_type
                            ,bltr.bill_id        --Add 4398
                        from cis_bill_lines blln
                            ,cis_bill_trans bltr
                       where blln.process_id = w_process_id
                         and blln.line_num = 1
                         and blln.copy_for_3rd_party_ind is null          -- Add 4614
                         and bltr.tran_id = blln.tran_id
                         and blln.bill_format_code NOT IN ('GRP-BILL', 'NO-PRINT')  -- Add 1.0.0.17
                         and bltr.supply_type = 'WATER'  --Add 4398
                     )
          loop
             w_cust_id := bpt.cust_id;
             w_inst_id := bpt.inst_id;
             w_tran_id := bpt.tran_id;
             w_bill_id := bpt.bill_id;       --Add 4398
             set_one_bill;
             -- Start Add 1.0.0.17A         2nd Unconditional Status Trace
             w_sofar := w_sofar + 1;
             if round(w_sofar/1000,0)*1000 = w_sofar then
                w_progress := 'Done ' || w_sofar || ' of ' ||  w_count;             -- Chg 1.0.0.19
                ciss0001.write_message                                              -- Add 1.0.0.19
                          (
                           p_procedure_name  => w_procedure_name
                          ,p_mesg_code       => 'PHL_BILL_REPORT_STATUS'
                          ,p_mesg_text       => w_progress
                          ,p_statement_label => w_label
                          );
             end if;
             -- End   Add 1.0.0.17A
          end loop;
       else
          trace_label('e297', w_procedure_name);
          for bpt in (
                      select bltr.cust_id
                            ,bltr.inst_id
                            ,bltr.tran_id
                            ,bltr.supply_type
                        from cis_bill_lines blln
                            ,cis_bill_trans bltr
                       where blln.process_id = w_process_id
                         and blln.line_num = 1
                         and blln.copy_for_3rd_party_ind is null          -- Add 4614
                         and bltr.tran_id = blln.tran_id
                         and blln.bill_format_code = w_bill_format
                         and bltr.supply_type = 'WATER'  --Add 4398
                     )
          loop
             w_cust_id := bpt.cust_id;
             w_inst_id := bpt.inst_id;
             w_tran_id := bpt.tran_id;
             set_one_bill;
          end loop;
            -- Start Add 1.0.0.17A         2nd Unconditional Status Trace
            w_sofar := w_sofar + 1;
            if round(w_sofar/1000,0)*1000 = w_sofar then
               w_progress := 'Done ' || w_sofar || ' of ' ||  w_count;                     -- Chg 1.0.0.19
               ciss0001.write_message                                                      -- Add 1.0.0.19
                         (
                          p_procedure_name  => w_procedure_name
                         ,p_mesg_code       => 'PHL_BILL_REPORT_STATUS'
                         ,p_mesg_text       => w_progress
                         ,p_statement_label => w_label
                         );
            end if;
            -- End   Add 1.0.0.17A
       end if;
    end if;
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
   debug(w_procedure_name,w_label,' Error AT = ' || w_label);
       debug(w_procedure_name,w_label,'...cust_id     =' || to_char(w_cust_id));
       ciss0047.raise_exception(w_procedure_name, w_label, 'cis_internal_error',
                                'error', sqlerrm, p_severity=>'F');
 end collate;
   --Start Add 2852
 /*************************************************************************************\
    public procedure collate_one_bill
 \*************************************************************************************/
   procedure collate_one_bill(p_bill_key              varchar2
                             ,p_bill_id               number
                             ,p_bill_format_code      varchar2
                             ,p_tran_id               number         --Add 3055
                             )
   is
      w_procedure_name varchar2(50) := 'phls0001.collate_one_bill';
      w_exception      boolean      := false;
   begin
      init;
      load_ref_data;
      debug_trace(w_procedure_name, '..p_bill_key  =' || p_bill_key );
      debug_trace(w_procedure_name, '..p_bill_id   =' || p_bill_id );
      debug_trace(w_procedure_name, '..p_bill_format_code  =' || p_bill_format_code);
      w_label := 'e298';
      if p_bill_key is null
      or p_bill_id  is null
      or p_bill_format_code  is null
      then
       ciss0047.raise_exception(w_procedure_name, w_label, 'cis_internal_error',
                                'error', 'Null parameter supplied', p_severity=>'f');
      end if;
      w_process_id := p_bill_id * -1;
      w_label := 'e299';
      begin
         update cis_bill_trans set
                current_process_id = w_process_id
          where bill_id = p_bill_id
          and supply_type = 'WATER'                 --Add 3706
          returning   cust_id,   inst_id,  tran_id
               into w_cust_id, w_inst_id, w_tran_id
          ;
      --Add 3055
      exception
         when too_many_rows then
         for r1 in (select cust_id,inst_id,tran_id
                      from cis_bill_trans
                     where bill_id=p_bill_id
                       --and tran_id=p_tran_id        --Del 3706
                       and supply_type = 'WATER'
                   )
         loop
            w_cust_id := r1.cust_id;
            w_inst_id := r1.inst_id;
            w_tran_id := r1.tran_id;
            w_exception := true;
            exit;
         end loop;
      --Add 3055
      end;
      --Start Add 3706
      if w_exception then
         update cis_bill_trans set
                current_process_id = w_process_id
          where bill_id = p_bill_id;
      end if;
      --End Add 3706
      w_count := 0;
      select count(*) into w_count from cis_bill_lines
      where bill_key = p_bill_key;
      if w_count = 0 then
         ciss0088.create_reprint_bill_lines(p_bill_id            => p_bill_id,
                                            p_bill_key           => p_bill_key,
                                            p_print_now_or_later => 'N',
                                            p_bill_format_code   => p_bill_format_code);
      end if;
      update cis_bill_lines set
             process_id = w_process_id
       where bill_key   = p_bill_key;
    w_label := 'e300';
      set_one_bill;
    w_label := 'e301';
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
  debug(w_procedure_name,w_label,' Error AT = ' || w_label);
      debug(w_procedure_name,w_label,'...cust_id     =' || to_char(w_cust_id));
      ciss0047.raise_exception(w_procedure_name, w_label, 'cis_internal_error',
                               'error', sqlerrm, p_severity=>'F');
   end collate_one_bill;
   --End Add 2852
 /*************************************************************************************\
    public procedure scan_string_return_check
 \*************************************************************************************/
 function scan_string_return_check(scanString varchar2) return varchar2
 is
    w_procedure_name   varchar2(50) := 'phls0001.scan_string_return_check';
    w_check_digit      varchar2(1);
    w_char_26_old      varchar2(1);        -- Add 1.0.0.56
    w_char_26_new      varchar2(1);        -- Add 1.0.0.56
    w_char_67_old      varchar2(1);
    w_char_67_new      varchar2(1);
    w_char_68          varchar2(1);
    w_scanString      varchar2(100);
    w_new_scan_string  varchar2(100);
 begin
    w_scanString:=substr(scanString,1,68);      --Mod 1.0.0.52a
    w_char_67_old:=substr(w_scanString,67,1);
    w_char_26_old:=substr(w_scanString,26,1);   -- Add 1.0.0.56
    w_char_26_new:=substr(w_scanString,26,1);   -- Add 1.0.0.56
    if  (w_char_67_old>= '0' and w_char_67_old <='9') then -- Chg 1.0.0.61 / 2.0.0.0A
         w_char_67_new:='0';                               -- Chg 1.0.0.61 / 2.0.0.0A
    elsif (w_char_67_old>= 'A' and w_char_67_old <='I') then
         w_char_67_new:='1';                               -- Chg 1.0.0.61 / 2.0.0.0A
 /* Start 1.0.0.56 */
     if w_char_26_old = 'A'
        then w_char_26_new := '1';
     elsif w_char_26_old = 'B'
        then w_char_26_new := '2';
     elsif w_char_26_old = 'C'
        then w_char_26_new := '3';
     elsif w_char_26_old = 'D'
        then w_char_26_new := '4';
     elsif w_char_26_old = 'E'
        then w_char_26_new := '5';
     elsif w_char_26_old = 'F'
        then w_char_26_new := '6';
     elsif w_char_26_old = 'G'
        then w_char_26_new := '7';
     elsif w_char_26_old = 'H'
        then w_char_26_new := '8';
     elsif w_char_26_old = 'I'
        then w_char_26_new := '9';
     end if;
 /* End 1.0.0.56 */
    elsif (w_char_67_old>= 'J' and w_char_67_old <='R') then
         w_char_67_new:='2';                             -- Chg 1.0.0.61 / 2.0.0.0A
 /* Start 1.0.0.56 */
     if w_char_26_old = 'J'
        then w_char_26_new := '1';
     elsif w_char_26_old = 'K'
        then w_char_26_new := '2';
     elsif w_char_26_old = 'L'
        then w_char_26_new := '3';
     elsif w_char_26_old = 'M'
        then w_char_26_new := '4';
     elsif w_char_26_old = 'N'
        then w_char_26_new := '5';
     elsif w_char_26_old = 'O'
        then w_char_26_new := '6';
     elsif w_char_26_old = 'P'
        then w_char_26_new := '7';
     elsif w_char_26_old = 'Q'
        then w_char_26_new := '8';
     elsif w_char_26_old = 'R'
        then w_char_26_new := '9';
     end if;
 /* End 1.0.0.56 */
    else
         w_char_67_new:='3';                               -- Chg 1.0.0.61 / 2.0.0.0A
 /* Start 1.0.0.56 */
     if w_char_26_old = 'S'
        then w_char_26_new := '1';
     elsif w_char_26_old = 'T'
        then w_char_26_new := '2';
     elsif w_char_26_old = 'U'
        then w_char_26_new := '3';
     elsif w_char_26_old = 'V'
        then w_char_26_new := '4';
     elsif w_char_26_old = 'W'
        then w_char_26_new := '5';
     elsif w_char_26_old = 'X'
        then w_char_26_new := '6';
     elsif w_char_26_old = 'Y'
        then w_char_26_new := '7';
     elsif w_char_26_old = 'Z'
        then w_char_26_new := '9';
     end if;
 /* End 1.0.0.56 */
    end if;
    w_label := 'e302';
    w_new_scan_string:=substr(w_scanString,1,25)||w_char_26_new||substr(w_scanString,27,40)||w_char_67_new||substr(w_scanString,68,1); --Mod 1.0.0.52a Mod 1.0.0.56
    w_check_digit := get_check_digit(w_new_scan_string);
    w_new_scan_string:=substr(w_scanString,1,25)||w_char_26_new||substr(w_scanString,27,40)||w_char_67_new||w_check_digit; -- Del 1.0.0.56 Mod 1.0.0.56
    --
    -- Report variable
    --
    return (w_new_scan_string);
 end scan_string_return_check;
 /*************************************************************************************\
    public procedure scan_string_group_bill          -- Add 709
 \*************************************************************************************/
 function scan_string_group_bill(scanString in varchar2) return varchar2
 is
    w_procedure_name   varchar2(50) := 'phls0001.scan_string_group_bill';
    w_check_digit      varchar2(1);
    w_char_26_old      varchar2(1);
    w_char_26_new      varchar2(1);
    w_char_67_old      varchar2(1);
    w_char_67_new      varchar2(1);
    w_new_scan_string  varchar2(100);
 begin
  w_label := 'e303';
    debug_trace(w_procedure_name,'...scanString =' || scanString);
    debug_trace(w_procedure_name,'...length(scanString) =' || length(scanString));
    w_char_26_old:=substr(scanString,26,1);
    w_char_67_old:=substr(scanString,67,1);
    debug_trace(w_procedure_name,'...w_char_26_old =' || w_char_26_old);
    debug_trace(w_procedure_name,'...w_char_67_old =' || w_char_67_old);
    if  (w_char_26_old>= '0' and w_char_26_old <='9') then
     w_char_26_new:='0';
         w_char_67_new:='0';
    elsif (w_char_26_old>= 'A' and w_char_26_old <='I') then
         w_char_67_new:=1;
     if w_char_26_old = 'A'
        then w_char_26_new := '1';
     elsif w_char_26_old = 'B'
        then w_char_26_new := '2';
     elsif w_char_26_old = 'C'
        then w_char_26_new := '3';
     elsif w_char_26_old = 'D'
        then w_char_26_new := '4';
     elsif w_char_26_old = 'E'
        then w_char_26_new := '5';
     elsif w_char_26_old = 'F'
        then w_char_26_new := '6';
     elsif w_char_26_old = 'G'
        then w_char_26_new := '7';
     elsif w_char_26_old = 'H'
        then w_char_26_new := '8';
     elsif w_char_26_old = 'I'
        then w_char_26_new := '9';
     end if;
    elsif (w_char_26_old>= 'J' and w_char_26_old <='R') then
         w_char_67_new:=2;
     if w_char_26_old = 'J'
        then w_char_26_new := '1';
     elsif w_char_26_old = 'K'
        then w_char_26_new := '2';
     elsif w_char_26_old = 'L'
        then w_char_26_new := '3';
     elsif w_char_26_old = 'M'
        then w_char_26_new := '4';
     elsif w_char_26_old = 'N'
        then w_char_26_new := '5';
     elsif w_char_26_old = 'O'
        then w_char_26_new := '6';
     elsif w_char_26_old = 'P'
        then w_char_26_new := '7';
     elsif w_char_26_old = 'Q'
        then w_char_26_new := '8';
     elsif w_char_26_old = 'R'
        then w_char_26_new := '9';
     end if;
    else
         w_char_67_new:=3;
     if w_char_26_old = 'S'
        then w_char_26_new := '1';
     elsif w_char_26_old = 'T'
        then w_char_26_new := '2';
     elsif w_char_26_old = 'U'
        then w_char_26_new := '3';
     elsif w_char_26_old = 'V'
        then w_char_26_new := '4';
     elsif w_char_26_old = 'W'
        then w_char_26_new := '5';
     elsif w_char_26_old = 'X'
        then w_char_26_new := '6';
     elsif w_char_26_old = 'Y'
        then w_char_26_new := '7';
     elsif w_char_26_old = 'Z'
        then w_char_26_new := '9';     -- Mod 1.0.056
     end if;
    end if;
    w_new_scan_string:=substr(scanString,1,25)||w_char_26_new||substr(scanString,27,40)||w_char_67_new||substr(scanString,68,1);
    w_check_digit := phls0001.get_check_digit(w_new_scan_string);
    w_new_scan_string:=substr(scanString,1,25)||w_char_26_new||substr(scanString,27,40)||w_char_67_new||w_check_digit;
    --
    -- Report variable
    --
    return (w_new_scan_string);
 end scan_string_group_bill;
 /*************************************************************************************\
    private procedure bg_shut_off_print_headings  Add 1.0.0.28
 \*************************************************************************************/
 procedure bg_shut_off_print_headings is
    w_procedure_name              varchar2(40) := 'phls0001.bg_shut_off_print_headings';
    -- Shutoff notice sorts by addr line 5
    -- 1.0.0.40 -- It will ensure header line is first line for the shut-off bill
    w_lv_addr5                    phl_tmg_shutoffnotice.mail_addr_line5%type    := chr('00'); --'00000';  --1.0.0.40
 begin
    trace_label('e304', w_procedure_name);
    w_ptsh := null;
    w_ptsh.mail_addr_line5 := w_lv_addr5;
    w_ptsh.background_print_string :=
                          'account_number'
             || '|' ||    'bill_number'
             || '|' ||    'owner_name'
             || '|' ||    'service_address'
             || '|' ||    'mail_addr_line1'
             || '|' ||    'mail_addr_line2'
             || '|' ||    'mail_addr_line3'
             || '|' ||    'mail_addr_line4'
             || '|' ||    'mail_addr_line5'
             || '|' ||    'district_number'
             || '|' ||    'shutoff_date'
             || '|' ||    'last_payment_date'
             || '|' ||    'scan_line'
             || '|' ||    'sewer_percent1'
             || '|' ||    'sewer_percent2'
             || '|' ||    'sewer_percent3'
             || '|' ||    'sewer_percent4'
             || '|' ||    'sewer_percent5'
             || '|' ||    'sewer_percent6'
             || '|' ||    'sewer_percent7'
             || '|' ||    'sewer_percent8'
             || '|' ||    'cycle1'
             || '|' ||    'cycle2'
             || '|' ||    'cycle3'
             || '|' ||    'cycle4'
             || '|' ||    'cycle5'
             || '|' ||    'cycle6'
             || '|' ||    'cycle7'
             || '|' ||    'cycle8'
             || '|' ||    'service_code1'
             || '|' ||    'service_code2'
             || '|' ||    'service_code3'
             || '|' ||    'service_code4'
             || '|' ||    'service_code5'
             || '|' ||    'service_code6'
             || '|' ||    'service_code7'
             || '|' ||    'service_code8'
             || '|' ||    'ar_code1'
             || '|' ||    'ar_code2'
             || '|' ||    'ar_code3'
             || '|' ||    'ar_code4'
             || '|' ||    'ar_code5'
             || '|' ||    'ar_code6'
             || '|' ||    'ar_code7'
             || '|' ||    'ar_code8'
             || '|' ||    'principal1'
             || '|' ||    'principal2'
             || '|' ||    'principal3'
             || '|' ||    'principal4'
             || '|' ||    'principal5'
             || '|' ||    'principal6'
             || '|' ||    'principal7'
             || '|' ||    'principal8'
             || '|' ||    'penalty1'
             || '|' ||    'penalty2'
             || '|' ||    'penalty3'
             || '|' ||    'penalty4'
             || '|' ||    'penalty5'
             || '|' ||    'penalty6'
             || '|' ||    'penalty7'
             || '|' ||    'penalty8'
             || '|' ||    'ar_total1'
             || '|' ||    'ar_total2'
             || '|' ||    'ar_total3'
             || '|' ||    'ar_total4'
             || '|' ||    'ar_total5'
             || '|' ||    'ar_total6'
             || '|' ||    'ar_total7'
             || '|' ||    'ar_total8'
             || '|' ||    'tot_bill_amt'
             || '|' ||    'msg_line'
             || '|' ||    'wtr_access_code' --Add 7080
             ;
 end bg_shut_off_print_headings;
                                                                                          --Del 1.0.0.24   -- Chg Back 1.0.0.28
 /*************************************************************************************\
    private procedure bg_shut_off_print_string
 \*************************************************************************************/
 procedure bg_shut_off_print_string is
    w_procedure_name              varchar2(40) := 'phls0001.bg_shut_off_print_string';
 begin
       trace_label('e305', w_procedure_name);
       w_ptsh.background_print_string :=                                                    -- Chg 1.0.0.10
                          trim(w_ptsh.account_number)
             || '|' ||    w_ptsh.bill_number
             || '|' ||    trim(w_ptsh.owner_name)
             || '|' ||    trim(w_ptsh.service_address)
             || '|' ||    trim(w_ptsh.mail_addr_line1)
             || '|' ||    trim(w_ptsh.mail_addr_line2)
             || '|' ||    trim(w_ptsh.mail_addr_line3)
             || '|' ||    trim(w_ptsh.mail_addr_line4)
             || '|' ||    trim(w_ptsh.mail_addr_line5)
             || '|' ||    trim(w_ptsh.district_number)
             || '|' ||    to_char(w_ptsh.shutoff_date,'MM/DD/YYYY')
             || '|' ||    to_char(w_ptsh.last_payment_date,'MM/DD/YY')
             || '|' ||    trim(w_ptsh.scan_line)
             || '|' ||    trim(w_ptsh.sewer_percent1)
             || '|' ||    trim(w_ptsh.sewer_percent2)
             || '|' ||    trim(w_ptsh.sewer_percent3)
             || '|' ||    trim(w_ptsh.sewer_percent4)
             || '|' ||    trim(w_ptsh.sewer_percent5)
             || '|' ||    trim(w_ptsh.sewer_percent6)
             || '|' ||    trim(w_ptsh.sewer_percent7)
             || '|' ||    trim(w_ptsh.sewer_percent8)
             || '|' ||    trim(w_ptsh.cycle1)
             || '|' ||    trim(w_ptsh.cycle2)
             || '|' ||    trim(w_ptsh.cycle3)
             || '|' ||    trim(w_ptsh.cycle4)
             || '|' ||    trim(w_ptsh.cycle5)
             || '|' ||    trim(w_ptsh.cycle6)
             || '|' ||    trim(w_ptsh.cycle7)
             || '|' ||    trim(w_ptsh.cycle8)
             || '|' ||    trim(w_ptsh.service_code1)
             || '|' ||    trim(w_ptsh.service_code2)
             || '|' ||    trim(w_ptsh.service_code3)
             || '|' ||    trim(w_ptsh.service_code4)
             || '|' ||    trim(w_ptsh.service_code5)
             || '|' ||    trim(w_ptsh.service_code6)
             || '|' ||    trim(w_ptsh.service_code7)
             || '|' ||    trim(w_ptsh.service_code8)
             || '|' ||    trim(w_ptsh.ar_code1)
             || '|' ||    trim(w_ptsh.ar_code2)
             || '|' ||    trim(w_ptsh.ar_code3)
             || '|' ||    trim(w_ptsh.ar_code4)
             || '|' ||    trim(w_ptsh.ar_code5)
             || '|' ||    trim(w_ptsh.ar_code6)
             || '|' ||    trim(w_ptsh.ar_code7)
             || '|' ||    trim(w_ptsh.ar_code8)
             || '|' ||    trim(to_char(w_ptsh.principal1,'99999990.00'))   --1.0.0.16
             || '|' ||    trim(to_char(w_ptsh.principal2,'99999990.00'))   --1.0.0.16
             || '|' ||    trim(to_char(w_ptsh.principal3,'99999990.00'))   --1.0.0.16
             || '|' ||    trim(to_char(w_ptsh.principal4,'99999990.00'))   --1.0.0.16
             || '|' ||    trim(to_char(w_ptsh.principal5,'99999990.00'))   --1.0.0.16
             || '|' ||    trim(to_char(w_ptsh.principal6,'99999990.00'))   --1.0.0.16
             || '|' ||    trim(to_char(w_ptsh.principal7,'99999990.00'))   --1.0.0.16
             || '|' ||    trim(to_char(w_ptsh.principal8,'99999990.00'))   --1.0.0.16
             || '|' ||    trim(to_char(w_ptsh.penalty1,'99999990.00'))     --1.0.0.16
             || '|' ||    trim(to_char(w_ptsh.penalty2,'99999990.00'))     --1.0.0.16
             || '|' ||    trim(to_char(w_ptsh.penalty3,'99999990.00'))     --1.0.0.16
             || '|' ||    trim(to_char(w_ptsh.penalty4,'99999990.00'))     --1.0.0.16
             || '|' ||    trim(to_char(w_ptsh.penalty5,'99999990.00'))     --1.0.0.16
             || '|' ||    trim(to_char(w_ptsh.penalty6,'99999990.00'))     --1.0.0.16
             || '|' ||    trim(to_char(w_ptsh.penalty7,'99999990.00'))     --1.0.0.16
             || '|' ||    trim(to_char(w_ptsh.penalty8,'99999990.00'))     --1.0.0.16
             || '|' ||    trim(to_char(w_ptsh.ar_total1,'99999990.00'))    --1.0.0.16
             || '|' ||    trim(to_char(w_ptsh.ar_total2,'99999990.00'))    --1.0.0.16
             || '|' ||    trim(to_char(w_ptsh.ar_total3,'99999990.00'))    --1.0.0.16
             || '|' ||    trim(to_char(w_ptsh.ar_total4,'99999990.00'))    --1.0.0.16
             || '|' ||    trim(to_char(w_ptsh.ar_total5,'99999990.00'))    --1.0.0.16
             || '|' ||    trim(to_char(w_ptsh.ar_total6,'99999990.00'))    --1.0.0.16
             || '|' ||    trim(to_char(w_ptsh.ar_total7,'99999990.00'))    --1.0.0.16
             || '|' ||    trim(to_char(w_ptsh.ar_total8,'99999990.00'))    --1.0.0.16
             || '|' ||    trim(to_char(w_ptsh.tot_bill_amt,'99999990.00')) --1.0.0.16
             || '|' ||    trim(w_ptsh.msg_line)
             || '|' ||    trim(g_wtr_access_code);												 --Add 7080
 end bg_shut_off_print_string;
                                                        --Del 1.0.0.24    -- Chg Back 1.0.0.28
 /*************************************************************************************\
    private procedure inst_phl_tmg_shutoffnotice
 \*************************************************************************************/
 procedure ins_phl_tmg_shutoffnotice is
     w_procedure_name              varchar2(40) := 'phls0001.ins_phl_tmg_shutoffnotice';
 begin
    trace_label('e306', w_procedure_name);
    debug_trace(w_procedure_name,'w_ptsh.process_id              '  || w_ptsh.process_id              );     --Add Ticket 3407   version 2.0.0.80
    debug_trace(w_procedure_name,'w_ptsh.account_number          '  || w_ptsh.account_number          );
    debug_trace(w_procedure_name,'w_ptsh.bill_number             '  || w_ptsh.bill_number             );
    debug_trace(w_procedure_name,'w_ptsh.owner_name              '  || w_ptsh.owner_name              );
    debug_trace(w_procedure_name,'w_ptsh.service_address         '  || w_ptsh.service_address         );
    debug_trace(w_procedure_name,'w_ptsh.mail_addr_line1         '  || w_ptsh.mail_addr_line1         );
    debug_trace(w_procedure_name,'w_ptsh.mail_addr_line2         '  || w_ptsh.mail_addr_line2         );
    debug_trace(w_procedure_name,'w_ptsh.mail_addr_line3         '  || w_ptsh.mail_addr_line3         );
    debug_trace(w_procedure_name,'w_ptsh.mail_addr_line4         '  || w_ptsh.mail_addr_line4         );
    debug_trace(w_procedure_name,'w_ptsh.mail_addr_line5         '  || w_ptsh.mail_addr_line5         );
    debug_trace(w_procedure_name,'w_ptsh.district_number         '  || w_ptsh.district_number         );
    debug_trace(w_procedure_name,'w_ptsh.shutoff_date            '  || datec(w_ptsh.shutoff_date)     );
    debug_trace(w_procedure_name,'w_ptsh.last_payment_date       '  || datec(w_ptsh.last_payment_date));
    debug_trace(w_procedure_name,'w_ptsh.scan_line               '  || w_ptsh.scan_line               );
    debug_trace(w_procedure_name,'w_ptsh.sewer_percent1          '  || w_ptsh.sewer_percent1          );
    debug_trace(w_procedure_name,'w_ptsh.sewer_percent2          '  || w_ptsh.sewer_percent2          );
    debug_trace(w_procedure_name,'w_ptsh.sewer_percent3          '  || w_ptsh.sewer_percent3          );
    debug_trace(w_procedure_name,'w_ptsh.sewer_percent4          '  || w_ptsh.sewer_percent4          );
    debug_trace(w_procedure_name,'w_ptsh.sewer_percent5          '  || w_ptsh.sewer_percent5          );
    debug_trace(w_procedure_name,'w_ptsh.sewer_percent6          '  || w_ptsh.sewer_percent6          );
    debug_trace(w_procedure_name,'w_ptsh.sewer_percent7          '  || w_ptsh.sewer_percent7          );
    debug_trace(w_procedure_name,'w_ptsh.sewer_percent8          '  || w_ptsh.sewer_percent8          );
    debug_trace(w_procedure_name,'w_ptsh.cycle1                  '  || w_ptsh.cycle1                  );
    debug_trace(w_procedure_name,'w_ptsh.cycle2                  '  || w_ptsh.cycle2                  );
    debug_trace(w_procedure_name,'w_ptsh.cycle3                  '  || w_ptsh.cycle3                  );
    debug_trace(w_procedure_name,'w_ptsh.cycle4                  '  || w_ptsh.cycle4                  );
    debug_trace(w_procedure_name,'w_ptsh.cycle5                  '  || w_ptsh.cycle5                  );
    debug_trace(w_procedure_name,'w_ptsh.cycle6                  '  || w_ptsh.cycle6                  );
    debug_trace(w_procedure_name,'w_ptsh.cycle7                  '  || w_ptsh.cycle7                  );
    debug_trace(w_procedure_name,'w_ptsh.cycle8                  '  || w_ptsh.cycle8                  );
    debug_trace(w_procedure_name,'w_ptsh.service_code1           '  || w_ptsh.service_code1           );
    debug_trace(w_procedure_name,'w_ptsh.service_code2           '  || w_ptsh.service_code2           );
    debug_trace(w_procedure_name,'w_ptsh.service_code3           '  || w_ptsh.service_code3           );
    debug_trace(w_procedure_name,'w_ptsh.service_code4           '  || w_ptsh.service_code4           );
    debug_trace(w_procedure_name,'w_ptsh.service_code5           '  || w_ptsh.service_code5           );
    debug_trace(w_procedure_name,'w_ptsh.service_code6           '  || w_ptsh.service_code6           );
    debug_trace(w_procedure_name,'w_ptsh.service_code7           '  || w_ptsh.service_code7           );
    debug_trace(w_procedure_name,'w_ptsh.service_code8           '  || w_ptsh.service_code8           );
    debug_trace(w_procedure_name,'w_ptsh.ar_code1                '  || w_ptsh.ar_code1                );
    debug_trace(w_procedure_name,'w_ptsh.ar_code2                '  || w_ptsh.ar_code2                );
    debug_trace(w_procedure_name,'w_ptsh.ar_code3                '  || w_ptsh.ar_code3                );
    debug_trace(w_procedure_name,'w_ptsh.ar_code4                '  || w_ptsh.ar_code4                );
    debug_trace(w_procedure_name,'w_ptsh.ar_code5                '  || w_ptsh.ar_code5                );
    debug_trace(w_procedure_name,'w_ptsh.ar_code6                '  || w_ptsh.ar_code6                );
    debug_trace(w_procedure_name,'w_ptsh.ar_code7                '  || w_ptsh.ar_code7                );
    debug_trace(w_procedure_name,'w_ptsh.ar_code8                '  || w_ptsh.ar_code8                );
    debug_trace(w_procedure_name,'w_ptsh.principal1              '  || w_ptsh.principal1              );
    debug_trace(w_procedure_name,'w_ptsh.principal2              '  || w_ptsh.principal2              );
    debug_trace(w_procedure_name,'w_ptsh.principal3              '  || w_ptsh.principal3              );
    debug_trace(w_procedure_name,'w_ptsh.principal4              '  || w_ptsh.principal4              );
    debug_trace(w_procedure_name,'w_ptsh.principal5              '  || w_ptsh.principal5              );
    debug_trace(w_procedure_name,'w_ptsh.principal6              '  || w_ptsh.principal6              );
    debug_trace(w_procedure_name,'w_ptsh.principal7              '  || w_ptsh.principal7              );
    debug_trace(w_procedure_name,'w_ptsh.principal8              '  || w_ptsh.principal8              );
    debug_trace(w_procedure_name,'w_ptsh.penalty1                '  || w_ptsh.penalty1                );
    debug_trace(w_procedure_name,'w_ptsh.penalty2                '  || w_ptsh.penalty2                );
    debug_trace(w_procedure_name,'w_ptsh.penalty3                '  || w_ptsh.penalty3                );
    debug_trace(w_procedure_name,'w_ptsh.penalty4                '  || w_ptsh.penalty4                );
    debug_trace(w_procedure_name,'w_ptsh.penalty5                '  || w_ptsh.penalty5                );
    debug_trace(w_procedure_name,'w_ptsh.penalty6                '  || w_ptsh.penalty6                );
    debug_trace(w_procedure_name,'w_ptsh.penalty7                '  || w_ptsh.penalty7                );
    debug_trace(w_procedure_name,'w_ptsh.penalty8                '  || w_ptsh.penalty8                );
    debug_trace(w_procedure_name,'w_ptsh.ar_total1               '  || w_ptsh.ar_total1               );
    debug_trace(w_procedure_name,'w_ptsh.ar_total2               '  || w_ptsh.ar_total2               );
    debug_trace(w_procedure_name,'w_ptsh.ar_total3               '  || w_ptsh.ar_total3               );
    debug_trace(w_procedure_name,'w_ptsh.ar_total4               '  || w_ptsh.ar_total4               );
    debug_trace(w_procedure_name,'w_ptsh.ar_total5               '  || w_ptsh.ar_total5               );
    debug_trace(w_procedure_name,'w_ptsh.ar_total6               '  || w_ptsh.ar_total6               );
    debug_trace(w_procedure_name,'w_ptsh.ar_total7               '  || w_ptsh.ar_total7               );
    debug_trace(w_procedure_name,'w_ptsh.ar_total8               '  || w_ptsh.ar_total8               );
    debug_trace(w_procedure_name,'w_ptsh.tot_bill_amt            '  || w_ptsh.tot_bill_amt            );
    debug_trace(w_procedure_name,'w_ptsh.msg_line                '  || w_ptsh.msg_line                );
    debug_trace(w_procedure_name,'w_ptsh.background_print_string '  || w_ptsh.background_print_string );
    debug_trace(w_procedure_name,'g_wtr_access_code '  || g_wtr_access_code ); --7080
    insert into phl_tmg_shutoffnotice
    (
     process_id                                           --Add Ticket 3407   version 2.0.0.80
    ,account_number
    ,bill_number
    ,owner_name
    ,service_address
    ,mail_addr_line1
    ,mail_addr_line2
    ,mail_addr_line3
    ,mail_addr_line4
    ,mail_addr_line5
    ,district_number
    ,shutoff_date
    ,last_payment_date
    ,scan_line
    ,sewer_percent1
    ,sewer_percent2
    ,sewer_percent3
    ,sewer_percent4
    ,sewer_percent5
    ,sewer_percent6
 ,sewer_percent7
 ,sewer_percent8
 ,cycle1
 ,cycle2
 ,cycle3
 ,cycle4
 ,cycle5
 ,cycle6
 ,cycle7
 ,cycle8
 ,service_code1
 ,service_code2
 ,service_code3
 ,service_code4
 ,service_code5
 ,service_code6
 ,service_code7
 ,service_code8
 ,ar_code1
 ,ar_code2
 ,ar_code3
 ,ar_code4
 ,ar_code5
 ,ar_code6
 ,ar_code7
 ,ar_code8
 ,principal1
 ,principal2
 ,principal3
 ,principal4
 ,principal5
 ,principal6
 ,principal7
 ,principal8
 ,penalty1
 ,penalty2
 ,penalty3
 ,penalty4
 ,penalty5
 ,penalty6
 ,penalty7
 ,penalty8
 ,ar_total1
 ,ar_total2
 ,ar_total3
 ,ar_total4
 ,ar_total5
 ,ar_total6
 ,ar_total7
 ,ar_total8
 ,tot_bill_amt
 ,msg_line
 ,background_print_string
 )
 values
 (
  w_ptsh.process_id                         --Add Ticket 3407   version 2.0.0.80
 ,w_ptsh.account_number
 ,w_ptsh.bill_number
 ,w_ptsh.owner_name
 ,w_ptsh.service_address
 ,w_ptsh.mail_addr_line1
 ,w_ptsh.mail_addr_line2
 ,w_ptsh.mail_addr_line3
 ,w_ptsh.mail_addr_line4
 ,w_ptsh.mail_addr_line5
 ,w_ptsh.district_number
 ,w_ptsh.shutoff_date
 ,w_ptsh.last_payment_date
 ,w_ptsh.scan_line
 ,w_ptsh.sewer_percent1
 ,w_ptsh.sewer_percent2
 ,w_ptsh.sewer_percent3
 ,w_ptsh.sewer_percent4
 ,w_ptsh.sewer_percent5
 ,w_ptsh.sewer_percent6
 ,w_ptsh.sewer_percent7
 ,w_ptsh.sewer_percent8
 ,w_ptsh.cycle1
 ,w_ptsh.cycle2
 ,w_ptsh.cycle3
 ,w_ptsh.cycle4
 ,w_ptsh.cycle5
 ,w_ptsh.cycle6
 ,w_ptsh.cycle7
 ,w_ptsh.cycle8
 ,w_ptsh.service_code1
 ,w_ptsh.service_code2
 ,w_ptsh.service_code3
 ,w_ptsh.service_code4
 ,w_ptsh.service_code5
 ,w_ptsh.service_code6
 ,w_ptsh.service_code7
 ,w_ptsh.service_code8
 ,w_ptsh.ar_code1
 ,w_ptsh.ar_code2
 ,w_ptsh.ar_code3
 ,w_ptsh.ar_code4
 ,w_ptsh.ar_code5
 ,w_ptsh.ar_code6
 ,w_ptsh.ar_code7
 ,w_ptsh.ar_code8
 ,w_ptsh.principal1
 ,w_ptsh.principal2
 ,w_ptsh.principal3
 ,w_ptsh.principal4
 ,w_ptsh.principal5
 ,w_ptsh.principal6
 ,w_ptsh.principal7
 ,w_ptsh.principal8
 ,w_ptsh.penalty1
 ,w_ptsh.penalty2
 ,w_ptsh.penalty3
 ,w_ptsh.penalty4
 ,w_ptsh.penalty5
 ,w_ptsh.penalty6
 ,w_ptsh.penalty7
 ,w_ptsh.penalty8
 ,w_ptsh.ar_total1
 ,w_ptsh.ar_total2
 ,w_ptsh.ar_total3
 ,w_ptsh.ar_total4
 ,w_ptsh.ar_total5
 ,w_ptsh.ar_total6
 ,w_ptsh.ar_total7
 ,w_ptsh.ar_total8
 ,w_ptsh.tot_bill_amt
 ,w_ptsh.msg_line
 ,w_ptsh.background_print_string
 );
 end ins_phl_tmg_shutoffnotice;
                                                           --Del 1.0.0.24    -- Chg Back 1.0.0.28
 /*************************************************************************************\
    private procedure scan_string_shut_off
 \*************************************************************************************/
 procedure scan_string_shut_off
 is
       w_procedure_name              varchar2(40) := 'phls0001.scan_string_shut_off';
       w_ptsh_check_digit            varchar2(1);
 begin
       w_label := 'e307';
 --     w_ptsh_acct_number             := trim(lpad(substr(w_ptsh.account_number,4),13,'0'));   -- Del 1.0.0.17A
       w_ptsh_acct_number             := trim(lpad(substr(w_city_acct_new_suffix,4),13,'0'));    -- Add 1.0.0.17A
       w_ptsh_tot_bill                := trim(lpad(replace(to_char(w_ptsh.tot_bill_amt),'.',''),10,'0'));
       w_ptsh_tot_principal           := trim(lpad(replace(to_char(nvl(w_ptsh.principal1,0) +
                                                           nvl(w_ptsh.principal2,0) +
                                                           nvl(w_ptsh.principal3,0) +
                                                           nvl(w_ptsh.principal4,0) +
                                                           nvl(w_ptsh.principal5,0) +
                                                           nvl(w_ptsh.principal6,0) +
                                                           nvl(w_ptsh.principal7,0) +
                                                           nvl(w_ptsh.principal8,0)),'.',''),10,'0'));
       w_ptsh_control_day             := trim(lpad(substr(w_ptsh.account_number,1,3),3,'0'));
                                                                           -- Posns -- Count
       w_ptsh_scan_string :=
          '333'                                                   -- 01-03 == 03         FIXED STRING
       || '72'                                                    -- 04-05 == 02         FIXED WATER BILL
       || '0000009990'                                            -- 06-15 == 10         FIXED SHUT-OFF
       || w_ptsh_acct_number                                      -- 16-28 == 13         ACCOUNT NUMBER
       || w_ptsh_29thchar                                         -- 29-29 == 01         FIXED NUMBER
       || w_ptsh_tot_bill                                         -- 30-39 == 10         TOTAL BILL AMOUNT
       || w_ptsh_tot_principal                                    -- 40-49 == 10         TOTAL PRINCIPAL AMOUNT
       || w_ptsh_control_day                                      -- 50-52 == 03         CONTROL_DUE
       || '0000'                                                  -- 53-56 == 04         FIXED STRING
       || w_ptsh_last_twelve;                                     -- 57-68 == 12         FIXED STRING
       w_ptsh_check_digit := get_check_digit(w_ptsh_scan_string);
 --      w_ptsh_scan_string := substr(w_ppln_scan_string,1,67) || to_char(w_ptsh_check_digit);   -- Del 1.0.0.17A
       w_ptsh_scan_string := substr(w_ptsh_scan_string,1,66)                           -- Chg 1.0.0.17A
                          || w_city_acct_new_67                                        -- Add 1.0.0.17A
                          || to_char(w_ptsh_check_digit);                              -- Add 1.0.0.17A
       debug_trace(w_procedure_name,'...w_ptsh_acct_number   =' || w_ptsh_acct_number);
       debug_trace(w_procedure_name,'...w_ptsh_tot_bill      =' || w_ptsh_tot_bill);
       debug_trace(w_procedure_name,'...w_ptsh_tot_principal =' || w_ptsh_tot_principal);
       debug_trace(w_procedure_name,'...w_ptsh_control_day   =' || w_ptsh_control_day);
       debug_trace(w_procedure_name,'...scan_string          =' || w_ptsh_scan_string);
       --
       -- Report variable
       --
       w_ptsh.scan_line :=  trim(w_ptsh_scan_string);
       w_label := 'e308';
       --
       -- Report Variable for output file
       --
       bg_shut_off_print_string;
 end scan_string_shut_off;
                                                  --Del 1.0.0.24   -- Chg Back 1.0.0.28
 /*************************************************************************************\
    private procedure get_shut_off_details
 \*************************************************************************************/
 procedure get_shut_off_details is
    w_procedure_name              varchar2(40) := 'phls0001.get_shut_off_details';
    w_c2_cntr                     number := 0;
    w_owner_cust_id               cis_installations.owner_cust_id%type;
    w_tenn_cust_id                cis_installations.tenn_cust_id%type;
    w_prop_addr_id                cis_installations.prop_addr_id%type;
    w_mail_addr_id                cis_accounts.mail_addr_id%type;
    w_service_code_inst           char(2);
    w_service_code_cust           char(1);
    w_bill_number                 number := 0;
    w_arrear_inst_id              cis_installations.inst_id%type;
    w_arrear_supply_type          cis_accounts.supply_type%type;
    w_arrears_b2_acct_key         cis_accounts.acct_key%type;                       -- Add 5659
    w_errbuf                      varchar2(1500);                                   -- Add 5659
    w_retcode                     number;                                           -- Add 5659
    w_count_shutreq               number;                                           -- Add 5659
    w_cur_sid                     varchar2(30);                                     -- Add 5659
    wc_dev_qa_sid_str             varchar2(30) := 'WDEV2, WQA';                     -- Add 5659
    w_ptsh_result                 varchar2(1);
    w_ptsh_message                varchar2(300);
    w_sofar                       number;                                           -- Add 1.0.0.25
    w_progress                    varchar2(300);                                    -- Add 1.0.0.25
    w_ptsh_service_code           varchar2(3);                                      -- Add 1.0.0.30
    w_event_count                 number;                                           -- Add 1.0.0.33
    w_mail_name                   varchar2(29);                                     -- Add 1.0.0.34
    w_owner_name                  varchar2(29);                                     -- Add 1.0.0.34
    w_occupier_name               varchar2(29);                                     -- Add 4956
    w_arrears_run_date            cis_tmp_arrears_summary.arrears_run_date%type;       -- Add 1.0.0.41
    w_pay_at_once_bal             phl_tmg_shutoffnotice.tot_bill_amt%type;          -- Add 2124/2265
    w_vacant_balance              cis_debt_collection.debt_bal_amnt%type;           -- Add 2124/2265
    cursor c1 is
    select
       mwos.meter_work_date
      ,mwos.work_type
      ,mwos.meter_work_status
      ,arrs.acct_id
      ,arrs.acct_key
      ,arrs.cust_id
      ,arrs.cust_key
      ,arrs.cust_name
      ,arrs.cust_type_code
      ,arrs.letter_code
      ,arrs.inst_id
      ,arrs.inst_key
      ,arrs.supply_type
      ,arrs.arrears_run_date                                            -- Add 1263
      ,arrs.acct_bal_amnt
      ,sum(arrs.overdue_amnt) overdue_amnt                              -- Chg 1263        -- Chg 1255
 --     ,arrs.arrears_process_id                                        -- Del 1263
 --     ,arrs.tars_id                                                   -- Add 1.0.0.34  -- Del 1263
 --     ,arrs.arrears_run_date                                          -- Add 1.0.0.41  -- Del 1263
    from
     cis_tmp_arrears_summary   arrs
    ,cis_meter_wos             mwos
    ,cis_installations         inst                                     -- Add 1.0.0.28
    ,cis_accounts              acct                                     -- Add 1255
    where arrs.arrears_process_id = w_arrears_process_id
      and mwos.work_type          = 'SHUT-OFF'
      and mwos.meter_work_status not in ('C', 'X')                      -- Add 1.0.0.37
      and mwos.meter_work_date < sysdate + 365                          -- Add 1.0.0.37
      and inst.inst_id         = arrs.inst_id                           -- Add 1.0.0.28
      and inst.attribute28     = mwos.meter_works_id                    -- Add 1.0.0.28
      and arrs.letter_code     in ('SHUTCST1','WRBCC-2')                                                      -- Add 8616
--      and arrs.letter_code     in ('SHUTCST1','SHUTCST2','WRBCC-2')     -- Mod 2514 'WRBCC-2' Add 1.0.0.53  -- Del 8616
 --     and arrs.letter_code     like 'SHUT%'                           -- Del 1.0.0.53 Add 1.0.0.33
 --     and arrs.letter_code  <> 'SHUTSTRT'                             -- Del 1.0.0.53 Add 1.0.0.37
      and arrs.supply_type  <> 'PRINTED'                                -- Add 1.0.0.33
      and arrs.copy_for_3rd_party_ind is null                           -- Add 4956
      and  ( inst.owner_cust_id is not null                             -- Add 1.0.0.34
          or inst.tenn_cust_id is not null)                             -- Add 1.0.0.34
      and nvl(inst.revu1_code, 'x') not like 'NB%'                      -- Add 1.0.0.34
      and acct.acct_id = arrs.acct_id                                   -- Add 1255
      and acct.acct_status = 'C'                                        -- Add 1255
 /*                                                                     -- Del this block 1.0.0.33
      and (
           (arrs.letter_set_code = 'RES-STDL' and  arrs.letter_no = 4)  -- Add 1.0.0.24 Residential
          or
           (arrs.letter_set_code = 'COM-STDL' and  arrs.letter_no = 3)  -- Add 1.0.0.24 Commercial
          )
 */
      -- and mwos.meter_work_status  != 'C'              -- Del 1.0.0.28
      -- and arrs.letter_code        = w_letter_code     -- Del 1.0.0.24-- Deliberately not changed as incorrect
      -- Start Add 1263
    group by
       mwos.meter_work_date
      ,mwos.work_type
      ,mwos.meter_work_status
      ,arrs.acct_id
      ,arrs.acct_key
      ,arrs.cust_id
      ,arrs.cust_key
      ,arrs.cust_name
      ,arrs.cust_type_code
      ,arrs.letter_code
      ,arrs.inst_id
      ,arrs.inst_key
      ,arrs.supply_type
      ,arrs.arrears_run_date
      ,arrs.acct_bal_amnt
      -- End Add 1263
      ;
    cursor c2
    is
    select
        sum(decode(substr(task_code,1,5),'PNLTY',tran_bal_amnt * acct_sign,0 )) PENALTY
       ,sum(decode(substr(task_code,1,5),'PNLTY',0,tran_bal_amnt * acct_sign )) PRINCIPAL
       ,to_char(tran_date,'YY-MM')                                              CYCLE
       ,to_char(tran_date,'YYYY-MM')                                            CYCLE4Y
    from
       cis_transactions
    where fully_reversed_ind is null
      and trim(dispute_code) is null                                -- add 3904
      and inst_id     = w_arrear_inst_id
      and supply_type = w_arrear_supply_type
--    and nvl(ifce_status_code, 'x')<>'OLD-BNKR'                    -- Add version 2.0.0.77 for BugID#2137 -- Del 2.0.0.85 TTID 3624
--    and nvl(ifce_status_code, 'x') not like 'BNKRPT%'             -- Add 1.0.0.34   -- Del 2.0.0.85 TTID 3624
      and tran_bal_amnt > 0
 --     and cust_id in (w_owner_cust_id, w_tenn_cust_id)            -- Del 1.0.0.54   -- Add 1.0.0.32
      and cust_id = w_cust_id                                       -- Add 1.0.0.54
-- *** START *** ADD 2.0.0.85 TTID 3624
      and (debt_coll_id_1 is null
      or not exists (select 'X' from cis_debt_collection x
      where debt_coll_id_1 = x.debt_coll_id
      and (x.debt_coll_path = 'OLD-BNKR'
      or x.debt_coll_path like 'TAP%'   --## Add 8936 08/28/29 ####
      or (x.debt_coll_path like 'BNKRPT%'
           and x.debt_coll_stage <> 'DISMISSD'))))
-- *** END *** ADD 2.0.0.85 TTID 3624
    group by to_char(tran_date,'YY-MM')
            ,to_char(tran_date,'YYYY-MM')                           -- Add 1.0.0.34
    order by to_char(tran_date,'YYYY-MM') desc                      -- Add 1.0.0.34
            ,to_char(tran_date,'YY-MM') desc;
    /** Start Del 5659
    -- start Add 4956
    --cursor c3 is
    --select
    --   mwos.meter_work_date
    --  ,mwos.work_type
    --  ,mwos.meter_work_status
    --  ,arrs.acct_id
    --  ,arrs.acct_key
    --  ,arrs.cust_id
    --  ,arrs.cust_key
    --  ,arrs.cust_name
    --  ,arrs.cust_type_code
    --  ,arrs.letter_code
    --  ,arrs.inst_id
    --  ,arrs.inst_key
    --  ,arrs.supply_type
    --  ,arrs.arrears_run_date
    --  ,arrs.acct_bal_amnt
    --  ,arrs.cust_name_3rd_party
    --  ,arrs.mail_addr_id
    --  ,sum(arrs.overdue_amnt) overdue_amnt
    --from
    -- cis_tmp_arrears_summary   arrs
    --,cis_meter_wos             mwos
    --,cis_installations         inst
    --,cis_accounts              acct
    --where arrs.arrears_process_id = w_arrears_process_id
    --  and mwos.work_type          = 'SHUT-OFF'
    --  and mwos.meter_work_status not in ('C', 'X')
    --  and mwos.meter_work_date < sysdate + 365
    --  and inst.inst_id         = arrs.inst_id
    --  and inst.attribute28     = mwos.meter_works_id
    --  and arrs.letter_code     in ('SHUTCST1','SHUTCST2','WRBCC-2')
    --  and arrs.supply_type  <> 'PRINTED'
    --  and arrs.copy_for_3rd_party_ind = 'Y'
    --  and  ( inst.owner_cust_id is not null
    --      or inst.tenn_cust_id is not null)
    --  and nvl(inst.revu1_code, 'x') not like 'NB%'
    --  and acct.acct_id = arrs.acct_id
    --  and acct.acct_status = 'C'
    --group by
    --   mwos.meter_work_date
    --  ,mwos.work_type
    --  ,mwos.meter_work_status
    --  ,arrs.acct_id
    --  ,arrs.acct_key
    --  ,arrs.cust_id
    --  ,arrs.cust_key
    --  ,arrs.cust_name
    --  ,arrs.cust_type_code
    --  ,arrs.letter_code
    --  ,arrs.inst_id
    --  ,arrs.inst_key
    --  ,arrs.supply_type
    --  ,arrs.arrears_run_date
    --  ,arrs.acct_bal_amnt
    --  ,arrs.cust_name_3rd_party
    --  ,arrs.mail_addr_id
    --  ;
    ---- end Add 4956
    -- End Del 5659 */
    -- Start Add 5659
    -- New cursor to only get 3rd party address details for the current c1 account record
    -- This runs within c1 cursor loop so must match values selected in c1 cursor.
    cursor c3 is  -- 3rd party address details
    SELECT
        arrs.acct_key
        ,arrs.copy_for_3rd_party_ind
        ,arrs.cust_name_3rd_party
        ,arrs.mail_addr_id
        ,arrs.tars_id
        ,mad.line1
        ,mad.line2
        ,mad.line3
        ,mad.line4
        ,mad.line5
        ,mad.line6
        ,mad.line7
        ,mad.line8
        ,mad.address4 -- Mailing Name
    FROM cis_tmp_arrears_summary arrs
        ,cis_addresses mad
    WHERE arrs.arrears_process_id = w_arrears_process_id
      AND arrs.acct_key = w_arrears_b2_acct_key       -- acct selected in c1 loop
      and arrs.letter_code   = w_letter_code          -- letter code selected in c1 loop
      and arrs.supply_type   = w_arrear_supply_type   -- supply type selected in c1 loop
      AND arrs.copy_for_3rd_party_ind = 'Y'           -- only include 3rd party copies
      AND arrs.mail_addr_id = mad.addr_id
    ORDER BY arrs.acct_key
             ,arrs.tars_id
    ;
    -- End Add 5659
 begin
   trace_label('e309', w_procedure_name);
   -- start add 5659
   -- Check if there are any SHUT-REQ events that have not been processed yet
   -- and run action specific event to process these events and create the SHUT-OFF work orders
   -- before we start assembling information for shut off letters.
   -- (SHUT-OFF meter work orders must have already been created in order
   --  to create the details required for the SHUT-OFF letters).
   -- This can be done in Philly R12 databases as they have the 3.3.1.1B hotfix version of ciss0010
   -- (basis2 call 4869) which allows the action_daemon and specific_events to be run at the same time.
   -- Currently we only do this for WDEV2/WQA.
   -- However, this could also be done in production to overcome the timing issues.
   -- This still needs to be confirmed with Susan.
   select count(*)
   into   w_count_shutreq
   from   cis_events
   where action_reqd_ind = 'Y'
     and event_type = 'SHUT-REQ';
   -- Deliberate Unconditional Trace to Show if there are any shut-req events
   -- whioh need to be processed first (but also include in debug tracing)
   w_progress := 'SHUT-REQ events to process first =' || w_count_shutreq;
   debug_trace(w_procedure_name,w_progress);
   ciss0001.write_message
                         (
                          p_procedure_name  => w_procedure_name
                         ,p_mesg_code       => 'PHL_SHUTOFF_STATUS'
                         ,p_mesg_text       => w_progress
                         ,p_statement_label => w_label
                         );
   w_label := 'e310';
   select name into w_cur_sid from v$database;
   debug_trace(w_procedure_name,'..w_cur_sid = ' || w_cur_sid);
   -- ensure SHUT-REQS have been processed in dev and qa databases
   if w_count_shutreq > 0
   and  instr(upper(wc_dev_qa_sid_str),upper(w_cur_sid)) <> 0
   then
     w_label := 'e311';
     debug_trace(w_procedure_name,'..call ciss0010.specific event to process SHUT-REQs');
     ciss0010.specific_events (errbuf           => w_errbuf
                              ,retcode          => w_retcode
                              ,p_user_name      => null
                              ,p_reqd_date_char => null
                              ,p_event_type     => 'SHUT-REQ'
                              );
   end if;
   -- Add 8616A count if there are still any shut-req events waiting to be processed
   -- Perhaps some event condition like furture dated events in test cases
   w_label := 'e312';
   select count(*)
   into   w_count_shutreq
   from   cis_events
   where action_reqd_ind = 'Y'
     and event_type = 'SHUT-REQ';
   if w_count_shutreq > 0
   then
       -- 8616A moved this code here and base on 2nd w_count_shutreq so we wait if there are any
       -- shut-req events still waiting to process.
       -- This works for both prod and test as the action daemon in prod will have already processed
       -- the shut-req events and processing will pause in dev/test so future dates events can be processed
       -- via test harness if required
       w_event_count := 1;                                                                           -- Add 1.0.0.33
       while w_event_count > 0                                                                       -- Add 1.0.0.33
       loop                                                                                          -- Add 1.0.0.33
          trace_label('e313', w_procedure_name);
          select count(event_id) into w_event_count                                                  -- Add 1.0.0.33
                    from cis_events                                                                  -- Add 1.0.0.33
                   where event_type = 'SHUT-REQ'                                                     -- Add 1.0.0.33
                     and action_reqd_ind = 'Y';                                                      -- Add 1.0.0.33
          if w_event_count > 0                                                                       -- Add 1.0.0.33
          then                                                                                       -- Add 1.0.0.33
             trace_label('e314', w_procedure_name);
             w_progress := 'Waiting for' || w_event_count || ' shut-off work orders to be created';  -- Add 1.0.0.33
             ciss0001.write_message                                                                  -- Add 1.0.0.33
                                   (                                                                 -- Add 1.0.0.33
                                    p_procedure_name  => w_procedure_name                            -- Add 1.0.0.33
                                   ,p_mesg_code       => 'PHL_SHUTOFF_STATUS'                        -- Add 1.0.0.33
                                   ,p_mesg_text       => w_progress                                  -- Add 1.0.0.33
                                   ,p_statement_label => w_label                                     -- Add 1.0.0.33
                                   );                                                                -- Add 1.0.0.33
             dbms_lock.sleep(60);                                                                    -- Add 1.0.0.33
          end if;                                                                                    -- Add 1.0.0.33
       end loop;                                                                                     -- Add 1.0.0.33
       -- 8616A end move
    end if;
    -- 8616A end
   w_label := 'e315';
   -- End Add 5659
   -- Start Add 1.0.0.25
   w_count := 0;
   w_sofar := 0;
 /*                                              Block replaced 1.0.0.33
    select count(*)
      into w_count
      from cis_tmp_arrears_summary
     where arrears_process_id = w_arrears_process_id
       and (
            (letter_set_code = 'RES-STDL' and  letter_no = 4)
         or
            (letter_set_code = 'COM-STDL' and  letter_no = 3)
           );
 */
    select count(arrs.tars_id)                                             -- Add 1.0.0.33
      into w_count                                                         -- Add 1.0.0.33
      from                                                                 -- Add 1.0.0.33
     cis_tmp_arrears_summary   arrs
    ,cis_meter_wos             mwos
    ,cis_installations         inst                                        -- Add 1.0.0.28
    where arrs.arrears_process_id = w_arrears_process_id
      and mwos.work_type          = 'SHUT-OFF'
      and mwos.meter_work_status not in ('C', 'X')                         -- Add 1.0.0.37
      and mwos.meter_work_date < sysdate + 365                             -- Add 1.0.0.37
      and inst.inst_id            = arrs.inst_id                           -- Add 1.0.0.28
      and inst.attribute28        = mwos.meter_works_id                    -- Add 1.0.0.28
      and arrs.letter_code     like 'SHUT%'                                -- Add 1.0.0.33
      and arrs.letter_code  <> 'SHUTSTRT'                                  -- Add 1.0.0.37
      and arrs.supply_type <> 'PRINTED'                                    -- Add 1.0.0.33
      and  ( inst.owner_cust_id is not null                                -- Add 1.0.0.34
          or inst.tenn_cust_id is not null)                                -- Add 1.0.0.34
      and nvl(inst.revu1_code, 'x') not like 'NB%';                        -- Add 1.0.0.34
    trace_label('e316', w_procedure_name);
    -- Deliberate Unconditional Trace to Show Total Bills
    w_progress := 'Arrears Shutoff Count=' || w_count;
    ciss0001.write_message
                          (
                           p_procedure_name  => w_procedure_name
                          ,p_mesg_code       => 'PHL_SHUTOFF_STATUS'
                          ,p_mesg_text       => w_progress
                          ,p_statement_label => w_label
                          );
    trace_label('e317', w_procedure_name);
    -- Start Add 1.0.0.28
    if w_count <> 0
    then
       -- 8616A moved 'wait' code up and changed to check if any shut-reqs still outstaning
       trace_label('e318', w_procedure_name);
       bg_shut_off_print_headings;
       ins_phl_tmg_shutoffnotice;
    end if;
    -- End Add 1.0.0.28
    w_label := 'e319';
    for r1 in c1
    loop
       -- Start Add 1.0.0.25        2nd Unconditional Status Trace
       w_sofar := w_sofar + 1;
       if round(w_sofar/1000,0)*1000 = w_sofar then
          w_progress := 'Done ' || w_sofar || ' of ' ||  w_count;
          ciss0001.write_message
                          (
                           p_procedure_name  => w_procedure_name
                          ,p_mesg_code       => 'PHL_BILL_REPORT_STATUS'
                          ,p_mesg_text       => w_progress
                          ,p_statement_label => w_label
                          );
       end if;
       -- End   Add 1.0.0.25
       w_label := 'e320';
       reset_shut_off_var;    --Add 7080
       w_letter_code        	 := r1.letter_code;
 --      w_arrears_process_id := r1.arrears_process_id;                                    -- Del 1263
       w_cust_id               := r1.cust_id;                                              -- Add 1263
       w_arrear_inst_id        := r1.inst_id;
       w_arrear_supply_type    := r1.supply_type;
       w_arrears_run_date      := r1.arrears_run_date;                                     -- Add 1.0.0.41
       w_arrears_b2_acct_key   := r1.acct_key;                                             -- Add 5659
       g_wtr_access_code			 := r1.acct_key;                                             -- Add 7080
       debug_trace(w_procedure_name,'..w_letter_code         '|| w_letter_code);
       debug_trace(w_procedure_name,'..w_arrears_process_id  '|| w_arrears_process_id);
       debug_trace(w_procedure_name,'..w_arrears_b2_acct_key '|| w_arrears_b2_acct_key);  -- Add 5659
       debug_trace(w_procedure_name,'..w_arrear_supply_type  '|| w_arrear_supply_type);   -- Add 5659
    	 debug_trace(w_procedure_name,'..g_wtr_access_code     '|| g_wtr_access_code ); 	  -- Add 7080
       --
       -- Initializing the record variable.
       --
       w_ptsh := null;
              --
              -- Arrears Process ID
              --
              w_ptsh.process_id:=w_arrears_process_id;               --Add Ticket 3407   version 2.0.0.80
       --
       -- Bill Account Number
       --
       w_label := 'e321';
       phlu0018.b2_acct_to_city_acct (
                                      p_acct_id   => null
                                     ,p_acct_key  => r1.acct_key
                                     ,p_city_acct => w_ptsh.account_number
                                     ,p_result    => w_ptsh_result
                                     ,p_message   => w_ptsh_message
                                     );
       w_city_acct := w_ptsh.account_number;                            -- Add 1.0.0.17A
       check_city_suffix;                                               -- Add 1.0.0.17A
       debug_trace(w_procedure_name,'..w_city_acct             ' || w_city_acct);
       debug_trace(w_procedure_name,'..w_ptsh_result           ' || w_ptsh_result);
       debug_trace(w_procedure_name,'..w_ptsh_message          ' || w_ptsh_message);
       --
       -- Bill Number -- Always one
       --
       w_label := 'e322';
       w_bill_number := w_bill_number + 1;
       w_ptsh.bill_number := w_bill_number;
       w_label := 'e323';
       select  nvl(owner_cust_id, tenn_cust_id)  ,nvl(tenn_cust_id, owner_cust_id)     -- Chg 1.0.0.34    Add nvl's
              ,prop_addr_id,substr(attribute29,1,2)
          into w_owner_cust_id,w_tenn_cust_id,w_prop_addr_id,w_service_code_inst
       from cis_installations
       where inst_id = r1.inst_id;
       w_label := 'e324';
       debug_trace(w_procedure_name,'..w_owner_cust_id              ' || w_owner_cust_id);
       debug_trace(w_procedure_name,'..w_tenn_cust_id               ' || w_tenn_cust_id);
       debug_trace(w_procedure_name,'..w_prop_addr_id               ' || w_prop_addr_id);
       debug_trace(w_procedure_name,'..w_service_code_inst          ' || w_service_code_inst);
       w_label := 'e325';                                -- Add 1.0.0.34
       select mail_addr_id into w_mail_addr_id           -- Add 1.0.0.34
       from cis_accounts where acct_id = r1.acct_id;     -- Add 1.0.0.34
       --
       -- Owner and Tenant Name
       -- Service and Mailing Address
       if w_owner_cust_id =  w_tenn_cust_id then
          w_label := 'e326';
          select upper(substr(cust_name,1,29)) ,substr(cust_type_code,1,1)      -- Chg 1.0.0.28  -- Chg 1.0.0.34 upper
            into w_ptsh.mail_addr_line1,w_service_code_cust                     -- Chg 1.0.0.34
          from cis_customers where cust_id = w_owner_cust_id;
          w_label := 'e327';
          select upper(substr(line1,1,29)), upper(substr(line2,1,29)),          -- Chg 1.0.0.34 upper
                 upper(substr(line3,1,29)), upper(substr(line4,1,29))           -- Add 1.0.0.34
                ,upper(substr(address4,1,29))                                   -- Add 1.0.0.34
            into w_ptsh.mail_addr_line2,w_ptsh.mail_addr_line3,                 -- Chg 1.0.0.34
                 w_ptsh.mail_addr_line4,w_ptsh.mail_addr_line5                  -- Add 1.0.0.34
                ,w_mail_name                                                    -- Add 1.0.0.34
          from cis_addresses where addr_id = w_mail_addr_id;                    -- Chg 1.0.0.34  was w_prop_addr_id
          -- (5659 comment) - keep occupier name for 3rd party letters
          w_occupier_name := w_ptsh.mail_addr_line1;                            -- Add 4956
          if w_ptsh.mail_addr_line1 <> nvl(w_mail_name, w_ptsh.mail_addr_line1) -- Add 1.0.0.34
          then                                                                  -- Add 1.0.0.34
             w_ptsh.owner_name := w_ptsh.mail_addr_line1;                       -- Add 1.0.0.34
             w_ptsh.mail_addr_line1 := w_mail_name;                             -- Add 1.0.0.34
/*********************************************************************************************/
/*                              TicketID#5828 code changes                                   */
/*********************************************************************************************/            --Added TicketID#5828 "v3.0.0.44"
          else
             w_ptsh.owner_name := w_ptsh.mail_addr_line1;
/*********************************************************************************************/            --End of Added TicketID#5828 "v3.0.0.44"
/*                          End of TicketID#5828 code changes                                */
/*********************************************************************************************/
          end if;                                                               -- Add 1.0.0.34
          debug_trace(w_procedure_name,'..w_ptsh.mail_addr_line3              ' || w_ptsh.mail_addr_line3);
          debug_trace(w_procedure_name,'..w_service_code_cust                 ' || w_service_code_cust);
       else
          w_label := 'e328';
          select upper(substr(cust_name, 1, 29)) into w_ptsh.owner_name       -- Chg 1.0.0.34 upper, substr to name
          from cis_customers where cust_id = w_owner_cust_id;
          debug_trace(w_procedure_name,'..w_ptsh.owner_name              ' || w_ptsh.owner_name);
          w_label := 'e329';
          select upper(substr(cust_name, 1, 29)) ,substr(cust_type_code,1,1)    -- Chg 1.0.0.34 upper, substr to name
          into w_ptsh.mail_addr_line1,w_service_code_cust                       -- Chg 1.0.0.34
          from cis_customers where cust_id = w_tenn_cust_id;
          debug_trace(w_procedure_name,'..w_ptsh.mail_addr_line3         ' || w_ptsh.mail_addr_line3);
          debug_trace(w_procedure_name,'..w_service_code_cust            ' || w_service_code_cust);
 /*  moved to before if test        1.0.0.34
          w_label := 'e330';
          select mail_addr_id into w_mail_addr_id
          from cis_accounts where acct_id = r1.acct_id;
 */
          --
          -- Mailing Address
          --
          debug_trace(w_procedure_name,'..w_mail_addr_id                 ' || w_mail_addr_id);
          w_label := 'e331';
          select upper(substr(line1,1,29)), upper(substr(line2,1,29))        -- Chg 1.0.0.34 upper
                ,upper(substr(line3,1,29)), upper(substr(line4,1,29))        -- Add 1.0.0.34
                ,upper(substr(address4,1,29))                                -- Add 1.0.0.34
            into w_ptsh.mail_addr_line2,w_ptsh.mail_addr_line3               -- Chg 1.0.0.34
                ,w_ptsh.mail_addr_line4,w_ptsh.mail_addr_line5               -- Add 1.0.0.34
                ,w_mail_name                                                 -- Add 1.0.0.34
          from cis_addresses where addr_id = w_mail_addr_id;
          if w_tenn_cust_id in (3, 4)   -- If NCO or RCB use mailing name as customer name  -- Add 1.0.0.33
          then                                                                              -- Add 1.0.0.33
             w_ptsh.mail_addr_line1 := trim(substr(nvl(w_mail_name, w_ptsh.owner_name),1,29));    -- Mod 7047    -- Add 1.0.0.33
          end if;                                                                           -- Add 1.0.0.33
          -- (5659 comment) - keep occupier name for 3rd party letters
          w_occupier_name := w_ptsh.mail_addr_line1;                                        -- Add 4956
       end if;                                                                              -- Add 1.0.0.34
       if w_prop_addr_id <> w_mail_addr_id                                                  -- Add 1.0.0.34
       or w_ptsh.owner_name is not null                                                     -- Add 1.0.0.34
       then                                                                                 -- Add 1.0.0.34
          --
          -- Service Address
          --
          w_label := 'e332';
          select upper(decode(trim(line1), trim(number2), substr(number2 ||' ' || line2,1,29), substr(line1,1,29))) -- Chg 818 was [substr(line1,1,29)] -- Chg 1.0.0.34 upper
            into w_ptsh.service_address
          from cis_addresses where addr_id = w_prop_addr_id;
          debug_trace(w_procedure_name,'..w_ptsh.mail_addr_line4         ' || w_ptsh.mail_addr_line4);
          debug_trace(w_procedure_name,'..w_ptsh.mail_addr_line5         ' || w_ptsh.mail_addr_line5);
       end if;
       --   Shuffle address so it fills from the bottom                                  -- Add 1.0.0.34
       if w_ptsh.mail_addr_line5 is null                                                 -- Add 1.0.0.34
       then                                                                              -- Add 1.0.0.34
          w_ptsh.mail_addr_line5 := w_ptsh.mail_addr_line4;                              -- Add 1.0.0.34
          w_ptsh.mail_addr_line4 := w_ptsh.mail_addr_line3;                              -- Add 1.0.0.34
          w_ptsh.mail_addr_line3 := w_ptsh.mail_addr_line2;                              -- Add 1.0.0.34
          w_ptsh.mail_addr_line2 := w_ptsh.mail_addr_line1;                              -- Add 1.0.0.34
          w_ptsh.mail_addr_line1 := null;                                                -- Add 1.0.0.34
       end if;                                                                           -- Add 1.0.0.34
       if w_ptsh.mail_addr_line5 is null                                                 -- Add 1.0.0.34
       then                                                                              -- Add 1.0.0.34
          w_ptsh.mail_addr_line5 := w_ptsh.mail_addr_line4;                              -- Add 1.0.0.34
          w_ptsh.mail_addr_line4 := w_ptsh.mail_addr_line3;                              -- Add 1.0.0.34
          w_ptsh.mail_addr_line3 := w_ptsh.mail_addr_line2;                              -- Add 1.0.0.34
          w_ptsh.mail_addr_line2 := w_ptsh.mail_addr_line1;                              -- Add 1.0.0.34
          w_ptsh.mail_addr_line1 := null;                                                -- Add 1.0.0.34
       end if;                                                                           -- Add 1.0.0.34
       --
       -- Shutoff Date
       --
       w_label := 'e333';
--       w_ptsh.shutoff_date := r1.meter_work_date;                                        -- Del 2.0.0.01 --1.0.0.63
   --Start Add 2514
   if r1.letter_code = 'WRBCC-2' then
    w_ptsh.shutoff_date := r1.meter_work_date + 30;
   --End Add 2514
     else
            -- Start Add 2.0.0.01 --1.0.0.63
            if r1.meter_work_date > w_arrears_run_date
            then
               w_ptsh.shutoff_date := r1.meter_work_date;
            else
         -- w_ptsh.shutoff_date := w_arrears_run_date + 15;                             -- Del 2809
         -- Start Add 2809
            w_ptsh.shutoff_date := w_arrears_run_date + 10;
            w_ptsh.shutoff_date := phls0007.next_shut_date
                                   (
                                    p_cust_id   => w_cust_id
                                   ,p_inst_id   => w_arrear_inst_id
                                   ,p_shut_date => w_ptsh.shutoff_date
                                   );
         -- End Add 2809
            end if;
            -- End   -- Add 2.0.0.01 --1.0.0.63
         end if;     -- Add 2514
       debug_trace(w_procedure_name,'..w_ptsh.shutoff_date         ' || datec(w_ptsh.shutoff_date));
       --
       -- LastPayment Date
       --
       /* Start Del 1.0.0.41
       w_label := 'e334';
       begin
          select max(tran_date) into w_ptsh.last_payment_date
          from cis_transactions
          where inst_id     =  w_arrear_inst_id
            and supply_type =  w_arrear_supply_type
            and cust_id in (w_owner_cust_id,w_tenn_cust_id)           -- Add 1.0.0.32
            and scnd_type   in ('REC','RTI');
       exception
          when no_data_found then
             w_ptsh.last_payment_date := null;
       end;
       -- End Del 1.0.0.41  */
       w_ptsh.last_payment_date := w_arrears_run_date;                -- Add 1.0.0.41
       debug_trace(w_procedure_name,'..w_ptsh.last_payment_date         ' || datec(w_ptsh.last_payment_date));
       --
       -- Scan Line
       --
       w_ptsh.scan_line         := null;
       --
       --Sewer Percentage  --- We dont have sewer percentage
       --
       w_label := 'e335';
       w_ptsh.sewer_percent1   := null;
       w_ptsh.sewer_percent2   := null;
       w_ptsh.sewer_percent3   := null;
       w_ptsh.sewer_percent4   := null;
       w_ptsh.sewer_percent5   := null;
       w_ptsh.sewer_percent6   := null;
       w_ptsh.sewer_percent7   := null;
       w_ptsh.sewer_percent8   := null;
       w_ptsh_service_code     := w_service_code_cust || w_service_code_inst;                  -- Add 1.0.0.30
       w_ptsh.service_code1    := null;                                                        -- Chg 1.0.0.30
       w_ptsh.service_code2    := null;
       w_ptsh.service_code3    := null;
       w_ptsh.service_code4    := null;
       w_ptsh.service_code5    := null;
       w_ptsh.service_code6    := null;
       w_ptsh.service_code7    := null;
       w_ptsh.service_code8    := null;
       debug_trace(w_procedure_name,'..w_ptsh.service_code1          ' || w_ptsh.service_code1);
       debug_trace(w_procedure_name,'..w_ptsh.service_code2          ' || w_ptsh.service_code2);
       debug_trace(w_procedure_name,'..w_ptsh.service_code3          ' || w_ptsh.service_code3);
       debug_trace(w_procedure_name,'..w_ptsh.service_code4          ' || w_ptsh.service_code4);
       debug_trace(w_procedure_name,'..w_ptsh.service_code5          ' || w_ptsh.service_code5);
       debug_trace(w_procedure_name,'..w_ptsh.service_code6          ' || w_ptsh.service_code6);
       debug_trace(w_procedure_name,'..w_ptsh.service_code7          ' || w_ptsh.service_code7);
       debug_trace(w_procedure_name,'..w_ptsh.service_code8          ' || w_ptsh.service_code8);
       --
       --AR Code  ---We dont have
       --
       w_ptsh.ar_code1         := null;
       w_ptsh.ar_code2         := null;
       w_ptsh.ar_code3         := null;
       w_ptsh.ar_code4         := null;
       w_ptsh.ar_code5         := null;
       w_ptsh.ar_code6         := null;
       w_ptsh.ar_code7         := null;
       w_ptsh.ar_code8         := null;
                                              -- For Chg 1.0.0.30
                                              -- All number in the next loop were reversed
       w_pay_at_once_bal :=0;                                                          -- Add 2124/2265
       w_c2_cntr := 0;                                                                 -- Add 1.0.0.34
       for r2 in c2
       loop
            w_pay_at_once_bal := w_pay_at_once_bal + (r2.principal + r2.penalty);        -- Add 2124/2265
          w_c2_cntr := w_c2_cntr + 1;
          if w_c2_cntr = 1 then
             w_label := 'e336';
 --          w_ptsh.principal1    := r2.principal;                                       -- Del 1.0.0.30
             w_ptsh.principal8    := r2.principal;                                       -- Add 1.0.0.30
             w_ptsh.penalty8      := r2.penalty;
             w_ptsh.ar_total8     := r2.principal + r2.penalty;
             w_ptsh.cycle8        := r2.cycle;
             w_ptsh.service_code8 := w_ptsh_service_code;                                -- Add 1.0.0.30
             debug_trace(w_procedure_name,'..w_ptsh.principal8      ' || w_ptsh.principal8);
             debug_trace(w_procedure_name,'..w_ptsh.penalty8        ' || w_ptsh.penalty8);
             debug_trace(w_procedure_name,'..w_ptsh.ar_total8       ' || w_ptsh.ar_total8);
             debug_trace(w_procedure_name,'..w_ptsh.cycle8          ' || w_ptsh.cycle8);
          elsif w_c2_cntr = 2 then
             w_label := 'e337';
             w_ptsh.principal7 := r2.principal;
             w_ptsh.penalty7   := r2.penalty;
             w_ptsh.ar_total7  := r2.principal + r2.penalty;
             w_ptsh.cycle7     := r2.cycle;
             w_ptsh.service_code7 := w_ptsh_service_code;                                -- Add 1.0.0.30
             debug_trace(w_procedure_name,'..w_ptsh.principal7      ' || w_ptsh.principal7);
             debug_trace(w_procedure_name,'..w_ptsh.penalty7        ' || w_ptsh.penalty7);
             debug_trace(w_procedure_name,'..w_ptsh.ar_total7       ' || w_ptsh.ar_total7);
             debug_trace(w_procedure_name,'..w_ptsh.cycle7          ' || w_ptsh.cycle7);
          elsif w_c2_cntr = 3 then
             w_label := 'e338';
             w_ptsh.principal6 := r2.principal;
             w_ptsh.penalty6   := r2.penalty;
             w_ptsh.ar_total6  := r2.principal + r2.penalty;
             w_ptsh.cycle6     := r2.cycle;
             w_ptsh.service_code6 := w_ptsh_service_code;                                -- Add 1.0.0.30
             debug_trace(w_procedure_name,'..w_ptsh.principal6      ' || w_ptsh.principal6);
             debug_trace(w_procedure_name,'..w_ptsh.penalty6        ' || w_ptsh.penalty6);
             debug_trace(w_procedure_name,'..w_ptsh.ar_total6       ' || w_ptsh.ar_total6);
             debug_trace(w_procedure_name,'..w_ptsh.cycle6          ' || w_ptsh.cycle6);
          elsif w_c2_cntr = 4 then
             w_label := 'e339';
             w_ptsh.principal5 := r2.principal;
             w_ptsh.penalty5   := r2.penalty;
             w_ptsh.ar_total5  := r2.principal + r2.penalty;
             w_ptsh.cycle5     := r2.cycle;
             w_ptsh.service_code5 := w_ptsh_service_code;                                -- Add 1.0.0.30
             debug_trace(w_procedure_name,'..w_ptsh.principal5      ' || w_ptsh.principal5);
             debug_trace(w_procedure_name,'..w_ptsh.penalty5        ' || w_ptsh.penalty5);
             debug_trace(w_procedure_name,'..w_ptsh.ar_total5       ' || w_ptsh.ar_total5);
             debug_trace(w_procedure_name,'..w_ptsh.cycle5          ' || w_ptsh.cycle5);
          elsif w_c2_cntr = 5 then
             w_label := 'e340';
             w_ptsh.principal4 := r2.principal;
             w_ptsh.penalty4   := r2.penalty;
             w_ptsh.ar_total4  := r2.principal + r2.penalty;
             w_ptsh.cycle4     := r2.cycle;
             w_ptsh.service_code4 := w_ptsh_service_code;                                -- Add 1.0.0.30
             debug_trace(w_procedure_name,'..w_ptsh.principal4      ' || w_ptsh.principal4);
             debug_trace(w_procedure_name,'..w_ptsh.penalty4        ' || w_ptsh.penalty4);
             debug_trace(w_procedure_name,'..w_ptsh.ar_total4       ' || w_ptsh.ar_total4);
             debug_trace(w_procedure_name,'..w_ptsh.cycle4          ' || w_ptsh.cycle4);
          elsif w_c2_cntr = 6 then
             w_label := 'e341';
             w_ptsh.principal3 := r2.principal;
             w_ptsh.penalty3   := r2.penalty;
             w_ptsh.ar_total3  := r2.principal + r2.penalty;
             w_ptsh.cycle3     := r2.cycle;
             w_ptsh.service_code3 := w_ptsh_service_code;                                -- Add 1.0.0.30
             debug_trace(w_procedure_name,'..w_ptsh.principal3      ' || w_ptsh.principal3);
             debug_trace(w_procedure_name,'..w_ptsh.penalty3        ' || w_ptsh.penalty3);
             debug_trace(w_procedure_name,'..w_ptsh.ar_total3       ' || w_ptsh.ar_total3);
             debug_trace(w_procedure_name,'..w_ptsh.cycle3          ' || w_ptsh.cycle3);
          elsif w_c2_cntr = 7 then
             w_label := 'e342';
             w_ptsh.principal2 := r2.principal;
             w_ptsh.penalty2   := r2.penalty;
             w_ptsh.ar_total2  := r2.principal + r2.penalty;
             w_ptsh.cycle2     := r2.cycle;
             w_ptsh.service_code2 := w_ptsh_service_code;                                -- Add 1.0.0.30
             debug_trace(w_procedure_name,'..w_ptsh.principal2      ' || w_ptsh.principal2);
             debug_trace(w_procedure_name,'..w_ptsh.penalty2        ' || w_ptsh.penalty2);
             debug_trace(w_procedure_name,'..w_ptsh.ar_total2       ' || w_ptsh.ar_total2);
             debug_trace(w_procedure_name,'..w_ptsh.cycle2          ' || w_ptsh.cycle2);
          elsif w_c2_cntr = 8 then
             w_label := 'e343';
             w_ptsh.principal1 := r2.principal;
             w_ptsh.penalty1   := r2.penalty;
             w_ptsh.ar_total1  := r2.principal + r2.penalty;
             w_ptsh.cycle1     := r2.cycle;
             w_ptsh.service_code1 := w_ptsh_service_code;                                -- Add 1.0.0.30
             debug_trace(w_procedure_name,'..w_ptsh.principal1      ' || w_ptsh.principal1);
             debug_trace(w_procedure_name,'..w_ptsh.penalty1        ' || w_ptsh.penalty1);
             debug_trace(w_procedure_name,'..w_ptsh.ar_total1       ' || w_ptsh.ar_total1);
             debug_trace(w_procedure_name,'..w_ptsh.cycle1          ' || w_ptsh.cycle1);
          elsif w_c2_cntr = 9 then
             w_label := 'e344';
 --          w_ptsh.principal3 := w_ptsh.principal2 + w_ptsh.principal1 + r2.principal;              -- Del 1.0.0.34
 --          w_ptsh.penalty3   := w_ptsh.penalty2   + w_ptsh.penalty1   + r2.penalty;                -- Del 1.0.0.34
 --          w_ptsh.ar_total3  := w_ptsh.ar_total2  + w_ptsh.ar_total1 + r2.principal + r2.penalty;  -- Del 1.0.0.34
             w_ptsh.principal3 := w_ptsh.principal3 + nvl(w_ptsh.principal2, 0)                      -- Add 1.0.0.34
                                + nvl(w_ptsh.principal1, 0) + r2.principal;                          -- Add 1.0.0.34
             w_ptsh.penalty3   := w_ptsh.penalty3 + nvl(w_ptsh.penalty2, 0)                          -- Add 1.0.0.34
                                + nvl(w_ptsh.penalty1, 0) + r2.penalty;                              -- Add 1.0.0.34
             w_ptsh.ar_total3  := w_ptsh.ar_total3 + nvl(w_ptsh.ar_total2, 0)                        -- Add 1.0.0.34
                                + nvl(w_ptsh.ar_total1, 0) + r2.principal + r2.penalty;              -- Add 1.0.0.34
             w_ptsh.principal2 := null;
             w_ptsh.penalty2   := null;
             w_ptsh.ar_total2  := null;
             w_ptsh.principal1 := null;
             w_ptsh.penalty1   := null;
             w_ptsh.ar_total1  := null;
             w_ptsh.service_code1 := null;                                -- Add 1.0.0.30
             w_ptsh.service_code2 := null;                                -- Add 1.0.0.30
             w_ptsh.cycle2     := 'to';
             w_ptsh.cycle1     := r2.cycle;
             debug_trace(w_procedure_name,'..w_ptsh.principal3     ' || w_ptsh.principal3 );
             debug_trace(w_procedure_name,'..w_ptsh.penalty3       ' || w_ptsh.penalty3   );
             debug_trace(w_procedure_name,'..w_ptsh.ar_total3      ' || w_ptsh.ar_total3  );
             debug_trace(w_procedure_name,'..w_ptsh.principal2     ' || w_ptsh.principal2 );
             debug_trace(w_procedure_name,'..w_ptsh.penalty2       ' || w_ptsh.penalty2   );
             debug_trace(w_procedure_name,'..w_ptsh.ar_total2      ' || w_ptsh.ar_total2  );
             debug_trace(w_procedure_name,'..w_ptsh.principal1     ' || w_ptsh.principal1 );
             debug_trace(w_procedure_name,'..w_ptsh.penalty1       ' || w_ptsh.penalty1   );
             debug_trace(w_procedure_name,'..w_ptsh.ar_total1      ' || w_ptsh.ar_total1  );
             debug_trace(w_procedure_name,'..w_ptsh.cycle2         ' || w_ptsh.cycle2     );
             debug_trace(w_procedure_name,'..w_ptsh.cycle1         ' || w_ptsh.cycle1     );
          else
             w_label := 'e345';
             w_ptsh.principal3 := w_ptsh.principal3 + r2.principal;
             w_ptsh.penalty3   := w_ptsh.penalty3   + r2.penalty;
 --          w_ptsh.ar_total6  := w_ptsh.ar_total3  + r2.principal + r2.penalty;                 -- Del 1.0.0.34
             w_ptsh.ar_total3  := w_ptsh.ar_total3  + r2.principal + r2.penalty;                 -- Add 1.0.0.34
             w_ptsh.cycle1     := r2.cycle;
             debug_trace(w_procedure_name,'..w_ptsh.principal3      ' || w_ptsh.principal3);
             debug_trace(w_procedure_name,'..w_ptsh.penalty3        ' || w_ptsh.penalty3);
             debug_trace(w_procedure_name,'..w_ptsh.ar_total3       ' || w_ptsh.ar_total3);
             debug_trace(w_procedure_name,'..w_ptsh.cycle1          ' || w_ptsh.cycle1);
          end if;
       end loop;      -- End C2 (5659 comment)
       --
       -- Total Bill Amount
       --
       w_label := 'e346';
       /* Del 1255
       w_ptsh.tot_bill_amt := nvl(w_ptsh.ar_total1,0) +
                              nvl(w_ptsh.ar_total2,0) +
                              nvl(w_ptsh.ar_total3,0) +
                              nvl(w_ptsh.ar_total4,0) +
                              nvl(w_ptsh.ar_total5,0) +
                              nvl(w_ptsh.ar_total6,0) +
                              nvl(w_ptsh.ar_total7,0) +
                              nvl(w_ptsh.ar_total8,0) ;
       -- End Del 1255 */
       --w_ptsh.tot_bill_amt := r1.overdue_amnt;                         -- Del 2124/2265 -- Add 1255
       w_ptsh.tot_bill_amt := w_pay_at_once_bal;                         -- Add 2124/2265
         select nvl(sum(debt_bal_amnt),0) into w_vacant_balance            -- Add 2124/2265
         from cis_debt_collection                                          -- Add 2124/2265
         where debt_coll_path = 'VACANT'                                   -- Add 2124/2265
         and cust_id = w_cust_id                                           -- Add 2124/2265
         and supply_type = 'WATER'                -- Add 3.0.0.1
         and inst_id = w_arrear_inst_id;                                   -- Add 2124/2265
         w_ptsh.tot_bill_amt :=  w_ptsh.tot_bill_amt - w_vacant_balance;   -- Add 2124/2265
     debug_trace(w_procedure_name,'..w_ptsh.tot_bill_amt          ' || w_ptsh.tot_bill_amt);
       -- -- Start Add 1710 --2.0.0.01A --1.0.0.64
       -- w_label := 'e347';                                                                                 --Del 2124/2265
       -- select sum(debt_bal_amnt) into w_count                                                             --Del 2124/2265
       --  from cis_debt_collection                                                                          --Del 2124/2265
       -- where debt_coll_path = 'SH-WATER'                                                                  --Del 2124/2265
       --   and cust_id = w_cust_id                                                                          --Del 2124/2265
       --   and inst_id = w_arrear_inst_id;                                                                  --Del 2124/2265
       --                                                                                                    --Del 2124/2265
       -- w_ptsh.tot_bill_amt :=  w_ptsh.tot_bill_amt + nvl(w_count,0);                                      --Del 2124/2265
       -- debug_trace(w_procedure_name,'..w_ptsh.tot_bill_amt with SH-WATER  ' || w_ptsh.tot_bill_amt);      --Del 2124/2265
       -- -- End   Add 1710 --2.0.0.01A --1.0.0.64
    -- -- End Del 2124/2265
       --
       -- Message Line
       --
       w_label := 'e348';
   --Start Add 2514
   if r1.letter_code = 'WRBCC-2' then
        w_ptsh.msg_line   :=
                      'WRBCC-SHUTOFF: YOUR WATER SERVICE WILL BE SHUT OFF ON OR AFTER ' || to_char(w_ptsh.shutoff_date,'MM/DD/YYYY')
        || ' TO AVOID TERMINATION OF SERVICE, PLEASE MAKE PAYMENT IMMEDIATELY.'
        || ' SUSPENSION OF WATER SERVICE MAY AFFECT YOUR FIRE SUPPRESSION SYSTEM IF THE'  --Add Ticket 3407   version 2.0.0.80
                      || ' PROPERTY IS SERVED BY A SINGLE/COMBINED DOMESTIC AND FIRE SERVICE LINE.'     --Add Ticket 3407   version 2.0.0.80
        || ' IF YOUR SERVICE IS SHUT OFF A VISITATION OR RESTORATION FEE WILL '
        || 'BE DUE.'
        || ' FOR YOUR CONVENIENCE, TELEPHONE CUSTOMER SERVICE IS AVAILABLE '
        || 'MONDAY THROUGH FRIDAY, 8:00 AM TO 5:00 PM.  WE CAN BE REACHED '      --Mod 1.0.0.52b
        || 'AT 215-686-6880.'                                                    -- Chg 1921
        || ' IF YOU HAVE ALREADY MADE YOUR PAYMENT, THANK YOU AND PLEASE '
        || 'DISREGARD THIS NOTICE.'
    ;
   --Start End 2514
   else
          w_ptsh.msg_line   :=
             'YOUR WATER SERVICE WILL BE SHUT OFF DURING THE WEEK OF ' || to_char(w_ptsh.shutoff_date,'MM/DD/YYYY')  -- Add 8616
--           'YOUR WATER SERVICE WILL BE SHUT OFF ON OR AFTER '        || to_char(w_ptsh.shutoff_date,'MM/DD/YYYY')  -- Del 8616
          || ' TO AVOID TERMINATION OF SERVICE, PLEASE MAKE PAYMENT IMMEDIATELY.'
          || ' SUSPENSION OF WATER SERVICE MAY AFFECT YOUR FIRE SUPPRESSION SYSTEM IF THE'  --Add Ticket 3407   version 2.0.0.80
              || ' PROPERTY IS SERVED BY A SINGLE/COMBINED DOMESTIC AND FIRE SERVICE LINE.'     --Add Ticket 3407   version 2.0.0.80
          || ' IF YOUR SERVICE IS SHUT OFF A VISITATION OR RESTORATION FEE WILL '
          || 'BE DUE.'
          || ' FOR YOUR CONVENIENCE, TELEPHONE CUSTOMER SERVICE IS AVAILABLE '
          || 'MONDAY THROUGH FRIDAY, 8:00 AM TO 5:00 PM.  WE CAN BE REACHED '      --Mod 1.0.0.52b
          || 'AT 215-686-6880.'                                                    -- Chg 1921
          || ' IF YOU HAVE ALREADY MADE YOUR PAYMENT, THANK YOU AND PLEASE '
          || 'DISREGARD THIS NOTICE.'
          ;
   end if;  -- Add 2514
       debug_trace(w_procedure_name,'..w_ptsh.msg_line          ' || w_ptsh.msg_line);
       --
       -- Scan String
       --
       w_label := 'e349';
       scan_string_shut_off;
       debug_trace(w_procedure_name,'..Done Scan String Shut off          ');
       --
       -- Insert records tmg table for reports
       --
       w_label := 'e350';
       ins_phl_tmg_shutoffnotice;
       debug_trace(w_procedure_name,'..Done Insert PHL TMG SHUTOFF NOTICE TABLE');
       -- start Add 4956
       -- Insert records into tmg table for 3rd party copies
       -- retain existing arrears summary record but replace the mailing address with the 3rd party
       --
       w_label := 'e351';
       debug_trace(w_procedure_name,'..get 3rd party address details for b2 acct = ' ||  w_arrears_b2_acct_key);  -- Add 5659
       w_label := 'e352';
       for r3 in c3
       loop
          -- Start Del 5659
          -- 3rd party address details for the current r1 account
          -- are now selected in c3 cursor
          -- --
          -- -- get 3rd party address
          -- --
          -- w_label := 'e353';
          -- w_mail_addr_id := r3.mail_addr_id;
          --
          -- debug_trace(w_procedure_name,'..w_mail_addr_id   ' || w_mail_addr_id);
          -- select upper(substr(line1,1,29)), upper(substr(line2,1,29))
          --       ,upper(substr(line3,1,29)), upper(substr(line4,1,29))
          --   into w_ptsh.mail_addr_line2,w_ptsh.mail_addr_line3
          --       ,w_ptsh.mail_addr_line4,w_ptsh.mail_addr_line5
          -- from cis_addresses
          --   where addr_id = w_mail_addr_id;
          -- End Del 5659
          w_label := 'e354';
          -- Start Add 5659
          debug_trace(w_procedure_name,'.. 3rd party = ' || r3.copy_for_3rd_party_ind
                                     || ', tars id = ' || r3.tars_id
                                     || ', mail_addr_id = ' || r3.mail_addr_id
                                     || ', cust name = ' || r3.cust_name_3rd_party);
          -- format/set up 3rd party address
          w_ptsh.mail_addr_line2 := upper(substr(r3.line1,1,29));
          w_ptsh.mail_addr_line3 := upper(substr(r3.line2,1,29));
          w_ptsh.mail_addr_line4 := upper(substr(r3.line3,1,29));
          w_ptsh.mail_addr_line5 := upper(substr(r3.line4,1,29));
          -- End Add 5659
          /* 5659 add comment from ticket 4956 re 3rd party mailing addresses:
          ** (Susan) Here are my thoughts on how the names and addresses should appear
          ** on notices sent to 3rd parties:
          **
          ** Item    Contents for Customer mailing            Contents for 3rd Party mailing
          ** A       Customer name and mailing address        3rd Party Mailing address
          ** B       Owner name and property address          Owner name and property address
          **         (Only if different from account name and
          **         mailing address)
          **
          ** C       Customer name and mailing address        3rd Party Mailing address
          ** D       Owner name and property address          Owner name and property address
          **         (Only if different from account name and
          **         mailing address)
          */
          w_label := 'e355';
--          w_ptsh.mail_addr_line1 := nvl(r3.cust_name_3rd_party, w_ptsh.owner_name)
          w_ptsh.mail_addr_line1 := trim(substr(w_occupier_name,1,29));  --Mod 7047 added substr to truncate the size to 29 chracters
          --   Shuffle address so it fills from the bottom
          if w_ptsh.mail_addr_line5 is null
          then
             w_ptsh.mail_addr_line5 := w_ptsh.mail_addr_line4;
             w_ptsh.mail_addr_line4 := w_ptsh.mail_addr_line3;
             w_ptsh.mail_addr_line3 := w_ptsh.mail_addr_line2;
             w_ptsh.mail_addr_line2 := w_ptsh.mail_addr_line1;
             w_ptsh.mail_addr_line1 := null;
          end if;
          if w_ptsh.mail_addr_line5 is null
          then
             w_ptsh.mail_addr_line5 := w_ptsh.mail_addr_line4;
             w_ptsh.mail_addr_line4 := w_ptsh.mail_addr_line3;
             w_ptsh.mail_addr_line3 := w_ptsh.mail_addr_line2;
             w_ptsh.mail_addr_line2 := w_ptsh.mail_addr_line1;
             w_ptsh.mail_addr_line1 := null;
          end if;
          if w_ptsh.service_address is null then
             select upper(decode(trim(line1), trim(number2), substr(number2 ||' ' || line2,1,29), substr(line1,1,29))) -- Chg 818 was [substr(line1,1,29)] -- Chg 1.0.0.34 upper
               into w_ptsh.service_address
             from cis_addresses where addr_id = w_prop_addr_id;
          end if;
          w_label := 'e356';
          --
          -- Report Variable for output file
          --
          bg_shut_off_print_string;
          --
          -- write 3rd party to tmg table
          --
          ins_phl_tmg_shutoffnotice;
          debug_trace(w_procedure_name,'..Done 3rd Party Insert PHL TMG SHUTOFF NOTICE TABLE'|| r3.cust_name_3rd_party);
      end loop;   -- End C3 (5659 comment)
      -- end Add 4956
/*********************************************************************************************/
/*                              TicketID#5828 code changes                                   */
/*********************************************************************************************/            --Added TicketID#5828 "v3.0.0.45"
      Begin
       w_label := 'e357';
        if w_prop_addr_id!=w_mail_addr_id and
            w_prop_addr_id is NOT NULL then
          Begin
           w_label := 'e358';
           select trim(substr(adr.line1,1,29)), --Mod 7047 address line can be bigger than 29 characters
                  trim(substr(adr.line2,1,29)), --Mod 7047 address line can be bigger than 29 characters
                  trim(substr(adr.line3,1,29)), --Mod 7047 address line can be bigger than 29 characters
                  trim(substr(adr.line4,1,29))  --Mod 7047 address line can be bigger than 29 characters
             into w_ptsh.mail_addr_line2,
                  w_ptsh.mail_addr_line3,
                  w_ptsh.mail_addr_line4,
                  w_ptsh.mail_addr_line5
            from cis.cis_addresses adr
             where adr.addr_id=w_prop_addr_id;
          Exception
            When others then
              raise;
          End;
         w_label := 'e359';
          w_ptsh.mail_addr_line1:='OWNER/OCCUPANT';
         w_label := 'e360';
          --   Shuffle address so it fills from the bottom
          if w_ptsh.mail_addr_line5 is null
          then
             w_ptsh.mail_addr_line5 := w_ptsh.mail_addr_line4;
             w_ptsh.mail_addr_line4 := w_ptsh.mail_addr_line3;
             w_ptsh.mail_addr_line3 := w_ptsh.mail_addr_line2;
             w_ptsh.mail_addr_line2 := w_ptsh.mail_addr_line1;
             w_ptsh.mail_addr_line1 := null;
          end if;
         w_label := 'e361';
          if w_ptsh.mail_addr_line5 is null
          then
             w_ptsh.mail_addr_line5 := w_ptsh.mail_addr_line4;
             w_ptsh.mail_addr_line4 := w_ptsh.mail_addr_line3;
             w_ptsh.mail_addr_line3 := w_ptsh.mail_addr_line2;
             w_ptsh.mail_addr_line2 := w_ptsh.mail_addr_line1;
             w_ptsh.mail_addr_line1 := null;
          end if;
         w_label := 'e362';
          --
          -- Report Variable for output file
          --
          bg_shut_off_print_string;
         w_label := 'e363';
          --
          -- Insert duplicate shut off bill for service address
          --
          ins_phl_tmg_shutoffnotice;
        end if;
      Exception
        When others then
          raise;
      End;
/*********************************************************************************************/            --End of Added TicketID#5828 "v3.0.0.45"
/*                          End of TicketID#5828 code changes                                */
/*********************************************************************************************/
   end loop;   -- End C1 (5659 comment)
   if c1%isopen then
      close c1;
   end if;
 --     Stop shut-off bill being printed once for each letter stage in this arrears run.
    update cis_tmp_arrears_summary                                    -- Add 1.0.0.33
       set supply_type = 'PRINTED'                                    -- Add 1.0.0.33
     where letter_code like 'SHUT%'                                   -- Add 1.0.0.33
       and arrears_process_id = w_arrears_process_id;                 -- Add 1.0.0.33
 end get_shut_off_details;
 /*************************************************************************************\
    public procedure assemble shut off
 \*************************************************************************************/
 procedure assemble_shut_off(p_arrears_process_id number)
 is
    w_procedure_name  varchar2(40) := 'phls0001.assemble_shut_off';
 begin
    if p_arrears_process_id is null then
       ciss0047.raise_exception(w_procedure_name, w_label, 'cis_internal_error',
                                'error', 'Null parameter supplied', p_severity=>'f');
    end if;
    load_ref_data;
    init;
    trace_label('e364', w_procedure_name);
    w_arrears_process_id := p_arrears_process_id;
    debug_trace(w_procedure_name, '..p_arrears_process_id  =' || p_arrears_process_id);
    performance_statistics('ARREARS');                                                      -- Add 1.0.0.27
    get_shut_off_details;
    trace_label('e365', w_procedure_name);
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
       debug(w_procedure_name,w_label,'...cust_id     =' || to_char(w_cust_id));
       ciss0047.raise_exception(w_procedure_name, w_label, 'cis_internal_error','error'
                               , '...cust_id     =' || to_char(w_cust_id) || '< ' || substr(sqlerrm,1,240)   -- Chg 1263
                               , p_severity=>'F');
  end assemble_shut_off;
end phls0001;
