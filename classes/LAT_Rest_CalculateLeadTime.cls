@RestResource(urlMapping='/LAT_Rest_CalculateLeadTime/*')
global with sharing class LAT_Rest_CalculateLeadTime {
    
    public static Set<Date> holydays;

    @HttpPost
    global static void processPost() {

        RestRequest req = RestContext.request;
        LAT_OpportunityHandlerJSON pedido = (LAT_OpportunityHandlerJSON)System.JSON.deserialize(req.requestBody.toString(), LAT_OpportunityHandlerJSON.class);
        System.debug('Pedido : ' + pedido);
        System.debug('Pedido.account : ' + pedido.header.account);
        
        LAT_Rest_OpportunityFlex.ServiceResponse res = calculateLeadTime(pedido);
        RestContext.response.addHeader('Content-Type', 'application/json');
        RestContext.response.responseBody   = Blob.valueOf(JSON.serialize(res));
        if (res.success) {
            RestContext.response.statusCode     = 200;
        } else {
            RestContext.response.statusCode     = 400;
        }
    }

    public static LAT_Rest_OpportunityFlex.ServiceResponse calculateLeadTime(LAT_OpportunityHandlerJSON pedido) {
        List<Account> accs = [SELECT Id, Revenue_UF__c, Business_Unit__c, Revenue_City__c, Yes_No__c  FROM Account WHERE Id =:pedido.header.account];
        Account acc;
        if(accs.size() > 0) acc = accs[0];
        System.debug('%%% Account encontrada: '  + acc);
        Date fechaFacturamento;
        Date fechaEntregaCalculada;
        if(acc!= null){
            Decimal totalWeight = 0;
            Set<Id> prods = new Set<Id>();
            for(LAT_OpportunityHandlerJSON.Detail line : pedido.detail){
                prods.add(line.product);
            }
            Map<Id, LAT_Product__c> mapProds = new Map<Id, LAT_Product__c>([SELECT Id, LAT_UnitWeight__c FROM LAT_Product__c WHERE Id IN :prods]);
            for(LAT_OpportunityHandlerJSON.Detail line : pedido.detail){
                totalWeight += line.quantity * mapProds.get(line.product).LAT_UnitWeight__c;
            }
            LAT_LeadTime__c lt = getLeadTimeForAccount(acc);
            if(lt != null){
                fechaFacturamento = acc.Yes_No__c ? getCalculatedDate(Date.valueOf(pedido.header.closeDate) , 3) : getCalculatedDate(Date.valueOf(pedido.header.closeDate) , 2);
                fechaEntregaCalculada = totalWeight >= Decimal.valueOf(LAT_GeneralConfig__c.getInstance('LAT_BR_LeadTimeCompletationWeight').LAT_Value__c) ? getCalculatedDate(fechaFacturamento , lt.LAT_Complete__c) : getCalculatedDate(fechaFacturamento , lt.LAT_Partial__c);
                return new LAT_Rest_OpportunityFlex.ServiceResponse('Data do faturamento prevista : '+fechaFacturamento.format() + ', Data do entrega prevista : '+fechaEntregaCalculada.format(), true);
            } else {
                return new LAT_Rest_OpportunityFlex.ServiceResponse('Cadastro de configuração não encontrado.', false);
            }
        } else {
            return new LAT_Rest_OpportunityFlex.ServiceResponse('Cliente não encontrado.', false);
        }
    }

    public static LAT_LeadTime__c getLeadTimeForAccount(Account acc){
        List<LAT_LeadTime__c> retorno = [SELECT Id, LAT_Complete__c, LAT_Partial__c FROM LAT_LeadTime__c WHERE (LAT_City__c = null OR LAT_City__c =:acc.Revenue_City__c) AND LAT_BusinessUnit__c= :acc.Business_Unit__c AND LAT_UF__c = :acc.Revenue_UF__c ORDER BY LAT_City__c NULLS LAST];
        if(retorno.size() > 0) {
            System.debug('%%%% retorno[0] : ' + retorno[0]);
            return retorno[0];
        } else {
            return null;
        }
    }

    public static Date getCalculatedDate(Date fechaInicio, Decimal diasHabilesASumar){
        Integer diasAsumar = (Integer)diasHabilesASumar;
        Date finalDate = fechaInicio;
         
        system.debug('%%% finaldate = '+finalDate);
        while(diasAsumar != 0) {
            finalDate = finalDate.AddDays(1);
            system.debug('diasAsumar = '+diasAsumar);            
            system.debug('finaldate = '+finalDate);
            if (isWorkingDay(finalDate)){
                diasAsumar -= 1;   
            }
        }

        return finalDate;
        
    }

    public static Boolean isWorkingDay(Date dateParam){
        if(holydays == null ) setHolydays();
        boolean result     = true;
        System.debug('dateParam = '+dateParam); 
        //Recover the day of the week
        Date startOfWeek   = dateParam.toStartOfWeek();
        system.debug('startOfWeek = '+startOfWeek);
        Integer dayOfWeek  = dateParam.day() - startOfWeek.day();
        system.debug('dayOfWeek = '+dayOfWeek);   
        result = dayOfWeek != 0 && dayOfWeek != 6 ? true : false;
        system.debug('result = '+result); 
        if(result){
            result = !holydays.contains(dateParam);
        }
        return result;
   } 

   public static void setHolydays(){
       holydays = new Set<Date>();
       List<LAT_Holiday__c> hds = [SELECT LAT_Date__c FROM LAT_Holiday__c WHERE LAT_Date__c > TODAY];
       for(LAT_Holiday__c h: hds){
           holydays.add(h.LAT_Date__c);
       }
   }
}