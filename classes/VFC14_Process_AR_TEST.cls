/****************************************************
*Dev: Denis Aranda  Version: 1  Consulting: Valuenet*
****************************************************/

@IsTest
public with sharing class VFC14_Process_AR_TEST { 

    static testMethod void UnitTest(){
        VFC14_Process_AR test = new VFC14_Process_AR();
        test.updatesOfAnalitics();
        test.hours = '7';
        test.minutes = '8';
        test.doSaveHours();
        test.getListHours();
        test.getListMinutes();
        test.runInventory();
        test.runReportAtivado();
        test.runReportAtivadoAP();
        test.saveColletaTaskAuto();
        test.doCalculateBDContratos();
        test.doSaveMonths();
        test.doSaveCheckNotifications();
        test.doallowCreateReceipt();
       // test.doSave();
        try{ test.doSaveCheckBox();}catch(Exception e){}
    }
}