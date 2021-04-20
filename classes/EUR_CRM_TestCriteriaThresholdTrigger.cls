/*------------------------------------------------------------
Author/Company:   IP Converge Data Services,Inc.
Description:      test class for EUR_CRM_CriteriaThresholdTrigger 
History
29/04/2014        IPC     Created
------------------------------------------------------------*/
@isTest
public with sharing class EUR_CRM_TestCriteriaThresholdTrigger {
    //private static Account account;
    private static EUR_CRM_Account__c account;
    private static EUR_CRM_Affiliate__c affiliate;
    private static EUR_CRM_Pros_Segmentation__c prosSegmentation;
    private static EUR_CRM_Criteria_Threshold__c criteriaThreshold;
    private static EUR_CRM_Criteria_Set__c criteriaSet;
    private static EUR_CRM_Criteria_Answer__c criteriaAnswer;
    private static EUR_CRM_Group_Outlet_Type__c groupOutlet;
    private static String groupOutletName;
    
    public static void dataInsert(){
        
        account= EUR_CRM_TestClassUtilityHelper.createAccountsEU(1, 'EE Direct - On Trade')[0];
        insert account;
        
        criteriaSet = EUR_CRM_TestClassUtilityHelper.createCriteriaSet(1, 'EE Image Level Criteria')[0];
        insert criteriaSet;
        
        criteriaThreshold = EUR_CRM_TestClassUtilityHelper.createCriteriaThreshold(1, 'Picklist', criteriaSet.Id)[0];
        insert criteriaThreshold;
        
        criteriaAnswer = EUR_CRM_TestClassUtilityHelper.createCriteriaAnswer(1, 'Text Input', criteriaThreshold.Id)[0];
        insert criteriaAnswer;
    
        groupOutlet = EUR_CRM_TestClassUtilityHelper.createGroupOutletType(1, 'EUR EE Group Outlet', 'EUR', criteriaSet.Id, null)[0];
        insert groupOutlet;
        
        prosSegmentation = EUR_CRM_TestClassUtilityHelper.createProsSegmentation(1, 'EUR_EE_PROS_Segmentation', 'EUR', account.Id, groupOutlet.Id, null, null, null, null)[0];
        insert prosSegmentation;
        
        
    }
    
    static testMethod void tesCriteriaThresholdInsert(){
        
        Test.startTest();
        dataInsert();
        system.assert(criteriaThreshold.Id<>null);
        
        EUR_CRM_Pros_Segmentation__c newProsSegmentation = retrieveProsSegmentation(prosSegmentation.Id);
        
        //System.assertEquals(newProsSegmentation.EUR_CRM_Is_Image_Level_Modified__c, true);
        Test.stopTest(); 
    }
    
    static testMethod void testCriteriaThresholdDelete(){

        dataInsert();
        Test.startTest();
        delete criteriaThreshold;
      
        EUR_CRM_Pros_Segmentation__c newProsSegmentation = retrieveProsSegmentation(prosSegmentation.Id);
        
        //System.assertEquals(newProsSegmentation.EUR_CRM_Is_Image_Level_Modified__c, true);  
        Test.stopTest();
    }
    
    static testMethod void testCriteriaThresholdUpdate(){
    
        dataInsert();
        Test.startTest();
        criteriaThreshold.EUR_CRM_Question__c = 'New Question?';
        criteriaThreshold.EUR_CRM_ActionPROS__c = 'No Need Update';
        update criteriaThreshold;
        EUR_CRM_Pros_Segmentation__c newProsSegmentation = retrieveProsSegmentation(prosSegmentation.Id);
        
        //System.assertEquals(newProsSegmentation.EUR_CRM_Is_Image_Level_Modified__c, true);
        Test.stopTest();
    }
    
    private static EUR_CRM_Pros_Segmentation__c retrieveProsSegmentation(Id prosId){
        EUR_CRM_Pros_Segmentation__c newProsSegmentation = [SELECT Id, EUR_CRM_Affiliate__c, EUR_CRM_Group_Outlet_Type__c,
                            EUR_CRM_Is_Image_Level_Modified__c, EUR_CRM_Is_Volume_Potential_Modified__c
                            FROM EUR_CRM_Pros_Segmentation__c
                            WHERE Id =: prosId];
                            
        return newProsSegmentation;
    }
    
}