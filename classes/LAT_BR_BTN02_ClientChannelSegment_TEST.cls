/********************************************************************************
*  Company:Valuenet         Developer:Denis Aranda       Date:30/05/2013        *
********************************************************************************/
/********************************************************************************
* 
* MIGRACION LICENCIAS 
* AUTHOR: ZIMMIC                     DATE: 05/12/2016
*
********************************************************************************/

@isTest
public with sharing class LAT_BR_BTN02_ClientChannelSegment_TEST {
	
	static testMethod void UnitTest(){
		

		User u = new User();
    u = LAT_TestUserAdmin.userWithAdminPorf ('Nome2','Sobrenome2','NSobre2','nome2@sobrenome.com','PriceCalculationInterface@mail.com','123jjjuuu2','ISO-8859-1','GMT','en_Us','en_Us','234','BR'); 
    insert u;  
		
		System.runAs(u){
			
			List<LAT_BR_ClientSegmentationParameters__c> listPar = new List<LAT_BR_ClientSegmentationParameters__c>();
			
			Account acc = new Account(
				RecordTypeId = Global_RecordTypeCache.getRtId('Account' + 'On_Trade'), 
				CNPJ__c = '54651716001150',
				Name = 'testAccount',
				Type = 'Prospect_ARG',
				Corporate_Name__c = 'test',
				Channel_Type__c = 'Direto',
				Sub_Channel__c = 'Delicatessen',
				AddressLine1_AR__c= 'test',
				Shipping_Neighbourhood__c = 'test',
				Revenue_Neighbourhood__c = 'test',
				Billing_Neighbourhood__c ='test',
				Shipping_Country__c ='test',
				Revenue_Country__c ='test',
				Client_code_AN8__c = '123697',
				Billing_Country__c ='test'
			);
			insert acc;
			
			CS002_FIeldsIds__c cs002 = new CS002_FIeldsIds__c(
				FieldApiName__c='LAT_BR_Client__c',
				Name = 'name',
				FieldId__c= '12345678',
				ObjectApiName__c='LAT_BR_ClientChannelSegmentation__c'
			);
			insert cs002;
			
			LAT_BR_BTN02_ClientChannelSegment.validationOfNewSeg(acc.Id);
			
			LAT_BR_ClientChannelSegmentation__c seg = new LAT_BR_ClientChannelSegmentation__c(
				LAT_BR_Client__c = acc.id,
				LAT_BR_ApprovalStatus__c = 'Draft',
				LAT_BR_IconicHouse__c = 'Yes',
				LAT_BR_PubPhysicalSpace__c = 'Tables and most people seated',
				
				LAT_BR_Music__c = 'Mild or none',
				LAT_BR_ConsumerProfile__c = 'A',
				LAT_BR_MainDrinks__c = 'High quality cocktails',
				LAT_BR_AverageMainMealPrice__c = 'Between 76 and 125',
				LAT_BR_AdultEntertainmentHouse__c = 'Yes',
				LAT_BR_MainBillFocus__c = 'Drinks with meals and snacks to complement',
				LAT_BR_MainConsumptionOccasion__c = 'Lunch/dinner',
				LAT_BR_ActivitiesStartTime__c = 'For lunches/dinners',
				LAT_BR_MainBrandsSold__c = 'Standard',
				LAT_BR_Brigade__c = 'Excellent',
				LAT_BR_AverageSodaCansPrice__c = 'Above 4',
				LAT_BR_PeopleCapacity__c = 'Above 1000',
				LAT_BR_ONSegment__c = 'Bar',
				RecordTypeId = Global_RecordTypeCache.getRtId('LAT_BR_ClientChannelSegmentation__c' + 'LAT_BR_CCS_OnTrade')
			);
			
			UDC__c tab = new UDC__c(
				RecordTypeId = Global_RecordTypeCache.getRtId('UDC__c' + 'BRA_Standard'),
				Internal_Id__c = '1-10-01-19',
				CodDefUsuario__c = '10',
				CodProd__c = '01',
				Name = 'PEQUENO',
				CodUs__c = '19'
			); 
			insert tab;
			
			UDC__c tab2 = new UDC__c(
				RecordTypeId = Global_RecordTypeCache.getRtId('UDC__c' + 'BRA_Standard'),
				Internal_Id__c = '1-3-01-18',
				CodDefUsuario__c = '3',
				CodProd__c = '01',
				Name = 'PREMIUM',
				CodUs__c = '18'
			); 
			insert tab2;
			
			UDC__c tab3 = new UDC__c(
				RecordTypeId = Global_RecordTypeCache.getRtId('UDC__c' + 'BRA_Standard'),
				Internal_Id__c = '1-10-01-18',
				CodDefUsuario__c = '10',
				CodProd__c = '01',
				Name = 'ICONIC',
				CodUs__c = '18'
			); 
			insert tab3;
			
			system.Test.startTest();
			
			LAT_BR_ClientSegmentationParameters__c par = new LAT_BR_ClientSegmentationParameters__c(
				LAT_BR_Answer__c = 'Drinks with meals and snacks to complement',
				LAT_BR_AnswerCode__c = 'A0',
				LAT_BR_DataType__c = 'Sub_Channel Code Answer',
				LAT_BR_Question__c = 'LAT_BR_MainBillFocus__c'
			);
			
			LAT_BR_ClientSegmentationParameters__c par1 = new LAT_BR_ClientSegmentationParameters__c(
				LAT_BR_Answer__c = 'Lunch/dinner',
				LAT_BR_AnswerCode__c = 'B2',
				LAT_BR_DataType__c = 'Sub_Channel Code Answer',
				LAT_BR_Question__c = 'LAT_BR_MainConsumptionOccasion__c'
			);
			
			LAT_BR_ClientSegmentationParameters__c par2 = new LAT_BR_ClientSegmentationParameters__c(
				LAT_BR_Answer__c = 'Tables and most people seated',
				LAT_BR_AnswerCode__c = 'C0',
				LAT_BR_DataType__c = 'Sub_Channel Code Answer',
				LAT_BR_Question__c = 'LAT_BR_PubPhysicalSpace__c'
			);
			
			LAT_BR_ClientSegmentationParameters__c par3 = new LAT_BR_ClientSegmentationParameters__c(
				LAT_BR_Answer__c = 'For lunches/dinners',
				LAT_BR_AnswerCode__c = 'D1',
				LAT_BR_DataType__c = 'Sub_Channel Code Answer',
				LAT_BR_Question__c = 'LAT_BR_ActivitiesStartTime__c'
			);
				
			LAT_BR_ClientSegmentationParameters__c par4 = new LAT_BR_ClientSegmentationParameters__c(
				LAT_BR_Answer__c = 'Mild or none',
				LAT_BR_AnswerCode__c = 'E0',
				LAT_BR_DataType__c = 'Sub_Channel Code Answer',
				LAT_BR_Question__c = 'LAT_BR_Music__c'
			);
			
			LAT_BR_ClientSegmentationParameters__c par5 = new LAT_BR_ClientSegmentationParameters__c(
				LAT_BR_DataType__c = 'Sub_Channel Key',
				LAT_BR_Key__c = 'A0B2C0D1E0',
				LAT_BR_SubChannel__c = 'Bar'
			);
			
			
			LAT_BR_ClientSegmentationParameters__c par6 = new LAT_BR_ClientSegmentationParameters__c(
				LAT_BR_Answer__c = '-',
				LAT_BR_AnswerCode__c = '0',
				LAT_BR_DataType__c = 'Profile Weight',
				LAT_BR_Question__c = 'LAT_BR_MainBrandsSold__c'
			);
			
			LAT_BR_ClientSegmentationParameters__c par7 = new LAT_BR_ClientSegmentationParameters__c(
				LAT_BR_Answer__c = '-',
				LAT_BR_AnswerCode__c = '3',
				LAT_BR_DataType__c = 'Profile Weight',
				LAT_BR_Question__c = 'LAT_BR_MainDrinks__c'
			);
			
			LAT_BR_ClientSegmentationParameters__c par8 = new LAT_BR_ClientSegmentationParameters__c(
				LAT_BR_Answer__c = 'Excellent',
				LAT_BR_AnswerCode__c = '3',
				LAT_BR_DataType__c = 'Profile Weight',
				LAT_BR_Question__c = 'LAT_BR_Brigade__c'
			);
			
			LAT_BR_ClientSegmentationParameters__c par9 = new LAT_BR_ClientSegmentationParameters__c(
				LAT_BR_Answer__c = 'A',
				LAT_BR_AnswerCode__c = '3',
				LAT_BR_DataType__c = 'Profile Weight',
				LAT_BR_Question__c = 'LAT_BR_ConsumerProfile__c'
			);
			
			LAT_BR_ClientSegmentationParameters__c par10 = new LAT_BR_ClientSegmentationParameters__c(
				LAT_BR_Answer__c = 'Above 4',
				LAT_BR_AnswerCode__c = '2',
				LAT_BR_DataType__c = 'Profile Weight',
				LAT_BR_Question__c = 'LAT_BR_AverageSodaCansPrice__c'
			);
			
			LAT_BR_ClientSegmentationParameters__c par11 = new LAT_BR_ClientSegmentationParameters__c(
				LAT_BR_Answer__c = '-',
				LAT_BR_AnswerCode__c = '3',
				LAT_BR_DataType__c = 'Profile Weight',
				LAT_BR_Question__c = 'LAT_BR_AverageMainMealPrice__c'
			);
			
			LAT_BR_ClientSegmentationParameters__c par12 = new LAT_BR_ClientSegmentationParameters__c(
				LAT_BR_Answer__c = '-',
				LAT_BR_AnswerCode__c = '0',
				LAT_BR_DataType__c = 'Sub_Channel Weight',
				LAT_BR_Question__c = 'LAT_BR_MainBrandsSold__c'
			);
			
			LAT_BR_ClientSegmentationParameters__c par13 = new LAT_BR_ClientSegmentationParameters__c(
				LAT_BR_Answer__c = 'Bar',
				LAT_BR_AnswerCode__c = '0.25',
				LAT_BR_DataType__c = 'Sub_Channel Weight',
				LAT_BR_Question__c = 'LAT_BR_MainDrinks__c'
			);
			
			LAT_BR_ClientSegmentationParameters__c par14 = new LAT_BR_ClientSegmentationParameters__c(
				LAT_BR_Answer__c = 'Bar',
				LAT_BR_AnswerCode__c = '0.1',
				LAT_BR_DataType__c = 'Sub_Channel Weight',
				LAT_BR_Question__c = 'LAT_BR_Brigade__c'
			);
			
			LAT_BR_ClientSegmentationParameters__c par15 = new LAT_BR_ClientSegmentationParameters__c(
				LAT_BR_Answer__c = 'Bar',
				LAT_BR_AnswerCode__c = '0.25',
				LAT_BR_DataType__c = 'Sub_Channel Weight',
				LAT_BR_Question__c = 'LAT_BR_ConsumerProfile__c'
			);
			
			LAT_BR_ClientSegmentationParameters__c par16 = new LAT_BR_ClientSegmentationParameters__c(
				LAT_BR_Answer__c = 'Bar',
				LAT_BR_AnswerCode__c = '0.15',
				LAT_BR_DataType__c = 'Sub_Channel Weight',
				LAT_BR_Question__c = 'LAT_BR_AverageSodaCansPrice__c'
			);
			
			LAT_BR_ClientSegmentationParameters__c par17 = new LAT_BR_ClientSegmentationParameters__c(
				LAT_BR_Answer__c = 'Bar',
				LAT_BR_AnswerCode__c = '0',
				LAT_BR_DataType__c = 'Sub_Channel Weight',
				LAT_BR_Question__c = 'LAT_BR_AverageMainMealPrice__c'
			);
			
			LAT_BR_ClientSegmentationParameters__c par18 = new LAT_BR_ClientSegmentationParameters__c(
				LAT_BR_Answer__c = 'Bar',
				LAT_BR_AnswerCode__c = '1.4',
				LAT_BR_DataType__c = 'Profile Answer',
				LAT_BR_Profile__c = tab2.id
			);
			
			LAT_BR_ClientSegmentationParameters__c par19 = new LAT_BR_ClientSegmentationParameters__c(
				LAT_BR_Answer__c = 'Above 1000',
				LAT_BR_DataType__c = 'Business Size',
				LAT_BR_BusinessSize__c = tab.Id,
				LAT_BR_Question__c = 'LAT_BR_PeopleCapacity__c'
			);
			
			LAT_BR_ClientSegmentationParameters__c par20 = new LAT_BR_ClientSegmentationParameters__c(
				LAT_BR_Answer__c = 'Yes',
				LAT_BR_DataType__c = 'Profile Exception',
				LAT_BR_Profile__c = tab3.Id,
				LAT_BR_Question__c = 'LAT_BR_IconicHouse__c'
			);
			
			LAT_BR_ClientSegmentationParameters__c par21 = new LAT_BR_ClientSegmentationParameters__c(
				LAT_BR_Answer__c = 'Yes',
				LAT_BR_DataType__c = 'Sub_Channel Exception',
				LAT_BR_SubChannel__c = 'Table Dance',
				LAT_BR_Question__c = 'LAT_BR_AdultEntertainmentHouse__c'
			);
			
			LAT_BR_ClientSegmentationParameters__c par22 = new LAT_BR_ClientSegmentationParameters__c(
				LAT_BR_Answer__c = 'Bar',
				LAT_BR_AnswerCode__c = '0.25',
				LAT_BR_DataType__c = 'Sub_Channel Weight',
				LAT_BR_Question__c = 'LAT_BR_MainBrandsSold__c'
			);
			
			listPar.add(par);
			listPar.add(par1);
			listPar.add(par2);
			listPar.add(par3);
			listPar.add(par4);
			listPar.add(par5);
			listPar.add(par6);
			listPar.add(par7);
			listPar.add(par8);
			listPar.add(par9);
			listPar.add(par10);
			listPar.add(par11);
			listPar.add(par12);
			listPar.add(par13);
			listPar.add(par14);
			listPar.add(par15);
			listPar.add(par16);
			listPar.add(par17);
			listPar.add(par18);
			listPar.add(par19);
			listPar.add(par20);
			listPar.add(par21);
			listPar.add(par22);
			
			insert listPar;
		  insert seg;
			
			LAT_BR_BTN02_ClientChannelSegment.validationOfNewSeg(acc.Id);

		}	
	}	

	static testMethod void UnitTest2(){
		Test.startTest();	
			User vendas = [SELECT Id FROM user WHERE Profile.Name = 'LAT_BR2_Vendas' AND isActive = true limit 1];         
	    system.runas(vendas){  

	    	
				LAT_BR_ClientChannelSegmentation__c seg = LAT_BR_BTN02_ClientChannelSegment_TEST.clientChannelSegTestFactory();

				String result = LAT_BR_BTN02_ClientChannelSegment.validationOfSegBeforeAproval(seg.id);
				//System.assertEquals('', result);

				result = LAT_BR_BTN02_ClientChannelSegment.validationOfSegBeforeAproval(seg.id);
				//System.assertEquals(Label.LAT_BR_VFC15_SegChannelApprovalMessage2, result);	

			}
		Test.stopTest();	
	}

	static testMethod void UnitTest2B(){
		Test.startTest();	
			User vendas = [SELECT Id FROM user WHERE Profile.Name = 'LAT_BR2_Vendas' AND isActive = true limit 1];         
	    system.runas(vendas){  

	    	
				LAT_BR_ClientChannelSegmentation__c seg = LAT_BR_BTN02_ClientChannelSegment_TEST.clientChannelSegTestFactory();

				String result = LAT_BR_BTN02_ClientChannelSegment.validationOfSegBeforeAproval(seg.id);
				//System.assertEquals('', result);

				result = LAT_BR_BTN02_ClientChannelSegment.validationOfSegBeforeAproval(seg.id);
				//System.assertEquals(Label.LAT_BR_VFC15_SegChannelApprovalMessage2, result);	

			}
		Test.stopTest();	
	}

	static testMethod void UnitTest3(){
		Test.startTest();	
			    	
			LAT_BR_ClientChannelSegmentation__c seg = LAT_BR_BTN02_ClientChannelSegment_TEST.clientChannelSegTestFactory();

			String result = LAT_BR_BTN02_ClientChannelSegment.validationOfSegBeforeAproval(seg.id);
			//System.assertEquals(Label.LAT_BR_VFC15_ApprobalEntryCriteriaErrorMsg, result);	

			
		Test.stopTest();	
	}

	static testMethod void UnitTest4(){
		Test.startTest();	
			User vendas = [SELECT Id FROM user WHERE Profile.Name = 'LAT_BR2_Vendas' AND isActive = true limit 1];         
	    system.runas(vendas){  

	    	
				LAT_BR_ClientChannelSegmentation__c seg = LAT_BR_BTN02_ClientChannelSegment_TEST.clientChannelSegTestFactory();
				seg.LAT_BR_ONSegment__c = '';
				update seg;
				String result = LAT_BR_BTN02_ClientChannelSegment.validationOfSegBeforeAproval(seg.id);
				//System.assertEquals(Label.LAT_BR_VFC15_ApprobalEntryCriteriaErrorMsg, result);	

			}
		Test.stopTest();	
	}

	static testMethod void UnitTest4B(){
		Test.startTest();	
			User vendas = [SELECT Id FROM user WHERE Profile.Name = 'LAT_BR2_Vendas' AND isActive = true limit 1];         
	    system.runas(vendas){  

	    	
				LAT_BR_ClientChannelSegmentation__c seg = LAT_BR_BTN02_ClientChannelSegment_TEST.clientChannelSegTestFactory();
				seg.LAT_BR_ONSegment__c = '';
				update seg;
				String result = LAT_BR_BTN02_ClientChannelSegment.validationOfSegBeforeAproval(seg.id);
				//System.assertEquals(Label.LAT_BR_VFC15_ApprobalEntryCriteriaErrorMsg, result);	

			}
		Test.stopTest();	
	}
	public static LAT_BR_ClientChannelSegmentation__c clientChannelSegTestFactory() {

		Account acc =  LAT_Account_TestFactory.getBRAAccountBase('Off_Trade');
		acc.Client_code_AN8__c = '122222';
		insert acc;

		LAT_BR_ClientChannelSegmentation__c seg = new LAT_BR_ClientChannelSegmentation__c(
		LAT_BR_Client__c = acc.id,
		LAT_BR_ApprovalStatus__c = 'Draft',
		LAT_BR_IconicHouse__c = 'Yes',
		LAT_BR_PubPhysicalSpace__c = 'Tables and most people seated',
		LAT_BR_Justificativa__c = 'Test Seg justificativa',
		LAT_BR_Music__c = 'Mild or none',
		LAT_BR_ConsumerProfile__c = 'A',
		LAT_BR_MainDrinks__c = 'High quality cocktails',
		LAT_BR_AverageMainMealPrice__c = 'Between 76 and 125',
		LAT_BR_AdultEntertainmentHouse__c = 'Yes',
		LAT_BR_MainBillFocus__c = 'Drinks with meals and snacks to complement',
		LAT_BR_MainConsumptionOccasion__c = 'Lunch/dinner',
		LAT_BR_ActivitiesStartTime__c = 'For lunches/dinners',
		LAT_BR_MainBrandsSold__c = 'Standard',
		LAT_BR_Brigade__c = 'Excellent',
		LAT_BR_AverageSodaCansPrice__c = 'Above 4',
		LAT_BR_PeopleCapacity__c = 'Above 1000',
		LAT_BR_ONSegment__c = 'Bar',
		RecordTypeId = Global_RecordTypeCache.getRtId('LAT_BR_ClientChannelSegmentation__c' + 'LAT_BR_CCS_OnTrade')
		);

				UDC__c tab = new UDC__c(
			RecordTypeId = Global_RecordTypeCache.getRtId('UDC__c' + 'BRA_Standard'),
			Internal_Id__c = '1-10-01-19',
			CodDefUsuario__c = '10',
			CodProd__c = '01',
			Name = 'PEQUENO',
			CodUs__c = '19'
		); 
		insert tab;
		
		UDC__c tab2 = new UDC__c(
			RecordTypeId = Global_RecordTypeCache.getRtId('UDC__c' + 'BRA_Standard'),
			Internal_Id__c = '1-3-01-18',
			CodDefUsuario__c = '3',
			CodProd__c = '01',
			Name = 'PREMIUM',
			CodUs__c = '18'
		); 
		insert tab2;
		
		UDC__c tab3 = new UDC__c(
			RecordTypeId = Global_RecordTypeCache.getRtId('UDC__c' + 'BRA_Standard'),
			Internal_Id__c = '1-10-01-18',
			CodDefUsuario__c = '10',
			CodProd__c = '01',
			Name = 'ICONIC',
			CodUs__c = '18'
		); 
		insert tab3;			

		List<LAT_BR_ClientSegmentationParameters__c> listPar = new List<LAT_BR_ClientSegmentationParameters__c>();		
		LAT_BR_ClientSegmentationParameters__c par = new LAT_BR_ClientSegmentationParameters__c(
			LAT_BR_Answer__c = 'Drinks with meals and snacks to complement',
			LAT_BR_AnswerCode__c = 'A0',
			LAT_BR_DataType__c = 'Sub_Channel Code Answer',
			LAT_BR_Question__c = 'LAT_BR_MainBillFocus__c'
		);
		
		LAT_BR_ClientSegmentationParameters__c par1 = new LAT_BR_ClientSegmentationParameters__c(
			LAT_BR_Answer__c = 'Lunch/dinner',
			LAT_BR_AnswerCode__c = 'B2',
			LAT_BR_DataType__c = 'Sub_Channel Code Answer',
			LAT_BR_Question__c = 'LAT_BR_MainConsumptionOccasion__c'
		);
		
		LAT_BR_ClientSegmentationParameters__c par2 = new LAT_BR_ClientSegmentationParameters__c(
			LAT_BR_Answer__c = 'Tables and most people seated',
			LAT_BR_AnswerCode__c = 'C0',
			LAT_BR_DataType__c = 'Sub_Channel Code Answer',
			LAT_BR_Question__c = 'LAT_BR_PubPhysicalSpace__c'
		);
		
		LAT_BR_ClientSegmentationParameters__c par3 = new LAT_BR_ClientSegmentationParameters__c(
			LAT_BR_Answer__c = 'For lunches/dinners',
			LAT_BR_AnswerCode__c = 'D1',
			LAT_BR_DataType__c = 'Sub_Channel Code Answer',
			LAT_BR_Question__c = 'LAT_BR_ActivitiesStartTime__c'
		);
			
		LAT_BR_ClientSegmentationParameters__c par4 = new LAT_BR_ClientSegmentationParameters__c(
			LAT_BR_Answer__c = 'Mild or none',
			LAT_BR_AnswerCode__c = 'E0',
			LAT_BR_DataType__c = 'Sub_Channel Code Answer',
			LAT_BR_Question__c = 'LAT_BR_Music__c'
		);
		
		LAT_BR_ClientSegmentationParameters__c par5 = new LAT_BR_ClientSegmentationParameters__c(
			LAT_BR_DataType__c = 'Sub_Channel Key',
			LAT_BR_Key__c = 'A0B2C0D1E0',
			LAT_BR_SubChannel__c = 'Bar'
		);
		
		
		LAT_BR_ClientSegmentationParameters__c par6 = new LAT_BR_ClientSegmentationParameters__c(
			LAT_BR_Answer__c = '-',
			LAT_BR_AnswerCode__c = '0',
			LAT_BR_DataType__c = 'Profile Weight',
			LAT_BR_Question__c = 'LAT_BR_MainBrandsSold__c'
		);
		
		LAT_BR_ClientSegmentationParameters__c par7 = new LAT_BR_ClientSegmentationParameters__c(
			LAT_BR_Answer__c = '-',
			LAT_BR_AnswerCode__c = '3',
			LAT_BR_DataType__c = 'Profile Weight',
			LAT_BR_Question__c = 'LAT_BR_MainDrinks__c'
		);
		
		LAT_BR_ClientSegmentationParameters__c par8 = new LAT_BR_ClientSegmentationParameters__c(
			LAT_BR_Answer__c = 'Excellent',
			LAT_BR_AnswerCode__c = '3',
			LAT_BR_DataType__c = 'Profile Weight',
			LAT_BR_Question__c = 'LAT_BR_Brigade__c'
		);
		
		LAT_BR_ClientSegmentationParameters__c par9 = new LAT_BR_ClientSegmentationParameters__c(
			LAT_BR_Answer__c = 'A',
			LAT_BR_AnswerCode__c = '3',
			LAT_BR_DataType__c = 'Profile Weight',
			LAT_BR_Question__c = 'LAT_BR_ConsumerProfile__c'
		);
		
		LAT_BR_ClientSegmentationParameters__c par10 = new LAT_BR_ClientSegmentationParameters__c(
			LAT_BR_Answer__c = 'Above 4',
			LAT_BR_AnswerCode__c = '2',
			LAT_BR_DataType__c = 'Profile Weight',
			LAT_BR_Question__c = 'LAT_BR_AverageSodaCansPrice__c'
		);
		
		LAT_BR_ClientSegmentationParameters__c par11 = new LAT_BR_ClientSegmentationParameters__c(
			LAT_BR_Answer__c = '-',
			LAT_BR_AnswerCode__c = '3',
			LAT_BR_DataType__c = 'Profile Weight',
			LAT_BR_Question__c = 'LAT_BR_AverageMainMealPrice__c'
		);
		
		LAT_BR_ClientSegmentationParameters__c par12 = new LAT_BR_ClientSegmentationParameters__c(
			LAT_BR_Answer__c = '-',
			LAT_BR_AnswerCode__c = '0',
			LAT_BR_DataType__c = 'Sub_Channel Weight',
			LAT_BR_Question__c = 'LAT_BR_MainBrandsSold__c'
		);
		
		LAT_BR_ClientSegmentationParameters__c par13 = new LAT_BR_ClientSegmentationParameters__c(
			LAT_BR_Answer__c = 'Bar',
			LAT_BR_AnswerCode__c = '0.25',
			LAT_BR_DataType__c = 'Sub_Channel Weight',
			LAT_BR_Question__c = 'LAT_BR_MainDrinks__c'
		);
		
		LAT_BR_ClientSegmentationParameters__c par14 = new LAT_BR_ClientSegmentationParameters__c(
			LAT_BR_Answer__c = 'Bar',
			LAT_BR_AnswerCode__c = '0.1',
			LAT_BR_DataType__c = 'Sub_Channel Weight',
			LAT_BR_Question__c = 'LAT_BR_Brigade__c'
		);
		
		LAT_BR_ClientSegmentationParameters__c par15 = new LAT_BR_ClientSegmentationParameters__c(
			LAT_BR_Answer__c = 'Bar',
			LAT_BR_AnswerCode__c = '0.25',
			LAT_BR_DataType__c = 'Sub_Channel Weight',
			LAT_BR_Question__c = 'LAT_BR_ConsumerProfile__c'
		);
		
		LAT_BR_ClientSegmentationParameters__c par16 = new LAT_BR_ClientSegmentationParameters__c(
			LAT_BR_Answer__c = 'Bar',
			LAT_BR_AnswerCode__c = '0.15',
			LAT_BR_DataType__c = 'Sub_Channel Weight',
			LAT_BR_Question__c = 'LAT_BR_AverageSodaCansPrice__c'
		);
		
		LAT_BR_ClientSegmentationParameters__c par17 = new LAT_BR_ClientSegmentationParameters__c(
			LAT_BR_Answer__c = 'Bar',
			LAT_BR_AnswerCode__c = '0',
			LAT_BR_DataType__c = 'Sub_Channel Weight',
			LAT_BR_Question__c = 'LAT_BR_AverageMainMealPrice__c'
		);
		
		LAT_BR_ClientSegmentationParameters__c par18 = new LAT_BR_ClientSegmentationParameters__c(
			LAT_BR_Answer__c = 'Bar',
			LAT_BR_AnswerCode__c = '1.4',
			LAT_BR_DataType__c = 'Profile Answer',
			LAT_BR_Profile__c = tab2.id
		);
		
		LAT_BR_ClientSegmentationParameters__c par19 = new LAT_BR_ClientSegmentationParameters__c(
			LAT_BR_Answer__c = 'Above 1000',
			LAT_BR_DataType__c = 'Business Size',
			LAT_BR_BusinessSize__c = tab.Id,
			LAT_BR_Question__c = 'LAT_BR_PeopleCapacity__c'
		);
		
		LAT_BR_ClientSegmentationParameters__c par20 = new LAT_BR_ClientSegmentationParameters__c(
			LAT_BR_Answer__c = 'Yes',
			LAT_BR_DataType__c = 'Profile Exception',
			LAT_BR_Profile__c = tab3.Id,
			LAT_BR_Question__c = 'LAT_BR_IconicHouse__c'
		);
		
		LAT_BR_ClientSegmentationParameters__c par21 = new LAT_BR_ClientSegmentationParameters__c(
			LAT_BR_Answer__c = 'Yes',
			LAT_BR_DataType__c = 'Sub_Channel Exception',
			LAT_BR_SubChannel__c = 'Table Dance',
			LAT_BR_Question__c = 'LAT_BR_AdultEntertainmentHouse__c'
		);
		
		LAT_BR_ClientSegmentationParameters__c par22 = new LAT_BR_ClientSegmentationParameters__c(
			LAT_BR_Answer__c = 'Bar',
			LAT_BR_AnswerCode__c = '0.25',
			LAT_BR_DataType__c = 'Sub_Channel Weight',
			LAT_BR_Question__c = 'LAT_BR_MainBrandsSold__c'
		);
		
		listPar.add(par);
		listPar.add(par1);
		listPar.add(par2);
		listPar.add(par3);
		listPar.add(par4);
		listPar.add(par5);
		listPar.add(par6);
		listPar.add(par7);
		listPar.add(par8);
		listPar.add(par9);
		listPar.add(par10);
		listPar.add(par11);
		listPar.add(par12);
		listPar.add(par13);
		listPar.add(par14);
		listPar.add(par15);
		listPar.add(par16);
		listPar.add(par17);
		listPar.add(par18);
		listPar.add(par19);
		listPar.add(par20);
		listPar.add(par21);
		listPar.add(par22);
		
		insert listPar;
		insert seg;	

		seg.LAT_BR_ONSegment__c = 'Bar';
		update seg;

		return seg;
	}
}