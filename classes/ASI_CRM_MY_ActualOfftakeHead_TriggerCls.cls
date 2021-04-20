public with sharing class ASI_CRM_MY_ActualOfftakeHead_TriggerCls {
	
    public static void routineBeforeInsert(List<ASI_CRM_ActualOfftakeHeader__c> NewList){    
        
        
        String query = 'SELECT Id, ASI_CRM_ToOutlet__c, ASI_CRM_Year_Number__c, ASI_CRM_Month_Number__c, ASI_CRM_OfftakeDate__c FROM ASI_CRM_ActualOfftakeHeader__c WHERE ';
        
        
        for(ASI_CRM_ActualOfftakeHeader__c ActualOfftakeHeader : NewList){
            String memberId = String.valueOf(ActualOfftakeHeader.ASI_CRM_ToOutlet__c);
            String year = String.valueOf(ActualOfftakeHeader.ASI_CRM_Year_Number__c);
            String month = String.valueOf(ActualOfftakeHeader.ASI_CRM_Month_Number__c);
            String key = memberId+'_'+year+'_'+month;
			String queryWhere = ' (ASI_CRM_ToOutlet__c  = \''+ActualOfftakeHeader.ASI_CRM_ToOutlet__c+'\' AND ASI_CRM_Month_Number__c = '+ActualOfftakeHeader.ASI_CRM_Month_Number__c+' AND ASI_CRM_Year_Number__c = '+ActualOfftakeHeader.ASI_CRM_Year_Number__c+' ) ';
            Integer index = NewList.indexOf(ActualOfftakeHeader);
            if(index < (NewList.size()-1)){
                queryWhere += ' AND ';
            }
            query += queryWhere;
        }
        
		system.debug('@@@query: '+query);   
        Map<String, ASI_CRM_ActualOfftakeHeader__c> m_ActualOfftakeHeader = new Map<String, ASI_CRM_ActualOfftakeHeader__c>();
        List<ASI_CRM_ActualOfftakeHeader__c> l_ActualOfftakeHeader = Database.query(query);
        for(ASI_CRM_ActualOfftakeHeader__c ActualOfftakeHeader : l_ActualOfftakeHeader){
            String memberId = String.valueOf(ActualOfftakeHeader.ASI_CRM_ToOutlet__c);
            String year = String.valueOf(ActualOfftakeHeader.ASI_CRM_Year_Number__c);
            String month = String.valueOf(ActualOfftakeHeader.ASI_CRM_Month_Number__c);
            String key = memberId+'_'+year+'_'+month;
            system.debug('@@@key1: '+key);   
            m_ActualOfftakeHeader.put(key, ActualOfftakeHeader);
        }
        
        for(ASI_CRM_ActualOfftakeHeader__c ActualOfftakeHeader : NewList){
            String memberId = String.valueOf(ActualOfftakeHeader.ASI_CRM_ToOutlet__c);
            String year = String.valueOf(ActualOfftakeHeader.ASI_CRM_Year_Number__c);
            String month = String.valueOf(ActualOfftakeHeader.ASI_CRM_Month_Number__c);
            String key = memberId+'_'+year+'_'+month;
            system.debug('@@@key2: '+key);   
            Boolean isContain = m_ActualOfftakeHeader.containsKey(key);
            if(isContain){
            	ActualOfftakeHeader.ASI_CRM_OfftakeDate__c.addError('Duplicate offtake date for the customer');  
            }
        }
        
    }
}