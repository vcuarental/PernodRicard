<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>ASI_CRM_CN_TOV_Line_copySUM</fullName>
        <field>ASI_CRM_CN_Copy_SUM__c</field>
        <formula>ASI_CRM_CN_SUM__c</formula>
        <name>ASI CRM CN TOV Line copy SUM</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ASI_CTY_CN_WS_TOV_Item_Set_Qty_CA_Rollup</fullName>
        <field>ASI_CTY_CN_WS_Order_Qty_CA_RollUp__c</field>
        <formula>ASI_CTY_CN_WS_Order_Qty_CA__c</formula>
        <name>ASI_CTY_CN_WS_TOV_Item_Set_Qty_CA_Rollup</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>ASI_CRM_CN_TOV_Line_copySUM</fullName>
        <actions>
            <name>ASI_CRM_CN_TOV_Line_copySUM</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>ASI_CRM_TOV_Detail__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>CN TOV Detail</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>ASI_CTY_CN_WS_TOV_Item_Set_Qty_CA_Rollup</fullName>
        <actions>
            <name>ASI_CTY_CN_WS_TOV_Item_Set_Qty_CA_Rollup</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>NOT( ISBLANK(  ASI_CTY_CN_WS_Order_Qty_CA__c  ) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
