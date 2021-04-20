@isTest
private class MMPJ_XRM_BatchCalculateSegmentation_Test {

    // static {

    //     Id rtId = Schema.SObjectType.MMPJ_Ext_Vign_Societe__c.getRecordTypeInfosByDeveloperName().get('MMPJ_Ext_Vign_Vigneron').getRecordTypeId();
    //     insert new MMPJ_XRM_Segmentation_Conf__c(SetupOwnerId = UserInfo.getOrganizationId(), RecordTypes__c = rtId);
    // }
    
    @isTest(SeeAllData=true)
    static void MMPJ_XRM_BatchCalculateSegmentation_Test() {

        // Id rtId = Schema.SObjectType.MMPJ_Ext_Vign_Societe__c.getRecordTypeInfosByDeveloperName().get('MMPJ_Ext_Vign_Vigneron').getRecordTypeId();
        // insert new MMPJ_XRM_Segmentation_Conf__c(SetupOwnerId = UserInfo.getOrganizationId(), RecordTypes__c = rtId);
        
        List<MMPJ_Ext_Vign_Societe__c> lstSociete = Test.loadData(MMPJ_Ext_Vign_Societe__c.sObjectType, 'MMPJ_XRM_SegmentationTestData_Societe');
        List<MMPJ_Ext_Vign_Contrat__c> lstContrat = Test.loadData(MMPJ_Ext_Vign_Contrat__c.sObjectType, 'MMPJ_XRM_SegmentationTestData_Contrat');
        List<MMPJ_XRM_Ligne_de_contrat__c> lstLigneContrat = Test.loadData(MMPJ_XRM_Ligne_de_contrat__c.sObjectType, 'MMPJ_XRM_SegmentationTestData_LigneContrat');

        Test.startTest();

        MMPJ_XRM_BatchCalculateSegmentation batch = new MMPJ_XRM_BatchCalculateSegmentation();
        batch.query += ' AND Name LIKE \'TestClass%\'';
        // batch.query += ' WHERE Name LIKE \'TestClass%\'';
        // batch.query += ' WHERE Name = \'TestClass\'';

        Id batchprocessid = Database.executeBatch(batch, 500);

        Test.stopTest();
    }

    @isTest
    static void MMPJ_XRM_BatchCalculateSegmentation_Schedule_Test () {

        Id rtId = Schema.SObjectType.MMPJ_Ext_Vign_Societe__c.getRecordTypeInfosByDeveloperName().get('MMPJ_Ext_Vign_Vigneron').getRecordTypeId();
        insert new MMPJ_XRM_Segmentation_Conf__c(SetupOwnerId = UserInfo.getOrganizationId(), RecordTypes__c = rtId);

        Test.StartTest();
        MMPJ_XRM_BatchCalculateSegmentation_Sch batch = new MMPJ_XRM_BatchCalculateSegmentation_Sch();        
        String sch = '0 0 23 * * ?';        
        System.schedule('Batch', sch, batch);
        Test.StopTest();
    }
}