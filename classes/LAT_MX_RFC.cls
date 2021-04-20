public with sharing class LAT_MX_RFC {
    

    public static void createUpdateRFC(List<LAT_RFC__c> records){
        List<String> tmpIds = new List<String>();
        Set<String> accs = new Set<String>();

        for(LAT_RFC__c rfc : records){
            if(rfc.status__c == 'Eliminado')tmpIds.add(rfc.rfc__c);
        }

        for(Account acc : [Select id,CNPJ__c from Account where CNPJ__c in: tmpIds]){
            accs.add(acc.CNPJ__c);
        }


        for(LAT_RFC__c rfc : records){
            if(accs.contains(rfc.rfc__c)){
                rfc.rfc__c.addError('La excepción de RFC es utilizada en un cliente');
            }
        }
    }
}