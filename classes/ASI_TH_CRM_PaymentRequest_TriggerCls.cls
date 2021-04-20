/*Created by Kevani Chow (Introv) 20160513*/
public without sharing class ASI_TH_CRM_PaymentRequest_TriggerCls{
    public static void routineBeforeUpsert(list<ASI_TH_CRM_PaymentRequest__c> trigger_new, map<id, ASI_TH_CRM_PaymentRequest__c> trigger_oldMap) {        
        Map<String, ASI_TH_CRM_PaymentRequest__c> mapPR = new Map<String, ASI_TH_CRM_PaymentRequest__c>();
        Set<String> setPR = new Set<String>();
        List<ASI_TH_CRM_PaymentRequestLineItem__c> updateItem = new List<ASI_TH_CRM_PaymentRequestLineItem__c>();
        for(ASI_TH_CRM_PaymentRequest__c  pr : trigger_new){          
            mapPR.put(pr.id,pr);
            setPR.add(pr.id);
        }
    
        Id LineItemRecordTypeId = Global_RecordTypeCache.getRTId('ASI_TH_CRM_PaymentRequestLineItem__cASI_TH_CRM_Payment_Request_Detail');
        List <ASI_TH_CRM_PaymentRequestLineItem__c> LineItemList = [SELECT Id, ASI_CRM_GL_Date__c, ASI_CRM_Invoice_Due_Date__c, ASI_TH_CRM_Payment_Request__c, ASI_CRM_Tax_Type__c FROM ASI_TH_CRM_PaymentRequestLineItem__c WHERE RecordTypeId=:LineItemRecordTypeId AND ASI_TH_CRM_Payment_Request__c IN:setPR];
        if(LineItemList.size()>0 && LineItemList!=null){
          for(ASI_TH_CRM_PaymentRequestLineItem__c item: LineItemList){
            //ASI_CRM_GL_Date__c
            //GL Date in Payment Request Header is input by CDP
            //Copy the date to Line Item GL Date once Approved (trigger)
             if(mapPR.get(item.ASI_TH_CRM_Payment_Request__c)!=null){                
                 if(trigger_oldMap.get(item.ASI_TH_CRM_Payment_Request__c).ASI_TH_CRM_Status__c!='Approved' && mapPR.get(item.ASI_TH_CRM_Payment_Request__c).ASI_TH_CRM_Status__c=='Approved'){
                    item.ASI_CRM_GL_Date__c=mapPR.get(item.ASI_TH_CRM_Payment_Request__c).ASI_TH_CRM_GL_Date__c; 
                    if(mapPR != NULL && mapPR.get(item.ASI_TH_CRM_Payment_Request__c) != NULL &&
                       mapPR.get(item.ASI_TH_CRM_Payment_Request__c).ASI_TH_CRM_VAT__c != '7%')
                        item.ASI_CRM_Tax_Type__c=mapPR.get(item.ASI_TH_CRM_Payment_Request__c).ASI_TH_CRM_VAT__c;
                    else
                        item.ASI_CRM_Tax_Type__c='IVAT(7%)';
                        
                    //ASI_CRM_Invoice_Due_Date__c
                    //Default to 10th of next month of Line Item GL Date once Approved
                    //Not visible to CDP. (trigger)      
                    if(item.ASI_CRM_GL_Date__c != null){             
                        if(item.ASI_CRM_GL_Date__c.month()!=12){
                            item.ASI_CRM_Invoice_Due_Date__c= date.newInstance(item.ASI_CRM_GL_Date__c.year(), item.ASI_CRM_GL_Date__c.month()+1, 10);
                        }else{
                            item.ASI_CRM_Invoice_Due_Date__c= date.newInstance(item.ASI_CRM_GL_Date__c.year()+1, 1, 10);
                        }
                    }
                    updateItem.add(item);
                 }
              } 
          }
          update updateItem;
       }
    }
}