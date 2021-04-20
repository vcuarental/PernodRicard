global class ASI_LUX_SendEmailNotifyInactiveAccount  implements Database.Batchable<sObject>{

	global final String queryLuxAccounts;

	global ASI_LUX_SendEmailNotifyInactiveAccount (String q)
	{
		System.debug('clk1 constructor');
		queryLuxAccounts = q;
	}
	
	global Database.QueryLocator start(Database.BatchableContext BC) 
	{
		System.debug('clk2 QueryLocator');
		return Database.getQueryLocator(queryLuxAccounts);
	}
	
	global void execute (Database.Batchablecontext BC, List<sObject> scope)
	{
		
   		ASI_LUX_AccountInactivity__c intervalMonth = [select Name, ASI_LUX_AccountInactivityTime_Inactivity__c from ASI_LUX_AccountInactivity__c limit 1];
		Integer convertedDecimalTime = intervalMonth.ASI_LUX_AccountInactivityTime_Inactivity__c.intValue();   		
		Date todayIndeductMonths = date.today().addDays(- convertedDecimalTime);
		
		Set<ID> userToNotifyID = new Set<ID>();
		Map<ID, Account> userToAccountMap = new Map<ID, Account>();
		List<Account> luxAccountList = (List<Account>)scope;
		
		for (Account luxAcct : luxAccountList)
		{
			System.debug('acct2 ' + luxAcct);
			System.debug('acct2size ' + luxAcct.ASI_HK_CRM_Sales_Order_Histories__r); 
			List<ASI_HK_CRM_Sales_Order_History__c> tempSOList = luxAcct.ASI_HK_CRM_Sales_Order_Histories__r;
			if (tempSOList != null)
			{
				boolean isInactiveOrders = true;
				for (ASI_HK_CRM_Sales_Order_History__c luxSOHist : tempSOList)
				{
					if (luxSOHist.ASI_HK_CRM_Order_Date__c > todayIndeductMonths || luxSOHist.ASI_HK_CRM_Order_Date__c == null)
					{
						isInactiveOrders = false;
						break;
					}
				}
				if (isInactiveOrders && tempSOList.size() > 0)
					sendInactiveAccount(luxAcct.OwnerID, luxAcct);
			}
		}
		
		/*List<User> userToNotifyList = [SELECT ID, Name, Email FROM User WHERE ID IN : userToNotifyID];
		System.debug('userclk ' + userToNotifyList);
		
		if (userToNotifyList != null)
			sendInactiveAccount(userToNotifyList, userToAccountMap);*/
	}
	
	global void finish(Database.BatchableContext BC) 
	{		
		sendInactiveAccountTest();
	}
	
    public void sendInactiveAccount(/*List<User> userToSendParam, Map<ID, Account> userToAccountMap*/ ID UID, Account OwnertoAcc){
    	//for (User u : userToSendParam)
    	//{
    		User u = [SELECT ID, Name, Email FROM User WHERE ID = : UID];
        	System.debug('aku1'+u.Name); 
        	System.debug('aku3'+u.Id);
        	Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        	EmailTemplate et = [select id, subject, Body, developerName from EmailTemplate where developerName = 'ASI_LUX_Account_Activity'];
        	String[] toAddresses = new String[]{};
            if(u.email != null){ 
                System.debug('aku4'+u.email);
                toAddresses.add(u.email);
                //toAddresses.add('cpantua@laputatech.com');
            }  
        	System.debug('address mailing3:'+toAddresses);
        	mail.setToAddresses(toAddresses);
        	//Mailing Subject
        	String mailingSubject = et.subject;
        	//Account acctTemp = userToAccountMap.get(u.id);
        	Account acctTemp = OwnertoAcc;
        	String accountNametemp = '';
        	if (acctTemp != null)
        		accountNametemp = acctTemp.name;
        	mailingSubject = mailingSubject.replace('{AccountName}', accountNametemp);
        
        	//Mailing Message
        	String mailingBody = et.body;
        	mailingBody = mailingBody.replace('{acccountOwner}', u.Name);
        	mailingBody = mailingBody.replace('{AccountName}', accountNametemp);
        
        
        	mail.setSubject(mailingSubject);              
        	mail.setPlainTextBody(mailingBody);
        	mail.setEmailPriority('High');
        	Messaging.sendEmail(new Messaging.SingleEmailMessage[]{mail});
    	//}
    }
    
    public void sendInactiveAccountTest (){
        	Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        	EmailTemplate et = [select id, subject, Body, developerName from EmailTemplate where developerName = 'ASI_LUX_Account_Activity'];
        	String[] toAddresses = new String[]{};
            toAddresses.add('cpantua@laputatech.com');
        	System.debug('address mailing3:'+toAddresses);
        	mail.setToAddresses(toAddresses);
        	//Mailing Subject
        	String mailingSubject = et.subject;
        	String accountNametemp = 'FINALLY';
        		
        	mailingSubject = mailingSubject.replace('{AccountName}', accountNametemp);
        
        	//Mailing Message
        	String mailingBody = et.body;
        	String test = 'FINALLY';
        	String nametest = 'FINALLY';
        	mailingBody = mailingBody.replace('{acccountOwner}', test);
        	mailingBody = mailingBody.replace('{AccountName}', nametest);
        
        
        	mail.setSubject(mailingSubject);              
        	mail.setPlainTextBody(mailingBody);
        	mail.setEmailPriority('High');
        	Messaging.sendEmail(new Messaging.SingleEmailMessage[]{mail});
    }    

}