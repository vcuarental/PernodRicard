trigger PJ_ByFor_Experience_BeforeInsert on PJ_ByFor_Experience__c (before insert) {
	Map<Id,String> owners = new Map<Id,String>();
    for(PJ_ByFor_Experience__c c:trigger.new)
        owners.put(c.OwnerId,'');
    
    Map<Id, Group> groupMap = new Map<Id, Group>([Select Id, DeveloperName, Name From Group Where DeveloperName like 'PJ_ByFor_Brand_Company_%']);
    List<GroupMember> groupMembers = [ Select GroupId, UserOrGroupId From GroupMember Where GroupId In :groupMap.keySet() and UserOrGroupId=:owners.keySet()];
    for (GroupMember m : groupMembers)
        if(owners.containsKey(m.UserOrGroupId) && owners.get(m.UserOrGroupId) == '')
            owners.put(m.UserOrGroupId,groupMap.get(m.GroupId).DeveloperName);
    
    for(PJ_ByFor_Experience__c c:trigger.new)
        if(owners.containsKey(c.ownerId) && owners.get(c.OwnerId) != '')
			c.PJ_ByFor_Tech_Owner_Company__c = owners.get(c.OwnerId);
}