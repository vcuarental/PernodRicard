@isTest
private class MYPJ_Contact_Trigger_Test {

    @isTest
    public static void test() {

        Id rtIdContact = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('MYPJ_Contact').getRecordTypeId();

        Contact con = new Contact(LastName = 'Test', RecordTypeId = rtIdContact);
        insert con;

        update con;
    }
}