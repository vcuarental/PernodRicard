/*******************************************************************************
*                           Company: Zimmic
*-------------------------------------------------------------------------------
*   Clase que contiene los triggers del objeto LAT_CotaMarket__c
*******************************************************************************/

public with sharing class LAT_DetalheCota {

    public static void validateDetalhe(List<LAT_DetalheCotaMarket__c> triggerNew){
        List<String> cotasIds = new List<String>();
        Map<Id,LAT_CotaMarket__c> cotasMap = new Map<Id,LAT_CotaMarket__c>();

        for(LAT_DetalheCotaMarket__c detalhe : triggerNew){
            cotasIds.add(detalhe.cotaMarket__c);
        }

        cotasMap = new Map<ID, LAT_CotaMarket__c>([Select id, (SELECT cliente__c,bandeira__c,consumo__c,cota__c,endDate__c,startDate__c,executivo__c,prioridad__c,regional__c,segmento__c,sub_canal__c FROM Detalhes_Cota__r) from LAT_CotaMarket__c where id in:cotasIds]);

        for(LAT_DetalheCotaMarket__c detalhe : triggerNew){
            for(LAT_DetalheCotaMarket__c co : cotasMap.get(detalhe.cotaMarket__c).Detalhes_Cota__r){
                if(detalhe.id != co.id && 
                    detalhe.cliente__c == co.cliente__c &&
                    detalhe.executivo__c == co.executivo__c &&
                    detalhe.bandeira__c == co.bandeira__c && 
                    detalhe.Regional__c == co.Regional__c &&
                    detalhe.sub_canal__c == co.sub_canal__c  &&
                    detalhe.segmento__c == co.segmento__c &&
                (co.startDate__c >= detalhe.startDate__c && co.startDate__c <= detalhe.endDate__c ||
                 co.endDate__c >= detalhe.startDate__c && co.endDate__c <= detalhe.endDate__c ||
                 co.startDate__c < detalhe.startDate__c && co.endDate__c > detalhe.endDate__c)){
                  
                  detalhe.addError(Label.LAT_COTA_00008);
                  return;
                }
            }
        }

    }


    public static void updateDetalhe(List<LAT_DetalheCotaMarket__c> triggerNew){
        List<String> detalheIds = new List<String>();
        Map<String,Account> clienteMap = new Map<String,Account>();
        
        for(LAT_DetalheCotaMarket__c detalhe : triggerNew){
            if(detalhe.cliente__c != null){
                detalheIds.add(detalhe.cliente__c);
            }
        }
        for(Account acc : [Select id,Customer_Flag__c, Sub_Channel_Rating__c ,Sub_Channel__c,Regional__c,ownerId from Account where id in: detalheIds]){
            clienteMap.put(acc.id, acc);
        }
        
        
        for(LAT_DetalheCotaMarket__c detalhe : triggerNew){
            if(detalhe.cliente__c != null){
                detalhe.prioridad__c = 0;
            }else{
                integer prioridad = 0;
                if(detalhe.segmento__c != null)prioridad += 1;
                if(detalhe.sub_canal__c != null)prioridad += 2;
                if(detalhe.regional__c != null)prioridad += 4;
                if(detalhe.bandeira__c != null)prioridad += 8;
                if(detalhe.executivo__c != null)prioridad += 16;
                detalhe.prioridad__c = 32 - prioridad;
            }
            
        }
    }

    // Sends Email when a cota is Consumed and it turns negative
    public static void negativeConsumptionNotification(List<LAT_DetalheCotaMarket__c> detalhes, Map<id, LAT_DetalheCotaMarket__c> oldDetalhes) {
        List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
        List<String> userOrGroupIds = new List<String>();
        List<String> toAddresses = new List<String>();

        for(GroupMember u : [Select UserOrGroupid From GroupMember Where Group.name = 'LAT_BR_COTA_ALERT']){
            userOrGroupIds.add(u.UserOrGroupid);
        }
        for(User u : [Select Id, email From User Where Id In :userOrGroupIds]){
            toAddresses.add(u.email);
        }

        for(LAT_DetalheCotaMarket__c detalhe : detalhes){
            Double Remaining = detalhe.cota__c - detalhe.consumo__c;
            Double OldRemaining = oldDetalhes.get(detalhe.id).cota__c - oldDetalhes.get(detalhe.id).consumo__c;
            if (Remaining < 0 && OldRemaining >= 0) {
                emailList.add(LAT_DetalheCota.getEmailMesasge(Label.LAT_COTA_00009, detalhe, toAddresses));
            }
            if (Math.abs(Remaining) > detalhe.cota__c * 2
                && Math.abs(OldRemaining) <= detalhe.cota__c * 2) {
                emailList.add(LAT_DetalheCota.getEmailMesasge(Label.LAT_COTA_00010, detalhe, toAddresses));
            }
        }

        // Send the email you have created.
        if (!emailList.isEmpty()) {
            Messaging.sendEmail(emailList);
        }
    }

    private static Messaging.SingleEmailMessage getEmailMesasge(String subject, LAT_DetalheCotaMarket__c detalhe, List<String> toAddresses) {
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(toAddresses);
        mail.setSubject(subject);
        mail.setPlainTextBody('');
        mail.setHtmlBody('');
        mail.setSenderDisplayName('Salesforce');
        
        mail.setPlainTextBody(mail.getPlainTextBody() + 
         'Nome: ' + detalhe.name + '\n' +
         'Cota Consumida: ' + (detalhe.cota__c - detalhe.consumo__c)+ '\n' 
         );

        String idString = detalhe.id + ''.toUpperCase();
        String idCotaString = detalhe.cotaMarket__c + ''.toUpperCase();

        mail.setHTMLBody(mail.getHTMLBody() +
            'Nome: <a href="'+ URL.getSalesforceBaseUrl().toExternalForm() + 
                   '/' + idString +'">' + detalhe.name + '</a><br />' +
            'Cota Consumida: ' + (detalhe.cota__c - detalhe.consumo__c) +'<br />'
        );

        return mail;
    }
}