public class ASI_CRM_VisitationPlanDetailCtr {
    @AuraEnabled
    public static CustomVisitationPlan getCustomVisitationPlan(String recordId)
    {
        ASI_HK_CRM_Visitation_Plan__c visitationPlan = getVisitationPlanRecord(recordId);
        List<ASI_HK_CRM_Visitation_Plan_Detail__c> visitationPlanDetailList = getVisitationPlanDetailRecord(recordId);
        
        return new CustomVisitationPlan(visitationPlan, visitationPlanDetailList);
    }
    
    @AuraEnabled 
    public static Integer getMyCustomCustomerCount(List<String> filter)
    {
        String ASI_CRM_CustomerRTypeAPI = ASI_CRM_VisitationRTypeMapping__c.getinstance().ASI_CRM_CustomerRTypeAPI__c.replace('ASI_CRM_AccountsAdditionalField__c','');
        List<String> MY_CUSTOMER_RECORD_TYPE_NAME_LIST = new List<String>();
        MY_CUSTOMER_RECORD_TYPE_NAME_LIST.addall(ASI_CRM_CustomerRTypeAPI.split(','));
    	return getCustomerCount(MY_CUSTOMER_RECORD_TYPE_NAME_LIST,
                                filter,
                                '(ASI_CRM_Channel__c = NULL OR ASI_CRM_Channel__r.Name <> \'' 
                                + String.escapeSingleQuotes('Employee\'s Accounts') 
                                + '\')');
    }

    @AuraEnabled
    public static CustomerResult getMYCustomCustomerList(List<String> filter, Integer pageSize, Integer pageNo)
    {
        CustomerResult result = new CustomerResult();

        String ASI_CRM_CustomerRTypeAPI = ASI_CRM_VisitationRTypeMapping__c.getinstance().ASI_CRM_CustomerRTypeAPI__c.replace('ASI_CRM_AccountsAdditionalField__c','');
        ASI_CRM_VisitationPlanSetting__c setting = ASI_CRM_VisitationPlanSetting__c.getInstance();
        List<String> MY_CUSTOMER_RECORD_TYPE_NAME_LIST = new List<String>();
        MY_CUSTOMER_RECORD_TYPE_NAME_LIST.addall(ASI_CRM_CustomerRTypeAPI.split(','));
                                                                   
        List<ASI_CRM_AccountsAdditionalField__c> customerList = getCustomerList(MY_CUSTOMER_RECORD_TYPE_NAME_LIST,
                                                                                filter,
                                                                                '(ASI_CRM_Channel__c = NULL OR ASI_CRM_Channel__r.Name <> \'' 
                                                                                     + String.escapeSingleQuotes('Employee\'s Accounts') 
                                                                                     + '\')',
                                                                               pageSize,
                                                                               pageNo);
        Set<Id> segmentationIdSet = new Set<Id>();
        for(ASI_CRM_AccountsAdditionalField__c customer : customerList)
        {
            if(customer.ASI_CRM_Segmentation_Criteria__c != NULL)
            {
                segmentationIdSet.add(customer.ASI_CRM_Segmentation_Criteria__c);
            }
        }
        	
        Map<Id, ASI_CRM_SegmentationCriteria__c> segmentationIdMap = segmentationIdSet.size() > 0
                                                                   ? new Map<Id, ASI_CRM_SegmentationCriteria__c>(getSegmentationCriteriaList(segmentationIdSet))
                                                                   : new Map<Id, ASI_CRM_SegmentationCriteria__c>();

        List<String> labelList = new List<String>();
        List<String> fieldList = new List<String>();
        List<String> objList = new List<String>();

        for (Integer i = 1; i <= 10; i++)
        {
            String fieldSetting = String.valueOf(setting.get('ASI_CRM_Visitation_Plan_Field_' + i + '__c'));

            if (fieldSetting != null)
            {
                String[] fieldArr = fieldSetting.split('\\|');
                labelList.add(fieldArr[0]);
                fieldList.add(fieldArr[1]);

                if (fieldArr.size() >= 3)
                {
                    objList.add(fieldArr[2]);
                }
                else
                {
                    objList.add('');    
                }
            }
        }

        List<CustomCustomer> customCustomerList = new List<CustomCustomer>();
        
        for (ASI_CRM_AccountsAdditionalField__c customer : customerList)
        {
        	Integer requiredVisitPerMonth = 0;
            if(customer.ASI_CRM_Segmentation_Criteria__c != NULL && 
              	segmentationIdMap.containsKey(customer.ASI_CRM_Segmentation_Criteria__c)) {
                ASI_CRM_SegmentationCriteria__c segmentationCriteria = segmentationIdMap.get(customer.ASI_CRM_Segmentation_Criteria__c);
                requiredVisitPerMonth = segmentationCriteria.ASI_CRM_CallFrequency__c == null
                                      ? 0  
                                      : segmentationCriteria.ASI_CRM_CallFrequency__c.intValue();
            }
            
            List<CustomerColumn> columns = new List<CustomerColumn>();
            Integer titleCount = 0;

            for (String field: fieldList)
            {
                CustomerColumn column = new CustomerColumn();
                column.label = '';
                column.value = '';
                column.objName = '';

                if (field.toLowerCase() == 'name')
                {
                    column.label = customer.Name;
                    column.value = customer.Id;
                    column.objName = 'ASI_CRM_AccountsAdditionalField__c';
                }
                else if (objList[titleCount] != '')
                {
                    if (customer.getSObject(field) != null)
                    {
                        column.label = String.valueOf(customer.getSObject(field).get('Name'));
                        column.value = String.valueOf(customer.getSObject(field).get('Id'));
                        column.objName = objList[titleCount];
                    }
                }
                else
                {
                    if (field.contains('.'))
                    {
                        String[] fieldAttribute = field.split('\\.');
                        column.label = String.valueOf(customer.getSObject(fieldAttribute[0]).get(fieldAttribute[1]));
                    }
                    else
                    {
                        column.label = String.valueOf(customer.get(field));
                    }
                }

                column.title = labelList[titleCount];
                columns.add(column);
                titleCount++;
            }

            customCustomerList.add(new CustomCustomer(customer, requiredVisitPerMonth, columns));
        }

        List<String> filterLabel = new List<String>();
        List<String> filterList = new List<String>();

        for (Integer i = 1; i <= 5; i++)
        {
            String fieldSetting = String.valueOf(setting.get('ASI_CRM_Visitation_Plan_Filter_' + i + '__c'));

            if (String.isNotBlank(fieldSetting))
            {
                String[] fieldArr = fieldSetting.split('\\|');
                filterLabel.add(fieldArr[0]);
                filterList.add('');
            }
        }

        result.titleList = labelList;
        result.customerList = customCustomerList;
        result.filterLabel = filterLabel;
        result.filterList = filter.size() > 0 ? filter : filterList;

        return result;
    }

    @AuraEnabled
    public static Map<String, Integer> getMYVisitationPlanRequirement(List<String> recordTypeDeveloperNameList) {
        List<AggregateResult> segmentationCountList = [
            SELECT RecordType.Name RecordTypeName, 
            		ASI_CRM_Segmentation_Criteria__c SegmentationId, 
            		SUM(ASI_CRM_Segmentation_Criteria__r.ASI_CRM_CallFrequency__c) RecordCallFrequency
			FROM ASI_CRM_AccountsAdditionalField__c
            WHERE RecordType.DeveloperName in :recordTypeDeveloperNameList 
            	AND ASI_CRM_Segmentation_Criteria__c != null
            GROUP BY RecordType.Name, ASI_CRM_Segmentation_Criteria__c
        ];
        
       	Map<String, Integer> recordTypeVisitationPlanCountMap = new Map<String, Integer>();    
        for(AggregateResult result : segmentationCountList) {
            String recordTypeName       = (String) result.get('RecordTypeName');
            Id segmentationId           = (Id) result.get('SegmentationId');
            Integer RecordCallFrequency = ((Decimal) result.get('RecordCallFrequency')).intValue();
            
            Integer totalFrequenceyPerRecordType = recordTypeVisitationPlanCountMap.containsKey(recordTypeName)
                                                 ? recordTypeVisitationPlanCountMap.get(recordTypeName)
                                                 : 0;
            
            totalFrequenceyPerRecordType += RecordCallFrequency;
            recordTypeVisitationPlanCountMap.put(recordTypeName, totalFrequenceyPerRecordType);
        } 
        
        return recordTypeVisitationPlanCountMap;
    }
    
    @AuraEnabled
    public static void saveVisitationPlanDetail(String insertDetailListJson, 
                                                String updateDetailListJson, 
                                                String deleteDetailIdListJson) {
                                                    
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
                	insertDetail.RecordTypeId = Global_RecordTypeCache.getRtId(ASI_CRM_VisitationRTypeMapping__c.getinstance().ASI_CRM_VisitationPlanDetailRTypeAPI__c);   
           		}        
                   insert insertDetailList;       
               }
        } catch (Exception e) {
            Database.rollback(sp);

            throw e;
        }                                            
    }
    
    private static List<ASI_CRM_SegmentationCriteria__c> getSegmentationCriteriaList(Set<Id> segmentationIdSet) {
        return [SELECT id, 
               	       ASI_CRM_CallFrequency__c 
                FROM ASI_CRM_SegmentationCriteria__c 
                WHERE id in :segmentationIdSet];
    }
    
    private static Integer getCustomerCount(List<String> recordTypeDeveloperNameList, List<String> filter, String specialQuery)
    {
        String selectQuery = 'SELECT count() FROM ASI_CRM_AccountsAdditionalField__c ' 
                           + genCustomerWhereClause(recordTypeDeveloperNameList, 
                                                    filter,
                                                    specialQuery);
            
    	return database.countQuery(selectQuery);    
    }
    
    private static List<ASI_CRM_AccountsAdditionalField__c> getCustomerList(List<String> recordTypeDeveloperNameList, 
                                                                            List<String> filter,
                                                                            String specialQuery,
                                                               				Integer pageSize,
                                                                            Integer pageNo)
    {
        ASI_CRM_VisitationPlanSetting__c setting = ASI_CRM_VisitationPlanSetting__c.getInstance();
        List<String> labelList = new List<String>();
        List<String> fieldList = new List<String>();
        List<String> objList = new List<String>();

        for (Integer i = 1; i <= 10; i++)
        {
            String fieldSetting = String.valueOf(setting.get('ASI_CRM_Visitation_Plan_Field_' + i + '__c'));

            if (fieldSetting != null)
            {
                String[] fieldArr = fieldSetting.split('\\|');
                labelList.add(fieldArr[0]);
                fieldList.add(fieldArr[1]);

                if (fieldArr.size() >= 3)
                {
                    objList.add(fieldArr[2]);
                }
                else
                {
                    objList.add('');    
                }
            }
        }

        String queryField = '';

        if (fieldList.size() > 0)
        {
            Integer count = 0;
            for (String field : fieldList)
            {
                if (field.toLowerCase() == 'name'
                    || field.toLowerCase() == 'id'
                    || field.toLowerCase() == 'asi_crm_segmentation_criteria__c'
                    || field.toLowerCase() == 'recordtype.id'
                    || field.toLowerCase() == 'recordtype.name')
                {

                }
                else if (objList[count] != '')
                {
                    queryField += (', ' + field + '.ID, ' + field + '.Name');
                }
                else
                {
                    queryField += (', ' + field);
                }

                count++;
            }
        }

        String selectQuery = 'SELECT ID, Name, ASI_CRM_Segmentation_Criteria__c, RecordType.ID, RecordType.Name'
                            + queryField
                            + ' from ASI_CRM_AccountsAdditionalField__c ';
        
      	selectQuery += genCustomerWhereClause(recordTypeDeveloperNameList, 
                                              filter,
                                              specialQuery);
        selectQuery += 'ORDER BY Name ASC ';
                                                                                
        if (pageSize != null && 
          	pageSize != 0 && 
          	pageNo != null && 
          	pageNo != 0)
            selectQuery += 'LIMIT ' + pageSize + ' OFFSET ' + ((pageNo - 1) * pageSize);
        
        return Database.query(selectQuery);
    }
    
    private static String genCustomerWhereClause(List<String> recordTypeDeveloperNameList, 
                                                List<String> filter,
                                                String specialQuery)
    {
        ASI_CRM_VisitationRTypeMapping__c rtSetting = ASI_CRM_VisitationRTypeMapping__c.getInstance();
        ASI_CRM_VisitationPlanSetting__c setting = ASI_CRM_VisitationPlanSetting__c.getInstance();

        List<String> queryStringList = new List<String>();
        queryStringList.add('ASI_CRM_CN_Inactive_Flag__c = FALSE');
                                                                                
        if (recordTypeDeveloperNameList.size() > 0)
        {
        	List<String> recordTypeQueryStringList = new List<String>();
            for (String recordTypeDeveloperName : recordTypeDeveloperNameList)
            {
                recordTypeQueryStringList.add('RecordType.DeveloperName = \'' + recordTypeDeveloperName + '\'');
            }
            queryStringList.add('(' + String.join(recordTypeQueryStringList, ' OR ') + ')');
        }

        for (Integer i = 1; i <= 5; i++)
        {
            String fieldSetting = String.valueOf(setting.get('ASI_CRM_Visitation_Plan_Filter_' + i + '__c'));

            if (String.isNotBlank(fieldSetting) && filter.size() >= i && filter[i - 1] != '')
            {
                String[] fieldArr = fieldSetting.split('\\|');
                queryStringList.add(fieldArr[1] + ' like \'%' + filter[i - 1] + '%\'');
            }
        }

        if (String.isNotBlank(specialQuery))
        {
            queryStringList.add(specialQuery);   
        }
            
        String customerFilter = String.valueOf(rtSetting.ASI_CRM_CustomerFilter__c);

        if (String.isNotBlank(customerFilter) && customerFilter.contains('UserInfo.getUserId()'))
        {
            customerFilter = customerFilter.replace('UserInfo.getUserId()', '\'' + UserInfo.getUserId() + '\'');
        }

        if (String.isNotBlank(customerFilter))
        {
            queryStringList.add(customerFilter);
        }

        if (queryStringList.size() > 0)
    		return 'WHERE ' + String.join(queryStringList, ' AND ') + ' ';
    	else 
            return '';
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
                		ASI_CRM_MY_Customer__r.id, 
                		ASI_CRM_MY_Customer__r.Name, 
                        ASI_CRM_MY_Customer__r.RecordType.Name,
                        ASI_HK_CRM_Status__c
                	FROM ASI_HK_CRM_Visitation_Plan_Detail__c 
            		WHERE ASI_HK_CRM_Visitation_Plan__c = :recordId 
            			LIMIT 1000];
    }
    
    public class CustomVisitationPlan {
        @AuraEnabled  
        public ASI_HK_CRM_Visitation_Plan__c visitationPlan {get; set;}
        @AuraEnabled 
        public List<ASI_HK_CRM_Visitation_Plan_Detail__c> visitationPlanDetailList { get; set; }
        
        public CustomVisitationPlan(ASI_HK_CRM_Visitation_Plan__c visitationPlan, 
                                    List<ASI_HK_CRM_Visitation_Plan_Detail__c> visitationPlanDetailList) {
            this.visitationPlan           = visitationPlan;
            this.visitationPlanDetailList = visitationPlanDetailList;
        }
        
    }

    public class CustomerResult {
        @AuraEnabled
        public List<CustomCustomer> customerList { get; set; }

        @AuraEnabled
        public List<String> titleList { get; set; }

        @AuraEnabled
        public List<String> filterLabel { get; set; }

        @AuraEnabled
        public List<String> filterList { get; set; }
    }

    public class CustomerColumn {
        @AuraEnabled
        public string label { get; set; }
        
        @AuraEnabled
        public string value { get; set; }

        @AuraEnabled
        public string objName { get; set; }

        @AuraEnabled
        public string title { get; set; }
    }

    public class CustomCustomer {
        @AuraEnabled 
        public ASI_CRM_AccountsAdditionalField__c customerRecord {get; set;}
        
        @AuraEnabled
        public Integer requiredVisitPerMonth {get; set;}
        
        @AuraEnabled
        public List<CustomerColumn> columns { get; set; }
        
        public CustomCustomer(ASI_CRM_AccountsAdditionalField__c customerRecord, 
                              Integer requiredVisitPerMonth, List<CustomerColumn> columns) {
        	this.customerRecord        = customerRecord;
            this.requiredVisitPerMonth = requiredVisitPerMonth;     
            this.columns = columns;              
        }
    }
    
}