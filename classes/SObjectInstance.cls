/*******************************************************************************
*                     Copyright (C) 2012 - Cloud2b
*-------------------------------------------------------------------------------
* Classe responsável por criar todo os objetos da organização Afim de manter a
* manutenção da criação de dos objetos em um único local.
*
* NAME: SObjectInstanceTest.cls
* AUTHOR: MARCOS DOBROWOLSKI                          DATE: 19/03/2013 
*******************************************************************************/

@isTest (seeAllData=true)
public class SObjectInstance {
  
  public static Account createAccount() {
    Account acc = new Account();
    acc.Name = 'Conta Teste';
    acc.CNPJ__c = '48843971000120';
    acc.Type = 'Outros';
    acc.Status__c = 'Cliente cadastrado no JDE';
    acc.Agency__c = '000';
    acc.Checking_account__c = '000';
    acc.Current_account__c = '0';
    acc.Corporate_Name__c = 'Teste';
    acc.Channel__c = 'Off Trade';
    acc.Frequency_of_Visits__c = 'Semanal';
    acc.Client_code_AN8__c = '335577';
    acc.Channel_Type__c = 'Direto';
    return acc;
  }
  
  public static Profile createProfile(){
    Profile perfil = [Select Id From Profile limit 1];
    return perfil;
  }
  
  public static User createUser() {
    User usuario = new User();
    usuario.FirstName = 'Nome';
    usuario.LastName = 'SobrenomeV';
    usuario.Alias = 'NSobreV';
    usuario.Email = 'usuario@sobrenomeV.com';
    usuario.Username = 'devtestusercloud2b@cloud2b.com.br';
    usuario.CommunityNickname = '123jjjuuu';
    usuario.EmailEncodingKey = 'ISO-8859-1';
    usuario.TimeZoneSidKey  = 'GMT';
    usuario.LocaleSidKey  = 'en_Us';
    usuario.LanguageLocaleKey = 'en_Us';
    usuario.C_digo_JDE__c = '234';
    usuario.Country = 'BR';
    return usuario;
  }

  public static Planejamento__c createPlanejamento() {
    Planejamento__c plan = new Planejamento__c();
    plan.Name = 'Plan Teste';
    return plan;
  }
  
  public static Visitas__c createVisitas() {
    Visitas__c visita = new Visitas__c();
    visita.Name = 'Teste';
    visita.Data_da_Visita__c = System.today();
    visita.Hora_da_Visita__c = '08:00';
    visita.Tipo_de_Visita__c = 'Execução';
    visita.Resumo_da_Visita__c = 'teste';
    return visita;
  }
  
  public static UDC__c createUDC() {
    UDC__c udc = new UDC__c();
    udc.CodUs__c = '03';
    udc.CodProd__c = '01';
    udc.Name = 'KA';
    udc.Internal_Id__c = '1238';
    return udc;
  }

}