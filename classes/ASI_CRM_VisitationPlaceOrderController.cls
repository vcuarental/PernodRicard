public class ASI_CRM_VisitationPlaceOrderController {
    public class SKU_List {
        @AuraEnabled 
        public Integer total {get; set;}
        @AuraEnabled 
        public List<ASI_MFM_SKU_Code__c> skuList {get; set;}
        @AuraEnabled 
        public ASI_CRM_AccountsAdditionalField__c customer {get; set;}

        public SKU_List() {
            this.total = 0;
            this.skuList = new List<ASI_MFM_SKU_Code__c>();
            this.customer = new ASI_CRM_AccountsAdditionalField__c();
        }
    }
    
    @AuraEnabled
    public static SKU_List getSKUs(Id customerId, String searchText, String searchMethod, Integer limitPerPage, Integer offset) {
        ASI_CRM_VisitationRTypeMapping__c recordTypeMapping = ASI_CRM_VisitationRTypeMapping__c.getInstance();
        Id skuRecordTypeId = Global_RecordTypeCache.getRtId(recordTypeMapping.ASI_CRM_SKURTypeAPI__c);
        Id wholesalerRecordTypeId = Global_RecordTypeCache.getRtId(recordTypeMapping.ASI_CRM_WholesalerRTypeAPI__c);

        string filter = recordTypeMapping.ASI_CRM_SKUIOTFilter__c;

        SKU_List result = new SKU_List();
        Date todayDate = Date.today();

        String filterCondition = '';
        if (!searchMethod.equals('all') && searchText != null) {
            if (searchMethod.equals('sku')) {
                filterCondition = 'AND Name LIKE \'%' + searchText + '%\' ';
            }
            else if (searchMethod.equals('sku_code')) {
                filterCondition = 'AND ASI_MFM_SKU_Code__c LIKE \'%' + searchText + '%\' ';
            }
            else if (searchMethod.equals('brand')) {
                filterCondition = 'AND ASI_HK_CRM_Product_Brand__r.Name LIKE \'%' + searchText + '%\' ';
            }
            else if (searchMethod.equals('brand_code')) {
                filterCondition = 'AND ASI_TH_CRM_Brand_Code__c LIKE \'%' + searchText + '%\' ';
            }
            else if (searchMethod.equals('sub_brand')) {
                filterCondition = 'AND ASI_MFM_Sub_brand__r.Name LIKE \'%' + searchText + '%\' ';
            }
            else if (searchMethod.equals('sub_brand_code')) {
                filterCondition = 'AND ASI_MFM_Sub_brand__r.ASI_MFM_Sub_brand_Code__c LIKE \'%' + searchText + '%\' ';
            }
        }

        filterCondition += (filter != null ? 'AND (' + filter + ') ' : '');
        // filterCondition += (filter != null ? 'AND (ASI_CRM_Selectable_In_Order__c = TRUE )' : '');

        String countQuery = 'SELECT Count() FROM ASI_MFM_SKU_Code__c ' 
            + 'WHERE RecordTypeId = :skuRecordTypeId '
            + filterCondition;

        String query = '' +
            'SELECT Id, ' +
            'RecordType.Name, ' +
            'Name, ' +
            'ASI_MFM_SKU_Code__c, ' +
            'ASI_MFM_SKU_Description__c, ' +
            'ASI_MFM_Sub_brand__r.ASI_MFM_Sub_brand_Code__c, ' +
            'ASI_MFM_Sub_brand__r.Name, ' +
            'ASI_TH_CRM_Brand_Code__c, ' +
            'ASI_HK_CRM_Product_Brand__r.Name, ' +
            'ASI_HK_CRM_Active__c, ' +
            'ASI_HK_CRM_Base_Price__c ' +
            // 'ASI_CRM_Image_Preview__c, ' +
            // 'ASI_CRM_Image_URL__c ' +
            'FROM ASI_MFM_SKU_Code__c ' +
            'WHERE RecordTypeId = :skuRecordTypeId ' +
            // 'AND ASI_CRM_Effective_Date__c <= :todayDate ' + 
            filterCondition + 
            'ORDER BY ASI_MFM_Sub_brand__r.Name asc, Name asc ' +
            'LIMIT :limitPerPage ' +
            'OFFSET :offset ';

        List<ASI_CRM_AccountsAdditionalField__c> customers = [SELECT Id,
                                                              Name,
                                                              ASI_CRM_CN_Address__c,
                                                              ASI_CRM_CN_Phone_Number__c,
                                                              ASI_CRM_CN_Contact_Person__c
                                                              FROM ASI_CRM_AccountsAdditionalField__c
                                                              WHERE Id = :customerId
                                                              LIMIT 1
        ];system.debug('query: ' + query);

        if (!customers.isEmpty()) {
            result.customer = customers.get(0);
        }
        result.skuList = Database.query(query);
        result.total = Database.countQuery(countQuery);
        

        return result;
    }

    @AuraEnabled
    public static List<ASI_CRM_AccountsAdditionalField__c> getWholesalers(String name) {
		if (name == '')
		{
			return new List<ASI_CRM_AccountsAdditionalField__c>();
        }
        
        ASI_CRM_VisitationRTypeMapping__c recordTypeMapping = ASI_CRM_VisitationRTypeMapping__c.getInstance();
        Id wholesalerRecordTypeId = Global_RecordTypeCache.getRtId(recordTypeMapping.ASI_CRM_WholesalerRTypeAPI__c);

		String searchStr = '%' + name + '%';
		return [
			SELECT Id, Name
			FROM ASI_CRM_AccountsAdditionalField__c
			WHERE RecordTypeId = :wholesalerRecordTypeId
			AND Name LIKE :searchStr
			ORDER BY Name
			LIMIT 10
		];
    }

    @AuraEnabled
    public static String saveIOT(string iotHeaderStr, string iotDetailsStr)
    {
		ASI_CRM_IOTHeader__c iotHeader = (ASI_CRM_IOTHeader__c)System.JSON.deserializeStrict(iotHeaderStr, ASI_CRM_IOTHeader__c.class);
		List<ASI_CRM_IOTLine__c> iotDetails = (List<ASI_CRM_IOTLine__c>)System.JSON.deserializeStrict(iotDetailsStr, List<ASI_CRM_IOTLine__c>.class);
		ASI_CRM_VisitationRTypeMapping__c setting = ASI_CRM_VisitationRTypeMapping__c.getInstance();
        ASI_CRM_VisitationPlanSetting__c visitSetting = ASI_CRM_VisitationPlanSetting__c.getinstance();
		ID iotHeaderRTID = Global_RecordTypeCache.getRtId(setting.ASI_CRM_IOTHeaderRTypeAPI__c);
		ID iotDetailRTID = Global_RecordTypeCache.getRtId(setting.ASI_CRM_IOTDetailRTypeAPI__c);
		Datetime today = System.now();

		if (iotHeader == null && iotDetails.size() == 0)
		{
			return 'Invalid params';
		}
        
        // check header
        if (iotHeader != null)
        {
            if (iotHeader.ASI_CRM_Customer__c == null)
            {
                return 'Customer Not Found';    
            }
            if (iotHeader.ASI_CRM_Wholesaler__c == null) {
                return 'Warehouse Not Found';
            }
            
            iotHeader.ASI_CRM_Send_Email__c = visitSetting.ASI_CRM_IOT_Email__c;
        }

        try
		{
			List<ASI_CRM_IOTLine__c> upsertList = new List<ASI_CRM_IOTLine__c>();
			for (ASI_CRM_IOTLine__c detail : iotDetails)
			{
				if (detail.ASI_CRM_SKU__c != null && detail.ASI_CRM_Quantity__c > 0)
				{
					upsertList.add(detail);
				}
			}

			if (iotHeader != null)
			{
				iotHeader.RecordTypeId = iotHeaderRTID;
				upsert iotHeader;
			}

			if (upsertList.size() > 0)
			{
				for (ASI_CRM_IOTLine__c detail : upsertList)
				{
					detail.ASI_CRM_IOTHeader__c = iotHeader.Id;
					detail.RecordTypeId = iotDetailRTID;
				}

				upsert upsertList;
			}
		}
		catch (Exception e)
		{
			return e.getMessage();
		}

		return 'success';
	}
}