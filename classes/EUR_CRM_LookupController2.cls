/**
 * Created by Alona Riabchenko on 3/22/2018.
 */

public with sharing class EUR_CRM_LookupController2 {
    @AuraEnabled
    public static List <sObject> fetchAccount(String objName, String searchKeyWord, String recordId) {
        String searchKey = '\'' + searchKeyWord + '%\'';
        String query = 'SELECT Id, Name ' +
                ' FROM ' + objName +
                ' WHERE Name LIKE ' + searchKey +
                ' {1} LIMIT 100';
        if (objName.equalsIgnoreCase('EUR_CRM_OP_Action__c') && String.isNotBlank(recordId)) {
            query = query.replace('{1}', 'AND EUR_CRM_OP_Template__c = \'' + recordId + '\'');
        } else {
            query = query.replace('{1}', '');
        }
        System.debug('\n\n query => ' + JSON.serializePretty(query) + '\n');
        List<sObject> sobjList = Database.query(query);
        return sobjList;
    }

    @AuraEnabled
    public static List <sObject> getNameById(String objName, Id objId, String lookupField) {
        String childObjName = objId.getSObjectType().getDescribe().getName();
        String searchKey = '\'' + objId + '\'';
        String query = 'SELECT Id, Name ' +
                ' FROM ' + childObjName +
                ' WHERE Id = ' + searchKey ;
        List<sObject> sobjList = Database.query(query);
        return sobjList;
    }
}