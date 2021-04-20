public class ASI_MFM_KR_Send_to_PO_OwnerController {
    ASI_MFM_Plan__c p = new ASI_MFM_Plan__c();
    public String Msg{get;set;}{Msg='';}
    public boolean HasError {get;set;}{HasError=false;}
     public boolean Sent {get;set;}{Sent=false;}
     
    public ASI_MFM_KR_Send_to_PO_OwnerController(apexpages.standardController sc) {
        Msg='Please click \'Send Email to PO Owner\' Button, thank you very much.';
        p = [select Id,Name,ASI_MFM_Status__c, recordTypeId from ASI_MFM_Plan__c where id = :sc.getId()];
    }
    
     public void sendEmail(){
        HasError=false;
        Msg='';
        Id templateId;
        String templateApiName = 'ASI_MFM_KR_Plan_Approved';     //  Set Email template          
        try {
            templateId = [select id, name from EmailTemplate where developername = : templateApiName].id;
        }catch (Exception e) {
            Msg=' Unable to locate EmailTemplate using name: ' + templateApiName ;
        }
        
        List <String> ToAddresses = new List <String>();  
        
        //Set To Addresses
        List<ASI_MFM_PO__c> POList = [select id,name,owner.Email from ASI_MFM_PO__c where ASI_MFM_Plan__c=:p.Id And ASI_MFM_Status__c='Draft' ];
         for(ASI_MFM_PO__c po:POList){
              ToAddresses.add(po.owner.Email);
         }
        
         
         //send email 
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage(); 
         email.setTargetObjectId(System.UserInfo.getUserId());
         email.setToAddresses( ToAddresses );
        email.setWhatId(p.Id);
        email.setSaveAsActivity(false); 
        email.setBccSender(false);
        email.setUseSignature(false);
        email.setTemplateId(templateId);
        try {
            if(!Test.isRunningTest()){     
                Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
            }
            Sent=true;
            HasError=false;
            Msg='An email notification has been sent to all Draft PO owner, thank you.';
        }catch (Exception e) {
            HasError=true;
            Msg=e.getMessage();
        }
     }
    
}