public without sharing class EUR_CRM_DynamicGroupService {

    public enum GroupType { ACCOUNT, PRODUCT }
    public enum GroupMembProcess { DELETING, ADDING }
    public enum GroupMembChangingProcess { MEMBERS_SELECTING, GROUPS_CHEKING }

    public static final String CONTAINS_RELATION_TYPE = 'contains';
    public static final String NOT_CONTAINS_RELATION_TYPE = 'does not contain';
    public static final String CONTAINS_ALL_RELATION_TYPE = 'has all';

    public static final Integer BATCH_SCOPE_SIZE = Test.isRunningTest() ? 1 : 1;
    public static final Integer BULK_CRUD_BATCH_SCOPE_SIZE = Test.isRunningTest() ? 100 : 200;

    public static final Id COMPANY_PRODUCT_RT_ID = EUR_CRM_RecordTypeHelper_v2.getRTByDevName('CTCPG__Product__c', 'CompanyProduct');

    private static final String FILTER_CRITERIA_STRING_FIELD_API_NAME = 'EUR_CRM_Criteria__c';

    public static Database.SaveResult[] insertMembersOfGroup(Set<Id> memberIds, Id groupId) {
        List<SObject> records = getRecordsInGroup(groupId, memberIds);
        return Database.insert(records, false);
    }

    private static List<SObject> getRecordsInGroup(Id groupId, Set<Id> memberIds) {
        GroupType who = groupId.getSobjectType() == EUR_CRM_Account_Target_Group__c.SObjectType ? GroupType.ACCOUNT : GroupType.PRODUCT;
        List<SObject> result = new List<SObject>();
        for (Id memberId : memberIds) {
            if (who == GroupType.ACCOUNT) {
                result.add(new EUR_CRM_Account_in_Target_Group__c(EUR_CRM_Account_Target_Group__c = groupId, EUR_CRM_Account__c = memberId));
            }
//            else {
//                result.add(new ProductInGroup__c(ProductGroup__c = groupId, ProductID__c = memberId));
//            }
        }
        return result;
    }

    public static String getConditions(String query) {
        if(String.isEmpty(query)) return null;
        String conditions;
        if (query.contains('WHERE') && query.contains('WITH')) {
            conditions = query.substringBetween('WHERE ', ' WITH');
        } else if (query.contains('WHERE') && query.contains('GROUP')) {
            conditions = query.substringBetween('WHERE ', ' GROUP');
        } else if (query.contains('WHERE') && query.contains('ORDER')) {
            conditions = query.substringBetween('WHERE ', ' ORDER');
        } else if (query.contains('WHERE') && query.contains('LIMIT')) {
            conditions = query.substringBetween('WHERE ', ' LIMIT');
        } else if (query.contains('WHERE')) {
            conditions = query.substringAfter('WHERE ');
        }
        return conditions;
    }

    public static EUR_CRM_DynamicGroupService.GroupType getGroupType(SObject groupElement) {
        return (groupElement instanceof EUR_CRM_Account_Target_Group__c || groupElement instanceof EUR_CRM_Account__c ) ? EUR_CRM_DynamicGroupService.GroupType.ACCOUNT : EUR_CRM_DynamicGroupService.GroupType.PRODUCT;
    }

    public static String getJunctionName(SObject dynamicGroup) {
        return dynamicGroup instanceof EUR_CRM_Account_Target_Group__c ? 'EUR_CRM_Account_in_Target_Group__c' : '';
    }

    public static String getJunctRelFieldName(SObject dynamicGroup) {
        return dynamicGroup instanceof EUR_CRM_Account_Target_Group__c ? 'EUR_CRM_Account__c' : '';
    }

    public static String getInstanceName(SObject dynamicGroup) {
        return dynamicGroup instanceof EUR_CRM_Account_Target_Group__c ? 'EUR_CRM_Account_Target_Group__c' : '';
    }

    public static void addDynamicGroupMembers(List<SObject> groups) {
        List<SObject> dynamicGroups = extractDynamicGroups(groups);
        if(dynamicGroups.isEmpty()) { return ; }

        createCacheForRecalculation(dynamicGroups);
        new EUR_CRM_DynGroupMembBatch(getGroupType(dynamicGroups[0])).scheduleBatch(dynamicGroups);
    }

    public static void createCacheForRecalculation(List<SObject> groups) {
        System.debug('groups ===> '+groups);
        Map<String, Set<String>> fieldsByObjectName = new Map<String, Set<String>>();
        for (SObject g : groups) {
            EUR_CRM_FilterBuilderService.ParentObjectFilterWrapper parentFilter
                = (EUR_CRM_FilterBuilderService.ParentObjectFilterWrapper) JSON.deserialize((String) g.get(FILTER_CRITERIA_STRING_FIELD_API_NAME), EUR_CRM_FilterBuilderService.ParentObjectFilterWrapper.class);

            if (parentFilter.items != null && ! parentFilter.items.isEmpty()) {
                if(fieldsByObjectName.containsKey(parentFilter.objectName)) {
                    fieldsByObjectName.get(parentFilter.objectName).addAll(getFields(parentFilter.items));
                } else {
                    fieldsByObjectName.put(parentFilter.objectName, new Set<String>(getFields(parentFilter.items)));
                }
            }
            List<EUR_CRM_FilterBuilderService.ChildObjectFilterWrapper> childFilters =
                (parentFilter.childItems == null) ? new List<EUR_CRM_FilterBuilderService.ChildObjectFilterWrapper>() : parentFilter.childItems.values();
            for(EUR_CRM_FilterBuilderService.ChildObjectFilterWrapper cof: childFilters){
                addChildRelationshipName(fieldsByObjectName, cof);
                if(fieldsByObjectName.containsKey(cof.objectName)) {
                    fieldsByObjectName.get(cof.objectName).addAll(getFields(cof.items));
                } else {
                    fieldsByObjectName.put(cof.objectName, new Set<String>(getFields(cof.items)));
                }
            }
        }

        List<EUR_CRM_Cache__c> caches = [SELECT EUR_CRM_Object__c, EUR_CRM_Fields__c FROM EUR_CRM_Cache__c WHERE EUR_CRM_Object__c IN :fieldsByObjectName.keySet()];
        List<EUR_CRM_Cache__c> cachesForUpsert = new List<EUR_CRM_Cache__c>();
        for (EUR_CRM_Cache__c cache : caches) {
            Set<String> cacheFields = new Set<String>(cache.EUR_CRM_Fields__c.split(','));
            Set<String> newCacheFields = fieldsByObjectName.get(cache.EUR_CRM_Object__c);
            cacheFields.addAll(newCacheFields);
            cache.EUR_CRM_Fields__c = String.join(new List<String>(cacheFields),',');
            cachesForUpsert.add(cache);
            fieldsByObjectName.remove(cache.EUR_CRM_Object__c);
        }

        for(String objectName : fieldsByObjectName.keySet()){
            EUR_CRM_Cache__c cache = new EUR_CRM_Cache__c();
            cache.EUR_CRM_Object__c = objectName;
            cache.EUR_CRM_Fields__c = String.join(new List<String>(fieldsByObjectName.get(objectName)),',');
            cache.EUR_CRM_isFieldCache__c = true;
            cachesForUpsert.add(cache);
        }
        upsert cachesForUpsert;
    }

    private static void addChildRelationshipName(Map<String, Set<String>> fieldsByObjectName, EUR_CRM_FilterBuilderService.ChildObjectFilterWrapper cof) {
        if (fieldsByObjectName.containsKey(cof.objectName)) {
            fieldsByObjectName.get(cof.objectName).addAll(new Set<String>{cof.childRelationshipField});
        } else {
            fieldsByObjectName.put(cof.objectName, new Set<String>{cof.childRelationshipField});
        }

    }

    public static List<String> getFields(List<EUR_CRM_FilterBuilderService.FiltersItemsWrapper> items){
        List<String> strs = new List<String>();
        for (EUR_CRM_FilterBuilderService.FiltersItemsWrapper fiw : items) {
            strs.add(fiw.field);
        }
        return strs;
    }

    public static void addDailyRecalculation(List<SObject> groups) {
        List<SObject> dynamicGroups = new List<SObject>();
        for (SObject g : groups) {
            if (!String.isEmpty((String)g.get(FILTER_CRITERIA_STRING_FIELD_API_NAME))) {
                setIsDailyRecalculation(g);
            }
        }
    }

    public static void changeDynamicGroupMembers(List<SObject> groups, Map<Id, SObject> oldGroups) {
        if(groups.isEmpty()) return;

        List<SObject> dynamicGroups = new List<SObject>();
        EUR_CRM_DynamicGroupService.GroupType groupType = getGroupType(groups[0]);
        for (SObject g : groups) {
            SObject oldGroup = oldGroups.get(g.Id);
            if (((String) g.get(FILTER_CRITERIA_STRING_FIELD_API_NAME)) != ((String) oldGroup.get(FILTER_CRITERIA_STRING_FIELD_API_NAME))
//                        || ((String) g.get('Country__c')) != ((String) oldGroup.get('Country__c')) ||
//                    (groupType == EUR_CRM_DynamicGroupService.GroupType.PRODUCT && (((String) g.get('Brand__c')) != ((String) oldGroup.get('Brand__c'))))
                ) {
                dynamicGroups.add(g);
            }
        }
        addDynamicGroupMembers(dynamicGroups);
    }

    public static void changeDailyRecalculation(List<SObject> groups, Map<Id, SObject> oldGroups) {
        if(groups.isEmpty()) return;

        List<SObject> dynamicGroups = new List<SObject>();
        for (SObject g : groups) {
            SObject oldGroup = oldGroups.get(g.Id);
            if (((String) g.get(FILTER_CRITERIA_STRING_FIELD_API_NAME)) != ((String) oldGroup.get(FILTER_CRITERIA_STRING_FIELD_API_NAME))) {
                setIsDailyRecalculation(g);
            }
        }
    }

    private static void setIsDailyRecalculation(SObject g) {
        Boolean isDailyRecalculation = false;
        String criteria = (String) g.get(FILTER_CRITERIA_STRING_FIELD_API_NAME);
        for (String dateLiteral : EUR_CRM_FilterBuilderService.dateLiterals) {
            if (criteria != NULL && criteria.contains(dateLiteral)) {
                isDailyRecalculation = true;
                break;
            }
        }
        g.put('EUR_CRM_isDailyRecalculation__c', isDailyRecalculation);
    }

    public static EUR_CRM_FilterBuilderService.ParentObjectFilterWrapper getGroupFilter(SObject dynamicGroup) {
        EUR_CRM_FilterBuilderService.ParentObjectFilterWrapper parentFilter = null;
        String criteria = (String)dynamicGroup.get(FILTER_CRITERIA_STRING_FIELD_API_NAME);
        if(!String.isEmpty(criteria)) {
            try {
                parentFilter = (EUR_CRM_FilterBuilderService.ParentObjectFilterWrapper) JSON.deserialize(criteria, EUR_CRM_FilterBuilderService.ParentObjectFilterWrapper.class);
            } catch (Exception ex) {
                System.debug('GetGroupFilter Error: ' + ex.getMessage());
            }
        }
        return parentFilter;
    }

    public static String getFilterSelectionQuery(SObject dynamicGroup) {
        EUR_CRM_FilterBuilderService.ParentObjectFilterWrapper parentFilter =  getGroupFilter(dynamicGroup);
        if(parentFilter == null) return null;
        List<EUR_CRM_FilterBuilderService.ChildObjectFilterWrapper> childFilters =
            (parentFilter.childItems == null) ? new List<EUR_CRM_FilterBuilderService.ChildObjectFilterWrapper>() : parentFilter.childItems.values();

        String dynQuery = 'SELECT Id, Name';
        for (EUR_CRM_FilterBuilderService.ChildObjectFilterWrapper childFilter : childFilters) {
            if (childFilter.parentRelationType != CONTAINS_ALL_RELATION_TYPE) {
                dynQuery += ', (' + EUR_CRM_FilterBuilderService.buildChildSObjectFilterSelectionQuery(childFilter) + ')';
            }
        }
        dynQuery += ' FROM ' + parentFilter.objectName;
        dynQuery += ' WHERE ';
        String selectionQueryCondition = EUR_CRM_FilterBuilderService.getSelectionQueryCondition((EUR_CRM_FilterBuilderService.ObjectFilterWrapper)parentFilter);
        if(!String.isEmpty(selectionQueryCondition)) {
            dynQuery += '(' + getConditions(selectionQueryCondition) + ') ';
        }

        System.debug('\n\n dynamicGroup => ' + JSON.serializePretty(dynamicGroup) + '\n');
        if (dynamicGroup.get('RecordTypeId') != null) {
            Id rtId = Id.valueOf(String.valueOf(dynamicGroup.get('RecordTypeId')));
            String rtDevName = Schema.SObjectType.EUR_CRM_Account_Target_Group__c.getRecordTypeInfosById().get(rtId).getDeveloperName();
            System.debug('\n\n rtDevName => ' + JSON.serializePretty(rtDevName) + '\n');

            String countryCode = rtDevName.split('_')[1]; // EUR_AT_Account_Target_Group
            System.debug('\n\n countryCode => ' + JSON.serializePretty(countryCode) + '\n');
            if (dynQuery.endsWith('WHERE ')) {
                dynQuery += 'EUR_CRM_Country_Code__c = \'' + countryCode + '\'';
            } else {
                dynQuery += 'AND EUR_CRM_Country_Code__c = \'' + countryCode + '\'';
            }
        }

        System.debug('\n\n dynQuery => ' + JSON.serializePretty(dynQuery) + '\n');
        return dynQuery;
    }

    public static Boolean isChangedDynamicGroup(Sobject dynamicGroupInRAM, Sobject dynamicGroupInDB,  EUR_CRM_DynamicGroupService.GroupType groupType) {
        if((String)(dynamicGroupInRAM.get(FILTER_CRITERIA_STRING_FIELD_API_NAME)) != (String)(dynamicGroupInDB.get(FILTER_CRITERIA_STRING_FIELD_API_NAME))) {
            return true;
        }

        return false;
    }

    public static String getGroupMembersQuery(SObject dynamicGroup, GroupMembProcess process) {
        String groupMembersQuery;

        if(process == EUR_CRM_DynamicGroupService.GroupMembProcess.DELETING) {
            groupMembersQuery = getDeletingIrrelevantGroupMembersQuery(dynamicGroup);
        } else if(process == EUR_CRM_DynamicGroupService.GroupMembProcess.ADDING) {
            groupMembersQuery = getAddingRelevantGroupMembersQuery(dynamicGroup, getFilterSelectionQuery(dynamicGroup));
        }

        return groupMembersQuery;
    }

    private static String getAddingRelevantGroupMembersQuery(SObject dynamicGroup, String filterSelectionQuery) {
        if(String.isEmpty(filterSelectionQuery)) return null;
        String addingRelevantGroupMembersQuery = filterSelectionQuery + ' ' +
            'AND Id NOT IN(' + getJunctionSelectionQuery(dynamicGroup) +  ')';
        System.debug('addingRelevantGroupMembersQuery: ' + addingRelevantGroupMembersQuery);
        return addingRelevantGroupMembersQuery;
    }

    private static String getDeletingIrrelevantGroupMembersQuery(SObject dynamicGroup) {
        String deletingIrrelevantGroupMembersQuery = getJunctionSelectionQuery(dynamicGroup) +
            getAdditionalDelGroupMembersConditions(dynamicGroup);
        System.debug('deletingIrrelevantGroupMembersQuery: ' + deletingIrrelevantGroupMembersQuery);
        return deletingIrrelevantGroupMembersQuery;
    }

    private static String getJunctionSelectionQuery(SObject dynamicGroup) {
        String query = '' +
            'SELECT ' + EUR_CRM_DynamicGroupService.getJunctRelFieldName(dynamicGroup) + ' ' +
            'FROM ' + EUR_CRM_DynamicGroupService.getJunctionName(dynamicGroup) + ' ' +
            'WHERE ' + EUR_CRM_DynamicGroupService.getInstanceName(dynamicGroup) + ' = \'' + dynamicGroup.Id + '\'';
        return query;
    }

    public static String getAdditionalDelGroupMembersConditions(SObject dynamicGroup) {
        EUR_CRM_DynamicGroupService.GroupType groupType = getGroupType(dynamicGroup);
        String additionalDelGroupMembersConditions = '';
        if (groupType == EUR_CRM_DynamicGroupService.GroupType.ACCOUNT) {
            additionalDelGroupMembersConditions += ' AND EUR_CRM_Exclusion__c = false';
        }
        return additionalDelGroupMembersConditions;
    }

    public static void processGroupMembers(List<SObject> groupMembers, SObject dynamicGroup, GroupMembProcess process) {
        if(process == EUR_CRM_DynamicGroupService.GroupMembProcess.DELETING) {
            deleteIrrelevantGroupMembers(groupMembers, dynamicGroup);
        } else if(process == EUR_CRM_DynamicGroupService.GroupMembProcess.ADDING) {
            insertRelevantGroupMembers(groupMembers, dynamicGroup);
        }
    }

    private static void deleteIrrelevantGroupMembers(List<SObject> groupMembers, SObject dynamicGroup) {
        String lookupGroupfieldName = EUR_CRM_DynamicGroupService.getJunctRelFieldName(dynamicGroup);
//        Set<Id> groupMemberIds = EUR_CRM_AccountSharingService.getParentIds(groupMembers, lookupGroupfieldName);
        Set<Id> groupMemberIds = new Set<Id>();
        Set<Id> relevantGroupMembers = getRelevantGroupMembers(groupMemberIds, dynamicGroup);

        List<SObject> groupMembersForDelete = new List<SObject>();
        for(SObject groupMember : groupMembers) {
            if(!relevantGroupMembers.contains((Id)(groupMember.get(lookupGroupfieldName)))) {
                groupMembersForDelete.add(groupMember);
            }
        }
        delete groupMembersForDelete;
    }

    private static void insertRelevantGroupMembers(List<SObject> groupMembers, SObject dynamicGroup) {
        Set<Id> relevantGroupMembers = getRelevantGroupMembers(groupMembers, dynamicGroup);
        insertMembersOfGroup(relevantGroupMembers, dynamicGroup.Id);
    }

    public static Set<Id> getRelevantGroupMembers(Set<Id> groupMemberIds, SObject dynamicGroup) {
        String filterSelectionQuery = getFilterSelectionQuery(dynamicGroup);
        if(String.isEmpty(filterSelectionQuery)) return new Set<Id>();
        String query = filterSelectionQuery + ' AND Id IN :groupMemberIds';
        System.debug('RelevantGroupMembers Query: ' + query);
        List<SObject> groupMembers = Database.query(query);
        return getRelevantGroupMembers(groupMembers, dynamicGroup);
    }

    public static Set<Id> getRelevantGroupMembers(List<SObject> groupMembers, SObject dynamicGroup) {
        Map<Id, SObject> relevantGroupMembers = new Map<Id, SObject>(groupMembers)  ;

        EUR_CRM_FilterBuilderService.ParentObjectFilterWrapper parentFilter = getGroupFilter(dynamicGroup);
        if(parentFilter == null) return new Set<Id>();
        if(parentFilter.childItems == null || parentFilter.childItems.isEmpty()) return relevantGroupMembers.keySet();

        for (EUR_CRM_FilterBuilderService.ChildObjectFilterWrapper childFilter : parentFilter.childItems.values()) {
            Map<Id, Integer> filteredChildCountMap = getChildCountMap(relevantGroupMembers.keySet(), childFilter, true);
            Map<Id, Integer> allChildCountMap = getChildCountMap(relevantGroupMembers.keySet(), childFilter, false);

            for (Id groupMemberId : new Set<Id>(relevantGroupMembers.keySet())) {
                if(childFilter.parentRelationType == CONTAINS_RELATION_TYPE ) {
                    List<SObject> children = relevantGroupMembers.get(groupMemberId).getSObjects(childFilter.childRelationshipName);
                    if(children == null || children.isEmpty()) {
                        relevantGroupMembers.remove(groupMemberId);
                        continue;
                    }
                } else if(childFilter.parentRelationType == NOT_CONTAINS_RELATION_TYPE) {
                    List<SObject> children = relevantGroupMembers.get(groupMemberId).getSObjects(childFilter.childRelationshipName);
                    if(children != null && !children.isEmpty()) {
                        relevantGroupMembers.remove(groupMemberId);
                        continue;
                    }
                } else if(childFilter.parentRelationType == CONTAINS_ALL_RELATION_TYPE) {
                    Integer filteredChildCount = filteredChildCountMap.get(groupMemberId);
                    Integer allChildCount = allChildCountMap.get(groupMemberId);
                    if(allChildCount == null || filteredChildCount != allChildCount) {
                        relevantGroupMembers.remove(groupMemberId);
                        continue;
                    }
                }
            }
        }

        return relevantGroupMembers.keySet();
    }

    private static Map<Id, Integer> getChildCountMap(Set<Id> groupMemberIds, EUR_CRM_FilterBuilderService.ChildObjectFilterWrapper childFilter, Boolean isUsingFilter) {
        Map<Id, Integer> childCountMap = new Map<Id, Integer>();
        if(childFilter.parentRelationType != CONTAINS_ALL_RELATION_TYPE) return childCountMap;

        String childCountQuery =
            'SELECT COUNT(Id) quantity, ' + childFilter.childRelationshipField + ' ' +
                'FROM ' + childFilter.objectName + ' ' +
                'WHERE ' + childFilter.childRelationshipField + ' IN :groupMemberIds ' +
                (isUsingFilter ? 'AND (' + getConditions(EUR_CRM_FilterBuilderService.getSelectionQueryCondition((EUR_CRM_FilterBuilderService.ObjectFilterWrapper)childFilter)) + ') ' : '') +
                'GROUP BY ' + childFilter.childRelationshipField;

        System.debug('ChildCountQuery: ' + childCountQuery);

        for (AggregateResult aggRes : Database.query(childCountQuery)) {
            Id groupMemberId = (Id)aggRes.get(childFilter.childRelationshipField);
            Integer quantity = (Integer)aggRes.get('quantity');
            childCountMap.put(groupMemberId, quantity);
        }

        return childCountMap;
    }

    public static String getDynamicGroupQuery(EUR_CRM_DynamicGroupService.GroupType groupType, Set<Id> groupIds, Integer queryLimit) {
        String query =
            'SELECT Id, EUR_CRM_Criteria__c, LastModifiedDate, RecordTypeId ' +
                'FROM EUR_CRM_Account_Target_Group__c ' +
                 ' WHERE EUR_CRM_IsDynamic__c = true ' +
                ((groupIds == null || groupIds.isEmpty()) ? '' : ('AND Id IN (\'' + String.join( new List<Id>(groupIds), '\',\'') + '\') ')) +
                'ORDER BY LastModifiedDate DESC' +
                (queryLimit == null ? '' : (' ' + 'LIMIT ' + queryLimit));
        System.debug('DynamicGroupQuery: ' + query);
        return query;
    }

    public static String getGroupQuery(EUR_CRM_DynamicGroupService.GroupType groupType, Set<Id> groupIds, Integer queryLimit) {
        String query =
                'SELECT Id, EUR_CRM_Criteria__c, LastModifiedDate, RecordTypeId ' +
                        'FROM EUR_CRM_Account_Target_Group__c ' +
                        ((groupIds == null || groupIds.isEmpty()) ? '' : ('WHERE Id IN (\'' + String.join( new List<Id>(groupIds), '\',\'') + '\') ')) +
                        'ORDER BY LastModifiedDate DESC' +
                        (queryLimit == null ? '' : (' ' + 'LIMIT ' + queryLimit));
        System.debug('GroupQuery: ' + query);
        return query;
    }

    public static void updateDynGroupsByMemberChildren(List<SObject> records, Map<Id, sObject> oldMap) {
        if (records == null || records.isEmpty()) return;
        String childSObjectType = records[0].getSObjectType().getDescribe().getName();
        List<SObject> filteredRecords = records;
        if (oldMap != null) {
            filteredRecords = getRecordWhichInCache(records, oldMap);
        }
        List<EUR_CRM_Custom_List_View_Setting__mdt> parents = [
            SELECT EUR_CRM_Child_To_Parent_Relationship__c
            FROM EUR_CRM_Custom_List_View_Setting__mdt
            WHERE EUR_CRM_Child_Object__r.QualifiedApiName = :childSObjectType
        ];
        if (parents.isEmpty()) return;

        List<SObject> parentsForUpdate = new List<SObject>();
        for (EUR_CRM_Custom_List_View_Setting__mdt parent : parents) {
            Set<Id> parentIds = new Set<Id>();
            for(SObject record : filteredRecords) {
                Id newParent = (Id) record.get(parent.EUR_CRM_Child_To_Parent_Relationship__c);
                parentIds.add(newParent);
                if(oldMap != null) {
                    SObject oldRecord =  oldMap.get(record.Id);
                    Id oldParent = (Id) oldRecord.get(parent.EUR_CRM_Child_To_Parent_Relationship__c);
                    parentIds.add(oldParent);
                }
            }
            for (Id parentId : parentIds) {
                parentsForUpdate.add(parentId.getSobjectType().newSObject(parentId));
            }
        }

        updateDynamicGroups(parentsForUpdate);
    }

    private static List<SObject> getRecordWhichInCache(List<SObject> records, Map<Id, sObject> oldMap){
        List<SObject> filteredRecords = new List<SObject>();
        List<EUR_CRM_Cache__c> caches = [SELECT EUR_CRM_Object__c, EUR_CRM_Fields__c FROM EUR_CRM_Cache__c WHERE EUR_CRM_Object__c=:records[0].getSObjectType().getDescribe().getName()];
        if(caches.isEmpty()){
            return filteredRecords;
        }
        SObjectType sObjType = Schema.getGlobalDescribe().get(records[0].getSObjectType().getDescribe().getName());
        Set<String> allField = sObjType.getDescribe().fields.getMap().keySet();
        for(SObject sObj: records){
            List<String> changedFields = new List<String>();
            for(String f: allField){
                if(sObj.get(f)!=oldMap.get((Id)sObj.get('Id')).get(f)){
                    changedFields.add(f);
                }
            }
            for(String changedField: changedFields){
                if(caches[0].EUR_CRM_Fields__c.containsIgnoreCase(changedField)){
                    filteredRecords.add(sObj);
                    break;
                }
            }
        }
        return filteredRecords;
    }

    public static void updateDynamicGroups(List<SObject> records) {
        updateDynamicGroups(records, null);
    }

    public static void updateDynamicGroups(List<SObject> records, Map<Id, SObject> oldRecords) {
        List<SObject> filteredRecords = records;
        if (oldRecords != null && !records.isEmpty()) {
            filteredRecords = getRecordWhichInCache(records, oldRecords);
            System.debug('Review ERROR');
            System.debug('filteredRecords - ' + filteredRecords);
        }
        if(filteredRecords == null || filteredRecords.isEmpty()) return;
        List<SObject> recordsForUpdating = new List<SObject>();
        EUR_CRM_DynamicGroupService.GroupType groupType = EUR_CRM_DynamicGroupService.getGroupType(filteredRecords[0]);
        System.debug('Review ERROR');
        System.debug('groupType - ' + groupType);
        for (SObject record : filteredRecords) {
            SObject oldRecord = (oldRecords == null) ? null : oldRecords.get(record.Id);
            if (groupType == EUR_CRM_DynamicGroupService.GroupType.ACCOUNT) {
                recordsForUpdating.add(record);
                continue;
            }
//            if (groupType == EUR_CRM_DynamicGroupService.GroupType.PRODUCT) {
//                if (
//                    ((Boolean)record.get('CTCPG__IsActive__c')) == True ||
//                        (oldRecord != null && ((Boolean)oldRecord.get('CTCPG__IsActive__c')) == True) ||
//                        ((Id)record.get('RecordTypeId')) == COMPANY_PRODUCT_RT_ID ||
//                        (oldRecord != null && ((Id)oldRecord.get('RecordTypeId')) == COMPANY_PRODUCT_RT_ID)
//                    ) {
//                    recordsForUpdating.add(record);
//                    continue;
//                }
//            }
        }
        if(!recordsForUpdating.isEmpty()) {
            System.debug('Review ERROR');
            System.debug('recordsForUpdating - ' + recordsForUpdating);
            new EUR_CRM_DynGroupMembChangingBatch(groupType).scheduleBatch(recordsForUpdating);
        }
    }

    public static String getMembChangingSelectingQuery(EUR_CRM_DynamicGroupService.GroupType groupType, Set<Id> groupMemberIds, Integer queryLimit) {
        String query =
            'SELECT Id, LastModifiedDate ' +
                'FROM EUR_CRM_Account__c ' +
                'WHERE ' +
                ((groupMemberIds == null || groupMemberIds.isEmpty()) ? '' :
                    ('Id IN (\'' + String.join( new List<Id>(groupMemberIds), '\',\'') + '\') ')) +
                    'AND Id NOT IN(SELECT EUR_CRM_Account__c FROM EUR_CRM_Account_in_Target_Group__c WHERE EUR_CRM_Exclusion__c = true) ' +
                'ORDER BY LastModifiedDate DESC' +
                (queryLimit == null ? '' : (' ' + 'LIMIT ' + queryLimit));
        System.debug('MembChangingSelectingQuery: ' + query);
        return query;
    }

    public static void processGroupMembersChanging(List<SObject> groupMembers, List<SObject> dynamicGroups) {
        if(groupMembers == null || groupMembers.isEmpty() || dynamicGroups == null || dynamicGroups.isEmpty()) return;
        Set<Id> groupMemberIds = new Map<Id, SObject>(groupMembers).keySet();

        List<SObject> junctionGroupMembersForInsert = new List<SObject>();
        List<SObject> junctionGroupMembersForDelete = new List<SObject>();
        for (SObject dynamicGroup : dynamicGroups) {
            Set<Id> relevantGroupMemberIds  = getRelevantGroupMembers(groupMemberIds, dynamicGroup);
            Map<Id, SObject> existingJunctionByGroupMemberId = getExistingJunctionByGroupMemberId(dynamicGroup, groupMemberIds);

            for(SObject groupMember : groupMembers) {
                if(relevantGroupMemberIds.contains(groupMember.Id) && !existingJunctionByGroupMemberId.keySet().contains(groupMember.Id)) {
                    junctionGroupMembersForInsert.addAll(getRecordsInGroup(dynamicGroup.Id, new Set<Id> {groupMember.Id}));
                } else if (!relevantGroupMemberIds.contains(groupMember.Id) && existingJunctionByGroupMemberId.keySet().contains(groupMember.Id)) {
                    junctionGroupMembersForDelete.add(existingJunctionByGroupMemberId.get(groupMember.Id));
                }
            }
        }
        insert junctionGroupMembersForInsert;
        delete junctionGroupMembersForDelete;
    }

    private static Map<Id, SObject> getExistingJunctionByGroupMemberId(SObject dynamicGroup, Set<Id> groupMembersIds) {
        String query = getJunctionSelectionQuery(dynamicGroup) +
            ' AND ' + EUR_CRM_DynamicGroupService.getJunctRelFieldName(dynamicGroup) + ' IN :groupMembersIds';
        List<SObject> junctions = Database.query(query);
        Map<Id, SObject> existingJunctionByGroupMemberId = new Map<Id, SObject>();
        for (SObject junction : junctions) {
            existingJunctionByGroupMemberId.put((Id)junction.get(EUR_CRM_DynamicGroupService.getJunctRelFieldName(dynamicGroup)), junction);
        }
        return existingJunctionByGroupMemberId;
    }

    public static void processRefreshGroup(List<SObject> dynamicGroups){
        new EUR_CRM_DynGroupMembBatch(getGroupType(dynamicGroups[0])).scheduleBatch(dynamicGroups);
    }


    /* ========================================================= */
    /*     Middle Level Helpers
    /* ========================================================= */
    private static List<SObject> extractDynamicGroups(List<SObject> groups) {
        List<SObject> dynamicGroups = new List<SObject>();
        for (SObject g : groups) {
            if ( !isFilterCriteriaStringEmpty(g)) {
                dynamicGroups.add(g);
            }
        }
        return dynamicGroups;
    }


    /* ========================================================= */
    /*     Low Level Helpers
    /* ========================================================= */

    private static String getFilterCriteriaString(SObject g) {
        return (String)g.get(FILTER_CRITERIA_STRING_FIELD_API_NAME);
    }

    private static Boolean isFilterCriteriaStringEmpty(SObject g) {
        return String.isEmpty(getFilterCriteriaString(g));
    }


//    public static void populateDLIAccLookup(List<Deliverylineitem__c> records) {
//        Set<Id> orderIds = AccountSharingService.getParentIds(records, 'OrderID__c');
//        Map<Id, SalesOrder__c> orders = new Map<Id, SalesOrder__c>([
//            SELECT AccountID__c FROM SalesOrder__c WHERE Id IN :orderIds
//        ]);
//        populateDLIAccLookup(records, orders);
//    }
//
//    private static void populateDLIAccLookup(List<Deliverylineitem__c> records, Map<Id, SalesOrder__c> orders) {
//        for(Deliverylineitem__c record : records) {
//            SalesOrder__c order = orders.get(record.OrderID__c);
//            if(order != null && order.AccountID__c != null) {
//                record.AccountID__c = order.AccountID__c;
//            }
//        }
//    }

//    public static void populateDLIAccLookup(List<Deliverylineitem__c> records, Map<Id, Deliverylineitem__c> oldRecords) {
//        List<Deliverylineitem__c> filteredRecords = new List<Deliverylineitem__c>();
//        for (Deliverylineitem__c record : records) {
//            Deliverylineitem__c oldRecord = oldRecords.get(record.Id);
//            if (record.OrderID__c != oldRecord.OrderID__c ) {
//                filteredRecords.add(record);
//            }
//        }
//        if (filteredRecords.isEmpty()) return;
//        populateDLIAccLookup(filteredRecords);
//    }

//    public static void populateDLIAccLookup(List<SalesOrder__c> records, Map<Id, SalesOrder__c> oldRecords) {
//        List<SalesOrder__c> filteredRecords = new List<SalesOrder__c>();
//        for (SalesOrder__c record : records) {
//            SalesOrder__c oldRecord = oldRecords.get(record.Id);
//            if (record.AccountID__c != oldRecord.AccountID__c ) {
//                filteredRecords.add(record);
//            }
//        }
//        if (filteredRecords.isEmpty()) return;
//        List<Deliverylineitem__c> dlis = [SELECT OrderID__c FROM Deliverylineitem__c WHERE OrderID__c IN : filteredRecords];
//
//        populateDLIAccLookup(dlis, new Map<Id, SalesOrder__c>(filteredRecords));
//        update dlis;
//    }

}