/*******************************************************************************
*                     Copyright (C) 2012 - Cloud2b
*-------------------------------------------------------------------------------
*
* Recupera a identificação de um tipo de registro
* NAME: RecordTypeForTest.cls
* AUTHOR: ROGERIO ALVARENGA                         DATE: 04/09/2012
*
*-------------------------------------------------------------------------------
* MAINTENANCE
* AUTHOR:                                           DATE:
*******************************************************************************/
public with sharing class RecordTypeForTest {
  
  private static Map< String, Map< String, Id > > fRecTypes = new Map< String, Map< String, Id > >();
  static {
    List< RecordType > lList = [ select id, SobjectType, DeveloperName from RecordType ];
    for ( RecordType lRec : lList )
    {
      Map< String, Id > lObjMap = fRecTypes.get( lRec.SobjectType );
      if ( lObjMap == null )
      {
        lObjMap = new Map< String, Id >();
        fRecTypes.put( lRec.SobjectType, lObjMap );
      }
      lObjMap.put( lRec.DeveloperName, lRec.id );
    }
  }
  
  public static id getRecType( String aObj, String aDevName )
  {
    Map< String, Id > lObjMap = fRecTypes.get( aObj );
    if ( lObjMap == null ) return null;
    return lObjMap.get( aDevName );
  }
}