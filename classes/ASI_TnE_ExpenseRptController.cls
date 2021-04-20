/*********************************************************************************
 * Name:ASI_TnE_ExpenseRptController
 * Description: Component Controller for TnE Expense Report
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 3/3/2015         Laputa: Hank            Created
 * 25/07/2016       Laputa: Hugo Cheung     Update. Change ASI_TnE_Payment_Amount__c to ASI_TnE_TW_Payment_Amount__c
 * 15/08/2016       Laputa: Hugo Cheung     Update. Change avg per receipt and avg per attendee to 2 decmial places
 * 09/11/2017       Introv: Linus           Update. Add a section to show the comment if over the budget (Only for MY)
 * 05/02/2018       Introv: Linus           Update. Add a record type KH
 * 21/03/2018       Introv: Linus           Update. Add G&H# for TW T&E
*********************************************************************************/
public without sharing class ASI_TnE_ExpenseRptController{
    public String currentHeaderId;
    public Boolean viewAllDetails{get;set;}
    public ASI_TnE_ClaimHeader__c header;
    public String currencyStr;
    private List<ASI_TnE_ClaimDetail__c> claimDetails {get;set;}     
    public List<accMapDetail> accMapDetails;
    public List<approvalDetail> approvalDetails;
    public budgetDetail budget;
    public Integer numOfApprovals{get;set;}
    public Integer numOfDetails;    
    public Decimal ttlAmount{get;set;}
    public Decimal ttlGSTAmt{get;set;}
    public Decimal ttlTaxableAmt{get;set;}
    public Decimal otherAdjust{get;set;}
    public Boolean isOverThreeMth;
    public Date startDate{get;set;}
    public Date endDate{get;set;}
    private Id approverId;
    private Boolean byPassApproverIdCheck;
    public ASI_TnE_ExpenseRptController(){
            
    }
    public void setcurrentHeaderId(String s){
        currentHeaderId = s;
    }
    public Date getStartDate(){
        if(startDate == null){
            getClaimDetails();
        }
        return startDate; 
    }
    
    public Date getEndDate(){
        if(endDate == null){
            getClaimDetails();
        }
        return endDate;
    } 
    
    public String getcurrentHeaderId() {
        return currentHeaderId;
    }
    public String getCurrencyStr(){
        if(currentHeaderId != null && (accMapDetails == null || accMapDetails.size() == 0)){
            getAccMapDetails();
        }
        return currencyStr;
    }
    public List<accMapDetail> getAccMapDetails(){
        if((accMapDetails == null || accMapDetails.size() == 0) && currentHeaderId != null){
            if(header == null){
                getHeader();
            }
            //String accMapRecordType = '';
            String clsRecordType = '';
            if(header.RecordType.Name.contains('TnE SG') || header.RecordType.Name == 'ASI TnE SG Claim Header Finance'){
                //accMapRecordType = 'ASI TnE SG Account Mapping'; 
                clsRecordType = 'ASI TnE SG Expense Classification';  
                //currencyStr = '[SGD]';
            }else if(header.RecordType.Name.contains('TnE KH') || header.RecordType.Name == 'ASI TnE KH Claim Header Finance'){        // Added by 2018-02-05 Linus@introv

                clsRecordType = 'ASI TnE KH Expense Classification'; 

            }else if(header.RecordType.Name.contains('TnE TH') || header.RecordType.Name == 'ASI TnE TH Claim Header Finance'){
                //accMapRecordType = 'ASI TnE TH Account Mapping';
                clsRecordType = 'ASI TnE TH Expense Classification'; 
                //currencyStr = '[THB]';
            }else if(header.RecordType.Name.contains('TnE PH') || header.RecordType.Name == 'ASI TnE PH Claim Header Finance'){
                //accMapRecordType = 'ASI TnE PH Account Mapping';
                clsRecordType = 'ASI TnE PH Expense Classification';
                //currencyStr = '[PHP]';
            }else if(header.RecordType.Name.contains('TnE MY') || header.RecordType.Name == 'ASI TnE MY Claim Header Finance'){
                //accMapRecordType = 'ASI TnE MY Account Mapping';
                clsRecordType = 'ASI TnE MY Expense Classification';
                //currencyStr = '[MYR]';
            }else if(header.RecordType.Name.contains('TnE HK') || header.RecordType.Name == 'ASI TnE HK Claim Header Finance'){
                //accMapRecordType = 'ASI TnE HK Account Mapping';
                clsRecordType = 'ASI TnE HK Expense Classification';
                //currencyStr = '[HKD]';
            }else if(header.RecordType.Name.contains('TnE ID') || header.RecordType.Name == 'ASI TnE ID Claim Header Finance'){
                //accMapRecordType = 'ASI TnE ID Account Mapping';
                clsRecordType = 'ASI TnE ID Expense Classification';
                //currencyStr = '[IDR]';
            }else if(header.RecordType.Name.contains('TnE TW')){
                //accMapRecordType = 'ASI TnE ID Account Mapping';
                clsRecordType = 'ASI TnE TW Expense Classification';
                currencyStr = '[TWD]';
            }
            currencyStr = header.ASI_TnE_Currency__c;
            accMapDetails = new List<accMapDetail>();
            //List<ASI_TnE_Account_Mapping__c> accMapList = [Select ASI_TnE_Account_Number__c, ASI_JP_TnE_Account_Name__c From ASI_TnE_Account_Mapping__c Where RecordType.Name = :accMapRecordType Order By ASI_TnE_Account_Number__c];
            List<ASI_JP_TnE_Expense_Classification__c> clsList = [Select Id, Name, ASI_JP_TnE_Expense_Category__r.Name, ASI_TnE_Other_Adjustment__c, ASI_JP_TnE_Account_Mapping__r.ASI_TnE_Account_Number__c From ASI_JP_TnE_Expense_Classification__c Order By ASI_JP_TnE_Account_Mapping__r.ASI_TnE_Account_Number__c];
            ttlAmount = 0;
            ttlGSTAmt = 0;
            ttlTaxableAmt = 0;
            otherAdjust = 0;
            if(claimDetails == null){
                getClaimDetails();
            }
            if(!header.RecordType.Name.contains('TnE HK') && header.ASI_TnE_Type__c == 'Cash Advance'){
                otherAdjust = (otherAdjust - header.ASI_TnE_Total_Amount_Approved__c).setScale(2);
                currencyStr = '[' + header.ASI_TnE_Currency__c + ']';
            }
            for(ASI_JP_TnE_Expense_Classification__c cls:clsList){
                accMapDetail detail = new accMapDetail();
                detail.detail = cls;
                Integer cnt = 0;
                decimal numOfAttendees = 0;
                if(header.RecordType.Name.contains('TnE MY') || header.RecordType.Name == 'ASI TnE MY Claim Header Finance'){
                    for(ASI_TnE_ClaimDetail__c d:claimDetails){
                        if(cls.Id == d.ASI_TnE_Expense_Classification__c){
                            detail.amount += ((d.ASI_TnE_HK_Payment_Amount__c == null)?0:d.ASI_TnE_HK_Payment_Amount__c);
                            detail.GSTAmt += ((d.ASI_TnE_MY_GST_Value__c == null)?0:d.ASI_TnE_MY_GST_Value__c);
                            detail.taxableAmt += ((d.ASI_TnE_Taxable_Amount_Display__c == null)?0:d.ASI_TnE_Taxable_Amount_Display__c);
                        }
                    }
                    accMapDetails.add(detail);
                    ttlAmount += detail.amount;
                    ttlGSTAmt += detail.GSTAmt;
                    ttlTaxableAmt += detail.taxableAmt;
                }else{
                    for(ASI_TnE_ClaimDetail__c d:claimDetails){
                        if(cls.Id == d.ASI_TnE_Expense_Classification__c){
                            if(!d.ASI_TnE_Dispute__c || !header.RecordType.Name.contains('TnE HK')){
                                if(header.RecordType.Name.contains('TnE TW')){
                                    detail.amount += ((d.ASI_TnE_TW_Payment_Amount__c == null)?0:d.ASI_TnE_TW_Payment_Amount__c);
                                }else{
                                    detail.amount += ((d.ASI_TnE_HK_Payment_Amount__c == null)?0:d.ASI_TnE_HK_Payment_Amount__c);
                                }
                                numOfAttendees += ((d.ASI_TnE_Total_Number_Pax__c == null)?0:d.ASI_TnE_Total_Number_Pax__c);
                                cnt++;
                                if(detail.isHidden == false && d.ASI_TnE_Expense_Classification__r.ASI_TnE_Read_Only_Fields__c != null && 
                                        (d.ASI_TnE_Expense_Classification__r.ASI_TnE_Read_Only_Fields__c).contains('ASI_TnE_Total_Number_Pax')){
                                    detail.isHidden = true;
                                }
                            }else{
                                otherAdjust += ((d.ASI_TnE_HK_Payment_Amount__c == null)?0:d.ASI_TnE_HK_Payment_Amount__c);   
                            }
                        }
                        if(cnt > 0){
                            if(header.RecordType.Name.contains('TnE TW') && header.ASI_TnE_Currency__c.equalsIgnoreCase('TWD')){
                                detail.avrgPerReceipt = (detail.amount/cnt).setScale(0);
                            }else{
                                detail.avrgPerReceipt = (detail.amount/cnt).setScale(2);
                            }
                            if(numOfAttendees > 0){
                                if(header.RecordType.Name.contains('TnE TW') && header.ASI_TnE_Currency__c.equalsIgnoreCase('TWD')){
                                    detail.avrgPerAttendee = (detail.amount/numOfAttendees).setScale(0);
                                }else{
                                    detail.avrgPerAttendee = (detail.amount/numOfAttendees).setScale(2);
                                }
                            }
                        }
                    }
                    if(cls.ASI_TnE_Other_Adjustment__c != null){
                            if(cls.ASI_TnE_Other_Adjustment__c){
                                otherAdjust += detail.amount;   
                            }
                        }
                    if(cls.ASI_TnE_Other_Adjustment__c == null || !cls.ASI_TnE_Other_Adjustment__c){
                        accMapDetails.add(detail);
                        ttlAmount += detail.amount;
                    }
                }
            }
        }
        return accMapDetails;
    }
    public List<approvalDetail> getapprovalDetails() {
        List<approvalDetail> details = new List<approvalDetail>();
        if (details.size() == 0 && currentHeaderId != null){
            List<ProcessInstance> pList = [SELECT Id, (SELECT CreatedDate, Id, StepStatus, Comments, ActorId, Actor.Name FROM StepsAndWorkitems Order By CreatedDate DESC, StepStatus DESC) FROM ProcessInstance Where TargetObjectId = :currentHeaderId Order By CreatedDate DESC Limit 1];
            Set<Id> actoerIdSet = new Set<Id>();
            for (ProcessInstance p:pList) {
                for (ProcessInstanceHistory his:p.StepsAndWorkitems) {
                    actoerIdSet.add(his.ActorId);
                }
            }
            Map<Id, User> userMap = new Map<Id, User>([Select Id, title From User Where Id In :actoerIdSet]);
            for (ProcessInstance p:pList) {
                Boolean byPassPending = false;
                if(p.StepsAndWorkitems.size() != 0 && (p.StepsAndWorkitems[0].StepStatus == 'Approved' || p.StepsAndWorkitems[0].StepStatus == 'Rejected') ){
                    byPassPending = true;
                }
                for (ProcessInstanceHistory his:p.StepsAndWorkitems) {
                    if(his.StepStatus != 'Reassigned' && his.StepStatus != 'NoResponse' && !(byPassPending && his.StepStatus == 'Pending')){
                        approvalDetail detail = new approvalDetail();
                        detail.title = userMap.get(his.ActorId).title;
                        detail.history = his;
                        details.add(detail);
                    }
                }
            }
            numOfApprovals = details.size();
        }
        return details;
    }
    public Boolean getIsOverThreeMth(){
        if(header == null){
            getHeader();
        }
        if(currentHeaderId != null){
            if(header.ASI_TnE_HK_Submission_Date__c == null || header.ASI_TnE_Start_Date__c == null){
                return false;
            }else{
                system.debug((header.ASI_TnE_HK_Submission_Date__c).daysBetween(header.ASI_TnE_Start_Date__c));
                return ((header.ASI_TnE_Start_Date__c).daysBetween(header.ASI_TnE_HK_Submission_Date__c) >= 90);
            }
        }else{
            return false;
        }
    }
    public ASI_TnE_ClaimHeader__c getHeader()
    {
        if (header == null && currentHeaderId != null) {
        header = [SELECT Name,
                         ASI_TnE_Total_Amount_LCY__c,
                         ASI_TnE_Total_Amount__c,
                         RecordType.Name,
                         Recordtype.Developername,
                         Owner.Name,
                         ASI_TnE_Payee_Employee__r.Name,
                         ASI_TnE_Payee_Employee__c,
                         OwnerId,
                         ASI_TnE_Sub_Ledger__c,
                         ASI_TnE_Total_Amount_Approved__c,
                         ASI_TnE_FX_Rate__c,
                         ASI_TnE_Sys_Fiscal_Year__c,
                         ASI_TnE_Employee_Type__c,
                         ASI_TnE_Department_Division__c,
                         ASI_TnE_HK_Submission_Date__c,
                         ASI_TnE_Business_Unit__c,
                         ASI_TnE_Company__c,
                         ASI_TnE_Type__c,
                         ASI_TnE_Over_3_Months_Submission__c,
                         ASI_TnE_Start_Date__c,
                         ASI_TnE_Claims_Value_Without_Receipts__c,
                         ASI_TnE_Claims_Count_Without_Receipts__c,
                         ASI_TnE_Remarks__c,
                         ASI_TnE_Currency__c,
                         ASI_TnE_End_Date__c,
                         ASI_TnE_MY_Comment_if_over_Budget__c     // Added by 2017-11-09 Linus@introv
                         from ASI_TnE_ClaimHeader__c where Id = :currentHeaderId];
            if(approverId == null){
                approverId = UserInfo.getUserId();
                byPassApproverIdCheck = false;
                Id userId = UserInfo.getUserId();
                Boolean alreadyChecked = false;
                User u = new User();
                List<ProcessInstance> pList = [SELECT Id, (SELECT CreatedDate, Id, StepStatus, Comments, ActorId FROM StepsAndWorkitems Where StepStatus = 'Pending' 
                                               Order By CreatedDate DESC) FROM ProcessInstance Where TargetObjectId = :currentHeaderId Order By CreatedDate DESC Limit 1];
                for(ProcessInstance p:pList){
                    for(ProcessInstanceHistory his:p.StepsAndWorkitems){
                        approverId = his.ActorId;
                    }
                }
                if(header.ASI_TnE_Payee_Employee__c == null){
                    userId = header.ownerId;
                }else{
                    userId = header.ASI_TnE_Payee_Employee__c; 
                }
                u = [Select Id, ManagerId, CompanyName, Department From User Where Id = :userId];
                List<ASI_TnE_Route_Type__c> routeList =  [Select ASI_TnE_Company__c, ASI_TnE_Department__c, ASI_TnE_User__r.Id, 
                                                         (Select ASI_TnE_Approver_Type__c, ASI_TnE_Approver_Name__c From ASI_TnE_Route_Rule_Details__r Order By Name ASC) 
                                                         From ASI_TnE_Route_Type__c Where ASI_TnE_Company__c = :u.CompanyName OR ASI_TnE_Department__c = :u.Department OR ASI_TnE_User__r.Id = :u.Id];
                for(ASI_TnE_Route_Type__c route:routeList){
                    if(u.Id == route.ASI_TnE_User__r.Id){
                        for(ASI_TnE_Route_Rule_Detail__c detail:route.ASI_TnE_Route_Rule_Details__r){
                            if(!byPassApproverIdCheck && detail.ASI_TnE_Approver_Type__c == 'Line Manager' && u.ManagerId == approverId){
                                byPassApproverIdCheck = true;  
                            }else if(!byPassApproverIdCheck && approverId == detail.ASI_TnE_Approver_Name__c){
                                byPassApproverIdCheck = true; 
                            }
                        }
                        alreadyChecked = true;
                    }
                    if(!alreadyChecked && u.CompanyName == route.ASI_TnE_Company__c && u.Department == route.ASI_TnE_Department__c){
                        for(ASI_TnE_Route_Rule_Detail__c detail:route.ASI_TnE_Route_Rule_Details__r){
                            if(!byPassApproverIdCheck && detail.ASI_TnE_Approver_Type__c == 'Line Manager' && u.ManagerId == approverId){
                                byPassApproverIdCheck = true;  
                            }else if(!byPassApproverIdCheck && approverId == detail.ASI_TnE_Approver_Name__c){
                                byPassApproverIdCheck = true; 
                            }
                        }
                    }
                }
            }
        }
        return header;
    }
    
    public List<ASI_TnE_ClaimDetail__c> getClaimDetails()
    {
        if (claimDetails == null && currentHeaderId != null) {
            String theQuery = 'SELECT ASI_TnE_Receipt_Date__c,ASI_TnE_Claim_Detail_ID__c,Name, ASI_TnE_Expense_Category__r.Name,ASI_TnE_Expense_Classification__r.Name,ASI_TnE_With_Receipt__c,ASI_TnE_Tax_Inclusive__c, ASI_TnE_Billed_To__c,';
            theQuery += 'ASI_TnE_Expense_Classification__r.ASI_JP_TnE_Account_Mapping__r.ASI_TnE_Account_Number__c,ASI_TnE_Expense_Classification__r.ASI_TnE_Read_Only_Fields__c,ASI_TnE_Client_Type__c, ASI_TnE_Outlet__r.Name,ASI_TnE_Payment_Request__r.name,';
            theQuery += 'ASI_TnE_Expense_Classification__r.ASI_TnE_Approver__c,ASI_TnE_Expense_Classification__r.ASI_TnE_Approver_2__c,ASI_TnE_Expense_Classification__r.ASI_TnE_Approver_3__c, ASI_TnE_MFM_PO__r.Name,ASI_TnE_CAP_Plan__r.Name,';
            theQuery += 'ASI_TnE_Expense_Classification__r.ASI_TnE_Approver_4__c,ASI_TnE_Total_Number_Pax__c,ASI_TnE_Currency__c,ASI_TnE_FX_Rate__c,ASI_TnE_Dispute__c,ASI_TnE_Receipt_Amount__c,';
            theQuery += 'ASI_TnE_HK_Payment_Amount__c,ASI_TnE_Payment_Amount__c,ASI_TnE_TW_Payment_Amount__c,ASI_TnE_Destination__c,ASI_TnE_Tax_Amount__c,ASI_TnE_Invoice_Issuer__c,ASI_TnE_Taxable_Amount_Display__c,ASI_TnE_MY_GST_Value__c,ASI_TnE_Details_of_Expense__c,';
            theQuery += 'ASI_TnE_Charge_To_Acc__r.Name,'; //20170202, Elufa
            theQuery += 'ASI_TnE_GnH_Request__c,ASI_TnE_GnH_Request__r.Name,'; // 2017-12-21 Linus@introv
            theQuery += 'ASI_TnE_Receipt_Number__c,ASI_TnE_Name_Company__c FROM ASI_TnE_ClaimDetail__c WHERE ASI_TnE_ClaimHeader__c = ' + '\'' + currentHeaderId + '\' ';
            If(header.RecordType.Name.contains('TnE HK')){
                theQuery += ' order by ASI_TnE_Receipt_Number__c ASC';
            }else if(header.RecordType.Name.contains('TnE TW')){
                theQuery += ' order by Name ASC';
            }else{
                theQuery += ' order by ASI_TnE_Receipt_Date__c ASC';
            }
            List<ASI_TnE_ClaimDetail__c> tempClaimDetails = (List<ASI_TnE_ClaimDetail__c>)Database.query(theQuery); 
            Boolean isSpecialApprover = false;
            for(ASI_TnE_ClaimDetail__c detail:tempClaimDetails){
                if(!isSpecialApprover && (detail.ASI_TnE_Expense_Classification__r.ASI_TnE_Approver__c == approverId ||
                        detail.ASI_TnE_Expense_Classification__r.ASI_TnE_Approver_2__c == approverId ||
                        detail.ASI_TnE_Expense_Classification__r.ASI_TnE_Approver_3__c == approverId ||
                        detail.ASI_TnE_Expense_Classification__r.ASI_TnE_Approver_4__c == approverId)){
                    isSpecialApprover = true;        
                }
            }
            if(viewAllDetails == null){
                viewAllDetails = false;
            }
            if((!byPassApproverIdCheck && !isSpecialApprover) || viewAllDetails){
                byPassApproverIdCheck = true;
            }
            if(byPassApproverIdCheck){
                claimDetails = tempClaimDetails;
            }else{
                claimDetails = new List<ASI_TnE_ClaimDetail__c>();
                for(ASI_TnE_ClaimDetail__c detail:tempClaimDetails){
                    if(detail.ASI_TnE_Expense_Classification__r.ASI_TnE_Approver__c == approverId ||
                            detail.ASI_TnE_Expense_Classification__r.ASI_TnE_Approver_2__c == approverId ||
                            detail.ASI_TnE_Expense_Classification__r.ASI_TnE_Approver_3__c == approverId ||
                            detail.ASI_TnE_Expense_Classification__r.ASI_TnE_Approver_4__c == approverId){
                        claimDetails.add(detail);    
                    }
                }
            }
            for(ASI_TnE_ClaimDetail__c d:claimDetails ){
                if(startDate == null){
                    startDate = d.ASI_TnE_Receipt_Date__c;
                }else if(startDate > d.ASI_TnE_Receipt_Date__c){
                    startDate = d.ASI_TnE_Receipt_Date__c;
                }
                
                if(endDate == null){
                    endDate = d.ASI_TnE_Receipt_Date__c;
                }else if(endDate < d.ASI_TnE_Receipt_Date__c){
                    endDate = d.ASI_TnE_Receipt_Date__c;
                }
            }
        }
        return claimDetails;
    }
    public budgetDetail getBudget(){
        if(budget == null && currentHeaderId != null){
            if(header == null){
                getHeader();
            }
            budget = new budgetDetail();
            ASI_MFM_Budget__c tneBudget = new ASI_MFM_Budget__c();
            ASI_MFM_Budget__c anpBudget = new ASI_MFM_Budget__c();
            ASI_MFM_Budget__c medicalBudget = new ASI_MFM_Budget__c();
            ASI_MFM_Budget__c gasolineBudget = new ASI_MFM_Budget__c();
            ASI_MFM_Budget__c dentalBudget = new ASI_MFM_Budget__c();
            ASI_MFM_Budget__c lensBudget = new ASI_MFM_Budget__c();
            Decimal[] tneBudgets = new Decimal[13];
            Decimal[] anpBudgets = new Decimal[13];
            Decimal[] medicalBudgets = new Decimal[13];
            Decimal[] gasolineBudgets = new Decimal[13];
            Decimal[] dentalBudgets = new Decimal[13];
            Decimal[] lensBudgets = new Decimal[13];
            Integer subMth = (header.ASI_TnE_HK_Submission_Date__c == null)?system.today().month():header.ASI_TnE_HK_Submission_Date__c.month();
            Integer subYr = (header.ASI_TnE_HK_Submission_Date__c == null)?system.today().year():header.ASI_TnE_HK_Submission_Date__c.year();
            Integer idx = (subMth>6)?subMth-6:subMth+6;
            Id userId = header.ASI_TnE_Payee_Employee__c == null?header.ownerId:header.ASI_TnE_Payee_Employee__c;
            List<ASI_TnE_ClaimHeader__c> existClaims = [Select ASI_TnE_Total_Amount_LCY__c,ASI_TnE_Total_Amount__c, ASI_TnE_HK_Submission_Date__c, (Select ASI_TnE_Receipt_Date__c, ASI_TnE_Expense_Classification__c, ASI_TnE_Expense_Classification__r.ASI_TnE_Budget_Type__c, ASI_TnE_Receipt_Amount__c, ASI_TnE_HK_Payment_Amount__c,ASI_TnE_Payment_Amount__c, ASI_TnE_TW_Payment_Amount__c 
                                     From ASI_TnE_ClaimDetail__r) From ASI_TnE_ClaimHeader__c 
                                     Where ASI_TnE_Sys_Fiscal_Year__c = :header.ASI_TnE_Sys_Fiscal_Year__c And ((OwnerId = :userId And ASI_TnE_Payee_Employee__c = null) OR ASI_TnE_Payee_Employee__c  = :userId) And (ASI_TnE_HK_Submission_Date__c <= today OR Id = :header.Id)];
            List<ASI_MFM_Budget__c> bgt = [Select ASI_MFM_Budget_Type__c, ASI_MFM_P1_Amount__c, ASI_MFM_P2_Amount__c, ASI_MFM_P3_Amount__c, ASI_MFM_P4_Amount__c, ASI_MFM_P5_Amount__c, ASI_MFM_P6_Amount__c, 
                                     ASI_MFM_P7_Amount__c, ASI_MFM_P8_Amount__c, ASI_MFM_P9_Amount__c, ASI_MFM_P10_Amount__c, ASI_MFM_P11_Amount__c, ASI_MFM_P12_Amount__c 
                                     From ASI_MFM_Budget__c Where ASI_CRM_Salesperson__r.Id = :userId And ASI_MFM_Fiscal_Year__c = :header.ASI_TnE_Sys_Fiscal_Year__c];
            system.debug('Check 1: ' + bgt);
            for(ASI_MFM_Budget__c b:bgt){
                if(b.ASI_MFM_Budget_Type__c == 'T&E'){
                    tneBudget = b;
                }else if(b.ASI_MFM_Budget_Type__c == 'A&P'){
                    anpBudget = b;
                }else if(b.ASI_MFM_Budget_Type__c == 'Medical'){
                    medicalBudget = b;    
                }else if(b.ASI_MFM_Budget_Type__c == 'Gasoline'){
                    gasolineBudget = b;    
                }else if(b.ASI_MFM_Budget_Type__c == 'Dental'){
                    dentalBudget = b;    
                }else if(b.ASI_MFM_Budget_Type__c == 'Lens'){
                    lensBudget = b;    
                }
            }
            if(tneBudget != null){
                system.debug('Check 2: ' + tneBudget.ASI_MFM_P1_Amount__c);
                tneBudgets[1] = tneBudget.ASI_MFM_P1_Amount__c;
                tneBudgets[2] = tneBudget.ASI_MFM_P2_Amount__c;
                tneBudgets[3] = tneBudget.ASI_MFM_P3_Amount__c;
                tneBudgets[4] = tneBudget.ASI_MFM_P4_Amount__c;
                tneBudgets[5] = tneBudget.ASI_MFM_P5_Amount__c;
                tneBudgets[6] = tneBudget.ASI_MFM_P6_Amount__c;
                tneBudgets[7] = tneBudget.ASI_MFM_P7_Amount__c;
                tneBudgets[8] = tneBudget.ASI_MFM_P8_Amount__c;
                tneBudgets[9] = tneBudget.ASI_MFM_P9_Amount__c;
                tneBudgets[10] = tneBudget.ASI_MFM_P10_Amount__c;
                tneBudgets[11] = tneBudget.ASI_MFM_P11_Amount__c;
                tneBudgets[12] = tneBudget.ASI_MFM_P12_Amount__c;
                for(Integer i=1;i<=idx;i++){
                    budget.ytdTnEBgt += (tneBudgets[i] == null?0:tneBudgets[i]);
                }
                budget.mtdTnEBgt = (tneBudgets[idx] == null?0:tneBudgets[idx]);
            }
            if(anpBudget != null){
                anpBudgets[1] = anpBudget.ASI_MFM_P1_Amount__c;
                anpBudgets[2] = anpBudget.ASI_MFM_P2_Amount__c;
                anpBudgets[3] = anpBudget.ASI_MFM_P3_Amount__c;
                anpBudgets[4] = anpBudget.ASI_MFM_P4_Amount__c;
                anpBudgets[5] = anpBudget.ASI_MFM_P5_Amount__c;
                anpBudgets[6] = anpBudget.ASI_MFM_P6_Amount__c;
                anpBudgets[7] = anpBudget.ASI_MFM_P7_Amount__c;
                anpBudgets[8] = anpBudget.ASI_MFM_P8_Amount__c;
                anpBudgets[9] = anpBudget.ASI_MFM_P9_Amount__c;
                anpBudgets[10] = anpBudget.ASI_MFM_P10_Amount__c;
                anpBudgets[11] = anpBudget.ASI_MFM_P11_Amount__c;
                anpBudgets[12] = anpBudget.ASI_MFM_P12_Amount__c;
                for(Integer i=1;i<=idx;i++){
                    budget.ytdAnPBgt += (anpBudgets[i] == null?0:anpBudgets[i]);
                }
                budget.mtdAnPBgt = (anpBudgets[idx] == null?0:anpBudgets[idx]);
            }
            if(medicalBudget != null){
                medicalBudgets[1] = medicalBudget.ASI_MFM_P1_Amount__c;
                medicalBudgets[2] = medicalBudget.ASI_MFM_P2_Amount__c;
                medicalBudgets[3] = medicalBudget.ASI_MFM_P3_Amount__c;
                medicalBudgets[4] = medicalBudget.ASI_MFM_P4_Amount__c;
                medicalBudgets[5] = medicalBudget.ASI_MFM_P5_Amount__c;
                medicalBudgets[6] = medicalBudget.ASI_MFM_P6_Amount__c;
                medicalBudgets[7] = medicalBudget.ASI_MFM_P7_Amount__c;
                medicalBudgets[8] = medicalBudget.ASI_MFM_P8_Amount__c;
                medicalBudgets[9] = medicalBudget.ASI_MFM_P9_Amount__c;
                medicalBudgets[10] = medicalBudget.ASI_MFM_P10_Amount__c;
                medicalBudgets[11] = medicalBudget.ASI_MFM_P11_Amount__c;
                medicalBudgets[12] = medicalBudget.ASI_MFM_P12_Amount__c;
                for(Integer i=1;i<=idx;i++){
                    budget.ytdMedicalBgt += (medicalBudgets[i] == null?0:medicalBudgets[i]);
                }
            }
            if(gasolineBudget != null){
                gasolineBudgets[1] = gasolineBudget.ASI_MFM_P1_Amount__c;
                gasolineBudgets[2] = gasolineBudget.ASI_MFM_P2_Amount__c;
                gasolineBudgets[3] = gasolineBudget.ASI_MFM_P3_Amount__c;
                gasolineBudgets[4] = gasolineBudget.ASI_MFM_P4_Amount__c;
                gasolineBudgets[5] = gasolineBudget.ASI_MFM_P5_Amount__c;
                gasolineBudgets[6] = gasolineBudget.ASI_MFM_P6_Amount__c;
                gasolineBudgets[7] = gasolineBudget.ASI_MFM_P7_Amount__c;
                gasolineBudgets[8] = gasolineBudget.ASI_MFM_P8_Amount__c;
                gasolineBudgets[9] = gasolineBudget.ASI_MFM_P9_Amount__c;
                gasolineBudgets[10] = gasolineBudget.ASI_MFM_P10_Amount__c;
                gasolineBudgets[11] = gasolineBudget.ASI_MFM_P11_Amount__c;
                gasolineBudgets[12] = gasolineBudget.ASI_MFM_P12_Amount__c;
                for(Integer i=1;i<=idx;i++){
                    budget.ytdGasolineBgt += (gasolineBudgets[i] == null?0:gasolineBudgets[i]);
                }
            }
            if(dentalBudget != null){
                dentalBudgets[1] = dentalBudget.ASI_MFM_P1_Amount__c;
                dentalBudgets[2] = dentalBudget.ASI_MFM_P2_Amount__c;
                dentalBudgets[3] = dentalBudget.ASI_MFM_P3_Amount__c;
                dentalBudgets[4] = dentalBudget.ASI_MFM_P4_Amount__c;
                dentalBudgets[5] = dentalBudget.ASI_MFM_P5_Amount__c;
                dentalBudgets[6] = dentalBudget.ASI_MFM_P6_Amount__c;
                dentalBudgets[7] = dentalBudget.ASI_MFM_P7_Amount__c;
                dentalBudgets[8] = dentalBudget.ASI_MFM_P8_Amount__c;
                dentalBudgets[9] = dentalBudget.ASI_MFM_P9_Amount__c;
                dentalBudgets[10] = dentalBudget.ASI_MFM_P10_Amount__c;
                dentalBudgets[11] = dentalBudget.ASI_MFM_P11_Amount__c;
                dentalBudgets[12] = dentalBudget.ASI_MFM_P12_Amount__c;
                for(Integer i=1;i<=idx;i++){
                    budget.ytdDentalBgt += (dentalBudgets[i] == null?0:dentalBudgets[i]);
                }
            }
            if(lensBudget != null){
                lensBudgets[1] = lensBudget.ASI_MFM_P1_Amount__c;
                lensBudgets[2] = lensBudget.ASI_MFM_P2_Amount__c;
                lensBudgets[3] = lensBudget.ASI_MFM_P3_Amount__c;
                lensBudgets[4] = lensBudget.ASI_MFM_P4_Amount__c;
                lensBudgets[5] = lensBudget.ASI_MFM_P5_Amount__c;
                lensBudgets[6] = lensBudget.ASI_MFM_P6_Amount__c;
                lensBudgets[7] = lensBudget.ASI_MFM_P7_Amount__c;
                lensBudgets[8] = lensBudget.ASI_MFM_P8_Amount__c;
                lensBudgets[9] = lensBudget.ASI_MFM_P9_Amount__c;
                lensBudgets[10] = lensBudget.ASI_MFM_P10_Amount__c;
                lensBudgets[11] = lensBudget.ASI_MFM_P11_Amount__c;
                lensBudgets[12] = lensBudget.ASI_MFM_P12_Amount__c;
                for(Integer i=1;i<=idx;i++){
                    budget.ytdLensBgt += (lensBudgets[i] == null?0:lensBudgets[i]);
                }
            }
            for(ASI_TnE_ClaimHeader__c h:existClaims){
                for(ASI_TnE_ClaimDetail__c d:h.ASI_TnE_ClaimDetail__r){
                    if(d.ASI_TnE_Expense_Classification__c != null){
                        if(d.ASI_TnE_Expense_Classification__r.ASI_TnE_Budget_Type__c == 'T&E'){
                            if(d.ASI_TnE_Receipt_Date__c.month() == subMth && d.ASI_TnE_Receipt_Date__c.year() == subYr){
                                budget.mtdTnEAmt += d.ASI_TnE_HK_Payment_Amount__c;
                            }

                            budget.ytdTnEAmt += d.ASI_TnE_HK_Payment_Amount__c;
                        }else if(d.ASI_TnE_Expense_Classification__r.ASI_TnE_Budget_Type__c == 'A&P'){
                            if(d.ASI_TnE_Receipt_Date__c.month() == subMth && d.ASI_TnE_Receipt_Date__c.year() == subYr){
                                budget.mtdAnPAmt += d.ASI_TnE_HK_Payment_Amount__c;
                            }
                            budget.ytdAnPAmt += d.ASI_TnE_HK_Payment_Amount__c;
                        }else if(d.ASI_TnE_Expense_Classification__r.ASI_TnE_Budget_Type__c == 'Medical'){
                            system.debug('Check Type: ' + d.ASI_TnE_HK_Payment_Amount__c);
                            budget.ytdMedicalAmt += d.ASI_TnE_HK_Payment_Amount__c;
                        }else if(d.ASI_TnE_Expense_Classification__r.ASI_TnE_Budget_Type__c == 'Gasoline'){
                            budget.ytdGasolineAmt += d.ASI_TnE_HK_Payment_Amount__c;
                        }else if(d.ASI_TnE_Expense_Classification__r.ASI_TnE_Budget_Type__c == 'Dental'){
                            budget.ytdDentalAmt += d.ASI_TnE_HK_Payment_Amount__c;
                        }else if(d.ASI_TnE_Expense_Classification__r.ASI_TnE_Budget_Type__c == 'Lens'){
                            budget.ytdLensAmt += d.ASI_TnE_HK_Payment_Amount__c;
                        }
                    }
                }
            }
            
            // Added by 2017-11-09 Linus@introv
            if(budget.ytdTnEAmt > budget.ytdTnEBgt || budget.ytdAnPAmt > budget.ytdAnPBgt ||
               budget.mtdTnEAmt > budget.mtdTnEBgt || budget.mtdAnPAmt > budget.mtdAnPBgt){
                   budget.overBudget = true;
            }
        }
        return budget;
    }
    public Integer getNumOfDetails(){
        if(claimDetails == null){
            getClaimDetails();
        }
        if(claimDetails != null){
            return claimDetails.size();
        }else{
            return 0;
        }
    }
    //Account Mapping Detail
    public Class accMapDetail{
        public ASI_JP_TnE_Expense_Classification__c detail{get;set;}
        public decimal amount{get;set;}
        public decimal GSTAmt{get;set;}
        public decimal taxableAmt{get;set;}
        public boolean isHidden{get;set;}
        public decimal avrgPerReceipt{get;set;}
        public decimal avrgPerAttendee{get;set;}
        public accMapDetail(){
            amount = 0;
            GSTAmt = 0;
            taxableAmt = 0;
            avrgPerReceipt = 0;
            avrgPerAttendee = 0;
            isHidden = false;
        }
    }
    //Approval History
    public Class approvalDetail{
        public ProcessInstanceHistory history{get;set;}
        public String title{get;set;}
    }
    //Budget info
    public Class budgetDetail{
        public decimal ytdTnEAmt{get;set;}
        public decimal ytdTnEBgt{get;set;}
        public decimal ytdAnPAmt{get;set;}
        public decimal ytdAnPBgt{get;set;}
        //for TH
        public decimal ytdMedicalAmt{get;set;}
        public decimal ytdMedicalBgt{get;set;}
        public decimal ytdGasolineAmt{get;set;}
        public decimal ytdGasolineBgt{get;set;}
        public decimal ytdDentalAmt{get;set;}
        public decimal ytdDentalBgt{get;set;}
        public decimal ytdLensAmt{get;set;}
        public decimal ytdLensBgt{get;set;}
        //for MY
        public decimal mtdTnEAmt{get;set;}
        public decimal mtdTnEBgt{get;set;}
        public decimal mtdAnPAmt{get;set;}
        public decimal mtdAnPBgt{get;set;}
        // Added by 2017-11-09 Linus@introv
        public boolean overBudget{get;set;}
        
        public budgetDetail(){
            ytdTnEAmt = 0;
            ytdTnEBgt = 0;
            ytdAnPAmt = 0;
            ytdAnPBgt = 0;
            ytdMedicalAmt = 0;
            ytdMedicalBgt = 0;
            ytdGasolineAmt = 0;
            ytdGasolineBgt = 0;
            ytdDentalAmt = 0;
            ytdDentalBgt = 0;
            ytdLensAmt = 0;
            ytdLensBgt = 0; 
            mtdAnPAmt = 0;
            mtdAnPBgt = 0;
            mtdTnEAmt = 0;
            mtdTnEBgt = 0; 
            overBudget = false;
        }
    }
}