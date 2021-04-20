/*------------------------------------------------------------
Author/Company:    IP Converge Data Services,Inc.
Description:       test class for EUR_CRM_AssignGroupOutletTypeController
History
24/04/2014         IPC     Created
------------------------------------------------------------*/
@isTest (SeeAllData=true)
public with sharing class EUR_CRM_TestAssignGrpOutletTypeCtrlr {

    private static EUR_CRM_Account__c accountEU; 
    private static EUR_CRM_Pros_Segmentation__c prosSegmentation;
    private static EUR_CRM_Group_Outlet_Type__c grpOutletType;
    
    static void dataInsert(){
        
        List<EUR_CRM_Account__c> accEUList = new List<EUR_CRM_Account__c>();
        accEUList = EUR_CRM_TestClassUtilityHelper.createAccountsEU(1, 'AT On Trade');
        insert accEUList;
        
        system.assert(accEUList[0].Id<>null);
        
        List<EUR_CRM_Pros_Segmentation__c>  proSegmentationList = new List<EUR_CRM_Pros_Segmentation__c>();
        proSegmentationList = EUR_CRM_TestClassUtilityHelper.createProsSegmentation(1, 'EUR_AT_PROS_Segmentation', 'EUR', accEUList[0].Id, null, null, null, null, null);
        insert proSegmentationList;
        
        system.assert(proSegmentationList[0].Id<>null);
        
        prosSegmentation = proSegmentationList[0];
        List<EUR_CRM_Group_Outlet_Type__c> grpOutletTypeList = new List<EUR_CRM_Group_Outlet_Type__c>();
        grpOutletTypeList = EUR_CRM_TestClassUtilityHelper.createGroupOutletType(1, 'EUR AT Group Outlet', 'EUR', null, null);
        insert grpOutletTypeList;
        grpOutletType = grpOutletTypeList.get(0);
        List<EUR_CRM_Outlet_Type__c> outletTypeList= new List<EUR_CRM_Outlet_Type__c>();
        outletTypeList= EUR_CRM_TestClassUtilityHelper.createOutletType(1, 'EUR AT Outlet Type', 'EUR', grpOutletTypeList.get(0).id);
        insert outletTypeList;
        
        
    }
    static testmethod void testStandardController(){
    
        dataInsert();       
       
        
        system.assert(grpOutletType.Id<>null);
        
        Test.startTest();
        ApexPages.Standardcontroller standard = new ApexPages.Standardcontroller(prosSegmentation);
        ApexPages.currentPage().getParameters().put('Id', prosSegmentation.Id);
        EUR_CRM_AssignGroupOutletTypeController assignGrpOutlet = new EUR_CRM_AssignGroupOutletTypeController(standard);
        assignGrpOutlet.getChildOptions();
        assignGrpOutlet.handleSave();
        assignGrpOutlet.handleExit();
        Test.stopTest();
    }
}