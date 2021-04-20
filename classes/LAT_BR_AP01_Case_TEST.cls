/********************************************************************************
* 
* MIGRACION LICENCIAS 
* AUTHOR: ZIMMIC                     DATE: 21/11/2016
*
********************************************************************************/
@isTest
public class LAT_BR_AP01_Case_TEST {
    
    @testSetup
    public static void setup(){
        User vendas = [SELECT Id FROM User WHERE IsActive=true AND Profile.Name = 'LAT_BR2_Vendas'  and c_digo_jde__c<> null  LIMIT 1];
        List < UDC__c > tabelas = new List < UDC__c > ();
        
        Id idRecTypeUdc = RecordTypeForTest.getRecType('UDC__c', 'BRA_Standard');
        // Politicas Preco UDC 05
        tabelas.add(new UDC__c(
            CodDefUsuario__c = '1JD',
            CodProd__c = '01',
            CodUs__c = '05',
            Name = '102A-SP',
            Internal_Id__c = '1-1JD-01-05',
            RecordTypeId = idRecTypeUdc
        ));
        tabelas.add(new UDC__c(
            CodDefUsuario__c = '1',
            CodProd__c = '01',
            CodUs__c = '01',
            Name = 'REG SP',
            Internal_Id__c = '1-1-01-01',
            RecordTypeId = idRecTypeUdc
        ));
        tabelas.add(new UDC__c(
            CodDefUsuario__c = '2',
            CodProd__c = '01',
            CodUs__c = '01',
            Name = 'REG NE',
            Internal_Id__c = '1-2-01-01',
            RecordTypeId = idRecTypeUdc
        ));
            
        tabelas.add(new UDC__c(
            CodDefUsuario__c = '1IO',
            CodProd__c = '01',
            CodUs__c = '05',
            Name = '101A-RJ',
            Internal_Id__c = '1-1IO-01-05',
            RecordTypeId = idRecTypeUdc

        ));

        // UDC 03 (CANAL/SUBCANAL/SEGM)
        tabelas.add(new UDC__c(
            CodDefUsuario__c = '1',
            CodProd__c = '01',
            CodUs__c = '03',
            Name = 'DISTRIBUICAO',
            Internal_Id__c = '1-1-01-03',
            RecordTypeId = idRecTypeUdc
        ));




        tabelas.add(new UDC__c(
            CodDefUsuario__c = '11',
            CodProd__c = '01',
            CodUs__c = '03',
            Name = 'ATACADO',
            Internal_Id__c = '1-11-01-03',
            RecordTypeId = idRecTypeUdc
        ));


        tabelas.add(new UDC__c(
            CodDefUsuario__c = '116',
            CodProd__c = '01',
            CodUs__c = '03',
            Name = 'LOCAL',
            Internal_Id__c = '1-116-01-03',
            RecordTypeId = idRecTypeUdc
        ));

        // udc 20 (client type)
        tabelas.add(new UDC__c(
            CodDefUsuario__c = '9',
            CodProd__c = '01',
            CodUs__c = '20',
            Name = 'COM FATURAMENTO',
            Internal_Id__c = '1-9-01-20',
            RecordTypeId = idRecTypeUdc
        ));

        // udc 18 (estrategia)
        tabelas.add(new UDC__c(
            CodDefUsuario__c = '7',
            CodProd__c = '01',
            CodUs__c = '18',
            Name = 'ESPECIALIZADO',
            Internal_Id__c = '1-7-01-18',
            RecordTypeId = idRecTypeUdc
        ));


        //uf for account

        tabelas.add(new UDC__c(
            CodDefUsuario__c = '116',
            CodProd__c = '00',
            CodUs__c = 'CT',
            Name = 'ABADIA DE GOIAS',
            Internal_Id__c = '1-5200050-00-CT',
            Descricao2__c = 'GO',
            RecordTypeId = idRecTypeUdc
        ));
        insert tabelas;
        Account acc = new Account(
            Name = 'TEST', 
            AccountNumber = '1000', 
            Status__c = 'Novo cadastro', 
            Type = 'Payer', 
            Phone = '11 1111-1111', 
            Notes__c = 'TEST', 
            AddressLine1_AR__c = 'TEST', 
            CNPJ__c = '51987528000137', 
            Corporate_Name__c = 'TEST', 
            Channel__c = 'WS', 
            RecordTypeId = Global_RecordTypeCache.getRtId('Account' + 'Off_Trade'),
            OwnerId = vendas.Id);
        insert acc;
    }

    @isTest
    static void unitTest(){
        Utils.setMigrationDoneTest(false);
        String recordType = Global_RecordTypeCache.getRtId('LAT_Case__c' + 'Alteracao_cadastro_de_clientes');
        Id controladoriaId = [SELECT Id FROM Group WHERE Name='Controladoria' AND Type='Queue'].Id;        
        Utils.setMigrationDoneTest(false);        
        Account acc = [SELECT Id FROM Account LIMIT 1];
        
        LAT_Case__c caseCustom = new LAT_Case__c(
            RecordTypeId = recordType, 
            LAT_Type__c = 'Alteração - Cadastro de cliente', 
            LAT_Status__c = 'Reprovado', 
            LAT_Reason__c = 'Alt. tipo cliente', 
            LAT_Account__c = acc.id, 
            OwnerId = controladoriaId);
        test.StartTest();
        try{
            insert caseCustom;
            caseCustom.LAT_Status__c = 'Fechado e resolvido';
            update caseCustom;
        } catch (Exception e) {}        
        test.stopTest();
    }

    //MIGRATED 21/11/2016 
    @isTest
    static void unitTestLATCase(){
        Utils.setMigrationDoneTest(true);
        String recordType = Global_RecordTypeCache.getRtId('LAT_Case__c' + 'Alteracao_cadastro_de_clientes');        
        Utils.setMigrationDoneTest(true);        
        Account acc = [SELECT Id FROM Account LIMIT 1];
        
        LAT_Case__c caseCustom = new LAT_Case__c(
            RecordTypeId = recordType, 
            LAT_Type__c= 'Outros', 
            LAT_Status__c = 'Reprovado', 
            LAT_Reason__c = 'Alt. tipo cliente',
            LAT_Account__c = acc.id);
        test.startTest();
        try{
            insert caseCustom;
            caseCustom.LAT_Status__c = 'Fechado e resolvido';
            update caseCustom;
        } catch (Exception e) {}        
        test.stopTest();
    }

    @isTest
    static void unitTest2(){
        Utils.setMigrationDoneTest(false);
        String recordType = Global_RecordTypeCache.getRtId('LAT_Case__c' + 'Alteracao_cadastro_de_clientes');
        Id controladoriaId = [SELECT Id FROM Group WHERE Name='Controladoria' AND Type='Queue'].Id;
        Utils.setMigrationDoneTest(false);        
        Account acc = [SELECT Id FROM Account LIMIT 1];
        
        LAT_Case__c caseCustom = new LAT_Case__c(
            RecordTypeId = recordType, 
            LAT_type__c = 'Outros', 
            LAT_Status__c = 'Reprovado', 
            LAT_Account__c = acc.id,
            LAT_Reason__c = 'Alt. tipo cliente',
            OwnerId = controladoriaId);
        test.startTest();
        try{
            insert caseCustom;
            caseCustom.LAT_Status__c = 'Fechado e resolvido';
            caseCustom.LAT_Type__c = 'Alteração - Cadastro de cliente';
            update caseCustom;
        } catch (Exception e) {}        
        test.stopTest();
    }
        
    @isTest
    static void unitTest3(){
        Utils.setMigrationDoneTest(false);
        String recordType = Global_RecordTypeCache.getRtId('LAT_Case__c' + 'Alteracao_cadastro_de_clientes');
        Id controladoriaId = [SELECT Id FROM Group WHERE Name='Customer service' AND Type='Queue'].Id;        
        Utils.setMigrationDoneTest(false);        
        Account acc = [SELECT Id FROM Account LIMIT 1];
        
        LAT_Case__c caseCustom = new LAT_Case__c(
            RecordTypeId = recordType, 
            LAT_type__c = 'Outros', 
            LAT_Status__c = 'Fechado e resolvido', 
            LAT_Account__c = acc.id,
            LAT_Reason__c = 'Alt. tipo cliente',
            OwnerId = controladoriaId);
        test.startTest();
        try{
            insert caseCustom;
            caseCustom.LAT_type__c = 'Alteração - Cadastro de cliente';
            update caseCustom;
        } catch (Exception e) {}
        test.stopTest();
    }

    @isTest
    static void unitTest2B(){
        Utils.setMigrationDoneTest(true);
        String recordType = Global_RecordTypeCache.getRtId('LAT_Case__c' + 'Alteracao_cadastro_de_clientes');
        Id controladoriaId = [SELECT Id FROM Group WHERE Name='Controladoria' AND Type='Queue'].Id;        
        Utils.setMigrationDoneTest(true);
        Account acc = [SELECT Id FROM Account LIMIT 1];
        
        LAT_Case__c caseCustom = new LAT_Case__c(
            RecordTypeId = recordType, 
            LAT_type__c = 'Outros', 
            LAT_Status__c = 'Reprovado', 
            LAT_Account__c = acc.id,
            OwnerId = controladoriaId);
        test.StartTest();
        try{
            insert caseCustom;
            caseCustom.LAT_SendAccountToJDE__c = true;
            update caseCustom;
        } catch (Exception e) {}
        Titulos__c titulo = new Titulos__c(
            NetSRReceipts_AR__c = 200,
            Internal_id_pk__c = 'TEST1',
            Cliente__c = acc.id,
            codigoCia__c = 'TEST',
            dataEmissao__c = date.today(),
            dataVencimentoAtual__c = date.today(),
            dataVencimentoOriginal__c = date.today(),
            numeroDocumento__c = 1,
            parcela__c = 'T',
            valorOriginalTitulo__c = 10,
            Status__c = false,
            valorSaldo__c = 10
        );
        
        try{
            insert titulo;
        } catch (Exception e) {}
        acc.Overdue__c = true;
        try{
            update acc;
        }catch (Exception e) {}

        LAT_BR_AP01_Case.loadClientType(new List<LAT_Case__c>{caseCustom});
        test.stopTest();
    }
    
    //MIGRATED 21/11/2016 
    @isTest
    static void unitTestLATCase5(){
        Utils.setMigrationDoneTest(true);
        String recordType = Global_RecordTypeCache.getRtId('LAT_Case__c' + 'Alteracao_cadastro_de_clientes');        
        Utils.setMigrationDoneTest(true);
        Account acc = [SELECT Id FROM Account LIMIT 1];

        LAT_Case__c caseCustom = new LAT_Case__c(
            RecordTypeId = recordType, 
            LAT_Reason__c = 'Alt. tipo cliente', 
            LAT_Type__c= 'Alteração - Cadastro de cliente', 
            LAT_Status__c = 'Reprovado', 
            LAT_Account__c = acc.id);
        test.startTest();
        insert caseCustom;
        caseCustom.LAT_Status__c = 'Fechado e resolvido'; 
        update caseCustom;        
        test.stopTest();
    }

    //MIGRATED 21/11/2016 
    @isTest
    static void unitTestLATCase54(){
        Utils.setMigrationDoneTest(true);
        String recordType = Global_RecordTypeCache.getRtId('LAT_Case__c' + 'Alteracao_cadastro_de_clientes');
        Id controladoriaId = [SELECT Id FROM Group WHERE Name='Controladoria' AND Type='Queue'].Id;
        Utils.setMigrationDoneTest(true);        
        Account acc = [SELECT Id FROM Account LIMIT 1];
        acc.Reason_for_Inactivation__c = 'Empresa extinta';
        acc.Notes_1__c = 'test';
        update acc;
        
        LAT_Case__c caseCustom = new LAT_Case__c(
            RecordTypeId = recordType, 
            LAT_Type__c= 'Alteração - Cadastro de cliente', 
            LAT_Status__c = 'Reprovado',             
            LAT_Reason__c = 'Solicitação de inativação de cliente',
            LAT_Account__c = acc.id);
        test.startTest();
        insert caseCustom;
        caseCustom.LAT_Status__c = 'Fechado e resolvido'; 
        caseCustom.OwnerId = controladoriaId;
        update caseCustom;        
        test.stopTest();
    }

    @isTest
    static void unitTestLATCase55(){
        Utils.setMigrationDoneTest(true);
        String recordType = Global_RecordTypeCache.getRtId('LAT_Case__c' + 'Alteracao_cadastro_de_clientes');
        Id credYcob = [SELECT Id FROM Group WHERE Name='Crédito e Cobrança' AND Type='Queue'].Id;
        Utils.setMigrationDoneTest(true);        
        Account acc = [SELECT Id FROM Account LIMIT 1];
        
        LAT_Case__c caseCustom = new LAT_Case__c(
            RecordTypeId = recordType, 
            LAT_Reason__c = 'Alt. tipo cliente', 
            LAT_Type__c= 'Alteração - Cadastro de cliente', 
            LAT_Status__c = 'Reprovado', 
            LAT_Account__c = acc.id);
        test.startTest();
        insert caseCustom;
        caseCustom.LAT_Status__c = 'Fechado e resolvido'; 
        caseCustom.LAT_Type__c= 'Outros'; 
        caseCustom.OwnerId = credYcob;
        try{
            update caseCustom;
        }catch(Exception e){}
        test.stopTest();
    }

    @isTest
    static void unitTestLATCase56(){
        Utils.setMigrationDoneTest(true);
        String recordType = Global_RecordTypeCache.getRtId('LAT_Case__c' + 'Alteracao_cadastro_de_clientes');
        Id admVentas = [SELECT Id FROM Group WHERE Name='Administração de Vendas' AND Type='Queue'].Id;
        Utils.setMigrationDoneTest(true);        
        Account acc = [SELECT Id FROM Account LIMIT 1];
        
        LAT_Case__c caseCustom = new LAT_Case__c(
            RecordTypeId = recordType, 
            LAT_Reason__c = 'Alt. tipo cliente', 
            LAT_Type__c= 'Alteração - Cadastro de cliente', 
            LAT_Status__c = 'Reprovado', 
            LAT_Account__c = acc.id,
            OwnerId = admVentas);
        test.startTest();
        try{
            insert caseCustom;            
            caseCustom.LAT_Status__c = 'Fechado e resolvido';
            update caseCustom;
        }catch(Exception e){}        
        test.stopTest();
    }

    @isTest
    static void unitTestLATCase7(){
        Utils.setMigrationDoneTest(true);
        String recordType = Global_RecordTypeCache.getRtId('LAT_Case__c' + 'Alteracao_cadastro_de_clientes');
        Id legal = [SELECT Id FROM Group WHERE Name='Legal' AND Type='Queue'].Id;
        //Id admVentas = [SELECT Id FROM Group WHERE Name='Administração de Vendas' AND Type='Queue'].Id;
        Utils.setMigrationDoneTest(true);        
        Account acc = [SELECT Id FROM Account LIMIT 1];
        
        LAT_Case__c caseCustomLegal = new LAT_Case__c(
            RecordTypeId = recordType, 
            LAT_Type__c= 'Outros', 
            LAT_Status__c = 'Fechado e resolvido',//'Análise pendente', 
            LAT_Account__c = acc.id,
            OwnerId = legal);
        // LAT_Case__c caseCustom = new LAT_Case__c(
        //     RecordTypeId = recordType, 
        //     LAT_Type__c= 'Outros', 
        //     LAT_Status__c = 'Fechado e resolvido', 
        //     LAT_Account__c = acc.id,
        //     OwnerId = admVentas);
        test.startTest();
        try{
            insert caseCustomLegal;
            // insert caseCustom;
        } catch(Exception e){}        
        test.stopTest();
    }

    @isTest
    static void unitTestLATCase57(){
        Utils.setMigrationDoneTest(true);
        String recordType = Global_RecordTypeCache.getRtId('LAT_Case__c' + 'Alteracao_cadastro_de_clientes');
        Id admVentas = [SELECT Id FROM Group WHERE Name='Administração de Vendas' AND Type='Queue'].Id;
        Utils.setMigrationDoneTest(true);        
        Account acc = [SELECT Id FROM Account LIMIT 1];

        test.startTest();        
        acc.Status__c = 'Em análise - Customer Service';
        try{update acc;}catch(Exception e){}  
        test.stopTest();
    }

    @isTest
    static void unitTestLATCase58(){
        Utils.setMigrationDoneTest(true);
        String recordType = Global_RecordTypeCache.getRtId('LAT_Case__c' + 'Alteracao_cadastro_de_clientes');
        Id admVentas = [SELECT Id FROM Group WHERE Name='Administração de Vendas' AND Type='Queue'].Id;
        Utils.setMigrationDoneTest(true);        
        Account acc = [SELECT Id FROM Account LIMIT 1];

        test.startTest();        
        acc.Status__c = 'Em análise - Crédito e Cobrança';
        try{update acc;}catch(Exception e){}        
        test.stopTest();
    }
    
}