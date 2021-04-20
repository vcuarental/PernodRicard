public with sharing class LAT_VFC08_UploadRegionalPOP {
    public Blob toParse {get; set;}
    public String[] mailsSupervisores {get;set;}

    public LAT_VFC08_UploadRegionalPOP() {
        mailsSupervisores = new List<String>();
    }


    public void upload() {
        try{
            
            List<List<String>> values = parseCSV(toParse.toString(), true);
            List<LAT_RegionalPOP__c> toUpsert = new List<LAT_RegionalPOP__c>();
            Map<String,LAT_Produto_POP__c> productos = new Map<String,LAT_Produto_POP__c>();
            Map<String,LAT_Produto_POP__c> newProductos = new Map<String,LAT_Produto_POP__c>();
            system.debug(values);
            if(values.size() <= 0){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'O arquivo não contém dados'));
            }
            else{
                List<String> regionales = new List<String>();
                List<String> skus = new LISt<String>();
                List<String>cantidades = new List<String>();            
                List<String>skuRegs = new List<String>();


                for (List<String> valList: values) {
                    if(valList.size() >= 4){
                        skus.add(valList[0]);
                        regionales.add(valList[3]);
                        cantidades.add(valList[2]);

                        LAT_Produto_POP__c tmpProd = new LAT_Produto_POP__c(sku__c = valList[0], name = valList[1]);
                        productos.put(valList[0], tmpProd);
                        newProductos.put(valList[0], tmpProd);
                        skuRegs.add(valList[0] + '-' + valList[3]);
                    }
                }
                Map<String, LAT_RegionalSupervisor__c> supervisores = new Map<String, LAT_RegionalSupervisor__c>();
                for(LAT_RegionalSupervisor__c regSup : [Select id,Supervisor__c,name,Supervisor__r.email from LAT_RegionalSupervisor__c where name in: regionales]){
                    supervisores.put(regSup.name, regSup);
                }
                for(LAT_Produto_POP__c regProd : [Select id,Sku__c from LAT_Produto_POP__c where sku__c in: skus]){
                    productos.get(regProd.sku__c).id = regProd.id;
                    newProductos.remove(regProd.sku__c);
                }

                upsert productos.values();

                if(newProductos.values().size() > 0)notifyNewProducts(newProductos.values());


                if((regionales.size() == skus.size()) && (regionales.size() == cantidades.size()) && (regionales.size()>0)){     
                    List<LAT_RegionalPOP__c> listRG =[SELECT id,Amount__c,SKURegional__c from LAT_RegionalPOP__C where SKURegional__c in:skuRegs];
                    Map<String,LAT_RegionalPOP__c> setRG = new Map<String,LAT_RegionalPOP__c>();
                    for(LAT_RegionalPOP__C rg : listRG){
                        setRG.put(rg.SKURegional__c,rg);
                    }
                    for(Integer pos = 0; pos < skus.size(); pos++){
                        String skuReg = (skus[pos] + '-' + regionales[pos]);
                        LAT_RegionalPOP__c reg;
                        if(setRG.get(skuReg) == null){
                            if(supervisores.get(regionales[pos]) != null){
                                reg = new LAT_RegionalPOP__c();
                                reg.product__c = productos.get(skus[pos]).id;
                                reg.Amount__c = Integer.valueOF(cantidades[pos]);
                                reg.SubRegional__c = regionales[pos];
                                reg.Regional_supervisor_POP__c = supervisores.get(reg.SubRegional__c).id;
                                reg.ownerId = supervisores.get(reg.SubRegional__c).Supervisor__c;
                                String mail = supervisores.get(reg.SubRegional__c).Supervisor__r.email;
                                mailsSupervisores.add(mail);
                                toUpsert.add(reg);
                            }
                        }else{
                            reg = setRG.get(skuReg);
                            reg.Amount__c += Integer.ValueOf(cantidades[pos]);
                            toUpsert.add(reg);
                        }
                    } 

                    if(toUpsert.size() != skus.size()){
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Carga con error. Registros con error:  ' + (skus.size()-toUpsert.size())));          
                    }else{
                        upsert toUpsert;   
                        String theId = LAT_RegionalPOP__c.sObjectType.getDescribe().getKeyPrefix();
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, 'Carga realizada com sucesso. Foram criados/atualizados ' + toUpsert.size() +' registros.' + '  <a href="/'+ theId.substring(0,3) +'">' + 'Distribuição Material POP' + '</a>'));          
                
                    }
                }else{
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Campos vacios en algun Regional Pop'));
                }    
            }       
        }catch(exception e){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage()));
        }
   
    }

    public static void notifyNewProducts(List<LAT_Produto_POP__c> prods){
        String productsText = Label.LAT_Processes_009 +  '</br></br>';

        for(LAT_Produto_POP__c pr: prods){
            productsText += pr.sku__c + ' - ' + pr.name + '</br>';
        }
        productsText += '</br></br>' + Label.LAT_Processes_010.replace('</br>','</br>');

        LAT_ProcessesEmails.emailMsg tmp = new LAT_ProcessesEmails.emailMsg(new List<String>{UserInfo.getUserId()},'Novos Materiais POP - Atualização Cadastro', productsText);
        LAT_ProcessesEmails.sendEmail(new List<LAT_ProcessesEmails.emailMsg>{tmp});
    }


    public static List<List<String>> parseCSV(String contents,Boolean skipHeaders) {
        List <List <String>> allFields = new List<List<String>>();
 
        System.debug('111111111111111' + contents);
        contents = contents.replaceAll(',"""',',"DBLQT').replaceall('""",','DBLQT",');

        System.debug('22222222222222222' + contents);
        contents = contents.replaceAll('""','DBLQT');

        System.debug('33333333333333333' + contents);
        List <String> lines = new List<String>();
        try {
            lines = contents.split('\n');

        System.debug('444444444444444444' + lines + lines.size());
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

    public void sendMailSuper(){
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        message.setsubject('POP Event');
        message.sethtmlBody('Got a new POP event');
        message.setToAddresses(mailsSupervisores);
       // Messaging.sendEmail(new Messaging.SingleEmailMessage[] { message });
    
      }
}