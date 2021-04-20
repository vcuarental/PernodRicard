@isTest
public class EUR_CRM_Test_RouteTemplate_Task{
    static testMethod void test1(){

        List<EUR_CRM_Route_Template__c> routeTemplateList = new List<EUR_CRM_Route_Template__c>();
        routeTemplateList = EUR_CRM_TestClassUtilityHelper.createRouteTemplate(2, 'EUR_GB_Route_Template', 'EUR');
        insert routeTemplateList;

        Task t = new Task();
        t.WhatId = routeTemplateList[0].Id; //Added by Laputa Hugo Cheung 27/09/2016
        t.OwnerId = UserInfo.getUserId();
        t.Subject='Donni';
        t.Status='Not Started';
        t.Priority='Normal';
        t.EUR_CRM_Route_Template__c = routeTemplateList[0].Id;
        insert t;
		
        t.EUR_CRM_Route_Template__c = routeTemplateList[1].Id;
        update t;
    }
}