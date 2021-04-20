global class LAT_UpdateAccountOwner_Batch implements Database.Batchable<sObject>, Database.Stateful,Database.AllowsCallouts {	
    String strSOQL = null;
	LAT_MasiveOwnerHeader__c objHeader = null;
	List <LAT_MasiveOwnerLine__c> lstMassiveLine = new List<LAT_MasiveOwnerLine__c>();
	Set <Id> setAccountIds = new Set<Id>();
	Set <Id> setAccountBridgeIds = new Set<Id>();

	global LAT_UpdateAccountOwner_Batch(String strId) {
        List <LAT_MasiveOwnerHeader__c> lstMassiveUpdateHeader =  null;

        System.debug('LAT_UpdateAccountOwner_Batch [strId : ' + strId + '] ->');
        lstMassiveUpdateHeader = [SELECT Id, CreatedById 
                                    FROM LAT_MasiveOwnerHeader__c 
                                    WHERE Id =: strId];
        

		lstMassiveLine = new List<LAT_MasiveOwnerLine__c>();
		setAccountBridgeIds = new Set<Id>();
		if (!lstMassiveUpdateHeader.IsEmpty()) {
			objHeader = lstMassiveUpdateHeader[0];
		}

        strSOQL = retrieveSOQL(strID); 		
    
        System.debug('LAT_UpdateAccountOwner_Batch [] <-');
	}
	
	global Database.QueryLocator start(Database.BatchableContext objBatchableContext) {
        Database.QueryLocator objQueryLocator = null;
        System.debug('LAT_UpdateAccountOwner_Batch.start [objBatchableContext : ' + objBatchableContext + '] ->');

        objQueryLocator = Database.getQueryLocator(strSOQL);		

        System.debug('LAT_UpdateAccountOwner_Batch.start [' + objQueryLocator + '] <-');
        return objQueryLocator;
	}

   	global void execute(Database.BatchableContext objBatchableContext, List<sObject> lstScope) {
		List <LAT_MasiveOwnerLine__c> lstLines = null;
        
        System.debug('LAT_UpdateAccountOwner_Batch.execute [objBatchableContext : ' + objBatchableContext + '] ->');
        lstLines = (List<LAT_MasiveOwnerLine__c>)lstScope;

		for (LAT_MasiveOwnerLine__c objLine : lstLines) {
			if (objLine.LAT_AccountAN8__c == 'Not exists') {
				objLine.LAT_Account__r.OwnerId = objLine.LAT_NewValue__c;				
                System.debug('LAT_UpdateAccountOwner_Batch.execute [objBatchableContext : ' + objBatchableContext + '] ->');
			} else {
                objLine.LAT_Account__r.OwnerId = objLine.LAT_NewValue__c;
                objLine.LAT_Account__r.Owner = objLine.LAT_NewValue__r;
                objLine.LAT_Account__r.Is_interface_Process_AR__c = true;
                
				if (objLine.LAT_Account__r.Client_country_AN8__c.startsWith('1-')) {
                    System.debug('LAT_UpdateAccountOwner_Batch.start [Transferir cuenta de Brasil]');
					if(!Test.isRunningTest()) {
						setAccountIds.add(objLine.LAT_Account__c);
					}					
				} else {
                    System.debug('LAT_UpdateAccountOwner_Batch.start [Transferir cuentas de otros paises (No Brasil)]');
					if(!Test.isRunningTest()){
                        System.debug('LAT_UpdateAccountOwner_Batch[objLine.LAT_Account__r.Client_country_AN8__c : ' + objLine.LAT_Account__r.Client_country_AN8__c + ']');
                        System.debug('LAT_UpdateAccountOwner_Batch[LAT_GeneralConfig__c.getInstance(MX_USE_BRIDGE_IN_CUSTOMERHANDLER) : ' + LAT_GeneralConfig__c.getInstance('MX_USE_BRIDGE_IN_CUSTOMERHANDLER') + ']');
                        System.debug('LAT_UpdateAccountOwner_Batch[LAT_GeneralConfig__c.getInstance(MX_USE_BRIDGE_IN_CUSTOMER_ACTIVE) : ' + LAT_GeneralConfig__c.getInstance('MX_USE_BRIDGE_IN_CUSTOMER_ACTIVE') + ']');
                        if(objLine.LAT_Account__r.Client_country_AN8__c.startsWith('12-') && LAT_GeneralConfig__c.getInstance('MX_USE_BRIDGE_IN_CUSTOMERHANDLER') != null){
							setAccountBridgeIds.add(objLine.LAT_Account__c);
						} else {
							setAccountIds.add(objLine.LAT_Account__c);
						}						
					}	
				}
								
			}
			objLine.LAT_Executed__c = true;
			lstMassiveLine.add(objLine);
			update objLine.LAT_Account__r;
        }		
        
        System.debug('LAT_UpdateAccountOwner_Batch.start [] <-');
	}
	
	global void finish(Database.BatchableContext objBatchableContext) {
        List<Account> lstAccounts = null;
        String strHTML = null;
        String strSubmittersEmail = null;
        System.debug('LAT_UpdateAccountOwner_Batch.start [objBatchableContext : ' + objBatchableContext + '] ->');
	
        
        if (objHeader != null) {
            lstAccounts = getAccounts(setAccountIds);
			try {
                System.debug('LAT_UpdateAccountOwner_Batch.start [objBatchableContext : ' + objBatchableContext + '] ->');
				if(setAccountBridgeIds != null && !setAccountBridgeIds.IsEmpty()) {
					for(Id objId : setAccountBridgeIds) {
						//INTEGRA VALORES ANTIGUOS PORQUE PRIMERO INTEGRA Y LUEGO GUARDA
						LAT_BridgeGS1_Customer.execute(objId, null);
					}	
				}

                strHTML = '<html><body><b>' + Label.LAT_UpdateAccountOwner_Mail01 + '</b> <br> <br><table width="75%" align="center" cellpadding="10"><tr><td><b>' + Label.LAT_UpdateAccountOwner_Mail02 + '<b/></td><td><b>' + Label.LAT_UpdateAccountOwner_Mail03 + '<b/></td><td><b>Status<b/></td></tr> ';
                for(Account objAccount : lstAccounts) {
                    CustomerInterfaceJDESync(objAccount);

                    strHTML += '<tr><td>' + objAccount.Name + '</td><td>' + objAccount.Owner.Name + '</td><td>' + objAccount.Status__c + '</td></tr>';
                }                
				strHTML += '</table></body></html>';

				objHeader.LAT_Status__c = 'Completed';
				update objHeader;
                update lstMassiveLine;
                

                strSubmittersEmail = retrieveSubmittersEmail(objHeader.CreatedById);
                sendNotificationEmail(strSubmittersEmail, strHTML);
            } catch (Exception Ex) {
                System.debug('AccountUpdateException [Message : ' + Ex.getMessage() + ']');
                System.debug('AccountUpdateException [StackTrace : ' + Ex.getStackTraceString() + ']');
    
                throw Ex;
            }			
		}
	}
	
  	public static void CustomerInterfaceJDESync (Account objAccount) {    
        String strCountry = null;
        LAT_WS_CustomerHandlerTypes.CustomerHandlerArgumentsType objCustomerArguments = null;
		LAT_WS_CustomerHandler.port objRequest = null; 
        LAT_WS_CustomerHandlerTypes.ClientInfoType objClientInfo = null;
        LAT_WS_CustomerHandlerRequestResponseTyp.AsyncIntegrationResponseType objResponse = null;
		String strEnpoint = null;

        System.debug('LAT_UpdateAccountOwner_Batch.CustomerInterfaceJDESync [objAccount : ' + objAccount + '] ->');

        if(objAccount != null) {
            strCountry = LAT_WS_CustomerHandlerInterface.getCountryInfo(objAccount.RecordTypeId);
		
            objCustomerArguments = LAT_WS_CustomerHandlerInterface.getCustomerArguments(objAccount, strCountry);
            objRequest = new LAT_WS_CustomerHandler.port(); 
            objClientInfo = LAT_WS_CustomerHandlerInterface.getConnectionParameter(strCountry);
            strEnpoint = LAT_WS_Utils.getWSEndpoint(objClientInfo.country);
            System.debug('LAT_UpdateAccountOwner_Batch.CustomerInterfaceJDESync [strEnpoint : ' + strEnpoint + ']');
            System.debug('LAT_UpdateAccountOwner_Batch.CustomerInterfaceJDESync [objCustomerArguments : ' + objCustomerArguments + ']');
            
            if(!Test.isRunningTest()){
                objResponse = objRequest.operation(objClientInfo, objCustomerArguments, strEnpoint, true, objAccount.Id);
                System.debug('LAT_UpdateAccountOwner_Batch.CustomerInterfaceJDESync [objResponse : ' + objResponse + ']');

                objAccount = LAT_WS_CustomerHandlerInterface.parseResponse(objResponse, objAccount);
                System.debug('LAT_UpdateAccountOwner_Batch.CustomerInterfaceJDESync [objAccount : ' + objAccount + ']');
            } 
        } else {
            System.debug('LAT_UpdateAccountOwner_Batch.CustomerInterfaceJDESync [Account is null]');
        }		    
  	}

  	public static List<Account> getAccounts(Set<Id> setAccountIds) {
        List<Account> lstAccounts = null;

        System.debug('getAccounts [setAccountIds : ' + setAccountIds + '] ->');

        lstAccounts =[SELECT   Accept_applications_Incompleted__c, Accept_Backorder__c, Accept_line_incompleted__c, Affiliate__c, Agency__c, 
                                Bank__r.Name, Bank_number__c, Barcode_EDI__c, Billing_Address_Code__c, Billing_Priority__c, Business_Unit__r.CodDefUsuario__c, 
                                Carriers_Numbers__c, 
                                Channel__c, 
                                Checking_account__c, 
                                Client_code_AN8__c, 
                                CNPJ__c, 
                                Corporate_Name__c,
                                Credit_line__c, 
                                Current_account__c, 
                                Customer_Flag__r.CodDefUsuario__c, 
                                Customer_Geographic_Region__r.CodDefUsuario__c, 
                                Customer_GL__r.CodDefUsuario__c, 
                                Customer_Organization__r.CodDefUsuario__c, 
                                Discount_Group__c, 
                                Email_NFE__c, 
                                Fax, 
                                Freight_Type__c, 
                                LAT_BR_BusinessSize__c,
                                LAT_BR_FiscalBenefit__c,
                                LAT_BR_PriorityLevel__c, 
                                Municipal_Registration__c, 
                                Nielsen_Area__r.CodDefUsuario__c, 
                                OwnerId, 
                                ParentId,
                                Parent.Client_code_AN8__c, 
                                Payment_Condition__r.CodDefUsuario__c, 
                                Payment_instrument__r.CodDefUsuario__c,
                                Phone, 
                                Rating_segmentation_targert_market__c, 
                                Rating, 
                                Receiving_Freight__c, 
                                RecordTypeId, 
                                Regional__r.CodDefUsuario__c, 
                                Revenue_Address__c, 
                                Revenue_City__r.Name,
                                Revenue_City_Code__c, 
                                Revenue_Complement__c, 
                                Revenue_Country__c, 
                                Revenue_Neighbourhood__c, 
                                Revenue_Number__c, 
                                Revenue_Postal_Code__c,  
                                Revenue_UF__c,
                                Shipping_Address_Code__c, 
                                State_registration__c,     
                                Sub_Channel_Rating__r.CodDefUsuario__c, 
                                Type,
                                WebSite,
                                Yes_No__c,                                  
                                CurrencyISOCode,
                                Owner.C_digo_JDE__c,
                                // AR and UY Fields
                                AddressLine1_AR__c, 
                                CatCode02_AR__r.CodDefUsuario__c, 
                                CollectionAgent_AR__r.CodDefUsuario__c,
                                CustomerPriceGroup_AR__r.CodDefUsuario__c,
                                CustomerPoRequired_AR__c,
                                Id,
                                Name,
                                Regional_AR__r.CodDefUsuario__c,
                                Status__c,
                                LAT_Account__r.LAT_JDEZone__c,
                                // MX Fields
                                AccountNumber,
                                Business_Unit_AR__r.CodDefUsuario__c,
                                Client_country_AN8__c, 
                                Is_interface_Process_AR__c,
                                LAT_MX_ABCCode__r.CodDefUsuario__c,
                                LAT_MX_AmountReceiptCopies__c, 
                                LAT_MX_BatchProcess__r.CodDefUsuario__c,
                                LAT_MX_BreakDownIEPS__c, 
                                LAT_MX_CableCodeS__c, 
                                LAT_MX_Chain__r.CodDefUsuario__c, 
                                LAT_MX_City__c, 
                                LAT_MX_County__c, 
                                LAT_MX_CreditVersionLevel__c, 
                                LAT_MX_CRMClientCode__c, 
                                LAT_MX_FiscalEntityType__c, 
                                LAT_MX_FiscalRate__r.CodDefUsuario__c, 
                                LAT_MX_Group__r.CodDefUsuario__c, 
                                LAT_MX_Language__c, 
                                LAT_MX_Market__c, 
                                LAT_MX_Neighbourhood__c, 
                                LAT_MX_PostalCode__r.Name, 
                                LAT_MX_RelatedAddressAN8__c, 
                                LAT_MX_RouteCode__r.CodDefUsuario__c, 
                                LAT_MX_State__c, 
                                LAT_MX_ZoneNumber__r.CodDefUsuario__c, 
                                Owner.Email, 
                                Owner.Name,
                                Return_JDE_Integration__c, 
                                Segmentation_Type_on_trade__c,
                                LAT_BR_RegionalClientOnPremise__c,
                                (SELECT Id,
                                        Name,
                                        Obtained_Beneficio_Fiscal_Udc__r.CodDefUsuario__c,
                                        Obtained_Segment_Udc__r.CodDefUsuario__c,
                                        Obtained_Perfil_Udc__r.CodDefUsuario__c,
                                        Obtained_Client_type_Udc__r.CodDefUsuario__c,
                                        Obtained_Estrategia_comercial_Udc__r.CodDefUsuario__c,
                                        Obtained_Channel_Udc__r.CodDefUsuario__c,
                                        Obtained_SubChannel_Udc__r.CodDefUsuario__c,
                                        Obtained_PRIOR_DE_INVESTIMENTO_Udc__r.CodDefUsuario__c,
                                        Obtained_Formato_Udc__r.CodDefUsuario__c,
                                        Obtained_POLiTICA_DE_PRECO_Udc__r.CodDefUsuario__c
                                    FROM Segmentation_Results__r 
                                WHERE Client_Segmentation_2__r.Status__c = 'Active')
                        FROM Account
                        WHERE Id =: setAccountIds];

        System.debug('getAccounts [' + lstAccounts + '] <-');
        return lstAccounts;
    }

    private static String retrieveSOQL(String strID) {
        String strSOQL = null;

		strSOQL = 'SELECT Id, OwnerId, LAT_AccountAN8__c, LAT_NewValue__c,LAT_NewValue__r.C_digo_JDE__c, LAT_Executed__c,LAT_Account__r.Accept_applications_Incompleted__c,LAT_Account__r.Accept_Backorder__c, LAT_Account__r.Accept_line_incompleted__c, ' +
					'LAT_Account__r.Affiliate__c, LAT_Account__r.Agency__c, LAT_Account__r.Bank__r.Name, LAT_Account__r.Bank_number__c, ' +
					'LAT_Account__r.Barcode_EDI__c, LAT_Account__r.Billing_Address_Code__c, LAT_Account__r.Billing_Priority__c, ' +
					'LAT_Account__r.Business_Unit__r.CodDefUsuario__c, LAT_Account__r.Carriers_Numbers__c, LAT_Account__r.Channel__c, ' +
					'LAT_Account__r.Checking_account__c, LAT_Account__r.Client_code_AN8__c, LAT_Account__r.CNPJ__c, ' +
					'LAT_Account__r.Corporate_Name__c,LAT_Account__r.Credit_line__c, LAT_Account__r.Current_account__c, ' +
					'LAT_Account__r.Customer_Flag__r.CodDefUsuario__c, LAT_Account__r.Customer_Geographic_Region__r.CodDefUsuario__c, ' +
					'LAT_Account__r.Customer_GL__r.CodDefUsuario__c, LAT_Account__r.Customer_Organization__r.CodDefUsuario__c, ' +
					'LAT_Account__r.Discount_Group__c, LAT_Account__r.Email_NFE__c, LAT_Account__r.Fax, LAT_Account__r.Freight_Type__c, ' +
					'LAT_Account__r.LAT_BR_BusinessSize__c,LAT_Account__r.LAT_BR_FiscalBenefit__c,LAT_Account__r.LAT_BR_PriorityLevel__c, ' +
					'LAT_Account__r.Municipal_Registration__c, LAT_Account__r.Nielsen_Area__r.CodDefUsuario__c, LAT_Account__r.OwnerId, ' +
					'LAT_Account__r.ParentId,LAT_Account__r.Parent.Client_code_AN8__c, LAT_Account__r.Payment_Condition__r.CodDefUsuario__c, ' +
					'LAT_Account__r.Payment_instrument__r.CodDefUsuario__c,LAT_Account__r.Phone, LAT_Account__r.Rating_segmentation_targert_market__c, ' +
					'LAT_Account__r.Rating, LAT_Account__r.Receiving_Freight__c, LAT_Account__r.RecordTypeId, LAT_Account__r.Regional__r.CodDefUsuario__c, ' +
					'LAT_Account__r.Revenue_Address__c, LAT_Account__r.Revenue_City__r.Name,LAT_Account__r.Revenue_City_Code__c, ' +
					'LAT_Account__r.Revenue_Complement__c, LAT_Account__r.Revenue_Country__c, LAT_Account__r.Revenue_Neighbourhood__c, ' +
					'LAT_Account__r.Revenue_Number__c, LAT_Account__r.Revenue_Postal_Code__c,  LAT_Account__r.Revenue_UF__c, ' +
					'LAT_Account__r.Shipping_Address_Code__c, LAT_Account__r.State_registration__c, LAT_Account__r.Sub_Channel_Rating__r.CodDefUsuario__c, ' +
					'LAT_Account__r.Type,LAT_Account__r.WebSite,LAT_Account__r.Yes_No__c, LAT_Account__r.CurrencyISOCode, ' +
					'LAT_Account__r.Owner.C_digo_JDE__c,LAT_Account__r.AddressLine1_AR__c, LAT_Account__r.CatCode02_AR__r.CodDefUsuario__c, ' +
					'LAT_Account__r.CollectionAgent_AR__r.CodDefUsuario__c,LAT_Account__r.CustomerPriceGroup_AR__r.CodDefUsuario__c, ' +
					'LAT_Account__r.CustomerPoRequired_AR__c,LAT_Account__r.Id,LAT_Account__r.Name,LAT_Account__r.Regional_AR__r.CodDefUsuario__c, ' +
					'LAT_Account__r.Status__c,LAT_Account__r.AccountNumber,LAT_Account__r.Business_Unit_AR__r.CodDefUsuario__c, ' +
					'LAT_Account__r.Client_country_AN8__c, LAT_Account__r.Is_interface_Process_AR__c,LAT_Account__r.LAT_MX_ABCCode__r.CodDefUsuario__c,' +
					'LAT_Account__r.LAT_MX_AmountReceiptCopies__c, LAT_Account__r.LAT_MX_BatchProcess__r.CodDefUsuario__c, ' +
					'LAT_Account__r.LAT_MX_BreakDownIEPS__c, LAT_Account__r.LAT_MX_CableCodeS__c, LAT_Account__r.LAT_MX_Chain__r.CodDefUsuario__c, ' +
					'LAT_Account__r.LAT_MX_City__c, LAT_Account__r.LAT_MX_County__c, LAT_Account__r.LAT_MX_CreditVersionLevel__c, ' +
					'LAT_Account__r.LAT_MX_CRMClientCode__c, LAT_Account__r.LAT_MX_FiscalEntityType__c, LAT_Account__r.LAT_MX_FiscalRate__r.CodDefUsuario__c, ' +
					'LAT_Account__r.LAT_MX_Group__r.CodDefUsuario__c, LAT_Account__r.LAT_MX_Language__c, LAT_Account__r.LAT_MX_Market__c, ' +
					'LAT_Account__r.LAT_MX_Neighbourhood__c, LAT_Account__r.LAT_MX_PostalCode__r.Name, LAT_Account__r.LAT_MX_RelatedAddressAN8__c, ' +
					'LAT_Account__r.LAT_MX_RouteCode__r.CodDefUsuario__c, LAT_Account__r.LAT_MX_State__c, LAT_Account__r.LAT_MX_ZoneNumber__r.CodDefUsuario__c, ' +
					'LAT_Account__r.Owner.Email, LAT_Account__r.Owner.Name,LAT_Account__r.Return_JDE_Integration__c, LAT_Account__r.Segmentation_Type_on_trade__c, ' +
					'LAT_Account__r.LAT_Account__r.LAT_JDEZone__c, LAT_Account__c '+
                    'FROM LAT_MasiveOwnerLine__c WHERE LAT_Header__c = \'' + strID + '\'';
                    
        return strSOQL;
    }

    private String retrieveSubmittersEmail(Id objSubmitterId) {
        User objUser = null;

        System.debug('retrieveSubmittersEmail [] ->');
        objUser = [SELECT Id, Email, Name FROM User WHERE id = :objSubmitterId];

        System.debug('retrieveSubmittersEmail [' + objUser.Email + '] <-');
        return objUser.Email;
    }

    private void sendNotificationEmail(String strSubmitterEmail, String strBody) {
        String[] lstEmailAddress = null;
        Messaging.SingleEmailMessage objEmailMessage = null;
        List<Messaging.SingleEmailMessage> lstSingleEmailMessage = null;

        System.debug('sendNotificationEmail [strSubmitterEmail : ' + strSubmitterEmail + ' - strBody : ' + strBody + '] ->');

        lstEmailAddress = LAT_GeneralConfigDao.getValueAsStringArray('MASIVE_OWNER_EMAIL_TARGET_ADDRESSES', ',');
        lstEmailAddress.add(strSubmitterEmail);
        
        objEmailMessage = new Messaging.SingleEmailMessage();
        objEmailMessage.setToAddresses(lstEmailAddress);
        objEmailMessage.setHtmlBody(strBody);
        objEmailMessage.setSenderDisplayName('noreply@pernod-ricard.com');
        objEmailMessage.setSubject(Label.LAT_UpdateAccountOwner_Mail05);
        lstSingleEmailMessage = new List<Messaging.SingleEmailMessage>();
        lstSingleEmailMessage.add(objEmailMessage);	
        
        Messaging.sendEmail(lstSingleEmailMessage);

        System.debug('sendNotificationEmail [] <-');
    }
}
/*
global class LAT_UpdateAccountOwner_Batch implements Database.Batchable<sObject>,Database.Stateful,Database.AllowsCallouts {
	
	String query;
	LAT_MasiveOwnerHeader__c header;
	List <Account> toUpdateAcc = new List<Account>();
	List <LAT_MasiveOwnerLine__c> toUpdate = new List<LAT_MasiveOwnerLine__c>();
	Set <Id> accountsIds = new Set<Id>();

	
	global LAT_UpdateAccountOwner_Batch(String headerId) {
		List <LAT_MasiveOwnerHeader__c> lst = [SELECT Id, CreatedById FROM LAT_MasiveOwnerHeader__c WHERE Id =: headerId];
		toUpdateAcc = new List<Account>();
		toUpdate = new List<LAT_MasiveOwnerLine__c>();
		if (lst != null && lst.size() > 0) {
			header = lst[0];
		}

		query = 'SELECT Id, OwnerId, LAT_AccountAN8__c, LAT_NewValue__c,LAT_NewValue__r.C_digo_JDE__c, LAT_Executed__c,LAT_Account__r.Accept_applications_Incompleted__c,LAT_Account__r.Accept_Backorder__c, LAT_Account__r.Accept_line_incompleted__c, ' +
					'LAT_Account__r.Affiliate__c, LAT_Account__r.Agency__c, LAT_Account__r.Bank__r.Name, LAT_Account__r.Bank_number__c, ' +
					'LAT_Account__r.Barcode_EDI__c, LAT_Account__r.Billing_Address_Code__c, LAT_Account__r.Billing_Priority__c, ' +
					'LAT_Account__r.Business_Unit__r.CodDefUsuario__c, LAT_Account__r.Carriers_Numbers__c, LAT_Account__r.Channel__c, ' +
					'LAT_Account__r.Checking_account__c, LAT_Account__r.Client_code_AN8__c, LAT_Account__r.CNPJ__c, ' +
					'LAT_Account__r.Corporate_Name__c,LAT_Account__r.Credit_line__c, LAT_Account__r.Current_account__c, ' +
					'LAT_Account__r.Customer_Flag__r.CodDefUsuario__c, LAT_Account__r.Customer_Geographic_Region__r.CodDefUsuario__c, ' +
					'LAT_Account__r.Customer_GL__r.CodDefUsuario__c, LAT_Account__r.Customer_Organization__r.CodDefUsuario__c, ' +
					'LAT_Account__r.Discount_Group__c, LAT_Account__r.Email_NFE__c, LAT_Account__r.Fax, LAT_Account__r.Freight_Type__c, ' +
					'LAT_Account__r.LAT_BR_BusinessSize__c,LAT_Account__r.LAT_BR_FiscalBenefit__c,LAT_Account__r.LAT_BR_PriorityLevel__c, ' +
					'LAT_Account__r.Municipal_Registration__c, LAT_Account__r.Nielsen_Area__r.CodDefUsuario__c, LAT_Account__r.OwnerId, ' +
					'LAT_Account__r.ParentId,LAT_Account__r.Parent.Client_code_AN8__c, LAT_Account__r.Payment_Condition__r.CodDefUsuario__c, ' +
					'LAT_Account__r.Payment_instrument__r.CodDefUsuario__c,LAT_Account__r.Phone, LAT_Account__r.Rating_segmentation_targert_market__c, ' +
					'LAT_Account__r.Rating, LAT_Account__r.Receiving_Freight__c, LAT_Account__r.RecordTypeId, LAT_Account__r.Regional__r.CodDefUsuario__c, ' +
					'LAT_Account__r.Revenue_Address__c, LAT_Account__r.Revenue_City__r.Name,LAT_Account__r.Revenue_City_Code__c, ' +
					'LAT_Account__r.Revenue_Complement__c, LAT_Account__r.Revenue_Country__c, LAT_Account__r.Revenue_Neighbourhood__c, ' +
					'LAT_Account__r.Revenue_Number__c, LAT_Account__r.Revenue_Postal_Code__c,  LAT_Account__r.Revenue_UF__c, ' +
					'LAT_Account__r.Shipping_Address_Code__c, LAT_Account__r.State_registration__c, LAT_Account__r.Sub_Channel_Rating__r.CodDefUsuario__c, ' +
					'LAT_Account__r.Type,LAT_Account__r.WebSite,LAT_Account__r.Yes_No__c, LAT_Account__r.CurrencyISOCode, ' +
					'LAT_Account__r.Owner.C_digo_JDE__c,LAT_Account__r.AddressLine1_AR__c, LAT_Account__r.CatCode02_AR__r.CodDefUsuario__c, ' +
					'LAT_Account__r.CollectionAgent_AR__r.CodDefUsuario__c,LAT_Account__r.CustomerPriceGroup_AR__r.CodDefUsuario__c, ' +
					'LAT_Account__r.CustomerPoRequired_AR__c,LAT_Account__r.Id,LAT_Account__r.Name,LAT_Account__r.Regional_AR__r.CodDefUsuario__c, ' +
					'LAT_Account__r.Status__c,LAT_Account__r.AccountNumber,LAT_Account__r.Business_Unit_AR__r.CodDefUsuario__c, ' +
					'LAT_Account__r.Client_country_AN8__c, LAT_Account__r.Is_interface_Process_AR__c,LAT_Account__r.LAT_MX_ABCCode__r.CodDefUsuario__c,' +
					'LAT_Account__r.LAT_MX_AmountReceiptCopies__c, LAT_Account__r.LAT_MX_BatchProcess__r.CodDefUsuario__c, ' +
					'LAT_Account__r.LAT_MX_BreakDownIEPS__c, LAT_Account__r.LAT_MX_CableCodeS__c, LAT_Account__r.LAT_MX_Chain__r.CodDefUsuario__c, ' +
					'LAT_Account__r.LAT_MX_City__c, LAT_Account__r.LAT_MX_County__c, LAT_Account__r.LAT_MX_CreditVersionLevel__c, ' +
					'LAT_Account__r.LAT_MX_CRMClientCode__c, LAT_Account__r.LAT_MX_FiscalEntityType__c, LAT_Account__r.LAT_MX_FiscalRate__r.CodDefUsuario__c, ' +
					'LAT_Account__r.LAT_MX_Group__r.CodDefUsuario__c, LAT_Account__r.LAT_MX_Language__c, LAT_Account__r.LAT_MX_Market__c, ' +
					'LAT_Account__r.LAT_MX_Neighbourhood__c, LAT_Account__r.LAT_MX_PostalCode__r.Name, LAT_Account__r.LAT_MX_RelatedAddressAN8__c, ' +
					'LAT_Account__r.LAT_MX_RouteCode__r.CodDefUsuario__c, LAT_Account__r.LAT_MX_State__c, LAT_Account__r.LAT_MX_ZoneNumber__r.CodDefUsuario__c, ' +
					'LAT_Account__r.Owner.Email, LAT_Account__r.Owner.Name,LAT_Account__r.Return_JDE_Integration__c, LAT_Account__r.Segmentation_Type_on_trade__c, ' +
					'LAT_Account__r.LAT_Account__r.LAT_JDEZone__c, LAT_Account__c '+
					'FROM LAT_MasiveOwnerLine__c WHERE LAT_Header__c = \'' + headerId + '\'';
		

		//query = 'SELECT Id, LAT_Account__r.Id, OwnerId, LAT_Account__r.OwnerId, LAT_AccountAN8__c, LAT_NewValue__c, LAT_Executed__c FROM LAT_MasiveOwnerLine__c WHERE LAT_Header__c = \'' + headerId + '\'';
	}
	
	global Database.QueryLocator start(Database.BatchableContext BC) {return Database.getQueryLocator(query);
		
	}

   	global void execute(Database.BatchableContext BC, List<sObject> scope) {
		List <LAT_MasiveOwnerLine__c> lines = (List<LAT_MasiveOwnerLine__c>)scope;
		
		for (LAT_MasiveOwnerLine__c line : lines) {
			Boolean useBridge = false;
			LAT_Account__c latAcc = [SELECT ID FROM LAT_Account__c WHERE Id = :line.LAT_Account__r.LAT_Account__c];
			if (line.LAT_AccountAN8__c == 'Not exists') {
				line.LAT_Account__r.OwnerId = line.LAT_NewValue__c;				
			} else {
				//Fix to run especific flow for Brasil
				if (line.LAT_Account__r.Client_country_AN8__c.startsWith('1-')) {
					line.LAT_Account__r.OwnerId = line.LAT_NewValue__c;
					line.LAT_Account__r.owner = line.LAT_NewValue__r;
					line.LAT_Account__r.Is_interface_Process_AR__c = true;
					//line.LAT_Account__r.Status__c = 'Aprovado - Aguardando retorno do JDE';
					if(!Test.isRunningTest()){
						//LAT_WS_CustomerHandlerInterface.CustomerInterfaceJDESync(line.LAT_Account__r);
						accountsIds.add(line.LAT_Account__c);
					}
					
				} else {
					line.LAT_Account__r.OwnerId = line.LAT_NewValue__c;
					line.LAT_Account__r.owner = line.LAT_NewValue__r;
					line.LAT_Account__r.Is_interface_Process_AR__c = true;
					//line.LAT_Account__r.Status__c = 'Customer Sent to JDE - Please Wait';
					if(!Test.isRunningTest()){
						//LAT_WS_CustomerHandlerInterface.CustomerInterfaceJDESync(line.LAT_Account__r);
						if(line.LAT_Account__r.Client_country_AN8__c.startsWith('12-') && LAT_GeneralConfig__c.getInstance('MX_USE_BRIDGE_IN_CUSTOMERHANDLER') != null){
							if(LAT_GeneralConfig__c.getInstance('MX_USE_BRIDGE_IN_CUSTOMERHANDLER').LAT_Value__c == 'true'){
                                useBridge = true;
                                if( LAT_GeneralConfig__c.getInstance('MX_USE_BRIDGE_IN_CUSTOMER_ACTIVE').LAT_Value__c == 'true') {
                                    LAT_BridgeGS1_Customer.execute(line.LAT_Account__c, null);
                                } 
								//LAT_BridgeGS1_Customer.execute(line.LAT_Account__c, null);
							}
							
						}
						if(!useBridge){
							accountsIds.add(line.LAT_Account__c);
						}
						
					}	
				}
								
			}
			line.LAT_Executed__c = true;
			toUpdate.add(line);
			update line.LAT_Account__r;
			update latAcc;
			
		}

		
	}
	
	global void finish(Database.BatchableContext BC) {
		if (header != null) {

			try{

				for(Account acc : getAccounts(accountsIds)){
					System.debug('%%%%% Entramos a mandar a integrar');
                    CustomerInterfaceJDESync(acc);
				}

				header.LAT_Status__c = 'Completed';
				update header;
				update toUpdate;
				User submitter = [SELECT Id, Email, Name FROM User WHERE id = :header.CreatedById];
				List <Account> accs = [SELECT Id, Name, Status__c, OwnerId, Owner.Name FROM Account WHERE Id IN :accountsIds];
				String[] emailAddresses = LAT_GeneralConfigDao.getValueAsStringArray('MASIVE_OWNER_EMAIL_TARGET_ADDRESSES', ',');
				emailAddresses.add(submitter.Email);
				String emailBody	= '<html><body><b>' + Label.LAT_UpdateAccountOwner_Mail01 + '</b> <br> <br><table width="75%" align="center" cellpadding="10"><tr><td><b>' + Label.LAT_UpdateAccountOwner_Mail02 + '<b/></td><td><b>' + Label.LAT_UpdateAccountOwner_Mail03 + '<b/></td><td><b>Status<b/></td></tr> ';
				for (Account acc : accs) {
					emailBody += '<tr><td>' + acc.Name + '</td><td>' + acc.Owner.Name + '</td><td>' + acc.Status__c + '</td></tr>';
				}
				emailBody += '</table></body></html>';
				Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
				mail.setToAddresses(emailAddresses);
	     		mail.setHtmlBody(emailBody);
		   		mail.setSenderDisplayName('noreply@pernod-ricard.com');
		   		mail.setSubject(Label.LAT_UpdateAccountOwner_Mail05);
		   		List<Messaging.SingleEmailMessage> list_emailsToSent = new List<Messaging.SingleEmailMessage>();
		   		list_emailsToSent.add(mail);	
		   		Messaging.sendEmail(list_emailsToSent);

				}catch (Exception e){

					system.debug('Error al enviar clientes:' + e.getMessage());
				}
			
		}
	}
	
  	public static void CustomerInterfaceJDESync (Account customer) {
	    system.debug('sentcust+++ : ' + customer);
	    
	    // do not continue if no id was received
	    if (customer == null) {
	      system.debug('entrocustomernull');
	      return;
	    }
		
		
		 
	    final String country = LAT_WS_CustomerHandlerInterface.getCountryInfo(customer.RecordTypeId);
		system.debug('ObtainedCountry+++ : ' + country);
		
		LAT_WS_CustomerHandlerTypes.CustomerHandlerArgumentsType customerArguments = LAT_WS_CustomerHandlerInterface.getCustomerArguments(customer, country);
		LAT_WS_CustomerHandler.port request = new LAT_WS_CustomerHandler.port(); // Timeout and auth handled directly on LAT_WS_CustomerHandler
		LAT_WS_CustomerHandlerTypes.ClientInfoType clientInfo = LAT_WS_CustomerHandlerInterface.getConnectionParameter(country);
		final String reqEndpoint = LAT_WS_Utils.getWSEndpoint(clientInfo.country);
		System.debug('%%%%% reqEndpoint:'+reqEndpoint);
		// Make request
		if(!Test.isRunningTest()){
			LAT_WS_CustomerHandlerRequestResponseTyp.AsyncIntegrationResponseType response = request.operation(clientInfo, customerArguments, reqEndpoint, true, customer.Id);
			system.debug('Parameterssss : ' + customerArguments);
			// Parse Response
			customer = LAT_WS_CustomerHandlerInterface.parseResponse(response, customer);
		} 
		
	     
	    
  	}


  	public static List<Account> getAccounts(Set<Id> accountsIds) {
  		return  [SELECT   Accept_applications_Incompleted__c, Accept_Backorder__c, Accept_line_incompleted__c, Affiliate__c, Agency__c, 
                   	Bank__r.Name, Bank_number__c, Barcode_EDI__c, Billing_Address_Code__c, Billing_Priority__c, Business_Unit__r.CodDefUsuario__c, 
                   	Carriers_Numbers__c, 
                  	Channel__c, 
                  	Checking_account__c, 
                  	Client_code_AN8__c, 
                  	CNPJ__c, 
                  	Corporate_Name__c,
                  	Credit_line__c, 
                  	Current_account__c, 
                  	Customer_Flag__r.CodDefUsuario__c, 
                  	Customer_Geographic_Region__r.CodDefUsuario__c, 
                  	Customer_GL__r.CodDefUsuario__c, 
                  	Customer_Organization__r.CodDefUsuario__c, 
                  	Discount_Group__c, 
                  	Email_NFE__c, 
                  	Fax, 
                  	Freight_Type__c, 
                  	LAT_BR_BusinessSize__c,
         	 		LAT_BR_FiscalBenefit__c,
                  	LAT_BR_PriorityLevel__c, 
                  	Municipal_Registration__c, 
                  	Nielsen_Area__r.CodDefUsuario__c, 
                  	OwnerId, 
                  	ParentId,
                  	Parent.Client_code_AN8__c, 
                  	Payment_Condition__r.CodDefUsuario__c, 
                  	Payment_instrument__r.CodDefUsuario__c,
                  	Phone, 
                  	Rating_segmentation_targert_market__c, 
                  	Rating, 
                  	Receiving_Freight__c, 
                  	RecordTypeId, 
                  	Regional__r.CodDefUsuario__c, 
                  	Revenue_Address__c, 
                  	Revenue_City__r.Name,
                  	Revenue_City_Code__c, 
                  	Revenue_Complement__c, 
                  	Revenue_Country__c, 
                  	Revenue_Neighbourhood__c, 
                  	Revenue_Number__c, 
                  	Revenue_Postal_Code__c,  
                  	Revenue_UF__c,
                  	Shipping_Address_Code__c, 
                  	State_registration__c,     
                  	Sub_Channel_Rating__r.CodDefUsuario__c, 
                  	Type,
                  	WebSite,
                  	Yes_No__c,                                  
                  	CurrencyISOCode,
                  	Owner.C_digo_JDE__c,
                	// AR and UY Fields
                  	AddressLine1_AR__c, 
                  	CatCode02_AR__r.CodDefUsuario__c, 
                  	CollectionAgent_AR__r.CodDefUsuario__c,
                  	CustomerPriceGroup_AR__r.CodDefUsuario__c,
                  	CustomerPoRequired_AR__c,
                  	Id,
                  	Name,
                  	Regional_AR__r.CodDefUsuario__c,
                  	Status__c,
                  	LAT_Account__r.LAT_JDEZone__c,
                	// MX Fields
                  	AccountNumber,
                  	Business_Unit_AR__r.CodDefUsuario__c,
                  	Client_country_AN8__c, 
                  	Is_interface_Process_AR__c,
                  	LAT_MX_ABCCode__r.CodDefUsuario__c,
                  	LAT_MX_AmountReceiptCopies__c, 
                  	LAT_MX_BatchProcess__r.CodDefUsuario__c,
                  	LAT_MX_BreakDownIEPS__c, 
                  	LAT_MX_CableCodeS__c, 
                  	LAT_MX_Chain__r.CodDefUsuario__c, 
                  	LAT_MX_City__c, 
                  	LAT_MX_County__c, 
                  	LAT_MX_CreditVersionLevel__c, 
                  	LAT_MX_CRMClientCode__c, 
                  	LAT_MX_FiscalEntityType__c, 
                  	LAT_MX_FiscalRate__r.CodDefUsuario__c, 
                  	LAT_MX_Group__r.CodDefUsuario__c, 
                  	LAT_MX_Language__c, 
                  	LAT_MX_Market__c, 
                  	LAT_MX_Neighbourhood__c, 
                  	LAT_MX_PostalCode__r.Name, 
                  	LAT_MX_RelatedAddressAN8__c, 
                  	LAT_MX_RouteCode__r.CodDefUsuario__c, 
                  	LAT_MX_State__c, 
                  	LAT_MX_ZoneNumber__r.CodDefUsuario__c, 
                  	Owner.Email, 
                  	Owner.Name,
                  	Return_JDE_Integration__c, 
                  	Segmentation_Type_on_trade__c,
                  	LAT_BR_RegionalClientOnPremise__c,
                  	(Select Id,
                            Name,
                            Obtained_Beneficio_Fiscal_Udc__r.CodDefUsuario__c,
                            Obtained_Segment_Udc__r.CodDefUsuario__c,
                            Obtained_Perfil_Udc__r.CodDefUsuario__c,
                            Obtained_Client_type_Udc__r.CodDefUsuario__c,
                            Obtained_Estrategia_comercial_Udc__r.CodDefUsuario__c,
                            Obtained_Channel_Udc__r.CodDefUsuario__c,
                            Obtained_SubChannel_Udc__r.CodDefUsuario__c,
                            Obtained_PRIOR_DE_INVESTIMENTO_Udc__r.CodDefUsuario__c,
                            Obtained_Formato_Udc__r.CodDefUsuario__c,
                            Obtained_POLiTICA_DE_PRECO_Udc__r.CodDefUsuario__c
                            FROM Segmentation_Results__r WHERE Client_Segmentation_2__r.Status__c ='Active')
	              	FROM Account
              		WHERE Id =: accountsIds];
}
}
*/