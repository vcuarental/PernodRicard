/******************************************************************************
*   Company:Valuenet    Developers:Elena Schwarzböck       Date:30/01/2014    *
*******************************************************************************/
 /********************************************************************************
* 
* MIGRACION LICENCIAS 
* AUTHOR: ZIMMIC                     DATE: 17/11/2016
*
********************************************************************************/

@istest
public with sharing class LAT_FillAccountProductPayment_TEST {

   static testMethod void unitTest() {
            Test.startTest(); 
            Utils.setMigrationDoneTest(false);    
            LAT_Account_product_payment__c newapp = new LAT_Account_product_payment__c();
            newapp.TimeStamp__c = '123';
            newapp.CustomerCountryAN8Code__c = '1-121212';
            insert newapp;
            LAT_FillAccountProductPayment clase = new LAT_FillAccountProductPayment();
            List<LAT_Account_product_payment__c> lista = new List<LAT_Account_product_payment__c>();
            lista.add(newapp);
            LAT_FillAccountProductPayment.fillProductPayment(lista);
            update lista;
            LAT_FillAccountProductPayment.fillProductPayment(lista);
            //LAT_FillAccountProductPayment.fillProductPayment();
            Test.stopTest();
   
   }
//MIGRATED 17/11/2016
   static testMethod void unitTestB() {

            Utils.setMigrationDoneTest(true);    
            LAT_Account_product_payment__c newapp = new LAT_Account_product_payment__c();
            newapp.TimeStamp__c = '123';
            newapp.CustomerCountryAN8Code__c = '1-121212';
            insert newapp;
            LAT_FillAccountProductPayment clase = new LAT_FillAccountProductPayment();
            List<LAT_Account_product_payment__c> lista = new List<LAT_Account_product_payment__c>();
            lista.add(newapp);
            LAT_FillAccountProductPayment.fillProductPayment(lista);
            update lista;
            LAT_FillAccountProductPayment.fillProductPayment(lista);
            //LAT_FillAccountProductPayment.fil
   }

   static testMethod void unitTest3() {

            Utils.setMigrationDoneTest(true);    
            LAT_ProductTriggerHandler.init(null,null,null,null);
   }


}