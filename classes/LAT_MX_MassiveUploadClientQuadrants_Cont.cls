public with sharing class LAT_MX_MassiveUploadClientQuadrants_Cont {
    
    public Blob toParse             {get; set;}
    public String successMessage    {get; set;}
    public String errorMessage      {get; set;}
    private static final String VALORES_CUADRANTES = ' Estrella , Lupa , Contribuyente , Volumen ';

    public LAT_MX_MassiveUploadClientQuadrants_Cont() {
        
    }

    public void upload() {

        try{
            successMessage  = '';
            errorMessage    = '';
            List <String> lines = new List<String>();
            try {
                lines = toParse.toString().split('\n');
                System.debug('lines size ---->' + lines.size());
            } catch (System.ListException e) {
                System.debug('Limits exceeded?' + e.getMessage());
            }

            //List<List<String>> values = LAT_Utils.parseCSV(toParse.toString(), true);
            
            system.debug('lines---->' + lines);

            if(lines.size() <= 0){
                //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'El archivo no contiene datos.'));
                errorMessage = 'Error : El archivo no contiene datos.';
            } else {
                Map<String, LineWrapper> mapCuadranteXIds = new Map<String, LineWrapper>();
                String lineasConError   = '';
                String lineasVacias     = '';
                Integer lineaActual     = 1;
                lines.remove(0);
                for (String line: lines) {
                    lineaActual++;
                    List<String> valList = line.split(',');
                    if(valList.size() ==1) {
                        valList = line.split(';');
                    }
                    System.debug('%%%%%%%. valList :' + valList);
                    if(valList.size() >= 1) {
                        //System.debug('%%%%%%%. valList :' + valList);
                        //List<String> linea = valList[0].replaceall('"','').split('",');
                        if(valList.size() > 1) {
                            if(valList[1].length() > 14) {
                                valList[1] = valList[1].replaceall('"','');
                                System.debug('%%% valList[1] : ' + valList[1]);
                                if(valList.size() >= 4) {
                                    valList[3] = valList[3].replaceall('"','');
                                    System.debug('%%% valList[3] : ' + valList[3]);
                                    System.debug('%%% VALORES_CUADRANTES : ' + VALORES_CUADRANTES);
                                    System.debug('%%% VALORES_CUADRANTES.containsIgnoreCase(valList[3]) : ' + VALORES_CUADRANTES.containsIgnoreCase(valList[3]));
                                    //if(VALORES_CUADRANTES.containsIgnoreCase(valList[3])) {
                                        System.debug('EEEntro.');
                                        LineWrapper lw = new LineWrapper(valList[3], String.valueOf(lineaActual));
                                        mapCuadranteXIds.put(valList[1].substring(0,15), lw);
                                    /*} else {
                                        if(valList.size() > 4) {
                                            String cuad = valList.get(valList.size()-1);
                                            cuad = cuad.replaceall('"','');
                                            LineWrapper lw = new LineWrapper(cuad, String.valueOf(lineaActual));
                                            //valList.get(valList.size()-1) = valList.get(valList.size()-1).replaceall('"','');
                                            //LineWrapper lw = new LineWrapper(valList.get(valList.size()-1), String.valueOf(lineaActual));
                                            mapCuadranteXIds.put(valList[1].substring(0,15), lw);
                                            //lineasConError += '- Línea : '+lineaActual + ' Id : ' + valList[1] + ' con Error : El nombre del Cliente contiene comas.';
                                        } else {
                                            lineasConError += '- Línea : '+lineaActual + ' Id : ' + valList[1] + ' con Error : Valor de Cuadrante Inválido.';
                                        }
                                        
                                    }*/
                                    
                                } else {
                                    
                                    lineasConError += '- Línea : '+lineaActual + ' Id : ' + valList[1] +  ' con Error : ';
                                    
                                }
                                
                            } else {
                                lineasConError += '- Línea : '+lineaActual + ' Id : ' + valList[1] +  ' con Error.';
                            }
                            
                        } else {
                            lineasVacias += '- Línea : '+lineaActual +' - Línea Vacía.';
                        }
                    }
                }
                system.debug('ids---->'+mapCuadranteXIds.keySet());

                List<LAT_Account__c> toUpdate = [SELECT Id, LAT_MX_CuadranteClientes__c, LAT_AccountId__c FROM LAT_Account__c WHERE LAT_AccountId__c IN :mapCuadranteXIds.keySet()];
                System.debug('%%%% Cuentas Encontradas : '+toUpdate.size());

                if(toUpdate != null && toUpdate.size() > 0) {

                    System.debug('mapCuadranteXIds KeySet : ' + mapCuadranteXIds.keySet());
                    System.debug('mapCuadranteXIds Values : ' + mapCuadranteXIds.values());
                    for (LAT_Account__c latAcc : toUpdate) {
                        latAcc.LAT_MX_CuadranteClientes__c = mapCuadranteXIds.get(String.valueOf(latAcc.LAT_AccountId__c).substring(0,15)).cuadrante;
                        mapCuadranteXIds.remove(String.valueOf(latAcc.LAT_AccountId__c).substring(0,15));
                    }
                    
                    
                    if(!mapCuadranteXIds.isEmpty()) {
                        for (LineWrapper lw : mapCuadranteXIds.values()) {
                            lineasConError += ' - Linea : '+lw.lineaEnCsv + ' con Error : No se encontró el Id del Cliente.';
                        }
                        //lineasConError = 'Las siguientes Líneas tienen errores, favor revisar: ' + lineasConError + lineasVacias;
                    }
                    if(toUpdate.size() > 0 && lineasConError.length() < 1)  {
                        //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM,'Se actualizaron con éxito los Cuadrantes de ' + toUpdate.size() + ' Clientes.'));
                        update toUpdate;
                        successMessage = 'Se actualizaron con éxito los Cuadrantes de ' + toUpdate.size() + ' Clientes.';

                    }

                    if(lineasConError != '') {
                        //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, lineasConError));
                        errorMessage = 'Las siguientes Líneas tienen errores, favor revisar: ' + lineasConError;
                    }

                    

                } else {
                    //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'El archivo no contiene datos válidos.'));
                    errorMessage = 'Error : El archivo no contiene datos validos.';
                }
                
            }
        } catch(exception e) {
            //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage()));
            errorMessage = 'Error : ' + e.getMessage();
        }
    }

    public  class LineWrapper {
        String cuadrante    {get; set;}
        String lineaEnCsv   {get; set;}

        public LineWrapper(String c, String l) {
            this.cuadrante   = c.replaceAll('"','');
            this.lineaEnCsv  = l;
        }
    }   

    public PageReference salir() {
        return new PageReference('/home/showAllTabs.jsp');
    }
}