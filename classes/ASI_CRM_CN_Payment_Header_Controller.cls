/* Filename:    ASI_CRM_CN_Payment_Header_Controller.cls
* Author:      Michael Yip (Introv Limited)
* Purpose:     Controller Class for payment request (new, edit, input payee, input payment detail) for CN CRM
*
*
* History
* -----------------------------------------------------------------------------
* 2014-03-10   michael.yip@introv.com      Created
* 2014-06-29   michael.yip@introv.com      BRSF Generation logic: Actual Vol generation(no duplicate for new 
contract on/off), suggested amount 
* 2014-06-30   michael.yip@introv.com      Payment Summary Calculation
* 2014-07-17   steve.wan@inrov.com         Modify Update PO Version Logic
* 2014-08-01   michael.yip@introv.com      Restriction on change in incentive, only new sub-brand in first payment can be changed 
* 2014-08-04   michael.yip@introv.com      Default Activity code for PSF
* 2014-08-15   michael.yip@introv.com      Block save if BRSF start/end date invalid
* 2014-09-10   michael.yip@introv.com      Overpayment checking by total instead of by line item
* 2014-09-16   michael.yip@introv.com      Fix overlap payment checking
* 2014-09-26   twinkle.li@introv.com       BA Return
* 2014-10-07   twinkle.li@introv.com       Lookup fields Autocomplete
* 2018-10-18   laputa - kevin              uncomment line 1145-1159 
*/
global without sharing class ASI_CRM_CN_Payment_Header_Controller {
    public ASI_TH_CRM_PaymentRequest__c PH {set;get;}
    public string PageId {set;get;}
    public String freeGoodsRecordTypeId { get; set; }
    public boolean showcalc {set;get;}
    public boolean cashtype {set;get;}
    public boolean require_overpayment_reason{set;get;}//lokman 6/23/2014
    public boolean require_other_reason{set;get;}//lokman 6/23/2014
    public boolean discounttype{set;get;}
    public boolean othertype {set;get;}
    public list <ASI_TH_CRM_PaymentRequest__c> HeaderList {set;get;}
    public list <ASI_TH_CRM_PaymentRequest__c> PaymentRequestList {set;get;}//lokman 24/6/2014
    public decimal Remaining_Amount{set;get;} 
    
    public decimal completionRate {set;get;}
    public decimal payableAmount {set;get;}
    public string OverPaymentReason {set;get;}
    public string OtherReason {set;get;}
    public decimal adjustment {set;get;}
    public decimal actualPayment {set;get;}
    public String division{set;get;} //lokman 5/30/2014
    public boolean Allow_Submit_For_Approval{set;get;} //lokman 5/30/2014
    private decimal totalpayment{set;get;}//lokman 6/23/2014
    
    public decimal sum_of_payee_amount{set;get;}
    //---- variables for Payee list Cash ----
    public list <ASI_CRM_CN_PH_Payee_Line_Item__c> PHPayee_CASH {set;get;}
    public map<integer, ASI_CRM_CN_PH_Payee_Line_Item__c> Payee_Item_Map_CASH {set;get;}
    public list <ASI_CRM_CN_PH_Payee_Line_Item__c> Del_Payee_Item_CASH {set;get;}
    public list<ASI_CRM_CN_PH_Payee_Line_Item__c> Save_Payee_Item_CASH {set;get;}
    public Integer indexCASH {set;get;}
    public Integer rowidCASH {set;get;}
    
    //---- variables for Payee list Discount ----
    public list <ASI_CRM_CN_PH_Payee_Line_Item__c> PHPayee_DISCOUNT {set;get;}
    public map<integer, ASI_CRM_CN_PH_Payee_Line_Item__c> Payee_Item_Map_DISCOUNT {set;get;}
    public list <ASI_CRM_CN_PH_Payee_Line_Item__c> Del_Payee_Item_DISCOUNT {set;get;}
    public list<ASI_CRM_CN_PH_Payee_Line_Item__c> Save_Payee_Item_DISCOUNT {set;get;}
    public Integer indexDISCOUNT {set;get;}
    public Integer rowidDISCOUNT {set;get;}
    
    //---- variables for Payee list CD ----
    public list <ASI_CRM_CN_PH_Payee_Line_Item__c> PHPayee_CD {set;get;}
    public map<integer, ASI_CRM_CN_PH_Payee_Line_Item__c> Payee_Item_Map_CD {set;get;}
    public list <ASI_CRM_CN_PH_Payee_Line_Item__c> Del_Payee_Item_CD {set;get;}
    public list<ASI_CRM_CN_PH_Payee_Line_Item__c> Save_Payee_Item_CD {set;get;}
    public Integer indexCD {set;get;}
    public Integer rowidCD {set;get;}
    
    //---- variables for BRSF list ----
    public list <ASI_TH_CRM_PaymentRequestLineItem__c> BRSFList {set;get;}
    public map<integer, ASI_TH_CRM_PaymentRequestLineItem__c> BRSF_Item_Map {set;get;}
    public List <ASI_TH_CRM_PaymentRequestLineItem__c> Save_BRSF_Item {set;get;}   
    
    
    //---- variables for PSF list ----
    public RecordType rtPSF {set;get;}
    public list <ASI_TH_CRM_PaymentRequestLineItem__c> PSFList {set;get;}
    public map<integer, ASI_TH_CRM_PaymentRequestLineItem__c> PSF_Item_Map {set;get;}
    public List <ASI_TH_CRM_PaymentRequestLineItem__c> Del_PSF_Item {set;get;}
    public List <ASI_TH_CRM_PaymentRequestLineItem__c> Save_PSF_Item {set;get;}    
    public Integer indexPSF {set;get;}
    public Integer rowidPSF {set;get;}
    
    //---- variables for Other Payment Detail list ----
    public list <ASI_TH_CRM_PaymentRequestLineItem__c> OTPList {set;get;}
    public ASI_TH_CRM_PaymentRequestLineItem__c downpayment{set;get;}
    public map<integer, ASI_TH_CRM_PaymentRequestLineItem__c> OTP_Item_Map {set;get;}
    public List <ASI_TH_CRM_PaymentRequestLineItem__c> Save_OTP_Item {set;get;}
    
    public List<String> payeeNamePicklist {set; get;}
    public List<SelectOption> discountT2WSPicklist {set; get;}
    public List<SelectOption> discountT1WSPicklist {set; get;}
    public List<SelectOption> othersT2WSPicklist {set; get;}
    public List<SelectOption> othersT1WSPicklist {set; get;} 
    
    public List<ASI_CRM_CN_PaymentRequestUtilCls.PaymentSummary> LPaymentSummary {set;get;}
    public decimal TotalPOEstAmt {set;get;}
    public decimal TotalPORemainAmt {set;get;}
    public decimal TotalRequestAmt {set;get;}
    //20160726 Ben @ Elufa
    public decimal TotalEstAmtCNY {set;get;}
    public decimal TotalEstAmtMAF {set;get;}
    public decimal TotalEstAmtOthers {set;get;}
    
    public decimal TotalRemainAmtCNY {set;get;}
    public decimal TotalRemainAmtMAF {set;get;}
    public decimal TotalRemainAmtOthers {set;get;}
    
    public decimal TotalRequestAmtCNY {set;get;}
    public decimal TotalRequestAmtMAF {set;get;}
    public decimal TotalRequestAmtOthers {set;get;}
    //20160726 End
    public Map<String,ASI_CRM_CN_PaymentRequestUtilCls.PaymentSummary> MPaymentSummary {set;get;}//20160816, added by Leo
    
    public List<ASI_CRM_Contract_Cost__c> LPSF {set;get;}
    
    public Integer cashRows {set;get;}
    public Integer discountRows {set;get;}
    public Integer otherRows {set;get;}
    
    public Boolean showReturn {set;get;}  
    
    //check language
    public Boolean boolCNLanguage {set;get;}
    public String strTotal {set;get;}
    
    //20160613 Ben @ Elufa
    Public Map<String, Boolean> festivalMap{Get; Set;}
    Public Map<String, String> poTypeMap{Get; Set;}
    Public Boolean isFestivalPSF{Get; Set;}
    Public Boolean ContractDateKey{Get; Set;}{ContractDateKey=true;}
    //20171110 Introv
    
    //20200609
    public interimData freeGoodsInterimData { get; set; }
    public String freeGoodsInterimDataJSON { get; set; }
    public Decimal Total_this_time_payment{get;set;}{Total_this_time_payment = 0;}
    public static final String PRICE_PROMOTION_MODULE_TYPE = 'PSF';
    public static final String FREE_GOODS_MODULE_TYPE = 'Display';

    Public pageReference reDirectToTaxSavingPage(){
        
        return new pageReference('/apex/ASI_CRM_CN_Payment_Tax_Saving_Page?id=' + PageId);
    }
    
    //20171110 End
    
    public ASI_CRM_CN_Payment_Header_Controller(ApexPages.StandardController controller) {
        this.PH = (ASI_TH_CRM_PaymentRequest__c)controller.getRecord();     
        freeGoodsRecordTypeId = Global_RecordTypeCache.getRtId('ASI_TH_CRM_PaymentRequestLineItem__cASI_CRM_CN_Payment_Request_Detail_Free_Goods');
        refresh();
        getRows();
        freeGoodsInterimDataJSON = JSON.serialize(freeGoodsInterimData);
    }
    
    //20160622 Ben @ Elufa
    
    public List<ASI_CRM_SpecialPromotionTypeSetting__c> GetAllSpecialPromotionTypeSetting() {
        
        String recordType = Global_RecordTypeCache.getRtId('ASI_CRM_SpecialPromotionTypeSetting__cASI_CRM_CN_SpecialPromotionTypeSetting');
        
        List<ASI_CRM_SpecialPromotionTypeSetting__c> tmpList;
        if(PH.ASI_CRM_New_FY_Payment__c){
            tmpList = [SELECT Id, Name, ASI_CRM_Validate_TotalSuggestedAmount__c, ASI_CRM_Promotion_Type_Chinese_Name__c, ASI_CRM_Bypass_Contract_Upload_Checking__c, ASI_CRM_Override_BC_Rate__c, ASI_CRM_SuggestedAmount_And_TargetVolume__c, ASI_CRM_Promotion_Type__c FROM ASI_CRM_SpecialPromotionTypeSetting__c
                       WHERE recordtypeid =: recordType AND ASI_CRM_New_FY_Promotion_Type__c = TRUE ORDER BY Name];
        }else{
            tmpList = [SELECT Id, Name, ASI_CRM_Validate_TotalSuggestedAmount__c, ASI_CRM_Promotion_Type_Chinese_Name__c, ASI_CRM_Bypass_Contract_Upload_Checking__c, ASI_CRM_Override_BC_Rate__c, ASI_CRM_SuggestedAmount_And_TargetVolume__c, ASI_CRM_Promotion_Type__c FROM ASI_CRM_SpecialPromotionTypeSetting__c
                       WHERE recordtypeid =: recordType AND ASI_CRM_New_FY_Promotion_Type__c = FALSE];
        }
        
        return tmpList;
    }
    
    //20160622 End
    
    public PageReference cancel(){        
        PageReference ab = new PageReference('/apex/ASI_CRM_CN_Payment_Header_Page'); 
        ab.getParameters().put('id',PageId); 
        ab.setRedirect(true); 
        return ab;
    }

    @RemoteAction
    Global static List<SObject> retrieveFreeGoods(String obj, String qry) {
        Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
        Schema.SObjectType sot = gd.get(obj);
        if (sot == null) {// Object name not valid
            return null;
        }

        //begin building the dynamic soql query
        String soql = 'select ' +
                'Id, Name,ASI_MFM_Item_Group_Code__c ,(select id, ASI_CRM_CN_T1_Price__c from T1_Price__r where ASI_CRM_CN_Effective_Date__c <= today order by ASI_CRM_CN_Effective_Date__c desc limit 1)  from ' + obj;
        if (String.isNotEmpty(qry)) {
            soql += qry;
        }
        soql += ' order by Name';

        try {
            return Database.query(soql);
        } catch (QueryException e) {
            ASI_MFM_ByPass_Setting.ErrorHandling('RemoteAction.ASI_CRM_CN_EditHeavyContractDetailCtrl.FindSubBrandList class have Error  ' + 'Save Error : ' + e.getMessage() + '</br>', 'ASI_CRM_CN_EditHeavyContractDetailCtrl', 'failed! ');
            return null;
        }
    }

    public void refresh(){
        freeGoodsInterimData = new interimData();
        if(UserInfo.getLanguage()=='zh_CN'){
            boolCNLanguage = true;
            strTotal = '总数:';
        }
        else{
            boolCNLanguage = false;
            strTotal = 'Total:';
        }
            
        PageId = PH.id;
        showcalc = true;
        showReturn = false;
        adjustment = 100;
        
        if (PageId != null){
            HeaderList = [SELECT id, name, ASI_CRM_CN_Payable_Amount__c, ASI_CRM_CN_Other_Reason__c, 
                          
                          ASI_TH_CRM_Status__c, ASI_CRM_CN_Bottle_Collection_Rate__c,  ASI_CRM_CN_BRSF_End_Date__c, 
                          
                          ASI_CRM_CN_BRSF_Start_Date__c,
                          ASI_CRM_CN_Channel__c, ASI_CRM_CN_Currency__c, ASI_CRM_CN_Last_Payment__c, 
                          
                          ASI_CRM_CN_Last_Year_Payment__c,ASI_CRM_CN_Division__c,
                          ASI_CRM_CN_OutletWS__c, ASI_CRM_CN_Payment_Raised_Date__c, ASI_CRM_CN_Payment_Type__c, 
                          
                          ASI_CRM_CN_PO_End_Date__c,ASI_TH_CRM_Contract__r.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Region__c,
                          ASI_CRM_CN_PO_No__c, ASI_CRM_CN_PO_Start_Date__c, ASI_CRM_CN_PO_Version__c, ASI_CRM_Volume_Option__c,
                          ASI_TH_CRM_Contract__r.ASI_CRM_CN_PO_Version__c,
                          ASI_CRM_CN_Promotion_Type__c,ASI_TH_CRM_Contract__r.ASI_CRM_CN_Outlet_WS__c,ASI_CRM_CN_OutletWS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__r.ASI_CRM_Region_Code__c,
                          ASI_CRM_CN_Reference_Code__c,ASI_TH_CRM_Total_Amount__c, ASI_CRM_CN_Total_Other_Amount__c, ASI_CRM_CN_PO_Version_Latest__c, ASI_CRM_CN_Overpayment_Reason__c,
                          ASI_CRM_CN_Total_BRSF_Amount__c,ASI_CRM_CN_Reason_For_Business_License__c, ASI_CRM_CN_Business_License_Qualify__c ,ASI_CRM_CN_Total_PSF_Amount__c, ASI_TH_CRM_Contract__r.ASI_CRM_CN_Outlet_WS__r.RecordType.DeveloperName,
                          ASI_CRM_CN_Adjustment__c, ASI_CRM_CN_No_of_Month__c   , ASI_CRM_CN_Total_Payment__c , ASI_CRM_CN_Overpayment_Comment__c,
                          ASI_TH_CRM_Contract__c,ASI_TH_CRM_Contract__r.ASI_CRM_CN_Total_Contract_Amount__c, ASI_CRM_CN_Total_BRSF_Actual_Amount__c,
                          ASI_TH_CRM_Contract__r.ASI_TH_CRM_Contract_Status__c, ASI_TH_CRM_Contract__r.ASI_CRM_CN_Last_PO_version__r.ASI_TH_CRM_Contract_Status__c  ,
                          ASI_TH_CRM_Contract__r.ASI_CRM_CN_Last_PO_version__r.ASI_CRM_CN_PO_Version__c, 
                          ASI_TH_CRM_Contract__r.ASI_CRM_Investment_Type__c,
                          ASI_CRM_CN_Description__c, ASI_TH_CRM_Contract__r.ASI_CRM_CN_PO_Modification__c,
                          ASI_TH_CRM_Contract__r.ASI_CRM_CN_Status__c, ASI_CRM_New_FY_Payment__c,ASI_TH_CRM_Contract__r.ASI_CRM_CN_Is_2nd_KPI_PO__c,
                          ASI_CRM_CN_OutletWS__r.ASI_CRM_CN_Greater_Region_Code__c,
                          ASI_TH_CRM_GL_Date__c,ASI_CRM_CN_Invoice_Date__c
                          FROM ASI_TH_CRM_PaymentRequest__c WHERE id = :PageId];
            if (HeaderList.size()> 0){
                this.PH = HeaderList[0];
                
                //20160622 Ben @ Elufa
                poTypeMap = new Map<String, String>();
                List<ASI_CRM_SpecialPromotionTypeSetting__c> tmpList = GetAllSpecialPromotionTypeSetting();
                
                if(tmpList.size() > 0){
                    for(ASI_CRM_SpecialPromotionTypeSetting__c obj : tmpList){
                        
                        if(boolCNLanguage){
                            
                            if(obj.ASI_CRM_Promotion_Type_Chinese_Name__c != NULL && obj.ASI_CRM_Promotion_Type_Chinese_Name__c != ''){
                                
                                poTypeMap.put(obj.ASI_CRM_Promotion_Type__c, obj.ASI_CRM_Promotion_Type_Chinese_Name__c);
                            }else{
                                
                                poTypeMap.put(obj.ASI_CRM_Promotion_Type__c, obj.ASI_CRM_Promotion_Type__c);
                            }
                        }
                    }
                }
                //20160622 End
            }
            
            
            system.debug('PH.id: ' + PH.id);
            
            //Added by Twinkle 9Oct2014
            if([SELECT Assignee.Name, PermissionSet.name
                FROM PermissionSetAssignment where permissionSet.name ='ASI_CRM_CN_General_BA' and Assigneeid = :Userinfo.getUserid()].size()>0 && PH.ASI_TH_CRM_Status__c == 'Submitted'){
                showReturn= true;
            }
            //End Twinkle 9Oct2014
            //20160628 Ben @ Elufa
            String POTypeName = PH.ASI_CRM_New_FY_Payment__c ? '%PSF & Trading Term Incentives%' : '%Promotion Service Fee%';
            //20160628 End
            LPSF = [Select id, name,ASI_CRM_CN_Chinese_Description__c, ASI_CRM_CN_Activity_Code__c, 
                    ASI_CRM_CN_Cost_Type__c from asi_crm_contract_cost__c 
                    where asi_crm_cn_contract__c = :PH.ASI_TH_CRM_Contract__c and name like : POTypeName];//'%Promotion Service Fee%']; 20160628 Ben @ Elufa
            System.debug(LPSF);

            //lokman 24/6/2014
            Remaining_Amount=0;
            PaymentRequestList = [Select  id,Name, ASI_CRM_CN_Last_Payment__c, ASI_TH_CRM_Contract__c,ASI_CRM_CN_PO_Version__c,
                                  ASI_CRM_CN_PO_Start_Date__c,ASI_CRM_CN_PO_End_Date__c,ASI_TH_CRM_Status__c,ASI_CRM_CN_Channel__c,
                                  ASI_CRM_CN_Total_Payment__c
                                  FROM ASI_TH_CRM_PaymentRequest__c 
                                  WHERE ASI_TH_CRM_Contract__c=:PH.ASI_TH_CRM_Contract__c
                                  AND (ASI_TH_CRM_Status__c='Approved' or ASI_TH_CRM_Status__c='Submitted')
                                 ];
            //lokman 6/25/2014
            
            for(ASI_TH_CRM_PaymentRequest__c payment_req : PaymentRequestList){
                if( payment_req.ASI_CRM_CN_Total_Payment__c!=null){
                    if(Remaining_Amount==null){Remaining_Amount=0;}
                    Remaining_Amount+=payment_req.ASI_CRM_CN_Total_Payment__c;
                }
            }
            
            if(Remaining_Amount==null)
            {Remaining_Amount=0;
            }
            if(PH.ASI_TH_CRM_Contract__r.ASI_CRM_CN_Total_Contract_Amount__c!=0){
                Remaining_Amount=PH.ASI_TH_CRM_Contract__r.ASI_CRM_CN_Total_Contract_Amount__c-Remaining_Amount;
            }
            
            BRSFList = [SELECT id, ASI_TH_CRM_Payment_Request__c, ASI_CRM_CN_Standard__c, ASI_CRM_CN_Sub_Brand__c, ASI_CRM_CN_Target_BT__c, 
                        ASI_CRM_CN_Incentive_BT__c, ASI_CRM_CN_Actual_Vol__c, ASI_CRM_CN_Completion_Rate__c, ASI_CRM_CN_Total_Payable__c,
                        ASI_CRM_CN_Payable_Vol__c, ASI_CRM_CN_Bottle_Collected__c, ASI_CRM_CN_Collection_Rate__c, ASI_CRM_CN_Offtake_Vol__c,
                        ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.Name,ASI_TH_CRM_Amount__c, ASI_CRM_CN_Suggested_Amount__c,
                        ASI_CRM_CN_Allow_Changing_Incentive__c, ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.ASI_CRM_Chinese_Name__c, ASI_CRM_Suggested_Volume__c
                        FROM ASI_TH_CRM_PaymentRequestLineItem__c 
                        WHERE ASI_TH_CRM_Payment_Request__c =:PH.id AND 
                        RecordTypeId = :Global_RecordTypeCache.getRTId('ASI_TH_CRM_PaymentRequestLineItem__cASI_CRM_CN_Payment_Request_Detail_BRSF')
                        order by ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.ASI_CRM_CN_Sequence__c
                       ];
            
            system.debug('BRSFList: ' + BRSFList);
            
            PSFList = [SELECT id, ASI_TH_CRM_Payment_Request__c,ASI_CRM_CN_Payment_Description__c, ASI_CRM_CN_Comment__c ,
                       ASI_CRM_CN_Period_Start__c, ASI_CRM_CN_Period_End__c, ASI_CRM_CN_Supporting_Document__c, ASI_TH_CRM_Amount__c, 
                       recordtypeid, ASI_CRM_CN_AC_Code__c, ASI_CRM_CN_Cost_Type__c, ASI_CRM_CN_Expense_Type__c
                       , ASI_CRM_CNY_Est__c, ASI_CRM_MAF_Est__c, ASI_CRM_Other_Est__c//20160728 Ben @ Elufa
                       FROM ASI_TH_CRM_PaymentRequestLineItem__c  
                       WHERE ASI_TH_CRM_Payment_Request__c =:PH.id AND
                       RecordTypeId = :Global_RecordTypeCache.getRTId('ASI_TH_CRM_PaymentRequestLineItem__cASI_CRM_CN_Payment_Request_Detail_PSF')
                      ];
            
            OTPList = [SELECT id, ASI_TH_CRM_Payment_Request__c, ASI_CRM_CN_Expense_Type__c, ASI_CRM_CN_Comment__c, ASI_TH_CRM_Amount__c, ASI_CRM_CN_Remaining_Amount__c, recordtypeid ,ASI_CRM_CN_Cost_Type__c
                       , ASI_CRM_CNY_Est__c, ASI_CRM_MAF_Est__c, ASI_CRM_Other_Est__c, ASI_TH_CRM_Payment_Request__r.ASI_CRM_CN_Promotion_Type__c, ASI_CRM_CN_AC_Code__c//20160610 Ben @ Elufa
                       FROM ASI_TH_CRM_PaymentRequestLineItem__c 
                       WHERE ASI_TH_CRM_Payment_Request__c =:PH.id AND
                       RecordTypeId = :Global_RecordTypeCache.getRTId('ASI_TH_CRM_PaymentRequestLineItem__cASI_CRM_CN_Payment_Request_Detail_Other')
                      ];
            
            rtPSF = Global_RecordTypeCache.getRTRec('ASI_TH_CRM_PaymentRequestLineItem__cASI_CRM_CN_Payment_Request_Detail_PSF');
            
            List<ASI_TH_CRM_PaymentRequestLineItem__c> freeGoodList = [
                SELECT
                //ASI_CRM_Brand_Code__c,
                //ASI_CRM_CN_AC_Code__c,
                        ASI_CRM_CN_Actual_Vol__c,
                        ASI_CRM_CN_Allow_Changing_Incentive__c,
                        ASI_CRM_CN_Comment__c,
                        ASI_CRM_Customer__c,
                        ASI_CRM_Customer__r.ASI_CRM_CN_CRM_Code__c,
                        ASI_CRM_Customer__r.Name,
                        //ASI_CRM_CN_Completion_Rate__c, // no need
                        //ASI_CRM_CN_Contract_BRSF_Line_Item__r.ASI_CRM_CN_Contract_Purchase_Value__c,
                        //ASI_CRM_CN_Contract_BRSF_Line_Item__r.ASI_CRM_CN_Estimate_Purchase_Value__c,
                        //ASI_CRM_CN_Contract_BRSF_Line_Item__r.ASI_CRM_CN_Contract_Total_Dummy__c,
                        //ASI_CRM_CN_Contract_BRSF_Line_Item__r.ASI_CRM_CN_Est_Total_Dummy__c,
                        //ASI_CRM_CN_Rebate__c, // no need
                        ASI_CRM_CN_Rebate_Percent__c,
                        //ASI_CRM_CN_Target__c, // no need
                        ASI_CRM_Historical_Paid_Amount__c, //no need
                        //ASI_CRM_CN_Contract_BRSF_Line_Item__r.ASI_CRM_Contract_Total_QTY_CR12_Eqv__c,
                        //ASI_CRM_CN_Contract_BRSF_Line_Item__r.ASI_CRM_Est_Total_QTY_CR12_Eqv__c,
                        //ASI_CRM_CN_Contract_BRSF_Line_Item__r.ASI_CRM_Contract_Total_QTY_std_Btl__c,
                        //ASI_CRM_CN_Contract_BRSF_Line_Item__r.ASI_CRM_Est_Total_QTY_std_Btl__c,
                        ASI_CRM_CN_Contract_BRSF_Line_Item__r.ASI_CRM_CN_Max_Purchase_Target__c,
                        ASI_CRM_CN_Contract_BRSF_Line_Item__r.ASI_CRM_CN_Min_Purchase_Target__c,
                        //ASI_CRM_CN_Contract_Cost__r.ASI_CRM_CN_Contract_Amount__c,    // no need
                        //ASI_CRM_CN_Contract_Cost__r.ASI_CRM_Contract_Terms__c,    // no need
                        //ASI_CRM_CN_Expense_Type__c, // no need
                        //ASI_CRM_CN_Incentive_BT__c, // no need
                        ASI_CRM_CN_Item_Group__c,   // no need
                        ASI_CRM_CN_Item_Group__r.Name,  // no need
                        ASI_CRM_CN_Item_Group__r.ASI_MFM_Item_Group_Code__c,    // no need
                        //ASI_CRM_CN_Payable_Vol__c,    // no need
                        //ASI_CRM_CN_Remaining_Amount__c,   // no need
                        //ASI_CRM_CN_Standard__c,   // no need
                        ASI_CRM_CN_Sub_Brand__c,
                        ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.ASI_CRM_Chinese_Name__c,
                        ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.Name,
                        ASI_CRM_CN_Sub_Brand__r.ASI_CRM_Sub_Brand_Grade_Sequence__c,
                        ASI_CRM_CN_Sub_Brand__r.Name,
                        //ASI_CRM_CN_Suggested_Amount__c,   // no need
                        ASI_CRM_CN_Total_Payable__c,
                        ASI_CRM_CN_Wholesaler__c,
                        ASI_CRM_CN_Wholesaler__r.ASI_CRM_CN_CRM_Code__c,
                        ASI_CRM_CN_Wholesaler__r.Name,
                        //ASI_CRM_CNY_Est__c,   // no need
                        ASI_CRM_CTD_Actual_Purchase_Value__c,
                        ASI_CRM_CTD_Actual_Vol__c,
                        //ASI_CRM_CTD_Actual_Vol_Martell_CR12__c,   // no need
                        //ASI_CRM_CTD_Actual_Vol_Pure_CR12__c,  // no need
                        //ASI_CRM_Key_Sub_Brand__c, // no need
                        //ASI_CRM_Line_Name__c, // no need
                        ASI_CRM_Line_Long_Name__c,
                        //ASI_CRM_MAF_Est__c, // no need
                        //ASI_CRM_Max_Incentive__c, // no need
                        ASI_CRM_Module__c,
                        ASI_CRM_Module__r.ASI_CRM_Parent_Module__c,
                        //ASI_CRM_Non_Contract_Line__c, // no need
                        //ASI_CRM_Other_Est__c, // no need
                        //ASI_CRM_Over_Incentive__c, // no need
                        //ASI_CRM_Product_Category__c,  // no need
                        //ASI_CRM_Product_Category__r.ASI_CRM_CN_Chinese_Name__c,   // no need
                        //ASI_CRM_Product_Category__r.ASI_HK_CRM_Sequence__c,       // no need
                        //ASI_CRM_Product_Category__r.Name, // no need
                        //ASI_CRM_Sub_Brand_Grade__c,       // no need
                        //ASI_CRM_Sub_Brand_Grade__r.ASI_CRM_Chinese_Name__c,   // no need
                        //ASI_CRM_Sub_Brand_Grade__r.ASI_CRM_CN_Sequence__c,    // no need
                        //ASI_CRM_System_Payable_Vol_Std_Bottle__c,         // no need
                        ASI_CRM_Unit_Price__c,
                        ASI_CRM_CN_Suggest_Unit_Price__c,
                        //ASI_CRM_V0_0_Full_Contract_Target__c, // no need
                        ASI_CRM_Volume_Base__c, // no need
                        //ASI_TH_CRM_Amount__c, // no need
                        ASI_TH_CRM_Payment_Request__c,
                        ASI_TH_CRM_Payment_Request__r.ASI_CRM_CN_Promotion_Type__c,
                        ASI_TH_CRM_Payment_Request__r.ASI_CRM_CN_Region__c,
                        ASI_TH_CRM_Quantity__c,
                        ASI_CRM_CN_WS_Intake_9L__c,
                        ASI_CRM_CTD_Actual_Vol_Std__c,
                        ASI_CRM_CN_WS_Intake_Std__c,
                        ASI_CRM_CN_Outlet_Intake_Std__c,
                        ASI_CRM_CN_Outlet_Intake_9L__c,
                        //ASI_CRM_CN_Outlet_Offtake_9L__c,      // no need
                        ASI_CRM_CN_POS_Volume__c,
                        //ASI_CRM_CTD_Actual_Offtake_Value__c,  // no need
                        ASI_CRM_CN_POS_Value__c,
                        ASI_CRM_CTD_Actual_Retail_Value__c,
                        ASI_CRM_Actual_Value_Base__c,
                        Id,
                        RecordType.DeveloperName,
                        RecordTypeId,
                        ASI_CRM_CN_CRM_Code__c
                FROM ASI_TH_CRM_PaymentRequestLineItem__c
                WHERE ASI_TH_CRM_Payment_Request__c = :PH.Id
                and recordType.DeveloperName =: 'ASI_CRM_CN_Payment_Request_Detail_Free_Goods'
                ORDER BY ASI_CRM_CN_CRM_Code__c ASC 
            ];

            for (ASI_TH_CRM_PaymentRequestLineItem__c paymentLine : freeGoodList) {
                if (paymentLine.ASI_CRM_CN_Suggest_Unit_Price__c == null)
                    paymentLine.ASI_CRM_CN_Suggest_Unit_Price__c = 0;
                if (paymentLine.ASI_CRM_Unit_Price__c == null) {
                    paymentLine.ASI_CRM_Unit_Price__c = 0;
                }
                if (paymentLine.ASI_TH_CRM_Quantity__c == null) {
                    paymentLine.ASI_TH_CRM_Quantity__c = 0;
                }
                freeGoodsInterimData.paymentRequestLines.add(paymentLine);
            }

            Map<String ,Decimal> moduleActualPaymentMap_ByController = new Map<String ,Decimal>();
            for (ASI_CRM_Module__c module : [
                SELECT
                        ASI_CRM_Actual_Payment__c,
                        //ASI_CRM_Adjustment__c,
                        ASI_CRM_Application_Payment_Amount__c,
                        //ASI_CRM_CN_CTD_Minimal_Achievement__c,
                        //ASI_CRM_CN_Contract_Volume_Base__c,
                        //ASI_CRM_CN_KPI_Base__c,
                        //ASI_CRM_CN_Total_Markup__c,
                        //ASI_CRM_CN_Minimal_Achievement__c,
                        //ASI_CRM_CN_Is_Capped__c,
                        //ASI_CRM_CN_Criteria__c,
                        ASI_CRM_CN_Customer__c,
                        ASI_CRM_CN_Customer__r.ASI_CRM_CN_CRM_Code__c,
                        //ASI_CRM_Completion_Ratio__c,
                        ASI_CRM_End_Date__c,
                        ASI_CRM_Historical_Paid_Amount__c,
                        ASI_CRM_Line_Type__c,
                        ASI_CRM_Methodology__c,
                        ASI_CRM_Methodology__r.ASI_CRM_Chinese_Name__c,
                        //ASI_CRM_Methodology__r.ASI_CRM_Methodology_Code__c,
                        ASI_CRM_Methodology__r.Name,
                        ASI_CRM_Other_Comments__c,
                        //ASI_CRM_Overpayment_Reason__c,
                        ASI_CRM_Parent_Module__c,
                        //ASI_CRM_Parent_Module__r.ASI_CRM_Payment_Reference__c,
                        //ASI_CRM_Parent_Module__r.ASI_CRM_Reason_NCD_Volume_Base__c,
                        //ASI_CRM_Parent_Module__r.ASI_CRM_Reason_Not_NCD_Methodology__c,
                        //ASI_CRM_Parent_Module__r.ASI_CRM_Remark__c,
                        //ASI_CRM_Parent_Module__r.ASI_CRM_Unit__c,
                        ASI_CRM_Parent_Module__r.ASI_CRM_Volume_Base__c,
                        //ASI_CRM_Parent_Module__r.ASI_CRM_CN_Criteria__c,
                        ASI_CRM_Parent_Module__r.ASI_CRM_Created_PO_Version__c,
                        ASI_CRM_Parent_Module__r.Name,
                        //ASI_CRM_PSF_Overpayment_Reason__c,
                        ASI_CRM_Created_PO_Version__c,
                        //ASI_CRM_Reason_NCD_Volume_Base__c,
                        //ASI_CRM_Reason_Not_NCD_Methodology__c,
                        //ASI_CRM_Remark__c,
                        //ASI_CRM_Suggested_Payable_Amount__c,
                        //ASI_CRM_Unit__c,
                        //ASI_CRM_VEC_Overpayment_Reason__c,
                        ASI_CRM_Volume_Base__c,
                        Id, (
                        SELECT
                        //ASI_CRM_Brand_Code__c,
                        //ASI_CRM_CN_AC_Code__c,
                                ASI_CRM_CN_Actual_Vol__c,
                                ASI_CRM_CN_Allow_Changing_Incentive__c,
                                ASI_CRM_CN_Comment__c,
                                ASI_CRM_Customer__c,
                                ASI_CRM_Customer__r.ASI_CRM_CN_CRM_Code__c,
                                ASI_CRM_Customer__r.Name,
                                //ASI_CRM_CN_Completion_Rate__c,
                                //ASI_CRM_CN_Contract_BRSF_Line_Item__r.ASI_CRM_CN_Contract_Purchase_Value__c,
                                //ASI_CRM_CN_Contract_BRSF_Line_Item__r.ASI_CRM_CN_Estimate_Purchase_Value__c,
                                //ASI_CRM_CN_Contract_BRSF_Line_Item__r.ASI_CRM_CN_Contract_Total_Dummy__c,
                                //ASI_CRM_CN_Contract_BRSF_Line_Item__r.ASI_CRM_CN_Est_Total_Dummy__c,
                                //ASI_CRM_CN_Rebate__c,
                                ASI_CRM_CN_Rebate_Percent__c,
                                //ASI_CRM_CN_Target__c,
                                ASI_CRM_Historical_Paid_Amount__c,
                                //ASI_CRM_CN_Contract_BRSF_Line_Item__r.ASI_CRM_Contract_Total_QTY_CR12_Eqv__c,
                                //ASI_CRM_CN_Contract_BRSF_Line_Item__r.ASI_CRM_Est_Total_QTY_CR12_Eqv__c,
                                //ASI_CRM_CN_Contract_BRSF_Line_Item__r.ASI_CRM_Contract_Total_QTY_std_Btl__c,
                                //ASI_CRM_CN_Contract_BRSF_Line_Item__r.ASI_CRM_Est_Total_QTY_std_Btl__c,
                                ASI_CRM_CN_Contract_BRSF_Line_Item__r.ASI_CRM_CN_Max_Purchase_Target__c,
                                ASI_CRM_CN_Contract_BRSF_Line_Item__r.ASI_CRM_CN_Min_Purchase_Target__c,
                                //ASI_CRM_CN_Contract_Cost__r.ASI_CRM_CN_Contract_Amount__c,
                                //ASI_CRM_CN_Contract_Cost__r.ASI_CRM_Contract_Terms__c,
                                //ASI_CRM_CN_Expense_Type__c,
                                //ASI_CRM_CN_Incentive_BT__c,
                                ASI_CRM_CN_Item_Group__c,
                                ASI_CRM_CN_Item_Group__r.Name,
                                ASI_CRM_CN_Item_Group__r.ASI_MFM_Item_Group_Code__c,
                                //ASI_CRM_CN_Payable_Vol__c,
                                //ASI_CRM_CN_Remaining_Amount__c,
                                //ASI_CRM_CN_Standard__c,
                                ASI_CRM_CN_Sub_Brand__c,
                                ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.ASI_CRM_Chinese_Name__c,
                                ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.Name,
                                ASI_CRM_CN_Sub_Brand__r.ASI_CRM_Sub_Brand_Grade_Sequence__c,
                                ASI_CRM_CN_Sub_Brand__r.Name,
                                //ASI_CRM_CN_Suggested_Amount__c,
                                ASI_CRM_CN_Total_Payable__c,
                                ASI_CRM_CN_Wholesaler__c,
                                ASI_CRM_CN_Wholesaler__r.ASI_CRM_CN_CRM_Code__c,
                                ASI_CRM_CN_Wholesaler__r.Name,
                                //ASI_CRM_CNY_Est__c,
                                ASI_CRM_CTD_Actual_Purchase_Value__c,
                                ASI_CRM_CTD_Actual_Vol__c,
                                //ASI_CRM_CTD_Actual_Vol_Martell_CR12__c,
                                //ASI_CRM_CTD_Actual_Vol_Pure_CR12__c,
                                //ASI_CRM_Key_Sub_Brand__c,
                                //ASI_CRM_Line_Name__c,
                                ASI_CRM_Line_Long_Name__c,
                                //ASI_CRM_MAF_Est__c,
                                //ASI_CRM_Max_Incentive__c,
                                ASI_CRM_Module__c,
                                ASI_CRM_Module__r.ASI_CRM_Parent_Module__c,
                                //ASI_CRM_Non_Contract_Line__c,
                                //ASI_CRM_Other_Est__c,
                                //ASI_CRM_Over_Incentive__c,
                                //ASI_CRM_Product_Category__c,
                                //ASI_CRM_Product_Category__r.ASI_CRM_CN_Chinese_Name__c,
                                //ASI_CRM_Product_Category__r.ASI_HK_CRM_Sequence__c,
                                //ASI_CRM_Product_Category__r.Name,
                                //ASI_CRM_Sub_Brand_Grade__c,
                                //ASI_CRM_Sub_Brand_Grade__r.ASI_CRM_Chinese_Name__c,
                                //ASI_CRM_Sub_Brand_Grade__r.ASI_CRM_CN_Sequence__c,
                                //ASI_CRM_System_Payable_Vol_Std_Bottle__c,
                                ASI_CRM_Unit_Price__c,
                                ASI_CRM_CN_Suggest_Unit_Price__c,
                                //ASI_CRM_V0_0_Full_Contract_Target__c,
                                ASI_CRM_Volume_Base__c,
                                //ASI_TH_CRM_Amount__c,
                                ASI_TH_CRM_Payment_Request__c,
                                ASI_TH_CRM_Payment_Request__r.ASI_CRM_CN_Promotion_Type__c,
                                ASI_TH_CRM_Quantity__c,
                                ASI_CRM_CN_WS_Intake_9L__c,
                                ASI_CRM_CTD_Actual_Vol_Std__c,
                                ASI_CRM_CN_WS_Intake_Std__c,
                                ASI_CRM_CN_Outlet_Intake_Std__c,
                                ASI_CRM_CN_Outlet_Intake_9L__c,
                                //ASI_CRM_CN_Outlet_Offtake_9L__c,
                                ASI_CRM_CN_POS_Volume__c,
                                //ASI_CRM_CTD_Actual_Offtake_Value__c,
                                ASI_CRM_CN_POS_Value__c,
                                ASI_CRM_CTD_Actual_Retail_Value__c,
                                ASI_CRM_Actual_Value_Base__c,
                                Id,
                                RecordType.DeveloperName,
                                RecordTypeId ,
                                ASI_CRM_CN_CRM_Code__c
                        FROM Payment_Request_Line_Items__r
                        WHERE ASI_TH_CRM_Payment_Request__c = :PH.Id
                        ORDER BY ASI_CRM_CN_CRM_Code__c DESC
                )
                FROM ASI_CRM_Module__c
                WHERE ASI_CRM_Payment_Request__c = :PageId])  {

                if (module.ASI_CRM_Line_Type__c == PRICE_PROMOTION_MODULE_TYPE) {
                    Total_this_time_payment += module.ASI_CRM_Actual_Payment__c == null ? 0 : module.ASI_CRM_Actual_Payment__c;
                }
                if (module.ASI_CRM_Line_Type__c == FREE_GOODS_MODULE_TYPE) {
                    freeGoodsInterimData.module = module;
                }
            }

            if (freeGoodsInterimData.module.Id == null) {
                freeGoodsInterimData.module = new ASI_CRM_Module__c(
                        ASI_CRM_Created_PO_Version__c = PH.ASI_TH_CRM_Contract__r.ASI_CRM_CN_PO_Version__c,
                        ASI_CRM_Line_Type__c = FREE_GOODS_MODULE_TYPE,
                        ASI_CRM_Payment_Request__c = PageId
                );
            }


            List<ASI_CRM_CN_PH_Payee_Line_Item__c> LPHPayeeAll = [SELECT ASI_CRM_CN_Amount__c, ASI_CRM_CN_Cash_Discount__c, ASI_CRM_CN_Cash_Amount__c, ASI_CRM_CN_Discount_Amount__c,
                                                                  ASI_CRM_CN_Payment_Request__c, ASI_CRM_CN_Type__c,ASI_CRM_CN_Payee_T1__r.Name, ASI_CRM_CN_Payee_T1__c, ASI_CRM_CN_Payee_Name_T1__c, ASI_CRM_CN_Payee_Name_T1__r.Name,
                                                                  ASI_CRM_CN_Reason__c , ASI_CRM_CN_Payee_T2__r.Name, ASI_CRM_CN_Payee_Name_T2_lookup__r.Name, ASI_CRM_CN_Comfirm_Receipt__c,
                                                                  ASI_CRM_CN_Cash_Payee_Name_T1__c, ASI_CRM_CN_Cash_Payee_Name_T1__r.Name, RecordTypeId, ASI_CRM_CN_Instruction_Sent_Time__c
                                                                  FROM ASI_CRM_CN_PH_Payee_Line_Item__c
                                                                  WHERE ASI_CRM_CN_Payment_Request__c = :PageId and
                                                                  (ASI_CRM_CN_Type__c = 'Cash' or ASI_CRM_CN_Type__c = 'Discount' or ASI_CRM_CN_Type__c = 'Others' OR ASI_CRM_CN_Type__c = 'CD')];
            PHPayee_CASH = new List<ASI_CRM_CN_PH_Payee_Line_Item__c>();
            PHPayee_Discount = new List<ASI_CRM_CN_PH_Payee_Line_Item__c>();
            PHPayee_CD = new List<ASI_CRM_CN_PH_Payee_Line_Item__c>();
            for(ASI_CRM_CN_PH_Payee_Line_Item__c payee : LPHPayeeAll){
                if(payee.ASI_CRM_CN_Type__c == 'Cash')
                    PHPayee_CASH.add(payee);
                else if(payee.ASI_CRM_CN_Type__c == 'Discount')
                    PHPayee_Discount.add(payee);
                else if(payee.ASI_CRM_CN_Type__c == 'Others' || payee.ASI_CRM_CN_Type__c == 'CD')
                    PHPayee_CD.add(payee);
            }
            
            //---- CASH Line Item - by michael (start) ----
            Del_Payee_Item_CASH = new List<ASI_CRM_CN_PH_Payee_Line_Item__c>();
            Payee_Item_Map_CASH = new Map<Integer, ASI_CRM_CN_PH_Payee_Line_Item__c>();
            indexCASH = 0;
            
            if(PHPayee_CASH != null && PHPayee_CASH.size()>0){
                for (ASI_CRM_CN_PH_Payee_Line_Item__c psf :PHPayee_CASH){
                    Payee_Item_Map_CASH.put(indexCASH++, psf);
                }
            }
            //---- CASH Line Item - by michael (end) ----
            
            //---- DISCOUNT Line Item - by michael (start) ----
            Del_Payee_Item_DISCOUNT = new List<ASI_CRM_CN_PH_Payee_Line_Item__c>();
            Payee_Item_Map_DISCOUNT = new Map<Integer, ASI_CRM_CN_PH_Payee_Line_Item__c>();
            indexDISCOUNT = 0;
            
            if(PHPayee_DISCOUNT != null && PHPayee_DISCOUNT.size()>0){
                for (ASI_CRM_CN_PH_Payee_Line_Item__c psf :PHPayee_DISCOUNT){
                    Payee_Item_Map_DISCOUNT.put(indexDISCOUNT++, psf);
                }
            }
            //---- DISCOUNT Line Item - by michael (end) ----
            
            //---- CD Line Item - by michael (start) ----
            Del_Payee_Item_CD = new List<ASI_CRM_CN_PH_Payee_Line_Item__c>();
            Payee_Item_Map_CD = new Map<Integer, ASI_CRM_CN_PH_Payee_Line_Item__c>();
            indexCD = 0;
            
            if(PHPayee_CD != null && PHPayee_CD.size()>0){
                for (ASI_CRM_CN_PH_Payee_Line_Item__c psf :PHPayee_CD){
                    Payee_Item_Map_CD.put(indexCD++, psf);
                }
            }
            //---- CD Line Item - by michael (end) ----
            
            
            //---- PSF Line Item - by leo (start) ----
            Del_PSF_Item = new List<ASI_TH_CRM_PaymentRequestLineItem__c>();
            PSF_Item_Map = new Map<Integer, ASI_TH_CRM_PaymentRequestLineItem__c>();
            indexPSF = 0;
            
            if(PSFList != null && PSFList.size()>0){
                for (ASI_TH_CRM_PaymentRequestLineItem__c psf :PSFList){
                    PSF_Item_Map.put(indexPSF++, psf);
                }
            }
            //---- PSF Line Item - by leo (end) ----
            
            if (PH.ASI_CRM_CN_Payment_Type__c != null && (PH.ASI_CRM_CN_Payment_Type__c.contains('Cash')||PH.ASI_CRM_CN_Payment_Type__c.contains('cash')))
                cashtype = true;
            else
                cashtype = false;        
            if (PH.ASI_CRM_CN_Payment_Type__c != null && (PH.ASI_CRM_CN_Payment_Type__c.contains('Discount')||PH.ASI_CRM_CN_Payment_Type__c.contains('discount')))
                discounttype = true;
            else
                discounttype = false;
                
            calcBRSFTotal();    
        }else{
            ASI_TH_CRM_PaymentRequest__c  ab;
            if(ApexPages.currentPage().getParameters().get('contractid') != null && ApexPages.currentPage().getParameters().get('contractid') != ''){
                ASI_TH_CRM_Contract__c contract = [Select ASI_CRM_CN_Outlet_WS__c, ASI_CRM_CN_PaymentRequestNumber__c, ASI_CRM_CN_PO_No__c, ASI_CRM_CN_PO_Version__c, ASI_CRM_CN_Bottle_Collection_Rate__c  
                                                   from ASI_TH_CRM_Contract__c where id =:ApexPages.currentPage().getParameters().get('contractid') limit 1];
                Decimal nextNumber = contract.ASI_CRM_CN_PaymentRequestNumber__c == null?1:contract.ASI_CRM_CN_PaymentRequestNumber__c+1;
                ab = new ASI_TH_CRM_PaymentRequest__c (ASI_CRM_CN_OutletWS__c = contract.ASI_CRM_CN_Outlet_WS__c,      
                                                       
                                                       
                                                       name=contract.ASI_CRM_CN_PO_No__c + '-'+digit_formatting(3,nextNumber ),
                                                       recordtypeid=Global_RecordTypeCache.getRtId('ASI_TH_CRM_PaymentRequest__cASI_CRM_CN_Payment_Request'),
                                                       ASI_CRM_CN_PO_Version__c = contract.ASI_CRM_CN_PO_Version__c,
                                                       ASI_CRM_CN_Bottle_Collection_Rate__c = contract.ASI_CRM_CN_Bottle_Collection_Rate__c,
                                                       ASI_CRM_CN_Adjustment__c = 100);
                ab.ASI_TH_CRM_Contract__c = (id)ApexPages.currentPage().getParameters().get('contractid');
            }
            else{
                ab = new ASI_TH_CRM_PaymentRequest__c (recordtypeid=ApexPages.currentPage().getParameters().get('recordtype'));
            }
            PH = ab;
        }  
        //lokman 30/5/2014
        if(OTPList != null && OTPList.size()>0){
            
            //20160613 Ben @ Elufa
            festivalMap = new Map<String, Boolean>();
            Map<String, Boolean> tmpMap = new Map<String, Boolean>();
            List<ASI_CRM_Contract_Cost_Setting__c> ccs = new List<ASI_CRM_Contract_Cost_Setting__c>([SELECT id, ASI_CRM_CN_Promotion_Type__c, ASI_CRM_Festival_Season__c, ASI_CRM_CN_Activity_Code__c FROM ASI_CRM_Contract_Cost_Setting__c WHERE RecordType.DeveloperName = 'ASI_CRM_CN_Contract_Cost_Setting']);
            
            for(ASI_CRM_Contract_Cost_Setting__c obj : ccs){
                tmpMap.put('' + obj.ASI_CRM_CN_Promotion_Type__c + obj.ASI_CRM_CN_Activity_Code__c, obj.ASI_CRM_Festival_Season__c);
            }
            //20160613 End
            
            //20160728 Ben @ Elufa
            
            isFestivalPSF = FALSE;
            
            if(LPSF.size() > 0 && PH.ASI_CRM_New_FY_Payment__c && tmpMap.containsKey(PH.ASI_CRM_CN_Promotion_Type__c + LPSF[0].ASI_CRM_CN_Activity_Code__c)){
                isFestivalPSF = tmpMap.get(PH.ASI_CRM_CN_Promotion_Type__c + LPSF[0].ASI_CRM_CN_Activity_Code__c);
            }
            //20160728 End
            
            for(ASI_TH_CRM_PaymentRequestLineItem__c  payment_request:OTPList){
                if(payment_request.ASI_CRM_CN_Expense_Type__c=='PRC - Down Payment - On Premise'){
                    downpayment=payment_request;
                    
                }
                
                //20160613 Ben @ Elufa
                if(tmpMap.containsKey(payment_request.ASI_TH_CRM_Payment_Request__r.ASI_CRM_CN_Promotion_Type__c + '' + payment_request.ASI_CRM_CN_AC_Code__c)){
                    festivalMap.put(payment_request.id, tmpMap.get(payment_request.ASI_TH_CRM_Payment_Request__r.ASI_CRM_CN_Promotion_Type__c + '' + payment_request.ASI_CRM_CN_AC_Code__c));
                }else{
                    festivalMap.put(payment_request.id, FALSE);
                }
                //20160613 End
            }
        }
        
        //***** downpayment validation missing (michael) ******
        Allow_Submit_For_Approval= true;
        
        retrievePicklist();
        
        
        LPaymentSummary = ASI_CRM_CN_PaymentRequestUtilCls.genPaymentSummary(PH,null);
        MPaymentSummary = new Map<String,ASI_CRM_CN_PaymentRequestUtilCls.PaymentSummary>();//20160816, added by Leo
        //LPaymentSummary = ASI_CRM_CN_PaymentRequestUtilCls.genPaymentSummaryAdv(PH, null, null , null);
        TotalPOEstAmt = 0;
        TotalPORemainAmt = 0;
        TotalRequestAmt = 0;
        
        //20160726 Ben @ Elufa
        TotalRemainAmtCNY = 0;
        TotalRemainAmtMAF = 0;
        TotalRemainAmtOthers = 0;
        
        TotalEstAmtCNY = 0;
        TotalEstAmtMAF = 0;
        TotalEstAmtOthers = 0;
        
        TotalRequestAmtCNY = 0;
        TotalRequestAmtMAF = 0;
        TotalRequestAmtOthers = 0;
        //20160726 End
        
        System.debug(LPaymentSummary);
        for(ASI_CRM_CN_PaymentRequestUtilCls.PaymentSummary ps : LPaymentSummary){
            TotalPOEstAmt += ps.POEstimateAmt;
            TotalPORemainAmt += ps.PORemainAmt;
            TotalRequestAmt += ps.PaymentRequestAmount;
            
            //20160726 Ben @ Elufa
            
            TotalEstAmtCNY += ps.cnyEst;
            TotalEstAmtMAF += ps.mafEst;
            TotalEstAmtOthers += ps.othersEst;
            
            TotalRemainAmtCNY += ps.cnyRemaining;
            TotalRemainAmtMAF += ps.mafRemaining;
            TotalRemainAmtOthers += ps.othersRemaining;
            
            TotalRequestAmtCNY += ps.cnyRequest;
            TotalRequestAmtMAF += ps.mafRequest;
            TotalRequestAmtOthers += ps.othersRequest;
            
            //20160726 End
            //20160816, added by Leo
            if(!MPaymentSummary.containsKey(ps.feeChiName))
                MPaymentSummary.put(ps.feeChiName, ps);
            //20160816, added by Leo
        }
        
        
    }
    
    // Added by Twinkle 26Sept2014 for return function
    public PageReference GoReturn(){
        List<ASI_TH_CRM_PaymentRequest__c> LPayment = [Select Id, ASI_TH_CRM_Status__c, ASI_CRM_CN_Return_Comments__c from ASI_TH_CRM_PaymentRequest__c where id=:PageId LIMIT 1];//20151210 Ben @ Elufa System add ASI_CRM_CN_Return_Comments__c
        List<Profile> LProfileID = [SELECT Id, Name FROM Profile WHERE Id=:userinfo.getProfileId() LIMIT 1];
        String profileName = LProfileID[0].Name;

        if(LPayment.size() > 0){ 
            if(LPayment [0].ASI_TH_CRM_Status__c != 'Submitted'){ 
                if(USerInfo.getLanguage()=='zh_CN')
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'付款不得退回！\nPO付款状态仅在"已提交"时方可退回。'));
                else
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Cannot Return Payment.\nOnly Payment with "Submitted" status can be returned'));
            } 
            else{ 
                //20151210 Ben @ Elufa System
                if(LPayment[0].ASI_CRM_CN_Return_Comments__c != ''){
                    try{
                        LPayment[0].ASI_CRM_CN_Return_Comments__c = '';
                        update LPayment[0];
                    }catch(dmlException e){
                        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Unable to save Return Comments'));
                    }
                }
                //20151210 End
                PageReference pageRef = new PageReference('/apex/ASI_CRM_CN_ReturnPaymentByBAPage?scontrolCaching=1&id='+PageId);
                pageRef.setRedirect(True);
                return pageRef;
            }
        }
        return null;       
    }
    // End - Twinkle Li 26Sept2014
    
    public String digit_formatting(Integer digit,Decimal numbers){
        Decimal base=Math.pow(10,(digit-1));
        String formate='';
        Decimal counter = numbers/base;
        if(counter>1)formate= String.valueOf(numbers);
        else{ 
            counter=0;
            for(Integer dec=Integer.valueOf(numbers);dec>0;dec=dec/10){
                counter++;
            }
            for(Integer a=0;a<digit-counter;a++){
                formate+='0';
            }
            
            formate +=numbers;
        }
        return formate;
    }
    
    //2014-06-16 Add checking for BRSF Date
    
    public pageReference saveDate(){
        checkBRSFDate();
        return null;
    }
    
    public boolean checkBRSFDate(){
        list<ASI_TH_CRM_PaymentRequest__c> PR_list = new list<ASI_TH_CRM_PaymentRequest__c>();
        map<id, map<date, date>> PR_brsf_map = new map<id, map<date, date>>();
        boolean allowSave = true;
        system.debug('PH.ASI_TH_CRM_Contract__c: ' + PH.ASI_TH_CRM_Contract__c);
        if (PH.ASI_TH_CRM_Contract__c != null ){
            if (PH.ASI_CRM_CN_BRSF_End_Date__c != null && PH.ASI_CRM_CN_BRSF_Start_Date__c != null){
                allowSave = true;
                
                //20151127 Ben @ Elufa
                date cutOffDate1 = CutOffDate(16);
                date PRSFStartDate;
                date PRSFEndDate;
                if(ph.ASI_CRM_CN_BRSF_Start_Date__c != null){
                    PRSFStartDate = ph.ASI_CRM_CN_BRSF_Start_Date__c.toStartOfMonth().addMonths(1).addDays(-1); 
                }
                if(ph.ASI_CRM_CN_BRSF_End_Date__c != null){
                    PRSFEndDate = ph.ASI_CRM_CN_BRSF_End_Date__c.toStartOfMonth().addMonths(1).addDays(-1); 
                }
                System.debug(LoggingLevel.INFO, '*** cutOffDate1: ' + cutOffDate1);
                System.debug(LoggingLevel.INFO, '*** PRSFStartDate: ' + PRSFStartDate);
                System.debug(LoggingLevel.INFO, '*** PRSFEndDate: ' + PRSFEndDate);
                if(cutOffDate1 < PRSFStartDate || cutOffDate1 < PRSFEndDate){
                    
                    String startString = '';
                    String endString = '';
                    if(USerInfo.getLanguage()=='zh_CN'){
                        startString = ' 以下月份的销量尚未更新至SFDC： ';
                        endString = ' 以下月份的销量尚未更新至SFDC： ';
                    }else{
                        startString = ' The volume of following months isn’t ready yet: ';
                        endString = ' The volume of following months isn’t ready yet: ';
                    }
                    
                    
                    date startdate = cutOffDate1.addMonths(1);
                    date enddate = cutOffDate1.addMonths(1);
                    
                    while(startdate <= PRSFStartDate){
                        startString += (startdate.year() + '-' + startdate.month()+ ', ');
                        startdate = startdate.addMonths(1);
                    }
                    
                    while(enddate <= PRSFEndDate){
                        endString += (enddate.year() + '-' + enddate.month() + ', ');
                        enddate = enddate.addMonths(1);
                    }
                    startString = startString.substring(0, startString.length() - 2 ); 
                    endString = endString.substring(0, endString.length() - 2 );
                    
                    ph.ASI_CRM_CN_BRSF_Start_Date__c.addError(startString, false);
                    ph.ASI_CRM_CN_BRSF_End_Date__c.addError(endString, false);
                    return FALSE;
                }
                //20151127 End
                
                //check BRSF date period is within PO date period
                if((PH.ASI_CRM_CN_BRSF_Start_Date__c >= PH.ASI_CRM_CN_PO_Start_Date__c && PH.ASI_CRM_CN_BRSF_End_Date__c <= PH.ASI_CRM_CN_PO_End_Date__c ) && (PH.ASI_CRM_CN_BRSF_Start_Date__c <= PH.ASI_CRM_CN_BRSF_End_Date__c) ){
                    //check whether other payment request BRSF period is overlapped. 
                    try{
                        PR_list = [SELECT Name, ASI_CRM_CN_BRSF_End_Date__c, ASI_CRM_CN_BRSF_Start_Date__c 
                                   FROM ASI_TH_CRM_PaymentRequest__c WHERE ASI_TH_CRM_Contract__c = :PH.ASI_TH_CRM_Contract__c
                                   AND ASI_CRM_CN_BRSF_End_Date__c != null AND ASI_CRM_CN_BRSF_Start_Date__c != null
                                   AND id != :PH.id];
                    }catch(exception e){
                        system.debug('Try PR_list failed: ' + e);
                    }
                    //20150915 Ben @ Elufa
                    Map<id, String> mapDuplication = new Map<id, String>();
                    system.debug('PR_list: ' + PR_list);
                    if (PR_list.size() > 0){
                        for (ASI_TH_CRM_PaymentRequest__c PR_list_temp : PR_list){
                            if (!PR_brsf_map.containskey(PR_list_temp.id)){
                                map<date, date> date_map = new map<date, date>();
                                date_map.put(PR_list_temp.ASI_CRM_CN_BRSF_Start_Date__c, PR_list_temp.ASI_CRM_CN_BRSF_End_Date__c);
                                PR_brsf_map.put(PR_list_temp.id, date_map);
                                mapDuplication.put(PR_list_temp.id, PR_list_temp.Name);
                            }
                        }
                    }
                    system.debug('PR_brsf_map: ' + PR_brsf_map);
                    if (PR_brsf_map.size() > 0){
                        integer strMonthS;
                        integer strMonthE;
                        // Edited by Michael Yip (Introv) 16Sep2014 to fix overlap payment
                        integer strYearS;
                        integer strYearE;
                        for(id PR_brsf_temp1 : PR_brsf_map.keyset()){
                            for (date PR_brsf_temp : PR_brsf_map.get(PR_brsf_temp1).keyset()){
                                system.debug('PR_brsf_temp Date: ' + PR_brsf_temp + ' to ' + PR_brsf_map.get(PR_brsf_temp1).get(PR_brsf_temp));
                                strMonthS = PR_brsf_temp.Month();
                                strMonthE = (PR_brsf_map.get(PR_brsf_temp1).get(PR_brsf_temp)).Month();
                                //Modified by William Yang(Introv) 20141209 to fix BRSF overlap checking
                                if ((PH.ASI_CRM_CN_BRSF_Start_Date__c >= PR_brsf_temp && PH.ASI_CRM_CN_BRSF_Start_Date__c <= PR_brsf_map.get(PR_brsf_temp1).get(PR_brsf_temp))
                                    || (PH.ASI_CRM_CN_BRSF_End_Date__c >= PR_brsf_temp && PH.ASI_CRM_CN_BRSF_End_Date__c <= PR_brsf_map.get(PR_brsf_temp1).get(PR_brsf_temp))
                                    || (PH.ASI_CRM_CN_BRSF_Start_Date__c.Month() == strMonthS && PH.ASI_CRM_CN_BRSF_Start_Date__c.Year() == strYearS)
                                    || (PH.ASI_CRM_CN_BRSF_Start_Date__c.Month() == strMonthE && PH.ASI_CRM_CN_BRSF_Start_Date__c.Year() == strYearE)
                                    || (PH.ASI_CRM_CN_BRSF_End_Date__c.Month() == strMonthS && PH.ASI_CRM_CN_BRSF_End_Date__c.Year() == strYearS)
                                    || (PH.ASI_CRM_CN_BRSF_End_Date__c.Month() == strMonthE && PH.ASI_CRM_CN_BRSF_End_Date__c.Year() == strYearE )
                                    || (PH.ASI_CRM_CN_BRSF_Start_Date__c <= PR_brsf_temp && PH.ASI_CRM_CN_BRSF_End_Date__c >= PR_brsf_map.get(PR_brsf_temp1).get(PR_brsf_temp)))
                                    {                          
                                        if(USerInfo.getLanguage()=='zh_CN'){
                                            PH.ASI_CRM_CN_BRSF_Start_Date__c.addError('空瓶回收费所选月份已由付款申请号(' + mapDuplication.get(PR_brsf_temp1) + ')支付。');
                                            PH.ASI_CRM_CN_BRSF_End_Date__c.addError('空瓶回收费所选月份已由付款申请号(' + mapDuplication.get(PR_brsf_temp1) + ')支付。');
                                        }
                                        else{
                                            PH.ASI_CRM_CN_BRSF_Start_Date__c.addError('The BRSF amount for selected period has already been paid by Payment Request No : ' + mapDuplication.get(PR_brsf_temp1) + '.');
                                            PH.ASI_CRM_CN_BRSF_End_Date__c.addError('The BRSF amount for selected period has already been paid by Payment Request No : ' + mapDuplication.get(PR_brsf_temp1) + '.');
                                        }
                                        allowSave = false;
                                    }
                            }
                        }
                    }
                    system.debug('allowSave: ' + allowSave);
                    if (allowSave){
                        try{
                            update PH;
                        }
                        catch(exception e){
                            apexpages.addmessages(e);
                        }
                    }
                }else{
                    if(PH.ASI_CRM_CN_BRSF_Start_Date__c > PH.ASI_CRM_CN_BRSF_End_Date__c){
                        if(USerInfo.getLanguage()=='zh_CN'){
                            PH.ASI_CRM_CN_BRSF_Start_Date__c.addError('空瓶回收费开始日期不能大于空瓶回收费结束日期');
                            PH.ASI_CRM_CN_BRSF_End_Date__c.addError('空瓶回收费结束日期不能小于空瓶回收费开始日期');
                        }
                        else{
                            PH.ASI_CRM_CN_BRSF_Start_Date__c.addError('BRSF start date can\'t be greater than BRSF end date');
                            PH.ASI_CRM_CN_BRSF_End_Date__c.addError('BRSF end date can\'t be less than BRSF end date');
                        }
                    }else{
                        if(USerInfo.getLanguage()=='zh_CN'){
                            PH.ASI_CRM_CN_BRSF_Start_Date__c.addError('空瓶回收费付款月份需在PO期间内选择。');
                            PH.ASI_CRM_CN_BRSF_End_Date__c.addError('空瓶回收费付款月份需在PO期间内选择。');
                        }
                        else{
                            PH.ASI_CRM_CN_BRSF_Start_Date__c.addError('Please select the BRSF Period within PO Period.');
                            PH.ASI_CRM_CN_BRSF_End_Date__c.addError('Please select the BRSF Period within PO Period.');
                        }
                    }
                    allowSave = false;
                }
            }else {
                
                if(PH.ASI_CRM_CN_BRSF_End_Date__c == NULL && PH.ASI_CRM_CN_BRSF_Start_Date__c != NULL){
                    if(USerInfo.getLanguage()=='zh_CN'){
                        PH.ASI_CRM_CN_BRSF_End_Date__c.addError('空瓶回收费付款月份需在PO期间内选择。');
                    }else{
                        PH.ASI_CRM_CN_BRSF_End_Date__c.addError('Please select the BRSF Period within PO Period.');
                    }
                    allowSave = false;
                }else if(PH.ASI_CRM_CN_BRSF_Start_Date__c == NULL && PH.ASI_CRM_CN_BRSF_End_Date__c != NULL){
                    if(USerInfo.getLanguage()=='zh_CN'){
                        PH.ASI_CRM_CN_BRSF_Start_Date__c.addError('空瓶回收费付款月份需在PO期间内选择。');
                    }else{
                        PH.ASI_CRM_CN_BRSF_Start_Date__c.addError('Please select the BRSF Period within PO Period.');
                    }
                    allowSave = false;
                }
            }
        }
        return allowSave;
        
    }//2014-06-16 Edit End.
    
    
    
    public void updatePOVersion(){
        if(ph.ASI_TH_CRM_Contract__r.ASI_TH_CRM_Contract_Status__c== 'Final'){
            ph.ASI_CRM_CN_PO_Version__c = ph.ASI_CRM_CN_PO_Version_Latest__c;
        }else if (ph.ASI_TH_CRM_Contract__r.ASI_CRM_CN_Last_PO_version__r.ASI_CRM_CN_PO_Version__c != null) {
            ph.ASI_CRM_CN_PO_Version__c = ph.ASI_TH_CRM_Contract__r.ASI_CRM_CN_Last_PO_version__r.ASI_CRM_CN_PO_Version__c ;
        }
        update PH;
    }
    
    public PageReference UpdateRecord(){
        if (PageId != null){
            update PH;
        }else{
            
            ASI_TH_CRM_Contract__c contract = [Select ASI_CRM_CN_Is_2nd_KPI_PO__c,ASI_CRM_CN_Last_PO_version__r.CreatedDate,CreatedDate,ASI_CRM_CN_PO_No__c, ASI_CRM_New_FY_PO__c //20160602 Ben @ Elufa    
                                               from ASI_TH_CRM_Contract__c where id =:PH.ASI_TH_CRM_Contract__c limit 1];

            if(ContractDateKey&&contract.ASI_CRM_CN_Last_PO_version__r.CreatedDate!=null&&contract.ASI_CRM_CN_Is_2nd_KPI_PO__c){
                if(Date.valueOf(contract.ASI_CRM_CN_Last_PO_version__r.CreatedDate).daysBetween(Date.today())>=90){
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING,System.Label.ASI_CRM_CN_Heavy_payment_amount_Checking));
                    ContractDateKey=false;
                    return null;
                }
            }else if(ContractDateKey&&Date.valueOf(contract.CreatedDate).daysBetween(Date.today())>=90&&contract.ASI_CRM_CN_Is_2nd_KPI_PO__c){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING,System.Label.ASI_CRM_CN_Heavy_payment_amount_Checking));
                ContractDateKey=false;
                return null;
            }

            //****** edited by leo @20140806 (start) ******
            string tempPHName_seq = '';
            Integer tmpPHSeq = 0;
            Integer countPH = 0;
            List<ASI_TH_CRM_PaymentRequest__c> listOtherPH = [SELECT id, Name FROM ASI_TH_CRM_PaymentRequest__c WHERE ASI_TH_CRM_Contract__c =:PH.ASI_TH_CRM_Contract__c ORDER BY Name Desc];

            if(listOtherPH != null && listOtherPH.size() > 0)
            {
              for(ASI_TH_CRM_PaymentRequest__c tmpPH : listOtherPH)
              {
                string[] strName = tmpPH.Name.split('-');
                if(strName.size() > 1)
                {
                  if(strName[1].isNumeric())
                  {
                    if(Integer.valueOf(strName[1]) > tmpPHSeq)
                      tmpPHSeq = Integer.valueOf(strName[1]);
                  }
                }

                countPH += 1;
              } 
            }
            
            if(tmpPHSeq == 0 && countPH == 0)
            {
              tempPHName_seq = '001';
            }
            else
            {
              if(tmpPHSeq > countPH)
              {
                tempPHName_seq = digit_formatting(3, tmpPHSeq + 1);
              }
              else  
              {
                tempPHName_seq = digit_formatting(3, countPH + 1);
              }
            }

            PH.Name = contract.ASI_CRM_CN_PO_No__c + '-' + tempPHName_seq; 

            //****** edited by leo @20140806 (end) ******        
            
            PH.ASI_CRM_New_FY_Payment__c = contract.ASI_CRM_New_FY_PO__c;//20160602 Ben @ Elufa
            
            try{upsert PH;
                PageId = PH.id;}
            catch(Exception exp){
                return null;
            }
        }
        PageReference ab = new PageReference('/apex/ASI_CRM_CN_Payment_Header_Page'); 
        //PageReference ab= new PageReference('http://www.google.com'); 
        ab.getParameters().put('id',PageId); 
        ab.setRedirect(true); 
        return ab;
    }
    public PageReference CancelBRSFChange(){
        
        String headerId = ApexPages.currentPage().getParameters().get('id');
        
        ASI_TH_CRM_PaymentRequest__c tmpPayment = [SELECT ASI_CRM_CN_BRSF_End_Date__c
                                                   , ASI_CRM_CN_BRSF_Start_Date__c 
                                                   FROM ASI_TH_CRM_PaymentRequest__c
                                                   WHERE ID = : headerId
                                                  ];
        PH.ASI_CRM_CN_BRSF_Start_Date__c = tmpPayment.ASI_CRM_CN_BRSF_Start_Date__c;
        PH.ASI_CRM_CN_BRSF_End_Date__c = tmpPayment.ASI_CRM_CN_BRSF_End_Date__c;
        
        PageReference ab = new PageReference('/apex/ASI_CRM_CN_EditPaymentDetailsPage'); 
        //PageReference ab= new PageReference('http://www.google.com'); 
        ab.getParameters().put('id',PageId); 
        ab.setRedirect(true); 
        return null;
    }
    
    public void calcBRSF_Total(){
        if(PH != null){
            System.debug(ph);
            if (PH.ASI_CRM_CN_Adjustment__c != null)
                update PH;
            for(ASI_TH_CRM_PaymentRequestLineItem__c item : BRSFList){
                //Updated by William Yang(Introv) 20141205 for #185
                if(item.ASI_CRM_CN_Payable_Vol__c == null)
                    item.ASI_CRM_CN_Payable_Vol__c = 0;
                if(item.ASI_CRM_CN_Incentive_BT__c == null)
                    item.ASI_CRM_CN_Incentive_BT__c = 0;
                if(item.ASI_CRM_Suggested_Volume__c == null)
                    item.ASI_CRM_Suggested_Volume__c = 0;
                if(item.ASI_CRM_CN_Payable_Vol__c != null && item.ASI_CRM_CN_Incentive_BT__c != null){
                    item.ASI_CRM_CN_Suggested_Amount__c = item.ASI_CRM_Suggested_Volume__c * item.ASI_CRM_CN_Incentive_BT__c;
                    item.ASI_CRM_CN_Total_Payable__c = item.ASI_CRM_CN_Payable_Vol__c * item.ASI_CRM_CN_Incentive_BT__c;
                }
                else
                    item.ASI_CRM_CN_Total_Payable__c = 0;
            }
            if(PH.ASI_CRM_CN_Adjustment__c > 100){
                require_overpayment_reason=true;
                require_other_reason=true;
            }  
            calcbrsftotal();
        }
    }
    
    //20151127 Ben @ Elufa
    public date CutOffDate(integer strDay){
        Date returnDate;
        Integer strDate = Date.Today().Day();
        Integer strMonth;
        Integer strEndDay;
        Integer strYear;
        if (strDay != 0){
            if (strDate >= strDay){
                strMonth = Date.Today().addMonths(-1).Month();
                strYear = Date.Today().addMonths(-1).year();
            }
            if (strDate < strDay){
                strMonth = Date.Today().addMonths(-2).Month();
                strYear = Date.Today().addMonths(-2).year();
            }
            strEndDay = Date.daysInMonth(strYear, strMonth);
            returnDate = Date.newinstance(strYear,strMonth,strEndDay);
        }else{
            returnDate = Date.Today();
        }
        return returnDate;
    }
    //20151127 End
    
    public pageReference regenerateBRSFVol(){
        if(checkBRSFDate()){
            
            ASI_TH_CRM_PaymentRequest__c LPaymentUpdated = [Select id, name, ASI_CRM_CN_Payable_Amount__c, ASI_CRM_CN_Other_Reason__c, ASI_TH_CRM_Status__c, ASI_CRM_CN_Bottle_Collection_Rate__c,  ASI_CRM_CN_BRSF_End_Date__c, ASI_CRM_CN_BRSF_Start_Date__c,                   
                                                            ASI_CRM_CN_Channel__c, ASI_CRM_CN_Currency__c, ASI_CRM_CN_Last_Payment__c, 
                                                            ASI_CRM_CN_Last_Year_Payment__c,ASI_CRM_CN_Division__c,
                                                            ASI_CRM_CN_OutletWS__c, ASI_CRM_CN_Payment_Raised_Date__c, ASI_CRM_CN_Payment_Type__c, 
                                                            ASI_CRM_CN_PO_End_Date__c,ASI_TH_CRM_Contract__r.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Region__c,
                                                            ASI_CRM_CN_PO_No__c, ASI_CRM_CN_PO_Start_Date__c, ASI_CRM_CN_PO_Version__c, 
                                                            ASI_CRM_CN_Promotion_Type__c,ASI_TH_CRM_Contract__r.ASI_CRM_CN_Outlet_WS__c,ASI_CRM_CN_OutletWS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__r.ASI_CRM_Region_Code__c,
                                                            ASI_CRM_CN_Reference_Code__c,ASI_TH_CRM_Total_Amount__c, ASI_CRM_CN_Total_Other_Amount__c, 
                                                            ASI_CRM_CN_PO_Version_Latest__c, ASI_CRM_CN_Overpayment_Reason__c,
                                                            ASI_CRM_CN_Total_BRSF_Amount__c,ASI_CRM_CN_Reason_For_Business_License__c, 
                                                            ASI_CRM_CN_Business_License_Qualify__c ,ASI_CRM_CN_Total_PSF_Amount__c, 
                                                            ASI_CRM_CN_Adjustment__c, ASI_CRM_CN_No_of_Month__c , ASI_CRM_CN_Total_Payment__c,
                                                            ASI_TH_CRM_Contract__r.ASI_TH_CRM_Promotion_Type__c, ASI_TH_CRM_Contract__r.ASI_CRM_Volume_Option__c,
                                                            ASI_CRM_CN_Overpayment_Comment__c, ASI_TH_CRM_Contract__c,ASI_TH_CRM_Contract__r.ASI_CRM_CN_Total_Contract_Amount__c, ASI_CRM_CN_Description__c,
                                                            ASI_TH_CRM_Contract__r.ASI_CRM_CN_V0_0_PO_version__c
                                                            from ASI_TH_CRM_PaymentRequest__c where id =:ph.id limit 1];
            ASI_CRM_CN_PaymentRequestUtilCls.genBRSF(LPaymentUpdated ,ph.ASI_CRM_CN_BRSF_Start_Date__c ,ph.ASI_CRM_CN_BRSF_End_Date__c );
            calcBRSF_Total();
            
            PageReference ab = new PageReference('/apex/ASI_CRM_CN_EditPaymentDetailsPage'); 
            
            ab.getParameters().put('id',PageId); 
            ab.setRedirect(true); 
            return ab;
        } 
        return null;
    }
    public void calcBRSFTotal(){
        if(ph!=null){
            PH.ASI_CRM_CN_Payable_Amount__c = 0;
            Decimal totalActual = 0;
            Decimal totalTarget = 0;
            completionRate = 0;
            for(ASI_TH_CRM_PaymentRequestLineItem__c item : BRSFList){
                if(item.ASI_CRM_CN_Total_Payable__c != null){
                    PH.ASI_CRM_CN_Payable_Amount__c += item.ASI_CRM_CN_Total_Payable__c;
                }
                if(item.ASI_CRM_CN_Actual_Vol__c != null)
                    totalActual += item.ASI_CRM_CN_Actual_Vol__c;
                if(item.ASI_CRM_CN_Target_BT__c != null)
                    totalTarget += item.ASI_CRM_CN_Target_BT__c;
            }
            if(BRSFList.size()>0 && totalTarget > 0){
                completionRate = totalActual/totalTarget*100;
            }
            if(PH.ASI_CRM_CN_Payable_Amount__c != null && PH.ASI_CRM_CN_Adjustment__c!= null){
                actualPayment = PH.ASI_CRM_CN_Payable_Amount__c * PH.ASI_CRM_CN_Adjustment__c / 100;
            }
            showcalc = true;
        }
        
    }

    public PageReference UpdatePayeeRecord() {
        boolean hasError = false;
        sum_of_payee_amount=0;
        //---- delete PSF Line Items - by leo (start) ----
        List <ASI_CRM_CN_PH_Payee_Line_Item__c> Del_PSF_Item_Temp = new List <ASI_CRM_CN_PH_Payee_Line_Item__c>();
        if(Del_Payee_Item_CASH != null && Del_Payee_Item_CASH.size()>0)
        {
            //List <ASI_CRM_CN_PH_Payee_Line_Item__c> Del_PSF_Item_Temp = new List <ASI_CRM_CN_PH_Payee_Line_Item__c>();
            for (ASI_CRM_CN_PH_Payee_Line_Item__c b : Del_Payee_Item_CASH)
            {
                if(b.Id != null)
                    Del_PSF_Item_Temp.add(b);
            }
        }
        
        if(Del_Payee_Item_DISCOUNT != null && Del_Payee_Item_DISCOUNT .size()>0)
        {
            //List <ASI_CRM_CN_PH_Payee_Line_Item__c> Del_PSF_Item_Temp = new List <ASI_CRM_CN_PH_Payee_Line_Item__c>();
            for (ASI_CRM_CN_PH_Payee_Line_Item__c b : Del_Payee_Item_DISCOUNT )
            {
                if(b.Id != null)
                    Del_PSF_Item_Temp.add(b);
            }
        }
        
        if(Del_Payee_Item_CD != null && Del_Payee_Item_CD .size()>0)
        {
            for (ASI_CRM_CN_PH_Payee_Line_Item__c b : Del_Payee_Item_CD )
            {
                if(b.Id != null)
                    Del_PSF_Item_Temp.add(b);
            }
        }
        
        
        if(Del_PSF_Item_Temp != null && Del_PSF_Item_Temp.size() > 0)
            delete Del_PSF_Item_Temp;
        
        //---- delete PSF Line Items - by leo (end) ----
        
        //---- save PSF Line Items - by leo (start) ----
        Save_Payee_Item_CASH = new List<ASI_CRM_CN_PH_Payee_Line_Item__c>();
        for (integer i : Payee_Item_Map_CASH.keySet())
        {
            ASI_CRM_CN_PH_Payee_Line_Item__c psf = Payee_Item_Map_CASH.get(i);
            
            if(psf.ASI_CRM_CN_Payment_Request__c == null)
                psf.ASI_CRM_CN_Payment_Request__c = PH.Id;
            if (psf.ASI_CRM_CN_Amount__c < 0 && (psf.ASI_CRM_CN_Reason__c == null || psf.ASI_CRM_CN_Reason__c == '')){
                hasError = true;
                
                if(USerInfo.getLanguage()=='zh_CN')
                    psf.ASI_CRM_CN_Reason__c.addError('必填项未填完整。');
                else
                    psf.ASI_CRM_CN_Reason__c.addError('The column is required to fill in.');
            }
            if(psf.ASI_CRM_CN_Amount__c!=null && psf.ASI_CRM_CN_Amount__c!=0){
                sum_of_payee_amount+=psf.ASI_CRM_CN_Amount__c;
            }
            if(psf.RecordTypeId == null)
                psf.RecordTypeId = Global_RecordTypeCache.getRTid('ASI_CRM_CN_PH_Payee_Line_Item__cASI_CRM_CN_Payee');
            if(psf.ASI_CRM_CN_Cash_Payee_Name_T1__c == NULL || String.valueOf(psf.ASI_CRM_CN_Cash_Payee_Name_T1__c) == '' || psf.ASI_CRM_CN_Amount__c == null){
                hasError = true;
                if(psf.ASI_CRM_CN_Cash_Payee_Name_T1__c == NULL || String.valueOf(psf.ASI_CRM_CN_Cash_Payee_Name_T1__c) == ''){
                    //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,Schema.ASI_CRM_CN_PH_Payee_Line_Item__c.fields.ASI_CRM_CN_Cash_Payee_Name_T1__c.getDescribe().getLabel()+': 必填项未填完整'));
                    if(USerInfo.getLanguage()=='zh_CN')
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'收款方信息为必填项'));
                    else
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Please input payee information.'));
                }
                if(psf.ASI_CRM_CN_Amount__c == null){
                    if(USerInfo.getLanguage()=='zh_CN')
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'付款金额为必填项'));
                    else
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Please input payment amount.'));
                }
            }
            else
                Save_Payee_Item_CASH.add(psf);
        } 
        Save_Payee_Item_DISCOUNT = new List<ASI_CRM_CN_PH_Payee_Line_Item__c>();
        for (integer i : Payee_Item_Map_DISCOUNT.keySet())
        {
            ASI_CRM_CN_PH_Payee_Line_Item__c psf = Payee_Item_Map_DISCOUNT.get(i);
            
            if(psf.ASI_CRM_CN_Payment_Request__c == null)
                psf.ASI_CRM_CN_Payment_Request__c = PH.Id;
            
            if (psf.ASI_CRM_CN_Amount__c < 0 && (psf.ASI_CRM_CN_Reason__c == null || psf.ASI_CRM_CN_Reason__c == '')){
                hasError = true;
                if(USerInfo.getLanguage()=='zh_CN')
                    psf.ASI_CRM_CN_Reason__c.addError('必填项未填完整。');
                else
                    psf.ASI_CRM_CN_Reason__c.addError('The column is required to fill in.');
            }
            if(psf.ASI_CRM_CN_Amount__c!=null && psf.ASI_CRM_CN_Amount__c!=0){
                sum_of_payee_amount+=psf.ASI_CRM_CN_Amount__c;
            }
            if(psf.RecordTypeId == null)
                psf.RecordTypeId = Global_RecordTypeCache.getRTid('ASI_CRM_CN_PH_Payee_Line_Item__cASI_CRM_CN_Payee');
            if(psf.ASI_CRM_CN_Payee_T2__c== null || String.valueOf(psf.ASI_CRM_CN_Payee_T2__c) == '' || psf.ASI_CRM_CN_Payee_T1__c== null || psf.ASI_CRM_CN_Amount__c == null){
                hasError = true;
                if(psf.ASI_CRM_CN_Payee_T2__c== null || String.valueOf(psf.ASI_CRM_CN_Payee_T2__c) == ''){
                    //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,Label.ASI_CRM_CN_VF_LABEL_T2_WS+': 必填项未填完整'));
                    if(USerInfo.getLanguage()=='zh_CN')
                        psf.ASI_CRM_CN_Payee_T2__c.addError('必填项未填完整。');
                    else
                        psf.ASI_CRM_CN_Payee_T2__c.addError('The column is required to fill in.');
                }
                if(psf.ASI_CRM_CN_Payee_T1__c== null){
                    //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,Label.ASI_CRM_CN_VF_LABEL_T1_WS+': 必填项未填完整'));
                    if(USerInfo.getLanguage()=='zh_CN')
                        psf.ASI_CRM_CN_Payee_T1__c.addError('必填项未填完整。');
                    else
                        psf.ASI_CRM_CN_Payee_T1__c.addError('The column is required to fill in.');
                }
                if(psf.ASI_CRM_CN_Amount__c== null){
                    if(USerInfo.getLanguage()=='zh_CN')
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'付款金额为必填项'));
                    else
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Please input payment amount.'));
                }    
            }
            else
                Save_Payee_Item_DISCOUNT.add(psf);
        }
        Save_Payee_Item_CD = new List<ASI_CRM_CN_PH_Payee_Line_Item__c>();
        for (integer i : Payee_Item_Map_CD.keySet())
        {
            ASI_CRM_CN_PH_Payee_Line_Item__c psf = Payee_Item_Map_CD.get(i);
            system.debug('Payee_Item_Map_CD: psf ' + psf);
            if(psf.ASI_CRM_CN_Payment_Request__c == null)
                psf.ASI_CRM_CN_Payment_Request__c = PH.Id;
            
            if (psf.ASI_CRM_CN_Amount__c < 0 && (psf.ASI_CRM_CN_Reason__c == null || psf.ASI_CRM_CN_Reason__c == '')){
                hasError = true;
                if(USerInfo.getLanguage()=='zh_CN')
                    psf.ASI_CRM_CN_Reason__c.addError('必填项未填完整。');
                else
                    psf.ASI_CRM_CN_Reason__c.addError('The column is required to fill in.');
            }
            if(psf.ASI_CRM_CN_Amount__c!=null && psf.ASI_CRM_CN_Amount__c!=0){
                sum_of_payee_amount+=psf.ASI_CRM_CN_Amount__c;
            }
            if(psf.RecordTypeId == null)
                psf.RecordTypeId = Global_RecordTypeCache.getRTid('ASI_CRM_CN_PH_Payee_Line_Item__cASI_CRM_CN_Payee');
            if(psf.ASI_CRM_CN_Payee_T2__c == null || String.valueOf(psf.ASI_CRM_CN_Payee_T2__c) == '' || psf.ASI_CRM_CN_Payee_T1__c == null || psf.ASI_CRM_CN_Amount__c == null){
                hasError = true;
                if(psf.ASI_CRM_CN_Payee_T2__c== null || String.valueOf(psf.ASI_CRM_CN_Payee_T2__c) == ''){
                    if(USerInfo.getLanguage()=='zh_CN')
                        psf.ASI_CRM_CN_Payee_T2__c.addError('必填项未填完整。');
                    else
                        psf.ASI_CRM_CN_Payee_T2__c.addError('The column is required to fill in.');
                }
                if(psf.ASI_CRM_CN_Payee_T1__c== null){
                    if(USerInfo.getLanguage()=='zh_CN')
                        psf.ASI_CRM_CN_Payee_T1__c.addError('必填项未填完整。');
                    else
                        psf.ASI_CRM_CN_Payee_T1__c.addError('The column is required to fill in.');
                }
                if(psf.ASI_CRM_CN_Amount__c== null){
                    if(USerInfo.getLanguage()=='zh_CN')
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'付款金额为必填项'));
                    else
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Please input payment amount.'));
                }        
            }
            else
                Save_Payee_Item_CD.add(psf);
        }
        system.debug('payee_amount'+sum_of_payee_amount);
        system.debug('total amount'+PH.ASI_CRM_CN_Total_Payment__c);
        Decimal payee_amount= sum_of_payee_amount.setScale(2, RoundingMode.HALF_UP);
        Decimal total_Amount = PH.ASI_CRM_CN_Total_Payment__c.setScale(2, RoundingMode.HALF_UP);
        // Decimal total_Amount = 0; 
        // if (PH.ASI_TH_CRM_Contract__r.ASI_CRM_CN_Is_2nd_KPI_PO__c) {
        //     for(ASI_CRM_Module__c Module: [select Id,ASI_CRM_Completion_Ratio__c,ASI_CRM_Methodology__r.ASI_CRM_Chinese_Name__c,ASI_CRM_Parent_Module__r.ASI_CRM_Payment_Reference__c,ASI_CRM_Parent_Module__r.ASI_CRM_Remark__c,ASI_CRM_Suggested_Payable_Amount__c,ASI_CRM_Parent_Module__r.ASI_CRM_Reason_NCD_Volume_Base__c,ASI_CRM_Parent_Module__r.ASI_CRM_Reason_Not_NCD_Methodology__c,ASI_CRM_Parent_Module__c,ASI_CRM_Methodology__r.ASI_CRM_Methodology_Code__c,
        //                                ASI_CRM_End_Date__c,ASI_CRM_Parent_Module__r.ASI_CRM_Unit__c,ASI_CRM_Parent_Module__r.ASI_CRM_Volume_Base__c,ASI_CRM_Other_Comments__c,ASI_CRM_Overpayment_Reason__c,ASI_CRM_PSF_Overpayment_Reason__c,ASI_CRM_Parent_Module__r.ASI_CRM_CN_Expected_Est_Total__c,ASI_CRM_Parent_Module__r.ASI_CRM_CN_AC_Code__c,
        //                                ASI_CRM_Actual_Payment__c,ASI_CRM_Adjustment__c,ASI_CRM_Application_Payment_Amount__c,ASI_CRM_Historical_Paid_Amount__c, ASI_CRM_Line_Type__c,ASI_CRM_Remark__c,ASI_CRM_Unit__c,ASI_CRM_VEC_Overpayment_Reason__c,
        //                                ASI_CRM_Volume_Base__c,ASI_CRM_Methodology__c,ASI_CRM_Methodology__r.Name,ASI_CRM_Reason_Not_NCD_Methodology__c,ASI_CRM_Reason_NCD_Volume_Base__c,
        //                               ASI_CRM_CN_AC_Code__r.ASI_MFM_A_C_CN_Description__c,ASI_CRM_CN_AC_Code__r.ASI_MFM_A_C_Description__c from ASI_CRM_Module__c where ASI_CRM_Payment_Request__c =:PH.Id ]) {
        //         total_Amount += Module.ASI_CRM_Actual_Payment__c != null? Module.ASI_CRM_Actual_Payment__c:0;
        //     }
        //     PH.ASI_CRM_Total_Actual_Amount__c = total_Amount;
        //     update PH;
        //     total_Amount = total_Amount.setScale(2, RoundingMode.HALF_UP);
        // } 
        // else {
        //     total_Amount = PH.ASI_CRM_CN_Total_Payment__c.setScale(2, RoundingMode.HALF_UP);
        // }
        if(payee_amount!=total_Amount){
            hasError=true;
        }
        if (hasError != true){
            if(Save_Payee_Item_CASH != null && Save_Payee_Item_CASH.size() > 0)
                System.debug('Wilson' +  Save_Payee_Item_CASH);
                upsert Save_Payee_Item_CASH;
            if(Save_Payee_Item_DISCOUNT != null && Save_Payee_Item_DISCOUNT.size() > 0)
                upsert Save_Payee_Item_DISCOUNT;
            system.debug('Save_Payee_Item_CD: ' + Save_Payee_Item_CD);
            if(Save_Payee_Item_CD != null && Save_Payee_Item_CD.size() > 0)
                upsert Save_Payee_Item_CD;
            //---- save PSF Line Items - by leo (end) ----
            
            //============================================================================
            
            system.debug('Go to Main Page');
            PageReference redirect = new PageReference('/apex/ASI_CRM_RedirectPRViewPage');  // change by laputa 20170826 ASI_CRM_CN_Payment_Header_Page
            redirect.getParameters().put('id',PageId); 
            redirect.setRedirect(true);
            return redirect;
        }else{
            
            if(payee_amount!=total_Amount){
                if(USerInfo.getLanguage()=='zh_CN')
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'报错：付款方金额加总须与付款申请总额一致。付款方金额：'+payee_amount+'。 付款申请总额：'+total_Amount));
                else
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Error: The total amount in payment detail should consistent with the one in payment information.  Payment amount: '+payee_amount+'. Total Payment Amount: '+total_Amount));
            }
            return null;
        }
        
    }
    
    public PageReference submitApproval(){
        boolean isOverRemaining = false;
        //[start]uncomment by Laputa - kevin due to recover this logic  
        if (LPaymentSummary.size() > 0){
            for (ASI_CRM_CN_PaymentRequestUtilCls.PaymentSummary pstemp : LPaymentSummary){
                system.debug('current payment summary');
                system.debug(pstemp);
                if ((pstemp.PORemainAmt >= 0 && pstemp.PaymentRequestAmount > pstemp.PORemainAmt + 1) ||     // 20151209 Ben @ Elufa System add 1 RMB Buffer
                    (pstemp.PORemainAmt < 0 && Math.abs(pstemp.PaymentRequestAmount) > Math.abs(pstemp.PORemainAmt)+ 1))
                    isOverRemaining = true;
                
                //20160726 Ben @ Elufa
                
              // if((pstemp.cnyRequest > pstemp.cnyRemaining || pstemp.mafRequest > pstemp.mafRemaining || pstemp.othersRequest > pstemp.othersRemaining) && PH.ASI_CRM_New_FY_Payment__c){
                 // isOverRemaining = true; 
               // }
                 system.debug('isOverRemaining'+ isOverRemaining);
                //20160726 End
            }
        }
        //[End]uncomment by Laputa - kevin due to recover this logic         
        if (isOverRemaining == true){
            if(USerInfo.getLanguage()=='zh_CN')
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'付款申请金额不能超过PO剩余金额！'));
            else
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Each Account payment amount could not larger than PO Remaining Amount.'));
            return null;
        }else{
            PageReference redirect = null;
            sum_of_payee_amount=0;
            for (ASI_CRM_CN_PH_Payee_Line_Item__c psf : PHPayee_Cash)
            {            
                if(psf.ASI_CRM_CN_Amount__c!=null && psf.ASI_CRM_CN_Amount__c!=0){
                    sum_of_payee_amount+=psf.ASI_CRM_CN_Amount__c;
                }           
            }
            for (ASI_CRM_CN_PH_Payee_Line_Item__c psf : PHPayee_Discount)
            {            
                if(psf.ASI_CRM_CN_Amount__c!=null && psf.ASI_CRM_CN_Amount__c!=0){
                    sum_of_payee_amount+=psf.ASI_CRM_CN_Amount__c;
                }           
            }
            for (ASI_CRM_CN_PH_Payee_Line_Item__c psf : PHPayee_CD)
            {            
                if(psf.ASI_CRM_CN_Amount__c!=null && psf.ASI_CRM_CN_Amount__c!=0){
                    sum_of_payee_amount+=psf.ASI_CRM_CN_Amount__c;
                }           
            }
            Decimal payee_amount= sum_of_payee_amount.setScale(2, RoundingMode.HALF_UP);
            Decimal total_Amount= PH.ASI_CRM_CN_Total_Payment__c.setScale(2, RoundingMode.HALF_UP);
            if ((PH.ASI_TH_CRM_Contract__r.ASI_CRM_CN_Total_Contract_Amount__c >= 0 && PH.ASI_CRM_CN_Total_Payment__c > PH.ASI_TH_CRM_Contract__r.ASI_CRM_CN_Total_Contract_Amount__c) || 
                (PH.ASI_TH_CRM_Contract__r.ASI_CRM_CN_Total_Contract_Amount__c < 0 && Math.abs(PH.ASI_CRM_CN_Total_Payment__c) > Math.abs(PH.ASI_TH_CRM_Contract__r.ASI_CRM_CN_Total_Contract_Amount__c))){
                //ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Payment Amount > PO Amount. Please modify the detail amount and submit again. Payment Amount:'+PH.ASI_CRM_CN_Total_Payment__c+'    PO Amount:'+PH.ASI_TH_CRM_Contract__r.ASI_CRM_CN_Total_Contract_Amount__c);
                ApexPages.Message msg;
                if(USerInfo.getLanguage()=='zh_CN')
                    msg = new ApexPages.Message(ApexPages.Severity.ERROR, '付款金额 > PO金额！需修改付款明细并重新提交。付款金额：'+PH.ASI_CRM_CN_Total_Payment__c+'    PO金额：'+PH.ASI_TH_CRM_Contract__r.ASI_CRM_CN_Total_Contract_Amount__c);
                else
                    msg = new ApexPages.Message(ApexPages.Severity.ERROR,'Payment Amount>PO Amount, please modify and re-submit.');
                
                apexpages.addmessage(msg);
                redirect = null;
            }
            else if(sum_of_payee_amount!=total_Amount){                
                if(USerInfo.getLanguage()=='zh_CN')
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'报错：付款方金额加总须与付款申请总额一致。付款方金额：'+payee_amount+'。 付款申请总额：'+total_Amount));
                else
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Error: The total amount in payment detail should consistent with the one in payment information.  Payment amount: '+payee_amount+'. Total Payment Amount: '+total_Amount));
                redirect = null;
            }
            else{
                
                //Ben @ Elufa 20150924
                //Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
                //req.setObjectId(PageId);
                //Approval.ProcessResult result = Approval.process(req);
                //End
                
                redirect = new PageReference('/apex/ASI_CN_SubmitApprovalPage?id=' + PageId);
                //redirect = new PageReference('/p/process/Submit');
                //redirect.getParameters().put('id',PageId); 
                //redirect.setRedirect(true);
            }
            
            AggregateResult PaymentTotal = [SELECT SUM(ASI_CRM_CN_Total_Payment__c) totalPayment FROM ASI_TH_CRM_PaymentRequest__c WHERE ASI_TH_CRM_Contract__c = :PH.ASI_TH_CRM_Contract__c AND ASI_TH_CRM_Status__c <> 'Draft'];
            
            ASI_TH_CRM_Contract__c  contract = [SELECT ASI_CRM_CN_Total_Contract_Amount__c FROM ASI_TH_CRM_Contract__c WHERE Id = :PH.ASI_TH_CRM_Contract__c];
            
            Decimal totalPayment = 0;
            // added null checking by wilson 30/7/2014
            if(PaymentTotal.get('totalPayment') != null){
                totalPayment = Decimal.valueOf(String.valueOf(PaymentTotal.get('totalPayment')));
            }
            
            
            if((contract.ASI_CRM_CN_Total_Contract_Amount__c >= 0 && totalPayment + PH.ASI_CRM_CN_Total_Payment__c > (contract.ASI_CRM_CN_Total_Contract_Amount__c + 0.1)) || 
               (contract.ASI_CRM_CN_Total_Contract_Amount__c < 0 && Math.abs(totalPayment + PH.ASI_CRM_CN_Total_Payment__c) > (Math.abs(contract.ASI_CRM_CN_Total_Contract_Amount__c) + 0.1))){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,Label.ASI_CRM_CN_PaymentRequestTotalAmountCheckErrMsg));
                //apexpages.addmessage(msg);
                redirect = null;            
            }
            
            if(PH.ASI_TH_CRM_Contract__r.ASI_CRM_CN_Status__c != 'Final'){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,Label.ASI_CRM_CN_PaymentRequestSubmitErrorMsg));
                //apexpages.addmessage(msg);
                redirect = null;
            }
            
            return redirect;
        }
        //}  Allow_Submit_For_Approval CHECK
    }
    
    public PageReference UpdateDetailRecord() {
        boolean hasError = false;       // edited by leo @20140706
        
        require_overpayment_reason=false;
        require_other_reason=false;
        boolean redirect = true;
        totalpayment=0;

        Map<String, String> params = ApexPages.currentPage().getParameters();
        freeGoodsInterimData = (interimData) JSON.deserialize(params.get('freeGoodsJSON'), interimData.class);

        if (PH.ASI_CRM_CN_Promotion_Type__c  == 'Promotion' && freeGoodsInterimData.paymentRequestLines != null) {
            Decimal freegoodsAmount = 0;
            for (ASI_TH_CRM_PaymentRequestLineItem__c paymentRequest:freeGoodsInterimData.paymentRequestLines) {
                System.debug(LoggingLevel.INFO, '*** paymentRequest.ASI_CRM_CN_Total_Payable__c: ' + paymentRequest.ASI_CRM_CN_Total_Payable__c);
                freegoodsAmount += paymentRequest.ASI_CRM_CN_Total_Payable__c != null?paymentRequest.ASI_CRM_CN_Total_Payable__c:0;
            }
            System.debug(LoggingLevel.INFO, '*** freegoodsAmount: ' + freegoodsAmount);
            if (freegoodsAmount > 0) {
                Decimal payFee = 0;
                for (ASI_TH_CRM_PaymentRequestLineItem__c item : OTPList) {
                    if (item.ASI_CRM_CN_Cost_Type__c != 'Fixed') {
                        payFee += (item.ASI_TH_CRM_Amount__c != null ? item.ASI_TH_CRM_Amount__c : 0);
                    }
                }
                System.debug(LoggingLevel.INFO, '*** payFee: ' + payFee);
                if (freegoodsAmount > payFee) {
                    // String tempStr = Label.ASI_CRM_CN_Goods_Deduction_Validation ;
                    // Decimal payFee_amount= payFee.setScale(2, RoundingMode.HALF_UP);
                    // List<String> fillers = new String[] {payFee.format(),freegoodsAmount.setScale(2, RoundingMode.HALF_UP).format()};
                    // Msg = String.format(tempStr,fillers)) + '<br/>';
                    // Msg += Label.ASI_CRM_CN_Goods_Deduction_Validation + '<br/>';
                    apexpages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.ASI_CRM_CN_Goods_Deduction_Validation));
                    // UpsertPermission = false;
                    return null;
                }
            }
        }

        
        //Added by Michael Yip (Introv) 15Aug2014 for blocking save when BRSF date is invalid
        hasError = !checkBRSFDate();
        System.debug(LoggingLevel.INFO, '*** hasError: ' + hasError);
        
        if (PageId != null){
            if(PH.ASI_CRM_CN_Adjustment__c != null){
                // Edited by Michael Yip (Introv) 10Sep2014 for checking overpayment reason by total instead of by line item
                System.debug(PH.ASI_CRM_CN_Overpayment_Reason__c);
                if(PH.ASI_CRM_CN_Overpayment_Reason__c == null || PH.ASI_CRM_CN_Overpayment_Reason__c==''){
                    Decimal TotalSuggestedAmt = 0;
                    Decimal TotalPaymentAmt = 0;
                    for(ASI_TH_CRM_PaymentRequestLineItem__c pl : BRSFList){
                        //2015-10-19 fix bug on BRSF overpayment checking
                        if(pl.ASI_CRM_CN_Payable_Vol__c != null && pl.ASI_CRM_CN_Incentive_BT__c != null){
                           // pl.ASI_CRM_CN_Suggested_Amount__c = pl.ASI_CRM_Suggested_Volume__c * pl.ASI_CRM_CN_Incentive_BT__c;
                            pl.ASI_CRM_CN_Total_Payable__c = pl.ASI_CRM_CN_Payable_Vol__c * pl.ASI_CRM_CN_Incentive_BT__c;
                        }
                        if(pl.ASI_CRM_CN_Total_Payable__c != null && PH.ASI_CRM_CN_Adjustment__c != null)
                            TotalPaymentAmt += pl.ASI_CRM_CN_Total_Payable__c * PH.ASI_CRM_CN_Adjustment__c /100;
                           // TotalPaymentAmt += pl.ASI_CRM_CN_Incentive_BT__c * pl.ASI_CRM_CN_Payable_Vol__c * PH.ASI_CRM_CN_Adjustment__c /100;
                        if(pl.ASI_CRM_CN_Suggested_Amount__c != null)
                        {
                            if(pl.ASI_CRM_Suggested_Volume__c != null)
                                TotalSuggestedAmt = TotalSuggestedAmt + pl.ASI_CRM_Suggested_Volume__c*pl.ASI_CRM_CN_Incentive_BT__c;
                            else
                                TotalSuggestedAmt = TotalSuggestedAmt + pl.ASI_CRM_CN_Suggested_Amount__c;
                        }
                        //20151209 Ben @ Elufa System
                        if(pl.ASI_CRM_CN_Payable_Vol__c > pl.ASI_CRM_CN_Bottle_Collected__c || pl.ASI_CRM_CN_Payable_Vol__c > pl.ASI_CRM_CN_Actual_Vol__c)
                            require_overpayment_reason = true;
                        //End
                    }
                    //20151209 Ben @ Elufa System
                    //if(TotalSuggestedAmt < TotalPaymentAmt)
                        //require_overpayment_reason = true;
                    //End
                    
                }
                if(PH.ASI_CRM_CN_Adjustment__c > 100){
                    ApexPages.Message msg;
                    if(USerInfo.getLanguage()=='zh_CN')
                        msg = new ApexPages.Message(ApexPages.Severity.ERROR, '付款调节比例不能超过100%！');
                    else
                        msg = new ApexPages.Message(ApexPages.Severity.ERROR,'The adjustment could not exceed 100%.');
                    
                    apexpages.addmessage(msg);                    
                    hasError = true;
                }
            }
            if(PH.ASI_CRM_CN_Overpayment_Reason__c=='其他－需填写具体原因'){
                if(PH.ASI_CRM_CN_Other_Reason__c==null || PH.ASI_CRM_CN_Other_Reason__c==''){
                    require_other_reason=true;
                }
            }

            System.debug(LoggingLevel.INFO, '*** hasError: ' + hasError);
            System.debug(LoggingLevel.INFO, '*** require_overpayment_reason: ' + require_overpayment_reason);
            System.debug(LoggingLevel.INFO, '*** require_other_reason: ' + require_other_reason);

            if(require_overpayment_reason||require_other_reason){
                ApexPages.Message msg;
                if(require_overpayment_reason){
                    //ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, '需填写原因,Required Field is missing:Overpayment Reason');
                    if(USerInfo.getLanguage()=='zh_CN')
                        msg = new ApexPages.Message(ApexPages.Severity.ERROR, '需填写原因:超额付款理由。');
                    else
                        msg = new ApexPages.Message(ApexPages.Severity.ERROR,'Plesae input the reason for overpayment.');
                    
                    apexpages.addmessage(msg);                    
                }
                
                if(require_other_reason){
                    //ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, '需具体填写其他原因,Required Field is missing:Other Reasons');
                    if(USerInfo.getLanguage()=='zh_CN')
                        msg = new ApexPages.Message(ApexPages.Severity.ERROR, '需具体填写其他原因。');
                    else
                        msg = new ApexPages.Message(ApexPages.Severity.ERROR,'Please input other reason.');
                    apexpages.addmessage(msg);
                }
                
                redirect=false;
                hasError = true;
                //return null;
            }else{
                //update PH;
            }
            
            // edited by leo @20140716
            if(hasError)
            {
                return null;
            }
            else
            {
                try{
                    update PH;
                }
                catch(exception e){
                    apexpages.addmessages(e);
                    redirect = false;
                }
            }
        }
        
        if(BRSFList != null && BRSFList.size()>0){
            //20150915 Ben @ Elufa
            calcBRSF_Total();
            //Updated by William Yang(Introv) 20141205 for #185
            for(ASI_TH_CRM_PaymentRequestLineItem__c item : BRSFList){
                if(item.ASI_CRM_CN_Payable_Vol__c == null)
                    item.ASI_CRM_CN_Payable_Vol__c = 0;
                if(item.ASI_CRM_CN_Incentive_BT__c == null)
                    item.ASI_CRM_CN_Incentive_BT__c = 0;
            }
            update BRSFList;
        }
        if(OTPList != null && OTPList.size()>0){
            //lokman 26/5/2014
            for(ASI_TH_CRM_PaymentRequestLineItem__c  payment_request:OTPList){
                
                //20160613 Ben @ Elufa
                if(festivalMap.containsKey(payment_request.id) && festivalMap.get(payment_request.id) && PH.ASI_CRM_New_FY_Payment__c)
                    payment_request.ASI_CRM_Other_Est__c = ( payment_request.ASI_TH_CRM_Amount__c != NULL ? payment_request.ASI_TH_CRM_Amount__c : 0 )  - ( payment_request.ASI_CRM_MAF_Est__c != NULL ? payment_request.ASI_CRM_MAF_Est__c : 0 )  - ( payment_request.ASI_CRM_CNY_Est__c != NULL ? payment_request.ASI_CRM_CNY_Est__c : 0 );
                //20160613 End
                
                //20160726 Ben @ Elufa
                
                if( (payment_request.ASI_TH_CRM_Amount__c >= 0 || payment_request.ASI_TH_CRM_Amount__c == NULL) && payment_request.ASI_CRM_Other_Est__c < 0 && PH.ASI_CRM_New_FY_Payment__c){
                    
                    if(USerInfo.getLanguage()=='zh_CN')
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'其他(预估)不能小于0'));
                    else
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Others(Est.) cannot be negative'));
                    return null;
                }
                
                //20160726 End
                
                //20160826, added by Leo
                if( (payment_request.ASI_TH_CRM_Amount__c >= 0 || payment_request.ASI_TH_CRM_Amount__c == NULL)  && payment_request.ASI_CRM_CNY_Est__c !=null && payment_request.ASI_CRM_CNY_Est__c < 0 && PH.ASI_CRM_New_FY_Payment__c){
                    
                    if(USerInfo.getLanguage()=='zh_CN')
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'春节(预估)不能小于0'));
                    else
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'CNY(Est.) cannot be negative'));
                    return null;
                }
                
                if( (payment_request.ASI_TH_CRM_Amount__c >= 0 || payment_request.ASI_TH_CRM_Amount__c == NULL) && payment_request.ASI_CRM_MAF_Est__c !=null && payment_request.ASI_CRM_MAF_Est__c < 0 && PH.ASI_CRM_New_FY_Payment__c){
                    
                    if(USerInfo.getLanguage()=='zh_CN')
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'中秋(预估)不能小于0'));
                    else
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'MAF(Est.) cannot be negative'));
                    return null;
                }
                //20160826, added by Leo
                
                if(payment_request.ASI_TH_CRM_Amount__c!=null ){
                    totalpayment+=payment_request.ASI_TH_CRM_Amount__c;
                }
                if(payment_request.ASI_CRM_CN_Expense_Type__c=='PRC - Down Payment - On Premise'){
                    downpayment=payment_request;
                }
            }
            try{
                update OTPList;
            } catch (Exception e) {
                ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage());
                ApexPages.addMessage(msg);
                redirect = false;
            }
        }
        //=============================================================================
        if(updatePSF()){
            //ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR,'Payment Period must be within PO Start & End Dates.');
            //ApexPages.addMessage(msg);
            System.debug('PSF update fail');
            redirect=false;
        }  
        if(upsertFreeGoods()){
            //ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR,'Payment Period must be within PO Start & End Dates.');
            //ApexPages.addMessage(msg);
            // System.debug('PSF update fail');
            redirect=false;
        } 
        if(PH.ASI_CRM_CN_Payable_Amount__c!=null && totalpayment!=null){
            if(PH.ASI_CRM_CN_Adjustment__c!=null){
                totalpayment+=PH.ASI_CRM_CN_Payable_Amount__c*PH.ASI_CRM_CN_Adjustment__c/100;
            }
            else{
                totalpayment+=PH.ASI_CRM_CN_Payable_Amount__c;
            }
            // if(totalpayment>PH.ASI_TH_CRM_Contract__r.ASI_CRM_CN_Total_Contract_Amount__c){
            if ((PH.ASI_TH_CRM_Contract__r.ASI_CRM_CN_Total_Contract_Amount__c >=0 && totalpayment>PH.ASI_TH_CRM_Contract__r.ASI_CRM_CN_Total_Contract_Amount__c) || 
                (PH.ASI_TH_CRM_Contract__r.ASI_CRM_CN_Total_Contract_Amount__c <0 && Math.abs(totalpayment)> Math.abs(PH.ASI_TH_CRM_Contract__r.ASI_CRM_CN_Total_Contract_Amount__c))) {
                //ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Payment Amount > PO Amount. Payment Amount:'+totalpayment+'    PO Amount:'+PH.ASI_TH_CRM_Contract__r.ASI_CRM_CN_Total_Contract_Amount__c);
                if(USerInfo.getLanguage()=='zh_CN')
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'付款金额>PO金额！付款金额：'+totalpayment+'    PO金额：'+PH.ASI_TH_CRM_Contract__r.ASI_CRM_CN_Total_Contract_Amount__c));
                else
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Payment Amount>PO Amount, please modify and re-submit.'));
                //apexpages.addmessage(msg);
                redirect=false;
            }
        }
        system.debug('Go to Main Page');
        // upsertFreeGoods();
        PageReference redirect_page = new PageReference('/apex/ASI_CRM_CN_Payment_Header_Page'); 
        redirect_page.getParameters().put('id',PageId);
        if(redirect==false){
            redirect_page.setRedirect(redirect);
            return null;
        }
        redirect_page.setRedirect(redirect);
        return redirect_page;
    }

    public boolean upsertFreeGoods() {
        boolean hasError = false;
        try {
            Map<String, ASI_TH_CRM_PaymentRequestLineItem__c> exisFreegoodsMap = new Map<String,ASI_TH_CRM_PaymentRequestLineItem__c>([select Id ,ASI_CRM_Module__c from ASI_TH_CRM_PaymentRequestLineItem__c where ASI_TH_CRM_Payment_Request__c =: PH.Id
                    and recordType.DeveloperName =: 'ASI_CRM_CN_Payment_Request_Detail_Free_Goods']);
            if (freeGoodsInterimData.paymentRequestLines != null) {
                for(ASI_TH_CRM_PaymentRequestLineItem__c item : freeGoodsInterimData.paymentRequestLines) {
                    if (item.Id != null) {
                        exisFreegoodsMap.remove(item.Id);
                    }
                }
            }
            
            if (!exisFreegoodsMap.isEmpty()) {
                delete exisFreegoodsMap.values();
            }

            if (freeGoodsInterimData.module != null) {
                //Update end Date in freeGoods module
                freeGoodsInterimData.module.ASI_CRM_End_Date__c = ph.ASI_CRM_CN_PO_End_Date__c;
                upsert freeGoodsInterimData.module;
            }
            if (freeGoodsInterimData.paymentRequestLines != null) {
                upsert freeGoodsInterimData.paymentRequestLines;
            }
        }
        catch (Exception e) {
            ApexPages.addMessages(e);
                hasError = true;
                // System.debug(e);
        }
        return hasError;
        
    }
    
    public boolean updatePSF(){
        boolean hasError = false;
        //---- delete PSF Line Items - by leo (start) ----
        if(totalpayment==null){
            totalpayment=0;
        }
        if(Del_PSF_Item != null && Del_PSF_Item.size()>0)
        {
            List <ASI_TH_CRM_PaymentRequestLineItem__c> Del_PSF_Item_Temp = new List <ASI_TH_CRM_PaymentRequestLineItem__c>();
            for (ASI_TH_CRM_PaymentRequestLineItem__c b : Del_PSF_Item)
            {
                if(b.Id != null)
                    Del_PSF_Item_Temp.add(b);
            }
            
            if(Del_PSF_Item_Temp != null && Del_PSF_Item_Temp.size() > 0)
                delete Del_PSF_Item_Temp;
        }
        //---- delete PSF Line Items - by leo (end) ----
        
        //---- save PSF Line Items - by leo (start) ----
        Save_PSF_Item = new List<ASI_TH_CRM_PaymentRequestLineItem__c>();
        for (integer i : PSF_Item_Map.keySet())
        {
            ASI_TH_CRM_PaymentRequestLineItem__c psf = PSF_Item_Map.get(i);
            System.debug(psf.ASI_CRM_CN_Period_Start__c);
            System.debug(ph.ASI_CRM_CN_PO_Start_Date__c );
            
            if(psf.ASI_TH_CRM_Payment_Request__c == null)
                psf.ASI_TH_CRM_Payment_Request__c = PH.Id;
            
            if(psf.RecordTypeId == null)
                psf.RecordTypeId = rtPSF.Id;
            
            //20160728 Ben @ Elufa
            /*if(PH.ASI_CRM_New_FY_Payment__c && isFestivalPSF){
                
                psf.ASI_CRM_Other_Est__c = ( psf.ASI_TH_CRM_Amount__c != NULL ? psf.ASI_TH_CRM_Amount__c : 0 )  - ( psf.ASI_CRM_MAF_Est__c != NULL ? psf.ASI_CRM_MAF_Est__c : 0 )  - ( psf.ASI_CRM_CNY_Est__c != NULL ? psf.ASI_CRM_CNY_Est__c : 0 );

                if(psf.ASI_TH_CRM_Amount__c != NULL && psf.ASI_TH_CRM_Amount__c >= 0 && psf.ASI_CRM_Other_Est__c < 0){
                    
                    if(USerInfo.getLanguage()=='zh_CN')
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'其他(预估)不能小于0'));
                    else
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Others(Est.) cannot be negative'));
                    
                    hasError = TRUE;
                }
            }*/
            //20160728 End
            
            Save_PSF_Item.add(psf);
            if(psf.ASI_TH_CRM_Amount__c!=null){
                totalpayment+=psf.ASI_TH_CRM_Amount__c;
            }
        }
        
        if(!hasError && Save_PSF_Item != null && Save_PSF_Item.size() > 0)
            try{
                upsert Save_PSF_Item;
            } catch (Exception e) {
                //ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage());//Same old drama 
                ApexPages.addMessages(e);
                hasError = true;
                System.debug(e);
            }
        //---- save PSF Line Items - by leo (end) ----
        return hasError;
        
        //============================================================================
    }
    public PageReference PSFReport(){
        
        if(updatePSF()){
            //ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR,'Payment Period must be within PO Start & End Dates.');
            if(USerInfo.getLanguage()=='zh_CN')
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'付款月份需在PO期间内选择。'));
            else
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Please select the BRSF Period within PO Period.'));
        }
        
        return null;
    }
    public PageReference BRSFReport(){
        try{
            update PH;
        }catch(exception e){
            //ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR,'Unable to save. Please try again.');
            if(USerInfo.getLanguage()=='zh_CN')
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'无法保存，请重试。'));
            else
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Failed to save, please try again.'));
        }
        return null;
    }
    //***** added by leo @2014-07-01 (start) *****
    public PageReference doCancel(){
        String retURL = '';
        retURL = ApexPages.currentPage().getParameters().get('retURL'); 
        
        String contractid = '';
        contractid = ApexPages.currentPage().getParameters().get('contractid');
        
        String pid = '';
        pid = ApexPages.currentPage().getParameters().get('id');   
        
        PageReference redirect;
        
        if(retURL != null && retURL != '')
        {
            redirect = new PageReference(retURL); 
        }        
        else
        {
            if(contractid != null && contractid != '')
            {
                // from contract "make payment"
                redirect = new PageReference('/apex/ASI_CRM_CN_MainContractPage?id=' + contractid); 
            }
            else
            {    
                if(pid != null && pid != '')
                {
                    // from edit existing payment
                    redirect = new PageReference('/apex/ASI_CRM_CN_Payment_Header_Page?id=' + pid); 
                }
                else
                {    
                    redirect = new PageReference('/apex/ASI_CRM_CN_Payment_Header_Page');
                }                
            }
        }
        
        redirect.setRedirect(true); 
        return redirect;
    }
    //***** added by leo @2014-07-01 (end) *****
    
    public PageReference GoURL(){
        //PageReference redirect = ApexPages.StandardController.cancel();  
        
        PageReference redirect = new PageReference('/apex/ASI_CRM_RedirectPRViewPage');  // change by laputa 20170826 from ASI_CRM_CN_Payment_Header_Page to ASI_CRM_RedirectPRViewPage 
        redirect.getParameters().put('id',PageId); 
        redirect.setRedirect(true); 
        return redirect;
    }
    public PageReference GoEditHeader(){
        PageReference redirect = new PageReference('/apex/ASI_CRM_CN_EditPayment_Header_Page'); 
        redirect.getParameters().put('id',PageId); 
        redirect.setRedirect(true); 
        return redirect;
    }
    public PageReference GoEditDetail(){
        calcBRSF_Total();
        PageReference redirect = new PageReference('/apex/ASI_CRM_CN_EditPaymentDetailsPage'); 
        redirect.getParameters().put('id',PageId); 
        redirect.setRedirect(true); 
        return redirect;
    }
    public PageReference GoEditPayee(){
        PageReference redirect = new PageReference('/apex/ASI_CRM_CN_EditPaymentPayeePage'); 
        redirect.getParameters().put('id',PageId); 
        redirect.setRedirect(true); 
        return redirect;
    }
    
    
    
    /*public void showcalcbtn(){
showcalc = true;
}*/
    
    public void AddNew_CASH(){
        ASI_CRM_CN_PH_Payee_Line_Item__c p = new  ASI_CRM_CN_PH_Payee_Line_Item__c(ASI_CRM_CN_Type__c = 'Cash');
        System.debug('@@@@value of p' + p);
        System.debug('@@@@value of indexCASH' + indexCASH);
        if(indexCASH ==null)
            indexCASH = 0;
        Payee_Item_Map_CASH.put(indexCASH++, p);
        getRows();

    }
    public void Clone_CASH(){
        ASI_CRM_CN_PH_Payee_Line_Item__c psf = Payee_Item_Map_CASH.get(rowidCASH);
        ASI_CRM_CN_PH_Payee_Line_Item__c psf_Clone = psf.clone(false, true);//new ASI_CRM_CN_PH_Payee_Line_Item__c();
        
        Payee_Item_Map_CASH.put(indexCASH++, psf_Clone);
        getRows();        
    }
    public void RemoveRow_CASH(){   
        Del_Payee_Item_CASH.add(Payee_Item_Map_CASH.get(rowidCASH));
        Payee_Item_Map_CASH.remove(rowidCASH);        

    }
    public void changeT1Method() {
        String index = Apexpages.currentPage().getParameters().get('index');
        Integer indexInt = Integer.valueOf(index);
        ASI_CRM_CN_PH_Payee_Line_Item__c item = Payee_Item_Map_DISCOUNT.get(indexInt);
        if (String.isNotBlank(item.ASI_CRM_CN_Payee_T2__c)) {
            List<ASI_CRM_AccountsAdditionalField__c> accList = [SELECT ASI_CRM_T1_WS_Account__c FROM ASI_CRM_AccountsAdditionalField__c WHERE ASI_CRM_Account__c =: item.ASI_CRM_CN_Payee_T2__c];
            if (accList != null && accList.size() > 0) {
                ASI_CRM_AccountsAdditionalField__c supplier = accList.get(0);
                for (SelectOption option : discountT1WSPicklist) {
                    if (supplier.ASI_CRM_T1_WS_Account__c == option.getValue()) {
                        item.ASI_CRM_CN_Payee_T1__c = option.getValue();
                    }
                }
            }
        }
        Payee_Item_Map_DISCOUNT.put(indexInt, item);

    }

    public void changeT2Method() {
        String index = Apexpages.currentPage().getParameters().get('index');
        // System.debug(LoggingLevel.INFO, '*** index: ' + index);
        Integer indexInt = Integer.valueOf(index);
        ASI_CRM_CN_PH_Payee_Line_Item__c item = Payee_Item_Map_CD.get(indexInt);
        System.debug(LoggingLevel.INFO, '*** item.ASI_CRM_CN_Payee_T2__c: ' + item.ASI_CRM_CN_Payee_T2__c);
        if (String.isNotBlank(item.ASI_CRM_CN_Payee_T2__c)) {
            List<ASI_CRM_AccountsAdditionalField__c> accList = [SELECT ASI_CRM_T1_WS_Account__c,ASI_CRM_Account__r.Name FROM ASI_CRM_AccountsAdditionalField__c WHERE ASI_CRM_Account__c =: item.ASI_CRM_CN_Payee_T2__c];
            if (accList != null && accList.size() > 0) {
                ASI_CRM_AccountsAdditionalField__c supplier = accList.get(0);
                item.ASI_CRM_CN_Payee_T2__r = supplier.ASI_CRM_Account__r;
                for (SelectOption option : othersT1WSPicklist) {
                    if (supplier.ASI_CRM_T1_WS_Account__c == option.getValue()) {
                        item.ASI_CRM_CN_Payee_T1__c = option.getValue();
                    }
                }
            }
        }
        Payee_Item_Map_CD.put(indexInt, item);

    }

    public void AddNew_Discount(){
        ASI_CRM_CN_PH_Payee_Line_Item__c p = new  ASI_CRM_CN_PH_Payee_Line_Item__c(ASI_CRM_CN_Type__c = 'Discount');
        if (discountT2WSPicklist != null && discountT2WSPicklist.size() > 0 && PH.ASI_CRM_CN_Promotion_Type__c  == 'Heavy Contract On') {
            p.ASI_CRM_CN_Payee_T2__c = discountT2WSPicklist.get(0).getValue();
            List<ASI_CRM_AccountsAdditionalField__c> accList = [SELECT ASI_CRM_T1_WS_Account__c FROM ASI_CRM_AccountsAdditionalField__c WHERE ASI_CRM_Account__c =: p.ASI_CRM_CN_Payee_T2__c];
            if (accList != null && accList.size() > 0) {
                ASI_CRM_AccountsAdditionalField__c supplier = accList.get(0);
                for (SelectOption option : discountT1WSPicklist) {
                    if (supplier.ASI_CRM_T1_WS_Account__c == option.getValue()) {
                        p.ASI_CRM_CN_Payee_T1__c = option.getValue();
                    }
                }
            }
        }
        Payee_Item_Map_Discount.put(indexDiscount++, p);
        getRows();
    }
    public void Clone_Discount(){
        ASI_CRM_CN_PH_Payee_Line_Item__c psf = Payee_Item_Map_Discount.get(rowidDiscount);
        ASI_CRM_CN_PH_Payee_Line_Item__c psf_Clone = psf.clone(false, true);//new ASI_CRM_CN_PH_Payee_Line_Item__c();
        
        Payee_Item_Map_Discount.put(indexDiscount++, psf_Clone);
        getRows();
    }
    public void RemoveRow_Discount(){
        Del_Payee_Item_Discount.add(Payee_Item_Map_Discount.get(rowidDiscount));
        Payee_Item_Map_Discount.remove(rowidDiscount);
        //system.assertEquals(Payee_Item_Map_Discount, Null);//getRows();
    }
    public void AddNew_CD(){
        ASI_CRM_CN_PH_Payee_Line_Item__c p = new  ASI_CRM_CN_PH_Payee_Line_Item__c(ASI_CRM_CN_Type__c = 'Others');
        Payee_Item_Map_CD.put(indexCD++, p);
        getRows();
    }
    public void Clone_CD(){
        ASI_CRM_CN_PH_Payee_Line_Item__c psf = Payee_Item_Map_CD.get(rowidCD);
        ASI_CRM_CN_PH_Payee_Line_Item__c psf_Clone = psf.clone(false, true);//new ASI_CRM_CN_PH_Payee_Line_Item__c();
        
        Payee_Item_Map_CD.put(indexCD++, psf_Clone);
        getRows();
    }
    public void RemoveRow_CD(){   
        Del_Payee_Item_CD.add(Payee_Item_Map_CD.get(rowidCD));
        Payee_Item_Map_CD.remove(rowidCD);        
    }
    
    //****** PSF Line Item - functions - (start) ******
    
    public void AddNew_PSF(){
        
        ASI_TH_CRM_PaymentRequestLineItem__c psf = new ASI_TH_CRM_PaymentRequestLineItem__c();
        // Added by Michael Yip (Introv) 04Aug2014
        if(LPSF != null && LPSF.size()==1){
            psf.ASI_CRM_CN_AC_Code__c = LPSF[0].ASI_CRM_CN_Activity_Code__c;
            psf.ASI_CRM_CN_Cost_Type__c = LPSF[0].ASI_CRM_CN_Cost_Type__c;
            psf.ASI_CRM_CN_Expense_Type__c = LPSF[0].ASI_CRM_CN_Chinese_Description__c;
        }
        PSF_Item_Map.put(indexPSF++, psf);
    }
    
    public void Clone_PSF(){
        
        ASI_TH_CRM_PaymentRequestLineItem__c psf = PSF_Item_Map.get(rowidPSF);
        ASI_TH_CRM_PaymentRequestLineItem__c psf_Clone = new ASI_TH_CRM_PaymentRequestLineItem__c();
        
        psf_Clone.ASI_CRM_CN_Payment_Description__c = psf.ASI_CRM_CN_Payment_Description__c;
        psf_Clone.ASI_CRM_CN_Period_Start__c = psf.ASI_CRM_CN_Period_Start__c;
        psf_Clone.ASI_CRM_CN_Period_End__c = psf.ASI_CRM_CN_Period_End__c;
        psf_Clone.ASI_CRM_CN_Supporting_Document__c = psf.ASI_CRM_CN_Supporting_Document__c;
        psf_Clone.ASI_TH_CRM_Amount__c = psf.ASI_TH_CRM_Amount__c;
        psf_Clone.ASI_TH_CRM_Payment_Request__c = PH.Id;
        psf_Clone.ASI_CRM_CN_AC_Code__c = psf.ASI_CRM_CN_AC_Code__c;
        psf_Clone.ASI_CRM_CN_Cost_Type__c = psf.ASI_CRM_CN_Cost_Type__c ;
        psf_Clone.ASI_CRM_CN_Expense_Type__c = psf.ASI_CRM_CN_Expense_Type__c ;
        //20160728 Ben @ Elufa
        psf_Clone.ASI_CRM_CNY_Est__c = psf.ASI_CRM_CNY_Est__c ;
        psf_Clone.ASI_CRM_MAF_Est__c = psf.ASI_CRM_MAF_Est__c ;
        //20160728 End
        psf_Clone.RecordTypeId = rtPSF.Id;
        
        PSF_Item_Map.put(indexPSF++, psf_Clone);
        
    }
    
    public void RemoveRow_PSF(){   
        Del_PSF_Item.add(PSF_Item_Map.get(rowidPSF));
        PSF_Item_Map.remove(rowidPSF);       
    }
    
    public void retrievePicklist(){
        payeeNamePicklist = new List<String>();
        discountT2WSPicklist = new List<SelectOption>();
        othersT2WSPicklist = new List<SelectOption>();
        discountT1WSPicklist = new List<SelectOption>();
        othersT1WSPicklist = new List<SelectOption>();
        List<Account> payees = new list<Account>();
        if (PH.ASI_TH_CRM_Contract__c != null){
            System.debug(PH.ASI_CRM_CN_OutletWS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__r.ASI_CRM_Region_Code__c);
            payees = [SELECT Id, Name FROM Account WHERE ASI_KOR_Addr_Region__c = :PH.ASI_CRM_CN_OutletWS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__r.ASI_CRM_Region_Code__c and ASI_KOR_Addr_Region__c != null and ASI_KOR_Addr_Region__c != '' AND RecordType.DeveloperName = 'ASI_CRM_CN_Supplier' order by Name ASC];
            
            
        }
        for(Account payee : payees){
            payeeNamePicklist.add(payee.Name);
        }
        Map<String, ID> cs = new Map<String, ID>();
        Set<id> i = new set<id>();
   //     ASI_TH_CRM_PaymentRequest__c PH = [SELECT id, name, ASI_TH_CRM_Contract__r.ASI_CRM_CN_Outlet_WS__c, ASI_CRM_CN_OutletWS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__r.ASI_CRM_Region_Code__c, ASI_TH_CRM_Contract__c, ASI_TH_CRM_Contract__r.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Region__c
    //                    FROM ASI_TH_CRM_PaymentRequest__c
     //                   WHERE id =: Pageid LIMIT 1];
      //  if(PH != null){
        if(!cs.containsKey(PH.ASI_TH_CRM_Contract__r.ASI_CRM_CN_Outlet_WS__c)){
            cs.put(PH.ASI_TH_CRM_Contract__r.ASI_CRM_CN_Outlet_WS__c, PH.ASI_TH_CRM_Contract__r.ASI_CRM_CN_Outlet_WS__c);
            i.add(PH.ASI_TH_CRM_Contract__r.ASI_CRM_CN_Outlet_WS__c);
        }
        for(ASI_CRM_CN_Covered_Outlet__c c : [SELECT ASI_CRM_CN_Outlet__c FROM ASI_CRM_CN_Covered_Outlet__c 
                                 WHERE ASI_CRM_CN_Contract__c = :PH.ASI_TH_CRM_Contract__c])
        {
            if(!cs.containsKey(c.ASI_CRM_CN_Outlet__c)){
                cs.put(c.ASI_CRM_CN_Outlet__c, c.ASI_CRM_CN_Outlet__c);
                i.add(c.ASI_CRM_CN_Outlet__c);
            }
        }    
        Map<String, ID> es = new Map<String, ID>();
        List<ASI_CRM_Effective_supplier__c> suppliers = [SELECT ASI_CRM_Supplier__c,ASI_CRM_Supplier__r.Id, ASI_CRM_Supplier__r.Name, ASI_CRM_Supplier__r.ASI_CRM_Account__r.id, ASI_CRM_Supplier__r.ASI_CRM_Account__r.Name FROM ASI_CRM_Effective_supplier__c WHERE ASI_CRM_Account__c in :i /*AND ASI_CRM_Supplier__r.ASI_CRM_CN_WS_Tier__c = 'T2'*/ AND ASI_CRM_Last_tran_date__c > :system.today().addYears(-1) order by ASI_CRM_Last_tran_date__c desc];
        system.debug('** suppliers**'+ i );
        system.debug(suppliers);
        for(ASI_CRM_Effective_supplier__c supplier : suppliers){
            if(supplier.ASI_CRM_Supplier__c != null && supplier.ASI_CRM_Supplier__r.Id != null && supplier.ASI_CRM_Supplier__r.Name != null && supplier.ASI_CRM_Supplier__r.ASI_CRM_Account__c != null)
            {   
                if(!es.containsKey(supplier.ASI_CRM_Supplier__r.ASI_CRM_Account__r.Name)) {
                    discountT2WSPicklist.add(new SelectOption(supplier.ASI_CRM_Supplier__r.ASI_CRM_Account__r.Id, supplier.ASI_CRM_Supplier__r.ASI_CRM_Account__r.Name));
                    es.put(supplier.ASI_CRM_Supplier__r.ASI_CRM_Account__r.Name,supplier.ASI_CRM_Supplier__r.ASI_CRM_Account__r.Id);
                }
            }
        }
        
        List<ASI_CRM_AccountsAdditionalField__c> outlets = [SELECT Id,Name, ASI_CRM_Account__r.Name, ASI_CRM_Account__r.id FROM ASI_CRM_AccountsAdditionalField__c WHERE ASI_CRM_CN_Region__c = :PH.ASI_TH_CRM_Contract__r.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Region__c AND RecordType.DeveloperName = 'ASI_CRM_CN_WS'];
        
        for(ASI_CRM_AccountsAdditionalField__c outlet : outlets){
            if(outlet.ASI_CRM_Account__c != null)
            othersT2WSPicklist.add(new SelectOption(outlet.ASI_CRM_Account__r.id, outlet.ASI_CRM_Account__r.Name));
        }        
        List<ASI_CRM_AccountsAdditionalField__c> t1Outlets;
        if(PH.ASI_CRM_CN_OutletWS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__r.ASI_CRM_Region_Code__c == 'HQ'){
            t1Outlets = [SELECT Id,Name, ASI_CRM_Account__r.Name, ASI_CRM_Account__r.id FROM ASI_CRM_AccountsAdditionalField__c WHERE (ASI_CRM_CN_WS_Tier__c = 'T1' OR ASI_CRM_CN_Status_T1__c = 'Final') AND RecordType.DeveloperName = 'ASI_CRM_CN_WS'];
        }
        else {
            t1Outlets = [SELECT Id,Name, ASI_CRM_Account__r.Name, ASI_CRM_Account__r.id FROM ASI_CRM_AccountsAdditionalField__c WHERE ASI_CRM_CN_Greater_Region_Code__c = : PH.ASI_CRM_CN_OutletWS__r.ASI_CRM_CN_Greater_Region_Code__c/*ASI_CRM_CN_Region__c = :PH.ASI_TH_CRM_Contract__r.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Region__c*/ AND (ASI_CRM_CN_WS_Tier__c = 'T1' OR ASI_CRM_CN_Status_T1__c = 'Final') AND RecordType.DeveloperName = 'ASI_CRM_CN_WS'];
        }
        for(ASI_CRM_AccountsAdditionalField__c t1Outlet : t1Outlets ){
            if(t1Outlet.ASI_CRM_Account__c != null)
            discountT1WSPicklist.add(new SelectOption(t1Outlet.ASI_CRM_Account__r.id, t1Outlet.ASI_CRM_Account__r.Name));
        }
        
        othersT1WSPicklist = discountT1WSPicklist;  
        System.debug(LoggingLevel.INFO, '*** discountT2WSPicklist: ' + discountT2WSPicklist);
        
    }
    
    //Added by Twinkle 7Oct2014 for autocomplete function
    public void getRows(){
        if(Payee_Item_Map_CASH !=null) 
            cashRows = Payee_Item_Map_CASH.size()-1;           
        else
            cashRows = 0;
            
        if(Payee_Item_Map_DISCOUNT !=null)
            discountRows = Payee_Item_Map_DISCOUNT.size()-1;           
        else
            discountRows = 0;
            
        if(Payee_Item_Map_CD !=null)
            otherRows = Payee_Item_Map_CD.size()-1;           
        else
            otherRows = 0;
    }
    
    @RemoteAction
    public static String[] findCashPayeeSObjects(string obj, string qry, string Pageid) {
        Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
        Schema.SObjectType sot = gd.get(obj);
        system.debug(sot);
        if (sot == null) {
            // Object name not valid
            return null;
        }

        ASI_TH_CRM_PaymentRequest__c PH = [SELECT id, name, ASI_TH_CRM_Contract__c, ASI_CRM_CN_OutletWS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__r.ASI_CRM_Region_Code__c,
                                            ASI_CRM_CN_OutletWS__r.ASI_CRM_CN_Is_IHBR_Outlet__c
                                            FROM ASI_TH_CRM_PaymentRequest__c
                                            WHERE id =: Pageid LIMIT 1];
        system.debug(PH);
        
        List<String> results = new List<String>();
        String key='%'+String.escapeSingleQuotes(qry)+'%';

        List <Account> LPayees = new List<Account>();
        
        if (PH != null && PH.ASI_TH_CRM_Contract__c != null){
            try {
                /*LPayees = [SELECT id, Name FROM Account
                WHERE ASI_KOR_Addr_Region__c = :PH.ASI_CRM_CN_OutletWS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__r.ASI_CRM_Region_Code__c
                AND ASI_KOR_Addr_Region__c != null 
                AND ASI_KOR_Addr_Region__c != '' 
                AND RecordType.DeveloperName = 'ASI_CRM_CN_Supplier' 
                AND Name like :key 
                ORDER BY NAME ASC];*/
                if(!PH.ASI_CRM_CN_OutletWS__r.ASI_CRM_CN_Is_IHBR_Outlet__c && PH.ASI_CRM_CN_OutletWS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__r.ASI_CRM_Region_Code__c != 'HQ'){
                    if(PH.ASI_CRM_CN_OutletWS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__r.ASI_CRM_Region_Code__c == 'C'){
                        LPayees = [SELECT id, Name FROM Account
                        WHERE (ASI_KOR_Addr_Region__c = 'C' OR ASI_KOR_Addr_Region__c = 'ALL')
                        AND RecordType.DeveloperName = 'ASI_CRM_CN_Supplier' 
                        AND Name like :key 
                        ORDER BY NAME ASC];
                    }
                    else if(PH.ASI_CRM_CN_OutletWS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__r.ASI_CRM_Region_Code__c == 'E'){
                        LPayees = [SELECT id, Name FROM Account
                        WHERE (ASI_KOR_Addr_Region__c = 'E' OR ASI_KOR_Addr_Region__c = 'ALL')
                        AND RecordType.DeveloperName = 'ASI_CRM_CN_Supplier' 
                        AND Name like :key 
                        ORDER BY NAME ASC];
                    }
                    else if(PH.ASI_CRM_CN_OutletWS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__r.ASI_CRM_Region_Code__c == 'N' ){
                        LPayees = [SELECT id, Name FROM Account
                        WHERE (ASI_KOR_Addr_Region__c = 'N' OR ASI_KOR_Addr_Region__c = 'ALL')
                        AND RecordType.DeveloperName = 'ASI_CRM_CN_Supplier' 
                        AND Name like :key 
                        ORDER BY NAME ASC];
                    }
                    else if( PH.ASI_CRM_CN_OutletWS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__r.ASI_CRM_Region_Code__c == 'NW'){
                        LPayees = [SELECT id, Name FROM Account
                        WHERE (ASI_KOR_Addr_Region__c = 'NW'  OR ASI_KOR_Addr_Region__c = 'ALL')
                        AND RecordType.DeveloperName = 'ASI_CRM_CN_Supplier' 
                        AND Name like :key 
                        ORDER BY NAME ASC]; //add 'NW' by laputa 
                    }
                    else if(PH.ASI_CRM_CN_OutletWS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__r.ASI_CRM_Region_Code__c == 'S' ||
                            PH.ASI_CRM_CN_OutletWS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__r.ASI_CRM_Region_Code__c == 'SW'){
                        LPayees = [SELECT id, Name FROM Account
                        WHERE (ASI_KOR_Addr_Region__c = 'SW' OR ASI_KOR_Addr_Region__c = 'S' OR ASI_KOR_Addr_Region__c = 'ALL')
                        AND RecordType.DeveloperName = 'ASI_CRM_CN_Supplier' 
                        AND Name like :key 
                        ORDER BY NAME ASC];
                    }
                }
                else{
                    LPayees = [SELECT id, Name FROM Account
                    WHERE (ASI_KOR_Addr_Region__c = 'HQ' OR ASI_KOR_Addr_Region__c = 'ALL')
                    AND RecordType.DeveloperName = 'ASI_CRM_CN_Supplier' 
                    AND Name like :key 
                    ORDER BY NAME ASC];
                }
                system.debug(LPayees);
        
                for(Account payee:LPayees ){
                   results.add(payee.Name + '$$$' + payee.id);//20151207 Ben @ Elufa System  (+ '$$$' + payee.id)
                }
            }
            catch (QueryException e) {
                return null;
            }   
         }
         return results;
    }    
    
    @RemoteAction
    public static String[] findDiscountWholesalerSObjects(string obj, string qry, string Pageid) {
        Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
        Schema.SObjectType sot = gd.get(obj);
        Map<String, ID> cs = new Map<String, ID>();
        Set<id> i = new set<id>();

        if (sot == null) {
            // Object name not valid
            return null;
        }
        ASI_TH_CRM_PaymentRequest__c PH = [SELECT id, name, ASI_TH_CRM_Contract__r.ASI_CRM_CN_Outlet_WS__c, ASI_TH_CRM_Contract__c
                        FROM ASI_TH_CRM_PaymentRequest__c
                        WHERE id =: Pageid LIMIT 1];
        if(!cs.containsKey(PH.ASI_TH_CRM_Contract__r.ASI_CRM_CN_Outlet_WS__c)){
            cs.put(PH.ASI_TH_CRM_Contract__r.ASI_CRM_CN_Outlet_WS__c, PH.ASI_TH_CRM_Contract__r.ASI_CRM_CN_Outlet_WS__c);
        }
        for(ASI_CRM_CN_Covered_Outlet__c c : [SELECT ASI_CRM_CN_Outlet__c FROM ASI_CRM_CN_Covered_Outlet__c 
                                 WHERE ASI_CRM_CN_Contract__c = :PH.ASI_TH_CRM_Contract__c])
        {
            if(!cs.containsKey(c.ASI_CRM_CN_Outlet__c)){
                cs.put(c.ASI_CRM_CN_Outlet__c, c.ASI_CRM_CN_Outlet__c);
                i.add(c.ASI_CRM_CN_Outlet__c);
            }
        }
                        
        List<String> results = new List<String>();
        String key='%'+String.escapeSingleQuotes(qry)+'%';

        List <ASI_CRM_Effective_supplier__c> LSuppliers = new List<ASI_CRM_Effective_supplier__c>();
        
        if (PH != null){
            try {
                LSuppliers = [SELECT ASI_CRM_Supplier__c, ASI_CRM_Supplier__r.Id, ASI_CRM_Supplier__r.Name, ASI_CRM_Supplier__r.ASI_CRM_Account__r.Name FROM ASI_CRM_Effective_supplier__c
                WHERE ASI_CRM_Account__c in :i 
                AND ASI_CRM_Last_tran_date__c > :system.today().addYears(-1) 
                AND ASI_CRM_Supplier__r.Name like :key 
                ORDER BY ASI_CRM_Supplier__r.Name ASC];
                
                system.debug(LSuppliers);
        
                    for(ASI_CRM_Effective_supplier__c supplier:LSuppliers ){
                        if(supplier.ASI_CRM_Supplier__c != null && supplier.ASI_CRM_Supplier__r.Id != null && supplier.ASI_CRM_Supplier__r.Name != null){
                            results.add(supplier.ASI_CRM_Supplier__r.ASI_CRM_Account__r.Name);  
                        }
                    }
            }
            catch (QueryException e) {
                    return null;
            }
         }                
         return results;
    } 
    

  @RemoteAction
    public static String[] findDiscountPayeeSObjects(string obj, string qry, string Pageid) {
        Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
        Schema.SObjectType sot = gd.get(obj);
        system.debug(sot);
        if (sot == null) {
            // Object name not valid
            return null;
        }
        ASI_TH_CRM_PaymentRequest__c PH = [SELECT id, name, ASI_TH_CRM_Contract__r.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Region__c
                        FROM ASI_TH_CRM_PaymentRequest__c
                        WHERE id =: Pageid LIMIT 1];
                        
        List<String> results = new List<String>();
        String key='%'+String.escapeSingleQuotes(qry)+'%';

        List <ASI_CRM_AccountsAdditionalField__c> t1Outlets = new List<ASI_CRM_AccountsAdditionalField__c>();
        
        if (PH != null){
            try {
                t1Outlets = [SELECT Id, Name
                FROM ASI_CRM_AccountsAdditionalField__c 
                WHERE ASI_CRM_CN_Region__c = :PH.ASI_TH_CRM_Contract__r.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Region__c
                AND (ASI_CRM_CN_WS_Tier__c = 'T1' OR ASI_CRM_CN_Status_T1__c = 'Final')
                AND RecordType.DeveloperName = 'ASI_CRM_CN_WS'
                AND Name like :key 
                ORDER BY Name ASC];
                
                system.debug(t1Outlets);
        
                    for(ASI_CRM_AccountsAdditionalField__c t:t1Outlets ){
                        results.add(t.Name);  
                    }
            }
            catch (QueryException e) {
                    return null;
            }
         }                
         return results;
    } 
    
    @RemoteAction
    public static String[] findOtherWholesalerSObjects(string obj, string qry, string Pageid) {
        Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
        Schema.SObjectType sot = gd.get(obj);
        system.debug(sot);
        if (sot == null) {
            // Object name not valid
            return null;
        }
        ASI_TH_CRM_PaymentRequest__c PH = [SELECT id, name, 
        ASI_TH_CRM_Contract__r.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Region__c, 
        ASI_CRM_CN_OutletWS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__r.ASI_CRM_Region_Code__c,
        ASI_CRM_CN_OutletWS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__r.ASI_CRM_Greater_Region__c
                        FROM ASI_TH_CRM_PaymentRequest__c
                        WHERE id =: Pageid LIMIT 1];
                        
        List<String> results = new List<String>();
        String key='%'+String.escapeSingleQuotes(qry)+'%';

        List <ASI_CRM_AccountsAdditionalField__c> outlets = new List<ASI_CRM_AccountsAdditionalField__c>();
        
        if (PH != null){
            try {
                if(PH.ASI_CRM_CN_OutletWS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__r.ASI_CRM_Region_Code__c != null && PH.ASI_CRM_CN_OutletWS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__r.ASI_CRM_Region_Code__c == 'HQ'){
                    outlets = [SELECT Id, Name, ASI_CRM_Account__c, ASI_CRM_Account__r.id
                    FROM ASI_CRM_AccountsAdditionalField__c 
                    WHERE RecordType.DeveloperName = 'ASI_CRM_CN_WS'
                    AND Name like :key 
                    ORDER BY Name ASC];
                } 
                else {
                    /*outlets = [SELECT Id, Name, ASI_CRM_Account__r.Name, ASI_CRM_Account__c, ASI_CRM_Account__r.id
                        FROM ASI_CRM_AccountsAdditionalField__c 
                        WHERE ASI_CRM_CN_Region__c = :PH.ASI_TH_CRM_Contract__r.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Region__c
                        //AND (ASI_CRM_CN_WS_Tier__c = 'T2' OR ASI_CRM_CN_WS_Tier__c = 'T1' OR ASI_CRM_CN_Status_T1__c = 'Final')
                        AND RecordType.DeveloperName = 'ASI_CRM_CN_WS'
                        AND Name like :key 
                    ORDER BY Name ASC];*/
                    //2020-12-15 match greater region
                    outlets = [SELECT Id, Name, ASI_CRM_Account__r.Name, ASI_CRM_Account__c, ASI_CRM_Account__r.id,ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__r.ASI_CRM_Greater_Region__c
                        FROM ASI_CRM_AccountsAdditionalField__c 
                        WHERE ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__r.ASI_CRM_Greater_Region__c = :PH.ASI_CRM_CN_OutletWS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__r.ASI_CRM_Greater_Region__c
                        //AND (ASI_CRM_CN_WS_Tier__c = 'T2' OR ASI_CRM_CN_WS_Tier__c = 'T1' OR ASI_CRM_CN_Status_T1__c = 'Final')
                        AND RecordType.DeveloperName = 'ASI_CRM_CN_WS'
                        AND Name like :key 
                    ORDER BY Name ASC];
                }
                system.debug(outlets);
        
                    for(ASI_CRM_AccountsAdditionalField__c o:outlets){
                        if(o.ASI_CRM_Account__c != null)
                            results.add(o.Name + '$$$' + o.ASI_CRM_Account__c);//20151207 Ben @ Elufa System  (+ '$$$' + o.ASI_CRM_Account__c));  
                    }
            }
            catch (QueryException e) {
                    return null;
            }
         }                
         return results;
    } 
    
    @RemoteAction
    public static String[] findOtherPayeeSObjects(string obj, string qry, string Pageid) {
        Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
        Schema.SObjectType sot = gd.get(obj);
        system.debug(sot);
        if (sot == null) {
            // Object name not valid
            return null;
        }
        ASI_TH_CRM_PaymentRequest__c PH = [SELECT id, name, ASI_TH_CRM_Contract__r.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Region__c
                        FROM ASI_TH_CRM_PaymentRequest__c
                        WHERE id =: Pageid LIMIT 1];
                        
        List<String> results = new List<String>();
        String key='%'+String.escapeSingleQuotes(qry)+'%';

        List <ASI_CRM_AccountsAdditionalField__c> t1Outlets = new List<ASI_CRM_AccountsAdditionalField__c>();
        
        if (PH != null){
            try {
                t1Outlets = [SELECT Id, Name
                FROM ASI_CRM_AccountsAdditionalField__c 
                WHERE ASI_CRM_CN_Region__c = :PH.ASI_TH_CRM_Contract__r.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Region__c
                AND (ASI_CRM_CN_WS_Tier__c = 'T1' OR ASI_CRM_CN_Status_T1__c = 'Final')
                AND RecordType.DeveloperName = 'ASI_CRM_CN_WS'
                AND Name like :key 
                ORDER BY Name ASC];
                
                system.debug(t1Outlets);
        
                for(ASI_CRM_AccountsAdditionalField__c t:t1Outlets ){
                    results.add(t.Name);  
                }
            }
            catch (QueryException e) {
                    return null;
            }
         }                
         return results;
    } 
    // End - Twinkle 7Oct2014
    // 
    public class interimData {
        ASI_TH_CRM_PaymentRequestLineItem__c paymentRequestLineOutletWS { set; get; }
        ASI_CRM_Module__c module { set; get; }
        //        List<ASI_CRM_Module__c> modules { set; get; }
        List<ASI_TH_CRM_PaymentRequestLineItem__c> paymentRequestLines { set; get; }
        List<interimData> moduleWrappers { set; get; }
        Decimal ASI_CRM_Application_Payment_Amount {get;set;}


        public interimData() {
            module = new ASI_CRM_Module__c();
            moduleWrappers = new List<interimData>();
            paymentRequestLines = new List<ASI_TH_CRM_PaymentRequestLineItem__c>();
        }
        public interimData(ASI_CRM_Module__c m) {
            module = m;
            moduleWrappers = new List<interimData>();
            paymentRequestLines = new List<ASI_TH_CRM_PaymentRequestLineItem__c>();
        }
    }
}