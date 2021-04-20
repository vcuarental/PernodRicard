/********************************************************************************
* Test Class for LAT_BR_Behavior_AnalisisDAO, LAT_BR_Billing_ProposalDAO, 
* LAT_BR_CISP_InformationDAO, LAT_BR_CustomerBehaviorDAO, 
* LAT_BR_Further_Suppliers_DetailDAO, LAT_BR_SalesPredictionDAO
*
* NAME: LAT_BR_CreditAnalysisDAO_Test .cls
* AUTHOR: Mariano Boezio                           DATE: 19/09/2014
********************************************************************************/

@isTest
public with sharing class LAT_BR_CreditAnalysisDAO_Test {

    static testMethod void LAT_BR_Behavior_AnalisisDAOTest(){
        Account acc = LAT_Account_TestFactory.getBRAAccountBase('Off_Trade');
        insert acc;
        
        Analise_de_credito__c ac = new Analise_de_credito__c();
        ac.Conta__c = acc.id;
        insert ac;
        
        Test.startTest();
            LAT_BR_Behavior_AnalisisDAO dao = new LAT_BR_Behavior_AnalisisDAO();
            dao.setCreditAnalysis(ac.id);
            dao.setCustomerBehavior('Test CC');
            dao.setValue('Test Value');
            dao.setWeight(10);
            dao.setInstance(dao.getInstance());
            
            List<LAT_BR_Behavior_AnalisisDAO> daoList = new List<LAT_BR_Behavior_AnalisisDAO>{dao};
            LAT_BR_Behavior_AnalisisDAO.upsertList(daoList);
            LAT_BR_Behavior_AnalisisDAO.getListBehaviorAnalisisPerACPerBehavior(ac.id);
            
            System.assertEquals(dao.getCreditAnalysis(), ac.id);
            System.assertEquals(dao.getCustomerBehavior(), 'Test CC');
            System.assertEquals(dao.getValue(), 'Test Value');
            System.assertEquals(dao.getWeight(), 10);
        Test.stopTest();
    }
    
    static testMethod void LAT_BR_Billing_ProposalDAOTest(){
        Account acc = LAT_Account_TestFactory.getBRAAccountBase('Off_Trade');
        insert acc;
        
        Analise_de_credito__c ac = new Analise_de_credito__c();
        ac.Conta__c = acc.id;
        insert ac;
        
        Test.startTest();
            LAT_BR_Billing_ProposalDAO dao = new LAT_BR_Billing_ProposalDAO();
            dao.setCreditAnalysis(ac.id);
            dao.setPreviousFY(false);
            dao.setQuarter('Test Quarter');
            dao.setValue(10);
            dao.setFY(20);
            dao.setInstance(dao.getInstance());
            
            List<LAT_BR_Billing_ProposalDAO> daoList = new List<LAT_BR_Billing_ProposalDAO>{dao};
            LAT_BR_Billing_ProposalDAO.getPicklistQuarter();
            LAT_BR_Billing_ProposalDAO.upsertList(daoList);
            LAT_BR_Billing_ProposalDAO.getListBillingProposalPerAC(ac.id);
            
            System.assertEquals(dao.getCreditAnalysis(), ac.id);
            System.assertEquals(dao.getPreviousFY(), false);
            System.assertEquals(dao.getValue(), 10);
            System.assertEquals(dao.getFY(), 20);
        Test.stopTest();
    }
    
    static testMethod void LAT_BR_CISP_InformationDAOTest(){
        Account acc = LAT_Account_TestFactory.getBRAAccountBase('Off_Trade');
        insert acc;
        
        Analise_de_credito__c ac = new Analise_de_credito__c();
        ac.Conta__c = acc.id;
        insert ac;
        
        Test.startTest();
            LAT_BR_CISP_InformationDAO dao = new LAT_BR_CISP_InformationDAO();
            dao.setCreditAnalysis(ac.id);
            dao.setCompany('Test Company');
            dao.setCISPI('Test CISPI');
            dao.setData(Date.Today());
            dao.setGreaterAccum(20);
            dao.setLimitValue(1);
            dao.setOrdination(10);
            dao.setInstance(dao.getInstance());
            
            List<LAT_BR_CISP_InformationDAO> daoList = new List<LAT_BR_CISP_InformationDAO>{dao};
            LAT_BR_CISP_InformationDAO.getPicklistCISPInfo();
            LAT_BR_CISP_InformationDAO.upsertList(daoList);
            LAT_BR_CISP_InformationDAO.getListcispInfonalisisPerAC(ac.id);
            
            System.assertEquals(dao.getCreditAnalysis(), ac.id);
            System.assertEquals(dao.getCompany(), 'Test Company');
            System.assertEquals(dao.getCISPI(), 'Test CISPI');
            System.assertEquals(dao.getData(), Date.today());
            System.assertEquals(dao.getGreaterAccum(), 20);
            System.assertEquals(dao.getLimitValue(), 1);
            System.assertEquals(dao.getOrdination(), 10);
        Test.stopTest();
    }
    
    static testMethod void LAT_BR_Further_Suppliers_DetailDAOTest(){
        Account acc = LAT_Account_TestFactory.getBRAAccountBase('Off_Trade');
        insert acc;
        
        Analise_de_credito__c ac = new Analise_de_credito__c();
        ac.Conta__c = acc.id;
        insert ac;
        
        Test.startTest();
            LAT_BR_Further_Suppliers_DetailDAO dao = new LAT_BR_Further_Suppliers_DetailDAO();
            dao.setCreditAnalysis(ac.id);
            dao.setAssociate(false);
            dao.setAssocName('Test Assoc');
            dao.setCreditLimit(20);
            dao.setCurrentDebit(10);
            dao.setHigherAccumulation(1);
            dao.setInstance(dao.getInstance());
            
            List<LAT_BR_Further_Suppliers_DetailDAO> daoList = new List<LAT_BR_Further_Suppliers_DetailDAO>{dao};
            LAT_BR_Further_Suppliers_DetailDAO.upsertList(daoList);
            LAT_BR_Further_Suppliers_DetailDAO.getListsupliersDetailnalisisPerAC(ac.id);
            
            System.assertEquals(dao.getCreditAnalysis(), ac.id);
            System.assertEquals(dao.getAssociate(), false);
            System.assertEquals(dao.getAssocName(), 'Test Assoc');
            System.assertEquals(dao.getCreditLimit(), 20);
            System.assertEquals(dao.getCurrentDebit(), 10);
            System.assertEquals(dao.getHigherAccumulation(), 1);
        Test.stopTest();
    }
    
    static testMethod void LAT_BR_SalesPredictionDAOTest(){
        Account acc = LAT_Account_TestFactory.getBRAAccountBase('Off_Trade');
        insert acc;
        
        Analise_de_credito__c ac = new Analise_de_credito__c();
        ac.Conta__c = acc.id;
        insert ac;
        
        Test.startTest();
            LAT_BR_SalesPredictionDAO dao = new LAT_BR_SalesPredictionDAO();
            dao.setCreditAnalisis(ac.id);
            dao.setPreviousFY(false);
            dao.setPrice(10);
            dao.setSKU('Test SKU');
            dao.setCA(1);
            dao.setInstance(dao.getInstance());
            
            List<LAT_BR_SalesPredictionDAO> daoList = new List<LAT_BR_SalesPredictionDAO>{dao};
            LAT_BR_SalesPredictionDAO.upsertList(daoList);
            LAT_BR_SalesPredictionDAO.getListSalesPredictionPerAC(ac.id);
            LAT_BR_SalesPredictionDAO.getPicklistSKU();
            
            System.assertEquals(dao.getCreditAnalisis(), ac.id);
            System.assertEquals(dao.getPreviousFY(), false);
            System.assertEquals(dao.getCA(), 1);
            System.assertEquals(dao.getPrice(), 10);
            System.assertEquals(dao.getSKU(), 'Test SKU');
        Test.stopTest();
    }
    
    static testMethod void LAT_BR_CustomerBehaviorDAOTest(){
        Account acc = LAT_Account_TestFactory.getBRAAccountBase('Off_Trade');
        insert acc;
        
        Analise_de_credito__c ac = new Analise_de_credito__c();
        ac.Conta__c = acc.id;
        insert ac;
        
        Test.startTest();
            LAT_BR_CustomerBehaviorDAO dao = new LAT_BR_CustomerBehaviorDAO();
            dao.setName('Test Name');
            dao.setValue('10');
            dao.setWeight(20);
            dao.setInstance(dao.getInstance());
            
            List<LAT_BR_CustomerBehaviorDAO> daoList = new List<LAT_BR_CustomerBehaviorDAO>{dao};
            LAT_BR_CustomerBehaviorDAO.upsertList(daoList);
            LAT_BR_CustomerBehaviorDAO.getCustomerBehaviors();
            
            System.assertEquals(dao.getName(), 'Test Name');
            System.assertEquals(dao.getValue(), '10');
            System.assertEquals(dao.getWeight(), 20);
        Test.stopTest();
    }

}