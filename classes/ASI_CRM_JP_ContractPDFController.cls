/*********************************************************************************
 * Name:ASI_CRM_JP_ContractPDFController
 * Description: Controller to handle Purchase Contract Data. Can handle multiple recordtypes
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 11/18/2014       Laputa: Conrad          Created
*********************************************************************************/
public with sharing class ASI_CRM_JP_ContractPDFController{
        
        public String currentHeaderId;
        public string init;
        public List<ASI_CRM_Purchase_Contract_Line_Item__c> details;
        public ASI_CRM_Purchase_Contract__c Header;
        public List<approvalDetail> approvalDetails;
        public Integer numOfApprovals{get;set;}
        public Boolean checkIfJP;
        public String approverLanguage;
        public String pageMargin {get;set;}
        public String firstMargin {get;set;}
          
        public ASI_CRM_JP_ContractPDFController()
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
        public String getPageMargin(){
            if(pageMargin == null){
                setMargin();
            }
            return pageMargin;
        }
        public String getFirstMargin(){
            if(firstMargin == null){
                setMargin();
            }
            return firstMargin;
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
             Map<String, Schema.SObjectField> contractFieldMap = Schema.SObjectType.ASI_CRM_Purchase_Contract__c.fields.getMap();
             String theQuery = 'Select ';
        
             for(String fields  : contractFieldMap.keySet()){
                theQuery += fields + ' ,';
             }
         
             thequery = theQuery.subString(0,theQuery.length()-1);
             thequery += ', owner.name, createdby.name From ASI_CRM_Purchase_Contract__c where  ID = ' + '\'' + currentHeaderId + '\' ';
         
             List<ASI_CRM_Purchase_Contract__c> contractList = (List<ASI_CRM_Purchase_Contract__c>)Database.query(theQuery); 
             if (contractList.size() > 0)
                 header = contractList.get(0);
             } 
             
             if (Details == null && currentHeaderId != null) 
             {
                 Map<String, Schema.SObjectField> contractDetailsFieldMap = Schema.SObjectType.ASI_CRM_Purchase_Contract_Line_Item__c.fields.getMap();
                 String theQuery = 'Select ';
        
                 for(String fields  : contractDetailsFieldMap.keySet()){
                    theQuery += fields + ' ,';
                 }
         
                 thequery = theQuery.subString(0,theQuery.length()-1);
                 thequery += 'From ASI_CRM_Purchase_Contract_Line_Item__c where ASI_CRM_Purchase_Contract__c = ' + '\'' + currentHeaderId + '\' ';
         
                 Details = (List<ASI_CRM_Purchase_Contract_Line_Item__c>)Database.query(theQuery); 
                                 
             }
        }
        
        public List<approvalDetail> getapprovalDetails() {
            List<approvalDetail> details = new List<approvalDetail>();
            if (details.size() == 0 && currentHeaderId != null){
                List<ProcessInstance> pList = [SELECT Id, (SELECT CreatedDate, Id, StepStatus, Comments, ActorId, Actor.Name FROM StepsAndWorkitems Order By IsPending DESC, CreatedDate DESC) FROM ProcessInstance Where TargetObjectId = :currentHeaderId Order By CreatedDate DESC Limit 1];
                Set<Id> actoerIdSet = new Set<Id>();
                for (ProcessInstance p:pList) {
                    for (ProcessInstanceHistory his:p.StepsAndWorkitems) {
                        actoerIdSet.add(his.ActorId);
                    }
                }
                Map<Id, User> userMap = new Map<Id, User>([Select Id, title From User Where Id In :actoerIdSet]);
                Map<ID, String> skipCommentMap = retrieveSkipCommentMap(pList);
                system.debug('skipCommentMap ' + skipCommentMap);
                for (ProcessInstance p:pList) {
                    for (ProcessInstanceHistory his:p.StepsAndWorkitems) {
                        if(his.StepStatus != 'Reassigned'){
                            approvalDetail detail = new approvalDetail();
                            detail.title = userMap.get(his.ActorId).title;
                            detail.history = his;
                            if(skipCommentMap.containsKey(his.ActorId)) {
                                detail.additionalComment = skipCommentMap.get(his.ActorId);
                            }
                            details.add(detail);
                        }
                    }
                }
            }
            numOfApprovals = details.size() + 1;
            return details;
        } 
        
        public Map<ID, String> retrieveSkipCommentMap(List<ProcessInstance> pList) {
        
            Map<ID, String> skipMap = new Map<ID, String>();
            Set<ID> actoerIdSet = new Set<ID>();
            if(pList.size() > 0) {
                
                Integer gapCounter = 0;
                List<ProcessInstanceHistory> historyList = pList.get(0).StepsAndWorkitems;
                Map<ID, ProcessInstanceHistory> historyActorMap = new Map<ID, ProcessInstanceHistory>();
                
                Map<ID, List<String>> skippedApproverMap = new Map<ID, List<String>>();
                
                for(ProcessInstanceHistory his : historyList) {
                    if(his.StepStatus == 'Approved') {
                        historyActorMap.put(his.ActorId, his);
                        actoerIdSet.add(his.ActorId);
                    }
                }
                
                List<String> skippedApproverList = new List<String>();
                
                for(Integer i = 1; i < 7 ; i++) {
                
                    ID currentSysApprover = (ID)(Header.get('ASI_CRM_Approver_'+String.valueof(i)+'__c'));
                    
                    if(currentSysApprover == null) {
                        break;
                    }
                    
                    ProcessInstanceHistory tempHis = historyActorMap.get(currentSysApprover);
                    system.debug('currentSysApprover ' + currentSysApprover );
                    system.debug('ASI_CRM_Approver_+String.valueof(i)+__c ' + 'ASI_CRM_Approver_'+String.valueof(i)+'__c');
                    
                    if(!actoerIdSet.contains(currentSysApprover)) {
                        system.debug('(String)(Header.getSObject(ASI_CRM_Approver_+String.valueof(i)+__r).get(Name)) ' + (String)(Header.getSObject('ASI_CRM_Approver_'+String.valueof(i)+'__r').get('Name')));
                        skippedApproverList.add((String)(Header.getSObject('ASI_CRM_Approver_'+String.valueof(i)+'__r').get('Name')));
                    } else if (actoerIdSet.contains(currentSysApprover) && skippedApproverList.size() > 0 ) {
                        system.debug('currentSysApprover ' + currentSysApprover);
                        system.debug('skippedApproverList ' + skippedApproverList);
                        skippedApproverMap.put(currentSysApprover, skippedApproverList);
                        skippedApproverList = new List<String>();
                    }
                }
                
                system.debug('skippedApproverMap ' + skippedApproverMap);
                
                if(skippedApproverMap.size() > 0) {
                    
                    for(ID actorIds : skippedApproverMap.keySet()) {
                        String skippedComment = 'Note: The following approvers have been skipped: ';
                        List<String> skippedApproversList = skippedApproverMap.get(actorIds);
                        
                        for(String skippedApprover : skippedApproversList ) {
                            skippedComment += skippedApprover + ', ';
                        }
                        
                        skippedComment = skippedComment.subString(0,skippedComment.length()-2);
                        
                        skipMap.put(actorIds, skippedComment);
                    }
                }
                
            }
            
            return skipMap;
        }
        
        public List<ASI_CRM_Purchase_Contract_Line_Item__c> getDetails()
        {
           if (Details == null && currentHeaderId != null) 
           {
             Map<String, Schema.SObjectField> contractDetailsFieldMap = Schema.SObjectType.ASI_CRM_Purchase_Contract_Line_Item__c.fields.getMap();
             String theQuery = 'Select ';
        
             for(String fields  : contractDetailsFieldMap.keySet()){
                theQuery += fields + ' ,';
             }
         
             thequery = theQuery.subString(0,theQuery.length()-1);
             thequery += ', ASI_CRM_Item_Group__r.ASI_MFM_Item_Group_Code__c, ASI_CRM_Item_Group__r.name, ASI_CRM_Pay_To__r.ASI_CRM_Pay_to_No__c, ASI_CRM_Pay_To__r.ASI_CRM_Pay_to_Name__c, ASI_CRM_Pay_To__r.Name ' +
             +', ASI_CRM_AP_Code__r.ASI_MFM_AP_Code__c, ASI_CRM_AP_Code__r.name, ASI_CRM_AP_Code__r.ASI_CRM_AP_Description_JP__c  ' +
             ' From ASI_CRM_Purchase_Contract_Line_Item__c where ASI_CRM_Purchase_Contract__c = ' + '\'' + currentHeaderId + '\' ORDER BY ID ASC';
         
             Details = (List<ASI_CRM_Purchase_Contract_Line_Item__c>)Database.query(theQuery);       
                       
            }
            return Details;
        }  
        
        public ASI_CRM_Purchase_Contract__c getHeader()
        {
            if (header == null && currentHeaderId != null) 
            {
             Map<String, Schema.SObjectField> contractFieldMap = Schema.SObjectType.ASI_CRM_Purchase_Contract__c.fields.getMap();
             String theQuery = 'Select ';
             
             
             for(String fields  : contractFieldMap.keySet()){
                theQuery += fields + ' ,';
             }
         
             thequery = theQuery.subString(0,theQuery.length()-1);
             
             thequery += ', ASI_CRM_Approver_1__r.name, ' +
             ' ASI_CRM_Approver_2__r.name, ' +
             ' ASI_CRM_Approver_3__r.name, ' +
             ' ASI_CRM_Approver_4__r.name, ' +
             ' ASI_CRM_Approver_5__r.name, ' +
             ' ASI_CRM_Approver_6__r.name '; 
             
             thequery += ',ASI_CRM_Outlet__r.ASI_CRM_Customer_Name_Kanji__c, ASI_CRM_Outlet__r.ASI_TH_CRM_OutletType__r.ASI_CRM_Channel_Group__c, ASI_CRM_Outlet__r.ASI_TH_CRM_OutletType__r.name, ASI_CRM_Wholesaler__r.ASI_CRM_VN_Channel__c, ASI_CRM_BS_Retailer_Ship_To__r.ASI_CRM_VN_Channel__c, ASI_CRM_Outlet__r.ASI_CRM_VN_Channel__c, recordtype.developername, owner.name, createdby.name, ASI_CRM_Wholesaler__r.ASI_CRM_CN_CRM_Code__c, ASI_CRM_Wholesaler__r.name, ASI_CRM_Wholesaler__r.ASI_CRM_Customer_Name_Kanji__c, ASI_CRM_Wholesaler__r.ASI_CRM_Channel__r.name, ' +
             'ASI_CRM_BS_Retailer_Ship_To__r.ASI_CRM_CN_CRM_Code__c, ASI_CRM_BS_Retailer_Ship_To__r.name, ASI_CRM_BS_Retailer_Ship_To__r.ASI_CRM_Customer_Name_Kanji__c, ASI_CRM_BS_Retailer_Ship_To__r.ASI_CRM_Channel__r.name,' + 
             + ' ASI_CRM_Outlet__r.ASI_CRM_CN_CRM_Code__c, ASI_CRM_Outlet__r.name, ASI_CRM_Outlet__r.ASI_CRM_Channel__r.name, ASI_CRM_Outlet__r.ASI_CRM_CN_Address__c ' +
             ' From ASI_CRM_Purchase_Contract__c where  ID = ' + '\'' + currentHeaderId + '\' ';
         
             List<ASI_CRM_Purchase_Contract__c> contractList = (List<ASI_CRM_Purchase_Contract__c>)Database.query(theQuery); 
             if (contractList.size() > 0)
                 header = contractList.get(0);
             }
             setMargin();
             return header;
        }
        
    public void setMargin(){
        if(header == null && currentHeaderId != null){
            getHeader();
        }
        if(header.RecordType.DeveloperName.contains('ASI_CRM_JP_SPTD_Contract'))   {
                pageMargin = '200px';
                firstMargin = '180px';
        } else 
        if(header.RecordType.DeveloperName.contains('ASI_CRM_JP_Direct_Rebate_Contract'))   {
                pageMargin = '165px';
                firstMargin = '145px';
        } else 
        if(header.RecordType.DeveloperName.contains('ASI_CRM_JP_Indirect_Rebate_Contract'))   {
                pageMargin = '175px';
                firstMargin = '145px';
        } 

    }    
    /*********************************************************************************
     * Description: Wrapper Class for Approval History
     *
    *********************************************************************************/   
        public Class approvalDetail{
            public ProcessInstanceHistory history{get;set;}
            public String title{get;set;}
            public String additionalComment {get;set;}
        }
        
}