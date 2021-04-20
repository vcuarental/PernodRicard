/*********************************************************************************
 * Name: ASI_CRM_TH_TestCriteriaManager
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 04/03/2016       Introv: Twinkle LI      Cloned from ASI_CRM_TW_TestCriteriaManager
*********************************************************************************/
@isTest
public with sharing class ASI_CRM_TH_TestCriteriaManager {

    private static ASI_CRM_Criteria_Set__c criteriaSet;
    private static Id recordtypeId;
    
    static testmethod void dataInsert(){        
        List<ASI_CRM_Criteria_Set__c> criteriaSetList = new List<ASI_CRM_Criteria_Set__c>();
        criteriaSetList = ASI_CRM_TH_TestClassUtilityHelperPROS.createCriteriaSet(1, 'ASI_CRM_TH_Image_Level_Criteria');
        insert criteriaSetList;
         
        system.assert(criteriaSetList[0].Id<>null);
        
        List<ASI_CRM_Criteria_Threshold__c> criteriaThresholdList = new List<ASI_CRM_Criteria_Threshold__c>();
        criteriaThresholdList = ASI_CRM_TH_TestClassUtilityHelperPROS.createCriteriaThreshold(1, 'ASi_CRM_TH_Picklist', criteriaSetList[0].Id);
        insert criteriaThresholdList;
        
        recordtypeId = criteriaThresholdList[0].RecordTypeId;
        
        system.assert(criteriaThresholdList[0].Id<>null);
        system.assert(recordtypeId<>null);
        
    }
    static testmethod void testManager(){    
        dataInsert();
        
        ASI_CRM_TH_CriteriaManager critManager = new ASI_CRM_TH_CriteriaManager();
        critManager.newClassInstance(recordtypeId);
        critManager.getDefaultRecordType();
        critManager.getAnswerRecordType(recordtypeId);
        critManager.getCriteriaRecordTypes();
        critManager.hasCriteriaAnswer(recordtypeId);
        critManager.returnBooleanRecordTypeId();
    }
    static testmethod void testManager2(){   
        recordtypeId = null;
    
        ASI_CRM_TH_CriteriaManager critManager = new ASI_CRM_TH_CriteriaManager();
        critManager.newClassInstance(recordtypeId);
        critManager.getDefaultRecordType();
        critManager.getAnswerRecordType(recordtypeId);
        critManager.getCriteriaRecordTypes();
        critManager.hasCriteriaAnswer(recordtypeId);
        critManager.returnBooleanRecordTypeId();
    }
}