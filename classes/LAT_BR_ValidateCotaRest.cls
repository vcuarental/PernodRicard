@RestResource(urlMapping='/LAT_BR_ValidateCotaRest/*')

global with sharing class LAT_BR_ValidateCotaRest {
    
    global class LineaPedido {
        global String Product;
        global Integer Quantity;
    }

    @HttpPost
    global static void post(List<LineaPedido> lineas, Date closeDate, String idCliente) {
        System.debug('%%%%% lineas : '+lineas);
        System.debug('%%%%% closeDate : '+closeDate);
        System.debug('%%%%% idCliente : '+idCliente);
        

        String resultado = validateCota(closeDate, lineas, idCliente, UserInfo.getUserId());
        
        Boolean success = (resultado == 'OK');
        RestContext.response.addHeader('Content-Type', 'application/json');
        RestContext.response.responseBody = Blob.valueOf('{ "success": "'+success+'", "message": "'+resultado+'"  }');
    }

    public static string validateCota(Date closeDate, List<LineaPedido> lineas, String idCliente, String idUsuario) {
            Account acc = [SELECT Id, Customer_Flag__c, Regional__c, Sub_Channel__c, Sub_Channel_Rating__c FROM Account WHERE Id = :idCliente]; 
            List<String> idsProductos = new List<String>();
            Map<String,Lat_cotaMarket__c> cotasMap = new Map<String,Lat_cotaMarket__c>();
            for (LineaPedido l : lineas) {
                idsProductos.add(l.Product);
            }
            for (Lat_cotaMarket__c cota : getCotasToConsume(closeDate, idsProductos)) {
                cotasMap.put(cota.LAT_Product__c, cota);
            }
            Map<Id, LAT_Product__c> mapProds = new Map<Id, LAT_Product__c>([SELECT Id, Name FROM LAT_Product__c WHERE id IN :idsProductos]);
            String returnMessage = Label.LAT_COTA_00011;
            Boolean isFirst = true;
            
            for(LineaPedido li : lineas){
                Boolean productHasNoCota = false;
                Boolean quantityIsUnderQuota = false;
                if(cotasMap.get(li.Product) != null){

                    for (LAT_DetalheCotaMarket__c detalhe : cotasMap.get(li.Product).Detalhes_Cota__r) {
                        if (productHasNoCota) continue;
                        
                        if (detalhe.cliente__c == idCliente) {
                            if(detalhe.consumo__c + li.Quantity > detalhe.cota__c){
                                    if(!isFirst) {
                                        returnMessage = returnMessage + ',';
                                    } 
                                    returnMessage = returnMessage +' '+  mapProds.get(li.Product).Name + ' (Disponivel: '+ (detalhe.cota__c - detalhe.consumo__c)+ ')';
                                    isFirst = false;
                                    productHasNoCota = true;
                                    
                            } else {
                                quantityIsUnderQuota = true;
                            }
                        } else if (detalhe.cliente__c == null) {
                            if((detalhe.executivo__c == null || detalhe.executivo__c == idUsuario) && (detalhe.bandeira__c == null || (detalhe.bandeira__c == acc.Customer_Flag__c && acc.Customer_Flag__c != null)) && (detalhe.Regional__c == null || (detalhe.Regional__c == acc.Regional__c && acc.Regional__c != null)) && (detalhe.sub_canal__c == null || (detalhe.sub_canal__c == acc.Sub_Channel__c && acc.Sub_Channel__c != null)) && (detalhe.segmento__c == null || (detalhe.segmento__c == acc.Sub_Channel_Rating__c && acc.Sub_Channel_Rating__c != null))) {
                                    if((detalhe.consumo__c + li.Quantity) > detalhe.cota__c){
                                        if (!returnMessage.contains(mapProds.get(li.Product).Name)) {
                                            if(!isFirst) {
                                                returnMessage = returnMessage + ',';
                                            } 
                                            returnMessage = returnMessage +' '+  mapProds.get(li.Product).Name + ' (Disponivel: '+ (detalhe.cota__c - detalhe.consumo__c)+ ')';
                                            isFirst = false;
                                            productHasNoCota = true;
                                        }
                                    } else {
                                        quantityIsUnderQuota = true;
                                    }
                                }
                        }
                        
                    }
                    if (!productHasNoCota && !quantityIsUnderQuota) {
                        if(!isFirst) {
                            returnMessage = returnMessage + ',';
                        }
                        returnMessage = returnMessage +  mapProds.get(li.Product).Name +'(Para este cliente não há cota definida)';
                        isFirst = false; 
                    }
                    
                }
            }
            if (!isFirst) {
                return returnMessage;
            } else {
                return 'OK';
            }
    }

    public Static List<Lat_cotaMarket__c> getCotasToConsume(Date closeDate, List<String> linesProductsIds){
        
        return [Select id,LAT_Product__c,(SELECT id,cliente__c,bandeira__c,consumo__c,cota__c,endDate__c,startDate__c,executivo__c,prioridad__c,regional__c,segmento__c,sub_canal__c FROM Detalhes_Cota__r where startDate__c <=: closeDate and endDate__c >=: closeDate order by prioridad__c asc) from Lat_cotaMarket__c where LAT_Product__c in: linesProductsIds and startDate__c <=: closeDate and endDate__c >=: closeDate];
        
    }
}