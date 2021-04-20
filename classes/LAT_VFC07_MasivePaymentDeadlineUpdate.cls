public with sharing class LAT_VFC07_MasivePaymentDeadlineUpdate {
    public LAT_VFC07_MasivePaymentDeadlineUpdate() {
        country = countryCodes.get(UserInfo.getDefaultCurrency());
    }

    public Blob toParse {get; set;}
    public String country {get;set;}
    public Map<String,String> countryCodes = new Map<String,String>{'ARS'=>'6','UYU'=>'5','MXN'=>'12','BRL'=>'1'};

    public void upload() {
        try{
            String[] approverIds = LAT_GeneralConfigDao.getValueAsStringArray('ACCOUNT_PD_UPDATE', ';');
            Map<String, String> approverMaps = new Map<String, String>();
            for (String s: approverIds) {
                String[] countryApp = s.split(':');
                if (countryApp != null && countryApp.size() > 1) {
                    approverMaps.put(countryCodes.get(countryApp[0]), countryApp[1]);
                }
            }

            List<List<String>> values = parseCSV(toParse.toString(), true);
            system.debug('############################### ' + values);
            if(values.size() <= 0){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.LAT_VFP06_Message02));
            }
            List<String> accIds = new List<String>();
            List<String> countryAn8 = new List<String>();
            Map<String,String> newValues = new Map<String,String>();

            String filterKey = country + '-%%-CRM-PT';
            List<UDC__c> paymnentConditions = [SELECT id, internal_id__c, CodDefUsuario__c, CodProd__c, 
                                                    CodUs__c, Descricao2__c FROM UDC__c WHERE internal_id__c LIKE: filterKey ];
            Map<String, UDC__c> internalIds = new Map<String, UDC__c>();
            for (UDC__c udc: paymnentConditions) {
                internalIds.put(udc.Internal_Id__c, udc);
            }

            for (List<String> valList: values) {

                if (valList.size() >= 2) {
                    if (valList[0].startsWith('001') && 
                            (valList[0].length() == 15 
                            || valList[0].length() == 18)) {
                        accIds.add(valList[0].substring(0,15));
                        if (valList[1].length() == 15 
                            || valList[1].length() == 18) {
                            newValues.put(valList[0].substring(0,15), valList[1]);
                        } else if (internalIds.get(country+'-'+valList[1]+'-CRM-PT') != null){
                            newValues.put(valList[0].substring(0,15), internalIds.get(country+'-'+valList[1]+'-CRM-PT').Id);
                        }
                    } else {
                        countryAn8.add(country + '-' + valList[0]);
                        if (valList[1].length() == 15 
                            || valList[1].length() == 18) {
                            newValues.put(country + '-' + valList[0], valList[1]);
                        } else if (internalIds.get(country+'-'+valList[1]+'-CRM-PT') != null){
                            newValues.put(country + '-' + valList[0], internalIds.get(country+'-'+valList[1]+'-CRM-PT').Id);
                        }
                    }
                }   
            }
            system.debug('############################### ' + countryAn8);
            LAT_MasivePaymentDeadlineHeader__c header;
            List<Account> tmpAccs = [SELECT Id, Client_country_AN8__c, Client_code_AN8__c, Payment_Condition__c FROM Account
                                                             WHERE Client_country_AN8__c in: countryAn8 
                                                            OR Id IN :accIds];
            if(tmpAccs != null && tmpAccs.size() > 0){
                header = new LAT_MasivePaymentDeadlineHeader__c();
                header.LAT_Status__c = 'New';
                header.LAT_Approver__c = approverMaps.get(country) != null ? approverMaps.get(country) : UserInfo.getUserId();
                insert header;

                List<LAT_MasivePaymentDeadlineLine__c> lines = new List<LAT_MasivePaymentDeadlineLine__c>();
                for(Account acc : tmpAccs){

                    LAT_MasivePaymentDeadlineLine__c line = new LAT_MasivePaymentDeadlineLine__c();
                    line.LAT_Account__c = acc.id;
                    line.LAT_OldValue__c = acc.Payment_Condition__c;
                    line.LAT_Header__c = header.id;
                    
                    if (acc.Client_code_AN8__c != null) {

                        line.LAT_AccountAN8__c = acc.client_country_an8__c;
                        if (newValues.containsKey(acc.Client_country_AN8__c)) {
                            line.LAT_NewValue__c = newValues.get(acc.Client_country_AN8__c).trim(); 
                        } else {
                            String accId = String.valueOf(acc.Id).substring(0,15);
                            line.LAT_NewValue__c = newValues.get(accId).trim(); 
                        }
                    } else {
                        line.LAT_AccountAN8__c = 'Not exists';
                        String accId = String.valueOf(acc.Id).substring(0,15);
                        line.LAT_NewValue__c = newValues.get(accId).trim();  
                    }
                    lines.add(line);
                }
                insert(lines);
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, Label.LAT_VFP06_Message04 + '<a href="/'+ header.id +'">' + header.id + '</a>'));

            }else{
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.LAT_VFP06_Message03)); 
            }
        
        }catch(exception e){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage()));
        }

    }


    public static List <List <String>> parseCSV(String contents,Boolean skipHeaders) {
        List <List <String>> allFields = new List<List<String>>();
 
        System.debug('111111111111111' + contents);
        contents = contents.replaceAll(',"""',',"DBLQT').replaceall('""",','DBLQT",');

        System.debug('22222222222222222' + contents);
        contents = contents.replaceAll('""','DBLQT');

        System.debug('33333333333333333' + contents);
        List <String> lines = new List<String>();
        try {
            lines = contents.split('\n');

        System.debug('444444444444444444' + lines);
        } catch (System.ListException e) {
            System.debug('Limits exceeded?' + e.getMessage());
        }
        Integer num = 0;
        for(String line : lines) {
            // check for blank CSV lines (only commas)
            if (line.replaceAll(',','').trim().length() == 0) break;
            if (line.replaceAll(';','').trim().length() == 0) break;
            
            system.debug('ˆˆˆˆˆˆˆˆˆˆˆˆ fields a: ' + line);
            List <String> fields = line.split(',');
            system.debug('ˆˆˆˆˆˆˆˆˆˆˆˆ fields b: ' + fields);
            if (fields.size() == 1) {
                fields = line.split(';');   
            }
            
            system.debug('ˆˆˆˆˆˆˆˆˆˆˆˆ fields c: ' + fields);
            List <String> cleanFields = new List<String>();
            String compositeField;
            Boolean makeCompositeField = false;
            for(String field : fields) {
                if (field.startsWith('"') && field.endsWith('"')) {
                    cleanFields.add(field.replaceAll('DBLQT','"'));
                    System.debug('$$$$$$$$$$$$$$$$$$ in 1' + field);
                } else if (field.startsWith('"')) {
                      makeCompositeField = true;
                      compositeField = field;
                      System.debug('$$$$$$$$$$$$$$$$$$ in 2' + field);
                } else if (field.endsWith('"')) {
                      compositeField += ',' + field;
                      cleanFields.add(compositeField.replaceAll('DBLQT','"'));
                      makeCompositeField = false;
                      System.debug('$$$$$$$$$$$$$$$$$$ in 3' + field);
                } else if (makeCompositeField) {
                      compositeField +=  ',' + field;
                      System.debug('$$$$$$$$$$$$$$$$$$ in 4' + field);
                } else {
                      cleanFields.add(field.trim());
                      System.debug('$$$$$$$$$$$$$$$$$$ in 5' + field);
                }
            }
            
            allFields.add(cleanFields);
        }
        if (skipHeaders) allFields.remove(0);
        return allFields;       
    }
        
}