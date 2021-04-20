global class ASI_MFM_PH_ClosingPOEmailReminder_Batch implements Database.AllowsCallouts, Database.Batchable<sObject>{
/********************************
 * Created by: Linus @Introv    
 * Created Date: 2018-06-17
 * Objective: Schedule job to send reminder to PO owner to close PO 
 * Module: MFM PH
******************************/
    global String queryFieldList = 'Select id, name, OwnerId , Owner.Email, ASI_MFM_PO_End_Date__c from ASI_MFM_PO__c ';  // PO
    
    global date OnemthBefore = system.today().addMonths(1);
    global date todayDate = system.today();
    global date OnemthAfter = system.today().addmonths(-1);
    global date TwomthAfter = system.today().addMonths(-2);

    public boolean hasError {set;get;}{hasError=false;}
    private String InfoMesg='';
    
    global ASI_MFM_PH_ClosingPOEmailReminder_Batch (){           
        
        system.debug('Start Batch Job');                        
    }
    
    global Database.QueryLocator start(Database.BatchableContext bc){
        String queryStr;
        String whereStam = Test.isRunningTest() == true? 'where id !=  null' :
                                                         'where RecordType.DeveloperName LIKE \'ASI_MFM_PH%\' AND ASI_MFM_Status__c != \'Draft\' AND (ASI_MFM_PO_End_Date__c =: OnemthBefore or ASI_MFM_PO_End_Date__c =: todayDate or ASI_MFM_PO_End_Date__c =: OnemthAfter or ASI_MFM_PO_End_Date__c =: TwomthAfter)' ;       
        queryStr = queryFieldList + whereStam ; 
                
        system.debug('queryStr: ' + queryStr);
        return Database.getQueryLocator(queryStr);
    }
    
    global void execute(Database.BatchableContext BC, List<SObject> scope){
        if(Scope == NULL){
            return;
        }
        
        List<ASI_MFM_PO__c> POlist = new List<ASI_MFM_PO__c>();
        Map<Id, String> POMap = new Map<Id, String>();
        Map<Id, Id> POOwnerMap= new Map<Id, Id>();
        
        for(SObject s: Scope){
            ASI_MFM_PO__c POL = (ASI_MFM_PO__c)s;
            POlist.add(POL);
        }
        
        system.debug('POlist Size: ' + POlist.size());
        
        for(ASI_MFM_PO__c po: POlist){
            POMap.put(po.id, po.Owner.Email);
            POOwnerMap.put(po.id, po.OwnerId);
        }
        
        EmailTemplate template = [SELECT id FROM EmailTemplate WHERE developername = 'ASI_MFM_PH_PO_Closing_Email_Template'];
        OrgWideEmailAddress owe = [SELECT ID FROM OrgWideEmailAddress WHERE DisplayName like 'IT Service Desk'];
        Messaging.SingleEmailMessage[] mailList = new Messaging.SingleEmailMessage[]{};
            String BccAddresses='prasia.mobile@pernod-ricard.com';   
        
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
        if(hasError)
            system.debug('Process fail with msg: ' + INfoMesg);
        else
            system.debug('Finish Reminder email scheduler');
    }
}