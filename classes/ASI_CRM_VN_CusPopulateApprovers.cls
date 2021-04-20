/*********************************************************************************
 * Name: ASI_CRM_VN_CusPopulateApprovers
 * Test: ASI_CRM_VN_CusPopulateApproversTest
 * Description: It is handler class for trigger 'ASI_CRM_AccountsAdditionalField_BeforeInsert'
 *              The method populateSysApproverFields() populates 3 fields Sys Approver 1, Sys Approver 2, Sys Approver 3 
 *              of Customer record
 *
 * Version History
 * Date                Developer             Comments
 * ---------------  --------------------  --------------------------------------------------------------------------------
 * 29/10/2015         Neha Sonawane         Created
 * 01/17/2018         Vincent Kwok          Updated, Revamp approval process to support new COA structure
 * 
*********************************************************************************/


public class  ASI_CRM_VN_CusPopulateApprovers{
     
    public void populateSysApproverFields(List<ASI_CRM_AccountsAdditionalField__c> lstCustomers){
        Set<String> RSD_APPROVAL_SERVICE_PACK = new Set<String>{'Iconic', 'Leading', 'Premium'};
        Set<String> NSD_APPROVAL_SERVICE_PACK = new Set<String>{'Iconic', 'Leading'};
        Set<String> OFF_TRADE_RECORD_DEVELOPER_NAME = new Set<String>{'ASI_CRM_VN_Off_Trade_Outlet', 'ASI_CRM_VN_Inactive_Off_Trade_Outlet'};
        Set<String> ON_TRADE_RECORD_DEVELOPER_NAME = new Set<String>{'ASI_CRM_VN_Outlet', 'ASI_CRM_VN_Outlet_Inactive'};
        Set<String> ExcludeRoleSet =new Set<String>{'ASI VN Managing Director', 'PR Holding'};

        
         //Logic to populate Sys Approver 1, Sys Approver 2, Sys Approver 3     
        set<Id> setOwnerId = new set<Id>();//set to store ownerId of Customer records
        Set<Id> setCustId = new Set<Id>();//set to store current customer Id

        //Get all Vietnam Users
        map<Id,User> mapIdUserVN = new map<Id,User>([select Id, ManagerId, UserRoleId, Userrole.Name, Manager.Userrole.Name from User where UserRole.DeveloperName LIKE 'ASI_VN%']);
        map<Id,String> mapCustRecType = new map<Id,String>();
        
        //Populate set with Customer ownerId
        for(ASI_CRM_AccountsAdditionalField__c objCustomer : lstCustomers){
            setOwnerId.add(objCustomer.OwnerId);//Add Owner Id in set
            setCustId.add(objCustomer.Id);//Add Cust Id in Set
        }
        
        List<ASI_CRM_AccountsAdditionalField__c> listCust = [select Id, RecordType.DeveloperName from ASI_CRM_AccountsAdditionalField__c where Id IN :setCustId];
        for(ASI_CRM_AccountsAdditionalField__c idx : listCust) {
            mapCustRecType.put(idx.id, idx.RecordType.DeveloperName);
        }

        for(ASI_CRM_AccountsAdditionalField__c objCustomer : lstCustomers){
            //Clear Approver 1, Approver 2, Approver 3
            objCustomer.ASI_CRM_CN_Sys_Approver_1__c = null;
            objCustomer.ASI_CRM_CN_Sys_Approver_2__c = null;
            objCustomer.ASI_CRM_CN_Sys_Approver_3__c = null;
            if (mapIdUserVN != null && mapIdUserVN.containsKey(objCustomer.ownerId)) {
                if(!String.isBlank(String.valueOf(mapIdUserVN.get(objCustomer.ownerId).ManagerId))){ //Line Manager
                    String Approver1 = mapIdUserVN.get(objCustomer.ownerId).ManagerId;
                    objCustomer.ASI_CRM_CN_Sys_Approver_1__c = mapIdUserVN.get(objCustomer.ownerId).ManagerId;
                                  
                    if (mapIdUserVN != null && mapIdUserVN.containsKey(Approver1)) {                   
                        if(String.isNotBlank(Approver1) && ((mapIdUserVN.get(Approver1).Manager.Userrole.Name != Label.ASI_CRM_VN_RoleName && RSD_APPROVAL_SERVICE_PACK.contains(objCustomer.ASI_CRM_CN_New_Image__c) && ON_TRADE_RECORD_DEVELOPER_NAME.contains(mapCustRecType.get(objCustomer.Id))) || (mapIdUserVN.get(Approver1).Manager.Userrole.Name != Label.ASI_CRM_VN_RoleName && OFF_TRADE_RECORD_DEVELOPER_NAME.contains(mapCustRecType.get(objCustomer.Id))))){ //CDP > LM > RSD > NSD
                               String Approver2 = mapIdUserVN.get(Approver1).ManagerId;
                               objCustomer.ASI_CRM_CN_Sys_Approver_2__c = mapIdUserVN.get(Approver1).ManagerId;
                               
                               if (mapIdUserVN != null && mapIdUserVN.containsKey(Approver2) && !ExcludeRoleSet.contains((mapIdUserVN.get(Approver2).Manager.Userrole.Name)) ) {
                                   if(String.isNotBlank(Approver2) && ((mapIdUserVN.get(Approver2).Manager.Userrole.Name != Label.ASI_CRM_VN_RoleName && RSD_APPROVAL_SERVICE_PACK.contains(objCustomer.ASI_CRM_CN_New_Image__c) && ON_TRADE_RECORD_DEVELOPER_NAME.contains(mapCustRecType.get(objCustomer.Id))) || (mapIdUserVN.get(Approver2).Manager.Userrole.Name != Label.ASI_CRM_VN_RoleName && OFF_TRADE_RECORD_DEVELOPER_NAME.contains(mapCustRecType.get(objCustomer.Id))))){
                                          String Approver3 = mapIdUserVN.get(Approver2).ManagerId;
                                          objCustomer.ASI_CRM_CN_Sys_Approver_3__c = mapIdUserVN.get(Approver2).ManagerId;
                                          
                                    }else if (String.isNotBlank(Approver2) && ( mapIdUserVN.get(Approver2).Manager.Userrole.Name == Label.ASI_CRM_VN_RoleName && NSD_APPROVAL_SERVICE_PACK.contains(objCustomer.ASI_CRM_CN_New_Image__c) && ON_TRADE_RECORD_DEVELOPER_NAME.contains(mapCustRecType.get(objCustomer.Id)))) {
                                        objCustomer.ASI_CRM_CN_Sys_Approver_3__c = mapIdUserVN.get(Approver2).ManagerId;
                                        
                                    }
                               }
                        }else if (String.isNotBlank(Approver1) && mapIdUserVN.get(Approver1).Manager.Userrole.Name == Label.ASI_CRM_VN_RoleName && NSD_APPROVAL_SERVICE_PACK.contains(objCustomer.ASI_CRM_CN_New_Image__c) && ON_TRADE_RECORD_DEVELOPER_NAME.contains(mapCustRecType.get(objCustomer.Id))){ //CDP > RSD > NSD
                            
                            objCustomer.ASI_CRM_CN_Sys_Approver_2__c = mapIdUserVN.get(Approver1).ManagerId;
                        }
                    }
                }
            }
		}
	}
}