/*Created by Twinkle Li @introv 06/15/2015
* Testclass for ASI_CRM_CriteriaThres_RedirectView_Ctrl
*/

@isTest
public class ASI_CRM_CriteriaThres_RedirectView_Test{
    public static testMethod void ASI_CRM_CriteriaThres_RedirectView_Test() {
        String recordTypeid;
        
        //1st criteria set
        List<ASI_CRM_Criteria_Set__c> criteriaSet = new List<ASI_CRM_Criteria_Set__c>();
        criteriaSet.add(ASI_CRM_TW_TestClassUtilityHelperPROS.createCriteriaSet(1, 'ASI_CRM_TW_Image_Level_Criteria')[0]);
        
        //2nd criteria set
        recordTypeid = Global_RecordTypeCache.getRTId('ASI_CRM_Criteria_Set__cASI_SG_Image_Level_Criteria');
        criteriaSet.add(new ASI_CRM_Criteria_Set__c(RecordTypeId = recordtypeId, ASI_CRM_SG_Name__c = 'TESTCRITERIASET'));
        
        //3nd criteria set
        criteriaSet.add(ASI_CRM_TW_TestClassUtilityHelperPROS.createCriteriaSet(1, 'ASI_CRM_TH_Image_Level_Criteria')[0]);
        
        insert criteriaSet;
        
        //1st criteria threshold
        List<ASI_CRM_Criteria_Threshold__c> criteriaThreshold = new List<ASI_CRM_Criteria_Threshold__c>();
        criteriaThreshold.add(ASI_CRM_TW_TestClassUtilityHelperPROS.createCriteriaThreshold(1, 'ASI_CRM_TW_Picklist', criteriaSet[0].Id)[0]);
        
        //2nd criteria threshold
        recordTypeid = Global_RecordTypeCache.getRTId('ASI_CRM_Criteria_Threshold__cASI_CRM_SG_Picklist');
        criteriaThreshold.add(new ASI_CRM_Criteria_Threshold__c(RecordTypeId = recordtypeId, ASI_CRM_SG_Criteria_Set__c = criteriaSet[1].Id, ASI_CRM_SG_Sequence__c = 1, ASI_CRM_SG_Question__c = 'TEST QUESTION', ASI_CRM_SG_Weight__c = 100));
        
        //3nd criteria threshold
        criteriaThreshold.add(ASI_CRM_TH_TestClassUtilityHelperPROS.createCriteriaThreshold(1, 'ASI_CRM_TH_Picklist', criteriaSet[2].Id)[0]);
        
        insert criteriaThreshold; 
        
        Test.startTest();
        
        ApexPages.Standardcontroller standardController = new Apexpages.Standardcontroller(criteriaThreshold[0]);
        ASI_CRM_CriteriaThres_RedirectView_Ctrl controller = new ASI_CRM_CriteriaThres_RedirectView_Ctrl(standardController);  
        controller.redirect();
        
        standardController = new Apexpages.Standardcontroller(criteriaThreshold[1]);
        controller = new ASI_CRM_CriteriaThres_RedirectView_Ctrl(standardController);
        controller.redirect();
        Test.stopTest();    
    }
}