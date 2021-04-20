@isTest
private class LAT_Edit_AccountMobileFSControllerTest {
    
    @isTest
    static void test_general() {

        try{
        LAT_BR_ClientChannelSegmentation__c seg;
        //seg = LAT_BR_BTN02_ClientChannelSegment_TEST.clientChannelSegTestFactory();

        PageReference pf = Page.LAT_BR_Edit_AccountMobile;
        //pf.getParameters().put('id',seg.LAT_BR_Client__c);
        //Account acc = [select Id,Name from account where Id =:seg.LAT_BR_Client__c];
        // controllerNew.brAcc.Name = 'testAcc';
        // 
        Account acc = new Account(
                RecordTypeId = Global_RecordTypeCache.getRtId('Account' + 'On_Trade'), 
                CNPJ__c = '54651716001150',
                Name = 'testAccount',
                Type = 'Prospect_ARG',
                Corporate_Name__c = 'test',
                Channel_Type__c = 'Direto',
                TriggerRun__c = true
            );
            insert acc;
        // 
        
        Test.setCurrentPage(pf);
        Test.startTest();
        ApexPages.StandardController ac = new ApexPages.StandardController(acc);
        LAT_Edit_AccountMobileFSController con = new LAT_Edit_AccountMobileFSController(ac);
        LAT_Edit_AccountMobileFSController.doSave(getJSONAccount(), getJSONLat_Account(), null, 'accIdURLParam', true, getJSONFieldSetsMap(), true, false, false);
        con.selectRType();

        //create segmentation id
        LAT_Mobile_Lookup_Filter__c filter = new LAT_Mobile_Lookup_Filter__c();
        filter.Name = 'Bank__c';
        filter.LAT_Columns__c = 'Name';
        filter.LAT_Filter_Value__c = 'Internal_Id__c != null,';
        insert filter;




        //Test Lookup Fields
        LAT_Edit_AccountMobileFSController.getLookupFieldInformation('Bank__c','test');
        con.editSegmentation();
        Map<String, String> mapReqs = new Map<String, String>();
        mapReqs.put('CNPJ__c', 'Debe informar valor');
        LAT_Edit_AccountMobileFSController.validateRequiredFields(mapReqs, '', getJSONAccount());
        con.deleteClient();
        con.reset();
        Test.stopTest();
        } catch(Exception e) {
                
            }
        /*
        con.cancelSeg();

        //Test 
        


        pf.getParameters().put('credId','ttestId');
        pf.getParameters().put('segId','segIdTest');
        Test.setCurrentPage(pf);

        con.saveSegmentation();
        con.editSegmentation();
    
        */
    }

    @isTest
    static void sentCreditAnalisisApprove() {

        Account acc = LAT_Account_TestFactory.getAccountOffTradeBraComplete();
        insert acc;

        PageReference pf = Page.LAT_BR_Edit_AccountMobile;
        pf.getParameters().put('id',acc.Id);
        Test.setCurrentPage(pf);
        Test.startTest();
        ApexPages.StandardController ac = new ApexPages.StandardController(acc);
        LAT_Edit_AccountMobileFSController con = new LAT_Edit_AccountMobileFSController(ac);
        LAT_Edit_AccountMobileFSController.doSave(getJSONAccount(), getJSONLat_Account(), null, 'accIdURLParam', true, getJSONFieldSetsMap(), true, false, false);
        con.selectRType();

        //create segmentation id
        LAT_Mobile_Lookup_Filter__c filter = new LAT_Mobile_Lookup_Filter__c();
        filter.Name = 'Bank__c';
        filter.LAT_Columns__c = 'Name'; 
        filter.LAT_Filter_Value__c = 'Internal_Id__c != null,';
        insert filter;

        //Test Lookup Fields
        LAT_Edit_AccountMobileFSController.getLookupFieldInformation('Bank__c','test');
        con.cancelSeg();
        con.saveSegmentation();
        LAT_Edit_AccountMobileFSController.validateAccountDataRemoting(acc.Id);

        //Test 
        
        //con.sendApprovalAccount();


        pf.getParameters().put('credId','ttestId');
        pf.getParameters().put('segId','segIdTest');
        Test.setCurrentPage(pf);
        /*
        con.saveSegmentation();
        con.editSegmentation();
        */

    }

    @isTest
    static void sentgonza() {
        LAT_WS_CustomerHandlerInterface_Test.testSetup();
        PageReference pageRef = Page.LAT_BR_SegmentationSlct;
        Test.setCurrentPage(pageRef);
        LAT_BR_SegmentationSlctController controllerNew = new LAT_BR_SegmentationSlctController();
        controllerNew.newSegmentation.q1_canal_negocio__c = 'É um intermediário que terá a responsabilidade de entregar os produtos da empresa para o ponto de venda final (CNPJ). Canais utilizados para alcançar pontos de venda On-Trade, Off Trade e Eventos.';
        controllerNew.newSegmentation.q2_relacao_comercial__c = '121-Cliente no qual emitimos pedidos e pagamentos (Dinheiro e "ou" Produtos).';
        controllerNew.isNew = true;
        controllerNew.brAcc.Name = 'testAcc';
        controllerNew.brAcc.TriggerRun__c = true;
        controllerNew.brAcc.Revenue_UF__c         = 'SP';
        controllerNew.brAcc.State_registration__c = '110.042.490.114';
        controllerNew.CreateClient();
        System.debug('%%%%% RecordTypeId de la controllerNew.brAcc: ' + controllerNew.brAcc.RecordTypeId);
        Account acc = controllerNew.brAcc;
        
        Test.startTest();
        
        ApexPages.StandardController ac = new ApexPages.StandardController(acc);
        LAT_Edit_AccountMobileFSController con = new LAT_Edit_AccountMobileFSController(ac);
        //Test Lookup Fields
        
        LAT_Mobile_Lookup_Filter__c filter = new LAT_Mobile_Lookup_Filter__c();
        filter.Name = 'Bank__c';
        filter.LAT_Columns__c = 'Name';
        filter.LAT_Filter_Value__c = 'Internal_Id__c != null,';
        insert filter;
        LAT_Edit_AccountMobileFSController.getLookupFieldInformation('Bank__c','test');
        LAT_Edit_AccountMobileFSController.validateAccountDataRemoting(acc.Id);
        con.getAllfields(acc.Id);
        Test.stopTest();
    }
    
    
    @isTest
    static void sentoffTradeUpdate() {
        LAT_WS_CustomerHandlerInterface_Test.testSetup();
        PageReference pageRef = Page.LAT_BR_SegmentationSlct;
        Test.setCurrentPage(pageRef);
        LAT_BR_SegmentationSlctController controllerNew = new LAT_BR_SegmentationSlctController();
        controllerNew.newSegmentation.q1_canal_negocio__c = 'É um intermediário que terá a responsabilidade de entregar os produtos da empresa para o ponto de venda final (CNPJ). Canais utilizados para alcançar pontos de venda On-Trade, Off Trade e Eventos.';
        controllerNew.newSegmentation.q2_relacao_comercial__c = '121-Cliente no qual emitimos pedidos e pagamentos (Dinheiro e "ou" Produtos).';
        controllerNew.isNew = true;
        controllerNew.brAcc.Name = 'testAcc';
        controllerNew.brAcc.TriggerRun__c = true;
        controllerNew.brAcc.Revenue_UF__c         = 'SP';
        controllerNew.brAcc.State_registration__c = '110.042.490.114';
        controllerNew.CreateClient();
        System.debug('%%%%% RecordTypeId de la controllerNew.brAcc: ' + controllerNew.brAcc.RecordTypeId);
        Account acc = controllerNew.brAcc;
        
        
        Analise_de_credito__c acred = new Analise_de_credito__c();
        acred.Conta__c = acc.id;
        insert acred;
        Test.startTest();
        PageReference pf = Page.LAT_BR_Edit_AccountMobile;
        pf.getParameters().put('id',acc.Id);
        Test.setCurrentPage(pf);
        ApexPages.StandardController ac = new ApexPages.StandardController(acc);
        LAT_Edit_AccountMobileFSController con = new LAT_Edit_AccountMobileFSController(ac);
        LAT_Edit_AccountMobileFSController.doSave(getJSONAccount(), getJSONLat_Account(), null, 'accIdURLParam', true, getJSONFieldSetsMap(), true, false, false);
        con.selectRType();
        con.credIdParam = acred.id;
        //create segmentation id
        LAT_Mobile_Lookup_Filter__c filter = new LAT_Mobile_Lookup_Filter__c();
        filter.Name = 'Bank__c';
        filter.LAT_Columns__c = 'Name';
        filter.LAT_Filter_Value__c = 'Internal_Id__c != null,';
        insert filter;

        //Test Lookup Fields
        LAT_Edit_AccountMobileFSController.getLookupFieldInformation('Bank__c','test');
        //con.cancelSeg();
        LAT_Edit_AccountMobileFSController.getAllfieldsStatic (acc.Id, new Map<String, Object>());
        Map<String, String> mapReqs = new Map<String, String>();
        mapReqs.put('CNPJ__c', 'Debe informar valor');
        LAT_Edit_AccountMobileFSController.validateRequiredFields(mapReqs, acc.Id, getJSONAccount());
        //Test 
        con.sendApprovalCredit();
        Test.stopTest();
        /*
        Test.setCurrentPage(pf);

        con.saveSegmentation();
        con.editSegmentation();
        */
    }

    public static String getJSONAccount(){
        return '{ '+
            '    "Accept_Backorder__c": true, '+
            '    "Accept_applications_Incompleted__c": false, '+
            '    "Accept_line_incompleted__c": true, '+
            '    "Accept_pallet_CHEP__c": false, '+
            '    "Accept_pallet_NF__c": false, '+
            '    "Agency__c": "0912", '+
            '    "Amount_due__c": 0, '+
            '    "Bank__c": "a4yD0000000CeBHIA0", '+
            '    "Bank__r": { '+
            '        "CurrencyIsoCode": "BRL", '+
            '        "Id": "a4yD0000000CeBHIA0", '+
            '        "Name": "Banco Itaú S.A.e", '+
            '        "RecordTypeId": "012D00000007DLvIAM", '+
            '        "attributes": { '+
            '            "type": "UDC__c", '+
            '            "url": "/services/data/v45.0/sobjects/UDC__c/a4yD0000000CeBHIA0" '+
            '        } '+
            '    }, '+
            '    "Business_Unit__c": "a4yD0000000t28fIAA", '+
            '    "Business_Unit__r": { '+
            '        "CurrencyIsoCode": "BRL", '+
            '        "Id": "a4yD0000000t28fIAA", '+
            '        "Name": "PREXTREMA", '+
            '        "RecordTypeId": "012D00000007DLvIAM", '+
            '        "attributes": { '+
            '            "type": "UDC__c", '+
            '            "url": "/services/data/v45.0/sobjects/UDC__c/a4yD0000000t28fIAA" '+
            '        } '+
            '    }, '+
            '    "CNPJ__c": "00776574000156", '+
            '    "Carriers_Numbers__c": "149146", '+
            '    "Checking_account__c": "9000", '+
            '    "Client_code_AN8__c": "134920", '+
            '    "Contact_Schedule__c": "003D000001J8m5jIAB", '+
            '    "Corporate_Name__c": "B2W COMPANHIA DIGITAL", '+
            '    "Credit_line__c": 1100000, '+
            '    "CurrencyIsoCode": "BRL", '+
            '    "Current_account__c": "8", '+
            '    "Customer_Flag__c": "a4yD0000000CfemIAC", '+
            '    "Customer_Flag__r": { '+
            '        "CurrencyIsoCode": "BRL", '+
            '        "Id": "a4yD0000000CfemIAC", '+
            '        "Name": "B2W", '+
            '        "RecordTypeId": "012D00000007DLvIAM", '+
            '        "attributes": { '+
            '            "type": "UDC__c", '+
            '            "url": "/services/data/v45.0/sobjects/UDC__c/a4yD0000000CfemIAC" '+
            '        } '+
            '    }, '+
            '    "Customer_Geographic_Region__c": "a4yD0000000CfZdIAK", '+
            '    "Customer_Geographic_Region__r": { '+
            '        "CurrencyIsoCode": "BRL", '+
            '        "Id": "a4yD0000000CfZdIAK", '+
            '        "Name": "SUDESTE", '+
            '        "RecordTypeId": "012D00000007DLvIAM", '+
            '        "attributes": { '+
            '            "type": "UDC__c", '+
            '            "url": "/services/data/v45.0/sobjects/UDC__c/a4yD0000000CfZdIAK" '+
            '        } '+
            '    }, '+
            '    "Customer_Organization__c": "a4yD0000000CfZGIA0", '+
            '    "Customer_Organization__r": { '+
            '        "CurrencyIsoCode": "BRL", '+
            '        "Id": "a4yD0000000CfZGIA0", '+
            '        "Name": "OUTRAS ORGANIZACOES", '+
            '        "RecordTypeId": "012D00000007DLvIAM", '+
            '        "attributes": { '+
            '            "type": "UDC__c", '+
            '            "url": "/services/data/v45.0/sobjects/UDC__c/a4yD0000000CfZGIA0" '+
            '        } '+
            '    }, '+
            '    "Email_NFE__c": "danieli.waltz@pernod-ricard-brasil.com", '+
            '    "How_many__c": 1, '+
            '    "Id": "001D0000015iA0oIAE", '+
            '    "IsPersonAccount": false, '+
            '    "LAT_BR_RegionalClientOnPremise__c": "REG SPC", '+
            '    "Name": "B2W COMPANHIA DIGITAL", '+
            '    "Necessary_to_inform_the_Fiscal_Number__c": false, '+
            '    "Need_helpers__c": true, '+
            '    "Nielsen_Area__c": "a4yD0000000CeEZIA0", '+
            '    "Nielsen_Area__r": { '+
            '        "CurrencyIsoCode": "BRL", '+
            '        "Id": "a4yD0000000CeEZIA0", '+
            '        "Name": "Area Nielsen 4", '+
            '        "RecordTypeId": "012D00000007DLvIAM", '+
            '        "attributes": { '+
            '            "type": "UDC__c", '+
            '            "url": "/services/data/v45.0/sobjects/UDC__c/a4yD0000000CeEZIA0" '+
            '        } '+
            '    }, '+
            '    "Overdue__c": false, '+
            '    "Owner": { '+
            '        "CurrencyIsoCode": "BRL", '+
            '        "Id": "005D000000251gtIAA", '+
            '        "Name": "Danieli Waltz", '+
            '        "attributes": { '+
            '            "type": "User", '+
            '            "url": "/services/data/v45.0/sobjects/User/005D000000251gtIAA" '+
            '        } '+
            '    }, '+
            '    "OwnerId": "005D000000251gtIAA", '+
            '    "Payment_Condition__c": "a4yD0000000Ce63IAC", '+
            '    "Payment_Condition__r": { '+
            '        "CurrencyIsoCode": "BRL", '+
            '        "Id": "a4yD0000000Ce63IAC", '+
            '        "Name": "Tab preço a vista", '+
            '        "RecordTypeId": "012D00000007DLvIAM", '+
            '        "attributes": { '+
            '            "type": "UDC__c", '+
            '            "url": "/services/data/v45.0/sobjects/UDC__c/a4yD0000000Ce63IAC" '+
            '        } '+
            '    }, '+
            '    "Payment_instrument__c": "a4yD0000000CeDaIAK", '+
            '    "Payment_instrument__r": { '+
            '        "CurrencyIsoCode": "BRL", '+
            '        "Id": "a4yD0000000CeDaIAK", '+
            '        "Name": "COBRANCA CARTEIRA", '+
            '        "RecordTypeId": "012D00000007DLvIAM", '+
            '        "attributes": { '+
            '            "type": "UDC__c", '+
            '            "url": "/services/data/v45.0/sobjects/UDC__c/a4yD0000000CeDaIAK" '+
            '        } '+
            '    }, '+
            '    "Phone": "11 1111-2222", '+
            '    "Process_EDI__c": false, '+
            '    "Rating": "Cliente Ativo", '+
            '    "Receiving_Freight__c": "Apenas batida", '+
            '    "RecordType": { '+
            '        "Id": "0121i000000g1IiAAI", '+
            '        "Name": "Off-Trade/Com Faturamento", '+
            '        "attributes": { '+
            '            "type": "RecordType", '+
            '            "url": "/services/data/v45.0/sobjects/RecordType/0121i000000g1IiAAI" '+
            '        } '+
            '    }, '+
            '    "RecordTypeId": "0121i000000g1IiAAI", '+
            '    "Regional__c": "a4yD0000000Ce9GIAS", '+
            '    "Regional__r": { '+
            '        "CurrencyIsoCode": "BRL", '+
            '        "Id": "a4yD0000000Ce9GIAS", '+
            '        "Name": "REG LESTE", '+
            '        "RecordTypeId": "012D00000007DLvIAM", '+
            '        "attributes": { '+
            '            "type": "UDC__c", '+
            '            "url": "/services/data/v45.0/sobjects/UDC__c/a4yD0000000Ce9GIAS" '+
            '        } '+
            '    }, '+
            '    "Revenue_Address__c": "RUA HENRY FORD", '+
            '    "Revenue_City__c": "a4yD0000000CfFHIA0", '+
            '    "Revenue_City__r": { '+
            '        "CurrencyIsoCode": "BRL", '+
            '        "Id": "a4yD0000000CfFHIA0", '+
            '        "Name": "OSASCO", '+
            '        "RecordTypeId": "012D00000007DLvIAM", '+
            '        "attributes": { '+
            '            "type": "UDC__c", '+
            '            "url": "/services/data/v45.0/sobjects/UDC__c/a4yD0000000CfFHIA0" '+
            '        } '+
            '    }, '+
            '    "Revenue_Country__c": "BR", '+
            '    "Revenue_Neighbourhood__c": "PRESIDENTE ALTINO", '+
            '    "Revenue_Number__c": "643", '+
            '    "Revenue_Postal_Code__c": "06210108", '+
            '    "Revenue_UF__c": "SP", '+
            '    "State_Registration__c": "492513778117", '+
            '    "Status__c": "Cliente cadastrado no JDE", '+
            '    "Unload__c": false, '+
            '    "Vehicle_Type__c": "Truck;3/4", '+
            '    "Yes_No__c": true, '+
            '    "attributes": { '+
            '        "type": "Account", '+
            '        "url": "/services/data/v45.0/sobjects/Account/001D0000015iA0oIAE" '+
            '    } '+
            '} ';
    }

    public static String getJSONLat_Account(){
        return '{ '+
        '    "CurrencyIsoCode": "BRL", '+
        '    "Id": "aAuD000000002QBKAY", '+
        '    "LAT_CustomerContractsClassification__c": false, '+
        '    "LAT_DirectSale__c": false, '+
        '    "LAT_JDEZone__c": "31C", '+
        '    "Name": "08184", '+
        '    "RecordTypeId": "012D00000007LFTIA2", '+
        '    "attributes": { '+
        '        "type": "LAT_ACCOUNT__c", '+
        '        "url": "/services/data/v45.0/sobjects/LAT_ACCOUNT__c/aAuD000000002QBKAY" '+
        '    } '+
        '} ';
    }

    public static String getJSONFieldSetsMap(){
        return '{ ' +
            '    "LAT_BR_offCompletos_Dados_Pagam_04": [ ' +
            '        { ' +
            '            "dbRequired": false, ' +
            '            "fieldPath": "Bank__c", ' +
            '            "label": "*Banco", ' +
            '            "required": false, ' +
            '            "type": "reference", ' +
            '            "typeApex": "REFERENCE" ' +
            '        } ' +
            '    ], ' +
            '    "LAT_BR_offCompletos_Endereco_de_Fat_03": [ ' +
            '        { ' +
            '            "dbRequired": false, ' +
            '            "fieldPath": "Revenue_Postal_Code__c", ' +
            '            "label": "*CEP", ' +
            '            "required": true, ' +
            '            "type": "string", ' +
            '            "typeApex": "STRING" ' +
            '        }, ' +
            '        { ' +
            '            "dbRequired": false, ' +
            '            "fieldPath": "Revenue_Address__c", ' +
            '            "label": "*Logradouro", ' +
            '            "required": true, ' +
            '            "type": "string", ' +
            '            "typeApex": "STRING" ' +
            '        } ' +
            '    ], ' +
            '    "LAT_BR_offcompletos_Informa_pedidos_05": [ ' +
            '        { ' +
            '            "dbRequired": false, ' +
            '            "fieldPath": "Accept_applications_Incompleted__c", ' +
            '            "label": "*Aceita pedidos incompletos", ' +
            '            "required": false, ' +
            '            "type": "boolean", ' +
            '            "typeApex": "BOOLEAN" ' +
            '        }, ' +
            '        { ' +
            '            "dbRequired": false, ' +
            '            "fieldPath": "Accept_Backorder__c", ' +
            '            "label": "*Aceita pedido em Back-order", ' +
            '            "required": false, ' +
            '            "type": "boolean", ' +
            '            "typeApex": "BOOLEAN" ' +
            '        }, ' +
            '        { ' +
            '            "dbRequired": false, ' +
            '            "fieldPath": "Accept_line_incompleted__c", ' +
            '            "label": "*Aceita linha incompleta", ' +
            '            "required": false, ' +
            '            "type": "boolean", ' +
            '            "typeApex": "BOOLEAN" ' +
            '        } ' +
            '    ] ' +
            '} ';
    }
}