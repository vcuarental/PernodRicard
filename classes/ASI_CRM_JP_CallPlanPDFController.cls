/*********************************************************************************
 * Name:ASI_CRM_JP_CallPlanPDFController
 * Description: Visitation Plan PDF Controller to handle the data
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 18/11/2014       Laputa: Conrad          Created
*********************************************************************************/
public with sharing class ASI_CRM_JP_CallPlanPDFController{
        
        public String currentHeaderId;
        public string init;
        public List<ASI_CRM_Call_Detail__c> details;
        public ASI_CRM_Call_Plan__c Header;
        public List<visitLinesGrouped> groupedDetails;
        public List<approvalDetail> approvalDetails;
        public Map<Id, Integer> budgetMap = new Map<Id ,Integer>();
        public Map<Id, Integer> budgetUsedMap = new Map<Id ,Integer>();
        public Integer numOfApprovals{get;set;}
        public Boolean checkIfJP;
        public String approverLanguage;
        
        public ASI_CRM_JP_CallPlanPDFController()
        {
            
        }  
        
        public void setcurrentHeaderId (String s) {
            currentHeaderId = s;
        }

        public String getcurrentHeaderId() {
            return currentHeaderId;
        }
        
        public String setinit(string s)
        {
            init();
            return s;
        }
        
        public Boolean getCheckIfJP(){
            return (approverLanguage != 'en_US');
        }
        
        public String getApproverLanguage(){
            if(approverLanguage == null && currentHeaderId != null){
                approverLanguage = UserInfo.getLanguage();
                Id userId;
                List<ProcessInstance> pList = [SELECT Id, (SELECT CreatedDate, Id, StepStatus, Comments, ActorId FROM StepsAndWorkitems Where StepStatus = 'Pending' Order By CreatedDate DESC) FROM ProcessInstance Where TargetObjectId = :currentHeaderId Order By CreatedDate DESC Limit 1];
                for(ProcessInstance p:pList){
                    for(ProcessInstanceHistory his:p.StepsAndWorkitems){
                        userId = his.ActorId;
                    }
                }
                List<User> userList = new List<User>([Select Id, LanguageLocaleKey From User Where Id = :userId]);
                for(User u:userList){
                    approverLanguage = u.LanguageLocaleKey;
                }
            }
            return approverLanguage;
        }
        
        public void init()
        {
            if (header == null && currentHeaderId != null) 
            {
             Map<String, Schema.SObjectField> visitingFieldMap = Schema.SObjectType.ASI_CRM_Call_Plan__c.fields.getMap();
             String theQuery = 'Select ';
        
             for(String fields  : visitingFieldMap.keySet()){
                theQuery += fields + ' ,';
             }
         
             thequery = theQuery.subString(0,theQuery.length()-1);
             thequery += ', owner.name, createdby.name From ASI_CRM_Call_Plan__c where ID = ' + '\'' + currentHeaderId + '\' ';
         
             List<ASI_CRM_Call_Plan__c> visitingList = (List<ASI_CRM_Call_Plan__c>)Database.query(theQuery); 
             if (visitingList.size() > 0)
                 header = visitingList.get(0);
             } 
             
             if (Details == null && currentHeaderId != null) 
             {
                 Map<String, Schema.SObjectField> visitingDetailsFieldMap = Schema.SObjectType.ASI_CRM_Call_Detail__c.fields.getMap();
                 String theQuery = 'Select ';
        
                 for(String fields  : visitingDetailsFieldMap.keySet()){
                    theQuery += fields + ' ,';
                 }
         
                 thequery = theQuery.subString(0,theQuery.length()-1);
                 thequery += 'From ASI_CRM_Call_Detail__c where ASI_CRM_Call_Plan__c = ' + '\'' + currentHeaderId + '\' ';
         
                 Details = (List<ASI_CRM_Call_Detail__c>)Database.query(theQuery); 
                                
             }
        }
        
        public List<ASI_CRM_Call_Detail__c> getDetails()
        {
           if (Details == null && currentHeaderId != null) 
           {
             Map<String, Schema.SObjectField> visitingDetailsFieldMap = Schema.SObjectType.ASI_CRM_Call_Detail__c.fields.getMap();
             String theQuery = 'Select ';
        
             for(String fields  : visitingDetailsFieldMap.keySet()){
                theQuery += fields + ' ,';
             }
         
             thequery = theQuery.subString(0,theQuery.length()-1);
             thequery += ' From ASI_CRM_Call_Detail__c where ASI_CRM_Call_Plan__c = ' + '\'' + currentHeaderId + '\' ORDER BY ID ASC';
         
             Details = (List<ASI_CRM_Call_Detail__c>)Database.query(theQuery);       
                       
            }
            return Details;
        }
        
        public List<approvalDetail> getapprovalDetails() {
            List<approvalDetail> details = new List<approvalDetail>();
            if (details.size() == 0 && currentHeaderId != null){
                List<ProcessInstance> pList = [SELECT Id, (SELECT CreatedDate, Id, StepStatus, Comments, ActorId, Actor.Name FROM StepsAndWorkitems Order By CreatedDate DESC) FROM ProcessInstance Where TargetObjectId = :currentHeaderId Order By CreatedDate DESC Limit 1];
                Set<Id> actoerIdSet = new Set<Id>();
                for (ProcessInstance p:pList) {
                    for (ProcessInstanceHistory his:p.StepsAndWorkitems) {
                        actoerIdSet.add(his.ActorId);
                    }
                }
                Map<Id, User> userMap = new Map<Id, User>([Select Id, title From User Where Id In :actoerIdSet]);
                for (ProcessInstance p:pList) {
                    for (ProcessInstanceHistory his:p.StepsAndWorkitems) {
                        if(his.StepStatus != 'Reassigned'){
                            approvalDetail detail = new approvalDetail();
                            detail.title = userMap.get(his.ActorId).title;
                            detail.history = his;
                            details.add(detail);
                        }
                    }
                }
            }
            numOfApprovals = details.size() + 1;
            return details;
        } 
        
        public List<visitLinesGrouped> getgroupedDetails()
        {
           
           List<visitLinesGrouped> groupedDetails = new List<visitLinesGrouped>();
           
           if (groupedDetails.size() == 0 && currentHeaderId != null) 
           {
             List<ASI_CRM_Call_Detail__c> tempDetails = new List<ASI_CRM_Call_Detail__c>();
             Map<String, Schema.SObjectField> visitingDetailsFieldMap = Schema.SObjectType.ASI_CRM_Call_Detail__c.fields.getMap();
             String theQuery = 'Select ';
        
             for(String fields  : visitingDetailsFieldMap.keySet()){
                theQuery += fields + ' ,';
             }
         
             thequery = theQuery.subString(0,theQuery.length()-1);
             thequery += ', ASI_CRM_Customer__r.recordtype.developername, ASI_CRM_Activity_Sub_brand_1__r.ASI_MFM_Brand__c, ASI_CRM_Activity_Sub_brand_1__r.ASI_MFM_Brand__r.Name, ASI_CRM_Activity_Sub_brand_1__r.ASI_MFM_Brand__r.ASI_MFM_Brand_Description__c, ASI_CRM_Activity_Sub_brand_1__r.Name, ASI_CRM_Customer__r.name, ASI_CRM_Customer__r.ASI_CRM_Customer_Name_Kanji__c, ASI_CRM_Customer__r.ASI_CRM_CN_CRM_Code__c, ASI_CRM_Customer__r.ASI_TH_CRM_OutletType__r.Name, ASI_CRM_Customer__r.ASI_TH_CRM_OutletType__r.ASI_CRM_Class__c, ASI_CRM_Customer__r.ASI_CRM_VN_Channel__c ' +
             ' From ASI_CRM_Call_Detail__c where ASI_CRM_Call_Plan__c = ' + '\'' + currentHeaderId + '\'  AND ASI_CRM_Ad_hoc__c = false ORDER BY ASI_CRM_Activity_Sub_brand_1__r.ASI_MFM_Brand__r.ASI_MFM_Brand_Description__c ASC';
         
             tempDetails = (List<ASI_CRM_Call_Detail__c>)Database.query(theQuery);       
             
             ID brand;
             String brandName;
             List<visitLinesDetail> groupingVisitation = new List<visitLinesDetail>();
             List<visitLinesDetail> groupingOriginalVisitation = new List<visitLinesDetail>();
             decimal ttlAmt = 0;
             decimal ttlOriginalAmt = 0;
             
             getHeader();
             for(integer i = 0; i < tempDetails.size(); i++) {
                 if (i == 0) {
                     brand = tempDetails.get(i).ASI_CRM_Activity_Sub_brand_1__c;
                     brandName = tempDetails.get(i).ASI_CRM_Activity_Sub_brand_1__r.Name;
                     visitLinesDetail visit = new visitLinesDetail();
                     visit.visitLine = tempDetails.get(i);
                     visit.totalAttendees = tempDetails.get(i).ASI_CRM_Number_of_PRJ_Sales_Attendees__c + tempDetails.get(i).ASI_CRM_Number_of_Attendees_BS__c + tempDetails.get(i).ASI_CRM_Number_of_Attendees_Other__c;
                     //If later want to order the record by original, just change the if(true) to if(brandName == 'The Brands That not grouped into original')
                     if (true) {
                         groupingVisitation.add(visit);
                         ttlAmt += tempDetails.get(i).ASI_CRM_Planned_Amount__c;
                     }else{
                         groupingOriginalVisitation.add(visit);
                         ttlOriginalAmt += tempDetails.get(i).ASI_CRM_Planned_Amount__c;
                     }
                 }
                 else if (brandName != tempDetails.get(i).ASI_CRM_Activity_Sub_brand_1__r.Name) {
                     if (groupingVisitation.size() > 0){
                         visitLinesGrouped lineGroup = new visitLinesGrouped();
                         lineGroup.brandID = brand;
                         if(calcBudget(header.ASI_CRM_Sys_Fiscal_Year__c, brand, header.ownerId) != -1){
                            lineGroup.brandName = brandName + ': ' + System.label.ASI_CRM_JP_Budget_Amount + numberWithCommas(calcBudget(header.ASI_CRM_Sys_Fiscal_Year__c, brand, header.ownerId)) + '; ' + System.label.ASI_CRM_JP_Remaining_Balance + numberWithCommas(calcUsedBudget(header.ASI_CRM_Sys_Fiscal_Year__c, brand, header.ownerId));
                         }else{
                            lineGroup.brandName = brandName;
                         }
                         lineGroup.visitLines = groupingVisitation;
                         lineGroup.total = ttlAmt;
                         ttlAmt = 0;
                         groupedDetails.add(lineGroup);
                     }
                     brand = tempDetails.get(i).ASI_CRM_Activity_Sub_brand_1__c;
                     brandName = tempDetails.get(i).ASI_CRM_Activity_Sub_brand_1__r.Name;
                     groupingVisitation = new List<visitLinesDetail>();
                     visitLinesDetail visit = new visitLinesDetail();
                     visit.visitLine = tempDetails.get(i);
                     visit.totalAttendees = tempDetails.get(i).ASI_CRM_Number_of_PRJ_Sales_Attendees__c + tempDetails.get(i).ASI_CRM_Number_of_Attendees_BS__c + tempDetails.get(i).ASI_CRM_Number_of_Attendees_Other__c;
                     //If later want to order the record by original, just change the if(true) to if(brandName == 'The Brands That not grouped into original')
                     if (true) {
                         groupingVisitation.add(visit);
                         ttlAmt += tempDetails.get(i).ASI_CRM_Planned_Amount__c;
                     }else{
                         groupingOriginalVisitation.add(visit);
                         ttlOriginalAmt += tempDetails.get(i).ASI_CRM_Planned_Amount__c;
                     }
                 }
                 else if (brandName == tempDetails.get(i).ASI_CRM_Activity_Sub_brand_1__r.Name) {
                     visitLinesDetail visit = new visitLinesDetail();
                     visit.visitLine = tempDetails.get(i);
                     visit.totalAttendees = tempDetails.get(i).ASI_CRM_Number_of_PRJ_Sales_Attendees__c + tempDetails.get(i).ASI_CRM_Number_of_Attendees_BS__c + tempDetails.get(i).ASI_CRM_Number_of_Attendees_Other__c;
                     // if (brandName == 'PERRIER JOUET' || brandName == 'MUMM' || brandName == 'CHIVAS REGAL' || brandName == 'MARTELL' || brandName == 'CAFE de PARIS' )
                     if (true) {
                         groupingVisitation.add(visit);
                         ttlAmt += tempDetails.get(i).ASI_CRM_Planned_Amount__c;
                     }else{
                         groupingOriginalVisitation.add(visit);
                         ttlOriginalAmt += tempDetails.get(i).ASI_CRM_Planned_Amount__c;
                     }
                 }
                 
                 if (i == tempDetails.size() - 1) {
                     if (groupingVisitation.size() > 0) {
                         visitLinesGrouped lineGroup = new visitLinesGrouped();
                         lineGroup.brandID = brand;
                         if(calcBudget(header.ASI_CRM_Sys_Fiscal_Year__c, brand, header.ownerId) != -1){
                            lineGroup.brandName = brandName + ': ' + System.label.ASI_CRM_JP_Budget_Amount + numberWithCommas(calcBudget(header.ASI_CRM_Sys_Fiscal_Year__c, brand, header.ownerId)) + '; ' + System.label.ASI_CRM_JP_Remaining_Balance + numberWithCommas(calcUsedBudget(header.ASI_CRM_Sys_Fiscal_Year__c, brand, header.ownerId));
                         }else{
                            lineGroup.brandName = brandName;
                         }
                         lineGroup.visitLines = groupingVisitation;
                         lineGroup.total = ttlAmt;
                         ttlAmt = 0;
                         groupedDetails.add(lineGroup);
                     }    
                 }
             }
             if (groupingOriginalVisitation.size() > 0) {
                 visitLinesGrouped lineGroup = new visitLinesGrouped();
                 lineGroup.brandID = brand;
                 lineGroup.brandName = 'Original';
                 lineGroup.visitLines = groupingOriginalVisitation;
                 lineGroup.total = ttlOriginalAmt;
                 groupedDetails.add(lineGroup);
                 }
            }
            return groupedDetails;
        }
        
        public ASI_CRM_Call_Plan__c getHeader()
        {
            if (header == null && currentHeaderId != null) 
            {
             Map<String, Schema.SObjectField> visitingFieldMap = Schema.SObjectType.ASI_CRM_Call_Plan__c.fields.getMap();
             String theQuery = 'Select ';
        
             for(String fields  : visitingFieldMap.keySet()){
                theQuery += fields + ' ,';
             }
         
             thequery = theQuery.subString(0,theQuery.length()-1);
             thequery += ', owner.name, createdby.name From ASI_CRM_Call_Plan__c where  ID = ' + '\'' + currentHeaderId + '\' ';
         
             List<ASI_CRM_Call_Plan__c> visitingList = (List<ASI_CRM_Call_Plan__c>)Database.query(theQuery); 
             if (visitingList.size() > 0)
                 header = visitingList.get(0);
             }
             return header;
        }
        
        //Calculate the budget
        private Integer calcBudget(String fiscalYear, Id subBrand, Id salesPerson){
            if(budgetMap.size() == 0){
                budgetMap = new Map<Id ,Integer>();
                Map<Id, String> typeSetMap = new Map<Id, String>();
                List<ASI_MFM_Budget__c> budgetList = [Select Id, Name, ASI_CRM_Amount__c, ASI_MFM_Type__c, ASI_MFM_Sub_brand_Code__c From ASI_MFM_Budget__c 
                        Where recordtypeid = : Global_RecordTypeCache.getRtId('ASI_MFM_Budget__cASI_CRM_JP_Budget') 
                        And ASI_MFM_Fiscal_year__c = :fiscalYear
                        And ASI_CRM_Salesperson__r.Id = :salesPerson];
                for(ASI_MFM_Budget__c budget:budgetList){
                    if(budget.ASI_MFM_Type__c == 'Original Budget' && typeSetMap.get(budget.ASI_MFM_Sub_brand_Code__c) == null){
                        typeSetMap.put(budget.ASI_MFM_Sub_brand_Code__c, budget.ASI_MFM_Type__c);
                    }else if(budget.ASI_MFM_Type__c == 'LE1' && (typeSetMap.get(budget.ASI_MFM_Sub_brand_Code__c) == null || typeSetMap.get(budget.ASI_MFM_Sub_brand_Code__c) == 'Original Budget')){
                        typeSetMap.put(budget.ASI_MFM_Sub_brand_Code__c, budget.ASI_MFM_Type__c);
                    }else if(budget.ASI_MFM_Type__c == 'LE2' && (typeSetMap.get(budget.ASI_MFM_Sub_brand_Code__c) == null || typeSetMap.get(budget.ASI_MFM_Sub_brand_Code__c) == 'Original Budget' || typeSetMap.get(budget.ASI_MFM_Sub_brand_Code__c) == 'LE1') ){
                        typeSetMap.put(budget.ASI_MFM_Sub_brand_Code__c, budget.ASI_MFM_Type__c);
                    }else if(budget.ASI_MFM_Type__c == 'LE3' && (typeSetMap.get(budget.ASI_MFM_Sub_brand_Code__c) == null || typeSetMap.get(budget.ASI_MFM_Sub_brand_Code__c) == 'Original Budget' || typeSetMap.get(budget.ASI_MFM_Sub_brand_Code__c) == 'LE1' || typeSetMap.get(budget.ASI_MFM_Sub_brand_Code__c) == 'LE2')){
                        typeSetMap.put(budget.ASI_MFM_Sub_brand_Code__c, budget.ASI_MFM_Type__c);
                    }else if(budget.ASI_MFM_Type__c == 'LE4' && (typeSetMap.get(budget.ASI_MFM_Sub_brand_Code__c) == null || typeSetMap.get(budget.ASI_MFM_Sub_brand_Code__c) == 'Original Budget' || typeSetMap.get(budget.ASI_MFM_Sub_brand_Code__c) == 'LE1' || typeSetMap.get(budget.ASI_MFM_Sub_brand_Code__c) == 'LE2' || typeSetMap.get(budget.ASI_MFM_Sub_brand_Code__c) == 'LE3')){
                        typeSetMap.put(budget.ASI_MFM_Sub_brand_Code__c, budget.ASI_MFM_Type__c);
                    }
                }
                for(ASI_MFM_Budget__c budget:budgetList){
                    if(budget.ASI_MFM_Type__c == typeSetMap.get(budget.ASI_MFM_Sub_brand_Code__c)){
                        if(budgetMap.get(budget.ASI_MFM_Sub_brand_Code__c) == null){
                            budgetMap.put(budget.ASI_MFM_Sub_brand_Code__c, Integer.valueOf(budget.ASI_CRM_Amount__c));
                        }else{
                            budgetMap.put(budget.ASI_MFM_Sub_brand_Code__c, budgetMap.get(budget.ASI_MFM_Sub_brand_Code__c) + Integer.valueOf(budget.ASI_CRM_Amount__c));
                        }
                    }
                }
            }
            if(budgetMap == null){
                return -1;
            }else{
                return (budgetMap.get(subBrand) == null)?-1:budgetMap.get(subBrand);
            }
        }
        
        private Integer calcUsedBudget(String fiscalYear, Id subBrand, Id salesPerson){
            if(budgetUsedMap.size() == 0){
                budgetUsedMap = new Map<Id, Integer>();
                List<ASI_CRM_Call_Detail__c> callDetailList = [Select ASI_CRM_Activity_Sub_brand_1__c, ASI_CRM_Status__c, ASI_CRM_Actual_Amount__c, ASI_CRM_Planned_Amount__c 
                        From ASI_CRM_Call_Detail__c 
                        Where ASI_CRM_Call_Plan__r.ASI_CRM_Sys_Fiscal_Year__c = :fiscalYear And ASI_CRM_Call_Plan__r.OwnerId = :salesPerson];
                for(ASI_CRM_Call_Detail__c detail:callDetailList){
                    if(budgetUsedMap.get(detail.ASI_CRM_Activity_Sub_brand_1__c) == null){
                        if(detail.ASI_CRM_Status__c == 'Draft'){
                            budgetUsedMap.put(detail.ASI_CRM_Activity_Sub_brand_1__c, Integer.valueOf((detail.ASI_CRM_Planned_Amount__c == null)?0:detail.ASI_CRM_Planned_Amount__c));
                        }else{
                            budgetUsedMap.put(detail.ASI_CRM_Activity_Sub_brand_1__c, Integer.valueOf((detail.ASI_CRM_Actual_Amount__c == null)?0:detail.ASI_CRM_Actual_Amount__c));
                        }
                    }else{
                        if(detail.ASI_CRM_Status__c == 'Draft'){
                            budgetUsedMap.put(detail.ASI_CRM_Activity_Sub_brand_1__c, budgetUsedMap.get(detail.ASI_CRM_Activity_Sub_brand_1__c) + Integer.valueOf((detail.ASI_CRM_Planned_Amount__c == null)?0:detail.ASI_CRM_Planned_Amount__c));
                        }else{
                            budgetUsedMap.put(detail.ASI_CRM_Activity_Sub_brand_1__c, budgetUsedMap.get(detail.ASI_CRM_Activity_Sub_brand_1__c) + Integer.valueOf((detail.ASI_CRM_Actual_Amount__c == null)?0:detail.ASI_CRM_Actual_Amount__c));
                        }
                    }
                }                                          
            }
            system.debug('Check' + calcBudget(fiscalYear, subBrand, salesPerson) + ' ' + budgetUsedMap.get(subBrand) + ' remain ' + (calcBudget(fiscalYear, subBrand, salesPerson) - budgetUsedMap.get(subBrand)));
            return Integer.valueOf((calcBudget(fiscalYear, subBrand, salesPerson) - budgetUsedMap.get(subBrand)));
        }
        
    private String numberWithCommas(Integer x) {
            String regex = '(\\d)(?=(\\d{3})+$)';
            return String.valueOf(x).replaceAll(regex, '$1,');
    }

    /*********************************************************************************
     * Description: Wrapper Class to Group the Detail lines by Brand
     *
    *********************************************************************************/
    public Class visitLinesGrouped{
        public ID brandID{ get;set; }
        public String brandName{ get;set; }
        public decimal total {get;set;}
        public List<visitLinesDetail> visitLines {get; set;}
    }

    /*********************************************************************************
     * Description: Wrapper Class to match the detail by the total number of attendees
     *
    *********************************************************************************/
    public Class visitLinesDetail{
        public Decimal totalAttendees{ get;set; }
        public ASI_CRM_Call_Detail__c visitLine {get; set;}
    }
 
    /*********************************************************************************
     * Description: Wrapper Class for Approval History
     *
    *********************************************************************************/   
    public Class approvalDetail{
        public ProcessInstanceHistory history{get;set;}
        public String title{get;set;}
    }
}