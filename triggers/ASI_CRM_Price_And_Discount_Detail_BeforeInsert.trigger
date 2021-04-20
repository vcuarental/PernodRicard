//2019/10/27 CanterDuan Create
trigger ASI_CRM_Price_And_Discount_Detail_BeforeInsert on ASI_CRM_Price_And_Discount_Detail__c (before insert) {
	ASI_CRM_CN_PriceDis_TriggerClass.GetTaxRate(trigger.new);
}