@isTest
public with sharing class LAT_BR_BTN01_CloseVisitValidation_Test {
	static testMethod void UnitTest1() {
		Account acc = Lat_Account_TestFactory.getAccountOnTradeBraComplete();
        insert acc;

        Planejamento__c planejamiento = new Planejamento__c(
            Ano_de_Referencia__c='2013',
            M_s_de_Ref_rencia__c= 'Julho',
            Name='Test 1',
            RecordTypeId =  Global_RecordTypeCache.getRtId('Planejamento__c' + 'PLV_Standard_AR')
        );
        insert planejamiento;

		Visitas__c visit = new Visitas__c(
            Conta__c = acc.id,
            Planejamento__c = planejamiento.id,
            Hora_da_Visita__c = '05:00',
            Resumo_da_Visita__c = 'asd',
            RecordTypeId = Global_RecordTypeCache.getRtId('Visitas__c' + 'VTS_Standard_AR')
        );
        insert visit;

        Test.startTest();
        String res = null;
        res = LAT_BR_BTN01_CloseVisitValidations.serviceName(null);
        res = LAT_BR_BTN01_CloseVisitValidations.serviceName(visit.Id);

        Test.stopTest();

	}
}