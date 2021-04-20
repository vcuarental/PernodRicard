/********************************************************************************
*                       
* MIGRACION LICENCIAS 
* AUTHOR: ZIMMIC                     DATE: 14/11/2016
*
********************************************************************************/
@isTest                            
private class LAT_BR_Test_ArchiveProducts {

    static testmethod void test() {
        Utils.setMigrationDoneTest(false);
          Product2 prod = new Product2();
          prod.Name = 'Product';
          prod.IsActive = true;
          prod.CD_Unit__c = 'UN';
          prod.Internal_id__c = '123';
          prod.RecordTypeId = Global_RecordTypeCache.getRtId('Product2' + 'BRA_Standard');
          prod.LAT_IsRefactorProduct__c = '';
          insert prod;
          
          Test.startTest();
          Utils.setMigrationDoneTest(false);
          LAT_BR_ArchiveProducts c = new LAT_BR_ArchiveProducts();
          Database.executeBatch(c);
          Test.stopTest();
          
    }
    //MIGRATED 14/11/2016 
    static testmethod void testMigrated() {
          Utils.setMigrationDoneTest(true);
          LAT_Product__c prod = new LAT_Product__c();
          prod.Name = 'Product';
          prod.LAT_IsActive__c = true;
          prod.LAT_CDUnit__c = 'UN';
          prod.LAT_ExternalID__c = '123';
          prod.RecordTypeId = Global_RecordTypeCache.getRtId('LAT_Product__c' + 'BRA_Standard');
          prod.LAT_IsRefactorProduct__c = '';
          insert prod;
          
          Test.startTest();
          LAT_BR_ArchiveProducts c = new LAT_BR_ArchiveProducts();
          Database.executeBatch(c);
          Test.stopTest();
    
          
          
    }
}