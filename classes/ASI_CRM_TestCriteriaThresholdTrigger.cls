@isTest
public with sharing class ASI_CRM_TestCriteriaThresholdTrigger {
    //private static Account account;
    private static ASI_CRM_AccountsAdditionalField__c account;
    private static ASI_CRM_Pros_Segmentation__c prosSegmentation;
    private static ASI_CRM_Criteria_Threshold__c criteriaThreshold;
    private static ASI_CRM_Criteria_Set__c criteriaSet;
    private static ASI_CRM_Criteria_Answer__c criteriaAnswer;
    private static ASI_CRM_Group_Outlet_Type__c groupOutlet;
    private static String groupOutletName;
    
    public static void dataInsert(){
        
        account= ASI_CRM_TestClassUtilityHelperPROS.createAccountsASI(1, 'ASI_CRM_SG_Outlet')[0];
        insert account;
        
        criteriaSet = ASI_CRM_TestClassUtilityHelperPROS.createCriteriaSet(1, 'ASI_SG_Image_Level_Criteria')[0];
        insert criteriaSet;
        
        criteriaThreshold = ASI_CRM_TestClassUtilityHelperPROS.createCriteriaThreshold(1, 'ASI_CRM_SG_Picklist', criteriaSet.Id)[0];
        insert criteriaThreshold;
        
        criteriaAnswer = ASI_CRM_TestClassUtilityHelperPROS.createCriteriaAnswer(1, 'ASI_CRM_SG_Text_Input', criteriaThreshold.Id)[0];
        insert criteriaAnswer;
    
        groupOutlet = ASI_CRM_TestClassUtilityHelperPROS.createGroupOutletType(1, 'ASI_CRM_SG_Group_Outlet_Type', 'SGD', criteriaSet.Id, null)[0];
        insert groupOutlet;
        
        prosSegmentation = ASI_CRM_TestClassUtilityHelperPROS.createProsSegmentation(1, 'ASI_CRM_SG_PROS_Segmentation', 'SGD', account.Id, groupOutlet.Id, null, null, null)[0];
        insert prosSegmentation;
        
        
    }
    
    static testMethod void tesCriteriaThresholdInsert(){
        
        Test.startTest();
        dataInsert();
        system.assert(criteriaThreshold.Id<>null);
        
        ASI_CRM_Pros_Segmentation__c newProsSegmentation = retrieveProsSegmentation(prosSegmentation.Id);
        
        //System.assertEquals(newProsSegmentation.ASI_CRM_Is_Image_Level_Modified__c, true);
        Test.stopTest(); 
    }
    
    static testMethod void testCriteriaThresholdDelete(){

        dataInsert();
        Test.startTest();
        delete criteriaThreshold;
      
        ASI_CRM_Pros_Segmentation__c newProsSegmentation = retrieveProsSegmentation(prosSegmentation.Id);
        
        //System.assertEquals(newProsSegmentation.ASI_CRM_Is_Image_Level_Modified__c, true);  
        Test.stopTest();
    }
    
    static testMethod void testCriteriaThresholdUpdate(){
    
        dataInsert();
        Test.startTest();
        criteriaThreshold.ASI_CRM_SG_Question__c = 'New Question?';
        update criteriaThreshold;
        ASI_CRM_Pros_Segmentation__c newProsSegmentation = retrieveProsSegmentation(prosSegmentation.Id);
        
        //System.assertEquals(newProsSegmentation.ASI_CRM_Is_Image_Level_Modified__c, true);
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