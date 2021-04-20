@isTest
private class LAT_ContractCoverPDFController_Test {
	
	@isTest static void test_method_one() {
        LAT_ContractDocumentsPDFController objContractDocumentsPDFController = null;
        User u = LAT_ContractsWS_Test.getLAT_BR2Vendas();
        LAT_ContractsWS_Test.setup(u);
		LAT_Contract2__c con = LAT_ContractsWS_Test.getContract();
		test.startTest();
		con.Status__c = 'Aprovado';
		insert con;
		system.CurrentPageReference().getParameters().put('id',con.id);
        system.CurrentPageReference().getParameters().put('type','Test');
        new LAT_ContractCoverPDFController();
        
        objContractDocumentsPDFController = new LAT_ContractDocumentsPDFController();        
        objContractDocumentsPDFController.convertTags('',con.id);
		test.stopTest();
		// Implement test code
	}

	@isTest static void test_method_two() {
        User u = LAT_ContractsWS_Test.getLAT_BR2Vendas();
        LAT_ContractsWS_Test.setup(u);
		LAT_Contract2__c con = LAT_ContractsWS_Test.getContract();
		test.startTest();
		con.RecordtypeId = Global_RecordTypeCache.getRtId('LAT_Contract2__c'+'LAT_Eventos_Contrato_de_Parceria');
		con.Status__c = 'Aprovado';
		insert con;
		system.CurrentPageReference().getParameters().put('id',con.id);
        system.CurrentPageReference().getParameters().put('type','Test');
        
		new LAT_ContractCoverPDFController();
		test.stopTest();
		// Implement test code
    }
    
    @isTest 
    private static void testContractAcordoPDF() {
        User objUserVendas = null;
        LAT_Contract2__c objContract = null;
        LAT_ContractCoverPDFController objController = null;
        LAT_ContractVolume__c objContractVolume = null;
        
        objUserVendas = LAT_ContractsWS_Test.getLAT_BR2Vendas();
        LAT_ContractsWS_Test.setup(objUserVendas);
        objContract = LAT_ContractsWS_Test.getContract();
 
        Test.startTest();
        try {
            objContract.Status__c = 'Aprovado';
            
            insert objContract;

            objContractVolume = LAT_ContractsWS_Test.getContractVolume(objContract.id);
            objContractVolume.RecordtypeId = Schema.SObjectType.LAT_ContractVolume__c.getRecordTypeInfosByDeveloperName().get('LAT_BR_Acordo_Category').getRecordTypeId();

            insert objContractVolume;

            System.CurrentPageReference().getParameters().put('id', objContract.id);
            System.CurrentPageReference().getParameters().put('type','acordo');
            
            objController = new LAT_ContractCoverPDFController();
        } catch(Exception Ex) {
            
        }
		Test.stopTest();
    }	

    @isTest 
    private static void testContractDistribuidorTest() {
        User objUserVendas = null;
        LAT_Contract2__c objContract = null;
        LAT_DistributorAgreementController objController = null;
        LAT_ContractVolume__c objContractVolume = null;
        
        objUserVendas = LAT_ContractsWS_Test.getLAT_BR2Vendas();
        LAT_ContractsWS_Test.setup(objUserVendas);
        objContract = LAT_ContractsWS_Test.getContract();
 
        Test.startTest();
        try {
            objContract.Status__c = 'Aprovado';
            objContract.RecordTypeId = Schema.SObjectType.LAT_ContractVolume__c.getRecordTypeInfosByDeveloperName().get('LAT_BR_Acordo_Category').getRecordTypeId();
            insert objContract;

            objContractVolume = LAT_ContractsWS_Test.getContractVolume(objContract.id);
            objContractVolume.RecordtypeId = Schema.SObjectType.LAT_ContractVolume__c.getRecordTypeInfosByDeveloperName().get('LAT_Eventos_Contrato_de_Parceria_Distribuidor').getRecordTypeId();

            insert objContractVolume;

            System.CurrentPageReference().getParameters().put('contractId', objContract.id);
            System.CurrentPageReference().getParameters().put('type','acordo');
            
            objController = new LAT_DistributorAgreementController();
        } catch(Exception Ex) {
            
        }
		Test.stopTest();
    }	
    
    
}