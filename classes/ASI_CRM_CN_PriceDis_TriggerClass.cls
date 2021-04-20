public without sharing class ASI_CRM_CN_PriceDis_TriggerClass {
	//2019/10/27 CanterDuan 添加功能：新增TOV时，获取最新的税率
    public static void GetTaxRate(List<ASI_CRM_Price_And_Discount_Detail__c> triggerNew){
        //获取税率信息
        List<ASI_CRM_CN_Tax_Rate_Config__c> taxRateList = new List<ASI_CRM_CN_Tax_Rate_Config__c>([SELECT Id,ASI_CRM_CN_Tax_Rate__c 
                                                                                        FROM ASI_CRM_CN_Tax_Rate_Config__c 
                                                                                        ORDER BY ASI_CRM_CN_Effective_From__c DESC]);
        if(taxRateList.isEmpty()) return;
        for(ASI_CRM_Price_And_Discount_Detail__c tov: triggerNew){
            tov.ASI_CRM_CN_Tax_Rate__c = taxRateList[0].ASI_CRM_CN_Tax_Rate__c;
        }
    }
    //2019/10/27 END
}