public class EUR_CRM_DE_OP_EmailNotifController{
   /*
   "O/P - a ""Notify Sales Manage"" button is needed on the O/P page with the following function:
- only Trade Marketing and KAM Assistant can access the button
- when the button is clicked, an email should be sent to the involed Sales Manager
- email subject: Objective (Name of the campaign) is ready to set a goal
- email body: please fill out the Sales Manager and Sales Reps goals to activate/ publish this campaign."
----------------------------
"O/P - a ""Notify TM/KAM"" button is needed on the O/P page with the following function:
- only Sales Manager can access the button
- when the button is clicked, an email should be sent to the TM/KAM (the person who create the O/P)
- email subject: Sales Manager (Sales Manager Name) objective (Name of the campaign) is done.
- email body: please activate/ publish the campaign (Name of the campaign) to the Sales Reps.
- words in bracket are dynamic value"
*/
    
    public PageReference sendNotificationEmail(){
        String id = ApexPages.currentPage().getParameters().get('id');
        String type = ApexPages.currentPage().getParameters().get('t');
        Boolean isSendToSalesManagers = type =='1';
        Boolean isSendToTMKAM = type =='2';
        
        if(! (isSendToSalesManagers || isSendToTMKAM ) || String.isEmpty(id))
            return returnBack(id);
        EUR_CRM_ObjPromo__c objPromo = [select id, owner.email, Name from EUR_CRM_ObjPromo__c where id =:id];
        
        if(objPromo == null) 
            return returnBack(id);
        
        Set<String> salesManagerEmails = new Set<String>();
        
        for(EUR_CRM_ObjPromo_Target__c regionalTarget: [select id,EUR_CRM_Target_Owner__r.email from EUR_CRM_ObjPromo_Target__c where EUR_CRM_ObjPromo__c =:id
            and recordtype.developername = 'EUR_DE_Regional_Volume_Target']){
            salesManagerEmails.add(regionalTarget.EUR_CRM_Target_Owner__r.email);
        }
        
        Set<Id> taxonomyIds = EUR_CRM_OPTargetHelperClass.retrieveCustomerTaxonomySet(id);
        if(taxonomyIds != null && taxonomyIds.size() > 0)
        for(User u : EUR_CRM_OPTargetHelperClass.retrieveTargetOwnersRegionalLevel(taxonomyIds)){
            salesManagerEmails.add(u.email);
            //salesManagerEmails.add('rey.magdaong@ipc.ph');
        }else{
            return returnBack(id);        
        }
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        List<String> sendTo = new List<String>();          
        String mailSubject = '';
        String mailBody = '';
        String replyTo= '' ;
        String displayName = '';
        
        system.debug('Flag 1: ');
        if(isSendToSalesManagers){ 
        system.debug('Flag 3: ');
             
            mailSubject = 'Objective ' + objPromo.name + ' is ready to set a goal';
            mailBody = 'Please fill out the Sales Manager and Sales Reps goals to activate/ publish this campaign.';
            replyTo= objPromo.owner.email;
            displayName = '';
            salesManagerEmails.remove(UserInfo.getUserEmail()); //remove currect user from email list.
            sendTo.addAll(salesManagerEmails); 
            system.debug('sendTo: ' + sendTo);
        }
        if(isSendToTMKAM){           
            system.debug('Flag 3: '); 
            mailSubject = 'Sales Manager ' + UserInfo.getFirstName() +' '+ UserInfo.getLastName() + ' objective '+ objPromo.name +' is done';
            mailBody = 'Please activate/ publish the campaign '+ objPromo.name +' to the Sales Reps.';
            replyTo= UserInfo.getUserEmail();
            displayName = '';
            if(UserInfo.getUserEmail() != objPromo.owner.email)
                sendTo.add(objPromo.owner.email); 
        }
        
        mailBody += ' ' +'<a href="'+URL.getSalesforceBaseURL().toExternalForm() + '/' + id +'">Link </a> to the Objective';
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage(); 
        mail.setToAddresses(sendTo);
        mail.setReplyTo(replyTo);
        //mail.setSenderDisplayName(displayName);
        mail.setSubject(mailSubject);
        mail.setHtmlBody(mailBody);
        mails.add(mail);
        
       
        if(mails.size() >0 && sendTo.size() > 0)
            Messaging.sendEmail(mails);
        return returnBack(id);
    }
    
    public PageReference returnBack(String id){
        if(String.isNotEmpty(id))
            return new PageReference('/'+id).setRedirect(true);
        else
            return null;
    }
}