/*
  @Company:     IP-Converge Data Services, Inc.
  @Description: Enable or Remove Read/Write Apex sharing of the Account to Sales Agency
  @Author:      IPC
  @History:     AUG.8.2014 - Created

  2017.JAN.19 Exit if no record to process
*/
public class EUR_CRM_DE_SalesAgencyAccountHandler  extends EUR_CRM_TriggerAbstract {
    
    private static Set<String> offTradeRecordTypeSet = new Set<String>{
        'EUR_DE_OFF_STD'
    };
    
    private static Set<String> offTradeNorthEastRole = new Set<String>{
        'EUR_DE_Regional_Sales_Manager_Off_Trade_North_East',
        'EUR_DE_BZL_Nord_East',
        'EUR_DE_OFF_Sales_Agency_Nord_East'
    };
    
    private static Set<String> offTradeSouthRole = new Set<String>{
        'EUR_DE_Regional_Sales_Manager_Off_Trade_South',
        'EUR_DE_BZL_South',
        'EUR_DE_OFF_Sales_Agency_South'
    };
    
    private static Set<String> offTradeWestRole = new Set<String>{
        'EUR_DE_Regional_Sales_Manager_Off_Trade_West',
        'EUR_DE_BZL_West',
        'EUR_DE_OFF_Sales_Agency_West'
    };
    
    public static Set<String> TargetRecordSet {
        get{
            Set<String> TRt = new Set<String>();
            TRt.addAll(offTradeRecordTypeSet);
            TRt.addAll(offTradeNorthEastRole);
            TRt.addAll(offTradeSouthRole);
            TRt.addAll(offTradeWestRole);

            return TRt;
        }private set;
    }

    public EUR_CRM_DE_SalesAgencyAccountHandler(){
        super('EUR_CRM_DE_SalesAgencyAccountHandler');
    }
    
    public override void executeTriggerAction(TriggerAction tAction, List<sObject> sObjList, Map<ID, sObject> newMap, Map<ID, sObject> oldMap){

        Map<String, Id> grpRoleMap = new Map<String, Id>();
        for(Group grp :[SELECT Id, RelatedId, DeveloperName, Type FROM Group Where Type = 'Role'
                        AND DeveloperName like '%Sales_Agency%']){
            grpRoleMap.put(grp.DeveloperName, grp.Id);
        }
        
        Set<Id> euAccountIds = new Set<Id>();
        List<EUR_CRM_Account__Share> euAccountToShare = new List<EUR_CRM_Account__Share>();
        for(EUR_CRM_Account__c acc :[Select Id, Name, EUR_CRM_Territory__r.EUR_CRM_Region__r.Owner.UserRole.developerName, 
                                        EUR_CRM_Territory__r.EUR_CRM_Region__r.Owner.UserRoleId, EUR_CRM_Status_of_Customer__c
                                        From EUR_CRM_Account__c Where Id IN :newMap.keySet()
                                        AND RecordType.developerName IN :offTradeRecordTypeSet]){
            if(acc.EUR_CRM_Territory__r.EUR_CRM_Region__r.Owner.UserRoleId != null
                && acc.EUR_CRM_Status_of_Customer__c == 'Agency Managed'){
                
                system.debug('***: ' + acc.Name);
                system.debug('***: ' + acc.EUR_CRM_Territory__r.EUR_CRM_Region__r.Owner.UserRole.developerName);
                euAccountIds.add(acc.Id);
                
                //North / East
                if(offTradeNorthEastRole.contains(acc.EUR_CRM_Territory__r.EUR_CRM_Region__r.Owner.UserRole.developerName)){
                    euAccountToShare.add(createEUAcctShare(acc.Id, grpRoleMap.get('EUR_DE_OFF_Sales_Agency_Nord_East')));
                }
                //South
                if(offTradeSouthRole.contains(acc.EUR_CRM_Territory__r.EUR_CRM_Region__r.Owner.UserRole.developerName)){
                    euAccountToShare.add(createEUAcctShare(acc.Id, grpRoleMap.get('EUR_DE_OFF_Sales_Agency_South')));
                }
                //West
                if(offTradeWestRole.contains(acc.EUR_CRM_Territory__r.EUR_CRM_Region__r.Owner.UserRole.developerName)){
                    euAccountToShare.add(createEUAcctShare(acc.Id, grpRoleMap.get('EUR_DE_OFF_Sales_Agency_West')));
                }
            }else if(Trigger.IsUpdate && acc.EUR_CRM_Status_of_Customer__c != 'Agency Managed' &&
                      acc.EUR_CRM_Status_of_Customer__c != ((EUR_CRM_Account__c ) oldMap.get(acc.id)).EUR_CRM_Status_of_Customer__c ){
                 system.debug('++ ');
                 euAccountIds.add(acc.Id);
            }
        }
        
     if(euAccountIds.size() > 0){   
            //Delete existing sharing
            List<EUR_CRM_Account__Share> euAcctSharelistDelete = new List<EUR_CRM_Account__Share>();
            Map<Id, Group> grpRole = new Map<Id, Group>([Select Id, Name From Group Where Type = 'Role' 
                                                                AND DeveloperName like '%Sales_Agency%']);
            for(EUR_CRM_Account__Share aShare :[Select Id, ParentId, UserOrGroupId
                                                From EUR_CRM_Account__Share
                                                Where ParentId IN: euAccountIds
                                                AND UserOrGroupId IN: grpRole.keySet()]){
                euAcctSharelistDelete.add(aShare);
            }
            
            if(euAcctSharelistDelete.size() > 0){
                system.debug('*** delete: ' + euAcctSharelistDelete);
                delete euAcctSharelistDelete;
            }
         }   
        if(euAccountToShare.size() > 0){
            //Add Sharing
            system.debug('***: ' + euAccountToShare);
            insert euAccountToShare;
        }
    }
    
    private EUR_CRM_Account__Share createEUAcctShare(Id euAccId, Id userOrGroupId){
        EUR_CRM_Account__Share teamMember = new EUR_CRM_Account__Share();
        teamMember.AccessLevel = 'Edit';
        teamMember.ParentId = euAccId;
        teamMember.UserOrGroupId = userOrGroupId;
        return teamMember;
    }
}