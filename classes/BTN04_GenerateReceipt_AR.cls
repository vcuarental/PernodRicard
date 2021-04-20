/***********************************************************************************************************
*   Company:Valuenet    Developers:   Tomás Etchegaray                Date:04/04/2013          *
*   Descripcion:Validacion sobre los Titulos em aberto seleccionados para crear un recibo   *
************************************************************************************************************/

global with sharing class BTN04_GenerateReceipt_AR {
    
    webService static String GenerateReceipt(list<id> ids_Register){

       list<id> listDeIdsREgistros = ids_Register;

        
        set<String> setDeBusqueda = new set<String>();
    
        for ( id a :listDeIdsREgistros ){
            setDeBusqueda.add(a);
        }
       system.debug('setDeBusquedaASD'+setDeBusqueda.size());
       system.debug('listDeIdsREgistrosASD'+listDeIdsREgistros.size());
      
       
       list<Titulos__c> tit = [SELECT Id,Name,NetOpenBalance_AR__c, tipoDocumento__c,ReceiptNumber_AR__c, Internal_id_pk__c FROM Titulos__c WHERE id IN : setDeBusqueda];
       List<LAT_Blocked_Document__c> docs = [SELECT Internal_id_pk__c, LAT_Receipt__r.Name FROM LAT_Blocked_Document__c];
       Map<String, String> mapRecibosXInternalId = new Map<String, String>();
       for(LAT_Blocked_Document__c doc : docs) {
          mapRecibosXInternalId.put(doc.Internal_id_pk__c, doc.LAT_Receipt__r.Name);
       }
       system.debug('sizeQuery'+ tit.size());
       system.debug('titit'+ tit);
              
       String error = '';
       
       set<Id> setIdAccounts = new set<Id>();
       
       for (Titulos__c t : tit){
       
           // validacion 2.1
           if (  (t.tipoDocumento__c == 'RU') &&  (t.ReceiptNumber_AR__c != null) ){
               error = label.BTN04_00001_AR;
               return error;
           } 
           
           // validacion 2.2
            if (  t.tipoDocumento__c == 'R1' ){
               error = label.BTN04_00002_AR;
               return error;
           } 
          // validacion 2.3
            if (  t.tipoDocumento__c == 'AA' ){
               error = 'No se pueden seleccionar Analíticos de tipo AA.';
               return error;
           }
           // validacion 2.4
           if(mapRecibosXInternalId.keySet().contains(t.Internal_id_pk__c)) {
              error = 'Existen Recibos pendientes de Integración que incluyen este Analítico (Recibo:' + mapRecibosXInternalId.get(t.Internal_id_pk__c) + ', Analítico: '+t.Name +').';
              return error;
           } 
       }
       
       
       boolean flag = false;

       for (Titulos__c t : tit){
           if (  t.NetOpenBalance_AR__c == 0 ){
               if (flag == false){
                   error = label.BTN04_00006_AR;
                   flag = true;
               }
           error = error + '  ' + t.Name + ' ';
           } 
       }
     
       
       return error;
    
    } 


/*******************************************************************************************************************************
* Company:Valuenet 
* Desarrollador: Elena J. Schwarzböck
* Nombre del boton: TIT_GenerateReceipt_AR
* Descripcion: valida que si se ingreso desde la ficha de ACC se seleccionaron titulos del mismo cliente, y que se si se ingreso
*              por la lista relacionado del cliente ademas esos titulos seleccionados correspondan a ese cliente.          
* Fecha: 16/05/2013
********************************************************************************************************************************/
    
    webService static String AccountIdSelected(list<id> ids_Register, String IdAcc){

        list<id> listDeIdsREgistros = ids_Register;

        set<String> setDeBusqueda = new set<String>();
    
        for ( id a :listDeIdsREgistros ){
            setDeBusqueda.add(a);
        }     
       
        list<Titulos__c> tit = [SELECT Id,Name, tipoDocumento__c,ReceiptNumber_AR__c,Cliente__c FROM Titulos__c WHERE id IN : setDeBusqueda];
       
        set<Id> setIdAccounts = new set<Id>();
       
        for (Titulos__c t : tit){        
           setIdAccounts.add(t.Cliente__c);
        }
   
        list<Account> listAccounts = [SELECT Id FROM Account WHERE Id IN: setIdAccounts];
       
        Id b = listAccounts[0].id;
        
        string IdResultado = b;
        
        if (IdAcc == ''){ 
        
            for(Account acc: listAccounts){

                if(acc.id != b){
                    IdResultado = '';
                    return IdResultado;
                }
            }
        } else {
            for(Account acc: listAccounts){
                    if (acc.id != IdAcc){
                    IdResultado = '';
                    return IdResultado;
                    }
                }       
        }
        
        return IdResultado;
    }
         
}