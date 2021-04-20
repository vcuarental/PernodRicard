@isTest
private class LAT_BR_SellOutTaskCreatorTest {
	
	@isTest static void testGetMonthMap() {
		LAT_BR_SellOutTaskCreator sotc = new LAT_BR_SellOutTaskCreator();
		Map<Integer, String> monthL = LAT_BR_SellOutTaskCreator.getMonthMap();
		system.assertEquals(LAT_BR_SellOutTaskCreator.getMonthMap().size(),12);
		system.assertEquals(monthL.size(),12);
	}
	
	@isTest static void testCreatTask() {
			testGetMonthMap();
			Account Acc = LAT_Account_TestFactory.getAccountOffTradeBraComplete();
    	insert Acc;
      LAT_ReferenceAccount__c rf = new LAT_ReferenceAccount__c();
      rf.Account__c = Acc.id;
      rf.IsActive__c = true;

      insert rf;
      Date vence = Date.today();
      LAT_BR_SellOutTaskCreator sotc = new LAT_BR_SellOutTaskCreator();
      LAT_BR_SellOutTaskCreator.createTask(vence);
      List<Task> ltask = [Select id from task]; 
      system.assertEquals(1,ltask.size());
	}

}