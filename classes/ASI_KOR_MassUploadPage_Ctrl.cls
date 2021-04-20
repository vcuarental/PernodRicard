/**********************************************************************************
 * Name : ASI_KOR_MassUploadPage_Ctrl 
 * Created : Vincent Lam
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 2018-12-13       Laputa: Vincent         created, in order to determine the role of user
 * 2018-12-18       Alan Lau                added System Administrator checking
 * 2019-06-03       Wilson Chow             added IT Admin checking
 **********************************************************************************/
public class ASI_KOR_MassUploadPage_Ctrl {
    public Boolean isTMKT {get;set;}
    public Boolean isBMKT {get;set;}
    public Boolean isAdmin {get;set;}
    public Boolean isItAdmin {get;set;} // 20190603 Wilson Chow add

    private static final String GROUP_TMKT = 'ASI_CRM_KR_TMKT_Users';
    private static final String GROUP_BMKT = 'ASI_CRM_KR_BMKT_Users';
    private static final String ADMIN_PROFILE_NAME = 'System Administrator';
    private static final String GROUP_IT_ADMIN = 'ASI_KOR_IT_Admin';

    public ASI_KOR_MassUploadPage_Ctrl(){
        identifyUserGroup();
        isAdmin = isAdmin(UserInfo.getProfileId());
    }

    private void identifyUserGroup(){
        String userId = UserInfo.getUserId();
        isTMKT = checkIfUserIsInGroup(userId, GROUP_TMKT);
        isBMKT = checkIfUserIsInGroup(userId, GROUP_BMKT);
        isItAdmin = checkIfUserIsInGroup(userId, GROUP_IT_ADMIN);
    }

    private Boolean isAdmin(String userProfileId) {
        Boolean isAdmin = false;
        Profile profile = [SELECT Name FROM Profile WHERE Id = :userProfileId];

        if (ADMIN_PROFILE_NAME.equals(profile.Name)) {
            isAdmin = true;
        }

        return isAdmin;
    }

    private Boolean checkIfUserIsInGroup(String userId, String groupName){
        List<GroupMember> list_gm = retrieveGroupMemberList(userId, groupName);
        if(list_gm.size()>0){
            return true;
        }
        return false;
    }

    private List<GroupMember> retrieveGroupMemberList(String userId, String groupName){
        return [
            SELECT Id
            FROM
            	GroupMember
            WHERE
            	GroupId IN (
                	SELECT Id FROM Group WHERE DeveloperName = :groupName
                )
            	AND UserOrGroupId = :userId
        ];
    }
}