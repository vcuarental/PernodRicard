/**************************************************************************
*   Company:Valuenet    Developers:Waldemar Mayo		Date:13/03/2014   *
**************************************************************************/

@isTest//(SeeAllData=true)
public with sharing class LAT_PCS01_BatchOrderToStdPricebook_TEST {
	
	static testMethod void unitTest(){
		
		set<Id> setRTsLATAM = Global_RecordTypeCache.getRtIdSet('Opportunity', new set<String>{'Nova_oportunidade', 'Bloqueia_alteracao_do_cabecalho', 'Bloqueia_alteracao', 'OPP_1_NewOrder_ARG', 'OPP_2_NewOrder_URU', 'OPP_3_HeaderBlocked_ARG', 'OPP_4_HeaderBlocked_URU', 'OPP_5_OrderBlocked_ARG', 'OPP_6_OrderBlocked_URU', 'LAT_MX_OPP_HeaderBlocked','LAT_MX_OPP_NewOrder','LAT_MX_OPP_OrderBlocked'});
		
		Account acc = LAT_Account_TestFactory.getBRAAccountBase('Off_Trade');
        insert acc;

		//Cria novo catalogo
		Pricebook2 pricebook = new Pricebook2();
		pricebook.Name = acc.Price_Group__c;
		pricebook.IsActive = true;
		insert pricebook;

		//Cria um novo produto
		Product2 produto = new Product2();
		produto.Name = 'Cloud2b';
		produto.IsActive = true;
		produto.CD_Unit__c = 'UN';
		produto.SKU__c = '35';
		produto.Country__c = 1;
		produto.Group__c = acc.Price_Group__c;
		produto.Internal_id__c = produto.Group__c+'-'+produto.SKU__c;//+'-'+produto.cd_payment_term__c;
		produto.RecordTypeId = RecordTypeForTest.getRecType( 'Product2' , 'BRA_Standard' );
		insert produto;

		PricebookEntry entradaCatalogoPreco = new PricebookEntry();
		entradaCatalogoPreco.Pricebook2Id = Test.getStandardPricebookId();
		entradaCatalogoPreco.Product2Id = produto.Id;
		entradaCatalogoPreco.UnitPrice = 1000.00;
		entradaCatalogoPreco.IsActive = true;
		entradaCatalogoPreco.UseStandardPrice = false;
      	insert entradaCatalogoPreco;
		
		//Cria nova entrada de catalogo
		/*PricebookEntry pbe = new PricebookEntry();
		pbe.Pricebook2Id = pricebook.Id;  
		pbe.Product2Id = produto.Id;
		pbe.UnitPrice = 100.00;
		pbe.IsActive = true;
		pbe.UseStandardPrice = false;
		insert pbe;*/
		
		//Inicializa as listas e maps.
		String idOpportunity = RecordTypeForTest.getRecType('Opportunity','Nova_oportunidade');
		//Cria nova oportunidade.
		Opportunity opp = new Opportunity();
		opp.Name = 'Opp TESTE COTA';
		opp.closeDate = System.today()+1;
		opp.AccountId = acc.Id;
		opp.StageName = 'Novo Pedido';
		opp.NR_customer_order__c = '34525';
		opp.Freight__c = 'F';
		opp.NR_order_JDE__c = '12345';
		opp.CD_order_status__c = 1;
		opp.RecordTypeId = idOpportunity;
		insert opp;

		//Cria um novo produto da oportunidade.
		/*OpportunityLineItem oli = new OpportunityLineItem();
		oli.PricebookEntryId = pbe.Id;
		oli.OpportunityId    = opp.Id;
		oli.UnitPrice        = 12;
		oli.Quantity         = 12;
		oli.cd_line_status__c = '500';
		insert oli;*/
 
		//Opportunity opp;
		//try{opp = [SELECT Id FROM Opportunity WHERE Pricebook2.isStandard = false AND Amount >: 0 AND RecordTypeId IN: setRTsLATAM LIMIT 1];}catch(Exception e){}
		
		LAT_PCS01_BatchOrderToStdPricebook bat = new LAT_PCS01_BatchOrderToStdPricebook();
		bat.idsOpp = new set<Id>{opp.Id};
		
		test.startTest();
		Database.executeBatch(bat, 1);
		test.stopTest();
	}
	
}