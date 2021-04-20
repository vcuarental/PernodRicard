/******************************************************************************
*   Company:Valuenet    Developers:Elena Schwarzböck       Date:26/02/2014    *
*******************************************************************************/
/********************************************************************************
* MIGRACION LICENCIAS 
* AUTHOR: ZIMMIC                     DATE: 17/11/2016
*
********************************************************************************/
/********************************************************************************
* 
* MIGRACION LICENCIAS 
* AUTHOR: ZIMMIC                     DATE: 21/11/2016
*
********************************************************************************/

@istest
public with sharing class LAT_AP01_Product2_TEST {

    @testSetup
    static void setup(){


        LAT_GeneralConfig__c cfg1 = new LAT_GeneralConfig__c(
            name = 'OPP_Verification_Email_Recipients',
            lat_value__c = 'test@zimmic.com,test@zimmic.com');
        insert cfg1;

    }

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
            LAT_BR_BrandGrouping__c = 'ABSOLUT',
            RecordTypeId = Global_RecordTypeCache.getRtId('Product2' + 'BRA_Standard')
        );
        
        insert prod;
        List<Product2> listp = new List<Product2>{prod};
        LAT_AP01_Product2.activatesProduct2(listp);
        
        prod.LAT_BR_BrandGrouping__c = 'ABSOLUT2';
       
        update prod;
    }
    
    //MIGRATED 21/11/2016
    @istest
    static void unitTestB() {
        Utils.setMigrationDoneTest(true); 
        LAT_Product__c prod = new LAT_Product__c(
            Name = 'TestProd',
            LAT_CDUnit__c = 'CA',
            LAT_ExternalId__c = '444',
            LAT_IsRefactorProduct__c = 'Y',
            LAT_QTLeadTime__c = 5,
            LAT_Sku__c = '5666',
            LAT_BR_BrandGrouping__c = 'ABSOLUT',
            RecordTypeId = Global_RecordTypeCache.getRtId('LAT_Product__c' + 'BRA_Standard')
        );
        
        insert prod;
        List<LAT_Product__c> listp = new List<LAT_Product__c>{prod};
        LAT_AP01_Product2.activatesProduct2(listp);
        
        prod.LAT_BR_BrandGrouping__c = 'ABSOLUT2';
        
        update prod;
    
    }

}