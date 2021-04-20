@isTest (SeeAllData = true)
public with sharing class ASI_CRM_TestVolPotentialHandler {

    private static ASI_CRM_AccountsAdditionalField__c accountASI; 
    private static ASI_CRM_Pros_Segmentation__c prosSegmentation;
    private static ASI_CRM_Group_Outlet_Type__c grpOutletType;
    private static ASI_CRM_Criteria_Threshold__c criteriaThreshold;
    private static ASI_CRM_Pros_Segmentation__c prosSegmentation2;
    private static ASI_CRM_Criteria_Threshold__c criteriaThreshold2;
    
    static testmethod void dataInsert(){
        
        List<ASI_CRM_AccountsAdditionalField__c > accASIList = new List<ASI_CRM_AccountsAdditionalField__c >();
        accASIList = ASI_CRM_TestClassUtilityHelperPROS.createAccountsASI(1, 'ASI_CRM_SG_Outlet');
        insert accASIList;
        
        system.assert(accASIList[0].Id<>null);
        
        List<ASI_CRM_Group_Outlet_Type__c> grpOutletTypeList = new List<ASI_CRM_Group_Outlet_Type__c>();
        grpOutletTypeList = ASI_CRM_TestClassUtilityHelperPROS.createGroupOutletType(1, 'ASI_CRM_SG_Group_Outlet_Type', 'SGD', null, null);
        insert grpOutletTypeList;
        
        grpOutletType = grpOutletTypeList[0];
        
        system.assert(grpOutletTypeList[0].Id<>null);
        
        List<ASI_CRM_Pros_Segmentation__c>  proSegmentationList = new List<ASI_CRM_Pros_Segmentation__c>();
        proSegmentationList = ASI_CRM_TestClassUtilityHelperPROS.createProsSegmentation(1, 'ASI_CRM_SG_PROS_Segmentation', 'SGD', accASIList[0].Id, null, null, null, null);
        insert proSegmentationList;
        
        system.assert(proSegmentationList[0].Id<>null);
        
        prosSegmentation = proSegmentationList[0];
        
        List<ASI_CRM_Criteria_Set__c> criteriaSetList = new List<ASI_CRM_Criteria_Set__c>();
        criteriaSetList = ASI_CRM_TestClassUtilityHelperPROS.createCriteriaSet(1, 'ASI_SG_Image_Level_Criteria');
        insert criteriaSetList;
        
        system.assert(criteriaSetList[0].Id<>null);
        
        List<ASI_CRM_Criteria_Threshold__c> criteriaThresholdList = new List<ASI_CRM_Criteria_Threshold__c>();
        criteriaThresholdList = ASI_CRM_TestClassUtilityHelperPROS.createCriteriaThreshold(1, 'ASI_CRM_SG_Picklist', criteriaSetList[0].Id);

        insert criteriaThresholdList;
        
        system.assert(proSegmentationList[0].Id<>null);
        
        criteriaThreshold = criteriaThresholdList[0];
        
        
    }
    static testmethod void dataInsert2(){
        
        List<ASI_CRM_AccountsAdditionalField__c> accASIList = new List<ASI_CRM_AccountsAdditionalField__c>();
        accASIList = ASI_CRM_TestClassUtilityHelperPROS.createAccountsASI(1, 'ASI_CRM_SG_Outlet');
        insert accASIList;
        
        system.assert(accASIList[0].Id<>null);
        
        List<ASI_CRM_Group_Outlet_Type__c> grpOutletTypeList = new List<ASI_CRM_Group_Outlet_Type__c>();
        grpOutletTypeList = ASI_CRM_TestClassUtilityHelperPROS.createGroupOutletType(1, 'ASI_CRM_SG_Group_Outlet_Type', 'SGD', null, null);
        insert grpOutletTypeList;
        
        grpOutletType = grpOutletTypeList[0];
        
        system.assert(grpOutletTypeList[0].Id<>null);
        
        List<ASI_CRM_Pros_Segmentation__c>  proSegmentationList = new List<ASI_CRM_Pros_Segmentation__c>();
        proSegmentationList = ASI_CRM_TestClassUtilityHelperPROS.createProsSegmentation(1, 'ASI_CRM_SG_PROS_Segmentation', 'SGD', accASIList[0].Id, null, null, null, null);
        insert proSegmentationList;
        
        system.assert(proSegmentationList[0].Id<>null);
        
        prosSegmentation2 = proSegmentationList[0];
        
        List<ASI_CRM_Criteria_Set__c> criteriaSetList = new List<ASI_CRM_Criteria_Set__c>();
        criteriaSetList = ASI_CRM_TestClassUtilityHelperPROS.createCriteriaSet(1, 'ASI_SG_Image_Level_Criteria');
        insert criteriaSetList;
        
        system.assert(criteriaSetList[0].Id<>null);
        
        List<ASI_CRM_Criteria_Threshold__c> criteriaThresholdList = new List<ASI_CRM_Criteria_Threshold__c>();
        criteriaThresholdList = ASI_CRM_TestClassUtilityHelperPROS.createCriteriaThreshold(1, 'ASI_CRM_SG_Picklist', criteriaSetList[0].Id);

        insert criteriaThresholdList;
        
        system.assert(proSegmentationList[0].Id<>null);
        
        criteriaThreshold2 = criteriaThresholdList[0];
        
        
    }
    static testmethod void testHandler1(){
        //AFTER INSERT
        Test.startTest();
        dataInsert();
        prosSegmentation = [Select Id, Name from ASI_CRM_Pros_Segmentation__c where Id =: prosSegmentation.Id];
        System.debug('@@PROSSEGCOUNTRY: '+prosSegmentation);
        List<ASI_CRM_Pros_Volume_Potential__c> prosVolPotentialList = new List<ASI_CRM_Pros_Volume_Potential__c>();
        prosVolPotentialList = ASI_CRM_TestClassUtilityHelperPROS.createProsVolumePotential(1, 'ASI_CRM_SG_ProsVolumePotential', 'SGD', prosSegmentation.Id, criteriaThreshold.Id);

        insert prosVolPotentialList;
        
        system.assert(prosVolPotentialList[0].Id<>null);
        
        Test.stopTest();
    }
    static testmethod void testHandler2(){
        //AFTER INSERT
        Test.startTest();
        dataInsert2();
        prosSegmentation2 = [Select Id, Name from ASI_CRM_Pros_Segmentation__c where Id =: prosSegmentation2.Id];
        System.debug('@@PROSSEGCOUNTRY: '+prosSegmentation2);
        List<ASI_CRM_Pros_Volume_Potential__c> prosVolPotentialList = new List<ASI_CRM_Pros_Volume_Potential__c>();
        prosVolPotentialList = ASI_CRM_TestClassUtilityHelperPROS.createProsVolumePotential(1, 'ASI_CRM_SG_ProsVolumePotential', 'SGD', prosSegmentation2.Id, criteriaThreshold2.Id);

        insert prosVolPotentialList;
        
        system.assert(prosVolPotentialList[0].Id<>null);
        
        Test.stopTest();
    }
    static testmethod void testHandler3(){
        //AFTER UPDATE
        
        dataInsert();
        prosSegmentation = [Select Id, Name from ASI_CRM_Pros_Segmentation__c where Id =: prosSegmentation.Id];
        System.debug('@@PROSSEGCOUNTRY: '+prosSegmentation);
        List<ASI_CRM_Pros_Volume_Potential__c> prosVolPotentialList = new List<ASI_CRM_Pros_Volume_Potential__c>();
        prosVolPotentialList = ASI_CRM_TestClassUtilityHelperPROS.createProsVolumePotential(1, 'ASI_CRM_SG_ProsVolumePotential', 'SGD', prosSegmentation.Id, criteriaThreshold.Id);

        insert prosVolPotentialList;
        
        system.assert(prosVolPotentialList[0].Id<>null);
        Test.startTest();
        update prosVolPotentialList;
        Test.stopTest();
    }
    static testmethod void testHandler4(){
        //AFTER UPDATE
        
        dataInsert2();
        prosSegmentation2 = [Select Id, Name from ASI_CRM_Pros_Segmentation__c where Id =: prosSegmentation2.Id];
        System.debug('@@PROSSEGCOUNTRY: '+prosSegmentation2);
        List<ASI_CRM_Pros_Volume_Potential__c> prosVolPotentialList = new List<ASI_CRM_Pros_Volume_Potential__c>();
        prosVolPotentialList = ASI_CRM_TestClassUtilityHelperPROS.createProsVolumePotential(1, 'ASI_CRM_SG_ProsVolumePotential', 'SGD', prosSegmentation2.Id, criteriaThreshold2.Id);

        insert prosVolPotentialList;
        
        system.assert(prosVolPotentialList[0].Id<>null);
        Test.startTest();
        update prosVolPotentialList;
        Test.stopTest();
    }
    
}