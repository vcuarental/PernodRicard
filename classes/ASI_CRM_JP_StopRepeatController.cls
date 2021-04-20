public with sharing class ASI_CRM_JP_StopRepeatController{
    private ASI_CRM_Call_Detail__c detail;
    private List<ASI_CRM_Call_Detail__c> detailList = new List<ASI_CRM_Call_Detail__c>();

    public ASI_CRM_JP_StopRepeatController(ApexPages.StandardController controller){
        detail = (ASI_CRM_Call_Detail__c)controller.getRecord();
        detail = [Select Id, ASI_CRM_Original_Call_Detail__c From ASI_CRM_Call_Detail__c Where Id = :detail.Id];
        if(detail.ASI_CRM_Original_Call_Detail__c == null){
            detailList = [Select Id, ASI_CRM_Repeat_End_Date__c From ASI_CRM_Call_Detail__c Where ASI_CRM_Original_Call_Detail__c = :detail.Id Or Id = :detail.Id];
        }else{
            detailList = [Select Id, ASI_CRM_Repeat_End_Date__c From ASI_CRM_Call_Detail__c Where ASI_CRM_Original_Call_Detail__c = :detail.ASI_CRM_Original_Call_Detail__c Or Id = :detail.ASI_CRM_Original_Call_Detail__c];
        }   
    }
    
    public PageReference save(){
        for(ASI_CRM_Call_Detail__c detail:detailList){
            detail.ASI_CRM_Repeat_End_Date__c = Date.valueOf(System.now());
        }
        update detailList;
        PageReference detailPage = new ApexPages.StandardController(detail).view();
        detailPage.setRedirect(true);
        return detailPage;
    }
}