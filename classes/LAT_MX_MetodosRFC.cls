public with sharing class LAT_MX_MetodosRFC {
	
public static void ValidationCNPJduplicate(List<LAT_MX_RFC__c> triggerNew) {
		 List<LAT_MX_RFC__c> rfcDuplicados = new List<LAT_MX_RFC__c>();
		 List<LAT_MX_RFC__c> todosLosRFc = [SELECT LAT_RFC__c from LAT_MX_RFC__c];
		 Set<String> rfcName = new Set<String>() ; 

		 if(todosLosRFc != null && todosLosRFc.size() > 0){ 
		 		for (LAT_MX_RFC__c r : todosLosRFc) {
		 			rfcName.add(r.LAT_RFC__c);
		 		}
		 

		 		for (LAT_MX_RFC__c r : triggerNew) { 
			 		if (rfcName.contains(r.LAT_RFC__c ))
			 			rfcDuplicados.add(r); 
			 	}
			 if(rfcDuplicados != null && rfcDuplicados.size() > 0){
				 String error = 'El siguiente RFC ya esta siendo utilizado :   ';
				 for(LAT_MX_RFC__c r : rfcDuplicados){
				 		error = error + r.LAT_RFC__c;
				 		r.LAT_RFC__c.addError(error);
				 }
			} 	
		}
}

public static void ValidationRFC(List<LAT_MX_RFC__c> triggerNew){                
        Boolean esValido = false;
        List<LAT_MX_RFC__c> listRFCAcc = [SELECT LAT_RFC__c from LAT_MX_RFC__c];
        Set<String> rfcs = new Set<String>();
        for(LAT_MX_RFC__c r : listRFCAcc){
            rfcs.add(r.LAT_RFC__c);
        }
        for (LAT_MX_RFC__c rf: triggerNew){   
            if(rf.LAT_RFC__c == 'XAXX010101000' || rf.LAT_RFC__c == 'XEXX010101000'){
                String error = 'RFC que se pretende usar correposnde a venta de mostrador';
                rf.LAT_RFC__c.addError(error);
            }
            if(!validarFormatoRFC(rf.LAT_RFC__c)){
                String error = 'El RFC '+rf.LAT_RFC__c+ ' es inválido. Debe tener 3 o 4 letras, 6 números (YYMMDD) y 3 letras o números';
                rf.LAT_RFC__c.addError(error);
            }
        }
}
    
    private static boolean validarFormatoRFC (String rfcText) {
        Boolean valido = false;
        if(rfcText.length() == 12){
            String primeraParte = rfcText.substring(0,3);
            String segundaParte = rfcText.substring(3,9);
            String terceraParte = rfcText.substring(9,12);
            String year = rfcText.substring(3,5);
            String month = rfcText.substring(5,7);
            String day = rfcText.substring(7,9);
            if(!primeraParte.isNumeric() && segundaParte.isNumeric() && validarFecha(year,month,day))
                    valido=true;
        }    
        if(rfcText.length() == 13){    
            String primeraParte2 = rfcText.substring(0,4);
            String segundaParte2 = rfcText.substring(4,10);
            String terceraParte2 = rfcText.substring(10,13);
            String year = rfcText.substring(4,6);
            String month = rfcText.substring(6,8);
            String day = rfcText.substring(8,10);
            if(!primeraParte2.isNumeric() && segundaParte2.isNumeric() && validarFecha(year,month,day))
                    valido=true;
        }
        return valido;
    }
    private static boolean validarFecha (String year , String month , String day) {
        Date d = null;
        boolean valid = true;
        try {
            d = Date.parse(day + '/'+ month + '/' + year);
        } catch (Exception e) {
                valid = false;
        }
        return valid;
    }

   private static boolean buscarExcepcion(String cnpj){
        List<LAT_RFC__c> tmpList = [Select id from LAT_RFC__c where status__c = 'Aprobado' AND rfc__c =: cnpj limit 1];
        if (tmpList != null && tmpList.size() > 0)return true;
        return false;
    }


	private static boolean CalculoValidacion(String cnpj){
    	
        Map<String, Integer> mapValoresRFC = new Map<String, Integer> {
            '0' => 0,'1' => 1,'2' => 2,'3' => 3,'4' => 4,'5' => 5,'6' => 6,'7' => 7,'8' => 8,'9' => 9,
            'A' => 10,'B' => 11,'C' => 12,'D' => 13,'E' => 14,'F' => 15,'G' => 16,'H' => 17,'I' => 18,
            'J' => 19,'K' => 20,'L' => 21,'M' => 22,'N' => 23,'Ñ' => 24,'O' => 25,'P' => 26,'Q' => 27,
            'R' => 28,'S' => 29,'T' => 30,'U' => 31,'V' => 32,'W' => 33,'X' => 34,'Y' => 35,'Z' => 36       
        };        
        Integer suma = 0;   
        cnpj = cnpj.toUpperCase();   
        for(Integer i = cnpj.length(); i >= 2 ; i--){  
            if( !mapValoresRFC.containsKey(cnpj.mid(cnpj.length()-i,1)) ){
                return false;
            }     
            if (cnpj.length() == 12 && i == 12){
                suma = suma + (37 * 13);  
            }
            suma = suma + (mapValoresRFC.get(cnpj.mid(cnpj.length()-i,1))*i);                  
        }           
        Integer resto = math.mod(suma, 11);
        resto = 11 - resto;

        if(resto == 10){
            if(cnpj.mid(cnpj.length()-1,1) == 'A'){
                return true;
            }else{
                return false;
            }
        }else if(resto == 11){
            resto = 0;
        }                       
        if(String.valueOf(resto).equals(cnpj.mid(cnpj.length()-1,1))){
            return true;
        }else{
            return false;
        }        
                             
    }   
}