/*
+-----------------------+------------------------------------------------------------------------------------+
| Author                | Tony Ren                                                                  
+-----------------------+------------------------------------------------------------------------------------+
| Description           | For ASI Korea user                                                                                                          
|     - Object(s)       | PO Receipt KR MFM                                                                          
|     - Description     | Send an email warning to PO receipt owner to encourage them to create the payment record      
+-----------------------+------------------------------------------------------------------------------------+
| Creation Date         | 21/02/2017                                                                        
+-----------------------+------------------------------------------------------------------------------------+
| Modifications         |                                                                                    
+-----------------------+------------------------------------------------------------------------------------+
| Related Informations  | run  //database.executebatch(new ASI_MFM_KR_PORLEmailNotificationProcess(),200);                                                                        
+-----------------------+------------------------------------------------------------------------------------+
*/

global without sharing class ASI_MFM_KR_PORLEmailNotificationProcess Implements Database.Batchable<sObject> ,Database.Stateful{
 public boolean hasError {set;get;}{hasError=false;}
    private String InfoMesg='';
    global ASI_MFM_KR_PORLEmailNotificationProcess(){
        
    }
     global Database.QueryLocator start(Database.BatchableContext BC){
        String SQLstr=System.Label.ASI_MFM_KR_PORLEmailNotificationProcess;
        return Database.getQueryLocator(SQLstr);
    }
    
    
    global void execute(Database.BatchableContext BC, List<sObject> scope)
    {
        List<ASI_MFM_PO_Receipt_Item__c > PORList= scope;//ASI_MFM_Mass_Upload_Log__c LOG = NEW ASI_MFM_Mass_Upload_Log__c(ASI_MFM_Configuration__c= string.valueOf(PRList));     insert LOG;
    	
        Set<id> UserIDSet = new Set<id> ();
        //Map<PO Receipt owner Id, PO Id> 
        Map<String,set<String>> POROwnerMap = new Map<String,set<String>>(); 
        if(PORList.size()>0){
            for(ASI_MFM_PO_Receipt_Item__c porl:PORList){
                // Modified by 2018-09-17 Linus@introv
                // Bypass PO receipt with amount < 0
                if(porl.Payment_Line_Items__r.size()==0 && porl.ASI_MFM_Amount__c > 0){ // check if this po receipt have create Payment 
                    if(!POROwnerMap.containsKey(porl.ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__c)){
                        set<String> TempList = new set<String>();
                        TempList.add(porl.ASI_MFM_PO_Receipt__r.OwnerId);
                        UserIDSet.add(porl.ASI_MFM_PO_Receipt__r.OwnerId);
                        POROwnerMap.put(porl.ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__c, TempList);
                    }else{
                        UserIDSet.add(porl.ASI_MFM_PO_Receipt__r.OwnerId);
                        POROwnerMap.get(porl.ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__c).add(porl.ASI_MFM_PO_Receipt__r.OwnerId); //POROwnerMap.put(porl.ASI_MFM_PO_Receipt__r.OwnerId, porl.ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__c);  
                    }/*if(!POROwnerMap.containsKey(porl.ASI_MFM_PO_Receipt__r.OwnerId)){ POROwnerMap.put(porl.ASI_MFM_PO_Receipt__r.OwnerId, porl.ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__c); }*/
                }
            }
        }// end of checking 
        
         Map<ID, User> mapUser = new Map<ID,User>([SELECT ID, Name, Email  FROM User WHERE id in : UserIDSet ]);
        
        EmailTemplate template = [SELECT id FROM EmailTemplate WHERE developername = 'ASI_MFM_KR_Open_PO_For_Create_Payment'];
        OrgWideEmailAddress owe = [SELECT ID FROM OrgWideEmailAddress WHERE DisplayName like 'IT Service Desk'];
        Messaging.SingleEmailMessage[] mailList = new Messaging.SingleEmailMessage[]{};
        String BccAddresses='prkmfm@gmail.com'; 
        
        
        for(String key:POROwnerMap.keySet()){
             for(String Oid:POROwnerMap.get(key)){ // owner id
                 if(mapUser.containsKey(Oid)){
                     Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
                     message.setOrgWideEmailAddressId(owe.Id);
                     message.setToAddresses(new String[] {mapUser.get(Oid).Email});
                     message.setBccAddresses(new String[] {BccAddresses});
                     message.setTargetObjectId(Oid);
                     message.setBccSender(false);
                     message.setWhatId(key);
                     message.setTemplateId(template.id);
                     message.setSaveAsActivity(false);
                     mailList.add(message);
                 }
                 
             } 
             
        }// end of for loop
        
        try{
            Messaging.sendEmail(mailList);
        }catch(exception e){
            InfoMesg=e.getMessage();
            hasError = true;
        }
            
    
    }
    
    global void finish(Database.BatchableContext BC){
        if(hasError){
            ASI_MFM_ByPass_Setting.ErrorHandling(InfoMesg,'ASI_MFM_KR_PORLEmailNotificationProcess','Send an email warning to PO receipt owner to encourage them to create the payment record');
        }else{
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            String email='pra.sfdc.uat@gmail.com';
            mail.setToAddresses(new String[] {email});
            mail.setReplyTo('sfdc@elufasys.com');
            mail.setSenderDisplayName('Batch Processing');
            mail.setSubject('ASI_MFM_KR_PORLEmailNotificationProcess Batch Process Completed successfully ');
            mail.setPlainTextBody('Batch Process for ASI_MFM_KR_PORLEmailNotificationProcess has completed successfully! !'+InfoMesg);
            
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        }
    }//end method: finish
    
    
}