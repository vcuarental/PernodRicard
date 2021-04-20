/**
* @author fabiosuenaga - topi
*/
@isTest
public class LAT_Rest_ContractsTest {
    public static String NEW_CONTRACT_ID = '30d184c1-9d17-4844-9d72-739a33ee0f97';
    public static String ACORDO_RECORDTYPE = 'LAT_BR_Acordo';//

    //Contratos obsoletos
    public static String ONTRADE_PATROCINIO_RECORDTYPE = 'LAT_OnTrade_SponsorshipAgreementOnTrade';
    public static String ONTRADE_CONDICIONCOMMERCIAL_RECORDTYPE = 'LAT_OnTrade_CommercialConditionContract';
    public static String ONTRADE_CARTAACTIVACION_RECORDTYPE = 'LAT_CartaAtivacao';
    public static String ONTRADE_CARTAACORDO_RECORDTYPE = 'LAT_OnTrade_LetterAgreement';
    public static String ONTRADE_CARTACONDICIONCOMMERCIAL_RECORDTYPE = 'LAT_OnTrade_LetterAgreementCommercialCondition';

    public static String EVENTOS_SIMULACION_RECORDTYPE = 'Simulacao_Contrato';
    public static String EVENTOS_SIMULACION_DISTRIBUTOR_RECORDTYPE = 'Simula_o_Contrato_Distribuidor';//
    public static String EVENTOS_CONTRATOPARCERIA_RECORDTYPE = 'LAT_Eventos_Contrato_de_Parceria';
    public static String EVENTOS_CONTRATOPARCERIA_RECORDTYPE_DISTRIBUIDOR = 'LAT_Eventos_Contrato_de_Parceria_Distribuidor';///
    
    public static String UDC_CIUDAD = '1-1500206-00-CT';
    public static String UDC_PERFIL = '1-TT-01-18';
    
    @TestSetup
    private static void setup() { 
        Account objAccount = null;
        
        System.debug('setup [] ->');

        delete [SELECT Id FROM PRH_Iconic_Account_Trigger__c];   

        objAccount = LAT_Account_TestFactory.getBRAAccountBase('Off_Trade');
        objAccount.Type = 'COM PAGAMENTO';
        objAccount.Revenue_UF__c = 'SC';
        
        insert objAccount;

        createGeneralConfigSettings();
        createUDC('01','18', 'TT', 'TODOS',UDC_PERFIL, 'BRA_Standard');
        createUDC('00','CT', '1500206', 'ACARA',UDC_CIUDAD, 'BRA_Standard');

        insert new LAT_GeneralConfig__c (Name= 'LAT_PRODUCT_COST_CHANNELS', LAT_Value__c = '101,102,103,104,112,113,114,115,116');

        System.debug('setup [] <-');
    }

    @isTest
    private static void createAndUpdateContractAcordoTest() {
        LAT_ContractHandlerJSON objJSON = null;
        String strBody = null;
        LAT_Contract2__c objContract = null;

        objJSON = createJSONAcordo(ACORDO_RECORDTYPE, NEW_CONTRACT_ID, 'New');
        strBody = JSON.serialize(objJSON);

        setupRESTContext();

        Test.startTest();

        LAT_Rest_Contracts.POST();


        RestContext.request.requestBody = Blob.valueOf(strBody);
        LAT_Rest_Contracts.POST();

        
        objContract = [SELECT Id FROM LAT_Contract2__c];
        
        LAT_Rest_Contracts.setContract(objContract);

        objJSON = createJSONAcordo(ACORDO_RECORDTYPE, objContract.Id, 'Approve');

        RestContext.request.requestBody = null;
        LAT_Rest_Contracts.PUT();            

        RestContext.request.requestBody = Blob.valueOf(strBody);
        LAT_Rest_Contracts.PUT();            
        
        Test.stopTest();
    }

    @isTest
    private static void createAndUpdateContractAcordoInvalidTest() {
        LAT_ContractHandlerJSON objJSON = null;
        String strBody = null;
        LAT_Contract2__c objContract = null;

        objJSON = createJSONAcordo(ACORDO_RECORDTYPE, NEW_CONTRACT_ID, 'New');
        strBody = JSON.serialize(objJSON);

        setupRESTContext();

        Test.startTest();


        RestContext.request.requestBody = Blob.valueOf('jajejijoju');
        LAT_Rest_Contracts.POST();

        Test.stopTest();
    }

    @isTest
    private static void createContractDistribuidorTest() {
        LAT_ContractHandlerJSON objJSON = null;
        String strBody = null;
        LAT_Contract2__c objContract = null;

        objJSON = createJSONEventosContratoParceria(EVENTOS_CONTRATOPARCERIA_RECORDTYPE_DISTRIBUIDOR, NEW_CONTRACT_ID, 'New');
        strBody = JSON.serialize(objJSON);

        setupRESTContext();
        RestContext.request.requestBody = Blob.valueOf(strBody);

        Test.startTest();

        LAT_Rest_Contracts.POST();
        
        Test.stopTest();
    }

    @isTest
    private static void createContractDistribuidorSimulationTest() {
        LAT_ContractHandlerJSON objJSON = null;
        String strBody = null;
        LAT_Contract2__c objContract = null;

        objJSON = createJSONEventosContratoParceria(EVENTOS_SIMULACION_DISTRIBUTOR_RECORDTYPE, NEW_CONTRACT_ID, 'New');
        strBody = JSON.serialize(objJSON);

        setupRESTContext();
        RestContext.request.requestBody = Blob.valueOf(strBody);

        Test.startTest();

        LAT_Rest_Contracts.POST();
        
        Test.stopTest();
    }

   // @isTest
    private static void updateContractDistribuidorTest() {
        LAT_ContractHandlerJSON objJSON = null;
        String strBody = null;
        LAT_Contract2__c objContract = null;

        objJSON = createJSONEventosContratoParceria(EVENTOS_CONTRATOPARCERIA_RECORDTYPE_DISTRIBUIDOR, NEW_CONTRACT_ID, 'New');
        strBody = JSON.serialize(objJSON);

        setupRESTContext();
        RestContext.request.requestBody = Blob.valueOf(strBody);


        LAT_Rest_Contracts.POST();
        
        objContract = [SELECT Id FROM LAT_Contract2__c];
        
        LAT_Rest_Contracts.setContract(objContract);

        Test.startTest();

        objJSON = createJSONEventosContratoParceria(EVENTOS_CONTRATOPARCERIA_RECORDTYPE_DISTRIBUIDOR, objContract.Id, 'Approve');
        RestContext.request.requestBody = Blob.valueOf(strBody);
        LAT_Rest_Contracts.PUT();            
        
        Test.stopTest();
    }

    @isTest
    private static void commonContractDistributorFunctionsTest() {
        LAT_EventPayment__c objEventPayment = null;
        LAT_EventVolume__c objEventVolume = null;
        LAT_Contract_Eventos__c objContractEventos = null;
        LAT_Meta_ROI_Consultant__c objMetaROI = null;
        LAT_Contract2__c objContract = null;
 
        objEventPayment = new LAT_EventPayment__c();
        objEventVolume = new LAT_EventVolume__c();
        objContractEventos = new LAT_Contract_Eventos__c();
        objContract = new LAT_Contract2__c();
        objMetaROI = new LAT_Meta_ROI_Consultant__c();

        Test.startTest();
        LAT_ContractHandlerJSON.Payment obkP= new LAT_ContractHandlerJSON.Payment(objEventPayment);
        LAT_ContractHandlerJSON.Volume obkV= new LAT_ContractHandlerJSON.Volume(objEventVolume);
        LAT_ContractHandlerJSON.ContractEvent obk3 = new LAT_ContractHandlerJSON.ContractEvent(objContractEventos);
        LAT_ContractHandlerJSON.ContractCalculationProdutor obk5= new LAT_ContractHandlerJSON.ContractCalculationProdutor(objContract);
        LAT_ContractHandlerJSON.ContractCalculationDistribuidor obk4= new LAT_ContractHandlerJSON.ContractCalculationDistribuidor(objContract);
        LAT_ContractHandlerJSON.ContractCalculationEvent obk7= new LAT_ContractHandlerJSON.ContractCalculationEvent();
        
        obk5.enrich(objContract);        
        obk5.enrich(objContract, objMetaROI);
        obk4.toUpdate();
        obk4.toUpsert();
        obk4.enrich(objContract);        
        
        obk7.toContratoEventos();

        new LAT_Rest_Contracts.ServiceResponseError(new LAT_Rest_Contracts.RestContractException(1,'test'));

        Test.stopTest();
    }

    @isTest
    private static void createContractProductorTest() {
        LAT_ContractHandlerJSON objJSON = null;
        String strBody = null;
        LAT_Contract2__c objContract = null;

        objJSON = createJSONEventosContratoParceria(EVENTOS_CONTRATOPARCERIA_RECORDTYPE, NEW_CONTRACT_ID, 'New');
        strBody = JSON.serialize(objJSON);

        setupRESTContext();
        RestContext.request.requestBody = Blob.valueOf(strBody);

        Test.startTest();

        LAT_ContractCalculationEventRest.POST();

        Test.stopTest();
    }

    
    @isTest
    private static void createContractProductorSimulacionTest() {
        LAT_ContractHandlerJSON objJSON = null;
        String strBody = null;
        LAT_Contract2__c objContract = null;

        objJSON = createJSONEventosContratoParceria(EVENTOS_SIMULACION_RECORDTYPE, NEW_CONTRACT_ID, 'New');
        strBody = JSON.serialize(objJSON);

        setupRESTContext();
        RestContext.request.requestBody = Blob.valueOf(strBody);

        Test.startTest();

        LAT_ContractCalculationEventRest.POST();

        Test.stopTest();
    }

  //  @isTest
    private static void updateContractProductorTest() {
        LAT_ContractHandlerJSON objJSON = null;
        String strBody = null;
        LAT_Contract2__c objContract = null;

        objJSON = createJSONEventosContratoParceria(EVENTOS_CONTRATOPARCERIA_RECORDTYPE, NEW_CONTRACT_ID, 'New');
        strBody = JSON.serialize(objJSON);

        setupRESTContext();
        RestContext.request.requestBody = Blob.valueOf(strBody);

        LAT_ContractCalculationEventRest.POST();

        objContract = [SELECT Id FROM LAT_Contract2__c];
        
        LAT_Rest_Contracts.setContract(objContract);

        Test.startTest();

        objJSON = createJSONEventosContratoParceria(EVENTOS_CONTRATOPARCERIA_RECORDTYPE, objContract.Id, 'Approve');
        RestContext.request.requestBody = Blob.valueOf(strBody);
        LAT_Rest_Contracts.PUT();            
        Test.stopTest();
    }
    
    @isTest
    private static void createCartaAcordoPatrocinioTest() {
        LAT_ContractHandlerJSON objJSON = null;
        String strBody = null;
        LAT_Contract2__c objContract = null;

        objJSON = createJSONCartaAcordoPatrocinio(ONTRADE_PATROCINIO_RECORDTYPE, NEW_CONTRACT_ID, 'New');
        strBody = JSON.serialize(objJSON);

        setupRESTContext();
        RestContext.request.requestBody = Blob.valueOf(strBody);

        Test.startTest();

        LAT_Rest_Contracts.POST();

        Test.stopTest();
    }

    //@isTest
    private static void updateCartaAcordoPatrocinioTest() {
        LAT_ContractHandlerJSON objJSON = null;
        String strBody = null;
        LAT_Contract2__c objContract = null;

        objJSON = createJSONCartaAcordoPatrocinio(ONTRADE_PATROCINIO_RECORDTYPE, NEW_CONTRACT_ID, 'New');
        strBody = JSON.serialize(objJSON);

        setupRESTContext();
        RestContext.request.requestBody = Blob.valueOf(strBody);

        LAT_Rest_Contracts.POST();
        objContract = [SELECT Id FROM LAT_Contract2__c];
        
        LAT_Rest_Contracts.setContract(objContract);

        Test.startTest();
        objJSON = createJSONCartaAcordoPatrocinio(ONTRADE_CARTAACORDO_RECORDTYPE, objContract.Id, 'Approve');
        RestContext.request.requestBody = Blob.valueOf(strBody);
        LAT_Rest_Contracts.PUT();            
        Test.stopTest();
    }

    @isTest
    private static void createAndUpdateCartaActivacionTest() {
        LAT_ContractHandlerJSON objJSON = null;
        String strBody = null;
        LAT_Contract2__c objContract = null;

        objJSON = createJSONCartaActivacion(ONTRADE_CARTAACTIVACION_RECORDTYPE, NEW_CONTRACT_ID, 'New');
        strBody = JSON.serialize(objJSON);

        setupRESTContext();
        RestContext.request.requestBody = Blob.valueOf(strBody);

        Test.startTest();

        LAT_Rest_Contracts.POST();
        /*
        objContract = [SELECT Id FROM LAT_Contract2__c];
        
        LAT_Rest_Contracts.setContract(objContract);

        objJSON = createJSONCartaActivacion(ONTRADE_CARTAACTIVACION_RECORDTYPE, objContract.Id, 'Approve');
        RestContext.request.requestBody = Blob.valueOf(strBody);
        LAT_Rest_Contracts.PUT();            
        */
        Test.stopTest();
    }
    
    @isTest
    private static void createAndCalculateCartaAcordoPatrocinioTest() {
        LAT_ContractHandlerJSON objJSON = null;
        String strBody = null;
        LAT_Contract2__c objContract = null;

        objJSON = createJSONCartaAcordoPatrocinio(ONTRADE_CARTAACORDO_RECORDTYPE, NEW_CONTRACT_ID, 'New');
        strBody = JSON.serialize(objJSON);

        setupRESTContext();
        RestContext.request.requestBody = Blob.valueOf(strBody);

        Test.startTest();

        try {
            LAT_ContractCalculationEventRest.POST();
        } catch (Exception Ex ) {

        }
        /*
        objContract = [SELECT Id FROM LAT_Contract2__c];
        
        LAT_Rest_Contracts.setContract(objContract);

        objJSON = createJSONCartaAcordoPatrocinio(ONTRADE_CARTAACORDO_RECORDTYPE, objContract.Id, 'Approve');
        RestContext.request.requestBody = Blob.valueOf(strBody);
        LAT_Rest_Contracts.PUT();            
        */
        Test.stopTest();
    }

    @isTest
    private static void createAndCalculateCartaActivacionTest() {
        LAT_ContractHandlerJSON objJSON = null;
        String strBody = null;
        LAT_Contract2__c objContract = null;

        objJSON = createJSONCartaActivacion(ONTRADE_CARTAACTIVACION_RECORDTYPE, NEW_CONTRACT_ID, 'New');
        strBody = JSON.serialize(objJSON);

        setupRESTContext();
        RestContext.request.requestBody = Blob.valueOf(strBody);

        Test.startTest();

        try {
            LAT_ContractCalculationEventRest.POST();
        } catch (Exception Ex ) {

        }

        /*
        objContract = [SELECT Id FROM LAT_Contract2__c];
        
        LAT_Rest_Contracts.setContract(objContract);

        objJSON = createJSONCartaActivacion(ONTRADE_CARTAACTIVACION_RECORDTYPE, objContract.Id, 'Approve');
        RestContext.request.requestBody = Blob.valueOf(strBody);
        LAT_Rest_Contracts.PUT();            
        */
        Test.stopTest();
    }

    @isTest
    private static void createAndUpdateEventosContratoParceriaTest() {
        LAT_ContractHandlerJSON objJSON = null;
        String strBody = null;
        LAT_Contract2__c objContract = null;

        objJSON = createJSONEventosContratoParceria(EVENTOS_CONTRATOPARCERIA_RECORDTYPE, NEW_CONTRACT_ID, 'New');
        strBody = JSON.serialize(objJSON);

        setupRESTContext();
        RestContext.request.requestBody = Blob.valueOf(strBody);

        Test.startTest();

        LAT_Rest_Contracts.POST();
        /*
        objContract = [SELECT Id FROM LAT_Contract2__c];
        
        LAT_Rest_Contracts.setContract(objContract);

        objJSON = createJSONEventosContratoParceria(EVENTOS_CONTRATOPARCERIA_RECORDTYPE, objContract.Id, 'Approve');
        RestContext.request.requestBody = Blob.valueOf(strBody);
        LAT_Rest_Contracts.PUT();            
        */
        Test.stopTest();
    }

    @isTest
    private static void createAndCalculateEventosContratoParceriaTest() {
        LAT_ContractHandlerJSON objJSON = null;
        String strBody = null;
        LAT_Contract2__c objContract = null;

        objJSON = createJSONEventosContratoParceria(EVENTOS_CONTRATOPARCERIA_RECORDTYPE, NEW_CONTRACT_ID, 'New');
        strBody = JSON.serialize(objJSON);

        setupRESTContext();
        RestContext.request.requestBody = Blob.valueOf(strBody);

        Test.startTest();

        try {
            LAT_ContractCalculationEventRest.POST();
        } catch (Exception Ex ) {

        }

        /*
        objContract = [SELECT Id FROM LAT_Contract2__c];
        
        LAT_Rest_Contracts.setContract(objContract);

        objJSON = createJSONEventosContratoParceria(EVENTOS_CONTRATOPARCERIA_RECORDTYPE, objContract.Id, 'Approve');
        RestContext.request.requestBody = Blob.valueOf(strBody);
        LAT_Rest_Contracts.PUT();            
        */
        Test.stopTest();
    }

    @isTest
    private static void commonFunctionTest() {
        LAT_Rest_Contracts.getEventRecordTypes();

        LAT_ContractCalculationEventRest.debugException(null);

        new LAT_Rest_Contracts.RestContractException(111, '111','111','111');        
	}

    public static LAT_ContractHandlerJSON createJSONCartaAcordoPatrocinio(String strRecordType, String strContractId, String strStatus) {
        LAT_ContractHandlerJSON objJSON = null;
        Account objAccount = null;

        objAccount = [SELECT Id FROM Account];

        objJSON = new LAT_ContractHandlerJSON();
        objJSON.sfdcId = strContractId;
        
        if(strStatus == 'New') {
            objJSON.processStatus = 'Em Elaboração';
            objJSON.status = 'Novo Contrato';
        } else if(strStatus == 'Approve') {
            objJSON.processStatus = 'Contrato em Aprovação';
            objJSON.status = 'Em Aprovação';
        }

        objJSON.recordType = Global_RecordTypeCache.getRtId('LAT_Contract2__c' + strRecordType);
        objJSON.account = objAccount.Id;
        objJSON.comments = 'OBSERVACIONES...';
        objJSON.startDate = DateTime.now().format('YYYY-MM-dd');
        objJSON.endDate = DateTime.now().format('YYYY-MM-dd');
        objJSON.exclusivity = '100% Portifolio';
        objJSON.monthElapsed = 1;
        objJSON.roi = -89.97;

        objJSON.money = 0;
        objJSON.source = 'Mobile';
        objJSON.ConsultantToTestify = true;
        objJSON.prbPortfolio = 'Vodkas Importadas - Wyborowa';
        objJSON.customerSignedBy = '';
        objJSON.contrapartidas = 'conttrapartidas'; 
        objJSON.standardClausesPRB = true;
        objJSON.tradingConditionNegotiated = 'COND NEGOCIADA';
        objJSON.vodkaClubCabinets = '10';
        objJSON.whiskyClubCabinets = '10';
        objJSON.djBooth = '10';
        objJSON.barsShelves = '10';
        objJSON.revenue = 10.0;
        objJSON.listVolume = new LAT_ContractHandlerJSON.ListVolume();
        objJSON.listPayment = new LAT_ContractHandlerJSON.ListPayment();
        objJSON.listContractEvent = new LAT_ContractHandlerJSON.ListContractEvent(); 
        objJSON.listClientContract = new LAT_ContractHandlerJSON.ListClientContract(); 
        objJSON.listProviders = new LAT_ContractHandlerJSON.ListProviders(); 
        objJSON.listPromotionAgreement = new LAT_ContractHandlerJSON.ListPromotionAgreement(); 
        objJSON.listContractDetail = new LAT_ContractHandlerJSON.ListContractDetail();
        objJSON.listContractEvent = new LAT_ContractHandlerJSON.ListContractEvent();
        objJSON.listVisibilityCounterPart = new LAT_ContractHandlerJSON.ListVisibilityCounterPart();

        objJSON.listVolume.volume =  retrieveVolumesForCartaAcordoPatrocinio(strContractId);
        objJSON.listPayment.payment =  retrievePaymentsForCartaAcordoPatrocinio(strContractId);
        objJSON.listClientContract.clientContract = retrieveClientsContractsForCartaAcordoPatrocinio(strContractId, objAccount);
        objJSON.listProviders.provider = retrieveProvidersContractsForCartaAcordoPatrocinio(strContractId);
        objJSON.listPromotionAgreement.promotionAgreement = retrievePromotionAgreementContractsForCartaAcordoPatrocinio(strContractId);
        objJSON.listContractDetail.contractDetail = retrieveContractDetailsForCartaAcordoPatrocinio(strContractId);
        objJSON.listVisibilityCounterPart.visibilityCounterPart = retrieveVisibilityForCartaAcordoPatrocinio(strContractId);

        return objJSON;
    }

    private static LAT_ContractHandlerJSON createJSONCartaActivacion(String strRecordType, String strContractId, String strStatus) {
        LAT_ContractHandlerJSON objJSON = null;
        Account objAccount = null;

        objAccount = [SELECT Id FROM Account];

        objJSON = new LAT_ContractHandlerJSON();
        objJSON.sfdcId = strContractId;
        
        if(strStatus == 'New') {
            objJSON.processStatus = 'Em Elaboração';
            objJSON.status = 'Novo Contrato';
        } else if(strStatus == 'Approve') {
            objJSON.processStatus = 'Contrato em Aprovação';
            objJSON.status = 'Em Aprovação';
        }

        objJSON.recordType = Global_RecordTypeCache.getRtId('LAT_Contract2__c' + strRecordType);
        objJSON.account = objAccount.Id;
        objJSON.comments = 'OBSERVACIONES...';
        objJSON.startDate = DateTime.now().format('YYYY-MM-dd');
        objJSON.endDate = DateTime.now().format('YYYY-MM-dd');
        objJSON.exclusivity = '100% Portifolio';
        objJSON.monthElapsed = 1;
        objJSON.money = 0;
        objJSON.source = 'Mobile';
        objJSON.ConsultantToTestify = true;
        objJSON.prbPortfolio = 'Vodkas Importadas - Wyborowa';
        objJSON.customerSignedBy = '';

        objJSON.contrapartidas = '<html><head><style type="text/css">.c0 { font-family: \'Segoe UI\'; font-size: 14px; color: Black } .c1 { margin: 0px 0px 10px } .c2 { font-weight: bold; font-size: 13.3333333333333px } .c3 { color: Black } .c4 { font-size: 13.3333333333333px } .c5 { text-align: center } .c6 { width: 179px } .c7 { vertical-align: middle } .c8 { vertical-align: middle; height: 15px } .c9 { vertical-align: top; width: 179px; height: 15px } .c10 { vertical-align: top; width: 179px } .c11 { margin: 0px 0px 12px 40px; list-style-type: decimal } .c12 { text-align: justify } .c13 { color: Black; font-size: 13.3333333333333px } .c14 { font-weight: bold } .c15 { font-style: italic } </style></head><body class="c0"><p class="c1"><span class="c2"><span class="c3">1A. Descri&#231;&#227;o da ativa&#231;&#227;o realizada:</span></span><br/><span class="c4"><span class="c3">Descrever a ativa&#231;&#227;o realizada conforme alinhado com o cliente, com detalhamento: de quantas pe&#231;as/ativa&#231;&#245;es, qual a marca e variante, qual o material e especifica&#231;&#245;es e em que local as ativa&#231;&#245;es ser&#227;o realizadas.</span></span><br/><span class="c4"><span class="c3">Exemplos:&#160;</span></span><br/><span class="c4"><span class="c3">Ativa&#231;&#227;o com Tailor Made de Absolut Regular de alum&#237;nio com ilumina&#231;&#227;o em neon azul, posicionado na parede central da cabine do DJ;</span></span><br/><span class="c4"><span class="c3">Display luminoso de Beefeater Dry de acr&#237;lico com ilumina&#231;&#227;oem vermelho, no bar principal;</span></span><br/><span class="c4"><span class="c3">Backdrop de fotos de Ballantine’s em acr&#237;lico, posicionado na entrada do estabelecimento;</span></span><br/><span class="c4"><span class="c3">Sof&#225; de tr&#234;s lugares no pantone de Chivas XV e cinco almofadas com signifier, posicionados no lounge de espera.</span></span><br/><br/><span class="c2"><span class="c3">1B. Descri&#231;&#227;o do compromisso de produtos listados na casa:</span></span><br/><span class="c4"><span class="c3">Descrever a marca e variante. Exemplo:</span></span><br/>&#160;</p><table class="c5"><col class="c6"/><col class="c6"/><tbody class="c7"><tr class="c8"><td class="c9"><span class="c2"><span class="c3">PRODUTO</span></span></td><td class="c9"><span class="c2"><span class="c3">PRODUTO</span></span></td></tr><tr class="c7"><td class="c10"><span class="c4"><span class="c3">ABSOLUT REGULAR</span></span></td><td class="c10"><span class="c4"><span class="c3">WYBOROWA</span></span></td></tr><tr class="c7"><td class="c10"><span class="c4"><span class="c3">ABSOLUT FLAVOURS</span></span></td><td class="c10"><span class="c4"><span class="c3">ORLOFF</span></span></td></tr><tr class="c7"><td class="c10"><span class="c4"><span class="c3">ABSOLUT EXTRAKT</span></span></td><td class="c10"><span class="c4"><span class="c3">SEAGRAM’S</span></span></td></tr><tr class="c7"><td class="c10"><span class="c4"><span class="c3">ABSOLUT ELYX</span></span></td><td class="c10"><span class="c4"><span class="c3">MONKEY 47</span></span></td></tr><tr class="c7"><td class="c10"><span class="c4"><span class="c3">BEEFEATER DRY</span></span></td><td class="c10"><span class="c4"><span class="c3">PLYMOUTH</span></span></td></tr><tr class="c7"><td class="c10"><span class="c4"><span class="c3">BEEFEATER PINK</span></span></td><td class="c10"><span class="c4"><span class="c3">JAMESON</span></span></td></tr><tr class="c7"><td class="c10"><span class="c4"><span class="c3">BEEFEATER 24</span></span></td><td class="c10"><span class="c4"><span class="c3">HAVANA 3</span></span></td></tr><tr class="c7"><td class="c10"><span class="c4"><span class="c3">CHIVAS 12</span></span></td><td class="c10"><span class="c4"><span class="c3">HAVANA 7</span></span></td></tr><tr class="c7"><td class="c10"><span class="c4"><span class="c3">CHIVAS XV</span></span></td><td class="c10"><span class="c4"><span class="c3">LILLET</span></span></td></tr><tr class="c7"><td class="c10"><span class="c4"><span class="c3">CHIVAS 18</span></span></td><td class="c10"><span class="c4"><span class="c3">MUMM BRUT</span></span></td></tr><tr class="c7"><td class="c10"><span class="c4"><span class="c3">BALLANTINE’S FINEST</span></span></td><td class="c10"><span class="c4"><span class="c3">MUMM ROSE</span></span></td></tr><tr class="c7"><td class="c10"><span class="c4"><span class="c3">BALLANTINE’S 12</span></span></td><td class="c10"><span class="c4"><span class="c3">RAMAZOTTI</span></span></td></tr></tbody></table><br/><span class="c2"><span class="c3">1B. PROPRIEDADES</span></span><ol class="c11"><li class="c12"><p class="c1"><span class="c13">As marcas&#160;<span class="c14">PERNOD</span>&#160;que ser&#227;o comunicadas no projeto s&#227;o Absolut, Beefeater, Ballantine’s e Chivas.</span></p></li><li class="c12"><p class="c1"><span class="c13"><span class="c3">A&#160;<span class="c14">PARCEIRA</span>&#160;ser&#225; respons&#225;vel pela aplica&#231;&#227;o das logo marcas&#160;<span class="c14">PERNOD</span>&#160;em todas as pe&#231;as de divulga&#231;&#227;o do projeto</span><span><span class="c3">, sendo obrigat&#243;ria a aprova&#231;&#227;o&#160;</span></span><span><span class="c3">previa com no m&#237;nimo 15 dias de anteced&#234;ncia de sua veicula&#231;&#227;o</span></span><span><span class="c3">.</span></span></span></p></li><li class="c12"><p class="c1"><span class="c13">As marcas Absolut, Beefeater, Chivas e Ballantine’s definidas previamente em comum acordo com a&#160;<span class="c14">PERNOD</span>, devem ter destaque em todas as a&#231;&#245;es de comunica&#231;&#227;o do projeto.</span></p></li><li class="c12"><p class="c1"><span class="c13"><span class="c3">A&#231;&#245;es/experi&#234;ncias conscientizando o consumo respons&#225;vel e/ou sustentabilidade no projeto.</span></span></p></li><li class="c12"><p class="c1"><span class="c13"><span class="c3">Locais onde as marcas devem ser comunicadas no estabelecimento:</span></span><ol class="c11"><li><p class="c1"><span class="c4"><span class="c3">Parede central da cabine do DJ;</span></span></p></li><li><p class="c1"><span class="c4"><span class="c3">No bar principal;</span></span></p></li><li><p class="c1"><span class="c4"><span class="c3">Na entrada do estabelecimento;</span></span></p></li><li><p class="c1"><span class="c4"><span class="c3">No lounge de espera.</span></span></p></li></ol></p></li><li class="c12"><p class="c1"><span class="c13">Toda e qualquer ativa&#231;&#227;o de marca criada/executada pela&#160;<span class="c14">PARCEIRA</span>&#160;deve ser alinhada com as necessidades da&#160;<span class="c14">PERNOD</span>, e aprovadas pela mesma, com no m&#237;nimo 15 dias de anteced&#234;ncia da execu&#231;&#227;o.</span></p></li></ol><span class="c2"><span class="c3">Das Obriga&#231;&#245;es da Parceira.</span></span><ol class="c11"><li class="c12"><p class="c1"><span class="c13">Prioridade de venda no portf&#243;lio da&#160;<span class="c14">PERNOD</span>&#160;nos segmentos de bebidas destiladas, espumantes e champanhe.</span></p></li><li class="c12"><p class="c1"><span class="c13">Entrega de ativa&#231;&#245;es/experi&#234;ncia das marcas&#160;<span class="c14">PERNOD&#160;</span>durante o projeto.</span></p></li><li class="c12"><p class="c1"><span class="c13">&#201; de comum acordo que a&#160;<span class="c14">PARCEIRA</span>&#160;aceita a condi&#231;&#227;o de compra dos produtos atrav&#233;s de distribuidor parceiro autorizado, considerando a tabela vigente no distribuidor no per&#237;odo da compra.</span></p></li><li class="c12"><p class="c1"><span class="c4"><span class="c3">Disponibilizar, em meio digital,&#160;</span></span><span class="c13">no m&#237;nimo 4&#160;<span class="c15">(quatro)</span>&#160;posts mensais que contenha conte&#250;do relacionado as marcas Absolut, Chivas, Ballantine’s e Beefeater, respeitando, em todo caso, a imagem de cada marca relacionada, bem como as regras relativas a responsabilidade social no consumo de bebidas alc&#243;olicas.</span></p></li></ol></body></html>'; 
        objJSON.marcasActivadas = 'Absolut';
        objJSON.comunicacaoes = 'Post Facebook';
        objJSON.ativacoes = 'Avental';

        objJSON.listVolume = new LAT_ContractHandlerJSON.ListVolume();
        objJSON.listPayment = new LAT_ContractHandlerJSON.ListPayment();
        objJSON.listContractEvent = new LAT_ContractHandlerJSON.ListContractEvent(); 
        objJSON.listClientContract = new LAT_ContractHandlerJSON.ListClientContract(); 
        objJSON.listProviders = new LAT_ContractHandlerJSON.ListProviders(); 
        objJSON.listPromotionAgreement = new LAT_ContractHandlerJSON.ListPromotionAgreement(); 
        objJSON.listContractDetail = new LAT_ContractHandlerJSON.ListContractDetail();
        objJSON.listContractEvent = new LAT_ContractHandlerJSON.ListContractEvent();
        objJSON.listVisibilityCounterPart = new LAT_ContractHandlerJSON.ListVisibilityCounterPart();

        objJSON.listVolume.volume =  new List<LAT_ContractHandlerJSON.Volume>();
        objJSON.listPayment.payment =  retrievePaymentsForCartaActivacion(strContractId);
        objJSON.listClientContract.clientContract = new List<LAT_ContractHandlerJSON.ClientContract>();
        objJSON.listProviders.provider = new List<LAT_ContractHandlerJSON.Provider>();
        objJSON.listPromotionAgreement.promotionAgreement = new List<LAT_ContractHandlerJSON.PromotionAgreement>();
        objJSON.listContractDetail.contractDetail = new List<LAT_ContractHandlerJSON.ContractDetail>();
        objJSON.listVisibilityCounterPart.visibilityCounterPart = new List<LAT_ContractHandlerJSON.VisibilityCounterPart>();

        return objJSON;
    }

    private static LAT_ContractHandlerJSON createJSONEventosContratoParceria(String strRecordType, String strContractId, String strStatus) {
        LAT_ContractHandlerJSON objJSON = null;
        Account objAccount = null;

        objAccount = [SELECT Id FROM Account WHERE Type = 'COM PAGAMENTO'];
        
        objJSON = new LAT_ContractHandlerJSON();
        objJSON.sfdcId = strContractId;
        
        if(strStatus == 'New') {
            objJSON.processStatus = 'Em Elaboração';
            objJSON.status = 'Novo Contrato';
        } else if(strStatus == 'Approve') {
            objJSON.processStatus = 'Contrato em Aprovação';
            objJSON.status = 'Em Aprovação';
        }

        objJSON.recordType = Global_RecordTypeCache.getRtId('LAT_Contract2__c' + strRecordType);
        objJSON.account = objAccount.Id;
        objJSON.startDate = DateTime.now().format('YYYY-MM-dd');
        objJSON.endDate = DateTime.now().format('YYYY-MM-dd');
        objJSON.monthElapsed = 10;
        objJSON.money = 0;
        objJSON.source = 'Mobile';
        objJSON.ConsultantToTestify = true;
        objJSON.contrapartidas = '<html><head><style type="text/css">.c0 { font-family: \'Segoe UI\'; font-size: 14px; color: Black } .c1 { margin: 0px 0px 12px 40px } .c2 { text-align: justify } .c3 { margin: 0px 0px 10px } .c4 { font-size: 13.3333333333333px } .c5 { color: #44546a } .c6 { color: #323e4f; font-size: 13.3333333333333px } .c7 { color: #323e4f } .c8 { font-family: \'Arial\',\'Arial\'; color: #44546a; font-size: 16px } .c9 { font-size: 13.3333333333333px; font-family: \'Arial\',\'Arial\' } </style></head><body class="c0"><ul class="c1"><li class="c2"><p class="c3"><span class="c4"><span class="c5">Arte de divulga&#231;&#227;o no facebook, instagram, tweeter &#160;sobre parceria XXXX vs Marca.</span></span></p></li><li><p class="c3"><span class="c4"><span class="c5">Ativa&#231;&#227;o e visibilidade da Marca dentro do evento (a ser determinado).</span></span></p></li><li><p class="c3"><span class="c6"><span><span class="c5">Divulga&#231;&#227;o e visibilidade em todo mate</span></span>rial impresso (flyers, mala direta, e VIPS) e digital dos eventos</span></p></li><li><p class="c3"><span class="c4"><span class="c7">Em caso de realiza&#231;&#227;o de log&#237;tica reversa (vidros das marcas PERNOD), a coleta dos res&#237;duos devem ser destinadas de prefer&#234;ncia ao programa Glass is Good.</span></span></p></li><li class="c2"><p class="c3"><span class="c4"><span class="c5">Disponibilizar &#224; t&#237;tulo de cortesia XX convites em da &#225;rea Vip por evento realizado, tendo fichas de consumo do evento no valor m&#237;nimo de $XXX,XX reais (XXXXXXX reais) em eventos que n&#227;o sejam Open Bar.</span></span></p></li><li class="c2"><p class="c3"><span class="c4"><span class="c5">2 livres acessos ao evento para a equipe PERNOD (credencial de trabalho ou pulseira), bem como camarote destinado a PERNOD para relacionamento.</span></span></p></li><li class="c2"><p class="c3"><span class="c4"><span class="c5">Exclusividade no portf&#243;lio da PERNOD nos segmentos de bebidas destiladas, gin, espumantes e champagne.</span></span></p></li><li class="c2"><p class="c3"><span class="c4"><span class="c5">Entrega de ativa&#231;&#245;es/experi&#234;ncia das marcas PERNOD em todos os eventos.</span></span><ul class="c1"><li><p class="c3"><span class="c4"><span class="c5">Projeto deve ser enviado pela PARCEIRA para aprova&#231;&#227;o com no m&#237;nimo 20 dias de anteced&#234;ncia do evento.</span></span></p></li><li><p class="c3"><span class="c4"><span class="c5">Veicula&#231;&#227;o de v&#237;deo das marcas PERNOD no palco, tel&#227;o e TVs do evento.</span></span></p></li></ul></p></li><li><p class="c3"><span class="c4"><span class="c5">Produ&#231;&#227;o de conte&#250;do para o v&#237;deo e fotos para report p&#243;s evento.</span></span></p></li><li class="c2"><p class="c3"><span class="c8"><span class="c4">N&#227;o vender, fornecer ou oferecer, em nenhuma hip&#243;tese, os produtos PERNOD a menores de 18 (dezoito) anos, bem como n&#227;o permitir a participa&#231;&#227;o dos menores nas eventuais a&#231;&#245;es promocionais a serem executadas em seu estabelecimento, responsabilizando-se civil e criminalmente por todos os atos que advierem da viola&#231;&#227;o do ora estabelecido.</span></span></p></li><li class="c2"><p class="c3"><span class="c8"><span class="c4">Realizar o correto descarte das garrafas dos produtos PERNOD, empreendendo seus melhores esfor&#231;os para dar-lhes destina&#231;&#227;o correta com vistas a atender &#224; legisla&#231;&#227;o do Meio Ambiente, em especial &#224; Politica Nacional de Res&#237;duos S&#243;lidos, bem como para inviabilizar o uso indevido das garrafas.</span></span></p></li><li class="c2"><p class="c3"><span class="c8"><span class="c4">Em nenhuma hip&#243;tese, a bonifica&#231;&#227;o conferida por oportunidade deste contrato &#224; PARCEIRA ser&#225; contabilizada para fins de alcance da meta de volume prevista neste contrato e em seus anexos.</span></span></p></li><li class="c2"><p class="c3"><span class="c8"><span class="c4">&#160;Produzir 50 kits para influenciadores com a marca Absolut Extrakt;</span></span><span class="c9"><span class="c5">.</span></span></p></li><li class="c2"><p class="c3"><span class="c4"><span class="c5">&#201; de comum acordo que a PARCEIRA, para usufruir das condi&#231;&#245;es comerciais e bonifica&#231;&#245;es descritas neste contrato, aceitam a condi&#231;&#227;o de compra dos produtos atrav&#233;s de distribuidor parceiro autorizado, considerando a tabela vigente no distribuidor no per&#237;odo da opera&#231;&#227;o.</span></span></p></li><li class="c2"><p class="c3"><span class="c4"><span class="c5">Disponibilizar, em meio digital, no m&#237;nimo 8 (oito) posts at&#233; a data do eventol que contenha conte&#250;do relacionado a marca Absolut, Absolut Extrakt, XXXXXXXX e Chivas, respeitando, em todo caso, a imagem da marca relacionada, bem como as regras relativas a responsabilidade social no consumo de bebidas alc&#243;olicas. Os posts realizados dever&#227;o contar com a autoriza&#231;&#227;o pr&#233;via da PERNOD antes de sua veicula&#231;&#227;o, devendo observar as regras aplicadas pelo Conar na comunica&#231;&#227;o de bebidas alco&#243;licas.</span></span></p></li></ul></body></html>'; 

        //objJSON.contractValue = '0.0';
        objJSON.isAnOpenPlace = false;
        objJSON.digital = 1.0;
        //objJSON.commercialConditionBalance = 0.0;
        objJSON.annex1 = false;
        objJSON.withoutVolumeInformation = false;
        //objJSON.roiSegment = 'LEADING';
        objJSON.roiTarget = -20.0;
        //objJSON.distribuitorId = objDistributor.Id;

        objJSON.listVolume = new LAT_ContractHandlerJSON.ListVolume();
        objJSON.listPayment = new LAT_ContractHandlerJSON.ListPayment();
        objJSON.listClientContract = new LAT_ContractHandlerJSON.ListClientContract(); 
        objJSON.listProviders = new LAT_ContractHandlerJSON.ListProviders(); 
        objJSON.listPromotionAgreement = new LAT_ContractHandlerJSON.ListPromotionAgreement(); 
        objJSON.listContractDetail = new LAT_ContractHandlerJSON.ListContractDetail();
        objJSON.listVisibilityCounterPart = new LAT_ContractHandlerJSON.ListVisibilityCounterPart();
        objJSON.listContractEvent = new LAT_ContractHandlerJSON.ListContractEvent();

        objJSON.listVolume.volume =  retrieveVolumesForEventoContratoEventos(strContractId);
        objJSON.listPayment.payment =  retrievePaymentsForEventosContratoParceria(strContractId, objAccount);
        objJSON.listClientContract.clientContract = new List<LAT_ContractHandlerJSON.ClientContract>();
        objJSON.listProviders.provider = retrieveProvidersContractsForCartaAcordoPatrocinio(strContractId);
        objJSON.listPromotionAgreement.promotionAgreement = new List<LAT_ContractHandlerJSON.PromotionAgreement>();
        objJSON.listContractDetail.contractDetail = new List<LAT_ContractHandlerJSON.ContractDetail>();
        objJSON.listVisibilityCounterPart.visibilityCounterPart = new List<LAT_ContractHandlerJSON.VisibilityCounterPart>();
        objJSON.listContractEvent.contractEvent = retrieveContractEvents(strContractId);
        
        return objJSON;
    }

    private static LAT_ContractHandlerJSON createJSONAcordo(String strRecordType, String strContractId, String strStatus) {
        LAT_ContractHandlerJSON objJSON = null;
        Account objAccount = null;

        objAccount = [SELECT Id FROM Account];


        objJSON = new LAT_ContractHandlerJSON();
        objJSON.sfdcId = strContractId;
        
        if(strStatus == 'New') {
            objJSON.processStatus = 'Em Elaboração';
            objJSON.status = 'Novo Contrato';
        } else if(strStatus == 'Approve') {
            objJSON.processStatus = 'Contrato em Aprovação';
            objJSON.status = 'Em Aprovação';
        }

        objJSON.recordType = Global_RecordTypeCache.getRtId('LAT_Contract2__c' + strRecordType);
        objJSON.account = objAccount.Id;
        objJSON.startDate = DateTime.now().format('YYYY-MM-dd');
        objJSON.endDate = DateTime.now().format('YYYY-MM-dd');
        objJSON.money = 0;
        objJSON.source = 'Mobile';
        objJSON.ConsultantToTestify = true;
        objJSON.prbPortfolio = '';
        objJSON.customerSignedBy = '';
        objJSON.contrapartidas = 'conttrapartidas';
        objJSON.listVolume = new LAT_ContractHandlerJSON.ListVolume();
        
        objJSON.listVolume.volume =  retrieveVolumesForAcordos(strContractId);
 
        return objJSON;
    }

    public static LAT_ReferenceProductGrouping__c retrieveProduct(String strRecordType) {
        LAT_ReferenceProductGrouping__c objProduct = null;

        objProduct = new LAT_ReferenceProductGrouping__c ();
        objProduct.RecordTypeId = Schema.SObjectType.LAT_ReferenceProductGrouping__c.getRecordTypeInfosByDeveloperName().get(strRecordType).getRecordTypeId();
        objProduct.Name = 'Test Parent Prod Grouping';
        objProduct.Order__c = 100;
        objProduct.GroupType__c ='SKU';
 
        return objProduct;
    }

    private static List<LAT_ContractHandlerJSON.Volume> retrieveVolumesForCartaAcordoPatrocinio(String strContractId) {
        List<LAT_ContractHandlerJSON.Volume> lstVolumes = null;
        LAT_ContractHandlerJSON.Volume objVolume = null;
        LAT_ReferenceProductGrouping__c objVolumeC = null;

        lstVolumes = new List<LAT_ContractHandlerJSON.Volume> ();
        objVolumeC = retrieveProduct('LAT_ContractVolume');   

        insert objVolumeC;

        objVolume = new LAT_ContractHandlerJSON.Volume();
        objVolume.contract = strContractId;
        objVolume.product = objVolumeC.Id;
        objVolume.boxesMaximum = '1';
        objVolume.businessCondition = '1';

        lstVolumes.add(objVolume);

        return lstVolumes;
    }

    private static List<LAT_ContractHandlerJSON.Payment> retrievePaymentsForCartaAcordoPatrocinio(String strContractId) {
        List<LAT_ContractHandlerJSON.Payment> lstPayments = null;
        LAT_ContractHandlerJSON.Payment objPayment = null;
        LAT_ReferenceProductGrouping__c objPagamentoProducto = null;
        LAT_ReferenceProductGrouping__c objChildC = null;

        lstPayments = new List<LAT_ContractHandlerJSON.Payment> ();
        objPagamentoProducto = retrieveProduct('LAT_ProductPayment');

        insert objPagamentoProducto;

        objPayment = new LAT_ContractHandlerJSON.Payment();
        objPayment.contract = strContractId;
        objPayment.productGroup = objPagamentoProducto.Id;
        objPayment.paymentDate = DateTime.now().format('YYYY-MM-dd');
        objPayment.volumen = 1;
        objPayment.producer = false;
        objPayment.toDelete = false;
        objPayment.EventPaymentCreatedAfterSigning = false;

        objPayment.recordType = Schema.SObjectType.LAT_Payment__c.getRecordTypeInfosByDeveloperName().get('LAT_PagamentoProduto').getRecordTypeId();
        
        lstPayments.add(objPayment);

        return lstPayments;
    }

    private static List<LAT_ContractHandlerJSON.ClientContract> retrieveClientsContractsForCartaAcordoPatrocinio(String strContractId, Account objAccount) {
        List<LAT_ContractHandlerJSON.ClientContract> lstClientContracts = null;
        LAT_ContractHandlerJSON.ClientContract objClientContract = null;

        lstClientContracts = new List<LAT_ContractHandlerJSON.ClientContract> ();

        objClientContract = new LAT_ContractHandlerJSON.ClientContract();
        objClientContract.contract = strContractId;
        objClientContract.client = objAccount.Id;

        lstClientContracts.add(objClientContract);

        return lstClientContracts;
    }

    private static List<LAT_ContractHandlerJSON.Provider> retrieveProvidersContractsForCartaAcordoPatrocinio(String strContractId) {
        List<LAT_ContractHandlerJSON.Provider> lstProvider = null;
        LAT_ContractHandlerJSON.Provider objProvider = null;

        lstProvider = new List<LAT_ContractHandlerJSON.Provider> ();

        objProvider = new LAT_ContractHandlerJSON.Provider();
        objProvider.contract = strContractId;
        objProvider.provider = 'FRONT';
        objProvider.cnpj = '08614297000197';

        lstProvider.add(objProvider);

        return lstProvider;
    }

    private static List<LAT_ContractHandlerJSON.PromotionAgreement> retrievePromotionAgreementContractsForCartaAcordoPatrocinio(String strContractId) {
        List<LAT_ContractHandlerJSON.PromotionAgreement> lstPromotionAgreement = null;
        LAT_ContractHandlerJSON.PromotionAgreement objPromotionAgreement = null;

        lstPromotionAgreement = new List<LAT_ContractHandlerJSON.PromotionAgreement> ();

        objPromotionAgreement = new LAT_ContractHandlerJSON.PromotionAgreement();
        objPromotionAgreement.contract = strContractId;
        objPromotionAgreement.category = 'Rum Nacional';
        objPromotionAgreement.exclusivityPromotional = false;
        objPromotionAgreement.visualExclusivity = false;
        objPromotionAgreement.priority = false;
        objPromotionAgreement.notes = 'OBSERVACION';

        lstPromotionAgreement.add(objPromotionAgreement);

        return lstPromotionAgreement;
    }

    private static List<LAT_ContractHandlerJSON.ContractDetail> retrieveContractDetailsForCartaAcordoPatrocinio(String strContractId) {
        List<LAT_ContractHandlerJSON.ContractDetail> lstClientContract = null;
        LAT_ContractHandlerJSON.ContractDetail objClientContract = null;
        LAT_ReferenceProductGrouping__c objVolumeC = null;
        LAT_Product__c objProduct = null;

        lstClientContract = new List<LAT_ContractHandlerJSON.ContractDetail> ();
        objVolumeC = retrieveProduct('LAT_Volumen');   

        lstClientContract = new List<LAT_ContractHandlerJSON.ContractDetail> ();

        objClientContract = new LAT_ContractHandlerJSON.ContractDetail();
        objClientContract.contract = strContractId;
        //objClientContract.date = DateTime.now().format('YYYY-MM-dd');
        objClientContract.date_Z = DateTime.now().format('YYYY-MM-dd');
        objClientContract.local = '111';
        objClientContract.recordType = Schema.SObjectType.LAT_ContractDetails__c.getRecordTypeInfosByDeveloperName().get('LAT_TailorMadeQuantidade').getRecordTypeId();

        lstClientContract.add(objClientContract);

        return lstClientContract;
    }

    private static List<LAT_ContractHandlerJSON.VisibilityCounterPart> retrieveVisibilityForCartaAcordoPatrocinio(String strContractId) {
        List<LAT_ContractHandlerJSON.VisibilityCounterPart> lstVisibilityCounterParts = null;
        LAT_ContractHandlerJSON.VisibilityCounterPart objVisibilityCounterPart = null;
    
        lstVisibilityCounterParts = new List<LAT_ContractHandlerJSON.VisibilityCounterPart> ();
    
        objVisibilityCounterPart = new LAT_ContractHandlerJSON.VisibilityCounterPart();
        objVisibilityCounterPart.contract = strContractId;
        //objVisibilityCounterPart.type = 'Divulgação Clube do Barman';
        objVisibilityCounterPart.type_Z = 'Divulgação Clube do Barman';
        objVisibilityCounterPart.comment = 'Observaciones';

        lstVisibilityCounterParts.add(objVisibilityCounterPart);

        return lstVisibilityCounterParts;
    }

    private static List<LAT_ContractHandlerJSON.Volume> retrieveVolumesForAcordos(String strContractId) {
        List<LAT_ContractHandlerJSON.Volume> lstVolumes = null;
        LAT_ContractHandlerJSON.Volume objVolume = null;
        LAT_ReferenceProductGrouping__c objVolumeC = null;
        LAT_ReferenceProductGrouping__c objCategoryC = null;

        lstVolumes = new List<LAT_ContractHandlerJSON.Volume> ();
        objCategoryC = retrieveProduct('LAT_BR_Acordo_Category');
        objVolumeC = retrieveProduct('LAT_BR_Acordo_Category');   

        insert objCategoryC;    
        objVolumeC.Parent__c = objCategoryC.Id;
        insert objVolumeC;

        objVolume = new LAT_ContractHandlerJSON.Volume();
        objVolume.contract = strContractId;
        objVolume.categoryid = objCategoryC.Id;
        objVolume.description = 'descipcion';
        lstVolumes.add(objVolume);

        objVolume = new LAT_ContractHandlerJSON.Volume();
        objVolume.contract = strContractId;
        objVolume.product = objVolumeC.Id;
        objVolume.valorCompreGane = 10;

        lstVolumes.add(objVolume);

        return lstVolumes;
    }

    private static List<LAT_ContractHandlerJSON.Payment> retrievePaymentsForCartaActivacion(String strContractId) {
        List<LAT_ContractHandlerJSON.Payment> lstPayments = null;
        LAT_ContractHandlerJSON.Payment objPayment = null;
        LAT_ReferenceProductGrouping__c objPagamentoProducto = null;
        LAT_ReferenceProductGrouping__c objChildC = null;

        lstPayments = new List<LAT_ContractHandlerJSON.Payment> ();
        objPagamentoProducto = retrieveProduct('LAT_ProductPayment');

        insert objPagamentoProducto;

        objPayment = new LAT_ContractHandlerJSON.Payment();
        objPayment.contract = strContractId;
        objPayment.productGroup = objPagamentoProducto.Id;
        objPayment.paymentDate = DateTime.now().format('YYYY-MM-dd');
        objPayment.volumen = 1;
        objPayment.producer = false;
        objPayment.toDelete = false;
        objPayment.finality = 'Carta Ativação';
        objPayment.status = 'P';
        objPayment.EventPaymentCreatedAfterSigning = false;
        objPayment.recordType = Schema.SObjectType.LAT_Payment__c.getRecordTypeInfosByDeveloperName().get('LAT_PagamentoProduto').getRecordTypeId();
        
        lstPayments.add(objPayment);

        objPayment = new LAT_ContractHandlerJSON.Payment();
        objPayment.contract = strContractId;
        objPayment.paymentDate = DateTime.now().format('YYYY-MM-dd');
        objPayment.volumen = 1;
        objPayment.producer = false;
        objPayment.toDelete = false;
        objPayment.finality = 'Carta Ativação';
        objPayment.status = 'P';
        objPayment.EventPaymentCreatedAfterSigning = false;
        objPayment.recordType = Schema.SObjectType.LAT_Payment__c.getRecordTypeInfosByDeveloperName().get('LAT_PagamentoDinheiro').getRecordTypeId();
        
        lstPayments.add(objPayment);

        return lstPayments;
    }
    
    private static List<LAT_ContractHandlerJSON.Volume> retrieveVolumesForEventoContratoParceria(String strContractId) {
        List<LAT_ContractHandlerJSON.Volume> lstVolumes = null;
        LAT_ContractHandlerJSON.Volume objVolume = null;
        LAT_ReferenceProductGrouping__c objVolumeC = null;
        LAT_ReferenceProduct__c objReferenceProductC = null;
        LAT_Product__c objProduct = null;

        lstVolumes = new List<LAT_ContractHandlerJSON.Volume> ();
        objVolumeC = retrieveProduct('LAT_ProductPayment');   
        insert objVolumeC;

        objProduct = new LAT_Product__c();
        objProduct.Name = 'Test';
        objProduct.RecordTypeId =  Schema.SObjectType.LAT_Product__c.getRecordTypeInfosByDeveloperName().get('BRA_Standard').getRecordTypeId();
       // insert objProduct;


        objReferenceProductC = new LAT_ReferenceProduct__c();
        objReferenceProductC.IsActive__c = true;
        objReferenceProductC.ReferenceGrouping__c = objVolumeC.Id;
        objReferenceProductC.LAT_Product__c = objProduct.Id;
        objReferenceProductC.RecordTypeId = Schema.SObjectType.LAT_ReferenceProduct__c.getRecordTypeInfosByDeveloperName().get('LAT_ProductPayment').getRecordTypeId();
        //insert objReferenceProductC;

        objVolume = new LAT_ContractHandlerJSON.Volume();
        objVolume.contract = strContractId;
        objVolume.product = objVolumeC.Id;
        objVolume.boxesMaximum = '1';
        objVolume.businessCondition = '1';
        objVolume.boxesContractMonth = '1';

        lstVolumes.add(objVolume);

        return lstVolumes;
    }

    private static List<LAT_ContractHandlerJSON.Volume> retrieveVolumesForEventoContratoEventos(String strContractId) {
        List<LAT_ContractHandlerJSON.Volume> lstVolumes = null;
        LAT_ContractHandlerJSON.Volume objVolume = null;
        LAT_ReferenceProductGrouping__c objVolumeC = null;
        LAT_ReferenceProduct__c objReferenceProductC = null;
        LAT_Product__c objProduct = null;

        lstVolumes = new List<LAT_ContractHandlerJSON.Volume> ();
        objVolumeC = retrieveProduct('LAT_ProductPayment');   
        insert objVolumeC;

        objProduct = new LAT_Product__c();
        objProduct.Name = 'Test';
        objProduct.RecordTypeId = Schema.SObjectType.LAT_Product__c.getRecordTypeInfosByDeveloperName().get('BRA_Standard').getRecordTypeId();
        //insert objProduct;

        System.debug('retrieveVolumesForEventoContratoEventos [objVolumeC.Id : ' + objVolumeC.Id + ']');
        System.debug('retrieveVolumesForEventoContratoEventos [objProduct.Id : ' + objProduct.Id + ']');

        objReferenceProductC = new LAT_ReferenceProduct__c();
        objReferenceProductC.IsActive__c = true;
        objReferenceProductC.ReferenceGrouping__c = objVolumeC.Id;
        objReferenceProductC.LAT_Product__c = objProduct.Id;
        objReferenceProductC.RecordTypeId = Schema.SObjectType.LAT_ReferenceProduct__c.getRecordTypeInfosByDeveloperName().get('LAT_ProductPayment').getRecordTypeId();
       // insert objReferenceProductC;

        objVolume = new LAT_ContractHandlerJSON.Volume();
        objVolume.contract = strContractId;
        objVolume.product = objVolumeC.Id;
        objVolume.boxesMaximum = '1';
        objVolume.businessCondition = '1';
        objVolume.boxesContractMonth = '1';

        lstVolumes.add(objVolume);

        return lstVolumes;
    }

    private static List<LAT_ContractHandlerJSON.Payment> retrievePaymentsForEventosContratoParceria(String strContractId, Account objAccount) {
        List<LAT_ContractHandlerJSON.Payment> lstPayments = null;
        LAT_ContractHandlerJSON.Payment objPayment = null;
        LAT_ReferenceProductGrouping__c objPagamentoProducto = null;
        LAT_ReferenceProductGrouping__c objChildC = null;
        LAT_ReferenceProduct__c objReferenceProductC = null;
        LAT_Product__c objProduct = null;

        lstPayments = new List<LAT_ContractHandlerJSON.Payment> ();
        objPagamentoProducto = retrieveProduct('LAT_ProductPayment');

        insert objPagamentoProducto;
        
        objProduct = new LAT_Product__c();
        objProduct.Name = 'Test';
        objProduct.RecordTypeId =  Schema.SObjectType.LAT_Product__c.getRecordTypeInfosByDeveloperName().get('BRA_Standard').getRecordTypeId();
       // insert objProduct;

        objReferenceProductC = new LAT_ReferenceProduct__c();
        objReferenceProductC.IsActive__c = true;
        objReferenceProductC.ReferenceGrouping__c = objPagamentoProducto.Id;
        objReferenceProductC.LAT_Product__c = objProduct.Id;
        objReferenceProductC.RecordTypeId = Schema.SObjectType.LAT_ReferenceProduct__c.getRecordTypeInfosByDeveloperName().get('LAT_ProductPayment').getRecordTypeId();
       // insert objReferenceProductC;
        
        objPayment = new LAT_ContractHandlerJSON.Payment();
        objPayment.contract = strContractId;
        objPayment.productGroup = objPagamentoProducto.Id;
        objPayment.paymentDate = DateTime.now().format('YYYY-MM-dd');
        objPayment.volumen = 1;
        objPayment.producer = true;
        objPayment.toDelete = false;
        objPayment.finality = 'Patrocínio';
        objPayment.status = 'P';
        objPayment.EventPaymentCreatedAfterSigning = false;
        objPayment.distribuitorId = objAccount.Id;
        objPayment.bonusQuantity = 0;
        //objPayment.isCondComChildPayment = false;
        objPayment.recordType = Schema.SObjectType.LAT_Payment__c.getRecordTypeInfosByDeveloperName().get('LAT_PagamentoProduto').getRecordTypeId();
        lstPayments.add(objPayment);

        objPayment = new LAT_ContractHandlerJSON.Payment();
        objPayment.contract = strContractId;
        objPayment.productGroup = objPagamentoProducto.Id;
        objPayment.paymentDate = DateTime.now().format('YYYY-MM-dd');
        objPayment.volumen = 1;
        objPayment.producer = false;
        objPayment.toDelete = false;
        objPayment.finality = 'Patrocínio';
        objPayment.status = 'P';
        objPayment.EventPaymentCreatedAfterSigning = false;
        objPayment.distribuitorId = objAccount.Id;
        objPayment.bonusQuantity = 0;
        //objPayment.isCondComChildPayment = false;
        objPayment.recordType = Schema.SObjectType.LAT_Payment__c.getRecordTypeInfosByDeveloperName().get('LAT_PagamentoProduto').getRecordTypeId();
        lstPayments.add(objPayment);

        objPayment = new LAT_ContractHandlerJSON.Payment();
        objPayment.contract = strContractId;
        objPayment.productGroup = objPagamentoProducto.Id;
        objPayment.paymentDate = DateTime.now().format('YYYY-MM-dd');
        objPayment.volumen = 1;
        objPayment.producer = false;
        objPayment.toDelete = false;
        objPayment.finality = 'Condição Comercial';
        objPayment.status = 'P';
        objPayment.EventPaymentCreatedAfterSigning = false;
        objPayment.distribuitorId = objAccount.Id;
        objPayment.bonusQuantity = 0;
        //objPayment.isCondComChildPayment = false;
        objPayment.recordType = Schema.SObjectType.LAT_Payment__c.getRecordTypeInfosByDeveloperName().get('LAT_PagamentoProduto').getRecordTypeId();
        lstPayments.add(objPayment);


        objPayment = new LAT_ContractHandlerJSON.Payment();
        objPayment.contract = strContractId;
        objPayment.paymentDate = DateTime.now().format('YYYY-MM-dd');
        objPayment.volumen = 1;
        objPayment.producer = true;
        objPayment.toDelete = false;
        objPayment.finality = 'Patrocínio';
        objPayment.status = 'P';
        objPayment.EventPaymentCreatedAfterSigning = false;
        objPayment.recordType = Schema.SObjectType.LAT_Payment__c.getRecordTypeInfosByDeveloperName().get('LAT_PagamentoDinheiro').getRecordTypeId();
        
        lstPayments.add(objPayment);

        return lstPayments;
    }

    private static List<LAT_ContractHandlerJSON.ContractEvent> retrieveContractEvents(String strContractId) {
        List<LAT_ContractHandlerJSON.ContractEvent> lstContractEvents = null;
        LAT_ContractHandlerJSON.ContractEvent objContractEvent = null;

        lstContractEvents = new List<LAT_ContractHandlerJSON.ContractEvent>();
        objContractEvent = new LAT_ContractHandlerJSON.ContractEvent();
        
        objContractEvent.contract = strContractId;
        objContractEvent.cidade = [SELECT Id FROM UDC__c WHERE Internal_Id__c =:UDC_CIUDAD].Id;
        objContractEvent.microRegional = 'REG PRESTIGE';                
        objContractEvent.openBar = true;
        objContractEvent.perfil = [SELECT Id FROM UDC__c WHERE Internal_Id__c =:UDC_PERFIL].Id;
        objContractEvent.periodo = 'Ambos';
        objContractEvent.tipoEvento = 'ON INVOICE';//d
        objContractEvent.tipoVerba = 'A&P';
        objContractEvent.classeSocial = 'A';
        objContractEvent.comunicacaoes = 'Post Facebook';
        objContractEvent.estilosMusicales = 'Rock';
        objContractEvent.faixaEtarias = '18-25';
        objContractEvent.motivo = 'Outros';
        objContractEvent.motivoComentarios = 'Outros';
        objContractEvent.status = 'Novo';
        //objContractEvent.valorIngresso = '0-50';        
        objContractEvent.ativacoes = 'Bar';        
        objContractEvent.marcasActivadas = 'Chivas';
        objContractEvent.marcasActivadasSR = 'Chivas';
        objContractEvent.comments  = 'Commers';
        objContractEvent.eventName = 'Name';
        objContractEvent.listVolume =  new LAT_ContractHandlerJSON.ListVolume();
        objContractEvent.listVolume.volume =  retrieveVolumesForEventoContratoEventos(strContractId);

        lstContractEvents.add(objContractEvent);

        return lstContractEvents;
    }

    private static void setupRESTContext() {
        RestRequest objRESTRequest = null; 
        RestResponse objRESTResponse = null;
        
        objRESTRequest = new RestRequest(); 
        objRESTResponse = new RestResponse();
        
        objRESTRequest.requestURI = 'https://www.salesforce.com';
        objRESTRequest.httpMethod = 'POST';
        
        RestContext.request = objRESTRequest;
        RestContext.response = objRESTResponse;        
    }

    private static void createGeneralConfigSettings() {
        List<LAT_GeneralConfig__c>  lstGeneralConfig = null;

        lstGeneralConfig = new List<LAT_GeneralConfig__c>();
        lstGeneralConfig.add(createGeneralConfigSetting('LAT_CONTRACT_CARTA_ACORDO_MAX_VALUE','50000'));

        insert lstGeneralConfig;
    }

    private static UDC__c createUDC(String strCodProd, String strCodUs, String strCodDefUsuario, String strName, String strInternalId, String strRecorType) {
        UDC__c objUDC = null;

        System.debug('createUDC [strCodUs : ' + strCodUs + ' - strCodProd : ' + strCodProd + ' - strName : ' + strName + ' - strInternalId : ' + strInternalId + ' - strRecorType : ' + strRecorType + '] ->');
        objUDC = new UDC__c();

        objUDC.CodUs__c = strCodUs;
        objUDC.CodProd__c = strCodProd;
        objUDC.Name = strName;
        objUDC.CodDefUsuario__c = strCodDefUsuario;
        //objUDC.LAT_MX_FilterKey__c = 'PY-00-AR';
        objUDC.Internal_Id__c = strInternalId;
        objUDC.RecordTypeId = Global_RecordTypeCache.getRtId('UDC__c' + strRecorType);
        
        insert objUDC;

        System.debug('createUDC [' + objUDC + '] <-');

        return objUDC;
    }

    private static LAT_GeneralConfig__c createGeneralConfigSetting(String strName, String strValue) {
        LAT_GeneralConfig__c objSetting = null;

        objSetting = new LAT_GeneralConfig__c();
        objSetting.Name = strName;
        objSetting.LAT_Value__c =  strValue;

        return objSetting;
    }
  
}