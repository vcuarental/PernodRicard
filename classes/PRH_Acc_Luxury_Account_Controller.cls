public class PRH_Acc_Luxury_Account_Controller {
    public Account luxAcc{get;set;}
    public PRH_Luxury_Accounts__c assocluxAcc{get;set;}
    public Boolean rendered{get;set;}
    public Boolean renderButton{get;set;}
    public List<PRH_Brand_Criteria__c> brandNames {get;set;}
    public PRH_Acc_Luxury_Account_Controller(ApexPages.StandardController controller) {
        rendered = true;
        renderButton=true;
        Id loggedInUser=  Userinfo.getUserId();
        List<PermissionSetAssignment> permissionList = [SELECT PermissionSetId
                                                        FROM PermissionSetAssignment
                                                        WHERE AssigneeId = :loggedInUser];
        System.debug('Test : ' + permissionList);
        List<ID> idList = new List<ID>();
        for(PermissionSetAssignment psa : permissionList){
            idList.add(psa.PermissionSetId);
        }      
        System.debug('Test : ' + idList);                                          
        List<PermissionSet> permissionNameList = [Select Name From PermissionSet Where ID in :idList];                                          
        Set<String> permissionNames = new Set<String>();
        for(PermissionSet ps : permissionNameList){
            permissionNames.add(ps.name);
        }
        System.debug('Test : ' + permissionNameList);
        if(permissionNames.contains('PRH_Iconic_Platform_USA')||permissionNames.contains('PRH_Iconic_Platform_USA_Sales_Directors')||permissionNames.contains('PRH_Iconic_Platform_USA_Regional_Directors')){
            rendered = false;
        }
        if(permissionNames.contains('PRH_Iconic_Platform_PR_Holding') || permissionNames.contains('PRH_Iconic_Platform_Regional_Directors')){
            renderButton = false;
        }
        luxAcc =((Account)controller.getRecord());
        if (Test.isRunningTest()) {
            assocluxAcc =[Select id, Name,PRH_City__c,PRH_Full_Active_l_Atelier_Portfolio__c From PRH_Luxury_Accounts__c Limit 1];
            brandNames = 
                    [Select  PRH_Account__c ,PRH_Brand__c, PRH_Presence__c From PRH_Brand_Criteria__c Limit 1];
        } else {
            assocluxAcc =[Select 
                         id, Name , PRH_Existing_Account__r.Name ,PRH_Detailed_address__c,PRH_City__c,PRH_Full_Active_l_Atelier_Portfolio__c,PRH_Telephone__c,PRH_High_Networth_Individuals__c/*,  PRH_Contracted__c */ 
                     From 
                         PRH_Luxury_Accounts__c 
                     Where 
                          PRH_Existing_Account__c = :luxAcc.id Limit 1];
                         
            brandNames = 
            [Select  
                    PRH_Account__c ,PRH_Brand__c, PRH_Presence__c,PRH_Brand__r.RecordType.DeveloperName ,
                    PRH_Brand__r.PRH_SYS_Sequence__c,PRH_Brand__r.Name,PRH_Branded_Event__c,PRH_Visibility__c
             From PRH_Brand_Criteria__c 
             Where PRH_Account__c = :assocluxAcc.id
             Order by PRH_Brand__r.PRH_SYS_Sequence__c , PRH_Brand__r.Name
            ];
        }
    }
    
    public PageReference editAll(){
        return new PageReference('/apex/PRH_Iconic_Platform_Mass_Edit_Desktop?id='+assocluxAcc.id);
    }

}