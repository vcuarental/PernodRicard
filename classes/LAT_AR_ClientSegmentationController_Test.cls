/****************************************************
 * Dev: Isabel Gabard  Version: 1  Consulting: Zimmic
 * Test class for cover the new Segmentation AR handler code
****************************************************/
@isTest
public with sharing class LAT_AR_ClientSegmentationController_Test {

    @testSetup
    public static void testSetup() {

        List <UDC__c> tabelas = new List <UDC__c>();
        
        Id idRecTypeUdc = RecordTypeForTest.getRecType('UDC__c', 'Standard_AR');

        tabelas.add(new UDC__c(
            CodDefUsuario__c = '01',
            CodProd__c = 'CRM',
            CodUs__c = 'DF',
            Name = 'PLANTABELLAVISTA',
            Internal_Id__c = '6-01-CRM-DF',
            RecordTypeId = idRecTypeUdc
        ));
        tabelas.add(new UDC__c(
            CodProd__c = '00',
            CodUs__c = 'PY',
            Name = 'Blanco',
            Internal_Id__c = '6--00-PY',
            RecordTypeId = idRecTypeUdc
        ));
        tabelas.add(new UDC__c(
            CodDefUsuario__c = 'PES',
            CodProd__c = '55',
            CodUs__c = 'GL',
            Name = 'Clientes en Pesos',
            Internal_Id__c = '6-PES-55-GL',
            RecordTypeId = idRecTypeUdc
        ));
        //customer price group
        tabelas.add(new UDC__c(
            CodDefUsuario__c = 'DIST',
            CodProd__c = '40',
            CodUs__c = 'PC',
            Name = 'Distribuidores',
            Internal_Id__c = '6-DIST-40-PC',
            RecordTypeId = idRecTypeUdc
        ));
        tabelas.add(new UDC__c(
            CodDefUsuario__c = 'OFF',
            CodProd__c = '40',
            CodUs__c = 'PC',
            Name = 'OFF TRADE',
            Internal_Id__c = '6-OFF-40-PC',
            RecordTypeId = idRecTypeUdc
        ));
        tabelas.add(new UDC__c(
            CodDefUsuario__c = 'ON',
            CodProd__c = '40',
            CodUs__c = 'PC',
            Name = 'ON TRADE',
            Internal_Id__c = '6-ON-40-PC',
            RecordTypeId = idRecTypeUdc
        ));
        // subchannel        
        tabelas.add(new UDC__c(
            CodDefUsuario__c = 'A01',
            CodProd__c = '01',
            CodUs__c = '03',
            Name = 'Supermercados - Nacionales',
            Internal_Id__c = '6-A01-01-03',
            RecordTypeId = idRecTypeUdc
        ));
        tabelas.add(new UDC__c(
            CodDefUsuario__c = 'A02',
            CodProd__c = '01',
            CodUs__c = '03',
            Name = 'Supermercados – Regionales',
            Internal_Id__c = '6-A02-01-03',
            RecordTypeId = idRecTypeUdc
        ));
        tabelas.add(new UDC__c(
            CodDefUsuario__c = 'A03',
            CodProd__c = '01',
            CodUs__c = '03',
            Name = 'Supermercados – Zonales',
            Internal_Id__c = '6-A03-01-03',
            RecordTypeId = idRecTypeUdc
        ));
        tabelas.add(new UDC__c(
            CodDefUsuario__c = 'G02',
            CodProd__c = '01',
            CodUs__c = '03',
            Name = 'On Trade - High Energy Bar',
            Internal_Id__c = '6-G02-01-03',
            RecordTypeId = idRecTypeUdc
        ));
        tabelas.add(new UDC__c(
            CodDefUsuario__c = 'G03',
            CodProd__c = '01',
            CodUs__c = '03',
            Name = 'On Trade - Discos',
            Internal_Id__c = '6-G03-01-03',
            RecordTypeId = idRecTypeUdc
        ));
        tabelas.add(new UDC__c(
            CodDefUsuario__c = 'G04',
            CodProd__c = '01',
            CodUs__c = '03',
            Name = 'On Trade - Restaurantes',
            Internal_Id__c = '6-G04-01-03',
            RecordTypeId = idRecTypeUdc
        ));
        tabelas.add(new UDC__c(
            CodDefUsuario__c = 'H03',
            CodProd__c = '01',
            CodUs__c = '03',
            Name = 'Ctas Esp - Deliveries / Catter',
            Internal_Id__c = '6-H03-01-03',
            RecordTypeId = idRecTypeUdc
        ));
        insert tabelas;
    }

    static testMethod void initAccountAR(){
        PageReference pageRef = Page.LAT_AR_ClientSegmentation;
        Test.setCurrentPage(pageRef);
        LAT_AR_ClientSegmentationController controllerNew = new LAT_AR_ClientSegmentationController();
        controllerNew.getItems();
        controllerNew.isOpenBottle = false;
        controllerNew.saveAccount();
        controllerNew.getQuestions();

        ApexPages.StandardController sc = new ApexPages.StandardController(controllerNew.newAccount);
        controllerNew = new LAT_AR_ClientSegmentationController(sc);
        controllerNew.cancel();
    }

    static testMethod void newAccountARBotellaAbierta1(){
        PageReference pageRef = Page.LAT_AR_ClientSegmentation;
        Test.setCurrentPageReference(pageRef);
        LAT_AR_ClientSegmentationController controllerNew = new LAT_AR_ClientSegmentationController();
        controllerNew.newAccount.Name = 'test account';
        controllerNew.newAccount.CNPJ__c = '20354266645';
        controllerNew.isOpenBottle = true;
        controllerNew.saveAccount();
        
        controllerNew.actualLevel = 0;
        controllerNew.response = false;
        controllerNew.questionLabel = 'LAT_AR_Level2OnTrade';
        controllerNew.nextLevel();

        controllerNew.actualLevel = 1;
        controllerNew.response = false;
        controllerNew.questionLabel = 'LAT_AR_Level3OnTrade';
        controllerNew.nextLevel();

        controllerNew.questionLabel = 'LAT_AR_Level4OnTrade';
        controllerNew.actualLevel = 2;
        controllerNew.response = true;
        controllerNew.updateAccountAR();
    }
    
    static testMethod void newAccountARBotellaAbierta2(){
        PageReference pageRef = Page.LAT_AR_ClientSegmentation;
        Test.setCurrentPageReference(pageRef);
        LAT_AR_ClientSegmentationController controllerNew = new LAT_AR_ClientSegmentationController();
        controllerNew.newAccount.Name = 'test account';
        controllerNew.newAccount.CNPJ__c = '20354266645';
        controllerNew.isOpenBottle = true;
        controllerNew.saveAccount();
        
        controllerNew.response = false;
        controllerNew.actualLevel = 0;
        controllerNew.questionLabel = 'LAT_AR_Level2OnTrade';
        controllerNew.nextLevel();

        controllerNew.response = false;
        controllerNew.actualLevel = 1;
        controllerNew.questionLabel = 'LAT_AR_Level3OnTrade';
        controllerNew.nextLevel();

        controllerNew.response = false;
        controllerNew.actualLevel = 2;
        controllerNew.questionLabel = 'LAT_AR_Level4OnTrade';
        controllerNew.nextLevel();

        controllerNew.response = false;
        controllerNew.actualLevel = 3;
        controllerNew.questionLabel = 'LAT_AR_Level5OnTrade';
        controllerNew.nextLevel();

        controllerNew.response = false;
        controllerNew.actualLevel = 4;
        controllerNew.questionLabel = 'LAT_AR_Level6OnTrade';//ON TRADE DIRECTA
        controllerNew.updateAccountAR();
    }

    static testMethod void newAccountARBotellaCerrada1(){
        PageReference pageRef = Page.LAT_AR_ClientSegmentation;
        Test.setCurrentPageReference(pageRef);
        LAT_AR_ClientSegmentationController controllerNew = new LAT_AR_ClientSegmentationController();
        controllerNew.newAccount.Name = 'test account';
        controllerNew.newAccount.CNPJ__c = '20354266645';
        controllerNew.isOpenBottle = false;
        controllerNew.saveAccount();
        
        controllerNew.response = false;
        controllerNew.actualLevel = 0;
        controllerNew.questionLabel = 'LAT_AR_Level2OffTrade';
        controllerNew.nextLevel();

        controllerNew.response = false;
        controllerNew.actualLevel = 1;
        controllerNew.questionLabel = 'LAT_AR_Level3_2OffTrade';
        controllerNew.nextLevel();

        controllerNew.response = true;
        controllerNew.actualLevel = 2;
        controllerNew.questionLabel = 'LAT_AR_Level4_4OffTrade';
        controllerNew.nextLevel();

        controllerNew.response = false;
        controllerNew.actualLevel = 3;
        controllerNew.questionLabel = 'LAT_AR_Level5_5OffTrade';
        controllerNew.nextLevel();
        
        controllerNew.response = false;
        controllerNew.actualLevel = 4;
        controllerNew.questionLabel = 'LAT_AR_Level6_6OffTrade';
        controllerNew.updateAccountAR();  // Mayoristas - Zonales
    }
    
    static testMethod void newAccountARBotellaCerrada2(){
        PageReference pageRef = Page.LAT_AR_ClientSegmentation;
        Test.setCurrentPageReference(pageRef);
        LAT_AR_ClientSegmentationController controllerNew = new LAT_AR_ClientSegmentationController();
        controllerNew.newAccount.Name = 'test account';
        controllerNew.newAccount.CNPJ__c = '20354266645';
        controllerNew.isOpenBottle = false;
        controllerNew.saveAccount();
        
        controllerNew.response = true;
        controllerNew.actualLevel = 0;
        controllerNew.questionLabel = 'LAT_AR_Level2OffTrade';
        controllerNew.nextLevel();

        controllerNew.response = true;
        controllerNew.actualLevel = 1;
        controllerNew.questionLabel = 'LAT_AR_Level3_1OffTrade';
        controllerNew.nextLevel();

        controllerNew.response = true;
        controllerNew.actualLevel = 2;
        controllerNew.questionLabel = 'LAT_AR_Level4_1OffTrade';
        controllerNew.nextLevel();

        controllerNew.response = true;
        controllerNew.actualLevel = 3;
        controllerNew.questionLabel = 'LAT_AR_Level5_1OffTrade';// Vinotecas Directas - Cadenas
        controllerNew.updateAccountAR();
    }
    
    static testMethod void newAccountARBotellaCerrada3(){
        PageReference pageRef = Page.LAT_AR_ClientSegmentation;
        Test.setCurrentPageReference(pageRef);
        LAT_AR_ClientSegmentationController controllerNew = new LAT_AR_ClientSegmentationController();
        controllerNew.newAccount.Name = 'test account';
        controllerNew.newAccount.CNPJ__c = '20354266645';
        controllerNew.isOpenBottle = false;
        controllerNew.saveAccount();
        
        controllerNew.response = true;
        controllerNew.actualLevel = 0;
        controllerNew.questionLabel = 'LAT_AR_Level2OffTrade';
        controllerNew.nextLevel();

        controllerNew.response = false;
        controllerNew.actualLevel = 1;
        controllerNew.questionLabel = 'LAT_AR_Level3_1OffTrade';
        controllerNew.nextLevel();

        controllerNew.response = true;
        controllerNew.actualLevel = 2;
        controllerNew.questionLabel = 'LAT_AR_Level4_2OffTrade';
        controllerNew.nextLevel();

        controllerNew.response = true;
        controllerNew.actualLevel = 3;
        controllerNew.questionLabel = 'LAT_AR_Level5_2OffTrade';
        controllerNew.nextLevel();
        
        controllerNew.response = true;
        controllerNew.actualLevel = 4;
        controllerNew.questionLabel = 'LAT_AR_Level6_1OffTrade';
        controllerNew.nextLevel();
        
        controllerNew.response = true;
        controllerNew.actualLevel = 5;
        controllerNew.questionLabel = 'LAT_AR_Level7_1OffTrade';//Supermercados – Hard Discount
        controllerNew.updateAccountAR();
    }

    static testMethod void newAccountARBotellaCerrada4(){
        PageReference pageRef = Page.LAT_AR_ClientSegmentation;
        Test.setCurrentPageReference(pageRef);
        LAT_AR_ClientSegmentationController controllerNew = new LAT_AR_ClientSegmentationController();
        controllerNew.newAccount.Name = 'test account';
        controllerNew.newAccount.CNPJ__c = '20354266645';
        controllerNew.isOpenBottle = false;
        controllerNew.saveAccount();
                
        controllerNew.response = false;
        controllerNew.actualLevel = 0;
        controllerNew.questionLabel = 'LAT_AR_Level2OffTrade';
        controllerNew.nextLevel();

        controllerNew.response = true;
        controllerNew.actualLevel = 1;
        controllerNew.questionLabel = 'LAT_AR_Level3_2OffTrade';
        controllerNew.nextLevel();

        controllerNew.response = true;
        controllerNew.actualLevel = 2;
        controllerNew.questionLabel = 'LAT_AR_Level4_3OffTrade';
        controllerNew.nextLevel();

        controllerNew.response = false;
        controllerNew.actualLevel = 3;
        controllerNew.questionLabel = 'LAT_AR_Level5_3OffTrade';
        controllerNew.nextLevel();
        
        controllerNew.response = true;
        controllerNew.actualLevel = 4;
        controllerNew.questionLabel = 'LAT_AR_Level6_4OffTrade';
        controllerNew.nextLevel();

        controllerNew.response = false;
        controllerNew.actualLevel = 5;
        controllerNew.questionLabel = 'LAT_AR_Level7_2OffTrade';
        controllerNew.nextLevel();
        
        controllerNew.response = false;
        controllerNew.actualLevel = 6;
        controllerNew.questionLabel = 'LAT_AR_Level8_1OffTrade';// Distribuidores Off trade – Solo bebidas
        controllerNew.updateAccountAR();
    }
}