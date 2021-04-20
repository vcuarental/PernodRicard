/***************************************************************************************************************************
 * Name:        ASI_MFM_CAP_GeneratePaymentExtension
 * Description: Extension Class to manually generate Payment in Detail button 
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 2018-10-18       Laputa                  Created
 ****************************************************************************************************************************/
 
 public with sharing class ASI_MFM_CAP_GeneratePaymentExtension {
 	
 	private final ASI_MFM_PO__c po;
	private string retURL = '';
	public Boolean showError {get;set;}{showError = false;}
    public String ErrorMessage {get;set;}
	
	
 	public ASI_MFM_CAP_GeneratePaymentExtension(ApexPages.StandardController controller){
 		this.po = (ASI_MFM_PO__c)controller.getRecord();
	}
    
    public PageReference generatePaymentFromPage(){
    	retURL = ApexPages.currentPage().getParameters().get('retURL');
    	ASI_MFM_Payment__c generatedpPayment;
        if(retURL == null) {
        	retURL = '/';
        }
        generatedpPayment = ASI_MFM_CAP_HK_PaymentGeneration.GeneratePaymentFromPO(po);

        if (generatedpPayment == null || showError){return null;} else {return new PageReference('/' + generatedpPayment.Id);}
    		
    }
}