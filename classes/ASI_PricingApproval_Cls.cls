global without sharing class ASI_PricingApproval_Cls{
    webservice static boolean checkVoidPermission(){
        list<GroupMember> gms = [SELECT Id FROM GroupMember WHERE Group.DeveloperName='ASI_Pricing_Team' AND UserOrGroupId = :UserInfo.getUserId()];
        if(gms.size()>0)
            return true;
        else
            return false;
    }
}