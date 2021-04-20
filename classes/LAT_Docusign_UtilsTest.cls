/**
 * this class add coverage for the following classes
 * -LAT_BR_DocusignDataTriggerHandler
 * -LAT_Docusign_Utils
 * -LAT_ContractsCalculations( ds integration new lines)
 * @author ernesto@zimmic.com
 */
@isTest
public with sharing class LAT_Docusign_UtilsTest {
    /**
     * Create a testing attachment for the opportunity
     */
    private static Attachment addAttachmentToParent(Id parentId) {
        Blob b = Blob.valueOf('Test Data');

        Attachment attachment = new Attachment();
        attachment.ParentId = parentId;
        attachment.Name = 'Test Attachment for Parent';
        attachment.Body = b;

        insert(attachment);
        return attachment;
    }

    public static List<User> generateConfigUsers(LAT_Docusign_Config__c config) {
        List<User> configUsers = new List<User>();
        User man = getLAT_SystemAdminUser('theManager@manager.test');

        Profile p = [SELECT Id FROM Profile WHERE Name='LAT_BR2_Vendas'];
        User u2 = new User(Alias = 'newUser2', Email='newuser2@testorg.com',
        EmailEncodingKey='UTF-8', LastName='Testing2', LanguageLocaleKey='en_US',
        LocaleSidKey='en_US',  ProfileId = p.Id, managerid = man.Id,
        TimeZoneSidKey='America/Los_Angeles', UserName='CaseAR2@mail.com');
        User u3 = new User(Alias = 'newUser3', Email='newuser2@testorg.com',
        EmailEncodingKey='UTF-8', LastName='Testing2', LanguageLocaleKey='en_US',
        LocaleSidKey='en_US',  ProfileId = p.Id, managerid = man.Id,
        TimeZoneSidKey='America/Los_Angeles', UserName='CaseAR3@mail.com');
        User u4 = new User(Alias = 'newUser3', Email='newuser3@testorg.com',
        EmailEncodingKey='UTF-8', LastName='Testing2', LanguageLocaleKey='en_US',
        LocaleSidKey='en_US',  ProfileId = p.Id, managerid = man.Id,
        TimeZoneSidKey='America/Los_Angeles', UserName='CaseAR4@mail.com');
        User u5 = new User(Alias = 'newUser4', Email='newuser4@testorg.com',
        EmailEncodingKey='UTF-8', LastName='Testing2', LanguageLocaleKey='en_US',
        LocaleSidKey='en_US',  ProfileId = p.Id, managerid = man.Id,
        TimeZoneSidKey='America/Los_Angeles', UserName='CaseAR5@mail.com');
        User u6 = new User(Alias = 'newUser2', Email='newuser6@testorg.com',
        EmailEncodingKey='UTF-8', LastName='Testing2', LanguageLocaleKey='en_US',
        LocaleSidKey='en_US',  ProfileId = p.Id, managerid = man.Id,
        TimeZoneSidKey='America/Los_Angeles', UserName='CaseAR6@mail.com');
        configUsers = new List<User>{u2,u3,u4,u5,u6};
        insert configUsers;
        config.LAT_ComercialDirectorId__c = u2.Id;
        config.LAT_FinancialDirectorId__c = u3.Id;
        config.LAT_PresidentId__c = u4.Id;
        config.LAT_TradeManagerId__c = u5.Id;
        config.LAT_Testemunha_PRB_Id__c = u6.Id;
        config.LAT_ComercialDirectorId_PRESTIGE__c = u2.Id;
        config.LAT_FinancialDirectorId__c = u3.Id;
        config.LAT_PresidentId__c = u4.Id;
        config.LAT_TradeManagerId__c = u5.Id;
        config.LAT_Testemunha_PRB_Id_PRESTIGE__c = u6.Id;
        config.LAT_Testemunha_PRB_Id_Eventos__c = u4.Id;
        return configUsers;
    }

    public static User getLAT_SystemAdminUser(String username) {
        Profile p = [SELECT Id FROM Profile WHERE Name='LAT_SystemAdministrator'];
        User u2 = new User(Alias = username.left(6), Email='newuser@testorg.com',
        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
        LocaleSidKey='en_US',  ProfileId = p.Id,
        TimeZoneSidKey='America/Los_Angeles', UserName=username);
        insert u2;
        return u2;
    }

    public static LAT_Contract2__c getTestContract(Id ManagerId) {
        LAT_Contract2__c con = new LAT_Contract2__c();
        con.TotalMoneyPerceivedValue__c = 1000.00;
        con.TotalMoneyPRBCost__c = 100.00;
        con.TotalProductsPerceivedValue__c = 10.00;
        con.TotalProductsPRBCost__c = 10.00;
        con.StartDate__c = Date.today().addDays(-105);
        con.EndDate__c = Date.today().addDays(105);
        con.Value__c = 1000000.00;
        con.Status__c = 'Aprovado';
        con.RegionalManager__c = ManagerId;
        return con;
    }

    public static LAT_Payment__c getPaymentForContract(LAT_Contract2__c con) {
        LAT_ReferenceProductGrouping__c rpg = new LAT_ReferenceProductGrouping__c(
            Name = 'Volume',
            ExternalId__c = '1234',
            GroupType__c = 'SKU',
            Order__c = 10000 );
        insert rpg;
        LAT_Payment__c pay = new LAT_Payment__c();
        pay.ProductGroup__c = rpg.Id;
        pay.LAT_Contract__c = con.Id;
        pay.Ammount__c = 100;
        pay.Volumen__c = 5;
        pay.Status__c = 'Previsto';
        pay.PaymentDate__c = Date.today().addDays(-5);
        pay.PaymentDateDone__c = Date.today().addDays(-5);
        return pay;
    }

    @isTest
    static void test_method_one() {

        Id StaticResourceId = [Select Id from StaticResource limit 1].id;
        insert new LAT_GeneralConfig__c (Name= 'LAT_ContractMinutaPadrao', LAT_Value__c = StaticResourceId);
        insert new LAT_GeneralConfig__c (Name= 'LAT_PRODUCT_COST_CHANNELS', LAT_Value__c = '101,102,103,104,112,113,114,115,116');
            LAT_Docusign_Config__c dSconfig = new LAT_Docusign_Config__c
                                (ds_Username__c = 'testUsername',
                                 ds_password__c='test',
                                 ds_integrationKey__c = 'test',
                                 Sent_to_President_Eventos__c = 1,
                                 Sent_to_President_PRESTIGE__c = 1,
                                 Sent_to_Comercial_Director_Eventos__c = 1,
                                 Sent_to_Comercial_Director__c = 1, 
                                 Sent_to_Comercial_Director_PRESTIGE__c = 1, 
                                 Sent_to_Financial_Director_Eventos__c = 1, 
                                 Sent_to_Financial_Director_PRESTIGE__c = 1, 
                                 Sent_to_President__c = 1);
            generateConfigUsers(dSconfig);
            insert dSconfig;
        User u = getLAT_SystemAdminUser('runnerUser@mail.test');

        System.runAs(u) {

            LAT_Contract2__c con = getTestContract(u.Id);
            insert con;
            LAT_Payment__c pay = LAT_ContractsWS_Test.getPaymentProductoWithParent(con.Id);
            insert pay;
            LAT_ContractsCalculations contCalc = new LAT_ContractsCalculations();

            List<Id> idsContratos = new List<Id>();
            idsContratos.add(con.Id);
            Test.startTest();
            Attachment att = addAttachmentToParent(con.Id);
            LAT_Docusign_Utils.requestEnvelopeCreation(con, new List<Attachment>{att});
 
            // UPDATE THE GENERATED ENVELOPES
            LAT_Docusign_Status__c status = [SELECT Name,Id,Envelope_Status__c FROM LAT_DocuSign_Status__c LIMIT 1];

            List<LAT_DocuSign_Recipient_Status__c> recipientes = [SELECT Id,
                            Name,
                            Routing_Order__c,
                            Parent_Status_Record__c,
                            Role__c
                     FROM
                         LAT_DocuSign_Recipient_Status__c ORDER BY Routing_Order__c ASC];

            // Ds sent the file
            recipientes[0].Recipient_Status__c = LAT_Docusign_Utils.DS_ENVELOPE_STATUS_SENT;
            update recipientes[0];
            // ds recipient sign it
            recipientes[0].Recipient_Status__c = LAT_Docusign_Utils.DS_ENVELOPE_STATUS_COMPLETED;
            update recipientes[0];
            // envelope is finished
            status.Envelope_Status__c = LAT_Docusign_Utils.DS_ENVELOPE_STATUS_COMPLETED;
            update status;
            recipientes[1].Recipient_Status__c = LAT_Docusign_Utils.DS_RECIPIENT_STATUS_DECLINED;
            update recipientes[0];
            status.Envelope_Status__c = LAT_Docusign_Utils.DS_RECIPIENT_STATUS_DECLINED;
            update status;
            recipientes[0].Recipient_Status__c = LAT_Docusign_Utils.DS_RECIPIENT_STATUS_DELIVERY_FAIL;
            update recipientes[0];


            Attachment at = new Attachment(name = 'CANC_TEST', parentId = con.Id, Body = Blob.valueOf('test'));
            insert at;

            try {
                LAT_Docusign_Utils.cancelDocusignFuture(con.Id);
            } catch (Exception e){
            //none
            }
            Test.stopTest();
        }
    }

    @isTest
    private static void docusingAcordosTest() {
        Id StaticResourceId = [Select Id from StaticResource limit 1].id;
        insert new LAT_GeneralConfig__c (Name= 'LAT_ContractMinutaPadrao', LAT_Value__c = StaticResourceId);
        insert new LAT_GeneralConfig__c (Name= 'LAT_PRODUCT_COST_CHANNELS', LAT_Value__c = '101,102,103,104,112,113,114,115,116');
            LAT_Docusign_Config__c dSconfig = new LAT_Docusign_Config__c
                                (ds_Username__c = 'testUsername',
                                 ds_password__c='test',
                                 ds_integrationKey__c = 'test',
                                 Sent_to_President_Eventos__c = 1,
                                 Sent_to_President_PRESTIGE__c = 1,
                                 Sent_to_Comercial_Director_Eventos__c = 1,
                                 Sent_to_Comercial_Director__c = 1, 
                                 Sent_to_Comercial_Director_PRESTIGE__c = 1, 
                                 Sent_to_Financial_Director_Eventos__c = 1, 
                                 Sent_to_Financial_Director_PRESTIGE__c = 1, 
                                 Sent_to_President__c = 1);
            generateConfigUsers(dSconfig);
            insert dSconfig;
        User u = getLAT_SystemAdminUser('runnerUser@mail.test');
        User objUserVendas = getLAT_BR2Vendas();
        createSignersForContracts(objUserVendas);


        System.runAs(u) {

            LAT_Contract2__c con = getTestContract(u.Id);
            con.RecordTypeId = Global_RecordTypeCache.getRtId('LAT_Contract2__c'+'LAT_BR_Acordo');
            insert con;
            LAT_Payment__c pay = LAT_ContractsWS_Test.getPaymentProductoWithParent(con.Id);
            insert pay;
            LAT_ContractsCalculations contCalc = new LAT_ContractsCalculations();

            List<Id> idsContratos = new List<Id>();
            idsContratos.add(con.Id);
            Test.startTest();
            Attachment att = addAttachmentToParent(con.Id);
            LAT_Docusign_Utils.requestEnvelopeCreation(con, new List<Attachment>{att});

            // UPDATE THE GENERATED ENVELOPES
            LAT_Docusign_Status__c status = [SELECT Name,Id,Envelope_Status__c FROM LAT_DocuSign_Status__c LIMIT 1];

            List<LAT_DocuSign_Recipient_Status__c> recipientes = [SELECT Id,
                            Name,
                            Routing_Order__c,
                            Parent_Status_Record__c,
                            Role__c
                     FROM
                         LAT_DocuSign_Recipient_Status__c ORDER BY Routing_Order__c ASC];

            // Ds sent the file
            recipientes[0].Recipient_Status__c = LAT_Docusign_Utils.DS_ENVELOPE_STATUS_SENT;
            update recipientes[0];
            // ds recipient sign it
            recipientes[0].Recipient_Status__c = LAT_Docusign_Utils.DS_ENVELOPE_STATUS_COMPLETED;
            update recipientes[0];
            // envelope is finished
            status.Envelope_Status__c = LAT_Docusign_Utils.DS_ENVELOPE_STATUS_COMPLETED;
            update status;
            recipientes[1].Recipient_Status__c = LAT_Docusign_Utils.DS_RECIPIENT_STATUS_DECLINED;
            update recipientes[0];
            status.Envelope_Status__c = LAT_Docusign_Utils.DS_RECIPIENT_STATUS_DECLINED;
            update status;
            recipientes[0].Recipient_Status__c = LAT_Docusign_Utils.DS_RECIPIENT_STATUS_DELIVERY_FAIL;
            update recipientes[0];


            Attachment at = new Attachment(name = 'CANC_TEST', parentId = con.Id, Body = Blob.valueOf('test'));
            insert at;

            try {
                LAT_Docusign_Utils.cancelDocusignFuture(con.Id);
            } catch (Exception e){
            //none
            }
            Test.stopTest();
        }
    }
    public static User getLAT_BR2Vendas() {        
        User usuarioVendas = [SELECT Id, Email FROM User WHERE Profile.Name = 'LAT_BR2_Vendas' AND IsActive = true and Email <> null 
                                AND Id NOT IN (SELECT UserOrGroupId FROM GroupMember WHERE Group.Name = 'LAT_BR_Vendas_Restringido') AND Managerid <> null AND Gerente_regional__c <>null  LIMIT 1];
        return usuarioVendas;
    }

    private static void createSignersForContracts(USer objUserVendas) {
        List<LAT_Docusign_Signer__c> lstSignersC = null;
        LAT_Docusign_Signer__c objSigner = null;
        LAT_Docusign__c objContractType = null;
        Schema.DescribeFieldResult objDocumentType = null;
        Schema.DescribeFieldResult objRole = null;
        List<Schema.PicklistEntry> lstPickListEntry = null;
        Contact objCliente = null;
        Integer intIndex = 0;

        lstSignersC = new List<LAT_Docusign_Signer__c>();

        objDocumentType = LAT_Docusign__c.fields.LAT_Document_Type__c.getDescribe();		
        objRole = LAT_Docusign_Signer__c.fields.LAT_Role__c.getDescribe();

 		for( Schema.PicklistEntry objPickListEntry : objDocumentType.getPicklistValues()){
            objContractType = new LAT_Docusign__c();
            objContractType.LAT_Document_Type__c = objPickListEntry.getValue();
            objContractType.LAT_Action__c = 'Create';
            insert objContractType;

            intIndex = 1;
            lstSignersC = new List<LAT_Docusign_Signer__c>();
            for(Schema.PicklistEntry objPickListEntry2 : objRole.getPicklistValues() ) {
                objSigner = new LAT_Docusign_Signer__c();
                objSigner.LAT_Role__c = objPickListEntry2.getValue();
                objSigner.LAT_Docusign__c = objContractType.Id; 
                objSigner.LAT_Order__c = intIndex;

                if(objPickListEntry.getValue() == 'Cliente') {

                } else {
                    objSigner.LAT_Signer__c = objUserVendas.Id;
                }
                lstSignersC.add(objSigner);
            }

            insert lstSignersC;
        }          
        
        
    }

    @isTest
    static void test_method_2B() {

        Id StaticResourceId = [Select Id from StaticResource limit 1].id;
        insert new LAT_GeneralConfig__c (Name= 'LAT_ContractMinutaPadrao', LAT_Value__c = StaticResourceId);
        insert new LAT_GeneralConfig__c (Name= 'LAT_PRODUCT_COST_CHANNELS', LAT_Value__c = '101,102,103,104,112,113,114,115,116');
            LAT_Docusign_Config__c dSconfig = new LAT_Docusign_Config__c
                                (ds_Username__c = 'testUsername',
                                 ds_password__c='test',
                                 ds_integrationKey__c = 'test'
                                 );
            generateConfigUsers(dSconfig);
            insert dSconfig;
        User u = getLAT_SystemAdminUser('runnerUser@mail.test');

        System.runAs(u) {

            LAT_Contract2__c con = getTestContract(u.Id);
            con.Use_Consultant_to_Testify__c = true;
            insert con;
            LAT_Payment__c pay = LAT_ContractsWS_Test.getPaymentProductoWithParent(con.Id);
            insert pay;
            LAT_ContractsCalculations contCalc = new LAT_ContractsCalculations();

            List<Id> idsContratos = new List<Id>();
            idsContratos.add(con.Id);
            Test.startTest();
            Attachment att = addAttachmentToParent(con.Id);
            LAT_Docusign_Utils.requestEnvelopeCreation(con, new List<Attachment>{att});

            // UPDATE THE GENERATED ENVELOPES
            LAT_Docusign_Status__c status = [SELECT Name,Id,Envelope_Status__c FROM LAT_DocuSign_Status__c LIMIT 1];

            List<LAT_DocuSign_Recipient_Status__c> recipientes = [SELECT Id,
                            Name,
                            Routing_Order__c,
                            Parent_Status_Record__c,
                            Role__c
                     FROM
                         LAT_DocuSign_Recipient_Status__c ORDER BY Routing_Order__c ASC];

            // Ds sent the file
            recipientes[0].Recipient_Status__c = LAT_Docusign_Utils.DS_ENVELOPE_STATUS_SENT;
            update recipientes[0];
            // ds recipient sign it
            recipientes[0].Recipient_Status__c = LAT_Docusign_Utils.DS_ENVELOPE_STATUS_COMPLETED;
            recipientes[0].RecipientId__c = '123';

            update recipientes[0];
            // envelope is finished
            status.Envelope_Status__c = LAT_Docusign_Utils.DS_ENVELOPE_STATUS_COMPLETED;
            update status;
            recipientes[1].Recipient_Status__c = LAT_Docusign_Utils.DS_RECIPIENT_STATUS_DECLINED;
            update recipientes[0];
            status.Envelope_Status__c = LAT_Docusign_Utils.DS_RECIPIENT_STATUS_DECLINED;
            update status;
            recipientes[0].Recipient_Status__c = LAT_Docusign_Utils.DS_RECIPIENT_STATUS_DELIVERY_FAIL;
            update recipientes[0];
            LAT_Docusign_Utils.requestResendButton(recipientes[0].Id);
            LAT_Docusign_Utils.voidEnvelope();
            LAT_Docusign_Utils.generateSignersNewUpdateContractPRESTIGE(con);
            LAT_Docusign_Utils.generateSignersNewUpdateContractEventos(con);
            
            Test.stopTest();
        }
    }

    @isTest
    static void test_method_3() {

        Id StaticResourceId = [Select Id from StaticResource limit 1].id;
        insert new LAT_GeneralConfig__c (Name= 'LAT_ContractMinutaPadrao', LAT_Value__c = StaticResourceId);
        insert new LAT_GeneralConfig__c (Name= 'LAT_PRODUCT_COST_CHANNELS', LAT_Value__c = '101,102,103,104,112,113,114,115,116');
            LAT_Docusign_Config__c dSconfig = new LAT_Docusign_Config__c
                                (ds_Username__c = 'testUsername',
                                 ds_password__c='test',
                                 ds_integrationKey__c = 'test'
                                 );
            generateConfigUsers(dSconfig);
            insert dSconfig;
        User u = getLAT_SystemAdminUser('runnerUser@mail.test');

        System.runAs(u) {

            LAT_Contract2__c con = getTestContract(u.Id);
            con.status__c = 'Distrato Aprovado';
            con.Use_Consultant_to_Testify__c = true;
            insert con;
            
            LAT_Payment__c pay = LAT_ContractsWS_Test.getPaymentProductoWithParent(con.Id);
            insert pay;
            LAT_ContractsCalculations contCalc = new LAT_ContractsCalculations();

            List<Id> idsContratos = new List<Id>();
            idsContratos.add(con.Id);
            Test.startTest();
            Attachment att = addAttachmentToParent(con.Id);
            LAT_Docusign_Utils.requestEnvelopeCreation(con, new List<Attachment>{att});

            // UPDATE THE GENERATED ENVELOPES
            LAT_Docusign_Status__c status = [SELECT Name,Id,Envelope_Status__c FROM LAT_DocuSign_Status__c LIMIT 1];

            List<LAT_DocuSign_Recipient_Status__c> recipientes = [SELECT Id,
                            Name,
                            Routing_Order__c,
                            Parent_Status_Record__c,
                            Role__c
                     FROM
                         LAT_DocuSign_Recipient_Status__c ORDER BY Routing_Order__c ASC];

            // Ds sent the file
            recipientes[0].Recipient_Status__c = LAT_Docusign_Utils.DS_ENVELOPE_STATUS_SENT;
            update recipientes[0];
            // ds recipient sign it
            recipientes[0].Recipient_Status__c = LAT_Docusign_Utils.DS_ENVELOPE_STATUS_COMPLETED;
            update recipientes[0];
            // envelope is finished
            status.Envelope_Status__c = LAT_Docusign_Utils.DS_ENVELOPE_STATUS_COMPLETED;
            update status;
            recipientes[1].Recipient_Status__c = LAT_Docusign_Utils.DS_RECIPIENT_STATUS_DECLINED;
            update recipientes[0];
            status.Envelope_Status__c = LAT_Docusign_Utils.DS_RECIPIENT_STATUS_DECLINED;
            update status;
            recipientes[0].Recipient_Status__c = LAT_Docusign_Utils.DS_RECIPIENT_STATUS_DELIVERY_FAIL;
            update recipientes[0];


            Attachment at = new Attachment(name = 'CANC_TEST', parentId = con.Id, Body = Blob.valueOf('test'));
            insert at;

            try {
                LAT_Docusign_Utils.cancelDocusignFuture(con.Id);
            } catch (Exception e){
            //none
            }
            Test.stopTest();
        }
    }

   @isTest
    static void test_method_4() {

        Id StaticResourceId = [Select Id from StaticResource limit 1].id;
        insert new LAT_GeneralConfig__c (Name= 'LAT_ContractMinutaPadrao', LAT_Value__c = StaticResourceId);
        insert new LAT_GeneralConfig__c (Name= 'LAT_PRODUCT_COST_CHANNELS', LAT_Value__c = '101,102,103,104,112,113,114,115,116');
            LAT_Docusign_Config__c dSconfig = new LAT_Docusign_Config__c
                                (ds_Username__c = 'testUsername',
                                 ds_password__c='test',
                                 ds_integrationKey__c = 'test'
                                 );
            generateConfigUsers(dSconfig);
            insert dSconfig;
        User u = getLAT_SystemAdminUser('runnerUser@mail.test');

        System.runAs(u) {

            LAT_Contract2__c con = getTestContract(u.Id);
            con.status__c = 'Distrato Aprovado';
            con.Use_Consultant_to_Testify__c = true;
            con.RecordTypeId =  Global_RecordTypeCache.getRtId('LAT_Contract2__c'+'LAT_CartaAtivacao');
            insert con;
            
            LAT_Payment__c pay = LAT_ContractsWS_Test.getPaymentProductoWithParent(con.Id);
            insert pay;
            LAT_ContractsCalculations contCalc = new LAT_ContractsCalculations();

            List<Id> idsContratos = new List<Id>();
            idsContratos.add(con.Id);
            Test.startTest();
            Attachment att = addAttachmentToParent(con.Id);
            LAT_Docusign_Utils.requestEnvelopeCreation(con, new List<Attachment>{att});

            // UPDATE THE GENERATED ENVELOPES
            LAT_Docusign_Status__c status = [SELECT Name,Id,Envelope_Status__c FROM LAT_DocuSign_Status__c LIMIT 1];

            List<LAT_DocuSign_Recipient_Status__c> recipientes = [SELECT Id,
                            Name,
                            Routing_Order__c,
                            Parent_Status_Record__c,
                            Role__c
                     FROM
                         LAT_DocuSign_Recipient_Status__c ORDER BY Routing_Order__c ASC];

            // Ds sent the file
            recipientes[0].Recipient_Status__c = LAT_Docusign_Utils.DS_ENVELOPE_STATUS_SENT;
            update recipientes[0];
            // ds recipient sign it
            recipientes[0].Recipient_Status__c = LAT_Docusign_Utils.DS_ENVELOPE_STATUS_COMPLETED;
            update recipientes[0];
            // envelope is finished
            status.Envelope_Status__c = LAT_Docusign_Utils.DS_ENVELOPE_STATUS_COMPLETED;
            update status;
            recipientes[1].Recipient_Status__c = LAT_Docusign_Utils.DS_RECIPIENT_STATUS_DECLINED;
            update recipientes[0];
            status.Envelope_Status__c = LAT_Docusign_Utils.DS_RECIPIENT_STATUS_DECLINED;
            update status;
            recipientes[0].Recipient_Status__c = LAT_Docusign_Utils.DS_RECIPIENT_STATUS_DELIVERY_FAIL;
            update recipientes[0];


            Attachment at = new Attachment(name = 'CANC_TEST', parentId = con.Id, Body = Blob.valueOf('test'));
            insert at;

            try {
                LAT_Docusign_Utils.generateSignersNewUpdateContractCartaAtivacao(con);
            } catch (Exception e){
            //none
            }
            Test.stopTest();
        }
    }
    
    @isTest
    static void test_LAT_Rest_Docusign() {
        User u = getLAT_SystemAdminUser('runnerUser@mail.test');

        System.runAs(u) {
            LAT_Contract2__c con = getTestContract(u.Id);
            con.status__c = 'Distrato Aprovado';
            con.Use_Consultant_to_Testify__c = true;
            con.RecordTypeId =  Global_RecordTypeCache.getRtId('LAT_Contract2__c'+'LAT_CartaAtivacao');
            insert con;

            List<Id> idsContratos = new List<Id>();
            idsContratos.add(con.Id);
            Test.startTest();
            Attachment att = addAttachmentToParent(con.Id);
            LAT_Docusign_Utils.requestEnvelopeCreation(con, new List<Attachment>{att});

            List<LAT_DocuSign_Recipient_Status__c> recipientes = [SELECT Id, Name, Routing_Order__c, Parent_Status_Record__c, Role__c
                                                                FROM LAT_DocuSign_Recipient_Status__c ORDER BY Routing_Order__c ASC];
            RestRequest request = new RestRequest();
            RestResponse response = new RestResponse();
            request.requestURI = 'https://XXXX.salesforce.com/services/apexrest/LAT_Rest_Docusign/'+recipientes[0].Id;
            request.httpMethod = 'POST';
            RestContext.request = request;
            RestContext.response = response;
            
            Map<String,String> mapa = new Map<String,String>();
            mapa.put('ANY key', 'ANY value');
            String mockbody = '[{ "mesage": "Alteração realizada na Docusign."}]';
            Test.setMock(HttpCalloutMock.class, new LAT_MockHttpResponseGenerator(1, 'Status', mockbody , mapa));
            // try {
                LAT_REST_Docusign.doPOST();
            //} catch(Exception e){}
        }
    }
}