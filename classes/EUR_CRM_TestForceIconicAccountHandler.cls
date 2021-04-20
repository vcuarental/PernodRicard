/*
  @Company:     IP-Converge Data Services, Inc.
  @Description: Test Class for EUR_CRM_ForceIconicAccountHandler Class.
  @Author:      IPC
  @History:     APR.28.2014 - Created
*/
@isTest (SeeAllData = true)
private class EUR_CRM_TestForceIconicAccountHandler {
    private static EUR_CRM_Account__c account;
    private static EUR_CRM_Pros_Segmentation__c prosSegmentation;
    private static EUR_CRM_Group_Outlet_Type__c groupOutlet;
    private static EUR_CRM_Image_Level__c imageLevel;
    
    static testmethod void dataInsert1(){
        
        account = EUR_CRM_TestClassUtilityHelper.createAccountsEU(1, 'GB FS Blitz')[0];
        account.EUR_CRM_Force_Iconic_Account__c = true;
        account.EUR_CRM_Sub_Channel__c = null;  //workaround for picklist value's restriction
        insert account;
        system.assert(account != null);

        groupOutlet = EUR_CRM_TestClassUtilityHelper.createGroupOutletType(1, 'EUR GB Group Outlet', '', null, null)[0];
        groupOutlet.EUR_CRM_Group_Outlet_Name__c = 'Nightclub';
        insert groupOutlet;
        system.assert(groupOutlet != null);

        imageLevel = EUR_CRM_TestClassUtilityHelper.createImageLevel(1, 'GB Image Level', '', groupOutlet.Id, 'Nightclub')[0];
        insert imageLevel;
        system.assert(imageLevel != null);

        prosSegmentation = EUR_CRM_TestClassUtilityHelper.createProsSegmentation(1, 'EUR_GB_PROS_Segmentation', '', null, groupOutlet.Id, null, imageLevel.Id, null, null)[0];
        insert prosSegmentation;
        system.assert(prosSegmentation != null);
    }

    static testmethod void dataInsert2(){

        account = EUR_CRM_TestClassUtilityHelper.createAccountsEU(1, 'GB FS Blitz')[0];
        account.EUR_CRM_Force_Iconic_Account__c = false;
        account.EUR_CRM_Sub_Channel__c = null;  //workaround for picklist value's restriction
        insert account;
        system.assert(account != null);
        
        groupOutlet = EUR_CRM_TestClassUtilityHelper.createGroupOutletType(1, 'EUR GB Group Outlet', '', null, null)[0];
        groupOutlet.EUR_CRM_Group_Outlet_Name__c = 'Nightclub';
        insert groupOutlet;
        system.assert(groupOutlet != null);
        
        imageLevel = EUR_CRM_TestClassUtilityHelper.createImageLevel(1, 'GB Image Level', '', groupOutlet.Id, 'Nightclub')[0];
        insert imageLevel;
        system.assert(imageLevel != null);
        
        prosSegmentation = EUR_CRM_TestClassUtilityHelper.createProsSegmentation(1, 'EUR_GB_PROS_Segmentation', '', account.Id, groupOutlet.Id, null, imageLevel.Id, null, null)[0];
        insert prosSegmentation;
        system.assert(prosSegmentation != null);
    }
    
    static testMethod void forceIconicAccountHandle0(){
        test.startTest();
            dataInsert1();
        test.stopTest();
    }
    
    static testMethod void forceIconicAccountHandle1(){
        dataInsert1();
        test.startTest();
            account.EUR_CRM_Force_Iconic_Account__c = true;
            update account;
            
            prosSegmentation.EUR_CRM_Account__c = account.Id;
            update prosSegmentation;
        test.stopTest();
    }
    
    static testMethod void forceIconicAccountHandle2(){
        dataInsert2();
        test.startTest();
            account.EUR_CRM_Force_Iconic_Account__c = false;
            update account;
            
            prosSegmentation.EUR_CRM_Account__c = account.Id; 
            update prosSegmentation;
        test.stopTest();
    }

}