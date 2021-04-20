/***************************************************************************************************************************
 * Name:        ASI_CRM_CN_CoveredOutletUploadCtrl
 * Description: Apex class for ASI_CRM_CN_CoveredOutletUploadCtrl
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 2018-08-08       Jeffrey Cheung          Created
 * 2019-02-19       Keith Yip               Handle promotion PO covered outlet upload function in ASI_CRM_CN_MassUploadComp 
 ****************************************************************************************************************************/

public class ASI_CRM_CN_CoveredOutletUploadCtrl {
    public String contractId {get;set;}
    public String contractType {get;set;}
    public String reportUrl {get;set;}
    public String OutletType {get;set;} 

    public ASI_CRM_CN_CoveredOutletUploadCtrl(ApexPages.StandardController controller){
        contractId = (String) controller.getRecord().Id;
        List<ASI_TH_CRM_Contract__c> ContractList = [Select Id,ASI_TH_CRM_Promotion_Type__c from ASI_TH_CRM_Contract__c where Id=:contractId];
        contractType = ContractList[0].ASI_TH_CRM_Promotion_Type__c;
        OutletType = ApexPages.currentPage().getParameters().get('OutletType');
        if(contractType == 'Outlet Promotion' || contractType =='Consumer Promotion' || contractType =='Wholesaler Promotion'){
        	if(OutletType =='Covered')
        		reportUrl = retrieveCoveredOutletReport('ASI_Promotion_Contracts_with_Covered_Outlet');
        	else
        		reportUrl = retrieveCoveredOutletReport('ASI_Promotion_Contracts_with_Covered_WS');
        }else{
        	reportUrl = retrieveCoveredOutletReport('ASI_Off_Trade_Contracts_with_Covered_Outlet');	
        }
        
    }



    public String retrieveCoveredOutletReport(String reportName){
        String reportType = '#';
        List<Report> reportList = [SELECT Id, Name, DeveloperName FROM Report WHERE DeveloperName =:reportName];
        if(reportList.size() > 0){
            String reportId = (String) reportList.get(0).get('Id');

            reportType = '/' + reportId + '?export=1&enc=UTF-8&xf=xls&pv0=' + String.valueOf(contractId).substring(0, 15);
        }
        return reportType;
    }

	public String getFields(){
		if(contractType == 'Outlet Promotion' || contractType =='Consumer Promotion' || contractType =='Wholesaler Promotion'){
			if(OutletType =='Covered')
				return 'ASI_CRM_CN_Outlet__c,ASI_CRM_CN_Target_Volume_9L__c,ASI_CRM_CN_Target_Value__c,ASI_CRM_CN_Est_Visibility_Amt__c,ASI_CRM_CN_Comment__c';
			else
				return 'ASI_CRM_CN_Outlet__c,ASI_CRM_CN_Target_Volume_9L__c,ASI_CRM_CN_Target_Value__c,ASI_CRM_CN_Strategy_WS__c,ASI_CRM_CN_Comment__c';	
		}else{
			return 'ASI_CRM_CN_Outlet__c,ASI_CRM_CN_Target_Volume_9L__c,ASI_CRM_CN_Target_Value__c';
		}
	}
	
	public String getTemplate(){
		if(contractType == 'Outlet Promotion' || contractType =='Consumer Promotion' || contractType =='Wholesaler Promotion'){
			if(OutletType =='Covered')
				return 'ASI_CRM_CN_Promotion_Covered_Outlet_Template';
			else
				return 'ASI_CRM_CN_Promotion_WS_Outlet_Template';	
		}else{
			return 'ASI_CRM_CN_Covered_Outlet_Template';		
		}
	}
	
	public String getFieldsLabel(){
		if(contractType == 'Outlet Promotion' || contractType =='Consumer Promotion' || contractType =='Wholesaler Promotion'){
		  if(OutletType =='Covered')
			return 'CRM Code,Target Volume (9L),Target Value,Est. Visibility Amount,Comment';
		  else
		    return 'CRM Code,Target Volume (9L),Target Value,Strategy WS,Comment';
		}else{
			return 'CRM Code,Target Volume (9L),Target Value';		
		}	
	}
	
}