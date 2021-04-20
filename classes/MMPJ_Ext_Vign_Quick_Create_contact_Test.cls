@isTest
private class MMPJ_Ext_Vign_Quick_Create_contact_Test {
    @isTest
    public static void TestCreateContact() {
        MMPJ_Ext_Vign_Societe__c societe = new MMPJ_Ext_Vign_Societe__c(Name='Societe Test');
        insert societe;

        Contact con = new Contact(LastName = 'Test');
        insert con;

        String returnCode = MMPJ_Ext_Vign_Quick_Create_contact_ctrl.quickCreateContact(con.Id, societe.Id, 'ADMIN', null, true, true, UserInfo.getUserId());

        Boolean isOk = returnCode.startsWith('OK:');

        System.assertEquals(true, isOk);

        MMPJ_Ext_Vign_Quick_Create_contact_ctrl.getSalesforceConfiguration();
    }

    @isTest
    static void searchShouldReturnUser() {
        Id[] fixedResults = new List<Id> { UserInfo.getUserId() };
        Test.setFixedSearchResults(fixedResults);
        List<String> selectedIds = new List<String>();

        List<MMPJ_Ext_Vign_Quick_Create_contact_ctrl.LookupSearchResult> results = MMPJ_Ext_Vign_Quick_Create_contact_ctrl.searchForUser(
            'User',
            selectedIds
        );

        System.assertEquals(1, results.size());
        System.assertEquals(UserInfo.getUserId(), results.get(0).getId());
    }

}