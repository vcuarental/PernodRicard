/*******************************************************************************
*                           Company: ValueNet
*-------------------------------------------------------------------------------
*   Clase que contiene los triggers PRM del objeto Attachment
*******************************************************************************/

public with sharing class LAT_MX_AP01_Attachment {
       
    /*****************************************************************************************
    * Nombre del metodo: UpdatesFieldMissingInformation
    * Descripcion: Metodo que actualiza el campo Missing Information segun los documentos que 
    *              se adjuntaron al Account chequeando cuales faltan en el Custom Setting 
    *              LAT_MX_CS001_AccountDocuments
    * Desarrollador: Elena J. Schwarzböck
    * Fecha: 24/09/2013
    * Modo: before insert, before update
    *****************************************************************************************/
    
    public static void UpdatesFieldMissingInformation (list<Attachment> triggerNewOrOLD, String tipoTrigger){
        
        set<Id> setParentId = new set<Id>();
        set<Id> setIdAttachs = new set<Id>();
        map<Id, Attachment> mapAccountIdAttach = new map<Id, Attachment>();
        
        for(Attachment attach: triggerNewOrOLD){
            setParentId.add(attach.ParentId);
            setIdAttachs.add(attach.id);
            if( tipoTrigger == 'insert' || tipoTrigger == 'update'){
                mapAccountIdAttach.put(attach.ParentId, attach);
            }
        }
        
        set<Id> setRtIds = Global_RecordTypeCache.getRtIdSet('Account',new set<String>{'LAT_MX_ACC_OffTrade','LAT_MX_ACC_OnTrade'});                
        list<Account> listAccounts = [SELECT Id, RecordTypeId FROM Account WHERE Id IN: setParentId AND RecordTypeId IN: setRtIds];                
        set<Id> setAccountId = new set<Id>();
        
        for(Account acc: listAccounts){
            setAccountId.add(acc.id);
        }
        
        list<Account> listAccountAttach = [SELECT Id, Channel__c, LAT_MX_MissingDocuments__c, Type, LAT_MX_FiscalEntityType__c, (SELECT Id, Name FROM Attachments WHERE Id NOT IN: setIdAttachs) FROM Account WHERE Id IN: setAccountId];
        list<LAT_MX_CS001_AccountDocuments__c> listAccountDocs = LAT_MX_CS001_AccountDocuments__c.getAll().values();       
        set<String> setChannels = new set<String>();
        
        for(LAT_MX_CS001_AccountDocuments__c accDoc: listAccountDocs){
            setChannels.add(accDoc.LAT_MX_RequiredForChannel__c);
        }
        List<Account> listAccountToUpdate = new List<Account>();        
        Set<String> setAttachName = new Set<String>();
        for(Account acc: listAccountAttach){
            list<String> listMissingDocs = new list<String>();      
            System.debug('%%%% setChannels : '+ setChannels);
            System.debug('%%%% acc.Channel__c : '+ acc.Channel__c);
            String MissingDocs = '';       
            if(setChannels.contains(acc.Channel__c)){
                for(Attachment attach: acc.Attachments){
                   if(attach.Name.length() >= 7){
                        setAttachName.add(attach.Name.substring(0, 7).toUpperCase());
                    }
                }
                if(mapAccountIdAttach.containsKey(acc.id)){
                    String docName = mapAccountIdAttach.get(acc.id).Name.toUpperCase();
                    if(docName.length() >= 7){
                        docName = docName.substring(0, 7);
                        setAttachName.add(docName);
                    }
                }
                String MissingDoc;
                for(LAT_MX_CS001_AccountDocuments__c accDoc: listAccountDocs){
                    System.debug('%%%% accDoc.LAT_MX_RequiredForFiscalEntityType__c : '+ accDoc.LAT_MX_RequiredForFiscalEntityType__c);
                    System.debug('%%%% acc.LAT_MX_FiscalEntityType__c : '+ acc.LAT_MX_FiscalEntityType__c);
                    System.debug('%%%% accDoc.LAT_MX_RequiredForFiscalEntityType__c == acc.LAT_MX_FiscalEntityType__c : '+ accDoc.LAT_MX_RequiredForFiscalEntityType__c == acc.LAT_MX_FiscalEntityType__c);
   
                    if(accDoc.LAT_MX_RequiredForChannel__c == acc.Channel__c
                        && accDoc.LAT_MX_RequiredForType__c == acc.Type
                        && accDoc.LAT_MX_RequiredForFiscalEntityType__c == acc.LAT_MX_FiscalEntityType__c
                        ){
                        if(!(setAttachName.contains(accDoc.Name.substring(0, 7).toUpperCase()))){
                            MissingDoc = accDoc.LAT_MX_TextToShow__c + ' (' + accDoc.Name.substring(0, 7) + ')';
                            listMissingDocs.add(MissingDoc);
                        }
                    }
                }
                
            }
            if(!listMissingDocs.isEmpty()){
                listMissingDocs.sort();
                for(String doc: listMissingDocs){
                    if(MissingDocs == ''){
                        MissingDocs = '- ' + doc;
                    } else {
                        MissingDocs = MissingDocs + '\n' + '- ' + doc;
                    }
                }
            }
            acc.LAT_MX_MissingDocuments__c = MissingDocs;
            listAccountToUpdate.add(acc);
        }

        /*
        for(LAT_MX_CS001_AccountDocuments__c accDoc: listAccountDocs){
            mapCS.put(accDoc.Name,accDoc);
            list<String> parts = new list<String>();
            parts = accDoc.LAT_MX_RequiredForChannel__c.split('","');
            for(Integer i = 0;i < parts.size(); i++){
                if( i== 0){
                    parts[i] = parts[i].substring(1,parts[i].length());
                }
                if(i == parts.size()-1){
                    parts[i] = parts[i].substring(0,parts[i].length()-1);
                }
                setChannels.add(parts[i]);
            }
        }
                
        list<Account> listAccountToUpdate = new list<Account>();        
        set<String> setAttachName = new set<String>();               
                          
        for(Account acc: listAccountAttach){
            list<String> listMissingDocs = new list<String>();      
            String MissingDocs = '';       
            if(setChannels.contains(acc.Channel__c)){
                for(Attachment attach: acc.Attachments){
                   if(attach.Name.length() >= 7){
                        setAttachName.add(attach.Name.substring(0, 7).toUpperCase());
                    }
                }
                if(mapAccountIdAttach.containsKey(acc.id)){
                    String docName = mapAccountIdAttach.get(acc.id).Name.toUpperCase();
                    if(docName.length() >= 7){
                        docName = docName.substring(0, 7);
                        setAttachName.add(docName);
                    }
                }
                String MissingDoc;
                for(String nombre: mapCS.keyset()){
                    System.debug('%%%% mapCS.get(nombre).LAT_MX_RequiredForFiscalEntityType__c : '+ mapCS.get(nombre).LAT_MX_RequiredForFiscalEntityType__c);
                    System.debug('%%%% acc.LAT_MX_FiscalEntityType__c : '+ acc.LAT_MX_FiscalEntityType__c);
                    System.debug('%%%% mapCS.get(nombre).LAT_MX_RequiredForFiscalEntityType__c.contains(acc.LAT_MX_FiscalEntityType__c) : '+ mapCS.get(nombre).LAT_MX_RequiredForFiscalEntityType__c.contains(acc.LAT_MX_FiscalEntityType__c));
                    if(mapCS.get(nombre).LAT_MX_RequiredForChannel__c.contains(acc.Channel__c)
                        && mapCS.get(nombre).LAT_MX_RequiredForType__c != null
                        && mapCS.get(nombre).LAT_MX_RequiredForType__c.contains(acc.Type)
                        && mapCS.get(nombre).LAT_MX_RequiredForFiscalEntityType__c.contains(acc.LAT_MX_FiscalEntityType__c)){
                        if(!(setAttachName.contains(nombre.toUpperCase()))){
                            MissingDoc = mapCS.get(nombre).LAT_MX_TextToShow__c + ' (' + nombre + ')';
                            listMissingDocs.add(MissingDoc);
                        }
                    }
                }
            }
            if(!listMissingDocs.isEmpty()){
                listMissingDocs.sort();
                for(String doc: listMissingDocs){
                    if(MissingDocs == ''){
                        MissingDocs = '- ' + doc;
                    } else {
                        MissingDocs = MissingDocs + '\n' + '- ' + doc;
                    }
                }
            }
            acc.LAT_MX_MissingDocuments__c = MissingDocs;
            listAccountToUpdate.add(acc);
        }
        */
        update listAccountToUpdate;
    }
   
}