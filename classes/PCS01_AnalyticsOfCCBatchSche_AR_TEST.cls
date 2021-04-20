/****************************************************
 Dev: Denis Aranda  Version: 1  Consulting: Valuenet
****************************************************/

@IsTest
public with sharing class PCS01_AnalyticsOfCCBatchSche_AR_TEST {

    //Test sin Custom Setting
    static testMethod void UnitTest(){
        delete [SELECT Id FROM CS005_Emails__c];
        
        Datetime sysNow = Datetime.now().addMinutes(2);
        String Seconds = '0';
        String Minutes = sysNow.minute() < 10 ? '0' + sysNow.minute() : String.valueOf(sysNow.minute());
        String Hours = sysNow.hour() < 10 ? '0' + sysNow.hour() : String.valueOf(sysNow.hour());
        String DayOfMonth = String.ValueOf(sysNow.day());
        String Month = String.ValueOf(sysNow.month());
        String DayOfweek = '?';
        String optionalYear = String.valueOf(sysNow.year());
        
        String CronExpression = Seconds+' '+Minutes+' '+Hours+' '+DayOfMonth+' '+Month+' '+DayOfweek+' '+optionalYear;
        test.startTest();
        system.schedule('Test'+system.now(), CronExpression, new PCS01_AnalyticsofCCBatchSche_AR());
        test.stopTest();
    }
    
    //Test con Custom Setting
    static testMethod void UnitTest1(){
        delete [SELECT Id FROM CS005_Emails__c];
        insert new CS005_Emails__c(Name='UpdateOfAnalyticsofCC', Emails__c=UserInfo.getUserEmail());
        
        Datetime sysNow = Datetime.now().addMinutes(2);
        String Seconds = '0';
        String Minutes = sysNow.minute() < 10 ? '0' + sysNow.minute() : String.valueOf(sysNow.minute());
        String Hours = sysNow.hour() < 10 ? '0' + sysNow.hour() : String.valueOf(sysNow.hour());
        String DayOfMonth = String.ValueOf(sysNow.day());
        String Month = String.ValueOf(sysNow.month());
        String DayOfweek = '?';
        String optionalYear = String.valueOf(sysNow.year());
        
        String CronExpression = Seconds+' '+Minutes+' '+Hours+' '+DayOfMonth+' '+Month+' '+DayOfweek+' '+optionalYear;
        test.startTest();
        system.schedule('Test'+system.now(), CronExpression, new PCS01_AnalyticsofCCBatchSche_AR());
        test.stopTest();
    }
}