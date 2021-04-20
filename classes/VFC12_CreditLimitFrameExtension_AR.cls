/**************************************************************************
 Dev: Juan Pablo Cubo		Version: 1
  This extension is for a page that's shown on the opportunity layout, the
 requirement is that the value for credit limit balance is recalculated
 every time the user views the opportunity.
***************************************************************************/
/********************************************************************************
*                       
* MIGRACION LICENCIAS 
* AUTHOR: ZIMMIC                     DATE: 07/11/2016
*
********************************************************************************/

public with sharing class VFC12_CreditLimitFrameExtension_AR {

    public Opportunity opp {get; set;}
    public LAT_Opportunity__c LAT_opp {get; set;}

    public VFC12_CreditLimitFrameExtension_AR(ApexPages.Standardcontroller controller) {
        if(!Utils.wasMigrationDone('6')) {  
            opp = [SELECT Id, Amount, CreditLimitBalance_AR__c, AccountId, Account.Credit_line__c, Account.ParentId, Account.Parent.Credit_line__c FROM Opportunity WHERE Id =: controller.getId()];
        }
        //MIGRATED 07/11/2016
        else {
            LAT_opp = [SELECT Id, LAT_Amount__c, LAT_AR_CreditLimitBalance__c, LAT_Account__c, LAT_Account__r.Credit_line__c, LAT_Account__r.ParentId, LAT_Account__r.Parent.Credit_line__c FROM LAT_Opportunity__c WHERE Id =: controller.getId()];
        }
    }
    
    public Pagereference calculateCreditLimit() {
        if(!Utils.wasMigrationDone('6')) {    	
        	Decimal creditLine = 0;
        	Id parentAccId;
        	if(opp.Account != null){
    	    	if(opp.Account.parentId != null){
    	    		parentAccId = opp.Account.parentId;
    	    		if(opp.Account.Parent.Credit_line__c != null){
    	    			creditLine = opp.Account.Parent.Credit_line__c;
    	    		}
    	    	}else{
    	    		parentAccId = opp.AccountId;
    	    		if(opp.Account.Credit_line__c != null){
    	    			creditLine = opp.Account.Credit_line__c;
    	    		}
    	    	}
        	}
        	
        	Decimal deudaTotal = 0;
        	Set<Id> setRecTypeOpp = Global_RecordTypeCache.getRtIdSet('Titulos__c', new set<String>{'Standard_AR', 'Standard_UY'});
        	for (Titulos__c titulo : [SELECT Id, valorSaldo__c FROM Titulos__c WHERE Cliente__c =: opp.AccountId AND valorSaldo__c!=NULL AND RecordTypeId IN: setRecTypeOpp]) {
        		if (titulo.valorSaldo__c != null) {
                    deudaTotal += titulo.valorSaldo__c;
                }
        	}
        	
        	Decimal sumaPedidos = 0;
        	for (OpportunityLineItem oli : [SELECT Id, TotalPrice FROM OpportunityLineItem WHERE (Opportunity.AccountId =: parentAccId OR Opportunity.Account.ParentId =:parentAccId) AND cd_line_status__c != '999' AND TotalPrice!=null]) {
        		if (oli.TotalPrice != null) {
                    sumaPedidos += oli.TotalPrice;
        	    }
            }
        	
        	Decimal oppAmount = opp.Amount == null ? 0 : opp.Amount;
        	
        	opp.CreditLimitBalance_AR__c = creditLine - deudaTotal - sumaPedidos + oppAmount;
    		try{update opp;}catch(Exception e){system.debug('----->' + e);}
    		
        	return null;
        }
        //MIGRATED 07/11/2016
        else {
            Decimal creditLine = 0;
            Id parentAccId;
            if(LAT_opp.LAT_Account__c != null){
                if(LAT_opp.LAT_Account__r.parentId != null){
                    parentAccId = LAT_opp.LAT_Account__r.parentId;
                    if(LAT_opp.LAT_Account__r.Parent.Credit_line__c != null){
                        creditLine = LAT_opp.LAT_Account__r.Parent.Credit_line__c;
                    }
                }else{
                    parentAccId = LAT_opp.LAT_Account__c;
                    if(LAT_opp.LAT_Account__r.Credit_line__c != null){
                        creditLine = LAT_opp.LAT_Account__r.Credit_line__c;
                    }
                }
            }
            
            Decimal deudaTotal = 0;
            Set<Id> setRecTypeOpp = Global_RecordTypeCache.getRtIdSet('Titulos__c', new set<String>{'Standard_AR', 'Standard_UY'});
            for (Titulos__c titulo : [SELECT Id, valorSaldo__c FROM Titulos__c WHERE Cliente__c =: LAT_opp.LAT_Account__c AND valorSaldo__c!=NULL AND RecordTypeId IN: setRecTypeOpp]) {
                if (titulo.valorSaldo__c != null) {
                    deudaTotal += titulo.valorSaldo__c;
                }
            }
            
            Decimal sumaPedidos = 0;
            for (LAT_OpportunityLineItem__c oli : [SELECT Id, LAT_TotalPrice__c FROM LAT_OpportunityLineItem__c WHERE (LAT_Opportunity__r.LAT_Account__c =: parentAccId OR LAT_Opportunity__r.LAT_Account__r.ParentId =:parentAccId) AND LAT_CdLineStatus__c != '999' AND LAT_TotalPrice__c!=null]) {
                if (oli.LAT_TotalPrice__c != null) {
                    sumaPedidos += oli.LAT_TotalPrice__c;
                }
            }
            
            Decimal oppAmount = LAT_opp.LAT_Amount__c == null ? 0 : LAT_opp.LAT_Amount__c;
            
            LAT_opp.LAT_AR_CreditLimitBalance__c = creditLine - deudaTotal - sumaPedidos + oppAmount;
            try{update LAT_opp;}catch(Exception e){system.debug('----->' + e);}
            
            return null;            
        }
    }
	
}