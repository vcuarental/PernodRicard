/****************************************************
 Dev: Denis Aranda  Version: 1  Consulting: Valuenet
****************************************************/

@IsTest
public with sharing class BTN03_AnaliticCCBtnController_AR_TEST {

    @isTest static void UnitTest(){
    
        User admin = new User();
        admin = LAT_TestUserAdmin.userWithAdminPorf ('Nome2','Sobrenome2','NSobre2','nome2@sobrenome.com','PriceCalculationInterface@mail.com','123jjjuuu2','ISO-8859-1','GMT','en_Us','en_Us','234','BR');                                                       
      
        insert admin;    
        system.runas(admin){  
        
            test.startTest();
            
            Account acco = new Account(Name='TEST', Corporate_Name__c = 'Target Corp', RecordTypeId = Global_RecordTypeCache.getRtId('Account' + 'ACC_1_OffTrade_ARG'), cnpj__c = '30500710507');
            insert acco;
            
            test.stopTest(); 
            
            RCP_Receipt_ARG__c recibo = new RCP_Receipt_ARG__c(Account_AR__c = acco.Id, RecordTypeId = Global_RecordTypeCache.getRtId('RCP_Receipt_ARG__c' + 'RCP_ReceiptGeneratedDepositDone_AR'));
            insert recibo;
            
            Titulos__c titulo = new Titulos__c (codigoCia__c = 'Targe', numeroDocumento__c = 12345678, parcela__c = 'tea', valorSaldo__c = 1230.54, valorOriginalTitulo__c = 500, dataEmissao__c = date.today(), dataVencimentoAtual__c = date.today().addMonths(3), dataVencimentoOriginal__c = date.today().addMonths(2), Internal_id_pk__c = 'Test12548', OrderNumber_AR__c = 1, Cliente__c = acco.id, RecordTypeId = Global_RecordTypeCache.getRtId('Titulos__c' + 'Standard_AR') );  
            insert titulo;
            
            Titulos__c titulo1 = new Titulos__c (codigoCia__c = 'Targ', numeroDocumento__c = 12345679, parcela__c = 'tee', valorSaldo__c = 1230.55, valorOriginalTitulo__c = 501, dataEmissao__c = date.today(), dataVencimentoAtual__c = date.today().addMonths(3), dataVencimentoOriginal__c = date.today().addMonths(2), Internal_id_pk__c = 'Test12549', OrderNumber_AR__c = 2, Cliente__c = acco.id, RecordTypeId = Global_RecordTypeCache.getRtId('Titulos__c' + 'Standard_AR') );  
            insert titulo1;
        
            string idRecibo = recibo.Id;
            
            List<Id> myList = new List<Id>();
            myList.add(titulo.id);
            myList.add(titulo1.id);
        
            BTN03_AnaliticCCBtnController_AR.idPage(idRecibo,myList);
        }
        
    }
    
    @isTest static void UnitTest1(){

        User admin = [SELECT Id FROM User WHERE Profile.Name = 'LAT_SystemAdministrator' AND isActive = true LIMIT 1]; 
        system.runas(admin){   
            
            test.startTest();
            
            Account acco = new Account(Name='TEST', Corporate_Name__c = 'Target Corp', RecordTypeId = Global_RecordTypeCache.getRtId('Account' + 'ACC_1_OffTrade_ARG'), cnpj__c = '30500710507');
            insert acco;
            
            test.stopTest();
            
            RCP_Receipt_ARG__c recibo = new RCP_Receipt_ARG__c(Account_AR__c = acco.Id, RecordTypeId = Global_RecordTypeCache.getRtId('RCP_Receipt_ARG__c' + 'RCP_ReceiptGeneratedDepositDone_AR'));
            insert recibo;
            
            Titulos__c titulo = new Titulos__c (codigoCia__c = 'Targe', numeroDocumento__c = 12345678, parcela__c = 'tea', valorSaldo__c = 1230.54, valorOriginalTitulo__c = 500, dataEmissao__c = date.today(), dataVencimentoAtual__c = date.today().addMonths(3), dataVencimentoOriginal__c = date.today().addMonths(2), Internal_id_pk__c = 'Test12548', OrderNumber_AR__c = 1, Cliente__c = acco.id, RecordTypeId = Global_RecordTypeCache.getRtId('Titulos__c' + 'Standard_AR'));  
            insert titulo;
            
            Titulos__c titulo1 = new Titulos__c (codigoCia__c = 'Targ', numeroDocumento__c = 12345679, parcela__c = 'tee', valorSaldo__c = 1230.55, valorOriginalTitulo__c = 501, dataEmissao__c = date.today(), dataVencimentoAtual__c = date.today().addMonths(3), dataVencimentoOriginal__c = date.today().addMonths(2), Internal_id_pk__c = 'Test12549', OrderNumber_AR__c = 2, Cliente__c = acco.id, RecordTypeId = Global_RecordTypeCache.getRtId('Titulos__c' + 'Standard_AR') );  
            insert titulo1;
        
            string idRecibo = recibo.Id;
            
            List<Id> myList = new List<Id>();
            myList.add(titulo.id);
            myList.add(titulo1.id);
        
            BTN03_AnaliticCCBtnController_AR.idPage(idRecibo,myList);
            BTN03_AnaliticCCBtnController_AR.idPage(idRecibo,myList);
        }
        
    }
    
    @isTest static void UnitTest2(){
    
        User admin = [SELECT Id FROM User WHERE Profile.Name = 'LAT_SystemAdministrator' AND isActive = true LIMIT 1]; 
        system.runas(admin){   
            
            
            
            Account acco = new Account(Name='TEST', Corporate_Name__c = 'Target Corp', RecordTypeId = Global_RecordTypeCache.getRtId('Account' + 'ACC_1_OffTrade_ARG'), cnpj__c = '30500710507');
            insert acco;
           
            
            
            RCP_Receipt_ARG__c recibo = new RCP_Receipt_ARG__c(Account_AR__c = acco.Id, RecordTypeId = Global_RecordTypeCache.getRtId('RCP_Receipt_ARG__c' + 'RCP_ReceiptGeneratedDepositDone_AR'));
            insert recibo;
            Test.startTest(); 
            Titulos__c titulo = new Titulos__c (codigoCia__c = 'Targe', numeroDocumento__c = 12345678, parcela__c = 'tea', valorSaldo__c = 1230.54, valorOriginalTitulo__c = 500, dataEmissao__c = date.today(), dataVencimentoAtual__c = date.today().addMonths(3), dataVencimentoOriginal__c = date.today().addMonths(2), Internal_id_pk__c = 'Test12548', OrderNumber_AR__c = 1, Cliente__c = acco.id, RecordTypeId = Global_RecordTypeCache.getRtId('Titulos__c' + 'Standard_AR') );  
            Titulos__c titulo1 = new Titulos__c (codigoCia__c = 'Targ', numeroDocumento__c = 12345679, parcela__c = 'tee', valorSaldo__c = 1230.55, valorOriginalTitulo__c = 501, dataEmissao__c = date.today(), dataVencimentoAtual__c = date.today().addMonths(3), dataVencimentoOriginal__c = date.today().addMonths(2), Internal_id_pk__c = 'Test12549', OrderNumber_AR__c = 2, Cliente__c = acco.id, RecordTypeId = Global_RecordTypeCache.getRtId('Titulos__c' + 'Standard_AR') );  
            insert new List<Titulos__c>{titulo1, titulo};
            string idRecibo = recibo.Id;
            
            List<Id> myList = new List<Id>();
            myList.add(titulo.id);
            myList.add(titulo1.id);
            

            BTN03_AnaliticCCBtnController_AR.idPage(idRecibo,myList); 
            BTN03_AnaliticCCBtnController_AR.getTitulos(idRecibo,null);
            BTN03_AnaliticCCBtnController_AR.getTitulos(idRecibo,recibo.Account_AR__c);
            try{BTN03_AnaliticCCBtnController_AR.GenerateReceipt(new List<Id>{titulo1.Id}); }catch(Exception e){}
            Test.stopTest();
        }      
    }
    
    @isTest static void UnitTest3(){
    
        User admin = [SELECT Id FROM User WHERE Profile.Name = 'LAT_SystemAdministrator' AND isActive = true LIMIT 1]; 
        system.runas(admin){   
            
            test.startTest(); 
            
            Account acco = new Account(Name='TEST', Corporate_Name__c = 'Target Corp', RecordTypeId = Global_RecordTypeCache.getRtId('Account' + 'ACC_1_OffTrade_ARG'), cnpj__c = '30500710507');
            insert acco;
            
            test.stopTest();
            
            RCP_Receipt_ARG__c recibo = new RCP_Receipt_ARG__c(Account_AR__c = acco.Id, RecordTypeId = Global_RecordTypeCache.getRtId('RCP_Receipt_ARG__c' + 'RCP_ReceiptGeneratedDepositDone_AR'));
            insert recibo;
            
            Titulos__c titulo = new Titulos__c (codigoCia__c = 'Targe', numeroDocumento__c = 12345678, parcela__c = 'tea', valorSaldo__c = 1230.54, valorOriginalTitulo__c = 500, dataEmissao__c = date.today(), dataVencimentoAtual__c = date.today().addMonths(3), dataVencimentoOriginal__c = date.today().addMonths(2), Internal_id_pk__c = 'Test12548', OrderNumber_AR__c = 1, Cliente__c = acco.id, RecordTypeId = Global_RecordTypeCache.getRtId('Titulos__c' + 'Standard_AR') );  
            insert titulo;
            
            Titulos__c titulo1 = new Titulos__c (codigoCia__c = 'Targ', numeroDocumento__c = 12345679, parcela__c = 'tee', valorSaldo__c = 1230.55, valorOriginalTitulo__c = 501, dataEmissao__c = date.today(), dataVencimentoAtual__c = date.today().addMonths(3), dataVencimentoOriginal__c = date.today().addMonths(2), Internal_id_pk__c = 'Test12549', OrderNumber_AR__c = 2, Cliente__c = acco.id, RecordTypeId = Global_RecordTypeCache.getRtId('Titulos__c' + 'Standard_AR') );  
            insert titulo1;
        
            string idRecibo;
            
            List<Id> myList = new List<Id>();
            myList.add(titulo.id);
            myList.add(titulo1.id);
        
            BTN03_AnaliticCCBtnController_AR.idPage(idRecibo,myList); 
        }      
    }
    
    @isTest static void UnitTest4(){
    
        User admin = [SELECT Id FROM User WHERE Profile.Name = 'LAT_SystemAdministrator' AND isActive = true LIMIT 1]; 
        system.runas(admin){   
            
            
            PermissionSet permission = [Select id from PermissionSet where name = 'LAT_SOA_DATA_LOAD'];

            PermissionSetAssignment psa = new PermissionSetAssignment(PermissionSetId = permission.id, AssigneeId = admin.id);
            //insert psa; 
            
            test.startTest(); 
            
            Account acco = new Account(Name='TEST', Corporate_Name__c = 'Target Corp', RecordTypeId = Global_RecordTypeCache.getRtId('Account' + 'ACC_2_OffTrade_URU'), cnpj__c = '214621120017');
            insert acco;
            
            test.stopTest();
            
            RCP_Receipt_ARG__c recibo = new RCP_Receipt_ARG__c(Account_AR__c = acco.Id, RecordTypeId = Global_RecordTypeCache.getRtId('RCP_Receipt_ARG__c' + 'RCP_ReceiptGeneratedDepositDone_UY'));
            insert recibo;
            
            Titulos__c titulo = new Titulos__c (codigoCia__c = 'Targe', numeroDocumento__c = 12345678, parcela__c = 'tea', valorSaldo__c = 1230.54, valorOriginalTitulo__c = 500, dataEmissao__c = date.today(), dataVencimentoAtual__c = date.today().addMonths(3), dataVencimentoOriginal__c = date.today().addMonths(2), Internal_id_pk__c = 'Test12548', OrderNumber_AR__c = 1, Cliente__c = acco.id, RecordTypeId = Global_RecordTypeCache.getRtId('Titulos__c' + 'Standard_UY') );  
            insert titulo;
            
            Titulos__c titulo1 = new Titulos__c (codigoCia__c = 'Targ', numeroDocumento__c = 12345679, parcela__c = 'tee', valorSaldo__c = 1230.55, valorOriginalTitulo__c = 501, dataEmissao__c = date.today(), dataVencimentoAtual__c = date.today().addMonths(3), dataVencimentoOriginal__c = date.today().addMonths(2), Internal_id_pk__c = 'Test12549', OrderNumber_AR__c = 2, Cliente__c = acco.id, RecordTypeId = Global_RecordTypeCache.getRtId('Titulos__c' + 'Standard_UY') );  
            insert titulo1;
        
            string idRecibo = recibo.Id;
            
            List<Id> myList = new List<Id>();
            myList.add(titulo.id);
            myList.add(titulo1.id);
        
            BTN03_AnaliticCCBtnController_AR.idPage(idRecibo,myList);
        }       
    }
    
    @isTest static void UnitTest5(){
    
        User admin = [SELECT Id FROM User WHERE Profile.Name = 'LAT_SystemAdministrator' AND isActive = true LIMIT 1]; 
        system.runas(admin){   
            
            test.startTest(); 
            
            Account acco = new Account(Name='TEST', Corporate_Name__c = 'Target Corp', RecordTypeId = Global_RecordTypeCache.getRtId('Account' + 'ACC_4_OnTrade_URU'), cnpj__c = '214621120017');
            insert acco;
            
            test.stopTest();
            
            RCP_Receipt_ARG__c recibo = new RCP_Receipt_ARG__c(Account_AR__c = acco.Id);
            insert recibo;
            
            Titulos__c titulo = new Titulos__c (codigoCia__c = 'Targe', numeroDocumento__c = 12345678, parcela__c = 'tea', valorSaldo__c = 1230.54, valorOriginalTitulo__c = 500, dataEmissao__c = date.today(), dataVencimentoAtual__c = date.today().addMonths(3), dataVencimentoOriginal__c = date.today().addMonths(2), Internal_id_pk__c = 'Test12548', OrderNumber_AR__c = 1, Cliente__c = acco.id, RecordTypeId = Global_RecordTypeCache.getRtId('Titulos__c' + 'Standard_UY') );  
            insert titulo;
            
            Titulos__c titulo1 = new Titulos__c (codigoCia__c = 'Targ', numeroDocumento__c = 12345679, parcela__c = 'tee', valorSaldo__c = 1230.55, valorOriginalTitulo__c = 501, dataEmissao__c = date.today(), dataVencimentoAtual__c = date.today().addMonths(3), dataVencimentoOriginal__c = date.today().addMonths(2), Internal_id_pk__c = 'Test12549', OrderNumber_AR__c = 2, Cliente__c = acco.id, RecordTypeId = Global_RecordTypeCache.getRtId('Titulos__c' + 'Standard_UY') );  
            insert titulo1;
        
            string idRecibo = recibo.Id;
            
            string titloid;
            
            List<Id> myList = new List<Id>();
            myList.add(titloid);
        
            BTN03_AnaliticCCBtnController_AR.idPage(idRecibo,myList); 
        }      
    }
}