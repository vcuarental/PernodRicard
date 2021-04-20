/********************************************************************************************
*  Company:Valuenet             Developers:Nicolas Javier Romero           Date:27/11/2013  *
********************************************************************************************/

public class LAT_BR_AP01_OpportunityLineItem{
    
    /*****************************************************************************************
    * Nombre del metodo: updateStatusOpportunity
    * Descripcion: Metodo que actualiza el status de la oportunidad de acuerdo al status de los items
    * Desarrollador: Nicolas Javier Romero
    * Fecha: 12/12/2013
    * Modo: after insert, after update, after delete
    *****************************************************************************************/
    /********************************************************************************
    * 
    * MIGRACION LICENCIAS 
    * AUTHOR: ZIMMIC                     DATE: 03/11/2016
    *
    ********************************************************************************/
    public static void updateStatusOpportunity(List<OpportunityLineItem> triggerNew, List<OpportunityLineItem> triggerOld, map<Id, OpportunityLineItem> triggerOldMap){
        /*
        Set<Id> setIdOpp = new Set<Id>();
        if(trigger.isDelete){
            for(OpportunityLineItem oli :triggerOld){
                setIdOpp.add(oli.OpportunityId);
            }
        }else{
            for(OpportunityLineItem oli :triggerNew){
                setIdOpp.add(oli.OpportunityId);
            }
        }
        
        if(!setIdOpp.isEmpty()){
            List<Opportunity> listOppToUpdate = new List<Opportunity>();
            for(Opportunity opp : [SELECT Id, StageName, NR_order_JDE__c, (SELECT Id, Descricao_do_status__c FROM OpportunityLineItems) FROM Opportunity WHERE Id =: setIdOpp]){
                if(opp.NR_order_JDE__c != null){
                    Integer contCancel = 0;
                    Integer contFacturado = 0;
                    Integer contAprobacion = 0;
                    for(OpportunityLineItem oli :opp.OpportunityLineItems){
                        if(oli.Descricao_do_status__c != null){
                            if(oli.Descricao_do_status__c.startsWithIgnoreCase('Cancelado')){

                                contCancel++;
                            }else if(oli.Descricao_do_status__c.startsWithIgnoreCase('Faturado') || oli.Descricao_do_status__c.startsWithIgnoreCase('Facturado') || oli.Descricao_do_status__c.startsWithIgnoreCase('Contabilizado')){
                                contFacturado++;
                            }else if(oli.Descricao_do_status__c.contains('Aprovação')) {
                                contAprobacion++;
                            }
                        }
                    }
                    String newStatus = opp.StageName;
                    
                    if(contFacturado != 0 && contFacturado != opp.OpportunityLineItems.size()){
                       newStatus = 'Partially billed';
                       opp.Probability = 90;
                    }
                    if(contFacturado == opp.OpportunityLineItems.size()){
                       newStatus = 'Totally billed';
                       opp.Probability = 100;
                    }
                    if(contCancel == opp.OpportunityLineItems.size()){
                       newStatus = 'Pedido cancelado no JDE';
                       opp.Probability = 0;
                    }
                    if(contAprobacion == opp.OpportunityLineItems.size()){
                       newStatus = 'Pedido em Aprovação';
                    }
                    
                    if(opp.StageName != newStatus){
                        opp.StageName = newStatus;
                        opp.Integracao__c = true;
                        listOppToUpdate.add(opp);
                    }
                }
            }
            if(!listOppToUpdate.isEmpty()){
                update listOppToUpdate;
            }
        }*/
    }
    
     //MIGRATED 03/11/2016 
    public static void updateStatusOpportunity(List<LAT_OpportunityLineItem__c> triggerNew, List<LAT_OpportunityLineItem__c> triggerOld, map<Id, LAT_OpportunityLineItem__c> triggerOldMap){
        LAT_JDE_PriceCalculation.priceCatalogueDetailsOutput out1 = new LAT_JDE_PriceCalculation.priceCatalogueDetailsOutput();
        LAT_JDE_PriceCalculation.discountAndChargeDetailsOutput out2 = new LAT_JDE_PriceCalculation.discountAndChargeDetailsOutput();
        LAT_JDE_PriceCalculation.discountAndChargeDetailsOutput out5 = new LAT_JDE_PriceCalculation.discountAndChargeDetailsOutput();
        LAT_JDE_PriceCalculation.messageValueObject out3 = new LAT_JDE_PriceCalculation.messageValueObject();
        LAT_JDE_PriceCalculation.e1MessageList out6 = new LAT_JDE_PriceCalculation.e1MessageList();
        LAT_JDE_PriceCalculation.priceCatalogueHeaderOutput out4 = new LAT_JDE_PriceCalculation.priceCatalogueHeaderOutput();
        LAT_JDE_PriceCalculation.BusinessServiceException_x out7 = new LAT_JDE_PriceCalculation.BusinessServiceException_x();
        LAT_JDE_PriceCalculation.valueObject out8 = new LAT_JDE_PriceCalculation.valueObject();
        LAT_JDE_PriceCalculation.errorRecords out9 = new LAT_JDE_PriceCalculation.errorRecords();
        LAT_JDE_PriceCalculation.e1Message out10 = new LAT_JDE_PriceCalculation.e1Message();
        LAT_JDE_PriceCalculation.responseValueObject out11 = new LAT_JDE_PriceCalculation.responseValueObject();


        //Generating Table
        out1.amountDiscountsAndCharges = 1;
        out1.amountExcise= 1;
        out1.amountExclusiveDiscountsAndCharges = 1;
        out1.amountGross= 1;
        out1.amountTax= 1;
        out1.amountTaxable= 1;
        out1.description1= '';
        out1.description2= '';
        out1.exciseRate = 1;
        out1.itemNumberShort = 1;
        out1.ordinalNumber = 1;
        out1.paymentTerms = 'TT';
        out1.quantityOrdered = 1;
        out1.ratePercentDiscountsAndCharges = 1;
        out1.secondItemNumber = 'Mx01';
        out1.taxRate = 1;
        out1.unitPrice = 1;
        out1.unitPriceExclusiveDiscountsAndCharges = 1;
        out1.unitPriceGross = 1;
        out1.unitofMeasure = 'CA';
        out1.discountAndChargeDetails = new List<LAT_JDE_PriceCalculation.discountAndChargeDetailsOutput>();
        out2.amountDiscountOrCharge= 1 ;
        out2.discountOrChargeGroup = 'IVA';
        out2.discountOrChargeType = 'IVA';
        out2.ratePercentDiscountsAndCharges=1;
        out2.unitDiscountOrCharge=1;
        out5.amountDiscountOrCharge = 1;
        out5.discountOrChargeGroup = 'IEPS';
        out5.discountOrChargeType = 'IEPS';
        out5.ratePercentDiscountsAndCharges=1;
        out5.unitDiscountOrCharge=1;
        out1.discountAndChargeDetails.add(out2);
        out1.discountAndChargeDetails.add(out5);
        out7.message = '';
        out7.requestID = '';
        out9.errorCode = '';
        out9.errorDescription = '';
        out10.message = '';
        out10.messagePrefix = '';
        out6.e1Messages = new List<LAT_JDE_PriceCalculation.e1Message>{out10};
        out11.errorRecords = new List<LAT_JDE_PriceCalculation.errorRecords>{out9};
        /*

        Set<Id> setIdOpp2 = new Set<Id>();
        
        if(trigger.isDelete){
            for(LAT_OpportunityLineItem__c oli :triggerOld){
                setIdOpp2.add(oli.LAT_Opportunity__c);
            }
        }else{
            for(LAT_OpportunityLineItem__c oli :triggerNew){
                setIdOpp2.add(oli.LAT_Opportunity__c);
            }
        }
        
        if(!setIdOpp2.isEmpty()){
            List<LAT_Opportunity__c> listOppToUpdate = new List<LAT_Opportunity__c>();
            for(LAT_Opportunity__c opp : [SELECT Id, LAT_StageName__c, LAT_NROrderJDE__c, (SELECT Id, LAT_StatusDescription__c FROM OpportunityLineItems__r) FROM LAT_Opportunity__c WHERE Id =: setIdOpp2]){
                if(opp.LAT_NROrderJDE__c != null){
                    Integer contCancel = 0;
                    Integer contFacturado = 0;
                    Integer contAprobacion = 0;
                    for(LAT_OpportunityLineItem__c oli :opp.OpportunityLineItems__r){
                        if(oli.LAT_StatusDescription__c != null){
                            if(oli.LAT_StatusDescription__c.startsWithIgnoreCase('Cancelado')){
                                contCancel++;
                            }else if(oli.LAT_StatusDescription__c.startsWithIgnoreCase('Faturado') || oli.LAT_StatusDescription__c.startsWithIgnoreCase('Facturado') || oli.LAT_StatusDescription__c.startsWithIgnoreCase('Contabilizado')){
                                contFacturado++;
                            }else if(oli.LAT_StatusDescription__c.contains('Aprovação')) {
                                contAprobacion++;
                            }
                        }
                    }
                    String newStatus = opp.LAT_StageName__c;
                    
                    if(contFacturado != 0 && contFacturado != opp.OpportunityLineItems__r.size()){
                       newStatus = 'Partially billed';
                       opp.LAT_Probability__c = 90;
                    }
                    if(contFacturado == opp.OpportunityLineItems__r.size()){
                       newStatus = 'Totally billed';
                       opp.LAT_Probability__c = 100;
                    }
                    if(contCancel == opp.OpportunityLineItems__r.size()){
                       newStatus = 'Pedido cancelado no JDE';
                       opp.LAT_Probability__c = 0;
                    }
                    if(contAprobacion == opp.OpportunityLineItems__r.size()){
                       newStatus = 'Pedido em Aprovação';
                    }
                    
                    if(opp.LAT_StageName__c != newStatus){
                        opp.LAT_StageName__c = newStatus;
                        opp.LAT_Integration__c = true;
                        listOppToUpdate.add(opp);
                    }
                }
            }
            if(!listOppToUpdate.isEmpty()){
                update listOppToUpdate;
            }
        }
        */
    }
    
    /*****************************************************************************************
    * Nombre del metodo: parseHelper
    * Descripcion: Metodo de utilidad para parsear el texto de compiosicion de precios
    * Desarrollador: Nicolas Javier Romero
    * Fecha: 12/12/2013
    * Modo: 
    *****************************************************************************************/
    public static decimal parseHelper(string headerText, string campoFormatacao, integer columnIndex) {
        
        integer startIndex = -1;
        integer endIndex = -1;
        
        startIndex = campoFormatacao.indexOf(headerText);
        endIndex = campoFormatacao.indexOf('</tr>', startIndex);
        decimal parsedValue = 0;
        
        string htmlFiltrado = '';
        if(startIndex <= -1 || endIndex <= -1){
            return null;
        }
        htmlFiltrado = campoFormatacao.substring(startIndex, endIndex);
        if (htmlFiltrado == '') {
            return null;
        }
        htmlFiltrado = htmlFiltrado.split('</td>')[columnIndex];
        htmlFiltrado = htmlFiltrado.replaceAll('<.*?>','');
        if (htmlFiltrado != '') {
            parsedValue = Decimal.valueOf(htmlFiltrado.replaceAll('\\.', '').replaceAll(',','.').trim().replaceAll('[^0-9\\.]', ''));
        }
        return parsedValue;
    }
    
    /*****************************************************************************************
    * Nombre del metodo: decodeCompositionPrice
    * Descripcion: Metodo de utilidad para parsear el texto de compiosicion de precios
    * Desarrollador: Nicolas Javier Romero
    * Fecha: 12/12/2013
    * Modo: 
    *****************************************************************************************/
    public static void decodeCompositionPrice(List<OpportunityLineItem> triggerNew){
        integer columnNumber = 2; //number 0 is invalid, it's the header
        for(OpportunityLineItem oli :triggerNew){
            if(oli.Campo_de_formatacao__c != null && oli.Campo_de_formatacao__c != ''){
                oli.LAT_IPI__c = parseHelper('IPI', oli.Campo_de_formatacao__c, columnNumber);
                oli.LAT_NFValue__c = parseHelper('Valor Mercadoria', oli.Campo_de_formatacao__c, columnNumber);//parseHelper('Valor NF PRB', oli.Campo_de_formatacao__c, columnNumber);
                oli.LAT_NFTotal__c = parseHelper('Valor Total NF', oli.Campo_de_formatacao__c, columnNumber);
                oli.LAT_TaxReplacement__c = parseHelper('Tributaria', oli.Campo_de_formatacao__c, columnNumber);
            }
        }
    }

    //MIGRATED 03/11/2016 
    public static void decodeCompositionPrice(List<LAT_OpportunityLineItem__c> triggerNew){
        integer columnNumber = 2; //number 0 is invalid, it's the header
        for(LAT_OpportunityLineItem__c oli :triggerNew){
            if(oli.LAT_FormatField__c != null && oli.LAT_FormatField__c != ''){
                oli.LAT_IPI__c = parseHelper('IPI', oli.LAT_FormatField__c, columnNumber);
                oli.LAT_NFValue__c = parseHelper('Valor Mercadoria', oli.LAT_FormatField__c, columnNumber);//parseHelper('Valor NF PRB', oli.Campo_de_formatacao__c, columnNumber);
                oli.LAT_NFTotal__c = parseHelper('Valor Total NF', oli.LAT_FormatField__c, columnNumber);
                oli.LAT_TaxReplacement__c = parseHelper('Tributaria', oli.LAT_FormatField__c, columnNumber);
            }
            String flexString = 'Flex (' + oli.LAT_AR_Discount__c + '%)|';
            if(oli.LAT_FormatField__c != null) {
                oli.LAT_FormatField__c = oli.LAT_FormatField__c.replace('Flex|', flexString);
            }
            if(oli.LAT_RawLinePriceComponents__c != null) {
                oli.LAT_RawLinePriceComponents__c = oli.LAT_RawLinePriceComponents__c.replace('Flex|', flexString);
            }
        }
    }
    public static void calculateFreightPercent(List<LAT_OpportunityLineItem__c> triggerNew, Set<Id> setOppIds){
        Map<Id, LAT_Opportunity__c> oppsMap = new Map<Id, LAT_Opportunity__c> ([SELECT Id, Name, LAT_OrderOrigin__c FROM LAT_Opportunity__c WHERE id in :setOppIds]);
        Map<Id, LAT_Product__c> productsBR = new Map<Id, LAT_Product__c> ([SELECT id, Name, LAT_PercentualOfFreight__c, LAT_BoxesPerPallet__c FROM LAT_Product__c WHERE LAT_IsActive__c = true AND LAT_ExternalID__c LIKE '1-%' AND LAT_IsRefactorProduct__c = 'Y' and lastmodifieddate >= LAST_N_DAYS:60]);
        List<LAT_GeneralConfig__c> configs = [SELECT Name, LAT_Value__c,LAT_Description__c FROM LAT_GeneralConfig__c WHERE name IN ('PERCENT_FREIGHT_DEFAULT','BOXES_PER_PALLET_DEFAULT')];
        Decimal defaultFreight;
        Decimal defaultQuantity;
        for (LAT_GeneralConfig__c c :configs) {
            if (c.Name == 'PERCENT_FREIGHT_DEFAULT') {
                defaultFreight = Decimal.valueOf(c.LAT_Value__c);
            } else if (c.Name == 'BOXES_PER_PALLET_DEFAULT') {
                    defaultQuantity = Decimal.valueOf(c.LAT_Value__c);   
            }
        }

        for(LAT_OpportunityLineItem__c oli :triggerNew){
            if (oppsMap.get(oli.LAT_Opportunity__c).LAT_OrderOrigin__c != 'APP') {
                if (productsBR.get(oli.LAT_Product__c) != null) {
                    if (productsBR.get(oli.LAT_Product__c).LAT_PercentualOfFreight__c != null) {
                        oli.LAT_FreightPercent__c = oli.LAT_Quantity__c * productsBR.get(oli.LAT_Product__c).LAT_PercentualOfFreight__c;
                    } else {
                        oli.LAT_FreightPercent__c = oli.LAT_Quantity__c * defaultFreight;
                    }
                    if (productsBR.get(oli.LAT_Product__c).LAT_BoxesPerPallet__c != null) {
                        oli.LAT_Pallet_Total_Quantity__c = oli.LAT_Quantity__c * productsBR.get(oli.LAT_Product__c).LAT_BoxesPerPallet__c;
                    } else {
                        oli.LAT_Pallet_Total_Quantity__c = oli.LAT_Quantity__c * defaultQuantity;
                    }
                }
            }
        }  
    }   

    public static void relateIMMLogs(List<LAT_OpportunityLineItem__c> triggerNew){
        Map<String, LAT_OpportunityLineItem__c> mapOliIdsByImmIds = new Map<String, LAT_OpportunityLineItem__c>();

        
        for(LAT_OpportunityLineItem__c oli :triggerNew){
            if(oli.LAT_IdIMM__c != null){
               mapOliIdsByImmIds.put(oli.LAT_IdIMM__c, oli);
            }
        }
        System.debug('%%%% relateIMMLogs mapOliIdsByImmIds : ' + mapOliIdsByImmIds);
        if(mapOliIdsByImmIds.size() > 0) {
            List<LAT_IMM_Logs__c> logsToUpdate = [SELECT Id, LAT_IMM_Id__c, LAT_uuid__c FROM LAT_IMM_Logs__c WHERE LAT_IMM_Id__c IN :mapOliIdsByImmIds.keyset() ];
            System.debug('%%%% relateIMMLogs logsToUpdate : ' + logsToUpdate);
            for (LAT_IMM_Logs__c log : logsToUpdate) {
                System.debug('%%%% relateIMMLogs mapOliIdsByImmIds.get(log.LAT_IMM_Id__c) : ' + mapOliIdsByImmIds.get(log.LAT_IMM_Id__c));
                log.LAT_OpportunityLineItem__c = mapOliIdsByImmIds.get(log.LAT_IMM_Id__c).Id;
            }
            update logsToUpdate;
        }
    }

    public static Boolean validateFlexAmount(List<LAT_OpportunityLineItem__c> triggerNew, Map<Id, LAT_OpportunityLineItem__c> triggerOldMap){
        return false;
        /*
        Map<String, String> mapOliIdsByImmIds = new Map<String, String>();
        System.debug('%%%%% entramos en validate Flex Amount  ');
        Boolean changed = false;
        for(LAT_OpportunityLineItem__c oli :triggerNew){
            System.debug('%%%%% oli.LAT_NisAmount__c:' + oli.LAT_NisAmount__c + ' || triggerOldMap.get(oli.Id).LAT_NisAmount__c:' +triggerOldMap.get(oli.Id).LAT_NisAmount__c);
            if(oli.LAT_NisAmount__c != triggerOldMap.get(oli.Id).LAT_NisAmount__c || oli.LAT_FlexNeedsValidation__c){
                System.debug('%%%%% changed = true');
                changed = true;
                break;
            }
            if(oli.LAT_AR_Discount__c > 0 && oli.LAT_CdLineStatus__c == '620' && triggerOldMap.get(oli.Id).LAT_CdLineStatus__c != '620'){
                System.debug('%%%%% changed = true');
                changed = true;
                break;
            }
        }
        if(changed) {
            for (LAT_OpportunityLineItem__c oli :triggerNew) {
                if(oli.LAT_IsFlex__c) {
                    System.debug('%%%%% se envia a processar Flex oli : ' + oli.Id);
                    LAT_Rest_PriceFlex_SyncParams.processFlexOpportunity(oli.LAT_Opportunity__c);
                    break;
                }
            }
        }
        return changed;
        */
    }

    public static void setFlexAmount(List<LAT_OpportunityLineItem__c> triggerNew){
        for (LAT_OpportunityLineItem__c oli :triggerNew) {
            if(oli.LAT_IsFlex__c && !oli.LAT_IsOnHoldEDI__c) {
                if(oli.LAT_NisAmount__c != null && oli.LAT_OriginalNisAmount__c != null) {
                    oli.LAT_FlexAmount__c = oli.LAT_NisAmount__c - oli.LAT_OriginalNisAmount__c;
                }   
            }
        }    
    }
    
    public static void setUnitOriginalNisAmount(List<LAT_OpportunityLineItem__c> triggerNew){
        for (LAT_OpportunityLineItem__c oli :triggerNew) {
            if(oli.LAT_IsFlex__c) {
                if(oli.LAT_OriginalNisAmount__c != null && oli.LAT_Quantity__c != null && !oli.LAT_IsOnHoldEDI__c) {
                    oli.LAT_OriginalUnitNisAmount__c = oli.LAT_OriginalNisAmount__c / oli.LAT_Quantity__c;
                }   
            }
        }    
    }

    public static void setNeedsFlexValidationFalse(List<LAT_OpportunityLineItem__c> triggerNew, Map<Id, LAT_OpportunityLineItem__c> triggerOldMap){
        for (LAT_OpportunityLineItem__c oli :triggerNew) {
            if(oli.LAT_FlexNeedsValidation__c) {
                if(!oli.LAT_JDEFlexReviewed__c){
                    oli.LAT_FlexNeedsValidation__c = false; 
                } else {
                    if(triggerOldMap.get(oli.Id)!= null){
                        oli.LAT_FlexNeedsValidation__c = triggerOldMap.get(oli.Id).LAT_JDEFlexReviewed__c;
                    }
                }
                
            }
        }    
    }


}