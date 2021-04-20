public with sharing class EUR_CRM_FindAccountsDuplicate implements
                Database.Batchable<SObject>, Database.Stateful {
    List<EUR_CRM_Account__c> accountsDuplicateList = new List<EUR_CRM_Account__c>();
    Map<Id, String> keyStringById = new Map<Id, String> ();
    Map<Id, List<Id>> originalAndDuplicatesIds = new Map<Id, List<Id>>();
    //String searchKey = 'Name, EUR_CRM_Street__c, EUR_CRM_City__c, EUR_CRM_Email__c';
    public static Set<String> noChangeChildrenSet = new Set<String>{
            'EUR_Account_Links__r', 'Histories', 'ActivityHistories', 'EUR_CRM_PRS_Segmentation__r',
            'NetworkUserHistoryRecentToRecord', 'RecordActionHistories', 'Shares', 'EUR_CRM_AccountGroups__r',
            'ContentDocumentLinks', 'DuplicateRecordItems', 'EUR_CRM_JB_Opening_Hour__c', 'EUR_CRM_Note__c', 'RecordAssociatedGroups',
            'CombinedAttachments', 'FeedSubscriptionsForEntity', 'Notes', 'NotesAndAttachments', 'OpenActivities', 'RelatedToId',
            'ProcessInstances', 'ProcessSteps', 'RecordActions', 'RecordActionHistories', 'AttachedContentDocuments'
    };
    public static Map<String, String> childrenFilterSetting = new Map<String, String>{
            'Contracts__r' => 'EUR_CRM_Start_Date__c', 'Sales_Orders__r' => 'Name',
            'Visits__r' => 'EUR_CRM_Start_Datetime__c', 'AttachedContentDocuments' => 'ContentSize',
            'Cases__r' => 'CaseNumber', 'Feeds' => 'LinkUrl',
            'Emails' => 'FirstOpenedDate', 'Events' => 'StartDateTime',
            'EventRelations' => 'Response', 'Tasks' => 'CreatedDate',
            'TaskRelations' => 'TaskId', 'TopicAssignments' => 'TopicId'
    };
    EUR_CRM_Find_Accounts_Duplicate_Keys__c customSettingSearchKey = EUR_CRM_Find_Accounts_Duplicate_Keys__c.getInstance();
    String searchKey = '' + customSettingSearchKey.keys__c;
    List <String> searchFieldsList = searchKey.deleteWhitespace().split(',');
    List<String> errorUpdateMsg = new List<String>();
    List<String> errorInsertMsg = new List<String>();


    private List<AggregateResult> AggregateResultList = Database.query(
            'SELECT Min(CreatedDate) CreatedDate, MIN(Id) Id, COUNT(Id), ' + searchKey +
                    ' FROM EUR_CRM_Account__c ' +
                    'WHERE CreatedDate > 2019-01-01T01:02:03Z' +
                    'GROUP BY ' + searchKey + ' ' +
                    'HAVING COUNT(Id) > 1 ' +
                    'ORDER BY Min(CreatedDate)');


    public Iterable<SObject> start(Database.BatchableContext bc) {
        return AggregateResultList;
    }

    public void execute(Database.BatchableContext context, List<AggregateResult> AggregateResults) {

        accountsDuplicateList = findDuplicate(searchFieldsAndValues(AggregateResults));
        originalAndDuplicatesIds = fillMapByIds(accountsDuplicateList);
        reassignAccountsRelatedObjects();

        Database.delete(accountsDuplicateList, false);
        accountsDuplicateList.clear();
        keyStringById.clear();
        originalAndDuplicatesIds.clear();
    }

    public List<EUR_CRM_Account__c> findDuplicate(Map<String, String> searchFieldsAndValues) {
        String query = ' SELECT Id,' + searchKey + ' FROM EUR_CRM_Account__c WHERE Id NOT IN( ' + searchFieldsAndValues.get('Id') + ' )';
        for (String field : searchFieldsAndValues.keySet()) {
            if (field != 'Id') {
                query = query + ' AND ' + field + ' IN( ' + searchFieldsAndValues.get(field) + ' )';
            }
        }

        System.debug('findDuplicate query => ' + query);
        List<EUR_CRM_Account__c> DuplicatesAccounts = Database.query(query);

        return DuplicatesAccounts;
    }
    public Map<String, String> searchFieldsAndValues(List<AggregateResult> aggregateResults) {
        Map<String, String> fieldApiNameAndValues = new Map<String, String> ();
        Boolean idFieldPut = false;
        for (String searchFieldApiName : searchFieldsList) {
            String fieldValue = '';
            String IdFieldValue = '';
            Id originalAccId;
            String temp = '';
            String tempKeyValue = '';
            Object fieldObject;
            for (Integer i = 0; i < aggregateResults.size(); i++) {
                AggregateResult aggRes = aggregateResults.get(i);
                originalAccId = (Id) aggRes.get('Id');
                if (!idFieldPut) {
                    IdFieldValue = IdFieldValue + '\'' + originalAccId + '\', ';
                    fieldApiNameAndValues.put('Id', IdFieldValue);
                    if (i == (aggregateResults.size() - 1)) {
                        fieldApiNameAndValues.put('Id', IdFieldValue.removeEnd(', '));
                        idFieldPut = true;
                    }
                }
                fieldObject = aggRes.get(searchFieldApiName);
                if (fieldObject != null) {
                    temp = fieldObject.toString();
                    if (temp.contains('\'')) {
                        temp = temp.replace('\'', '\\\'');
                    }
                    fieldValue = fieldValue + '\'' + temp + '\', ';
                } else {
                    fieldValue = fieldValue + '\'\', ';
                    temp = '_';
                }

                fieldApiNameAndValues.put(searchFieldApiName, fieldValue);

                if (keyStringById.get(originalAccId) != null) {
                    tempKeyValue = keyStringById.get(originalAccId) + temp;
                    keyStringById.put(originalAccId, tempKeyValue);
                } else {
                    keyStringById.put(originalAccId, temp);
                }
            }
            fieldApiNameAndValues.put(searchFieldApiName, fieldValue.removeEnd(', '));
        }

        for (Id i : keyStringById.keySet()) {
            System.debug('originalId => ' + i + ' Key => ' + keyStringById.get(i));
        }
        return fieldApiNameAndValues;
    }

    private Map<Id, List<Id>> fillMapByIds(List<EUR_CRM_Account__c> duplicateAccounts) {
        Map<Id, List<Id>> originalAndDuplicates = new Map<Id, List<Id>>();
        Map<String, List<Id>> keysAndDuplicates = getKeysFromAccountsList(duplicateAccounts);

        for (Id originalAccId : keyStringById.keySet()) {
            System.debug('keyStringById =>' + keyStringById);
            System.debug('keysAndDuplicates =>' + keysAndDuplicates);
            originalAndDuplicates.put(originalAccId, keysAndDuplicates.get(keyStringById.get(originalAccId)));
        }
// System.debug('original and duplicate map  => ' + originalAndDuplicates);
        return originalAndDuplicates;
    }

    private Map<String, List<Id>> getKeysFromAccountsList(List<EUR_CRM_Account__c> duplicateAccounts) {
        Map<String, List<Id>> keyAndDuplicatesList = new Map<String, List<Id>>();
        String key = '';
        for (EUR_CRM_Account__c acc : duplicateAccounts) {
            for (Integer i = 0; i < searchFieldsList.size(); i++) {
                String fieldApiName = searchFieldsList.get(i);
                if (acc.get(fieldApiName) != null) {
                    key += acc.get(fieldApiName);
                } else {
                    key += '_';
                }
            }
            if (key.contains('\'')) {
                key = key.replace('\'', '\\\'');
            }
            if (keyAndDuplicatesList.containsKey(key)) {
                keyAndDuplicatesList.get(key).add(acc.Id);
            } else {
                keyAndDuplicatesList.put(key, new List<Id>());
                keyAndDuplicatesList.get(key).add(acc.Id);
            }
            key = '';
        }
        return keyAndDuplicatesList;
    }

    public void reassignAccountsRelatedObjects() {
        Schema.DescribeSObjectResult describeSObjectResult = EUR_CRM_Account__c.SObjectType.getDescribe();
        List<Schema.ChildRelationship> childRelationships = describeSObjectResult.getChildRelationships();
        Schema.DescribeSObjectResult childDescribe;
        Map<String, Schema.SObjectField> fieldMap;
        SObjectType childSObjectType;
        String childFieldRelatedToAccount;
        String RelationshipName;
        for (Schema.ChildRelationship relationship : childRelationships) {
            childSObjectType = relationship.childSObject;
            childFieldRelatedToAccount = String.valueOf(relationship.getField());
            RelationshipName = relationship.getRelationshipName();
            childDescribe = childSObjectType.getDescribe();
            fieldMap = childDescribe.fields.getMap();

            if (relationship != null && childFieldRelatedToAccount != null && RelationshipName != null && childDescribe != null && !noChangeChildrenSet.contains(RelationshipName)) {
                reassignChangeableAccountsChildren(originalAndDuplicatesIds, RelationshipName, childFieldRelatedToAccount);
            }
//            else {
//                //  reassignMasterDetailAccountsChildren(originalAndDuplicatesIds, RelationshipName, childFieldRelatedToAccount, childSObjectType);
//            }
        }

    }
    public void reassignChangeableAccountsChildren(Map<Id, List<Id>> originalAccountAndDuplicates, String sObjectApiName, String accountFieldOnSobject) {
        Map<Id, List<SObject>> duplicatesChildrenMap = findChangeableChildren(accountsDuplicateList, sObjectApiName, accountFieldOnSobject);
        Map<Id, List<SObject>> originalChildrenMap = findOriginalChildren(originalAccountAndDuplicates.keySet(), sObjectApiName, accountFieldOnSobject);
        Map<Id, List<SObject>> filteredChildrenMap = filterChildren(originalChildrenMap, duplicatesChildrenMap, sObjectApiName);
        List<SObject> updateChildrenList = new List<SObject>();
        List<SObject> tempObjects = new List<SObject>();
        Integer i = 0;
        for (Id originalAccId : originalAccountAndDuplicates.keySet()) {
            System.debug('originalAccId => ' + originalAccId);
            System.debug('originalAccountAndDuplicates.get(originalAccId) => ' + originalAccountAndDuplicates);
            if (originalAccountAndDuplicates.get(originalAccId) != null) {
                for (Id duplicateId : originalAccountAndDuplicates.get(originalAccId)) {
                    tempObjects = filteredChildrenMap.get(duplicateId);
                    if (tempObjects != null && !tempObjects.isEmpty()) {
                        for (SObject child : tempObjects) {
                            child.put(accountFieldOnSobject, originalAccId);
                            updateChildrenList.add(child);
                        }
                    }
                }
            }

        }
        System.debug('reassignedChildren => ' + updateChildrenList);
        Database.SaveResult[] result = Database.update(updateChildrenList, false);

        for (Database.SaveResult res : result) {
            if (!res.isSuccess()) {
                String error;
                error = 'Error => ' + res.getErrors().get(0) + '\r' +
                        'Not updateChildren => ' + updateChildrenList.get(i) + '\r';
                errorUpdateMsg.add(error);
            }
            i++;
        }

    }

    public Map<Id, List<SObject>> findChangeableChildren(List<EUR_CRM_Account__c>duplicatesAccounts, String sObjectApiName, String accountFieldOnSobject) {
        Map<Id, List<SObject>> duplicateAccountsAndChildrenMap = new Map<Id, List<SObject>>();
        List<SObject> childrenList = new List<SObject>();
        Set<Id> accountsIds = new Set<Id>();
        List<SObject> sObjects;
        System.debug('duplicatesAccountIds => ' + duplicatesAccounts);
        System.debug('SObjectApiName => ' + sObjectApiName);
        System.debug('field => ' + accountFieldOnSobject);

        for (EUR_CRM_Account__c acc : duplicatesAccounts) {
            accountsIds.add((Id) acc.get('Id'));
        }
        String childQuery = 'SELECT id , name,' +
                '(Select id, ' + accountFieldOnSobject +
                ' from ' + sObjectApiName + ')' +
                ' from EUR_CRM_ACCOUNT__c ' +
                ' where id IN(' + returnStringFromIdsSet(accountsIds) + ')';

        if (childrenFilterSetting.containsKey(sObjectApiName)) {
            childQuery = childQuery.replace('(Select id, ', ('(Select id, ' + childrenFilterSetting.get(sObjectApiName) + ', '));
        } else {
            childQuery = childQuery.replace('(Select id, ', ('(Select id, Name, '));
        }

        for (EUR_CRM_Account__c acc : Database.query(childQuery)) {
            sObjects = acc.getSObjects(sObjectApiName);
            if (sObjects != null) {
                childrenList.addAll(sObjects);
            }
        }
        if (!childrenList.isEmpty()) {
            for (SObject child : childrenList) {
                Id accId = (Id) child.get(accountFieldOnSobject);
                if (duplicateAccountsAndChildrenMap.containsKey(accId)) {
                    duplicateAccountsAndChildrenMap.get(accId).add(child);
                } else {
                    duplicateAccountsAndChildrenMap.put(accId, new List<SObject>());
                    duplicateAccountsAndChildrenMap.get(accId).add(child);
                }
            }
        }

        return duplicateAccountsAndChildrenMap;
    }

    public Map<Id, List<SObject>> findOriginalChildren(Set<Id>originalIds, String sObjectApiName, String accountFieldOnSobject) {
        Map<Id, List<SObject>> originalIdAndChildrenMap = new Map<Id, List<SObject>>();
        List<SObject> childrenList = new List<SObject>();
        List<SObject> sObjects;
        System.debug('duplicatesAccountIds => ' + originalIds);
        System.debug('SObjectApiName => ' + sObjectApiName);
        System.debug('field => ' + accountFieldOnSobject);

        String childQuery = 'SELECT id , name,' +
                '(Select id, ' + accountFieldOnSobject +
                ' from ' + sObjectApiName + ')' +
                ' from EUR_CRM_ACCOUNT__c ' +
                ' where id IN(' + returnStringFromIdsSet(originalIds) + ')';
        if (childrenFilterSetting.containsKey(sObjectApiName)) {
            childQuery = childQuery.replace('(Select id, ', ('(Select id, ' + childrenFilterSetting.get(sObjectApiName) + ', '));
        } else {
            childQuery = childQuery.replace('(Select id, ', ('(Select id, Name, '));
        }

        for (EUR_CRM_Account__c acc : Database.query(childQuery)) {
            sObjects = acc.getSObjects(sObjectApiName);
            if (sObjects != null) {
                childrenList.addAll(sObjects);
            }
        }
        if (!childrenList.isEmpty()) {
            for (SObject child : childrenList) {
                Id accId = (Id) child.get(accountFieldOnSobject);
                if (originalIdAndChildrenMap.containsKey(accId)) {
                    originalIdAndChildrenMap.get(accId).add(child);
                } else {
                    originalIdAndChildrenMap.put(accId, new List<SObject>());
                    originalIdAndChildrenMap.get(accId).add(child);
                }
            }
        }

        return originalIdAndChildrenMap;
    }

    private Map<Id, List<SObject>> filterChildren(Map<Id, List<SObject>>originalAccChildren, Map<Id, List<SObject>>duplicateAccChildren, String sObjectApiName) {
        System.debug('Filter children =>' + sObjectApiName);
        System.debug('originalAccChildren =>' + originalAccChildren);
        System.debug('duplicateAccChildren =>' + duplicateAccChildren);
        Map<Id, List<SObject>>filteredDuplicatesChildren = new Map<Id, List<SObject>>();
        String filterFieldApiName = '';
        if (childrenFilterSetting.containsKey(sObjectApiName)) {
            filterFieldApiName = childrenFilterSetting.get(sObjectApiName);
        } else {
            filterFieldApiName = 'Name';
        }
        if (duplicateAccChildren != null && originalAccChildren != null && !originalAccChildren.isEmpty()) {
            for (Id originalAccId : originalAccChildren.keySet()) {
                List<Id>duplicateAccIds = originalAndDuplicatesIds.get(originalAccId);
                List<SObject> originalChildren = originalAccChildren.get(originalAccId);
                Map<String, List<SObject>> originalChildrenByFilterField = getCustomMap(originalChildren, filterFieldApiName);

                for (Id duplicateId : duplicateAccIds) {
                    List<SObject> duplicateChildren = new List<SObject>();
                    if (duplicateAccChildren.containsKey(duplicateId)) {
                        duplicateChildren = duplicateAccChildren.get(duplicateId);
                    }
                    System.debug('duplicate children list size =>' + duplicateChildren.size());
                    System.debug('duplicate children =>' + duplicateChildren);
                    for (SObject child : duplicateChildren) {
                        if (originalChildrenByFilterField.containsKey(String.valueOf(child.get(filterFieldApiName))) != true) {
                            if (filteredDuplicatesChildren.containsKey(duplicateId) != true) {
                                filteredDuplicatesChildren.put(duplicateId, new List<SObject>());
                            }
                            filteredDuplicatesChildren.get(duplicateId).add(child);
                        }
                    }
                }

            }
        } else if (duplicateAccChildren != null && originalAccChildren != null) {
            filteredDuplicatesChildren = duplicateAccChildren;
        }
        return filteredDuplicatesChildren;
    }
//-----------------------------------------------------------Work with Master-Detail---------------------------------------------------------------------------
//    public void reassignMasterDetailAccountsChildren(Map<Id, List<Id>> originalAccountAndDuplicates, String SObjectApiName, String accountFieldOnSobject, SObjectType sObjectType) {
//        List<SObject> newChildrenList = new List<SObject>();
//        Map<Id, List<SObject>> allChildrenMap = findMasterDetailChildren(accountsDuplicateList, SObjectApiName, sObjectType, accountFieldOnSobject);
//        List<SObject> tempObjects = new List<SObject>();
//        SObject cloneObject;
//        Integer i = 0;
//
//
//        if (!allChildrenMap.isEmpty() && allChildrenMap != null) {
//            for (Id originalAccId : originalAccountAndDuplicates.keySet()) {
//                for (Id duplicateId : originalAndDuplicatesIds.get(originalAccId)) {
//                    tempObjects = allChildrenMap.get(duplicateId);
//                    if (tempObjects != null && !tempObjects.isEmpty()) {
//                        for (SObject child : tempObjects) {
//                            cloneObject = child.clone();
//                            cloneObject.put(accountFieldOnSobject, originalAccId);
//                            newChildrenList.add(cloneObject);
//                        }
//                    }
//                }
//            }
//
//        }
//
//        Database.SaveResult[] result = Database.insert(newChildrenList, false);
//
//        for (Database.SaveResult res : result) {
//            if (!res.isSuccess()) {
//                String error;
//                error = 'Error => ' + res.getErrors().get(0) + '\r' +
//                        'Not insert Children => ' + newChildrenList.get(i) + '\r';
//                errorInsertMsg.add(error);
//            }
//            i++;
//        }
//    }

//    public Map<Id, List<SObject>> findMasterDetailChildren(List<EUR_CRM_Account__c>duplicatesAccounts, String childSObject, SObjectType sObjectType, String accountFieldOnSobject) {
//        Map<Id, List<SObject>> parentAccWithChildren = new Map<Id, List<SObject>>();
//        List<SObject> childrenList = new List<SObject>();
//        Set<Id> accountsIds = new Set<Id>();
//        List<SObject> sObjects;
//        String fieldSet = '';
//
//        for (EUR_CRM_Account__c acc : duplicatesAccounts) {
//            accountsIds.add((Id) acc.get('Id'));
//        }
//
//        for (String s : requiredFields(sObjectType)) {
//            fieldSet += s + ', ';
//        }
//        fieldSet = fieldSet.removeEnd(', ');
//        System.debug('required fieldSet  => ' + fieldSet);
//
//        String childQuery = 'SELECT id , name,' +
//                '(Select  ' + fieldSet +
//                ' from ' + childSObject + ')' +
//                ' from EUR_CRM_ACCOUNT__c ' +
//                ' where id IN(' + returnStringFromIdsSet(accountsIds) + ')';
//
//        System.debug('child query => ' + childQuery);
//
//        for (EUR_CRM_Account__c acc : Database.query(childQuery)) {
//            sObjects = acc.getSObjects(childSObject);
//
//            if (sObjects != null) {
//                childrenList.addAll(sObjects);
//            }
//        }
//
//        for (SObject child : childrenList) {
//            Id accId = (Id) child.get(accountFieldOnSobject);
//            if (!parentAccWithChildren.containsKey(accId)) {
//                parentAccWithChildren.put(accId, new List<SObject>());
//            }
//            parentAccWithChildren.get(accId).add(child);
//        }
//        return parentAccWithChildren;
//    }


//    public List<String> requiredFields(SObjectType sObjectType) {
//        List<String> reqFields = new List<String>();
//        SObjectType objectType = sObjectType;
//        Schema.DescribeSObjectResult describeSObjectResult = objectType.getDescribe();
//        Map<String, Schema.SObjectField> fieldsMap = describeSObjectResult.fields.getMap();
//        for (String fieldName : fieldsMap.keySet()) {
//            Schema.SObjectField field = fieldsMap.get(fieldName);
//            Schema.DescribeFieldResult fieldDescribe = field.getDescribe();
//
//            if (String.valueOf(fieldDescribe.type) != 'BASE64' && fieldDescribe.isNillable() != true) {
////                System.debug('field label => '+ fieldDescribe.label);
////                System.debug('field length => '+ fieldDescribe.type);
//                reqFields.add(String.valueOf(field));
//            }
//        }
//        return reqFields;
//    }
//-----------------------------------------------------------------------------------------------------------------------
    private String returnStringFromIdsSet(Set<Id> ids) {
        String stringId = '';
        if (ids != null) {
            for (Id tempId : ids) {
                stringId = stringId + '\'' + tempId + '\',';
            }
            return stringId.removeEnd(',');
        } else {
            stringId = '\'\'';
            return stringId;
        }
    }
    private Map<String, List<SObject>>getCustomMap(List<SObject>customSObjects, String keyTypeApi) {
        Map<String, List<SObject>> customMap = new Map<String, List<SObject>>();
        Map<String, SObjectType> globalDescribe = Schema.getGlobalDescribe();
        SObjectType keyType = globalDescribe.get(keyTypeApi);
        for (SObject customObject : customSObjects) {
            if (customMap.containsKey(String.valueOf(customObject.get(keyTypeApi))) != true) {
                customMap.put(String.valueOf(customObject.get(keyTypeApi)), new List<SObject>());
            }
            customMap.get(String.valueOf(customObject.get(keyTypeApi))).add(customObject);
        }
        return customMap;
    }


    public void finish(Database.BatchableContext param1) {
        if (!errorInsertMsg.isEmpty() || !errorUpdateMsg.isEmpty()) {
            try {
                sendEmail(errorUpdateMsg, errorInsertMsg);
            } catch (Exception e) {
                System.debug('Email send exception =>' + e.getMessage());
            }
        }

    }


//---------------------------------------------------------------------------------------------

    private void sendEmail(List<String> errorUpdateMsgString, List<String> errorInsertMsgString) {
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[]{
                UserInfo.getUserEmail()
        };
        String mainString = 'Errors and Accounts children, which were not inserted or updated due to an error: \r ';

        if (!errorUpdateMsgString.isEmpty()) {
            mainString = 'Update errors:  \r';
            Integer i = 0;
            for (String err : errorUpdateMsgString) {
                mainString = mainString + err;
                i++;
            }
        }
        if (!errorInsertMsgString.isEmpty()) {
            mainString = 'Insert errors:  \r';
            Integer i = 0;
            for (String err : errorInsertMsgString) {
                mainString = mainString + err;
                i++;
            }
        }

        email.setToAddresses(toAddresses);
        email.setSubject('Errors deleting duplicate accounts');
        email.setPlainTextBody(mainString);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[]{
                email
        });
    }

}