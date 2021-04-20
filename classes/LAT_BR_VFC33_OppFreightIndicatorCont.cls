public with sharing class LAT_BR_VFC33_OppFreightIndicatorCont {

	public String percent {get;set;}
	public String color {get;set;}

	public LAT_BR_VFC33_OppFreightIndicatorCont(ApexPages.standardController controller) {
		LAT_Opportunity__c opp = [SELECT id, LAT_Freight_Formula__c, LAT_FreightFormulaDisplay__c  FROM LAT_Opportunity__c WHERE id =: controller.getRecord().Id];
		percent = String.valueOf(opp.LAT_FreightFormulaDisplay__c);
		color = opp.LAT_Freight_Formula__c;
	}
}