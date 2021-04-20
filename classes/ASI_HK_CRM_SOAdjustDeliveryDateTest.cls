@isTest 
public with sharing class ASI_HK_CRM_SOAdjustDeliveryDateTest {
    private static ASI_HK_CRM_TestUtils.CommonData cmData;
    
    static testMethod void testAdjustDeliverDate_1() {
         
        ASI_HK_CRM_TestUtils.initSOEssentialSettings('0:00', '0:02');
        cmData = new ASI_HK_CRM_TestUtils.CommonData();
        ASI_HK_CRM_TestUtils.assignCreditAccountData(cmData, 3, 3);
        ASI_HK_CRM_TestUtils.assignSalesOrderData(cmData, 3, 3);
        Test.startTest(); 
        ASI_HK_CRM_Sales_Order__c so = cmData.so;
        so.ASI_HK_CRM_Delivery_Date__c = DateTime.now().date().addDays(1);
        update so;
        so.ASI_HK_CRM_Delivery_Date__c = DateTime.now().date().addDays(2);
        update so;
        so.ASI_HK_CRM_Urgent_Order__c = true;
        so.ASI_HK_CRM_Delivery_Date__c = DateTime.now().date();
        update so;
        Test.stopTest();
    }

    static testMethod void testAdjustDeliverDate_2() { 
        ASI_HK_CRM_TestUtils.initSOEssentialSettings('0:01', '23:59');
        cmData = new ASI_HK_CRM_TestUtils.CommonData();
        ASI_HK_CRM_TestUtils.assignCreditAccountData(cmData, 3, 3);
        ASI_HK_CRM_TestUtils.assignSalesOrderData(cmData, 3, 3);
        Test.startTest();     
        ASI_HK_CRM_Sales_Order__c so = cmData.so;
        so.ASI_HK_CRM_Delivery_Date__c = DateTime.now().date().addDays(1);
        update so;
        so.ASI_HK_CRM_Delivery_Date__c = DateTime.now().date().addDays(2);
        update so;
        so.ASI_HK_CRM_Urgent_Order__c = true;
        so.ASI_HK_CRM_Delivery_Date__c = DateTime.now().date();
        update so;
        Test.stopTest();
    }

    static testMethod void testAdjustDeliverDate_3() {
          
        ASI_HK_CRM_TestUtils.initSOEssentialSettings('23:58', '23:59');
        cmData = new ASI_HK_CRM_TestUtils.CommonData();
        ASI_HK_CRM_TestUtils.assignCreditAccountData(cmData, 3, 3);
        ASI_HK_CRM_TestUtils.assignSalesOrderData(cmData, 3, 3); 
        Test.startTest();    
        ASI_HK_CRM_Sales_Order__c so = cmData.so;
        so.ASI_HK_CRM_Delivery_Date__c = DateTime.now().date().addDays(1);
        update so;
        so.ASI_HK_CRM_Delivery_Date__c = DateTime.now().date().addDays(2);
        update so;
        so.ASI_HK_CRM_Urgent_Order__c = true;
        so.ASI_HK_CRM_Delivery_Date__c = DateTime.now().date();
        //update so;
        Test.stopTest();
    }    
    
    static testMethod void testAdjustDeliverDate_4() {
          
        ASI_HK_CRM_TestUtils.initSOEssentialSettings('23:58', '23:59');
        cmData = new ASI_HK_CRM_TestUtils.CommonData();
        ASI_HK_CRM_TestUtils.assignCreditAccountData(cmData, 3, 3);
        ASI_HK_CRM_TestUtils.assignSalesOrderData(cmData, 3, 3); 
        Test.startTest();    
        ASI_HK_CRM_Sales_Order__c so = cmData.so;
        so.ASI_HK_CRM_Urgent_Order__c = true;
        so.ASI_HK_CRM_Delivery_Date__c = DateTime.now().date().addDays(1);
        update so;
        so.ASI_HK_CRM_Urgent_Order__c = true;
        so.ASI_HK_CRM_Delivery_Date__c = DateTime.now().date().addDays(2);
        update so;
        so.ASI_HK_CRM_Delivery_Date__c = DateTime.now().date();
        update so;
        Test.stopTest();
    } 
    
}