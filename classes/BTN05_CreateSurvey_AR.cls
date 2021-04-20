/******************************************************************************************
*   Company:Valuenet    Developers:   Tomás Etchegaray                Date:21/03/2013     *
*   Descripcion: Va a la pagina de crear encuenta con el RT correspondiente               *
*******************************************************************************************/

global with sharing class BTN05_CreateSurvey_AR {
    
        webService static String CreateSurvey(String idAccount){
            /*CONSULTO EL RT DEL ACCOUNT*/
            
            Account acc;
            try{acc = [SELECT Id, Segmentation_Type_on_trade__c,Name FROM Account WHERE id=:idAccount];}catch(Exception e){}
            if(acc==null){
                return 'Error: No se encontró la cuenta seleccionada';
            }
             
             
            String DevName;
            system.debug('entro a la clase');
            if (acc.Segmentation_Type_on_trade__c == 'Restaurant_ARG' ){
                DevName = 'SRV_3_Restaurant_AR';
  //              system.debug('entro en resto');
            } 
            if (acc.Segmentation_Type_on_trade__c == 'Disco_ARG'){
                DevName = 'SRV_2_Disco_AR';
      //          system.debug('entro en resto');
            } 
           if (acc.Segmentation_Type_on_trade__c == 'Bar_ARG'){
                DevName = 'SRV_1_Bar_AR';
     //               system.debug('entro en resto');
            }
             if (acc.Segmentation_Type_on_trade__c != 'Restaurant_ARG' && acc.Segmentation_Type_on_trade__c != 'Disco_ARG' && acc.Segmentation_Type_on_trade__c != 'Bar_ARG'){
                return ('Error: '+Label.BTN05_00001_AR);
                   
            }
            
            
            RecordType Rt = [SELECT Id FROM RecordType WHERE SobjectType=:'SRV_Survey_ARG__c' AND RecordType.DeveloperName=:DevName];
            
             system.debug('Rt');
            
            //Redireccionar a una pagina standard
            String prefixObj = SRV_Survey_ARG__c.SObjectType.getDescribe().getKeyPrefix();
            
            String accName = acc.Name;
            String accId = acc.id;
            
            String idCampo =[SELECT Id, FieldId__c FROM CS002_FIeldsIds__c WHERE FieldApiName__c='AccountName_AR__c' AND ObjectApiName__c='SRV_Survey_ARG__c'].FieldId__c;
            idCampo = 'CF'+idCampo;
            String idAcc = '&'+idCampo+'_lkid=';
            String urlReturn = URL.getSalesforceBaseUrl().toExternalForm() +
                                    '/' + prefixObj + '/e?RecordType=' + Rt.id + 
                                    '&nooverride=1&ent=Account&retURL=%2F' + idAccount + 
                                    '&' + idCampo + '=' + EncodingUtil.urlEncode(accName, 'UTF-8') +
                                    idAcc + EncodingUtil.urlEncode(accId, 'UTF-8') ;
            // LINEA QUE FUNCIONA   String urlReturn = prefixObj+'/e?RecordType='+Rt.id+'&nooverride=1&ent=Account&retURL=%2F'+idAccount;
            //a51/e?retURL=%2F001M000000P3nEV&RecordType=012M00000000LS9&ent=01IM00000000cdD
            
            //CF00NM0000000ckF3=TEST+OFF+AR+VENDEDOR&CF00NM0000000ckF3_lkid=001M000000P3nEV&
            
            return urlReturn;
        }
    }