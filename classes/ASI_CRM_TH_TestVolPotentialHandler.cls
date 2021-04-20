/*********************************************************************************
 * Name: ASI_CRM_TH_TestVolPotentialHandler 
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 04/03/2016       Introv: Twinkle LI      Cloned from ASI_CRM_TW_TestVolPotentialHandler 
*********************************************************************************/
@isTest (SeeAllData = true)
public with sharing class ASI_CRM_TH_TestVolPotentialHandler {

    private static ASI_CRM_AccountsAdditionalField__c accountASI; 
    private static ASI_CRM_Pros_Segmentation__c prosSegmentation;
    private static ASI_CRM_Group_Outlet_Type__c grpOutletType;
    private static ASI_CRM_Criteria_Threshold__c criteriaThreshold;
    private static ASI_CRM_Pros_Segmentation__c prosSegmentation2;
    private static ASI_CRM_Criteria_Threshold__c criteriaThreshold2;
    
    static testmethod void dataInsert(){
        
        ASI_CRM_AccountsAdditionalField__c accASIList = new ASI_CRM_AccountsAdditionalField__c();
        accASIList = ASI_CRM_TH_TestClassUtilityHelperPROS.createAccountsASI(1, 'ASI_TH_CRM_Outlet')[0];
        accASIList.ASI_CRM_Region__c = 'Second Tier';
        insert accASIList;
        
        system.assert(accASIList.Id<>null);
        
        List<ASI_CRM_Group_Outlet_Type__c> grpOutletTypeList = new List<ASI_CRM_Group_Outlet_Type__c>();
        //grpOutletTypeList = ASI_CRM_TH_TestClassUtilityHelperPROS.createGroupOutletType(1, 'ASI_CRM_TH_Group_Outlet_Type', 'THB', null, null);
        grpOutletTypeList.add(new ASI_CRM_Group_Outlet_Type__c(RecordTypeId = Global_RecordTypeCache.getRTId('ASI_CRM_Group_Outlet_Type__cASI_CRM_TH_Group_Outlet_Type'),
                                                               ASI_CRM_SG_Name__c = 'TEST NAME', ASI_CRM_SG_Group_Outlet_Name__c='test 1'));
        insert grpOutletTypeList;
        
        grpOutletType = grpOutletTypeList[0];
        
        system.assert(grpOutletTypeList[0].Id<>null);
        
        List<ASI_CRM_Pros_Segmentation__c>  proSegmentationList = new List<ASI_CRM_Pros_Segmentation__c>();
        proSegmentationList = ASI_CRM_TH_TestClassUtilityHelperPROS.createProsSegmentation(1, 'ASI_CRM_TH_PROS_Segmentation', 'THB', accASIList.Id, null, null, null, null);
        insert proSegmentationList;
        
        system.assert(proSegmentationList[0].Id<>null);
        
        prosSegmentation = proSegmentationList[0];
        
        List<ASI_CRM_Criteria_Set__c> criteriaSetList = new List<ASI_CRM_Criteria_Set__c>();
        criteriaSetList = ASI_CRM_TH_TestClassUtilityHelperPROS.createCriteriaSet(1, 'ASI_CRM_TH_Image_Level_Criteria');
        insert criteriaSetList;
        
        system.assert(criteriaSetList[0].Id<>null);
        
        List<ASI_CRM_Criteria_Threshold__c> criteriaThresholdList = new List<ASI_CRM_Criteria_Threshold__c>();
        criteriaThresholdList = ASI_CRM_TH_TestClassUtilityHelperPROS.createCriteriaThreshold(1, 'ASI_CRM_TH_Picklist', criteriaSetList[0].Id);

        insert criteriaThresholdList;
        
        system.assert(proSegmentationList[0].Id<>null);
        
        criteriaThreshold = criteriaThresholdList[0];
        
        
    }
    static testmethod void dataInsert2(){
        
        List<ASI_CRM_AccountsAdditionalField__c> accASIList = new List<ASI_CRM_AccountsAdditionalField__c>();
        Account acc = new Account(Name='TestAccount', RecordTypeId = Global_RecordTypeCache.getRTId('AccountASI_TH_CRM_Outlet'));     
        insert acc;
        
        ASI_CRM_CN_Channel__c ch = new ASI_CRM_CN_Channel__c();
        ch.ASI_CRM_CN_Channel_Chi_Name__c = 'Channel';
        insert ch;
        
        ASI_MFM_Sub_Channel__c sc = new ASI_MFM_Sub_Channel__c();
        sc.ASI_CRM_CN_Channel__c = ch.id;
        insert sc;
        
        ASI_TH_CRM_OutletType__c ot = new ASI_TH_CRM_OutletType__c();
        ot.ASI_CRM_Sub_Channel__c = sc.id;
        insert ot;
          
        accASIList.add(new ASI_CRM_AccountsAdditionalField__c(Name = 'Test', RecordTypeId = Global_RecordTypeCache.getRTId('ASI_CRM_AccountsAdditionalField__cASI_TH_CRM_Outlet'),
                                                         ASI_CRM_Account__c = acc.id, ASI_TH_CRM_OutletType__c = ot.id, ASI_CRM_Region__c = 'Second Tier'));
        insert accASIList;
        
        system.assert(accASIList[0].Id<>null);
        
        List<ASI_CRM_Group_Outlet_Type__c> grpOutletTypeList = new List<ASI_CRM_Group_Outlet_Type__c>();
        grpOutletTypeList = ASI_CRM_TH_TestClassUtilityHelperPROS.createGroupOutletType(1, 'ASI_CRM_TH_Group_Outlet_Type', 'THB', null, null);
        insert grpOutletTypeList;
        
        grpOutletType = grpOutletTypeList[0];
        
        system.assert(grpOutletTypeList[0].Id<>null);
        
        List<ASI_CRM_Pros_Segmentation__c>  proSegmentationList = new List<ASI_CRM_Pros_Segmentation__c>();
        proSegmentationList = ASI_CRM_TH_TestClassUtilityHelperPROS.createProsSegmentation(1, 'ASI_CRM_TH_PROS_Segmentation', 'THB', accASIList[0].Id, null, null, null, null);
        insert proSegmentationList;
        
        system.assert(proSegmentationList[0].Id<>null);
        
        prosSegmentation2 = proSegmentationList[0];
        
        List<ASI_CRM_Criteria_Set__c> criteriaSetList = new List<ASI_CRM_Criteria_Set__c>();
        criteriaSetList = ASI_CRM_TH_TestClassUtilityHelperPROS.createCriteriaSet(1, 'ASI_CRM_TH_Image_Level_Criteria');
        insert criteriaSetList;
        
        system.assert(criteriaSetList[0].Id<>null);
        
        List<ASI_CRM_Criteria_Threshold__c> criteriaThresholdList = new List<ASI_CRM_Criteria_Threshold__c>();
        criteriaThresholdList = ASI_CRM_TH_TestClassUtilityHelperPROS.createCriteriaThreshold(1, 'ASI_CRM_TH_Picklist', criteriaSetList[0].Id);

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
        prosVolPotentialList = ASI_CRM_TH_TestClassUtilityHelperPROS.createProsVolumePotential(1, 'ASI_CRM_TH_Pros_Volume_Potential', 'THB', prosSegmentation.Id, criteriaThreshold.Id);

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
        prosVolPotentialList = ASI_CRM_TH_TestClassUtilityHelperPROS.createProsVolumePotential(1, 'ASI_CRM_TH_Pros_Volume_Potential', 'THB', prosSegmentation2.Id, criteriaThreshold2.Id);

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
        prosVolPotentialList = ASI_CRM_TH_TestClassUtilityHelperPROS.createProsVolumePotential(1, 'ASI_CRM_TH_Pros_Volume_Potential', 'THB', prosSegmentation.Id, criteriaThreshold.Id);

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
        prosVolPotentialList = ASI_CRM_TH_TestClassUtilityHelperPROS.createProsVolumePotential(1, 'ASI_CRM_TH_Pros_Volume_Potential', 'THB', prosSegmentation2.Id, criteriaThreshold2.Id);

        insert prosVolPotentialList;
        
        system.assert(prosVolPotentialList[0].Id<>null);
        Test.startTest();
        update prosVolPotentialList;
        Test.stopTest();
    }
    
}