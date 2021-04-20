/*------------------------------------------------------------
Author:         IPC
Company:        IP Converge Data Services,Inc.
Description:    Test class for EUR_CRM_CriteriaSetMassUpdateCtrExt
History
------------------------------------------------------------*/
@isTest
private class EUR_CRM_CriteriaSetMassUpdateCtrExtTest {
 
    private static EUR_CRM_Account__c account;
    private static EUR_CRM_Affiliate__c affiliate;
    private static EUR_CRM_Pros_Segmentation__c prosSegmentation;
    private static EUR_CRM_Pros_Segmentation__c prosSegmentation2;
    private static EUR_CRM_Criteria_Threshold__c criteriaThreshold;
    private static EUR_CRM_Criteria_Threshold__c criteriaThreshold2;
    private static EUR_CRM_Criteria_Threshold__c criteriaThreshold3;
    private static EUR_CRM_Criteria_Threshold__c criteriaThreshold4;
    private static EUR_CRM_Criteria_Threshold__c criteriaThreshold5;
    private static EUR_CRM_Criteria_Threshold__c criteriaThreshold6;
    private static EUR_CRM_Criteria_Threshold__c criteriaThreshold7;
    private static EUR_CRM_Criteria_Threshold__c criteriaThreshold8;
    private static EUR_CRM_Criteria_Threshold__c criteriaThreshold9;
    private static EUR_CRM_Criteria_Threshold__c criteriaThreshold10;
    private static EUR_CRM_Criteria_Set__c criteriaSetImgLevel;
    private static EUR_CRM_Criteria_Set__c criteriaSetVolPotential;
    private static EUR_CRM_Criteria_Answer__c criteriaAnswer;
    private static EUR_CRM_Criteria_Answer__c criteriaAnswer2;
    private static EUR_CRM_Criteria_Answer__c criteriaAnswer3;
    private static EUR_CRM_Criteria_Answer__c criteriaAnswer4;
    private static EUR_CRM_Criteria_Answer__c criteriaAnswer5;
    private static EUR_CRM_Criteria_Answer__c criteriaAnswer6;
    private static EUR_CRM_Criteria_Answer__c criteriaAnswer7;
    private static EUR_CRM_Criteria_Answer__c criteriaAnswer8;
    private static EUR_CRM_Criteria_Answer__c criteriaAnswer9;
    private static EUR_CRM_Criteria_Answer__c criteriaAnswer10;
    private static EUR_CRM_Group_Outlet_Type__c groupOutlet;
    private static EUR_CRM_Pros_Image_Level__c prosImGLevel;
    private static EUR_CRM_Pros_Image_Level__c prosImGLevel2;
    private static EUR_CRM_Pros_Image_Level__c prosImGLevel3;
    private static EUR_CRM_Pros_Image_Level__c prosImGLevel4;
    private static EUR_CRM_Pros_Image_Level__c prosImGLevel5;
    private static EUR_CRM_Pros_Volume_Potential__c prosVolPotential;
    private static EUR_CRM_Pros_Volume_Potential__c prosVolPotential2;
    private static EUR_CRM_Pros_Volume_Potential__c prosVolPotential3;
    private static EUR_CRM_Pros_Volume_Potential__c prosVolPotential4;
    private static EUR_CRM_Pros_Volume_Potential__c prosVolPotential5;
    
    
    public static testMethod void dataInsert(){

        account= EUR_CRM_TestClassUtilityHelper.createAccountsEU(1, 'EE Direct - On Trade')[0];
        insert account;
        
        criteriaSetImgLevel = EUR_CRM_TestClassUtilityHelper.createCriteriaSet(1, 'LT Image Level Criteria')[0];
        insert criteriaSetImgLevel;
        
        criteriaSetVolPotential = EUR_CRM_TestClassUtilityHelper.createCriteriaSet(1, 'LT Volume Potential Criteria')[0];
        insert criteriaSetVolPotential;
        
        groupOutlet = EUR_CRM_TestClassUtilityHelper.createGroupOutletType(1, 'EUR LT Group Outlet', 'EUR', criteriaSetImgLevel.Id, criteriaSetVolPotential.Id)[0];
        insert groupOutlet;
        
        prosSegmentation = EUR_CRM_TestClassUtilityHelper.createProsSegmentation(1, 'EUR_EE_PROS_Segmentation', 'EUR', account.Id, groupOutlet.Id, null, null, null, null)[0];
        insert prosSegmentation;    
        
    }
     
    public static testMethod void runtestDataImg(){
        dataInsert(); 
        
        List<EUR_CRM_Criteria_Threshold__c> criteriaThresholdList = new List<EUR_CRM_Criteria_Threshold__c>();
        List<EUR_CRM_Criteria_Answer__c> criteriaAnswerList = new List<EUR_CRM_Criteria_Answer__c>();
        List<EUR_CRM_Pros_Image_Level__c> prosImgLevelList = new List<EUR_CRM_Pros_Image_Level__c>();
        
        criteriaThreshold = EUR_CRM_TestClassUtilityHelper.createCriteriaThreshold(1, 'Currency Input', criteriaSetImgLevel.Id)[0];
        criteriaThreshold.EUR_CRM_Question__c = 'Number of Super premium category';
        //insert criteriaThreshold;
        criteriaThresholdList.add(criteriaThreshold);
        
        //threshold for boolean
        criteriaThreshold2 = EUR_CRM_TestClassUtilityHelper.createCriteriaThreshold(1, 'Yes/No', criteriaSetImgLevel.Id)[0];
        criteriaThreshold2.EUR_CRM_Question__c = 'TRUE of FALSE?';
        //insert criteriaThreshold2;
        criteriaThresholdList.add(criteriaThreshold2);
        
        //threshold for integer
        criteriaThreshold3 = EUR_CRM_TestClassUtilityHelper.createCriteriaThreshold(1, 'Number Input', criteriaSetImgLevel.Id)[0];
        if(criteriaThreshold3.RecordTypeId == null)
            criteriaThreshold3 = EUR_CRM_TestClassUtilityHelper.createCriteriaThreshold(1, 'Integer Input', criteriaSetImgLevel.Id)[0];
    
        criteriaThreshold3.EUR_CRM_Question__c = 'how many?';
        //insert criteriaThreshold3;
        criteriaThresholdList.add(criteriaThreshold3);
        
        //threshold for picklist
        criteriaThreshold4 = EUR_CRM_TestClassUtilityHelper.createCriteriaThreshold(1, 'Picklist', criteriaSetImgLevel.Id)[0];
        criteriaThreshold4.EUR_CRM_Question__c = 'how many?';
        //insert criteriaThreshold4;
        criteriaThresholdList.add(criteriaThreshold4);
        
        //threshold for Text
        criteriaThreshold5 = EUR_CRM_TestClassUtilityHelper.createCriteriaThreshold(1, 'Text Input', criteriaSetImgLevel.Id)[0];
        criteriaThreshold5.EUR_CRM_Question__c = 'how many?';
        //insert criteriaThreshold5;
        criteriaThresholdList.add(criteriaThreshold5);
        
        insert criteriaThresholdList;
        
        criteriaAnswer = EUR_CRM_TestClassUtilityHelper.createCriteriaAnswer(1, 'Currency Input', criteriaThresholdList[0].Id)[0];
        criteriaAnswer.EUR_CRM_Condition__c = 'Greater Than (>)';
        //insert criteriaAnswer;
        criteriaAnswerList.add(criteriaAnswer);
        
        criteriaAnswer2 = EUR_CRM_TestClassUtilityHelper.createCriteriaAnswer(1, 'Yes/No', criteriaThresholdList[1].Id)[0];
        criteriaAnswer2.EUR_CRM_Condition__c = 'Equal (=)';
        //insert criteriaAnswer2;
        criteriaAnswerList.add(criteriaAnswer2);
        
        criteriaAnswer3 = EUR_CRM_TestClassUtilityHelper.createCriteriaAnswer(1, 'Integer Input', criteriaThresholdList[2].Id)[0];
        criteriaAnswer3.EUR_CRM_Condition__c = 'Greater Than (>)';
        //insert criteriaAnswer3;
        criteriaAnswerList.add(criteriaAnswer3);
        
        criteriaAnswer4 = EUR_CRM_TestClassUtilityHelper.createCriteriaAnswer(1, 'Picklist', criteriaThresholdList[3].Id)[0];
        criteriaAnswer4.EUR_CRM_Condition__c = 'Equal (=)';
        //insert criteriaAnswer4;
        criteriaAnswerList.add(criteriaAnswer4);
        
        criteriaAnswer5 = EUR_CRM_TestClassUtilityHelper.createCriteriaAnswer(1, 'Text Input', criteriaThresholdList[4].Id)[0];
        criteriaAnswer5.EUR_CRM_Condition__c = 'Equal (=)';
        //insert criteriaAnswer5;
        criteriaAnswerList.add(criteriaAnswer5);
        
        insert criteriaAnswerList;
        prosImgLevel = EUR_CRM_TestClassUtilityHelper.createProsImageLevel(1, 'EUR', prosSegmentation.Id, criteriaThresholdList[0].Id)[0];
        prosImgLevel.EUR_CRM_Answer__c = '5';
        prosImgLevel.EUR_CRM_Weight__c = 10;
        //insert prosImgLevel;
        prosImgLevelList.add(prosImGLevel);
        
        prosImgLevel4 = EUR_CRM_TestClassUtilityHelper.createProsImageLevel(1, 'EUR', prosSegmentation.Id, criteriaThresholdList[3].Id)[0];
        prosImgLevel4.EUR_CRM_Answer__c = 'Yes';
        prosImgLevel4.EUR_CRM_Weight__c = 10;
        //insert prosImgLevel4;
        prosImgLevelList.add(prosImGLevel4);
        
        prosImgLevel3 = EUR_CRM_TestClassUtilityHelper.createProsImageLevel(1, 'EUR', prosSegmentation.Id, criteriaThresholdList[2].Id)[0];
        prosImgLevel3.EUR_CRM_Answer__c = '5';
        prosImgLevel3.EUR_CRM_Weight__c = 10;
        //insert prosImgLevel3;
        prosImgLevelList.add(prosImGLevel3);
        
        prosImgLevel2 = EUR_CRM_TestClassUtilityHelper.createProsImageLevel(1, 'EUR', prosSegmentation.Id, criteriaThresholdList[1].Id)[0];
        prosImgLevel2.EUR_CRM_Answer__c = 'Yes';
        prosImgLevel2.EUR_CRM_Weight__c = 10;
        //insert prosImgLevel2;
        prosImgLevelList.add(prosImGLevel2);
        
        prosImgLevel5 = EUR_CRM_TestClassUtilityHelper.createProsImageLevel(1, 'EUR', prosSegmentation.Id, criteriaThresholdList[4].Id)[0];
        prosImgLevel5.EUR_CRM_Answer__c = 'Yes';
        prosImgLevel5.EUR_CRM_Weight__c = 10;
        //insert prosImgLevel5;
        prosImgLevelList.add(prosImGLevel5);
        
        insert prosImgLevelList;
        
        test.startTest();
         
        Pagereference pr = page.EUR_CRM_CriteriaSetMassUpdatePage;
        pr.getParameters().put('cSetId', criteriaSetImgLevel.Id);
        Test.setCurrentPage(pr);
        
        ApexPages.StandardController sc = new ApexPages.StandardController(criteriaSetImgLevel);
        ApexPages.currentPage().getParameters().put('Id', criteriaSetImgLevel.Id);
        EUR_CRM_CriteriaSetMassUpdateCtrExt cs = new EUR_CRM_CriteriaSetMassUpdateCtrExt(sc);  
        cs.cSetId = criteriaSetImgLevel.Id;
        cs.massUpdate();
        test.stopTest();
    }
    
    public static testMethod void runtestDataVol(){
        dataInsert(); 
        
        List<EUR_CRM_Criteria_Threshold__c> criteriaThresholdList = new List<EUR_CRM_Criteria_Threshold__c>();
        List<EUR_CRM_Criteria_Answer__c> criteriaAnswerList = new List<EUR_CRM_Criteria_Answer__c>();
        List<EUR_CRM_Pros_Volume_Potential__c> prosVolPotentialList = new List<EUR_CRM_Pros_Volume_Potential__c>();
        
        criteriaThreshold6 = EUR_CRM_TestClassUtilityHelper.createCriteriaThreshold(1, 'Currency Input', criteriaSetVolPotential.Id)[0];
        criteriaThreshold6.EUR_CRM_Question__c = 'Number of Super premium category';
        //insert criteriaThreshold6;
        criteriaThresholdList.add(criteriaThreshold6);
        
        //threshold for boolean
        criteriaThreshold7 = EUR_CRM_TestClassUtilityHelper.createCriteriaThreshold(1, 'Yes/No', criteriaSetVolPotential.Id)[0];
        criteriaThreshold7.EUR_CRM_Question__c = 'TRUE of FALSE?';
        //insert criteriaThreshold2;
        criteriaThresholdList.add(criteriaThreshold7);
        
        //threshold for integer
        criteriaThreshold8 = EUR_CRM_TestClassUtilityHelper.createCriteriaThreshold(1, 'Number Input', criteriaSetVolPotential.Id)[0];
        if(criteriaThreshold8.RecordTypeId == null)
            criteriaThreshold8 = EUR_CRM_TestClassUtilityHelper.createCriteriaThreshold(1, 'Integer Input', criteriaSetImgLevel.Id)[0];
    
        criteriaThreshold8.EUR_CRM_Question__c = 'how many?';
        //insert criteriaThreshold3;
        criteriaThresholdList.add(criteriaThreshold8);
        
        //threshold for picklist
        criteriaThreshold9 = EUR_CRM_TestClassUtilityHelper.createCriteriaThreshold(1, 'Picklist', criteriaSetVolPotential.Id)[0];
        criteriaThreshold9.EUR_CRM_Question__c = 'how many?';
        //insert criteriaThreshold4;
        criteriaThresholdList.add(criteriaThreshold9);
        
        //threshold for Text
        criteriaThreshold10 = EUR_CRM_TestClassUtilityHelper.createCriteriaThreshold(1, 'Text Input', criteriaSetVolPotential.Id)[0];
        criteriaThreshold10.EUR_CRM_Question__c = 'how many?';
        //insert criteriaThreshold5;
        criteriaThresholdList.add(criteriaThreshold10);
        
        insert criteriaThresholdList;
        
        criteriaAnswer6 = EUR_CRM_TestClassUtilityHelper.createCriteriaAnswer(1, 'Currency Input', criteriaThresholdList[0].Id)[0];
        criteriaAnswer6.EUR_CRM_Condition__c = 'Greater Than (>)';
        //insert criteriaAnswer6;
        criteriaAnswerList.add(criteriaAnswer6);
        
        criteriaAnswer7 = EUR_CRM_TestClassUtilityHelper.createCriteriaAnswer(1, 'Yes/No', criteriaThresholdList[1].Id)[0];
        criteriaAnswer7.EUR_CRM_Condition__c = 'Equal (=)';
        //insert criteriaAnswer7;
        criteriaAnswerList.add(criteriaAnswer7);
        
        criteriaAnswer8 = EUR_CRM_TestClassUtilityHelper.createCriteriaAnswer(1, 'Integer Input', criteriaThresholdList[2].Id)[0];
        criteriaAnswer8.EUR_CRM_Condition__c = 'Greater Than (>)';
        //insert criteriaAnswer8;
        criteriaAnswerList.add(criteriaAnswer8);
        
        criteriaAnswer9 = EUR_CRM_TestClassUtilityHelper.createCriteriaAnswer(1, 'Picklist', criteriaThresholdList[3].Id)[0];
        criteriaAnswer9.EUR_CRM_Condition__c = 'Equal (=)';
        //insert criteriaAnswer9;
        criteriaAnswerList.add(criteriaAnswer9);
        
        criteriaAnswer10 = EUR_CRM_TestClassUtilityHelper.createCriteriaAnswer(1, 'Text Input', criteriaThresholdList[4].Id)[0];
        criteriaAnswer10.EUR_CRM_Condition__c = 'Equal (=)';
        //insert criteriaAnswer5;
        criteriaAnswerList.add(criteriaAnswer10);
        
        insert criteriaAnswerList;
        
        prosVolPotential = EUR_CRM_TestClassUtilityHelper.createProsVolumePotential(1, 'EUR_PRT_ProsVolumePotential', 'EUR', prosSegmentation.Id, criteriaThresholdList[0].Id)[0];
        prosVolPotential.EUR_CRM_Answer__c = '5';
        prosVolPotential.EUR_CRM_Weight__c = 10;
        //insert prosVolPotential;
        prosVolPotentialList.add(prosVolPotential);
        
        prosVolPotential2 = EUR_CRM_TestClassUtilityHelper.createProsVolumePotential(1, 'EUR_PRT_ProsVolumePotential', 'EUR', prosSegmentation.Id, criteriaThresholdList[1].Id)[0];
        prosVolPotential2.EUR_CRM_Answer__c = '5';
        prosVolPotential2.EUR_CRM_Weight__c = 10;
        //insert prosVolPotential2;
        prosVolPotentialList.add(prosVolPotential2);
        
        prosVolPotential3 = EUR_CRM_TestClassUtilityHelper.createProsVolumePotential(1, 'EUR_PRT_ProsVolumePotential', 'EUR', prosSegmentation.Id, criteriaThresholdList[2].Id)[0];
        prosVolPotential3.EUR_CRM_Answer__c = '5';
        prosVolPotential3.EUR_CRM_Weight__c = 10;
        //insert prosVolPotential3;
        prosVolPotentialList.add(prosVolPotential3);
        
        /*prosVolPotential4 = EUR_CRM_TestClassUtilityHelper.createProsVolumePotential(1, 'EUR_PRT_ProsVolumePotential', 'EUR', prosSegmentation.Id, criteriaThresholdList[3].Id)[0];
        prosVolPotential4.EUR_CRM_Answer__c = '5';
        prosVolPotential4.EUR_CRM_Weight__c = 10;
        //insert prosVolPotential4;
        prosVolPotentialList.add(prosVolPotential4);
        
        prosVolPotential5 = EUR_CRM_TestClassUtilityHelper.createProsVolumePotential(1, 'EUR_PRT_ProsVolumePotential', 'EUR', prosSegmentation.Id, criteriaThresholdList[4].Id)[0];
        prosVolPotential5.EUR_CRM_Answer__c = '5';
        prosVolPotential5.EUR_CRM_Weight__c = 10;
        //insert prosVolPotential5;
        prosVolPotentialList.add(prosVolPotential5);*/
        
        insert prosVolPotentialList;
        
        test.startTest();
        
        Pagereference pr = page.EUR_CRM_CriteriaSetMassUpdatePage;
        pr.getParameters().put('cSetId', criteriaSetVolPotential.Id);
        Test.setCurrentPage(pr);
        
        ApexPages.StandardController sc = new ApexPages.StandardController(criteriaSetVolPotential);
        ApexPages.currentPage().getParameters().put('Id', criteriaSetVolPotential.Id);
        EUR_CRM_CriteriaSetMassUpdateCtrExt cs = new EUR_CRM_CriteriaSetMassUpdateCtrExt(sc);  
        cs.cSetId = criteriaSetVolPotential.Id;
        cs.massUpdate();
        test.stopTest();
    }
}