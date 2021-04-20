public with sharing class LAT_VFC01_02_VisRecHoursController {
    
    public Account acc {get; set;}
    public id accId {get; set;}
    public LAT_CWH_ClientWorkHour__c cli {get; set;}
    
    public LAT_VFC01_02_VisRecHoursController(ApexPages.StandardController controller) {
        accId = controller.getId();
        try{
        cli = [SELECT Id, Name, Monday_1st_period_begin_Time__c, Monday_1st_period_End_Time__c, Monday_1st_period_Order_Begin_time__c, Monday_1st_period_Order_End_time__c, Monday_2nd_period_begin_Time__c, 
            Monday_2nd_period_End_Time__c, Monday_2nd_period_Order_Begin_time__c, Monday_2nd_period_Order_End_time__c, Tuesday_1st_period_begin_Time__c, Tuesday_1st_period_End_Time__c, 
            Tuesday_1st_period_Order_Begin_time__c, Tuesday_1st_period_Order_End_time__c, Tuesday_2nd_period_begin_Time__c, Tuesday_2nd_period_End_Time__c, Tuesday_2nd_period_Order_Begin_time__c, 
            Tuesday_2nd_period_Order_End_time__c, Wednesday_1st_period_begin_Time__c, Wednesday_1st_period_End_Time__c, Wednesday_1st_period_Order_Begin_time__c, Wednesday_1st_period_Order_End_time__c, 
            Wednesday_2nd_period_begin_Time__c, Wednesday_2nd_period_End_Time__c, Wednesday_2nd_period_Order_Begin_time__c, Wednesday_2nd_period_Order_End_time__c, Thursday_1st_period_begin_Time__c, 
            Thursday_1st_period_End_Time__c, Thursday_1st_period_Order_Begin_time__c, Thursday_1st_period_Order_End_time__c, Thursday_2nd_period_begin_Time__c, Thursday_2nd_period_End_Time__c, 
            Thursday_2nd_period_Order_Begin_time__c, Thursday_2nd_period_Order_End_time__c, Friday_1st_period_begin_Time__c, Friday_1st_period_End_Time__c, Friday_1st_period_Order_Begin_time__c, 
            Friday_1st_period_Order_End_time__c, Friday_2nd_period_begin_Time__c, Friday_2nd_period_End_Time__c, Friday_2nd_period_Order_Begin_time__c, Friday_2nd_period_Order_End_time__c, 
            Saturday_1st_period_begin_Time__c, Saturday_1st_period_End_Time__c, Saturday_1st_period_Order_Begin_time__c, Saturday_1st_period_Order_End_time__c, Saturday_2nd_period_begin_Time__c, 
            Saturday_2nd_period_End_Time__c, Sunday_2nd_period_End_Time__c, Saturday_2nd_period_Order_Begin_time__c, Saturday_2nd_period_Order_End_time__c, Sunday_1st_period_begin_Time__c, 
            Sunday_1st_period_End_Time__c, Sunday_1st_period_Order_Begin_time__c, Sunday_1st_period_Order_End_time__c, Sunday_2nd_period_begin_Time__c, Sunday_2nd_period_Order_Begin_time__c, 
            Sunday_2nd_period_Order_End_time__c, Account__c, AccountId__c, Friday__c, Friday_order__c, LATACCOUNT__c, Monday__c, Monday_order__c, Saturday__c, Saturday_order__c, 
            Sunday_Order__c, Sunday__c, Thursday_Order__c, Thursday__c, Tuesday__c, Tuesday_order__c, Wednesday_Order__c, Wednesday__c
            FROM LAT_CWH_ClientWorkHour__c
            WHERE Account__c =: accId];}catch(Exception e){}
    }
}