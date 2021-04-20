/********************************************************************************
* Test Class for LAT_BR_VFC13_NuevoAnalisisCredito
*
* NAME: LAT_BR_VFC13_NuevoAnalisisCredito_Test.cls
* AUTHOR: Mariano Boezio                           DATE: 20/09/2014
********************************************************************************/

@isTest
public with sharing class LAT_BR_VFC13_NuevoAnalisisCredito_Test {

    @testSetup
    public static void setup(){
        delete [SELECT Id FROM PRH_Iconic_Account_Trigger__c];
        LAT_WS_CustomerHandlerInterface_Test.testSetup();
        AP01_Account_BR_Test.createAccountFromScratch();
    }

    @istest
    static void BasicInitTest(){
        Analise_de_credito__c ac = basicData();
        
        Test.startTest();
            // No Analise de credito created for account
            ApexPages.StandardController sc = new ApexPages.standardController(new Analise_de_credito__c());
            LAT_BR_VFC13_NuevoAnalisisCredito nac = new LAT_BR_VFC13_NuevoAnalisisCredito(sc);
            nac.pageActionInit();

            // Check size of list for initial condition
            system.assertEquals(nac.salesPrevission.size(), 1);
            system.assertEquals(nac.salesPrevissionAnt.size(), 1);
            system.assertEquals(nac.CISPInfo.size(), 1); 
            system.assertEquals(nac.suppliers.size(), 1); 
            system.assertEquals(nac.billingProposal.size(), 4); // One for each qurter
            system.assertEquals(nac.ClientBehaviors.size(), 1); // No ClientBehavior created
            system.assertEquals(nac.clientB.size(), 1); // No ClientBehavior created

            ApexPages.CurrentPage().getparameters().put('id', ac.id);
            sc = new ApexPages.standardController(ac);
            nac = new LAT_BR_VFC13_NuevoAnalisisCredito(sc);
            nac.pageActionInit();

            // Check size of list for edit condition
            system.assertEquals(nac.salesPrevission.size(), 1);
            //system.assertEquals(nac.salesPrevissionAnt.size(), 1);
            system.assertEquals(nac.CISPInfo.size(), 1);  
            system.assertEquals(nac.suppliers.size(), 1); 
            system.assertEquals(nac.billingProposal.size(), 4); // One for each qurter
            system.assertEquals(nac.ClientBehaviors.size(), 1); // No ClientBehavior created
            system.assertEquals(nac.clientB.size(), 1); // No ClientBehavior created
        Test.stopTest();
     }
     
    @istest
    static void PerPageInitTest(){
        Analise_de_credito__c ac = basicData();
        
        Test.startTest();
            ApexPages.CurrentPage().getparameters().put('id', ac.id);
            ApexPages.StandardController sc = new ApexPages.standardController(ac);
            LAT_BR_VFC13_NuevoAnalisisCredito nac = new LAT_BR_VFC13_NuevoAnalisisCredito(sc);
            nac.pageActionInit();

            // Check loading for diferent pages on layout
            PageReference pr = new PageReference('/apex/LAT_BR_VFP14_SalesForecastSection');
            Test.setCurrentPageReference(pr);
            nac = new LAT_BR_VFC13_NuevoAnalisisCredito(sc);
            nac.pageActionInit();
            system.assertEquals(nac.salesPrevission.size(), 1);
            system.assertEquals(nac.suppliers.size(), 0);
            
            pr = new PageReference('/apex/LAT_BR_VFP15_ProposedBilling');
            Test.setCurrentPage(pr);
            nac = new LAT_BR_VFC13_NuevoAnalisisCredito(sc);
            nac.pageActionInit();
            system.assertEquals(nac.salesPrevission.size(), 0);
            
            pr = new PageReference('/apex/LAT_BR_VFP16_ClientBehavior');
            Test.setCurrentPage(pr);
            nac = new LAT_BR_VFC13_NuevoAnalisisCredito(sc);
            nac.pageActionInit();
            system.assertEquals(nac.ClientBehaviors.size(), 1);
            system.assertEquals(nac.suppliers.size(), 0);
            
            pr = new PageReference('/apex/LAT_BR_VFC17_LargestSuppliers');
            Test.setCurrentPage(pr);
            nac = new LAT_BR_VFC13_NuevoAnalisisCredito(sc);
            nac.pageActionInit();
            system.assertEquals(nac.suppliers.size(), 0);
            system.assertEquals(nac.CISPInfo.size(), 0);
            
            pr = new PageReference('/apex/LAT_BR_VFC18_CISPInformation');
            Test.setCurrentPage(pr);
            nac = new LAT_BR_VFC13_NuevoAnalisisCredito(sc);
            nac.pageActionInit();
            system.assertEquals(nac.CISPInfo.size(), 0);
            system.assertEquals(nac.suppliers.size(), 0);
            
            pr = new PageReference('/apex/LAT_BR_VFP19_PreviousSalesForecast');
            Test.setCurrentPage(pr);
            nac = new LAT_BR_VFC13_NuevoAnalisisCredito(sc);
            nac.pageActionInit();
            system.assertEquals(nac.salesPrevission.size(), 1);
            system.assertEquals(nac.suppliers.size(), 0);
        Test.stopTest();
     }
     
    @istest
    static void SaveTest(){
        
        Analise_de_credito__c ac = LAT_BR_VFC13_NuevoAnalisisCredito_Test.basicData();
        
        Test.startTest();
            // No Analise de credito created for account
            ApexPages.StandardController sc = new ApexPages.standardController(new Analise_de_credito__c());
            LAT_BR_VFC13_NuevoAnalisisCredito nac = new LAT_BR_VFC13_NuevoAnalisisCredito(sc);
            nac.pageActionInit();
            nac.saveAll();
            
            // Analise de credito created for account
            ApexPages.CurrentPage().getparameters().put('id', ac.id);
            sc = new ApexPages.standardController(ac);
            nac = new LAT_BR_VFC13_NuevoAnalisisCredito(sc);
            nac.pageActionInit();
            nac.salesPrevission.add(new LAT_BR_CreditAnalisisUtils.PrevisaoDeVendas('Test', 10, 10, new LAT_BR_SalesPredictionDAO()));
            nac.saveAll();
            
            List<LAT_BR_SalesPredictionDAO> baDaoList = LAT_BR_SalesPredictionDAO.getListSalesPredictionPerAC(ac.id);
            List<LAT_BR_Billing_ProposalDAO> bpDaoList = LAT_BR_Billing_ProposalDAO.getListbillingProposalPerAC(ac.id);
            system.assertEquals(baDaoList.size(), 1);
            system.assertEquals(bpDaoList.size(), 1);

            
            // Check everything is the same if we do a second save
            nac.saveAll();
            baDaoList = LAT_BR_SalesPredictionDAO.getListSalesPredictionPerAC(ac.id);
            bpDaoList = LAT_BR_Billing_ProposalDAO.getListbillingProposalPerAC(ac.id);
            system.assertEquals(baDaoList.size(), 1);
            system.assertEquals(bpDaoList.size(), 1);

            LAT_Utils.testOn = true;
            nac.saveAll();
            
            
        Test.stopTest();
     }
     
    @istest
    static void addMethodsTest(){
        
            Analise_de_credito__c ac = LAT_BR_VFC13_NuevoAnalisisCredito_Test.basicData();
        
            Test.startTest();
            // No Analise de credito created for account
            ApexPages.StandardController sc = new ApexPages.standardController(new Analise_de_credito__c());
            LAT_BR_VFC13_NuevoAnalisisCredito nac = new LAT_BR_VFC13_NuevoAnalisisCredito(sc);
            nac.pageActionInit();

            // Initial condition
            system.assertEquals(nac.salesPrevission.size(), 1);
            system.assertEquals(nac.salesPrevissionAnt.size(), 1);
            system.assertEquals(nac.suppliers.size(), 1);
            system.assertEquals(nac.CISPInfo.size(), 1);
            
            nac.addPrevisaoDeVendas();
            nac.addPrevisaoDeVendasAnt();
            nac.addDetalhesMaioresFornecedore();
            nac.addCISPInfo();
            
            system.assertEquals(nac.salesPrevission.size(), 2);
            system.assertEquals(nac.salesPrevissionAnt.size(), 2);
            system.assertEquals(nac.suppliers.size(), 2);
            system.assertEquals(nac.CISPInfo.size(), 2);
            
            
            // Covering get picklist values
            nac.getSKUPFY();
            nac.getCISPInfoSO();
            nac.getQuarters();

            nac.retryBi();
            nac.salesPrevissionAnt = new List<LAT_BR_CreditAnalisisUtils.PrevisaoDeVendas>();
            nac.retryBi();
            nac.accId = ac.Conta__c;
            nac.newCreditApex();
            nac.getRecordsBasedOnObject('Analise_de_credito__c','Conta__c');
            nac.isMobile = true;
            nac.cancel();
            

            Test.stopTest();
     }

    @istest
    static void addMethodsTestB(){
        
            Analise_de_credito__c ac = LAT_BR_VFC13_NuevoAnalisisCredito_Test.basicData();
        
            Test.startTest();
            // No Analise de credito created for account
            ApexPages.StandardController sc = new ApexPages.standardController(new Analise_de_credito__c());
            LAT_BR_VFC13_NuevoAnalisisCredito nac = new LAT_BR_VFC13_NuevoAnalisisCredito(sc);
            nac.pageActionInit();

            // Initial condition
            system.assertEquals(nac.salesPrevission.size(), 1);
            system.assertEquals(nac.salesPrevissionAnt.size(), 1);
            system.assertEquals(nac.suppliers.size(), 1);
            system.assertEquals(nac.CISPInfo.size(), 1);
            
            nac.addPrevisaoDeVendas();
            nac.addPrevisaoDeVendasAnt();
            nac.addDetalhesMaioresFornecedore();
            nac.suppliers.add(new LAT_BR_CreditAnalisisUtils.DetalhesMaioresFornecedore(false, 'TEST', 0, 0, 0, new LAT_BR_Further_Suppliers_DetailDAO()));
            Account accBr = LAT_Account_TestFactory.getAccountOffTradeBraComplete();
            accBr.CNPJ__c = '24951131000112';
            insert accBr;
            LAT_BR_CreditAnalisisUtils.upsertSupliers(nac.suppliers,ac.Id);
            nac.addCISPInfo();
            
            system.assertEquals(nac.salesPrevission.size(), 2);
            system.assertEquals(nac.salesPrevissionAnt.size(), 2);
            system.assertEquals(nac.suppliers.size(), 3);
            system.assertEquals(nac.CISPInfo.size(), 2);
            
            
            // Covering get picklist values
            nac.getSKUPFY();
            nac.getCISPInfoSO();
            nac.getQuarters();

            nac.retryBi();
            nac.salesPrevissionAnt = new List<LAT_BR_CreditAnalisisUtils.PrevisaoDeVendas>();
            nac.retryBi();
            nac.accId = ac.Conta__c;
            nac.newCreditApex();
            ac.LAT_BR_Status__c = 'Draft';
            update ac;
            nac.newCreditApex();
            nac.getRecordsBasedOnObject('Analise_de_credito__c','Conta__c');
            nac.cancel();
            

            Test.stopTest();
     }
     
    @istest
    static void missingTest(){

        Analise_de_credito__c ac = LAT_BR_VFC13_NuevoAnalisisCredito_Test.basicDataNovoCadastro();
        
        Test.startTest();
            // No Analise de credito created for account
            ApexPages.StandardController sc = new ApexPages.standardController(new Analise_de_credito__c());
            LAT_BR_VFC13_NuevoAnalisisCredito nac = new LAT_BR_VFC13_NuevoAnalisisCredito(sc);
            nac.pageActionInit();

            ApexPages.CurrentPage().getparameters().put('id', ac.id);
            sc = new ApexPages.standardController(ac);
            nac = new LAT_BR_VFC13_NuevoAnalisisCredito(sc);
            nac.pageActionInit();
            
            nac.getCreatedbillingProposal();
            nac.removePrevisaoDeVendasAnt();
            nac.removePrevisaoDeVendas();

            ApexPages.CurrentPage().getparameters().put('revision', 'true');
            nac = new LAT_BR_VFC13_NuevoAnalisisCredito(sc);
            nac.pageActionInit();
            nac.retryBi();
            ApexPages.CurrentPage().getparameters().put('isInsert', 'true');
            nac = new LAT_BR_VFC13_NuevoAnalisisCredito(sc);
            nac.pageActionInit();
            nac.retryBi();
            
        Test.stopTest();
     }
    
    @istest
    static void missingTestB(){

        Analise_de_credito__c ac = LAT_BR_VFC13_NuevoAnalisisCredito_Test.basicDataNovoCadastro();
        
        Test.startTest();
            // No Analise de credito created for account
            ApexPages.StandardController sc = new ApexPages.standardController(new Analise_de_credito__c());
            LAT_BR_VFC13_NuevoAnalisisCredito nac = new LAT_BR_VFC13_NuevoAnalisisCredito(sc);
            nac.pageActionInit();

            ApexPages.CurrentPage().getparameters().put('id', ac.id);
            sc = new ApexPages.standardController(ac);
            nac = new LAT_BR_VFC13_NuevoAnalisisCredito(sc);
            nac.pageActionInit();
            
            nac.getCreatedbillingProposal();
            nac.removePrevisaoDeVendasAnt();
            nac.removePrevisaoDeVendas();

            ApexPages.CurrentPage().getparameters().put('revision', 'true');
            nac = new LAT_BR_VFC13_NuevoAnalisisCredito(sc);
            nac.pageActionInit();
            nac.retryBi();
            ApexPages.CurrentPage().getparameters().put('isInsert', 'true');
            nac = new LAT_BR_VFC13_NuevoAnalisisCredito(sc);
            nac.pageActionInit();
            nac.retryBi();
            nac.credIdParam = nac.ac.Id;
            nac.saveAndSendApproval();
            nac.sendApproval();
            nac.editCreditApex();

        Test.stopTest();
     }

     static Analise_de_credito__c basicData() {
        Account acc = [SELECT Id FROM Account LIMIT 1];
        Analise_de_credito__c ac = new Analise_de_credito__c();
        ac.Conta__c = acc.id;
        insert ac;

        LAT_BR_Behavior_AnalisisDAO dao = new LAT_BR_Behavior_AnalisisDAO();
        dao.setCreditAnalysis(ac.id);
        dao.setCustomerBehavior('Test Name');
        dao.setValue('20');
        dao.setWeight(10);
        List<LAT_BR_Behavior_AnalisisDAO> daoList = new List<LAT_BR_Behavior_AnalisisDAO>{dao};
        LAT_BR_Behavior_AnalisisDAO.upsertList(daoList);

        LAT_BR_Billing_ProposalDAO bpdao = new LAT_BR_Billing_ProposalDAO();
        bpdao.setCreditAnalysis(ac.id);
        bpdao.setPreviousFY(false);
        bpdao.setQuarter('Test Quarter');
        bpdao.setValue(10);
        bpdao.setFY(20);
        List<LAT_BR_Billing_ProposalDAO> bpdaoList = new List<LAT_BR_Billing_ProposalDAO>{bpdao};
        LAT_BR_Billing_ProposalDAO.upsertList(bpdaoList);

        LAT_BR_SalesPredictionDAO spdao = new LAT_BR_SalesPredictionDAO();
        spdao.setCreditAnalisis(ac.id);
        spdao.setPreviousFY(false);
        spdao.setPrice(10);
        spdao.setSKU('Test SKU');
        spdao.setCA(1);
        List<LAT_BR_SalesPredictionDAO> spdaoList = new List<LAT_BR_SalesPredictionDAO>{spdao};
        LAT_BR_SalesPredictionDAO.upsertList(spdaoList);
        
        LAT_BR_CustomerBehaviorDAO cbdao = new LAT_BR_CustomerBehaviorDAO();
        cbdao.setName('Test Name');
        cbdao.setValue('20');
        cbdao.setWeight(20);
        List<LAT_BR_CustomerBehaviorDAO> cbdaoList = new List<LAT_BR_CustomerBehaviorDAO>{cbdao};
        LAT_BR_CustomerBehaviorDAO.upsertList(cbdaoList);
        
        return ac;
     }

     static Analise_de_credito__c basicDataNovoCadastro() {
        Account acc = [SELECT Id FROM Account LIMIT 1];
        
        Analise_de_credito__c ac = new Analise_de_credito__c();
        ac.Conta__c = acc.id;
        insert ac;

        LAT_BR_Behavior_AnalisisDAO dao = new LAT_BR_Behavior_AnalisisDAO();
        dao.setCreditAnalysis(ac.id);
        dao.setCustomerBehavior('Test Name');
        dao.setValue('20');
        dao.setWeight(10);
        List<LAT_BR_Behavior_AnalisisDAO> daoList = new List<LAT_BR_Behavior_AnalisisDAO>{dao};
        LAT_BR_Behavior_AnalisisDAO.upsertList(daoList);

        LAT_BR_Billing_ProposalDAO bpdao = new LAT_BR_Billing_ProposalDAO();
        bpdao.setCreditAnalysis(ac.id);
        bpdao.setPreviousFY(false);
        bpdao.setQuarter('Test Quarter');
        bpdao.setValue(10);
        bpdao.setFY(20);
        List<LAT_BR_Billing_ProposalDAO> bpdaoList = new List<LAT_BR_Billing_ProposalDAO>{bpdao};
        LAT_BR_Billing_ProposalDAO.upsertList(bpdaoList);

        LAT_BR_SalesPredictionDAO spdao = new LAT_BR_SalesPredictionDAO();
        spdao.setCreditAnalisis(ac.id);
        spdao.setPreviousFY(false);
        spdao.setPrice(10);
        spdao.setSKU('Test SKU');
        spdao.setCA(1);
        List<LAT_BR_SalesPredictionDAO> spdaoList = new List<LAT_BR_SalesPredictionDAO>{spdao};
        LAT_BR_SalesPredictionDAO.upsertList(spdaoList);
        
        LAT_BR_CustomerBehaviorDAO cbdao = new LAT_BR_CustomerBehaviorDAO();
        cbdao.setName('Test Name');
        cbdao.setValue('20');
        cbdao.setWeight(20);
        List<LAT_BR_CustomerBehaviorDAO> cbdaoList = new List<LAT_BR_CustomerBehaviorDAO>{cbdao};
        LAT_BR_CustomerBehaviorDAO.upsertList(cbdaoList);
        
        return ac;
     }
}