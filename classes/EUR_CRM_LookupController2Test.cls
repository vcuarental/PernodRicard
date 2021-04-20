@IsTest (IsParallel = true)
private with sharing class EUR_CRM_LookupController2Test {

    @IsTest
    private static void fetchAccountTest() {
        Account acc = new Account(Name = 'Test');
        insert acc;
        List <SObject> resList = EUR_CRM_LookupController2.fetchAccount('Account', 'Test', '');
        System.assertEquals(1,resList.size());
    }

    @IsTest
    private static void getNameByIdTest() {
        Contact con = new Contact(LastName = 'Test');
        insert con;
        List <SObject> resList = EUR_CRM_LookupController2.getNameById('Contact',con.Id,'AccountId');
        System.assertEquals(1,resList.size());
    }

}