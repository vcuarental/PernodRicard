/*********************************************************************************
 * Name: ASI_HK_CRM_SalesOrderARCheckController
 * Description: 
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 14/01/2018         Wilken Lee            [WL 1.0] Updated to use Oracle SOA for AR Checking in JDE BSSV
*********************************************************************************/
public without sharing class ASI_HK_CRM_SalesOrderARCheckController {

    public ID soId { get; private set; }    
    private ASI_HK_CRM_Sales_Order__c so;
    private static final Set<String> validStatusName = new Set<String>{
    	'CC'
    	, 'CS'
    	, 'CO'
    	, 'IF'
    	, 'IP'
    	, 'S'     
    	, 'Approved'
    };
    
    public ASI_HK_CRM_SalesOrderARCheckController(ApexPages.StandardController stdCon) {
        this.soId = stdCon.getId();
        this.so = [SELECT Id, ASI_HK_CRM_Customer_DA__c
        		   , ASI_HK_CRM_Order_Status_Name__c
                   , ASI_HK_CRM_Account_PA__r.ASI_HK_CRM_JDE_Account_Number__c 
                   , ASI_HK_CRM_Customer_DA__r.recordType.developerName
                   FROM ASI_HK_CRM_Sales_Order__c WHERE Id = :soId]; 
        
        if(validStatusName.contains(so.ASI_HK_CRM_Order_Status_Name__c)) throw new SalesOrderCheckARException('You are not allowed to edit this record');
        
    }
    
    public PageReference requestARInfo() {

        PageReference redirectPage = null;
        
        if (this.so.ASI_HK_CRM_Customer_DA__c != null) {   // Changed from PA to DA by Abel
            if (this.so.ASI_HK_CRM_Customer_DA__r.recordType.developerName == 'ASI_HK_CRM_Outlet'){
                try { 
                    ID acctId = this.so.ASI_HK_CRM_Customer_DA__c;
                    Account acct = [SELECT Id, ASI_HK_CRM_JDE_Account_Number__c FROM Account WHERE Id = :so.ASI_HK_CRM_Customer_DA__c];
                    //The DA account JDE account number would be pass to the webservice
					
					/*[WL 1.0] BEGIN*/
					ASI_SOA_Setting__c customSetting = ASI_SOA_Setting__c.getValues('ASI_CRM_HK_SO_EnableSOAInterface');
					system.debug('HK CRM SOA Web Service exist: ' + customSetting != null);
		
					if (customSetting != null){
						ASI_CRM_HK_SOA_InvokeSOA.checkAR(
							Integer.ValueOf(acct.ASI_HK_CRM_JDE_Account_Number__c), 
							String.ValueOf(acct.Id), 
							String.ValueOf(this.so.Id), 
							UserInfo.getName() + ', ' + Datetime.now().format('dd/MM/yyyy HH:MM'));
					}
					else {
						ASI_HK_CRM_ARCheckHelper.updateAccountByWS(acct, this.so, Integer.valueOf(acct.ASI_HK_CRM_JDE_Account_Number__c)); 
						update acct;
						update this.so; 
					}
					/*[WL 1.0] END*/
					
                    redirectPage = new PageReference('/' + soId);
                } catch (Exception e) {
                    showPageError(e.getMessage());
                }
            }
        } else {
            showPageError('The sales order does not belong to an account');
        }
        redirectPage = new PageReference('/' + soId);
        return redirectPage;
    }
    
    private void showPageMessage(ApexPages.Severity severity, String msg) { ApexPages.addMessage(new ApexPages.Message(severity, msg)); }
    private void showPageError(String msg) { showPageMessage(ApexPages.Severity.ERROR, msg); }

    public class SalesOrderCheckARException extends Exception {
        
    }
    
}