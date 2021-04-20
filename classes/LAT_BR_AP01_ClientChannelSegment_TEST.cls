/********************************************************************************
*  Company:Valuenet         Developer:Denis Aranda       Date:30/05/2013        *
********************************************************************************/
@isTest
public with sharing class LAT_BR_AP01_ClientChannelSegment_TEST {
    
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
            
            LAT_BR_ClientChannelSegmentation__c seg = new LAT_BR_ClientChannelSegmentation__c(
                LAT_BR_Client__c = acc.id,
                RecordTypeId = Global_RecordTypeCache.getRtId('LAT_BR_ClientChannelSegmentation__c' + 'LAT_BR_CCS_OnTrade'),
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
                LAT_BR_Justificativa__c = 'Justificativa'
            );
            try{insert seg;}catch(Exception e){}
            
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
                RecordTypeId = Global_RecordTypeCache.getRtId('LAT_BR_ClientSegmentationParameters__c' + 'LAT_BR_CSP_OnTrade'),
                LAT_BR_Answer__c = 'Drinks with meals and snacks to complement',
                LAT_BR_AnswerCode__c = 'A0',
                LAT_BR_DataType__c = 'Sub_Channel Code Answer',
                LAT_BR_Question__c = 'LAT_BR_MainBillFocus__c'
            );
            
            LAT_BR_ClientSegmentationParameters__c par1 = new LAT_BR_ClientSegmentationParameters__c(
                RecordTypeId = Global_RecordTypeCache.getRtId('LAT_BR_ClientSegmentationParameters__c' + 'LAT_BR_CSP_OnTrade'),
                LAT_BR_Answer__c = 'Lunch/dinner',
                LAT_BR_AnswerCode__c = 'B2',
                LAT_BR_DataType__c = 'Sub_Channel Code Answer',
                LAT_BR_Question__c = 'LAT_BR_MainConsumptionOccasion__c'
            );
            
            LAT_BR_ClientSegmentationParameters__c par2 = new LAT_BR_ClientSegmentationParameters__c(
                RecordTypeId = Global_RecordTypeCache.getRtId('LAT_BR_ClientSegmentationParameters__c' + 'LAT_BR_CSP_OnTrade'),
                LAT_BR_Answer__c = 'Tables and most people seated',
                LAT_BR_AnswerCode__c = 'C0',
                LAT_BR_DataType__c = 'Sub_Channel Code Answer',
                LAT_BR_Question__c = 'LAT_BR_PubPhysicalSpace__c'
            );
            
            LAT_BR_ClientSegmentationParameters__c par3 = new LAT_BR_ClientSegmentationParameters__c(
                RecordTypeId = Global_RecordTypeCache.getRtId('LAT_BR_ClientSegmentationParameters__c' + 'LAT_BR_CSP_OnTrade'),
                LAT_BR_Answer__c = 'For lunches/dinners',
                LAT_BR_AnswerCode__c = 'D1',
                LAT_BR_DataType__c = 'Sub_Channel Code Answer',
                LAT_BR_Question__c = 'LAT_BR_ActivitiesStartTime__c'
            );
                
            LAT_BR_ClientSegmentationParameters__c par4 = new LAT_BR_ClientSegmentationParameters__c(
                RecordTypeId = Global_RecordTypeCache.getRtId('LAT_BR_ClientSegmentationParameters__c' + 'LAT_BR_CSP_OnTrade'),
                LAT_BR_Answer__c = 'Mild or none',
                LAT_BR_AnswerCode__c = 'E0',
                LAT_BR_DataType__c = 'Sub_Channel Code Answer',
                LAT_BR_Question__c = 'LAT_BR_Music__c'
            );
            
            LAT_BR_ClientSegmentationParameters__c par5 = new LAT_BR_ClientSegmentationParameters__c(
                RecordTypeId = Global_RecordTypeCache.getRtId('LAT_BR_ClientSegmentationParameters__c' + 'LAT_BR_CSP_OnTrade'),
                LAT_BR_DataType__c = 'Sub_Channel Key',
                LAT_BR_Key__c = 'A0B2C0D1E0',
                LAT_BR_SubChannel__c = 'Bar'
            );
            
            LAT_BR_ClientSegmentationParameters__c par6 = new LAT_BR_ClientSegmentationParameters__c(
                RecordTypeId = Global_RecordTypeCache.getRtId('LAT_BR_ClientSegmentationParameters__c' + 'LAT_BR_CSP_OnTrade'),
                LAT_BR_Answer__c = '-',
                LAT_BR_AnswerCode__c = '0',
                LAT_BR_DataType__c = 'Profile Weight',
                LAT_BR_Question__c = 'LAT_BR_MainBrandsSold__c'
            );
            
            LAT_BR_ClientSegmentationParameters__c par7 = new LAT_BR_ClientSegmentationParameters__c(
                RecordTypeId = Global_RecordTypeCache.getRtId('LAT_BR_ClientSegmentationParameters__c' + 'LAT_BR_CSP_OnTrade'),
                LAT_BR_Answer__c = '-',
                LAT_BR_AnswerCode__c = '3',
                LAT_BR_DataType__c = 'Profile Weight',
                LAT_BR_Question__c = 'LAT_BR_MainDrinks__c'
            );
            
            LAT_BR_ClientSegmentationParameters__c par8 = new LAT_BR_ClientSegmentationParameters__c(
                RecordTypeId = Global_RecordTypeCache.getRtId('LAT_BR_ClientSegmentationParameters__c' + 'LAT_BR_CSP_OnTrade'),
                LAT_BR_Answer__c = 'Excellent',
                LAT_BR_AnswerCode__c = '3',
                LAT_BR_DataType__c = 'Profile Weight',
                LAT_BR_Question__c = 'LAT_BR_Brigade__c'
            );
            
            LAT_BR_ClientSegmentationParameters__c par9 = new LAT_BR_ClientSegmentationParameters__c(
                RecordTypeId = Global_RecordTypeCache.getRtId('LAT_BR_ClientSegmentationParameters__c' + 'LAT_BR_CSP_OnTrade'),
                LAT_BR_Answer__c = 'A',
                LAT_BR_AnswerCode__c = '3',
                LAT_BR_DataType__c = 'Profile Weight',
                LAT_BR_Question__c = 'LAT_BR_ConsumerProfile__c'
            );
            
            LAT_BR_ClientSegmentationParameters__c par10 = new LAT_BR_ClientSegmentationParameters__c(
                RecordTypeId = Global_RecordTypeCache.getRtId('LAT_BR_ClientSegmentationParameters__c' + 'LAT_BR_CSP_OnTrade'),
                LAT_BR_Answer__c = 'Above 4',
                LAT_BR_AnswerCode__c = '2',
                LAT_BR_DataType__c = 'Profile Weight',
                LAT_BR_Question__c = 'LAT_BR_AverageSodaCansPrice__c'
            );
            
            LAT_BR_ClientSegmentationParameters__c par11 = new LAT_BR_ClientSegmentationParameters__c(
                RecordTypeId = Global_RecordTypeCache.getRtId('LAT_BR_ClientSegmentationParameters__c' + 'LAT_BR_CSP_OnTrade'),
                LAT_BR_Answer__c = '-',
                LAT_BR_AnswerCode__c = '3',
                LAT_BR_DataType__c = 'Profile Weight',
                LAT_BR_Question__c = 'LAT_BR_AverageMainMealPrice__c'
            );
            
            LAT_BR_ClientSegmentationParameters__c par12 = new LAT_BR_ClientSegmentationParameters__c(
                RecordTypeId = Global_RecordTypeCache.getRtId('LAT_BR_ClientSegmentationParameters__c' + 'LAT_BR_CSP_OnTrade'),
                LAT_BR_Answer__c = '-',
                LAT_BR_AnswerCode__c = '0',
                LAT_BR_DataType__c = 'Sub_Channel Weight',
                LAT_BR_Question__c = 'LAT_BR_MainBrandsSold__c'
            );
            
            LAT_BR_ClientSegmentationParameters__c par13 = new LAT_BR_ClientSegmentationParameters__c(
                RecordTypeId = Global_RecordTypeCache.getRtId('LAT_BR_ClientSegmentationParameters__c' + 'LAT_BR_CSP_OnTrade'),
                LAT_BR_Answer__c = 'Bar',
                LAT_BR_AnswerCode__c = '0.25',
                LAT_BR_DataType__c = 'Sub_Channel Weight',
                LAT_BR_Question__c = 'LAT_BR_MainDrinks__c'
            );
            
            LAT_BR_ClientSegmentationParameters__c par14 = new LAT_BR_ClientSegmentationParameters__c(
                RecordTypeId = Global_RecordTypeCache.getRtId('LAT_BR_ClientSegmentationParameters__c' + 'LAT_BR_CSP_OnTrade'),
                LAT_BR_Answer__c = 'Bar',
                LAT_BR_AnswerCode__c = '0.1',
                LAT_BR_DataType__c = 'Sub_Channel Weight',
                LAT_BR_Question__c = 'LAT_BR_Brigade__c'
            );
            
            LAT_BR_ClientSegmentationParameters__c par15 = new LAT_BR_ClientSegmentationParameters__c(
                RecordTypeId = Global_RecordTypeCache.getRtId('LAT_BR_ClientSegmentationParameters__c' + 'LAT_BR_CSP_OnTrade'),
                LAT_BR_Answer__c = 'Bar',
                LAT_BR_AnswerCode__c = '0.25',
                LAT_BR_DataType__c = 'Sub_Channel Weight',
                LAT_BR_Question__c = 'LAT_BR_ConsumerProfile__c'
            );
            
            LAT_BR_ClientSegmentationParameters__c par16 = new LAT_BR_ClientSegmentationParameters__c(
                RecordTypeId = Global_RecordTypeCache.getRtId('LAT_BR_ClientSegmentationParameters__c' + 'LAT_BR_CSP_OnTrade'),
                LAT_BR_Answer__c = 'Bar',
                LAT_BR_AnswerCode__c = '0.15',
                LAT_BR_DataType__c = 'Sub_Channel Weight',
                LAT_BR_Question__c = 'LAT_BR_AverageSodaCansPrice__c'
            );
            
            LAT_BR_ClientSegmentationParameters__c par17 = new LAT_BR_ClientSegmentationParameters__c(  
                RecordTypeId = Global_RecordTypeCache.getRtId('LAT_BR_ClientSegmentationParameters__c' + 'LAT_BR_CSP_OnTrade'),
                LAT_BR_Answer__c = 'Bar',
                LAT_BR_AnswerCode__c = '0',
                LAT_BR_DataType__c = 'Sub_Channel Weight',
                LAT_BR_Question__c = 'LAT_BR_AverageMainMealPrice__c'
            );
            
            LAT_BR_ClientSegmentationParameters__c par18 = new LAT_BR_ClientSegmentationParameters__c(
                RecordTypeId = Global_RecordTypeCache.getRtId('LAT_BR_ClientSegmentationParameters__c' + 'LAT_BR_CSP_OnTrade'),
                LAT_BR_Answer__c = 'Bar',
                LAT_BR_AnswerCode__c = '1.4',
                LAT_BR_DataType__c = 'Profile Answer',
                LAT_BR_Profile__c = tab2.Id
            );
            
            LAT_BR_ClientSegmentationParameters__c par19 = new LAT_BR_ClientSegmentationParameters__c(
                RecordTypeId = Global_RecordTypeCache.getRtId('LAT_BR_ClientSegmentationParameters__c' + 'LAT_BR_CSP_OnTrade'),
                LAT_BR_Answer__c = 'Above 1000',
                LAT_BR_DataType__c = 'Business Size',
                LAT_BR_BusinessSize__c = tab.Id,
                LAT_BR_Question__c = 'LAT_BR_PeopleCapacity__c'
            );
            
            LAT_BR_ClientSegmentationParameters__c par20 = new LAT_BR_ClientSegmentationParameters__c(
                RecordTypeId = Global_RecordTypeCache.getRtId('LAT_BR_ClientSegmentationParameters__c' + 'LAT_BR_CSP_OnTrade'),
                LAT_BR_Answer__c = 'Yes',
                LAT_BR_DataType__c = 'Profile Exception',
                LAT_BR_Profile__c = tab3.Id,
                LAT_BR_Question__c = 'LAT_BR_IconicHouse__c'
            );
            
            LAT_BR_ClientSegmentationParameters__c par21 = new LAT_BR_ClientSegmentationParameters__c(
                RecordTypeId = Global_RecordTypeCache.getRtId('LAT_BR_ClientSegmentationParameters__c' + 'LAT_BR_CSP_OnTrade'),
                LAT_BR_Answer__c = 'Yes',
                LAT_BR_DataType__c = 'Sub_Channel Exception',
                LAT_BR_SubChannel__c = 'Table Dance',
                LAT_BR_Question__c = 'LAT_BR_AdultEntertainmentHouse__c'
            );
            
            LAT_BR_ClientSegmentationParameters__c par22 = new LAT_BR_ClientSegmentationParameters__c(
                RecordTypeId = Global_RecordTypeCache.getRtId('LAT_BR_ClientSegmentationParameters__c' + 'LAT_BR_CSP_OnTrade'),
                LAT_BR_Answer__c = 'Bar',
                LAT_BR_AnswerCode__c = '0.25',
                LAT_BR_DataType__c = 'Sub_Channel Weight',
                LAT_BR_Question__c = 'LAT_BR_MainBrandsSold__c'
            );
            
            LAT_BR_ClientSegmentationParameters__c par23 = new LAT_BR_ClientSegmentationParameters__c(
                RecordTypeId = Global_RecordTypeCache.getRtId('LAT_BR_ClientSegmentationParameters__c' + 'LAT_BR_CSP_OnTrade'),
                LAT_BR_DataType__c = 'Sub_Channel Key',
                LAT_BR_Key__c = 'A0',
                LAT_BR_SubChannel__c = 'Bar'
            );
            
            LAT_BR_ClientSegmentationParameters__c par24 = new LAT_BR_ClientSegmentationParameters__c(
                RecordTypeId = Global_RecordTypeCache.getRtId('LAT_BR_ClientSegmentationParameters__c' + 'LAT_BR_CSP_OnTrade'),
                LAT_BR_DataType__c = 'Sub_Channel Key',
                LAT_BR_Key__c = 'A0B2',
                LAT_BR_SubChannel__c = 'Bar'
            );
            
            LAT_BR_ClientSegmentationParameters__c par25 = new LAT_BR_ClientSegmentationParameters__c(
                RecordTypeId = Global_RecordTypeCache.getRtId('LAT_BR_ClientSegmentationParameters__c' + 'LAT_BR_CSP_OnTrade'),
                LAT_BR_DataType__c = 'Sub_Channel Key',
                LAT_BR_Key__c = 'A0B2C0',
                LAT_BR_SubChannel__c = 'Bar'
            );
            
            LAT_BR_ClientSegmentationParameters__c par26 = new LAT_BR_ClientSegmentationParameters__c(
                RecordTypeId = Global_RecordTypeCache.getRtId('LAT_BR_ClientSegmentationParameters__c' + 'LAT_BR_CSP_OnTrade'),
                LAT_BR_DataType__c = 'Sub_Channel Key',
                LAT_BR_Key__c = 'A0B2C0D1',
                LAT_BR_SubChannel__c = 'Bar'
            );
            
            listPar.add(par);
            listPar.add(par1);
            listPar.add(par2);
            listPar.add(par3);
            listPar.add(par4);
            listPar.add(par5);
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
            listPar.add(par23);
            listPar.add(par24);
            listPar.add(par25);
            listPar.add(par26);
            
            insert listPar;         
            try{insert seg;}catch(Exception e){}
            
            insert par6;
            try{insert seg;}catch(Exception e){}
            
            insert par7;
            try{insert seg;}catch(Exception e){}
            
            insert par8;
            try{insert seg;}catch(Exception e){}
            
            insert par9;
            try{insert seg;}catch(Exception e){}
            
            insert par10;
            try{insert seg;}catch(Exception e){}
            
            insert par11;
            try{insert seg;}catch(Exception e){}
            //Think
            seg.LAT_BR_IconicHouse__c = 'No';
            seg.LAT_BR_AdultEntertainmentHouse__c = 'No';
            update seg;
            
            seg.LAT_BR_ApprovalStatus__c = 'Active';
            update seg;
            
            try{delete seg;}catch(Exception e){}
            
            system.test.stopTest();
        }
    }
    
    static testMethod void UnitTest2(){
        
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
            
            LAT_BR_ClientChannelSegmentation__c seg = new LAT_BR_ClientChannelSegmentation__c(
                LAT_BR_Client__c = acc.id,
                RecordTypeId = Global_RecordTypeCache.getRtId('LAT_BR_ClientChannelSegmentation__c' + 'LAT_BR_CCS_OnTrade'),
                LAT_BR_ApprovalStatus__c = 'Draft',
                LAT_BR_IconicHouse__c = 'No',
                LAT_BR_PubPhysicalSpace__c = 'Tables and most people seated',
                LAT_BR_Music__c = 'Mild or none',
                LAT_BR_AverageMainMealPrice__c = 'Between 76 and 125',
                LAT_BR_AdultEntertainmentHouse__c = 'No',
                LAT_BR_MainBillFocus__c = 'Drinks with meals and snacks to complement',
                LAT_BR_MainConsumptionOccasion__c = 'Lunch/dinner',
                LAT_BR_ActivitiesStartTime__c = 'For lunches/dinners',
                LAT_BR_PeopleCapacity__c = 'Above 1000'
            );
            try{insert seg;}catch(Exception e){}
            
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
                RecordTypeId = Global_RecordTypeCache.getRtId('LAT_BR_ClientSegmentationParameters__c' + 'LAT_BR_CSP_OnTrade'),
                LAT_BR_Answer__c = 'Drinks with meals and snacks to complement',
                LAT_BR_AnswerCode__c = 'A0',
                LAT_BR_DataType__c = 'Sub_Channel Code Answer',
                LAT_BR_Question__c = 'LAT_BR_MainBillFocus__c'
            );
            
            LAT_BR_ClientSegmentationParameters__c par1 = new LAT_BR_ClientSegmentationParameters__c(
                RecordTypeId = Global_RecordTypeCache.getRtId('LAT_BR_ClientSegmentationParameters__c' + 'LAT_BR_CSP_OnTrade'),
                LAT_BR_Answer__c = 'Lunch/dinner',
                LAT_BR_AnswerCode__c = 'B2',
                LAT_BR_DataType__c = 'Sub_Channel Code Answer',
                LAT_BR_Question__c = 'LAT_BR_MainConsumptionOccasion__c'
            );
            
            LAT_BR_ClientSegmentationParameters__c par2 = new LAT_BR_ClientSegmentationParameters__c(
                RecordTypeId = Global_RecordTypeCache.getRtId('LAT_BR_ClientSegmentationParameters__c' + 'LAT_BR_CSP_OnTrade'),
                LAT_BR_Answer__c = 'Tables and most people seated',
                LAT_BR_AnswerCode__c = 'C0',
                LAT_BR_DataType__c = 'Sub_Channel Code Answer',
                LAT_BR_Question__c = 'LAT_BR_PubPhysicalSpace__c'
            );
            
            LAT_BR_ClientSegmentationParameters__c par3 = new LAT_BR_ClientSegmentationParameters__c(
                RecordTypeId = Global_RecordTypeCache.getRtId('LAT_BR_ClientSegmentationParameters__c' + 'LAT_BR_CSP_OnTrade'),
                LAT_BR_Answer__c = 'For lunches/dinners',
                LAT_BR_AnswerCode__c = 'D1',
                LAT_BR_DataType__c = 'Sub_Channel Code Answer',
                LAT_BR_Question__c = 'LAT_BR_ActivitiesStartTime__c'
            );
                
            LAT_BR_ClientSegmentationParameters__c par4 = new LAT_BR_ClientSegmentationParameters__c(
                RecordTypeId = Global_RecordTypeCache.getRtId('LAT_BR_ClientSegmentationParameters__c' + 'LAT_BR_CSP_OnTrade'),
                LAT_BR_Answer__c = 'Mild or none',
                LAT_BR_AnswerCode__c = 'E0',
                LAT_BR_DataType__c = 'Sub_Channel Code Answer',
                LAT_BR_Question__c = 'LAT_BR_Music__c'
            );
            
            LAT_BR_ClientSegmentationParameters__c par5 = new LAT_BR_ClientSegmentationParameters__c(
                RecordTypeId = Global_RecordTypeCache.getRtId('LAT_BR_ClientSegmentationParameters__c' + 'LAT_BR_CSP_OnTrade'),
                LAT_BR_DataType__c = 'Sub_Channel Key',
                LAT_BR_Key__c = 'A0B2C0D1E0',
                LAT_BR_SubChannel__c = 'Bar'
            );
            
            LAT_BR_ClientSegmentationParameters__c par6 = new LAT_BR_ClientSegmentationParameters__c(
                RecordTypeId = Global_RecordTypeCache.getRtId('LAT_BR_ClientSegmentationParameters__c' + 'LAT_BR_CSP_OnTrade'),
                LAT_BR_Answer__c = '-',
                LAT_BR_AnswerCode__c = '0',
                LAT_BR_DataType__c = 'Profile Weight',
                LAT_BR_Question__c = 'LAT_BR_MainBrandsSold__c'
            );
            
            LAT_BR_ClientSegmentationParameters__c par7 = new LAT_BR_ClientSegmentationParameters__c(
                RecordTypeId = Global_RecordTypeCache.getRtId('LAT_BR_ClientSegmentationParameters__c' + 'LAT_BR_CSP_OnTrade'),
                LAT_BR_Answer__c = '-',
                LAT_BR_AnswerCode__c = '3',
                LAT_BR_DataType__c = 'Profile Weight',
                LAT_BR_Question__c = 'LAT_BR_MainDrinks__c'
            );
            
            LAT_BR_ClientSegmentationParameters__c par8 = new LAT_BR_ClientSegmentationParameters__c(
                RecordTypeId = Global_RecordTypeCache.getRtId('LAT_BR_ClientSegmentationParameters__c' + 'LAT_BR_CSP_OnTrade'),
                LAT_BR_Answer__c = 'Excellent',
                LAT_BR_AnswerCode__c = '3',
                LAT_BR_DataType__c = 'Profile Weight',
                LAT_BR_Question__c = 'LAT_BR_Brigade__c'
            );
            
            LAT_BR_ClientSegmentationParameters__c par9 = new LAT_BR_ClientSegmentationParameters__c(
                RecordTypeId = Global_RecordTypeCache.getRtId('LAT_BR_ClientSegmentationParameters__c' + 'LAT_BR_CSP_OnTrade'),
                LAT_BR_Answer__c = 'A',
                LAT_BR_AnswerCode__c = '3',
                LAT_BR_DataType__c = 'Profile Weight',
                LAT_BR_Question__c = 'LAT_BR_ConsumerProfile__c'
            );
            
            LAT_BR_ClientSegmentationParameters__c par10 = new LAT_BR_ClientSegmentationParameters__c(
                RecordTypeId = Global_RecordTypeCache.getRtId('LAT_BR_ClientSegmentationParameters__c' + 'LAT_BR_CSP_OnTrade'),
                LAT_BR_Answer__c = 'Above 4',
                LAT_BR_AnswerCode__c = '2',
                LAT_BR_DataType__c = 'Profile Weight',
                LAT_BR_Question__c = 'LAT_BR_AverageSodaCansPrice__c'
            );
            
            LAT_BR_ClientSegmentationParameters__c par11 = new LAT_BR_ClientSegmentationParameters__c(
                RecordTypeId = Global_RecordTypeCache.getRtId('LAT_BR_ClientSegmentationParameters__c' + 'LAT_BR_CSP_OnTrade'),
                LAT_BR_Answer__c = '-',
                LAT_BR_AnswerCode__c = '3',
                LAT_BR_DataType__c = 'Profile Weight',
                LAT_BR_Question__c = 'LAT_BR_AverageMainMealPrice__c'
            );
            
            LAT_BR_ClientSegmentationParameters__c par12 = new LAT_BR_ClientSegmentationParameters__c(
                RecordTypeId = Global_RecordTypeCache.getRtId('LAT_BR_ClientSegmentationParameters__c' + 'LAT_BR_CSP_OnTrade'),
                LAT_BR_Answer__c = '-',
                LAT_BR_AnswerCode__c = '0',
                LAT_BR_DataType__c = 'Sub_Channel Weight',
                LAT_BR_Question__c = 'LAT_BR_MainBrandsSold__c'
            );
            
            LAT_BR_ClientSegmentationParameters__c par13 = new LAT_BR_ClientSegmentationParameters__c(
                RecordTypeId = Global_RecordTypeCache.getRtId('LAT_BR_ClientSegmentationParameters__c' + 'LAT_BR_CSP_OnTrade'),
                LAT_BR_Answer__c = 'Bar',
                LAT_BR_AnswerCode__c = '0.25',
                LAT_BR_DataType__c = 'Sub_Channel Weight',
                LAT_BR_Question__c = 'LAT_BR_MainDrinks__c'
            );
            
            LAT_BR_ClientSegmentationParameters__c par14 = new LAT_BR_ClientSegmentationParameters__c(
                RecordTypeId = Global_RecordTypeCache.getRtId('LAT_BR_ClientSegmentationParameters__c' + 'LAT_BR_CSP_OnTrade'),
                LAT_BR_Answer__c = 'Bar',
                LAT_BR_AnswerCode__c = '0.1',
                LAT_BR_DataType__c = 'Sub_Channel Weight',
                LAT_BR_Question__c = 'LAT_BR_Brigade__c'
            );
            
            LAT_BR_ClientSegmentationParameters__c par15 = new LAT_BR_ClientSegmentationParameters__c(
                RecordTypeId = Global_RecordTypeCache.getRtId('LAT_BR_ClientSegmentationParameters__c' + 'LAT_BR_CSP_OnTrade'),
                LAT_BR_Answer__c = 'Bar',
                LAT_BR_AnswerCode__c = '0.25',
                LAT_BR_DataType__c = 'Sub_Channel Weight',
                LAT_BR_Question__c = 'LAT_BR_ConsumerProfile__c'
            );
            
            LAT_BR_ClientSegmentationParameters__c par16 = new LAT_BR_ClientSegmentationParameters__c(
                RecordTypeId = Global_RecordTypeCache.getRtId('LAT_BR_ClientSegmentationParameters__c' + 'LAT_BR_CSP_OnTrade'),
                LAT_BR_Answer__c = 'Bar',
                LAT_BR_AnswerCode__c = '0.15',
                LAT_BR_DataType__c = 'Sub_Channel Weight',
                LAT_BR_Question__c = 'LAT_BR_AverageSodaCansPrice__c'
            );
            
            LAT_BR_ClientSegmentationParameters__c par17 = new LAT_BR_ClientSegmentationParameters__c(  
                RecordTypeId = Global_RecordTypeCache.getRtId('LAT_BR_ClientSegmentationParameters__c' + 'LAT_BR_CSP_OnTrade'),
                LAT_BR_Answer__c = 'Bar',
                LAT_BR_AnswerCode__c = '0',
                LAT_BR_DataType__c = 'Sub_Channel Weight',
                LAT_BR_Question__c = 'LAT_BR_AverageMainMealPrice__c'
            );
            
            LAT_BR_ClientSegmentationParameters__c par18 = new LAT_BR_ClientSegmentationParameters__c(
                RecordTypeId = Global_RecordTypeCache.getRtId('LAT_BR_ClientSegmentationParameters__c' + 'LAT_BR_CSP_OnTrade'),
                LAT_BR_Answer__c = 'Bar',
                LAT_BR_AnswerCode__c = '1.4',
                LAT_BR_DataType__c = 'Profile Answer',
                LAT_BR_Profile__c = tab2.Id
            );
            
            LAT_BR_ClientSegmentationParameters__c par19 = new LAT_BR_ClientSegmentationParameters__c(
                RecordTypeId = Global_RecordTypeCache.getRtId('LAT_BR_ClientSegmentationParameters__c' + 'LAT_BR_CSP_OnTrade'),
                LAT_BR_Answer__c = 'Above 1000',
                LAT_BR_DataType__c = 'Business Size',
                LAT_BR_BusinessSize__c = tab.Id,
                LAT_BR_Question__c = 'LAT_BR_PeopleCapacity__c'
            );
            
            LAT_BR_ClientSegmentationParameters__c par20 = new LAT_BR_ClientSegmentationParameters__c(
                RecordTypeId = Global_RecordTypeCache.getRtId('LAT_BR_ClientSegmentationParameters__c' + 'LAT_BR_CSP_OnTrade'),
                LAT_BR_Answer__c = 'Yes',
                LAT_BR_DataType__c = 'Profile Exception',
                LAT_BR_Profile__c = tab3.Id,
                LAT_BR_Question__c = 'LAT_BR_IconicHouse__c'
            );
            
            LAT_BR_ClientSegmentationParameters__c par21 = new LAT_BR_ClientSegmentationParameters__c(
                RecordTypeId = Global_RecordTypeCache.getRtId('LAT_BR_ClientSegmentationParameters__c' + 'LAT_BR_CSP_OnTrade'),
                LAT_BR_Answer__c = 'Yes',
                LAT_BR_DataType__c = 'Sub_Channel Exception',
                LAT_BR_SubChannel__c = 'Table Dance',
                LAT_BR_Question__c = 'LAT_BR_AdultEntertainmentHouse__c'
            );
            
            LAT_BR_ClientSegmentationParameters__c par22 = new LAT_BR_ClientSegmentationParameters__c(
                RecordTypeId = Global_RecordTypeCache.getRtId('LAT_BR_ClientSegmentationParameters__c' + 'LAT_BR_CSP_OnTrade'),
                LAT_BR_Answer__c = 'Bar',
                LAT_BR_AnswerCode__c = '0.25',
                LAT_BR_DataType__c = 'Sub_Channel Weight',
                LAT_BR_Question__c = 'LAT_BR_MainBrandsSold__c'
            );
            
            LAT_BR_ClientSegmentationParameters__c par23 = new LAT_BR_ClientSegmentationParameters__c(
                RecordTypeId = Global_RecordTypeCache.getRtId('LAT_BR_ClientSegmentationParameters__c' + 'LAT_BR_CSP_OnTrade'),
                LAT_BR_DataType__c = 'Sub_Channel Key',
                LAT_BR_Key__c = 'A0',
                LAT_BR_SubChannel__c = 'Bar'
            );
            
            LAT_BR_ClientSegmentationParameters__c par24 = new LAT_BR_ClientSegmentationParameters__c(
                RecordTypeId = Global_RecordTypeCache.getRtId('LAT_BR_ClientSegmentationParameters__c' + 'LAT_BR_CSP_OnTrade'),
                LAT_BR_DataType__c = 'Sub_Channel Key',
                LAT_BR_Key__c = 'A0B2',
                LAT_BR_SubChannel__c = 'Bar'
            );
            
            LAT_BR_ClientSegmentationParameters__c par25 = new LAT_BR_ClientSegmentationParameters__c(
                RecordTypeId = Global_RecordTypeCache.getRtId('LAT_BR_ClientSegmentationParameters__c' + 'LAT_BR_CSP_OnTrade'),
                LAT_BR_DataType__c = 'Sub_Channel Key',
                LAT_BR_Key__c = 'A0B2C0',
                LAT_BR_SubChannel__c = 'Bar'
            );
            
            LAT_BR_ClientSegmentationParameters__c par26 = new LAT_BR_ClientSegmentationParameters__c(
                RecordTypeId = Global_RecordTypeCache.getRtId('LAT_BR_ClientSegmentationParameters__c' + 'LAT_BR_CSP_OnTrade'),
                LAT_BR_DataType__c = 'Sub_Channel Key',
                LAT_BR_Key__c = 'A0B2C0D1',
                LAT_BR_SubChannel__c = 'Bar'
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
            listPar.add(par23);
            listPar.add(par24);
            listPar.add(par25);
            listPar.add(par26);
            
            insert listPar;
            
            try{insert seg;}catch(Exception e){}
            
            seg.LAT_BR_MainBrandsSold__c = 'Standard';
            
            try{insert seg;}catch(Exception e){}
            
            seg.LAT_BR_MainDrinks__c = 'High quality cocktails';
            
            try{insert seg;}catch(Exception e){}
            
            seg.LAT_BR_Brigade__c = 'Excellent';
            
            try{insert seg;}catch(Exception e){}
            
            seg.LAT_BR_ConsumerProfile__c = 'A';
            
            try{insert seg;}catch(Exception e){}
            
            seg.LAT_BR_AverageSodaCansPrice__c = 'Above 4';
            
            try{insert seg;}catch(Exception e){}
            
            seg.LAT_BR_AverageMainMealPrice__c = 'Between 76 and 125';
            
            try{insert seg;}catch(Exception e){}
            
            system.test.stopTest();
        }
    }
    
    static testMethod void UnitTest3(){
        
        User u = new User();
        u = LAT_TestUserAdmin.userWithAdminPorf ('Nome2','Sobrenome2','NSobre2','nome2@sobrenome.com','PriceCalculationInterface@mail.com','123jjjuuu2','ISO-8859-1','GMT','en_Us','en_Us','234','BR'); 
        insert u; 
        
        System.runAs(u){
            
            List<LAT_BR_ClientSegmentationParameters__c> listPar = new List<LAT_BR_ClientSegmentationParameters__c>();
            List<UDC__c> listUDC = new List<UDC__c>(); 
            
            Account acc = new Account(
                RecordTypeId = Global_RecordTypeCache.getRtId('Account' + 'Off_Trade'), 
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
            
            LAT_BR_ClientChannelSegmentation__c seg = new LAT_BR_ClientChannelSegmentation__c(
                LAT_BR_Client__c = acc.id,
                RecordTypeId = Global_RecordTypeCache.getRtId('LAT_BR_ClientChannelSegmentation__c' + 'LAT_BR_CCS_OffTrade'),
                LAT_BR_ApprovalStatus__c = 'Draft',
                LAT_BR_BusinessTargetAudience__c = 'Mostly Legal Entities',
                LAT_BR_PortfolioType__c = 'Standard Products',
                LAT_BR_MainAttentionChannel__c = 'Off Trade',
                LAT_BR_PerformingArea__c = 'Have sales team within 3 States without a defined territory',
                LAT_BR_SKUCategoriesAmount__c ='High categories number and more than 1000 SKUs', 
                LAT_BR_RelationshipLevel__c = 'Trading Brands',
                LAT_BR_FiscalBenefit__c = 'Yes'
            );
            try{insert seg;}catch(Exception e){}
            
            UDC__c tab = new UDC__c(
                RecordTypeId = Global_RecordTypeCache.getRtId('UDC__c' + 'BRA_Standard'),
                Internal_Id__c = '1-8-01-20',
                CodDefUsuario__c = '8',
                CodProd__c = '01',
                Name = 'TRADING BRANDS',
                CodUs__c = '20'
            ); 
            listUDC.add(tab);
            
            UDC__c tab1 = new UDC__c(
                RecordTypeId = Global_RecordTypeCache.getRtId('UDC__c' + 'BRA_Standard'),
                Internal_Id__c = '1-5-01-21',
                CodDefUsuario__c = '5',
                CodProd__c = '01',
                Name = 'SIM',
                CodUs__c = '21'
            ); 
            listUDC.add(tab1);
            
            UDC__c tab2 = new UDC__c(
                RecordTypeId = Global_RecordTypeCache.getRtId('UDC__c' + 'BRA_Standard'),
                Internal_Id__c = '1-601-01-03',
                CodDefUsuario__c = '601',
                CodProd__c = '01',
                Name = 'Sub Channel Rating',
                CodUs__c = '03'
            ); 
            listUDC.add(tab2);
            
            UDC__c tab3 = new UDC__c(
                RecordTypeId = Global_RecordTypeCache.getRtId('UDC__c' + 'BRA_Standard'),
                Internal_Id__c = '1-8-01-18',
                CodDefUsuario__c = '8',
                CodProd__c = '01',
                Name = 'MAINSTREAM',
                CodUs__c = '18'
            ); 
            listUDC.add(tab3);
            
            UDC__c tab4 = new UDC__c(
                RecordTypeId = Global_RecordTypeCache.getRtId('UDC__c' + 'BRA_Standard'),
                Internal_Id__c = '01-06',
                CodProd__c = '01',
                Name = 'Customer Flag',
                CodUs__c = '06'
            ); 
            listUDC.add(tab4);
            
            UDC__c tab5 = new UDC__c(
                RecordTypeId = Global_RecordTypeCache.getRtId('UDC__c' + 'BRA_Standard'),
                Internal_Id__c = '1-6-01-19',
                CodDefUsuario__c = '6',
                CodProd__c = '01',
                Name = 'SUPER',
                CodUs__c = '19'
            ); 
            listUDC.add(tab5);
            
            system.test.startTest();
            LAT_BR_ClientSegmentationParameters__c par1 = new LAT_BR_ClientSegmentationParameters__c(
                RecordTypeId = Global_RecordTypeCache.getRtId('LAT_BR_ClientSegmentationParameters__c' + 'LAT_BR_CSP_OffTrade'),
                LAT_BR_DataType__c = 'Code Answer',
                LAT_BR_Question__c = 'LAT_BR_BusinessTargetAudience__c',
                LAT_BR_Answer__c = 'Mostly Legal Entities',
                LAT_BR_AnswerCode__c = 'A2'
            );
            
            LAT_BR_ClientSegmentationParameters__c par2 = new LAT_BR_ClientSegmentationParameters__c(
                RecordTypeId = Global_RecordTypeCache.getRtId('LAT_BR_ClientSegmentationParameters__c' + 'LAT_BR_CSP_OffTrade'),
                LAT_BR_DataType__c = 'Code Answer',
                LAT_BR_Question__c = 'LAT_BR_MainAttentionChannel__c',
                LAT_BR_Answer__c = 'Off Trade',
                LAT_BR_AnswerCode__c = 'B3'
            );
            
            LAT_BR_ClientSegmentationParameters__c par3 = new LAT_BR_ClientSegmentationParameters__c(
                RecordTypeId = Global_RecordTypeCache.getRtId('LAT_BR_ClientSegmentationParameters__c' + 'LAT_BR_CSP_OffTrade'),
                LAT_BR_DataType__c = 'Code Answer',
                LAT_BR_Question__c = 'LAT_BR_PerformingArea__c',
                LAT_BR_Answer__c = 'Have sales team within 3 States without a defined territory',
                LAT_BR_AnswerCode__c = 'C3'
            );
            
            LAT_BR_ClientSegmentationParameters__c par4 = new LAT_BR_ClientSegmentationParameters__c(
                RecordTypeId = Global_RecordTypeCache.getRtId('LAT_BR_ClientSegmentationParameters__c' + 'LAT_BR_CSP_OffTrade'),
                LAT_BR_DataType__c = 'Code Answer',
                LAT_BR_Question__c = 'LAT_BR_SKUCategoriesAmount__c',
                LAT_BR_Answer__c = 'High categories number and more than 1000 SKUs',
                LAT_BR_AnswerCode__c = 'D4'
            );
            
            LAT_BR_ClientSegmentationParameters__c par5 = new LAT_BR_ClientSegmentationParameters__c(
                RecordTypeId = Global_RecordTypeCache.getRtId('LAT_BR_ClientSegmentationParameters__c' + 'LAT_BR_CSP_OffTrade'),
                LAT_BR_DataType__c = 'Code Answer',
                LAT_BR_Question__c = 'LAT_BR_PortfolioType__c',
                LAT_BR_Answer__c = 'Standard Products',
                LAT_BR_AnswerCode__c = 'F2'
            );
            
            LAT_BR_ClientSegmentationParameters__c par6 = new LAT_BR_ClientSegmentationParameters__c(
                RecordTypeId = Global_RecordTypeCache.getRtId('LAT_BR_ClientSegmentationParameters__c' + 'LAT_BR_CSP_OffTrade'),
                LAT_BR_DataType__c = 'Code Answer',
                LAT_BR_Question__c = 'LAT_BR_FiscalBenefit__c',
                LAT_BR_Answer__c = 'Yes',
                LAT_BR_AnswerCode__c = 'G1'
            );
            
            LAT_BR_ClientSegmentationParameters__c par7 = new LAT_BR_ClientSegmentationParameters__c(
                RecordTypeId = Global_RecordTypeCache.getRtId('LAT_BR_ClientSegmentationParameters__c' + 'LAT_BR_CSP_OffTrade'),
                LAT_BR_DataType__c = 'Code Answer',
                LAT_BR_Question__c = 'LAT_BR_RelationshipLevel__c',
                LAT_BR_Answer__c = 'Trading Brands',
                LAT_BR_AnswerCode__c = 'E3'
            );
            
            LAT_BR_ClientSegmentationParameters__c par8 = new LAT_BR_ClientSegmentationParameters__c(
                RecordTypeId = Global_RecordTypeCache.getRtId('LAT_BR_ClientSegmentationParameters__c' + 'LAT_BR_CSP_OffTrade'),
                LAT_BR_DataType__c = 'Priority Level',
                LAT_BR_Question__c = 'LAT_BR_RelationshipLevel__c',
                LAT_BR_Answer__c = 'Trading Brands',
                LAT_BR_PriorityLevel__c = tab.Id
            );
            
            LAT_BR_ClientSegmentationParameters__c par9 = new LAT_BR_ClientSegmentationParameters__c(
                RecordTypeId = Global_RecordTypeCache.getRtId('LAT_BR_ClientSegmentationParameters__c' + 'LAT_BR_CSP_OffTrade'),
                LAT_BR_DataType__c = 'Business Size',
                LAT_BR_Question__c = 'LAT_BR_StoreSize__c',
                LAT_BR_Answer__c = 'From 5 to 9 cks',
                LAT_BR_BusinessSize__c = tab5.Id
            );
            
            LAT_BR_ClientSegmentationParameters__c par10 = new LAT_BR_ClientSegmentationParameters__c(
                RecordTypeId = Global_RecordTypeCache.getRtId('LAT_BR_ClientSegmentationParameters__c' + 'LAT_BR_CSP_OffTrade'),
                LAT_BR_Key__c = 'A2B3C3D4E3F2G1',
                LAT_BR_Channel__c = 'Off Trade',
                LAT_BR_SubChannel__c = 'Atacadista',
                LAT_BR_FiscalBenefit__c = tab1.Id,
                LAT_BR_Profile__c = tab3.Id,
                LAT_BR_PriorityLevel__c = tab.Id,
                LAT_BR_Segment__c = tab2.Id,
                LAT_BR_CustomerFlag__c = tab4.Id
            );
            
            LAT_BR_ClientSegmentationParameters__c par11 = new LAT_BR_ClientSegmentationParameters__c(
                RecordTypeId = Global_RecordTypeCache.getRtId('LAT_BR_ClientSegmentationParameters__c' + 'LAT_BR_CSP_OffTrade'),
                LAT_BR_DataType__c = 'Code Answer',
                LAT_BR_Question__c = 'LAT_BR_StoresTypes__c',
                LAT_BR_Answer__c = 'Self-Service with stores in large format and low level of service',
                LAT_BR_AnswerCode__c = 'H1'
            );
            
            LAT_BR_ClientSegmentationParameters__c par12 = new LAT_BR_ClientSegmentationParameters__c(
                RecordTypeId = Global_RecordTypeCache.getRtId('LAT_BR_ClientSegmentationParameters__c' + 'LAT_BR_CSP_OffTrade'),
                LAT_BR_DataType__c = 'Code Answer',
                LAT_BR_Question__c = 'LAT_BR_StoreScope__c',
                LAT_BR_Answer__c = 'Independent local shop range',
                LAT_BR_AnswerCode__c = 'J1'
            );
            
            LAT_BR_ClientSegmentationParameters__c par13 = new LAT_BR_ClientSegmentationParameters__c(
                RecordTypeId = Global_RecordTypeCache.getRtId('LAT_BR_ClientSegmentationParameters__c' + 'LAT_BR_CSP_OffTrade'),
                LAT_BR_DataType__c = 'Code Answer',
                LAT_BR_Question__c = 'LAT_BR_StoreSize__c',
                LAT_BR_Answer__c = 'From 5 to 9 cks',
                LAT_BR_AnswerCode__c = 'L3'
            );
            
            LAT_BR_ClientSegmentationParameters__c par14 = new LAT_BR_ClientSegmentationParameters__c(
                RecordTypeId = Global_RecordTypeCache.getRtId('LAT_BR_ClientSegmentationParameters__c' + 'LAT_BR_CSP_OffTrade'),
                LAT_BR_DataType__c = 'Code Answer',
                LAT_BR_Question__c = 'LAT_BR_IsKA__c',
                LAT_BR_Answer__c = 'KA',
                LAT_BR_AnswerCode__c = 'K1'
            );
            
            LAT_BR_ClientSegmentationParameters__c par15 = new LAT_BR_ClientSegmentationParameters__c(
                RecordTypeId = Global_RecordTypeCache.getRtId('LAT_BR_ClientSegmentationParameters__c' + 'LAT_BR_CSP_OffTrade'),
                LAT_BR_DataType__c = 'Fiscal Benefit',
                LAT_BR_Question__c = 'LAT_BR_FiscalBenefit__c',
                LAT_BR_Answer__c = 'Yes',
                LAT_BR_AnswerCode__c = 'K1'
            );
            
            LAT_BR_ClientSegmentationParameters__c par16 = new LAT_BR_ClientSegmentationParameters__c(
                RecordTypeId = Global_RecordTypeCache.getRtId('LAT_BR_ClientSegmentationParameters__c' + 'LAT_BR_CSP_OffTrade'),
                LAT_BR_Key__c = 'A1F2H1J1L3',
                LAT_BR_DataType__c = 'Segmentation Key',
                LAT_BR_Channel__c = 'Off Trade',
                LAT_BR_SubChannel__c = 'C&C',
                LAT_BR_FiscalBenefit__c = tab1.Id,
                LAT_BR_Profile__c = tab3.Id,
                LAT_BR_PriorityLevel__c = tab.Id,
                LAT_BR_Segment__c = tab2.Id,
                LAT_BR_CustomerFlag__c = tab4.Id,
                LAT_BR_BusinessSize__c = tab5.Id
            );
            
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
            
            insert listUDC;
            insert listPar;         
            insert seg;
            system.test.stopTest();
            
            seg.LAT_BR_ApprovalStatus__c = null;
            seg.LAT_BR_MainAttentionChannel__c = null;
            seg.LAT_BR_PerformingArea__c = null;
            seg.LAT_BR_SKUCategoriesAmount__c = null;
            seg.LAT_BR_RelationshipLevel__c = null;
            seg.LAT_BR_FiscalBenefit__c = null;
            seg.LAT_BR_BusinessTargetAudience__c = 'Mostly Physical Persons';
            seg.LAT_BR_StoresTypes__c = 'Self-Service with stores in large format and low level of service';
            seg.LAT_BR_StoreScope__c = 'Independent local shop range';
            seg.LAT_BR_StoreSize__c = 'From 5 to 9 cks';
            seg.LAT_BR_StoreSizeDetail__c = 'Convenience';
                           
            update seg; 
        }
    }
}