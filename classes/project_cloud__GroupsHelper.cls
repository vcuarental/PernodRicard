/*
This file is generated and isn't the actual source code for this
managed global class.
This read-only file shows the class's global constructors,
methods, variables, and properties.
To enable code to compile, all methods return null.
*/
global class GroupsHelper {
    global Map<Id,Set<Id>> groupsUsers {
        get;
    }
    global Map<Id,Set<Id>> roleSubordinateUsers {
        get;
    }
    global Map<Id,Set<Id>> roleUsers {
        get;
    }
    global Map<Id,Set<Id>> usersGroups {
        get;
    }
    global GroupsHelper() {

    }
    global void refresh(Boolean refreshRoles, Boolean refreshGroups) {

    }
    global void refreshGroups() {

    }
    global void refreshRoles() {

    }
global class GroupsException extends Exception {
}
}
