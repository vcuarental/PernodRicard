<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>ASI_CRM_JP_Set_Ex_Price</fullName>
        <field>ASI_CRM_Sys_Ex_Price__c</field>
        <formula>BLANKVALUE(ASI_CRM_Item_Group__r.ASI_CRM_Ex_Price__c, 0) - BLANKVALUE(ASI_CRM_Item_Group__r.ASI_CRM_Semi_Direct_Rebate_Price__c, 0)</formula>
        <name>Set Ex Price</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>ASI_CRM_JP_Copy_Ex_Price</fullName>
        <actions>
            <name>ASI_CRM_JP_Set_Ex_Price</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>CONTAINS(RecordType.DeveloperName, &apos;ASI_CRM_JP_&apos;) &amp;&amp;  OR(ISNEW(),  ISCHANGED( ASI_CRM_Item_Group__c )||ISCHANGED(  ASI_CRM_Reg_Volume_Monthly__c ) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
