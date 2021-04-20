@isTest
private class LAT_BR_AccountKnowYourCustomerContTest {
    
    @isTest
    static void test_general() {        
        PageReference pf = Page.LAT_BR_AccountKnowYourCustomer;
		Account acc = new Account(
                RecordTypeId = Global_RecordTypeCache.getRtId('Account' + 'Off_Trade'), 
                CNPJ__c = '54651716001150',
                Name = 'testAccount',
                Type = 'COM FATURAMENTO',
                Corporate_Name__c = 'test',
                Channel_Type__c = 'Direto',
                TriggerRun__c = true
            );
        insert acc;
        
        Test.setCurrentPage(pf);
        Test.startTest();
        ApexPages.StandardController ac = new ApexPages.StandardController(acc);
        LAT_BR_AccountKnowYourCustomerCont con = new LAT_BR_AccountKnowYourCustomerCont(ac);
        con.doSave();
        con.updateAccount();
        con.doEdit();
        con.doCancel();
        Test.stopTest();
    }

}