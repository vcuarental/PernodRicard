@isTest
Private class ASI_CRM_CN_RoleAndSubordinateCLS_Test {
    
    Private static User tempU = [select id, userRoleId from user where CompanyName = 'Pernod Ricard China' limit 1];
    
    static testMethod void testHelperClass(){
        
        test.startTest();
        
        ASI_CRM_CN_RoleAndSubordinateHelperCLS.getAllUsersInRole(tempU.userRoleId);
        ASI_CRM_CN_RoleAndSubordinateHelperCLS.getAllUsersInRole(tempU.userRoleId);
        ASI_CRM_CN_RoleAndSubordinateHelperCLS.getChildRole(tempU.userRoleId);
        ASI_CRM_CN_RoleAndSubordinateHelperCLS.getParentRole(tempU.userRoleId);
        ASI_CRM_CN_RoleAndSubordinateHelperCLS.getUserRole(tempU.Id);
        
        test.stopTest();
    }
}