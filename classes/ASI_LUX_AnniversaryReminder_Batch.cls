global class ASI_LUX_AnniversaryReminder_Batch implements Database.Batchable<sObject>{

    global final String queryLuxAccounts;

    global ASI_LUX_AnniversaryReminder_Batch (String q){
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
        Date todaysDate = date.today();
        List<Account> luxAccountList = (List<Account>)scope; 
        for (Account luxAcct : luxAccountList)
        {
            if (luxAcct.ASI_LUX_LeCercle_Member_Since_Date__c != null)
            {
                Integer memberDateMonth = luxAcct.ASI_LUX_LeCercle_Member_Since_Date__c.month();
                Integer memberDateDay = luxAcct.ASI_LUX_LeCercle_Member_Since_Date__c.day();
                if (memberDateMonth == todaysDate.month() && memberDateDay == todaysDate.day())
                    sendAnniversaryReminder(luxAcct);
            }
        }
    }
    
    global void finish(Database.BatchableContext BC) 
    {   

    }
    
     public void sendAnniversaryReminder (Account luxAcctParam)
     {
        User u = [SELECT ID, Name, Email FROM User WHERE ID = : luxAcctParam.ownerid];
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        //mail.setWhatId(luxAcctParam.id);
        EmailTemplate et1 = [select id, subject, Body, HtmlValue, developerName from EmailTemplate where developerName = 'ASI_LUX_Le_Cercle_Membership_Anniversary_Reminder'];
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

        mail.setSubject(et1.subject);    
        
        String mailingBody1 = et1.HtmlValue; 
        mailingBody1 = mailingBody1.replace('{!Account.Name}', luxAcctParam.Name == null ? '' : luxAcctParam.Name);
        mailingBody1 = mailingBody1.replace('{!Account.ASI_LUX_Preferred_Contact_Number__c}', luxAcctParam.ASI_LUX_Preferred_Contact_Number__c == null ? '' : luxAcctParam.ASI_LUX_Preferred_Contact_Number__c);
        mailingBody1 = mailingBody1.replace('{!Account.PersonMobilePhone}', luxAcctParam.PersonMobilePhone == null ? '' : luxAcctParam.PersonMobilePhone);
        mailingBody1 = mailingBody1.replace('{!Account.PersonHomePhone}', luxAcctParam.PersonHomePhone == null ? '' : luxAcctParam.PersonHomePhone);
        mailingBody1 = mailingBody1.replace(']]>', '');
        
        mail.setHtmlBody(mailingBody1);
        mail.setEmailPriority('High');
        
        Messaging.sendEmail(new Messaging.SingleEmailMessage[]{mail});
     }

}