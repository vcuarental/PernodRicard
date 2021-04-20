/**********************************************
 Dev: Juan Pablo Cubo       Version: 1
**********************************************/
@istest
public with sharing class LAT_CleanAccountProductPaymentTest {

    @istest
    public static void unitTest() {
        LAT_Account_product_payment__c newapp = new LAT_Account_product_payment__c();
        newapp.TimeStamp__c = '123';
        newapp.ExternalUniqueKey__c = '12-0000';
        insert newapp;
        System.Test.startTest();
        LAT_Clean_Account_Product_Payment__c newcapp = new LAT_Clean_Account_Product_Payment__c();
        newcapp.TimeStamp__c = '124';
        newapp.ExternalUniqueKey__c = '12-1111';
        insert newcapp;
        //test batch with null timestamp
        LAT_CleanAccountProductPaymentBatch batchToRun = new LAT_CleanAccountProductPaymentBatch();
        Database.executeBatch(batchToRun);
        System.Test.stopTest();
    }
    
}