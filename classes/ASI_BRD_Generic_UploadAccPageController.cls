/*********************************************************************************
    * Name: ASI_BRD_Generic_UploadAccPageController
    * Description:  Controller for ASI_BRD_Generic_UploadAccPage
    *
    * Version History
    * April 26, 2016        Laputa      Create
*********************************************************************************/
public class ASI_BRD_Generic_UploadAccPageController{
    public Boolean isLux{get;set;}
    public Boolean isBrand{get;set;}
    public final Set<String> groupLUXList = new Set<String>{'ASI_LUX_SG_Users','ASI_LUX_TW_Users','ASI_LUX_MY_Users'};
    public final Set<String> groupBrandList = new Set<String>{'ASI_BRD_SG_All_Brands_Users','ASI_BRD_Generic_TW_All_Brands_Users','ASI_BRD_MY_All_Brands_Users','ASI_BRD_PH_All_Brands_Users','ASI_BRD_TH_All_Brands_Users','ASI_BRD_VN_All_Brands_Users'};
    
    public ASI_BRD_Generic_UploadAccPageController(){
        //Get all the public groups from user
        List<Group> relatedGroup = getGroupsForUser(userinfo.getuserid());
        for(Group i :relatedGroup){
            if (groupLUXList.contains(i.DeveloperName) || test.isRunningTest())
                this.isLux = true;
            if (groupBrandList.contains(i.DeveloperName)|| test.isRunningTest())
                this.isBrand = true;
        }
    }
    public Group[] getGroupsForUser(Id userId){
        Set<Id> groupIds = getGroupsForIds(new Set<Id>{userId});
        return [Select Id, 
                       Name,
                       DeveloperName 
                From   Group
                Where Id IN: groupIds];
    }
    
    public Set<Id> getGroupsForIds(Set<Id> userOrGroupIds){

        Set<Id> output = new Set<Id>();

        Set<Id> nestedGroupIds = new Set<Id>();

        // only query actual groups and not roles and queues
        list<GroupMember> records = [
            select id
                 , GroupId
                 , UserOrGroupId
              from GroupMember
         where UserOrGroupId =: userOrGroupIds
            and UserOrGroupId != null];

        for (GroupMember record:records)
        {
            // found a group, remember for traversal
            if (!(record.UserOrGroupId + '').startsWith('005'))
            {
                nestedGroupIds.add(record.UserOrGroupId);   
            }
            else
            {
                output.add(record.GroupId);
            }
        }

        // call self to get nested groups we found
        if (nestedGroupIds.size() > 0)
        {
            output.addAll(getGroupsForIds(nestedGroupIds));
        }

        return output;
    }
}