@isTest
public class LAT_VFC07_MasivePaymentDeadlineTest {
	
    
	@isTest static void testConstructor() {

		LAT_VFC07_MasivePaymentDeadlineUpdate mpdu = new LAT_VFC07_MasivePaymentDeadlineUpdate();
		String validationCountry = mpdu.countryCodes.get(UserInfo.getDefaultCurrency());

		system.assertEquals(mpdu.country, validationCountry);

	}

	@isTest static void testUpload() {

		LAT_GeneralConfig__c cfg = new LAT_GeneralConfig__c(
              Name = 'ACCOUNT_PD_UPDATE',
              LAT_Value__c = 'AR:' + UserInfo.getUserId() + ';BR:' + UserInfo.getUserId() + 
              				';UY:' + UserInfo.getUserId() + ';MX:' + UserInfo.getUserId()
        );
        insert cfg;

		UDC__c pd = new UDC__c(
			CodDefUsuario__c = 'D02',
			CodProd__c = 'CRM',
			CodUs__c = 'PT',
			Internal_Id__c = '12-D02-CRM-PT',
			RecordTypeId = RecordTypeForTest.getRecType('UDC__c', 'LAT_MX_UDC_Standard')
		);
      	insert pd;

      	Account acc = CreateMXOfftradeAccount();
		String csv = 'AN8,PaymentCondition\n12706,D02\n' + acc.id + ',' + pd.id;
		
		LAT_VFC07_MasivePaymentDeadlineUpdate mpdu = new LAT_VFC07_MasivePaymentDeadlineUpdate();
		mpdu.toParse = Blob.valueOf(csv);
		mpdu.country = '12';
		mpdu.upload();
	}

	// Create MX Account
	public static Account CreateMXOfftradeAccount() {
		String rtOffMX = Global_RecordTypeCache.getRtId('Account' + 'LAT_MX_ACC_OffTrade');
        Id usuarioId = UserInfo.getUserId();
        
        String rtUDC = Global_RecordTypeCache.getRtId('UDC__c' + 'LAT_MX_UDC_Standard');
        
        List<UDC__c> listUdc = new List<UDC__c>();
        
        UDC__c udcCustomerPriceGroup = new UDC__c(Name = 'testCustomerPriceGroup', Internal_Id__c = '2', CodProd__c = '40', CodUs__c = 'PC', RecordTypeId = rtUDC);      
        listUDC.add(udcCustomerPriceGroup);
        UDC__c udcCustomerGeographicRegion = new UDC__c(Name = 'testCustomerGeographicRegion', Internal_Id__c = '3', CodProd__c = '01', CodUs__c = '11', RecordTypeId = rtUDC);      
        listUDC.add(udcCustomerGeographicRegion);
        UDC__c udcPaymentCondition = new UDC__c(Name = 'testPaymentCondition', Internal_Id__c = '4', CodProd__c = 'CRM', CodUs__c = 'PT', RecordTypeId = rtUDC);      
        listUDC.add(udcPaymentCondition);
        UDC__c udcPaymentInstrument = new UDC__c(Name = 'testPaymentInstrument', Internal_Id__c = '5', CodProd__c = '00', CodUs__c = 'PY', RecordTypeId = rtUDC);      
        listUDC.add(udcPaymentInstrument);
        UDC__c udcCustomerGL = new UDC__c(Name = 'testCustomerGL', Internal_Id__c = '6', CodProd__c = '55', CodUs__c = 'GL', RecordTypeId = rtUDC);      
        listUDC.add(udcCustomerGL);
        UDC__c udcABCCode = new UDC__c(Name = 'testABCCode', Internal_Id__c = '7', CodProd__c = 'H01', CodUs__c = 'A2', RecordTypeId = rtUDC);      
        listUDC.add(udcABCCode);
        UDC__c udcRouteCode = new UDC__c(Name = 'testRouteCode', Internal_Id__c = '8', CodProd__c = '42', CodUs__c = 'RT', RecordTypeId = rtUDC);      
        listUDC.add(udcRouteCode);
        UDC__c udcBatchProcess = new UDC__c(Name = 'testBatchProcess', Internal_Id__c = '9', CodProd__c = '01', CodUs__c = '30', RecordTypeId = rtUDC);      
        listUDC.add(udcBatchProcess);
        UDC__c udcZoneNumber = new UDC__c(Name = 'testZoneNumber', Internal_Id__c = '10', CodProd__c = '40', CodUs__c = 'ZN', RecordTypeId = rtUDC);      
        listUDC.add(udcZoneNumber);
        UDC__c udcChain = new UDC__c(Name = 'testChain', Internal_Id__c = '11', CodProd__c = '01', CodUs__c = '10', RecordTypeId = rtUDC);      
        listUDC.add(udcChain);
        UDC__c udcFiscalRate = new UDC__c(Name = 'testFiscalRate', Internal_Id__c = '12', CodProd__c = 'CRM', CodUs__c = 'TX', RecordTypeId = rtUDC);      
        listUDC.add(udcFiscalRate);
        UDC__c udcGroup = new UDC__c(Name = 'testGroup', Internal_Id__c = '13', CodProd__c = '01', CodUs__c = '09', RecordTypeId = rtUDC);      
        listUDC.add(udcGroup);
        
        insert listUDC;
        
        Account acc = new Account(
            OwnerId = usuarioId,
            Name = 'Test',
            Customer_Geographic_Region__c = udcCustomerGeographicRegion.Id,
            Payment_Condition__c = udcPaymentCondition.Id,
            Payment_instrument__c = udcPaymentInstrument.Id,
            Customer_GL__c = udcCustomerGL.Id,
            LAT_MX_ABCCode__c = udcABCCode.Id,
            LAT_MX_RouteCode__c = udcRouteCode.Id,
            LAT_MX_BatchProcess__c = udcBatchProcess.Id,
            LAT_MX_ZoneNumber__c = udcZoneNumber.Id,
            LAT_MX_Chain__c = udcChain.Id,
            LAT_MX_FiscalRate__c = udcFiscalRate.Id,
            LAT_MX_Group__c = udcGroup.Id,
            CNPJ__c = 'ETE9510126P1',
            AccountNumber = '1000',
            Status__c = 'Cliente cadastrado no JDE', 
            Type = 'Payer',
            Phone = '1-11-1111-1111',
            Fax = '11-1111-1111',
            LAT_MX_FiscalEntityType__c = 'Company',
            RecordTypeId = rtOffMX,
            Corporate_Name__c = 'TEST',
            Channel__c = 'WS',
            Segmentation_Type_on_trade__c = 'MOP',
            CurrencyISOCode = 'MXN',
            Client_country_AN8__c = '12-12706',
      		Client_code_AN8__c = '12706'
        );
        insert acc;

        return acc;
	}
	
}