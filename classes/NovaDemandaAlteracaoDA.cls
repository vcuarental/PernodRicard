/**********************************************************************************************
*   Company:Valuenet    Developer:   Elena Schwarzböck               Date:29/08/2013          *
***********************************************************************************************/
 /********************************************************************************
* 
* MIGRACION LICENCIAS 
* AUTHOR: ZIMMIC                     DATE: 02/11/2016
* AUTHOR: ZIMMIC                     DATE: 05/12/2016
*
********************************************************************************/

global without sharing class NovaDemandaAlteracaoDA {

    //MIGRATED 02/11/2016 
    webService static String NovaDemanda(String IdCont){
    
        Id proUser = userinfo.getProfileid();
        
        Profile pro;
        if(!Utils.wasMigrationDone('1')) {
            pro = [SELECT Id, Name FROM Profile WHERE Name = 'Vendas' LIMIT 1];
        }
        //MIGRATED 05/12/2016 
        else {
            pro = [SELECT Id, Name FROM Profile WHERE Name = 'LAT_BR2_Vendas' LIMIT 1];
        }
        system.debug('ORG ID: ' + Userinfo.getOrganizationId());
        
        
        if(pro.id == proUser){

            String rtAgrup = RecordTypeForTest.getRecType('Agrupamento_Fiscal_Year__c', 'BRA_Standard');
            Profile pro2;
            if(!Utils.wasMigrationDone('1')) {
                pro2 = [SELECT Id, Name FROM Profile WHERE Name = 'Business administrator' LIMIT 1];
            }
            //MIGRATED 05/12/2016 
            else {
                pro2 = [SELECT Id, Name FROM Profile WHERE Name = 'LAT_BusinessAdministrator' LIMIT 1];
            }
            User userOwner = [SELECT Id FROM User WHERE profileId =: pro2.Id  AND isActive = true LIMIT 1];
            
            system.debug('ORG ID: ' + Userinfo.getOrganizationId());
            
            Integer StartMonth = [SELECT FiscalYearStartMonth FROM Organization WHERE id =:Userinfo.getOrganizationId()].FiscalYearStartMonth;
            system.debug('START MONTH: ' + StartMonth);
            
            integer AnoFiscal = system.today().year();
            
            system.debug('AÑO FISCAL: ' + AnoFiscal);
            
            if (system.today().month() >= StartMonth){
                AnoFiscal++;
                system.debug('NUEVO AÑO FISCAL: ' + AnoFiscal);
            }
        
            LAT_Contract__c contrato = [SELECT Id, Account__c, Finalidades_Acoes__c FROM LAT_Contract__c WHERE Id =: IdCont];
            
            list<Agrupamento_Fiscal_Year__c> listAgrup = [SELECT Id, Numero_da_D_A__c FROM Agrupamento_Fiscal_Year__c WHERE LAT_Contract__c =: IdCont AND Ano_fiscal_calculadoag__c =: String.valueOf(AnoFiscal) AND RecordTypeId =: rtAgrup];
            
            if(listAgrup.isEmpty() ){
                //no hay agrupamiento fiscal para el corriente año
                return ('Erro ao criar a demanda: Não existe um Agrupamento FY para o ano em curso.');
            
            } else if (listAgrup[0].Numero_da_D_A__c != null){
                if(!Utils.wasMigrationDone('1')) {
                    String rtDA = RecordTypeForTest.getRecType( 'Case', 'AlterarDAnoSistemaME');
                    Case demandaDA = new Case(
                        AccountId = contrato.Account__c,
                        Status = 'Análise pendente',
                        Priority = 'Médio',
                        Origin = 'Demanda Interna PRB',
                        LAT_Contract__c = contrato.id,
                        Purposes_Action__c = contrato.Finalidades_Acoes__c,
                        Grouping_Fiscal_Year__c = listAgrup[0].id,
                        Subject = 'Alterar D.A',
                        RecordTypeId = rtDA,
                        OwnerId = userOwner.id           
                    );
                    insert demandaDA;
                    return demandaDA.id;
                }else{
                    String rtDA = RecordTypeForTest.getRecType( 'LAT_Case__c', 'AlterarDAnoSistemaME');
                    LAT_Case__c demandaDA = new LAT_Case__c(
                        LAT_Account__c = contrato.Account__c,
                        LAT_Status__c = 'Análise pendente',
                        LAT_Priority__c = 'Médio',
                        LAT_Origin__c = 'Demanda Interna PRB',
                        LAT_Contract__c = contrato.id,
                        LAT_ActionProposal__c = contrato.Finalidades_Acoes__c,
                        LAT_GroupingFiscalYear__c = listAgrup[0].id,
                        LAT_Subject__c = 'Alterar D.A',
                        RecordTypeId = rtDA,
                        OwnerId = userOwner.id           
                    );
                    insert demandaDA;
                    return demandaDA.id;
                }
 
                
            } else {
                //el agrupamente fiscal no tiene numero DA
                return ('Error ao criar a demanda: O Agrupamento FY do ano em curso, tem que ter preenchido o Número D.A. para ser alterado.');
                
                
            }
        } else {
            //el usuario logueado no tiene perfil Vendas
            return ('Erro ao criar a demanda: Só os usuários com perfil "Vendas" podem criar demandas do tipo "Alteração D.A.');
        }
            
    }
}