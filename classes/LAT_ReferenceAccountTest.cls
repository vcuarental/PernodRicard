@isTest
private class LAT_ReferenceAccountTest {
	
	@isTest static void testAssignAccountName() {
	        
                LAT_ReferenceAccount  ra = new LAT_ReferenceAccount();
	        Account Acc = LAT_Account_TestFactory.getAccountOffTradeBraComplete();
                insert Acc;
                LAT_ReferenceAccount__c rf = new LAT_ReferenceAccount__c();
                rf.Account__c = Acc.id;
                insert rf;
                List<LAT_ReferenceAccount__c> rfL = new List<LAT_ReferenceAccount__c>();
                rfL.add(rf);
                LAT_ReferenceAccount.AssignAccountName(rfL);
                system.assertEquals(rf.AccountName__c,rf.name);
	}
	
	@isTest static void testUniqueAccount() {

                LAT_ReferenceAccount  ra = new LAT_ReferenceAccount();
		Account Acc = LAT_Account_TestFactory.getAccountOffTradeBraComplete();
                insert Acc;
                LAT_ReferenceAccount__c rf = new LAT_ReferenceAccount__c();
                rf.Account__c = Acc.id;
                insert rf;
                List<LAT_ReferenceAccount__c> rfL = new List<LAT_ReferenceAccount__c>();
                rfL.add(rf);
                Map<Id,LAT_ReferenceAccount__c> m = new Map<Id,LAT_ReferenceAccount__c>();
                 m.put(rf.id,rf);
                LAT_ReferenceAccount.UniqueAccount(rfL,m,false);
                system.assertEquals(rf.AccountName__c,rf.name);

	}
        @isTest static void testAssignValues(){
                 LAT_ReferenceAccount  ra = new LAT_ReferenceAccount();
                Account Acc = LAT_Account_TestFactory.getAccountOffTradeBraComplete();
                insert Acc;
                LAT_ReferenceAccount__c rf = new LAT_ReferenceAccount__c();
                rf.Account__c = Acc.id;
                insert rf;
                List<LAT_ReferenceAccount__c> rfL = new List<LAT_ReferenceAccount__c>();
                rfL.add(rf);
                LAT_ReferenceAccount.AssignValues(rfL);
                system.assert(rf.externalId__c != NULL);
        }

}