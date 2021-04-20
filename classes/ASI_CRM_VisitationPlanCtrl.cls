public with sharing class ASI_CRM_VisitationPlanCtrl {

    public static List<String> PH_CUSTOMER_RECORD_TYPE_NAME_LIST = new List<String> {
        'ASI_CRM_PH_Customer', 'ASI_CRM_PH_Potential_Outlet'
    };

    public static Id PH_VISITATION_PLAY_DETAIL_RECORD_TYPE_ID = Schema.SObjectType.ASI_HK_CRM_Visitation_Plan_Detail__c.RecordTypeInfosByName.get('PH Visitation Plan Detail').RecordTypeId;

    @AuraEnabled
    public static void savePHVisitationPlanDetail(String insertDetailListJson, 
                                                  String updateDetailListJson, 
                                                  String deleteDetailIdListJson) {
        saveVisitationPlanDetail(insertDetailListJson, updateDetailListJson, deleteDetailIdListJson, PH_VISITATION_PLAY_DETAIL_RECORD_TYPE_ID);                                                                                                  
    }

    private static void saveVisitationPlanDetail(String insertDetailListJson, 
                                                String updateDetailListJson, 
                                                String deleteDetailIdListJson,
                                                Id recordTypeId) {
                                                    
    	List<ASI_HK_CRM_Visitation_Plan_Detail__c> insertDetailList = (List<ASI_HK_CRM_Visitation_Plan_Detail__c>) 
            	JSON.deserialize(insertDetailListJson, List<ASI_HK_CRM_Visitation_Plan_Detail__c>.class);
                                                    
    	List<ASI_HK_CRM_Visitation_Plan_Detail__c> updateDetailList = (List<ASI_HK_CRM_Visitation_Plan_Detail__c>) 
            	JSON.deserialize(updateDetailListJson, List<ASI_HK_CRM_Visitation_Plan_Detail__c>.class);
                                                    
    	List<String> deleteDetailIdList = (List<String>) 
            	JSON.deserialize(deleteDetailIdListJson, List<String>.class);
                                                    
    	Savepoint sp = Database.setSavepoint();
        
        try {
            if(deleteDetailIdList != null && 
               deleteDetailIdList.size() != 0) {
                List<ASI_HK_CRM_Visitation_Plan_Detail__c> deleteDetailList = new List<ASI_HK_CRM_Visitation_Plan_Detail__c>();
            	
           		for(String detailId : deleteDetailIdList) {
                	deleteDetailList.add(new ASI_HK_CRM_Visitation_Plan_Detail__c(id = detailId));	       
            	}
                
            	delete deleteDetailList;        
        	}
            
            if(updateDetailList != null && 
               updateDetailList.size() != 0) {
            	update updateDetailList;        
            }
            
            if(insertDetailList != null && 
               insertDetailList.size() != 0) {
           		for(ASI_HK_CRM_Visitation_Plan_Detail__c insertDetail : insertDetailList) {
                	insertDetail.RecordTypeId = recordTypeId;
           		}        
            	insert insertDetailList;       
        	}
        } catch (Exception e) {
            Database.rollback(sp);

            throw e;
        }                                            
    }

    @AuraEnabled
    public static CustomVisitationPlan getCustomVisitationPlan(String recordId){
        ASI_HK_CRM_Visitation_Plan__c visitationPlan = getVisitationPlanRecord(recordId);
        List<ASI_HK_CRM_Visitation_Plan_Detail__c> visitationPlanDetailList = getVisitationPlanDetailRecord(recordId);
        
        return new CustomVisitationPlan(visitationPlan, visitationPlanDetailList);
    }
    
    private static ASI_HK_CRM_Visitation_Plan__c getVisitationPlanRecord(String recordId) {
		return [SELECT Id, 
                		Name, 
                		ASI_HK_CRM_Year__c, 
                		ASI_HK_CRM_Month__c, 
                		ASI_CRM_Month_Number__c, 
                		ASI_HK_CRM_Confirmed__c
                    FROM ASI_HK_CRM_Visitation_Plan__c 
                	WHERE Id = :recordId];
    }

    private static List<ASI_HK_CRM_Visitation_Plan_Detail__c> getVisitationPlanDetailRecord(String recordId) {
		return [SELECT Id, 
                		Name, 
                        ASI_HK_CRM_Visit_Date__c, 
                        ASI_HK_CRM_Status__c,
                        ASI_CRM_Locked__c,
                		ASI_CRM_MY_Customer__r.id, 
                		ASI_CRM_MY_Customer__r.Name, 
                		ASI_CRM_MY_Customer__r.RecordType.Name 
                	FROM ASI_HK_CRM_Visitation_Plan_Detail__c 
            		WHERE ASI_HK_CRM_Visitation_Plan__c = :recordId 
            			LIMIT 1000];
    }

    @AuraEnabled 
    public static Integer getPHCustomCustomerCount(String customerName, 
                                                   Boolean isOwned) {
        List<String> specialQueryList = new List<String>();
        if(String.isNotBlank(customerName))
            specialQueryList.add('(Name LIKE \'%' + customerName + '%\')');

        if(isOwned == true) 
            specialQueryList.add('(OwnerId = \'' + UserInfo.getUserId() + '\')');

        String specialQuery = '';
        if(specialQueryList.size() != 0) 
            specialQuery = String.join(specialQueryList, ' AND ');

    	return getCustomerCount(PH_CUSTOMER_RECORD_TYPE_NAME_LIST, specialQuery);                                                   
    }
    
    @AuraEnabled
    public static List<ASI_CRM_AccountsAdditionalField__c> getPHCustomCustomerList(String customerName,
                                                                                   Boolean isOwned,
                                                                                   Integer pageSize,
                                                                                   Integer pageNo) {
        List<String> specialQueryList = new List<String>();
        if(String.isNotBlank(customerName))
            specialQueryList.add('(Name LIKE \'%' + customerName + '%\')');

        if(isOwned == true) 
            specialQueryList.add('(OwnerId = \'' + UserInfo.getUserId() + '\')');

        String specialQuery = '';
        if(specialQueryList.size() != 0) 
            specialQuery = String.join(specialQueryList, ' AND ');

        List<ASI_CRM_AccountsAdditionalField__c> customerList = getCustomerList(PH_CUSTOMER_RECORD_TYPE_NAME_LIST,
                                                                                specialQuery,
                                                                                pageSize,
                                                                                pageNo);
                                                                    
        return customerList;
    }

    private static Integer getCustomerCount(List<String> recordTypeDeveloperNameList, 
                                            String specialQuery) {
        String selectQuery = 'SELECT count() FROM ASI_CRM_AccountsAdditionalField__c ' 
                           + genCustomerWhereClause(recordTypeDeveloperNameList, 
                                                    specialQuery);
            
    	return database.countQuery(selectQuery);
    }

    private static List<ASI_CRM_AccountsAdditionalField__c> getCustomerList(List<String> recordTypeDeveloperNameList, 
                                                                            String specialQuery,
                                                               				Integer pageSize,
                                                                            Integer pageNo) {
        String selectQuery = 'SELECT Id, '
                           + 'Name, '
                           + 'RecordTypeId, '
                           + 'RecordType.Name, ' 
                           + 'RecordType.DeveloperName, '
                           + 'ASI_CRM_SG_Area__c, '
                           + 'ASI_CRM_VN_Channel__c, '
                           + 'ASI_CRM_JP_City_Ward__c, '
                           + 'ASI_CRM_JP_Town__c, '
                           + 'OwnerId, '
                           + 'Owner.Id, '
                           + 'Owner.Name '
                           + 'FROM ASI_CRM_AccountsAdditionalField__c ';
        
      	selectQuery += genCustomerWhereClause(recordTypeDeveloperNameList, 
                                              specialQuery);
        
        selectQuery += 'ORDER BY Name ASC ';
                                                                                
        if(pageSize != null && 
          	pageSize != 0 && 
          	pageNo != null && 
          	pageNo != 0)
            selectQuery += 'LIMIT ' + pageSize + ' OFFSET ' + ((pageNo - 1) * pageSize);
                                                                                
        return Database.query(selectQuery);
    }

    private static String genCustomerWhereClause(List<String> recordTypeDeveloperNameList, 
                                                String specialQuery) {
        List<String> queryStringList = new List<String>();
        queryStringList.add('ASI_CRM_CN_Inactive_Flag__c = FALSE');
                                                                                
        if(recordTypeDeveloperNameList.size() > 0) {
        	List<String> recordTypeQueryStringList = new List<String>();
            for(String recordTypeDeveloperName : recordTypeDeveloperNameList) {
                recordTypeQueryStringList.add('RecordType.DeveloperName = \'' + recordTypeDeveloperName + '\'');
            }
            queryStringList.add('(' + String.join(recordTypeQueryStringList, ' OR ') + ')');
        }
                                                     
        if(String.isNotBlank(specialQuery))
        	queryStringList.add(specialQuery);                                      
        
        if(queryStringList.size() > 0)                                     
    		return 'WHERE ' + String.join(queryStringList, ' AND ') + ' ';
    	else 
            return '';
    }

    public class CustomVisitationPlan {
        @AuraEnabled  
        public ASI_HK_CRM_Visitation_Plan__c visitationPlan {get; set;}
        @AuraEnabled 
        public List<ASI_HK_CRM_Visitation_Plan_Detail__c> visitationPlanDetailList {get; set;}
        
        public CustomVisitationPlan(ASI_HK_CRM_Visitation_Plan__c visitationPlan, 
                                    List<ASI_HK_CRM_Visitation_Plan_Detail__c> visitationPlanDetailList) {
            this.visitationPlan           = visitationPlan;
            this.visitationPlanDetailList = visitationPlanDetailList;
        }
        
    }

}