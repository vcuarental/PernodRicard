@isTest
public with sharing class ASI_CRM_TestCriteriaManager {

    private static ASI_CRM_Criteria_Set__c criteriaSet;
    private static Id recordtypeId;
    
    static testmethod void dataInsert(){
        
        List<ASI_CRM_Criteria_Set__c> criteriaSetList = new List<ASI_CRM_Criteria_Set__c>();
        criteriaSetList = ASI_CRM_TestClassUtilityHelperPROS.createCriteriaSet(1, 'ASI_SG_Image_Level_Criteria');
        insert criteriaSetList;
         
        system.assert(criteriaSetList[0].Id<>null);
        
        List<ASI_CRM_Criteria_Threshold__c> criteriaThresholdList = new List<ASI_CRM_Criteria_Threshold__c>();
        criteriaThresholdList = ASI_CRM_TestClassUtilityHelperPROS.createCriteriaThreshold(1, 'ASi_CRM_SG_Picklist', criteriaSetList[0].Id);
        insert criteriaThresholdList;
        
        recordtypeId = criteriaThresholdList[0].RecordTypeId;
        
        system.assert(criteriaThresholdList[0].Id<>null);
        system.assert(recordtypeId<>null);
        
    }
    static testmethod void testManager(){
    
        dataInsert();
        
        ASI_CRM_CriteriaManager critManager = new ASI_CRM_CriteriaManager();
        critManager.newClassInstance(recordtypeId);
        critManager.getDefaultRecordType();
        critManager.getAnswerRecordType(recordtypeId);
        critManager.getCriteriaRecordTypes();
        critManager.hasCriteriaAnswer(recordtypeId);
        critManager.returnBooleanRecordTypeId();
    }
    static testmethod void testManager2(){
    
        recordtypeId = null;
    
        ASI_CRM_CriteriaManager critManager = new ASI_CRM_CriteriaManager();
        critManager.newClassInstance(recordtypeId);
        critManager.getDefaultRecordType();
        critManager.getAnswerRecordType(recordtypeId);
        critManager.getCriteriaRecordTypes();
        critManager.hasCriteriaAnswer(recordtypeId);
        critManager.returnBooleanRecordTypeId();
    }
}