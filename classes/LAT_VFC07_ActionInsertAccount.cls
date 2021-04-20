/********************************************************************************
*
* MIGRACION LICENCIAS
* AUTHOR: ZIMMIC                     DATE: 07/11/2016
*
********************************************************************************/

public with sharing class LAT_VFC07_ActionInsertAccount {


    // Field types
    private static final Set<Schema.DisplayType> STRING_TYPES = new Set<Schema.DisplayType>{
         Schema.DisplayType.base64
        ,Schema.DisplayType.Email
        ,Schema.DisplayType.MultiPicklist
        ,Schema.DisplayType.Phone
        ,Schema.DisplayType.Picklist
        ,Schema.DisplayType.String
        ,Schema.DisplayType.TextArea
        ,Schema.DisplayType.URL
    };
    private static final Set<Schema.DisplayType> INTEGER_TYPES = new Set<Schema.DisplayType>{
        Schema.DisplayType.Integer
    };
    private static final Set<Schema.DisplayType> ID_TYPES = new Set<Schema.DisplayType>{
        Schema.DisplayType.ID
        ,Schema.DisplayType.Reference
    };
    private static final Set<Schema.DisplayType> DOUBLE_TYPES = new Set<Schema.DisplayType>{
        Schema.DisplayType.Currency
        ,Schema.DisplayType.Double
        ,Schema.DisplayType.Percent
    };
    private static final Set<Schema.DisplayType> DATETIME_TYPES = new Set<Schema.DisplayType>{
        Schema.DisplayType.DateTime
    };
    private static final Set<Schema.DisplayType> DATE_TYPES = new Set<Schema.DisplayType>{
        Schema.DisplayType.Date
    };
    private static final Set<Schema.DisplayType> BOOLEAN_TYPES = new Set<Schema.DisplayType>{
        Schema.DisplayType.Boolean
        ,Schema.DisplayType.Combobox
    };

    public Id acaoId {get;set;}
    public LAT_AccountInAction__c dummyInputClientRegional{get;set;}
    public Blob toParse {get; set;}
    public String country {get; set;}
    public Map<String,String> countryCodes = new Map<String,String>{'ARS'=>'6','UYU'=>'5','MXN'=>'12','BRL'=>'1'};
    public Boolean selectAll {get; set;}
    public List<LAT_AccountInAction__c> listAccount {get; set;}
    public List<accountInActionInner> listAccountInner {get; set;}
	public Set<String> accountNotFound {get; set;}
	public Boolean hasErrors {get; set;}
    public List<filterConditionsWrapper> filterList {get; set;}
    public Map<String, Schema.DisplayType> fieldTypeMap {get; set;}

    public LAT_VFC07_ActionInsertAccount() {
        dummyInputClientRegional = new LAT_AccountInAction__c();
        this.country = countryCodes.get(UserInfo.getDefaultCurrency());
        this.filterList = new List<filterConditionsWrapper>();
        this.listAccount = new List<LAT_AccountInAction__c>();
        this.listAccountInner = new List<accountInActionInner>();
		this.accountNotFound = new Set<String>();
		this.hasErrors = false;
        this.filterList.add(new filterConditionsWrapper());
        this.filterList.add(new filterConditionsWrapper());
        this.filterList.add(new filterConditionsWrapper());
        this.filterList.add(new filterConditionsWrapper());
        this.filterList.add(new filterConditionsWrapper());

        this.selectAll = false;

        this.fieldTypeMap = new Map<String, Schema.DisplayType>();
        for (Schema.FieldSetMember f : SObjectType.Account.FieldSets.LAT_AccountDynamicFiltersFields.getFields()) {
            fieldTypeMap.put('acc: ' + f.getLabel(), f.getType());
        }


        if(!Utils.wasMigrationDone('1')) {
            for (Schema.FieldSetMember f : SObjectType.Opportunity.FieldSets.LAT_OppDynamicFiltersFields.getFields()) {
                    fieldTypeMap.put('opp: ' + f.getLabel(), f.getType());
            }
        }
        //MIGRATED 07/11/2016
        else {
            for (Schema.FieldSetMember f : SObjectType.LAT_Opportunity__c.FieldSets.LAT_OppDynamicFiltersFields.getFields()) {
                    fieldTypeMap.put('opp: ' + f.getLabel(), f.getType());
            }
        }
    }

    // Carga por Filtros
    public List<SelectOption> getFilterValues() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('--None--', '--None--'));
        options.add(new SelectOption('=', 'equals'));
        options.add(new SelectOption('!=', 'not equal to'));
        options.add(new SelectOption('LIKE', 'contains'));
        options.add(new SelectOption('<', 'less than'));
        options.add(new SelectOption('>', 'greater than'));
        options.add(new SelectOption('<=', 'less or equal'));
        options.add(new SelectOption('>=', 'greater or equal'));
        return options;
    }

    public List<SelectOption> getFieldValues() {
        List<SelectOption> options = new List<SelectOption>();

        options.add(new SelectOption('--None--', '--None--'));
        for (Schema.FieldSetMember f : SObjectType.Account.FieldSets.LAT_AccountDynamicFiltersFields.getFields()) {
            options.add(new SelectOption(f.getType() + ';acc: ' + f.getFieldPath(), 'Account: ' + f.getLabel()));
        }
        if(!Utils.wasMigrationDone('1')) {
            for (Schema.FieldSetMember f : SObjectType.Opportunity.FieldSets.LAT_OppDynamicFiltersFields.getFields()) {
                options.add(new SelectOption(f.getType() + ';opp: ' + f.getFieldPath(), 'Opportunity: ' + f.getLabel()));
            }
        }
        //MIGRATED 07/11/2016
        else {
            for (Schema.FieldSetMember f : SObjectType.LAT_Opportunity__c.FieldSets.LAT_OppDynamicFiltersFields.getFields()) {
                options.add(new SelectOption(f.getType() + ';opp: ' + f.getFieldPath(), 'LAT_Opportunity__c: ' + f.getLabel()));
            }
        }

        return options;
    }

    public void filterValues() {
        if(!Utils.wasMigrationDone('1')) {
            String baseQuery = 'SELECT id, Name, Client_code_AN8__c, CNPJ__c, owner.Name, Regional__r.Name, Sub_Channel_Rating__r.Name, ';

            for (Schema.FieldSetMember f : SObjectType.Account.FieldSets.LAT_AccountDynamicFiltersFields.getFields()) {
                if (f.getFieldPath() != 'Name') {
                    baseQuery += f.getFieldPath() + ', ';
                }
            }

            String opportunityQuery = 'Select id, Name, ';
            for (Schema.FieldSetMember f : SObjectType.Opportunity.FieldSets.LAT_OppDynamicFiltersFields.getFields()) {
                opportunityQuery += f.getFieldPath() + ', ';
            }
            opportunityQuery = opportunityQuery.substring(0, opportunityQuery.length() - 2) + ' From Opportunities ';

            baseQuery += '{oppQuery} FROM Account WHERE (RecordType.DeveloperName = \'Off_Trade\' OR RecordType.DeveloperName = \'On_Trade\') AND Owner.IsActive = true ';

            String filterOpties = '';

            for (filterConditionsWrapper filterCond : this.filterList) {
                if (filterCond.hasFilter()) {
                    if (filterCond.fieldName.contains('REFERENCE') && !filterCond.fieldName.contains('OwnerId')) {
                      filterCond.fieldName = filterCond.fieldName.replaceAll('__c', '__r.Name');
                    } else if (filterCond.fieldName.contains('OwnerId')) {
                      filterCond.fieldName = filterCond.fieldName.replaceAll('OwnerId', 'Owner.Name');
                    }
                    String fieldAPI = filterCond.fieldName + ' ';
                    String operator = filterCond.filterOption + ' ';
                    String value = filterCond.formatValue();
                    if (fieldAPI.contains('opp: ')) {
                        fieldAPI = fieldAPI.substring(fieldAPI.indexOf('opp: '), fieldAPI.length());
                        if (filterOpties.contains('WHERE')){
                            filterOpties += 'AND ' + fieldAPI.replace('opp: ', ' ') + operator +  value;
                        } else {
                            filterOpties += 'WHERE ' + fieldAPI.replace('opp: ', ' ') + operator + value;
                        }
                    }
                    if (fieldAPI.contains('acc: ')) {
                        fieldAPI = fieldAPI.substring(fieldAPI.indexOf('acc: '), fieldAPI.length());
                        baseQuery += 'AND ' + fieldAPI.replace('acc: ', ' ') + operator +  value;
                    }
                }
            }

            if (filterOpties != '') {
                opportunityQuery += filterOpties;
                baseQuery = baseQuery.replace('{oppQuery}', '(' + opportunityQuery + ')');
            } else {
                baseQuery = baseQuery.replace(', {oppQuery}', '');
            }

            baseQuery += ' LIMIT 1000';

            system.debug('query----->' + baseQuery);

            try {
                List<Account> tmpAccs = Database.query(baseQuery);
                if(tmpAccs != null && tmpAccs.size() > 0){
                    String webURL = ApexPages.currentPage().getParameters().get('id');
                    acaoId = webURL;
                    List<LAT_AccountInAction__c> aiaList = [SELECT id, LAT_Account__c FROM LAT_AccountInAction__c WHERE LAT_PromotionalAction__c=:webURL];
                    Set<String> accList = new Set<String>();
                    for (LAT_AccountInAction__c aia: aiaList) {
                        accList.add(aia.LAT_Account__c);
                    }

                    listAccountInner.clear();
                    for(Account acc : tmpAccs){
                        if (((filterOpties != '' && !acc.Opportunities.isEmpty()) || filterOpties == '') && !accList.contains(acc.id)) {
                            LAT_accountInAction__c ain = new LAT_accountInAction__c();
                            ain.LAT_ClientByRegion__c = dummyInputClientRegional.LAT_ClientByRegion__c;
                            ain.LAT_Account__c = acc.id;
                            //ain.Name = acc.Name;
                            ain.LAT_PromotionalAction__c = webURL;
                            ain.LAT_Status__C = 'Cliente Selecionado';
                            //ain.LAT_Execute__c = true;
                            //listAccount.add(ain);
                            listAccountInner.add(new accountInActionInner(ain, acc, false));
                        }
                    }
                } else {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Os filtros não contém dados válidos.'));
                }
            } catch (Exception e) {
                system.debug('Exception----->' + e.getMessage());
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Os filtros não contém dados válidos. Error: ' + e.getMessage()));
            }
            system.debug('query----->' + baseQuery);
        }
        //MIGRATED 07/11/2016
        else {

            String offTradeRecordTypes = LAT_GeneralConfig__c.getInstance('LAT_BR_Off_Trade_Record_Types').LAT_Value__c;
            String onTradeRecordTypes = LAT_GeneralConfig__c.getInstance('LAT_BR_On_Trade_Record_Types').LAT_Value__c;
            
            String baseQuery = 'SELECT id, Name, Client_code_AN8__c, CNPJ__c, owner.Name, Regional__r.Name, Sub_Channel_Rating__r.Name, ';

            for (Schema.FieldSetMember f : SObjectType.Account.FieldSets.LAT_AccountDynamicFiltersFields.getFields()) {
                if (f.getFieldPath() != 'Name') {
                    baseQuery += f.getFieldPath() + ', ';
                }
            }

            String opportunityQuery = 'Select id, Name, ';
            for (Schema.FieldSetMember f : SObjectType.LAT_Opportunity__c.FieldSets.LAT_OppDynamicFiltersFields.getFields()) {
                opportunityQuery += f.getFieldPath() + ', ';
            }
            opportunityQuery = opportunityQuery.substring(0, opportunityQuery.length() - 2) + ' From Opportunities ';

            //baseQuery += '{oppQuery} FROM Account WHERE (RecordType.DeveloperName in (' + offTradeRecordTypes + ') \'Off_Trade\' OR RecordType.DeveloperName = \'On_Trade\') AND Owner.IsActive = true ';
            baseQuery += '{oppQuery} FROM Account WHERE RecordType.DeveloperName in (' + offTradeRecordTypes + ',' + onTradeRecordTypes + ') AND Owner.IsActive = true ';

            String filterOpties = '';

            for (filterConditionsWrapper filterCond : this.filterList) {
                if (filterCond.hasFilter()) {
                    if (filterCond.fieldName.contains('REFERENCE') && !filterCond.fieldName.contains('OwnerId')) {
                      filterCond.fieldName = filterCond.fieldName.replaceAll('__c', '__r.Name');
                    } else if (filterCond.fieldName.contains('OwnerId')) {
                      filterCond.fieldName = filterCond.fieldName.replaceAll('OwnerId', 'Owner.Name');
                    }
                    String fieldAPI = filterCond.fieldName + ' ';
                    String operator = filterCond.filterOption + ' ';
                    String value = filterCond.formatValue();
                    if (fieldAPI.contains('opp: ')) {
                        fieldAPI = fieldAPI.substring(fieldAPI.indexOf('opp: '), fieldAPI.length());
                        if (filterOpties.contains('WHERE')){
                            filterOpties += 'AND ' + fieldAPI.replace('opp: ', ' ') + operator +  value;
                        } else {
                            filterOpties += 'WHERE ' + fieldAPI.replace('opp: ', ' ') + operator + value;
                        }
                    }
                    if (fieldAPI.contains('acc: ')) {
                        fieldAPI = fieldAPI.substring(fieldAPI.indexOf('acc: '), fieldAPI.length());
                        baseQuery += 'AND ' + fieldAPI.replace('acc: ', ' ') + operator +  value;
                    }
                }
            }

            if (filterOpties != '') {
                opportunityQuery += filterOpties;
                baseQuery = baseQuery.replace('{oppQuery}', '(' + opportunityQuery + ')');
            } else {
                baseQuery = baseQuery.replace(', {oppQuery}', '');
            }

            baseQuery += ' LIMIT 1000';

            system.debug('query+++----->' + baseQuery);

            try {
                List<Account> tmpAccs = Database.query(baseQuery);
                if(tmpAccs != null && tmpAccs.size() > 0){
                    String webURL = ApexPages.currentPage().getParameters().get('id');
                    List<LAT_AccountInAction__c> aiaList = [SELECT id, LAT_Account__c FROM LAT_AccountInAction__c WHERE LAT_PromotionalAction__c=:webURL];
                    Set<String> accList = new Set<String>();
                    for (LAT_AccountInAction__c aia: aiaList) {
                        accList.add(aia.LAT_Account__c);
                    }

                    listAccountInner.clear();
                    for(Account acc : tmpAccs){
                        if (((filterOpties != '' && !acc.Opportunities.isEmpty()) || filterOpties == '') && !accList.contains(acc.id)) {
                            LAT_accountInAction__c ain = new LAT_accountInAction__c();
                            ain.LAT_Account__c = acc.id;
                            //ain.Name = acc.Name;
                            ain.LAT_PromotionalAction__c = webURL;
                            ain.LAT_Status__C = 'Cliente Selecionado';
                            //ain.LAT_Execute__c = true;
                            //listAccount.add(ain);
                            listAccountInner.add(new accountInActionInner(ain, acc, false));
                        }
                    }
                } else {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Os filtros não contém dados válidos.'));
                }
            } catch (Exception e) {
                system.debug('Exception----->' + e.getMessage());
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Os filtros não contém dados válidos. Error: ' + e.getMessage()));
            }
            system.debug('query----->' + baseQuery);
        }
    }

    public PageReference save() {
        List<LAT_AccountInAction__c> toInsert = new List<LAT_AccountInAction__c>();
        for (accountInActionInner aiai: listAccountInner) {
          if (aiai.selected) {
            LAT_AccountInAction__c clienteFoco = aiai.aia;
            toInsert.add(clienteFoco);
          }
        }
        //try {
        system.debug('-^^&^&^&%^%&$%^$%^%$^$%^%$^$%^%$^$%^%$^%$^$%^%$^$%^%$^----->' + toInsert);
        upsert toInsert;

            String apId = ApexPages.currentPage().getParameters().get('id');
            return new PageReference('/' + apId);
        /*} catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Entre em contato com o administrador do sistema. ERROR:' + e.getMessage()));
            return null;
        }*/
    }

    public class filterConditionsWrapper{
        public String fieldName {get;set;}
        public String filterOption {get;set;}
        public String filterValue {get;set;}
        public String filterValue2 {get;set;}

        public filterConditionsWrapper () {}

        public filterConditionsWrapper (String fieldName, String filterOption, String filter) {
            this.fieldName = fieldName;
            this.filterOption = filterOption;
            this.filterValue = String.escapeSingleQuotes(filter);
        }

        public boolean hasFilter() {
            return (this.fieldName != null && this.filterOption != null && this.filterOption != null
                    && this.filterOption != '--None--' && this.fieldName != '' && ((this.filterValue != ''
                    && this.filterValue != null) || (this.filterValue2 != '' && this.filterValue2 != null)));
        }

        public String formatValue() {
            String returnValue = '';

            if (this.fieldName.contains('DATE')) {
                String year = this.filterValue2.split('/')[2];
                String month = this.filterValue2.split('/')[1];
                String day = this.filterValue2.split('/')[0];

                returnValue = year + '-' + month + '-' + day;

                if(this.fieldName.contains('TIME')) { returnValue += 'T00:00:00.000Z';}
                
            } else if (this.fieldName.contains('CURRENCY') || this.fieldName.contains('DOUBLE')
                        || this.fieldName.contains('PERCENT') || this.fieldName.contains('INTEGER')){
                returnValue = this.filterValue;
            } else if (this.fieldName.contains('BOOLEAN') || this.fieldName.contains('COMBOBOX')){
                if (this.filterValue == 'true' || this.filterValue == 'false') {
                    returnValue = this.filterValue;
                } else {
                    returnValue = 'false';
                }
            } else {
                //returnValue = '\'' + this.filterValue;

                if (this.filterOption.contains('LIKE')) {
                    returnValue = ' \'%' + this.filterValue + '%\' ';
                } else {
                    returnValue = ' \'' + this.filterValue + '\' ';
                }
            }

            return returnValue;
        }

    }

    class accountInActionInner{
        public LAT_AccountInAction__c aia {get; set;}
        public Account acc {get; set;}
        public boolean selected {get; set;}
        public String mechanic {get;set;}
		public String mechanicName {get;set;}

        public accountInActionInner(LAT_AccountInAction__c aia, Account acc, Boolean selected, String mechanic, string mechanicName) {
            this.aia = aia;
            this.selected = selected;
            this.acc = acc;
            this.mechanic = mechanic;
			this.mechanicName = mechanicName;
        }

        // Marianos's method
        public accountInActionInner(LAT_AccountInAction__c aia, Account acc, Boolean selected) {
            this.aia = aia;
            this.selected = selected;
            this.acc = acc;
            this.mechanic = '';
			this.mechanicName = 'Default';
        }
    }

    // Carga Csv
    public void upload() {

        try{

            listAccount= new List<LAT_AccountInAction__c>();
            List<List<String>> values = parseCSV(toParse.toString(), true);
            system.debug(values);

            if(values.size() <= 0){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'O arquivo não contém dados'));
            } else {

                String webURL = ApexPages.currentPage().getParameters().get('id');
                System.debug(webURL);
                if(webURL !=NULL && webURL != ''){
                    Set<String> countryAn8 = new Set<String>();
                    Set<String> countryCNPJ = new Set<String>();
					Set<String> mechanicsList = new Set<String>();

                    //Map<String, Boolean> mapCnpTofoco = new Map<String, Boolean>();
                    for (List<String> valList: values) {
                        if(valList.size() >= 1){
		                    countryAn8.add('1-' + valList[0]);
		                    countryCNPJ.add(valList[0]);

							if(valList.size() == 2){
  								System.debug('====================='+valList[1] );
								// If mechanic is empty
								if(valList[1] == null || valList[1]==''){
									// Default behaivor
								} else {
									// Filter with mechanic
									mechanicsList.add(valList[1]);
								}
  							}
                        }
                    }

					System.debug('\n===========================\n countryAn8 !=  '+ countryAn8 + '\n===================');
					System.debug('\n===========================\n countryCNPJ !=  '+ countryCNPJ + '\n===================');
					System.debug('\n===========================\n mechanicsList !=  '+ mechanicsList + '\n===================');


                    List<Account> tmpAccs = [Select id,Client_code_AN8__c,CNPJ__c,Client_country_AN8__c,Name,owner.managerId,owner.Gerente_de_area__c,owner.Gerente_regional__c, owner.Name, LAT_BR_RegionalClientOnPremise__c, Regional__r.Name, Sub_Channel_Rating__r.Name from Account where (client_country_an8__c in: countryAn8 OR CNPJ__c in: countryCNPJ)];
					List<LAT_Mecanica__c> mechanics = [SELECT Id, Name, LAT_Default__c from LAT_Mecanica__c where LAT_PromotionalAction__c =: webURL and Name IN :mechanicsList ];

					System.debug('\n===========================\n tmpAccs !=  '+ tmpAccs + '\n===================');


					// accountNotFound.addAll(countryAn8);
					// accountNotFound.addAll(countryCNPJ);
					for(String cA : countryAn8){
                        if(!cA.contains('1-')){
					       accountNotFound.add('Cliente: '+cA);
                        }
					}
					for(String cA : countryCNPJ){
                        if(!cA.contains('1-')){
					       accountNotFound.add('Cliente: '+cA);
                        } 
					}




					System.debug('\n===========================\n accountNotFound !=  '+ accountNotFound + '\n===================');

					if(tmpAccs != null && tmpAccs.size() > 0){


						// Original
                        List<LAT_AccountInAction__c> aiaList = [SELECT id, LAT_Account__c FROM LAT_AccountInAction__c WHERE LAT_PromotionalAction__c=:webURL];
						//List<LAT_AccountInAction__c> aiaList = [SELECT Id, LAT_Account__c, LAT_Account__r.CNPJ__c, Lat_account__r.client_country_an8__c, mechanic__c, mechanic__r.name  FROM LAT_AccountInAction__c WHERE LAT_PromotionalAction__c=:webURL];

						//List<LAT_AccountInAction__c> tmpAC = [Select Id, LAT_Account__c, LAT_Account__r.CNPJ__c, Lat_account__r.client_country_an8__c, mechanic__c, mechanic__r.name from  LAT_AccountInAction__c where  where (LAT_Account__r.client_country_an8__c in: LAT_Account__r.countryAn8 OR CNPJ__c in: countryCNPJ) and mechanic__r.name='Mecânica Off'];

                        Set<Id> accList = new Set<Id>();
						Map<Id, Id> accAccInActionMap = new Map<Id, Id>();

                        for (LAT_AccountInAction__c aia: aiaList) {
                            accList.add(aia.LAT_Account__c);
							accAccInActionMap.put(aia.LAT_Account__c, aia.id);
                        }

						System.debug('\n===========================\n accList !=  '+ accList+ '\n===================');

                        for(Account acc : tmpAccs){
							// TO DO: Remove this control
                          //if (!accList.contains(acc.id)) {

						  System.debug('\n===========================\n acc.CNPJ__c !=  '+ acc.CNPJ__c + '\n===================');

							//Errors check
							if(accountNotFound.contains('Cliente: '+acc.CNPJ__c) || accountNotFound.contains('Cliente: '+acc.Client_code_AN8__c)){
								accountNotFound.remove('Cliente: '+acc.Client_country_AN8__c);
								accountNotFound.remove('Cliente: '+acc.CNPJ__c);
								accountNotFound.remove('Cliente: '+acc.Client_code_AN8__c);
								accountNotFound.remove('Cliente: 1-'+acc.CNPJ__c);
							}

                            LAT_accountInAction__c ain = new LAT_accountInAction__c();
                            ain.LAT_Account__c = acc.id;
							// We set the id, because we need to do an update
							if (accList.contains(acc.id)) {
								ain.Id = accAccInActionMap.get(acc.id) ;
							}
								System.debug('\n===========================\n ain.Id !=  '+ ain.Id+ '\n===================');
                            //ain.Name = acc.Name;
                            ain.LAT_PromotionalAction__c = webURL ;
                            ain.LAT_Status__C = 'Cliente Selecionado';
                            /*system.debug('---->' + mapCnpTofoco.get(acc.Client_country_AN8__c));
                            system.debug('---->' + mapCnpTofoco.get(acc.CNPJ__c));
                            if (acc.Client_country_AN8__c != null && mapCnpTofoco.get(acc.Client_country_AN8__c) != null) {
                              ain.LAT_Execute__c = mapCnpTofoco.get(acc.Client_country_AN8__c);
                            }
                            if (acc.CNPJ__c != null && mapCnpTofoco.get('1-' + acc.CNPJ__c) != null) {
                              ain.LAT_Execute__c = mapCnpTofoco.get('1-' + acc.CNPJ__c);
                            }*/

                            //ain.LAT_Execute__c = true;
                            //listAccount.add(ain);
							Set<String> setMech = new Set<String>();
							Set<String> setMechSelected = new Set<String>();
							for (List<String> valList: values) {

								String an8 = '1-' + valList[0];
								String cNPJ = valList[0];

		                        if(valList.size() >= 2){

									String mechanicName = valList[1];
									setMech.add(mechanicName);
                                    String mechanicToSave = '';
                                    if(mechanics.size()>0 ){
                                        // Mechanic Name != Empty
                                        if(mechanicName != ''){
                                            for(LAT_Mecanica__c mec : mechanics){
                                                System.debug('\n===========================\n mec !=  '+ mec.name + '\n===================');
                                                System.debug('\n===========================\n mechanicName !=  '+ mechanicName + '\n===================');

												if(mec.Name == mechanicName){
													mechanicToSave =  String.valueOf(mec.Id) ;
													setMechSelected.add(mec.Name.tolowercase());
                                                    System.debug('\n===========================\n TRUUUUUUUUE \n===================');

												} else {
													// If the mechanic doesn't exists we must show to the user
													//
                                                    System.debug('\n===========================\n FALSE \n===================');

												}
                                            }
                                            System.debug('\n===========================\n mechanicToSave  '+mechanicToSave +'\n===================');
                                        }
                                        // Mechanic Name == Empty
                                        else {
                                            // for(LAT_Mecanica__c mec : mechanics){
                                            //     mechanicToSave = (mec.Name == mechanicName) ? mec.Id : '' ;
                                            // }
                                            System.debug('\n===========================\n Mechanic Name == Empty  '+mechanicToSave +'\n===================');
                                        }
                                    }

									if(an8 == acc.Client_country_AN8__c || cNPJ == acc.CNPJ__c ) {
										if(mechanicToSave == ''){

											//listAccountInner.add(new accountInActionInner(ain, acc, false, '', 'Default'));
										} else {
											ain.mechanic__c = Id.valueOf(mechanicToSave);
											listAccountInner.add(new accountInActionInner(ain, acc, false, mechanicToSave, mechanicName));
										}

									}
		                        } else {
									if(an8 == acc.Client_country_AN8__c || cNPJ == acc.CNPJ__c ) {
										listAccountInner.add(new accountInActionInner(ain, acc, false));
									}
                                }
		                    //}
                          }
						  System.debug('\n===========================\n setMech %%%%%%%%%%%  '+setMech +'\n===================');
						  System.debug('\n===========================\n setMechSelected %%%%%%%%%%%  '+setMechSelected +'\n===================');

						  for(String mecN : setMech){
							  System.debug('\n===========================\n mecN %%%%%%%%%%%  '+mecN +'\n===================');


							if(!setMechSelected.contains(mecN.tolowercase())) { accountNotFound.add('Mecânica: ' + mecN);}


						  }
                        }
						if(accountNotFound.size() > 0){hasErrors =true;}
                        System.debug('\n===========================\n listAccountInner  '+listAccountInner +'\n===================');
                        //insert listAccount;

                        //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM,'Carga satisfatório. Processo:<a href="/'+ webURL +'">' + 'Voltar para promoção' + '</a>'));
                    } else {
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'O arquivo não contém dados válidos.'));
                    }
                } else{ ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Inválido ação promocional.'));}
            }
        } catch(exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage())); }
    }

    public PageReference addRow() {
        this.filterList.add(new filterConditionsWrapper());
        return null;
    }

    public PageReference removeRow() {
        this.filterList.remove(this.filterList.size()-1);
        return null;
    }

    public static List<List<String>> parseCSV(String contents,Boolean skipHeaders) {
        List <List <String>> allFields = new List<List<String>>();

        System.debug('111111111111111' + contents);
        contents = contents.replaceAll(',"""',',"DBLQT').replaceall('""",','DBLQT",');

        System.debug('22222222222222222' + contents);
        contents = contents.replaceAll('""','DBLQT');

        System.debug('33333333333333333' + contents);
        List <String> lines = new List<String>();
        try {
            lines = contents.split('\n');

        System.debug('444444444444444444' + lines);
        } catch (System.ListException e) {
            System.debug('Limits exceeded?' + e.getMessage());
        }
        Integer num = 0;
        for(String line : lines) {
            // check for blank CSV lines (only commas)
            if (line.replaceAll(',','').trim().length() == 0) break;
            if (line.replaceAll(';','').trim().length() == 0) break;

            system.debug('ˆˆˆˆˆˆˆˆˆˆˆˆ fields a: ' + line);
            List <String> fields = line.split(',');
            system.debug('ˆˆˆˆˆˆˆˆˆˆˆˆ fields b: ' + fields);
            if (fields.size() == 1) {
                fields = line.split(';');
            }

            system.debug('ˆˆˆˆˆˆˆˆˆˆˆˆ fields c: ' + fields);
            List <String> cleanFields = new List<String>();
            String compositeField;
            Boolean makeCompositeField = false;
            for(String field : fields) {
                if (field.startsWith('"') && field.endsWith('"')) {
                    cleanFields.add(field.replaceAll('DBLQT','"'));
                    System.debug('$$$$$$$$$$$$$$$$$$ in 1' + field);
                } else if (field.startsWith('"')) {
                      makeCompositeField = true;
                      compositeField = field;
                      System.debug('$$$$$$$$$$$$$$$$$$ in 2' + field);
                } else if (field.endsWith('"')) {
                      compositeField += ',' + field;
                      cleanFields.add(compositeField.replaceAll('DBLQT','"'));
                      makeCompositeField = false;
                      System.debug('$$$$$$$$$$$$$$$$$$ in 3' + field);
                } else if (makeCompositeField) {
                      compositeField +=  ',' + field;
                      System.debug('$$$$$$$$$$$$$$$$$$ in 4' + field);
                } else {
                      cleanFields.add(field.trim());
                      System.debug('$$$$$$$$$$$$$$$$$$ in 5' + field);
                }
            }
            allFields.add(cleanFields);
        }
        if (skipHeaders) allFields.remove(0);
        return allFields;
    }

    public PageReference cancel() {
      String webURL = ApexPages.currentPage().getParameters().get('id');
      return new PageReference('/' + webURL);
    }
}