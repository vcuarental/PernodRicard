/*------------------------------------------------------------
Author/Company:   IP Converge Data Services,Inc.
Description:      test class for EUR_CRM_VolPotentialHandler
History
25/04/2014        IPC     Created
------------------------------------------------------------*/
@isTest (SeeAllData = true)
public with sharing class EUR_CRM_TestVolPotentialHandler {

    private static EUR_CRM_Account__c accountEU; 
    private static Account account;
    private static EUR_CRM_Pros_Segmentation__c prosSegmentation;
    private static EUR_CRM_Group_Outlet_Type__c grpOutletType;
    private static EUR_CRM_Criteria_Threshold__c criteriaThreshold;
    private static EUR_CRM_Pros_Segmentation__c prosSegmentation2;
    private static EUR_CRM_Criteria_Threshold__c criteriaThreshold2;
    
    static testmethod void dataInsert(){
        
        List<EUR_CRM_Account__c> accEUList = new List<EUR_CRM_Account__c>();
        accEUList = EUR_CRM_TestClassUtilityHelper.createAccountsEU(1, 'EUR_AT_On_Trade');
        insert accEUList;
        
        system.assert(accEUList[0].Id<>null);
        
        List<EUR_CRM_Group_Outlet_Type__c> grpOutletTypeList = new List<EUR_CRM_Group_Outlet_Type__c>();
        grpOutletTypeList = EUR_CRM_TestClassUtilityHelper.createGroupOutletType(1, 'EUR_GB_Group_Outlet', 'EUR', null, null);
        insert grpOutletTypeList;
        
        grpOutletType = grpOutletTypeList[0];
        
        system.assert(grpOutletTypeList[0].Id<>null);
        
        List<EUR_CRM_Pros_Segmentation__c>  proSegmentationList = new List<EUR_CRM_Pros_Segmentation__c>();
        proSegmentationList = EUR_CRM_TestClassUtilityHelper.createProsSegmentation(1, 'EUR_GB_PROS_Segmentation', 'EUR', accEUList[0].Id, null, null, null, null, null);
        insert proSegmentationList;
        
        system.assert(proSegmentationList[0].Id<>null);
        
        prosSegmentation = proSegmentationList[0];
        
        List<EUR_CRM_Criteria_Set__c> criteriaSetList = new List<EUR_CRM_Criteria_Set__c>();
        criteriaSetList = EUR_CRM_TestClassUtilityHelper.createCriteriaSet(1, 'EUR_PRT_Image_Level_Criteria');
        insert criteriaSetList;
        
        system.assert(criteriaSetList[0].Id<>null);
        
        List<EUR_CRM_Criteria_Threshold__c> criteriaThresholdList = new List<EUR_CRM_Criteria_Threshold__c>();
        criteriaThresholdList = EUR_CRM_TestClassUtilityHelper.createCriteriaThreshold(1, 'Picklist', criteriaSetList[0].Id);

        insert criteriaThresholdList;
        
        system.assert(proSegmentationList[0].Id<>null);
        
        criteriaThreshold = criteriaThresholdList[0];
        
        
    }
    static testmethod void dataInsert2(){
        
        List<EUR_CRM_Account__c> accEUList = new List<EUR_CRM_Account__c>();
        accEUList = EUR_CRM_TestClassUtilityHelper.createAccountsEU(1, 'EUR_AT_On_Trade');
        insert accEUList;
        
        system.assert(accEUList[0].Id<>null);
        
        List<EUR_CRM_Group_Outlet_Type__c> grpOutletTypeList = new List<EUR_CRM_Group_Outlet_Type__c>();
        grpOutletTypeList = EUR_CRM_TestClassUtilityHelper.createGroupOutletType(1, 'EUR_GB_Group_Outlet', 'EUR', null, null);
        insert grpOutletTypeList;
        
        grpOutletType = grpOutletTypeList[0];
        
        system.assert(grpOutletTypeList[0].Id<>null);
        
        List<EUR_CRM_Pros_Segmentation__c>  proSegmentationList = new List<EUR_CRM_Pros_Segmentation__c>();
        proSegmentationList = EUR_CRM_TestClassUtilityHelper.createProsSegmentation(1, 'EUR_AT_PROS_Segmentation', 'EUR', accEUList[0].Id, null, null, null, null, null);
        insert proSegmentationList;
        
        system.assert(proSegmentationList[0].Id<>null);
        
        prosSegmentation2 = proSegmentationList[0];
        
        List<EUR_CRM_Criteria_Set__c> criteriaSetList = new List<EUR_CRM_Criteria_Set__c>();
        criteriaSetList = EUR_CRM_TestClassUtilityHelper.createCriteriaSet(1, 'EUR_PRT_Image_Level_Criteria');
        insert criteriaSetList;
        
        system.assert(criteriaSetList[0].Id<>null);
        
        List<EUR_CRM_Criteria_Threshold__c> criteriaThresholdList = new List<EUR_CRM_Criteria_Threshold__c>();
        criteriaThresholdList = EUR_CRM_TestClassUtilityHelper.createCriteriaThreshold(1, 'Picklist', criteriaSetList[0].Id);

        insert criteriaThresholdList;
        
        system.assert(proSegmentationList[0].Id<>null);
        
        criteriaThreshold2 = criteriaThresholdList[0];
        
        
    }
    static testmethod void testHandler1(){
        //AFTER INSERT
        Test.startTest();
        dataInsert();
        prosSegmentation = [Select Id, Name, EUR_CRM_Country_Code__c from EUR_CRM_Pros_Segmentation__c where Id =: prosSegmentation.Id];
        System.debug('@@PROSSEGCOUNTRY: '+prosSegmentation.EUR_CRM_Country_Code__c);
        List<EUR_CRM_Pros_Volume_Potential__c> prosVolPotentialList = new List<EUR_CRM_Pros_Volume_Potential__c>();
        prosVolPotentialList = EUR_CRM_TestClassUtilityHelper.createProsVolumePotential(1, 'EUR_PRT_ProsVolumePotential', 'EUR', prosSegmentation.Id, criteriaThreshold.Id);

        insert prosVolPotentialList;
        
        system.assert(prosVolPotentialList[0].Id<>null);
        
        Test.stopTest();
    }
    static testmethod void testHandler2(){
        //AFTER INSERT
        Test.startTest();
        dataInsert2();
        prosSegmentation2 = [Select Id, Name, EUR_CRM_Country_Code__c from EUR_CRM_Pros_Segmentation__c where Id =: prosSegmentation2.Id];
        System.debug('@@PROSSEGCOUNTRY: '+prosSegmentation2.EUR_CRM_Country_Code__c);
        List<EUR_CRM_Pros_Volume_Potential__c> prosVolPotentialList = new List<EUR_CRM_Pros_Volume_Potential__c>();
        prosVolPotentialList = EUR_CRM_TestClassUtilityHelper.createProsVolumePotential(1, 'EUR_PRT_ProsVolumePotential', 'EUR', prosSegmentation2.Id, criteriaThreshold2.Id);

        insert prosVolPotentialList;
        
        system.assert(prosVolPotentialList[0].Id<>null);
        
        Test.stopTest();
    }
    static testmethod void testHandler3(){
        //AFTER UPDATE
        
        dataInsert();
        prosSegmentation = [Select Id, Name, EUR_CRM_Country_Code__c from EUR_CRM_Pros_Segmentation__c where Id =: prosSegmentation.Id];
        System.debug('@@PROSSEGCOUNTRY: '+prosSegmentation.EUR_CRM_Country_Code__c);
        List<EUR_CRM_Pros_Volume_Potential__c> prosVolPotentialList = new List<EUR_CRM_Pros_Volume_Potential__c>();
        prosVolPotentialList = EUR_CRM_TestClassUtilityHelper.createProsVolumePotential(1, 'EUR_PRT_ProsVolumePotential', 'EUR', prosSegmentation.Id, criteriaThreshold.Id);

        insert prosVolPotentialList;
        
        system.assert(prosVolPotentialList[0].Id<>null);
        Test.startTest();
        update prosVolPotentialList;
        Test.stopTest();
    }
    static testmethod void testHandler4(){
        //AFTER UPDATE
        
        dataInsert2();
        prosSegmentation2 = [Select Id, Name, EUR_CRM_Country_Code__c from EUR_CRM_Pros_Segmentation__c where Id =: prosSegmentation2.Id];
        System.debug('@@PROSSEGCOUNTRY: '+prosSegmentation2.EUR_CRM_Country_Code__c);
        List<EUR_CRM_Pros_Volume_Potential__c> prosVolPotentialList = new List<EUR_CRM_Pros_Volume_Potential__c>();
        prosVolPotentialList = EUR_CRM_TestClassUtilityHelper.createProsVolumePotential(1, 'EUR_PRT_ProsVolumePotential', 'EUR', prosSegmentation2.Id, criteriaThreshold2.Id);

        insert prosVolPotentialList;
        
        system.assert(prosVolPotentialList[0].Id<>null);
        Test.startTest();
        update prosVolPotentialList;
        Test.stopTest();
    }
    
}