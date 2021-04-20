public with sharing class EUR_CRM_RoleUtils {
   
   
   public static Set<ID> getRoleSubordinateUsers(Id userId) {

    // get requested user's role
       List<User> userRoles = [select UserRoleId from User where Id = :userId];
       Id roleId = userRoles.isEmpty() ? null : userRoles[0].UserRoleId;
    // get all of the roles underneath the user
    Set<Id> allSubRoleIds = getAllSubRoleIds(new Set<ID>{roleId});
    // get all of the ids for the users in those roles
    Map<Id,User> users = new Map<Id, User>([Select Id, Name From User where 
      UserRoleId IN :allSubRoleIds]);
    // return the ids as a set so you can do what you want with them
    return users.keySet();

  } 
  public static Set<ID> getRoleSubordinateUsers(Set<Id> usersId) {

    // get requested user's role
    Set<Id> roleIds = new Set<Id>();
    for(User u : [select UserRoleId from User where Id in:usersId]){
        roleIds.add(u.UserRoleId);
    } 
    // get all of the roles underneath the user
    Set<Id> allSubRoleIds = getAllSubRoleIds(roleIds);
    // get all of the ids for the users in those roles
    Map<Id,User> users = new Map<Id, User>([Select Id, Name From User where 
      UserRoleId IN :allSubRoleIds]);
    // return the ids as a set so you can do what you want with them
    return users.keySet();

  }
 
   public static Set<ID> getRoleSubordinateUsers(String roleDevName) {

    // get requested user's role
    Id roleId = [select id from UserRole where Developername =: roleDevName].id;
    // get all of the roles underneath the user
    Set<Id> allSubRoleIds = getAllSubRoleIds(new Set<ID>{roleId});
    // get all of the ids for the users in those roles
    Map<Id,User> users = new Map<Id, User>([Select Id, Name From User where 
      UserRoleId IN :allSubRoleIds]);
    // return the ids as a set so you can do what you want with them
    return users.keySet();

  }

  private static Set<ID> getAllSubRoleIds(Set<ID> roleIds) {

    Set<ID> currentRoleIds = new Set<ID>();

    // get all of the roles underneath the passed roles
    for(UserRole userRole :[select Id from UserRole where ParentRoleId 
      IN :roleIds AND ParentRoleID != null])
    currentRoleIds.add(userRole.Id);

    // go fetch some more rolls!
    if(currentRoleIds.size() > 0) {
        currentRoleIds.addAll(getAllSubRoleIds(currentRoleIds));        
    }

    return currentRoleIds;

  }
  
  public static List<User> getUsers(Set<Id> salesRepsId){
    List<User> salesReps = [select name, id from User where id in: salesRepsId];
    return salesReps;
  }
}