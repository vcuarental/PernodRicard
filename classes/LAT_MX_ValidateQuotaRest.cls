@RestResource(urlMapping='/LAT_MX_ValidateQuotaRest/*')
global with sharing class LAT_MX_ValidateQuotaRest {
    
    global class LineaPedido {
        global String Product;
        global Integer Quantity;
    }

    @HttpPost
    global static void post(List<LineaPedido> lineas, String idCliente) {
        System.debug('%%%%% lineas : '+lineas);
        System.debug('%%%%% idCliente : '+idCliente);      

        String resultado = validarQuotas(lineas, idCliente);
        
        Boolean success = (resultado == 'OK');
        RestContext.response.addHeader('Content-Type', 'application/json');
        RestContext.response.responseBody = Blob.valueOf('{ "success": "'+success+'", "message": "'+resultado+'"  }');
    }

    public static String validarQuotas(List<LineaPedido> lineas, String idCliente) {
    	String retorno 	= '';
    	Boolean isFirst = true; 
    	Map<String, LineaPedido> lineasByProd = new Map<String, LineaPedido>();
        for (LineaPedido linea : lineas) {
        	lineasByProd.put(linea.Product, linea);
        }
    	List<LAT_MX_QTA_Quota__c> quotasVigentes = [SELECT Id, LAT_MX_QuotaBalance__c, LAT_Product__c, LAT_Product__r.Name FROM LAT_MX_QTA_Quota__c 
    												WHERE LAT_MX_Client__c =: idCliente AND LAT_Product__c IN :lineasByProd.keySet()
    												AND LAT_MX_ValidityUntil__c >=: date.Today() AND LAT_MX_ValiditySince__c <=: date.Today()];
    	
    	if(quotasVigentes.size() > 0) {
    		for(LAT_MX_QTA_Quota__c q : quotasVigentes) {
    			if(q.LAT_MX_QuotaBalance__c < lineasByProd.get(q.LAT_Product__c).Quantity) {
    				if(!isFirst) {
                        retorno = retorno + ',';
                    } 
                    retorno = retorno +' '+  q.LAT_Product__r.Name + ' (Disponible: '+ q.LAT_MX_QuotaBalance__c + ')';
                    isFirst = false;
    			}
    		}
    	}
    	if (retorno == '') {
    		retorno = 'OK';
    	} else {
    		retorno = 'No hay cuota disponible para los siguientes productos: ' + retorno;
       	}

    	return retorno;
    }

}