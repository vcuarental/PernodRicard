/****************************************************
 Dev: Isabel Gabard  Version: 1  Consulting: Zimmic
****************************************************/
/**
 * Controller used for creating new Cient to Argentina
 *
 */
public with sharing class LAT_AR_ClientSegmentationController {
    public String retUrl { get; set; }
    public Boolean isNew { get; set; }
    public Account newAccount { get; set; }
    public boolean isOpenBottle { get; set; }

    public Map<String, DecisionItem> decisionTree { get; set; }
    private Map<Integer, List<DecisionItem>> questionsOrdered { get; set; }

    public Boolean showNextButton { get; set; }
    public Boolean showSaveButton { get; set; }
    public Integer actualLevel { get; set; }
    public Integer maxLevel { get; set; }
    public Boolean response { get; set; }
    public String questionLabel { get; set; }

    public class DecisionItem {
        public String label { get; set; }
        public String question { get; set; }
		public Boolean response { get; set; }
        public Boolean showQuestion { get; set; }
	} 

    public LAT_AR_ClientSegmentationController(ApexPages.StandardController stdController) {
        this();
    }

	public LAT_AR_ClientSegmentationController() {
        init();
                
        // string recordTypeArgOn = Global_RecordTypeCache.getRtId('Account'+'ACC_3_OnTrade_ARG');
        // string recordTypeArgOff = Global_RecordTypeCache.getRtId('Account'+'ACC_1_OffTrade_ARG');
        // string recordTypeUruOn = Global_RecordTypeCache.getRtId('Account'+'ACC_4_OnTrade_URU');
        // string recordTypeUruOff = Global_RecordTypeCache.getRtId('Account'+'ACC_2_OffTrade_URU');

        loadQuestions();
    }
    
    private void init() {
        this.retUrl = String.format('https://{0}{1}', new String[] { ApexPages.currentPage().getHeaders().get('Host'), System.currentPageReference().getParameters().get('retURL') });
        this.isNew = true;
        this.newAccount = new Account();
        this.isOpenBottle = false;
        this.actualLevel = 0;
        this.showSaveButton = true;
        this.showNextButton = false;
    }

    public List<SelectOption> getItems() {
        List<SelectOption> options = new List<SelectOption>(); 
        options.add(new SelectOption('true','Si')); 
        options.add(new SelectOption('false','No')); 
        return options; 
    }

    public void saveAccount() {        
        this.isNew = false;
        loadQuestions();
    }

    /**
     * Crea la cuenta seteando los valores correspondientes segun las opciones elegidas
     */
    public PageReference updateAccountAR() {
        system.debug(this.actualLevel);
        system.debug('questionLabel = ' + questionLabel);
        system.debug('response = ' + response);
        Boolean updateResponse = false;
        switch on this.actualLevel {
            when 0 {
                if (this.isOpenBottle) {
                    updateResponse = updateAccount('Direto', '6-OFF-40-PC', 'Off Trade', 'H03', 'Special Accounts_ARG', false);
                    system.debug('////////// Ctas Esp - Caterings / CUENTAS ESPECIALES / OFFTRADE');
                } 
            }
            when 1 {
                if (this.isOpenBottle) {
                    updateResponse = updateAccount('Direto', '6-ON-40-PC', 'On Trade', 'G05', 'Direct On-Trade_ARG', true);
                    system.debug('////////// On Trade - Hoteles / ON TRADE DIRECTA');
                } 
            }
            when 2 {
                if (this.isOpenBottle) {
                    updateResponse = updateAccount('Direto', '6-ON-40-PC', 'On Trade', 'G04', 'Direct On-Trade_ARG', true);
                    system.debug('////////// On Trade - Restaurantes / ON TRADE DIRECTA');
                } else {
                    if (questionLabel.equals('LAT_AR_Level4_1OffTrade')) {
                        updateResponse = updateAccount('Direto', '6-OFF-40-PC', 'Off Trade', 'H03', 'Special Accounts_ARG', true);
                        system.debug('////////// Ctas Esp - Deliveries / Cuentas Especiales');
                    } else if (questionLabel.equals('LAT_AR_Level4_2OffTrade')) {
                        updateResponse = updateAccount('Direto', '6-OFF-40-PC', 'Off Trade', 'E03', 'Wineries_ARG', true);
                        system.debug('////////// Vinotecas Directas - Almacen D /  Vinotecas Directa   ');
                    }
                }
            }
            when 3 {
                if (this.isOpenBottle) {
                    updateResponse = updateAccount('Direto', '6-ON-40-PC', 'On Trade', 'G03', 'Direct On-Trade_ARG', true);
                    system.debug('////////// Mayoristas - Nacionales / ON TRADE DIRECTA');
                } else {
                    if (questionLabel.equals('LAT_AR_Level5_1OffTrade')) {
                        if (response) {
                            updateResponse = updateAccount('Direto', '6-OFF-40-PC', 'Off Trade', 'E01', 'Wineries_ARG', true);
                            system.debug('////////// Vinotecas Directas - Cadenas / Vinotecas Directa');
                        } else {
                            updateResponse = updateAccount('Direto', '6-OFF-40-PC', 'Off Trade', 'E02', 'Wineries_ARG', true);
                            system.debug('////////// Vinotecas Directas - Boutique / Vinotecas Directa');
                        }
                    } else if (questionLabel.equals('LAT_AR_Level5_4OffTrade')) {
                        updateResponse = updateAccount('Indireto', '6-OFF-40-PC', 'Off Trade', 'B01', 'Wholesalers_ARG', true);
                        system.debug('////////// Mayoristas - Nacionales / Mayoristas ');
                    } else if (questionLabel.equals('LAT_AR_Level5_5OffTrade')) {
                        updateResponse = updateAccount('Indireto', '6-OFF-40-PC', 'Off Trade', 'B01', 'Wholesalers_ARG', true);
                        system.debug('////////// Mayoristas - Nacionales / Mayoristas');
                    } else if (questionLabel.equals('LAT_AR_Level5_6OffTrade')) {
                        if (response) {
                            updateResponse = updateAccount('Indireto', '6-OFF-40-PC', 'Off Trade', 'H02', 'Special Accounts_ARG', true);
                            system.debug('////////// Ctas Esp – Empresas/ Cuentas Especiales     ');
                        } else {
                            updateResponse = updateAccount('Indireto', '6-OFF-40-PC', 'Off Trade', 'H03', 'Special Accounts_ARG', true);
                            system.debug('////////// Ctas Esp - Deliveries / Catter / Cuentas Especiales ');
                        }
                    }
                }
            }
            when 4 {
                if (this.isOpenBottle) {
                    if (response) {
                        updateResponse = updateAccount('Direto', '6-ON-40-PC', 'On Trade', 'G01', 'Direct On-Trade_ARG', true);
                        system.debug('////////// On Trade - Low Energy Bar / ON TRADE DIRECTA');
                    } else {
                        updateResponse = updateAccount('Direto', '6-ON-40-PC', 'On Trade', 'G02', 'Direct On-Trade_ARG', true);
                        system.debug('////////// On Trade - High Energy Bar / ON TRADE DIRECTA');
                    }
                    system.debug('Subcanal= ON TRADE DIRECTA 3');
                } else {
                    if (questionLabel.equals('LAT_AR_Level6_1OffTrade')) {
                        updateResponse = updateAccount('Direto', '6-OFF-40-PC', 'Off Trade', 'A02', 'Supermarkets_ARG', true);
                        system.debug('////////// Supermercados -  Regionales / Supermercados ');
                    } else if (questionLabel.equals('LAT_AR_Level6_2OffTrade')) {
                        if (response) {
                            updateResponse = updateAccount('Direto', '6-OFF-40-PC', 'Off Trade', 'A02', 'Supermarkets_ARG', true);
                            system.debug('////////// Supermercados -  Regionales / Supermercados');
                        } else {
                            updateResponse = updateAccount('Direto', '6-OFF-40-PC', 'Off Trade', 'A03', 'Supermarkets_ARG', true);
                            system.debug('////////// Supermercados - Zonales / Supermercados');
                        }
                    } else if (questionLabel.equals('LAT_AR_Level6_3OffTrade')) {
                        if (response) {
                            updateResponse = updateAccount('Direto', '6-DIST-40-PC', 'Off Trade', 'D01', 'Indirect On-Trade_ARG', true); 
                            system.debug('//////////  Distribuidores ON Trade - Estratégicos / On Trade Indirecta     ');
                        } else {
                            updateResponse = updateAccount('Ind ireto', '6-DIST-40-PC', 'Off Trade', 'C01', 'Distribuitors_ARG', true);
                            system.debug('//////////  Distribuidores OFF Trade - Estrategicos / Distribuidores Off Trade   ');
                        }
                    } else if (questionLabel.equals('LAT_AR_Level6_5OffTrade') || questionLabel.equals('LAT_AR_Level6_6OffTrade')) {
                        if (response) {
                            updateResponse = updateAccount('Indireto', '6-OFF-40-PC', 'Off Trade', 'B02', 'Wholesalers_ARG', true);
                            system.debug('////////// Mayoristas - Regionales / Mayoristas  ');
                        } else {
                            updateResponse = updateAccount('Indireto', '6-OFF-40-PC', 'Off Trade', 'B03', 'Wholesalers_ARG', true);
                            system.debug('//////////  Mayoristas - Zonales / Mayoristas');
                        }
                    }
                }
            }
            when 5 {
                if (questionLabel.equals('LAT_AR_Level7_1OffTrade')) {
                    if (response) {
                        updateResponse = updateAccount('Direto', '6-OFF-40-PC', 'Off Trade', 'A04', 'Supermarkets_ARG', true);
                        system.debug('////////// Supermercados – Hard Discount / Supermercados');
                    } else {
                        updateResponse = updateAccount('Direto', '6-OFF-40-PC', 'Off Trade', 'A01', 'Supermarkets_ARG', true);
                        system.debug('//////////  Supermercados – Nacionales / Supermercados');
                    }
                } else if (questionLabel.equals('LAT_AR_Level7_2OffTrade')) {
                    updateResponse = updateAccount('Indireto', '6-DIST-40-PC', 'Off Trade', 'F01', 'POS Wineries_ARG', true);
                    system.debug('//////////  Vinotecas - Distribuidores / Vinotecas Indirecta    ');
                } else if (questionLabel.equals('LAT_AR_Level7_3OffTrade')) {
                    if (response) {
                        updateResponse = updateAccount('Indireto', '6-DIST-40-PC', 'Off Trade', 'D02', 'Indirect On-Trade_ARG', true); 
                        system.debug('//////////  Distribuidores On trade – Multicategoria  / On trade Indirecta  ');
                    } else {
                        updateResponse = updateAccount('Indireto', '6-DIST-40-PC', 'Off Trade', 'C02', 'Distribuitors_ARG', true);
                        system.debug('//////////  Distribuidores Off trade – Multicategoria / Distribuidores Off Trade  ');
                    }
                }
            }
            when 6 {
                if (response) {
                    updateResponse = updateAccount('Indireto', '6-DIST-40-PC', 'Off Trade', 'D03', 'Indirect On-Trade_ARG', true); 
                    system.debug('//////////  Distribuidores On trade – Solo bebidas  / On trade Indirecta  ');
                } else {
                    updateResponse = updateAccount('Indireto', '6-DIST-40-PC', 'Off Trade', 'C03', 'Distribuitors_ARG', true); 
                    system.debug('////////// Distribuidores On trade – Solo bebidas /   Distribuidores Off Trade ');
                }
            }
        }

        if (updateResponse) {
            return new PageReference('/' + this.newAccount.Id + '/e?id=' + this.newAccount.Id);
        }
        return null;
    }

    private Boolean updateAccount(String channelType, String customerPriceGroup, String channel, String subChannelRating, String subChannel, Boolean ontrade) {
        
        this.newAccount.recordTypeId = getRecordType(ontrade);
        this.newAccount.Type = 'Sale_ARG';

        system.debug('//////////////////UPDATE ACCOUNT '+ channelType+' // '+customerPriceGroup+' // '+channel+' // '+subChannelRating+' // '+subChannel+' // '+Global_RecordTypeCache.getRtId('UDC__c'+'Standard_AR'));
        //CollectionAgent_AR__c  precargar el campo con la referencia del usuario creador desde el campo User. LAT_UdcCollectionAgentId__c donde estarán cargados los ID.
        String owner = UserInfo.getName().toUppercase();
        List<UDC__c> collectionAgent = [Select Id From UDC__c Where Descricao2__c = :owner];
        if (collectionAgent.size() > 0) {
            this.newAccount.collectionAgent_AR__c = collectionAgent[0].Id;
        } else {
            owner = UserInfo.getLastName() + ' ' + UserInfo.getFirstName();
            collectionAgent = [Select Id From UDC__c Where Descricao2__c = :owner];
            if (collectionAgent.size() > 0) {
                this.newAccount.collectionAgent_AR__c = collectionAgent[0].Id;
            } else {
                system.debug('No existe el owner en UDC '+owner);
            }
        }
        
        try {
            // Customer_GL__c  Customer_GL__c precargar con "cliente en pesos" a4yD0000000Cv6b
            this.newAccount.Customer_GL__c = [SELECT Id FROM UDC__c WHERE CodDefUsuario__c = 'PES' AND RecordTypeId = :Global_RecordTypeCache.getRtId('UDC__c'+'Standard_AR')][0].Id;
            // Payment_instrument__c precargar con "blanco" a4yD0000000Cv12
            this.newAccount.Payment_instrument__c = [SELECT Id FROM UDC__c WHERE Name = 'Blanco' AND RecordTypeId = :Global_RecordTypeCache.getRtId('UDC__c'+'Standard_AR') AND Internal_Id__c = '6--00-PY'][0].Id;
            
            this.newAccount.Channel_Type__c = channelType;
            List<UDC__c> customerPriceGroupDef = [SELECT Id FROM UDC__c WHERE RecordTypeId = :Global_RecordTypeCache.getRtId('UDC__c'+'Standard_AR') AND Internal_Id__c = :customerPriceGroup];
            if (customerPriceGroupDef.size() > 0) {
                this.newAccount.CustomerPriceGroup_AR__c = customerPriceGroupDef[0].Id;
            }
            else {
                system.debug('No existe UDC para '+customerPriceGroup);
            }
            this.newAccount.Channel__c = channel;
            List<UDC__c> subChannelDef = [SELECT Id FROM UDC__c WHERE CodDefUsuario__c = :subChannelRating AND RecordTypeId = :Global_RecordTypeCache.getRtId('UDC__c'+'Standard_AR')];
            if (subChannelDef.size() > 0) {
                this.newAccount.Sub_Channel_Rating__c = subChannelDef[0].Id; 
            } else {
                system.debug('No existe UDC para '+subChannelRating);
            }
            this.newAccount.Business_Unit_AR__c = [SELECT Id FROM UDC__c WHERE CodDefUsuario__c = '01' AND RecordTypeId = :Global_RecordTypeCache.getRtId('UDC__c'+'Standard_AR')][0].Id;
            this.newAccount.Sub_Channel__c = subChannel;

            system.debug('== NEWACCOUNT == '+ this.newAccount);
            insert this.newAccount;
            return true;
        } catch(Exception ex) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Fatal,ex.getDmlMessage(0)));
            return false;
        }
    }

    /**
     * Guarda la respuesta del nivel actual y dependiendo de ella setea la siguiente pregunta a mostrar
     */
    public void nextLevel() {
        system.debug('response = ' + this.response);
        system.debug('questionLabel = ' + this.questionLabel);
        system.debug('actualLevel = ' + this.actualLevel);
        system.debug('this.decisionTree = '+this.decisionTree);
        DecisionItem di = this.decisionTree.get(questionLabel);
        System.debug('DecisionItem questionLabel = '+di);
        di.response = this.response;
        di.showQuestion = true;
        this.actualLevel = this.actualLevel + 1;

        if (!isOpenBottle) {
            List<DecisionItem> items = new List<DecisionItem>();
            if (this.questionsOrdered.containsKey(actualLevel)) {
                items = this.questionsOrdered.get(actualLevel);
            }
            
            for (DecisionItem it : items) {
                // update items in next level
                DecisionItem nextItem = this.decisionTree.get(it.Label);
                nextItem.showQuestion = false; 
                switch on it.label {
                    when 'LAT_AR_Level3_1OffTrade' {
                        nextItem.showQuestion = di.response; 
                    }
                    when 'LAT_AR_Level3_2OffTrade' {
                        nextItem.showQuestion = !di.response; 
                    }
                    when 'LAT_AR_Level4_1OffTrade' {
                        if (questionLabel.equals('LAT_AR_Level3_1OffTrade')) {
                            nextItem.showQuestion = di.response;        
                        }
                    }
                    when 'LAT_AR_Level4_2OffTrade'{ 
                        if (questionLabel.equals('LAT_AR_Level3_1OffTrade')) {
                            nextItem.showQuestion = !di.response;
                        }
                    }
                    when 'LAT_AR_Level4_3OffTrade' {
                        if (questionLabel.equals('LAT_AR_Level3_2OffTrade')) {
                            nextItem.showQuestion = di.response; 
                        }
                    }
                    when 'LAT_AR_Level4_4OffTrade' {
                        if (questionLabel.equals('LAT_AR_Level3_2OffTrade')) {
                            nextItem.showQuestion = !di.response;
                        }
                    }
                    when 'LAT_AR_Level5_1OffTrade' {
                        if (questionLabel.equals('LAT_AR_Level4_1OffTrade')) {
                            nextItem.showQuestion = di.response;
                        }
                    }
                    when  'LAT_AR_Level5_2OffTrade' {
                        if (questionLabel.equals('LAT_AR_Level4_2OffTrade')) {
                            nextItem.showQuestion = di.response;
                        }                        
                    }
                    when 'LAT_AR_Level5_3OffTrade' { 
                        if (questionLabel.equals('LAT_AR_Level4_3OffTrade')) {
                            nextItem.showQuestion = di.response;
                        }                        
                    }
                    when 'LAT_AR_Level5_4OffTrade' {
                        if (questionLabel.equals('LAT_AR_Level4_3OffTrade')) {
                            nextItem.showQuestion = !di.response;
                        }                        
                    }
                    when 'LAT_AR_Level5_5OffTrade' {
                        if (questionLabel.equals('LAT_AR_Level4_4OffTrade')) {
                            nextItem.showQuestion = di.response;
                        }                        
                    }
                    when 'LAT_AR_Level5_6OffTrade' {
                        if (questionLabel.equals('LAT_AR_Level4_4OffTrade')) {
                            nextItem.showQuestion = !di.response;
                        }
                    }
                    when 'LAT_AR_Level6_1OffTrade' {
                        if (questionLabel.equals('LAT_AR_Level5_2OffTrade')) {
                            nextItem.showQuestion = di.response;
                        }
                    }
                    when 'LAT_AR_Level6_2OffTrade' {
                        if (questionLabel.equals('LAT_AR_Level5_2OffTrade')) {
                            nextItem.showQuestion = !di.response;
                        }
                    }
                    when 'LAT_AR_Level6_3OffTrade' {
                        if (questionLabel.equals('LAT_AR_Level5_3OffTrade')) {
                            nextItem.showQuestion = di.response;
                        }
                    }
                    when 'LAT_AR_Level6_4OffTrade' {
                        if (questionLabel.equals('LAT_AR_Level5_3OffTrade')) {
                            nextItem.showQuestion = !di.response;
                        }
                    }
                    when 'LAT_AR_Level6_5OffTrade' {
                        if (questionLabel.equals('LAT_AR_Level5_4OffTrade')) {
                            nextItem.showQuestion = !di.response;
                        }
                    }
                    when 'LAT_AR_Level6_6OffTrade' {
                        if (questionLabel.equals('LAT_AR_Level5_5OffTrade')) {
                            nextItem.showQuestion = !di.response;
                        }
                    }
                    when 'LAT_AR_Level7_1OffTrade' {
                        if (questionLabel.equals('LAT_AR_Level6_1OffTrade')) {
                            nextItem.showQuestion = di.response;
                        }
                    }
                    when 'LAT_AR_Level7_2OffTrade' {
                        if (questionLabel.equals('LAT_AR_Level6_4OffTrade')) {
                            nextItem.showQuestion = di.response;
                        }
                    }
                    when 'LAT_AR_Level7_3OffTrade' {
                        if (questionLabel.equals('LAT_AR_Level6_4OffTrade')) {
                            nextItem.showQuestion = !di.response;
                        }
                    }
                    when 'LAT_AR_Level7_4OffTrade' {
                        if (questionLabel.equals('LAT_AR_Level6_4OffTrade')) {
                            nextItem.showQuestion = di.response;
                        }
                    }
                    when 'LAT_AR_Level8_1OffTrade' {
                        if (questionLabel.equals('LAT_AR_Level7_2OffTrade')) {
                            nextItem.showQuestion = !di.response;
                        }
                    }
                    when else {
                        system.debug(questionLabel);
                    }
                }
                if (!nextItem.showQuestion) {
                    this.decisionTree.remove(nextItem.Label);
                }
            }
            this.questionsOrdered.put(actualLevel, items);
        }
        
        this.decisionTree.put(questionLabel, di);
    }

    public PageReference cancel() {
        PageReference objPageReference = null;
        if (this.newAccount != null) {
            objPageReference = new PageReference('/apex/LAT_AR_ClientSegmentation');       
        	objPageReference.setRedirect(true);
        } else {
            objPageReference = new PageReference(retUrl);
        }

		return objPageReference;
    }

    public DecisionItem[] getQuestions() {
        return this.decisionTree.values();
    }

    private void loadQuestions() {
        this.decisionTree = new Map<String, DecisionItem>();
        this.questionsOrdered = new Map<Integer, List<DecisionItem>>();
        for (LAT_AR_DecisionTreeAccount__mdt qst : [SELECT LAT_AR_Question__c, LAT_AR_Order__c, Label 
                                                    FROM LAT_AR_DecisionTreeAccount__mdt 
                                                    WHERE LAT_AR_IsOnTrade__c = :this.isOpenBottle ORDER BY LAT_AR_Order__c]) {
            DecisionItem di = new DecisionItem();
            di.label = qst.Label;
            di.question = qst.LAT_AR_Question__c;
            di.showQuestion = true;
            this.decisionTree.put(qst.Label, di);
            
            List<DecisionItem> items = new List<DecisionItem>();
            Integer order = Integer.valueOf(qst.LAT_AR_Order__c)-1;
            if (this.questionsOrdered.containsKey(order)) {
                items = this.questionsOrdered.get(order);
            }
            items.add(di);
            // la configuracion esta armada empezando con orden 1
            this.questionsOrdered.put(order, items);

            maxLevel = Integer.valueOf(qst.LAT_AR_Order__c);
        }
        
    }

    private String getRecordType(Boolean ontrade) {        
        if (isOpenBottle && ontrade) {
            return Global_RecordTypeCache.getRtId('Account' + 'ACC_3_OnTrade_ARG');
        } 
        return Global_RecordTypeCache.getRtId('Account' + 'ACC_1_OffTrade_ARG');
    }

}