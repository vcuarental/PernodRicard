/*********************************************************************************
 * Name:ASI_TnE_CashAdvController
 * Description: Component Controller for TnE Cash Advance requistition
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 6/12/2015         Laputa: Hank            Created
*********************************************************************************/
public without sharing class ASI_TnE_CashAdvController{
    public String currentHeaderId{get;set;}
    public ASI_TnE_Cash_Advance_Pre_Approval__c header;
    public String recordDate;
    public List<approvalDetail> approvalDetails;
    public Integer numOfApprovals{get;set;}
    public ASI_TnE_CashAdvController(){
        system.debug('Check Header: ' + header + ' Id:' + currentHeaderId);  
    }
    public void setcurrentHeaderId(String s){
        currentHeaderId = s;
    }
    public String getRecordDate(){
        if(recordDate == null){
            getHeader();
        }
        return recordDate;
    }
    public ASI_TnE_Cash_Advance_Pre_Approval__c getHeader(){
        if(header == null && currentHeaderId != null) {
            header = [Select Id, 
                             Name, 
                             createddate,
                             RecordType.DeveloperName, 
                             ASI_TnE_Country_of_Travel__c, 
                             ASI_TnE_FX_Rate__c, 
                             ASI_TnE_No_of_Person_Travel__c, 
                             ASI_TnE_Reason_for_Cash_Advance__c, 
                             ASI_TnE_Required_Amount__c,
                             ASI_TnE_Requested_Employee__c,
                             ASI_TnE_Requested_Employee__r.Name, 
                             ASI_TnE_Required_Currency__c, 
                             ASI_TnE_Status__c,
                      		 ASI_TnE_Requested_Employee__r.ASI_TnE_Sub_Ledger__c From ASI_TnE_Cash_Advance_Pre_Approval__c Where Id = :currentHeaderId];
            recordDate = header.createddate.format();
        }
        return header;
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
    
    public Integer getNumOfApprovals(){
        if(approvalDetails == null){
            getapprovalDetails();
        }
        return numOfApprovals;
    }
    
    //Approval History
    public Class approvalDetail{
        public ProcessInstanceHistory history{get;set;}
        public String title{get;set;}
    }
}