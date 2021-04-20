public without sharing class ASI_CRM_EOL_TriggerClass {
    
    public static void executeBeforeUpdateTriggerAction(List<ASI_CRM_EOL__c> trigger_new, map<id, ASI_CRM_EOL__c> trigger_oldMap){
        
        for (ASI_CRM_EOL__c eol : trigger_new){
            if(eol.ASI_CRM_Status__c == 'Open'){
                
                for(Integer i = 1 ; i <= 20 ; i ++){
                    String fieldStr = 'ASI_CRM_Receiver_' + i + '__c';
                    eol.put(fieldStr, NULL);
                }
                
                if(eol.ASI_CRM_Approver_1__c==null && eol.ASI_CRM_Marketing_Contact__c!=null){
                    eol.ASI_CRM_Approver_1__c=getBrandDirectorIdFromOwnerId(eol.ASI_CRM_Marketing_Contact__c);
                }else if(eol.ASI_CRM_Approver_1__c == NULL){//20160321 Ben @ Elufa
                    eol.ASI_CRM_Approver_1__c=getBrandDirectorIdFromOwnerId(UserInfo.getUserId());
                }
                if(eol.ASI_CRM_Approver_1__c==null){
                    eol.ASI_CRM_Approver_1__c=getPublicGroupUserIDByGroupName('ASI CN NPL Brand Director Approvers');
                }
                // Approver 2
                if(eol.ASI_CRM_Approver_2__c==null){
                    eol.ASI_CRM_Approver_2__c=getPublicGroupUserIDByGroupName('ASI CN NPL Marketing Director');
                }
                // Approver 3
                if(eol.ASI_CRM_Approver_3__c==null){
                    eol.ASI_CRM_Approver_3__c=getPublicGroupUserIDByGroupName('ASI CN NPL Trade Marketing Director');
                }
                // Approver 4
                if(eol.ASI_CRM_Approver_4__c==null){
                    eol.ASI_CRM_Approver_4__c=getPublicGroupUserIDByGroupName('ASI CN NPL National Sales Dev VP');
                }
                // Approver 5
                if(eol.ASI_CRM_Approver_5__c==null){
                    eol.ASI_CRM_Approver_5__c=getPublicGroupUserIDByGroupName('ASI CN NPL Finance Director');
                }
                // Approver 6
                if(eol.ASI_CRM_Approver_6__c==null){
                    eol.ASI_CRM_Approver_6__c=getPublicGroupUserIDByGroupName('ASI CN NPL Deputy Managing Director');
                }
                
                //20160418 Ben @ Elufa
                Set<ID> subordinateID = new Set<ID>();
                
                List<UserRole> requestByRoleName = new List<UserRole>();
                if(ASI_CRM_CN_RoleAndSubordinateHelperCLS.getUserRole(eol.ASI_CRM_Approver_1__c) != NULL)
                    requestByRoleName.add(ASI_CRM_CN_RoleAndSubordinateHelperCLS.getUserRole(eol.ASI_CRM_Approver_1__c));
                
                if(requestByRoleName.size() > 0){
                    
					if (eol.ASI_CRM_Approver_1__c != NULL){
                        subordinateID = getRoleSubordinateUsers(eol.ASI_CRM_Approver_1__c, true);
                    }
                }
                if(subordinateID != null && subordinateID.size()>0){
                    
                    for (Id u : subordinateID){
                        if (eol.ASI_CRM_Receiver_1__c == null)
                            eol.ASI_CRM_Receiver_1__c = u;
                        
                        else if (eol.ASI_CRM_Receiver_2__c == null)
                            eol.ASI_CRM_Receiver_2__c = u;
                        
                        else if (eol.ASI_CRM_Receiver_3__c == null)
                            eol.ASI_CRM_Receiver_3__c = u;
                        
                        else if (eol.ASI_CRM_Receiver_4__c == null)
                            eol.ASI_CRM_Receiver_4__c = u;
                        
                        else if (eol.ASI_CRM_Receiver_5__c == null)
                            eol.ASI_CRM_Receiver_5__c = u;
                        
                        else if (eol.ASI_CRM_Receiver_6__c == null)
                            eol.ASI_CRM_Receiver_6__c = u;
                        
                        else if (eol.ASI_CRM_Receiver_7__c == null)
                            eol.ASI_CRM_Receiver_7__c = u;
                        
                        else if (eol.ASI_CRM_Receiver_8__c == null)
                            eol.ASI_CRM_Receiver_8__c = u;
                        
                        else if (eol.ASI_CRM_Receiver_9__c == null)
                            eol.ASI_CRM_Receiver_9__c = u;
                        
                        else if (eol.ASI_CRM_Receiver_10__c == null)
                            eol.ASI_CRM_Receiver_10__c = u;
                        
                        else if (eol.ASI_CRM_Receiver_11__c == null)
                            eol.ASI_CRM_Receiver_11__c = u;
                        
                        else if (eol.ASI_CRM_Receiver_12__c == null)
                            eol.ASI_CRM_Receiver_12__c = u;
                        
                        else if (eol.ASI_CRM_Receiver_13__c == null)
                            eol.ASI_CRM_Receiver_13__c = u;
                        
                        else if (eol.ASI_CRM_Receiver_14__c == null)
                            eol.ASI_CRM_Receiver_14__c = u;
                        
                        else if (eol.ASI_CRM_Receiver_15__c == null)
                            eol.ASI_CRM_Receiver_15__c = u;
                        
                        else if (eol.ASI_CRM_Receiver_16__c == null)
                            eol.ASI_CRM_Receiver_16__c = u;
                        
                        else if (eol.ASI_CRM_Receiver_17__c == null)
                            eol.ASI_CRM_Receiver_17__c = u;
                        
                        else if (eol.ASI_CRM_Receiver_18__c == null)
                            eol.ASI_CRM_Receiver_18__c = u;
                        
                        else if (eol.ASI_CRM_Receiver_19__c == null)
                            eol.ASI_CRM_Receiver_19__c = u;
                        
                        else if (eol.ASI_CRM_Receiver_20__c == null)
                            eol.ASI_CRM_Receiver_20__c = u;
                    }
                }
                //20160418 End
                
                //  Approver 1  ASI_CRM_Marketing_Contact__c
                // if(eol.ASI_CRM_Approver_1__c==null && eol.OwnerID!=null){
                //     eol.ASI_CRM_Approver_1__c=getBrandDirectorIdFromOwnerId(eol.OwnerID);
            }
        }
    }
    
    private static Set<ID> getRoleSubordinateUsers(Id userId,boolean userFlag) {
        // get requested user's role
        Id roleId =NULL;
        if(userFlag)
            roleId = ASI_CRM_CN_RoleAndSubordinateHelperCLS.getUserRole(userId) != NULL ? ASI_CRM_CN_RoleAndSubordinateHelperCLS.getUserRole(userId).Id : NULL;
        else
            roleId = userId;
        
        // get all of the roles underneath the user
        Set<Id> allSubRoleIds = getAllSubRoleIds(new Set<ID>{roleId});
        // get all of the ids for the users in those roles
        Map<Id,User> users = new Map<Id, User>();
        List<User> userList = new List<User>();
        for(Id subRoleId : allSubRoleIds){
            if(ASI_CRM_CN_RoleAndSubordinateHelperCLS.getAllUsersInRole(subRoleId) != NULL)
            	userList.addAll(ASI_CRM_CN_RoleAndSubordinateHelperCLS.getAllUsersInRole(subRoleId));
        }
        
        for(user obj : userList){
            users.put(obj.id, obj);
        }
        //Modified by Wilken on 20130911, add Brand Director for notification
        if(userFlag){
            if(ASI_CRM_CN_RoleAndSubordinateHelperCLS.getUser(userId) != NULL){
                User approver = ASI_CRM_CN_RoleAndSubordinateHelperCLS.getUser(userId);
                users.put(approver.Id, approver);
            }
        }
        //End modification on 20130911
        
        // return the ids as a set so you can do what you want with them
        return users.keySet();
        
    }
    
    private static Set<ID> getAllSubRoleIds(Set<ID> roleIds) {
        Set<ID> currentRoleIds = new Set<ID>();
        Set<userRole> currentRole = new Set<userRole>();
        for(Id roleId : roleIds){
            if(ASI_CRM_CN_RoleAndSubordinateHelperCLS.getChildRole(roleId) != NULL){
                currentRole.addAll(ASI_CRM_CN_RoleAndSubordinateHelperCLS.getChildRole(roleId));
            }
        }
        // get all of the roles underneath the passed roles
        for(UserRole userRole : currentRole)
            currentRoleIds.add(userRole.Id);
        
        // go fetch some more rolls!
        if(currentRoleIds.size() > 0)
            currentRoleIds.addAll(getAllSubRoleIds(currentRoleIds));
        
        return currentRoleIds;
        
    }
    
    private static Id getPublicGroupUserIDByGroupName(String name){
        String userType = Schema.SObjectType.User.getKeyPrefix();
        Group publicGroup = [Select Id From Group Where Name = :name Limit 1];
        GroupMember member = [Select UserOrGroupId From GroupMember Where GroupId = :publicGroup.Id Limit 1];
        if (((String)member.UserOrGroupId).startsWith(userType)){
            return member.UserOrGroupId;
        }
        else {
            return null;
        }
    }
    
    private static Id getBrandDirectorIdFromOwnerId(Id ownerId){
        String userType = Schema.SObjectType.User.getKeyPrefix();
        List<User> nplOwner = [Select Id, ManagerId From User Where Id = :ownerId];
        Group approverGroup = [Select Id From Group Where DeveloperName = 'ASI_CN_NPL_Brand_Director_Approvers'];
        Boolean result = false;
        Id brandDirectorId;
        Id supervisorID = getSupervisorID(ownerId);
        if (nplOwner.size() == 1){
            for (GroupMember m : [Select Id, UserOrGroupId From GroupMember Where GroupId = :approverGroup.Id]){
                if (((String)m.UserOrGroupId).startsWith(userType)){
                    if (m.UserOrGroupId == supervisorID){
                        result = true;
                        brandDirectorId = supervisorID;
                    }
                }
            }
            if (result == false){
                brandDirectorId = getBrandDirectorIdFromOwnerId(supervisorID);
            }
        }
        return brandDirectorId;
    }
    
    private static Id getSupervisorID(Id ownerId){
        if(ownerId==null)
            return null;
        User u = [Select UserRoleId From User Where Id = :ownerId Limit 1];
        List<UserRole> ur = [Select ParentRoleId From UserRole Where Id = :u.UserRoleId];
        ID result;
        if (ur.size() == 1){
            List<User> su = [Select Id From User Where UserRoleId = :ur.get(0).ParentRoleId];
            if (su.size() >= 1){
                result = su.get(0).Id;
            }else{
                
                List<UserRole> ur2 = [Select ParentRoleId From UserRole Where Id = :ur.get(0).ParentRoleId];
                
                if(ur2.size() == 1){
                    List<User> su2 = [Select Id From User Where UserRoleId = :ur2.get(0).ParentRoleId];
                    
                    if (su2.size() >= 1){
                        result = su2[0].Id;
                    }
                }
            }
        }
        return result;
    }
}