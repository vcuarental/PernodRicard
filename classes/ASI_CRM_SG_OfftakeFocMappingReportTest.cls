/*********************************************************************************
 * Name: ASI_CRM_SG_OfftakeFocMappingReportTest
 * Description: 
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 2018-02-22       Billy Lo                Created
 */
@isTest
private class ASI_CRM_SG_OfftakeFocMappingReportTest {

	private static testMethod void testReport() {
	    
	    Test.startTest();
	    ASI_CRM_SG_TestClassHelper.createDataSettings();
	    ASI_CRM_SG_TestClassHelper.contractData contractC1 = new ASI_CRM_SG_TestClassHelper.contractData(true);
        ASI_CRM_SG_TestClassHelper.freeGoodsData freeGoodsC = new ASI_CRM_SG_TestClassHelper.freeGoodsData(true, 'ASI_CRM_SG_FOC_Read_Only');
        
        
        Map<string, ASI_TH_CRM_Contract__c> map_contract = new Map<string, ASI_TH_CRM_Contract__c>();
        map_contract.put(contractC1.contract.Id, contractC1.contract);
        
        Set<String> s1 = new Set<String>();
        s1.add('1_1');
        s1.add('2_2');
        
        Map<string, Set<string>> map_contractWithoutFOCMonth = new Map<string, Set<string>>();
        map_contractWithoutFOCMonth.put(contractC1.contract.Id, s1);
        
	    ASI_CRM_SG_OfftakeFocMappingReport offtakeReport = new ASI_CRM_SG_OfftakeFocMappingReport();
	    offtakeReport.runSearch();
	    offtakeReport.buildDisplayList(map_contractWithoutFOCMonth, map_contract);
	    
	    ASI_CRM_SG_OfftakeFocMappingReport.wrapper wrapper = new ASI_CRM_SG_OfftakeFocMappingReport.wrapper(contractC1.contract, s1);
	    wrapper.getDetail();
	    Test.stopTest();

	}

}