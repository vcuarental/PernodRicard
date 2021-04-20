public without sharing class EUR_CRM_AccountSharingService {

    public static Set<Id> getParentIds(List<SObject> sObjects, String parentFieldName) {
        Set<Id> parentIds = new Set<Id>();
        if(sObjects == null || sObjects.isEmpty() || String.isEmpty(parentFieldName)) return parentIds;
        for(SObject sObj : sObjects) {
            Id parentId = (Id) sObj.get(parentFieldName);
            if(parentId != null) parentIds.add(parentId);
        }
        return parentIds;
    }

}