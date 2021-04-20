/****************************************

* Created by Stella Li (Introv) 03/19/2015
* Modified by Twinkle LI (Introv) 04/28/2015

****************************************/
public with sharing class ASI_CRM_TW_PlanAttachDownload_Ctrl{
    public list <Attachment> attach{set;get;}
    public string pageId{set;get;}
    public Attachment attach1{set;get;}
    
  public ASI_CRM_TW_PlanAttachDownload_Ctrl(ApexPages.StandardController controller) {
      attach1 = new Attachment();
      attach = new list <Attachment>();
      PageId = ApexPages.currentPage().getParameters().get('id');
      
      ASI_MFM_Plan__c plan = [SELECT id, ASI_MFM_Status__c FROM ASI_MFM_Plan__c WHERE id=:PageId];
      
      if(plan != null){
          if(plan.ASI_MFM_Status__c != 'Final'){
              ApexPages.addmessage(new ApexPages.message(ApexPages.Severity.info,'合約尚未核准'));
              attach1 = null;
          }
          else{
              attach= [SELECT Id, Name,ContentType, Body, Description FROM Attachment where ParentId =:PageId AND Description like '%Contract%' LIMIT 1];
              if(attach.size() > 0){
                  attach1 = attach[0];
              }
              else{
                  ApexPages.addmessage(new ApexPages.message(ApexPages.Severity.info,'No Contract Attachment'));
                  attach1 = null;
              }
          }
      }
  
  }


}