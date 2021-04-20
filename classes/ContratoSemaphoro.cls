/*******************************************************************************
*                     Copyright (C) 2012 - Cloud2b
*-------------------------------------------------------------------------------
*
* Classe que faz um semáforo para o contrato.
* NAME: ContratoSemaphoro.cls
* AUTHOR: ROGERIO ALVARENGA                         DATE: 18/08/2012
*
*******************************************************************************/

public with sharing class ContratoSemaphoro {
  
  private static Map< String, Map< String, String >> mapCodesInExecution;
    
    static{
      mapCodesInExecution = new Map< String, Map< String, String >>();
    }
    
    public static Boolean setNewCode( String aIdRecord, String aCodeName ){
      
      Map< String, String > mapCode = new Map< String, String >();
      if( mapCodesInExecution.containsKey( aIdRecord ) ) {
        mapCode = mapCodesInExecution.get( aIdRecord );
        if( mapCode.containsKey( aCodeName ) ) return true;
      }
      
      mapCode.put( aCodeName, aCodeName );
      mapCodesInExecution.put( aIdRecord, mapCode );
      return false;
    }
    
    public static boolean alreadyRun( String aIdRecord )
    {
      return mapCodesInExecution.containsKey( aIdRecord );
    }
}