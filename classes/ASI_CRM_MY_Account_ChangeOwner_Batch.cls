global class ASI_CRM_MY_Account_ChangeOwner_Batch implements Database.Batchable<sObject>{
    private set<Id> s_change_owner_customer {set; get;}
    
    
    global ASI_CRM_MY_Account_ChangeOwner_Batch(set<Id> s_change_owner_customer){
        this.s_change_owner_customer = s_change_owner_customer;
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        if(s_change_owner_customer.size() > 0){
            return Database.getQueryLocator([
                SELECT Id, OwnerId
                FROM ASI_CRM_AccountsAdditionalField__c
                WHERE RecordType.DeveloperName LIKE '%ASI_CRM_MY%'
                AND Id IN :s_change_owner_customer
            ]);   
        }
        else{
            return null;
        }
    }
    
    
    global void execute(Database.BatchableContext BC, List<ASI_CRM_AccountsAdditionalField__c> scope) {
        
        system.debug('@@@s_change_owner_customer: '+s_change_owner_customer);
        Map<Id, ASI_CRM_AccountsAdditionalField__c> m_customer = new Map<Id, ASI_CRM_AccountsAdditionalField__c>();
        for(ASI_CRM_AccountsAdditionalField__c customer : scope){
            m_customer.put(customer.Id, customer);
        }
        system.debug('@@@m_customer: '+m_customer);
        
        List<ASI_TH_CRM_Contract__c> l_update_contract = new List<ASI_TH_CRM_Contract__c>();
        List<ASI_TH_CRM_Contract__c> l_contract = [SELECT Id, ASI_CRM_CN_Outlet_WS__c, OwnerId
                                                   FROM ASI_TH_CRM_Contract__c 
                                                   WHERE ASI_CRM_CN_Outlet_WS__c IN :s_change_owner_customer
                                                   AND ASI_CRM_Obsolete_Version__c = false];
        for(ASI_TH_CRM_Contract__c contract : l_contract){
			Id contract_customer = contract.ASI_CRM_CN_Outlet_WS__c;
            ASI_CRM_AccountsAdditionalField__c customer = m_customer.get(contract_customer);
            system.debug('@@@contract: '+contract);  
            system.debug('@@@contract.OwnerId: '+contract.OwnerId);  
            system.debug('@@@customer.OwnerId: '+customer.OwnerId);  
            if(contract.OwnerId != customer.OwnerId){
            	contract.OwnerId = customer.OwnerId;   
               	l_update_contract.add(contract);
            }
        }
		
		system.debug('@@@l_contract: '+l_contract);        
        
        List<ASI_FOC_Free_Goods_Request__c> l_update_free_good_request = new List<ASI_FOC_Free_Goods_Request__c>();
        List<ASI_FOC_Free_Goods_Request__c> l_free_good_request = [SELECT Id, ASI_CRM_Outlet__c, OwnerId, ASI_CRM_Contract__r.ASI_CRM_Obsolete_Version__c
                                                          FROM ASI_FOC_Free_Goods_Request__c 
                                                          WHERE ASI_CRM_Outlet__c IN :s_change_owner_customer
                                                          AND ASI_CRM_Contract__r.ASI_CRM_Obsolete_Version__c = false];
        for(ASI_FOC_Free_Goods_Request__c free_good_request : l_free_good_request){
			Id free_good_request_customer = free_good_request.ASI_CRM_Outlet__c;
            ASI_CRM_AccountsAdditionalField__c customer = m_customer.get(free_good_request_customer);
            if(free_good_request.OwnerId != customer.OwnerId){
            	free_good_request.OwnerId = customer.OwnerId;  
                l_update_free_good_request.add(free_good_request);
            }
        }
        system.debug('@@@l_free_good_request: '+l_free_good_request);    
        
        List<ASI_TH_CRM_PaymentRequest__c> l_update_payment_request = new List<ASI_TH_CRM_PaymentRequest__c>();
        List<ASI_TH_CRM_PaymentRequest__c> l_payment_request = [SELECT Id, ASI_CRM_CN_OutletWS__c, OwnerId, ASI_TH_CRM_Contract__r.ASI_CRM_Obsolete_Version__c
                                                                FROM ASI_TH_CRM_PaymentRequest__c 
                                                                WHERE ASI_CRM_CN_OutletWS__c IN :s_change_owner_customer
                                                                AND ASI_TH_CRM_Contract__r.ASI_CRM_Obsolete_Version__c = false];
        for(ASI_TH_CRM_PaymentRequest__c payment_request : l_payment_request){
			Id payment_request_customer = payment_request.ASI_CRM_CN_OutletWS__c;
            ASI_CRM_AccountsAdditionalField__c customer = m_customer.get(payment_request_customer);
            if(payment_request.OwnerId != customer.OwnerId){
				payment_request.OwnerId = customer.OwnerId;  
                l_update_payment_request.add(payment_request);
            }
        }
        system.debug('@@@l_payment_request: '+l_payment_request); 
        
        
        //Database.update(l_contract, false);
        Database.SaveResult[] l_update_result_contract = Database.update(l_update_contract, false);
        for(Integer i=0; i<l_update_result_contract.size(); i++){
            Database.SaveResult sr = l_update_result_contract[i];
            if (!sr.isSuccess()) {
                for(Database.Error err : sr.getErrors()) {
                    System.debug('@@@l_update_contract : The following error has occurred.');                    
                    System.debug('@@@l_update_contract: '+err.getStatusCode() + ': ' + err.getMessage());
                    System.debug('@@@l_update_contract: Fields that affected this error: ' + err.getFields());
                }
            }
        }
        //Database.update(l_update_free_good_request, false);
        Database.SaveResult[] l_update_result_free_good_request = Database.update(l_update_free_good_request, false);
        for(Integer i=0; i<l_update_result_free_good_request.size(); i++){
            Database.SaveResult sr = l_update_result_free_good_request[i];
            if (!sr.isSuccess()) {
                for(Database.Error err : sr.getErrors()) {
                    System.debug('@@@l_update_free_good_request : The following error has occurred.');                    
                    System.debug('@@@l_update_free_good_request: '+err.getStatusCode() + ': ' + err.getMessage());
                    System.debug('@@@l_update_free_good_request: Fields that affected this error: ' + err.getFields());
                }
            }
        }
        
        //Database.update(l_update_payment_request, false);
        Database.SaveResult[] l_update_result_payment_request = Database.update(l_update_payment_request, false);
        for(Integer i=0; i<l_update_result_payment_request.size(); i++){
            Database.SaveResult sr = l_update_result_payment_request[i];
            if (!sr.isSuccess()) {
                for(Database.Error err : sr.getErrors()) {
                    System.debug('@@@l_update_free_good_request : The following error has occurred.');                    
                    System.debug('@@@l_update_free_good_request: '+err.getStatusCode() + ': ' + err.getMessage());
                    System.debug('@@@l_update_free_good_request: Fields that affected this error: ' + err.getFields());
                }
            }
        }

    }
    
    global void finish(Database.BatchableContext BC) {
        
    }
    
}