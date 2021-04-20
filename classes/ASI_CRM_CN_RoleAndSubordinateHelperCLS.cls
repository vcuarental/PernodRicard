public without sharing class ASI_CRM_CN_RoleAndSubordinateHelperCLS {
    
    Private Static Map<Id, UserRole> mapRole = new Map<Id, UserRole>([SELECT Id, ParentRoleId, DeveloperName FROM UserRole WHERE DeveloperName LIKE '%CN_%' OR DeveloperName LIKE 'ASI_CN' OR DeveloperName LIKE '%FOC_%' OR DeveloperName LIKE 'ASI_ATR_%' OR DeveloperName LIKE 'ASI_DFPM_%']);
    Private Static List<User> allCNUsers = new List<User>([SELECT Id, ManagerId, UserRoleId, ASI_CRM_Sales_Team__c, ASI_MFM_Team__c FROM User WHERE isActive = TRUE AND (CompanyName = 'Pernod Ricard China' OR UserRole.DeveloperName LIKE 'ASI_ATR_%' OR UserRole.DeveloperName LIKE 'ASI_DFPM_%')]);
    Private Static Map<Id, Set<User>> userInRole = new Map<Id, Set<User>>();
    Private Static Map<Id, Set<UserRole>> mapChildRole = new Map<Id, Set<UserRole>>();
    Private Static Map<Id, UserRole> mapUserRole = new Map<Id, UserRole>();
    Private Static Map<Id, User> mapUser = new Map<Id, User>();
    
    Static{
        
        for(User Obj : allCNUsers){
            
            if(mapRole.containsKey(obj.UserRoleId)){
                
                Set<User> tmpSet = new Set<User>();
                
                if(userInRole.containsKey(obj.UserRoleId)){
                    
                    tmpSet = userInRole.get(obj.UserRoleId);
                }
                tmpSet.add(obj);
                
                userInRole.put(obj.UserRoleId, tmpSet);
                mapUserRole.put(obj.Id, mapRole.get(obj.UserRoleId));
                mapUser.put(obj.Id, obj);
            }
        }
        
        for(UserRole obj : mapRole.values()){
            
            Set<UserRole> tmpSet = new Set<UserRole>();
            
            if(mapChildRole.containsKey(obj.ParentRoleId)){
                tmpSet = mapChildRole.get(obj.ParentRoleId);
            }
            
            tmpSet.add(obj);
            mapChildRole.put(obj.ParentRoleId, tmpSet);
        }
    }
    
    Public Static UserRole getParentRole(Id roleId){
        
        if(mapRole.containsKey(roleId) && mapRole.containsKey(mapRole.get(roleId).ParentRoleId)){
            Return mapRole.get(mapRole.get(roleId).ParentRoleId);
        }
        
        Return NULL;
    }
    
    Public Static Set<User> getAllUsersInRole(Id roleId){
        
        if(userInRole.containsKey(roleId)){
            Return userInRole.get(roleId);
        }
        
        Return NULL;
    }
    
    Public Static Set<UserRole> getChildRole(Id roleId){
        
        if(mapChildRole.containsKey(roleId)){
            Return mapChildRole.get(roleId);
        }
        
        Return NULL;
    }
    
    Public Static UserRole getUserRole(Id userId){
        
        if(mapUserRole.containsKey(userId)){
            Return mapUserRole.get(userId);
        }
        
        Return NULL;
    }
    
    Public Static User getUser(Id userId){
        
        if(mapUser.containsKey(userId)){
            Return mapUser.get(userId);
        }
        
        Return NULL;
    }
}