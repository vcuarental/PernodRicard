public with sharing class ASI_TH_CRM_PaymentRequestAutoNumber extends ASI_HK_CRM_TriggerAbstract {
    
    public ASI_TH_CRM_PaymentRequestAutoNumber() {
        super('ASI_TH_CRM_PaymentRequestAutoNumber');
    }
    
    public override void executeTriggerAction(TriggerAction tAction, List<sObject> sObjList, Map<ID, sObject> newMap, Map<ID, sObject> oldMap) {
        if ((tAction == TriggerAction.BEFORE_INSERT)
            && !isBypassByCurrentUser()) {
            List<ASI_TH_CRM_PaymentRequest__c > soList = (List<ASI_TH_CRM_PaymentRequest__c >)sObjList;
            Map<id, ASI_TH_CRM_Contract__c> contractMap = new Map<id, ASI_TH_CRM_Contract__c>();
            Set<Id> contractIds = new Set<Id>();
            Set<Id> oultetIds = new Set<Id>();
            Set<String> vendorNos = new Set<String>();
            Map<String, id> customerNoAccountMap = new Map<String, id>();
            Map<id, String> accountVendorNoMap = new Map<id, String>();
            Set<Id> SupplerIds = new Set<Id>();
            Map<Id, String> SupplierVATMap = new Map<Id, String>();
            
            for (ASI_TH_CRM_PaymentRequest__c so : soList) {
                contractIds.add(so.ASI_TH_CRM_Contract__c);
                //System.debug('Contact ID:' +   so.ASI_TH_CRM_Contract__c);
                //System.debug('Outlet ID:' +   so.ASI_TH_CRM_Contract__r.ASI_TH_CRM_Outlet__c);              
                //oultetIds.add(so.ASI_TH_CRM_Contract__r.ASI_TH_CRM_Outlet__c);
                //vendorNos.add(so.ASI_TH_CRM_Contract__r.ASI_TH_CRM_Outlet__r.ASI_TH_CRM_VendorNo__c);
            }
            for (ASI_TH_CRM_Contract__c contract : [Select ASI_TH_CRM_Outlet__r.ownerid, ASI_TH_CRM_Outlet__c, 
                ASI_TH_CRM_Outlet__r.owner.ManagerId,
                ASI_TH_CRM_Outlet__r.owner.Manager.ManagerId,
                ASI_TH_CRM_Outlet__r.owner.Manager.Manager.ManagerId,
                ASI_TH_CRM_Outlet__r.owner.Manager.Manager.Manager.ManagerId
                From ASI_TH_CRM_Contract__c WHERE id in :contractIds]){
                contractMap.put(contract.id, contract);
            }
            
            for (ASI_TH_CRM_PaymentRequest__c so : soList) {                              
                oultetIds.add(contractMap.get(so.ASI_TH_CRM_Contract__c).ASI_TH_CRM_Outlet__c);                
            }
            for (ASI_CRM_AccountsAdditionalField__c accountsAdditionalField : [SELECT ASI_CRM_Account__c, ASI_TH_CRM_VendorNo__c From ASI_CRM_AccountsAdditionalField__c
            WHERE ASI_CRM_Account__c in :oultetIds]){
                //System.Debug('Vendor No:' + accountsAdditionalField.ASI_TH_CRM_VendorNo__c);
                accountVendorNoMap.put(accountsAdditionalField.ASI_CRM_Account__c, accountsAdditionalField.ASI_TH_CRM_VendorNo__c);
            }
            
            for (ASI_TH_CRM_PaymentRequest__c so : soList) {                
                vendorNos.add(accountVendorNoMap.get(contractMap.get(so.ASI_TH_CRM_Contract__c).ASI_TH_CRM_Outlet__c));
            }
            
            for (Account account : [SELECT id, ASI_KOR_Customer_Code__c 
            FROM account WHERE ASI_KOR_Customer_Code__c in :vendorNos
            AND ASI_KOR_Customer_Code__c != null
            AND ASI_KOR_Customer_Code__c != '' 
            AND RecordType.DeveloperName = 'ASI_TH_CRM_Supplier']){
                SupplerIds.add(account.id);
                customerNoAccountMap.put(account.ASI_KOR_Customer_Code__c, account.id);
            }
                
            //Vincent@20170227 Populate VAT from Supplier
            for (ASI_CRM_AccountsAdditionalField__c SupplierAdditionalFields : [SELECT ASI_CRM_Account__c, ASI_CRM_CN_Tax_Number__c From ASI_CRM_AccountsAdditionalField__c
            WHERE ASI_CRM_Account__c in :SupplerIds]){
                if (SupplierAdditionalFields.ASI_CRM_CN_Tax_Number__c!=null) {
                    SupplierVATMap.put(SupplierAdditionalFields.ASI_CRM_Account__c, String.valueOf(SupplierAdditionalFields.ASI_CRM_CN_Tax_Number__c.intValue())+'%');
                }
            }
            ASI_HK_CRM_AutoNumberAssignment autoNumAssign = new ASI_HK_CRM_AutoNumberAssignment('ASI_TH_CRM_PaymentRequest__c');
            for (ASI_TH_CRM_PaymentRequest__c so : soList) {
                if(so.ASI_TH_PR_No_Data_Migration__c != null && so.ASI_TH_PR_No_Data_Migration__c != '')
                    so.Name = so.ASI_TH_PR_No_Data_Migration__c;
                else
                    so.Name = autoNumAssign.nextAutoNumStr();
                
                so.ASI_TH_CRM_RequestBy__c = UserInfo.getUserId();
                //Remarked by William as error occurs during UAT
                //so.OwnerId = ((Account)[Select ownerid From Account WHERE id = :so.ASI_TH_CRM_Outlet__c]).ownerid;
                                
                ASI_TH_CRM_Contract__c contract = contractMap.get(so.ASI_TH_CRM_Contract__c);
                
                so.OwnerId = contract.ASI_TH_CRM_Outlet__r.ownerid;
                if (contract.ASI_TH_CRM_Outlet__r.owner.ManagerId != null)
                    so.ASI_TH_CRM_Regional_Sales_Manager__c = contract.ASI_TH_CRM_Outlet__r.owner.ManagerId;
                if (contract.ASI_TH_CRM_Outlet__r.owner.Manager.ManagerId != null)
                    so.ASI_TH_CRM_Head_of_National_On_Trade__c = contract.ASI_TH_CRM_Outlet__r.owner.Manager.ManagerId;
                if (contract.ASI_TH_CRM_Outlet__r.owner.Manager.Manager.ManagerId != null)
                    so.ASI_TH_CRM_Head_of_Finance_Operations__c = contract.ASI_TH_CRM_Outlet__r.owner.Manager.Manager.ManagerId;
                if (contract.ASI_TH_CRM_Outlet__r.owner.Manager.Manager.Manager.ManagerId != null)
                    so.ASI_TH_CRM_Managing_Director__c = contract.ASI_TH_CRM_Outlet__r.owner.Manager.Manager.Manager.ManagerId;
                
                String customerNo = accountVendorNoMap.get(contractMap.get(so.ASI_TH_CRM_Contract__c).ASI_TH_CRM_Outlet__c);
                //System.Debug('customerNo:' + customerNo);
                //System.Debug('Vendor SFDC id' + customerNoAccountMap.get(customerNo));
                if (customerNo != null)
                    so.ASI_TH_CRM_Vendor__c = customerNoAccountMap.get(customerNo);
                	so.ASI_TH_CRM_VAT__c = SupplierVATMap.get(customerNoAccountMap.get(customerNo));
            }
            autoNumAssign.writeToDB();
        }
    }

}