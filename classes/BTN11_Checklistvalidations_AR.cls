/********************************************************************************************************************************************************************
*  Company:Valuenet           Developer  Tomás Etchegaray          Date:18/04/2013 descripcion: Hace validaciones sobre visitas y crea checklist de visita asociados  **
*********************************************************************************************************************************************************************/


global with sharing class BTN11_Checklistvalidations_AR {

    webService static String checkValidations(String idVisita){
       /*CONSULTO EL RT DEL ACCOUNT*/
            
        //system.debug('token visita: '+idVisita);
        Visitas__c visita = [SELECT Id,Hora_da_Visita__c,Data_da_Visita__c, Conta__c, Resumo_da_Visita__c FROM Visitas__c WHERE id=:idVisita];
   
        if (visita.Hora_da_Visita__c == null || visita.Data_da_Visita__c == null || visita.Resumo_da_Visita__c == null ){
          //return ('Error: '+Label.ACC00004);//////////////////////////////////////////////////////////////////////////////importante
          if (visita.Hora_da_Visita__c == null){
              return ('Error: '+ label.BTN11_00002_AR);
          }
          if (visita.Data_da_Visita__c == null){
              return ('Error: '+ label.BTN11_00001_AR);
          }
          if (visita.Resumo_da_Visita__c == null){
              return ('Error: '+ label.BTN11_00003_AR);
          }
        } 

        string idConta = visita.Conta__c;

        Account acc = [SELECT Id, checkList_AR__c,Channel__c,Sub_Channel__c, Recordtype.DeveloperName FROM Account WHERE id=:idConta];
        
        system.debug('rtcliente' + acc.Recordtype.DeveloperName);
            
        string valor =  acc.checkList_AR__c;   
            
        system.debug(' valor' +valor);
            
        string recTypeNAme = returnRecordtypeNAme(valor,acc.Recordtype.DeveloperName);
           
        system.debug('rtname' +recTypeNAme);
                       
        RecordType Rt;
        try{
            Rt = [SELECT Id, DeveloperName FROM RecordType WHERE SobjectType=:'CLV_ChecklistVisita_ARG__c' AND RecordType.DeveloperName=:recTypeNAme];
        }catch(Exception e){
            return ('Error: '+ Label.BTN13_00001_AR);
        }
            
        system.debug('Rtidd' +Rt );
       
        string channel = acc.Channel__c;
        string subbchannel = acc.Sub_Channel__c;
        CLV_ChecklistVisita_ARG__c check = new CLV_ChecklistVisita_ARG__c();
        check.Visit_AR__c = idVisita;
        check.RecordTypeId = Rt.id;
        try{
           insert check;
        }catch(Exception e){
            return ('Error: '+ e.getMessage());
        }
       /* ESTO UN CREA PARAMETRO PRODUCTO CONCURRENCIA EL CUAL NI PARA ARGENTINA NI URUGUAY LO USAN
       list<Par_metro_Produto_Concorr_ncia__c> listProdu = [SELECT Id, Canal__c, Sub__c, Produto_Pernod__c, Produto_Concorrencia__c FROM Par_metro_Produto_Concorr_ncia__c WHERE (Canal__c =:channel OR Sub__c =: subbchannel) OR (Canal__c = NULL AND  Sub__c = NULL ) ];// hace falta comparar con sub IMPORTANTE
       list<Produto_Concorr_ncia__c> listProdConcu = new list<Produto_Concorr_ncia__c>();
       for (Par_metro_Produto_Concorr_ncia__c par : listProdu){
            Produto_Concorr_ncia__c produ = new Produto_Concorr_ncia__c(
            Canal__c = par.Canal__c ,
            Produto_PERNOD__c = par.Produto_Pernod__c,
            Produto_Concorrente__c = par.Produto_Concorrencia__c);
            listProdConcu.add(produ);
            
       try{
           insert listProdConcu;
       }catch(Exception e){
           return ('Error: '+ e.getMessage());
       }*/
       return check.id;
    }
    
    public static string returnRecordtypeNAme(string value,string client){
    
        string resul; 
    
        
            if (value == 'Supermarkets_ARG'){
                resul = 'CLV_Supermarkets_ARG';}
            
            if (value == 'Wholesalers_ARG'){
                resul = 'CLV_Wholesalers_ARG';}
            
            if (value == 'Distributors On_ARG'){
                resul = 'CLV_DistributorsOn_ARG';}
            
            if (value == 'Distributors Off_ARG'){
                resul = 'CLV_DistributorsOff_ARG';}
            
            if (value == 'Wineries_ARG'){
                resul = 'CLV_Wineries_ARG';}
            
            if (value == 'Direct On-Trade_ARG'){
                resul = 'CLV_DirectOntrade_ARG';}
            
            if (value == 'POS Supermarkets_ARG'){
                resul = 'CLV_POSSupermarkets_ARG';}
            
            if (value == 'POS Wholesalers_ARG'){
                resul = 'CLV_POSWholesalers_ARG';}
            
            if (value == 'Convenience Stores_ARG'){
                resul = 'CLV_ConvenienceStores_ARG';}
            
            if (value == 'POS Wineries_ARG'){
                resul = 'CLV_POSWineries_ARG';}
            
            if (value == 'Indirect On-Trade_ARG'){
                resul = 'CLV_IndirectOnTrade_ARG';}
            
            if (value == 'Direct Off-Trade_URU'){
                resul = 'CLV_DirectOffTrade_URU';}
            
            if (value == 'POS Direct Off-Trade_URU'){
                resul = 'CLV_POSDirectOffTrade_URU';}
            
            if (value == 'Indirect Off-Trade_URU'){
                resul = 'CLV_IndirectOffTrade_URU';}
            
            if (value == 'Distributors_URU'){
                resul = 'CLV_Distributors_URU';}
            
            if (value == 'Border_URU'){
                resul = 'CLV_Border_URU';}
            
            if (value == 'Direct On-Trade_URU'){
                resul = 'CLV_OnTradeDirecto_URU';}
            
            if (value == 'Indirect On-Trade_URU'){
                resul = 'CLV_OnTradeIndirectos_URU';}
                
            if (value == 'None_ARG'){
                if (client == 'ACC_1_OffTrade_ARG' || client == 'ACC_3_OnTrade_ARG' || client == 'ACC_5_Events_ARG'  ){
                resul = 'CLV_IndirectOnTrade_ARG';
                }
                if (client == 'ACC_4_OnTrade_URU' || client == 'ACC_2_OffTrade_URU' || client == 'ACC_6_Events_URU'  ){
                resul = 'CLV_OnTradeIndirectos_URU';
                }
            }
                
                return resul;
    }
    
    
    

}