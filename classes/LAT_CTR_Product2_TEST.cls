/******************************************************************************
*   Company:Valuenet    Developers:Elena Schwarzböck       Date:26/02/2014    *
*******************************************************************************/
 /********************************************************************************
* 
* MIGRACION LICENCIAS 
* AUTHOR: ZIMMIC                     DATE: 20/11/2016
*
********************************************************************************/
/********************************************************************************
* 
* MIGRACION LICENCIAS 
* AUTHOR: ZIMMIC                     DATE: 21/11/2016
*
********************************************************************************/
@istest
public with sharing class LAT_CTR_Product2_TEST {

    @istest
    static void unitTest() {
        Utils.setMigrationDoneTest(false); 

        Product2 prod = new Product2(
            Name = 'TestProd',
            CD_Unit__c = 'CA',
            Internal_id__c = '444',
            LAT_IsRefactorProduct__c = 'Y',
            QT_lead_time__c = 5,
            SKU__c = '5666',
            RecordTypeId = Global_RecordTypeCache.getRtId('Product2' + 'LAT_MX_PRD_Standard')
        );
        
        insert prod;    

    }

    //MIGRATED 21/11/2016
    @istest
    static void unitTestB() {
        Utils.setMigrationDoneTest(true); 

        LAT_GeneralConfig__c cfg = new LAT_GeneralConfig__c(name ='MX_IndexMarca_Notification_Users', LAT_Value__C = '1');
        insert cfg;
        LAT_GeneralConfig__c cfg1 = new LAT_GeneralConfig__c(name ='MX_DEFAULT_INDEX_MARGIN', LAT_Value__C = '2');
        insert cfg1;
        
        LAT_CHATTER_POST_BODY__c cpb = new LAT_CHATTER_POST_BODY__c();
        cpb.Name = 'LAT_MX_ProductoSinIndexMarca';
        cpb.Body__c = 'Tests';
        insert cpb;

        LAT_Product__c prod = new LAT_Product__c(
            Name = 'TestProd',
            LAT_CDUnit__c = 'CA',
            LAT_ExternalId__c = '444',
            LAT_IsRefactorProduct__c = 'Y',
            LAT_QTLeadTime__c = 5,
            LAT_Sku__c = '5666',
            RecordTypeId = Global_RecordTypeCache.getRtId('LAT_Product__c' + 'LAT_MX_PRD_Standard')
        );
        
        insert prod;  
        update prod;  
    }

}