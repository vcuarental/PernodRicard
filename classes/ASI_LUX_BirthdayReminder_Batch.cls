global class ASI_LUX_BirthdayReminder_Batch implements Database.Batchable<sObject>{
    
    global final String queryLuxAccounts;

    global ASI_LUX_BirthdayReminder_Batch (String q){
        System.debug('zonda constructor');
        queryLuxAccounts = q;
    }

    global Database.QueryLocator start(Database.BatchableContext BC) 
    {
        System.debug('zonda QueryLocator');
        return Database.getQueryLocator(queryLuxAccounts);
    }

    global void execute (Database.Batchablecontext BC, List<sObject> scope)
    {
        List<Account> luxAccountList = (List<Account>)scope;
        for (Account luxAcct : luxAccountList)
            sendBirthdayReminder(luxAcct);
    }

    global void finish(Database.BatchableContext BC)  
    {   

    }

     public void sendBirthdayReminder (Account luxAcctParam)
     {
        User u = [SELECT ID, Name, Email FROM User WHERE ID = : luxAcctParam.ownerid];
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setWhatId(luxAcctParam.id);
        EmailTemplate et = [select id, subject, Body, HtmlValue, developerName from EmailTemplate where developerName = 'ASI_LUX_Birthday_Reminder'];
        String[] toAddresses = new String[]{};
        if(u != null){ 
            System.debug('aku4'+u.email);
            toAddresses.add(u.email);
            //toAddresses.add('cpantua@laputatech.com');
        }  
        System.debug('address mailing3:'+toAddresses);
        mail.setToAddresses(toAddresses);
        //Mailing Subject
        //String mailingSubject = et.subject;
        //Account acctTemp = userToAccountMap.get(u.id);

        mail.setSubject(et.subject);    
        
        String mailingBody = et.HtmlValue; 
        mailingBody = mailingBody.replace('{!Account.Name}', luxAcctParam.Name == null ? '' : luxAcctParam.Name);
        mailingBody = mailingBody.replace('{!Account.ASI_LUX_Preferred_Contact_Number__c}', luxAcctParam.ASI_LUX_Preferred_Contact_Number__c == null ? '' : luxAcctParam.ASI_LUX_Preferred_Contact_Number__c);
        mailingBody = mailingBody.replace('{!Account.PersonMobilePhone}', luxAcctParam.PersonMobilePhone == null ? '' : luxAcctParam.PersonMobilePhone);
        mailingBody = mailingBody.replace('{!Account.PersonHomePhone}', luxAcctParam.PersonHomePhone == null ? '' : luxAcctParam.PersonHomePhone);
        mailingBody = mailingBody.replace(']]>', '');
        
        mail.setHtmlBody(mailingBody);
        mail.setEmailPriority('High');
        
        Messaging.sendEmail(new Messaging.SingleEmailMessage[]{mail});
     }

}