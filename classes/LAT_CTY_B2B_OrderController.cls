public with sharing class LAT_CTY_B2B_OrderController {
    public class B2BCustomError {
        @AuraEnabled
        public Integer errorCode        { get; set; }
        @AuraEnabled
        public String message           { get; set; }
        @AuraEnabled
        public String internalMessage   { get; set; }
        @AuraEnabled
        public String stackTrace        { get; set; }        
        @AuraEnabled
        public Boolean displayError      { get; set; } 
        @AuraEnabled
        public Boolean blockSite      { get; set; } 

        public B2BCustomError(Boolean boolDisplayError,Boolean boolBlockSite, Integer intErrorCode, String strMessage) {
            this.errorCode = intErrorCode;
            this.message = strMessage;
            this.displayError = boolDisplayError;
            this.blockSite = boolBlockSite;
        }

        public B2BCustomError(Boolean boolDisplayError,Boolean boolBlockSite, Integer intErrorCode, Exception Ex) {
            this.errorCode = intErrorCode;
            this.displayError = boolDisplayError;
            this.blockSite = boolBlockSite;
            this.message = 'Ha ocurrido un error en la aplicación. Por favor, reintente la operación más tarede.';
            this.internalMessage = Ex.getMessage();
            this.stackTrace = Ex.getStackTraceString();      

            LAT_Utils.handleException('B2BCustomException', Ex);      
        }
    }

    @AuraEnabled
    public static Map<String,List<String>> getAllCategories()   {
        List<String> categoryList = new List<String>{'Whisky','Vodka','Vinos','Gin','Ron','Licores','Espumantes','Otros'};
        List<String> whisky = new List<String>{'100 Pipers','Aberlour','Ballantine\'s','Blenders Pride','Chivas Regal','Jameson','Royal Salute','Scapa','The Glenlivet'};
        List<String> vodka = new List<String>{'Absolut','Absolut Elyx','Oddka','Wyborowa'};
        List<String> gin = new List<String>{'Beefeater','Monkey 47'};
        List<String> vinos = new List<String>{'Bodega Colon','Bodega Etchart','Etchart Privado','Graffigna','Santa Silvia'};
        List<String> espumantes = new List<String>{'Bodega Mumm','G.H.MUMM','Perrier-Jouët'};
        List<String> otros = new List<String>{'Capri','Durazno','Hiram Walker','Malibu','Padilla','Ramazzotti','Ricard'};
        List<String> licores = new List<String>{'Cusenier','Doble V','Kahlua','Tia Maria'};
        List<String> ron = new List<String>{'Havana Club'};
        Map<String,List<String>> retorno = new Map<String,List<String>>();
        
        retorno.put('Whisky', whisky);
        retorno.put('Vodka', vodka);
        retorno.put('Vinos', vinos);
        retorno.put('Gin', gin); 
        retorno.put('Ron', ron);
        retorno.put('Licores', licores);
        retorno.put('Espumantes', espumantes);
        retorno.put('Otros', otros);
        return retorno;
    }

    @AuraEnabled
    public static Boolean getChartBlocked() {
        return LAT_CTY_B2B_PendingFiscalNotesCont.getChartBlocked();
    }

    @AuraEnabled
    public static LAT_GeneralConfig__c getBlockingComments() {
        LAT_GeneralConfig__c objSetting = LAT_GeneralConfig__c.getInstance('LAT_CTY_B2B_AR_BlockingComments');
        System.debug('getBlockingComments [] ->');

        if(objSetting == null) {
            objSetting = new LAT_GeneralConfig__c();
            objSetting.Name = 'LAT_CTY_B2B_AR_BlockingComments';
            objSetting.LAT_Value__c = '';
            objSetting.LAT_Description__c = 'Comentarios del Bloqueo del carrito en B2B.';
            insert objSetting;
        }

        System.debug('getBlockingComments [' + objSetting + '] <-');

        return objSetting;
    }

    @AuraEnabled
    public static Decimal getMinimunPrice() {
        final Id accountId = getAccountId();
        return LAT_CTY_B2B_UtilsController.getMinimunPrice(accountId);
    }

    @AuraEnabled
    public static String getAccountDetail() {
        Contact objContact = null;
        String strAccountCredit = null;
        LAT_WS_GetAvailableCredit.creditItem objCredit = null;

        System.debug('getAccountDetail[] ->');
        try {
            objContact = LAT_CTY_B2B_MyAccountController.getContact();

            if(objContact != NULL && objContact.Account != NULL && String.IsNotBlank(objContact.Account.Client_country_AN8__c)) {            
                objCredit = LAT_WS_GetAvailableCredit.getAvailableCredit(objContact.Account.Client_country_AN8__c);
                if(objCredit != NULL) {
                    strAccountCredit =  JSON.serialize(objCredit);
                } else {                    
                    throw new AuraHandledException(JSON.serializePretty(new B2BCustomError(true, false, 100, 'No se ha encontrado información del contacto o de la cuenta.'))) ;
                }
            } else {
                throw new AuraHandledException(JSON.serializePretty(new B2BCustomError(true, false, 200, 'No se ha encontrado información del contacto o de la cuenta.'))) ;
            }
        } catch(AuraHandledException Ex) {
            throw Ex;
        } catch (Exception Ex) {
            throw new AuraHandledException(JSON.serializePretty(new B2BCustomError(true, false, 999, Ex))) ;
        }

        System.debug('getAccountDetail[' + strAccountCredit + '] <-');

        return strAccountCredit;
    }

    @AuraEnabled
    public static String getAccountIdFromUser() {
        Contact objContact = null;
        String strAccountId = null;

        System.debug('getAccountIdFromUser[] ->');
        try {
            objContact = LAT_CTY_B2B_MyAccountController.getContact();

            if(objContact != NULL && objContact.Account != NULL && String.IsNotBlank(objContact.Account.Id)) {            
                strAccountId = objContact.Account.Id;
            } else {
                throw new AuraHandledException(JSON.serializePretty(new B2BCustomError(true, false, 200, 'No se ha encontrado información del contacto o de la cuenta.'))) ;
            }
        } catch(AuraHandledException Ex) {
            throw Ex;
        } catch (Exception Ex) {
            throw new AuraHandledException(JSON.serializePretty(new B2BCustomError(true, false, 999, Ex))) ;
        }

        System.debug('getAccountIdFromUser[' + strAccountId + '] <-');

        return strAccountId;
    }

    @AuraEnabled
    public static Id getAccountId() {
        Id objAccountId = null;

        System.debug('getAccountId [] ->');

        try {
            final String userId = UserInfo.getUserId(); 
            final List <User> usrs = [SELECT Id, Contact.AccountId FROM User WHERE Id = :userId];

            if (!usrs.isEmpty()) {
                objAccountId =  (usrs[0].Contact !=  null ) ? usrs[0].Contact.AccountId : null;
            }
        } catch(Exception Ex) {
            throw new AuraHandledException(JSON.serializePretty(new B2BCustomError(true, false, 999, Ex))) ;
        }

        System.debug('getAccountId [' + objAccountId + '] <-');

        return objAccountId;
    }

    @AuraEnabled
    public static Boolean getBlockedClient() {
        Boolean retorno = false;
        List<LAT_FiscalNote__c> fns = null;
        
        System.debug('getBlockedClient [] ->');

        try {
            fns = getPendingFiscalNotes();

            for (LAT_FiscalNote__c fn : fns){
                if(fn.LAT_DueDate__c < Date.today() && fn.LAT_Balance__c > 0){
                    retorno = true;
                    break;
                } 
            }
        } catch(Exception Ex) {
            throw new AuraHandledException(JSON.serializePretty(new B2BCustomError(true, false, 999, Ex))) ;
        }

        System.debug('getBlockedClient [' + retorno + '] <-');

        return retorno;
    }

    @AuraEnabled
    public static List<LAT_Opportunity__c> getCommunityOrders() {
        String strBaseUrl = null;
        Id strAccountId = null;
        Map<Id, LAT_Opportunity__c> mapOpportunity = null;
        List<LAT_FiscalNote__c> lstFiscalNotes = null; 
        List<LAT_Opportunity__c> lstOpportunities = null;

        System.debug('getCommunityOrders [] ->');
        
        try {
            strBaseUrl = retrieveCommunityBaseUrl();
            strAccountId = getAccountId();
            lstOpportunities = new List<LAT_Opportunity__c>();
            mapOpportunity =  new Map<Id, LAT_Opportunity__c>([ SELECT  Id, 
                                                                        CurrencyIsoCode,  
                                                                        LAT_TotalValue__c, 
                                                                        LAT_AR_IVA__c, 
                                                                        LAT_AR_IIBB__c, 
                                                                        CreatedDate, 
                                                                        LAT_Type__c, 
                                                                        LAT_Account__r.Name, 
                                                                        LAT_AR_TotalImpuestosInculidos__c,
                                                                        LAT_Account__c, 
                                                                        Name, 
                                                                        LAT_StageName__c, 
                                                                        LAT_NROrderJDE__c, 
                                                                        LAT_NRCustomerOrder__c, 
                                                                        LAT_NextStep__c,
                                                                        LAT_CTY_B2B_URL_Calico__c	
                                                               FROM LAT_Opportunity__c  
                                                               WHERE LAT_Account__c =: strAccountId 
                                                               AND LAT_LeadSource__c = 'B2B' 
                                                               AND LAT_StageName__c != 'Novo Pedido' 
                                                               ORDER BY CreatedDate DESC]);

            System.debug('getCommunityOrders [ mapOpportunity : ' + mapOpportunity + ']');

            if(!mapOpportunity.IsEmpty()) {
                lstFiscalNotes = [  SELECT  Id, 
                                            LAT_Opportunity__c, 
                                            LAT_LegalInvoice__c, 
                                            (SELECT ID, Name 
                                             FROM Attachments) 
                                    FROM LAT_FiscalNote__c 
                                    WHERE LAT_Opportunity__c IN :mapOpportunity.keySet()];

                System.debug('getCommunityOrders [ lstFiscalNotes : ' + lstFiscalNotes + ']');
 
                if(!lstFiscalNotes.IsEmpty()) {
                    for(LAT_FiscalNote__c objFiscalNotes : lstFiscalNotes) {
                        if(mapOpportunity.containsKey(objFiscalNotes.LAT_Opportunity__c)) {
                            mapOpportunity.get(objFiscalNotes.LAT_Opportunity__c).LAT_MobileId__c = objFiscalNotes.LAT_LegalInvoice__c;
                        
                            if(objFiscalNotes.Attachments != null && objFiscalNotes.Attachments.size() > 0) {
                                for(Attachment objAttachment : objFiscalNotes.Attachments) {
                                    if(objAttachment.Name.contains(objFiscalNotes.LAT_LegalInvoice__c)) {
                                        mapOpportunity.get(objFiscalNotes.LAT_Opportunity__c).LAT_NextStep__c = strBaseUrl + '/servlet/servlet.FileDownload?file=' + objAttachment.Id;
                                    }
                                }
                            } else {
                                System.debug('getCommunityOrders [' + objFiscalNotes.Id + ' has no attachments]');
                            }
                        }                                        
                    }
                }

                lstOpportunities = mapOpportunity.values();
            }
        } catch (Exception Ex) {
            throw new AuraHandledException(JSON.serializePretty(new B2BCustomError(true, false, 999, Ex))) ;
        }

        System.debug('getCommunityOrders [' + lstOpportunities + '] <-');

        return lstOpportunities;
    }


    /*
    * getlastOrder
    * TO DO: Add a filter LAT_LeadSource__c
    */
    @AuraEnabled
    public static LAT_Opportunity__c getlastOrder() {
        LAT_Opportunity__c objResult = null;
        Id strAccountId = null;
        List<LAT_Opportunity__c> lstOpportunity = null;
        List<LAT_FiscalNote__c> lstFiscalNotes = null;
        
        System.debug('getlastOrder [] ->');

        try {
            strAccountId = getAccountId();
            if(String.isNotBlank(strAccountId)) {
                lstFiscalNotes = [SELECT LAT_Opportunity__c 
                                    FROM LAT_FiscalNote__c 
                                    WHERE LAT_Client__c =: strAccountId 
                                    AND LAT_AR_B2B_Status__c IN ('A pagar','Pago Informado') 
                                    ORDER BY LAT_DueDate__c 
                                    LIMIT 1];

                System.debug('getlastOrder [lstFiscalNotes : ' + lstFiscalNotes + ']'); 

                if(!lstFiscalNotes.IsEmpty() && String.isNotBlank(lstFiscalNotes[0].LAT_Opportunity__c)) {
                    lstOpportunity = [SELECT Id, 
                                            CurrencyIsoCode,  
                                            LAT_TotalValue__c, 
                                            CreatedDate, 
                                            LAT_Type__c, 
                                            LAT_Account__r.Name, 
                                            LAT_Account__c, 
                                            Name, 
                                            LAT_NROrderJDE__c, 
                                            (SELECT Id, Name, LAT_LegalInvoice__c, LAT_B2B_Estado_Calico__c, LAT_AR_B2B_Status__c 
                                            FROM LAT_Fiscal_Notes__r 
                                            ORDER BY LAT_DueDate__c ) 
                                        FROM LAT_Opportunity__c  
                                        WHERE LAT_Account__c =: strAccountId  
                                        AND Id =: lstFiscalNotes[0].LAT_Opportunity__c 
                                        LIMIT 1];
                    System.debug('getlastOrder [lstOpportunity : ' + lstOpportunity + ']'); 
                    if(!lstOpportunity.IsEmpty()) {
                        objResult = lstOpportunity[0];
                    } else {
                        throw new AuraHandledException(JSON.serializePretty(new B2BCustomError(true, false, 100, 'No se ha encontrado información de la oportunidad asociada a la nota fiscal.'))) ;
                    }
                } else {           
                    lstOpportunity = [SELECT Id, 
                                            CurrencyIsoCode,  
                                            LAT_TotalValue__c, 
                                            CreatedDate, 
                                            LAT_Type__c, 
                                            LAT_Account__r.Name, 
                                            LAT_Account__c, 
                                            Name, 
                                            LAT_NROrderJDE__c, 
                                            (SELECT Id, Name, LAT_LegalInvoice__c, LAT_B2B_Estado_Calico__c,LAT_AR_B2B_Status__c, LAT_DueDate__c FROM LAT_Fiscal_Notes__r ORDER BY LAT_DueDate__c) 
                                        FROM LAT_Opportunity__c  
                                        WHERE LAT_Account__c =: strAccountId  
                                        ORDER BY CreatedDate DESC 
                                        LIMIT 1];
                    System.debug('getlastOrder [strAccountId : ' + strAccountId + ']'); 
                    System.debug('getlastOrder [lstOpportunity : ' + lstOpportunity + ']'); 

                    if(!lstOpportunity.IsEmpty()) {
                        objResult = lstOpportunity[0];
                    } else {
                        throw new AuraHandledException(JSON.serializePretty(new B2BCustomError(true, false, 200, 'No se ha encontrado información de la oportunidad asociada a la nota fiscal.'))) ;
                    }                        
                } 
            } else {
                throw new AuraHandledException(JSON.serializePretty(new B2BCustomError(true, false, 300, 'No se ha encontrado información del contacto o la cuenta.'))) ; 
            }
        } catch(Exception Ex) {
            throw new AuraHandledException(JSON.serializePretty(new B2BCustomError(true, false, 999, Ex))) ;
        }

        System.debug('getlastOrder [' + objResult + '] <-');

        return objResult;
    }

    /*
    * getlastOrder
    * TO DO: Add a filter LAT_LeadSource__c
    */
    @AuraEnabled
    public static LAT_Opportunity__c getOpenOrder() {
        Id accountId = null;
        String unidadDeNegocios = '01';
        List<LAT_Opportunity__c> foundOpps = null;
        LAT_Opportunity__c objResult = null;

        System.debug('getOpenOrder [] ->');

        try {
            accountId = getAccountId();
            foundOpps =  [SELECT  LAT_Account__r.Business_Unit_AR__r.CodDefUsuario__c, 
                                                            (SELECT Id, 
                                                                    LAT_QTTotal__c, 
                                                                    CurrencyIsoCode, 
                                                                    LAT_StatusDescription__c,  
                                                                    LAT_UnitCode__c,  
                                                                    LAT_UnitPrice__c,
                                                                    LAT_PriceTotal__c,  
                                                                    LAT_Product__r.LAT_ScheduleC__c,  
                                                                    LAT_Product__r.LAT_ScheduleC__r.Name, 
                                                                    LAT_Product__r.LAT_B2B_Product_Name__c, 
                                                                    LAT_Product__r.LAT_B2B_Thumbnail_URL__c, 
                                                                    LAT_Product__r.Name, 
                                                                    LAT_Product__r.LAT_Sku__c, 
                                                                    LAT_PcDiscount__c, 
                                                                    LAT_Quantity__c, 
                                                                    LAT_BottlesPerBoxFormula__c, 
                                                                    LAT_UnitIva__c, 
                                                                    LAT_UnitIibb__c,
                                                                    LAT_AR_IvaTotal__c, 
                                                                    LAT_AR_TotalIBB__c, 
                                                                    LAT_AR_TotalImpIncuidos__c  
                                                            FROM  OpportunityLineItems__r), 
                                                            Id, 
                                                            CurrencyIsoCode,  
                                                            LAT_TotalValue__c, 
                                                            CreatedDate, 
                                                            LAT_Type__c, 
                                                            LAT_Account__r.Name, 
                                                            LAT_Account__c, 
                                                            Name, 
                                                            LAT_NROrderJDE__c, 
                                                            LAT_NRCustomerOrder__c,
                                                            LAT_Account__r.Corporate_Name__c, 
                                                            LAT_Account__r.CNPJ__c, 
                                                            LAT_Account__r.AddressLine1_AR__c, 
                                                            LAT_DSMessage1__c, 
                                                            LAT_DSMessage2__c
                                                    FROM LAT_Opportunity__c  
                                                    WHERE LAT_Account__c = :accountId 
                                                    AND LAT_StageName__c = 'Novo Pedido' 
                                                    AND LAT_LeadSource__c = 'B2B' 
                                                    ORDER BY LastModifiedDate DESC 
                                                    LIMIT 1] ;
            
            if (foundOpps.size() == 0) {
                LAT_GeneralConfig__C conf = LAT_GeneralConfig__C.getInstance('AR_B2B_OrderNumer');
                Integer currentValue = Integer.valueOf(conf.LAT_Value__c);
                currentValue++;
                String currentValueStr = String.valueOf(currentValue);
                LAT_Opportunity__c newOpp = new LAT_Opportunity__c();
                
                newOpp.LAT_Account__c = accountId;
                newOpp.LAT_StageName__c = 'Novo Pedido';
                newOpp.LAT_LeadSource__c='B2B';
                newOpp.RecordTypeId = Global_RecordTypeCache.getRtId('LAT_Opportunity__c'+'OPP_1_NewOrder_ARG');
                newOpp.LAT_NRCustomerOrder__c = 'B2B-'+currentValueStr;
                newOpp.LAT_CloseDate__c = Date.today();
                newOpp.Name  = 'B2B-' + currentValueStr;
                
                System.debug('getOpenOrder[newOpp.CurrencyIsoCode : ' + newOpp.CurrencyIsoCode + ']');
                System.debug('getOpenOrder[newOpp.LAT_Account__r.CurrencyIsoCode : ' + newOpp.LAT_Account__r.CurrencyIsoCode + ']');

                
                insert newOpp;

                conf.LAT_Value__c = currentValueStr;
                
                update conf;
                foundOpps.add(newOpp);
            } else {
                Set<Id> prodIds = new Set<Id>();
                LAT_Opportunity__c opp = foundOpps[0];
                unidadDeNegocios = opp.LAT_Account__r.Business_Unit_AR__r.CodDefUsuario__c != null ? opp.LAT_Account__r.Business_Unit_AR__r.CodDefUsuario__c : unidadDeNegocios;
                for(LAT_OpportunityLineItem__c oli : opp.OpportunityLineItems__r){
                    prodIds.add(oli.LAT_Product__c);
                }
                Map<Id, LAT_Product__c> prods = new Map<Id, LAT_Product__c>([SELECT Id, LAT_MX_ClientStock__c, LAT_MX_StockPRM__c, LAT_BottlesPerBox__c,
                                                                                    (SELECT LAT_Stock__c FROM Lat_StocksList__r WHERE LAT_Branch__c =: unidadDeNegocios LIMIT 1)
                                                                            FROM LAT_Product__c 
                                                                            WHERE Id IN :prodIds]);
                for(LAT_OpportunityLineItem__c oli : opp.OpportunityLineItems__r){
                    if(prods.get(oli.LAT_Product__c).Lat_StocksList__r != null) {
                        Double stockInBt = prods.get(oli.LAT_Product__c).Lat_StocksList__r[0].LAT_Stock__c;
                        oli.LAT_Product__r.LAT_MX_StockPRM__c = stockInBt;//stock en botellas
                        if(prods.get(oli.LAT_Product__c).LAT_BottlesPerBox__c!=null && prods.get(oli.LAT_Product__c).LAT_BottlesPerBox__c !=0){
                            oli.LAT_Product__r.LAT_MX_ClientStock__c = Math.floor(stockInBt /prods.get(oli.LAT_Product__c).LAT_BottlesPerBox__c );//stock en cajas
                        }
                        
                    }
                }
            }
            objResult = foundOpps[0];
        } catch(Exception Ex) {
            LAT_Utils.handleException('getOpenOrder', Ex);
            throw new AuraHandledException(JSON.serializePretty(new B2BCustomError(true, false, 999, Ex))) ;
        }

        System.debug('getOpenOrder [' + objResult + '] <-');

        return objResult;
    }

    @AuraEnabled
    public static LAT_Opportunity__c getOrder(String orderId) {
        String strBaseUrl = null;
        LAT_Opportunity__c oppty = null;
        
        System.debug('getOrder [orderId : ' + orderId + '] ->');

        try {
            strBaseUrl = retrieveCommunityBaseUrl();
            final Id accountId = getAccountId();
            
            List<LAT_Opportunity__c> foundOpps =  [SELECT (SELECT Id, LAT_QTTotal__c,  CurrencyIsoCode, LAT_StatusDescription__c,  LAT_UnitCode__c,  LAT_UnitPrice__c,
                                                                LAT_PriceTotal__c,  LAT_Product__r.LAT_ScheduleC__c,  LAT_Product__r.LAT_ScheduleC__r.Name, LAT_Product__r.LAT_B2B_Product_Name__c, LAT_Product__r.LAT_B2B_Thumbnail_URL__c, 
                                                                LAT_Product__r.Name, LAT_Product__r.LAT_Sku__c, LAT_PcDiscount__c, LAT_Quantity__c, LAT_BottlesPerBox__c, LAT_UnitIva__c, LAT_UnitIibb__c ,
                                                                LAT_AR_IvaTotal__c, LAT_AR_TotalIBB__c, LAT_AR_TotalImpIncuidos__c
                                                            FROM  OpportunityLineItems__r), 
                                                            Id, CurrencyIsoCode,  LAT_TotalValue__c, CreatedDate, LAT_Type__c, LAT_Account__r.Name, LAT_Account__c, Name, LAT_NROrderJDE__c, LAT_NRCustomerOrder__c,
                                                            LAT_Account__r.Corporate_Name__c, LAT_Account__r.CNPJ__c, LAT_Account__r.AddressLine1_AR__c, LAT_DSMessage1__c, LAT_DSMessage2__c, LAT_StageName__c, LAT_NextStep__c,
                                                            LAT_AR_IIBB__c, LAT_AR_IVA__c, LAT_AR_TotalImpuestosInculidos__c
                                                    FROM LAT_Opportunity__c  
                                                    WHERE LAT_Account__c =: accountId 
                                                    AND LAT_LeadSource__c = 'B2B' 
                                                    AND Id =: orderId 
                                                    ORDER BY LastModifiedDate DESC LIMIT 1];
                    
            if (!foundOpps.isEmpty()) {
                oppty = foundOpps[0];
                // Load tracking Number to the Next Step temporary field
                final List <LAT_FiscalNote__c> notasFiscales = [SELECT Id, LAT_Opportunity__c, LAT_LegalInvoice__c, (SELECT ID, Name FROM Attachments) FROM LAT_FiscalNote__c WHERE LAT_Opportunity__c =: orderId];
                for (LAT_FiscalNote__c nf : notasFiscales) {
                    if (nf.Attachments != null) {
                        for (Attachment att : nf.Attachments) {
                            if (att.Name.contains(nf.LAT_LegalInvoice__c)) {
                                oppty.LAT_NextStep__c = strBaseUrl + '/servlet/servlet.FileDownload?file=' + att.Id;
                            }
                        }
                    } else {
                        System.debug('%%%% no hay Attachments');
                    }
                }
            }
        } catch(Exception Ex) {
            throw new AuraHandledException(JSON.serializePretty(new B2BCustomError(true, false, 999, Ex))) ;
        }
        System.debug('getOrder [' + oppty + '] <-');

        return oppty;
    }

    @AuraEnabled
    public static String saveOpportunity(LAT_Opportunity__c record, List<LAT_OpportunityLineItem__c> items) {
        Id objOpportunityId = null;

        System.debug('saveOpportunity [ record : ' + record + ' - items : ' + items + '] ->');

        try {
            final Id devRecordTypeId = Schema.SObjectType.LAT_Opportunity__c.getRecordTypeInfosByDeveloperName().get('OPP_1_NewOrder_ARG').getRecordTypeId();
            record.RecordTypeId = devRecordTypeId;
            record.LAT_CloseDate__c = Date.today();
            record.LAT_StageName__c = 'Novo Pedido';
            record.LAT_DTDelivery__c =  Date.today().addDays(7);
            record.LAT_LeadSource__c = 'B2B';
            insert record;

            // Set the parent Id
            for (LAT_OpportunityLineItem__c item: items) {
                item.LAT_Opportunity__c = record.Id;
            }
            insert items;
        
            system.debug('Save  ' + record);
            system.debug('items ' + items);

            objOpportunityId = record.Id;
        } catch(Exception Ex) {
            throw new AuraHandledException(JSON.serializePretty(new B2BCustomError(true, false, 999, Ex))) ;
        }
        System.debug('saveOpportunity [' + objOpportunityId + '] <-');

        return objOpportunityId;
   }

    @AuraEnabled
    public static Id insertLineItem(LAT_OpportunityLineItem__c record) {
        String strResult = null;

        System.debug('insertLineItem[ record ' + record + '] ->');
        try {
            insert record;
            strResult = record.Id;
        } catch (Exception Ex) {
            throw new AuraHandledException(JSON.serializePretty(new B2BCustomError(true, false, 999, Ex))) ;
        }

        System.debug('insertLineItem[' + strResult + '] <-');

        return strResult;
    }

    @AuraEnabled
    public static String updateLineItem(LAT_OpportunityLineItem__c record) {
        String strResult = null;

        System.debug('updateLineItem[ record ' + record + '] ->');
        try {
            update record;
            strResult = 'saved';
        } catch (Exception Ex) {
            //throw new AuraHandledException(JSON.serializePretty(new B2BCustomError(true,false, 999, Ex))) ;
        }

        System.debug('updateLineItem[' + strResult + '] <-');

        return strResult;
    }

    @AuraEnabled
    public static String deleteProductItem(LAT_OpportunityLineItem__c record) {
        String strResult = null;
        System.debug('deleteProductItem [record : ' + record + '] ->');

        try {
            delete record;
            strResult = 'delete';
        } catch(Exception Ex) {
            throw new AuraHandledException(JSON.serializePretty(new B2BCustomError(true, false, 999, Ex))) ;
        }

        System.debug('deleteProductItem [' + strResult + '] <-');

        return strResult;
    }

    @AuraEnabled
    public static String setCommentarios(String oppId, String comments) {        
        String strResult = null;

        System.debug('setCommentarios [oppId : ' + oppId + ' - comments : ' + comments + '] ->');
 
        try {
            if(comments !=null && comments != ''){
                LAT_Opportunity__c opp = new LAT_Opportunity__c();
                opp.Id = oppId;
                if(comments.length() > 30){
                    opp.LAT_DSMessage1__c = comments.substring(0, 29);
                    opp.LAT_DSMessage2__c = comments.substring(30, comments.length()-1);
                } else {
                    opp.LAT_DSMessage1__c = comments;
                }
                update opp;
            }

            strResult = '';
        } catch(Exception Ex) {
            throw new AuraHandledException(JSON.serializePretty(new B2BCustomError(true, false, 999, Ex))) ;
        }

        System.debug('setCommentarios [' + strResult + '] <-');

        return strResult;
    }

    @AuraEnabled
    public static Object reOrderOppty (String opptyId) {
        LAT_Opportunity__c clonedOppty = null;
        
        System.debug('reOrderOppty [opptyId : ' + opptyId + '] ->');

        try {
            LAT_Opportunity__c originalOpportunity = [SELECT LAT_DTDelivery__c, LAT_DSMessage1__c, LAT_DSMessage2__c, 
                                                            (SELECT Id, LAT_AR_SentToApproveDiscount__c, LAT_AR_MaxDiscount__c, LAT_QTTotal__c, LAT_QTBonus__c, CurrencyIsoCode, LAT_StatusDescription__c, 
                                                                    LAT_PaymentCondition__c, LAT_PaymentConditionDescription__c , LAT_UnitCode__c, LAT_PercentualBonus__c , LAT_UnitPrice__c,LAT_Product__c,
                                                                    LAT_PriceTotal__c, LAT_CdLineStatus__c, LAT_Product__r.LAT_ScheduleC__c, LAT_AR_Discount__c, LAT_Discount__c,  
                                                                    LAT_Product__r.LAT_ScheduleC__r.KeyBrand__c, LAT_Product__r.LAT_ScheduleC__r.KeyBrand__r.ImageURL__c, LAT_Product__r.Name, 
                                                                    LAT_Product__r.LAT_Sku__c, LAT_PcDiscount__c, LAT_Quantity__c, LAT_BottlesPerBox__c, LAT_UnitIva__c, LAT_UnitIibb__c, LAT_SkuText__c, LAT_AR_UOM__c
                                                            FROM  OpportunityLineItems__r 
                                                            ORDER BY LAT_Product__r.Name), 
                                                            Id, CurrencyIsoCode, LAT_TotalValue__c, CreatedDate, LAT_Type__c, LAT_ClientCodeAN8__c ,LAT_Account__r.name, LAT_Account__r.Business_Unit_AR__r.CodDefUsuario__c ,LAT_Account__r.Business_Unit__r.CodDefUsuario__c,  LAT_Account__c, Name,LAT_Country__c, LAT_NROrderJDE__c, LAT_Account__r.Sub_Channel_Rating__r.Internal_Id__c, LAT_Account__r.LAT_Account__r.LAT_SubCanalExento__r.Internal_Id__c, LAT_Account__r.LAT_Account__r.LAT_SubCanalExento__c
                                                    FROM LAT_Opportunity__c  
                                                    WHERE Id =: opptyId];
            Set<Id> productsToCheck = new Set<Id>();
            for(LAT_OpportunityLineItem__c originalLineItem : originalOpportunity.OpportunityLineItems__r){
                productsToCheck.add(originalLineItem.LAT_Product__c);
            }
            //Busco los acc prod payments existentes para este m
            List <LAT_Account_product_payment__c> accountProductPayments = 
                                                                [SELECT LAT_Product__c
                                                                    FROM LAT_Account_product_payment__c
                                                                    WHERE account__c =: originalOpportunity.LAT_Account__c
                                                                    AND LAT_Product__r.LAT_IsRefactorProduct__c = 'Y'
                                                                    AND LAT_Product__r.LAT_IsActive__c = true
                                                                    AND LAT_Product__c IN :productsToCheck];

            Set<Id> validProducts = new Set<Id>();
            for(LAT_Account_product_payment__c app : accountProductPayments){
                validProducts.add(app.LAT_Product__c);
            }
            String subCanal = originalOpportunity.LAT_Account__r.LAT_Account__r.LAT_SubCanalExento__c != null ? originalOpportunity.LAT_Account__r.LAT_Account__r.LAT_SubCanalExento__r.Internal_Id__c : originalOpportunity.LAT_Account__r.Sub_Channel_Rating__r.Internal_Id__c;
            List<LAT_AR_B2B_ProductPricesByChannel__c> precios = [SELECT Id, LAT_AR_UOM__c, LAT_Price__c, LAT_Iva__c, LAT_Iibb__c, LAT_Product__c 
                                                                    FROM LAT_AR_B2B_ProductPricesByChannel__c
                                                                    WHERE LAT_Product__c IN :validProducts 
                                                                    AND LAT_Channel__c = :subCanal];
            Map<String, LAT_AR_B2B_ProductPricesByChannel__c> pricesMap = new Map<String, LAT_AR_B2B_ProductPricesByChannel__c>();
            for(LAT_AR_B2B_ProductPricesByChannel__c precio : precios){
                pricesMap.put(precio.LAT_Product__c+'-'+precio.LAT_AR_UOM__c, precio);
            }

            // Numero de Pedido
            LAT_GeneralConfig__C conf = LAT_GeneralConfig__C.getInstance('AR_B2B_OrderNumer');
            Integer currentValue = Integer.valueOf(conf.LAT_Value__c);
            currentValue++;
            final String currentValueStr = String.valueOf(currentValue);
            conf.LAT_Value__c = currentValueStr;
            update conf;
            

            // Clone oppty
            final Id devRecordTypeId = Schema.SObjectType.LAT_Opportunity__c.getRecordTypeInfosByDeveloperName().get('OPP_1_NewOrder_ARG').getRecordTypeId();
            clonedOppty = originalOpportunity.clone(false, true);
            clonedOppty.RecordTypeId = devRecordTypeId;
            clonedOppty.LAT_CloseDate__c = Date.today();
            clonedOppty.LAT_StageName__c = 'Novo Pedido';
            clonedOppty.LAT_LeadSource__c = 'B2B';
            clonedOppty.LAT_NRCustomerOrder__c = 'B2B-' + currentValueStr;
            clonedOppty.Name  = 'B2B-' + currentValueStr;
            clonedOppty.LAT_NROrderJDE__c = '';
            clonedOppty.LAT_JDEOrderKey__c = '';

            insert clonedOppty;

            // Clone Line Items
            List <LAT_OpportunityLineItem__c> orderLineItemsClones =  new List <LAT_OpportunityLineItem__c>();
            for (LAT_OpportunityLineItem__c originalLineItem : originalOpportunity.OpportunityLineItems__r) {
                if(validProducts.contains(originalLineItem.LAT_Product__c)){
                    LAT_OpportunityLineItem__c clonedLineItem = originalLineItem.clone(false, false);
                    LAT_AR_B2B_ProductPricesByChannel__c precio = pricesMap.get(originalLineItem.LAT_Product__c+'-'+originalLineItem.LAT_AR_UOM__c);
                    clonedLineItem.LAT_StatusDescription__c = null;
                    clonedLineItem.LAT_CdLineStatus__c = null;
                    clonedLineItem.LAT_Opportunity__c = clonedOppty.Id;
                    clonedLineItem.LAT_UnitPrice__c = precio.LAT_Price__c;
                    clonedLineItem.LAT_UnitIva__c = precio.LAT_Iva__c;
                    clonedLineItem.LAT_UnitIibb__c = precio.LAT_Iibb__c;
                    orderLineItemsClones.add(clonedLineItem);
                }
                
            }

            insert orderLineItemsClones;
        } catch(Exception Ex) {
            throw new AuraHandledException(JSON.serializePretty(new B2BCustomError(true, false, 999, Ex))) ;
        }

        System.debug('reOrderOppty [' + clonedOppty + '] <-');

        return clonedOppty;
    }
    
    @AuraEnabled
    public static List<LAT_FiscalNote__c> getPendingFiscalNotes(){
        Id strAccountId = null;
        List<LAT_FiscalNote__c> lstResult = null;

        System.debug('getPendingFiscalNotes [] ->');

        strAccountId = getAccountId();
        if(String.isNotBlank(strAccountId)) {
            lstResult = [SELECT Id, 
                                LAT_Opportunity__r.LAT_NROrderJDE__c, 
                                LAT_DueDate__c, 
                                LAT_Balance__c, 
                                LAT_LegalInvoice__c, 
                                LAT_B2B_Estado_Calico__c,
                                LAT_AR_B2B_Status__c 
                        FROM LAT_FiscalNote__c 
                        WHERE LAT_AR_B2B_Status__c IN ('A Pagar','Pago Informado') 
                        AND LAT_Client__c =: strAccountId  
                        ORDER BY LAT_BillingDate__c];
        } else {
            throw new AuraHandledException(JSON.serializePretty(new B2BCustomError(true, false, 100, 'No se ha encontrado información del contacto o de la cuenta.'))) ;
        }

        System.debug('getPendingFiscalNotes [' + lstResult + '] <-');
        return lstResult;
    }

    @AuraEnabled
    public static List<LAT_FiscalNote__c> getTrackingFiscalNotes(){
        Id accountId = getAccountId();
        
        return [SELECT Id, LAT_B2B_Estado_Calico__c, LAT_B2B_URL_Calico__c ,LAT_Opportunity__r.LAT_NROrderJDE__c,LAT_Opportunity__r.LAT_CloseDate__c,LAT_Opportunity__c, LAT_Opportunity__r.LAT_TotalValue__c, LAT_LegalInvoice__c,LAT_AR_B2B_Status__c 
        FROM LAT_FiscalNote__c 
        where LAT_B2B_Estado_Calico__c IN :LAT_CTY_B2B_PendingFiscalNotesCont.TRACKING_STATUS  
        AND LAT_Client__c =:accountId  
        ORDER BY createdDate DESC] ;
    }

    @AuraEnabled
    public static String getSemaforoStatus() {
        Id strAccountId = null;
        List<LAT_FiscalNote__c> lstResult = null;
        String strSemaforo = null;

        System.debug('getSemaforoStatus [] ->');

        try {
            strSemaforo = 'Amarillo';
            strAccountId = getAccountId();
            
            lstResult = [SELECT Id, 
                                LAT_Opportunity__r.LAT_NROrderJDE__c, 
                                LAT_LegalInvoice__c, 
                                LAT_B2B_Estado_Calico__c, 
                                LAT_AR_B2B_Status__c,
                                LAT_DueDate__c, 
                                LAT_Balance__c
                        FROM LAT_FiscalNote__c 
                        WHERE LAT_AR_B2B_Status__c IN ('A Pagar','Pago Informado') 
                        AND LAT_Client__c =: strAccountId  
                        ORDER BY LAT_DueDate__c];
            
            for(LAT_FiscalNote__c objFiscalNote : lstResult){
                System.debug('getSemaforoStatus [ objFiscalNote : ' + objFiscalNote + ']');
                if(objFiscalNote.LAT_DueDate__c != NULL) {
                    if(Date.today() <= objFiscalNote.LAT_DueDate__c) {
                        System.debug('getSemaforoStatus [ Date.today().daysBetween(fn.LAT_DueDate__c) : ' + Date.today().daysBetween(objFiscalNote.LAT_DueDate__c) + ']');

                        if(Date.today().daysBetween(objFiscalNote.LAT_DueDate__c) < 8){
                            strSemaforo = 'Amarillo';
                        } else  {
                            strSemaforo = 'Verde';
                        }
                    } else {
                        strSemaforo = 'Rojo';
                    }            
                }
            } 
        } catch (Exception Ex) {
            throw new AuraHandledException(JSON.serializePretty(new B2BCustomError(true, false, 999, Ex))) ;
        }

        System.debug('getSemaforoStatus [' + strSemaforo + '] <-');

        return strSemaforo;                   
    }

    @AuraEnabled
    public static Lat_Product__c getProduct (String productId) {
        Lat_Product__c ret = null;

        System.debug('getProduct [productId : ' + productId + '] ->');

        try {
            final String unidadDeNegocios = '01';
            final Id accountId = getAccountId();
            Account c = [SELECT Id, Client_country_AN8__c, Sub_Channel_Rating__r.Internal_Id__c, LAT_Account__r.LAT_SubCanalExento__c, 
                            LAT_Account__r.LAT_SubCanalExento__r.Internal_Id__c 
                            FROM Account 
                            WHERE  Id = :accountId];

            String subCanal = c.LAT_Account__r.LAT_SubCanalExento__c != null ? c.LAT_Account__r.LAT_SubCanalExento__r.Internal_Id__c : c.Sub_Channel_Rating__r.Internal_Id__c;
            
            ret = [SELECT Id, Name, LAT_EAN__c, LAT_B2B_Alcohol_Level__c, LAT_B2B_Brand__c, LAT_B2B_Brand_Quality__c, LAT_B2B_Country__c, LAT_B2B_Description__c,
                                                                LAT_B2B_Ingredients__c, LAT_B2B_Manufacturer_Details__c, LAT_B2B_Packaging_Details__c, LAT_B2B_Product_History__c, LAT_B2B_Product_Name__c,
                                                                LAT_B2B_Quality__c, LAT_B2B_Size_Label__c, LAT_B2B_Size_Value__c, LAT_B2B_Image_URL__c, LAT_B2B_Thumbnail_URL__c, LAT_SKU__c,
                                                                LAT_CDUnit__c, LAT_BottlesPerBox__c, LAT_UnitWeight__c, LAT_B2B_MinimumStock__c, LAT_IsActive__c, LAT_B2B_Visibility__c,
                                                                (SELECT LAT_Price__c, LAT_PriceWithoutOffer__c, LAT_AR_UOM__c, LAT_Iibb__c, LAT_Iva__c, LAT_OfferIva__c, LAT_OfferIibb__c FROM Precios_Productos_B2B__r WHERE LAT_Channel__c = : subCanal),
                                                                (SELECT LAT_Stock__c FROM Lat_StocksList__r WHERE LAT_Branch__c =:unidadDeNegocios LIMIT 1)
                                                      FROM LAT_Product__c WHERE Id =: productId];
        } catch(Exception Ex) {
            throw new AuraHandledException(JSON.serializePretty(new B2BCustomError(true, false, 999, Ex))) ;
        }

        System.debug('getProduct [' + ret + '] <-');

        return ret;
    }

    
    
    @AuraEnabled(cacheable=true)
    public static String getProducts (Integer offSet) {
        String strResult = null;
        System.debug('getProducts [offSet : ' + offSet + '] ->');

        try{
            //Contact c = getContact();
            String unidadDeNegocios = '01';
            Id accountId = getAccountId();
            if(accountId != null) {

                Account c = [SELECT Id, Client_country_AN8__c, Sub_Channel_Rating__r.Internal_Id__c, LAT_Account__r.LAT_SubCanalExento__r.Internal_Id__c,
                            LAT_Account__r.LAT_SubCanalExento__c FROM Account WHERE  Id = :accountId];
                String subCanal = c.LAT_Account__r.LAT_SubCanalExento__c != null ? c.LAT_Account__r.LAT_SubCanalExento__r.Internal_Id__c : c.Sub_Channel_Rating__r.Internal_Id__c;
                final List <LAT_Account_product_payment__c> accountProductPayments = 
                                                            [SELECT LAT_Product__r.Id, Account__r.Business_Unit_AR__c, Account__r.Business_Unit_AR__r.CodDefUsuario__c
                                                                   FROM LAT_Account_product_payment__c
                                                                   WHERE account__c =: accountId
                                                                   AND LAT_Product__r.LAT_IsRefactorProduct__c = 'Y'
                                                                   AND LAT_Product__r.LAT_IsActive__c = true ];
                List <String> productIds = new List <String>();
                for (LAT_Account_product_payment__c app : accountProductPayments) {
                    productIds.add(app.LAT_Product__r.Id);
                    if(app.Account__r.Business_Unit_AR__c != null) {
                        unidadDeNegocios = app.Account__r.Business_Unit_AR__r.CodDefUsuario__c;
                    }
                }
                System.debug('%%% subCanal: ' +  subCanal);
                List <Lat_Product__c> returnProducts = [SELECT Id, Name, LAT_EAN__c, LAT_B2B_Alcohol_Level__c, LAT_B2B_Brand__c, LAT_B2B_Brand_Quality__c, LAT_B2B_Country__c, LAT_B2B_Description__c,
                                                            LAT_B2B_Ingredients__c, LAT_B2B_Manufacturer_Details__c, LAT_B2B_Packaging_Details__c, LAT_B2B_Product_History__c, LAT_B2B_Product_Name__c,
                                                            LAT_B2B_Quality__c, LAT_B2B_Size_Label__c, LAT_B2B_Size_Value__c, LAT_B2B_Image_URL__c, LAT_B2B_Thumbnail_URL__c, LAT_SKU__c,
                                                            LAT_CDUnit__c, LAT_BottlesPerBox__c, LAT_UnitWeight__c, LAT_B2B_MinimumStock__c, LAT_IsActive__c, LAT_B2B_Visibility__c,
                                                            (SELECT LAT_Price__c, LAT_PriceWithoutOffer__c, LAT_AR_UOM__c, LAT_Iibb__c, LAT_Iva__c, LAT_OfferIva__c, LAT_OfferIibb__c FROM Precios_Productos_B2B__r WHERE LAT_Channel__c = : subCanal ORDER BY LAT_AR_UOM__c ),
                                                            (SELECT LAT_Stock__c FROM Lat_StocksList__r WHERE LAT_Branch__c =:unidadDeNegocios LIMIT 1)
                                                            FROM LAT_Product__c WHERE Id in:productIds AND LAT_B2B_Visibility__c <> 'Oculto' ORDER BY LAT_B2B_OrderInShoppingCart__c DESC NULLS LAST LIMIT 20 OFFSET :offset];

                for(Lat_Product__c p : returnProducts){
                    if(p.Lat_StocksList__r.size() > 0) {
                        if(p.LAT_B2B_MinimumStock__c != null) {
                            if(p.Lat_StocksList__r[0].LAT_Stock__c < p.LAT_B2B_MinimumStock__c){
                                p.LAT_IsActive__c = false;
                            }
                        } else {
                            if(p.Lat_StocksList__r[0].LAT_Stock__c ==0) {
                                p.LAT_IsActive__c = false;
                            }
                        }
                    } 
                }
                System.debug('%%%% returnProducts[0] : ' + returnProducts[0]);
                System.debug('%%%% returnProducts[0].Precios_Productos_B2B__r : ' + returnProducts[0].Precios_Productos_B2B__r);
                strResult = JSON.serialize(returnProducts);  
            } else {
                strResult = null;  
            }
            
        } catch(Exception Ex) {
            throw new AuraHandledException(JSON.serializePretty(new B2BCustomError(true, false, 999, Ex))) ;
        }

        System.debug('getProducts [' + strResult + '] <-');

        return strResult;
    }

    @AuraEnabled(cacheable=true)
    public static String getProductsDynamic (String key) {
        String strResult = null;

        System.debug('getProductsDynamic [key : ' + key + '] ->');

        try {
            key = '%' + key + '%';
            //Contact c = getContact();
            String unidadDeNegocios = '01';
            Id accountId = getAccountId();
            if(accountId != null) {

                Account c = [SELECT Id, Client_country_AN8__c, Sub_Channel_Rating__r.Internal_Id__c, LAT_Account__r.LAT_SubCanalExento__r.Internal_Id__c,
                            LAT_Account__r.LAT_SubCanalExento__c FROM Account WHERE  Id = :accountId];
                String subCanal = c.LAT_Account__r.LAT_SubCanalExento__c != null ? c.LAT_Account__r.LAT_SubCanalExento__r.Internal_Id__c : c.Sub_Channel_Rating__r.Internal_Id__c;
                final List <LAT_Account_product_payment__c> accountProductPayments = 
                                                            [SELECT LAT_Product__r.Id, Account__r.Business_Unit_AR__c, Account__r.Business_Unit_AR__r.CodDefUsuario__c
                                                                   FROM LAT_Account_product_payment__c
                                                                   WHERE account__c =: accountId
                                                                   AND LAT_Product__r.LAT_IsRefactorProduct__c = 'Y'
                                                                   AND LAT_Product__r.LAT_IsActive__c = true ];
                List <String> productIds = new List <String>();
                for (LAT_Account_product_payment__c app : accountProductPayments) {
                    productIds.add(app.LAT_Product__r.Id);
                    if(app.Account__r.Business_Unit_AR__c != null) {
                        unidadDeNegocios = app.Account__r.Business_Unit_AR__r.CodDefUsuario__c;
                    }
                }
                System.debug('%%% subCanal: ' +  subCanal);
                List <Lat_Product__c> returnProducts = [SELECT Id, Name, LAT_EAN__c, LAT_B2B_Alcohol_Level__c, LAT_B2B_Brand__c, LAT_B2B_Brand_Quality__c, LAT_B2B_Country__c, LAT_B2B_Description__c,
                                                            LAT_B2B_Ingredients__c, LAT_B2B_Manufacturer_Details__c, LAT_B2B_Packaging_Details__c, LAT_B2B_Product_History__c, LAT_B2B_Product_Name__c,
                                                            LAT_B2B_Quality__c, LAT_B2B_Size_Label__c, LAT_B2B_Size_Value__c, LAT_B2B_Image_URL__c, LAT_B2B_Thumbnail_URL__c, LAT_SKU__c,
                                                            LAT_CDUnit__c, LAT_BottlesPerBox__c, LAT_UnitWeight__c, LAT_B2B_MinimumStock__c, LAT_IsActive__c, LAT_B2B_Visibility__c,
                                                            (SELECT LAT_Price__c, LAT_PriceWithoutOffer__c, LAT_AR_UOM__c, LAT_Iibb__c, LAT_Iva__c, LAT_OfferIva__c, LAT_OfferIibb__c FROM Precios_Productos_B2B__r WHERE LAT_Channel__c = : subCanal ORDER BY LAT_AR_UOM__c ),
                                                            (SELECT LAT_Stock__c FROM Lat_StocksList__r WHERE LAT_Branch__c =:unidadDeNegocios LIMIT 1)
                                                            FROM LAT_Product__c WHERE Id in:productIds AND LAT_B2B_SpotLight__c LIKE :key ORDER BY LAT_B2B_OrderInShoppingCart__c DESC NULLS LAST];

                for(Lat_Product__c p : returnProducts){
                    if(p.Lat_StocksList__r.size() > 0) {
                        if(p.LAT_B2B_MinimumStock__c != null) {
                            if(p.Lat_StocksList__r[0].LAT_Stock__c < p.LAT_B2B_MinimumStock__c){
                                p.LAT_IsActive__c = false;
                            }
                        } else {
                            if(p.Lat_StocksList__r[0].LAT_Stock__c ==0) {
                                p.LAT_IsActive__c = false;
                            }
                        }
                    } 
                }
                System.debug('%%%% returnProducts[0] : ' + returnProducts[0]);
                System.debug('%%%% returnProducts[0].Precios_Productos_B2B__r : ' + returnProducts[0].Precios_Productos_B2B__r);
                strResult = JSON.serialize(returnProducts);  
            } else {
                strResult = null;  
            }
            
        } catch(Exception Ex) {
            throw new AuraHandledException(JSON.serializePretty(new B2BCustomError(true, false, 999, Ex))) ;
        }
        System.debug('getProductsDynamic [' + strResult + '] <-');

        return strResult;
    }

    @AuraEnabled 
    public static String getHighlightedProducts (Integer rowNumber) {        
        String strResult = null;

        System.debug('getHighlightedProducts [rowNumber : ' + rowNumber + '] ->');

        try {
            rowNumber*=4;

            //Contact c = getContact();
            String unidadDeNegocios = '01';
            Id accountId = getAccountId();
            if(accountId != null) {

                Account c = [SELECT Id, Client_country_AN8__c, Sub_Channel_Rating__r.Internal_Id__c, LAT_Account__r.LAT_SubCanalExento__r.Internal_Id__c,
                                LAT_Account__r.LAT_SubCanalExento__c FROM Account WHERE  Id = :accountId];
                String subCanal = c.LAT_Account__r.LAT_SubCanalExento__c != null ? c.LAT_Account__r.LAT_SubCanalExento__r.Internal_Id__c : c.Sub_Channel_Rating__r.Internal_Id__c;

                final List <LAT_Account_product_payment__c> accountProductPayments = 
                                                            [SELECT LAT_Product__r.Id, Account__r.Business_Unit_AR__c, Account__r.Business_Unit_AR__r.CodDefUsuario__c
                                                                   FROM LAT_Account_product_payment__c
                                                                   WHERE account__c =: accountId
                                                                   AND LAT_Product__r.LAT_IsRefactorProduct__c = 'Y'
                                                                   AND LAT_Product__r.LAT_IsActive__c = true];
                List <String> productIds = new List <String>();
                for (LAT_Account_product_payment__c app : accountProductPayments) {
                    productIds.add(app.LAT_Product__r.Id);
                    if(app.Account__r.Business_Unit_AR__c != null) {
                        unidadDeNegocios = app.Account__r.Business_Unit_AR__r.CodDefUsuario__c;
                    }
                }
                System.debug('%%% subCanal : ' +  subCanal);
                List <Lat_Product__c> returnProducts = [SELECT Id, Name, LAT_EAN__c, LAT_B2B_Alcohol_Level__c, LAT_B2B_Brand__c, LAT_B2B_Brand_Quality__c, LAT_B2B_Country__c, LAT_B2B_Description__c,
                                                            LAT_B2B_Ingredients__c, LAT_B2B_Manufacturer_Details__c, LAT_B2B_Packaging_Details__c, LAT_B2B_Product_History__c, LAT_B2B_Product_Name__c,
                                                            LAT_B2B_Quality__c, LAT_B2B_Size_Label__c, LAT_B2B_Size_Value__c, LAT_B2B_Image_URL__c, LAT_B2B_Thumbnail_URL__c, LAT_SKU__c,
                                                            LAT_CDUnit__c, LAT_BottlesPerBox__c, LAT_UnitWeight__c, LAT_B2B_MinimumStock__c, LAT_IsActive__c, LAT_B2B_Visibility__c,
                                                            (SELECT LAT_Price__c, LAT_PriceWithoutOffer__c, LAT_AR_UOM__c, LAT_Iibb__c, LAT_Iva__c, LAT_OfferIva__c, LAT_OfferIibb__c FROM Precios_Productos_B2B__r WHERE LAT_Channel__c = : subCanal ORDER BY LAT_AR_UOM__c ),
                                                            (SELECT LAT_Stock__c FROM Lat_StocksList__r WHERE LAT_Branch__c =:unidadDeNegocios LIMIT 1)
                                                            FROM LAT_Product__c WHERE Id in:productIds AND LAT_B2B_Visibility__c <> 'Oculto' 
                                                            AND LAT_B2B_OrderInShoppingCart__c <> null ORDER BY LAT_B2B_OrderInShoppingCart__c DESC Limit 4 OFFSET :rowNumber
                                                            ];

                for(Lat_Product__c p : returnProducts){
                    if(p.Lat_StocksList__r.size() > 0) {
                        if(p.LAT_B2B_MinimumStock__c != null) {
                            if(p.Lat_StocksList__r[0].LAT_Stock__c < p.LAT_B2B_MinimumStock__c){
                                p.LAT_IsActive__c = false;
                            }
                        } else {
                            if(p.Lat_StocksList__r[0].LAT_Stock__c ==0) {
                                p.LAT_IsActive__c = false;
                            }
                        }
                    } 
                }
                System.debug('%%%% returnProducts[0] : ' + returnProducts[0]);
                System.debug('%%%% returnProducts[0].Precios_Productos_B2B__r : ' + returnProducts[0].Precios_Productos_B2B__r);
                strResult = JSON.serialize(returnProducts);  
            } else {
                strResult = null;  
            }
            
        } catch(Exception Ex) {
            throw new AuraHandledException(JSON.serializePretty(new B2BCustomError(true, false, 999, Ex))) ;
        }

        System.debug('getHighlightedProducts [' + strResult + '] <-');

        return strResult;
    }

    @AuraEnabled
    public static String integrateToJDE(String oppId) {
        String strResult = null;

        System.debug('integrateToJDE [oppId : ' + oppId + '] ->');

        try {
            strResult = WS03_SalesOrderHandlerInterface_AR.LAT_SalesOrderInterface(oppId);
        } catch(Exception Ex) {
            throw new AuraHandledException(JSON.serializePretty(new B2BCustomError(true, false, 999, Ex))) ;
        }

        System.debug('integrateToJDE [' + strResult + '] <-');

        return strResult;
    }

    @AuraEnabled
    public static String integrateToJDE(String oppId, String comments) {        
        String ret = null;
         
        System.debug('integrateToJDE [oppId : ' + oppId + ' - comments : ' + comments + '] ->');

        try {
            ret = WS03_SalesOrderHandlerInterface_AR.LAT_SalesOrderInterface(oppId);

            List<LAT_Opportunity__c> toDelete = [SELECT Id 
                                                FROM LAT_Opportunity__c 
                                                WHERE LAT_StageName__c = 'Novo Pedido' 
                                                AND LAT_Account__c =:getAccountId() 
                                                AND LAT_LeadSource__c='B2B' 
                                                AND Id!=:oppId];
            if(toDelete.size() > 0) { 
                delete toDelete;
            }
        } catch(Exception Ex) {
            throw new AuraHandledException(JSON.serializePretty(new B2BCustomError(true, false, 999, Ex))) ;
        }

        System.debug('integrateToJDE [' + ret + '] <-');

        return ret;
    }

    @AuraEnabled
    public static String checkStockOnline(String oppId) {
        String strCheckStock = null;

        System.debug('checkStockOnline [oppId : ' + oppId + '] ->');
        try {
            strCheckStock = 'true';
            
            List<LAT_OpportunityLineItem__c> items = [SELECT Id, LAT_Product__r.LAT_Sku__c, LAT_Product__c, LAT_Opportunity__r.LAT_Account__c, LAT_Quantity__c,
                                                        LAT_Opportunity__r.LAT_Account__r.Business_Unit_AR__r.CodDefUsuario__c, LAT_Product__r.LAT_BottlesPerBox__c,
                                                        LAT_AR_UOM__c 
                                                    FROM LAT_OpportunityLineItem__c 
                                                    WHERE LAT_Opportunity__c = :oppId ];
            
            List<LAT_Product__c> skus = new List<LAT_Product__c>();
            Map<Id, LAT_OpportunityLineItem__c> olisByProd = new Map<Id, LAT_OpportunityLineItem__c>();
            for(LAT_OpportunityLineItem__c oli : items) {
                LAT_Product__c toAdd = new LAT_Product__c();
                toAdd.id = oli.Lat_Product__c;
                toAdd.LAT_Sku__c = oli.LAT_Product__r.LAT_Sku__c;
                toAdd.LAT_BottlesPerBox__c = oli.LAT_Product__r.LAT_BottlesPerBox__c;
                skus.add(toAdd);
                olisByProd.put(oli.LAT_Product__c, oli);
            }

            List<LAT_Stock__c> res = LAT_StockAvailabilityInterface.getStockBatch('Argentina', items[0].LAT_Opportunity__r.LAT_Account__r.Business_Unit_AR__r.CodDefUsuario__c, 'BT', skus);
            if (res.size() > 0) {
                upsert res LAT_ExternalID__c;
            }
            for(LAT_Stock__c stk : res){
                Decimal stock = stk.LAT_Stock__c;
                LAT_OpportunityLineItem__c oli = olisByProd.get(stk.LAT_Product__c);
                if(oli.LAT_AR_UOM__c == 'CA'){
                    stock = Math.floor(stock /oli.LAT_Product__r.LAT_BottlesPerBox__c );
                } 
                System.debug('SKU: '+ oli.LAT_Product__r.LAT_Sku__c+ ' || stock: ' + stock+ ' || qty: '+ oli.LAT_Quantity__c);
                if(stock < oli.LAT_Quantity__c) {
                    strCheckStock = 'false';
                }
            }
        } catch(Exception Ex) {
            throw new AuraHandledException(JSON.serializePretty(new B2BCustomError(true, false, 999, Ex))) ;
        }

        System.debug('integrateToJDE [' + strCheckStock + '] <-');

        return strCheckStock;        
    }

    @AuraEnabled
    public static String sendConfirmationEmail(String oppId) {
        String strResult = null;
        System.debug('sendConfirmationEmail [oppId : ' + oppId + '] ->');
        
        try {
            Network community = [SELECT Id, Name FROM Network WHERe Name = 'LAT_CTY_B2B' LIMIT 1];
            List<LAT_Opportunity__c> opps = [SELECT Id, Name, LAT_Account__r.Name, CreatedBy.FirstName, CreatedBy.Email, LAT_Account__r.Owner.Email, LAT_Account__r.USA_Account_Owner_Email__c
                                             FROM LAT_Opportunity__c WHERE Id = :oppId ];
            
            if(opps.size()>0){
                System.debug('%%%% opps[0] : '+ opps[0]);
                System.debug('%%%% opps[0].CreatedBy.Email : '+ opps[0].CreatedBy.Email);
                System.debug('%%%% opps[0].LAT_Account__r.Owner.Email : '+ opps[0].LAT_Account__r.Owner.Email);
                System.debug('%%%% opps[0].LAT_Account__r.USA_Account_Owner_Email__c : '+ opps[0].LAT_Account__r.USA_Account_Owner_Email__c);
                LAT_Opportunity__c opp = opps[0];
                List<LAT_OpportunityLineItem__c> items = [SELECT Id, LAT_Sku__c, LAT_SkuText__c, LAT_Product__r.LAT_B2B_Product_Name__c, LAT_AR_UOM__c, LAT_Quantity__c, LAT_TotalPrice__c
                                                          FROM LAT_OpportunityLineItem__c 
                                                          WHERE LAT_Opportunity__c = :oppId];

                String basePAth = System.Test.isRunningTest() ? 'Test' : Network.getLoginUrl(community.Id).replace('/login', '');
                String body = 'Estimado ' + opp.CreatedBy.FirstName + ', <br><br>'+
                    'Tu pedido ' + opp.Name+ ' en Pernod Ricard ya está en proceso! <br><br>'+
                    'Para ver el detalle del pedido puedes ingresar aquí: <a href="'+basePAth+'/detalle-pedido?order='+opp.Id+'">VER PEDIDO.</a><br><br>'+
                    '<table style="width:95%;margin-left: auto; margin-right: auto;" border="1"><tr>'+
                    '<th style="width: 20%; text-align: left;">SKU</th>'+
                    '<th style="width: 25%; text-align: left;">Descripcion SKU</th>'+
                    '<th style="width: 18%; text-align: left;">Unidad de Medida</th>'+
                    '<th style="width: 17%; text-align: right;">Cantidad</th>'+
                    '<th style="width: 20%; text-align: right;">Precio Neto</th></tr>';
                for (LAT_OpportunityLineItem__c item : items) {
                    body += '<tr><td>' + item.LAT_Sku__c + '</td>'+
                        '<td>' + item.LAT_Product__r.LAT_B2B_Product_Name__c + '</td>'+
                        '<td>' + item.LAT_AR_UOM__c + '</td>'+
                        '<td style="text-align: right;">' + item.LAT_Quantity__c + '</td>'+
                        '<td style="text-align: right;">' + item.LAT_TotalPrice__c + '</td></tr>';
                }
                body += '</table><br><br>'+
                    'Por dudas o consultas envianos un email a soportetiendapr@pernod-ricard.com.<br><br>'+
                    'Desde ya muchas gracias!<br><br>'+
                    'Pernod Ricard Argentina.';
                System.debug('%%%% body : '+ body);
                
                String subject = 'Tu pedido de Pernod Ricard B2B está siendo procesado';
                List<String> emails = new List<String>{opp.LAT_Account__r.USA_Account_Owner_Email__c, opp.CreatedBy.Email};
                System.debug('%%%% emails : '+ emails);
                
                AP01_Case_AR.enviarEmail(body, subject, emails);
            }
            
            strResult = '';
        } catch(Exception Ex) {
            throw new AuraHandledException(JSON.serializePretty(new B2BCustomError(true, false, 999, Ex))) ;
        }
        System.debug('sendConfirmationEmail [' + strResult + '] <-');
        
        return strResult;
    }

    @future
    public static void sendOpportunityCancelledEmail(String oppId) {
        System.debug('sendOpportunityCancelledEmail [oppId : ' + oppId + '] ->');

        try {
            System.debug('%%%% oppId : '+ oppId);
            Network community = [SELECT Id,Name FROM Network wHERe name = 'LAT_CTY_B2B' LIMIT 1];
            List<LAT_Opportunity__c> opps = [SELECT Id, Name, LAT_Account__r.Name, CreatedBy.FirstName, CreatedBy.Email, LAT_Account__r.Owner.Email, LAT_Account__r.USA_Account_Owner_Email__c
                                                FROM LAT_Opportunity__c WHERE Id = :oppId ];
                                
            
            if(opps.size()>0){
                System.debug('%%%% opps[0] : '+ opps[0]);
                System.debug('%%%% opps[0].CreatedBy.Email : '+ opps[0].CreatedBy.Email);
                System.debug('%%%% opps[0].LAT_Account__r.Owner.Email : '+ opps[0].LAT_Account__r.Owner.Email);
                System.debug('%%%% opps[0].LAT_Account__r.USA_Account_Owner_Email__c : '+ opps[0].LAT_Account__r.USA_Account_Owner_Email__c);
                LAT_Opportunity__c opp = opps[0];
                String basePAth = System.Test.isRunningTest()?'Test' : Network.getLoginUrl(community.Id).replace('/login', '');
                String body = 'Estimado ' + opp.CreatedBy.FirstName + ', <br><br>'+
                                'Tu pedido ' + opp.Name+ ' en Pernod Ricard cancelado. <br><br>'+
                                'Para ver el detalle del pedido puedes ingresar aquí: <a href="'+basePAth+'/detalle-pedido?order='+opp.Id+'">VER PEDIDO.</a><br><br>'+
                                'Por dudas o consultas envianos un email a soportetiendapr@pernod-ricard.com.<br><br>'+
                                'Desde ya muchas gracias!<br><br>'+
                                'Pernod Ricard Argentina.';
                System.debug('%%%% body : '+ body);
                String subject = 'Tu pedido de Pernod Ricard B2B fue Cancelado';
                List<String> emails = new List<String>{opp.LAT_Account__r.USA_Account_Owner_Email__c, opp.CreatedBy.Email};
                System.debug('%%%% emails : '+ emails);
                AP01_Case_AR.enviarEmail(body, subject, emails);

            }
        } catch(Exception Ex) {
            throw new AuraHandledException(JSON.serializePretty(new B2BCustomError(true, false, 999, Ex))) ;
        }

        System.debug('sendOpportunityCancelledEmail [] <-');
    }
    
    @future
    public static void sendOpportunityDispachedEmail(String fiscalNoteId) { 
        System.debug('sendOpportunityDispachedEmail [fiscalNoteId : ' + fiscalNoteId + '] ->');
        
        try {
            System.debug('%%%% fiscalNoteId : '+ fiscalNoteId);
            Network community = [SELECT Id,Name FROM Network wHERe name = 'LAT_CTY_B2B' LIMIT 1];
            List<LAT_FiscalNote__c> fiscalnotes= [Select Id, LAT_Opportunity__r.LAT_LeadSource__c,LAT_Opportunity__r.LAT_NROrderJDE__c, LAT_Opportunity__r.LAT_Account__r.Name, LAT_B2B_URL_Calico__c,
            LAT_Opportunity__r.CreatedBy.Email, LAT_Opportunity__r.LAT_Account__r.Owner.Email, LAT_Opportunity__r.Name,
            LAT_Opportunity__r.LAT_Account__r.USA_Account_Owner_Email__c, LAT_Opportunity__c, LAT_Opportunity__r.CreatedBy.FirstName
            FROM LAT_FiscalNote__c where Id = :fiscalNoteId] ;                  
            
            if(fiscalnotes.size()>0){
                
                System.debug('%%%% fiscalnotes[0] : '+ fiscalnotes[0]);
                if(fiscalnotes[0].LAT_Opportunity__r.LAT_LeadSource__c == 'B2B'){
                    System.debug('%%%% fiscalnotes[0].CreatedBy.Email : '+ fiscalnotes[0].LAT_Opportunity__r.CreatedBy.Email);
                    System.debug('%%%% fiscalnotes[0].LAT_Account__r.Owner.Email : '+ fiscalnotes[0].LAT_Opportunity__r.LAT_Account__r.Owner.Email);
                    System.debug('%%%% fiscalnotes[0].LAT_Account__r.USA_Account_Owner_Email__c : '+ fiscalnotes[0].LAT_Opportunity__r.LAT_Account__r.USA_Account_Owner_Email__c);
                    LAT_FiscalNote__c fn = fiscalnotes[0];
                    String basePAth = System.Test.isRunningTest()?'Test' : Network.getLoginUrl(community.Id).replace('/login', '');
                    String body = 'Estimado ' + fn.LAT_Opportunity__r.CreatedBy.FirstName + ', <br><br>'+
                        'Tu pedido ' + fn.LAT_Opportunity__r.Name+ ' en Pernod Ricard ya se encuentra en camino. <br><br>'+
                        'Podés darle seguimiento en el siguiente link: <a href="'+fn.LAT_B2B_URL_Calico__c+'">TRACKING.</a><br><br>'+
                        'Para ver el detalle del pedido puedes ingresar aquí: <a href="'+basePAth+'/detalle-pedido?order='+fn.LAT_Opportunity__c+'">VER PEDIDO.</a><br><br>'+
                        'Por dudas o consultas envianos un email a soportetiendapr@pernod-ricard.com.<br><br>'+
                        'Desde ya muchas gracias!<br><br>'+
                        'Pernod Ricard Argentina.';
                    System.debug('%%%% body : '+ body);
                    String subject = 'Tu pedido de Pernod Ricard B2B está en camino!';
                    List<String> emails = new List<String>{fn.LAT_Opportunity__r.LAT_Account__r.USA_Account_Owner_Email__c, fn.LAT_Opportunity__r.createdBy.Email};
                        System.debug('%%%% emails : '+ emails);
                    AP01_Case_AR.enviarEmail(body, subject, emails);
                }
                
                
            }
        } catch(Exception Ex) {
            throw new AuraHandledException(JSON.serializePretty(new B2BCustomError(true, false, 999, Ex))) ;
        }
        
        System.debug('sendOpportunityDispachedEmail [] <-');
    }

    private static String retrieveCommunityBaseUrl() {
        String strNetworkId = null;
        String strBaseUrl = null;

        System.debug('retrieveCommunityBaseUrl [] ->');
        strNetworkId = Network.getNetworkId();

        if(String.isNotBlank(strNetworkId)) {
            strBaseUrl = Network.getLoginUrl(strNetworkId);

            if(String.isNotBlank(strBaseUrl)) {
                strBaseUrl = strBaseUrl.remove('/s/login');
            } 
        }

        System.debug('retrieveCommunityBaseUrl [' + strBaseUrl + '] <-');

        return strBaseUrl;
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
            objOpportunityCloned.LAT_EDI_NeedsToAdvanceStatus__c = objOpportunity.LAT_EDI_NeedsToAdvanceStatus__c; 
        } catch(Exception Ex) {

        }
        System.debug('LAT_Opportunity__c [' + objOpportunityCloned + '] <-');

        return objOpportunityCloned;
    }
}