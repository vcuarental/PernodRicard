public with sharing class EUR_CRM_ObjPromoActionSetVisActRTID {


    /* ========================================================= */
    /*     Interface
    /* ========================================================= */
    public void setVisitActionRecordTypeId(List<EUR_CRM_ObjPromo_Action__c> objPromoActions) {
        Map<String, List<EUR_CRM_ObjPromo_Action__c>> opActionsByVisitActionRTDevName = this.getObjPromoActionsByVisitActionRTDevName(objPromoActions);
        System.debug('\n\n opActionsByVisitActionRTDevName => ' + JSON.serializePretty(opActionsByVisitActionRTDevName) + '\n');
        if (opActionsByVisitActionRTDevName.isEmpty()) { return ; }

        this.doSetUpVisitActionRecordTypeId(opActionsByVisitActionRTDevName);
    }

    public void setVisitActionRecordTypeId(List<EUR_CRM_ObjPromo_Action__c> objPromoActions, Map<Id, EUR_CRM_ObjPromo_Action__c> oldObjPromoActionById) {
        Map<String, List<EUR_CRM_ObjPromo_Action__c>> opActionsByVisitActionRTDevName = this.getObjPromoActionsByVisitActionRTDevName(objPromoActions, oldObjPromoActionById);
        System.debug('\n\n opActionsByVisitActionRTDevName => ' + JSON.serializePretty(opActionsByVisitActionRTDevName) + '\n');
        if (opActionsByVisitActionRTDevName.isEmpty()) { return ; }

        this.doSetUpVisitActionRecordTypeId(opActionsByVisitActionRTDevName);
    }


    /* ========================================================= */
    /*     Delegate Methods
    /* ========================================================= */
    private void doSetUpVisitActionRecordTypeId(Map<String, List<EUR_CRM_ObjPromo_Action__c>> opActionsByVisitActionRTDevName) {
        Map<String, Id> recordTypeIdByDeveloperName = this.getRecordTypeIdByDeveloperName(opActionsByVisitActionRTDevName.keySet());
        System.debug('\n\n recordTypeIdByDeveloperName => ' + JSON.serializePretty(recordTypeIdByDeveloperName) + '\n');
        if (recordTypeIdByDeveloperName.isEmpty()) { return ; }

        for (String rtDevName : opActionsByVisitActionRTDevName.keySet()) {
            if (recordTypeIdByDeveloperName.containsKey(rtDevName)) {
                Id rtId = recordTypeIdByDeveloperName.get(rtDevName);
                for (EUR_CRM_ObjPromo_Action__c objPromoAction : opActionsByVisitActionRTDevName.get(rtDevName)) {
                    objPromoAction.EUR_CRM_Visit_Action_RecordTypeID__c = rtId;
                }
            }
        }
    }


    /* ========================================================= */
    /*     High Level Helpers
    /* ========================================================= */
    private Map<String, Id> getRecordTypeIdByDeveloperName(Set<String> rtDevNames) {
        List<RecordType> recordTypes = this.selectRecordTypesWhereDeveloperNames(rtDevNames);
        System.debug('\n\n recordTypes => ' + JSON.serializePretty(recordTypes) + '\n');

        Map<String, Id> recordTypeIdByDeveloperName = new Map<String, Id>();
        for (RecordType rt : recordTypes) {
            recordTypeIdByDeveloperName.put(rt.DeveloperName, rt.Id);
        }
        return recordTypeIdByDeveloperName;
    }


    /* ========================================================= */
    /*     Middle Level Helpers
    /* ========================================================= */
    private Map<String, List<EUR_CRM_ObjPromo_Action__c>> getObjPromoActionsByVisitActionRTDevName(List<EUR_CRM_ObjPromo_Action__c> objPromoActions) {
        Map<String, List<EUR_CRM_ObjPromo_Action__c>> opActionsByVisitActionRTDevName = new Map<String, List<EUR_CRM_ObjPromo_Action__c>>();
        for (EUR_CRM_ObjPromo_Action__c objPromoAction : objPromoActions) {
            if (this.isDataValid(objPromoAction)) {
                this.populateMap(opActionsByVisitActionRTDevName, objPromoAction);
            }
        }
        return opActionsByVisitActionRTDevName;
    }

    private Map<String, List<EUR_CRM_ObjPromo_Action__c>> getObjPromoActionsByVisitActionRTDevName(List<EUR_CRM_ObjPromo_Action__c> objPromoActions, Map<Id, EUR_CRM_ObjPromo_Action__c> oldObjPromoActionById) {
        Map<String, List<EUR_CRM_ObjPromo_Action__c>> opActionsByVisitActionRTDevName = new Map<String, List<EUR_CRM_ObjPromo_Action__c>>();
        for (EUR_CRM_ObjPromo_Action__c objPromoAction : objPromoActions) {
            if (this.isDataChanged(objPromoAction, oldObjPromoActionById) && this.isDataValid(objPromoAction)) {
                this.populateMap(opActionsByVisitActionRTDevName, objPromoAction);
            }
        }
        return opActionsByVisitActionRTDevName;
    }

    private void populateMap(Map<String, List<EUR_CRM_ObjPromo_Action__c>> opActionsByVisitActionRTDevName, EUR_CRM_ObjPromo_Action__c objPromoAction) {
        if (opActionsByVisitActionRTDevName.containsKey(objPromoAction.EUR_CRM_Visit_Action_RecordType_DevName__c)) {
            opActionsByVisitActionRTDevName.get(objPromoAction.EUR_CRM_Visit_Action_RecordType_DevName__c).add(objPromoAction);
        } else {
            opActionsByVisitActionRTDevName.put(objPromoAction.EUR_CRM_Visit_Action_RecordType_DevName__c, new List<EUR_CRM_ObjPromo_Action__c> { objPromoAction });
        }
    }


    /* ========================================================= */
    /*     Low Level Helpers
    /* ========================================================= */
    private Boolean isDataValid(EUR_CRM_ObjPromo_Action__c objPromoAction) {
        return objPromoAction.EUR_CRM_Visit_Action_RecordType_DevName__c != null;
    }

    private Boolean isDataChanged(EUR_CRM_ObjPromo_Action__c objPromoAction, Map<Id, EUR_CRM_ObjPromo_Action__c> oldObjPromoActionById) {
        return objPromoAction.EUR_CRM_Visit_Action_RecordType_DevName__c != oldObjPromoActionById.get(objPromoAction.Id).EUR_CRM_Visit_Action_RecordType_DevName__c;
    }


    /* ========================================================= */
    /*     SOQL Selectors
    /* ========================================================= */
    private List<RecordType> selectRecordTypesWhereDeveloperNames(Set<String> rtDevNames) {
        return [
            SELECT Id
            ,   DeveloperName
            FROM RecordType
            WHERE DeveloperName IN :rtDevNames
                AND SobjectType = 'EUR_CRM_Visit_Action__c'
        ];
    }

}