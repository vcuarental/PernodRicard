@isTest
private class EUR_CRM_EventOverviewCtrlTest {
	private static final String PROFILENAME = 'EUR ZA Telesales Agent';
    private static EUR_CRM_Account__c  accountEU;
    private static Account  account;
    private static Event event;
    private static List<Event> eventList = new List<Event>();

	static testMethod void testEventOverviewCtrl(){
		User u = EUR_CRM_TestClassUtilityHelper.createUser(PROFILENAME);
		System.runAs(new User(Id=UserInfo.getUserId())){
			insert u;
		}
        accountEU = EUR_CRM_TestClassUtilityHelper.createAccountsEU(1, 'EUR_FI_Direct_On_Trade')[0];
        insert accountEU;
        Date d = date.valueOf(System.now()+7);
        d = d.toStartOfWeek()+3;
        Datetime dt = datetime.newInstance(d.year(), d.month(),d.day());
        event = EUR_CRM_TestClassUtilityHelper.createEvents(1, 'EUR_FI_Visitation_Event', accountEU.Id, UserInfo.getUserId(), dt, System.now()+14)[0];
		insert event;

		PageReference cpage = Page.EUR_CRM_EventOverview;
		cpage.getParameters().put('Id', event.Id);
		Test.setCurrentPage(cpage);
		EUR_CRM_EventOverviewCtrl ctrl;

		Test.startTest();
        	System.runAs(u){
        		ctrl = new EUR_CRM_EventOverviewCtrl(new ApexPages.StandardController(event));
        		System.assertEquals(2, ctrl.getEUAccountRelatedLists().childComponents.size());
        	}	
        Test.stopTest();

        System.assert(ctrl.isObjWhat);
        System.assert(ctrl.isShowRLs);
        System.assertEquals(ctrl.cEvent.WhatId, event.WhatId);
	}
	
}