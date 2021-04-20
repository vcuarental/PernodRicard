/*
+-----------------------+------------------------------------------------------------------------------------+
| Author                | Elufa                                                      
+-----------------------+------------------------------------------------------------------------------------+
| Description           | For ASI Korea user                                                                                                          
|     - Object(s)       | Purchase Requests                                                                               
|     - Description     | New field for expiration date for PR      
|                       | Send a chasing email to PR requester in case PO receipt is not fully done after expiration date
|                       | Expiration date can be automatically setting as 60 days after PR date and also manually edited for long term PR/PO
+-----------------------+------------------------------------------------------------------------------------+
| Creation Date         | 21/01/2017                                                                        
+-----------------------+------------------------------------------------------------------------------------+
| Modifications         |                                                                                    
+-----------------------+------------------------------------------------------------------------------------+
List<ASI_MFM_PO__c> PYlist = [select Id,ASI_MFM_Expiration_Date__c from ASI_MFM_PO__c where RecordType.DeveloperName LIKE 'ASI_MFM_KR%' ]; 
date td= system.today(); 
for(ASI_MFM_PO__c pl : PYlist){ pl.ASI_MFM_Expiration_Date__c=td; } 
update PYlist;

| Related Informations  | run  //database.executebatch(new ASI_MFM_KR_PR_ExpirationDateEmailRemind(),200);   select Id,ASI_MFM_Expiration_Date__c from ASI_MFM_Purchase_Request__c where RecordType.DeveloperName LIKE 'ASI_MFM_KR%'                                                                         
+-----------------------+------------------------------------------------------------------------------------+
*/

global without sharing class ASI_MFM_KR_PR_ExpirationDateEmailRemind implements Database.Batchable<sObject> ,Database.Stateful{
    public boolean hasError {set;get;}{hasError=false;}
    private String InfoMesg='';
    global ASI_MFM_KR_PR_ExpirationDateEmailRemind(){
        
    }
    global Database.QueryLocator start(Database.BatchableContext BC){
        
        integer DateNum=0;
        if(ASI_MFM_Setting__c.getOrgDefaults().ASI_MFM_PO_exiprationDate_addNum__c!=null)
                    DateNum=integer.valueOf(ASI_MFM_Setting__c.getOrgDefaults().ASI_MFM_PO_exiprationDate_addNum__c);
        Date LastEndDate= Date.today();//system.today();
        if(DateNum>0){
            // future 
            DateNum = DateNum*-1;
            LastEndDate = LastEndDate.addDays(DateNum);
        }else if(DateNum <0){
                            //before 
                            LastEndDate= LastEndDate.addDays(DateNum);
                            }
                            else{
                                //Same date, i.e. DateNum = 0;
                                LastEndDate=  LastEndDate;
                            }
        system.debug('Query Date : '+ LastEndDate.format());
        
        return Database.getQueryLocator([select Id,ASI_MFM_Expiration_Date__c,
                                         (select Id,Name,ASI_MFM_PO__c,ASI_MFM_PO__r.OwnerId,ASI_MFM_PO__r.Owner.Email,ASI_MFM_Purchase_Request_Line__r.ASI_MFM_Purchase_Request__r.Owner.Email FROM PO_Line_Items__r)
                                         from ASI_MFM_PO__c 
                                         where RecordType.DeveloperName LIKE 'ASI_MFM_KR%' and 
                                         ASI_MFM_Expiration_Date__c =:LastEndDate 
                                         //ASI_MFM_Expiration_Date__c>=:system.today() and ASI_MFM_Expiration_Date__c <=:LastEndDate 
                                         AND ASI_MFM_Is_Direct_Payment__c =FALSE AND ASI_MFM_Dummy_PO__c =FALSE 
                                         //and (ASI_MFM_Status__c='Approved' or ASI_MFM_Status__c='Closed') order by Id ]);  
                                         and (ASI_MFM_Status__c='Approved') order by Id ]);   // Modified by 2018-02-22 Linus@introv
        
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> scope)
    {
         List<ASI_MFM_PO__c> POList= scope;
        
        Set<Id> InputPOIDSet= new Set<Id>();
        // PO ID/ PR Owner email 
        Map<Id,String> POMap= new Map<Id,String>();
        // PO ID/ P0 Owner Id 
        Map<Id,String> POOwnerMap= new Map<Id,String>();

        if(POList.size()>0){
            for(ASI_MFM_PO__c po:POList){
                InputPOIDSet.add(po.Id);
            }
        }
        
        
        set<id> POIDSet= new set<id>();
      
        
        
        List<ASI_MFM_PO_Line_Item__c> POLineList =[select Id,Name,ASI_MFM_PO__c,ASI_MFM_PO__r.OwnerId,ASI_MFM_PO__r.Owner.Email,
                                                   ASI_MFM_Purchase_Request_Line__r.ASI_MFM_Purchase_Request__r.Owner.Email,
                                                   ASI_MFM_Purchase_Request_Line__r.ASI_MFM_Purchase_Request__r.OwnerId,
                                                   (select id from PO_Receipt_Items__r) 
                                                   from ASI_MFM_PO_Line_Item__c 
                                                   where RecordType.DeveloperName LIKE 'ASI_MFM_KR%' 
                                                   and ASI_MFM_PO__c in : InputPOIDSet and ASI_MFM_PO__r.ASI_MFM_Is_Direct_Payment__c=false];
        
        
        
        for(ASI_MFM_PO_Line_Item__c pol:POLineList){
            
            if(pol.PO_Receipt_Items__r.size()==0 && !POIDSet.contains(pol.ASI_MFM_PO__c)){
                POIDSet.add(pol.ASI_MFM_PO__c);
                POOwnerMap.put(pol.ASI_MFM_PO__c, String.valueOf(pol.ASI_MFM_PO__r.OwnerId));
                POMap.put(pol.ASI_MFM_PO__c, String.valueOf(pol.ASI_MFM_Purchase_Request_Line__r.ASI_MFM_Purchase_Request__r.Owner.Email));
            }
            
        }
        
        //For testing use only: InfoMesg+=string.valueOf(POLineList);
        
        EmailTemplate template = [SELECT id FROM EmailTemplate WHERE developername = 'ASI_MFM_KR_PO_ExpirationDate_to_PR'];
        OrgWideEmailAddress owe = [SELECT ID FROM OrgWideEmailAddress WHERE DisplayName like 'IT Service Desk'];
        Messaging.SingleEmailMessage[] mailList = new Messaging.SingleEmailMessage[]{};
            String BccAddresses='pra.sfdc.uat@gmail.com';   
        
        for(Id key:POMap.keySet()){
            List <String> ToAddresses = new List <String>(); 
            ToAddresses.add(POMap.get(key));
            Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
            message.setOrgWideEmailAddressId(owe.Id);
            message.setToAddresses(ToAddresses);
            message.setBccAddresses(new String[] {BccAddresses});
            message.setTargetObjectId(POOwnerMap.get(key));
            message.setBccSender(false);
            message.setWhatId(key);
            message.setTemplateId(template.id);
            message.setSaveAsActivity(false);
            mailList.add(message);
        }
        
        try{
            Messaging.sendEmail(mailList);
        }catch(exception e){
            InfoMesg+=e.getMessage();
            hasError = true;
        }
        
        
        
        
        
        
    }
    
    
    global void finish(Database.BatchableContext BC){
        if(hasError){
            ASI_MFM_ByPass_Setting.ErrorHandling('Batch Process has completed:'+InfoMesg,'ASI_MFM_KR_PR_ExpirationDateEmailRemind','Batch Process Failed!');
        }else{
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            String email='prasia.mobile@pernod-ricard.com';
            mail.setToAddresses(new String[] {email});
            mail.setReplyTo('prasia.mobile@pernod-ricard.com');
            mail.setSenderDisplayName('Batch Processing');
            mail.setSubject('ASI_MFM_KR_PR_ExpirationDateEmailRemind Batch Process Completed successfully ');
            mail.setPlainTextBody('Batch Process for ASI_MFM_KR_PR_ExpirationDateEmailRemind has completed successfully! !'+InfoMesg);
            
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        }
    }//end method: finish
}