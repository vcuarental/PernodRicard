/**
* @author fabiosuenaga - topi
*/
@isTest
public with sharing class LAT_EventFixtureFactory {

    public static Account createAccount() {
        Account distributor = new Account (
            Name = 'Account Distribuidor',
            CNPJ__c = '93536508000190',
            Type = 'Outros',
            RecordTypeId = Global_RecordTypeCache.getRtId('Account' + 'LAT_Distribucao_Com_Faturamento'),
            Status__c = 'Cliente cadastrado no JDE',
            Agency__c = '000',
            Checking_account__c = '000',
            Current_account__c = '0',
            Corporate_Name__c = 'Teste 1',
            Channel__c = 'Off Trade',
            Frequency_of_Visits__c = 'Semanal',
            Channel_Type__c = 'Direto',
            Client_code_AN8__c = '557798',
            Price_Group__c = '1',
            Revenue_UF__c = 'SP'
        );

        Account account = new Account (
            Name = 'Account On_Trade',
            CNPJ__c = '48843971000120',
            Type = 'Outros',
            RecordTypeId = Global_RecordTypeCache.getRtId('Account' + 'On_Trade'),
            Status__c = 'Cliente cadastrado no JDE',
            Agency__c = '000',
            Checking_account__c = '000',
            Current_account__c = '0',
            Corporate_Name__c = 'Teste',
            Channel__c = 'Off Trade',
            Frequency_of_Visits__c = 'Semanal',
            Channel_Type__c = 'Direto',
            Client_code_AN8__c = '557799',
            Price_Group__c = '1',
            Revenue_UF__c = 'SP'
        );

        List<Account> accounts = new List<Account>{distributor, account};
        insert accounts;

        return distributor;
    }

    public static LAT_ProductCost__c createProductCost() {
        Account account = [SELECT Id FROM Account WHERE CNPJ__c = '48843971000120'];

        LAT_Product__c product = createProduct();
        LAT_ReferenceProductGrouping__c referenceProductGrouping = createProductGrouping();
        LAT_ReferenceProduct__c referenceProduct = createReferenceProduct(referenceProductGrouping.Id, product.Id); 

        LAT_ProductCost__c productCost = createProductCost(referenceProductGrouping.Id,  account.Id);

        return productCost;
    }

    public static LAT_ProductCost__c createProductCost(Id referenceProductGroupingId, Id distributorOrAccountId) {
        Integer currentYear = Date.today().year();
        Integer currentMonth = Date.today().month();
        String formattedCurrentMonth = String.valueOf(currentMonth);
        formattedCurrentMonth = (formattedCurrentMonth.length() == 1) ? '0'+formattedCurrentMonth : formattedCurrentMonth;

        UDC__c canal = new UDC__c(Name = 'teste', CodDefUsuario__c = '114', Internal_Id__c = '123');
        insert canal;

        LAT_ProductCost__c productCost = new LAT_ProductCost__c(Start_Year__c = String.valueOf(currentYear) ,
                                                                Start_Month__c = formattedCurrentMonth,
                                                                UF__c = 'SC', 
                                                                Canal__c = canal.Id,
                                                                Product__c = referenceProductGroupingId, 
                                                                Distributor__c = 2,
                                                                CM_Case__c = 161.68,  
                                                                DistributorCost__c = 514.46,  
                                                                LDCost__c = 34188, 
                                                                Net_Sales_Case__c = 224.89, 
                                                                MeasureUnit__c = 'CA', 
                                                                AN8__c = distributorOrAccountId,
                                                                EndDate__c = Date.today().addDays(2),
                                                                RecordTypeId = Global_RecordTypeCache.getRtId('LAT_ProductCost__c'+'LAT_ProductPayment') );

        Account distributor = [SELECT Id FROM Account WHERE CNPJ__c = '93536508000190' LIMIT 1];

        LAT_ProductCost__c productCostDistributor = new LAT_ProductCost__c(Start_Year__c = String.valueOf(currentYear),
                                                                            Start_Month__c = formattedCurrentMonth,
                                                                            UF__c = 'SC', 
                                                                            Product__c = referenceProductGroupingId, 
                                                                            Distributor__c = 1,
                                                                            CM_Case__c = 161.68,  
                                                                            DistributorCost__c = 514.46,  
                                                                            LDCost__c = 24188, 
                                                                            Net_Sales_Case__c = 224.89, 
                                                                            MeasureUnit__c = 'CA', 
                                                                            AN8__c = distributor.Id,
                                                                            EndDate__c = Date.today().addDays(2),
                                                                            RecordTypeId = Global_RecordTypeCache.getRtId('LAT_ProductCost__c'+'LAT_ProductPayment') );

        List<LAT_ProductCost__c> productCosts = new List<LAT_ProductCost__c>{productCost, productCostDistributor}; 

        insert productCosts;

        return productCost;
    }
    
    public static LAT_ReferenceProductGrouping__c createProductGrouping() {
        LAT_ReferenceProductGrouping__c productGrouping = new LAT_ReferenceProductGrouping__c(Name = 'BALLANTINES BRASIL', 
                                                                                            GroupType__c = 'SKU',
                                                                                            Order__c = 170.0,
                                                                                            RecordTypeId = Global_RecordTypeCache.getRtId('LAT_ReferenceProductGrouping__c'+'LAT_ProductPayment') );

        insert productGrouping;

        return productGrouping;
    }

    public static LAT_Product__c createProduct() {
        LAT_Product__c product = new LAT_Product__c(Name = 'Cachaca',
                                        LAT_ExternalId__c = '1-123',
                                        LAT_IsRefactorProduct__c = 'Y',
                                        RecordTypeId = RecordTypeForTest.getRecType( 'LAT_Product__c', 'BRA_Standard' ),
                                        LAT_SKU__c = '123',
                                        LAT_BottlesPerBox__c = 1, 
                                        LAT_BonusQuantity__c = 1
                                        );

        insert product;

        return product;
    }

    public static LAT_ReferenceProduct__c createReferenceProduct(Id referenceProductGroupingId, Id productId) {
        LAT_ReferenceProduct__c referenceProduct = new LAT_ReferenceProduct__c(
                                                                                LAT_Product__c = productId,
                                                                                RecordTypeId = Global_RecordTypeCache.getRtId('LAT_ReferenceProduct__c'+'LAT_ProductPayment'), 
                                                                                IsActive__c = true,
                                                                                Type__c = 'sku',
                                                                                ReferenceGrouping__c = referenceProductGroupingId
                                                                                );
        insert referenceProduct;

        return referenceProduct;
    }

    public static LAT_UnitConversionRates__c createUnitConversionRate(LAT_Product__c product) {
        LAT_UnitConversionRates__c conversionRate = new LAT_UnitConversionRates__c (Factor__c = 1, 
                                                                                    LAT_KeyUnica__c = '1-123-CA-BT',
                                                                                    Origen__c = 'CA',
                                                                                    Destino__c = 'BT' ,
                                                                                    LAT_Product__c = product.Id
                                                                                    );

        insert conversionRate;

        return conversionRate;
    }

    public static LAT_Contract2__c createContract(String recordTypeDeveloperName, Account distributor) {
        insert new LAT_GeneralConfig__c (Name= 'LAT_PRODUCT_COST_CHANNELS', LAT_Value__c = '101,102,103,104,112,113,114,115,116');

        LAT_ProductCost__c productCost = createProductCost();

        Account account = [SELECT Id FROM Account WHERE CNPJ__c = '48843971000120' LIMIT 1];

        LAT_Contract2__c contract = new LAT_Contract2__c (
                                                            TotalMoneyPerceivedValue__c = 1000.00,
                                                            TotalMoneyPRBCost__c = 100.00,
                                                            TotalProductsPerceivedValue__c = 10.00,
                                                            TotalProductsPRBCost__c = 10.00,
                                                            StartDate__c = Date.today().addDays(-105),
                                                            EndDate__c = Date.today().addDays(105),
                                                            Value__c = 100000.00,
                                                            DistributorTax__c = 1,
                                                            Account__c = account.Id,
                                                            LAT_Distributor__c = distributor.Id,
                                                            FreightDistributor__c = 3,
                                                            RecordtypeId = Global_RecordTypeCache.getRtId('LAT_Contract2__c'+recordTypeDeveloperName)
                                                            );

        insert contract;

        return contract;
    }

    public static List<LAT_Payment__c> createPayment(LAT_Contract2__c contract) {
        LAT_ReferenceProductGrouping__c productGrouping = [SELECT Id FROM LAT_ReferenceProductGrouping__c LIMIT 1];
            		
		LAT_ContractsCalculationsTest.createProductCost(productGrouping.Id, contract.Account__c);

        LAT_Payment__c paymentAP = new LAT_Payment__c (
                                                        LAT_Contract__c = contract.Id,
                                                        PaymentDateDone__c = Date.today(),
                                                        PaymentDate__c   = Date.today(),
                                                        RecordTypeId = Global_RecordTypeCache.getRtId('LAT_Payment__c'+'LAT_PagamentoProduto'),
                                                        paymentGoals__c = '<table cellpadding="4" border="0" style="width: 100%;" cellspacing="0"><thead><tr><th colspan="1" rowspan="1" style="text-align: left;">Produto</th><th colspan="1" rowspan="1" style="text-align: left;">Volume Previsto(LT)</th><th colspan="1" rowspan="1" style="text-align: left;">Volume Comprovado(LT)</th><th colspan="1" rowspan="1" style="text-align: left;">Meta Atingida?</th></tr></thead><tbody><tr><td colspan="1" rowspan="1"><strong>CHIVAS 12</strong></td><td colspan="1" rowspan="1">3.0</td><td colspan="1" rowspan="1">2.0</td><td colspan="1" rowspan="1">Não</td></tr><tr><td colspan="1" rowspan="1"><strong>ABSOLUT REGULAR</strong></td><td colspan="1" rowspan="1">41.1</td><td colspan="1" rowspan="1">6.0</td><td colspan="1" rowspan="1">Não</td></tr><tr><td colspan="1" rowspan="1"><strong>JAMESON</strong></td><td colspan="1" rowspan="1">16.5</td><td colspan="1" rowspan="1">26.0</td><td colspan="1" rowspan="1">Sim</td></tr><tr><td colspan="1" rowspan="1"><strong>CHIVAS 18</strong></td><td colspan="1" rowspan="1">0</td><td colspan="1" rowspan="1">2.1</td><td colspan="1" rowspan="1">Não</td></tr></tbody><tfoot><tr><td colspan="1" rowspan="1"><strong>TOTAL</strong></td><td colspan="1" rowspan="1"><strong>60.6</strong></td><td colspan="1" rowspan="1"><strong>36.1</strong></td><td colspan="1" rowspan="1"></td></tr></tfoot></table>',
                                                        Status__c = 'P',
                                                        Ammount__c = 1000.00,
                                                        ProductGroup__c = productGrouping.Id,
                                                        Finality__c = 'Condição Comercial Off Invoice',
                                                        EventType__c = 'A&P',
                                                        LAT_BonusQuantity__c = 6,
                                                        EventPaymentCreatedAfterSigning__c = false,
                                                        Volumen__c = 1,
                                                        LAT_Producer__c = false
                                                        );

        LAT_Payment__c paymentMoneyAP = new LAT_Payment__c (
                                                            LAT_Contract__c = contract.Id,
                                                            PaymentDateDone__c = Date.today(),
                                                            PaymentDate__c   = Date.today(),
                                                            RecordTypeId = Global_RecordTypeCache.getRtId('LAT_Payment__c'+'LAT_PagamentoDinheiro'),
                                                            paymentGoals__c = '<table cellpadding="4" border="0" style="width: 100%;" cellspacing="0"><thead><tr><th colspan="1" rowspan="1" style="text-align: left;">Produto</th><th colspan="1" rowspan="1" style="text-align: left;">Volume Previsto(LT)</th><th colspan="1" rowspan="1" style="text-align: left;">Volume Comprovado(LT)</th><th colspan="1" rowspan="1" style="text-align: left;">Meta Atingida?</th></tr></thead><tbody><tr><td colspan="1" rowspan="1"><strong>CHIVAS 12</strong></td><td colspan="1" rowspan="1">3.0</td><td colspan="1" rowspan="1">2.0</td><td colspan="1" rowspan="1">Não</td></tr><tr><td colspan="1" rowspan="1"><strong>ABSOLUT REGULAR</strong></td><td colspan="1" rowspan="1">41.1</td><td colspan="1" rowspan="1">6.0</td><td colspan="1" rowspan="1">Não</td></tr><tr><td colspan="1" rowspan="1"><strong>JAMESON</strong></td><td colspan="1" rowspan="1">16.5</td><td colspan="1" rowspan="1">26.0</td><td colspan="1" rowspan="1">Sim</td></tr><tr><td colspan="1" rowspan="1"><strong>CHIVAS 18</strong></td><td colspan="1" rowspan="1">0</td><td colspan="1" rowspan="1">2.1</td><td colspan="1" rowspan="1">Não</td></tr></tbody><tfoot><tr><td colspan="1" rowspan="1"><strong>TOTAL</strong></td><td colspan="1" rowspan="1"><strong>60.6</strong></td><td colspan="1" rowspan="1"><strong>36.1</strong></td><td colspan="1" rowspan="1"></td></tr></tfoot></table>',
                                                            Status__c = 'P',
                                                            Ammount__c = 1000.00,
                                                            ProductGroup__c = productGrouping.Id,
                                                            Finality__c = 'Condição Comercial Off Invoice',
                                                            EventType__c = 'A&P',
                                                            LAT_BonusQuantity__c = 6,
                                                            EventPaymentCreatedAfterSigning__c = false,
                                                            Volumen__c = 1,
                                                            LAT_Producer__c = false
                                                            );

                                                            
        LAT_Payment__c paymentNetSales = new LAT_Payment__c (
                                                            LAT_Contract__c = contract.Id,
                                                            PaymentDateDone__c = Date.today(),
                                                            PaymentDate__c   = Date.today(),
                                                            RecordTypeId = Global_RecordTypeCache.getRtId('LAT_Payment__c'+'LAT_PagamentoProduto'),
                                                            paymentGoals__c = '<table cellpadding="4" border="0" style="width: 100%;" cellspacing="0"><thead><tr><th colspan="1" rowspan="1" style="text-align: left;">Produto</th><th colspan="1" rowspan="1" style="text-align: left;">Volume Previsto(LT)</th><th colspan="1" rowspan="1" style="text-align: left;">Volume Comprovado(LT)</th><th colspan="1" rowspan="1" style="text-align: left;">Meta Atingida?</th></tr></thead><tbody><tr><td colspan="1" rowspan="1"><strong>CHIVAS 12</strong></td><td colspan="1" rowspan="1">3.0</td><td colspan="1" rowspan="1">2.0</td><td colspan="1" rowspan="1">Não</td></tr><tr><td colspan="1" rowspan="1"><strong>ABSOLUT REGULAR</strong></td><td colspan="1" rowspan="1">41.1</td><td colspan="1" rowspan="1">6.0</td><td colspan="1" rowspan="1">Não</td></tr><tr><td colspan="1" rowspan="1"><strong>JAMESON</strong></td><td colspan="1" rowspan="1">16.5</td><td colspan="1" rowspan="1">26.0</td><td colspan="1" rowspan="1">Sim</td></tr><tr><td colspan="1" rowspan="1"><strong>CHIVAS 18</strong></td><td colspan="1" rowspan="1">0</td><td colspan="1" rowspan="1">2.1</td><td colspan="1" rowspan="1">Não</td></tr></tbody><tfoot><tr><td colspan="1" rowspan="1"><strong>TOTAL</strong></td><td colspan="1" rowspan="1"><strong>60.6</strong></td><td colspan="1" rowspan="1"><strong>36.1</strong></td><td colspan="1" rowspan="1"></td></tr></tfoot></table>',
                                                            Status__c = 'P',
                                                            Ammount__c = 1000.00,
                                                            ProductGroup__c = productGrouping.Id,
                                                            Finality__c = 'Patrocínio',
                                                            EventType__c = 'A&P',
                                                            LAT_BonusQuantity__c = 1,
                                                            EventPaymentCreatedAfterSigning__c = false,
                                                            Volumen__c = 2,
                                                            LAT_Producer__c = false
                                                            );

        List<LAT_Payment__c> payments = new List<LAT_Payment__c>{paymentAP, paymentMoneyAP, paymentNetSales};
        insert payments;

        return payments;
    }

    public static LAT_Meta_ROI_Consultant__c createMetaRoiConsultant(String jdeCode, String fyCode) {
  /*      LAT_Meta_ROI_Consultant__c metaROIConsultant = new LAT_Meta_ROI_Consultant__c (
                                                                                        Consultant__c = jdeCode, 
                                                                                        FY__c = fyCode, 
                                                                                        ROI_AP__c = '1', 
                                                                                        ROI_Net_Sales__c = '2', 
                                                                                        ROI_Contrato__c = '3'
                                                                                    );
        insert metaROIConsultant;
        
        return metaROIConsultant;
        */
        return null;
    }

    public static LAT_Contract_Eventos__c createEvent(LAT_Contract2__c contract) {
        LAT_Contract_Eventos__c contractEvent = new LAT_Contract_Eventos__c(
            LAT_Contract__c = contract.Id,
            LAT_Status__c = 'Novo'
        );

        insert contractEvent;

        return contractEvent;
    }

    public static LAT_EventVolume__c createEventVolume(LAT_Contract_Eventos__c contractEvent, LAT_ReferenceProductGrouping__c productGrouping) {
        LAT_EventVolume__c eventVolume = new LAT_EventVolume__c(
            LAT_ProductGroup__c = productGrouping.Id,
            LAT_ContractEvent__c = contractEvent.Id,
            LAT_EstimatedBoxesContract__c = 1,
            LAT_BoxesContract__c = 1
        );

        insert eventVolume;

        return eventVolume;
    }
}