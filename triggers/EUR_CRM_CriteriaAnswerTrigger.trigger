trigger EUR_CRM_CriteriaAnswerTrigger on EUR_CRM_Criteria_Answer__c (before delete, after insert, after update) {
    /**
    * EUR_CRM_ProsSegmentationClass.processCriteriaSheetModification - finds all PROS Segmentation record using criteria set and updates EUR_CRM_Pros_Segmentation__c.EUR_CRM_Is_Image_Level_Modified__c and EUR_CRM_Pros_Segmentation__c.EUR_CRM_Is_Volume_Potential_Modified__c. 
    * 09/26
    * 1)For Germany (DE) and SFA Lite (E1)
    *       a) Warning Message show on PROS section on account page layout when met the following condition:
    *           - Add new criteria threshold
    *           - Edit the criteria threshold statement
    *           - Edit the selected picklist value of a criteria threshold
    *           - Remove selected picklist value of a criteria threshold
    *           - Update of criteria threshold type (the record type)
    *
    *Edit: 12/18 - Apply new warning message change criteria (identified above, change 09/26) for all affiliates
    **/
    
    Set<String> limitedUpdateAffiliateSet = new Set<String> {'DE', 'E1'};
    Set<String> criteriaAnswerTypeForVerification = new Set<String> {'EUR_CRM_Picklist'};
    
    Set<Id> criteriaThresholds = new Set<Id>();
    Map<Id, List<EUR_CRM_Criteria_Answer__c>> criteriaThresholdsPicklist = new Map<Id, List<EUR_CRM_Criteria_Answer__c>>();
    List<EUR_CRM_Criteria_Threshold__c> criteriaThresholdList= new List<EUR_CRM_Criteria_Threshold__c>();
    Set<Id> criteriaSet = new Set<Id>();
    
    //init Criteria Answer Record Type Map
    /*if (Trigger.isInsert){
        for (EUR_CRM_Criteria_Answer__c cAnswer : [Select Id, EUR_CRM_Criteria_Threshold__c,
                                                    EUR_CRM_Criteria_Threshold__r.EUR_CRM_Criteria_Set__r.EUR_CRM_Country_Code__c,EUR_CRM_Value__c
                                                    FROM EUR_CRM_Criteria_Answer__c
                                                    WHERE Id IN:Trigger.New])
        {
            System.debug('Flag- Criteria set of answer: ' + cAnswer);
            System.debug('Flag- Criteria set of answerInsert: ');
            if (!limitedUpdateAffiliateSet.contains(cAnswer.EUR_CRM_Criteria_Threshold__r.EUR_CRM_Criteria_Set__r.EUR_CRM_Country_Code__c)){
                criteriaThresholds.add(cAnswer.EUR_CRM_Criteria_Threshold__c);
            }
        }
    }*/
    
    if (Trigger.isDelete){
        for (EUR_CRM_Criteria_Answer__c cAnswer : [Select Id, EUR_CRM_Criteria_Threshold__c, RecordTypeId,
                                                    EUR_CRM_Criteria_Threshold__r.EUR_CRM_Criteria_Set__r.EUR_CRM_Country_Code__c,
                                                    EUR_CRM_Criteria_Threshold__r.RecordType.DeveloperName, EUR_CRM_Value__c
                                                    FROM EUR_CRM_Criteria_Answer__c
                                                    WHERE Id IN: Trigger.Old])
        {
            System.debug('Flag- Criteria set of answer: ' + cAnswer);
            /*if (! limitedUpdateAffiliateSet.contains(cAnswer.EUR_CRM_Criteria_Threshold__r.EUR_CRM_Criteria_Set__r.EUR_CRM_Country_Code__c)){
                criteriaThresholds.add(cAnswer.EUR_CRM_Criteria_Threshold__c);
            }*/
            //if(limitedUpdateAffiliateSet.contains(cAnswer.EUR_CRM_Criteria_Threshold__r.EUR_CRM_Criteria_Set__r.EUR_CRM_Country_Code__c) &&
            if (criteriaAnswerTypeForVerification.contains(cAnswer.EUR_CRM_Criteria_Threshold__r.RecordType.DeveloperName)){
                
                if(!criteriaThresholdsPicklist.containsKey(cAnswer.EUR_CRM_Criteria_Threshold__c)){
                    List<EUR_CRM_Criteria_Answer__c> tempAns = new List<EUR_CRM_Criteria_Answer__c>();
                    tempAns.add(Trigger.oldMap.get(cAnswer.Id));
                    criteriaThresholdsPicklist.put(cAnswer.EUR_CRM_Criteria_Threshold__c, tempAns);
                }else{
                    criteriaThresholdsPicklist.get(cAnswer.EUR_CRM_Criteria_Threshold__c).add(Trigger.oldMap.get(cAnswer.Id));
                }
            }
        }
    }
    
    if (Trigger.isUpdate){
        for (EUR_CRM_Criteria_Answer__c cAnswer : [Select Id, EUR_CRM_Criteria_Threshold__c, RecordTypeId,
                                                    EUR_CRM_Criteria_Threshold__r.EUR_CRM_Criteria_Set__r.EUR_CRM_Country_Code__c,
                                                    EUR_CRM_Criteria_Threshold__r.RecordType.DeveloperName, EUR_CRM_Value__c
                                                    FROM EUR_CRM_Criteria_Answer__c
                                                    WHERE Id IN:Trigger.New]){
                                                    
            System.debug('Flag- Criteria set of answer: ' + cAnswer);
            System.debug('Flag- Criteria set of answerUpdate: ');
            /*if (! limitedUpdateAffiliateSet.contains(cAnswer.EUR_CRM_Criteria_Threshold__r.EUR_CRM_Criteria_Set__r.EUR_CRM_Country_Code__c)){
                criteriaThresholds.add(cAnswer.EUR_CRM_Criteria_Threshold__c);
            }*/
            //if(limitedUpdateAffiliateSet.contains(cAnswer.EUR_CRM_Criteria_Threshold__r.EUR_CRM_Criteria_Set__r.EUR_CRM_Country_Code__c)
            if(criteriaAnswerTypeForVerification.contains(cAnswer.EUR_CRM_Criteria_Threshold__r.RecordType.DeveloperName) &&
                    (cAnswer.EUR_CRM_Value__c != Trigger.oldMap.get(cAnswer.Id).EUR_CRM_Value__c)){

                if(!criteriaThresholdsPicklist.containsKey(cAnswer.EUR_CRM_Criteria_Threshold__c)){
                    List<EUR_CRM_Criteria_Answer__c> tempAns = new List<EUR_CRM_Criteria_Answer__c>();
                    tempAns.add(Trigger.oldMap.get(cAnswer.Id));
                    criteriaThresholdsPicklist.put(cAnswer.EUR_CRM_Criteria_Threshold__c, tempAns);
                }else{
                    criteriaThresholdsPicklist.get(cAnswer.EUR_CRM_Criteria_Threshold__c).add(Trigger.oldMap.get(cAnswer.Id));
                }
            }
        }
    }
    
    
    criteriaThresholdList = [SELECT EUR_CRM_Criteria_Set__c from EUR_CRM_Criteria_Threshold__c WHERE Id IN:criteriaThresholds];
    
    for(EUR_CRM_Criteria_Threshold__c cThreshold: criteriaThresholdList)
    {
        criteriaSet.add(cThreshold.EUR_CRM_Criteria_Set__c);
    }
    System.debug('Flag - Criteria Set: ' + criteriaSet);
    //Process selected criteria set
    EUR_CRM_ProsSegmentationClass.processCriteriaSheetModification(criteriaSet);
    
    system.debug('****criteriaThresholdsPicklist: ' + criteriaThresholdsPicklist);
    if(criteriaThresholdsPicklist.size() > 0){
        criteriaThresholdList = [SELECT EUR_CRM_Criteria_Set__c from EUR_CRM_Criteria_Threshold__c WHERE Id IN:criteriaThresholdsPicklist.keySet()];
        
        for(EUR_CRM_Criteria_Threshold__c cThreshold: criteriaThresholdList){
            criteriaSet.add(cThreshold.EUR_CRM_Criteria_Set__c);
        }
        
        EUR_CRM_ProsSegmentationClass.processPicklistCriteriaSheetModification(criteriaSet, criteriaThresholdsPicklist);
    }
}