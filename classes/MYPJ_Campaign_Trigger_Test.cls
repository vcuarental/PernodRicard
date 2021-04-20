@isTest
private class MYPJ_Campaign_Trigger_Test {

    @isTest
    public static void test() {

        Id rtIdContact = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('MYPJ_Contact').getRecordTypeId();
        Id rtIdCamp = Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get('MYPJ_Campaign').getRecordTypeId();

        Contact con = new Contact(LastName = 'Test', RecordTypeId = rtIdContact);
        insert con;

        Campaign camp = new Campaign(Name = 'Test', RecordTypeId = rtIdCamp);
        insert camp;
        
        CampaignMember campM1 = new CampaignMember(ContactId = con.Id, CampaignId = camp.Id, Status='Sent');
        insert campM1;

        // update con;
    }
}