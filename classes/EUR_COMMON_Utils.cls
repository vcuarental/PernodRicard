public with sharing class EUR_COMMON_Utils
{
    private static String currentNamedCredentials = null;
    public static final String PRICE_SERVICE = 'PriceService';
    public static final String INVENTORY_SERVICE = 'InventoryService';
    public static final String PRICE_SERVICE_TYPE_SAP = 'SAP';
    public static final String PRICE_SERVICE_TYPE_JDE = 'JDE';

    public EUR_COMMON_Utils() {

    }

    /**
    * @Description Get name of Named Credential according instance and service type. Save value during execution context
    * @return String presentation of named credential
    */
    public static String getNamedCredential(String affiliate, String serviceType)
    {
        if (currentNamedCredentials == null)
        {
            String accessKey = affiliate + '_' + serviceType;
            currentNamedCredentials = [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox ? 'EUR_NIM_' + accessKey + '_Test' : 'EUR_NIM_' + accessKey + '_Prod';
        }
        return currentNamedCredentials;
    }

    /*
    Build map of all EUR_NIM_Sales_Order_Setting__mdt records (custom metadata type).
    Key - is a DeveloperName field value.
	*/
	private static Map<String, EUR_NIM_Sales_Order_Setting__mdt> salesOrderSettingsMdtMap
	{
		get
		{
			if (salesOrderSettingsMdtMap == null)
			{
				salesOrderSettingsMdtMap = new Map<String, EUR_NIM_Sales_Order_Setting__mdt>();
				for (EUR_NIM_Sales_Order_Setting__mdt setting : [SELECT MasterLabel, DeveloperName, EUR_NIM_Catalog_Name__c, 
                    EUR_NIM_PriceService_Type__c, EUR_NIM_InventoryService_Type__c 
                    FROM EUR_NIM_Sales_Order_Setting__mdt])
				{
					salesOrderSettingsMdtMap.put(setting.DeveloperName, setting);
				}
			}
            return salesOrderSettingsMdtMap;
		}
		set;
	}

    /*
    Build map of all EUR_NIM_CustomMapping__mdt records (custom metadata type).
    Key - is a DeveloperName field value.
	*/
	private static Map<String, EUR_NIM_CustomMapping__mdt> salesOrderMappingSettingsMap
	{
		get
		{
			if (salesOrderMappingSettingsMap == null)
			{
				salesOrderMappingSettingsMap = new Map<String, EUR_NIM_CustomMapping__mdt>();
				for (EUR_NIM_CustomMapping__mdt setting : [SELECT DeveloperName, EUR_NIM_FieldMappings__c
                    FROM EUR_NIM_CustomMapping__mdt])
				{
					salesOrderMappingSettingsMap.put(setting.DeveloperName, setting);
				}
			}
            return salesOrderMappingSettingsMap;
		}
		set;
	}

	/*
    *   It retrieves all the record types from DB.
    *   You can get record type Id by key "ObjectName:RecordTypeName".
    *   For example EUR_COMMON_Utils.recordTypes.get('EUR_CRM_SKU__c:EUR_IDL_SKU').
    */
    public static Map<String, ID> recordTypes
    {
        get
        {
            if (recordTypes == null )
            {
                recordTypes = new Map<String, Id>();
                for (RecordType aRecordType : [SELECT Name, SobjectType, Id, DeveloperName FROM RecordType 
                                                Where DeveloperName like 'EUR%' and IsActive = true])
                {
                    //recordTypes.put(aRecordType.DeveloperName, aRecordType.Id);
                    recordTypes.put(aRecordType.SobjectType + ':' + aRecordType.DeveloperName, aRecordType.Id);
                }
            }
            return recordTypes;
        }
        set;
    }
    
    /* Get Sales Order custom mapping values for JDE outbound unittype conversions*/
    public static Map<String,Object> getUnitTypeMapping(String countryCode)
    {
	    Map<String, Object> mappings = 
        (Map<String, Object>) JSON.deserializeUntyped(salesOrderMappingSettingsMap.get('JDE_Outbound_UnitType_'+countryCode).EUR_NIM_FieldMappings__c);
        return mappings;
    }

    /* Get Sales Order custom mapping values for JDE outbound price service */
    public static Map<String,Object> getJDEPriceMapping(String countryCode)
    {
	    Map<String, Object> mappings = 
        (Map<String, Object>) JSON.deserializeUntyped(salesOrderMappingSettingsMap.get('JDE_Outbound_Price_'+countryCode).EUR_NIM_FieldMappings__c);
        return mappings;
    }

    /* Get Sales Order custom mapping values for JDE outbound price service */
    public static Map<String,Object> getJDEInventoryMapping(String countryCode)
    {
	    Map<String, Object> mappings = 
        (Map<String, Object>) JSON.deserializeUntyped(salesOrderMappingSettingsMap.get('JDE_Outbound_Inventory_'+countryCode).EUR_NIM_FieldMappings__c);
        return mappings;
    }

    /* Get Sales Order custom mapping values for JDE inbound sales order updates */
    public static Map<String,Object> getUpdateSalesOrderMapping(String countryCode)
    {
	    Map<String, Object> updateSalesOrderMappings = 
        (Map<String, Object>) JSON.deserializeUntyped(salesOrderMappingSettingsMap.get('JDE_Inbound_UpdateSalesOrder_'+countryCode).EUR_NIM_FieldMappings__c);
        return updateSalesOrderMappings;
    }

    /* Get Sales Order custom metadata values. It is common method which will return entire metadata object */
    public static EUR_NIM_Sales_Order_Setting__mdt getSalesOrderMetadataValues(String recordId)
    {
        String countryCode = [select id,recordType.DeveloperName, EUR_CRM_Country_Code__c from EUR_CRM_Account__c where Id=:recordId].EUR_CRM_Country_Code__c;
        return salesOrderSettingsMdtMap.containsKey(countryCode) ? salesOrderSettingsMdtMap.get(countryCode) : null;
    }

    /**
    * @Description: get the sales order metadata settings for the current account
    * @return: EUR_NIM_Sales_Order_Setting__mdt
    */
    public static EUR_NIM_Sales_Order_Setting__mdt getSalesOrderMetadataValues(EUR_CRM_Account__c acc)
    {
        String countryCode = acc.EUR_CRM_Country_Code__c;
        return salesOrderSettingsMdtMap.containsKey(countryCode) ? salesOrderSettingsMdtMap.get(countryCode) : null;
    }
    
    /**
    * @Description: get the sales order metadata settings for the current country code
    * @return: EUR_NIM_Sales_Order_Setting__mdt
    */
    public static EUR_NIM_Sales_Order_Setting__mdt getSalesOrderMetadataValuesByCountryCode(String countryCode)
    {
        return salesOrderSettingsMdtMap.containsKey(countryCode) ? salesOrderSettingsMdtMap.get(countryCode) : null;
    }

    /**
    * @Description: get the account by id
    * @return: EUR_CRM_Account__c
    */
    public static EUR_CRM_Account__c getAccountById(String accId)
    {
        EUR_CRM_Account__c account = [SELECT EUR_CRM_Customer_No_ERP__c, EUR_CRM_Sales_Organization__c, name, 
                                        EUR_CRM_Country_Code__c, CurrencyIsocode, EUR_CRM_Customer_Ship_To_No_ERP__c,
                                        EUR_CRM_ERPSoldToAccount__r.EUR_CRM_Customer_No_ERP__c, EUR_CRM_ERPSoldToAccount__c,
                                        EUR_CRM_Order_Block__c 
                                        FROM EUR_CRM_Account__c
                                        WHERE Id = :accId];
        return account;
    }
}