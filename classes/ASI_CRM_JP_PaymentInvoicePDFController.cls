/*********************************************************************************
 * Name:ASI_CRM_JP_PaymentInvoicePDFController
 * Description: Controller to handle the data of Payment Invoice PDF Generation.
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 18/11/2014       Laputa: Conrad          Created
*********************************************************************************/
public with sharing class ASI_CRM_JP_PaymentInvoicePDFController{ 
        
        public String currentHeaderId;
        public string init;
        public List<ASI_CRM_Payment_Invoice_Line_Item__c> details;
        public List<cashPmtGroup> cashDetailsGroup;
        public ASI_CRM_Payment_Invoice__c Header;
        public decimal totalAmount {get;set;}
        public decimal totalTargetVol {get;set;}
        public decimal totalProResult {get;set;}
        public decimal totalTaxAmt {get;set;}
        public decimal lineTtlAmt {get;set;}
        public decimal totalActualQty {get;set;}
        public List<approvalDetail> approvalDetails;
        public Integer numOfApprovals{get;set;}
        public Integer numOfDetails{get;set;}
        public Integer numOfCashDetails{get;set;}
        public String currentAction {get; set;}
        public Boolean checkIfJP;
                
        public ASI_CRM_JP_PaymentInvoicePDFController()
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
        
        public void init()
        {
           
        }
        
        public Boolean getCheckIfJP(){
            return (UserInfo.getLanguage() != 'en_US');
        }
        
        public boolean getIsFinalPrint()
        { 
            return (currentAction!=null && 'finalPrint'.equals(currentAction));
        }
        
        public void checkForUpdate(){
            //getHeader();
            //System.debug('Update 0');
            //if(currentAction!=null && 'finalPrint'.equals(currentAction)){
            //    System.debug('Update 1');
            //    if (Header.ASI_CRM_Status__c == 'Draft'){
            //        System.debug('Update 2');
            //        Header.ASI_CRM_Status__c = 'Approval In Progress';
            //        update Header;
            //    }
            //}
        }
        
        public List<approvalDetail> getapprovalDetails() {
            List<approvalDetail> details = new List<approvalDetail>();
            
            system.debug('getapprovalDetails INSIDE ' + currentHeaderId);
            
            if (details.size() == 0 && currentHeaderId != null){
                List<ProcessInstance> pList = [SELECT Id, (SELECT CreatedDate, Id, StepStatus, Comments, ActorId, Actor.Name FROM StepsAndWorkitems Order By CreatedDate DESC, StepStatus DESC) FROM ProcessInstance Where TargetObjectId = :currentHeaderId Order By CreatedDate DESC Limit 1];
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
                    Boolean byPassPending = false;
                    if(p.StepsAndWorkitems.size() != 0 && p.StepsAndWorkitems[0].StepStatus == 'Approved'){
                        byPassPending = true;
                    }
                    for (ProcessInstanceHistory his:p.StepsAndWorkitems) {
                        if(his.StepStatus != 'Reassigned' && !(byPassPending && his.StepStatus == 'Pending')){
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
        
        public List<ASI_CRM_Payment_Invoice_Line_Item__c> getDetails()
        {
           if (Details == null && currentHeaderId != null) 
           {
             Map<String, Schema.SObjectField> contractDetailsFieldMap = Schema.SObjectType.ASI_CRM_Payment_Invoice_Line_Item__c.fields.getMap();
             String theQuery = 'Select ';
        
             for(String fields  : contractDetailsFieldMap.keySet()){
                theQuery += fields + ' ,';
             }
             
             if (header == null && currentHeaderId != null){
                 getHeader();
             }
         
             thequery = theQuery.subString(0,theQuery.length()-1);
             thequery += ', ASI_CRM_Purchase_Contract_Line_Item__r.ASI_CRM_Purchase_Contract__r.ASI_CRM_Outlet__r.name, ' +
             ' ASI_CRM_Purchase_Contract_Line_Item__r.ASI_CRM_Purchase_Contract__r.ASI_CRM_BS_Retailer_Ship_To__r.name, ' +
             ' ASI_CRM_Purchase_Contract_Line_Item__r.ASI_CRM_Purchase_Contract__r.ASI_CRM_BS_Retailer_Ship_To__r.ASI_CRM_Customer_Name_Kanji__c, ' +
             ' ASI_CRM_Purchase_Contract_Line_Item__r.ASI_CRM_Purchase_Contract__r.ASI_CRM_BS_Retailer_Ship_To__r.ASI_CRM_CN_CRM_Code__c, ' +
             ' ASI_CRM_Purchase_Contract_Line_Item__r.ASI_CRM_Purchase_Contract__r.ASI_CRM_Wholesaler__r.name, ' +
             ' ASI_CRM_Purchase_Contract_Line_Item__r.ASI_CRM_Purchase_Contract__r.ASI_CRM_Wholesaler__r.ASI_CRM_Customer_Name_Kanji__c, ' +
             ' ASI_CRM_Purchase_Contract_Line_Item__r.ASI_CRM_AP_Code__r.name, ' +
             ' ASI_CRM_Contract_No__r.ASI_CRM_Wholesaler__r.name, ' +
             ' ASI_CRM_SKU__r.Name, ' +
             ' ASI_CRM_SKU__r.ASI_MFM_SKU_Code__c, ' +
             ' ASI_CRM_SKU__r.ASI_MFM_SKU_Description__c, ' +
             ' ASI_CRM_Contract_No__r.ASI_CRM_Wholesaler__r.ASI_CRM_Customer_Name_Kanji__c, ' +
             ' ASI_CRM_Purchase_Contract_Line_Item__r.ASI_CRM_AP_Code__r.ASI_CRM_AP_Description_JP__c, ' +
             ' ASI_CRM_Purchase_Contract_Line_Item__r.ASI_CRM_Item_Group__r.name, ' +
             ' ASI_CRM_Purchase_Contract_Line_Item__r.ASI_CRM_Rebate_Type__c, ' +
             ' ASI_CRM_Purchase_Contract_Line_Item__r.ASI_CRM_Item_Group__r.ASI_MFM_Item_Group_Code__c, ' +
             ' ASI_CRM_Purchase_Contract_Line_Item__r.ASI_CRM_Item_Group__c, ' +
             ' ASI_CRM_Purchase_Contract_Line_Item__r.ASI_CRM_Condition_Of__c, ' +
             ' ASI_CRM_Purchase_Contract_Line_Item__r.ASI_CRM_Condition_to__c, ' +
             ' ASI_CRM_Purchase_Contract_Line_Item__r.ASI_CRM_Condition__c, ' +
             ' ASI_CRM_Purchase_Contract_Line_Item__r.ASI_CRM_Purchase_Contract__r.owner.name, ' +
             ' ASI_CRM_Purchase_Contract_Line_Item__r.ASI_CRM_Purchase_Contract__r.name, ' +
             ' ASI_CRM_Purchase_Contract_Line_Item__r.ASI_CRM_Purchase_Contract__r.ASI_CRM_End_Date__c, ' +
             ' ASI_CRM_Purchase_Contract_Line_Item__r.ASI_CRM_Unit_Price__c, ' +
             ' ASI_CRM_Purchase_Contract_Line_Item__r.ASI_CRM_Target_Volume__c ' +
             ' From ASI_CRM_Payment_Invoice_Line_Item__c where (Not RecordType.DeveloperName Like \'%ASI_CRM_JP_SPTD_Cash_Invoice%\') AND ASI_CRM_Payment_Invoice__c = ' + '\'' + currentHeaderId + '\' AND (((ASI_CRM_Sales_Result__c != 0 OR ASI_CRM_Actual_Quantity__c != 0) AND RecordType.Name = \'JP SPTD FOC Invoice Line Item\') OR RecordType.Name != \'JP SPTD FOC Invoice Line Item\') ';
             
             if(header.recordtype.Name.contains('FOC')){
                 theQuery += ' ORDER BY ASI_CRM_Purchase_Contract_Line_Item__r.ASI_CRM_AP_Code__r.name ASC, ASI_CRM_Purchase_Contract_Line_Item__r.ASI_CRM_Purchase_Contract__r.name ASC';
             }else{
                 theQuery += ' ORDER BY name ASC';
             }
             
             Details = (List<ASI_CRM_Payment_Invoice_Line_Item__c>)Database.query(theQuery); 
             
             totalAmount = 0;
             totalTargetVol = 0;
             totalProResult = 0;
             totalTaxAmt = 0;
             lineTtlAmt = 0;
             totalActualQty = 0;
             for (ASI_CRM_Payment_Invoice_Line_Item__c item:Details) {
                 if (item.ASI_CRM_Actual_Amount__c != null) {
                     totalAmount += item.ASI_CRM_Actual_Amount__c;
                 }
                 if (item.ASI_CRM_Tax_Amount__c != null) {
                     totalTaxAmt += item.ASI_CRM_Tax_Amount__c;
                 }
                 if (item.ASI_CRM_Line_Total_Amount__c != null) {
                     lineTtlAmt +=item.ASI_CRM_Line_Total_Amount__c;
                 }
                 if(item.ASI_CRM_Purchase_Contract_Line_Item__r.ASI_CRM_Target_Volume__c != null){
                     totalTargetVol += item.ASI_CRM_Purchase_Contract_Line_Item__r.ASI_CRM_Target_Volume__c;
                 }
                 if(item.ASI_CRM_Sales_Result__c != null){
                     totalProResult += item.ASI_CRM_Sales_Result__c;
                 }
                 if(item.ASI_CRM_Actual_Quantity__c != null){
                     totalActualQty += item.ASI_CRM_Actual_Quantity__c;
                 }
                 
                 if(String.isNotBlank(item.ASI_CRM_Purchase_Contract_Line_Item__r.ASI_CRM_Purchase_Contract__r.ASI_CRM_Wholesaler__r.name)) {
                     List<String> splitedNameList = item.ASI_CRM_Purchase_Contract_Line_Item__r.ASI_CRM_Purchase_Contract__r.ASI_CRM_Wholesaler__r.name.split('(?<=\\G.......)');
                     item.ASI_CRM_Purchase_Contract_Line_Item__r.ASI_CRM_Purchase_Contract__r.ASI_CRM_Wholesaler__r.name = '';
                     for(String name : splitedNameList) {
                         System.debug(name);
                         item.ASI_CRM_Purchase_Contract_Line_Item__r.ASI_CRM_Purchase_Contract__r.ASI_CRM_Wholesaler__r.name += name + '\n';
                     }
                     System.debug(item.ASI_CRM_Purchase_Contract_Line_Item__r.ASI_CRM_Purchase_Contract__r.ASI_CRM_Wholesaler__r.name);
                 }
             }         
                       
           }
           numOfDetails = details.size();
           return Details;
        }
        
        public List<cashPmtGroup> getCashDetailsGroup()
        {    
           List<cashPmtGroup> PmtAllgroup = new List<cashPmtGroup>();
           if (PmtAllgroup.size() == 0 && currentHeaderId != null) 
           {
             Map<String, Schema.SObjectField> contractDetailsFieldMap = Schema.SObjectType.ASI_CRM_Payment_Invoice_Line_Item__c.fields.getMap();
             String theQuery = 'Select ';
        
             for(String fields  : contractDetailsFieldMap.keySet()){
                theQuery += fields + ' ,';
             }
         
             thequery = theQuery.subString(0,theQuery.length()-1);
             thequery += ', ASI_CRM_Purchase_Contract_Line_Item__r.ASI_CRM_Purchase_Contract__r.ASI_CRM_Outlet__r.name, ' +
             ' ASI_CRM_Payment_Invoice_Item_Owner__r.ASI_TnE_Sub_Ledger__c, ' +
             ' ASI_CRM_Payment_Invoice_Item_Owner__r.ASI_KOR_User_Branch_Code__c, ' +
             ' ASI_CRM_Payment_Invoice_Item_Owner__r.Manager.Name, ' + 
             ' ASI_CRM_Payment_Invoice_Item_Owner__r.Manager.ASI_TnE_Sub_Ledger__c, ' +
             ' ASI_CRM_Payment_Invoice_Item_Owner__r.Manager.ASI_KOR_User_Branch_Code__c, ' +
             ' ASI_CRM_Payment_Invoice_Item_Owner__r.Name, ' +
             ' ASI_CRM_SKU__r.Name, ' +
             ' ASI_CRM_SKU__r.ASI_MFM_SKU_Code__c, ' +
             ' ASI_CRM_SKU__r.ASI_MFM_SKU_Description__c, ' +
             ' ASI_CRM_Contract_No__r.ASI_CRM_Wholesaler__r.name, ' +
             ' ASI_CRM_Contract_No__r.ASI_CRM_Wholesaler__r.ASI_CRM_Customer_Name_Kanji__c, ' +
             ' ASI_CRM_Purchase_Contract_Line_Item__r.ASI_CRM_Purchase_Contract__r.ASI_CRM_BS_Retailer_Ship_To__r.name, ' +
             ' ASI_CRM_Purchase_Contract_Line_Item__r.ASI_CRM_Purchase_Contract__r.ASI_CRM_BS_Retailer_Ship_To__r.ASI_CRM_CN_CRM_Code__c, ' +
             ' ASI_CRM_Purchase_Contract_Line_Item__r.ASI_CRM_Purchase_Contract__r.ASI_CRM_Wholesaler__r.name, ' +
             ' ASI_CRM_Purchase_Contract_Line_Item__r.ASI_CRM_Purchase_Contract__r.ASI_CRM_Staff_Code__c, ' +
             ' ASI_CRM_Purchase_Contract_Line_Item__r.ASI_CRM_AP_Code__r.name, ' +
             ' ASI_CRM_Purchase_Contract_Line_Item__r.ASI_CRM_AP_Code__r.ASI_CRM_AP_Description_JP__c, ' +
             ' ASI_CRM_Purchase_Contract_Line_Item__r.ASI_CRM_Item_Group__r.name, ' +
             ' ASI_CRM_Purchase_Contract_Line_Item__r.ASI_CRM_Rebate_Type__c, ' +
             ' ASI_CRM_Purchase_Contract_Line_Item__r.ASI_CRM_Item_Group__r.ASI_MFM_Item_Group_Code__c, ' +
             ' ASI_CRM_Purchase_Contract_Line_Item__r.ASI_CRM_Item_Group__c, ' +
             ' ASI_CRM_Purchase_Contract_Line_Item__r.ASI_CRM_Condition_Of__c, ' +
             ' ASI_CRM_Purchase_Contract_Line_Item__r.ASI_CRM_Condition_to__c, ' +
             ' ASI_CRM_Purchase_Contract_Line_Item__r.ASI_CRM_Condition__c, ' +
             ' ASI_CRM_Purchase_Contract_Line_Item__r.ASI_CRM_Purchase_Contract__r.owner.name, ' +
             ' ASI_CRM_Purchase_Contract_Line_Item__r.ASI_CRM_Purchase_Contract__r.name, ' +
             ' ASI_CRM_Purchase_Contract_Line_Item__r.ASI_CRM_Unit_Price__c, ' +
             ' ASI_CRM_Purchase_Contract_Line_Item__r.ASI_CRM_Purchase_Contract__r.ASI_CRM_End_Date__c, ' +
             ' ASI_CRM_Purchase_Contract_Line_Item__r.ASI_CRM_Target_Volume__c, ' +
             ' ASI_CRM_Payment_Invoice__r.RecordTypeId ' +
             ' From ASI_CRM_Payment_Invoice_Line_Item__c where (Not RecordType.DeveloperName Like \'%ASI_CRM_JP_Indirect_Rebate_Invoice%\') AND ASI_CRM_Payment_Invoice__c = ' + '\'' + currentHeaderId + '\' AND (((ASI_CRM_Actual_Amount__c != 0 OR ASI_CRM_Actual_Quantity__c != 0) AND RecordType.Name = \'JP SPTD FOC Invoice Line Item\') OR RecordType.Name != \'JP SPTD FOC Invoice Line Item\') ORDER BY ASI_CRM_Payment_Invoice_Item_Owner__r.ManagerId ASC, Name ASC';
         
             List<ASI_CRM_Payment_Invoice_Line_Item__c> itemList = (List<ASI_CRM_Payment_Invoice_Line_Item__c>)Database.query(theQuery);
             List<ASI_CRM_Payment_Invoice_Line_Item__c> groupList = new List<ASI_CRM_Payment_Invoice_Line_Item__c>();
             Id ownerId;
             String ownerInfo;
             decimal ttlSalesTgt = 0;
             decimal ttlQty = 0;
             decimal ttlActualAmt = 0;
             decimal ttlActualQty = 0;
             
             for(integer i = 0; i < itemList.size(); i++) {
                 if (i == 0){
                     ownerId = itemList.get(i).ASI_CRM_Payment_Invoice_Item_Owner__r.ManagerId;
                     if (itemList.get(i).ASI_CRM_Payment_Invoice_Item_Owner__r.Manager.ASI_TnE_Sub_Ledger__c != null) {
                         ownerInfo = itemList.get(i).ASI_CRM_Payment_Invoice_Item_Owner__r.Manager.ASI_TnE_Sub_Ledger__c + ' ';
                     } else {
                         ownerInfo = '';
                     }
                     ownerInfo += itemList.get(i).ASI_CRM_Payment_Invoice_Item_Owner__r.Manager.Name; 
                     if (itemList.get(i).ASI_CRM_Payment_Invoice_Item_Owner__r.Manager.ASI_KOR_User_Branch_Code__c != null) {
                         ownerInfo += '/' + itemList.get(i).ASI_CRM_Payment_Invoice_Item_Owner__r.Manager.ASI_KOR_User_Branch_Code__c;
                     }
                     groupList.add(itemList.get(i));
                     ttlSalesTgt += (itemList.get(i).ASI_CRM_Purchase_Contract_Line_Item__r.ASI_CRM_Target_Volume__c == null)?0:itemList.get(i).ASI_CRM_Purchase_Contract_Line_Item__r.ASI_CRM_Target_Volume__c;
                     ttlQty += (itemList.get(i).ASI_CRM_Sales_Result__c == null)?0:itemList.get(i).ASI_CRM_Sales_Result__c;
                     ttlActualAmt += (itemList.get(i).ASI_CRM_Final_Amount__c == null)?0:itemList.get(i).ASI_CRM_Final_Amount__c;
                     ttlActualQty += (itemList.get(i).ASI_CRM_Actual_Quantity__c == null)?0:itemList.get(i).ASI_CRM_Actual_Quantity__c;
                 } else if (ownerId != itemList.get(i).ASI_CRM_Payment_Invoice_Item_Owner__r.ManagerId) {
                     cashPmtGroup pmtGroup = new cashPmtGroup();
                     pmtGroup.title = ownerInfo;
                     pmtGroup.details = groupList;
                     pmtGroup.ttlSalesTgt = ttlSalesTgt;
                     pmtGroup.ttlQty = ttlQty;
                     pmtGroup.ttlActualQty = ttlActualQty;
                     pmtGroup.ttlActualAmt = ttlActualAmt;
                     PmtAllgroup.add(pmtGroup);
                     ttlSalesTgt = 0;
                     ttlQty = 0;
                     ttlActualAmt = 0;
                     ttlActualQty = 0;
                     groupList = new List<ASI_CRM_Payment_Invoice_Line_Item__c>();
                     ownerId = itemList.get(i).ASI_CRM_Payment_Invoice_Item_Owner__r.ManagerId;
                     if (itemList.get(i).ASI_CRM_Payment_Invoice_Item_Owner__r.Manager.ASI_TnE_Sub_Ledger__c != null) {
                         ownerInfo = itemList.get(i).ASI_CRM_Payment_Invoice_Item_Owner__r.Manager.ASI_TnE_Sub_Ledger__c + ' ';
                     } else {
                         ownerInfo = '';
                     }
                     ownerInfo += itemList.get(i).ASI_CRM_Payment_Invoice_Item_Owner__r.Manager.Name; 
                     if (itemList.get(i).ASI_CRM_Payment_Invoice_Item_Owner__r.Manager.ASI_KOR_User_Branch_Code__c != null) {
                         ownerInfo += ' / ' + itemList.get(i).ASI_CRM_Payment_Invoice_Item_Owner__r.Manager.ASI_KOR_User_Branch_Code__c;
                     }
                     ttlSalesTgt += (itemList.get(i).ASI_CRM_Purchase_Contract_Line_Item__r.ASI_CRM_Target_Volume__c == null)?0:itemList.get(i).ASI_CRM_Purchase_Contract_Line_Item__r.ASI_CRM_Target_Volume__c;
                     ttlQty += (itemList.get(i).ASI_CRM_Sales_Result__c == null)?0:itemList.get(i).ASI_CRM_Sales_Result__c;
                     ttlActualQty += (itemList.get(i).ASI_CRM_Actual_Quantity__c == null)?0:itemList.get(i).ASI_CRM_Actual_Quantity__c; 
                     ttlActualAmt += (itemList.get(i).ASI_CRM_Final_Amount__c == null)?0:itemList.get(i).ASI_CRM_Final_Amount__c;
                     groupList.add(itemList.get(i));
                 } else if (ownerId == itemList.get(i).ASI_CRM_Payment_Invoice_Item_Owner__r.ManagerId) {
                     groupList.add(itemList.get(i));
                     ttlSalesTgt += (itemList.get(i).ASI_CRM_Purchase_Contract_Line_Item__r.ASI_CRM_Target_Volume__c == null)?0:itemList.get(i).ASI_CRM_Purchase_Contract_Line_Item__r.ASI_CRM_Target_Volume__c;
                     ttlQty += (itemList.get(i).ASI_CRM_Sales_Result__c == null)?0:itemList.get(i).ASI_CRM_Sales_Result__c;
                     ttlActualAmt += (itemList.get(i).ASI_CRM_Final_Amount__c == null)?0:itemList.get(i).ASI_CRM_Final_Amount__c;
                     ttlActualQty += (itemList.get(i).ASI_CRM_Actual_Quantity__c == null)?0:itemList.get(i).ASI_CRM_Actual_Quantity__c;
                 }
                 if (i == itemList.size() - 1) {
                     cashPmtGroup pmtGroup = new cashPmtGroup();
                     pmtGroup.title = ownerInfo;
                     pmtGroup.details = groupList;
                     pmtGroup.ttlSalesTgt = ttlSalesTgt;
                     pmtGroup.ttlQty = ttlQty;
                     pmtGroup.ttlActualAmt = ttlActualAmt;
                     pmtGroup.ttlActualQty = ttlActualQty;
                     PmtAllgroup.add(pmtGroup);
                 }
             
             }
             
                       
           }
           numOfCashDetails = PmtAllGroup.size();
           return PmtAllgroup;
        }    
        
        public ASI_CRM_Payment_Invoice__c getHeader()
        {    
            if (header == null && currentHeaderId != null) 
            {
             Map<String, Schema.SObjectField> contractFieldMap = Schema.SObjectType.ASI_CRM_Payment_Invoice__c.fields.getMap();
             String theQuery = 'Select ';
        
             for(String fields  : contractFieldMap.keySet()){
                theQuery += fields + ' ,';
             }
         
             thequery = theQuery.subString(0,theQuery.length()-1);
             thequery += ', recordtype.developername, owner.name, createdby.name, ' +
             ' ASI_CRM_Approver_1__r.name, ' +
             ' ASI_CRM_Approver_2__r.name, ' +
             ' ASI_CRM_Approver_3__r.name, ' +
             ' ASI_CRM_Approver_4__r.name, ' +
             ' ASI_CRM_Approver_5__r.name, ' +
             ' ASI_CRM_Approver_6__r.name' +
             ' , ASI_CRM_Customer_Ship_Pay_To__r.ASI_CRM_CN_Address__c, ASI_CRM_Customer_Ship_Pay_To__r.ASI_CRM_Customer_Name_Kanji__c, ASI_CRM_Customer_Ship_Pay_To__r.ASI_CRM_CN_CRM_Code__c, ASI_CRM_Customer_Ship_Pay_To__r.name, ASI_CRM_Pay_To__r.ASI_CRM_Pay_to_No__c, ASI_CRM_Pay_To__r.Name, ASI_CRM_Pay_To__r.ASI_CRM_Account_Number__c, ASI_CRM_Pay_To__r.ASI_CRM_Pay_to_Name__c, recordtype.Name' + 
             ' From ASI_CRM_Payment_Invoice__c where  ID = ' + '\'' + currentHeaderId + '\' ';
         
             List<ASI_CRM_Payment_Invoice__c> paymentInvoice = (List<ASI_CRM_Payment_Invoice__c>)Database.query(theQuery); 
             if (paymentInvoice.size() > 0)
                 header = paymentInvoice.get(0);
             }
             return header;
        }

    public String getPayToName(){
        return splitLine(header.ASI_CRM_Pay_To__r.Name, Integer.valueOf(ASI_CRM_JP_Text_Wrap__c.getOrgDefaults().ASI_CRM_JP_Payment_Invoice_Pay_To_Name__c));
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
        
        public Class cashPmtGroup{
            public List<ASI_CRM_Payment_Invoice_Line_Item__c> details{get;set;}
            public String title{get;set;}
            public decimal ttlSalesTgt{get;set;}
            public decimal ttlQty{get;set;}
            public decimal ttlActualQty{get;set;}
            public decimal ttlActualAmt{get;set;}
        }

    public static String splitLine(String inputString, Integer cutNumber){
        if (inputString == null) {
            return '';
        }
        String outputString ='';

        // Split string into list of characters
        List<String> stringCharacters = inputString.split('');
        // Note that the first element in the collection will be "empty":
        stringCharacters.remove(0);

        Decimal count = 0;
        for (Integer i = 0; i < stringCharacters.size(); i++) {
            String character = stringCharacters[i];

            // Count the number of character. Half-width character count as 0.5
            count += isHalfWidthCharacter(character) ? 0.5 : 1;

            // If current string count > cutNumber, insert line break in between
            if (count > cutNumber) {
                outputString = inputString.substring(0, i) + '<br/>' + inputString.substring(i, inputString.length());
                // Reset count
                count = 0;
            }
        }

        if (String.isEmpty(outputString)) {
            return inputString;
        }

        return outputString;
    }

    public static Boolean isHalfWidthCharacter(String character){
        Pattern p = Pattern.compile('[\\w\\p{P}ｱ-ﾝﾞﾟ]');
        Matcher m = p.matcher(character);

        return m.matches();
    }
}