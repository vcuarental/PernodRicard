/*
+-----------------------+------------------------------------------------------------------------------------+
| Author                | Cécile Lartaud                                                                     |
+-----------------------+------------------------------------------------------------------------------------+
| Description           |                                                                                    |
|                       |                                                                                    |
|     - Object(s)       | External User Requests                                                             |
|     - Description     | Let the PR Employee to manage customers of private groups he is Owner of.                      |
+-----------------------+------------------------------------------------------------------------------------+
| Creation Date         | 18/12/2012                                                                         |
+-----------------------+------------------------------------------------------------------------------------+
| Modifications         |                                                                                    |
+-----------------------+------------------------------------------------------------------------------------+
| Governor informations |                                                                                    |
+-----------------------+------------------------------------------------------------------------------------+
*/
public class EXT_USR_RQT_ManageExtUsersCON {

    /*############################################################################
    #   A.T.T.R.I.B.U.T.E.S
    ##############################################################################*/
        // Return the list of customers of the given group ID 
    public Map<Id,List<User>> map_usrGroup_listExtUsr {get;set;}
        
        // List of all private groups with customers of the current user
    public List<CollaborationGroup> list_userPrivateGroupsWithCustomers {get;set;}
    
        // Return the object related to the given ID 
    public Map<Id,User> map_UserId_ExtUsers {get;set;}
    public Map<Id,CollaborationGroup> map_GroupId_CollabGroup {get;set;}
    
        // Return the CollaborationGroupMember related to the key string, builded by concatenate the selected group ID and the selected user ID
    public Map<String,CollaborationGroupMember> map_keyGroupUsr_CollaborationGrpMember {get;set;}
        
        // Store IDs of the selected group and the selected user
    public String extUsrSelectedID {get;set;}    
    public String groupSelectedID {get;set;}   
    
    public String msg {get;set;}
    
    /*############################################################################
    #   C.O.N.S.T.R.U.C.T.O.R
    ##############################################################################*/
    public EXT_USR_RQT_ManageExtUsersCON() {
        /* Instanciate */
        List<Id> listMemberIds = new List<Id>();
        map_UserId_ExtUsers = new Map<Id,User>();
        map_GroupId_CollabGroup = new Map<Id,CollaborationGroup>();
        list_userPrivateGroupsWithCustomers = new List<CollaborationGroup>();
        map_keyGroupUsr_CollaborationGrpMember = new Map<String,CollaborationGroupMember>();
        String uid = UserInfo.getUserId();
        
        /* Query all privates groups with customers where the current user is Owner. Then build the map getter. */    
        List<CollaborationGroup> listUsrGroup = [SELECT Name,Id FROM CollaborationGroup WHERE Id IN (SELECT CollaborationGroupId FROM CollaborationGroupMember WHERE MemberId = :uid AND CollaborationRole = 'admin') AND CanHaveGuests = true AND CollaborationType = 'Private'];
        // Build a map to return the full object when give it an ID.
        for(CollaborationGroup var : listUsrGroup){
            map_GroupId_CollabGroup.put(var.Id, var);
        }
        
        /* Query all collaboration members associated to groups queried below. Then build the map getter. */    
        List<CollaborationGroupMember> listMembers = [SELECT CollaborationGroupId, MemberId FROM CollaborationGroupMember WHERE CollaborationGroupId IN : listUsrGroup];
        // Build a map to return the full object when give it the right key. The key is builded by concatenate the group ID and the member ID. 
        for(CollaborationGroupMember item : listMembers){
            listMemberIds.add(item.MemberId);
            String key = ''+item.CollaborationGroupId+item.MemberId;
            map_keyGroupUsr_CollaborationGrpMember.put(key, item);
        }
                
        /* Query all collaboration members associated to groups queried below. Then build the map getter. */  
        List<User> listExtUsers = [SELECT Id, Name, CompanyName, EXT_USR_RQT_Expiration_Status__c,EXT_USR_RQT_Expiration_Date__c FROM User WHERE Id IN :listMemberIds AND ProfileId =: EXT_USR_Config__c.getOrgDefaults().EXT_USR_RQT_External_Profile_Id__c];
        // Build a map to return the full object when give it the User ID.
        for(User var : listExtUsers){
            map_UserId_ExtUsers.put(var.Id, var);
        }
        
        /* Build the map used to display the table of customers for each group. */  
        buildRelationUsrGroup2ExtUsr(listMembers, map_UserId_ExtUsers);
    }
    
    /*############################################################################
    #   M.E.T.H.O.D.S
    ##############################################################################*/  
    
    /*
     * Build the map used to display the table of customers for each group.
     * - The key is the Group ID. 
     * - The value is a list of customers who are members of the group. 
     ***/
    public void buildRelationUsrGroup2ExtUsr(List<CollaborationGroupMember> listGroupMember, Map<Id,User> map_UserId_ExtUsers){
        map_usrGroup_listExtUsr = new Map<Id,List<User>>();
        
        for(CollaborationGroupMember var : listGroupMember){  
            if(map_UserId_ExtUsers.containsKey(var.MemberId)){  
                        // the Member is a customer.
                if(map_usrGroup_listExtUsr.containsKey(var.CollaborationGroupId)){
                        // This group has been already added to the map -> get its list of customers, add it the current then update the map element. 
                    List<User> listChild = map_usrGroup_listExtUsr.get(var.CollaborationGroupId);                            
                    listChild.add(map_UserId_ExtUsers.get(var.MemberId));                
                    map_usrGroup_listExtUsr.put(var.CollaborationGroupId, listChild);
                } else {
                        // This group is treated for the first time -> Add it to the list of groups, create a new list with the current customer inside, then put the element in the map.
                    list_userPrivateGroupsWithCustomers.add(map_GroupId_CollabGroup.get(var.CollaborationGroupId));
                    List<User> listChild = new List<User>();                        
                    listChild.add(map_UserId_ExtUsers.get(var.MemberId));                
                    map_usrGroup_listExtUsr.put(var.CollaborationGroupId, listChild);
                }
            }
        }
    }
    
    /*
     * Extends the expiration date of the current customer for a period defined by the default expiration duration.
     ***/
    public Pagereference renewUser() {
        // Get the user and update the fields.
        User usrToRenew = map_UserId_ExtUsers.get(extUsrSelectedID);
        usrToRenew.EXT_USR_RQT_Expiration_Date__c = DateTime.now()+ EXT_USR_Config__c.getOrgDefaults().EXT_USR_RQT_Expiry_Duration__c ;
        usrToRenew.EXT_USR_RQT_Expiration_Status__c = 'Active';
        
        try{
            // Update the User
            update usrToRenew;
        } catch (Exception ex) {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, ex.getTypeName()+': '+ex.getMessage()+'. Cause :'+ex.getCause()+'.');
            ApexPages.addMessage(myMsg);
        }
        return null;
    }
    
    /*
     * Remove the current customer from the current group. do not desactive it.
     ***/
    public Pagereference removeUser() {
        // Generate the key then get the CollaborationGroupMember.
        String key = '' + groupSelectedID + extUsrSelectedID;
        CollaborationGroupMember userToDeleteGroup = map_keyGroupUsr_CollaborationGrpMember.get(key);
        try{
            delete userToDeleteGroup;
            // Remove the User from the map.
            removeUser2Map(groupSelectedID, extUsrSelectedID);
            groupSelectedID = '';
            extUsrSelectedID = '';
        } catch (Exception ex) {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, ex.getTypeName()+': '+ex.getMessage()+'. Cause :'+ex.getCause()+'.');
            ApexPages.addMessage(myMsg);
        }
        return null;
    }
    
    /*
     * Remove the selected user to the selected group in the main map.
     ***/
    public void removeUser2Map(String groupSelectId, String userSelectId){
        List<User> oldlistChild = map_usrGroup_listExtUsr.get(groupSelectId);
        List<User> newlistChild = new List<User>();
        
        for(User var : oldlistChild) {
            if(var.Id != userSelectId)
                newlistChild.add(var);
        }
        map_usrGroup_listExtUsr.put(groupSelectId, newlistChild);
    }
}