public class ASI_CRM_SG_Outlet_P_L_See_ThroughCtrl {
	@AuraEnabled
    public static Boolean checkPermission(){
       // try{
        String sysAdminId = [Select Id, Name from Profile where Name = 'System Administrator'].Id;
        List<GroupMember> grpm = [select id from GroupMember where UserOrGroupId= : UserInfo.getUserId() and groupid in (select id from Group where developername='ASI_CRM_SG_Access_Management_Report')];
        if(UserInfo.getProfileId() == sysAdminId || ( grpm != null && grpm.size()>0)){
            system.debug('here');
            return true;
        }else{
            return false;
        }
       /* }catch(Exception e){
            return false;
        }*/
    }
}