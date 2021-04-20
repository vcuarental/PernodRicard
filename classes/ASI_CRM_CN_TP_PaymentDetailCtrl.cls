/* Filename:    ASI_CRM_CN_TP_PaymentDetailCtrl.cls
* Author:      
* Purpose:     
*/
public without sharing class ASI_CRM_CN_TP_PaymentDetailCtrl {
    public ASI_TH_CRM_PaymentRequest__c PH {set;get;}
    public Boolean showEdit {set;get;}
    public string PageId {set;get;}
    public boolean cashtype {set;get;}
    public boolean discounttype{set;get;}
    // public boolean othertype {set;get;}
    public list <ASI_TH_CRM_PaymentRequest__c> HeaderList {set;get;}
    public list <ASI_TH_CRM_PaymentRequest__c> PaymentRequestList {set;get;}
    // public decimal Remaining_Amount{set;get;} 
    
    // public decimal completionRate {set;get;}
    // public decimal adjustment {set;get;}
    // public decimal actualPayment {set;get;}
    // public String division{set;get;} 
    // public boolean Allow_Submit_For_Approval{set;get;} 
    // private decimal totalpayment{set;get;}
    
    public decimal sum_of_payee_amount{set;get;}
    
    public list <ASI_CRM_CN_PH_Payee_Line_Item__c> PHPayee_CASH {set;get;}{PHPayee_CASH =new list <ASI_CRM_CN_PH_Payee_Line_Item__c>();}
    public map<integer, ASI_CRM_CN_PH_Payee_Line_Item__c> Payee_Item_Map_CASH {set;get;}
    // public list <ASI_CRM_CN_PH_Payee_Line_Item__c> Del_Payee_Item_CASH {set;get;}
    // public list<ASI_CRM_CN_PH_Payee_Line_Item__c> Save_Payee_Item_CASH {set;get;}
    public Integer indexCASH {set;get;}
    // public Integer rowidCASH {set;get;}
    
    
    public list <ASI_CRM_CN_PH_Payee_Line_Item__c> PHPayee_DISCOUNT {set;get;}{PHPayee_DISCOUNT =new list <ASI_CRM_CN_PH_Payee_Line_Item__c>();}
    public map<integer, ASI_CRM_CN_PH_Payee_Line_Item__c> Payee_Item_Map_DISCOUNT {set;get;}
    // public list <ASI_CRM_CN_PH_Payee_Line_Item__c> Del_Payee_Item_DISCOUNT {set;get;}
    // public list<ASI_CRM_CN_PH_Payee_Line_Item__c> Save_Payee_Item_DISCOUNT {set;get;}
    public Integer indexDISCOUNT {set;get;}
    // public Integer rowidDISCOUNT {set;get;}
    
    
    public list <ASI_CRM_CN_PH_Payee_Line_Item__c> PHPayee_CD {set;get;}{PHPayee_CD =new list <ASI_CRM_CN_PH_Payee_Line_Item__c>();}
    public map<integer, ASI_CRM_CN_PH_Payee_Line_Item__c> Payee_Item_Map_CD {set;get;}
    // public list <ASI_CRM_CN_PH_Payee_Line_Item__c> Del_Payee_Item_CD {set;get;}
    // public list<ASI_CRM_CN_PH_Payee_Line_Item__c> Save_Payee_Item_CD {set;get;}
    public Integer indexCD {set;get;}
    
    public list <ASI_TH_CRM_PaymentRequestLineItem__c> BRSFList {set;get;}
    
    
    // public RecordType rtPSF {set;get;}
    // public list <ASI_TH_CRM_PaymentRequestLineItem__c> PSFList {set;get;}
    // public map<integer, ASI_TH_CRM_PaymentRequestLineItem__c> PSF_Item_Map {set;get;}
    // public List <ASI_TH_CRM_PaymentRequestLineItem__c> Del_PSF_Item {set;get;}
    // public List <ASI_TH_CRM_PaymentRequestLineItem__c> Save_PSF_Item {set;get;}    
    // public Integer indexPSF {set;get;}
    
    
    public list <ASI_TH_CRM_PaymentRequestLineItem__c> OTPList {set;get;}
    // public ASI_TH_CRM_PaymentRequestLineItem__c downpayment{set;get;}
    
    public List<ASI_CRM_CN_PaymentRequestUtilCls.PaymentSummary> LPaymentSummary {set;get;}
    public decimal TotalPOEstAmt {set;get;}
    public decimal TotalPORemainAmt {set;get;}
    public decimal TotalRequestAmt {set;get;}
    
    // public decimal TotalEstAmtCNY {set;get;}
    // public decimal TotalEstAmtMAF {set;get;}
    // public decimal TotalEstAmtOthers {set;get;}
    
    // public decimal TotalRemainAmtCNY {set;get;}
    // public decimal TotalRemainAmtMAF {set;get;}
    // public decimal TotalRemainAmtOthers {set;get;}
    
    public decimal TotalRequestAmtCNY {set;get;}
    public decimal TotalRequestAmtMAF {set;get;}
    public decimal TotalRequestAmtOthers {set;get;}
    
    // public Map<String,ASI_CRM_CN_PaymentRequestUtilCls.PaymentSummary> MPaymentSummary {set;get;}
    
    // public List<ASI_CRM_Contract_Cost__c> LPSF {set;get;}
    
    public Boolean showReturn {set;get;}
    
    public Boolean boolCNLanguage {set;get;}
    public String strTotal {set;get;}
    
    
    Public Map<String, Boolean> festivalMap{Get; Set;}
    // Public Map<String, String> poTypeMap{Get; Set;}
    // Public Boolean isFestivalPSF{Get; Set;}
    

    public List <ASI_TH_CRM_PaymentRequestLineItem__c> paymentItemList {set;get;}
    public ASI_CRM_CN_TotalAmount totalAmount {set;get;}

    public class ASI_CRM_CN_TotalAmount{
        public Decimal pmtVol {set;get;}
        public Decimal estAmount {set;get;}
        public Decimal fixedAmount {set;get;}
        public Decimal paymentAmount {set;get;}

        public Decimal paymentCost {set;get;}
        public Decimal paymentPromotion {set;get;}

        public ASI_CRM_CN_TotalAmount() {
            pmtVol = 0;
            estAmount = 0;
            fixedAmount = 0;
            paymentAmount = 0;
            paymentCost = 0;
            paymentPromotion = 0;
        }
    }

    public totalinnerCls totalBRSF2 {set;get;}

    public class totalinnerCls{
        public Decimal volumes {set;get;}
        public Decimal fixedAmount {set;get;}
        public Decimal promotionAmount {set;get;}   
        public Decimal gs {set;get;}
        public Decimal gsPercent {set;get;}
        public Decimal cm {set;get;}

        public totalinnerCls() {
            volumes = 0;
            fixedAmount = 0;
            promotionAmount = 0;
            gs = 0;
            gsPercent = 0;
            cm = 0;
        }
    }

    
    public void getPlanItems() {
        totalAmount = new ASI_CRM_CN_TotalAmount();
        paymentItemList = [select ASI_CRM_CN_TP_Plan_Line_Item__r.ASI_MFM_Sub_brand_Code__r.Name,
                                  ASI_CRM_CN_TP_Plan_Line_Item__r.ASI_CRM_CN_TP_Estimated_Amount__c,
                                  ASI_CRM_CN_TP_Plan_Line_Item__r.ASI_CRM_CN_TP_Bottle_Size__c,
                                  ASI_CRM_CN_TP_Plan_Line_Item__r.ASI_MFM_Plan__c,
                                  ASI_CRM_CN_TP_Plan_Line_Item__r.ASI_MFM_Plan__r.Name,
                                  ASI_CRM_CN_TP_Plan_Line_Item__r.ASI_MFM_Plan__r.ASI_CRM_CN_TP_Activity_NO__c,
                                  ASI_CRM_CN_TP_Plan_Line_Item__r.ASI_CRM_CN_TP_Fixed_Cost__c,
                                  ASI_CRM_CN_TP_Plan_Line_Item__r.ASI_CRM_CN_TP_Payment_Amount__c,
                                  ASI_CRM_CN_TP_Plan_Line_Item__r.ASI_CRM_CN_TP_VolumesIn9L__c,
                                  ASI_CRM_CN_TP_Fixed_Cost__c,
                                  ASI_CRM_CN_TP_Promotion_Fee__c,
                                  ASI_CRM_CN_Actual_Vol__c
                            from ASI_TH_CRM_PaymentRequestLineItem__c
                            where ASI_TH_CRM_Payment_Request__c = :PH.Id
                            and (ASI_CRM_CN_TP_Fixed_Cost__c >0
                            or ASI_CRM_CN_TP_Promotion_Fee__c>0)
                            and RecordType.DeveloperName = 'ASI_CRM_CN_TP_Payment_Request_Detail_TradePlan'
                            order by ASI_CRM_CN_TP_Plan_Line_Item__r.ASI_MFM_Plan__r.ASI_CRM_CN_TP_Activity_NO__c desc];

        for (ASI_TH_CRM_PaymentRequestLineItem__c item : paymentItemList) {
            totalAmount.pmtVol += (item.ASI_CRM_CN_Actual_Vol__c ==null ? 0 : item.ASI_CRM_CN_Actual_Vol__c);
            totalAmount.estAmount += (item.ASI_CRM_CN_TP_Plan_Line_Item__r.ASI_CRM_CN_TP_Estimated_Amount__c==null?0:item.ASI_CRM_CN_TP_Plan_Line_Item__r.ASI_CRM_CN_TP_Estimated_Amount__c);
            totalAmount.fixedAmount += (item.ASI_CRM_CN_TP_Plan_Line_Item__r.ASI_CRM_CN_TP_Fixed_Cost__c==null?0:item.ASI_CRM_CN_TP_Plan_Line_Item__r.ASI_CRM_CN_TP_Fixed_Cost__c);
            totalAmount.paymentAmount += (item.ASI_CRM_CN_TP_Plan_Line_Item__r.ASI_CRM_CN_TP_Payment_Amount__c == null?0:item.ASI_CRM_CN_TP_Plan_Line_Item__r.ASI_CRM_CN_TP_Payment_Amount__c);
            totalAmount.paymentCost += (item.ASI_CRM_CN_TP_Fixed_Cost__c==null?0:item.ASI_CRM_CN_TP_Fixed_Cost__c);
            totalAmount.paymentPromotion += (item.ASI_CRM_CN_TP_Promotion_Fee__c==null?0:item.ASI_CRM_CN_TP_Promotion_Fee__c);
        }
        totalAmount.pmtVol.setScale(2);
        totalAmount.estAmount.setScale(2);
        totalAmount.fixedAmount.setScale(2);
        totalAmount.paymentAmount.setScale(2);
        totalAmount.paymentCost.setScale(2);
        totalAmount.paymentPromotion.setScale(2);
    }

    public PageReference GoReturn(){
        List<ASI_TH_CRM_PaymentRequest__c> LPayment = [Select Id, ASI_TH_CRM_Status__c, ASI_CRM_CN_Return_Comments__c from ASI_TH_CRM_PaymentRequest__c where id=:PageId LIMIT 1];
        List<Profile> LProfileID = [SELECT Id, Name FROM Profile WHERE Id=:userinfo.getProfileId() LIMIT 1];
        String profileName = LProfileID[0].Name;

        if(LPayment.size() > 0){ 
            if(LPayment [0].ASI_TH_CRM_Status__c != 'Submitted'){ 
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, Label.ASI_CRM_CN_TP_PmtDetail_Error));
            } else{ 
                
                if(LPayment[0].ASI_CRM_CN_Return_Comments__c != ''){
                    try{
                        LPayment[0].ASI_CRM_CN_Return_Comments__c = '';
                        update LPayment[0];
                    }catch(dmlException e){
                        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Unable to save Return Comments'));
                    }
                }
                
                PageReference pageRef = new PageReference('/apex/ASI_CRM_CN_ReturnPaymentByBAPage?scontrolCaching=1&id='+PageId);
                pageRef.setRedirect(True);
                return pageRef;
            }
        }
        return null;       
    }

    public PageReference GoEditPayee(){
        PageReference redirect = new PageReference('/apex/ASI_CRM_CN_EditPaymentPayeePage'); 
        redirect.getParameters().put('id',PageId); 
        redirect.setRedirect(true); 
        return redirect;
    }
    
    
    public ASI_CRM_CN_TP_PaymentDetailCtrl(ApexPages.StandardController controller) {
        this.PH = (ASI_TH_CRM_PaymentRequest__c)controller.getRecord();
        refresh();
        // getRows();
        getPlanItems();
    }
    
    
    
    // public List<ASI_CRM_SpecialPromotionTypeSetting__c> GetAllSpecialPromotionTypeSetting() {
        
    //     String recordType = Global_RecordTypeCache.getRtId('ASI_CRM_SpecialPromotionTypeSetting__cASI_CRM_CN_SpecialPromotionTypeSetting');
        
    //     List<ASI_CRM_SpecialPromotionTypeSetting__c> tmpList;
    //     if(PH.ASI_CRM_New_FY_Payment__c){
    //         tmpList = [SELECT Id, Name, ASI_CRM_Validate_TotalSuggestedAmount__c, ASI_CRM_Promotion_Type_Chinese_Name__c, ASI_CRM_Bypass_Contract_Upload_Checking__c, ASI_CRM_Override_BC_Rate__c, ASI_CRM_SuggestedAmount_And_TargetVolume__c, ASI_CRM_Promotion_Type__c FROM ASI_CRM_SpecialPromotionTypeSetting__c
    //                    WHERE recordtypeid =: recordType AND ASI_CRM_New_FY_Promotion_Type__c = TRUE ORDER BY Name];
    //     }else{
    //         tmpList = [SELECT Id, Name, ASI_CRM_Validate_TotalSuggestedAmount__c, ASI_CRM_Promotion_Type_Chinese_Name__c, ASI_CRM_Bypass_Contract_Upload_Checking__c, ASI_CRM_Override_BC_Rate__c, ASI_CRM_SuggestedAmount_And_TargetVolume__c, ASI_CRM_Promotion_Type__c FROM ASI_CRM_SpecialPromotionTypeSetting__c
    //                    WHERE recordtypeid =: recordType AND ASI_CRM_New_FY_Promotion_Type__c = FALSE];
    //     }
        
    //     return tmpList;
    // }
    
    
    
    public PageReference cancel(){        
        PageReference ab = new PageReference('/apex/ASI_CRM_CN_Payment_Header_Page'); 
        ab.getParameters().put('id',PageId); 
        ab.setRedirect(true); 
        return ab;
    }
    public void refresh(){
        boolCNLanguage = false;
        strTotal = 'Total:';
        PageId = PH.id;
        showReturn = false;
        // adjustment = 100;
        
        if (PageId != null){
            HeaderList = [SELECT id, name, ASI_CRM_CN_Payable_Amount__c, ASI_CRM_CN_Other_Reason__c, 
                          
                          ASI_TH_CRM_Status__c, ASI_CRM_CN_Bottle_Collection_Rate__c,  ASI_CRM_CN_BRSF_End_Date__c, 
                          
                          ASI_CRM_CN_BRSF_Start_Date__c,
                          ASI_CRM_CN_Channel__c, ASI_CRM_CN_Currency__c, ASI_CRM_CN_Last_Payment__c, 
                          
                          ASI_CRM_CN_Last_Year_Payment__c,ASI_CRM_CN_Division__c,
                          ASI_CRM_CN_OutletWS__c, ASI_CRM_CN_Payment_Raised_Date__c, ASI_CRM_CN_Payment_Type__c, 
                          
                          ASI_CRM_CN_PO_End_Date__c,ASI_TH_CRM_Contract__r.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Region__c,
                          ASI_CRM_CN_PO_No__c, ASI_CRM_CN_PO_Start_Date__c, ASI_CRM_CN_PO_Version__c, ASI_CRM_Volume_Option__c,
                          
                          ASI_CRM_CN_Promotion_Type__c,ASI_TH_CRM_Contract__r.ASI_CRM_CN_Outlet_WS__c,ASI_CRM_CN_OutletWS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__r.ASI_CRM_Region_Code__c,
                          ASI_CRM_CN_Reference_Code__c,ASI_TH_CRM_Total_Amount__c, ASI_CRM_CN_Total_Other_Amount__c, ASI_CRM_CN_PO_Version_Latest__c, ASI_CRM_CN_Overpayment_Reason__c,
                          ASI_CRM_CN_Total_BRSF_Amount__c,ASI_CRM_CN_Reason_For_Business_License__c, ASI_CRM_CN_Business_License_Qualify__c ,ASI_CRM_CN_Total_PSF_Amount__c, ASI_TH_CRM_Contract__r.ASI_CRM_CN_Outlet_WS__r.RecordType.DeveloperName,
                          ASI_CRM_CN_Adjustment__c, ASI_CRM_CN_No_of_Month__c   , ASI_CRM_CN_Total_Payment__c , ASI_CRM_CN_Overpayment_Comment__c,
                          ASI_TH_CRM_Contract__c,ASI_TH_CRM_Contract__r.ASI_CRM_CN_Total_Contract_Amount__c, ASI_CRM_CN_Total_BRSF_Actual_Amount__c,
                          ASI_TH_CRM_Contract__r.ASI_TH_CRM_Contract_Status__c, ASI_TH_CRM_Contract__r.ASI_CRM_CN_Last_PO_version__r.ASI_TH_CRM_Contract_Status__c  ,
                          ASI_TH_CRM_Contract__r.ASI_CRM_CN_Last_PO_version__r.ASI_CRM_CN_PO_Version__c, 
                          ASI_TH_CRM_Contract__r.ASI_CRM_Investment_Type__c, ASI_CRM_Auto_PO_Modification__c,
                          ASI_CRM_CN_Description__c, ASI_TH_CRM_Contract__r.ASI_CRM_CN_PO_Modification__c,
                          ASI_TH_CRM_Contract__r.ASI_CRM_CN_Status__c, ASI_CRM_New_FY_Payment__c,ASI_CRM_Volume_Cut_Off_Date__c,
                          ASI_CRM_CN_OutletWS__r.ASI_CRM_CN_Greater_Region_Code__c
                          FROM ASI_TH_CRM_PaymentRequest__c WHERE id = :PageId];
            if (HeaderList.size()> 0){
                this.PH = HeaderList[0];
                
                // poTypeMap = new Map<String, String>();
                // List<ASI_CRM_SpecialPromotionTypeSetting__c> tmpList = GetAllSpecialPromotionTypeSetting();
                
                // if(tmpList.size() > 0){
                //     for(ASI_CRM_SpecialPromotionTypeSetting__c obj : tmpList){
                        
                //         if(boolCNLanguage){
                            
                //             if(obj.ASI_CRM_Promotion_Type_Chinese_Name__c != NULL && obj.ASI_CRM_Promotion_Type_Chinese_Name__c != ''){
                                
                //                 // poTypeMap.put(obj.ASI_CRM_Promotion_Type__c, obj.ASI_CRM_Promotion_Type_Chinese_Name__c);
                //             }else{
                                
                //                 poTypeMap.put(obj.ASI_CRM_Promotion_Type__c, obj.ASI_CRM_Promotion_Type__c);
                //             }
                //         }
                //     }
                // }
                
            }
            
            
            system.debug('PH.id: ' + PH.id);
            

            if([SELECT Assignee.Name, PermissionSet.name
                FROM PermissionSetAssignment where permissionSet.name ='ASI_CRM_CN_General_BA' and Assigneeid = :Userinfo.getUserid()].size()>0 && PH.ASI_TH_CRM_Status__c == 'Submitted'){
                showReturn= true;
            }

            String POTypeName = PH.ASI_CRM_New_FY_Payment__c ? '%PSF & Trading Term Incentives%' : '%Promotion Service Fee%';
            
            // LPSF = [Select id, name,ASI_CRM_CN_Chinese_Description__c, ASI_CRM_CN_Activity_Code__c, 
            //         ASI_CRM_CN_Cost_Type__c from asi_crm_contract_cost__c 
            //         where asi_crm_cn_contract__c = :PH.ASI_TH_CRM_Contract__c and name like : POTypeName];
            // System.debug(LPSF);

            
            // Remaining_Amount=0;
            PaymentRequestList = [Select  id,Name, ASI_CRM_CN_Last_Payment__c, ASI_TH_CRM_Contract__c,ASI_CRM_CN_PO_Version__c,
                                  ASI_CRM_CN_PO_Start_Date__c,ASI_CRM_CN_PO_End_Date__c,ASI_TH_CRM_Status__c,ASI_CRM_CN_Channel__c,
                                  ASI_CRM_CN_Total_Payment__c
                                  FROM ASI_TH_CRM_PaymentRequest__c 
                                  WHERE ASI_TH_CRM_Contract__c=:PH.ASI_TH_CRM_Contract__c
                                  AND (ASI_TH_CRM_Status__c='Approved' or ASI_TH_CRM_Status__c='Submitted')
                                 ];

            
            // for(ASI_TH_CRM_PaymentRequest__c payment_req : PaymentRequestList){
            //     if( payment_req.ASI_CRM_CN_Total_Payment__c!=null){
            //         if(Remaining_Amount==null){Remaining_Amount=0;}
            //         Remaining_Amount+=payment_req.ASI_CRM_CN_Total_Payment__c;
            //     }
            // }
            
            // if(Remaining_Amount==null)
            // {Remaining_Amount=0;
            // }
            // Remaining_Amount=PH.ASI_TH_CRM_Contract__r.ASI_CRM_CN_Total_Contract_Amount__c!=null&& PH.ASI_TH_CRM_Contract__r.ASI_CRM_CN_Total_Contract_Amount__c!=0?PH.ASI_TH_CRM_Contract__r.ASI_CRM_CN_Total_Contract_Amount__c-Remaining_Amount:0;

            BRSFList = [SELECT id, ASI_CRM_CN_TP_CM_Amount__c,ASI_TH_CRM_Payment_Request__c, ASI_CRM_CN_Standard__c, ASI_CRM_CN_Sub_Brand__c, ASI_CRM_CN_Target_BT__c, 
                        ASI_CRM_CN_Incentive_BT__c, ASI_CRM_CN_Actual_Vol__c, ASI_CRM_CN_Completion_Rate__c, ASI_CRM_CN_Total_Payable__c,
                        ASI_CRM_CN_Payable_Vol__c, ASI_CRM_CN_Bottle_Collected__c, ASI_CRM_CN_Collection_Rate__c, ASI_CRM_CN_Offtake_Vol__c,
                        ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.Name,ASI_TH_CRM_Amount__c, ASI_CRM_CN_Suggested_Amount__c,
                        ASI_CRM_CN_Allow_Changing_Incentive__c, ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.ASI_CRM_Chinese_Name__c, ASI_CRM_Suggested_Volume__c,
                        ASI_CRM_Volume_9L__c,
                        ASI_CRM_CN_TP_Fixed_Cost__c,
                        ASI_CRM_CN_TP_GS_Amount__c,
                        ASI_CRM_CN_TP_GS_Percent__c,
                        ASI_CRM_CN_TP_Amount__c
                        FROM ASI_TH_CRM_PaymentRequestLineItem__c 
                        WHERE ASI_TH_CRM_Payment_Request__c =:PH.id
                        // and (ASI_CRM_CN_TP_Fixed_Cost__c > 0
                        // or ASI_CRM_CN_TP_CM_Amount__c > 0)
                        and RecordTypeId = :Global_RecordTypeCache.getRTId('ASI_TH_CRM_PaymentRequestLineItem__cASI_CRM_CN_Payment_Request_Detail_BRSF')
                        order by ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.ASI_CRM_CN_Sequence__c
                       ];
            
            system.debug('BRSFList: ' + BRSFList);
            
            // PSFList = [SELECT id, ASI_TH_CRM_Payment_Request__c,ASI_CRM_CN_Payment_Description__c, ASI_CRM_CN_Comment__c ,
            //            ASI_CRM_CN_Period_Start__c, ASI_CRM_CN_Period_End__c, ASI_CRM_CN_Supporting_Document__c, ASI_TH_CRM_Amount__c, 
            //            recordtypeid, ASI_CRM_CN_AC_Code__c, ASI_CRM_CN_Cost_Type__c, ASI_CRM_CN_Expense_Type__c
            //            , ASI_CRM_CNY_Est__c, ASI_CRM_MAF_Est__c, ASI_CRM_Other_Est__c
            //            FROM ASI_TH_CRM_PaymentRequestLineItem__c  
            //            WHERE ASI_TH_CRM_Payment_Request__c =:PH.id AND
            //            RecordTypeId = :Global_RecordTypeCache.getRTId('ASI_TH_CRM_PaymentRequestLineItem__cASI_CRM_CN_Payment_Request_Detail_PSF')
            //           ];
            
            OTPList = [SELECT id, ASI_TH_CRM_Payment_Request__c, ASI_CRM_CN_Expense_Type__c, ASI_CRM_CN_Comment__c, ASI_TH_CRM_Amount__c, ASI_CRM_CN_Remaining_Amount__c, recordtypeid 
                       , ASI_CRM_CNY_Est__c, ASI_CRM_MAF_Est__c, ASI_CRM_Other_Est__c, ASI_TH_CRM_Payment_Request__r.ASI_CRM_CN_Promotion_Type__c, ASI_CRM_CN_AC_Code__c
                       FROM ASI_TH_CRM_PaymentRequestLineItem__c 
                       WHERE ASI_TH_CRM_Payment_Request__c =:PH.id AND
                       RecordTypeId = :Global_RecordTypeCache.getRTId('ASI_TH_CRM_PaymentRequestLineItem__cASI_CRM_CN_Payment_Request_Detail_Other')
                      ];
            
            // rtPSF = Global_RecordTypeCache.getRTRec('ASI_TH_CRM_PaymentRequestLineItem__cASI_CRM_CN_Payment_Request_Detail_PSF');
            
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
            
            
            // Del_Payee_Item_CASH = new List<ASI_CRM_CN_PH_Payee_Line_Item__c>();
            Payee_Item_Map_CASH = new Map<Integer, ASI_CRM_CN_PH_Payee_Line_Item__c>();
            indexCASH = 0;
            
            if(PHPayee_CASH != null && PHPayee_CASH.size()>0){
                for (ASI_CRM_CN_PH_Payee_Line_Item__c psf :PHPayee_CASH){
                    Payee_Item_Map_CASH.put(indexCASH++, psf);
                }
            }


            // Del_Payee_Item_DISCOUNT = new List<ASI_CRM_CN_PH_Payee_Line_Item__c>();
            Payee_Item_Map_DISCOUNT = new Map<Integer, ASI_CRM_CN_PH_Payee_Line_Item__c>();
            indexDISCOUNT = 0;
            
            if(PHPayee_DISCOUNT != null && PHPayee_DISCOUNT.size()>0){
                for (ASI_CRM_CN_PH_Payee_Line_Item__c psf :PHPayee_DISCOUNT){
                    Payee_Item_Map_DISCOUNT.put(indexDISCOUNT++, psf);
                }
            }

            // Del_Payee_Item_CD = new List<ASI_CRM_CN_PH_Payee_Line_Item__c>();
            Payee_Item_Map_CD = new Map<Integer, ASI_CRM_CN_PH_Payee_Line_Item__c>();
            indexCD = 0;
            
            if(PHPayee_CD != null && PHPayee_CD.size()>0){
                for (ASI_CRM_CN_PH_Payee_Line_Item__c psf :PHPayee_CD){
                    Payee_Item_Map_CD.put(indexCD++, psf);
                }
            }
            
            
            // Del_PSF_Item = new List<ASI_TH_CRM_PaymentRequestLineItem__c>();
            // PSF_Item_Map = new Map<Integer, ASI_TH_CRM_PaymentRequestLineItem__c>();
            // indexPSF = 0;
            
            // if(PSFList != null && PSFList.size()>0){
            //     for (ASI_TH_CRM_PaymentRequestLineItem__c psf :PSFList){
            //         PSF_Item_Map.put(indexPSF++, psf);
            //     }
            // }
            
            if (PH.ASI_CRM_CN_Payment_Type__c != null && (PH.ASI_CRM_CN_Payment_Type__c.contains('Cash')||PH.ASI_CRM_CN_Payment_Type__c.contains('cash')))
                cashtype = true;
            else
                cashtype = false;        
            if (PH.ASI_CRM_CN_Payment_Type__c != null && (PH.ASI_CRM_CN_Payment_Type__c.contains('Discount')||PH.ASI_CRM_CN_Payment_Type__c.contains('discount')))
                discounttype = true;
            else
                discounttype = false;
                
            calcBRSFTotal();    
        }

        if(OTPList != null && OTPList.size()>0){
            
            festivalMap = new Map<String, Boolean>();
            Map<String, Boolean> tmpMap = new Map<String, Boolean>();
            List<ASI_CRM_Contract_Cost_Setting__c> ccs = new List<ASI_CRM_Contract_Cost_Setting__c>([SELECT id, ASI_CRM_CN_Promotion_Type__c, ASI_CRM_Festival_Season__c, ASI_CRM_CN_Activity_Code__c FROM ASI_CRM_Contract_Cost_Setting__c WHERE RecordType.DeveloperName = 'ASI_CRM_CN_Contract_Cost_Setting']);
            
            for(ASI_CRM_Contract_Cost_Setting__c obj : ccs){
                tmpMap.put('' + obj.ASI_CRM_CN_Promotion_Type__c + obj.ASI_CRM_CN_Activity_Code__c, obj.ASI_CRM_Festival_Season__c);
            }
            
            
            
            // isFestivalPSF = FALSE;
            
            // if(LPSF.size() > 0 && PH.ASI_CRM_New_FY_Payment__c && tmpMap.containsKey(PH.ASI_CRM_CN_Promotion_Type__c + LPSF[0].ASI_CRM_CN_Activity_Code__c)){
            //     isFestivalPSF = tmpMap.get(PH.ASI_CRM_CN_Promotion_Type__c + LPSF[0].ASI_CRM_CN_Activity_Code__c);
            // }
            
            
            for(ASI_TH_CRM_PaymentRequestLineItem__c  payment_request:OTPList){
                // if(payment_request.ASI_CRM_CN_Expense_Type__c=='PRC - Down Payment - On Premise'){
                //     downpayment=payment_request;
                    
                // }
                
                if(tmpMap.containsKey(payment_request.ASI_TH_CRM_Payment_Request__r.ASI_CRM_CN_Promotion_Type__c + '' + payment_request.ASI_CRM_CN_AC_Code__c)){
                    festivalMap.put(payment_request.id, tmpMap.get(payment_request.ASI_TH_CRM_Payment_Request__r.ASI_CRM_CN_Promotion_Type__c + '' + payment_request.ASI_CRM_CN_AC_Code__c));
                }else{
                    festivalMap.put(payment_request.id, FALSE);
                }
                
            }
        }
        
        // Allow_Submit_For_Approval= true;
        
        // retrievePicklist();
        
        
        LPaymentSummary = ASI_CRM_CN_PaymentRequestUtilCls.genPaymentSummary(PH,null);
        // MPaymentSummary = new Map<String,ASI_CRM_CN_PaymentRequestUtilCls.PaymentSummary>();
        
        TotalPOEstAmt = 0;
        TotalPORemainAmt = 0;
        TotalRequestAmt = 0;
        
        // TotalRemainAmtCNY = 0;
        // TotalRemainAmtMAF = 0;
        // TotalRemainAmtOthers = 0;
        
        // TotalEstAmtCNY = 0;
        // TotalEstAmtMAF = 0;
        // TotalEstAmtOthers = 0;
        
        TotalRequestAmtCNY = 0;
        TotalRequestAmtMAF = 0;
        TotalRequestAmtOthers = 0;
        
        System.debug(LPaymentSummary);
        for(ASI_CRM_CN_PaymentRequestUtilCls.PaymentSummary ps : LPaymentSummary){
            TotalPOEstAmt += ps.POEstimateAmt;
            TotalPORemainAmt += ps.PORemainAmt;
            TotalRequestAmt += ps.PaymentRequestAmount;
            
            
            // TotalEstAmtCNY += ps.cnyEst;
            // TotalEstAmtMAF += ps.mafEst;
            // TotalEstAmtOthers += ps.othersEst;
            
            // TotalRemainAmtCNY += ps.cnyRemaining;
            // TotalRemainAmtMAF += ps.mafRemaining;
            // TotalRemainAmtOthers += ps.othersRemaining;
            
            TotalRequestAmtCNY += ps.cnyRequest;
            TotalRequestAmtMAF += ps.mafRequest;
            TotalRequestAmtOthers += ps.othersRequest;
            
            // if(!MPaymentSummary.containsKey(ps.feeChiName))
            //     MPaymentSummary.put(ps.feeChiName, ps);
        }
        
        
    }
    
    
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
    
    
    public pageReference saveDate(){
        // checkBRSFDate();
        return null;
    }
    
    public void calcBRSFTotal(){
        if(ph!=null){
            PH.ASI_CRM_CN_Payable_Amount__c = 0;
            Decimal totalActual = 0;
            Decimal totalTarget = 0;
            // completionRate = 0;

            totalBRSF2 = new totalinnerCls();

            for(ASI_TH_CRM_PaymentRequestLineItem__c item : BRSFList){
                if(item.ASI_CRM_Volume_9L__c != null){
                    // item.ASI_CRM_Volume_9L__c = item.ASI_CRM_Volume_9L__c.setScale(2);
                    totalBRSF2.volumes += item.ASI_CRM_Volume_9L__c;

                }
                if(item.ASI_CRM_CN_TP_GS_Amount__c != null){
                    totalBRSF2.gs += item.ASI_CRM_CN_TP_GS_Amount__c;
                }
                if(item.ASI_CRM_CN_TP_CM_Amount__c != null){
                    totalBRSF2.cm += item.ASI_CRM_CN_TP_CM_Amount__c;
                }
                if(item.ASI_CRM_CN_TP_Amount__c != null){
                    totalBRSF2.promotionAmount += item.ASI_CRM_CN_TP_Amount__c;
                }
                if(item.ASI_CRM_CN_TP_Fixed_Cost__c != null){
                    totalBRSF2.fixedAmount += item.ASI_CRM_CN_TP_Fixed_Cost__c;
                }

                if(item.ASI_CRM_CN_Total_Payable__c != null){
                    PH.ASI_CRM_CN_Payable_Amount__c += item.ASI_CRM_CN_Total_Payable__c;
                }
                if(item.ASI_CRM_CN_Actual_Vol__c != null)
                    totalActual += item.ASI_CRM_CN_Actual_Vol__c;
                if(item.ASI_CRM_CN_Target_BT__c != null)
                    totalTarget += item.ASI_CRM_CN_Target_BT__c;
            }

            totalBRSF2.gsPercent = totalBRSF2.gs!=0?totalBRSF2.promotionAmount / totalBRSF2.gs:0;

            // if(BRSFList.size()>0 && totalTarget > 0){
            //     completionRate = totalActual/totalTarget*100;
            // }
            // if(PH.ASI_CRM_CN_Payable_Amount__c != null && PH.ASI_CRM_CN_Adjustment__c!= null){
            //     actualPayment = PH.ASI_CRM_CN_Payable_Amount__c * PH.ASI_CRM_CN_Adjustment__c / 100;
            // }
        }
        
    }

    public PageReference submitApproval(){
        boolean isOverRemaining = false;
        if (LPaymentSummary.size() > 0){
            for (ASI_CRM_CN_PaymentRequestUtilCls.PaymentSummary pstemp : LPaymentSummary){
                system.debug('current payment summary');
                system.debug(pstemp);
                if (pstemp.PaymentRequestAmount > pstemp.PORemainAmt + 1)
                    isOverRemaining = true;

                 system.debug('isOverRemaining'+ isOverRemaining);
            }
        }
        if (isOverRemaining == true){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.ASI_CRM_CN_TP_PmtAmountCheck));
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
            Decimal payee_amount= sum_of_payee_amount!=null?sum_of_payee_amount.setScale(2, RoundingMode.HALF_UP):0;
            Decimal total_Amount= PH.ASI_CRM_CN_Total_Payment__c!=null?PH.ASI_CRM_CN_Total_Payment__c.setScale(2, RoundingMode.HALF_UP):0;
            if (PH.ASI_CRM_CN_Total_Payment__c  > PH.ASI_TH_CRM_Contract__r.ASI_CRM_CN_Total_Contract_Amount__c){
                ApexPages.Message msg;
                msg = new ApexPages.Message(ApexPages.Severity.ERROR, Label.ASI_CRM_CN_TP_PmtOverPOAmtCheck);
                apexpages.addmessage(msg);
                redirect = null;
            }
            else if(sum_of_payee_amount!=total_Amount){                
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.ASI_CRM_CN_TP_PmtAmtAppAmtCheck + 'Payment amount: '+payee_amount+'. Total Payment Amount: '+total_Amount));
                redirect = null;
            }
            else{
                redirect = new PageReference('/apex/ASI_CN_SubmitApprovalPage?id=' + PageId);

            }
            
            AggregateResult PaymentTotal = [SELECT SUM(ASI_CRM_CN_Total_Payment__c) totalPayment FROM ASI_TH_CRM_PaymentRequest__c WHERE ASI_TH_CRM_Contract__c = :PH.ASI_TH_CRM_Contract__c AND ASI_TH_CRM_Status__c <> 'Draft'];
            
            List<ASI_TH_CRM_Contract__c>  contract = [SELECT ASI_CRM_CN_Total_Contract_Amount__c FROM ASI_TH_CRM_Contract__c WHERE Id = :PH.ASI_TH_CRM_Contract__c];
            
            Decimal totalPayment = 0;
            if(PaymentTotal.get('totalPayment') != null){
                totalPayment = Decimal.valueOf(String.valueOf(PaymentTotal.get('totalPayment')));
            }
            
            
            if(contract.size() > 0 && totalPayment + PH.ASI_CRM_CN_Total_Payment__c > (contract[0].ASI_CRM_CN_Total_Contract_Amount__c + 0.1)){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,Label.ASI_CRM_CN_PaymentRequestTotalAmountCheckErrMsg));
                redirect = null;            
            }
            
            if(PH.ASI_TH_CRM_Contract__r.ASI_CRM_CN_Status__c != 'Final'){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,Label.ASI_CRM_CN_PaymentRequestSubmitErrorMsg));
                redirect = null;
            }
            
            return redirect;
        }

    }
    
    public void GoEditHeader(){
        // PageReference redirect = new PageReference('/apex/ASI_CRM_CN_EditPayment_Header_Page'); 
        // redirect.getParameters().put('id',PageId); 
        // redirect.setRedirect(true); 
        // return redirect;
        showEdit = true;
    }

    public void UpdateRecord(){
        update PH;
        showEdit = false;
    }

    public void doCancel(){
        showEdit = false;
    }

    public PageReference AutoPOModification(){
        if(PH.ASI_TH_CRM_Contract__r.ASI_TH_CRM_Contract_Status__c=='Final'){
            try{
                PH.ASI_CRM_Auto_PO_Modification__c =true;
                update PH;
                ASI_TH_CRM_Contract__c contract = [SELECT Id,Name,ASI_CRM_Reject_Return_Comments__c,ASI_CRM_CN_Return_Comments__c,ASI_CRM_CN_Last_Approved_By__c,ASI_CRM_CN_Last_Approved_Date__c,
                                                        ASI_CRM_PSF_Estimate_Adjustment_Amount__c,ASI_CRM_EVC_Cost_Estimate_Total__c,ASI_CRM_CN_V0_0_PO_version__c,
                                                        ASI_CRM_V0_PSF_Contract_Total__c,ASI_CRM_Expected_V0_PSF_Estimated_Total__c,ASI_CRM_Martell_BC_Rate__c,ASI_CRM_Auto_PO_Modification_Time__c,ASI_CRM_Auto_PO_Modification__c,
                                                        ASI_CRM_CN_Expected_PSF_Est_Total__c,ASI_CRM_Previous_Version_PSF_Est_Total__c,ASI_CRM_Converted_From__c,
                                                        ASI_CRM_CN_Last_Recall_By__c,ASI_CRM_CN_Last_Recall_Date__c,ASI_CRM_CN_Last_Rejected_By__c,ASI_CRM_CN_Last_Submitted_By__c,
                                                        ASI_CRM_CN_Group_Contract__c, ASI_CRM_Investment_Type__c,ASI_CRM_CN_Total_Contract_Amount__c , ASI_CRM_CN_Vol_Budget_LE__c, ASI_CRM_CN_Status__c, ASI_CRM_CN_Source_of_Contract__c,ASI_CRM_CN_Source_Others__c,
                                                        ASI_CRM_CN_Reason_without_Budget__c, ASI_TH_CRM_Promotion_Type__c, ASI_CRM_CN_PP_No__c, ASI_CRM_CN_PO_Version__c, ASI_CRM_CN_PO_Start_Date__c, ASI_CRM_CN_PO_No__c, ASI_CRM_CN_PO_End_Date__c, ASI_CRM_CN_Outlet_WS__c,
                                                        ASI_CRM_CN_Exchange_Rate__c, ASI_CRM_CN_Expected_BRSF_Est_Total__c , ASI_CRM_Expected_V0_0_VEC_Est_Total__c,ASI_CRM_Expected_V0_BRSF_Estimated_Total__c,  ASI_CRM_CN_Description__c, ASI_CRM_CN_Currency__c, ASI_CRM_CN_Budget_LE__c, ASI_CRM_CN_Bottle_Collection_Rate__c, ASI_CRM_CN_Effective_Date__c,
                                                        RecordTypeId, ASI_CRM_CN_No_of_Months__c , ASI_CRM_CN_PO_Modification__c , ASI_CRM_CN_Special_Promotion__c, ASI_CRM_CN_Contract_Upload__c,  ASI_CRM_CN_Last_PO_version__c, ASI_CRM_CN_National_Group_Contract__c,ASI_CRM_CN_Business_License__c, CreatedDate, ASI_CRM_CN_Outlet_WS__r.RecordType.DeveloperName, ASI_CRM_Volume_Option__c, LastModifiedDate, ASI_CRM_New_FY_PO__c, ASI_CRM_PO_Channel__c, ASI_CRM_PO_Province__c,
                                                        ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_NewChannel__r.Name, ASI_CRM_PO_City__c, ASI_CRM_PO_City__r.Name,ASI_CRM_National_Group__c, ASI_CRM_CN_Last_PO_version__r.ASI_CRM_National_Group__c,
                                                        ASI_CRM_National_Group__r.Name, ASI_CRM_CN_Last_PO_version__r.ASI_CRM_National_Group__r.Name, ASI_CRM_CN_Last_Submitted_Date__c, ASI_CRM_CN_Last_Rejected_Date__c,
                                                        ASI_CRM_CN_Expected_Display_Est_Total__c, ASI_CRM_CN_TP_Is_Trade_Plan_CN__c, 
                                                        ASI_CRM_CN_V0_Display_Contract_Total__c,
                                                        ASI_CRM_CN_Expected_V0_Display_Est_Total__c,
                                                        ASI_CRM_Prev_Version_Display_Est_Total__c,
                                                        ASI_CRM_Display_Estimate_Adjustment_Amt__c,
                                                        (SELECT Id, Name, ASI_CRM_CN_Last_Payment__c, ASI_TH_CRM_Contract__c
                                                           FROM ASI_TH_CRM_PaymentRequests_Contract__r)
                                                    FROM ASI_TH_CRM_Contract__c
                                                    WHERE Id = :PH.ASI_TH_CRM_Contract__c];
                
                contract.ASI_CRM_CN_Status__c= 'Archived';
                update contract;
                //---- get original Contract Cost items ----
                String whereClause = 'ASI_CRM_CN_Contract__c =\'' + contract.Id + '\'';
                String soqlContractCost = ASI_CRM_Function.getCreatableFieldsSOQL('ASI_CRM_Contract_Cost__c', whereClause, '');
                List<ASI_CRM_Contract_Cost__c> LContractCost = Database.query(soqlContractCost);

                //cloned header
                ASI_TH_CRM_Contract__c contractCloned = contract.clone(false, true);
                contractCloned.ASI_CRM_CN_Status__c = 'Final';
                contractCloned.ASI_CRM_CN_PO_Version__c = String.valueOf(Decimal.valueOf(Contract.ASI_CRM_CN_PO_Version__c) + 0.1);
                contractCloned.Name = contract.Name + '1';

                contractCloned.ASI_CRM_CN_Last_PO_version__c = contract.Id;
                contractCloned.ASI_CRM_CN_V0_0_PO_version__c = contract.ASI_CRM_CN_V0_0_PO_version__c == null && contract.ASI_CRM_CN_PO_Version__c == '0.0' ? contract.Id : contract.ASI_CRM_CN_V0_0_PO_version__c;
                contractCloned.Id = null;
                insert contractCloned;

                //Calculate actual paid amount
                Decimal promotionEstimateAmount=0;
                Decimal dmDisplayEstimateAmount=0;
                List<ASI_TH_CRM_PaymentRequest__c> paymentRequest_update = new List<ASI_TH_CRM_PaymentRequest__c>();
                for(ASI_TH_CRM_PaymentRequest__c paymentRequest : [SELECT Id,Name,ASI_TH_CRM_Status__c, ASI_TH_CRM_Contract__c, 
                                                                          (SELECT Id, ASI_TH_CRM_Subbrand__c, ASI_CRM_Volume_9L__c, ASI_CRM_CN_TP_Amount__c, ASI_CRM_CN_TP_Fixed_Cost__c,  
                                                                                  ASI_CRM_CN_Total_Payable__c, RecordType.DeveloperName, ASI_CRM_CN_Payment_Description__c 
                                                                             FROM ASI_TH_CRM_PRLI_PaymentRequest__r) 
                                                                     FROM ASI_TH_CRM_PaymentRequest__c
                                                                    WHERE ASI_TH_CRM_Contract__c = :contract.Id 
                                                                      AND ASI_TH_CRM_Status__c != 'Draft']){
                    paymentRequest.ASI_TH_CRM_Contract__c = contractCloned.Id;
                    paymentRequest_update.add(paymentRequest);
                    for(ASI_TH_CRM_PaymentRequestLineItem__c prli : paymentRequest.ASI_TH_CRM_PRLI_PaymentRequest__r){
                        if(prli.RecordType.DeveloperName.contains('Other')){//payment summary
                            if (prli.ASI_CRM_CN_Payment_Description__c == 'PRC - Outlet Price Promotion') {
                                promotionEstimateAmount += prli.ASI_CRM_CN_Total_Payable__c;
                            } else if (prli.ASI_CRM_CN_Payment_Description__c == 'PRC - DM/Secondary Display Fee') {
                                dmDisplayEstimateAmount += prli.ASI_CRM_CN_Total_Payable__c;
                            }
                        }else if(prli.RecordType.DeveloperName.contains('BRSF')){
                            // if (String.isNotBlank(prli.ASI_TH_CRM_Subbrand__c)){
                                
                            // }
                        }
                    }
                }

                if (paymentRequest_update.size() > 0) {
                    update paymentRequest_update;
                }

                //------ Process Constract Cost Items ------
                List<ASI_CRM_Contract_Cost__c> LContractCost_Clone = new List<ASI_CRM_Contract_Cost__c>();
                if (LContractCost != null && LContractCost.size()>0){
                    for(ASI_CRM_Contract_Cost__c originalCost :LContractCost) {
                        ASI_CRM_Contract_Cost__c cloneCost = originalCost.clone(false, true);
                        cloneCost.ASI_CRM_CN_Contract__c = contractCloned.Id;
                        cloneCost.ASI_CRM_CN_External_ID__c=null;
                        if (cloneCost.Name == 'PRC - Outlet Price Promotion') {
                            cloneCost.ASI_CRM_CN_Estimate_Amount__c = promotionEstimateAmount;
                            cloneCost.ASI_CRM_CN_Contract_Amount__c = promotionEstimateAmount;
                            cloneCost.ASI_CRM_Other_Est__c = promotionEstimateAmount;
                        }
                        if (cloneCost.Name == 'PRC - DM/Secondary Display Fee') {
                            cloneCost.ASI_CRM_CN_Estimate_Amount__c = dmDisplayEstimateAmount;
                            cloneCost.ASI_CRM_CN_Contract_Amount__c = dmDisplayEstimateAmount;
                            cloneCost.ASI_CRM_Other_Est__c = dmDisplayEstimateAmount;
                        }
                        LContractCost_Clone.add(cloneCost);
                    }
                }

                if (LContractCost_Clone.size() > 0) {
                    insert LContractCost_Clone;
                }

                //Detail
                //move Contract Approval Comment
                List<ASI_CRM_Approval_Comment__c> LTransferContractComment = [SELECT Id, ASI_CRM_Contract__c FROM ASI_CRM_Approval_Comment__c WHERE ASI_CRM_Contract__c =: Contract.Id];
                for(ASI_CRM_Approval_Comment__c tcc : LTransferContractComment){
                    tcc.ASI_CRM_Contract__c = contractCloned.Id;
                }
                update LTransferContractComment;

                return new pageReference('/' + contractCloned.Id);
            }catch(Exception e){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
                return null;
            }
        }else{
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.ASI_CRM_CN_TP_POModifyCheck));
            return null;
        }
    }

}