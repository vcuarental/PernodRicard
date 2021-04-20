/***************************************************************************************************************************
 * Name:        ASI_CRM_CN_OffPDFRedirectController
 * Description: Controller for Page ASI_CRM_CN_OffPDFRedirectPage 
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 2018-09-07       Laputa(Hector)         	Created
 * 2018-11-01		Laputa(Hector)			Update Financial Indicator
 ****************************************************************************************************************************/

public class ASI_CRM_CN_OffPDFRedirectController {
    public ASI_TH_CRM_Contract__c ContractSelected {set;get;}
    public PageReference redirectPage {get;set;}
    
    
    public ASI_CRM_CN_OffPDFRedirectController (ApexPages.StandardController controller) { 
        String recordId = ((ASI_TH_CRM_Contract__c)controller.getRecord()).Id;
        this.ContractSelected = [SELECT Id,
										Name,
										Createddate,
										LastModifiedDate,
										Recordtypeid,
										ASI_CRM_CN_Bottle_Collection_Rate__c,
										ASI_CRM_CN_Budget_LE__c,
										ASI_CRM_CN_Business_License__c,
										ASI_CRM_CN_Contract_Upload__c,
										ASI_CRM_CN_Currency__c,
										ASI_CRM_CN_Description__c,
										ASI_CRM_CN_Effective_Date__c,
										ASI_CRM_CN_Exchange_Rate__c,
										ASI_CRM_CN_Expected_BRSF_Est_Total__c,
										ASI_CRM_CN_Last_PO_version__c,
										ASI_CRM_CN_Last_PO_version__r.ASI_CRM_National_Group__c,
										ASI_CRM_CN_Last_PO_version__r.ASI_CRM_National_Group__r.Name,
										ASI_CRM_CN_Last_Rejected_Date__c,
										ASI_CRM_CN_Last_Submitted_Date__c,
										ASI_CRM_CN_National_Group_Contract__c,
										ASI_CRM_CN_No_of_Months__c,
										ASI_CRM_CN_Outlet_WS__c,
										ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_NewChannel__r.Name,
										ASI_CRM_CN_Outlet_WS__r.RecordType.DeveloperName,
										ASI_CRM_CN_PO_End_Date__c,
										ASI_CRM_CN_PO_Modification__c,
										ASI_CRM_CN_PO_No__c,
										ASI_CRM_CN_PO_Start_Date__c,
										ASI_CRM_CN_PO_Version__c,
										ASI_CRM_CN_PP_No__c,
										ASI_CRM_CN_Reason_without_Budget__c,
										ASI_CRM_CN_Source_Others__c,
										ASI_CRM_CN_Source_of_Contract__c,
										ASI_CRM_CN_Special_Promotion__c,
										ASI_CRM_CN_Status__c,
										ASI_CRM_CN_Total_Contract_Amount__c,
										ASI_CRM_CN_V0_0_PO_version__c,
										ASI_CRM_CN_Vol_Budget_LE__c,
										ASI_CRM_EVC_Cost_Estimate_Total__c,
										ASI_CRM_Investment_Type__c,
										ASI_CRM_National_Group__c,
										ASI_CRM_National_Group__r.Name,
										ASI_CRM_New_FY_PO__c,
										ASI_CRM_PO_Channel__c,
										ASI_CRM_PO_City__c,
										ASI_CRM_PO_City__r.Name,
										ASI_CRM_PO_Province__c,
										ASI_CRM_PSFGrand_ContractTotal_BeforeAdj__c,
										ASI_CRM_PSF_Contract_Adjustment_Amount__c,
										ASI_CRM_PSF_Estimate_Adjustment_Amount__c,
										ASI_CRM_PSF_Grand_Contract_Total__c,
										ASI_CRM_PSF_Grand_Estimate_Total__c,
										ASI_CRM_PSF_Grd_Est_Total_before_Adj__c,
										ASI_CRM_Volume_Option__c,
										ASI_TH_CRM_Promotion_Type__c,
										ASI_TH_CRM_Summary_Contract_Spending__c,
			ASI_CRM_Expected_V0_PSF_Estimated_Total__c,
	                                 	(SELECT Id,
											Name,
											ASI_CRM_CN_Channel__c,
											ASI_CRM_CN_Last_Payment__c,
											ASI_CRM_CN_PO_End_Date__c,
											ASI_CRM_CN_PO_Start_Date__c,
											ASI_CRM_CN_PO_Version__c,
											ASI_CRM_CN_Paid_In_Progress__c,
											ASI_CRM_CN_Paid__c,
											ASI_CRM_CN_Payment_Raised_Date__c,
											ASI_CRM_CN_Total_Payment__c,
											ASI_TH_CRM_Contract__c,
											ASI_TH_CRM_Status__c
	                                 	 FROM ASI_TH_CRM_PaymentRequests_Contract__r)                       
                                 FROM ASI_TH_CRM_Contract__c
                                 WHERE id =:recordId ];
    }
    
    
    
    public PageReference CalculationRedirect() {
        Map<String, String> params = ApexPages.currentPage().getParameters();
        string TypeName = params.get('Type');
        
        try{
            if(TypeName=='PDF'){
            	//Profit Shuttle
            	ASI_CRM_CN_OffContractUtilitiesClass.RestructureHistoricalFinancialIndicatorData(ContractSelected);
                ASI_CRM_CN_OffContractUtilitiesClass.RestructureCurrentFinancialIndicatorData(ContractSelected);
            }
            
            if(TypeName=='POModificationPDF'){
                ASI_CRM_CN_OffContractUtilitiesClass.ReconstructCurrentPOModiFIData(ContractSelected);                
            }
            
            if (TypeName == 'GroupConsolidateShuttle'){
            	ASI_CRM_CN_OffContractUtilitiesClass.calculateGroupFI(ContractSelected, null);
            }
            
            if(TypeName=='SubmitApproval'){
                if(ContractSelected.ASI_CRM_CN_PO_Version__c=='0.0'){
                    ASI_CRM_CN_OffContractUtilitiesClass.RestructureCurrentFinancialIndicatorData(ContractSelected);
                } else {
                    ASI_CRM_CN_OffContractUtilitiesClass.ReconstructCurrentPOModiFIData(ContractSelected);
                    //not !='0.0'
                    CalculateV0FIData();
                }
            }
            
            if((TypeName=='POModificationPDF' || TypeName=='ViewCheckPoint') && ContractSelected.ASI_CRM_CN_PO_Version__c!='0.0'){
                CalculateV0FIData();
            }
        }catch(Exception e){
            String msg = 'Save Error : ' +e.getMessage() + '</br>';
            ASI_MFM_ByPass_Setting.ErrorHandling('ASI_CRM_CN_OffContractUtilitiesClass <br/> in CalculationRedirect class have Error  '+msg,'ASI_CRM_CN_OffPDFRedirectController','Calculation function failed! <br/>TypeName: '+TypeName+' <br/> with Contract Id: '+ContractSelected.id );
        }
        
        if(TypeName=='PDF'){
            redirectPage = new pageReference('/apex/ASI_CRM_CN_OffContractProfitShuttlePDF?id='+ContractSelected.Id);
        }else if(TypeName=='SubmitApproval'){
            redirectPage = new pageReference('/apex/ASI_CRM_CN_OffCheckPointResultPage?id='+ContractSelected.Id+'&Type='+TypeName);
        }else if(TypeName=='ViewCheckPoint'){
            redirectPage = new pageReference('/apex/ASI_CRM_CN_OffCheckPointResultPage?id='+ContractSelected.Id+'&Type='+TypeName);
        }else if(TypeName=='POModificationPDF'){
            redirectPage = new pageReference('/apex/ASI_CRM_CN_OffPOModificationPDF?id='+ContractSelected.Id+'&Type='+TypeName); // /apex/ASI_CRM_CN_OffContractEmailPDFPage?id={!ASI_TH_CRM_Contract__c.id}&PDF=1'
        }else if(TypeName == 'GroupConsolidateShuttle'){
          	redirectPage = new pageReference('/apex/ASI_CRM_CN_OffGroupShuttlePage?id='+ContractSelected.Id);
        }
        
        
        redirectPage.setRedirect(true);
        return redirectPage;
    }
    
    public void CalculateV0FIData(){
        ASI_TH_CRM_Contract__c V0ContractSelected = [SELECT Id,
														Name,
														Owner.Email,
														createddate,
														lastModifiedDate,
														recordtypeid,
														ASI_CRM_Auto_PO_Modification__c,
														ASI_CRM_CN_Bottle_Collection_Rate__c,
														ASI_CRM_CN_Budget_LE__c,
														ASI_CRM_CN_Business_License__c,
														ASI_CRM_CN_Contract_Upload__c,
														ASI_CRM_CN_Currency__c,
														ASI_CRM_CN_Description__c,
														ASI_CRM_CN_Effective_Date__c,
														ASI_CRM_CN_Exchange_Rate__c,
														ASI_CRM_CN_Expected_BRSF_Est_Total__c,
														ASI_CRM_CN_Expected_PSF_Est_Total__c,
														ASI_CRM_CN_Group_Contract__c,
														ASI_CRM_CN_Last_PO_version__c,
														ASI_CRM_CN_Last_PO_version__r.ASI_CRM_National_Group__c,
														ASI_CRM_CN_Last_PO_version__r.ASI_CRM_National_Group__r.Name,
														ASI_CRM_CN_Last_Rejected_Date__c,
														ASI_CRM_CN_Last_Submitted_Date__c,
														ASI_CRM_CN_National_Group_Contract__c,
														ASI_CRM_CN_No_of_Months__c,
														ASI_CRM_CN_Outlet_WS__c,
														ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_City_Tier__c,
														ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Commercial_Team__c,
														ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_NewChannel__r.Name,
														ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Region__c,
														ASI_CRM_CN_Outlet_WS__r.RecordType.DeveloperName,
														ASI_CRM_CN_PO_End_Date__c,
														ASI_CRM_CN_PO_Modification__c,
														ASI_CRM_CN_PO_No__c,
														ASI_CRM_CN_PO_Start_Date__c,
														ASI_CRM_CN_PO_Version__c,
														ASI_CRM_CN_PP_No__c,
														ASI_CRM_CN_Reason_without_Budget__c,
														ASI_CRM_CN_Source_Others__c,
														ASI_CRM_CN_Source_of_Contract__c,
														ASI_CRM_CN_Special_Promotion__c,
														ASI_CRM_CN_Status__c,
														ASI_CRM_CN_Total_Contract_Amount__c,
														ASI_CRM_CN_V0_0_PO_version__c,
														ASI_CRM_CN_Vol_Budget_LE__c,
														ASI_CRM_EVC_Cost_Estimate_Total__c,
														ASI_CRM_Expected_V0_0_VEC_Est_Total__c,
														ASI_CRM_Expected_V0_BRSF_Estimated_Total__c,
														ASI_CRM_Expected_V0_PSF_Estimated_Total__c,
														ASI_CRM_Investment_Type__c,
														ASI_CRM_Last_RBA_Approver__c,
														ASI_CRM_National_Group__c,
														ASI_CRM_National_Group__r.Name,
														ASI_CRM_New_FY_PO__c,
														ASI_CRM_PO_Channel__c,
														ASI_CRM_PO_City__c,
														ASI_CRM_PO_City__r.Name,
														ASI_CRM_PO_Province__c,
														ASI_CRM_PSFGrand_ContractTotal_BeforeAdj__c,
														ASI_CRM_PSF_Contract_Adjustment_Amount__c,
														ASI_CRM_PSF_Estimate_Adjustment_Amount__c,
														ASI_CRM_PSF_Grand_Contract_Total__c,
														ASI_CRM_PSF_Grand_Estimate_Total__c,
														ASI_CRM_PSF_Grd_Est_Total_before_Adj__c,
														ASI_CRM_Previous_Version_PSF_Est_Total__c,
														ASI_CRM_System_Debug__c,
														ASI_CRM_V0_PSF_Contract_Total__c,
														ASI_CRM_Volume_Option__c,
														ASI_TH_CRM_Promotion_Type__c,
														ASI_TH_CRM_Summary_Contract_Spending__c,
                                                     	(SELECT Id, 
                                                     		Name, 
                                                     		ASI_CRM_CN_Last_Payment__c, 
                                                     		ASI_TH_CRM_Contract__c,
                                                     		ASI_CRM_CN_PO_Version__c, 
                                                     		ASI_CRM_CN_PO_Start_Date__c,
                                                     		ASI_CRM_CN_PO_End_Date__c,
                                                     		ASI_TH_CRM_Status__c,
                                                      		ASI_CRM_CN_Channel__c, 
                                                      		ASI_CRM_CN_Total_Payment__c,
                                                      		ASI_CRM_CN_Paid__c,
                                                      		ASI_CRM_CN_Paid_In_Progress__c, 
                                                      		ASI_CRM_CN_Payment_Raised_Date__c 
                                                      	FROM ASI_TH_CRM_PaymentRequests_Contract__r)                       
                                                     FROM ASI_TH_CRM_Contract__c
                                                     WHERE id =:ContractSelected.ASI_CRM_CN_V0_0_PO_version__c ];
        
        ASI_CRM_CN_OffContractUtilitiesClass.RestructureHistoricalFinancialIndicatorData(V0ContractSelected); 
        ASI_CRM_CN_OffContractUtilitiesClass.RestructureCurrentFinancialIndicatorData(V0ContractSelected);
    }
    
}