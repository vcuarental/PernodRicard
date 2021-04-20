/*********************************************************************************
 * Name: ASI_CRM_TH_TestCriteriaThresholdTrigger
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 04/03/2016       Introv: Twinkle LI      Cloned from ASI_CRM_TW_TestCriteriaThresholdTrigger
*********************************************************************************/
@isTest
public with sharing class ASI_CRM_TH_TestCriteriaThresholdTrigger{
    //private static Account account;
    private static ASI_CRM_AccountsAdditionalField__c account;
    private static ASI_CRM_Pros_Segmentation__c prosSegmentation;
    private static ASI_CRM_Criteria_Threshold__c criteriaThreshold;
    private static ASI_CRM_Criteria_Set__c criteriaSet;
    private static ASI_CRM_Criteria_Answer__c criteriaAnswer;
    private static ASI_CRM_Group_Outlet_Type__c groupOutlet;
    private static String groupOutletName;
    
    public static void dataInsert(){
        
        account= ASI_CRM_TH_TestClassUtilityHelperPROS.createAccountsASI(1, 'ASI_TH_CRM_Outlet')[0];
        insert account;
        
        criteriaSet = ASI_CRM_TH_TestClassUtilityHelperPROS.createCriteriaSet(1, 'ASI_CRM_TH_Image_Level_Criteria')[0];
        insert criteriaSet;
        
        criteriaThreshold = ASI_CRM_TH_TestClassUtilityHelperPROS.createCriteriaThreshold(1, 'ASI_CRM_TH_Picklist', criteriaSet.Id)[0];
        insert criteriaThreshold;
        
        criteriaAnswer = ASI_CRM_TH_TestClassUtilityHelperPROS.createCriteriaAnswer(1, 'ASI_CRM_TH_Text_Input', criteriaThreshold.Id)[0];
        insert criteriaAnswer;
    
        groupOutlet = ASI_CRM_TH_TestClassUtilityHelperPROS.createGroupOutletType(1, 'ASI_CRM_TH_Group_Outlet_Type', '', criteriaSet.Id, null)[0];
        insert groupOutlet;
        
        prosSegmentation = ASI_CRM_TH_TestClassUtilityHelperPROS.createProsSegmentation(1, 'ASI_CRM_TH_PROS_Segmentation', 'THB', account.Id, groupOutlet.Id, null, null, null)[0];
        insert prosSegmentation;
        
        
    }
    
    static testMethod void tesCriteriaThresholdInsert(){
        
        Test.startTest();
        dataInsert();
        system.assert(criteriaThreshold.Id<>null);
        
        ASI_CRM_Pros_Segmentation__c newProsSegmentation = retrieveProsSegmentation(prosSegmentation.Id);
        Test.stopTest(); 
    }
    
    static testMethod void testCriteriaThresholdDelete(){

        dataInsert();
        Test.startTest();
        delete criteriaThreshold;
      
        ASI_CRM_Pros_Segmentation__c newProsSegmentation = retrieveProsSegmentation(prosSegmentation.Id);
        Test.stopTest();
    }
    
    static testMethod void testCriteriaThresholdUpdate(){
    
        dataInsert();
        Test.startTest();
        criteriaThreshold.ASI_CRM_SG_Question__c = 'New Question?';
        update criteriaThreshold;
        ASI_CRM_Pros_Segmentation__c newProsSegmentation = retrieveProsSegmentation(prosSegmentation.Id);
        Test.stopTest();
    }
    
    private static ASI_CRM_Pros_Segmentation__c retrieveProsSegmentation(Id prosId){
        ASI_CRM_Pros_Segmentation__c newProsSegmentation = [SELECT Id, ASI_CRM_SG_Group_Outlet_Type__c,
                            ASI_CRM_SG_Is_Image_Level_Modified__c, ASI_CRM_SG_Is_Volume_Potential_Modified__c
                            FROM ASI_CRM_Pros_Segmentation__c
                            WHERE Id =: prosId];
                            
        return newProsSegmentation;
    }
    
}