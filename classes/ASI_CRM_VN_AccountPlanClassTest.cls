/*
*********************************************************************************
     * Name: ASI_CRM_VN_Test_AccountPlanClass
     * Description: Test Class for ASI_CRM_VN_AccountPlanClass controller extension
     *
     * Version History
     * Date             Developer               Comments
     * ---------------  --------------------    -------------------------------------------------------
     * 20/10/2015       Laputa: Neha             Created
********************************************************************************
*/

@isTest
private class ASI_CRM_VN_AccountPlanClassTest{
    
    static ASI_CRM_VN_AccountPlanClass accPlanClassController;

    public list<ASI_CRM_AccountsAdditionalField__c> lstAccAdditionalField = new list<ASI_CRM_AccountsAdditionalField__c>();
    
    // Test Method to check if the value of serivce pack item is 'Visiblity'//
    static testMethod void displayServicePackVisblityTest(){
       
        String strRecordTypeID;
        list<RecordType> getRecordType=[Select Id 
                                        From RecordType 
                                        Where SobjectType='ASI_CRM_AccountsAdditionalField__c' 
                                        and Name = 'Outlet (VN)'];
        strRecordTypeID=String.valueOf(getRecordType[0].Id);
       
        ASI_HK_CRM_Running_Number__c rnumberObj=
            ASI_CRM_VN_TestDataFactory.getRunningNumber('ASI_CRM_VN_Customer_Code',2,'text',6,1992);
        insert rnumberObj;
        
        ASI_CRM_ServicePack__c servicePackObj=
            ASI_CRM_VN_TestDataFactory.getServicePack('servicePackTest','restaurant',12,1,3,5,7,4,9,3,14,15,11,1,'Visibility',7,65,'Attack'); 
        insert servicePackObj;
        
        ASI_CRM_ServicePackItem__c servicePackItemObj= 
            ASI_CRM_VN_TestDataFactory.getServicePackItem('Visibility','VR12',servicePackObj.Id);
        insert servicePackItemObj;
        
        ASI_CRM_ServicePackItem__c servicePackItemObjSubBrand= 
            ASI_CRM_VN_TestDataFactory.getServicePackItem('Visibility','VR11',servicePackObj.Id);
        insert servicePackItemObjSubBrand;
        
        Account acc=new Account(Name='Test Account');
        insert acc;

        ASI_CRM_AccountsAdditionalField__c customerObj= 
            ASI_CRM_VN_TestDataFactory.getCustomerAccount('customerTest','Presence','HEB',strRecordTypeId,servicePackObj.Id,acc.id );
        insert customerObj;  
                
        //Instance of Standard controller 
        ApexPages.StandardController StandardController = new ApexPages.StandardController(customerObj);
        //Instance of controller
        PageReference pageRef = Page.ASI_CRM_VN_AccountPlan;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id',customerObj.Id);       
        Test.startTest();
        ASI_CRM_VN_AccountPlanClass controllerInstance = new ASI_CRM_VN_AccountPlanClass(StandardController);
        controllerInstance.gotoProsSegmentation();
        Test.stopTest();
        system.assertEquals(controllerInstance.visibilityValues,'VR12,VR11');
        
    }
    
    // Test Method to check if the value of serivce pack item is 'Presence'//  
    static testMethod void displayServicePackPresenceTest(){
        
        String strRecordTypeId = [Select Id 
                                  From RecordType 
                                  Where SobjectType='ASI_CRM_AccountsAdditionalField__c' 
                                  and Name = 'Outlet (VN)'].Id;  
        ASI_CRM_ServicePack__c servicePackObj= 
            ASI_CRM_VN_TestDataFactory.getServicePack('servicePackTest','restaurant',12,1,3,5,7,4,9,3,14,15,11,1,'Visiblity',7,65,'Attack'); 
        insert servicePackObj;
        
        ASI_HK_CRM_Running_Number__c  rnumberObj= 
            ASI_CRM_VN_TestDataFactory.getRunningNumber('ASI_CRM_VN_Customer_Code',2,'text',6,1992);
        insert rnumberObj;
        
        ASI_CRM_ServicePackItem__c servicePackItemObj= 
            ASI_CRM_VN_TestDataFactory.getServicePackItem('Presence','PR12',servicePackObj.Id);
        insert servicePackItemObj;
        
        ASI_CRM_ServicePackItem__c servicePackItemObjSubBrand= 
            ASI_CRM_VN_TestDataFactory.getServicePackItem('Presence','PR11',servicePackObj.Id);
        insert servicePackItemObjSubBrand;
        
        Account acc=new Account(Name='Test Account');
        insert acc;
        
        ASI_CRM_AccountsAdditionalField__c customerObj= 
            ASI_CRM_VN_TestDataFactory.getCustomerAccount('customerTest','Presence','HEB',strRecordTypeId,servicePackObj.Id,acc.id );
        insert customerObj;
        
        //Instance of Standard controller 
        ApexPages.StandardController StandardController = new ApexPages.StandardController(customerObj);
        //Instance of controller
        Test.startTest();
        ASI_CRM_VN_AccountPlanClass controllerInstance =  new ASI_CRM_VN_AccountPlanClass(StandardController );
        controllerInstance.gotoProsSegmentation();
        Test.stopTest();
        system.assertEquals(controllerInstance.presenceValues,'PR12,PR11');
    }
    
     // Test Method to check if the value of serivce pack item is 'Activation'//
     static testMethod void displayServicePackActivationTest(){
        
        String strRecordTypeId = [Select Id From RecordType Where SobjectType = 'ASI_CRM_AccountsAdditionalField__c' and Name = 'Outlet (VN)'].Id;  
        
        ASI_CRM_ServicePack__c servicePackObj= 
            ASI_CRM_VN_TestDataFactory.getServicePack('servicePackTest','restaurant',12,1,3,5,7,4,9,3,14,15,11,1,'Activation',7,65,'Attack'); 
        insert servicePackObj;
        
        ASI_HK_CRM_Running_Number__c  rnumberObj= 
            ASI_CRM_VN_TestDataFactory.getRunningNumber('ASI_CRM_VN_Customer_Code',2,'text',6,1992);
        insert rnumberObj;

        ASI_CRM_ServicePackItem__c servicePackItemObj= 
            ASI_CRM_VN_TestDataFactory.getServicePackItem('Activation','AR12',servicePackObj.Id);
        insert servicePackItemObj;
        
        ASI_CRM_ServicePackItem__c servicePackItemObjSubBrand= 
            ASI_CRM_VN_TestDataFactory.getServicePackItem('Activation','AR11',servicePackObj.Id);
        insert servicePackItemObjSubBrand;
        
        Account acc=new Account(Name='Test Account');
        insert acc;
        
        ASI_CRM_AccountsAdditionalField__c customerObj= 
            ASI_CRM_VN_TestDataFactory.getCustomerAccount('customerTest','Presence','HEB',strRecordTypeId,servicePackObj.Id,acc.id);
        insert customerObj;  
        
        //Instance of Standard controller 
        ApexPages.StandardController StandardController = new ApexPages.StandardController(customerObj);
        //Instance of controller
        Test.startTest();
        ASI_CRM_VN_AccountPlanClass controllerInstance =  new ASI_CRM_VN_AccountPlanClass(StandardController );
        controllerInstance.gotoProsSegmentation();
        Test.stopTest();
        system.assertEquals(controllerInstance.activationValues,'AR12,AR11');
        
    }


}