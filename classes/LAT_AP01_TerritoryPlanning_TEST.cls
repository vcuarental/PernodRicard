/******************************************************************************
*    Company:Valuenet     Developers:Denis Aranda        Date:26/02/2014      *
*******************************************************************************/

@istest
public with sharing class LAT_AP01_TerritoryPlanning_TEST {
	static testMethod void unitTest() {
		
		Planejamento__c plan0 = new Planejamento__c(Name = 'Test0', Ano_de_Referencia__c = '2012', M_s_de_Ref_rencia__c = 'Dezembro', Solicitar_aprova_o_para__c = 'Planejamento semana 2', Aprovado_semana_1__c = true, RecordTypeId = Global_RecordTypeCache.getRtId('Planejamento__c'+'BRA_Standard' ));
		insert plan0;
		
		LAT_BR_TPL_TerritoryPlanning__c ter = new LAT_BR_TPL_TerritoryPlanning__c(
        	LAT_BR_VisitPlanning__c = plan0.Id,
        	LAT_BR_TerritoryPlanning__c = 'Passport'
        );
        insert ter;
        
        LAT_BR_TPL_TerritoryPlanning__c ter2 = new LAT_BR_TPL_TerritoryPlanning__c(
        	LAT_BR_VisitPlanning__c = plan0.Id,
        	LAT_BR_TerritoryPlanning__c = 'Passport'
        );
        try{ insert ter2; }catch(exception e){}
        
        List<LAT_BR_TPL_TerritoryPlanning__c> listTer = new List<LAT_BR_TPL_TerritoryPlanning__c>(); 
        
        LAT_BR_TPL_TerritoryPlanning__c ter3 = new LAT_BR_TPL_TerritoryPlanning__c(
        	LAT_BR_VisitPlanning__c = plan0.Id,
        	LAT_BR_TerritoryPlanning__c = 'Teachers'
        );
        listTer.add(ter3);
        
        LAT_BR_TPL_TerritoryPlanning__c ter4 = new LAT_BR_TPL_TerritoryPlanning__c(
        	LAT_BR_VisitPlanning__c = plan0.Id,
        	LAT_BR_TerritoryPlanning__c = 'Teachers'
        );
        listTer.add(ter4);
        try{ insert listTer; }catch(exception e){}
	}
}