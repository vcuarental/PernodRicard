@isTest
/********************************************************************************
*                         Copyright 2012 - Cloud2b
********************************************************************************
* Realiza teste de cobertura da classe CasoCopiaIdGerenteRegionalArea.cls
*                                      TRCustomerInterface - 80%
*                                      CriaCriterioRegional - 100%
*                                      ContaCopiaIdGerenteRegionalArea - 100%
*                                      ContratoCopiaIdGerenteRegionalArea - 100%
*                                      UserDAO - 100%
*
* NAME: CasoCopiaIdGerenteRegionalAreaTest.cls
* AUTHOR: CARLOS CARVALHO                        DATE: 12/03/2012 
*
* MAINTENANCE: 
* AUTHOR: CARLOS CARVALHO                        DATE: 14/05/2012
*
* MAINTENANCE: INSERIDO LÓGICA DE VALIDAÇÃO DO TIPO DE REGISTRO DOS OBJETOS.
* AUTHOR: CARLOS CARVALHO                           DATE: 09/01/2013 
********************************************************************************/
/********************************************************************************
* 
* MIGRACION LICENCIAS 
* AUTHOR: ZIMMIC                     DATE: 21/11/2016
*
********************************************************************************/
private class CasoCopiaIdGerenteRegionalAreaTest {

    static testMethod void CasoCopiaIdGerenteRegionalAreaTest() {
        
        Profile perfil = null;
        User usuario = null;
        User gerente = null;
        Account acc = null;
        LAT_Contract__c contract = null;
        Case caso = null;
        Id idRecTypeUdc =  [SELECT id,Name FROM RecordType WHERE SobjectType='UDC__c' AND DeveloperName = 'BRA_Standard' Limit 1].id;
        
        perfil =  [SELECT Id, Name, Description FROM Profile WHERE UserType = 'Standard' AND PermissionsAuthorApex = true AND name != 'System Administrator SESAME'  LIMIT 1];
        
        gerente = new User();
        gerente.FirstName           = 'Nome';
        gerente.LastName            = 'SobrenomeC';
        gerente.Alias               = 'NSobreC';
        gerente.Email               = 'gerenteC@sobrenome.com';
        gerente.Username            = 'devtestusercloud2b@cloud2b.com.br';
        gerente.CommunityNickname   = '123jjjuuu';
        gerente.EmailEncodingKey    = 'ISO-8859-1';
        gerente.TimeZoneSidKey      = 'GMT';
        gerente.LocaleSidKey        = 'en_Us';
        gerente.LanguageLocaleKey   = 'en_Us';
        gerente.C_digo_JDE__c       = '234';
        gerente.ProfileId           = perfil.Id;
        gerente.Country = 'BR';
        
        insert gerente;
        
        usuario = new User();
        usuario.FirstName           = 'nome';
        usuario.LastName            = 'Sobrenome';
        usuario.Alias               = 'NSobreU';
        usuario.Email               = 'usuarioC@sobrenome.com';
        usuario.Username            = 'devtestusercloud2b2@cloud2b.com.br';
        usuario.CommunityNickname   = '1234jjuuu';
        usuario.EmailEncodingKey    = 'ISO-8859-1';
        usuario.TimeZoneSidKey      = 'GMT';
        usuario.LocaleSidKey        = 'en_Us';
        usuario.LanguageLocaleKey   = 'en_Us';
        usuario.C_digo_JDE__c       = '235';
        usuario.ProfileId           = perfil.Id;
        usuario.Gerente_de_area__c  = gerente.Id;
        usuario.Gerente_regional__c = gerente.Id;
        usuario.Country = 'BR';
       
        insert usuario;
 
        acc = new Account();
        acc.OwnerId = usuario.Id;
        acc.Name = 'Conta teste Trigger';
        acc.CNPJ__c = '48843971000120';
        acc.Type = 'Outros';
        acc.Status__c = 'Cliente cadastrado no JDE';
        acc.Agency__c = '000';
        acc.Checking_account__c = '000';
        acc.Current_account__c = '0';
        acc.Corporate_Name__c = 'Teste';
        acc.RecordTypeId = RecordTypeForTest.getRecType('Account', 'Off_Trade');
        acc.Area_Manager__c = gerente.Id;
        acc.Regional_Manager__c = gerente.Id;
        
        insert acc;       

        
        test.startTest();
        System.runAs(usuario){     

            contract = new LAT_Contract__c();
            contract.OwnerId = usuario.Id;
            contract.Account__c = acc.Id;
            contract.Status__c = 'Em elaboração';
            contract.StartDate__c = System.today();
            contract.ContractTerm__c = 12;
            contract.RecordTypeId = RecordTypeForTest.getRecType('LAT_Contract__c', 'Assinatura_de_contrato_Off_Trade');
      
            insert contract;
            
            caso = new Case();
            caso.AccountId = acc.Id;
            caso.Origin = 'Demanda Interna';
            caso.Reason = 'Alt. tipo cliente';
            caso.Status = 'Novo';
            caso.LAT_Contract__c = contract.id;
            caso.RecordTypeId = [SELECT id,Name FROM RecordType WHERE SobjectType='Case' AND DeveloperName = 'Alteracao_cadastro_de_clientes' Limit 1].id;
            insert caso;

        }

        test.stopTest();   
    }
//MIGRATED 21/11/2016
    static testMethod void CasoCopiaIdGerenteRegionalAreaTestLATCaso() {
        
        Profile perfil = null;
        User usuario = null;
        User gerente = null;
        Account acc = null;
        LAT_Contract__c contract = null;
        LAT_Case__c caso = null;
        Id idRecTypeUdc =  [SELECT id,Name FROM RecordType WHERE SobjectType='UDC__c' AND DeveloperName = 'BRA_Standard' Limit 1].id;
        
        perfil =  [SELECT Id, Name, Description FROM Profile WHERE UserType = 'Standard' AND PermissionsAuthorApex = true AND name != 'System Administrator SESAME'  LIMIT 1];
        
        gerente = new User();
        gerente.FirstName           = 'Nome';
        gerente.LastName            = 'SobrenomeC';
        gerente.Alias               = 'NSobreC';
        gerente.Email               = 'gerenteC@sobrenome.com';
        gerente.Username            = 'devtestusercloud2b@cloud2b.com.br';
        gerente.CommunityNickname   = '123jjjuuu';
        gerente.EmailEncodingKey    = 'ISO-8859-1';
        gerente.TimeZoneSidKey      = 'GMT';
        gerente.LocaleSidKey        = 'en_Us';
        gerente.LanguageLocaleKey   = 'en_Us';
        gerente.C_digo_JDE__c       = '234';
        gerente.ProfileId           = perfil.Id;
        gerente.Country = 'BR';
        
        insert gerente;
        
        usuario = new User();
        usuario.FirstName           = 'nome';
        usuario.LastName            = 'Sobrenome';
        usuario.Alias               = 'NSobreU';
        usuario.Email               = 'usuarioC@sobrenome.com';
        usuario.Username            = 'devtestusercloud2b2@cloud2b.com.br';
        usuario.CommunityNickname   = '1234jjuuu';
        usuario.EmailEncodingKey    = 'ISO-8859-1';
        usuario.TimeZoneSidKey      = 'GMT';
        usuario.LocaleSidKey        = 'en_Us';
        usuario.LanguageLocaleKey   = 'en_Us';
        usuario.C_digo_JDE__c       = '235';
        usuario.ProfileId           = perfil.Id;
        usuario.Gerente_de_area__c  = gerente.Id;
        usuario.Gerente_regional__c = gerente.Id;
        usuario.Country = 'BR';
       
        insert usuario;
        
        acc = new Account();
        acc.OwnerId = usuario.Id;
        acc.Name = 'Conta teste Trigger';
        acc.CNPJ__c = '48843971000120';
        acc.Type = 'Outros';
        acc.Status__c = 'Cliente cadastrado no JDE';
        acc.Agency__c = '000';
        acc.Checking_account__c = '000';
        acc.Current_account__c = '0';
        acc.Corporate_Name__c = 'Teste';
        acc.RecordTypeId = RecordTypeForTest.getRecType('Account', 'Off_Trade');
        acc.Area_Manager__c = gerente.Id;
        acc.Regional_Manager__c = gerente.Id;
        
        insert acc;       

        
        test.startTest();
        System.runAs(usuario){     

            contract = new LAT_Contract__c();
            contract.OwnerId = usuario.Id;
            contract.Account__c = acc.Id;
            contract.Status__c = 'Em elaboração';
            contract.StartDate__c = System.today();
            contract.ContractTerm__c = 12;
            contract.RecordTypeId = RecordTypeForTest.getRecType('LAT_Contract__c', 'Assinatura_de_contrato_Off_Trade');
      
            insert contract;
            
            caso = new LAT_Case__c();
            caso.LAT_Account__c = acc.Id;
            caso.LAT_Origin__c = 'Demanda Interna';
            caso.LAT_Reason__c = 'Alt. tipo cliente';
            caso.LAT_Status__c = 'Novo';
            caso.LAT_Contract__c = contract.id;
            caso.RecordTypeId = [SELECT id,Name FROM RecordType WHERE SobjectType='LAT_Case__c' AND DeveloperName = 'Alteracao_cadastro_de_clientes' Limit 1].id;
            insert caso;

        }

        test.stopTest();   
    }
}