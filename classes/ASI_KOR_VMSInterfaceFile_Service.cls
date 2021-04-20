/*********************************************************************************
 * Name:ASI_KOR_VMSInterfaceFile_Service
 * Description: Service Class for KOR VMS interface file
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 2018-04-24		Vincent lam             Created
*********************************************************************************/
public class ASI_KOR_VMSInterfaceFile_Service {
    
    private static ASI_KOR_VMSInterfaceFile_Service VMSINTERFACEFILE_SERVICE = new ASI_KOR_VMSInterfaceFile_Service();
    
	private static final String ADMINGROUP = 'ASI_KOR_IT_Admin';
    
    //Not Allow to create instance
    private ASI_KOR_VMSInterfaceFile_Service() { 
    }
    
    public static ASI_KOR_VMSInterfaceFile_Service getInstance() {
		return VMSINTERFACEFILE_SERVICE;
	}
  
	public void validationVMSSyncFlag(List<ASI_KOR_VMS_Interface_File__c> list_i){
		Boolean canEditVMSFlag = false;
		Id userId = UserInfo.getUserId();
				
		List<GroupMember> groupMemberList = [SELECT groupID, userOrGroupID FROM groupMember 
			WHERE GroupID in (SELECT ID FROM Group WHERE DeveloperName = :ADMINGROUP)];
			
		for (GroupMember m:groupMemberList){
			if (userId == m.userOrGroupID){
				canEditVMSFlag = true;
			}
		}
		
		if(!canEditVMSFlag && !Test.isRunningTest()){
			for(ASI_KOR_VMS_Interface_File__c i : list_i){
				i.addError('You are not able to change the VMS Sync flag.');
			}
		}
		
	}
}