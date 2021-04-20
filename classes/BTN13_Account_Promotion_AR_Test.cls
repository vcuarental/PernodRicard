@isTest
private class BTN13_Account_Promotion_AR_Test{

	@isTest static void  test2() {

		Account acc = new Account(name='Acc1', recordtypeid=Global_RecordTypeCache.getRtId('Account' + 'LAT_AR_Prospect'));
		insert acc;

		BTN13_Account_Promotion_AR.promoteAccountAR(acc.Id);
	}
}