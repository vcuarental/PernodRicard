/******************************************************************************************************************************************************************************
*   Company:Valuenet    Developers:   Tomás Etchegaray                                                                                                                                                     *
*   Date:22/03/2013     Descripcion: Clona una cuenta exeptuando algunos campos que se los paso por custom setting                                                    *
********************************************************************************************************************************************************************************/


global with sharing class BTN06_CloneAccount_AR {
    
     webService static String AccountClone(String idAccount, String action){
           
            try{ 
                    /*CONSULTO EL RT DEL ACCOUNT*/
                    
                    Account acc = [SELECT Id, Segmentation_Type_on_trade__c,Name,ParentId FROM Account WHERE id=:idAccount];
                    String accName = acc.Name;
                    String accId = acc.id;

                    //Redireccionar a una pagina standard
                    String prefixObj = SRV_Survey_ARG__c.SObjectType.getDescribe().getKeyPrefix();
                    
                    String val = 'false';
                    String urlReturn = '/'+accId+'/e?clone=1&';

                    String idCampo_01 = [SELECT Id, FieldId__c FROM CS002_FIeldsIds__c WHERE FieldApiName__c='Client_code_AN8__c' AND ObjectApiName__c='Account'].FieldId__c;
                    String idCampo_02 = [SELECT Id, FieldId__c FROM CS002_FIeldsIds__c WHERE FieldApiName__c='Credit_line__c' AND ObjectApiName__c='Account'].FieldId__c;
                    String idCampo_03 = [SELECT Id, FieldId__c FROM CS002_FIeldsIds__c WHERE FieldApiName__c='Rating_segmentation_targert_market__c' AND ObjectApiName__c='Account'].FieldId__c;
                    String idCampo_04 = [SELECT Id, FieldId__c FROM CS002_FIeldsIds__c WHERE FieldApiName__c='Status__c' AND ObjectApiName__c='Account'].FieldId__c;
                    /* modificacion por bug*/
                     
                    String idCampo_05 = [SELECT Id, FieldId__c FROM CS002_FIeldsIds__c WHERE FieldApiName__c='ParentId' AND ObjectApiName__c='Account'].FieldId__c;
                    String idCampo_06 = [SELECT Id, FieldId__c FROM CS002_FIeldsIds__c WHERE FieldApiName__c='ParentName' AND ObjectApiName__c='Account'].FieldId__c;
                    
                    String idCampo_07 = [SELECT Id, FieldId__c FROM CS002_FIeldsIds__c WHERE FieldApiName__c='Overdue__c' AND ObjectApiName__c='Account'].FieldId__c;
                    String idCampo_08 = [SELECT Id, FieldId__c FROM CS002_FIeldsIds__c WHERE FieldApiName__c='Credit_line_USD_AR__c' AND ObjectApiName__c='Account'].FieldId__c;
                    String idCampo_09 = [SELECT Id, FieldId__c FROM CS002_FIeldsIds__c WHERE FieldApiName__c='Sub_Channel__c' AND ObjectApiName__c='Account'].FieldId__c;
                    
                    String idCampo_10 = [SELECT Id, FieldId__c FROM CS002_FIeldsIds__c WHERE FieldApiName__c='CNPJ__c' AND ObjectApiName__c='Account'].FieldId__c;
                    String idCampo_11 = [SELECT Id, FieldId__c FROM CS002_FIeldsIds__c WHERE FieldApiName__c='Corporate_Name__c' AND ObjectApiName__c='Account'].FieldId__c;
                    String idCampo_12 = [SELECT Id, FieldId__c FROM CS002_FIeldsIds__c WHERE FieldApiName__c='AccountNumber' AND ObjectApiName__c='Account'].FieldId__c;
                    String idCampo_13 = [SELECT Id, FieldId__c FROM CS002_FIeldsIds__c WHERE FieldApiName__c='SaveDuplicatedFiscalID_AR__c' AND ObjectApiName__c='Account'].FieldId__c;
                    String idCampo_14 = [SELECT Id, FieldId__c FROM CS002_FIeldsIds__c WHERE FieldApiName__c='Client_country_AN8__c' AND ObjectApiName__c='Account'].FieldId__c;
                    String idCampo_15 = [SELECT Id, FieldId__c FROM CS002_FIeldsIds__c WHERE FieldApiName__c='State_Registration__c' AND ObjectApiName__c='Account'].FieldId__c;
                    String idCampo_16 = [SELECT Id, FieldId__c FROM CS002_FIeldsIds__c WHERE FieldApiName__c='AddressLine1_AR__c' AND ObjectApiName__c='Account'].FieldId__c;
                    String idCampo_17 = [SELECT Id, FieldId__c FROM CS002_FIeldsIds__c WHERE FieldApiName__c='Revenue_City__c' AND ObjectApiName__c='Account'].FieldId__c;
                    String idCampo_18 = [SELECT Id, FieldId__c FROM CS002_FIeldsIds__c WHERE FieldApiName__c='Notes_1__c' AND ObjectApiName__c='Account'].FieldId__c;
                    String idCampo_19 = [SELECT Id, FieldId__c FROM CS002_FIeldsIds__c WHERE FieldApiName__c='CustomerPriceGroup_AR__c' AND ObjectApiName__c='Account'].FieldId__c;
                    String idCampo_20 = [SELECT Id, FieldId__c FROM CS002_FIeldsIds__c WHERE FieldApiName__c='Revenue_Postal_Code__c' AND ObjectApiName__c='Account'].FieldId__c;
                    String idCampo_21 = [SELECT Id, FieldId__c FROM CS002_FIeldsIds__c WHERE FieldApiName__c='Name' AND ObjectApiName__c='Account'].FieldId__c;

                    if(action.equalsIgnoreCase('P')){

                        urlReturn += idCampo_01+'=+'+'&'+idCampo_02+'=+'+'&'+idCampo_03+'=+'
                        +'&'+idCampo_04+'=Novo Cadastro'+'&'+idCampo_05+'='+'&'+idCampo_06+'='+'&'
                        +idCampo_07+'='+val+'&'+idCampo_08+'='+''+'&'+'&'+idCampo_10+'='
                    +'&'+idCampo_11+'='+''+'&'+idCampo_12+'='+''+'&'+idCampo_13+'='
                    +'&'+idCampo_14+'='+''+'&'+idCampo_15+'='+''+'&'+idCampo_16+'='
                    +'&'+idCampo_17+'='+''+'&'+idCampo_18+'='+''+'&'+idCampo_19+'='
                    +'&'+idCampo_20+'='+''+'&'+idCampo_21+'=';

                    } else{

                        String parent;
                        String parentName;
                        if(acc.ParentId != null){
                            Parent = acc.ParentId;
                        }else{
                            parent = acc.id;
                        }
                        
                        Account accPAdre = [SELECT Id, Name FROM Account WHERE id = :parent];
                        parentName = accPAdre.Name;

                        urlReturn += idCampo_01+'=+'+'&'+idCampo_02+'=+'+'&'+idCampo_03+'=+'+'&'+idCampo_04+'=Novo Cadastro'+'&'+idCampo_05+'='+Parent+'&'+idCampo_06+'='+ParentName+'&'+idCampo_07+'='+val
                    +'&'+idCampo_08+'='+''+'&'+idCampo_13+'='+ ''+'&'+ idCampo_14+'='+'' + '&'+idCampo_16+'='
                    +'&'+idCampo_17+'='+''+'&'+idCampo_18+'='+''+'&'+idCampo_20+'=';

                    } 
                    
                    system.debug('action: ' + action);
                    system.debug('urlReturn: ' + urlReturn);
                    //SE PIDE SACAR
                    //String Parent;
                    //String ParentName;
                    
               /* String idCampo =[SELECT Id, FieldId__c FROM CS002_FIeldsIds__c WHERE FieldApiName__c='AccountName_AR__c' AND ObjectApiName__c='SRV_Survey_ARG__c'].FieldId__c;
                    idCampo = 'CF'+idCampo;
                    String idAcc = '&'+idCampo+'_lkid=';
                    String urlReturn = prefixObj+'/e?RecordType='+Rt.id+'&nooverride=1&ent=Account&retURL=%2F'+idAccount+'&'+idCampo+'
                    ='+EncodingUtil.urlEncode(accName, 'UTF-8')+idAcc+EncodingUtil.urlEncode(accId, 'UTF-8') ;*/
                                        
                    //MEJORAS EN CLONAR CLIENTE 18-6-2019
                    /*listo---accClone.Parentid = null;
                    accClone. = null;   00ND0000005SKlF
                    accClone. = null;    acc5
                    listo---accClone.CNPJ__c = null;
                    accClone. = false;    00ND0000005ossn
                    accClone.Client_country_AN8__c = null;    00ND0000005SKl8
                    */

                    
                    /*
                    SE PIDE SACAR

                    if ( acc.ParentId == null){
                        Parent = acc.id;
                        ParentName = acc.Name;
                    }else{
                        Parent = acc.ParentId;
                        Account accPAdre = [SELECT Id, Name FROM Account WHERE id =: Parent] ;
                        ParentName = accPAdre.Name;
                    }
                    
                    system.debug('asdtestNAME'+ParentName);

                    String urlReturn = '/'+accId+'/e?clone=1&'+idCampo_01+'=+'+'&'+idCampo_02+'=+'+'&'+idCampo_03+'=+'+'&'+idCampo_04+'=Novo Cadastro'+'&'+idCampo_05+'='+Parent+'&'+idCampo_06+'='+ParentName+'&'+idCampo_07+'='+val+'&'+idCampo_08+'='+''+'&'+idCampo_09+'='+'';
                    */
                                   
                    
                    //{!Account.Id}/e?clone=1&acc3={!Account.Name}
                    // LINEA QUE FUNCIONA   String urlReturn = prefixObj+'/e?RecordType='+Rt.id+'&nooverride=1&ent=Account&retURL=%2F'+idAccount;
        
                    return urlReturn;
             }catch(Exception e){return '';}
     }
}