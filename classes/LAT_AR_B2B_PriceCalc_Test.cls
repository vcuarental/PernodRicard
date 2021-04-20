@istest
public with sharing  class LAT_AR_B2B_PriceCalc_Test {

    static boolean hayErrores = false;

    @testSetup
    static void setup(){
        delete [SELECT Id FROM PRH_Iconic_Account_Trigger__c];
        insert LAT_TestFactory.createCS001_JDECredentials('Argentina','6');
        insert new LAT_GeneralConfig__c (Name='AR_B2B_PriceCalcBatchInterval', LAT_Value__c = '120');
        insert new LAT_GeneralConfig__c (Name='AR_B2B_EmailSoporte', LAT_Value__c = 'test@test.com');
    }

    @isTest
    static void test_LAT_AR_B2B_PriceCalc_Scheduler(){
        LAT_B2B_Price_Configs__c conf = new LAT_B2B_Price_Configs__c(
            Name = 'TEST',
            LAT_Account__c = '109836',
            LAT_LastExecution__c = Date.Today().addDays(-1),
            LAT_InternalId__c   = '6-H03-01-03'
        );
        insert conf;

        Account acc = LAT_Account_TestFactory.getAccountOffTradeArgComplete();
        acc.Name = 'ProdutosOppVerificaCotaExistenteTeste';
        acc.Status__c = 'Cliente cadastrado no JDE';
        acc.Frequency_of_Visits__c = 'Semanal';
        acc.Client_code_AN8__c = '109836';
        acc.Client_country_an8__c = '6-557799';
        acc.Corporate_Name__c = 'Teste';
        acc.Checking_account__c = '000';
        acc.Carriers_Numbers__c = '123';
        //acc.CNPJ__c = '48843971000120';
        acc.Current_account__c = '0';
        acc.Channel__c = 'Off Trade';
        acc.Price_Group__c = '1';
        acc.Agency__c = '000';
        acc.Type = 'Outros';
        //acc.Regional__c = regional.Id;
        //acc.Customer_Flag__c = customerFlag.Id;
        //acc.Business_Unit__c = businessUnit.Id;
        insert acc;

        Test.startTest();
        LAT_Product__c produto2 = new LAT_Product__c();
        produto2.Name = 'TestProd';
        produto2.LAT_IsActive__c = true;
        produto2.LAT_IsRefactorProduct__c = 'Y';
        produto2.LAT_CDUnit__c = 'UN';
        produto2.LAT_ExternalId__c = '444';
        produto2.LAT_Country__c = 6;
        produto2.LAT_Sku__c = '5666';
        produto2.LAT_EAN__c = '89540468709';
        produto2.RecordTypeId = Global_RecordTypeCache.getRtId( 'LAT_Product__c'+'Standard_AR' );
        insert produto2;
        
        String CRON_EXP = '0 0 0 3 9 ? 2022';
        LAT_AR_B2B_PriceCalc_Scheduler taskSched = new LAT_AR_B2B_PriceCalc_Scheduler();
        String jobId = System.schedule('ScheduleApexClassTest', CRON_EXP, taskSched);
        Test.stopTest();
    }

    @isTest
    static void test_LAT_AR_B2B_PriceCalc_Scheduler2(){
        hayErrores = true;
        LAT_B2B_Price_Configs__c conf = new LAT_B2B_Price_Configs__c(
            Name = 'TEST',
            LAT_Account__c = '109836',
            LAT_LastExecution__c = Date.Today().addDays(-1),
            LAT_InternalId__c   = '6-H03-01-03'
        );
        insert conf;
        LAT_B2B_Price_Configs__c conf2 = new LAT_B2B_Price_Configs__c(
            Name = 'TEST 2',
            LAT_Account__c = '109822',
            LAT_LastExecution__c = Date.Today().addDays(-1),
            LAT_InternalId__c   = '6-A03-01-03'
        );
        insert conf2;

        Account acc = LAT_Account_TestFactory.getAccountOffTradeArgComplete();
        acc.Name = 'ProdutosOppVerificaCotaExistenteTeste';
        acc.Status__c = 'Cliente cadastrado no JDE';
        acc.Frequency_of_Visits__c = 'Semanal';
        acc.Client_code_AN8__c = '109836';
        acc.Client_country_an8__c = '6-557799';
        acc.Corporate_Name__c = 'Teste';
        acc.Checking_account__c = '000';
        acc.Carriers_Numbers__c = '123';
        //acc.CNPJ__c = '48843971000120';
        acc.Current_account__c = '0';
        acc.Channel__c = 'Off Trade';
        acc.Price_Group__c = '1';
        acc.Agency__c = '000';
        acc.Type = 'Outros';
        //acc.Regional__c = regional.Id;
        //acc.Customer_Flag__c = customerFlag.Id;
        //acc.Business_Unit__c = businessUnit.Id;
        insert acc;

        Test.startTest();
        LAT_Product__c produto2 = new LAT_Product__c();
        produto2.Name = 'TestProd';
        produto2.LAT_IsActive__c = true;
        produto2.LAT_IsRefactorProduct__c = 'Y';
        produto2.LAT_CDUnit__c = 'UN';
        produto2.LAT_ExternalId__c = '444';
        produto2.LAT_Country__c = 6;
        produto2.LAT_Sku__c = '5666';
        produto2.LAT_EAN__c = '89540468709';
        produto2.RecordTypeId = Global_RecordTypeCache.getRtId( 'LAT_Product__c'+'Standard_AR' );
        insert produto2;
        
        String CRON_EXP = '0 0 0 3 9 ? 2022';
        LAT_AR_B2B_PriceCalc_Scheduler taskSched = new LAT_AR_B2B_PriceCalc_Scheduler();
        String jobId = System.schedule('ScheduleApexClassTest', CRON_EXP, taskSched);
        Test.stopTest();
    }

    @isTest
    static void test_LAT_B2B_PIMIntegration(){

        List<LAT_Product__c> toInsert = new List<LAT_Product__c>();
        for(Integer i =1; i<40; i++){
            LAT_Product__c produto = new LAT_Product__c();
            produto.Name = 'TestProd'+i;
            produto.LAT_IsActive__c = true;
            produto.LAT_IsRefactorProduct__c = 'Y';
            produto.LAT_CDUnit__c = 'UN';
            produto.LAT_ExternalId__c = '444'+i;
            produto.LAT_Country__c = 6;
            produto.LAT_Sku__c = '5666'+i;
            produto.LAT_EAN__c = '3444342'+i;
            produto.RecordTypeId = Global_RecordTypeCache.getRtId( 'LAT_Product__c'+'Standard_AR' );
            toInsert.add(produto);
        }
        LAT_Product__c produto2 = new LAT_Product__c();
        produto2.Name = 'TestProd';
        produto2.LAT_IsActive__c = true;
        produto2.LAT_IsRefactorProduct__c = 'Y';
        produto2.LAT_CDUnit__c = 'UN';
        produto2.LAT_ExternalId__c = '444';
        produto2.LAT_Country__c = 6;
        produto2.LAT_Sku__c = '5666';
        produto2.LAT_EAN__c = '89540468709';
        produto2.RecordTypeId = Global_RecordTypeCache.getRtId( 'LAT_Product__c'+'Standard_AR' );
        toInsert.add(produto2);
        
        insert toInsert;
        Test.startTest();
        Map<String,String> mapa = new Map<String,String>();
        mapa.put('ANY key', 'ANY value');
            
        Test.setMock(HttpCalloutMock.class, new LAT_MockHttpResponseGenerator(200, '200', getResponseBody(), mapa));
        LAT_B2B_PIMIntegration cls = new LAT_B2B_PIMIntegration();
        cls.makePIMCallout(cls.getProducts());
        Test.stopTest();

    }

    public static LAT_JDE_PriceCalculation.priceCatalogueHeaderOutput getRespuesta(){

        LAT_JDE_PriceCalculation.priceCatalogueHeaderOutput retorno = new LAT_JDE_PriceCalculation.priceCatalogueHeaderOutput();
        if(hayErrores){
            LAT_JDE_PriceCalculation.errorRecords error = new LAT_JDE_PriceCalculation.errorRecords();
            error.errorCode = '1';
            error.errorDescription = 'test';
            List<LAT_JDE_PriceCalculation.errorRecords> errors = new List<LAT_JDE_PriceCalculation.errorRecords>();
            errors.add(error);
            retorno.errorRecords =  errors; 
        }
        LAT_JDE_PriceCalculation.priceCatalogueDetailsOutput detalle = new LAT_JDE_PriceCalculation.priceCatalogueDetailsOutput();
        detalle.unitofMeasure ='CA';
        detalle.unitPrice = 11.0;
        detalle.amountTax = 11.0;
        detalle.amountExcise = 11.0;
        detalle.itemNumberShort = 5666;
        detalle.discountAndChargeDetails = new List<LAT_JDE_PriceCalculation.discountAndChargeDetailsOutput>();
        List<LAT_JDE_PriceCalculation.priceCatalogueDetailsOutput> priceCatalogueDetails = new List<LAT_JDE_PriceCalculation.priceCatalogueDetailsOutput>();
        priceCatalogueDetails.add(detalle);
        retorno.priceCatalogueDetails = priceCatalogueDetails;
        return retorno;

            
    }
    static String getResponseBody(){
            String retorno = '{'+
            '     "facets": {'+
            '         "brand.id": {'+
            '             "PRPECOMB000052": 1'+
            '         },'+
            '         "size.label": {'+
            '             "0.75 L": 1'+
            '         },'+
            '         "brand.label": {'+
            '             "Malibu": 1'+
            '         },'+
            '         "productType": {'+
            '             "BQS": 1'+
            '         },'+
            '         "category.label": {'+
            '             "Liqueur": 1'+
            '         },'+
            '         "language.label": {'+
            '             "Spanish (Argentina)": 1'+
            '         },'+
            '         "onlineExclusive": {'+
            '             "false": 1'+
            '         },'+
            '         "brandQuality.label": {'+
            '             "Malibu Original 21%": 1'+
            '         }'+
            '     },'+
            '     "hits": ['+
            '         {'+
            '             "id": "PRPECOM000801",'+
            '             "productType": "BQS",'+
            '             "language": {'+
            '                 "language": "es",'+
            '                 "market": "AR",'+
            '                 "locale": "es_AR",'+
            '                 "label": "Spanish (Argentina)"'+
            '             },'+
            '             "retailer": null,'+
            '             "ebxLastUpdateDate": "2018-01-15T16:20:27.677",'+
            '             "pimUpdateDate": 1563534394757,'+
            '             "path": "BProductEcommerce/ProductEcommerce-es_AR/root/Product/PRPECOM000801",'+
            '             "bcCode": "853821",'+
            '             "gtinCodeList": ['+
            '                 {'+
            '                     "gtinCode": "89540468709"'+
            '                 }'+
            '             ],'+
            '             "skuStatus": "ready",'+
            '             "productName": "Malibu Ron Botella de 750 ml",'+
            '             "brand": {'+
            '                 "id": "PRPECOMB000052",'+
            '                 "label": "Malibu"'+
            '             },'+
            '             "brandQuality": {'+
            '                 "id": "PRPECOMBQ000075",'+
            '                 "label": "Malibu Original 21%"'+
            '             },'+
            '             "quality": "Original 21%",'+
            '             "size": {'+
            '                 "id": "0.75",'+
            '                 "value": 0.75,'+
            '                 "label": "0.75 L"'+
            '             },'+
            '             "category": {'+
            '                 "id": "Liqueur",'+
            '                 "label": "Liqueur"'+
            '             },'+
            '             "countryOfOrigin": "Canada",'+
            '             "onlineExclusive": false,'+
            '             "alcoholLevel": 21,'+
            '             "translatedInTheLocale": true,'+
            '             "availableInTheMarket": true,'+
            '             "gtrExclusive": false,'+
            '             "translationActivatedOn": null,'+
            '             "partnerActivationDate": null,'+
            '             "description": "El Malibú es un ron hecho en las Barbados con extracto natural de coco. Malibu es el sol en una botella con un sabor dulce y suave del coco. Es el ron caribeño con sabor a coco de mayor venta del mundo.",'+
            '             "manufacturerDetails": "Manzanares, España",'+
            '             "packagingDetails": "750 ml Botella",'+
            '             "consumptionTips": "Malibu & Pineapple: 1 part (50 ml) Malibu Original 2 parts (100 ml) pineapple juice 1 lime wedge Fill a chilled highball glass with ice cubes and add Malibu. Top up with pineapple juice. Garnish with a lime wedge. You can also enjoy in many other drinks such as Malibu & Cola or as a Pina Colada.",'+
            '             "ingredientList": "Caribbean Rum, Sweetner and Flavoring",'+
            '             "productHistory": "Malibu is an original Caribbean coconut rum, that was born and lives in a place where the spirit of summer shines all year round.",'+
            '             "variety": null,'+
            '             "vintage": null,'+
            '             "foodPairing": null,'+
            '             "vineyardHistory": null,'+
            '             "medalsAndAwards": null,'+
            '             "medalsAndAwardsList": [],'+
            '             "tastingNotes": null,'+
            '             "color": null,'+
            '             "taste": null,'+
            '             "aroma": null,'+
            '             "nutritional": {},'+
            '             "storageUseAdvice": null,'+
            '             "publishToWeCommerce": true,'+
            '             "keyWords": ['+
            '                 "null"'+
            '             ],'+
            '             "gs1": {'+
            '                 "airlineExclusive": false,'+
            '                 "allergen": null,'+
            '                 "containsGMO": false,'+
            '                 "codeForBestBefore": null,'+
            '                 "customsTariffNumber": null,'+
            '                 "tariffPreferenceCustomsStatus": null,'+
            '                 "handelingAdvice": null,'+
            '                 "storageAdvice": null,'+
            '                 "totalStorageLife": null,'+
            '                 "holding": null,'+
            '                 "vbst": null,'+
            '                 "vbstProductCode": null,'+
            '                 "cartonsPerPallet": null,'+
            '                 "contentPerCarton": null,'+
            '                 "width": null,'+
            '                 "height": null,'+
            '                 "length": null,'+
            '                 "depth": null,'+
            '                 "grossWeight": null,'+
            '                 "netWeight": null,'+
            '                 "federalState": null,'+
            '                 "basicDataTextGerman": null,'+
            '                 "packageKind": {'+
            '                     "content": null,'+
            '                     "label": null'+
            '                 },'+
            '                 "withColouring": null,'+
            '                 "limitedEdition": null,'+
            '                 "startAvailabilityDateTime": null,'+
            '                 "endAvailabilityDateTime": null'+
            '             },'+
            '             "localFields": {},'+
            '             "mediaList": ['+
            '                 {'+
            '                     "damAssetId": "314856",'+
            '                     "mediaType": "Image",'+
            '                     "channel": "Web",'+
            '                     "mainTag": "Packshot",'+
            '                     "tag": "E-Commerce",'+
            '                     "ordering": 1,'+
            '                     "originalInfo": {'+
            '                         "size": "2.22 MB",'+
            '                         "height": 3000,'+
            '                         "width": 3000'+
            '                     },'+
            '                     "urls": {'+
            '                         "original": "https://assets.pernod-ricard.io/pim/production/v2/Malibu_Ron_Botella_de_750_ml_es_AR_1_original.png?version=1563534394483",'+
            '                         "bamArticleFull": "https://assets.pernod-ricard.io/pim/production/v2/Malibu_Ron_Botella_de_750_ml_es_AR_1_bamArticleFull.png?version=1563534394495",'+
            '                         "forsightPreview": "https://assets.pernod-ricard.io/pim/production/v2/Malibu_Ron_Botella_de_750_ml_es_AR_1_forsightPreview.png?version=1563534394506",'+
            '                         "thumbnail": "https://assets.pernod-ricard.io/pim/production/v2/Malibu_Ron_Botella_de_750_ml_es_AR_1_thumbnail.png?version=1563534394517",'+
            '                         "forsightLargePreview": "https://assets.pernod-ricard.io/pim/production/v2/Malibu_Ron_Botella_de_750_ml_es_AR_1_forsightLargePreview.png?version=1563534394530"'+
            '                     }'+
            '                 },'+
            '                 {'+
            '                     "damAssetId": "314857",'+
            '                     "mediaType": "Image",'+
            '                     "channel": "Web",'+
            '                     "mainTag": "Packshot",'+
            '                     "tag": "E-Commerce",'+
            '                     "ordering": 2,'+
            '                     "originalInfo": {'+
            '                         "size": "0.43 MB",'+
            '                         "height": 3000,'+
            '                         "width": 3000'+
            '                     },'+
            '                     "urls": {'+
            '                         "original": "https://assets.pernod-ricard.io/pim/production/v2/Malibu_Ron_Botella_de_750_ml_es_AR_2_original.jpg?version=1563534394542",'+
            '                         "bamArticleFull": "https://assets.pernod-ricard.io/pim/production/v2/Malibu_Ron_Botella_de_750_ml_es_AR_2_bamArticleFull.jpg?version=1563534394553",'+
            '                         "forsightPreview": "https://assets.pernod-ricard.io/pim/production/v2/Malibu_Ron_Botella_de_750_ml_es_AR_2_forsightPreview.jpg?version=1563534394564",'+
            '                         "thumbnail": "https://assets.pernod-ricard.io/pim/production/v2/Malibu_Ron_Botella_de_750_ml_es_AR_2_thumbnail.jpg?version=1563534394577",'+
            '                         "forsightLargePreview": "https://assets.pernod-ricard.io/pim/production/v2/Malibu_Ron_Botella_de_750_ml_es_AR_2_forsightLargePreview.jpg?version=1563534394590"'+
            '                     }'+
            '                 },'+
            '                 {'+
            '                     "damAssetId": "189909",'+
            '                     "mediaType": "Movie",'+
            '                     "channel": "Web",'+
            '                     "mainTag": "Packshot",'+
            '                     "tag": "How to mix a Pina Colada Video",'+
            '                     "ordering": 5,'+
            '                     "originalInfo": {'+
            '                         "size": "9.96 MB",'+
            '                         "height": 720,'+
            '                         "width": 1280'+
            '                     },'+
            '                     "urls": {'+
            '                         "original": "https://assets.pernod-ricard.io/pim/production/v2/video/Malibu_Ron_Botella_de_750_ml_es_AR_5_original.mp4?version=1563534394630",'+
            '                         "bamPresentationUse": "https://assets.pernod-ricard.io/pim/production/v2/video/Malibu_Ron_Botella_de_750_ml_es_AR_5_bamPresentationUse.mp4?version=1563534394643",'+
            '                         "bamVideoPreview": "https://assets.pernod-ricard.io/pim/production/v2/video/Malibu_Ron_Botella_de_750_ml_es_AR_5_bamVideoPreview.mp4?version=1563534394658"'+
            '                     }'+
            '                 },'+
            '                 {'+
            '                     "damAssetId": "293649",'+
            '                     "mediaType": "Image",'+
            '                     "channel": "Web",'+
            '                     "mainTag": "Packshot",'+
            '                     "tag": "Malibu Pineapple & Packshot",'+
            '                     "ordering": 7,'+
            '                     "originalInfo": {'+
            '                         "size": "1.92 MB",'+
            '                         "height": 2400,'+
            '                         "width": 2400'+
            '                     },'+
            '                     "urls": {'+
            '                         "original": "https://assets.pernod-ricard.io/pim/production/v2/Malibu_Ron_Botella_de_750_ml_es_AR_7_original.png?version=1563534394711",'+
            '                         "bamArticleFull": "https://assets.pernod-ricard.io/pim/production/v2/Malibu_Ron_Botella_de_750_ml_es_AR_7_bamArticleFull.png?version=1563534394723",'+
            '                         "forsightPreview": "https://assets.pernod-ricard.io/pim/production/v2/Malibu_Ron_Botella_de_750_ml_es_AR_7_forsightPreview.png?version=1563534394734",'+
            '                         "thumbnail": "https://assets.pernod-ricard.io/pim/production/v2/Malibu_Ron_Botella_de_750_ml_es_AR_7_thumbnail.png?version=1563534394745",'+
            '                         "forsightLargePreview": "https://assets.pernod-ricard.io/pim/production/v2/Malibu_Ron_Botella_de_750_ml_es_AR_7_forsightLargePreview.png?version=1563534394757"'+
            '                     }'+
            '                 }'+
            '             ],'+
            '             "packshot": {'+
            '                 "damAssetId": "314856",'+
            '                 "originalInfo": {'+
            '                     "size": "2.22 MB",'+
            '                     "height": 3000,'+
            '                     "width": 3000'+
            '                 },'+
            '                 "urls": {'+
            '                     "original": "https://assets.pernod-ricard.io/pim/production/v2/Malibu_Ron_Botella_de_750_ml_es_AR_1_original.png?version=1563534394483",'+
            '                     "bamArticleFull": "https://assets.pernod-ricard.io/pim/production/v2/Malibu_Ron_Botella_de_750_ml_es_AR_1_bamArticleFull.png?version=1563534394495",'+
            '                     "forsightPreview": "https://assets.pernod-ricard.io/pim/production/v2/Malibu_Ron_Botella_de_750_ml_es_AR_1_forsightPreview.png?version=1563534394506",'+
            '                     "thumbnail": "https://assets.pernod-ricard.io/pim/production/v2/Malibu_Ron_Botella_de_750_ml_es_AR_1_thumbnail.png?version=1563534394517",'+
            '                     "forsightLargePreview": "https://assets.pernod-ricard.io/pim/production/v2/Malibu_Ron_Botella_de_750_ml_es_AR_1_forsightLargePreview.png?version=1563534394530"'+
            '                 }'+
            '             },'+
            '             "vap": null,'+
            '             "associatedProductList": null,'+
            '             "_tags": ['+
            '                 "L",'+
            '                 "NR"'+
            '             ],'+
            '             "objectID": "PRPECOM000801_es_AR"'+
            '         }'+
            '     ],'+
            '     "nbHits": 1,'+
            '     "page": 0,'+
            '     "nbPages": 1,'+
            '     "hitsPerPage": 25'+
            '}';
            return retorno;
        }
}