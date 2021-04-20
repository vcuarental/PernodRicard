/*
*********************************************************************************
     * Name: ASI_CRM_VN_AutoNumberAssign_Test 
     * Description: Test Class for ASI_CRM_VN_AssignAutoNumber controller 
     *
     * Version History
     * Date             Developer               Comments
     * ---------------  --------------------    -------------------------------------------------------
     * 06/11/2015       Laputa: Neha             Created
********************************************************************************
*/


@isTest
public class ASI_CRM_VN_AutoNumberAssign_Test {
    
    static testMethod void autoNumberAssignmentTest() {
    
        list<ASI_HK_CRM_Running_Number__c> newRunningNumbrList = new list<ASI_HK_CRM_Running_Number__c>();
        string result;
       
        ASI_HK_CRM_Running_Number__c  instance = ASI_CRM_VN_TestDataFactory.getRunningNumber('key',1,'DateFormat',1,date.today().year());
        insert instance;
        
        test.startTest();
        
        Integer rNewSize = newRunningNumbrList.size();
       
        ASI_CRM_VN_AutoNumberAssignment controllerInstance = new ASI_CRM_VN_AutoNumberAssignment('key');
       
        result = controllerInstance.nextAutoNumStr();
        controllerInstance.writeToDB();

        test.stopTest();
        
        newRunningNumbrList = [Select Id,ASI_HK_CRM_Running_Number__c 
                               from ASI_HK_CRM_Running_Number__c
                               where Id =: instance.Id];
        
    }
    
    static testMethod void autoNumberAssignmentWithNullDateFormatTest() {
   
        list<ASI_HK_CRM_Running_Number__c> newRunningNumbrList = new list<ASI_HK_CRM_Running_Number__c>();
        string result;
        
        ASI_HK_CRM_Running_Number__c  instance = ASI_CRM_VN_TestDataFactory.getRunningNumber('key',1,'',1,date.today().year());
        insert instance;
        
        test.startTest();

           
        ASI_CRM_VN_AutoNumberAssignment controllerInstance = new ASI_CRM_VN_AutoNumberAssignment('key');
           
        result = controllerInstance.nextAutoNumStr();
        controllerInstance.writeToDB();
        
        test.stopTest();
        
        newRunningNumbrList = [Select Id,ASI_HK_CRM_Running_Number__c 
                               from ASI_HK_CRM_Running_Number__c
                               where Id =: instance.Id];
        
        
    }
    
    static testMethod void autoNumberAssignmentWithCorrectDateFormatTest() {
   
        list<ASI_HK_CRM_Running_Number__c> newRunningNumbrList = new list<ASI_HK_CRM_Running_Number__c>();
        string result;
        ASI_HK_CRM_Running_Number__c  instance = ASI_CRM_VN_TestDataFactory.getRunningNumber('key',2,'VN{000000}',2,date.today().year());
        insert instance;

        test.startTest();

           
        ASI_CRM_VN_AutoNumberAssignment controllerInstance = new ASI_CRM_VN_AutoNumberAssignment('key');

        result = controllerInstance.nextAutoNumStr();
        controllerInstance.writeToDB();

        test.stopTest();

        newRunningNumbrList = [Select Id,ASI_HK_CRM_Running_Number__c 
                               from ASI_HK_CRM_Running_Number__c
                               where Id =: instance.Id];
        
    }
    
    
    static testMethod void autoNumberAssignmentWithtDateFormat1Test() {
   
        list<ASI_HK_CRM_Running_Number__c> newRunningNumbrList = new list<ASI_HK_CRM_Running_Number__c>();
        string result;
        
        ASI_HK_CRM_Running_Number__c  instance = ASI_CRM_VN_TestDataFactory.getRunningNumber('key',2,'VN{YYYY}',2,date.today().year());
        insert instance;
        
        test.startTest();

        ASI_CRM_VN_AutoNumberAssignment controllerInstance = new ASI_CRM_VN_AutoNumberAssignment('key');
       
        result = controllerInstance.nextAutoNumStr();
        controllerInstance.writeToDB();

        test.stopTest();
        
        newRunningNumbrList = [Select Id,ASI_HK_CRM_Running_Number__c 
                               from ASI_HK_CRM_Running_Number__c
                               where Id =: instance.Id];

    }
    
    static testMethod void autoNumberAssignmentWithtDateFormat2Test() {
   
        list<ASI_HK_CRM_Running_Number__c> newRunningNumbrList = new list<ASI_HK_CRM_Running_Number__c>();
        string result;
        ASI_HK_CRM_Running_Number__c  instance = ASI_CRM_VN_TestDataFactory.getRunningNumber('key',2,'VN{YY}',2,date.today().year());
        insert instance;
        
        test.startTest();
        
       
        ASI_CRM_VN_AutoNumberAssignment controllerInstance = new ASI_CRM_VN_AutoNumberAssignment('key');
       
        result = controllerInstance.nextAutoNumStr();
        controllerInstance.writeToDB();

        test.stopTest();
        
        newRunningNumbrList = [Select Id,ASI_HK_CRM_Running_Number__c 
                               from ASI_HK_CRM_Running_Number__c
                               where Id =: instance.Id];
        
    }
    
    static testMethod void autoNumberAssignmentWithtDateFormat3Test() {
   
        list<ASI_HK_CRM_Running_Number__c> newRunningNumbrList = new list<ASI_HK_CRM_Running_Number__c>();
        string result;
        
        DateTime testDate = DateTime.newInstance(12,12,12);

        ASI_HK_CRM_Running_Number__c  instance = ASI_CRM_VN_TestDataFactory.getRunningNumber('key',2,'VN{MM}',2,testDate.year());
        insert instance;

        test.startTest();

        ASI_CRM_VN_AutoNumberAssignment controllerInstance = new ASI_CRM_VN_AutoNumberAssignment('key');

        result = controllerInstance.nextAutoNumStr();
        controllerInstance.writeToDB();

        test.stopTest();

        newRunningNumbrList = [Select Id,ASI_HK_CRM_Running_Number__c 
                               from ASI_HK_CRM_Running_Number__c
                               where Id =: instance.Id];
        
    }
    
    static testMethod void autoNumberAssignmentNoRecordFoundTest() {
   
        list<ASI_HK_CRM_Running_Number__c> newRunningNumbrList = new list<ASI_HK_CRM_Running_Number__c>();
        string result;
        
        ASI_HK_CRM_Running_Number__c  instance = ASI_CRM_VN_TestDataFactory.getRunningNumber('key',2,'VN{YY}',2,null);
        insert instance;
        
        test.startTest();

           
        ASI_CRM_VN_AutoNumberAssignment controllerInstance = new ASI_CRM_VN_AutoNumberAssignment('key');

        result = controllerInstance.nextAutoNumStr();
        controllerInstance.writeToDB();

        test.stopTest();
        
        newRunningNumbrList = [Select Id,ASI_HK_CRM_Running_Number__c 
                               from ASI_HK_CRM_Running_Number__c
                               where Id =: instance.Id];
    
    }
    
    static testMethod void autoNumberAssignmentWithtWrongFiscalYearTest() {
   
        list<ASI_HK_CRM_Running_Number__c> newRunningNumbrList = new list<ASI_HK_CRM_Running_Number__c>();
        string result;
        DateTime testDate = DateTime.newInstance(12,12,12);

        ASI_HK_CRM_Running_Number__c  instance = ASI_CRM_VN_TestDataFactory.getRunningNumber('key',2,'VN{MM}',testDate.month(),testDate.year()-1);
        insert instance;

        test.startTest();

        ASI_CRM_VN_AutoNumberAssignment controllerInstance = new ASI_CRM_VN_AutoNumberAssignment('key');

        result = controllerInstance.nextAutoNumStr();
        controllerInstance.writeToDB();

        test.stopTest();

        newRunningNumbrList = [Select Id,ASI_HK_CRM_Running_Number__c 
                               from ASI_HK_CRM_Running_Number__c
                               where Id =: instance.Id];
        
    }
}