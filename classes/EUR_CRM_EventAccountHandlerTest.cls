@isTest
private class EUR_CRM_EventAccountHandlerTest {
    private static EUR_CRM_Account__c  accountEU;
    private static Account  account;
    private static Event event;
    private static List<Event> eventList = new List<Event>();

	static testMethod void testEventAccountHandler(){
        accountEU = EUR_CRM_TestClassUtilityHelper.createAccountsEU(1, 'EUR_FI_Direct_On_Trade')[0];
        insert accountEU;
        account = [SELECT Id FROM Account LIMIT 1];//EUR_CRM_TestClassUtilityHelper.createAccounts(1, 'On_Trade')[0];
        Date d = date.valueOf(System.now()+7);
        d = d.toStartOfWeek()+3;
        Datetime dt = datetime.newInstance(d.year(), d.month(),d.day());

        event = EUR_CRM_TestClassUtilityHelper.createEvents(1, 'EUR_FI_Visitation_Event', account.Id, UserInfo.getUserId(), dt, System.now()+14)[0];
		Test.startTest();
        	insert event;
        Test.stopTest();

        Event selectedEvent = [SELECT Id, WhatId FROM Event WHERE Id=:event.Id];
        System.assertEquals(accountEU.Id, selectedEvent.WhatId);
	}

}