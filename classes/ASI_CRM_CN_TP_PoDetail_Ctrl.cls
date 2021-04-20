/* Filename:    ASI_CRM_CN_TP_PoDetail_Ctrl.cls
* Author:
* Purpose:
*/
public without sharing class ASI_CRM_CN_TP_PoDetail_Ctrl {
    public ASI_TH_CRM_Contract__c ContractSelected {set; get;}
    public String PageId {set; get;}
    public ASI_CRM_CN_Contract_BRSF_Line_Item__c totalBRSF {set; get;}
    public ASI_CRM_Contract_Cost__c fix_totalCost {set; get;}
    public ASI_CRM_Contract_Cost__c variable_totalCost {set; get;}
    public Decimal totalBRSF_est_total {set; get;}
    public Decimal totalBRSF_contract_total {set; get;}
    public List <ASI_TH_CRM_Contract__c> LContract {set; get;}
    public List<ASI_CRM_CN_Covered_Outlet__c> ContractOutletList {set; get;}
    // public List<ASI_CRM_CN_Covered_Outlet__c> ContractOutletListCopy {set; get;}
    public List<ASI_TH_CRM_PaymentRequest__c> PaymentRequestList {set; get;}
    public boolean showApprovalButton {set; get;}
    public boolean showPOModification {set; get;}
    public boolean showRestorePO {set; get;}
    public boolean showShuttle {set; get;}
    public boolean makePayment {set; get;}
    public boolean showEdit {set; get;}
    public boolean isShowEdit {set; get;}
    public boolean contractUpload {set; get;}
    public boolean isCreate {set; get;}
    public boolean inBAPermissionSet {set; get;}
    public boolean businessLicense {set; get;}
    public Boolean showReturn {set; get;}
    public List<ASI_CRM_Contract_Cost__c> LFixCost {set; get;}
    public List<ASI_CRM_Contract_Cost__c> LFixCostDisplay {set; get;}
    public List<ASI_CRM_Contract_Cost__c> LVariableCost {set; get;}
    public List<ASI_CRM_Contract_Cost__c> LVariableCostDisplay {set; get;}
    public decimal Total_Payments_Amount {set; get;}
    public decimal Total_Payment_Paid {set; get;}
    public decimal Total_Payment_PaidInProgress {set; get;}
    public List<ASI_CRM_CN_Contract_BRSF_Line_Item__c> LBRSF {set; get;}
    public List<ASI_CRM_CN_Contract_BRSF_Line_Item__c> LBRSFDisplay {set; get;}
    public boolean pendingPR {set; get;}
    public Integer orgFiscalMonth {set; get;}

    public Boolean AllowEditInvestmentType {set; get;} {AllowEditInvestmentType = true;}

    public boolean isCNCRM {set; get;}
    public boolean showCN {set; get;} {showCN = false;}
    public string UserId {set; get;} //
    // public boolean ADorAbove {set; get;}
    
    public boolean paymentError {set; get;}
   
    public list<ASI_CRM_CN_PaymentRequestUtilCls.PaymentSummary> paymentRequestSummary {set; get;}

    Public Map<String, Boolean> festivalMap {Get; Set;}
    Public Boolean needChannelnProvince {Get; Set;}
    
    public List <ASI_MFM_Plan_Line_Item__c> planLineItemList {set; get;}
    public Decimal totalPlanEstVol {set; get;}
    public Decimal totalPlanEstAmount {set; get;}
    public Decimal totalPlanFixedAmount {set; get;}

    public totalinnerCls totalBRSF2 {set; get;}
    public Boolean showSuggestedAmountAndTargetVolume { get; set; } 
    public map<integer, ASI_CRM_CN_Covered_Outlet__c> CoveredOutlet_Item_Map {set;get;}
    public List <ASI_CRM_CN_Covered_Outlet__c> Del_CoveredOutlet_Item {set;get;}
    public List <ASI_CRM_CN_Covered_Outlet__c> Save_CoveredOutlet_Item {set;get;}
    public List<ASI_CRM_CN_Covered_Outlet__c> Saved_CoveredOutlet_Temp {set;get;}
    public List<ASI_CRM_SpecialPromotionTypeSetting__c> LSpecicalPromotionType {set; get;} 
    public Integer indexCoveredOutlet {set;get;}
    public Integer rowidCoveredOutlet {set;get;}
    public Set<id> Selecteddd {set;get;}
    public static double totalEstimate = 0;

    public class totalinnerCls {
        public Decimal volumes {set; get;}
        public Decimal fixedAmount {set; get;}
        public Decimal promotionAmount {set; get;}
        public Decimal gs {set; get;}
        public Decimal gsPercent {set; get;}
        public Decimal cm {set; get;}

        public totalinnerCls() {
            volumes = 0;
            fixedAmount = 0;
            promotionAmount = 0;
            gs = 0;
            gsPercent = 0;
            cm = 0;
        }
    }

    public ASI_CRM_CN_TP_PoDetail_Ctrl(ApexPages.StandardController controller) {

        pendingPR = false;
        this.ContractSelected = (ASI_TH_CRM_Contract__c )controller.getRecord();
        if (this.ContractSelected != null)
            PageId = ContractSelected.id;
        system.debug('PageId: ' + PageId );

        orgFiscalMonth = [SELECT FiscalYearStartMonth FROM Organization].FiscalYearStartMonth;

        init();

        getPlanItems();
        checkSpecialPromotionObj();
    }



    public void getPlanItems() {
        totalPlanEstAmount = 0;
        totalPlanFixedAmount = 0;
        totalPlanEstVol = 0;

        planLineItemList = [select ASI_MFM_Sub_brand_Code__r.Name,
                            ASI_CRM_CN_TP_Estimated_Amount__c,
                            ASI_CRM_CN_TP_Bottle_Size__c,
                            ASI_MFM_Plan__c,
                            ASI_MFM_Plan__r.Name,
                            ASI_MFM_Plan__r.ASI_CRM_CN_TP_Activity_NO__c,
                            ASI_CRM_CN_TP_Fixed_Cost__c,
                            ASI_CRM_CN_TP_Estimated_Qty__c,
                            ASI_CRM_CN_TP_VolumesIn9L__c
                            from ASI_MFM_Plan_Line_Item__c
                            where ASI_MFM_Plan__r.ASI_CRM_CN_TP_Contract__c = :ContractSelected.Id
                                    and (ASI_CRM_CN_TP_Estimated_Amount__c > 0
                                         or ASI_CRM_CN_TP_Fixed_Cost__c > 0)
                                    order by ASI_MFM_Plan__r.ASI_CRM_CN_TP_Activity_NO__c desc];
        for (ASI_MFM_Plan_Line_Item__c item : planLineItemList) {
            totalPlanEstAmount += item.ASI_CRM_CN_TP_Estimated_Amount__c == null ? 0 : item.ASI_CRM_CN_TP_Estimated_Amount__c;
            totalPlanFixedAmount += item.ASI_CRM_CN_TP_Fixed_Cost__c == null ? 0 : item.ASI_CRM_CN_TP_Fixed_Cost__c;
            totalPlanEstVol += item.ASI_CRM_CN_TP_Estimated_Qty__c == null ? 0 : item.ASI_CRM_CN_TP_Estimated_Qty__c;
        }
        totalPlanEstAmount.setScale(2);
        totalPlanFixedAmount.setScale(2);
        totalPlanEstVol.setScale(2);
    }

    

    public ASI_CRM_CN_TotalAmount getTotalAmount() {

        ASI_CRM_CN_TotalAmount totalAmount = new ASI_CRM_CN_TotalAmount();

        totalAmount.totalSuggestedAmount = 0;
        totalAmount.totalTargetVolume = 0;

        if (ContractOutletList != null && ContractOutletList.size() > 0) {
            for (ASI_CRM_CN_Covered_Outlet__c obj : ContractOutletList) {
                if (obj.ASI_CRM_CN_Suggested_Amount__c != null) totalAmount.totalSuggestedAmount += obj.ASI_CRM_CN_Suggested_Amount__c;
                if (obj.ASI_CRM_CN_Target_Volume_Std_Btl__c != null) totalAmount.totalTargetVolume += obj.ASI_CRM_CN_Target_Volume_Std_Btl__c;
            }
        }

        return totalAmount;
    }

    public class ASI_CRM_CN_TotalAmount {
        public decimal totalSuggestedAmount { get; set; }
        public decimal totalTargetVolume { get; set; }
    }

    public PageReference addPlans() {
        PageReference pageRef = new PageReference('/apex/ASI_CRM_CN_TP_PO_Add_TP_Page?scontrolCaching=1&id='+PageId);
        pageRef.setRedirect(True);
        return pageRef;
    }

    public PageReference GoReturn(){
        if(ContractSelected != null)
        {
            if(ContractSelected.ASI_CRM_CN_Status__c != 'Submitted'){ 
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, Label.ASI_CRM_CN_TP_POReturnCheck));
            } 
            else{
                List<ASI_TH_CRM_Contract__c> LContract = [Select ASI_CRM_CN_Return_Comments__c from ASI_TH_CRM_Contract__c where id=:PageId LIMIT 1]; 
                if(LContract[0].ASI_CRM_CN_Return_Comments__c != ''){
                    try{
                        LContract[0].ASI_CRM_CN_Return_Comments__c = '';
                        update LContract[0];
                    }catch(DmlException e){
                        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, e.getMessage()));
                    }
                }
                PageReference pageRef = new PageReference('/apex/ASI_CRM_CN_ReturnContractByBAPage?scontrolCaching=1&id='+PageId);
                pageRef.setRedirect(True);
                return pageRef;
            }
        }
        
        return null;
    }

    public void init() {
        needChannelnProvince = FALSE;
        paymentError = false;
        showApprovalButton = true;
        showPOModification = false;
        showShuttle = true;
        showRestorePO  = false;
        showEdit = true;
        makePayment = true;
        isCreate = false;
        isCNCRM = true;
        inBAPermissionSet = false;
        businessLicense = false;
        UserId = UserInfo.getUserId();
        // isPOModi = ContractSelected.ASI_CRM_CN_PO_Version__c != '0.0';

        // checkUserID();
        if ([SELECT Assignee.Name, PermissionSet.name
                FROM PermissionSetAssignment where permissionSet.name = 'ASI_CRM_CN_General_BA' and Assigneeid = :Userinfo.getUserid()].size() > 0) {
            inBAPermissionSet = true;
        }
        if (PageId != null) {
            LContract = [SELECT Name, ASI_CRM_CN_Total_Contract_Amount__c , ASI_CRM_CN_Vol_Budget_LE__c, ASI_CRM_CN_Status__c, ASI_CRM_CN_Source_of_Contract__c, ASI_CRM_CN_Source_Others__c,
                         ASI_CRM_CN_Reason_without_Budget__c, ASI_TH_CRM_Promotion_Type__c, ASI_CRM_CN_PP_No__c, ASI_CRM_CN_PO_Version__c,
                         ASI_CRM_CN_PO_Start_Date__c, ASI_CRM_CN_PO_No__c, ASI_CRM_CN_PO_End_Date__c, ASI_CRM_CN_Outlet_WS__c,
                         ASI_CRM_CN_Exchange_Rate__c, ASI_CRM_CN_Expected_BRSF_Est_Total__c , ASI_CRM_Investment_Type__c, ASI_CRM_Martell_BC_Rate__c,
                         ASI_CRM_CN_Description__c, ASI_CRM_CN_Currency__c, ASI_CRM_CN_Budget_LE__c, ASI_CRM_CN_Bottle_Collection_Rate__c, ASI_CRM_CN_Effective_Date__c,
                         recordtypeid, ASI_CRM_CN_No_of_Months__c , ASI_CRM_CN_PO_Modification__c , ASI_CRM_CN_Special_Promotion__c, ASI_CRM_CN_Contract_Upload__c,
                         ASI_CRM_CN_Last_PO_version__c, ASI_CRM_CN_National_Group_Contract__c, ASI_CRM_CN_Business_License__c, createddate,
                         ASI_CRM_CN_Outlet_WS__r.RecordType.DeveloperName, ASI_CRM_Volume_Option__c, lastModifiedDate,
                         ASI_CRM_New_FY_PO__c, ASI_CRM_PO_Channel__c, ASI_CRM_PO_Province__c,
                         ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_NewChannel__r.Name,
                         ASI_CRM_PO_City__c, ASI_CRM_PO_City__r.Name,
                         ASI_CRM_National_Group__c, ASI_CRM_CN_Last_PO_version__r.ASI_CRM_National_Group__c,
                         ASI_CRM_National_Group__r.Name, ASI_CRM_CN_Last_PO_version__r.ASI_CRM_National_Group__r.Name,
                         ASI_CRM_NationalGroup__c, ASI_CRM_CN_Last_PO_version__r.ASI_CRM_NationalGroup__c,
                         ASI_CRM_NationalGroup__r.Name, ASI_CRM_CN_Last_PO_version__r.ASI_CRM_NationalGroup__r.Name,
                         ASI_CRM_NationalGroup__r.ASI_CRM_Apply_National_Approval__c, ASI_CRM_NationalGroup__r.ASI_CRM_National_Group__c,
                         ASI_CRM_CN_Last_Submitted_Date__c, ASI_CRM_CN_Last_Rejected_Date__c,
                         (Select Id, Name, ASI_CRM_CN_Last_Payment__c, ASI_TH_CRM_Contract__c, ASI_CRM_CN_PO_Version__c,
                          ASI_CRM_CN_PO_Start_Date__c, ASI_CRM_CN_PO_End_Date__c, ASI_TH_CRM_Status__c, ASI_CRM_CN_Channel__c,
                          ASI_CRM_CN_Total_Payment__c, ASI_CRM_CN_Paid__c, ASI_CRM_CN_Paid_In_Progress__c, ASI_CRM_CN_Payment_Raised_Date__c
                          From ASI_TH_CRM_PaymentRequests_Contract__r)
                         FROM ASI_TH_CRM_Contract__c
                         WHERE id = :pageId FOR UPDATE];
            system.debug('LContract: ' + LContract );

            if (LContract != null && LContract.size() > 0) {

                this.ContractSelected = LContract[0];

                Integer PendingPaymentNo = 0;
                Integer FinalPaymentNo = 0;
                for (ASI_th_crm_paymentrequest__c p : ContractSelected.ASI_TH_CRM_PaymentRequests_Contract__r) {
                    if (p.ASI_TH_CRM_Status__c == 'Draft' || p.ASI_TH_CRM_Status__c == 'Submitted')
                        PendingPaymentNo += 1;
                    if (p.ASI_CRM_CN_Last_Payment__c && p.ASI_TH_CRM_Status__c == 'Approved')
                        FinalPaymentNo += 1;
                    if (p.ASI_TH_CRM_Status__c == 'Submitted') pendingPR = true;
                }


                if (LContract[0].recordtypeid != Global_RecordTypeCache.getRtId('ASI_TH_CRM_Contract__cASI_CRM_CN_Contract')) {
                    isCNCRM = false;
                } else {
                    if (ContractSelected.ASI_CRM_CN_Status__c == 'Draft' && ContractSelected.ASI_CRM_CN_Last_PO_version__c != null) {
                        showEdit = true;
                        showRestorePO = true;
                        showApprovalButton = true;
                        makePayment = false;
                        showPOModification = false;
                        showShuttle = false;
                        contractUpload = true;
                        businessLicense = true;

                    } else if (ContractSelected.ASI_CRM_CN_Status__c == 'Draft' && ContractSelected.ASI_CRM_CN_Last_PO_version__c == null) {
                        showEdit = true;
                        showRestorePO = false;
                        showShuttle = true;
                        showPOModification = false;
                        showApprovalButton = true;
                        makePayment = false;
                        contractUpload = true;
                        businessLicense = true;
                    } else if (ContractSelected.ASI_CRM_CN_Status__c == 'Final') {
                        showPOModification = true;
                        showApprovalButton = false;
                        showShuttle = false;
                        if ( ContractSelected.ASI_CRM_CN_PO_Version__c == '0.0') {  showShuttle = true; }

                        makePayment = true;
                        showEdit = false;
                        showRestorePO = false;
                        contractUpload = true;
                        businessLicense  = true;
                    } else if (ContractSelected.ASI_CRM_CN_Status__c == 'Archived' || ContractSelected.ASI_CRM_CN_Status__c == 'Submitted') {
                        showEdit = false;
                        showApprovalButton = false;
                        makePayment = false;
                        showShuttle = false;
                        if ( ContractSelected.ASI_CRM_CN_PO_Version__c == '0.0') { showShuttle = true; }
                        showRestorePO = false;
                        showPOModification = false;
                        businessLicense = false;
                    }
                }

                if (ContractSelected.ASI_CRM_CN_PO_Modification__c == true) {
                    try {
                        paymentRequestSummary = ASI_CRM_CN_PaymentRequestUtilCls.genPaymentSummary(null, ContractSelected);
                    } catch (exception e) {
                        system.debug('Try paymentRequestSummary failed: ' + e);
                        paymentRequestSummary = new list<ASI_CRM_CN_PaymentRequestUtilCls.PaymentSummary>();
                    }
                    
                } else {
                    paymentRequestSummary = new list<ASI_CRM_CN_PaymentRequestUtilCls.PaymentSummary>();
                }
            }

            LBRSF = [SELECT id, ASI_CRM_CN_Contract__c, ASI_CRM_CN_Sub_Brand__r.Name, ASI_CRM_CN_Contract_BRSF_Per_Bottle__c, ASI_CRM_CN_Contract_Monthly_Qty__c,
                     ASI_CRM_CN_Contract_Total__c, ASI_CRM_CN_Est_BRSF_Per_Bottle__c, ASI_CRM_CN_Est_Monthly_Qty__c,
                     ASI_CRM_CN_Est_Total__c, ASI_CRM_CN_Sub_Brand__c,
                     ASI_CRM_CN_Contract_Total_Dummy__c, ASI_CRM_CN_Est_Total_Dummy__c,
                     ASI_CRM_CN_No_of_Months__c, ASI_CRM_CN_Activity_Code__c,
                     ASI_CRM_CN_TP_Promotion_Cost__c,
                     ASI_CRM_CN_TP_Fixed_Cost__c,
                     ASI_CRM_CN_Total_Volume_9L__c,
                     ASI_CRM_CN_TP_GS_Amount__c,
                     ASI_CRM_CN_TP_CM_Amount__c,
                     ASI_CRM_CN_TP_GS_Percent__c
                     FROM ASI_CRM_CN_Contract_BRSF_Line_Item__c
                     WHERE ASI_CRM_CN_Contract__c = :PageId];
            if (LBRSF != null && LBRSF.size() > 0) {


                totalBRSF_est_total = 0;
                totalBRSF_contract_total = 0;
                totalBRSF = new ASI_CRM_CN_Contract_BRSF_Line_Item__c(ASI_CRM_CN_Est_Monthly_Qty__c = 0, ASI_CRM_CN_Contract_Monthly_Qty__c = 0,
                        ASI_CRM_CN_Est_BRSF_Per_Bottle__c = 0, ASI_CRM_CN_Contract_BRSF_Per_Bottle__c = 0, ASI_CRM_CN_Est_Total_Dummy__c = 0, ASI_CRM_CN_Contract_Total_Dummy__c = 0);

                totalBRSF2 = new totalinnerCls();
                LBRSFDisplay = new List<ASI_CRM_CN_Contract_BRSF_Line_Item__c>();
                for (ASI_CRM_CN_Contract_BRSF_Line_Item__c c : LBRSF) {
                    if(c.ASI_CRM_CN_Est_Total_Dummy__c != null) {
                        totalEstimate += c.ASI_CRM_CN_Est_Total_Dummy__c;
                    }
                    if (c.ASI_CRM_CN_TP_Promotion_Cost__c <= 0 && c.ASI_CRM_CN_TP_Fixed_Cost__c <= 0) {
                        continue;
                    }
                    if (c.ASI_CRM_CN_Total_Volume_9L__c != null) {
                        totalBRSF2.volumes += c.ASI_CRM_CN_Total_Volume_9L__c;
                    }
                    if (c.ASI_CRM_CN_TP_GS_Amount__c != null) {
                        totalBRSF2.gs += c.ASI_CRM_CN_TP_GS_Amount__c;
                    }
                    // if(c.ASI_CRM_CN_TP_GS_Percent__c != null){
                    //     totalBRSF2.gsPercent += c.ASI_CRM_CN_TP_GS_Percent__c;
                    // }
                    if (c.ASI_CRM_CN_TP_CM_Amount__c != null) {
                        totalBRSF2.cm += c.ASI_CRM_CN_TP_CM_Amount__c;
                    }
                    if (c.ASI_CRM_CN_TP_Promotion_Cost__c != null) {
                        totalBRSF2.promotionAmount += c.ASI_CRM_CN_TP_Promotion_Cost__c;
                    }
                    if (c.ASI_CRM_CN_TP_Fixed_Cost__c != null) {
                        totalBRSF2.fixedAmount += c.ASI_CRM_CN_TP_Fixed_Cost__c;
                    }

                    if (c.ASI_CRM_CN_Est_Monthly_Qty__c != null) {
                        totalBRSF.ASI_CRM_CN_Est_Monthly_Qty__c += c.ASI_CRM_CN_Est_Monthly_Qty__c;
                    }
                    if (c.ASI_CRM_CN_Contract_Monthly_Qty__c != null) {
                        totalBRSF.ASI_CRM_CN_Contract_Monthly_Qty__c += c.ASI_CRM_CN_Contract_Monthly_Qty__c;
                    }
                    if (c.ASI_CRM_CN_Est_BRSF_Per_Bottle__c != null) {
                        totalBRSF.ASI_CRM_CN_Est_BRSF_Per_Bottle__c += c.ASI_CRM_CN_Est_BRSF_Per_Bottle__c;
                    }
                    if (c.ASI_CRM_CN_Contract_BRSF_Per_Bottle__c != null) {
                        totalBRSF.ASI_CRM_CN_Contract_BRSF_Per_Bottle__c += c.ASI_CRM_CN_Contract_BRSF_Per_Bottle__c;
                    }
                    if (c.ASI_CRM_CN_Est_Total_Dummy__c != null) {
                        totalBRSF.ASI_CRM_CN_Est_Total_Dummy__c += c.ASI_CRM_CN_Est_Total_Dummy__c;
                    }
                    if (c.ASI_CRM_CN_Contract_Total_Dummy__c != null) {
                        totalBRSF.ASI_CRM_CN_Contract_Total_Dummy__c += c.ASI_CRM_CN_Contract_Total_Dummy__c;
                    }
                    if (c.ASI_CRM_CN_Est_Total__c != null) {
                        totalBRSF_est_total += c.ASI_CRM_CN_Est_Total__c;
                    }
                    if (c.ASI_CRM_CN_Contract_Total__c != null) {
                        totalBRSF_contract_total += c.ASI_CRM_CN_Contract_Total__c;
                    }

                    LBRSFDisplay.add(c);
                }
                totalBRSF2.gsPercent = totalBRSF2.gs != 0 ? totalBRSF2.promotionAmount / totalBRSF2.gs : 0;

                if (LBRSFDisplay.size() > 0) {


                }
            }
            Total_Payments_Amount = 0;
            Total_Payment_Paid = 0;
            Total_Payment_PaidInProgress = 0;
            PaymentRequestList = ContractSelected.ASI_TH_CRM_PaymentRequests_Contract__r;

            if (PaymentRequestList != null && PaymentRequestList.size() > 0)
                for (ASI_TH_CRM_PaymentRequest__c payment_req : PaymentRequestList) {
                    if ( payment_req.ASI_CRM_CN_Total_Payment__c != null && payment_req.ASI_TH_CRM_Status__c != 'Draft') {
                        Total_Payments_Amount += payment_req.ASI_CRM_CN_Total_Payment__c;
                    }
                    if (payment_req.ASI_CRM_CN_Total_Payment__c != null) {
                        Total_Payment_Paid += payment_req.ASI_CRM_CN_Total_Payment__c;
                    }
                    if (payment_req.ASI_CRM_CN_Paid_In_Progress__c != null) {
                        Total_Payment_PaidInProgress += payment_req.ASI_CRM_CN_Paid_In_Progress__c;
                    }

                }
            ContractOutletList = [SELECT id, ASI_CRM_CN_Contract__c, ASI_CRM_CN_Suggested_Amount__c, ASI_CRM_CN_Target_Volume_Std_Btl__c, ASI_CRM_CN_Outlet__c, ASI_CRM_CN_Outlet__r.ASI_CRM_Account__c, ASI_CRM_CN_Allocated_Amount__c, ASI_CRM_CN_Check_All__c, ASI_CRM_CN_Selected_Covered_Outlet__c FROM ASI_CRM_CN_Covered_Outlet__c
                                          WHERE ASI_CRM_CN_Contract__c = :PageId];
            LFixCost = new List<ASI_CRM_Contract_Cost__c> ();
            LVariableCost = new List<ASI_CRM_Contract_Cost__c> ();


            festivalMap = new Map<String, Boolean>();
            Map<String, Boolean> tmpMap = new Map<String, Boolean>();
            List<ASI_CRM_Contract_Cost_Setting__c> ccs = new List<ASI_CRM_Contract_Cost_Setting__c>([SELECT id, ASI_CRM_CN_Promotion_Type__c, ASI_CRM_Festival_Season__c, ASI_CRM_CN_Activity_Code__c FROM ASI_CRM_Contract_Cost_Setting__c WHERE RecordType.DeveloperName = 'ASI_CRM_CN_Contract_Cost_Setting']);

            for (ASI_CRM_Contract_Cost_Setting__c obj : ccs) {
                tmpMap.put('' + obj.ASI_CRM_CN_Promotion_Type__c + obj.ASI_CRM_CN_Activity_Code__c, obj.ASI_CRM_Festival_Season__c);
            }

            List<ASI_CRM_Contract_Cost__c> LContractCost = [Select id, name, ASI_CRM_CNY_Est__c, ASI_CRM_MAF_Est__c, ASI_CRM_Other_Est__c, ASI_CRM_CN_Activity_Code__c, ASI_CRM_CN_Chinese_Description__c, ASI_CRM_CN_Contract__c, ASI_CRM_CN_Contract_Amount__c, ASI_CRM_CN_Estimate_Amount__c,
                                           ASI_CRM_CN_Cost_Type__c, ASI_CRM_CN_Sequence__c, ASI_CRM_CN_Contract__r.ASI_TH_CRM_Promotion_Type__c from ASI_CRM_Contract_Cost__c where ASI_CRM_CN_Contract__c = :PageId and (ASI_CRM_CN_Cost_Type__c = 'Fixed' or ASI_CRM_CN_Cost_Type__c = 'Variable')
                                                   order by ASI_CRM_CN_Sequence__c ASC, ASI_CRM_CN_Activity_Code__r.ASI_CRM_Promotion_Type__r.ASI_CRM_Sequence__c ASC];

            if (LContractCost != null && LContractCost.size() > 0)
                for (ASI_CRM_Contract_Cost__c cc : LContractCost) {
                    if (cc.ASI_CRM_CN_Cost_Type__c == 'Fixed') {
                        LFixCost.add(cc);
                    } else if (cc.ASI_CRM_CN_Cost_Type__c == 'Variable') {
                        LVariableCost.add(cc);
                    }
                    if (tmpMap.containsKey(cc.ASI_CRM_CN_Contract__r.ASI_TH_CRM_Promotion_Type__c + '' + cc.ASI_CRM_CN_Activity_Code__c)) {
                        festivalMap.put(cc.id, tmpMap.get(cc.ASI_CRM_CN_Contract__r.ASI_TH_CRM_Promotion_Type__c + '' + cc.ASI_CRM_CN_Activity_Code__c));
                    } else {
                        festivalMap.put(cc.id, FALSE);
                    }
                }

            if (LFixCost != null && LFixCost.size() > 0) {
                fix_totalCost = new ASI_CRM_Contract_Cost__c(name = 'Fixed Cost Total:', ASI_CRM_MAF_Est__c = 0, ASI_CRM_CNY_Est__c = 0, ASI_CRM_Other_Est__c = 0, ASI_CRM_CN_Estimate_Amount__c = 0, ASI_CRM_CN_Contract_Amount__c = 0, ASI_CRM_CN_Sequence__c = 99999999);
                LFixCostDisplay = new List<ASI_CRM_Contract_Cost__c>();
                for (ASI_CRM_Contract_Cost__c c : LFixCost) {
                    if (c.ASI_CRM_CN_Estimate_Amount__c != null) {
                        fix_totalCost.ASI_CRM_CN_Estimate_Amount__c += c.ASI_CRM_CN_Estimate_Amount__c;
                    }
                    if (c.ASI_CRM_CN_Contract_Amount__c != null) {
                        fix_totalCost.ASI_CRM_CN_Contract_Amount__c += c.ASI_CRM_CN_Contract_Amount__c;
                    }

                    if (festivalMap.containsKey(c.id) && festivalMap.get(c.id) && c.ASI_CRM_MAF_Est__c != null) {
                        fix_totalCost.ASI_CRM_MAF_Est__c += c.ASI_CRM_MAF_Est__c;
                    }
                    if (festivalMap.containsKey(c.id) && festivalMap.get(c.id) && c.ASI_CRM_CNY_Est__c != null) {
                        fix_totalCost.ASI_CRM_CNY_Est__c += c.ASI_CRM_CNY_Est__c;
                    }
                    if (festivalMap.containsKey(c.id) && festivalMap.get(c.id) && c.ASI_CRM_Other_Est__c != null) {
                        fix_totalCost.ASI_CRM_Other_Est__c += c.ASI_CRM_Other_Est__c;
                    }

                    LFixCostDisplay.add(c);
                }
                if (LFixCostDisplay.size() > 0) {

                }
            }

            if (LVariableCost != null && LVariableCost.size() > 0) {
                variable_totalCost = new ASI_CRM_Contract_Cost__c(name = 'Other Variable Cost Total', ASI_CRM_MAF_Est__c = 0, ASI_CRM_CNY_Est__c = 0, ASI_CRM_Other_Est__c = 0, ASI_CRM_CN_Estimate_Amount__c = 0, ASI_CRM_CN_Contract_Amount__c = 0, ASI_CRM_CN_Sequence__c = 99999999);
                LVariableCostDisplay = new List<ASI_CRM_Contract_Cost__c>();
                for (ASI_CRM_Contract_Cost__c c : LVariableCost) {
                    if (c.ASI_CRM_CN_Estimate_Amount__c != null) {
                        variable_totalCost.ASI_CRM_CN_Estimate_Amount__c += c.ASI_CRM_CN_Estimate_Amount__c;
                    }
                    if (c.ASI_CRM_CN_Contract_Amount__c != null) {
                        variable_totalCost.ASI_CRM_CN_Contract_Amount__c += c.ASI_CRM_CN_Contract_Amount__c;
                    }

                    if (c.ASI_CRM_MAF_Est__c != null) {
                        variable_totalCost.ASI_CRM_MAF_Est__c += c.ASI_CRM_MAF_Est__c;
                    }
                    if (c.ASI_CRM_CNY_Est__c != null) {
                        variable_totalCost.ASI_CRM_CNY_Est__c += c.ASI_CRM_CNY_Est__c;
                    }
                    if (c.ASI_CRM_Other_Est__c != null) {
                        variable_totalCost.ASI_CRM_Other_Est__c += c.ASI_CRM_Other_Est__c;
                    }

                    LVariableCostDisplay.add(c);
                }
                if (LVariableCostDisplay.size() > 0) {

                }
            }


            if (LBRSF != null && LBRSF.size() > 0) {
                for (ASI_CRM_CN_Contract_BRSF_Line_Item__c brsf : LBRSF) {

                    if (brsf.ASI_CRM_CN_Est_Monthly_Qty__c != null && brsf.ASI_CRM_CN_Est_BRSF_Per_Bottle__c != null)
                        brsf.ASI_CRM_CN_Est_Total_Dummy__c = brsf.ASI_CRM_CN_Est_Monthly_Qty__c * brsf.ASI_CRM_CN_Est_BRSF_Per_Bottle__c * ContractSelected.ASI_CRM_CN_No_of_Months__c;

                    if (brsf.ASI_CRM_CN_Contract_Monthly_Qty__c != null && brsf.ASI_CRM_CN_Contract_BRSF_Per_Bottle__c != null)
                        brsf.ASI_CRM_CN_Contract_Total_Dummy__c = brsf.ASI_CRM_CN_Contract_Monthly_Qty__c * brsf.ASI_CRM_CN_Contract_BRSF_Per_Bottle__c * ContractSelected.ASI_CRM_CN_No_of_Months__c;
                }
            }

            if (inBAPermissionSet == true) {
                if (ContractSelected.ASI_CRM_CN_Status__c == 'Submitted')
                    showReturn = true;
                else
                    showReturn = false;
            }

        }

        CoveredOutlet_Item_Map = new Map<Integer, ASI_CRM_CN_Covered_Outlet__c >();
        indexCoveredOutlet = 0;

        if(ContractOutletList != null && ContractOutletList.size()>0){
            for (ASI_CRM_CN_Covered_Outlet__c  outlet :ContractOutletList){
                CoveredOutlet_Item_Map.put(indexCoveredOutlet++, outlet);
            }
        }
    }

    // Added by Jack Yuan BLS 20201210
    public void AddNew_CoveredOutlet(){
        ASI_CRM_CN_Covered_Outlet__c outlet = new ASI_CRM_CN_Covered_Outlet__c();
        CoveredOutlet_Item_Map.put(indexCoveredOutlet++, outlet );
        outlet.ASI_CRM_CN_Selected_Covered_Outlet__c = true;
    }

    public void Addall_CoveredOutlet(){
        ASI_CRM_CN_Covered_Outlet__c outlet = new ASI_CRM_CN_Covered_Outlet__c();
        Selecteddd = new Set<id>();
        Set<id> SChildCustomersIds = new Set<id>();
        
        //Updated by William Yang(Introv) 20141103 to reduce no. of SOQL
        //ASI_TH_CRM_Contract__c contract = [SELECT ASI_CRM_CN_Outlet_WS__r.RecordType.DeveloperName FROM ASI_TH_CRM_Contract__c where id = :PageId];
        String recordType = ContractSelected.ASI_CRM_CN_Outlet_WS__r.RecordType.DeveloperName;
        Integer limitRecord = 0;
    
        if(recordType == 'ASI_CRM_Outlet_CN' || test.isRunningTest()){
            /*
            List <ASI_CRM_CN_Covered_Outlet__c> Selected = [Select ASI_CRM_CN_Outlet__r.Id From ASI_CRM_CN_Covered_Outlet__c Where ASI_CRM_CN_Contract__c=: PageId];
            */
            if (!ContractOutletList.isEmpty()) {
                List <ASI_CRM_CN_Covered_Outlet__c> Selected = ContractOutletList;
                for ( ASI_CRM_CN_Covered_Outlet__c s:Selected ){
                    Selecteddd.add(s.ASI_CRM_CN_Outlet__r.Id);
                }
            }
            
   
            List<ASI_CRM_AccountsAdditionalField__c> childCustomers = [SELECT Id FROM ASI_CRM_AccountsAdditionalField__c where ASI_CRM_CN_Parent_Outlet__c = :ContractSelected.ASI_CRM_CN_Outlet_WS__c AND Id NOT IN :Selecteddd  limit 200];
    
            if(childCustomers!= null && childCustomers.size() > 0) {          
                for(ASI_CRM_AccountsAdditionalField__c customer : childCustomers){ 
                    if(limitRecord < 200){                 
                        outlet = new ASI_CRM_CN_Covered_Outlet__c(ASI_CRM_CN_Outlet__c = customer.id);
                        outlet.ASI_CRM_CN_Selected_Covered_Outlet__c = true;
                        SChildCustomersIds.add(customer.Id);
                        CoveredOutlet_Item_Map.put(indexCoveredOutlet++,outlet);
                        limitRecord++;  
                    }  
                    else
                        break;
                }
            }  
                      
            if(SChildCustomersIds != null && SChildCustomersIds.size() > 0 && limitRecord < 200){
                List<ASI_CRM_AccountsAdditionalField__c> childChildCustomers = [SELECT Id, Name FROM ASI_CRM_AccountsAdditionalField__c where ASI_CRM_CN_Parent_Outlet__c IN :SChildCustomersIds limit 200];        
                if(childChildCustomers != null && childChildCustomers.size() > 0 ) {                                  
                    for(ASI_CRM_AccountsAdditionalField__c childCustomer : childChildCustomers){  
                        if(limitRecord < 200){               
                            outlet = new ASI_CRM_CN_Covered_Outlet__c(ASI_CRM_CN_Outlet__c = childcustomer.id);
                            outlet.ASI_CRM_CN_Selected_Covered_Outlet__c = true;
                            CoveredOutlet_Item_Map.put(indexCoveredOutlet++,outlet);
                            limitRecord++;  
                        }
                        else
                            break;
                    }
                }
            }
        }
    }
    //  Added by Jack Yuan BLS 20201211
    public void checkSpecialPromotionObj(){
    
        Map<String, Boolean> mapSpecialPromotion = new Map<String, Boolean>();
        
        if(LSpecicalPromotionType != null && LSpecicalPromotionType.size() > 0){
            for(ASI_CRM_SpecialPromotionTypeSetting__c obj : LSpecicalPromotionType)
                mapSpecialPromotion.put(obj.ASI_CRM_Promotion_Type__c, obj.ASI_CRM_SuggestedAmount_And_TargetVolume__c);
        }
        if(mapSpecialPromotion.get(ContractSelected.ASI_TH_CRM_Promotion_Type__c) != null)
            showSuggestedAmountAndTargetVolume = mapSpecialPromotion.get(ContractSelected.ASI_TH_CRM_Promotion_Type__c);
    }

    public PageReference redirectToPage(String pagePath, String pid) {
        paymentError = false;
        PageReference redirect = new PageReference(pagePath);
        redirect.getParameters().put('id', pid);
        redirect.setRedirect(true);
        return redirect;
    }

    public PageReference changeContractUpload() {
        contractSelected.ASI_CRM_CN_Contract_Upload__c = !contractSelected.ASI_CRM_CN_Contract_Upload__c;
        update contractSelected;
        return redirectToPage('/apex/ASI_CRM_CN_TP_PODetail', PageId);
    }

    public void GoEdit() {
        isShowEdit = true;
    }
    public PageReference UpdateRecord() {
        //---- save Covered Outlet Line Items - by leo (start) ----
        //---- updated by Stella Li      
        Save_CoveredOutlet_Item = new List<ASI_CRM_CN_Covered_Outlet__c>();
        Saved_CoveredOutlet_Temp = new List<ASI_CRM_CN_Covered_Outlet__c>();
         
        for (integer i : CoveredOutlet_Item_Map.keySet()) {
                ASI_CRM_CN_Covered_Outlet__c outlet = CoveredOutlet_Item_Map.get(i);
                if(outlet.ASI_CRM_CN_Contract__c == null){
                    outlet.ASI_CRM_CN_Contract__c = ContractSelected.Id;
                    outlet.RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_CN_Covered_Outlet__cASI_CRM_CN_Covered_Outlet');
                }
                if(outlet != null && outlet.ASI_CRM_CN_Selected_Covered_Outlet__c == true && outlet.ASI_CRM_CN_Outlet__c != null){
                    Save_CoveredOutlet_Item.add(outlet);            
                }  else if (outlet.id != null && outlet.ASI_CRM_CN_Selected_Covered_Outlet__c == false) { 
                    Saved_CoveredOutlet_Temp.add(outlet);            
                }
            
        }        

        if(Save_CoveredOutlet_Item != null && Save_CoveredOutlet_Item.size() > 0) {
            //20161028 Elufa
            
            Set<Id> effectiveChildsSet = new Set<Id>();
            Set<Id> invalidChilds = new Set<Id>();
            
            Boolean isAllCustomer = False;
            
            if(ContractSelected.ASI_CRM_CN_Outlet_WS__r.RecordType.DeveloperName == 'ASI_CRM_Outlet_CN'){//20170128 Elufa add validation for outlet
                
                isAllCustomer = ContractSelected.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_NewChannel__c != Null && ContractSelected.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_NewChannel__r.Name.toLowerCase().contains('all customer');
                
                if(!isAllCustomer){
                    for(ASI_CRM_AccountsAdditionalField__c obj : [SELECT id
                                                                  FROM ASI_CRM_AccountsAdditionalField__c
                                                                  WHERE ASI_CRM_CN_Parent_Outlet__c = : ContractSelected.ASI_CRM_CN_Outlet_WS__c
                                                                 ]){
                                                                     effectiveChildsSet.add(obj.id);
                                                                 }
                    
                    for(ASI_CRM_AccountsAdditionalField__c obj : [SELECT id
                                                                  FROM ASI_CRM_AccountsAdditionalField__c
                                                                  WHERE ASI_CRM_CN_Parent_Outlet__c IN : effectiveChildsSet
                                                                 ]){
                                                                     effectiveChildsSet.add(obj.id);
                                                                 }
                }
            }
            
            //20161028 End
            
            // Ben 2015-06-24 Start
            double totalSuggestedAmount = 0;
            for(ASI_CRM_CN_Covered_Outlet__c obj : Save_CoveredOutlet_Item) {
                
                if(obj.ASI_CRM_CN_Suggested_Amount__c != null){
                  totalSuggestedAmount += obj.ASI_CRM_CN_Suggested_Amount__c;
                }
                
                //20161028 Elufa
                if(!effectiveChildsSet.contains(obj.ASI_CRM_CN_Outlet__c)){
                    invalidChilds.add(obj.ASI_CRM_CN_Outlet__c);
                }
                //20161028 End
            }
            
            //20161028 Elufa
            if(invalidChilds.size() > 0 && !isAllCustomer){
                
                String errorMsg = ContractSelected.ASI_CRM_CN_Outlet_WS__r.RecordType.DeveloperName == 'ASI_CRM_CN_WS' ? 'This wholesaler is not effective supplier of below outlets and thus they can\'t be cover outlet : ' : 'This Outlet is not effective parent of below outlets and thus they can\'t be cover outlet : ';
                String errorMsgCN = ContractSelected.ASI_CRM_CN_Outlet_WS__r.RecordType.DeveloperName == 'ASI_CRM_CN_WS' ? '该经销商并非以下店家的有效供货商，因此不能被添加为覆盖店家 ： ' : '该母店家并非以下店家的有效供货商，因此不能被添加为覆盖店家 ： ';
                
                for(ASI_CRM_AccountsAdditionalField__c obj : [SELECT id
                                                              , Name
                                                              FROM ASI_CRM_AccountsAdditionalField__c
                                                              WHERE Id IN : invalidChilds
                                                             ]){
                                                                 errorMsg += obj.Name + ',';
                                                                 errorMsgCN += obj.Name + ',';
                                                             }
                
                errorMsg += ' If it is necessary to be covered, Please contact Admin';
                errorMsgCN += ContractSelected.ASI_CRM_CN_Outlet_WS__r.RecordType.DeveloperName == 'ASI_CRM_CN_WS' ? ' 若此覆盖店家与供货商暂无展开合作，但确认需加入，请和Admin联系' : ' 如确认需加入，请和Admin联系';
                
                
                if(USerInfo.getLanguage()=='zh_CN')
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, errorMsgCN));
                else
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, errorMsg));
                
                Return Null;
            }
            //20161028 End
            
            Map<String, Boolean> mapSpecialPromotion = new Map<String, Boolean>();
        
          if(LSpecicalPromotionType != null && LSpecicalPromotionType.size() > 0){
              for(ASI_CRM_SpecialPromotionTypeSetting__c obj : LSpecicalPromotionType)
                  mapSpecialPromotion.put(obj.ASI_CRM_Promotion_Type__c, obj.ASI_CRM_Validate_TotalSuggestedAmount__c);
          }
            
            if(mapSpecialPromotion.containsKey(ContractSelected.ASI_TH_CRM_Promotion_Type__c) && mapSpecialPromotion.get(ContractSelected.ASI_TH_CRM_Promotion_Type__c) && totalEstimate != totalSuggestedAmount){
                Apexpages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR,'Total suggested amount should equal to total PO est. amount.'));
                return null;
            }
            // Ben 2015-06-24 End
                
            try{        
                upsert Save_CoveredOutlet_Item;
            }   catch (DmlException ex) {
                system.debug('Duplication');
                ApexPages.addMessages(ex);
                return null;
            }
        }   
        if (Saved_CoveredOutlet_Temp!= null && Saved_CoveredOutlet_Temp.size() > 0) {
            try{    
                delete Saved_CoveredOutlet_Temp;    
            }  catch (DmlException ex) {
                system.debug('Duplication');
                ApexPages.addMessages(ex);
                return null;
            }
        }   
        
        //---- save Covered Outlet Line Items - by leo (end) ----
        update this.ContractSelected;
        isShowEdit = false;
        return new PageReference('/' + this.contractSelected.Id);
    }
    
    public PageReference doCancel(){
        return new PageReference('/' + this.contractSelected.Id);
    }

    public PageReference submitApproval() {
        Boolean validByACCode = true;
        if (paymentRequestSummary != null && paymentRequestSummary.size() > 0)
            for (ASI_CRM_CN_PaymentRequestUtilCls.PaymentSummary p : paymentRequestSummary)
                if (p.POEstimateAmt.setScale(2) < p.PaidAmt.setScale(2)) {
                    validByACCode = false;
                    break;
                }
        if (!validByACCode) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.ASI_CRM_CN_ContractAmountByACCheckErrMsg));
            return null;
        }

        if (contractSelected != null && Total_Payments_Amount != null && contractSelected.ASI_CRM_CN_Total_Contract_Amount__c < (Total_Payments_Amount - 0.1) && contractSelected.ASI_CRM_CN_PO_Version__c != '0.0') {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.ASI_CRM_CN_ContractTotalAmountCheckErrMsg));
            return null;
        }


        if (contractSelected.ASI_CRM_CN_PO_Start_Date__c != Null && getFiscalYearStart(date.today()) > getFiscalYearStart(contractSelected.ASI_CRM_CN_PO_Start_Date__c) && contractSelected.ASI_CRM_CN_Last_Rejected_Date__c == Null && contractSelected.ASI_CRM_CN_PO_Version__c == '0.0') {

            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.ASI_CRM_CN_TP_PODetail_Error));
            return null;
        }

        if (contractSelected.ASI_CRM_CN_PO_Start_Date__c != null) {
            System.debug(contractSelected.ASI_CRM_CN_PO_Start_Date__c + '/' + getFiscalYearStart(system.today()).addYears(1));
            if (contractSelected.ASI_CRM_CN_PO_Start_Date__c < getFiscalYearStart(system.today()).addYears(1)) {
                contractSelected.ASI_CRM_CN_Effective_Date__c = getFiscalYearStart(System.today());
            } else {
                contractSelected.ASI_CRM_CN_Effective_Date__c = getFiscalYearStart(contractSelected.ASI_CRM_CN_PO_Start_Date__c);
            }
        } else {
            contractSelected.ASI_CRM_CN_Effective_Date__c = getFiscalYearStart(System.today());
        }

        update contractSelected;
        return new PageReference('/apex/ASI_CN_SubmitApprovalPage?id=' + PageId);
    }



    public date getFiscalYearStart(Date inputDate) {

        Date fiscalYearStart;
        if (inputDate != null) {
            fiscalYearStart = Date.newinstance(inputDate.year(), orgFiscalMonth, 1);
            if (inputDate.month() < orgFiscalMonth && inputDate.year() == inputDate.year())
                fiscalYearStart = fiscalYearStart.addYears(-1);
        }
        System.debug(inputDate + '/' + fiscalYearStart);
        return fiscalYearStart;
    }

}