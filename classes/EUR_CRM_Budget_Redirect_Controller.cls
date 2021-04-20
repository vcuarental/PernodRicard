/*********************************************************************************
 * Name: EUR_CRM_Budget_Redirect_Controller
 * Description: Controller class to redirect Budget page to respective summary pages
 *
 * Version History
 * Date				Developer				Comments
 * ---------------	--------------------	--------------------------------------------------------------------------------
 * 9/22/2015		Conrad					Created
 *
*********************************************************************************/
public with sharing class EUR_CRM_Budget_Redirect_Controller {
	EUR_CRM_Budget__c budget;
    Map<String,String> recordTypePageMap = new Map<String,String>{
        'EUR_DE_On_Trade_WKZ'=>'EUR_CRM_DE_BudgetSummaryPage',
        'EUR_ZA_On_Trade_Budget'=>'EUR_CRM_BudgetSummaryPage'
    };
    public EUR_CRM_Budget_Redirect_Controller(ApexPages.StandardController stdController) {
        budget = (EUR_CRM_Budget__c) stdController.getRecord(); 
    }
    
    public PageReference redirect(){
        PageReference ref;
        String rtDevName = budget.RecordType.Developername;
        String vfPage = recordTypePageMap.get(rtDevName );
        if(String.isNotEmpty(vfPage)){
            ref = new PageReference('/apex/'+vfPage+'?id=' + this.budget.Id); 
        }else{
            ref = new PageReference('/'+this.budget.Id+'?nooverride=1'); 
        }
        ref.setRedirect(true);
        return ref;
    } 
}