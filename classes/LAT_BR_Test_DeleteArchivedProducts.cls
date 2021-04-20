/********************************************************************************
* 
* MIGRACION LICENCIAS 
* AUTHOR: ZIMMIC                     DATE: 21/11/2016
*
********************************************************************************/
@isTest
private class LAT_BR_Test_DeleteArchivedProducts {
	
	static testmethod void test() {
          Utils.setMigrationDoneTest(false); 
          Product2 prod = new Product2();
          prod.Name = 'Product';
          prod.IsActive = true;
          prod.CD_Unit__c = 'UN';
          prod.Internal_id__c = '123';
          prod.RecordTypeId = Global_RecordTypeCache.getRtId('Product2' + 'BRA_Standard_Archived');
          prod.LAT_IsRefactorProduct__c = '';
          insert prod;
          
          Test.startTest();
          Utils.setMigrationDoneTest(false); 
          LAT_Delete_ArchivedProducts c = new LAT_Delete_ArchivedProducts();
          Database.executeBatch(c);
          Test.stopTest();
    
          
          
    }
    //MIGRATED 21/11/2016
    static testmethod void testB() {
          Utils.setMigrationDoneTest(true); 
          LAT_Product__c prod = new LAT_Product__c();
          prod.Name = 'Product';
          prod.LAT_IsActive__c = true;
          prod.LAT_CDUnit__c = 'UN';
          prod.LAT_ExternalID__c = '123';
          prod.RecordTypeId = Global_RecordTypeCache.getRtId('LAT_Product__c' + 'BRA_Standard_Archived');
          prod.LAT_IsRefactorProduct__c = '';
          insert prod;
          
          Test.startTest();
          Utils.setMigrationDoneTest(true); 
          LAT_Delete_ArchivedProducts c = new LAT_Delete_ArchivedProducts();
          Database.executeBatch(c);
          Test.stopTest();
    
          
          
    }
      static testmethod void test2() {
          Utils.setMigrationDoneTest(false); 
          Product2 prod = new Product2();
          prod.Name = 'Product';
          prod.IsActive = true;
          prod.CD_Unit__c = 'UN';
          prod.Internal_id__c = '123';
          prod.RecordTypeId = Global_RecordTypeCache.getRtId('Product2' + 'BRA_Standard_Archived');
          prod.LAT_IsRefactorProduct__c = '';
          insert prod;
          
          Test.startTest();
          Utils.setMigrationDoneTest(false); 
          LAT2_Delete_ArchivedProducts c = new LAT2_Delete_ArchivedProducts();
          Database.executeBatch(c);
          Test.stopTest();
    
          
          
    }
    //MIGRATED 21/11/2016
    static testmethod void test2B() {
          Utils.setMigrationDoneTest(true); 
          LAT_Product__c prod = new LAT_Product__c();
          prod.Name = 'Product';
          prod.LAT_IsActive__c = true;
          prod.LAT_CDUnit__c = 'UN';
          prod.LAT_ExternalID__c = '123';
          prod.RecordTypeId = Global_RecordTypeCache.getRtId('LAT_Product__c' + 'BRA_Standard_Archived');
          prod.LAT_IsRefactorProduct__c = '';
          insert prod;
          
          Test.startTest();
          Utils.setMigrationDoneTest(true); 
          LAT2_Delete_ArchivedProducts c = new LAT2_Delete_ArchivedProducts();
          Database.executeBatch(c);
          Test.stopTest();
    
          
          
    }
}