/********************************************************************
* Company: Valuenet 
* Desarrollador: Elena J. Schwarzböck

* Nombre del pagina: LAT_MX_VFC01_GeneratePromNoteController
* Descripcion: controlador de la pagina LAT_MX_VFC01_GeneratePromNote.
* Fecha: 25/09/2013 
*********************************************************************/

public with sharing class LAT_MX_VFC01_GeneratePromNoteCtrl {
  
    public LAT_MX_PMN_PromissoryNote__c pagare {get;set;}
    public String DueDate {get;set;}
    public String Today {get;set;}
    public String ImporteEnTexto {get;set;}
    
    map<Integer, String> mapMonths = new Map<Integer, String>{
        1 => 'Enero', 2 => 'Febrero', 3 => 'Marzo', 4 => 'Abril', 5 => 'Mayo', 6 => 'Junio',
        7 => 'Julio', 8 => 'Agosto', 9 => 'Septiembre', 10 => 'Octubre', 11 => 'Noviembre', 12 => 'Diciembre'    
    };        
    
    
    public LAT_MX_VFC01_GeneratePromNoteCtrl(){

        String idPagare = Apexpages.currentPage().getParameters().get('idPagare');
        
        pagare = [SELECT LAT_MX_Executor__r.Name, LAT_MX_DueDate__c, LAT_MX_Amount__c, LAT_MX_Street__c, LAT_MX_Neighbourhood__c, LAT_MX_County__c, LAT_MX_City__c, LAT_MX_State__c, LAT_MX_PostalCode__c, LAT_MX_RFC__c, LAT_MX_LegalRepresentative__c, LAT_MX_Consignature1__c, LAT_MX_Consignature2__c FROM LAT_MX_PMN_PromissoryNote__c WHERE Id =: idPagare];
        
        DueDate = '';
        if(pagare.LAT_MX_DueDate__c != null){
            DueDate = ', el día ' + pagare.LAT_MX_DueDate__c.day() + ' de ' + mapMonths.get(pagare.LAT_MX_DueDate__c.month()) + ' de ' + pagare.LAT_MX_DueDate__c.year();
        }
        Today = date.today().day() + ' de ' + mapMonths.get(date.today().month()) + ' de ' + date.today().year();
        Decimal num = pagare.LAT_MX_Amount__c;
        String numS = String.valueOf(num);
        Long ParteEntero = Long.valueOf(numS.substring(0,numS.length()-3));
        Long ParteDecimal = Long.valueOf(numS.substring(numS.length()-2, numS.length()));
        
        ImporteEnTexto = ConvertNumberToText(ParteEntero,ParteDecimal);
    
    }
    
    static String[] unidades = new string[]{  '', 'un ', 'dos ', 'tres ','cuatro ', 'cinco ', 'seis ', 'siete ', 'ocho ', 'nueve', 'diez ','once ', 'doce ', 'trece ', 'catorce ', 'quince ', 'dieciseis','diecisiete', 'dieciocho', 'diecinueve', 'veinte' };
    static String[] decenas = new string[]{ '','', 'veinti', 'treinta ', 'cuarenta ','cincuenta ', 'sesenta ', 'setenta ', 'ochenta ', 'noventa '};
    static String[] centenas = new string[]{ '', 'ciento ', 'doscientos ','trescientos ', 'cuatrocientos ', 'quinientos ', 'seiscientos ','setecientos ', 'ochocientos ', 'novecientos ' };
    static String[] denom = new string[]{ '','mil', 'millones', 'billones', 'trillones', 'cuatrillones', 'quintillones', 'decillones'};
    static String[] denom2 = new string[]{ '','mil', 'millón', 'billón', 'trillón', 'cuatrillón', 'quintillón', 'decillón'};
    static Boolean UltimosTres = false;
            
    public static String ConvertNumberToText(Long val, Long val2) {
        String ret;
        if (val < 1000){
            UltimosTres = true;
            ret = Convert_nnn(val);
            if(val == 1){
                ret += ' peso';
            } else { 
                ret += ' pesos';
            }
            /*if(val2 > 1){ //true si tiene decimales mayores a 1 centavo
                ret += ' con ' + Convert_nnn(val2) + ' centavos';
            } else if( val2 == 1){ //true si tiene 1 centavo
                ret += ' con 1 centavo';
            } else {
                ret += ' con cero centavos';
            }*/
            if(val2 == 0){
                ret += ' 00/100';
            }else if(val2 < 10){
                ret += ' 0' + val2 + '/100'; 
            }else{
                ret += ' ' + val2 + '/100';
            }         
            return ret;
        }
        if(val == 1000){
            ret = 'mil pesos';
            /*if(val2 > 1){ //true si tiene decimales mayores a 1 centavo
                ret += ' con ' + Convert_nnn(val2) + ' centavos';
            } else if( val2 == 1){ //true si tiene 1 centavo
                ret += ' con 1 centavo';
            } else {
                ret += ' con cero centavos';
            }*/
            if(val2 == 0){
                ret += ' 00/100';
            }else if(val2 < 10){
                ret += ' 0' + val2 + '/100'; 
            }else{
                ret += ' ' + val2 + '/100';
            }  
            return ret;
        }            
        for (integer v = 0; v < denom.size(); v++) {
            if(v + 1 == denom.size()){
                UltimosTres = true;
            }
            Integer didx = v - 1;
            long dval = (long)Math.pow(1000, v);
            if (dval > val) {
                Long mod = (long)Math.pow(1000, didx);
                Long l = (long) val / mod;
                Long r = (long) val - (l * mod);
                system.debug('MOD: ' + mod + ' L: ' + l + ' R: ' + r);
                if(l == 1 && didx > 1){ //si es millones, billones, trillones, etc uso denom2 porq tiene q ser singular
                    ret = Convert_nnn(l) + ' ' + denom2[didx];
                } else {
                    ret = Convert_nnn(l) + ' ' + denom[didx];
                }
                if (r > 0) {
                    ret += ' ' + ConvertNumberToText(r,0);
                }
                ret += ' pesos';
                /*if(val2 > 1){ //true si tiene decimales mayores a 1 centavo
                    ret += ' pesos con ' + Convert_nnn(val2) + ' centavos';
                } else if( val2 == 1){
                    ret += ' con 1 centavo';
                } else {
                    ret += ' con cero centavos';
                }*/
                if(val2 == 0){
                    ret += ' 00/100';
                }else if(val2 < 10){
                    ret += ' 0' + val2 + '/100'; 
                }else{
                    ret += ' ' + val2 + '/100';
                } 
                return ret;              
            }     
        }
        return ret;
    }
    
    public static String Convert_nnn(Long val) {
        String word = '';
        Integer cent = Integer.valueOf(val / 100); //en cent se guarda la centena
        Integer dec = Integer.valueOf((math.mod(val,100)) / 10); //en dec se guarda la decena
        Integer uni = Integer.valueOf(math.mod((math.mod(val,100)), 10)); //se guarda la unidad
        Integer UltimosDos = Integer.valueOf(math.mod(val,100)); //se guardan los ultimos dos por casos especiales
        if (cent > 0) {
            word = centenas[cent];
            if(cent == 1 && dec == 0 && uni == 0 ){ //si true es porque es 100
                word = 'cien';
            }       
        }
        if (dec > 0){
            if(UltimosDos <= 20){ //si true son casos especiales y los saco de unidades
                word += unidades[UltimosDos];
                return word; 
            } else {
                word += decenas[dec];
            }
        }
        if (uni > 0) {
            if(UltimosTres && UltimosDos == 21){//true si es son los ultimos 3 numeros y los ultimos 2 son 21
                word += 'uno';
            } else if(dec == 0 || (dec == 2 || dec == 3)){//caso especial para 
                word += unidades[uni];
            } else if (UltimosTres && uni == 1){
                word += ' y uno';
            } else {
                word += ' y ' + unidades[uni];
            }
        }
        return word;
    }

}