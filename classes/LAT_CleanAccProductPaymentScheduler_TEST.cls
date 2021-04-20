/******************************************************************************
*   Company:Valuenet    Developers:Elena Schwarzböck       Date:12/05/2014    *
*******************************************************************************/

@istest
public with sharing class LAT_CleanAccProductPaymentScheduler_TEST {

    static testMethod void unitTest1() {
            
        LAT_Account_product_payment__c newapp = new LAT_Account_product_payment__c(
            TimeStamp__c = '123',
            ExternalUniqueKey__c = '12-0000'
        );
        insert newapp;
        
        System.Test.startTest();
        
        LAT_Clean_Account_Product_Payment__c newcapp = new LAT_Clean_Account_Product_Payment__c(
            TimeStamp__c = '124',
            LAT_Country__c = '1'
        );
        insert newcapp;
        
        System.Test.stopTest();
        
        
/*
        DateTime nowTime = datetime.now().addSeconds(65);
        String Seconds = '0';
        String Minutes = String.valueOf(nowTime.minute()).length() == 1 ? '0' + String.valueOf(nowTime.minute()) : String.valueOf(nowTime.minute());
        String Hours = String.valueOf(nowTime.hour()).length() == 1 ? '0' + String.valueOf(nowTime.hour()) : String.valueOf(nowTime.hour());
        String DayOfMonth = String.valueOf(nowTime.day());
        String Month = String.ValueOf(nowTime.month());
        String DayOfweek = '?';
        String optionalYear = String.valueOf(nowTime.year());
        String CronExpression = Seconds+' '+Minutes+' '+Hours+' '+DayOfMonth+' '+Month+' '+DayOfweek+' '+optionalYear;
        
        LAT_CleanAccProductPaymentScheduler scheduleToRun = new LAT_CleanAccProductPaymentScheduler();
        scheduleToRun.idCAPP = newcapp.Id;      
        String idjob = system.schedule('LAT_CleanAccProductPaymentScheduler '+system.now(), CronExpression, scheduleToRun);
        */
        
    }
}