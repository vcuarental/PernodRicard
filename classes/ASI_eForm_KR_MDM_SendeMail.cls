public class ASI_eForm_KR_MDM_SendeMail {
    
    ApexPages.StandardController controller;
    private ASI_eForm_HR_MDM__c header;
    
    public ASI_eForm_KR_MDM_SendeMail(ApexPages.StandardController controller) {
        this.controller = controller;
    }

    public void ASI_eForm_KR_MDM_SendeMail() {
        
        if(header==null){
            header = [SELECT id,ASI_eForm_Employee_Work_Email__c,Name From ASI_eForm_HR_MDM__c where id =: controller.getid()];
        }
        
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        message.setsubject('Salesforce MDM profile');
        message.sethtmlBody('Please note that your MDM profile has been created in SFDC with following detail:<br/>Employee No. : '+ header.Name);
        message.setToAddresses(new String[] {header.ASI_eForm_Employee_Work_Email__c});
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { message });
    }
}