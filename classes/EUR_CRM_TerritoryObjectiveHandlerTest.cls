@isTest
private class EUR_CRM_TerritoryObjectiveHandlerTest {

	static testMethod void myUnitTest() {
		EUR_CRM_Region__c region = new EUR_CRM_Region__c(name='test region', EUR_CRM_Region_Owner__c = UserInfo.getUserId());
		insert region;
		EUR_CRM_Territory__c territory = new EUR_CRM_Territory__c(name='test territory', EUR_CRM_Territory_Owner__c = UserInfo.getUserId(), EUR_CRM_Region__c = region.id);
		insert territory;
		EUR_CRM_GB_Objective__c objective = new EUR_CRM_GB_Objective__c(name='test kpi obj');
		insert objective;
		List<EUR_CRM_GB_Territory_Objective__c> tobjlist = new List<EUR_CRM_GB_Territory_Objective__c>();
		EUR_CRM_GB_Territory_Objective__c territoryObj1 = new EUR_CRM_GB_Territory_Objective__c(EUR_CRM_Objective__c=objective.Id, EUR_CRM_Territory__c=territory.Id);
		EUR_CRM_GB_Territory_Objective__c territoryObj2 = new EUR_CRM_GB_Territory_Objective__c(EUR_CRM_Objective__c=objective.Id, EUR_CRM_Region__c = region.Id);
		tobjlist.add(territoryObj1);
		tobjlist.add(territoryObj2);
		insert tobjlist;
		update territoryObj1;
		
	}
	

}