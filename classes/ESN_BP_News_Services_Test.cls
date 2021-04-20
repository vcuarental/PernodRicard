@isTest
private class ESN_BP_News_Services_Test {
	
	@isTest static void testPushNotificationOnInsertion() {

		// Set mock callout class 
        Test.setMock(HttpCalloutMock.class, new ESN_BP_MockHttpResponseGenerator());

		List<sObject> inserts = new List<sObject>();
		
		// Create device tokens
		ESN_BP_Device_Token__c token1 = new ESN_BP_Device_Token__c(ESN_BP_Device_Token__c = '1111111111LKXC654654dEZODKDJZU');
		inserts.add(token1);
		ESN_BP_Device_Token__c token2 = new ESN_BP_Device_Token__c(ESN_BP_Device_Token__c = '2222222222LKXC654654dEZODKDJZU');
		inserts.add(token2);

		// Create news
		ESN_BP_News__c news1 = new ESN_BP_News__c(ESN_BP_News_Title__c = 'This is a test news 1', ESN_BP_News_Active__c = TRUE, ESN_BP_News_Starting_Date__c = Datetime.newInstance(Date.today(), Time.newInstance(0, 0, 0, 0)),ESN_BP_News_Ending_Date__c = Datetime.now().addDays(2));
		inserts.add(news1);
		
		ESN_BP_News__c news2 = new ESN_BP_News__c(ESN_BP_News_Title__c = 'This is a test news 2', ESN_BP_News_Active__c = TRUE, ESN_BP_News_Starting_Date__c = Datetime.newInstance(Date.today(), Time.newInstance(0, 0, 0, 0)),ESN_BP_News_Ending_Date__c = Datetime.now().addDays(2));
		inserts.add(news2);

		insert inserts;
	}

	@isTest static void testPushNotificationOnUpdate() {

		// Set mock callout class 
        Test.setMock(HttpCalloutMock.class, new ESN_BP_MockHttpResponseGenerator());

		List<sObject> inserts = new List<sObject>();
		List<sObject> updates = new List<sObject>();
		
		// Create device tokens
		ESN_BP_Device_Token__c token1 = new ESN_BP_Device_Token__c(ESN_BP_Device_Token__c = '1111111111LKXC654654dEZODKDJZU');
		inserts.add(token1);
		ESN_BP_Device_Token__c token2 = new ESN_BP_Device_Token__c(ESN_BP_Device_Token__c = '2222222222LKXC654654dEZODKDJZU');
		inserts.add(token2);

		// Create news
		ESN_BP_News__c news1 = new ESN_BP_News__c(ESN_BP_News_Title__c = 'This is a test news 1', ESN_BP_News_Active__c = FALSE);
		inserts.add(news1);
		
		ESN_BP_News__c news2 = new ESN_BP_News__c(ESN_BP_News_Title__c = 'This is a test news 2', ESN_BP_News_Active__c = FALSE);
		inserts.add(news2);

		insert inserts;

		news1.ESN_BP_News_Active__c = TRUE; 
		news1.ESN_BP_News_Starting_Date__c = Datetime.newInstance(Date.today(), Time.newInstance(0, 0, 0, 0));
		news1.ESN_BP_News_Ending_Date__c = Datetime.now().addDays(2);
		updates.add(news1);

		news2.ESN_BP_News_Active__c = TRUE; 
		news2.ESN_BP_News_Starting_Date__c = Datetime.newInstance(Date.today(), Time.newInstance(0, 0, 0, 0));
		news2.ESN_BP_News_Ending_Date__c = Datetime.now().addDays(2);
		updates.add(news2);

		update updates;
	}
}