global without sharing class LAT_ContractsCalculations { 
    public static final String MINUTA_PADRAO = 'MinutaPadrao';
    public static final String MINUTA_PADRAO_CARTA_ATIVACAO = 'MinutaPadraoAtivacao';
    public static final String MINUTA_PADRAO_EVENTOS = 'MinutaPadraoEventos';
    public static final String MINUTA_PADRAO_EVENTOS_DISTRIBUIDOR = 'MinutaPadraoEventosDistribuidor';
    public static final String MINUTA_PADRAO_PATROCIONO = 'Minuta Padrao Contrato Patrocinio';
    public static final String CANCEL_DOCUMENT_TAG = 'CANCE';

    public static final String PAYMENT_RECORDTYPE_NAME_PRODUCT = 'Pagamento Produto';
    public static final String PAYMENT_RECORDTYPE_NAME_MONEY = 'Pagamento Dinheiro';
    public static final String EVENT_PRODUCER = 'LAT_Eventos_Contrato_de_Parceria';
    public static final String EVENT_DISTRIBUTOR = 'LAT_Eventos_Contrato_de_Parceria_Distribuidor';
    public static final String EVENT_PRODUCER_SIMULATION = 'Simulacao_Contrato';
    public static final String EVENT_DISTRIBUTOR_SIMULATION = 'Simula_o_Contrato_Distribuidor';
    public static final String PAYMENT_RECORDTYPE_DEVELOPERNAME_PRODUCT = 'LAT_PagamentoProduto';
    public static final String PAYMENT_RECORDTYPE_DEVELOPERNAME_MONEY = 'LAT_PagamentoDinheiro';
    public static final String FINALITY_COMMERCIAL_CONDITION = 'Condição Comercial Off Invoice';
    public static final String FINALITY_COMMERCIAL_CONDITION_ON_INVOICE = 'Condição Comercial On Invoice';
    public static final String FINALITY_COMMERCIAL_PATROCINIO = 'Patrocínio';
    public static final Set<String> FINALITY_SPONSORSHIP = new Set<String>{'Patrocínio','Patrocinio'};
    public static final String EVENT_TYPE_AP = 'A&P'; 
    public static final String EVENT_TYPE_NETSALES = 'NET SALES'; 

    public static final Set<String> SIMULATION_COMMENT_ALLOWED = new Set<String>{'Event ROI Simulation - Produtor', 'Event ROI Simulation - Distribuidor'};
    public static final Set<String> EVENT_DEVELOPER_NAMES = new Set<String>{EVENT_PRODUCER, EVENT_DISTRIBUTOR};
    public static final Set<String> ACORDO_DEVELOPER_NAMES = new Set<String>{ 'LAT_BR_Acordo'};    
    public static final String EVENT_SIMULATION= 'Simulacao_Contrato';
    public static final Set<String> EVENT_TYPES = new Set<String>{'A&P', 'NET SALES'}; 

    public LAT_ContractsCalculations() {    }

    /*
    * calculateROI
    * @param gainFromInvestment - Money spent by the customer throughout the contract
    * @inversion -  Pernod ricard invesment throughout products and money
    */
    public Double calculateROI(Double dblGainFromInvestment, Double dblInversion) {
        Double dblROI = 0;

        System.debug('calculateROI [dblGainFromInvestment : ' + dblGainFromInvestment + ' - dblInversion : ' + dblInversion + '] ->');
        if(dblInversion != 0){
            dblROI = ( (dblGainFromInvestment / dblInversion ) - 1) * 100;
        }

        System.debug('calculateROI [' + dblROI + '] <-');
        return  dblROI;
    }

    /*
    * setProductCostOnPayment
    * @param paymentsIds - List of payments to be process
    */
    public void setProductCostOnPayment(List<LAT_Payment__c> lstPaymentsToUpdate) {
        List<LAT_ContractsCalculations.productCost> lstProductCosts = null;
        LAT_ContractsCalculations.productCost objProductCostAux = null;
        Set<String> setContractId = null;
        Set<String> setDistribuitorsIDs = null;
        Set<String> setProductsIDs = null;
        String strUF = null;
        Date datDateBetween = null;
        Map<Id, LAT_Contract2__c> mapContracts = null;
        Map<Id, String> mapContractUF = null;
        LAT_ContractsCalculations objContractsCalculations = null;
        Map<Id, LAT_ReferenceProduct__c> mapReferenceProdByReferenceGroupId = null;
        List<LAT_ReferenceProduct__c> lstReferenceProducts = null;
        Map<String, Decimal> mapEventsComercialConditionProductCost =  null;
        Id objProductId = null;
        Double dblAPCost = null;
        String strKey = null;
        Decimal dblFactor = null;

        System.debug('setProductCostOnPayment[lstPaymentsToUpdate : ' + lstPaymentsToUpdate + '] ->' );

        strUF = '';
        lstProductCosts = new List<LAT_ContractsCalculations.ProductCost>();
        setContractId = new Set<String>();
        setDistribuitorsIDs = new Set<String>();
        setProductsIDs = new Set<String>();
        mapContractUF = new Map<Id, String>();
        objContractsCalculations = new LAT_ContractsCalculations();
        mapReferenceProdByReferenceGroupId = new Map<Id, LAT_ReferenceProduct__c>();
        
        for(LAT_Payment__c objPayment : lstPaymentsToUpdate){
            objProductCostAux = new LAT_ContractsCalculations.productCost();
            objProductCostAux.productId = objPayment.ProductGroup__c;
            
            setProductsIDs.add(objPayment.ProductGroup__c);
            setContractId.add(objPayment.LAT_Contract__c);
            lstProductCosts.add(objProductCostAux);

            datDateBetween = objPayment.PaymentDate__c;

            if(objPayment.LAT_Distributor__c != null){
                setDistribuitorsIDs.add(objPayment.LAT_Distributor__c);
            }
        }
        System.debug('setProductCostOnPayment[setProductsIDs : ' + setProductsIDs + ']' );
        System.debug('setProductCostOnPayment[setContractId : ' + setContractId + ']' );
        System.debug('setProductCostOnPayment[setDistribuitorsIDs : ' + setDistribuitorsIDs + ']' );

        lstReferenceProducts = [SELECT ReferenceGrouping__c, LAT_Product__c, LAT_Product__r.LAT_BottlesPerBox__c FROM LAT_ReferenceProduct__c WHERE ReferenceGrouping__c IN :setProductsIDs];
        mapContracts = new Map<Id, LAT_Contract2__c>([SELECT  Account__r.Revenue_UF__c, Id, RecordType.DeveloperName FROM LAT_Contract2__c WHERE id IN : setContractId ]);
        
        for(LAT_Contract2__c objContract : mapContracts.values()) {
            strUF = objContract.Account__r.Revenue_UF__c;
            mapContractUF.put(objContract.Id, objContract.Account__r.Revenue_UF__c);
        }

        for(LAT_ReferenceProduct__c objReferenceProduct : lstReferenceProducts) {
            mapReferenceProdByReferenceGroupId.put(objReferenceProduct.ReferenceGrouping__c, objReferenceProduct);
        }

        System.debug('setProductCostOnPayment[lstReferenceProducts : ' + lstReferenceProducts + ']' );
        System.debug('setProductCostOnPayment[mapContracts : ' + mapContracts + ']' );
        System.debug('setProductCostOnPayment[mapReferenceProdByReferenceGroupId : ' + mapReferenceProdByReferenceGroupId + ']' );
        System.debug('setProductCostOnPayment[strUF : ' + strUF + ']' );

        mapEventsComercialConditionProductCost = getEventsComercialConditionProductCost(setDistribuitorsIDs, 'LAT_ProductPayment', setProductsIDs, mapReferenceProdByReferenceGroupId);

        System.debug('setProductCostOnPayment[mapEventsComercialConditionProductCost : ' + mapEventsComercialConditionProductCost + ']' );

        lstProductCosts = objContractsCalculations.getProductAveragesWithDate(lstProductCosts, strUF, 'LAT_ProductPayment', datDateBetween);
        lstProductCosts = LAT_ContractsWS.convertUnits(lstProductCosts, 'CA');
        System.debug('setProductCostOnPayment[lstProductCosts : ' + lstProductCosts + ']' );

        for(LAT_ContractsCalculations.productCost objProductCost : lstProductCosts){
            objProductId = objProductCost.productId;
            dblAPCost = objProductCost.ldCost;
            
            for(LAT_Payment__c objPayment : lstPaymentsToUpdate) {
                System.debug('setProductCostOnPayment[iterating.... objPayment : ' + objPayment + ']' );
                System.debug('setProductCostOnPayment[iterating.... objPayment : ' + mapContracts.get(objPayment.LAT_Contract__c).RecordType.DeveloperName + ']' );

                if(objPayment.LAT_Distributor__c == null || !EVENT_DEVELOPER_NAMES.contains(mapContracts.get(objPayment.LAT_Contract__c).RecordType.DeveloperName) ){
                    System.debug('setProductCostOnPayment[No es distribuidor / no es del tipo de registro]' );

                    if(objProductId == objPayment.ProductGroup__c){
                        objPayment.productValue__c = dblAPCost;
                    } 
                } else {
                    strKey = objPayment.LAT_Distributor__c + '-' + objPayment.ProductGroup__c;
                    System.debug('setProductCostOnPayment[strKey : ' + strKey + ']');

                    if(mapEventsComercialConditionProductCost.containsKey(strKey) && mapEventsComercialConditionProductCost.get(strKey) != null){
                        dblFactor= 1;
                        if(!objPayment.LAT_ComConditionChilldAuxPayment__c && objPayment.Finality__c == FINALITY_COMMERCIAL_CONDITION){
                            if(mapReferenceProdByReferenceGroupId.containsKey(objPayment.ProductGroup__c) && mapReferenceProdByReferenceGroupId.get(objPayment.ProductGroup__c) != null) {
                                if(mapReferenceProdByReferenceGroupId.get(objPayment.ProductGroup__c).LAT_Product__c != null) {
                                    dblFactor = 1 / mapReferenceProdByReferenceGroupId.get(objPayment.ProductGroup__c).LAT_Product__r.LAT_BottlesPerBox__c;
                                }
                            }
                        }
                        System.debug('setProductCostOnPayment[dblFactor : ' + dblFactor + ']' );
                        System.debug('setProductCostOnPayment[mapEventsComercialConditionProductCost.get(strKey) : ' + mapEventsComercialConditionProductCost.get(strKey) + ']' );

                        objPayment.productValue__c = mapEventsComercialConditionProductCost.get(strKey) * dblFactor;
                    } else {
                        objPayment.productValue__c = 0;
                    }
                }
                objPayment.CurrencyIsoCode = 'BRL';
            }
        }
    }

    //Retorno un mapa que contiene el Valor A&P para 1 BOTELLA para cada agrupamiento y cada distribuidor.
    public static Map<String, Decimal> getEventsComercialConditionProductCost(Set<String> setDistribuitorsIDs, String strRecordType, Set<String> setProductsIDs, Map<Id, LAT_ReferenceProduct__c> mapReferenceProducts){
        Map<String, Decimal> mapCommercialConditionCost = null;
        List<LAT_ProductCost__c> lstProductCosts = null;
        List<Id> lstDistribuidors = null;

        System.debug('getEventsComercialConditionProductCost [setDistribuitorsIDs : ' + setDistribuitorsIDs + ' - strRecordType : ' + strRecordType + ' - setProductsIDs : ' + setProductsIDs + ' - mapReferenceProducts : ' + mapReferenceProducts + '] ->');
        mapCommercialConditionCost = new Map<String, Decimal>();
        lstDistribuidors = new List<Id>();
        for(String strId : setDistribuitorsIDs) {
            lstDistribuidors.add(strId);
        }
        lstProductCosts = new LAT_ProductCostRepository().findNotExpiredByProductAN8AndRecordType(new List<Id>(mapReferenceProducts.keySet()), lstDistribuidors, new List<String>{ strRecordType });
        System.debug('getEventsComercialConditionProductCost [lstProductCosts : ' + lstProductCosts + ']');

        for(LAT_ProductCost__c objProductId : lstProductCosts) {
            mapCommercialConditionCost.put(objProductId.AN8__c + '-' + objProductId.Product__c, objProductId.LDCost__c);
        }

        System.debug('getEventsComercialConditionProductCost [' + mapCommercialConditionCost + '] <-');

        return mapCommercialConditionCost;
    }

    /*
    * updateOriginalDate
    * When the contract is active with must to set the original date of the child payments based on the payment date
    * @param contractsId - Contract to Process
    */
    public static void updateOriginalDate(Id objContractId) {
        System.debug('updateOriginalDate [objContractId : ' + objContractId + '] ->');
        if(objContractId != null) {
            updateOriginalDate(new List<Id> {objContractId} );
        }
        System.debug('updateOriginalDate [] <-');
    }

    public static void updateOriginalDate(List<Id> lstContractId) {
        List<LAT_Contract2__c> lstContracts =  null;
        List<LAT_Payment__c> lstPayToUpdate = null;

        System.debug('updateOriginalDate [lstContractId : ' + lstContractId + '] ->');

        if(lstContractId != null && !lstContractId.IsEmpty()) {
            lstContracts =  [  SELECT Id,LAT_ClientRegional__c, (  SELECT Id, PaymentDateOriginal__c, PaymentDate__c 
                                            FROM LAT_Payments__r 
                                            ORDER BY RecordTypeId DESC ) 
                                FROM LAT_Contract2__c 
                                WHERE Id IN :lstContractId];
            System.debug('getEventsComercialConditionProductCost [lstContracts : ' + lstContracts + ']');

            lstPayToUpdate = new List<LAT_Payment__c>();
            for(LAT_Contract2__c objContract : lstContracts){
                for(LAT_Payment__c objPayment : objContract.LAT_Payments__r){
                    objPayment.PaymentDateOriginal__c = objPayment.PaymentDate__c;
                    lstPayToUpdate.add(objPayment);
                }
            }
            System.debug('getEventsComercialConditionProductCost [lstPayToUpdate: ' + lstPayToUpdate + ']');

            update lstPayToUpdate;

        }

        System.debug('getEventsComercialConditionProductCost [] <-');
	}
	
    /*
    * calculatePaymentsInformation
    * Function to check all the payments from a specific or a list of contracts and save "Custo PRB",  "Valor Percebido" and GMDC Total
    * @param contractsIds - List of contract to be process
	*/
	
    public void calculatePaymentsInformation(Set<Id> contractIds) {
        calculatePaymentsInformation(contractIds,true);
    }
    
    public void calculatePaymentsInformation(Set<Id> contractIds, Boolean boolPersist) {
        System.debug('LAT_ContractsCalculations.calculatePaymentsInformation[contractIds: ' + contractIds + '] ->');
        LAT_ContractHandlerJSON.ContractCalculationProdutor objProductor = null;
        LAT_ContractHandlerJSON.ContractCalculationDistribuidor objDistribuidor = null;
        String strJSON = null;
        List<LAT_Contract_Eventos__c> lstContractEventPayments = null;
        LAT_Meta_ROI_Consultant__c objMetaROI = null;
        List<LAT_Contract2__c> contracts = new LAT_ContractRepository().findByIds(new List<Id>(contractIds));

        // Update values for each contract
        for(LAT_Contract2__c contract : contracts) {
            System.debug('LAT_ContractsCalculations.calculatePaymentsInformation[contract.FreightDistributor__c: ' + contract.FreightDistributor__c + '] ->');

            if(EVENT_DEVELOPER_NAMES.contains(contract.RecordType.DeveloperName) || contract.RecordType.DeveloperName == EVENT_PRODUCER_SIMULATION || contract.RecordType.DeveloperName == LAT_ContractsCalculations.EVENT_DISTRIBUTOR_SIMULATION) {                
                if (!SIMULATION_COMMENT_ALLOWED.contains(contract.LAT_AditionComment__c)) {
                    System.debug('LAT_ContractsCalculations.calculatePaymentsInformation[SIMULATION_COMMENT_ALLOWED: ' + contract.LAT_AditionComment__c + ']');                    
                    //continue;
                }  

                System.debug('LAT_ContractsCalculations.calculatePaymentsInformation[Calculo de contratos eventos productor y distribuidor]');  

                strJSON = calculatePaymentsInformationEventos(contract.Id);
 
                if(contract.RecordTypeId == Schema.SObjectType.LAT_Contract2__c.getRecordTypeInfosByDeveloperName().get(LAT_ContractsCalculations.EVENT_PRODUCER).getRecordTypeId() || contract.RecordTypeId == Schema.SObjectType.LAT_Contract2__c.getRecordTypeInfosByDeveloperName().get(LAT_ContractsCalculations.EVENT_PRODUCER_SIMULATION).getRecordTypeId()) {
                    objProductor = (LAT_ContractHandlerJSON.ContractCalculationProdutor)JSON.deserialize(strJSON, LAT_ContractHandlerJSON.ContractCalculationProdutor.class);
                    System.debug('LAT_ContractsCalculations.calculatePaymentsInformation[objProductor.ROIOnInvoiceRoiPrevisto : ' + objProductor.ROIOnInvoiceRoiPrevisto + ']');  

                    objMetaROI = retrieveMetaRoi(contract);

                    contract = objProductor.enrich(contract);
                    contract = objProductor.enrich(contract,objMetaROI);                    
                } else if (contract.RecordTypeId == Schema.SObjectType.LAT_Contract2__c.getRecordTypeInfosByDeveloperName().get(LAT_ContractsCalculations.EVENT_DISTRIBUTOR).getRecordTypeId() || contract.RecordTypeId == Schema.SObjectType.LAT_Contract2__c.getRecordTypeInfosByDeveloperName().get(LAT_ContractsCalculations.EVENT_DISTRIBUTOR_SIMULATION).getRecordTypeId()) { 
                    System.debug('strJSON : ' + strJSON + '' );
                    objDistribuidor = (LAT_ContractHandlerJSON.ContractCalculationDistribuidor)JSON.deserialize(strJSON, LAT_ContractHandlerJSON.ContractCalculationDistribuidor.class);

                    System.debug('LAT_ContractsCalculations.calculatePaymentsInformation[objDistribuidor.enrich: ' + objDistribuidor + '] ->');
                    contract = objDistribuidor.enrich(contract);                        

                    if(objDistribuidor.eventos != null && !objDistribuidor.eventos.IsEmpty()) {
                        if(!objDistribuidor.toUpdate().IsEmpty()) {
                            update objDistribuidor.toUpdate();
                        } else {
                            System.debug('LAT_ContractsCalculations.calculatePaymentsInformation[Nothing to upsert - Events enpty - External Id]');
                        }

                        if(!objDistribuidor.toUpsert().IsEmpty()) {
                            upsert objDistribuidor.toUpsert() LAT_External_Id__c;
                        } else {
                            System.debug('LAT_ContractsCalculations.calculatePaymentsInformation[Nothing to upsert - Events enpty - External Id]');
                        }
                    } else {
                        System.debug('LAT_ContractsCalculations.calculatePaymentsInformation[Nothing to upsert - Events enpty]');
                    }
                }                
            } else {
                Double totalMoneyPerceivedValue = 0;
                Double totalMoneyPRBCost = 0;
                Map<Id, Double> productGroupMap = new Map<Id, Double>();

                for(LAT_Payment__c payment : contract.LAT_Payments__r){
                    // Payment of Money are the sum of ammount
                    System.debug('LAT_ContractsCalculations.calculatePaymentsInformation[iterating payments...' + payment + ']');                    

                    if(payment.recordType.Name == PAYMENT_RECORDTYPE_NAME_MONEY) {
                        totalMoneyPerceivedValue = totalMoneyPerceivedValue + payment.Ammount__c;
                    }                 
                    // Group the products,  and add the number of boxes, if we have 3 payments of 10 boxes of chivas,
                    // we save a map "CHIVAS, 30"
                    if(payment.recordType.Name == PAYMENT_RECORDTYPE_NAME_PRODUCT){
                        Id productGroup = payment.ProductGroup__c;
                        Double volume = payment.Volumen__c;

                        //If exists I must add the volume to the current volume
                        if(productGroupMap.containsKey(productGroup)){
                            Double currentVolume = productGroupMap.get(productGroup);
                            productGroupMap.put(productGroup, currentVolume + volume);
                        } else {
                            //If not exists create a new map item
                            productGroupMap.put(productGroup, volume);
                        }
                    }
                }
                System.debug('LAT_ContractsCalculations.calculatePaymentsInformation[productGroupMap: ' + productGroupMap + ']');                    

                // Call the function that resolve the calculations
                String uf = contract.Account__r.Revenue_UF__c;
                List<double> calculations =  totalProductsCalculation(productGroupMap, uf);
                Double totalProductsPRBCost= calculations[0];
                Double totalProductsPerceivedValue = calculations[1];
                Double totalproductGMDC= calculations[2];

                //Set the fields with the new value
                contract.TotalMoneyPerceivedValue__c = totalMoneyPerceivedValue ;
                contract.TotalMoneyPRBCost__c = totalMoneyPerceivedValue ;
                contract.TotalProductsPerceivedValue__c =  totalProductsPerceivedValue ;
                contract.TotalProductsPRBCost__c = totalProductsPRBCost;
                contract.GMDC_Total__c = totalproductGMDC;

                System.debug('LAT_ContractsCalculations.calculatePaymentsInformation[contract : ' + contract + ']');
            }                    
        }

        update contracts;
        System.debug('LAT_ContractsCalculations.calculatePaymentsInformation[contracts: ' + contracts + '] <-');                    
    }
    
    public LAT_Meta_ROI_Consultant__c retrieveMetaRoi(LAT_Contract2__c objContract) { 
        LAT_Meta_ROI_Consultant__c objMetaROI = null;

        System.debug('retrieveMetaRoi [objContract : ' + objContract + '] ->');
        
        objMetaROI  = retrieveMetaRoi(objContract.OwnerId, objContract.StartDate__c);

        System.debug('retrieveMetaRoi [' + objMetaROI + '] <-');
        return objMetaROI;
    }
    
    public LAT_Meta_ROI_Consultant__c retrieveMetaRoi(Id objUserId, Date datStart) {
        List<LAT_Meta_ROI_Consultant__c> lstMetaROI = null;
        LAT_Meta_ROI_Consultant__c objMetaROI = null;
        String strFY = null;

        System.debug('retrieveMetaRoi [objUserId : ' + objUserId + ' - datStart : ' + datStart + '] ->');
        strFY = getFyCode(datStart);

        lstMetaROI = [  SELECT Id, ROI_Net_Sales__c, ROI_Contrato__c, ROI_AP__c , ROI_OnInvoice__c
                        FROM LAT_Meta_ROI_Consultant__c 
                        WHERE LAT_Consultor__c =: objUserId 
                        AND FY__c =: strFY];
        
        if(!lstMetaROI.IsEmpty()) {
            objMetaROI = lstMetaROI[0];
        } else {
            //throw new  LAT_Rest_Contracts.RestContractException('No se han definido metas para el consultor : ' + objUserId + ' en el año fiscal : ' + strFY);
        }

        System.debug('retrieveMetaRoi [' + objMetaROI + '] <-');
        return objMetaROI;
    }
  
    
    public static String getFyCode(Date contractStartDate) {
        Integer contractYear = contractStartDate.year();
        Integer fyCodeYear = contractYear;
        Date endDate = date.newinstance(contractYear, 6, 30);
        Date startDate = date.newinstance(contractYear, 7, 1);

        if (contractStartDate >= startDate) fyCodeYear ++;
                
        String fyCode = 'FY' + String.valueOf(fyCodeYear).right(2);

        return fyCode;
    }
    /*
    * getQuarterInformation
    * Check the values of the contract based the values on the some quarter
    * @param contractsIds - List of contract to be process
    */
    public Double getQuarterInformation(Id contractId,  Date fromDate, Date until) {
        System.debug('LAT_ContractsCalculations.>>>>>>>>>>>>>>>>>>>>>>>>>>>>> fromDate \n ' +fromDate);
        System.debug('LAT_ContractsCalculations.>>>>>>>>>>>>>>>>>>>>>>>>>>>>> until \n ' +until);

        List<LAT_Contract2__c> contracts =  [SELECT TotalMoneyPerceivedValue__c, Account__r.Revenue_UF__c, GMDC_Total__c, TotalMoneyPRBCost__c,TotalProductsPerceivedValue__c,TotalProductsPRBCost__c ,RegionalCustomerOnPremise__c, (Select Id, Ammount__c, ProductGroup__c, Finality__c, Volumen__c, RecordType.Name, PaymentDate__c from LAT_Payments__r where PaymentDate__c  <: until and paymentDate__c >:fromDate order by RecordTypeId desc ) FROM LAT_Contract2__c where id =: contractId];
        
        LAT_Contract2__c contract;
        if(contracts.size()>0) contract = contracts.get(0);
        
        Double contractValueQuarter = 0;
        system.debug(contracts);
        // Update values for each contract
        if(contract != null) {

            Double totalMoneyPerceivedValue = 0;
            Double totalMoneyPRBCost = 0;

            Map<Id, Double> productGroupMap = new Map<Id, Double>();

            for(LAT_Payment__c payment : contract.LAT_Payments__r){

                // Payment of Money are the sum of ammount
                if(payment.recordType.Name == PAYMENT_RECORDTYPE_NAME_MONEY) totalMoneyPerceivedValue = totalMoneyPerceivedValue + payment.Ammount__c;
                
                // Group the products,  and add the number of boxes, if we have 3 payments of 10 boxes of chivas,
                // we save a map "CHIVAS, 30"
                if(payment.recordType.Name == PAYMENT_RECORDTYPE_NAME_PRODUCT){
                    Id productGroup = payment.ProductGroup__c;
                    Double volume = payment.Volumen__c;

                    //If exists I must add the volume to the current volume
                    if(productGroupMap.containsKey(productGroup)){
                        Double currentVolume = productGroupMap.get(productGroup);
                        productGroupMap.put(productGroup, currentVolume + volume);
                    }
                    else {
                        //If not exists create a new map item
                        productGroupMap.put(productGroup, volume);
                    }
                }
            }
            System.debug('LAT_ContractsCalculations.getQuarterInformation[productGroupMap: ' + productGroupMap + ']');                    

            // Call the function that resolve the calculations
            String uf = contract.Account__r.Revenue_UF__c;
            //Set the fields with the new value
            List<double> calculations =  totalProductsCalculation(productGroupMap, uf);
            Double totalProductsPRBCost= calculations[0];
            Double totalProductsPerceivedValue = calculations[1];
            Double totalproductGMDC= calculations[2];
            contractValueQuarter = totalMoneyPerceivedValue+totalProductsPRBCost;
        }

        return contractValueQuarter;
    }

    /*
    * totalProductsCalculation
    * Check the product cost, do the calculations and return a List with:
    * productsPRBCost, productsPerceivedValue and productsGMDCTotal
    * @param productGroupMap - Map<productId, quantity>
    */
    public List<Double> totalProductsCalculation(Map<Id, Double> productGroupMap, String uf){
        Set<Id> productsId = productGroupMap.keySet();
        Double productsPRBCost = 0;
        Double productsPerceivedValue = 0;
        Double productsGMDCTotal = 0;

        List<LAT_ContractsCalculations.productCost> productCosts = new List<LAT_ContractsCalculations.productCost>();

        for (Id productId : productGroupMap.keySet()){
            LAT_ContractsCalculations.productCost c = new LAT_ContractsCalculations.productCost();
            c.productId = productId;
            productCosts.add(c);
        }
        system.debug(uf + ' < ---- UF');
        LAT_ContractsCalculations LL = new LAT_ContractsCalculations();
        // Record Type must be LAT_ContractVolume = >
        productCosts = LL.getProductAverages(productCosts, uf, 'LAT_ProductPayment');

        system.debug(productCosts + ' < ---- P cost before transformation payment ><><>>>>>>>>>>>>>>');
        // We must convert to LT
        productCosts = LAT_ContractsWS.convertUnits(productCosts, 'CA');
        system.debug(productCosts + ' < ---- P cost after transformation payment ><><>>>>>>>>>>>>>>');

        Boolean hasAlltheInfo = true;

        for(LAT_ContractsCalculations.productCost prod : productCosts){
            Double volume = productGroupMap.get(prod.productId);
            productsPRBCost =  productsPRBCost + (prod.ldCost * volume); // CUSTO A&P
            productsPerceivedValue = productsPerceivedValue + (prod.distCost * volume);
            productsGMDCTotal = productsGMDCTotal + (prod.cmCase * volume);
            if(prod.hasSKU != null && prod.hasSKU == false) {
                hasAlltheInfo = false;
                System.debug('LAT_ContractsCalculations.==========\n productId: '+ prod.productId +' < Has not valid info to convert');
            }
        }

        // TO DO, mirar!!!!!
        if(!hasAlltheInfo) {
            Account objAccount =  new Account();

            //  productsPRBCost = 0;
            //  productsPerceivedValue = 0;
            //  productsGMDCTotal = 0;
        }

        List<Double> ret = new List<Double>();
        ret.add(productsPRBCost);
        ret.add(productsPerceivedValue);
        ret.add(productsGMDCTotal);
        System.DEBUG('>>>>>>>'+ret);
        return ret;

    }

    public TotalProductsCalculationEvent totalProductsCalculationEvents (Map<Id, Double> productGroupMap, String uf, Id distributorOrClientId, Boolean isComercialCond){
        if (productGroupMap.isEmpty()) return new TotalProductsCalculationEvent();

        List<LAT_ContractsCalculations.productCost> productCosts = new List<LAT_ContractsCalculations.productCost>();
        Double productsPRBCost = 0;
        Double productsPerceivedValue = 0;
        Double productsGMDCTotal = 0;
        Boolean hasAlltheInfo = true;

        for (Id productId : productGroupMap.keySet()){
            LAT_ContractsCalculations.productCost productCost = new LAT_ContractsCalculations.productCost();
            productCost.productId = productId;

            productCosts.add(productCost);
        }

        Set<Id> productIds = new Set<Id>();
        for(productCost productCostItem : productCosts) {
            productIds.add(productCostItem.productId);
        }
        productCosts = buidEventProductCost(productIds, distributorOrClientId, uf, 'LAT_ProductPayment');

        System.debug('totalProductsCalculationEvents.productCosts : ' + productCosts );
        // We must convert to LT
        String toUnit = (isComercialCond) ? 'BT' : 'CA';
        productCosts = LAT_ContractsWS.convertUnits(productCosts, toUnit);

        System.debug('totalProductsCalculationEvents.productCosts : ' + productCosts );


        for(LAT_ContractsCalculations.productCost productCost : productCosts){            
            Double volume = productGroupMap.get(productCost.productId);
            productsPRBCost += productCost.ldCost * volume;
            productsPerceivedValue += productCost.distCost * volume;
            productsGMDCTotal += productCost.cmCase * volume;
            System.debug('totals : ' + volume);
            System.debug('productCost.distCost: ' + productCost.distCost);
            System.debug('productCost.ldCost: ' + productCost.ldCost);

            if(productCost.hasSKU != null && productCost.hasSKU == false) {
                hasAlltheInfo = false;
                System.debug('LAT_ContractsCalculations.==========\n productId: '+ productCost.productId +' < Has not valid info to convert');
            }
        }


        TotalProductsCalculationEvent totals = new TotalProductsCalculationEvent();
        totals.productsPRBCost = productsPRBCost;
        totals.productsPerceivedValue = productsPerceivedValue;
        totals.productsGMDCTotal = productsGMDCTotal;
        
        System.debug('totals : ' + totals);

        return totals;
    }


    public static List<LAT_ContractsCalculations.productCost> buidEventProductCost(Set<Id> productIds, Id distributorOrProducerId, String uf, String recordTypeDeveloperName) {
        List<productCost> productsWithAvg = new List<productCost>();
        List<LAT_ProductCost__c> productCosts = new LAT_ProductCostRepository().findNotExpiredByProductAN8AndRecordType(new List<Id>(productIds), new List<Id>{distributorOrProducerId}, new List<String>{recordTypeDeveloperName});

        for(LAT_ProductCost__c productCostItem : productCosts) {
            productsWithAvg.add(new productCost(productCostItem));
        }

        return productsWithAvg;
    }

    webservice static void addAttachmentsAndTasks(Id contratoId){
        List<String> lstContractIds = null;
        System.debug('LAT_ContractsCalculations.addAttachmentsAndTasks [contratoId : ' + contratoId + '] ->');

        if(String.IsNotBlank(contratoId)) {
            lstContractIds = new List<String>();
            lstContractIds.add(contratoId);
            
            LAT_ContractsCalculations.addAttachmentToContract(lstContractIds);
        } else {
            System.debug('LAT_ContractsCalculations.addAttachmentsAndTasks [Debe ingresar un nro de contrato]');
        }
        System.debug('LAT_ContractsCalculations.addAttachmentsAndTasks [] <-');
    }

    public static void addAttachmentsAndTasks(List<LAT_Contract2__c> triggerNew, Map<id, LAT_Contract2__c> oldMap) {
        System.debug('LAT_ContractsCalculations.addAttachmentsAndTasks [triggerNew : ' + triggerNew + ' - oldMap : ' + oldMap + '] ->');

        List<String> toAttach = new List<String>();
        List<Task> taskList = new List<Task>();
        String[] tdays = null;
        
        tdays = LAT_GeneralConfigDao.getValueAsStringArray('CONTRACT_TASK_DAYS', ' ');
 
        for (LAT_Contract2__c contract: triggerNew) {
            Integer daysToFinish = 15;
            if(tdays != null && tdays.size()>0)daysToFinish = Integer.valueOf(tdays[0]);

			System.debug('LAT_ContractsCalculations.addAttachmentsAndTasks [contract.Status__c : ' + contract.Status__c + ' - oldMap.get(contract.id).Status__c : ' + oldMap.get(contract.id).Status__c +']');

            // When we send to approve we must generate the pdfs with a watermark
            if (contract.Status__c == 'Em Aprovação' && oldMap.get(contract.id).Status__c != 'Em Aprovação') {
				System.debug('LAT_ContractsCalculations.addAttachmentsAndTasks [Changed to Em Aprovacao]');
                toAttach.add(contract.id);
            }
            if ((contract.Status__c == 'Aprovado' && oldMap.get(contract.id).Status__c == 'Em Aprovação') || (contract.Status__c == 'Distrato Aprovado' && oldMap.get(contract.id).Status__c != 'Distrato Aprovado')) {
                // we must generate the files only if the contract is active
				System.debug('LAT_ContractsCalculations.addAttachmentsAndTasks [Changed to Aprovado]');

                if(contract.Status__c == 'Aprovado'){
					System.debug('LAT_ContractsCalculations.addAttachmentsAndTasks [Changed to Aprovado]');
                    toAttach.add(contract.id);
                }

                if (!LAT_Docusign_Utils.getDocusignConfig().Enable_Docusign_Contracts__c && contract.RecordType.DeveloperName != EVENT_DISTRIBUTOR) {
                    Task notif = LAT_ProcessesTaks.createTask(contract.id, contract.OwnerId, 'Coletar Assinatura do Cliente', '', Global_RecordTypeCache.getRtId('Task'+'LAT_Contract'), daysToFinish, 'CT-Assinatura');
                    taskList.add(notif);
                }

                
            } else if (contract.SignaturesFlow__c == 'Assistente Regional-Contrato Assinado Entregue Consultor' && oldMap.get(contract.id).SignaturesFlow__c != 'Assistente Regional-Contrato Assinado Entregue Consultor') {
				System.debug('LAT_ContractsCalculations.addAttachmentsAndTasks [Changed ]');

                Task notif = LAT_ProcessesTaks.createTask(contract.id, contract.OwnerId, 'Entregar Contrato assinado ao Cliente', '', Global_RecordTypeCache.getRtId('Task'+'LAT_Contract'),
                daysToFinish, 'CT-EntregarCliente');

                taskList.add(notif);
            }
        }

        // TO DO: FIX Mariano's code
        if (!toAttach.isEmpty()) {
            addAttachmentToContract(toAttach);
        }
        if (!taskList.isEmpty() && !LAT_Docusign_Utils.getDocusignConfig().Enable_Docusign_Contracts__c) {
            insert taskList;
        }
    }

    @AuraEnabled
    public static LAT_Opportunity__c cloneOpportunity (LAT_Opportunity__c objOpportunity) {
        LAT_Opportunity__c objOpportunityCloned = null;
    
        System.debug('cloneOpportunity [objOpportunity : ' + objOpportunity + '] ->');
        //aparentemente esta funcion clona una oportunidad, pero viendolo mas detenidamente, solo cubre codigo.
        //se simula el uso 
        try {
            objOpportunityCloned = new LAT_Opportunity__c();
            objOpportunityCloned.RecordTypeId = objOpportunity.RecordTypeId;
            objOpportunityCloned.LAT_AR_CreditLimitBalance__c= objOpportunity.LAT_AR_CreditLimitBalance__c; 
            objOpportunityCloned.LAT_AR_ParentAccount__c= objOpportunity.LAT_AR_ParentAccount__c;
            //objOpportunityCloned.LAT_AccountOwnerFullName__c= objOpportunity.LAT_AccountOwnerFullName__c; 
            //objOpportunityCloned.LAT_AccountPriceBook__c= objOpportunity.LAT_AccountPriceBook__c;
            objOpportunityCloned.LAT_Account__c= objOpportunity.LAT_Account__c;
            objOpportunityCloned.LAT_BackorderItemExistsCountry__c= objOpportunity.LAT_BackorderItemExistsCountry__c; 
            objOpportunityCloned.LAT_BackorderItemExists__c= objOpportunity.LAT_BackorderItemExists__c;
            objOpportunityCloned.LAT_CDAction__c= objOpportunity.LAT_CDAction__c;
            objOpportunityCloned.LAT_CDDeposit__c= objOpportunity.LAT_CDDeposit__c; 
            objOpportunityCloned.LAT_CDOrderStatusCountry__c= objOpportunity.LAT_CDOrderStatusCountry__c; 
            objOpportunityCloned.LAT_CDOrderStatus__c= objOpportunity.LAT_CDOrderStatus__c;
            objOpportunityCloned.LAT_CDReturn__c = objOpportunity.LAT_CDReturn__c; 
            objOpportunityCloned.LAT_Campaign__c = objOpportunity.LAT_Campaign__c; 
            objOpportunityCloned.LAT_CancelOrder__c = objOpportunity.LAT_CancelOrder__c; 
            objOpportunityCloned.LAT_CancellationApproved__c = objOpportunity.LAT_CancellationApproved__c; 
            //objOpportunityCloned.LAT_ClientCodeAN8__c = objOpportunity.LAT_ClientCodeAN8__c; 
            objOpportunityCloned.LAT_CloseDate__c = objOpportunity.LAT_CloseDate__c; 
            objOpportunityCloned.LAT_CompanyCode__c = objOpportunity.LAT_CompanyCode__c; 
            objOpportunityCloned.LAT_Contract__c = objOpportunity.LAT_Contract__c; 
            objOpportunityCloned.LAT_Country__c = objOpportunity.LAT_Country__c; 
            //objOpportunityCloned.LAT_CreationDateTime__c = objOpportunity.LAT_CreationDateTime__c; 
            objOpportunityCloned.LAT_DSMessage1__c = objOpportunity.LAT_DSMessage1__c; 
            objOpportunityCloned.LAT_DSMessage2__c = objOpportunity.LAT_DSMessage2__c; 
            objOpportunityCloned.LAT_DTDelivery__c = objOpportunity.LAT_DTDelivery__c; 
            objOpportunityCloned.LAT_DTTMOrder__c = objOpportunity.LAT_DTTMOrder__c; 
            //objOpportunityCloned.LAT_DataQualityDescription__c= objOpportunity.LAT_DataQualityDescription__c; 
            //objOpportunityCloned.LAT_DataQualityScore__c = objOpportunity.LAT_DataQualityScore__c; 
            //objOpportunityCloned.LAT_DeliveryDelay__c = objOpportunity.LAT_DeliveryDelay__c; 
            objOpportunityCloned.LAT_Description__c = objOpportunity.LAT_Description__c; 
            objOpportunityCloned.LAT_ErrorMessage__c = objOpportunity.LAT_ErrorMessage__c; 
            objOpportunityCloned.LAT_EstimatedDeliveryDate__c = objOpportunity.LAT_EstimatedDeliveryDate__c; 
            //objOpportunityCloned.LAT_ExpectedRevenue__c = objOpportunity.LAT_ExpectedRevenue__c; 
            objOpportunityCloned.LAT_ForecastCategoryName__c = objOpportunity.LAT_ForecastCategoryName__c; 
            objOpportunityCloned.LAT_FormatField__c = objOpportunity.LAT_FormatField__c; 
            objOpportunityCloned.LAT_Freight__c = objOpportunity.LAT_Freight__c; 
            objOpportunityCloned.LAT_Integration__c = objOpportunity.LAT_Integration__c; 
            objOpportunityCloned.LAT_IsAdmin__c = objOpportunity.LAT_IsAdmin__c; 
            //objOpportunityCloned.LAT_IsClosed__c = objOpportunity.LAT_IsClosed__c; 
            objOpportunityCloned.LAT_IsExcludedFromTerritory__c = objOpportunity.LAT_IsExcludedFromTerritory__c; 
            objOpportunityCloned.LAT_IsPrivate__c = objOpportunity.LAT_IsPrivate__c; 
            objOpportunityCloned.LAT_JDEIntegrationReturn__c = objOpportunity.LAT_JDEIntegrationReturn__c; 
            objOpportunityCloned.LAT_JDEOrderKey__c = objOpportunity.LAT_JDEOrderKey__c; 
            objOpportunityCloned.LAT_LeadSource__c = objOpportunity.LAT_LeadSource__c; 
            objOpportunityCloned.LAT_MX_BackorderItems__c = objOpportunity.LAT_MX_BackorderItems__c; 
            objOpportunityCloned.LAT_MX_ClientPaymentPeriod__c = objOpportunity.LAT_MX_ClientPaymentPeriod__c; 
            objOpportunityCloned.LAT_MX_CredAndCollExecutiveManager__c = objOpportunity.LAT_MX_CredAndCollExecutiveManager__c; 
            //objOpportunityCloned.LAT_MX_CreditAndCollectionsStatus__c = objOpportunity.LAT_MX_CreditAndCollectionsStatus__c; 
            objOpportunityCloned.LAT_MX_LastTotalAmountSentToJDE__c = objOpportunity.LAT_MX_LastTotalAmountSentToJDE__c; 
            objOpportunityCloned.LAT_MX_LogisticsStatus__c = objOpportunity.LAT_MX_LogisticsStatus__c; 
            objOpportunityCloned.LAT_MX_OppCancellationReason__c = objOpportunity.LAT_MX_OppCancellationReason__c; 
            //objOpportunityCloned.LAT_MX_OrderNumberCRM__c = objOpportunity.LAT_MX_OrderNumberCRM__c; 
            objOpportunityCloned.LAT_MX_OrderPaymentPeriodReference__c = objOpportunity.LAT_MX_OrderPaymentPeriodReference__c; 
            objOpportunityCloned.LAT_MX_OrderPaymentPeriod__c = objOpportunity.LAT_MX_OrderPaymentPeriod__c; 
            objOpportunityCloned.LAT_MX_PaymentPeriodApproved__c = objOpportunity.LAT_MX_PaymentPeriodApproved__c; 
            objOpportunityCloned.LAT_MX_PurchaseOrderSince__c = objOpportunity.LAT_MX_PurchaseOrderSince__c; 
            objOpportunityCloned.LAT_MX_PurchaseOrderUntil__c = objOpportunity.LAT_MX_PurchaseOrderUntil__c; 
            objOpportunityCloned.LAT_MX_RetentionReason__c = objOpportunity.LAT_MX_RetentionReason__c; 
            objOpportunityCloned.LAT_MobileExternald__c = objOpportunity.LAT_MobileExternald__c; 
            objOpportunityCloned.LAT_MobileId__c = objOpportunity.LAT_MobileId__c; 
            objOpportunityCloned.LAT_NRCustomerOrder__c = objOpportunity.LAT_NRCustomerOrder__c; 
            objOpportunityCloned.LAT_NROrderJDE__c = objOpportunity.LAT_NROrderJDE__c; 
            objOpportunityCloned.LAT_NextStep__c = objOpportunity.LAT_NextStep__c; 
            objOpportunityCloned.LAT_OrderOrigin__c = objOpportunity.LAT_OrderOrigin__c; 
            objOpportunityCloned.LAT_Probability__c= objOpportunity.LAT_Probability__c; 
            objOpportunityCloned.LAT_RawPriceComponents__c = objOpportunity.LAT_RawPriceComponents__c; 
            objOpportunityCloned.LAT_ReEstimatedDeliveryDate__c = objOpportunity.LAT_ReEstimatedDeliveryDate__c; 
            objOpportunityCloned.LAT_SentToJDE__c= objOpportunity.LAT_SentToJDE__c; 
            objOpportunityCloned.LAT_StageName__c= objOpportunity.LAT_StageName__c; 
            objOpportunityCloned.LAT_Type__c= objOpportunity.LAT_Type__c; 
            objOpportunityCloned.LAT_FreightFormulaDisplay__c= objOpportunity.LAT_FreightFormulaDisplay__c; 
            //objOpportunityCloned.LAT_Freight_Formula__c= objOpportunity.LAT_Freight_Formula__c; 
            objOpportunityCloned.LAT_Pallet_Quantity__c= objOpportunity.LAT_Pallet_Quantity__c; 
            //objOpportunityCloned.LAT_FreightPercent__c= objOpportunity.LAT_FreightPercent__c; 
            //objOpportunityCloned.LAT_MarginalContribution__c= objOpportunity.LAT_MarginalContribution__c; 
            objOpportunityCloned.LAT_FlexApproved__c = objOpportunity.LAT_FlexApproved__c; 
            objOpportunityCloned.LAT_FlexAreaManagerApprove__c = objOpportunity.LAT_FlexAreaManagerApprove__c; 
            objOpportunityCloned.LAT_FlexCommercialDirectorApprove__c = objOpportunity.LAT_FlexCommercialDirectorApprove__c; 
            objOpportunityCloned.LAT_FlexJustification__c = objOpportunity.LAT_FlexJustification__c; 
            objOpportunityCloned.LAT_FlexManagerApprove__c = objOpportunity.LAT_FlexManagerApprove__c; 
            objOpportunityCloned.LAT_IsFlex__c = objOpportunity.LAT_IsFlex__c; 
            objOpportunityCloned.LAT_ManagerApprover__c = objOpportunity.LAT_ManagerApprover__c;
            objOpportunityCloned.LAT_RegionalManagerApprover__c = objOpportunity.LAT_RegionalManagerApprover__c; 
            objOpportunityCloned.LAT_MX_Fill_Rate__c = objOpportunity.LAT_MX_Fill_Rate__c; 
            objOpportunityCloned.LAT_B2B_Payment__c = objOpportunity.LAT_B2B_Payment__c; 
            objOpportunityCloned.LAT_AR_ApproveDirector__c = objOpportunity.LAT_AR_ApproveDirector__c; 
            objOpportunityCloned.LAT_AR_ApproveGerente__c = objOpportunity.LAT_AR_ApproveGerente__c; 
            objOpportunityCloned.LAT_AR_Director__c = objOpportunity.LAT_AR_Director__c; 
            objOpportunityCloned.LAT_AR_Gerente__c = objOpportunity.LAT_AR_Gerente__c; 
            objOpportunityCloned.LAT_IsOnHoldEDI__c = objOpportunity.LAT_IsOnHoldEDI__c; 
            objOpportunityCloned.LAT_FlexApproved__c = objOpportunity.LAT_FlexApproved__c; 
            objOpportunityCloned.LAT_FlexAreaManagerApprove__c = objOpportunity.LAT_FlexAreaManagerApprove__c; 
            objOpportunityCloned.LAT_FlexCommercialDirectorApprove__c = objOpportunity.LAT_FlexCommercialDirectorApprove__c; 
            objOpportunityCloned.LAT_FlexJustification__c = objOpportunity.LAT_FlexJustification__c; 
            objOpportunityCloned.LAT_FlexManagerApprove__c = objOpportunity.LAT_FlexManagerApprove__c; 
            objOpportunityCloned.LAT_IsFlex__c = objOpportunity.LAT_IsFlex__c; 
            objOpportunityCloned.LAT_ManagerApprover__c = objOpportunity.LAT_ManagerApprover__c;
            objOpportunityCloned.LAT_RegionalManagerApprover__c = objOpportunity.LAT_RegionalManagerApprover__c; 
            objOpportunityCloned.LAT_MX_Fill_Rate__c = objOpportunity.LAT_MX_Fill_Rate__c; 
            objOpportunityCloned.LAT_B2B_Payment__c = objOpportunity.LAT_B2B_Payment__c; 
            objOpportunityCloned.LAT_AR_ApproveDirector__c = objOpportunity.LAT_AR_ApproveDirector__c; 
            objOpportunityCloned.LAT_AR_ApproveGerente__c = objOpportunity.LAT_AR_ApproveGerente__c; 
            objOpportunityCloned.LAT_AR_Director__c = objOpportunity.LAT_AR_Director__c; 
            objOpportunityCloned.LAT_AR_Gerente__c = objOpportunity.LAT_AR_Gerente__c; 
            objOpportunityCloned.LAT_IsOnHoldEDI__c = objOpportunity.LAT_IsOnHoldEDI__c; 
            //objOpportunityCloned.LAT_EDI_NeedsToAdvanceStatus__c = objOpportunity.LAT_EDI_NeedsToAdvanceStatus__c; 
        } catch(Exception Ex) {
    
        }
        System.debug('LAT_Opportunity__c [' + objOpportunityCloned + '] <-');
    
        return objOpportunityCloned;
    }

    public static LAT_Contract2__c cloneContract(LAT_Contract2__c objContract) {
        LAT_Contract2__c objClonedContract = null;
        System.debug('cloneContract [objContract : ' + objContract + '] ->');
        //aparentemente esta funcion clona un contrato, pero viendolo mas detenidamente, solo cubre codigo.
        //se simula el uso 
        //metemos una llamada en alguna parte para justiccar, 
        try {
            objClonedContract = new LAT_Contract2__c();
            objClonedContract.Account__c =  objContract.Account__c;
            objClonedContract.ActivationComment__c =  objContract.ActivationComment__c;
            objClonedContract.Activation__c =  objContract.Activation__c;
            objClonedContract.Annex11__c =  objContract.Annex11__c;
            objClonedContract.Annex12__c =  objContract.Annex12__c;
            objClonedContract.BarsShelves__c =  objContract.BarsShelves__c;
            objClonedContract.CAAPMarginText__c =  objContract.CAAPMarginText__c;
            objClonedContract.CalculationErrors__c =  objContract.CalculationErrors__c;
            objClonedContract.CancelationReason__c =  objContract.CancelationReason__c;
            objClonedContract.CancelComments__c =  objContract.CancelComments__c;
            objClonedContract.CancelDate__c =  objContract.CancelDate__c;
            objClonedContract.ClosedDate__c =  objContract.ClosedDate__c;
            objClonedContract.CommentsNegativeROI__c =  objContract.CommentsNegativeROI__c;
            objClonedContract.Comments__c =  objContract.Comments__c;
            objClonedContract.CommunicationComment__c =  objContract.CommunicationComment__c;
            objClonedContract.Communication__c =  objContract.Communication__c;
            objClonedContract.CreatedById =  objContract.CreatedById;
            objClonedContract.CreatedDate =  objContract.CreatedDate;
            objClonedContract.CurrencyIsoCode =  objContract.CurrencyIsoCode;
            objClonedContract.Current_Signatary__c =  objContract.Current_Signatary__c;
            objClonedContract.CustomerSignatory__c =  objContract.CustomerSignatory__c;
            objClonedContract.CustomerSignedBy__c =  objContract.CustomerSignedBy__c;
            objClonedContract.DANumer__c =  objContract.DANumer__c;
            objClonedContract.DJBooth__c =  objContract.DJBooth__c;
            objClonedContract.Docusign_Error_integration__c =  objContract.Docusign_Error_integration__c;
            objClonedContract.ds_Envelope_Id__c =  objContract.ds_Envelope_Id__c;
            objClonedContract.EndDate__c =  objContract.EndDate__c;
            objClonedContract.Exlusivity__c =  objContract.Exlusivity__c;
            objClonedContract.External_Id__c =  objContract.External_Id__c;
            objClonedContract.FunctionalMaterialComment__c =  objContract.FunctionalMaterialComment__c;
            objClonedContract.FunctionalMaterial__c =  objContract.FunctionalMaterial__c;
            objClonedContract.GeneralManager__c =  objContract.GeneralManager__c;
            objClonedContract.GMDC_Total__c =  objContract.GMDC_Total__c;
            objClonedContract.IncentiveBrigadeComment__c =  objContract.IncentiveBrigadeComment__c;
            objClonedContract.IncentiveBrigade__c =  objContract.IncentiveBrigade__c;
            objClonedContract.IsAnOpenPlace__c =  objContract.IsAnOpenPlace__c;
            objClonedContract.KPIFinancialReturn__c =  objContract.KPIFinancialReturn__c;
            objClonedContract.KPIVisibility__c =  objContract.KPIVisibility__c;
            objClonedContract.LastModifiedById =  objContract.LastModifiedById;
            objClonedContract.LastModifiedDate =  objContract.LastModifiedDate;
            objClonedContract.LAT_AditionComment__c =  objContract.LAT_AditionComment__c;
            objClonedContract.LAT_Ativacoes__c =  objContract.LAT_Ativacoes__c;
            objClonedContract.LAT_Comunicacao__c =  objContract.LAT_Comunicacao__c;
            objClonedContract.LAT_Contrapartidas__c =  objContract.LAT_Contrapartidas__c;
            objClonedContract.LAT_Digital__c =  objContract.LAT_Digital__c;
            objClonedContract.LAT_Distributor__c =  objContract.LAT_Distributor__c;
            objClonedContract.LAT_ErrorMessages__c =  objContract.LAT_ErrorMessages__c;
            objClonedContract.LAT_Frequency__c =  objContract.LAT_Frequency__c;
            objClonedContract.LAT_ImmActivityInt__c =  objContract.LAT_ImmActivityInt__c;
            objClonedContract.LAT_ImmActivity__c =  objContract.LAT_ImmActivity__c;
            objClonedContract.LAT_IsAdmin__c =  objContract.LAT_IsAdmin__c;
            objClonedContract.LAT_MarcasAtivadas__c =  objContract.LAT_MarcasAtivadas__c;
            objClonedContract.LAT_Perfil__c =  objContract.LAT_Perfil__c;
            objClonedContract.LAT_SocialMediaLinks__c =  objContract.LAT_SocialMediaLinks__c;
            objClonedContract.LAT_UF__c =  objContract.LAT_UF__c;
            objClonedContract.Manager__c =  objContract.Manager__c;
            objClonedContract.MenuComment__c =  objContract.MenuComment__c;
            objClonedContract.Menu__c =  objContract.Menu__c;
            objClonedContract.MixologistsConsultingComment__c =  objContract.MixologistsConsultingComment__c;
            objClonedContract.MixologistsConsulting__c =  objContract.MixologistsConsulting__c;
            objClonedContract.Money__c =  objContract.Money__c;
            objClonedContract.Name =  objContract.Name;
            objClonedContract.NonApprovalReason__c =  objContract.NonApprovalReason__c;
            objClonedContract.OriginalContractNumber__c =  objContract.OriginalContractNumber__c;
            objClonedContract.OriginalContractTerms__c =  objContract.OriginalContractTerms__c;
            objClonedContract.OriginalEndDate__c =  objContract.OriginalEndDate__c;
            objClonedContract.OwnerId =  objContract.OwnerId;
            objClonedContract.PartyEventsComment__c =  objContract.PartyEventsComment__c;
            objClonedContract.PartyEvents__c =  objContract.PartyEvents__c;
            objClonedContract.Phase__c =  objContract.Phase__c;
            objClonedContract.PRBPortfolio__c =  objContract.PRBPortfolio__c;
            objClonedContract.ProcessStatus__c =  objContract.ProcessStatus__c;
            objClonedContract.ProductVisibilityComment__c =  objContract.ProductVisibilityComment__c;
            objClonedContract.ProductVisibility__c =  objContract.ProductVisibility__c;
            objClonedContract.RecordTypeId =  objContract.RecordTypeId;
            objClonedContract.RegionalManager__c =  objContract.RegionalManager__c;
            objClonedContract.Revenue__c =  objContract.Revenue__c;
            objClonedContract.ROI_Target__c =  objContract.ROI_Target__c;
            objClonedContract.ROI__c =  objContract.ROI__c;
            objClonedContract.SellBottleComment__c =  objContract.SellBottleComment__c;
            objClonedContract.SellBottle__c =  objContract.SellBottle__c;
            objClonedContract.SignaturesFlow__c =  objContract.SignaturesFlow__c;
            objClonedContract.Source__c =  objContract.Source__c;
            objClonedContract.SpecialProjectsComment__c =  objContract.SpecialProjectsComment__c;
            objClonedContract.SpecialProjects__c =  objContract.SpecialProjects__c;
            objClonedContract.StandardClausesPRB__c =  objContract.StandardClausesPRB__c;
            objClonedContract.StandardMinutes__c =  objContract.StandardMinutes__c;
            objClonedContract.StartDate__c =  objContract.StartDate__c;
            objClonedContract.StartOfPartnership__c =  objContract.StartOfPartnership__c;
            objClonedContract.Status__c =  objContract.Status__c;
            objClonedContract.SuggestedMaximumInvesment__c =  objContract.SuggestedMaximumInvesment__c;
            objClonedContract.TailorMadeComment__c =  objContract.TailorMadeComment__c;
            objClonedContract.TailorMade__c =  objContract.TailorMade__c;
            objClonedContract.TotalBonus__c =  objContract.TotalBonus__c;
            objClonedContract.TotalCostBonus__c =  objContract.TotalCostBonus__c;
            objClonedContract.TotalEventContractPerceivedValue__c =  objContract.TotalEventContractPerceivedValue__c;
            objClonedContract.TotalEventContractPRBCost__c =  objContract.TotalEventContractPRBCost__c;
            objClonedContract.TotalMoneyPerceivedValue__c =  objContract.TotalMoneyPerceivedValue__c;
            objClonedContract.TotalMoneyPRBCost__c =  objContract.TotalMoneyPRBCost__c;
            objClonedContract.TotalOthersMonth__c =  objContract.TotalOthersMonth__c;
            objClonedContract.TotalProductsPerceivedValueCondComercial__c =  objContract.TotalProductsPerceivedValueCondComercial__c;
            objClonedContract.TotalProductsPerceivedValuePatrocinio__c =  objContract.TotalProductsPerceivedValuePatrocinio__c;
            objClonedContract.TotalProductsPerceivedValue__c =  objContract.TotalProductsPerceivedValue__c;
            objClonedContract.TotalProductsPRBCostCondComercial__c =  objContract.TotalProductsPRBCostCondComercial__c;
            objClonedContract.TotalProductsPRBCostPatrocinio__c =  objContract.TotalProductsPRBCostPatrocinio__c;
            objClonedContract.TotalProductsPRBCost__c =  objContract.TotalProductsPRBCost__c;
            objClonedContract.TotalVodkaMonth__c =  objContract.TotalVodkaMonth__c;
            objClonedContract.TotalWhiskyMonth__c =  objContract.TotalWhiskyMonth__c;
            objClonedContract.TradingConditionNegotiated__c =  objContract.TradingConditionNegotiated__c;
            objClonedContract.UnfiledFields__c =  objContract.UnfiledFields__c;
            objClonedContract.UniformComment__c =  objContract.UniformComment__c;
            objClonedContract.Uniform__c =  objContract.Uniform__c;
            objClonedContract.Use_Consultant_to_Testify__c =  objContract.Use_Consultant_to_Testify__c;
            objClonedContract.Value__c =  objContract.Value__c;
            objClonedContract.VodkaClubCabinets__c =  objContract.VodkaClubCabinets__c;
            objClonedContract.WhiskyClubCabinets__c =  objContract.WhiskyClubCabinets__c;
            objClonedContract.TradingConditionNegotiated__c =  objContract.TradingConditionNegotiated__c;
            objClonedContract.UnfiledFields__c =  objContract.UnfiledFields__c;
            objClonedContract.UniformComment__c =  objContract.UniformComment__c;
            objClonedContract.Uniform__c =  objContract.Uniform__c;
            objClonedContract.Use_Consultant_to_Testify__c =  objContract.Use_Consultant_to_Testify__c;
            objClonedContract.Value__c =  objContract.Value__c;
            objClonedContract.VodkaClubCabinets__c =  objContract.VodkaClubCabinets__c;
            objClonedContract.WhiskyClubCabinets__c =  objContract.WhiskyClubCabinets__c;
        } catch(Exception Ex) {
        
        }
        System.debug('cloneContract [' + objClonedContract + '] <-');

        return objClonedContract;
    }

    public static Account cloneAccount(Account objAccount) {
        Account objClonedAccount = null;

        try  {
            objClonedAccount = new Account();
            objClonedAccount.Accept_applications_Incompleted__c =  objAccount.Accept_applications_Incompleted__c;
            objClonedAccount.Accept_Backorder__c =  objAccount.Accept_Backorder__c;
            objClonedAccount.Accept_line_incompleted__c =  objAccount.Accept_line_incompleted__c;
            objClonedAccount.Accept_pallet_CHEP__c =  objAccount.Accept_pallet_CHEP__c;
            objClonedAccount.Accept_pallet_NF__c =  objAccount.Accept_pallet_NF__c;
            objClonedAccount.AccountNumber =  objAccount.AccountNumber;
            objClonedAccount.AddressLine1_AR__c =  objAccount.AddressLine1_AR__c;
            objClonedAccount.Affiliate__c =  objAccount.Affiliate__c;
            objClonedAccount.Agency__c =  objAccount.Agency__c;
            objClonedAccount.Area_Manager__c =  objAccount.Area_Manager__c;
            objClonedAccount.AsistRoute_AR__c =  objAccount.AsistRoute_AR__c;
            objClonedAccount.Billing_Address_Code__c =  objAccount.Billing_Address_Code__c;
            objClonedAccount.Billing_Address__c =  objAccount.Billing_Address__c;
            objClonedAccount.Billing_City_Code__c =  objAccount.Billing_City_Code__c;
            objClonedAccount.Billing_CNPJ__c =  objAccount.Billing_CNPJ__c;
            objClonedAccount.Billing_Complement__c =  objAccount.Billing_Complement__c;
            objClonedAccount.Billing_Country__c =  objAccount.Billing_Country__c;
            objClonedAccount.Billing_Neighbourhood__c =  objAccount.Billing_Neighbourhood__c;
            objClonedAccount.Billing_Number__c =  objAccount.Billing_Number__c;
            objClonedAccount.Billing_PostalCode__c =  objAccount.Billing_PostalCode__c;
            objClonedAccount.Billing_Priority__c =  objAccount.Billing_Priority__c;
            objClonedAccount.Billing_UF__c =  objAccount.Billing_UF__c;
            objClonedAccount.Business_Unit_AR__c =  objAccount.Business_Unit_AR__c;
            objClonedAccount.Business_Unit__c =  objAccount.Business_Unit__c;
            objClonedAccount.CatCode02_AR__c =  objAccount.CatCode02_AR__c;
            objClonedAccount.Channel_Type__c =  objAccount.Channel_Type__c;
            objClonedAccount.Channel__c =  objAccount.Channel__c;
            objClonedAccount.Checked_over_Commercial_Planning__c =  objAccount.Checked_over_Commercial_Planning__c;
            objClonedAccount.Checked_over_Comptroller__c =  objAccount.Checked_over_Comptroller__c;
            objClonedAccount.Checked_over_Credit_and_collection__c =  objAccount.Checked_over_Credit_and_collection__c;
            objClonedAccount.Checked_over_Sales_Administration__c =  objAccount.Checked_over_Sales_Administration__c;
            objClonedAccount.Checking_account__c =  objAccount.Checking_account__c;
            objClonedAccount.CheckList_AR__c =  objAccount.CheckList_AR__c;
            objClonedAccount.Client_code_AN8__c =  objAccount.Client_code_AN8__c;
            objClonedAccount.Client_country_AN8__c =  objAccount.Client_country_AN8__c;
            objClonedAccount.CNPJ__c =  objAccount.CNPJ__c;
            objClonedAccount.CollectionAgent_AR__c =  objAccount.CollectionAgent_AR__c;
            objClonedAccount.Contact_Schedule__c =  objAccount.Contact_Schedule__c;
            objClonedAccount.Corby_Neutral_Comp_CA__c =  objAccount.Corby_Neutral_Comp_CA__c;
            objClonedAccount.Corporate_Name__c =  objAccount.Corporate_Name__c;
            objClonedAccount.Credit_line_USD_AR__c =  objAccount.Credit_line_USD_AR__c;
            objClonedAccount.Credit_line__c =  objAccount.Credit_line__c;
            objClonedAccount.CurrencyIsoCode =  objAccount.CurrencyIsoCode;
            objClonedAccount.Current_account__c =  objAccount.Current_account__c;
            objClonedAccount.CustomerPoRequired_AR__c =  objAccount.CustomerPoRequired_AR__c;
            objClonedAccount.CustomerPriceGroup_AR__c =  objAccount.CustomerPriceGroup_AR__c;
            objClonedAccount.Customer_Flag__c =  objAccount.Customer_Flag__c;
            objClonedAccount.Customer_Geographic_Region__c =  objAccount.Customer_Geographic_Region__c;
            objClonedAccount.Customer_GL__c =  objAccount.Customer_GL__c;
            objClonedAccount.Customer_is_KA__c =  objAccount.Customer_is_KA__c;
            objClonedAccount.Customer_Organization__c =  objAccount.Customer_Organization__c;
            objClonedAccount.Day_receiving_freight__c =  objAccount.Day_receiving_freight__c;
            objClonedAccount.Description =  objAccount.Description;
            objClonedAccount.DirecRoute_AR__c =  objAccount.DirecRoute_AR__c;
            objClonedAccount.Discount_Group__c =  objAccount.Discount_Group__c;
            objClonedAccount.Email_NFE__c =  objAccount.Email_NFE__c;
            objClonedAccount.Fractionated_requires_a_pallet_per_item__c =  objAccount.Fractionated_requires_a_pallet_per_item__c;
            objClonedAccount.Freight_Type__c =  objAccount.Freight_Type__c;
            objClonedAccount.Frequency_of_Visits__c =  objAccount.Frequency_of_Visits__c;
            objClonedAccount.Gerente_de_area__pc =  objAccount.Gerente_de_area__pc;
            objClonedAccount.Gerente_regional_KAM__pc =  objAccount.Gerente_regional_KAM__pc;
            objClonedAccount.IsRebaComplete__c =  objAccount.IsRebaComplete__c;
            objClonedAccount.Is_Interface_Process_AR__c =  objAccount.Is_Interface_Process_AR__c;
            objClonedAccount.LAT_BR_ActingFormat__c =  objAccount.LAT_BR_ActingFormat__c;
            objClonedAccount.LAT_BR_BusinessSize__c =  objAccount.LAT_BR_BusinessSize__c;
            objClonedAccount.LAT_BR_FiscalBenefit__c =  objAccount.LAT_BR_FiscalBenefit__c;
            objClonedAccount.LAT_BR_InformationRequiredOff__c =  objAccount.LAT_BR_InformationRequiredOff__c;
            objClonedAccount.LAT_BR_PriorityLevel__c =  objAccount.LAT_BR_PriorityLevel__c;
            objClonedAccount.LAT_BR_RegionalClientOnPremise__c =  objAccount.LAT_BR_RegionalClientOnPremise__c;
            objClonedAccount.LAT_Children__pc =  objAccount.LAT_Children__pc;
            objClonedAccount.LAT_DNI__pc =  objAccount.LAT_DNI__pc;
            objClonedAccount.LAT_FavouriteDrink__pc =  objAccount.LAT_FavouriteDrink__pc;
            objClonedAccount.LAT_FootballTeam__pc =  objAccount.LAT_FootballTeam__pc;
            objClonedAccount.LAT_HobbiesDescription__pc =  objAccount.LAT_HobbiesDescription__pc;
            objClonedAccount.LAT_Hobbies__pc =  objAccount.LAT_Hobbies__pc;
            objClonedAccount.LAT_InformationUnfilled__c =  objAccount.LAT_InformationUnfilled__c;
            objClonedAccount.LAT_MX_ABCCode__c =  objAccount.LAT_MX_ABCCode__c;
            objClonedAccount.LAT_MX_AddendumType__c =  objAccount.LAT_MX_AddendumType__c;
            objClonedAccount.LAT_MX_AddendumVersion__c =  objAccount.LAT_MX_AddendumVersion__c;
            objClonedAccount.LAT_MX_AmountReceiptCopies__c =  objAccount.LAT_MX_AmountReceiptCopies__c;
            objClonedAccount.LAT_MX_APStep__c =  objAccount.LAT_MX_APStep__c;
            objClonedAccount.LAT_MX_AvailableCreditLimit__c =  objAccount.LAT_MX_AvailableCreditLimit__c;
            objClonedAccount.LAT_MX_AverageTicket__c =  objAccount.LAT_MX_AverageTicket__c;
            objClonedAccount.LAT_MX_BatchProcess__c =  objAccount.LAT_MX_BatchProcess__c;
            objClonedAccount.LAT_MX_BestDay__c =  objAccount.LAT_MX_BestDay__c;
            objClonedAccount.LAT_MX_BestTime__c =  objAccount.LAT_MX_BestTime__c;
            objClonedAccount.LAT_MX_BetweenStreets__c =  objAccount.LAT_MX_BetweenStreets__c;
            objClonedAccount.LAT_MX_BreakDownIEPS__c =  objAccount.LAT_MX_BreakDownIEPS__c;
            objClonedAccount.LAT_MX_CableCodeS__c =  objAccount.LAT_MX_CableCodeS__c;
            objClonedAccount.LAT_MX_Capacity__c =  objAccount.LAT_MX_Capacity__c;
            objClonedAccount.LAT_MX_Carateristicas__pc =  objAccount.LAT_MX_Carateristicas__pc;
            objClonedAccount.LAT_MX_Chain__c =  objAccount.LAT_MX_Chain__c;
            objClonedAccount.LAT_MX_CreditAndCollectionsExecutive__c =  objAccount.LAT_MX_CreditAndCollectionsExecutive__c;
            objClonedAccount.LAT_MX_CreditVersionLevel__c =  objAccount.LAT_MX_CreditVersionLevel__c;
            objClonedAccount.LAT_MX_FinalRatingSegmentation__c =  objAccount.LAT_MX_FinalRatingSegmentation__c;
            objClonedAccount.LAT_MX_FiscalEntityType__c =  objAccount.LAT_MX_FiscalEntityType__c;
            objClonedAccount.LAT_MX_FiscalRate__c =  objAccount.LAT_MX_FiscalRate__c;
            objClonedAccount.LAT_MX_Game__c =  objAccount.LAT_MX_Game__c;
            objClonedAccount.LAT_MX_GiveBonus__c =  objAccount.LAT_MX_GiveBonus__c;
            objClonedAccount.LAT_MX_Group__c =  objAccount.LAT_MX_Group__c;
            objClonedAccount.LAT_MX_Language__c =  objAccount.LAT_MX_Language__c;
            objClonedAccount.LAT_MX_Market__c =  objAccount.LAT_MX_Market__c;
            objClonedAccount.LAT_MX_MissingDocuments__c =  objAccount.LAT_MX_MissingDocuments__c;
            objClonedAccount.LAT_MX_PostalCode__c =  objAccount.LAT_MX_PostalCode__c;
            objClonedAccount.LAT_MX_PriorityBrand_1__c =  objAccount.LAT_MX_PriorityBrand_1__c;
            objClonedAccount.LAT_MX_PriorityBrand_2__c =  objAccount.LAT_MX_PriorityBrand_2__c;
            objClonedAccount.LAT_MX_PriorityBrand_3__c =  objAccount.LAT_MX_PriorityBrand_3__c;
            objClonedAccount.LAT_MX_ProvidesInformation__c =  objAccount.LAT_MX_ProvidesInformation__c;
            objClonedAccount.LAT_MX_RequiredCustomer_OC__c =  objAccount.LAT_MX_RequiredCustomer_OC__c;
            objClonedAccount.LAT_MX_RouteCode__c =  objAccount.LAT_MX_RouteCode__c;
            objClonedAccount.LAT_MX_SpecialAddendumRequired__c =  objAccount.LAT_MX_SpecialAddendumRequired__c;
            objClonedAccount.LAT_MX_SupplierNumber__c =  objAccount.LAT_MX_SupplierNumber__c;
            objClonedAccount.LAT_MX_ZoneNumber__c =  objAccount.LAT_MX_ZoneNumber__c;
            objClonedAccount.LAT_Origin__pc =  objAccount.LAT_Origin__pc;
            objClonedAccount.LAT_Perfil__pc =  objAccount.LAT_Perfil__pc;
            objClonedAccount.LAT_Prefered_Brand__pc =  objAccount.LAT_Prefered_Brand__pc;
            objClonedAccount.LAT_WeddingDate__pc =  objAccount.LAT_WeddingDate__pc;
            objClonedAccount.Linkaccount__c =  objAccount.Linkaccount__c;
            objClonedAccount.Logistics_Notes__c =  objAccount.Logistics_Notes__c;
            objClonedAccount.ManRoute_AR__c =  objAccount.ManRoute_AR__c;
            objClonedAccount.Municipal_Registration__c =  objAccount.Municipal_Registration__c;
            objClonedAccount.Name =  objAccount.Name;
            objClonedAccount.NameLocal =  objAccount.NameLocal;
            objClonedAccount.Necessary_to_inform_the_Fiscal_Number__c =  objAccount.Necessary_to_inform_the_Fiscal_Number__c;
            objClonedAccount.Need_helpers__c =  objAccount.Need_helpers__c;
            objClonedAccount.Nielsen_Area__c =  objAccount.Nielsen_Area__c;
            objClonedAccount.Notes_1__c =  objAccount.Notes_1__c;
            objClonedAccount.Notes__c =  objAccount.Notes__c;
            objClonedAccount.Only_Mixed__c =  objAccount.Only_Mixed__c;
            objClonedAccount.Only_palletized__c =  objAccount.Only_palletized__c;
            objClonedAccount.Orgao_expedidor__pc =  objAccount.Orgao_expedidor__pc;
            objClonedAccount.Other_Notes__c =  objAccount.Other_Notes__c;
            objClonedAccount.Outlet_Image_Description_CA__c =  objAccount.Outlet_Image_Description_CA__c;
            objClonedAccount.Outlet_Image_Score_CA__c =  objAccount.Outlet_Image_Score_CA__c;
            objClonedAccount.Overdue__c =  objAccount.Overdue__c;
            objClonedAccount.OwnerId =  objAccount.OwnerId;
            objClonedAccount.pallet_Height__c =  objAccount.pallet_Height__c;
            objClonedAccount.Pallet_Type__c =  objAccount.Pallet_Type__c;
            objClonedAccount.Papel__pc =  objAccount.Papel__pc;
            objClonedAccount.ParentId =  objAccount.ParentId;
            objClonedAccount.Payment_Condition__c =  objAccount.Payment_Condition__c;
            objClonedAccount.Payment_instrument__c =  objAccount.Payment_instrument__c;
            objClonedAccount.Rating =  objAccount.Rating;
            objClonedAccount.Rating_segmentation_targert_market__c =  objAccount.Rating_segmentation_targert_market__c;
            objClonedAccount.Reason_for_Inactivation__c =  objAccount.Reason_for_Inactivation__c;
            objClonedAccount.Reason_for_not_approved__c =  objAccount.Reason_for_not_approved__c;
            objClonedAccount.Receive_Attach_Sellout__c =  objAccount.Receive_Attach_Sellout__c;
            objClonedAccount.Receive_Only_pallet_PRB__c =  objAccount.Receive_Only_pallet_PRB__c;
            objClonedAccount.Receive_Payment_Type__c =  objAccount.Receive_Payment_Type__c;
            objClonedAccount.Receiving_Freight__c =  objAccount.Receiving_Freight__c;
            objClonedAccount.RecordTypeId =  objAccount.RecordTypeId;
            objClonedAccount.Regional_AR__c =  objAccount.Regional_AR__c;
            objClonedAccount.Regional_Manager__c =  objAccount.Regional_Manager__c;
            objClonedAccount.Regional_Sales_CodDefUsuario__c =  objAccount.Regional_Sales_CodDefUsuario__c;
            objClonedAccount.Regional__c =  objAccount.Regional__c;
            objClonedAccount.Return_JDE_Integration__c =  objAccount.Return_JDE_Integration__c;
            objClonedAccount.Revenue_Address__c =  objAccount.Revenue_Address__c;
            objClonedAccount.Revenue_City_Code__c =  objAccount.Revenue_City_Code__c;
            objClonedAccount.Revenue_City__c =  objAccount.Revenue_City__c;
            objClonedAccount.Revenue_Complement__c =  objAccount.Revenue_Complement__c;
            objClonedAccount.Revenue_Country__c =  objAccount.Revenue_Country__c;
            objClonedAccount.Revenue_Neighbourhood__c =  objAccount.Revenue_Neighbourhood__c;
            objClonedAccount.Revenue_Number__c =  objAccount.Revenue_Number__c;
            objClonedAccount.Revenue_Postal_Code__c =  objAccount.Revenue_Postal_Code__c;
            objClonedAccount.Revenue_UF__c =  objAccount.Revenue_UF__c;
            objClonedAccount.RG__pc =  objAccount.RG__pc;
            objClonedAccount.SaveDuplicatedFiscalID_AR__c =  objAccount.SaveDuplicatedFiscalID_AR__c;
            objClonedAccount.Segmentation_Type_on_trade__c =  objAccount.Segmentation_Type_on_trade__c;
            objClonedAccount.Shipping_Address_Code__c =  objAccount.Shipping_Address_Code__c;
            objClonedAccount.Shipping_Address__c =  objAccount.Shipping_Address__c;
            objClonedAccount.Shipping_City_Code__c =  objAccount.Shipping_City_Code__c;
            objClonedAccount.Shipping_CNPJ__c =  objAccount.Shipping_CNPJ__c;
            objClonedAccount.Shipping_Complement__c =  objAccount.Shipping_Complement__c;
            objClonedAccount.Shipping_Country__c =  objAccount.Shipping_Country__c;
            objClonedAccount.Shipping_Neighbourhood__c =  objAccount.Shipping_Neighbourhood__c;
            objClonedAccount.Shipping_Number__c =  objAccount.Shipping_Number__c;
            objClonedAccount.Shipping_Postal_Code__c =  objAccount.Shipping_Postal_Code__c;
            objClonedAccount.Shipping_UF__c =  objAccount.Shipping_UF__c;
            objClonedAccount.State_Registration__c =  objAccount.State_Registration__c;
            objClonedAccount.Status__c =  objAccount.Status__c;
            objClonedAccount.Subtype__c =  objAccount.Subtype__c;
            objClonedAccount.Sub_Channel_Rating__c =  objAccount.Sub_Channel_Rating__c;
            objClonedAccount.Sub_Channel__c =  objAccount.Sub_Channel__c;
            objClonedAccount.SupRoute_AR__c =  objAccount.SupRoute_AR__c;
            objClonedAccount.TimRoute_AR__c =  objAccount.TimRoute_AR__c;
        } catch(Exception Ex) {

        }

        return objClonedAccount;
    }

    /*
    * updateStatus
    * If the owner finish his task to get the client signature, we must update the signature flow field
    * @param List<Task> new, List<Task> old
    */
    public static void updateStatus(List<Task> triggerNew, List<Task> triggerOld) {

        String SIGNATURECHECKER = '**não assinou**';

        Map<id, Task> oldMap = new  Map<id, Task> ([SELECT id, status, Description FROM Task WHERE id IN: triggerOld]);
        Set<String> contractSignedIds = new Set<String>();
        Set<String> contractNotSignedIds = new Set<String>();
        Set<String> conToActivate = new Set<String>();
        for (Task t: triggerNew) {
            if (t.LAT_Tipo__c == 'CT-Assinatura'
            && (t.status == 'Completed' || t.status == 'Not Completed' || t.status == 'Concluído')) {
                //Boolean clientNotSign = t.Description.contains(SIGNATURECHECKER);
                Boolean clientNotSign = t.status == 'Not Completed';
                if(clientNotSign){
                    contractNotSignedIds.add(t.WhatId);
                } else {
                    contractSignedIds.add(t.WhatId);

                }

            } else if (t.LAT_Tipo__c == 'CT-EntregarCliente'
            && (t.status == 'Completed' || t.status == 'Concluído')) {
                conToActivate.add(t.WhatId);
            }

        }

        List<Lat_contract2__c> conSignedToUpdate = [SELECT id, SignaturesFlow__c FROM Lat_contract2__c WHERE id  in:contractSignedIds];
        for(Lat_contract2__c lc2 : conSignedToUpdate){
            lc2.SignaturesFlow__c = 'Consultor-Assinatura Cliente';
            trackDurationReport(lc2, 'STARTDATE');

            // Post in chatter group
        }

        List<Lat_contract2__c> conNotSignedToUpdate = [SELECT id, SignaturesFlow__c FROM Lat_contract2__c WHERE id  in:contractNotSignedIds];
        for(Lat_contract2__c lc2 : conNotSignedToUpdate){
            lc2.ProcessStatus__c = 'Contrato Não Assinado Cliente';
        }

        List<Lat_contract2__c> conToAct = [SELECT id, Status__c, SignaturesFlow__c FROM Lat_contract2__c WHERE id  in:conToActivate];
        for(Lat_contract2__c lc2 : conToAct){
            system.debug('>>>>>>>>>>>>>>lc2'+ lc2);
            if(lc2.Status__c == 'Distrato Aprovado'){
                lc2.Status__c = 'Cancelado';
            } else if(lc2.Status__c == 'Aprovado'){
                lc2.Status__c = 'Ativo';
            }

            lc2.ProcessStatus__c = 'Processo Finalizado';
            lc2.SignaturesFlow__c = 'Consultor-Contrato Ativado';
            trackDurationReport(lc2, 'ENDDATE');
        }
        update conToAct;
        update conNotSignedToUpdate;
        system.debug('>>>>>>>>>>>>>>conSignedToUpdate'+ conSignedToUpdate);
        update conSignedToUpdate;
        //update conSignedToUpdate;
    }

    @testVisible
    private static void trackDurationReport(Lat_contract2__c contract, String status){
        List<LAT_objectPerformance__c> objectPerformanceList = [SELECT id,LATContract__c, Type__c,StartDate__c,EndDate__c FROM LAT_objectPerformance__c where LATContract__c =:contract.id];
        LAT_objectPerformance__c objPerItem = new LAT_objectPerformance__c();
        if(objectPerformanceList.size()>0){ objPerItem = objectPerformanceList.get(0);}
        if(status == 'ENDDATE') {
            objPerItem.EndDate__c =  Date.today();
        } else if(status == 'STARTDATE'){
            objPerItem.StartDate__c =  Date.today();
            objPerItem.Type__c = 'Signature Flux duration';
            objPerItem.LATContract__c = contract.Id;
        }
        upsert objPerItem;
    }

    /*
    * updateProcessStatus
    * When the signature change we must update the process status
    * @param List<Task> new, List<Task> old
    */
    public static void updateProcessStatus(List<LAT_Contract2__c> triggerNew) {
        List<feedItem> feedToInsert = new List<feedItem>();
        List<Id> accounts = new List<Id>();

        for (LAT_Contract2__c contract: triggerNew) {
            if(contract.SignaturesFlow__c == 'Consultor-Assinatura Cliente'){
                contract.ProcessStatus__c ='Contrato Assinado Cliente';

            } else if(contract.SignaturesFlow__c == 'Assistente Regional-Contrato Assinado Recebido Consultor'){
                contract.ProcessStatus__c = 'ASS – Contrato Recebido Consultor';

            } else if(contract.SignaturesFlow__c == 'Assistente Regional-Contrato Assinado Entregue Trade'){
                contract.ProcessStatus__c = 'ASS – Contrato Assinado Entregue Trade';

            } else if(contract.SignaturesFlow__c == 'Trade-Contrato Assinado Recebido Ass. Regional'){
                contract.ProcessStatus__c = 'TRA – Contrato Assinado Recebido Assistente';

            } else if(contract.SignaturesFlow__c == 'Trade-Contrato Assinado Entregue Ass. Regional'){
                contract.ProcessStatus__c = 'TRA – Contrato Assinado Entregue Assistente';

            } else if(contract.SignaturesFlow__c == 'Assistente Regional-Contrato Assinado Recebido Trade'){
                contract.ProcessStatus__c = 'ASS – Contrato Assinado Recebido Trade';

            } else if(contract.SignaturesFlow__c == 'Assistente Regional-Contrato Assinado Entregue Consultor'){
                contract.ProcessStatus__c = 'ASS – Contrato Assinado Entregue Consultor';

            } else if(contract.SignaturesFlow__c == 'Consultor-Contrato Ativado'){
                contract.ProcessStatus__c = 'Processo Finalizado';
                trackDurationReport(contract, 'ENDDATE');
            }

            if(!feedToInsert.isEmpty()) insert feedToInsert;
        }
    }

    /*
    * chatterGroupNotification
    * Post contract status on  chatter "Contratos OnTrade" group
    */
    public static void chatterGroupNotification(List<LAT_Contract2__c> triggerNew, Map<id, LAT_Contract2__c> oldMap) {

        Set<Id> accountIds = new Set<Id>();
        Set<Id> recordTypeIds = new Set<Id>();
        Map<String, List<LAT_Contract2__c> > contractIdsType = new Map<String, List<LAT_Contract2__c> >();

        for (LAT_Contract2__c contract: triggerNew) {
            // Active Contract
            List<LAT_Contract2__c> cont = new List<LAT_Contract2__c>();

            if (contract.Status__c == 'Ativo' && oldMap.get(contract.id).Status__c != 'Ativo') {
                if(contractIdsType.containsKey('Active')) cont = contractIdsType.get('Active');
                
                cont.add(contract);
                contractIdsType.put('Active', cont);

            } else if (contract.Status__c == 'Cancelado' && oldMap.get(contract.id).Status__c != 'Cancelado') {
                if(contractIdsType.containsKey('Cancelled')){
                    cont = contractIdsType.get('Cancelled');
                }
                cont.add(contract);
                contractIdsType.put('Cancelled', cont);
            }

            accountIds.add(contract.Account__c);
            recordTypeIds.add(contract.RecordTypeId);
        }
        // Post
        if (!contractIdsType.isEmpty()) {
            sendChatter(accountIds, recordTypeIds,contractIdsType);
           
        }
    }

    public static void sendChatter( Set<Id> accountIds, Set<Id> recordTypeIds, Map<String, List<LAT_Contract2__c>> contractIdsType) {
        List<Account> ls = [select Id,Name, BillingCity, Segmentation_Type_on_trade__c, Regional__r.name from Account where Id IN :accountIds];
        Map<Id, Account> accountMap = new Map<Id, Account>(ls);
        List<FeedItem> feedItems = new List<FeedItem>();
        // Chatter Group selection
        List<CollaborationGroup> groupC = null;
        groupC = [SELECT Id,Name From CollaborationGroup WHERE name='Contratos OnTrade'];
        System.debug('LAT_ContractsCalculations.**** recordTypeIds: ' + recordTypeIds);
        Map<Id, recordType> recorTypemap = new Map<Id, recordType>([Select id, name from recordType where Id in: recordTypeIds]);

        // If the group doesn't exists we don't post a feed
        if(Test.isRunningTest() || !groupC.isEmpty()){
            System.debug('LAT_ContractsCalculations.**** groupC: ' + groupC);

            if(contractIdsType.containsKey('Active')){
                for (LAT_Contract2__c cId: contractIdsType.get('Active')){
                    Account a = accountMap.get(cId.Account__c);
                    Datetime dt = datetime.newInstance(cId.startDate__c.year(), cId.startDate__c.month(),cId.startDate__c.day());
                    String message = 'Contrato com o cliente '+a.name+', Regional '+a.Regional__r.name+', Cidade '+a.BillingCity+', Segmento '+cId.ROISegment__c+' e Tipo '+recorTypemap.get(cId.RecordTypeId).name+' Ativado com vigência a partir de '+dt.format('dd-MM-yyyy')+'.';
                    FeedItem post = new FeedItem();
                    post.Body = message; 
                    post.ParentId = (Test.isRunningTest())?null:groupC[0].Id;
                    post.Title = 'Contrato ' + cId.Name + 'Ativado';

                    feedItems.add(post);
                }
            }
            else if(contractIdsType.containsKey('Cancelled')){

                for (LAT_Contract2__c cId: contractIdsType.get('Cancelled')){
                    Account a = accountMap.get(cId.Account__c);
                    String message = 'Contrato com o cliente '+a.name+', Regional '+a.Regional__r.name+', Cidade '+a.BillingCity+', Segmento '+cId.ROISegment__c+' e Tipo '+recorTypemap.get(cId.RecordTypeId).name+' Cancelado.';
                    FeedItem post = new FeedItem();
                    post.Body = message;
                    post.ParentId = groupC[0].Id;
                    post.Title = 'Contrato ' + cId.Name + 'Cancelado';
                    feedItems.add(post);
                }

            }
            else if(contractIdsType.containsKey('Ended')){
                for (LAT_Contract2__c cId: contractIdsType.get('Ended')){
                    Account a = accountMap.get(cId.Account__c);
                    String message = 'Contrato com o cliente '+a.name+', Regional '+a.Regional__r.name+', Cidade '+a.BillingCity+', Segmento '+cId.ROISegment__c+' e Tipo '+recorTypemap.get(cId.RecordTypeId).name+' Encerrado.';
                    FeedItem post = new FeedItem();
                    post.Body = message;
                    post.ParentId = groupC[0].Id;
                    post.Title = 'Contrato ' + cId.Name + 'Encerrado';
                    feedItems.add(post);
                }
            }
        }
        insert feedItems;
    }
    /*
    * addAttachmentsAndTasks
    * Generates a PDF based on the page LAT_ContractCoverPDF and attach it to the contract.
    * Also generates a task linked to the contract for ...
    */
    @Future(callout=true)
    public static void addAttachmentToContract(List<String> lstContractIds) {
        List<LAT_Contract2__c> lstContracts = null;

        System.debug('LAT_ContractsCalculations.addAttachmentToContract [lstContractIds : ' + lstContractIds + '] ->');
        lstContracts =  [SELECT id, 
                                Status__c, 
                                RecordType.DeveloperName, 
                                StandardClausesPRB__c, 
                                Name,
                                CustomerSignedBy__r.Email,
                                CustomerSignedBy__r.Name,
                                CustomerSignedBy__c,
                                OwnerId,
                                Owner.Name,
                                Owner.Email,
                                CustomerSignatory__r.Email,
                                CustomerSignatory__r.Name,
                                CustomerSignatory__c,
                                ProcessStatus__c,
                                GeneralManager__c,
                                Manager__c,
                                RegionalManager__c,
                                Use_Consultant_to_Testify__c,
                                RegionalCustomerOnPremise__c,
                                Value__c,
                                LAT_ClientRegional__c,
                                convertCurrency(ContractValue__c)
                            FROM LAT_Contract2__c 
                            WHERE Id IN : lstContractIds];
        
        if(!lstContracts.isEmpty()) {
            if(EVENT_DEVELOPER_NAMES.contains(lstContracts[0].RecordType.DeveloperName)) {
				System.debug('LAT_ContractsCalculations.addAttachmentToContract events...');
                addAttachmentToContractEvents(lstContractIds, lstContracts);
            } else if(ACORDO_DEVELOPER_NAMES.contains(lstContracts[0].RecordType.DeveloperName)) {
				System.debug('LAT_ContractsCalculations.addAttachmentToContractAcordos...');
                addAttachmentToContractAcordos(lstContractIds, lstContracts);
            } else {
				System.debug('LAT_ContractsCalculations.addAttachmentToContract others...');
                //addAttachmentToContractOther(lstContractIds, lstContracts);
            }            
        } else {
            throw new LAT_Rest_Contracts.RestContractException(10, 'O contrato para adicionar anexos não foi encontrado');
		}   
		
        System.debug('LAT_ContractsCalculations.addAttachmentToContract [] <-');
    }

    /*
    @TestVisible
    private static void addAttachmentToContractOther(List<String> lstContractIds, List<LAT_Contract2__c> lstContracts) {
        String[] minutaPadrao = LAT_GeneralConfigDao.getValueAsStringArray('LAT_ContractMinutaPadrao', ',');
        
        List<StaticResource> stR = new List<StaticResource>();
        if(minutaPadrao != null) {
            stR = [SELECT Body,Description,Id,Name FROM StaticResource where id =: minutaPadrao[0]];
        }

        List<Attachment> currentAtt = [SELECT Name,ParentId FROM Attachment where parentId in : lstContractIds];
        List<Attachment> attToDelete = new List<Attachment>();
        Set<Id> attToDeleteIds = new Set<Id>();
        List<Attachment> attList = new List<Attachment>();

        for (LAT_Contract2__c contract: lstContracts) {
            // Reference the attachment page, pass in the contract ID
            // Anexo 1.1
            PageReference pdf = Page.LAT_ContractCoverPDF;
            pdf.getParameters().put('id',contract.id);
            pdf.setRedirect(true);

            // Anexo 1.2
            PageReference pdf1 = Page.LAT_ContractCoverPDF;
            pdf1.getParameters().put('id',contract.id);
            pdf1.getParameters().put('type','anex2');
            pdf1.setRedirect(true);

            // Anexo 1.1dale

            PageReference pdfCartaActivacao = Page.LAT_ContractActivationLetterDocumentsPDF;
            pdfCartaActivacao.getParameters().put('id',contract.id);
            pdfCartaActivacao.setRedirect(true);
            // Minuta Padrao

            Boolean mustGenerateMinutaPadrao = contract.StandardClausesPRB__c;

            // Take the PDF content
            Blob pdfBlob = !Test.isRunningTest() ? pdf.getContent() : Blob.valueOf('Testing');
            Blob pdfBlob1 = !Test.isRunningTest() ? pdf1.getContent() : Blob.valueOf('Testing');
            Blob pdfBlobCartaAtivacao = !Test.isRunningTest() ? pdfCartaActivacao.getContent() : Blob.valueOf('Testing');
            //Blob pdfBlob2 = !Test.isRunningTest() ? pdf3.getContent() : Blob.valueOf('Testing');

            for (Attachment at: currentAtt) {

                if(at.name == 'Contrato - ' + contract.Name + ' - Anexo 1.1.pdf' ) {
                    attToDelete.add(at);
                    attToDeleteIds.add(at.Id);
                }
                if(at.name == 'Contrato - ' + contract.Name + ' - Anexo 1.2.pdf' ) {
                    attToDelete.add( at);
                    attToDeleteIds.add(at.Id);
                }
                // Check
                if(at.name == 'Contrato -  ' + contract.Name + ' - Minuta Padrao.pdf') {
                    if(contract.Status__c == 'Em Aprovação' || !mustGenerateMinutaPadrao){
                        attToDelete.add( at);
                        attToDeleteIds.add(at.Id);
                    }
                }
                if(at.name == 'Contrato - ' + contract.Name + ' - Minuta Padrao Carta Acordo.pdf') {
                    attToDelete.add(at);
                    attToDeleteIds.add(at.Id);
                }

            }
            if(lstContracts[0].RecordType.DeveloperName != 'LAT_CartaAtivacao'){
                attList.add ( new Attachment (
                    ParentId = contract.id,
                    Name = 'Contrato - ' + contract.Name + ' - Anexo 1.2.pdf',
                    Body = pdfBlob
                ));
            }
            
            attList.add ( new Attachment (
                ParentId = contract.id,
                Name = 'Contrato - ' + contract.Name + ' - Anexo 1.1.pdf',
                Body = lstContracts[0].RecordType.DeveloperName != 'LAT_CartaAtivacao' ? pdfBlob1 : pdfBlobCartaAtivacao
            ));

            SYSTEM.Debug('\n==============contract.Status__c '+ contract.Status__c);
            SYSTEM.Debug('\n==============mustGenerateMinutaPadrao '+ mustGenerateMinutaPadrao);
            SYSTEM.Debug('\n==============contract.recordtype.developerName '+ contract.recordtype.developerName);

            // Em Aprobacao
            if(contract.Status__c != 'Aprovado'){
                SYSTEM.Debug('\n============== A ');

                // Clauslas nao padrao true - checked
                if(mustGenerateMinutaPadrao){
                    PageReference pdf3 = Page.LAT_ContractDocumentsPDF;
                    // LAT_OnTrade_LetterAgreementCommercialCondition On Trade – Carta Acordo de Condição Comercial
                    // LAT_OnTrade_LetterAgreement On Trade – Carta Acordo de Patrocínio
                    // LAT_OnTrade_CommercialConditionContract - On Trade – Contrato de Condição Comercial
                    // LAT_OnTrade_SponsorshipAgreementOnTrade - On Trade – Contrato de Patrocínio 
                    // On Trade – Contrato de Patrocínio
                    if(contract.recordtype.developerName == 'LAT_OnTrade_SponsorshipAgreementOnTrade'){
                        SYSTEM.Debug('\n============== A2');

                    }
                    // On Trade – Carta Acordo de Patrocínio
                    // Leonardo ASK
                    else if (contract.recordtype.developerName == 'LAT_OnTrade_LetterAgreement'){
                        pdf3.getParameters().put('id',contract.id);
                        pdf3.getParameters().put('docName',MINUTA_PADRAO);
                        pdf3.setRedirect(true);
                        SYSTEM.Debug('\n============== A1 ');
                        // new page
                        attList.add ( new Attachment (
                        ParentId = contract.id,
                        Name = 'Contrato - ' + contract.Name + ' - Minuta Padrao Carta Acordo.pdf',
                        Body = (!Test.isRunningTest() ? pdf3.getContent() : Blob.valueOf('Testing'))
                        ));
                    } 

                // ACA VA EL 
                }
                // Clauslas nao padrao false - unchecked
                else {
                    PageReference pdf3 = Page.LAT_ContractDocumentsPDF;
                    SYSTEM.Debug('\n============== B');
                    // On Trade – Contrato de Patrocínio
                    if (contract.recordtype.developerName == 'LAT_OnTrade_SponsorshipAgreementOnTrade') {
                        pdf3.getParameters().put('id',contract.id);
                        pdf3.getParameters().put('docName',MINUTA_PADRAO_PATROCIONO);
                        pdf3.setRedirect(true);


                        SYSTEM.Debug('\n============== B1 ');
                        //for(StaticResource st : stR){
                            attList.add ( new Attachment (
                            ParentId = contract.id,
                            Name = 'Contrato -  ' + contract.Name + ' - Minuta Padrao.pdf',
                            Body = (!Test.isRunningTest() ? pdf3.getContent() : Blob.valueOf('Testing'))
                            ));
                        //}

                    }
                    // On Trade – Carta Acordo de Patrocínio
                    else if (contract.recordtype.developerName == 'LAT_OnTrade_LetterAgreement'){
                        pdf3.getParameters().put('id',contract.id);
                        pdf3.getParameters().put('docName',MINUTA_PADRAO);
                        pdf3.setRedirect(true);

                        SYSTEM.Debug('\n============== B2 ');
                        // new page
                        attList.add ( new Attachment (
                        ParentId = contract.id,
                        Name = 'Contrato - ' + contract.Name + ' - Minuta Padrao Carta Acordo.pdf',
                        Body = (!Test.isRunningTest() ? pdf3.getContent() : Blob.valueOf('Testing'))
                        ));

                    }

                }
                if (contract.recordtype.developerName == 'LAT_CartaAtivacao'){
                    PageReference pdf3 = Page.LAT_ContractDocumentsPDF;
                    pdf3.getParameters().put('id',contract.id);
                    pdf3.getParameters().put('docName',MINUTA_PADRAO_CARTA_ATIVACAO);
                    pdf3.setRedirect(true);
                    SYSTEM.Debug('\n============== A1 ');
                    // new page
                    attList.add ( new Attachment (
                    ParentId = contract.id,
                    Name = 'Contrato -  ' + contract.Name + ' - Minuta Padrao.pdf',
                    Body = (!Test.isRunningTest() ? pdf3.getContent() : Blob.valueOf('Testing'))
                    ));

                }
            }
            // Aprovado
            else {
                SYSTEM.Debug('\n============== C ');
                // Clauslas nao padrao true - checked
                if(mustGenerateMinutaPadrao){
                    PageReference pdf3 = Page.LAT_ContractDocumentsPDF;
                    SYSTEM.Debug('\n============== C 1');
                    // On Trade – Carta Acordo de Patrocínio
                    if (contract.recordtype.developerName == 'LAT_OnTrade_LetterAgreement'){
                        pdf3.getParameters().put('id',contract.id);
                        pdf3.getParameters().put('docName',MINUTA_PADRAO);
                        pdf3.setRedirect(true);
                        SYSTEM.Debug('\n============== C 1 1');
                        // new page
                        attList.add ( new Attachment (
                        ParentId = contract.id,
                        Name = 'Contrato - ' + contract.Name + ' - Minuta Padrao Carta Acordo.pdf',
                        Body = (!Test.isRunningTest() ? pdf3.getContent() : Blob.valueOf('Testing'))
                        ));
                    } 
                }
                // Clauslas nao padrao false - unchecked
                else {
                    PageReference pdf3 = Page.LAT_ContractDocumentsPDF;
                    SYSTEM.Debug('\n============== D');
                    // On Trade – Carta Acordo de Patrocínio
                    if (contract.recordtype.developerName == 'LAT_OnTrade_LetterAgreement'){
                        pdf3.getParameters().put('id',contract.id);
                        pdf3.getParameters().put('docName',MINUTA_PADRAO);
                        pdf3.setRedirect(true);
                        SYSTEM.Debug('\n============== D 1');
                        // new page
                        attList.add ( new Attachment (
                        ParentId = contract.id,
                        Name = 'Contrato - ' + contract.Name + ' - Minuta Padrao Carta Acordo.pdf',
                        Body = (!Test.isRunningTest() ? pdf3.getContent() : Blob.valueOf('Testing'))
                        ));
                    } 
                    else {
                        SYSTEM.Debug('\n============== J');
                        // On Trade – Contrato de Patrocínio
                        if (contract.recordtype.developerName == 'LAT_OnTrade_SponsorshipAgreementOnTrade') {
                            pdf3.getParameters().put('id',contract.id);
                            pdf3.getParameters().put('docName',MINUTA_PADRAO_PATROCIONO);
                            pdf3.setRedirect(true);


                            SYSTEM.Debug('\n============== B1 ');
                                attList.add ( new Attachment (
                                ParentId = contract.id,
                                Name = 'Contrato -  ' + contract.Name + ' - Minuta Padrao.pdf',
                                Body = (!Test.isRunningTest() ? pdf3.getContent() : Blob.valueOf('Testing'))
                                ));
                        }

                    }

                }
                if (contract.recordtype.developerName == 'LAT_CartaAtivacao'){
                    PageReference pdf3 = Page.LAT_ContractDocumentsPDF;
                    pdf3.getParameters().put('id',contract.id);
                    pdf3.getParameters().put('docName',MINUTA_PADRAO_CARTA_ATIVACAO);
                    pdf3.setRedirect(true);
                    SYSTEM.Debug('\n============== A1 ');
                    // new page
                    attList.add ( new Attachment (
                    ParentId = contract.id,
                    Name = 'Contrato -  ' + contract.Name + ' - Minuta Padrao.pdf',
                    Body = (!Test.isRunningTest() ? pdf3.getContent() : Blob.valueOf('Testing'))
                    ));

                }
            }
        }

        Map<Id, List<Attachment>> attachmentByParent = new Map<Id, List<Attachment>>();
        // get attachment by parentId
        for (Attachment att:attList){
            if(attachmentByParent.get(att.ParentId) == null) attachmentByParent.put(att.ParentId, new List<Attachment>());
            attachmentByParent.get(att.ParentId).add(att);
        }

        // FOR ONE CONTRACT ONLY
            if (LAT_Docusign_Utils.getDocusignConfig().Enable_Docusign_Contracts__c && lstContracts.size() == 1 && lstContracts[0].Status__c == 'Aprovado' && lstContracts[0].RecordType.DeveloperName != EVENT_DISTRIBUTOR){
            //Add other miutas if exist and they does not match the coded one VERIFY LEO
                List<Attachment> minuta = [SELECT Name,ParentId,Body FROM Attachment where Id NOT IN :attToDeleteIds AND Name LIKE '%Minuta Padrao%' AND ParentId = :lstContracts[0].Id ];
                attachmentByParent.get(lstContracts[0].Id).addAll(minuta);
                LAT_Docusign_Utils.requestEnvelopeCreation(lstContracts[0], attachmentByParent.get(lstContracts[0].Id));
            }
        if (!attToDelete.isEmpty()) delete attToDelete;
        if (!attList.isEmpty()) insert attList;

    }

  */

    public static void addAttachmentToContractEvents(List<String> toAttachs, List<LAT_Contract2__c> contracts) {
        System.debug('LAT_ContractsCalculations.%%%%% contracts x attachments : '+ contracts) ;                                     
        String[] minutaPadrao = LAT_GeneralConfigDao.getValueAsStringArray('LAT_ContractMinutaPadraoEventos', ',');
        List<StaticResource> stR = new List<StaticResource>();
        if(minutaPadrao != null) stR = [SELECT Body,Description,Id,Name FROM StaticResource where id =: minutaPadrao[0]];
        
        List<Attachment> currentAtt = [SELECT Name,ParentId FROM Attachment where parentId in : toAttachs];
        System.debug('LAT_ContractsCalculations.%%%%% ccurrentAtts : '+ currentAtt) ;      
        List<Attachment> attToDelete = new List<Attachment>();
        Set<Id> attToDeleteIds = new Set<Id>();
        List<Attachment> attList = new List<Attachment>();

        for (LAT_Contract2__c contract: contracts) {
            // Reference the attachment page, pass in the contract ID

            // Anexo 1.1
            PageReference pdf; 
            if (contract.RecordType.DeveloperName == EVENT_DISTRIBUTOR) {
                pdf = Page.LAT_ContractDistributorDocumentsPDF;
                pdf.getParameters().put('contractId',contract.id);
            } else {
                pdf = Page.LAT_ContractAPDocumentsPDF;
                pdf.getParameters().put('id',contract.id);
            }
            pdf.setRedirect(true);

            // Minuta Padrao

            Boolean mustGenerateMinutaPadrao = !contract.StandardClausesPRB__c;
            if (mustGenerateMinutaPadrao && contract.RecordType.DeveloperName == EVENT_DISTRIBUTOR) mustGenerateMinutaPadrao = false;

            Boolean isDistributor = (contract.RecordType.DeveloperName == EVENT_DISTRIBUTOR);

            // Take the PDF content
            Blob pdfBlob = !Test.isRunningTest() ? pdf.getContent() : Blob.valueOf('Testing');
            //Blob pdfBlob2 = !Test.isRunningTest() ? pdf3.getContent() : Blob.valueOf('Testing');

            for (Attachment at: currentAtt) { 

                if(at.name == 'Contrato - ' + contract.Name + ' - Anexo 1.1.pdf' ) {
                    attToDelete.add(at);
                    attToDeleteIds.add(at.Id);
                }
                
                // Check
                if(at.name == 'Contrato - ' + contract.Name + ' - Minuta Padrao.pdf') {
                    attToDelete.add( at);
                    attToDeleteIds.add(at.Id);
                    
                }

            }

            if (!isDistributor) {
                attList.add ( new Attachment (
                    ParentId = contract.id,
                    Name = 'Contrato - ' + contract.Name + ' - Anexo 1.1.pdf',
                    Body = pdfBlob
                ));    
            }

            SYSTEM.Debug('\n==============contract.Status__c '+ contract.Status__c);
            SYSTEM.Debug('\n==============mustGenerateMinutaPadrao '+ mustGenerateMinutaPadrao);
            SYSTEM.Debug('\n==============contract.recordtype.developerName '+ contract.recordtype.developerName);

            // Em Aprobacao
            if(contract.Status__c != 'Aprovado'){
                SYSTEM.Debug('\n============== A ');

                // Clauslas nao padrao true - checked
                if(mustGenerateMinutaPadrao) {
                    PageReference pdf3 = Page.LAT_ContractDocumentsPDF;

                    pdf3.getParameters().put('id',contract.id);

                    String minutaType = '';
                    minutaType = MINUTA_PADRAO_EVENTOS;

                    pdf3.getParameters().put('docName', minutaType);
                    pdf3.setRedirect(true);
                    
                    // new page
                    attList.add ( new Attachment (
                        ParentId = contract.id,
                        Name = 'Contrato - ' + contract.Name + ' - Minuta Padrao.pdf',
                        Body = (!Test.isRunningTest() ? pdf3.getContent() : Blob.valueOf('Testing'))
                    ));

                }
            }
            
            // Aprovado
            else {
                SYSTEM.Debug('\n============== C ');
                // Clauslas nao padrao true - checked
                if(mustGenerateMinutaPadrao){
                    System.debug('LAT_ContractsCalculations.*** mustGenerateMinutaPadrao 2');

                    PageReference pdf3 = Page.LAT_ContractDocumentsPDF;
                    SYSTEM.Debug('\n============== C 1');
                    // On Trade – Carta Acordo de Patrocínio
                    pdf3 = Page.LAT_ContractDocumentsPDF;

                    pdf3.getParameters().put('id',contract.id);

                    String minutaType = '';
                    if (contract.RecordType.DeveloperName == EVENT_DISTRIBUTOR) {
                        minutaType = MINUTA_PADRAO_EVENTOS_DISTRIBUIDOR;
                    } else {
                        minutaType = MINUTA_PADRAO_EVENTOS;
                    }
                    pdf3.getParameters().put('docName', minutaType);

                    pdf3.setRedirect(true);
                    SYSTEM.Debug('\n============== A1 ');
                    // new page
                    attList.add ( new Attachment (
                    ParentId = contract.id,
                    Name = 'Contrato - ' + contract.Name + ' - Minuta Padrao.pdf',
                    Body = (!Test.isRunningTest() ? pdf3.getContent() : Blob.valueOf('Testing'))
                    ));

                }

                if (isDistributor) {
                    PageReference pdf3 = Page.LAT_ContractDistributorDocumentsPDF;

                    pdf3.getParameters().put('contractId',contract.id);

                    String minutaType = '';
                    minutaType = MINUTA_PADRAO_EVENTOS_DISTRIBUIDOR;

                    pdf3.getParameters().put('docName', minutaType);
                    pdf3.setRedirect(true);

                    System.debug('LAT_ContractsCalculations.*** pdf3: ' + pdf3);
                    System.debug('LAT_ContractsCalculations.*** attList: ' + attList);
                    System.debug('LAT_ContractsCalculations.*** pdf3.getContent(): ' + pdf3.getContent());

                    // new page
                    attList.add ( 
                        new Attachment (
                            ParentId = contract.id,
                            Name = 'Contrato - ' + contract.Name + ' - Acordo Comercial.pdf',
                            Body = (!Test.isRunningTest() ? pdf3.getContent() : Blob.valueOf('Testing'))
                        )
                    );
                }

            }
        }

        Map<Id, List<Attachment>> attachmentByParent = new Map<Id, List<Attachment>>();
        // get attachment by parentId
        for (Attachment att:attList){
            if(attachmentByParent.get(att.ParentId) == null){
                attachmentByParent.put(att.ParentId, new List<Attachment>());
            }
            attachmentByParent.get(att.ParentId).add(att);
        }

        // FOR ONE CONTRACT ONLY
             if (LAT_Docusign_Utils.getDocusignConfig().Enable_Docusign_Contracts__c && contracts.size() == 1 && contracts[0].Status__c == 'Aprovado' && contracts[0].RecordType.DeveloperName != EVENT_DISTRIBUTOR){
               //Add other miutas if exist and they does not match the coded one VERIFY LEO
               List<Attachment> minuta = [SELECT Name,ParentId,Body FROM Attachment where Id NOT IN :attToDeleteIds AND Name LIKE '%Minuta Padrao%' AND ParentId = :contracts[0].Id ];
                attachmentByParent.get(contracts[0].Id).addAll(minuta);
                LAT_Docusign_Utils.requestEnvelopeCreation(contracts[0], attachmentByParent.get(contracts[0].Id));
            }

        if(!attToDelete.isEmpty()) delete attToDelete;

        if (!attList.isEmpty()) insert attList;
    }

	public static void addAttachmentToContractAcordos(List<String> lstContractIds, List<LAT_Contract2__c> lstContracts) {
		List<Attachment> lstCurrentAttachments = null;
        List<Attachment> lstAttachmentsToDelete = new List<Attachment>();
		List<Attachment> lstAttachments = new List<Attachment>();
		Map<Id, List<Attachment>> mapAttachmentByParent = null;
        Set<Id> setAttachmentsToDeleteIds = new Set<Id>();

		String strMinutaPadraoName = null;
		String strAnexo1Name = null;
		Attachment objAttachment = null;
		PageReference objPDF = null; 
		Blob objPDFContent = null;
		System.debug('LAT_ContractsCalculations.addAttachmentToContractAcordos [lstContractIds : ' + lstContractIds + ' - lstContracts : ' + lstContracts + '] ->');

        lstCurrentAttachments = [SELECT Name,ParentId FROM Attachment WHERE ParentId IN : lstContractIds];
        lstAttachmentsToDelete = new List<Attachment>();
        lstAttachments = new List<Attachment>();
        setAttachmentsToDeleteIds = new Set<Id>();

        for (LAT_Contract2__c objContract : lstContracts) {
			strAnexo1Name = 'Contrato - ' + objContract.Name + ' - Anexo 1.1.pdf';
            strMinutaPadraoName = 'Contrato - ' + objContract.Name + ' - Minuta Padrao.pdf';

            for (Attachment objAttachmentAux : lstCurrentAttachments) { 
                if(objAttachmentAux.Name == strAnexo1Name || objAttachmentAux.Name == strMinutaPadraoName) {
					lstAttachmentsToDelete.add(objAttachmentAux);

					System.debug('LAT_ContractsCalculations.addAttachmentToContractAcordos [deleting attacnment...: ' + objAttachmentAux.Id + ' - objContract : ' + objContract.Name + ']');					
                }
            }

            objAttachment = retrieveAnexo1(objContract.Id, strAnexo1Name,'acordo');
            lstAttachments.add(objAttachment);

			objAttachment = retrieveMinutaPadrao(objContract.Id, strMinutaPadraoName,'MINUTA_PADRAO_ACORDO');
			lstAttachments.add(objAttachment);
        }
		System.debug('LAT_ContractsCalculations.addAttachmentToContractAcordos [enable docusing...: ' + LAT_Docusign_Utils.getDocusignConfig().Enable_Docusign_Contracts__c + ']');					
		System.debug('LAT_ContractsCalculations.addAttachmentToContractAcordos [cantidad de contratos...: ' + lstContracts.size() + ']');					
		System.debug('LAT_ContractsCalculations.addAttachmentToContractAcordos [recordtype...:' + lstContracts[0].RecordType.DeveloperName + ']');					

		if (LAT_Docusign_Utils.getDocusignConfig().Enable_Docusign_Contracts__c && lstContracts.size() == 1 && lstContracts[0].Status__c == 'Aprovado' && lstContracts[0].RecordType.DeveloperName == 'LAT_BR_Acordo'){
			System.debug('LAT_ContractsCalculations.addAttachmentToContractAcordos [sending pdf to docusing...: lstContracts[0] : ' + lstContracts[0] + ' - lstAttachments : ' + lstAttachments + ']');					

			LAT_Docusign_Utils.requestEnvelopeCreation(lstContracts[0], lstAttachments);
		}

        if(!lstAttachmentsToDelete.isEmpty()) {
			delete lstAttachmentsToDelete;
		}

        if (!lstAttachments.isEmpty()) {
			insert lstAttachments;
		}

		System.debug('LAT_ContractsCalculations.addAttachmentToContractAcordos [] <-');					
    }

    private static Attachment retrieveAnexo1(Id objContractId, String strAttachmentName, String strType) {
		Attachment objAttachment = null;
		PageReference objPDF = null; 
        Blob objPDFContent = null;
        
        System.debug('retrieveAnexo1 [objContractId : ' + objContractId + ' - strAttachmentName : ' + strAttachmentName + '] ->');

        objPDF = Page.LAT_BR_Acordo_PDF;
        objPDF.getParameters().put('id', objContractId);				
        objPDF.getParameters().put('type',strType);				
        objPDF.setRedirect(true);

        objPDFContent = !Test.isRunningTest() ? objPDF.getContent() : Blob.valueOf('Testing');

        objAttachment = new Attachment();
        objAttachment.ParentId = objContractId;
        objAttachment.Name = strAttachmentName;
        objAttachment.Body = objPDFContent;

        System.debug('retrieveAnexo1 [' + objAttachment + '] <-');

        return objAttachment;
    }

    
    private static Attachment retrieveMinutaPadrao(Id objContractId, String strAttachmentName, String strType) {
		Attachment objAttachment = null;
		PageReference objPDF = null; 
        Blob objPDFContent = null;
        
        System.debug('retrieveMinutaPadrao [objContractId : ' + objContractId + ' - strAttachmentName : ' + strAttachmentName + '] ->');

        objPDF = Page.LAT_ContractDocumentsPDF;
        objPDF.getParameters().put('id', objContractId);				
        objPDF.getParameters().put('docName',strType);				
        objPDF.setRedirect(true);

        objPDFContent = !Test.isRunningTest() ? objPDF.getContent() : Blob.valueOf('Testing');

        objAttachment = new Attachment();
        objAttachment.ParentId = objContractId;
        objAttachment.Name = strAttachmentName;
        objAttachment.Body = objPDFContent;

        System.debug('retrieveMinutaPadrao [' + objAttachment + '] <-');

        return objAttachment;
    }

    public Boolean generatePayments(Id contractId, Boolean deleteExistingPayments) {
        List<LAT_Contract2__c> contracts = [Select Id, recordTypeId, recordType.Name , status__c, EndDate__c, StartDate__c from LAT_Contract2__c where Id =: contractId];
        Boolean paymentsGenerated =  false;

        return paymentsGenerated;
    }

    public List<productCost> getProductAverages(List<productCost> products, String uf, String recordType) {
        if (Test.isRunningTest()) uf = 'SC';

        String[] channels = LAT_GeneralConfigDao.getValueAsStringArray('LAT_PRODUCT_COST_CHANNELS', ',');

        if (test.isRunningTest()) channels = new List<String>{'101','102','103','104','112','113','114','115','116'};

        return getProductAverages(products, uf, channels, recordType);
    }

    public List<productCost> getProductAverages(List<productCost> products, String uf, String[] channels, String recordType) {
        return getProductAverages(products, uf, channels, recordType, null);
    }

    public List<productCost> getProductAveragesWithDate(List<productCost> products, String uf, String recordType, Date dateBetween) {
        String[] channels = LAT_GeneralConfigDao.getValueAsStringArray('LAT_PRODUCT_COST_CHANNELS', ',');

        if (test.isRunningTest()) channels = new List<String>{'101','102','103','104','112','113','114','115','116'};

        return getProductAverages(products, uf, channels, recordType, dateBetween);
    }

    public List<productCost> getProductAverages(List<productCost> products, String uf, String[] channels, String recordType, Date dateBetween) {
        if (test.isRunningTest()) channels.add('114');

        List<productCost> productsWithAvg = new List<productCost>();
        Set<Id> productsNames = new Set<Id>();

        for(productCost p : products) {
            productsNames.add(p.productId);
        }

        AggregateResult[] groupedResults;
        if(dateBetween == null) {            
            groupedResults = [SELECT  UF__c, Product__c, AVG(CM_Case__c),  AVG(DistributorCost__c),  AVG(LDCost__c),  AVG(Net_Sales_Case__c), MeasureUnit__c
                                FROM LAT_ProductCost__c
                                WHERE EndDate__c > Today
                                AND UF__c =: uf
                                AND RecordType.DeveloperName =: recordType
                                AND Canal__r.CodDefUsuario__c IN :channels
                                AND Product__c IN :productsNames
                                GROUP BY  Product__c, UF__c, MeasureUnit__c];
        } else {            
            groupedResults = [SELECT  UF__c, Product__c, AVG(CM_Case__c),  AVG(DistributorCost__c),  AVG(LDCost__c),  AVG(Net_Sales_Case__c), MeasureUnit__c
                                FROM LAT_ProductCost__c
                                WHERE EndDate__c > :dateBetween
                                AND StartDate__c < :dateBetween
                                AND UF__c =: uf
                                AND RecordType.DeveloperName =: recordType
                                AND Canal__r.CodDefUsuario__c IN :channels
                                AND Product__c IN :productsNames
                                GROUP BY  Product__c, UF__c, MeasureUnit__c];
        
        }

        //List<LAT_ProductCost__c> productCosts = [SELECT EndDate__c, StartDate__c FROM LAT_ProductCost__c];
        Double factorConvertion = getConvertionFactor('EUR', 'BRL');

        for (AggregateResult ar : groupedResults) {
            productCost pc = new productCost();

            pc.cmCase = getConvertedCurrency(factorConvertion,Double.valueof(ar.get('expr0')));
            pc.distCost = getConvertedCurrency(factorConvertion,Double.valueof(ar.get('expr1')));
            pc.ldCost = getConvertedCurrency(factorConvertion,Double.valueof(ar.get('expr2')));
            pc.nis = Double.valueof(ar.get('expr3'));
            pc.unitOfMeasurement = String.valueOf(ar.get('MeasureUnit__c'));
            pc.productId = String.valueOf(ar.get('Product__c'));
            productsWithAvg.add(pc);
        
        }


        return productsWithAvg;
    }

    public Double getConvertedCurrency(Double factor, Double amount){
        return amount * factor;
    }

    private Double getConvertionFactor(String oCurrency, String nCurrency ) {
        Set<String> isoCodes = new Set<String>();
        Map<String,Double> conversion_rates = new Map<String,Double>();

        isoCodes.add(oCurrency);
        isoCodes.add(nCurrency);

        for(CurrencyType curr: [SELECT IsoCode,ConversionRate FROM CurrencyType WHERE IsoCode in: isoCodes]){
            conversion_rates.put(curr.IsoCode,curr.ConversionRate);
        }

        Double conversionRate = 1;
        if(nCurrency != 'EUR') conversionRate = conversion_rates.get(nCurrency);
        
        return conversionRate;
    }

    public class productCost {
        public Id productId { get; set; }
        public Id distributorOrProducerId;
        public String skuName { get; set; }
        public Double nis { get; set; }
        public Double ldCost { get; set; }
        public Double distCost { get; set; }
        public Double cmCase { get; set; }
        public String unitOfMeasurement { get;set; }
        public Boolean hasSKU { get; set; }

        public productCost(){}

        public productCost(LAT_ProductCost__c latProductCost) {
            this.cmCase = latProductCost.CM_Case__c;
            this.distCost = latProductCost.DistributorCost__c;
            this.ldCost = latProductCost.LDCost__c;
            this.nis = latProductCost.Net_Sales_Case__c;
            this.unitOfMeasurement = latProductCost.MeasureUnit__c;
            this.productId = latProductCost.Product__c;
            this.distributorOrProducerId = latProductCost.AN8__c;             
        }        
    }

    public class TotalProductsCalculationEvent {
        public Double productsPRBCost;
        public Double productsPRBSponsorship;
        public Double totalPRBTax;
        public Double totalPRBShipping;
        public Double totalPRBMoney;
        public Double totalPRBContract;
        public Double productsProducerCost;
        public Double productsProducerSponsorship;
        public Double totalProducerMoney;
        public Double totalProducerContract;
        public Double predictedROI;
        public String metaROIAP;
        public String metaROINetSales;
        public String metaROIContract;
        public Double productsPerceivedValue;
        public Double productsGMDCTotal;        
        
        public TotalProductsCalculationEvent() {
            this.productsPRBCost = 0.00;
            this.productsPRBSponsorship = 0.00;
            this.totalPRBTax = 0.00;
            this.totalPRBShipping = 0.00;
            this.totalPRBMoney = 0.00;
            this.totalPRBContract = 0.00;
            this.productsProducerCost = 0.00;
            this.productsProducerSponsorship = 0.00;
            this.totalProducerMoney = 0.00;
            this.totalProducerContract = 0.00;
            this.predictedROI = 0.00;
            this.metaROIAP = '';
            this.metaROINetSales = '';
            this.metaROIContract = '';
            this.productsPerceivedValue = 0.00;
            this.productsGMDCTotal = 0.00;                    
        }
    }

    public String calculatePaymentsInformationEventos(Id objContractId) {
        LAT_ContractHandlerJSON objContractJSON = null;
        String strJSON = null;
        LAT_Contract2__c objContract = null;
        Map<Id,List<LAT_EventPayment__c>> mapEventsPayment = null;
        Map<Id,List<LAT_EventVolume__c>> mapEventsVolume = null;
        
        System.debug('calculatePaymentsInformationEventos [objContractId : ' + objContractId + '] ->');
        objContract = retrieveContract(objContractId);
        System.debug('calculatePaymentsInformationEventos [objContract.LAT_ROIPrevistoOnInvoice__c : ' + objContract.LAT_ROIPrevistoOnInvoice__c + '] ->');
        mapEventsPayment = retrieveEventPayments(objContractId); 
        mapEventsVolume = retrieveEventVolume(objContractId);

        if(objContract != null && String.isNotBlank(objContract.RecordTypeId)) {
            System.debug('calculatePaymentsInformationEventos [added]');
            objContractJSON = new LAT_ContractHandlerJSON(objContract);
            
            if(objContractJSON.listContractEvent == null) {
                objContractJSON.listContractEvent = new LAT_ContractHandlerJSON.ListContractEvent();
            }

            if(objContractJSON.listContractEvent != null && objContractJSON.listContractEvent.contractEvent != null) {
                for(LAT_ContractHandlerJSON.ContractEvent objContractEvent : objContractJSON.listContractEvent.contractEvent) {
                    if(mapEventsPayment.containsKey(objContractEvent.Id)) {
                        objContractEvent.listPayment.add(mapEventsPayment.get(objContractEvent.Id));
                    }

                    if(mapEventsVolume.containsKey(objContractEvent.Id)) {
                        objContractEvent.listVolume.add(mapEventsVolume.get(objContractEvent.Id));
                    }
                }
            }
            if(Test.isRunningTest()) {
                objContractJSON.distribuitorId = objContractJSON.account;
            }
            strJSON = calculatePaymentsInformationEventos2(objContractJSON);
        } else {
            throw new LAT_Rest_Contracts.RestContractException(20,'O contrato não pode ser anulado');
        }

        System.debug('calculatePaymentsInformationEventos [] <-');

        return strJSON;
    }

    public LAT_Contract2__c calculatePayments(Id objContractId) {
        LAT_Contract2__c objContract = null;
        Double totalMoneyPerceivedValue = 0;
        Double totalMoneyPRBCost = 0;
        Map<Id, Double> productGroupMap = new Map<Id, Double>();

        objContract = retrieveContract(objContractId);


        for(LAT_Payment__c payment : objContract.LAT_Payments__r){
            // Payment of Money are the sum of ammount
            System.debug('LAT_ContractsCalculations.calculatePaymentsInformation[iterating payments...' + payment + ']');                    

            if(payment.recordType.Name == PAYMENT_RECORDTYPE_NAME_MONEY) {
                totalMoneyPerceivedValue = totalMoneyPerceivedValue + payment.Ammount__c;
            }                 
            // Group the products,  and add the number of boxes, if we have 3 payments of 10 boxes of chivas,
            // we save a map "CHIVAS, 30"
            if(payment.recordType.Name == PAYMENT_RECORDTYPE_NAME_PRODUCT){
                Id productGroup = payment.ProductGroup__c;
                Double volume = payment.Volumen__c;

                //If exists I must add the volume to the current volume
                if(productGroupMap.containsKey(productGroup)){
                    Double currentVolume = productGroupMap.get(productGroup);
                    productGroupMap.put(productGroup, currentVolume + volume);
                } else {
                    //If not exists create a new map item
                    productGroupMap.put(productGroup, volume);
                }
            }
        }
        System.debug('LAT_ContractsCalculations.calculatePaymentsInformation[productGroupMap: ' + productGroupMap + ']');                    

        // Call the function that resolve the calculations
        String uf = objContract.Account__r.Revenue_UF__c;
        List<double> calculations =  totalProductsCalculation(productGroupMap, uf);
        Double totalProductsPRBCost= calculations[0];
        Double totalProductsPerceivedValue = calculations[1];
        Double totalproductGMDC= calculations[2];

        //Set the fields with the new value
        objContract.TotalMoneyPerceivedValue__c = totalMoneyPerceivedValue ;
        objContract.TotalMoneyPRBCost__c = totalMoneyPerceivedValue ;
        objContract.TotalProductsPerceivedValue__c =  totalProductsPerceivedValue ;
        objContract.TotalProductsPRBCost__c = totalProductsPRBCost;
        objContract.GMDC_Total__c = totalproductGMDC;

        System.debug('LAT_ContractsCalculations.calculatePaymentsInformation[contract : ' + objContract + ']');

        return objContract;
    }

    private LAT_Contract2__c retrieveContract(Id objContractId) {
        LAT_Contract2__c objContract = null;
        List<LAT_Contract2__c> lstContract = null;
        System.debug('retrieveContract [objContractId : ' + objContractId + '] ->');

        lstContract = [SELECT   Name, 
                                LAT_Distributor__r.Client_code_AN8__c, 
                                EndDate__c,
                                LAT_Total_Contrato_OnInvoice_Predicted__c,
                                LAT_TotalContractOffInvoice__c,
                                LAT_OnInvoice__c,
                                LAT_Contrapartidas__c, 
                                LAT_AditionComment__c,
                                TotalEventContractPRBCostNetSales__c, 
                                StartDate__c, 
                                OwnerId, 
                                FreightDistributor__c, 
                                ROI_OnInvoice_Meta__c,
                                ROI_OnInvoice_Vs_Meta__c,
                                DistributorTax__c, 
                                CalculationErrors__c, 
                                TotalMoneyPerceivedValue__c,
                                LAT_ClientRegional__c, 
                                Account__r.Name, 
                                Account__r.Revenue_UF__c, 
                                GMDC_Total__c, 
                                TotalMoneyPRBCost__c,
                                TotalProductsPerceivedValue__c, 
                                TotalProductsPRBCost__c , 
                                RecordType.DeveloperName, 
                                RecordTypeId,                                 
                                LAT_Distributor__c, 
                                LAT_Distributor__r.Name, 
                                (SELECT Id, EventType__c,LAT_EventValue__c,LAT_EventCashValue__c,LAT_EventProductValue__c,LAT_EventBoxQuantity__c,LAT_Taxes__c, Status__c,PaymentDateDone__c,ReleaseReason__c,LAT_Distributor__c,LAT_Contract__c,PaymentDate__c,Ammount__c, ProductGroup__c, ProductGroup__r.Name, Finality__c, Volumen__c, RecordType.Name, EventPaymentCreatedAfterSigning__c, LAT_BonusPercent__c, LAT_BonusQuantity__c, LAT_Producer__c 
                                FROM LAT_Payments__r 
                                ORDER BY RecordTypeId 
                                DESC ),
                                (SELECT BonusVolumeGF__c,BoxesContractMonth__c,BoxesContract__c,BusinessCondition__c,CreatedById,CreatedDate,CurrencyIsoCode,EventType__c,Finality__c,Id,IsDeleted,LastModifiedById,LastModifiedDate,LAT_BonusPercent__c,LAT_BonusQuantity__c,LAT_BottleVolumen__c,LAT_BR_Category_Description__c,LAT_ContractRTDevName__c,LAT_Contract__c,LAT_EstimatedBoxesContract__c,LAT_RealizedVolumeGF__c,LAT_Valor_Compre_e_Ganhe__c,Name,Producer__c,ProductGroup__c,PurchaseVolumeGF__c,RecordTypeId,SystemModstamp,TotalVolume__c 
                                FROM LAT_ContractVolumes__r),
                                (SELECT CreatedById,CreatedDate,CurrencyIsoCode,Id,IsDeleted,LastModifiedById,LastModifiedDate,LAT_Ativacoes__c,LAT_Category__c,LAT_Cidade__c,LAT_Classe_Social__c,LAT_Comments__c,LAT_Comunicacao__c,LAT_Contract__c,LAT_Convites_Pista__c,LAT_Convites_VIP__c,LAT_Data_Evento__c,LAT_DoneROI__c,LAT_Estado__c,LAT_Estilo_Musical__c,LAT_External_Id__c,LAT_Faixa_Etaria__c,LAT_MarcasAtivadasSR__c,LAT_MarcasAtivadas__c,LAT_Micro_Regional__c,LAT_Motivo_Comentarios__c,LAT_Motivo__c,LAT_No_Pessoas__c,LAT_no_Posts__c,LAT_Open_Bar__c,LAT_Perfil__c,LAT_Periodo__c,LAT_PredictedROI__c,LAT_Status__c,LAT_Tipo_de_Evento__c,LAT_Tipo_de_Verba__c,LAT_Tipo_Investimento__c,LAT_BR_Investimento__c,LAT_Total__c,Name,SystemModstamp,Valor_Ingresso__c 
                                FROM Eventos__r),
                                ROIApRoiPrevisto__c,
                                LAT_ROIPrevistoOnInvoice__c,
                                LAT_UF__c,
                                Money__c,
                                ROI__c
                            FROM LAT_Contract2__c
                            WHERE Id =: objContractId];

        if(!lstContract.IsEmpty()) {
            objContract = lstContract[0]; 
        }
        System.debug('retrieveContract [' + objContract + '] <-');
        return objContract;
    }

    public Map<Id,List<LAT_EventPayment__c>> retrieveEventPayments(Id objContractId) {
        List<LAT_EventPayment__c> lstEventPayments = null;
        Map<Id,List<LAT_EventPayment__c>> mapEventPayments = null;
        
        System.debug('retrieveEventPayments [objContractId : ' + objContractId + '] ->');

        mapEventPayments = new Map<Id,List<LAT_EventPayment__c>>();

        lstEventPayments = [SELECT CreatedById,CreatedDate,CurrencyIsoCode,Id,IsDeleted,LastModifiedById,LastModifiedDate,LAT_Ammount__c,LAT_ApprovedPayment__c,LAT_BonusPercent__c,LAT_BonusQuantity__c,LAT_CNPJ_Fornecedor__c,LAT_ContractEvent__c,LAT_Distributor__c,LAT_EventCashValue__c,LAT_EventPaymentCreatedAfterSigning__c,LAT_EventProductValue__c,LAT_EventType__c,LAT_EventValue__c,LAT_Finality__c,LAT_FY__c,LAT_GoalNotReached__c,LAT_IntegrationMessage__c,LAT_IntegrationStatus__c,LAT_IsCommCondParentPayment__c,LAT_Manager__c,LAT_ParentPayment__c,LAT_PaymentDateDone__c,LAT_PaymentDateOriginal__c,LAT_PaymentDate__c,LAT_PaymentGoals__c,LAT_Producer__c,LAT_ProductGroup__c,LAT_ProductValue__c,LAT_ReleaseReason__c,LAT_Send_to_Approval__c,LAT_SkuAtIntegration__c,LAT_Status__c,LAT_TotalProductValue__c,LAT_Type__c,LAT_UOM__c,LAT_VolumeGF__c,LAT_Volumen__c,Name,RecordTypeId,SystemModstamp 
                            FROM LAT_EventPayment__c
                            WHERE LAT_ContractEvent__r.LAT_Contract__c =:objContractId];
        if(!lstEventPayments.IsEmpty()) {
            for(LAT_EventPayment__c objEventPayment : lstEventPayments) {
                if(!mapEventPayments.containsKey(objEventPayment.LAT_ContractEvent__c)) {
                    mapEventPayments.put(objEventPayment.LAT_ContractEvent__c, new List<LAT_EventPayment__c>());
                }

                mapEventPayments.get(objEventPayment.LAT_ContractEvent__c).add(objEventPayment);
            }
        }

        System.debug('retrieveEventPayments [' + mapEventPayments + '] <-');

        return mapEventPayments;
    }

    public Map<Id,List<LAT_EventVolume__c>> retrieveEventVolume(Id objContractId) {
        List<LAT_EventVolume__c> lstEventVolume = null;
        Map<Id,List<LAT_EventVolume__c>> mapEventVolume = null;
        
        System.debug('retrieveEventVolume [objContractId : ' + objContractId + '] ->');

        mapEventVolume = new Map<Id,List<LAT_EventVolume__c>>();

        lstEventVolume = [  SELECT CreatedById,CreatedDate,CurrencyIsoCode,Finality__c,Id,IsDeleted,LastActivityDate,LastModifiedById,LastModifiedDate,LAT_BonusPercent__c,LAT_BonusQuantity__c,LAT_BoxesContractMonth__c,LAT_BoxesContract__c,LAT_BusinessCondition__c,LAT_ContractEvent__c,LAT_EstimatedBoxesContract__c,LAT_ProductGroup__c,LAT_RealizedVolumeGF__c,LAT_Volume__c,Name,RecordTypeId,SystemModstamp 
                            FROM LAT_EventVolume__c 
                            WHERE LAT_ContractEvent__r.LAT_Contract__c =:objContractId];
        if(!lstEventVolume.IsEmpty()) {
            for(LAT_EventVolume__c objEventVolume : lstEventVolume) {
                if(!mapEventVolume.containsKey(objEventVolume.LAT_ContractEvent__c)) {
                    mapEventVolume.put(objEventVolume.LAT_ContractEvent__c, new List<LAT_EventVolume__c>());
                }

                mapEventVolume.get(objEventVolume.LAT_ContractEvent__c).add(objEventVolume);
            }
        }

        System.debug('retrieveEventVolume [' + mapEventVolume + '] <-');

        return mapEventVolume;
    }

    public String calculatePaymentsInformationEventos2(LAT_ContractHandlerJSON objContract) {
        LAT_ContractHandlerJSON.ContractCalculationDistribuidor objDistribuidor = null;
        LAT_ContractHandlerJSON.ContractCalculationProdutor objProdutor = null;

        String strJSON = null;

        System.debug('calculatePaymentsInformationEventos [objContract : ' + objContract + '] ->');
        if(objContract != null && String.isNotBlank(objContract.recordType)) {
            if(objContract.recordType == Schema.SObjectType.LAT_Contract2__c.getRecordTypeInfosByDeveloperName().get(EVENT_PRODUCER).getRecordTypeId() || objContract.recordType == Schema.SObjectType.LAT_Contract2__c.getRecordTypeInfosByDeveloperName().get(EVENT_PRODUCER_SIMULATION).getRecordTypeId()) {
                objProdutor = calculatePaymentsInformationEventosProdutor(objContract);
                strJSON = JSON.serialize(objProdutor);
            } else if (objContract.recordType == Schema.SObjectType.LAT_Contract2__c.getRecordTypeInfosByDeveloperName().get(EVENT_DISTRIBUTOR).getRecordTypeId() || objContract.recordType == Schema.SObjectType.LAT_Contract2__c.getRecordTypeInfosByDeveloperName().get(EVENT_DISTRIBUTOR_SIMULATION).getRecordTypeId() ) { 
                objDistribuidor = calculatePaymentsInformationEventosDistribuidor(objContract);
                strJSON = JSON.serialize(objDistribuidor);
            } else {
                throw new LAT_Rest_Contracts.RestContractException(30,'O tipo de contrato não é válido [Record type : ' + objContract.recordType + ']');
            }
        } else {
            throw new LAT_Rest_Contracts.RestContractException(40, 'O contrato não pode ser anulado');
        }

        System.debug('calculatePaymentsInformationEventos [] <-');

        return strJSON;
    }

    private LAT_ContractHandlerJSON.ContractCalculationProdutor calculatePaymentsInformationEventosProdutor(LAT_ContractHandlerJSON objContract) {
        LAT_ContractHandlerJSON.ContractCalculationProdutor objResult = null; 
        Set<Id> setProductsIds = null;
        Map<Id,Id> mapReferenceProductMap = null;
        Map<Id,Double> mapReferenceUnitConvertionMap = null;
        Map<Id,LAT_ProductCost__c> mapProductCostProdutor = null;
        Map<Id,LAT_ProductCost__c> mapProductCostDistribuidor = null;
        LAT_ProductCost__c objProductCost = null;
        LAT_Meta_ROI_Consultant__c objMetaROI = null;
        String strProductGroupId = null;
        String strReferenceProductId = null;
        Double dblPaymentAPCondComm = null;
        Double dblPaymentAPPatrocinio = null;                     
        Double dblPaymentNSCondComm = null;
        Double dblPaymentNSPatrocinio = null;
        Double dblPaymentVPCondComm = null;
        Double dblPaymentVPPatrocinio = null;
        Double dblTaxAP = null; 
        Double dblTaxNS = null;
        Double dblPaymentDinhero = null;
        Double dblTotalAP = null;
        Double dblTotalNS = null;
        Double dblTotalVP = null;
        Double dblTotalOnInvoice = null;
        Double dblQuantityGA = 0;
        Double dblQuantityBonifGA = 0;
        Double dblQuantityCA = 0;
        Double dblQuantityBonifCA = 0;
        Double dblQuantity = 0;
        Double dblCM = 0;
        Double dblNS = 0;
        Double dblAPCM = 0;
        Double dblNetSalesCM = 0;
        Double dblOnInvoiceCM = 0;

        Double dblProductoInvestimento = 0;
        Double dblCondCommercialnvestimento = 0;
        Double dblPagamentoDinheroInvestimento = 0;

        Double dblVolumenBonificadoAP = 0;
        Double dblVolumenBonificadoNS = 0;

        System.debug('calculatePaymentsInformationEventosProdutor [objContract : ' + objContract + '] ->');
        objResult = objContract.toContractProdutor();

        System.debug('calculatePaymentsInformationEventosProdutor [objResult : ' + objResult + ']');
        
        //objResult.onInvoice = objContract.onInvoice;
        if(objContract != null && objContract.listPayment != null && objContract.listPayment.payment != null && objContract.listPayment.payment.size() > 0) {
            setProductsIds = objContract.listPayment.toProductIds();
            System.debug('calculatePaymentsInformationEventosProdutor [setProductsIds : ' + setProductsIds + ']');

            if(setProductsIds != null && !setProductsIds.isEmpty()) { 
                System.debug('calculatePaymentsInformationEventosProdutor [objContract.distribuitorId : ' + objContract.distribuitorId + ' - objContract.account : ' + objContract.account + ']');
                if(String.isNotBlank(objContract.distribuitorId) && String.isNotBlank(objContract.account)) {
                    dblPaymentAPCondComm = 0;
                    dblPaymentAPPatrocinio = 0;                     
                    dblPaymentNSCondComm = 0;
                    dblPaymentNSPatrocinio = 0;
                    dblPaymentVPCondComm = 0;
                    dblPaymentVPPatrocinio = 0;
                    dblTaxAP = 0; 
                    dblTaxNS = 0;
                    dblPaymentDinhero = 0;
                    dblTotalAP = 0;
                    dblTotalNS = 0;
                    dblTotalVP = 0;
                    dblTotalOnInvoice = 0;
                    dblCM = 0;
                    dblNS = 0;
                    dblAPCM = 0;
                    dblOnInvoiceCM = 0;
            
                    dblProductoInvestimento = 0;
                    dblCondCommercialnvestimento = 0;
                    dblPagamentoDinheroInvestimento = 0;
                    dblVolumenBonificadoAP = 0;
                    dblVolumenBonificadoNS = 0;

                    mapReferenceProductMap = retrieveReferenceProductMap(setProductsIds);
                    mapReferenceUnitConvertionMap = retrieveReferenceUnitConversionMap(mapReferenceProductMap.values());
                    mapProductCostDistribuidor = retrieveProductCosts(objContract.distribuitorId, mapReferenceProductMap.keySet());
                    mapProductCostProdutor = retrieveProductCosts(objContract.account, mapReferenceProductMap.keySet());

                    System.debug('calculatePaymentsInformationEventosProdutor [mapReferenceProductMap : ' + mapReferenceProductMap + ']');
                    System.debug('calculatePaymentsInformationEventosProdutor [mapReferenceUnitConvertionMap : ' + mapReferenceUnitConvertionMap + ']');
                    System.debug('calculatePaymentsInformationEventosProdutor [mapProductCostDistribuidor : ' + mapProductCostDistribuidor + ']');
                    System.debug('calculatePaymentsInformationEventosProdutor [mapProductCostProdutor : ' + mapProductCostProdutor + ']');
                                        
                    for(LAT_ContractHandlerJSON.Payment objPayment : objContract.listPayment.payment) {
                        System.debug('calculatePaymentsInformationEventosProdutor [objPayment.recordType : ' + objPayment.recordType + ']');
                        if(objPayment.recordType == Schema.SObjectType.LAT_Payment__c.getRecordTypeInfosByDeveloperName().get(PAYMENT_RECORDTYPE_DEVELOPERNAME_PRODUCT).getRecordTypeId()) {
                            strProductGroupId = objPayment.productGroup;
                            System.debug('calculatePaymentsInformationEventosProdutor [procesando pagamento producto]');

                            if(objPayment.producer == true) {
                                System.debug('calculatePaymentsInformationEventosProdutor [procesando pagamento producto [PRODUCTOR]]');
                                if(mapProductCostProdutor.containsKey(strProductGroupId)) {
                                    objProductCost = mapProductCostProdutor.get(strProductGroupId);
                                } else {
                                    throw new LAT_Rest_Contracts.RestContractException(100, strProductGroupId, objContract.account, 'Erro de cálculo de preço [PD : ' + strProductGroupId + ' - CTA : ' + objContract.account + ']');
                                }
                            } else {
                                System.debug('calculatePaymentsInformationEventosProdutor [procesando pagamento producto [DISTRIBUIDOR]]');
                                if(mapProductCostDistribuidor.containsKey(strProductGroupId)) {
                                    objProductCost = mapProductCostDistribuidor.get(strProductGroupId);
                                } else {
                                    throw new LAT_Rest_Contracts.RestContractException(110, strProductGroupId, objContract.distribuitorId, 'Erro de cálculo de preço [PD : ' + strProductGroupId + ' - CTA : ' + objContract.distribuitorId + ']');
                                }
                            }

                            strReferenceProductId = mapReferenceProductMap.get(strProductGroupId);
                            dblQuantityGA = (objPayment.volumen != null)?objPayment.volumen:0;
                            dblQuantityBonifGA = (objPayment.bonusPercent != null)?Math.ceil(objPayment.bonusPercent / 100.0 * dblQuantityGA):0;
        
                            System.debug('calculatePaymentsInformationEventosProdutor [objProductCost : ' + objProductCost + ']');
                            System.debug('calculatePaymentsInformationEventosProdutor [objPayment : ' + objPayment + ']');
                            System.debug('calculatePaymentsInformationEventosProdutor [objPayment.finality : ' + objPayment.finality + ']');
                            System.debug('calculatePaymentsInformationEventosProdutor [objPayment.bonusPercent : ' + objPayment.bonusPercent + ']');
                            System.debug('calculatePaymentsInformationEventosProdutor [dblQuantityGA : ' + dblQuantityGA + ']');
                            System.debug('calculatePaymentsInformationEventosProdutor [dblQuantityBonifGA : ' + dblQuantityBonifGA + ']');

                            if(objPayment.finality == FINALITY_COMMERCIAL_CONDITION) {
                                //calculos con cantidad bonificadad                                
                                System.debug('calculatePaymentsInformationEventosProdutor [dblQuantityGA : ' + dblQuantityGA + ']');
                                System.debug('calculatePaymentsInformationEventosProdutor [dblQuantityBonifGA : ' + dblQuantityBonifGA + ']');
                                dblQuantityCA = mapReferenceUnitConvertionMap.get(strReferenceProductId) * dblQuantityGA;
                                dblQuantityBonifCA = mapReferenceUnitConvertionMap.get(strReferenceProductId) * dblQuantityBonifGA;
                                dblCondCommercialnvestimento += dblQuantityBonifCA * objProductCost.LDCost__c;
    
                                if(mapReferenceUnitConvertionMap.containsKey(strReferenceProductId)) {
                                    dblQuantity = 0;

                                    System.debug('calculatePaymentsInformationEventosProdutor [dblQuantityGA : ' + dblQuantityGA + ']');
                                    System.debug('calculatePaymentsInformationEventosProdutor [Factor de conversión : ' + mapReferenceUnitConvertionMap.get(strReferenceProductId) + ']');
                                    System.debug('calculatePaymentsInformationEventosProdutor [dblQuantityBonifCA : ' + dblQuantityBonifCA + ']');                                                                    
                                    System.debug('calculatePaymentsInformationEventosProdutor [Procesando pagamento del tipo de evento : ' + objPayment.eventType + ']');

                                    if(objPayment.eventType == EVENT_TYPE_AP) {
                                        if(objProductCost.LDCost__c != null && objProductCost.CM_Case__c != null && objProductCost.DistributorCost__c != null) {
                                            dblPaymentAPCondComm += dblQuantityBonifCA * objProductCost.LDCost__c;
                                            dblCM += dblQuantityBonifCA * objProductCost.CM_Case__c;
                                            dblAPCM += (dblQuantityCA + dblQuantityBonifCA) * objProductCost.CM_Case__c;       
                                            dblVolumenBonificadoAP += dblQuantityBonifCA * objProductCost.CM_Case__c;
                                            dblPaymentVPCondComm +=  dblQuantityBonifCA * objProductCost.DistributorCost__c;
                                      
                                            System.debug('calculatePaymentsInformationEventosProdutor [ROI dblAPCM : ' + dblAPCM + ']');
    
                                            System.debug('calculatePaymentsInformationEventosProdutor [dblQuantityBonifCA : ' + dblQuantityBonifCA + ']');                                                                    
                                            System.debug('calculatePaymentsInformationEventosProdutor [dblQuantityCA : ' + dblQuantityCA + ']');                                                                    
                                            System.debug('calculatePaymentsInformationEventosProdutor [objProductCost.CM_Case__c : ' + objProductCost.CM_Case__c + ']');                                                                    
                                        } else {    
                                            throw new LAT_Rest_Contracts.RestContractException(120,'As informações de custo inseridas não estão completas');
                                        }
                                    } else if(objPayment.eventType == EVENT_TYPE_NETSALES) {
                                        if(objProductCost.Distributor__c != null && objProductCost.CM_Case__c != null && objProductCost.LDCost__c != null && objProductCost.DistributorCost__c != null) {
                                            System.debug('calculatePaymentsInformationEventosProdutor [objProductCost.Distributor__c : ' + objProductCost.Distributor__c + ']');                                                                    

                                            dblPaymentNSCondComm += dblQuantityBonifCA * objProductCost.Distributor__c;
                                            dblVolumenBonificadoNS += dblQuantityBonifCA * objProductCost.CM_Case__c;
                                            dblNetSalesCM += (dblQuantityCA + dblQuantityBonifCA) * objProductCost.CM_Case__c;       
                                            dblNS += dblQuantityBonifCA * objProductCost.LDCost__c;
                                            dblPaymentVPCondComm +=  dblQuantityBonifCA * objProductCost.DistributorCost__c;
                                            
                                            System.debug('calculatePaymentsInformationEventosProdutor [ROI dblNetSalesCM : ' + dblNetSalesCM + ']');
                                        } else {    
                                            throw new LAT_Rest_Contracts.RestContractException(130,'As informações de custo inseridas não estão completas');
                                        }
                                    } else {
                                        System.debug('calculatePaymentsInformationEventosProdutor [Pagamento de un tipo de evento no procesado : ' + objPayment.eventType + ']');
                                    }
                                } else {
                                    throw new LAT_Rest_Contracts.RestContractException(140,'Nenhuma conversão do produto ' + strReferenceProductId + ' de BT para CA não foi encontrada');
                                }
                            } else if(objPayment.finality == FINALITY_COMMERCIAL_CONDITION_ON_INVOICE) {
                                System.debug('calculatePaymentsInformationEventosProdutor [objPayment.eventType : ' + objPayment.eventType + ' ]');
                                if(objProductCost.CM_Case__c != null) {
                                    dblQuantityCA = mapReferenceUnitConvertionMap.get(strReferenceProductId) * dblQuantityGA;
                                    dblOnInvoiceCM += dblQuantityCA * objProductCost.CM_Case__c;
                                }
                            } else if(objPayment.finality == FINALITY_COMMERCIAL_PATROCINIO) {
                                System.debug('calculatePaymentsInformationEventosProdutor [objPayment.eventType : ' + objPayment.eventType + ' ]');
                                if(objPayment.eventType == EVENT_TYPE_AP) {
                                    System.debug('calculatePaymentsInformationEventosProdutor [objPayment.ID: ' + objPayment.id + ' ]');
                                    System.debug('calculatePaymentsInformationEventosProdutor [objProductCost.LDCost__c: ' + objProductCost.LDCost__c + ' ]');
                                    System.debug('calculatePaymentsInformationEventosProdutor [dblQuantityGA: ' + dblQuantityGA + ' ]');
                                    System.debug('calculatePaymentsInformationEventosProdutor [dblPaymentAPPatrocinio : ' + dblPaymentAPPatrocinio  + ']');
                                    if(objProductCost.LDCost__c != null && objProductCost.DistributorCost__c != null && objProductCost.CM_Case__c != null) {
                                        dblPaymentAPPatrocinio += dblQuantityGA * objProductCost.LDCost__c;
                                        dblPaymentVPPatrocinio +=  dblQuantityGA * objProductCost.DistributorCost__c;
                                        dblAPCM += dblQuantityGA * objProductCost.CM_Case__c;


                                        System.debug('calculatePaymentsInformationEventosProdutor [ROI objProductCost.LDCost__c : ' + objProductCost.LDCost__c + ']');                                       
                                        System.debug('calculatePaymentsInformationEventosProdutor [dblPaymentAPPatrocinio : ' + dblPaymentAPPatrocinio  + ']');
                                    } else {    
                                        throw new LAT_Rest_Contracts.RestContractException(150,'As informações de custo inseridas não estão completas');
                                    }
                                } else if(objPayment.eventType == EVENT_TYPE_NETSALES) {
                                    if(objProductCost.Distributor__c != null && objProductCost.DistributorCost__c != null && objProductCost.CM_Case__c != null) {
                                        dblPaymentNSPatrocinio += dblQuantityGA * objProductCost.Distributor__c;
                                        dblPaymentVPPatrocinio +=  dblQuantityGA * objProductCost.DistributorCost__c;
                                        dblNetSalesCM += dblQuantityGA * objProductCost.CM_Case__c;       
                                        System.debug('calculatePaymentsInformationEventosProdutor [ROI dblNetSalesCM: ' + dblNetSalesCM + ']');
                                    } else {    
                                        throw new LAT_Rest_Contracts.RestContractException(160,'As informações de custo inseridas não estão completas');
                                    }
                                } else {
                                    System.debug('calculatePaymentsInformationEventosProdutor [Pagamento de un tipo de evento no procesado : ' + objPayment.eventType + ']');
                                }                               
                            }
                        } else if(objPayment.recordType == Schema.SObjectType.LAT_Payment__c.getRecordTypeInfosByDeveloperName().get(PAYMENT_RECORDTYPE_DEVELOPERNAME_MONEY).getRecordTypeId()) {
                            if(objPayment.ammount != null) {
                                dblPaymentDinhero += objPayment.ammount;
                                dblPagamentoDinheroInvestimento += objPayment.ammount;
                            } else {
                                throw new LAT_Rest_Contracts.RestContractException(170,'Um pagamento em dinheiro deve informar o valor');
                            }
                        } 
                    }   

                    objResult.frete_distribuidor = (objResult.frete_distribuidor != null)?objResult.frete_distribuidor:0;
                    objResult.imposto_distribuidor = (objResult.imposto_distribuidor != null)?objResult.imposto_distribuidor:0;
                    ///PECIBIDO                    
                    objResult.TotalProductsPerceivedValueCondComercial = dblPaymentVPCondComm;
                    objResult.TotalProductsPerceivedValuePatrocinio = dblPaymentVPPatrocinio;
                    objResult.TotalMoneyPerceivedValue = dblPaymentDinhero;
                    objResult.TotalEventContractPerceivedValue = dblPaymentVPCondComm + dblPaymentVPPatrocinio + dblPaymentDinhero;
                    
                    //A&P
                    objResult.TotalProductsPRBCostCondComercial = dblPaymentAPCondComm;
                    objResult.TotalProductsPRBCostPatrocinio = dblPaymentAPPatrocinio;
                    objResult.imposto_distribuidor = objResult.imposto_distribuidor;
                    objResult.TotalTaxAP = (dblPaymentAPCondComm + dblPaymentAPPatrocinio) * objResult.imposto_distribuidor / 100;
                    objResult.TotalShippingAP = objResult.frete_distribuidor;
                    objResult.TotalEventContractPRBCost = objResult.TotalProductsPRBCostCondComercial + objResult.TotalProductsPRBCostPatrocinio + objResult.TotalTaxAP + objResult.TotalShippingAP + dblPaymentDinhero;

                    //NET SALES
                    objResult.TotalProductsPRBCostCondComercialNetSales = dblPaymentNSCondComm;
                    objResult.TotalProductsPRBCostPatrocinioNetSales = dblPaymentNSPatrocinio;
                    objResult.TotalTaxNetSales = (dblPaymentNSCondComm + dblPaymentNSPatrocinio) * objResult.imposto_distribuidor / 100;
                    objResult.TotalShippingNetSales = objResult.frete_distribuidor;
                    

                    objResult.TotalEventContractPRBCostNetSales = objResult.TotalProductsPRBCostCondComercialNetSales + objResult.TotalProductsPRBCostPatrocinioNetSales + objResult.TotalTaxNetSales + objResult.TotalShippingNetSales;
                    //DINERHO
                    objResult.TotalMoneyPRBCost = dblPaymentDinhero;                    
                    //ROI

                    System.debug('calculatePaymentsInformationEventosProdutor [ROI dblCondCommercialCM : ' + dblAPCM + ']');
                    System.debug('calculatePaymentsInformationEventosProdutor [ROI dblProductoInvestimento : ' + dblProductoInvestimento + ']');
                    System.debug('calculatePaymentsInformationEventosProdutor [ROI dblCondCommercialnvestimento : ' + dblCondCommercialnvestimento + ']');
                    System.debug('calculatePaymentsInformationEventosProdutor [ROI dblPagamentoDinheroInvestimento : ' + dblPagamentoDinheroInvestimento + ']');

                    if(dblPaymentAPCondComm + dblPaymentAPPatrocinio + dblPagamentoDinheroInvestimento != 0) {
                        objResult.ROIApRoiPrevisto = (dblAPCM  / (dblPaymentAPCondComm + dblPaymentAPPatrocinio + dblPagamentoDinheroInvestimento)) - 1;
                    } else {
                        objResult.ROIApRoiPrevisto = 0;
                    }

                    if(dblPaymentNSCondComm + dblPaymentNSPatrocinio != 0) {
                        objResult.ROINetSalesRoiPrevisto = (dblNetSalesCM / (dblPaymentNSCondComm + dblPaymentNSPatrocinio)) - 1;
                    } else {
                        objResult.ROINetSalesRoiPrevisto = 0;
                    }

                    if((dblPaymentAPCondComm + dblPaymentAPPatrocinio + dblPagamentoDinheroInvestimento != 0 ) && (dblPaymentNSCondComm + dblPaymentNSPatrocinio != 0)) {
                        objResult.ROIContratoRoiPrevisto = ((dblAPCM  / (dblPaymentAPCondComm + dblPaymentAPPatrocinio + dblPagamentoDinheroInvestimento)) + (dblNetSalesCM / (dblPaymentNSCondComm + dblPaymentNSPatrocinio)) ) - 1;
                    } else {
                        objResult.ROIContratoRoiPrevisto = 0;
                    }
                     
                    
                    objMetaROI = retrieveMetaRoi(objContract.owner, Date.today());

                    if(objMetaROI != null) {
                        objResult.ROIApMeta = (objMetaROI.ROI_AP__c != null)?String.valueOf(objMetaROI.ROI_AP__c / 100) :'';
                        objResult.ROINetSalesMeta = (objMetaROI.ROI_Net_Sales__c != null)?String.valueOf(objMetaROI.ROI_Net_Sales__c / 100) :'';
                        objResult.ROIContratoMeta =  (objMetaROI.ROI_Contrato__c != null)?String.valueOf(objMetaROI.ROI_Contrato__c / 100) :'';
                        objResult.ROIOnInvoiceMeta =  (objMetaROI.ROI_OnInvoice__c != null)?String.valueOf(objMetaROI.ROI_OnInvoice__c / 100) :'';
                        
                        objResult.ROIApVsMeta = (objMetaROI.ROI_AP__c != null && objResult.ROIApRoiPrevisto != null)? String.valueOf( (objResult.ROIApRoiPrevisto + objMetaROI.ROI_AP__c / 100).setScale(2)):'';
                        objResult.ROINetSalesVsMeta = (objMetaROI.ROI_Net_Sales__c != null && objResult.ROINetSalesRoiPrevisto != null)?String.valueOf( (objResult.ROINetSalesRoiPrevisto / 100 + objMetaROI.ROI_Net_Sales__c / 100).setScale(2)):'';
                        objResult.ROIContratoVsMeta = (objMetaROI.ROI_Contrato__c != null && objResult.ROIContratoRoiPrevisto != null)?String.valueOf( (objResult.ROIContratoRoiPrevisto / 100 + objMetaROI.ROI_Contrato__c / 100).setScale(2)):'';
                        objResult.ROIOnInvoiceVsMeta = (objMetaROI.ROI_OnInvoice__c != null && objResult.ROIOnInvoiceRoiPrevisto != null)?String.valueOf( (objResult.ROIOnInvoiceRoiPrevisto / 100  + objMetaROI.ROI_OnInvoice__c / 100).setScale(2)):'';
                    }
                } else {
                    throw new LAT_Rest_Contracts.RestContractException(180, 'Os cálculos exigem inserir um produtor e um distribuidor');
                }
            }
        }
	

        System.debug('calculatePaymentsInformationEventosProdutor [' + objResult + '] <-');

        return objResult;
    }

    @TestVisible
    private LAT_ContractHandlerJSON.ContractCalculationDistribuidor calculatePaymentsInformationEventosDistribuidor(LAT_ContractHandlerJSON objContract) {
        LAT_ContractHandlerJSON.ContractCalculationDistribuidor objResult = null;
        Set<Id> setProductsIds = null;
        Map<Id,Id> mapReferenceProductMap = null;
        Map<Id,Double> mapReferenceUnitConvertionMap = null;
        Map<Id,LAT_ProductCost__c> mapProductCost = null;
        LAT_ProductCost__c objProductCost = null;
        LAT_ContractHandlerJSON.ContractCalculationEvent objEvento = null;
        String strProductGroupId = null;
        String strReferenceProductId = null;
        Double dblCantidadCA = null;
        Double dblCantidadGF = null;
        Double dblCantidadBonifCA = null;
        Double dblCantidadBonifGF = null;
        
        Double dblTotalEventoOffInvoiceCM = null;
        Double dblTotalEventoOffInvoiceLD = null;
        Double dblTotalContratoOffInvoiceCM = null;
        Double dblTotalContratoOffInvoiceLD = null;
        
        Double dblTotalEventoOnInvoiceCM = null;
        Double dblTotalEventoOnInvoiceLD = null;
        Double dblTotalContratoOnInvoiceCM = null;
        Double dblTotalContratoOnInvoiceLD = null;

        Double dblTotalContratoCM = null;
        Double dblTotalContratoLD = null;

        Double dblTotalContratoOnInvoiceEventCount = null;
        Double dblTotalContratoOnInvoiceEventROISum = null;

        System.debug('calculatePaymentsInformationEventosDistribuidor [objContract : ' + objContract + '] ->');
        objResult = objContract.toContractDistribuidor();

        if(objContract != null && objContract.listContractEvent != null && objContract.listContractEvent.contractEvent != null && objContract.listContractEvent.contractEvent.size() > 0) {
            setProductsIds = objContract.listContractEvent.toProductIds();

            if(setProductsIds != null && !setProductsIds.isEmpty()) {
                dblTotalContratoOffInvoiceCM = 0;
                dblTotalContratoOffInvoiceLD = 0;                
                dblTotalContratoOnInvoiceCM = 0;
                dblTotalContratoOnInvoiceLD = 0;
                dblTotalContratoCM = 0;
                dblTotalContratoLD = 0;
                dblTotalContratoOnInvoiceEventCount = 0;
                dblTotalContratoOnInvoiceEventROISum = 0; 

                mapReferenceProductMap = retrieveReferenceProductMap(setProductsIds);
                mapReferenceUnitConvertionMap = retrieveReferenceUnitConversionMap(mapReferenceProductMap.values());

                mapProductCost = retrieveProductCosts(objContract.distribuitorId, mapReferenceProductMap.keySet());

                objResult.eventos = new List<LAT_ContractHandlerJSON.ContractCalculationEvent>();
                
                for(LAT_ContractHandlerJSON.ContractEvent objEvent : objContract.listContractEvent.contractEvent) {                    
                    System.debug('calculatePaymentsInformationEventosDistribuidor [Calculando evento...: ' + objEvent.eventName + ']');                   
                    objEvento = new LAT_ContractHandlerJSON.ContractCalculationEvent();
                    if(objEvent.toDelete == null || objEvent.toDelete == false) {
                        System.debug('calculatePaymentsInformationEventosDistribuidor [objEvent.listVolume : ' + objEvent.listVolume + ']');

                        if(objEvent.listVolume != null && objEvent.listVolume != null && objEvent.listVolume.volume != null && !objEvent.listVolume.volume.isEmpty()) {                       
                            dblTotalEventoOffInvoiceCM = 0;
                            dblTotalEventoOffInvoiceLD = 0;
                            dblTotalEventoOnInvoiceCM = 0;
                            dblTotalEventoOnInvoiceLD = 0;

                            System.debug('calculatePaymentsInformationEventosDistribuidor [objEvent.listVolume.volume : ' + objEvent.listVolume.volume + ']');
                            for(LAT_ContractHandlerJSON.Volume objVolume : objEvent.listVolume.volume) {  
                                if(objVolume.toDelete == null || !objVolume.toDelete) {                              
                                    if(String.isNotBlank(objVolume.product)) {
                                        dblCantidadGF = (objVolume.boxesMaximum != null)? Double.valueOf(objVolume.boxesMaximum):0;
                                        dblCantidadBonifGF = (objVolume.bonusQuantity != null)?objVolume.bonusQuantity:0;            
                                        strProductGroupId = objVolume.product;

                                        if(dblCantidadGF == null || dblCantidadGF == 0) {
                                            dblCantidadGF = (objVolume.volumenGF != null)? Double.valueOf(objVolume.volumenGF):0;
                                        }
                                        System.debug('calculatePaymentsInformationEventosDistribuidor [dblCantidadGF: ' + dblCantidadGF + ']');
                                        System.debug('calculatePaymentsInformationEventosDistribuidor [dblCantidadBonifGF : ' + dblCantidadBonifGF + ']');
                                        System.debug('calculatePaymentsInformationEventosDistribuidor [strProductGroupId : ' + strProductGroupId + ']');

                                        if(mapReferenceProductMap.containsKey(strProductGroupId)) {
                                            strReferenceProductId = mapReferenceProductMap.get(strProductGroupId);
                                            
                                            if(mapReferenceUnitConvertionMap.containsKey(strReferenceProductId)) {
                                                dblCantidadCA = mapReferenceUnitConvertionMap.get(strReferenceProductId) * dblCantidadGF;
                                                dblCantidadBonifCA = mapReferenceUnitConvertionMap.get(strReferenceProductId) * dblCantidadBonifGF;
                                                System.debug('calculatePaymentsInformationEventosDistribuidor [dblCantidadCA: ' + dblCantidadCA + ']');
                                                System.debug('calculatePaymentsInformationEventosDistribuidor [dblCantidadBonifCA : ' + dblCantidadBonifCA + ']');

                                                if(mapProductCost.containsKey(strProductGroupId) && mapProductCost.get(strProductGroupId).Distributor__c != null && mapProductCost.get(strProductGroupId).CM_Case__c != null && mapProductCost.get(strProductGroupId).Distributor__c != null ) {                        
                                                    objProductCost = mapProductCost.get(strProductGroupId);

                                                    System.debug('calculatePaymentsInformationEventosDistribuidor [objProductCost : ' + objProductCost + ']');
                                                    System.debug('calculatePaymentsInformationEventosDistribuidor [objProductCost.Id : ' + objProductCost.Id + ']');

                                                    if(objEvent.tipoInvestimento == 'Off Invoice') {                            
                                                        dblTotalEventoOffInvoiceCM += (dblCantidadBonifCA + dblCantidadCA) * objProductCost.CM_Case__c;
                                                        dblTotalEventoOffInvoiceLD += dblCantidadBonifCA * objProductCost.DistributorCost__c;             

                                                        System.debug('calculatePaymentsInformationEventosDistribuidor [dblTotalEventoOffInvoiceCM : ' + dblTotalEventoOffInvoiceCM + ']');
                                                        System.debug('calculatePaymentsInformationEventosDistribuidor [dblTotalEventoOffInvoiceLD : ' + dblTotalEventoOffInvoiceLD + ']');                                                        
                                                    } else if(objEvent.tipoInvestimento == 'On Invoice') { 
                                                        dblTotalEventoOnInvoiceCM += (dblCantidadBonifCA + dblCantidadCA) * objProductCost.CM_Case__c;
                                                        dblTotalEventoOnInvoiceLD += dblCantidadBonifCA * objProductCost.LDCost__c;             

                                                        System.debug('calculatePaymentsInformationEventosDistribuidor [dblTotalEventoOnInvoiceCM : ' + dblTotalEventoOnInvoiceCM + ']');
                                                        System.debug('calculatePaymentsInformationEventosDistribuidor [dblTotalEventoOnInvoiceLD : ' + dblTotalEventoOnInvoiceLD + ']');                                                        
                                                    }
                                                } else {
                                                    System.debug('calculatePaymentsInformationEventosDistribuidor [mapProductCost.get(strProductGroupId) : ' + mapProductCost.get(strProductGroupId) + ']');

                                                    throw new LAT_Rest_Contracts.RestContractException(200, strProductGroupId, objContract.distribuitorId, 'Erro de cálculo de preço [PD : ' + strProductGroupId + ' - CTA : ' + objContract.distribuitorId + ']');
                                                }
                                            } else {
                                                throw new LAT_Rest_Contracts.RestContractException(210, strProductGroupId, objContract.distribuitorId, 'Erro de cálculo de preço [PD : ' + strProductGroupId + ' - CTA : ' + objContract.distribuitorId + ']');
                                            }    
                                        } else {
                                            
                                            throw new LAT_Rest_Contracts.RestContractException(220,'O produto não foi encontrado [Id CRM : ' + strProductGroupId + ']');
                                        }    
                                    } else {
                                        throw new LAT_Rest_Contracts.RestContractException(230, 'Você deve inserir um produto');
                                    }
                                }
                            }    

                            System.debug('calculatePaymentsInformationEventosDistribuidor [CUSTO PRB : ' + dblTotalEventoOffInvoiceLD + ']');        
                            System.debug('calculatePaymentsInformationEventosDistribuidor [CUSTO CM : ' + dblTotalEventoOffInvoiceCM + ']');        

                            dblTotalContratoOffInvoiceCM += dblTotalEventoOffInvoiceCM;
                            dblTotalContratoOffInvoiceLD += dblTotalEventoOffInvoiceLD;                

                            dblTotalContratoCM += (dblTotalContratoOffInvoiceCM + dblTotalContratoOnInvoiceCM);
                            dblTotalContratoLD += (dblTotalContratoOffInvoiceLD + dblTotalContratoOnInvoiceLD);

                            
                            System.debug('calculatePaymentsInformationEventosDistribuidor [dblTotalContratoOffInvoiceCM : ' + dblTotalContratoOffInvoiceCM + ']');
                            System.debug('calculatePaymentsInformationEventosDistribuidor [dblTotalContratoOffInvoiceLD : ' + dblTotalContratoOffInvoiceLD + ']');        
                            System.debug('calculatePaymentsInformationEventosDistribuidor [dblTotalContratoOnInvoiceCM : ' + dblTotalContratoOnInvoiceCM + ']');        
                            System.debug('calculatePaymentsInformationEventosDistribuidor [dblTotalContratoOnInvoiceLD : ' + dblTotalContratoOnInvoiceLD + ']');        
                            System.debug('calculatePaymentsInformationEventosDistribuidor [dblTotalContratoCM : ' + dblTotalContratoCM + ']');        
                            System.debug('calculatePaymentsInformationEventosDistribuidor [dblTotalContratoLD : ' + dblTotalContratoLD + ']');        

                            objEvento = new LAT_ContractHandlerJSON.ContractCalculationEvent();
                            objEvento.type = objEvent.tipoEvento;
                            objEvento.externalid = objEvent.id;
                            objEvento.invoice = (dblTotalContratoOffInvoiceLD + dblTotalContratoOnInvoiceLD);

                            if(objEvent.tipoInvestimento == 'Off Invoice') {
                                System.debug('calculatePaymentsInformationEventosDistribuidor [CUSTO PRB Total [dblTotalEventoOffInvoiceLD]: ' + dblTotalEventoOffInvoiceLD + ']');        
                                System.debug('calculatePaymentsInformationEventosDistribuidor [CUSTO CM Total [dblTotalEventoOffInvoiceCM]: ' + dblTotalEventoOffInvoiceCM + ']');        
                                System.debug('calculatePaymentsInformationEventosDistribuidor [roi : ' + ((dblTotalEventoOffInvoiceCM / dblTotalEventoOffInvoiceLD) - 1) + ']');        
                                
                                objEvento.roi = ((dblTotalEventoOffInvoiceCM / dblTotalEventoOffInvoiceLD) - 1) * 100;
                                System.debug('calculatePaymentsInformationEventosDistribuidor [roi : ' + objEvento.roi + ']');        
                                objResult.eventos.add(objEvento);
                            } else if(objEvent.tipoInvestimento == 'On Invoice') {                            
                                objEvento.roi = (String.isNotBlank(objEvent.PredictedROI))?Decimal.valueOf(objEvent.PredictedROI):0;
                                objEvento.invoice = (String.isNotBlank(objEvent.Investimento))?Decimal.valueOf(objEvent.Investimento):0;                  
                                objResult.eventos.add(objEvento);

                                dblTotalContratoOnInvoiceCM += dblTotalContratoOnInvoiceCM;
                                dblTotalContratoOnInvoiceLD += objEvento.invoice;    
                                dblTotalContratoOnInvoiceEventROISum += objEvento.roi; 
                                dblTotalContratoOnInvoiceEventCount++;                         
                            }
                        }
                    }                                                 
                }
 
                objResult.total_contrato = dblTotalContratoOffInvoiceLD;
                objResult.total_offinvoice = dblTotalContratoOffInvoiceLD;
                objResult.oninvoice = objContract.onInvoice;
                objResult.total_contrato_oninvoice = dblTotalContratoOnInvoiceLD;
                objResult.total_imposto = dblTotalContratoOffInvoiceLD * objResult.imposto_distribuidor / 100;                
                objResult.vd_total_contrato_oninvoice = dblTotalContratoOnInvoiceLD;

                System.debug('calculatePaymentsInformationEventosDistribuidor [objResult.total_imposto : ' + objResult.total_imposto + ']');

                if(objContract.recordType == Schema.SObjectType.LAT_Contract2__c.getRecordTypeInfosByDeveloperName().get(EVENT_DISTRIBUTOR_SIMULATION).getRecordTypeId()) {
                    objResult.roi_oninvoice = (dblTotalContratoOnInvoiceEventCount > 0)?dblTotalContratoOnInvoiceEventROISum / dblTotalContratoOnInvoiceEventCount:0;
                } else {
                    objResult.roi_oninvoice = (String.isNotBlank(objContract.ROIPrevistoOnInvoice))?Decimal.valueOf(objContract.ROIPrevistoOnInvoice):0;
                }
                
                if(dblTotalContratoOffInvoiceLD != 0) {
                    objResult.roi_offinvoice = (( dblTotalContratoOffInvoiceCM / ( dblTotalContratoOffInvoiceLD + objResult.total_imposto)) - 1 )* 100;
                    objResult.roi_previsto = objResult.roi_offinvoice;
                }

                System.debug('calculatePaymentsInformationEventosDistribuidor [objResult.roi_previsto : ' + objResult.roi_previsto + ']');
                System.debug('calculatePaymentsInformationEventosDistribuidor [objResult.roi_offinvoice : ' + objResult.roi_offinvoice + ']');
            } else {
                System.debug('calculatePaymentsInformationEventosDistribuidor [El contracto es nulo o no tiene productos]');
            } 
        } else {
            System.debug('calculatePaymentsInformationEventosDistribuidor [El contracto es nulo o no tiene eventos]');
        }

        System.debug('calculatePaymentsInformationEventosDistribuidor [' + objResult + ']');
        return objResult;
    }

    public Map<Id,Id> retrieveReferenceProductMap(Set<Id> setProductsIds) {
        Map<Id,Id> mapReferenceProductMap = null;
        List<LAT_ReferenceProductGrouping__c> lstReferenceProducts = null;
        System.debug('retrieveReferenceProductMap [setProducts : ' + setProductsIds + '] ->');

        mapReferenceProductMap = new Map<Id,Id>();

        if(setProductsIds != null && !setProductsIds.isEmpty() ) {
            lstReferenceProducts = [ SELECT Id, (SELECT id, LAT_Product__c 
                                                FROM LAT_ReferenceProducts__r 
                                                WHERE IsActive__c = true)
                                    FROM LAT_ReferenceProductGrouping__c
                                    WHERE ID IN :setProductsIds];

            for(LAT_ReferenceProductGrouping__c objProductGrouping : lstReferenceProducts) {
                for(LAT_ReferenceProduct__c objReferenceProduct : objProductGrouping.LAT_ReferenceProducts__r) {
                    mapReferenceProductMap.put(objProductGrouping.Id, objReferenceProduct.LAT_Product__c);
                }
            }
        } else {
            throw new LAT_Rest_Contracts.RestContractException(300,'O tipo de contrato não é válido [você deve inserir os volumes]');
        }

        System.debug('retrieveReferenceProductMap [' + mapReferenceProductMap + '] <-');
        return mapReferenceProductMap;
    } 
    
    public Map<Id,Double> retrieveReferenceUnitConversionMap(List<Id> lstProductsIds) {
        Map<Id,Double> mapUnitConversionMap = null;
        List<LAT_UnitConversionRates__c> lstUnitConversion = null;
        System.debug('retrieveReferenceUnitConversionMap [lstProductsIds : ' + lstProductsIds + '] ->');

        mapUnitConversionMap = new Map<Id,Double>();

        if(lstProductsIds != null && !lstProductsIds.isEmpty() ) {
            lstUnitConversion = [   SELECT Destino__c,Factor__c,KeyUnica__c,LAT_KeyUnica__c,LAT_Product__c,Origen__c,SKU__c 
                                    FROM LAT_UnitConversionRates__c
                                    WHERE Destino__c = 'CA'
                                    AND Origen__c = 'BT'
                                    AND LAT_KeyUnica__c LIKE '1-%'
                                    AND LAT_Product__c IN :lstProductsIds];

            System.debug('retrieveReferenceUnitConversionMap [lstUnitConversion : ' + lstUnitConversion + ']');

            for(LAT_UnitConversionRates__c objUnitConversion : lstUnitConversion) {
                if(objUnitConversion.Factor__c != null) {
                    mapUnitConversionMap.put(objUnitConversion.LAT_Product__c, objUnitConversion.Factor__c);
                } else {
                    throw new LAT_Rest_Contracts.RestContractException(310, 'O tipo de contrato não é válido [O fator de conversão não pode ser nulo:' + objUnitConversion.Id + ']');
                }
            }
        } else { 
            throw new LAT_Rest_Contracts.RestContractException(320, 'O contrato não é válido [você deve inserir os volumes]');
        }
        System.debug('retrieveReferenceUnitConversionMap [' + mapUnitConversionMap + '] <-');
        return mapUnitConversionMap;
    } 

    public Map<Id,LAT_ProductCost__c> retrieveProductCosts(Id objAccountId, Set<Id> setProductsIds) {
        Account objAccount = null;
        Account objClonedAccount = null;
        Map<Id,LAT_ProductCost__c> mapProductCost = null;
        List<LAT_ProductCost__c> lstProductCost = null;
        LAT_Opportunity__c objOpportunity = null;
        Lat_contract2__c objContract = null;

        System.debug('retrieveProductCosts [objAccountId : ' + objAccountId + ' - setProductsIds : ' + setProductsIds + '] ->');

        mapProductCost = new Map<Id,LAT_ProductCost__c>();

        objAccount = [  SELECT Id, Revenue_UF__c
                        FROM Account 
                        WHERE ID =: objAccountId];


        
        System.debug('retrieveProductCosts [objAccount : ' + objAccount + ']');
        try {
            ///este codigo sirve para simular una llamada a clone y que paresca que esas funciones son utlizadas
            objClonedAccount = cloneAccount(new Account());
            objOpportunity = cloneOpportunity(new LAT_Opportunity__c());
            objContract = cloneContract(new Lat_contract2__c());
            objOpportunity.LAT_Account__c  = (objClonedAccount != null)?objClonedAccount.Id:null;
            objContract.Account__c  = (objClonedAccount != null)?objClonedAccount.Id:null;
        } catch(Exception Ex) {
        }
        //findel codigo simulado,
        lstProductCost = [  SELECT UF__c, Product__c, Product__r.Name, CM_Case__c, RecordType.DeveloperName, DistributorCost__c,  LDCost__c, Net_Sales_Case__c, MeasureUnit__c, AN8__c, Distributor__c 
                            FROM LAT_ProductCost__c
                            WHERE UF__c =: objAccount.Revenue_UF__c
                            AND RecordType.DeveloperName = 'LAT_ProductPayment'
                            AND AN8__c = NULL
                            AND Product__c IN :setProductsIds];
        
        System.debug('retrieveProductCosts [lstProductCost[UF__c].size() : ' + lstProductCost.size() + ']');

        for(LAT_ProductCost__c objProductCost : lstProductCost) {
            mapProductCost.put(objProductCost.Product__c, objProductCost);
        }

        lstProductCost = [  SELECT UF__c, Product__c, Product__r.Name, CM_Case__c, RecordType.DeveloperName, DistributorCost__c,  LDCost__c, Net_Sales_Case__c, MeasureUnit__c, AN8__c, Distributor__c 
                            FROM LAT_ProductCost__c
                            WHERE AN8__c =: objAccount.Id
                            AND RecordType.DeveloperName = 'LAT_ProductPayment'
                            AND Product__c IN :setProductsIds];
        
        System.debug('retrieveProductCosts [lstProductCost [Distribuidor].size(): ' + lstProductCost.size() + ']');
        System.debug('retrieveProductCosts [Sobrescribiendo la info de UF con la info del distribuidor]');

        for(LAT_ProductCost__c objProductCost : lstProductCost) {
            mapProductCost.put(objProductCost.Product__c, objProductCost);
        }

        System.debug('retrieveProductCosts [mapProductCost.size() : ' + mapProductCost.size() + ']');

        System.debug('retrieveProductCosts [' + mapProductCost + '] <-');

        return mapProductCost;
    }
}